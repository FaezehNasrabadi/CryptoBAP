(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec - tools under a BSD license.
    See LICENSE file for copyright notice.
*)

open Common
open Type
open Sym
open Sym.Op
open Sym.Arith
open Exp

module E = Exp
module S = Solver

module Stats = Stats_local


(**
   OLD

   Simplifies an expression.
   Currently following transformations types are performed, given suitable conditions:
   - [Range(String) -> String]
   - [Range(Range(X)) -> Range(X)]
   - [Range(X) -> X]
   - [Concat(Range(X), Range(X)) -> Range(X)]
   - [Concat(String, String) -> String]
   - [Range(Concat(X, Y)) -> Concat(X)]

   Assumes that all subexpressions have already been simplified.

   Accepts ranges that do not fulfill the invariant. The behaviour then is as
   follows: if length is not [All], the parts of the range that are outside of
   the expression are filled with [undef]. If length is [All] and position is
   not within the expression, an empty expression is returned.
*)
let rec simplify : type a.  a Exp.t -> a Exp.t = fun e ->

  let undef l =
    let e = Sym (Undef (Var.fresh_id "undef"), []) in
    S.assume [E.eq_int [Len e; l]];
    e
  in

  let mk_encoder = function
    | [e] -> e
    | es -> Concat es
  in

  (* don't think this can be optimised much *)
  let rec encoder = function
      (* Concat nesting might give useful hints about message formats, but for now we flatten all encoders *)
    | Concat es' :: es -> encoder (es' @ es)
    | Range (e1, pos1, len1) :: Range (e2, pos2, len2) :: es
        when S.equal_int pos2 (sum [pos1; len1]) && e1 = e2 ->
      encoder (simplify (Range (e1, pos1, sum [len1; len2])) :: es)
    (* FIXME: return string encoderenation when you also do corresponding arithmetic simplifications for lengths *)
    (* | String s1 :: String s2 :: es -> encoder (String (s1 ^ s2) :: es) *)
    | e :: es when S.equal_int (Len e) E.zero -> encoder es
    | e :: es -> e :: encoder es
    | [] -> []

  (* don't think this can be optmised much *)
  and cut (pos : iterm) (es : bterm list) : (bterm list * bterm list) option =
    (* debug ("cut, pos: " ^ E.dump pos);
    debug ("cut, es: " ^ E.dump (Concat es)); *)
    match es with
        (* in case the range extends beyond the end of the expression, we add an undefined chunk *)
      | [] -> Some ((if S.equal_int pos E.zero then [] else [undef pos]), [])
      | e :: es ->
        let l = Len e in
        match S.greater_equal_len_answer l pos with
        | S.Yes ->
            Some ([simplify (Range (e, E.zero, pos))],
                   simplify (Range (e, pos, E.minus l pos)) :: es)
        | S.Maybe -> None
        | S.No ->
            let pos' = E.minus pos l in
            match cut pos' es with
              | Some (es1, es2) -> Some (e :: es1, es2)
              | None -> None

  and cut_left pos es =
    match cut pos es with
    | Some (left, _) -> Some (encoder left)
    | None -> None

  and cut_right pos es =
    match cut pos es with
    | Some (_, right) -> Some (encoder right)
    | None -> None

  in
  let default = S.simplify in

  let simplify (type a) (e_orig : a Exp.t) : a Exp.t =
    match e_orig with
    | Sym (Int_op _, _) as e -> E.arith_simplify e

    (* The ztp business is based on user-defined equations Ztp_safe(e) = e, and
       so actually relies on the solver. *)
    | Sym (Ztp, [String cs]) as e ->
      let rec up_to_zero acc = function
        | [] -> None
        | c :: cs ->
          if Char.code c = 0
          then Some (List.rev acc)
          else up_to_zero (c :: acc) cs
      in
      begin match up_to_zero [] cs with
      | Some cs -> String cs
      | None -> e
      end

    | Sym (Ztp, [Concat es]) ->
      let rec apply_ztp acc = function
        | e :: _ when S.equal_bitstring e E.zero_byte ->
          Sym (Ztp_safe, acc) |> simplify
        | e :: es -> apply_ztp (acc @ [e]) es
        | [] -> default e_orig
      in
      apply_ztp [] es

    | Sym (Ztp_safe, [e]) when S.equal_bitstring e_orig e -> e

    | Range (e, pos, len) ->
      begin
        let e_len = Len e in
        let new_len = arith_simplify len in
        let e_new = Range (e, pos, new_len) in
        DEBUG "simplify: e_len = %s" (E.dump e_len);
        DEBUG "simplify: new_len = %s" (E.dump new_len);
        match e with
        (* OLD?: unfortunately e_len is not always known, so we need the disjunction *)
        (* e when S.greater_equal_len new_len e_len -> e *)
        | e when S.equal_int E.zero pos && S.equal_int len e_len -> e
        | _ when S.greater_equal_len E.zero new_len -> Concat []
        | String bs ->
          begin
            match S.eval pos, S.eval new_len with
            | Some pos, Some len ->
              if pos + len <= List.length bs
              then String (List.sub bs ~pos ~len)
                (* Unfortunately can't get rid of this case - not all buffers are filled
                   from left to right. *)
              else Concat
                [String (List.sub bs ~pos ~len:(List.length bs - pos));
                 undef (E.int (len + pos - List.length bs)) ]
            | _ -> e_new
          end
        | Concat es ->
          begin
            match cut_right pos es with
            | None -> e_new
            | Some es1 ->
              (* debug ("cut_right result: " ^ E.dump (Concat es1)); *)
              match cut_left len es1 with
              | Some es2 ->
                (* debug ("cut_left result:" ^ E.dump (Concat es2)); *)
                mk_encoder es2
              | None -> Range (mk_encoder es1, E.zero, new_len)
          end
        (* | Range (_, _, len') when len' <> All && len = All ->
           fail "simplify: e{pos1, l}{pos2, All} with l <> All and pos2 <> 0 is considered suspicious" *)
        (* FIXME: still need to check that new_len is smaller than len' *)
        | Range (e', pos', _) -> simplify (Range (e', sum [pos'; pos], new_len))
        (* | Range (e', pos', _) -> simplify (Range (e', L.add_len pos' pos, len)) *)

        (* FIXME: need to check that we don't cut the boundary if e_byte has length > 1 *)
        | Sym (Replicate, [e_byte]) -> Sym (Replicate, [e_byte])
        | _ -> e_new
      (* | _ -> e_orig *)
      end

    | Concat es -> mk_encoder (encoder es)

    | e -> default e
  in

  DEBUG "simplify: %s" (E.dump e);
  push_debug "simplify";
  let e = simplify e in
  pop_debug "simplify";
  DEBUG "simplify result: %s" (E.dump e);
  e

let rec deep_simplify : type a. a exp -> a exp = fun e ->
  let e = simplify e in
  (* Do not simplify opaque expressions so as not to confuse the solver. *)
  if S.is_opaque e then e
  else E.descend {E.descend = deep_simplify} e

let rec full_simplify e =
  DEBUG "full_simplify: %s" (E.dump e);
  push_debug "full_simplify";
  let e'= deep_simplify e in
  let result = if e' = e then e' else full_simplify e' in
  pop_debug "full_simplify";
  DEBUG "full_simplify result: %s" (E.dump result);
  result

let full_simplify e =
  Stats.call "full_simplify" (fun () -> full_simplify e)

(*************************************************)
(** {1 Testing.} *)
(*************************************************)

let test_result ~expect actual =
  if expect <> actual
  then fail "Expected: \n%s\ngot \n%s\n" (E.to_string expect) (E.to_string actual)

let test_nothing_to_simplify () =
  let e = Sym (Defined, [Sym (Ztp, [Exp.var_s "v"])]) in
  S.assume [e];
  test_result (simplify e) ~expect:e;
  test_result (full_simplify e) ~expect:e

(* ((2)^[u,8] ( * : [u,8] * [u,8] -> [u,8]) (8)^[u,8])_[u,8] *)
let test_simplify_bs_arithmetic () =
  push_debug "Simplify.test_simplify_bs_arithmetic";
  let itype = Int_type.create `Unsigned 8 in
  let two = BS (Int 2L, itype) in
  let eight = BS (Int 8L, itype) in
  let op_type = ([Bs_int itype; Bs_int itype], Bs_int itype) in
  let bs_prod = Sym (Op (Op_arith (Mult 2), op_type), [two; eight]) in
  let e = Val (bs_prod, itype) in
  test_result (full_simplify e) ~expect:(Sym (Int_op (Mult 2), [Int 2L; Int 8L]));
  pop_debug "Simplify.test_simplify_bs_arithmetic"

let test () =
  test_nothing_to_simplify ();
  test_simplify_bs_arithmetic ()

(* 280 lines *)
