(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common

open Sym
open Exp
open Iml
open Iml.Pat
open Iml.Stmt

module E = Exp
module S = Solver

open Typing
open Transform

(********************************************************)
(** {1 Replace inverse functions by pattern matching} *)
(********************************************************)

let is_inverse f =
  match Str.split (Str.regexp "_") f with
  | "inverse" :: _ -> true
  | _ -> false

let inverse_of f =
  Fun (Str.replace_first (Str.regexp "inverse_") "" f,
       (1, Kind.Bitstring))

let rec check_no_inverse : type a. a exp -> unit = fun e ->
  match e with
  | Sym (Fun (f, _), _) when is_inverse f ->
    fail "inverse function not directly in let-bindig: %s" (E.to_string e)
  | e -> E.iter_children {E.f = check_no_inverse} e

let rec match_inverse p =
  match p with
    | Let (VPat v, Sym (Fun (f, _), [e])) :: p when is_inverse f ->
      Let (FPat (inverse_of f, [VPat v]), e) :: match_inverse p

    | s :: p ->
      Stmt.iter_children {E.f = check_no_inverse} s;
      s :: match_inverse p

    | [] -> []

(*************************************************)
(** {1 Use pattern matching for safe parsing} *)
(*************************************************)

let mk_pattern f_c arity v i =
  let pat = List.replicate arity Underscore in
  FPat (f_c, List.set_element i (VPat v) pat)

(**
  Expects formatting-normal form.
*)
let match_safe_parsers fun_types syms facts p =
  let encoders = Syms.encoders syms in
  let parsing_eqs = Syms.parsing_eqs syms fun_types in
  let rec do_match facts = function
    | (Let (VPat v, Annotation (Parser _, Sym (Fun _ as f_p, [e])))) as s :: p ->
      begin match safe_parse fun_types encoders parsing_eqs facts f_p e with
      | Some (f_c, i) ->
        Let (mk_pattern f_c (Sym.arity f_c) v i, e) :: do_match facts p
      | None ->
        s :: do_match facts p
      end

    | s :: p ->
      s :: do_match (facts @ Stmt.facts s) p

    | [] -> []
  in
  do_match facts p

let merge_patterns ~fun_types p =

  let choose_symbol f vs f' vs' =
    let rec vote ts vs ts' vs' =
      match ts, vs, ts', vs' with
      | t :: ts, v :: vs, t' :: ts', v' :: vs' ->
        begin
          if t = t' then vote ts vs ts' vs'
          else match v, v' with
          | VPat _, Underscore ->
            f :: vote ts vs ts' vs'
          | Underscore, VPat _ ->
            f' :: vote ts vs ts' vs'
          | Underscore, Underscore ->
            vote ts vs ts' vs'
          | VPat _, VPat _ ->
            (* Types are not equal, so make an inconsistent vote. *)
            [f; f']
          | _ -> assert false
        end
      | [], [], [], [] -> []
      | _ -> assert false
    in
    let rec tally vote = function
      | [] -> vote
      | f :: fs ->
        match vote with
        | Some f'  ->
          if f = f' then tally (Some f) fs else None
        | None -> tally (Some f) fs
    in
    let ts, _  = Fun_type_ctx.find f  fun_types in
    let ts', _ = Fun_type_ctx.find f' fun_types in
    match vote ts vs ts' vs' with
    | [] -> Some f
    | fs -> tally None fs
  in

  let merge vpat vpat' =
    match vpat, vpat' with
    | VPat v, _ | Underscore, VPat v  -> VPat v
    | Underscore, Underscore -> Underscore
    | _ -> failwith "merge_patterns: impossible"
  in

  let merge_pattern = List.map2 ~f:merge in

  let rec match_vars pat pat' =
    match pat, pat' with
      | VPat v :: pat, VPat v' :: pat' ->
        (v', Var (v, Kind.Bitstring)) :: match_vars pat pat'
      | _ :: pat, _ :: pat' -> match_vars pat pat'
      | [], [] -> []
      | _ -> failwith "match_vars: impossible"
  in

  let rec collect_pattern f vs e p =
    match p with
    | [] -> [], FPat (f, vs)
    | s :: p ->
      let default () =
        let p, pat = collect_pattern f vs e p in
        s :: p, pat
      in
      match s with
      | Let (FPat (f', vs'), e') when e = e' ->
        begin match choose_symbol f vs f' vs' with
        | None -> default ()
        | Some f ->
          let vs = merge_pattern vs vs' in
          let xs, xs' = List.split (match_vars vs vs') in
          let p = Iml.subst xs xs' p in
          collect_pattern f vs e p
        end
      | _ -> default ()
  in

  let rec merge = function
    | Let (FPat (f, vs), e) :: p ->
      let p, pat = collect_pattern f vs e p in
      Let (pat, e) :: merge p
    | s :: p -> s :: merge p
    | [] -> []
  in
  merge p

let test_merge_patterns () =
  let f1 = Fun ("f1", (2, Kind.Bitstring)) in
  let f2 = Fun ("f2", (2, Kind.Bitstring)) in
  let e = String ['x'] in
  let p =
    [ Let (FPat (f1, [vpat "v1"; Underscore]), e)
    ; Let (FPat (f2, [Underscore; vpat "v2"]), e) ]
  in
  let t1 = Type.Named ("t1", None) in
  let t2 = Type.Named ("t2", None) in

  let fun_types =
    Fun_type_ctx.of_list [ f1, ([t1; t1], Type.Bitstring)
                         ; f2, ([t1; t2], Type.Bitstring)]
  in
  let p' = [ Let (FPat (f2, [vpat "v1"; vpat "v2"]), e) ] in
  test_result ~expect:p' (merge_patterns ~fun_types p) Iml.to_string;

  let fun_types =
    Fun_type_ctx.of_list [ f1, ([t1; t1], Type.Bitstring)
                         ; f2, ([t2; t2], Type.Bitstring)]
  in
  test_result ~expect:p (merge_patterns ~fun_types p) Iml.to_string

(*************************************************)
(** {1 Input and Output Merging} *)
(*************************************************)

let merge_in_out p =

  let rec merge_in (vs: var list) p =
    match (vs, p) with
    | vs, In [v] :: p -> merge_in (v :: vs) p
    | [], s :: p -> s :: merge_in [] p
    | vs, (Out _ as s) :: p ->
      In vs :: s :: merge_in [] p
    | vs, s :: p -> s :: merge_in vs p
    | vs, [] -> [In vs] (* including vs =  [] *)
  in

  (*
    Requires only-variables-in-write form.
  *)
  let rec merge_out es p =
  match (es, p) with
    | es, Out [e] :: p -> merge_out (e :: es) p
    | [], s :: p -> s :: merge_out [] p
    | es, (In _ as s) :: p ->
      Out es :: s :: merge_out [] p
    | es, s :: p -> s :: merge_out es p
    | [], [] -> [Yield]
    | es, [] -> [Out es]
  in

  List.rev (merge_in [] (List.rev (merge_out [] p)))

(*************************************************)
(** {1 Misc} *)
(*************************************************)

let verbose = true

let rec remove_casts : type a. a exp -> a exp = function
  | Sym (Op (Sym.Op.Cast_to_int, _), [e]) -> remove_casts e
  | e -> E.descend {E.descend = remove_casts} e

let debug_iml client server title =
  if verbose
  then begin
    prerr_title title;
    prerr_endline "Client = ";
    prerr_endline (Iml.to_string client);
    prerr_endline "Server = ";
    prerr_endline (Iml.to_string server)
  end

let test () =
  test_merge_patterns ()

