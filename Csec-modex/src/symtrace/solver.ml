(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)

open Common

module Core_map = Map

open Type
open Sym
open Sym.Op
open Sym.Arith
open Sym.Logical
open Sym.Cmp
open Exp

module E = Exp

module Stats = Stats_local

(*************************************************)
(** {1 Types} *)
(*************************************************)

type answer = Yes | No | Maybe

(**
    [true] means definitely true, [false] means we don't know.
*)
type pbool = bool

(*************************************************)
(** {1 State} *)
(*************************************************)

let ctx : Yices.context = Yices.mk_context ()

let cache : pbool Int_map.t ref = ref Int_map.empty

(* Simulating the yices stack. *)
let assumed_facts = ref [[]]
let assumed_raw_facts = ref [[]]

(* accelerated cache for eq queries *)
module Int_pair =
struct
  type t = int * int
  let compare = Pervasives.compare
end
module Pair_map = Core_map.Make (Int_pair)
let eq_cache: pbool Pair_map.t ref = ref Pair_map.empty

let warn_cache = ref E.Set.empty

(*************************************************)
(** {1 Naming} *)
(*************************************************)

(*
  The naming should be separate from the naming used by output routines,
  we want the names to persist continuously, no reset.

  At the same time this ending may, if necessary, be made to respect
  output names when they are available.
*)

let mk_exp_name (type a) (e : a Exp.t) =
  let result = match e with
    | E.Var (v, _) -> "var_" ^ Var.to_string v ~dont_mask:true
    | E.String _ as e ->
      let escaped =
        E.to_string e |> String.map ~f:(function
        | '\\' -> '_'
        | c -> c)
      in
      "string_" ^ escaped
    | _ -> "var" ^ (string_of_int (E.id e))
  in
  `Mangled result

(*************************************************)
(** {1 Yices theory} *)
(*************************************************)

let theory =
  "\n\
(define-type bitstringbot)\n\
(define bottom:: bitstringbot)\n\
(define-type bitstring (subtype (x::bitstringbot) (/= x bottom)))\n\
\n\
; These correspond to val and bs functions in the paper\n\
(define value_unsigned:: (-> bitstringbot nat))\n\
(define value_signed::   (-> bitstringbot int))\n\
(define bs_unsigned::    (-> int nat bitstringbot))\n\
(define bs_signed::      (-> int nat bitstringbot))\n\
\n\
; In theory we should have two functions, one using C interpretation of truth, the other\n\
; using IML interpretation, but these two would be indistinguishable from yices point of\n\
; view. See the translation function.\n\
(define truth:: (-> bitstringbot bool))\n\
\n\
; The length of bottom is arbitrary.\n\
(define len::   (-> bitstringbot nat))\n\
(define range:: (-> bitstringbot nat nat bitstringbot))\n\
\n\
(define defined :: (-> bitstringbot bool))\n\
"
(*
  (define ptr::   (-> nat nat nat))
  (assert
  (forall (base1::nat offset1::nat base2::nat offset2::nat)
  (=> (/= base1 base2)
  (/= (ptr base1 offset1) (ptr base2 offset2)))))
*)

;;
Yices.parse_command ctx theory
;;

let range () =
    Yices.mk_var_from_decl ctx (Yices.get_var_decl_from_name ctx "range")

let len () =
    Yices.mk_var_from_decl ctx (Yices.get_var_decl_from_name ctx "len")

let value = function
  | `Unsigned -> Yices.mk_var_from_decl ctx (Yices.get_var_decl_from_name ctx "value_unsigned")
  | `Signed -> Yices.mk_var_from_decl ctx (Yices.get_var_decl_from_name ctx "value_signed")

let truth () =
    Yices.mk_var_from_decl ctx (Yices.get_var_decl_from_name ctx "truth")

let bs = function
  |  `Unsigned -> Yices.mk_var_from_decl ctx (Yices.get_var_decl_from_name ctx "bs_unsigned")
  |  `Signed -> Yices.mk_var_from_decl ctx (Yices.get_var_decl_from_name ctx "bs_signed")

(*
let ptr () =
    Yices.mk_var_from_decl ctx (Yices.get_var_decl_from_name ctx "ptr")
*)

let defined () =
    Yices.mk_var_from_decl ctx (Yices.get_var_decl_from_name ctx "defined")

(*************************************************)
(** {1 Debug} *)
(*************************************************)

let warn_on_failed_conditions_ref = ref true

let warn_on_failed_conditions b =
  warn_on_failed_conditions_ref := b

let debug_expr s e =
  if debug_enabled () then begin
    prerr_string (decorate_debug s);
    flush stderr;
    Yices.pp_expr e;
    prerr_endline "";
    flush stderr;
  end

let push_ctx () =
  Yices.push ctx;
  assumed_facts := [] :: !assumed_facts;
  assumed_raw_facts := [] :: !assumed_raw_facts

let pop_ctx () =
  Yices.pop ctx;
  assumed_facts := List.tl !assumed_facts;
  assumed_raw_facts := List.tl !assumed_raw_facts

let add_to_fact_stack facts fact =
  match !facts with
  | [] -> assert false
  | xs :: xss ->
    facts := (fact :: xs) :: xss

let dump_facts () =
  let assumed_facts = List.concat !assumed_facts in
  let assumed_raw_facts = List.concat !assumed_raw_facts in
  Printf.eprintf "ASSUMED FACTS:\n%s\nraw facts:\n%s\n"
    (E.list_to_string assumed_facts ~newline:true)
    (E.list_to_string assumed_raw_facts ~newline:true)

(*************************************************)
(** {1 Tracing} *)
(*************************************************)

type trace_step =
  { trace : 'a 'b. root:'a exp -> left:'b exp -> right:'b exp -> conds:fact list -> unit }

let dummy_trace = { trace = fun ~root:_ ~left:_ ~right:_ ~conds:_ -> () }

let trace_ref = ref dummy_trace
let tracing_mode = ref false

let enable_tracing trace =
  tracing_mode := true;
  trace_ref := trace

let disable_tracing () =
  tracing_mode := false;
  trace_ref := dummy_trace

let trace_step ~root ~left ~right ~conds =
  !trace_ref.trace ~root ~left ~right ~conds

(*************************************************)
(** {1 Checking facts} *)
(*************************************************)

;;
Yices.enable_type_checker true
;;

let rec rewrite_ptr : type a. a Exp.t -> a Exp.t = fun e ->
  (*
    To deal with
      <<stack null_ptr; index 0(i8), index 0(i1)>> == <<stack null_ptr; index 0(i1)>>
  *)
  let not_zero = function
    | (Flat (E.Int 0L), _) -> false
    | (Index 0, _) -> false
    | _ -> true
  in
  match e with
  | Ptr (pb, eo) ->
    Var (Var.of_string
           ("ptr_" ^
               E.to_string (Ptr (pb, List.filter ~f:not_zero eo))),
            Kind.Bitstring)

  | e -> E.descend {E.descend = rewrite_ptr} e

module Mode = struct
  type t = [ `Assert | `Query | `Simplify_step | `Simplify ]

  let to_string = function
    | `Assert -> "assert"
    | `Query -> "query"
    | `Simplify_step -> "simplify_step"
    | `Simplify -> "simplify"
end

module Rewrite_key = struct
  type 'a t = Mode.t * 'a exp
  module Kind = Kind
  let kind (_, e) = E.kind e
  let to_string (mode, e) = Printf.sprintf "%s, %s" (Mode.to_string mode) (E.to_string e)
end

module Rewrite_result = struct
  type 'a t = 'a exp * fact list
  module Kind = Kind
  let kind (e, _) = E.kind e
end

module Cache = Common.Map_any (Kind) (Rewrite_key) (Rewrite_result)

(* CR make this a hash table *)
let rewrite_cache = ref Cache.empty

let rec add_pi e_o pos =
  match pos with
  | [Flat b, step] -> [(Flat (sum [b; (prod [step; e_o])]), step)]
  | [Index i, step] ->
    (* Should not be too eager to concretise because in the parser we may not
       be able to restore the correct general form again. *)
    (* TODO: this should not actually affect parser correctness, think more about this. *)
    add_pi e_o [Flat (prod [step; (E.int i)]), step]
    (*
    let int_value = if E.is_constant e_o then S.eval e_o else None in
    begin match int_value with
    | Some j -> [Index (i + j), step]
    | None ->
    (* fail "add_pi: only concrete integers can be added to index offsets" *)
    end
    *)
  | [(o, step)] -> [(o, step); (Flat e_o, step)] (* FIXME: actually need an index here *)
  | o :: os -> o :: add_pi e_o os
  | [] -> fail "add_pi: pointer has no offsets"

let subtract_pp pos1 pos2 =
  let flatten_offset = function
    | Flat e, _ -> e
    | Index i, step -> prod [step; (E.int i)]
    | Field f, _ -> Sym (Field_offset f, [])
    | Attr _, _ ->
      fail "trying to subtract pointers with attribute offsets."
  in
  let flatten_pos pos =
    sum (List.map pos ~f:flatten_offset)
  in
  let is_zero_offset : offset -> bool = function (ov, _) -> is_zero_offset_val ov in
  let rec skip_zeros : pos -> pos = function
    | [os] -> [os]
    | os :: pos' when is_zero_offset os -> skip_zeros pos'
    | pos -> pos
  in
  let rec ptr_step = function
    | [_, step] -> step
    | _ :: pos -> ptr_step pos
    | [] -> fail "ptr_step"
  in
  match skip_zeros pos1, skip_zeros pos2 with
  | [Index i, step1], [Index j, step2] ->
      (*
	The pointer difference type is ptrdiff_t, which is implementation - dependent.
	For now, the right thing might be to insert explicit casts during the instrumentation.
      *)
    `Condition (E.eq_int [step1; step2]), `Result (E.int (i - j))

  | pos1, pos2 ->
    let e1 = flatten_pos pos1 in
    let e2 = flatten_pos pos2 in
    `Condition (E.eq_int [ptr_step pos1; ptr_step pos2]),
    `Result (E.minus e1 e2)

let rewrite
    (type a)
    ~(mode : [ `Assert | `Query | `Simplify_step ])
    (e : a exp)
    : a Rewrite_result.t =

  (* Root is only there for tracing purposes. *)
  let rec rewrite
      : type a b.
        mode : Mode.t
     -> ?assume:fact list
     -> root:b exp
     -> a exp
     -> a Rewrite_result.t
          = fun ~mode ?(assume = []) ~root e ->
    match Cache.maybe_find (mode, e) !rewrite_cache with
    | Some result -> result
    | None ->
      (* We can't really push assume down into rewriting because then caching
         would be unsound. *)
      let result = do_rewrite ~mode ~root e in
      if not !tracing_mode
      then rewrite_cache := Cache.add (mode, e) result !rewrite_cache;
      let e, conds = result in
      let assume = List.concat_map ~f:E.flatten_conj assume in
      let conds = List.diff conds assume in
      e, conds

  and descend_rewrite
    : type a b.
         mode : Mode.t
      -> ?assume: fact list
      -> root: b exp
      -> a exp
      -> a Rewrite_result.t
    = fun ~mode ?(assume = []) ~root e ->
    let all_conds = ref [] in
    let rewrite : type a. a exp -> a exp = fun e ->
      let e, conds = rewrite ~mode ~assume ~root e in
      all_conds := conds @ !all_conds;
      e
    in
    let e = E.descend {E.descend = rewrite} e in
    e, !all_conds

  (* Application of the chaining rule (see thesis) *)
  and rewrite_conjunction
      : type b.
        mode : Mode.t
     -> root: b exp
     -> fact list
     -> fact list * fact list
      = fun ~mode ~root es ->
    let rec loop ~result_es ~result_conds = function
      | [] -> List.dedup result_es, List.dedup result_conds
      | e :: es ->
        let e', result_conds' = rewrite ~mode ~root e in
        let result_es' = E.flatten_conj e' in
        (* CR: use sets *)
        let result_conds' = List.diff result_conds' result_es in
        let result_es = result_es' @ result_es in
        let result_conds = result_conds' @ result_conds in
        loop ~result_es ~result_conds es
    in
    loop ~result_es:[] ~result_conds:[] es

  (* For now I follow the principle that all transformations relating to one
     syntactic construct should be in one place. Another option would be to
     split this function into several and get rid of the mode argument. *)
  and do_rewrite
      : type a b.
        mode : Mode.t
     -> root:b exp
     -> a exp
     -> a Rewrite_result.t
     = fun ~mode ~root e ->
    let rewritten_conds = ref Fact_set.empty in
    let raw_conds = ref Fact_set.empty in
    let queued_conds = Queue.create () in
    let add_conditions ?(already_rewritten = false) conds =
      let conds = List.concat_map conds ~f:E.flatten_conj in
      let conds = Fact_set.of_list conds in
      if already_rewritten
      then rewritten_conds := Fact_set.union !rewritten_conds conds
      else begin
        let conds = Fact_set.diff conds !raw_conds in
        raw_conds := Fact_set.union !raw_conds conds;
        List.iter (Fact_set.to_list conds) ~f:(fun cond -> Queue.add cond queued_conds)
      end
    in
    let e_lhs = e in
    let rec collect : type a b. mode : Mode.t -> root:b exp -> a exp -> a exp = fun ~mode ~root e ->
      let collect_even_if_simplifying e = collect ~mode ~root e in
      let collect : type a. ?mode : Mode.t -> a exp -> a exp = fun ?(mode = mode) e ->
        match mode with
        | `Query | `Assert | `Simplify -> collect ~mode ~root e
        | `Simplify_step -> Fn.id e
      in
      let e_top = e in
      let step ~(right : a exp) ~conds =
        trace_step ~root ~left:(e_top : a exp) ~right:(right : a exp) ~conds;
        add_conditions conds;
      in
      let make_opaque e =
        match mode with
        | `Simplify | `Simplify_step -> e
        | `Assert | `Query ->
          let right = Sym (Opaque, [e]) in
          step ~right ~conds:[];
          right
      in
      let fail_already_rewritten e =
        fail "Rewriting an expression that is already rewritten: %s" (E.to_string e)
      in
      let default e =
        E.descend {E.descend = collect} e
      in
      let unexpected e =
        fail "Solver: unexpected expression: %s" (E.to_string e)
      in
      let (result : a exp) =
        match e with
        (*
          Rewriting of binary arithmetic to integer arithmetic.
        *)
        | Sym (Truth_of_bs,
               [Sym ((Op (Op_cmp cmp, ([Bs_int t1; Bs_int t2], _))), [e1; e2])]) ->
          let sym' = Int_cmp cmp in
          let e' = Sym (sym', [Val (e1, t1); Val (e2, t2)]) in
          step ~right:e' ~conds:[];
          collect e'

        | Sym (Int_cmp _, [e1; e2]) as e ->
          let defined =
            if not !tracing_mode
            then [is_defined e1; is_defined e2]
            else [is_defined (E.unfold e1); is_defined (E.unfold e2)]
          in
          (* The chaining rule only matters for assert. *)
          begin match mode with
          | `Assert ->
            (* This is [rewrite_conjunction [defined; e]] with the additional
               twist that we descend in e instead of starting from the top.  *)
            trace_step
              ~root
              ~left:e_top
              ~right:(E.conj (defined @ [e]))
              ~conds:[];
            let defined, defined_conds = rewrite_conjunction ~mode ~root defined in
            let e, e_conds = descend_rewrite ~mode ~assume:defined ~root e in
            add_conditions ~already_rewritten:true (defined_conds @ e_conds);
            E.conj (defined @ [e])
          | `Simplify | `Simplify_step ->
            default e
          | `Query ->
            (* It is not really necessary to add conditions here because we
               check that every leaf integer subexpression is not bottom. Well,
               almost, we would also need to check that integer variables are
               defined. I still keep this check in place, just for extra
               safety. For tracing, however, I skip the conditions for
               simplicity. *)
            if not !tracing_mode then add_conditions defined;
            default e
          end

        | Val ((Sym (Op (Op_arith op, _), [e1; e2])) as e, itype) ->
          let sym' = Int_op op in
          let e'= Sym (sym', [Val (e1, itype); Val (e2, itype)]) in
          let conds = is_defined e :: Range.contains itype e' in
          step ~right:e' ~conds;
          collect e'

        | Sym (Op (Cast_to_ptr, _), [e]) ->
          (* It might be necessary for PolarSSL to collect e first. *)
          begin match e with
          | Ptr (b, pos)  -> Ptr (b, pos @ [Index 0, Unknown Kind.Int])
          | BS (Int i, _) -> Ptr (Abs i, [Index 0, Unknown Kind.Int])
          | _ -> fail "simplify: cast to pointer of non-zero expression: %s" (E.to_string e)
          end

        | Sym (Op (Cast_to_int, ([t2], t3)), [e2]) as e ->
          let contains t e =
            match t with
            | Bs_int itype -> E.Range.contains itype e
            | _ -> assert false
          in
          if t2 = t3 then collect e2
          else begin match e2 with
          (* CR: check that new type is wide enough *)
          | Ptr _ -> collect e2
          | Sym (Op (Cast_to_int, ([Bs_int t1],  t2')), [e1]) ->
            assert (t2 = t2');
            (* Both conditions are necessary. *)
            add_conditions (contains t2 (Val (e1, t1)));
            add_conditions (contains t3 (Val (e1, t1)));
            Sym (Op (Cast_to_int, ([Bs_int t1], t3)), [e1]) |> collect
          | BS (e1, t) ->
            assert (t2 = Bs_int t);
            add_conditions (contains t2 e1);
            begin match t3 with
            | Bs_int t3 -> BS (e1, t3) |> collect
            | _ -> assert false
            end
          | _ -> make_opaque e
          end

        | Val ((Sym (Op (Cast_to_int, ([Bs_int itype_from], Bs_int itype_to)), [e])) as cast_e, itype_to') ->
          if itype_to <> itype_to' then
            fail "itype of Val not the same as itype of cast: %s" (E.to_string e_top);
          let e' = Val (e, itype_from) in
          let range_cond =
            if Range.subset itype_from itype_to then []
            else Range.contains itype_to e'
          in
          let conds = is_defined cast_e :: range_cond in
          step ~right:e' ~conds;
          collect e'

        | Val (BS (e, itype) as e_bs, itype') ->
          if itype <> itype'
          then fail "incompatible Val of BS: %s" (E.to_string e_top)
          else begin
            let conds = [is_defined e_bs] in
            step ~right:e ~conds;
            collect e
          end

        | Val (Ptr (Heap (_, es, _), pos), _) when E.is_zero_pos pos ->
          let e = E.malloc_expr es in
          collect e

        | Val (Ptr (Stack "nullPtr", pos), _) when E.is_zero_pos pos ->
          E.int 0

        | BS (Val (e, itype), itype') as e_bs ->
          if itype <> itype'
          then default e
          (*  fail "incompatible BS of Val: %s" (E.to_string e_top); *)
          (* Not failing since in normal form we try to see if "msg" is equal to, say
             ((msg{4, 8})_[u,8])^[u,3] *)
          else begin
            let conds = [is_defined e_bs] in
            step ~right:e ~conds;
            collect e
          end

        | Char c ->
          let e' = E.int (Char.code c) in
          step ~right:e' ~conds:[];
          e'

        (* CR-soon: check against thesis. *)
        (* CR-someday: add tracing for pointer operations. *)
        | Sym (Op (Plus_PI,  ([_; Bs_int itype], _)), [Ptr (b, pos); e_o]) ->
          let shift = collect (Val (e_o, itype)) in
          Ptr (b, add_pi shift pos)

        | Sym (Op (Minus_PI, ([_; Bs_int itype], _)), [Ptr (b, pos); e_o]) ->
          let shift = collect (Val (e_o, itype)) in
          Ptr (b, add_pi (E.minus E.zero shift) pos)

        | Sym (Op (Minus_PP, (_, Bs_int itype)),
               [Ptr (b1, pos1); Ptr (b2, pos2)]) ->
          if b1 <> b2
          then fail "simplify: trying to subtract pointers with different bases";
          let `Condition cond, `Result result = subtract_pp pos1 pos2 in
          add_conditions [cond];
          BS (result, itype) |> collect

        | Len e as e_top ->
          let unexpected e =
            fail "Unexpected len argument: %s" (E.to_string e)
          in
          let default e =
            match mode with
            | `Simplify | `Simplify_step ->
              e_top
            | `Assert | `Query ->
              let e' = Sym (Len_y, [e]) in
              step ~right:e' ~conds:[is_defined e];
              default e'
          in
          begin match e with
          | BS (_, itype) as e_bs ->
            let e' = E.int (Int_type.width itype) in
            step ~right:e' ~conds:[is_defined e_bs];
            collect e'

          | Sym (BS_of_truth width, _) as e_bs ->
            let e' = E.int width in
            step ~right:e' ~conds:[is_defined e_bs];
            e'

          | Sym (Op (_, (_, Bs_int itype)), _) as e_bin ->
            let e' = E.int (Int_type.width itype) in
            step ~right:e' ~conds:[is_defined e_bin];
            collect e'

          | Sym (Op _, _) ->
            assert false

          | Concat es ->
            let e' = E.sum (List.map ~f:(fun e -> Len e) es) in
            step ~right:e' ~conds:[];
            collect e'

          | Range (_, _, l) as e ->
            step ~right:l ~conds:[is_defined e];
            collect l

          | String b ->
            let e' = E.int (List.length b) in
            step ~right:e' ~conds:[];
            e'

          (* This will become unnecessary once pointers are rewritten into vanilla
             expressions, as per thesis *)
          | Ptr _ as e ->
            add_conditions [is_defined e];
            Sym (Ptr_len, [])

          | Struct (_, _, l, _) as e ->
            add_conditions [is_defined e];
            collect l

          | Array (_, l, _) as e ->
            add_conditions [is_defined e];
            collect l

          | Annotation (_, e) ->
            collect_even_if_simplifying (Len e)

          | Sym ((Opaque), _) as e -> unexpected e

          | Sym (Replicate, _) as e -> default e
          | Sym (Cmp, _) as e -> default e
          | Sym (Ztp, _) as e -> default e
          | Sym (Ztp_safe, _) as e -> default e
          | Sym (Undef _, _) as e -> default e
          | Sym (Fun _, _) as e -> default e
          | Sym (Cast _, _) as e -> default e
          | Var _ as e -> default e
          | Unknown _ as e -> default e
          end

        | Sym (Defined, [e]) ->
          let default e =
            Sym (Defined, [collect e])
          in
          let rewrite_to_true () =
            step ~right:true_fact ~conds:[];
            true_fact
          in
          begin match e with
          (* Here and below we do not list defined() conditions because those are
             implied by the comparison operators *)
          | Range (e, p, l) ->
            let right =
              E.conj [ge (Len e) (E.sum [p; l]);
                      ge p E.zero;
                      ge l E.zero;]
            in
            step ~right ~conds:[];
            collect right

          | BS (e, itype) ->
            let right = E.conj (Range.contains itype e) in
            step ~right ~conds:[];
            collect right

          | Val (e, itype) ->
            let right = eq_int [E.int (Int_type.width itype); E.len e] in
            step ~right ~conds:[];
            collect right

          | Sym (Op (_, (ts, _)), es) ->
            let right =
              List.combine ts es
              |> List.filter_map ~f:(function
                | Bs_int itype, e -> Some (eq_int [E.int (Int_type.width itype); E.len e])
                | Type.Ptr, Ptr _ -> None
                | t, e ->
                  fail "unexpected type of op argument: %s: %s"
                    (E.to_string e) (Type.to_string t))
              |> E.conj
            in
            step ~right ~conds:[];
            collect right

          | Sym (sym, es) as e ->
            if Sym.never_fails sym
            then rewrite_to_true ()
            else if not (Sym.may_fail sym)
            then begin
              let right = E.conj (List.map ~f:is_defined es) in
              step ~right ~conds:[];
              collect right
            end
            else begin match mode with
            | `Simplify | `Simplify_step | `Query ->
              default e
            | `Assert ->
              let defined_es =
                if not !tracing_mode
                then List.map es ~f:is_defined
                else List.map es ~f:(fun e -> E.unfold (is_defined e))
              in
              let right = E.conj (is_defined e :: defined_es) in
              step ~right ~conds:[];
              (* Note the difference in application order for e and es. *)
              let e = is_defined (collect e) in
              let es = List.map ~f:collect defined_es in
              E.conj (e :: es)
            end

          | Len e ->
            let right = Sym (Defined, [e]) in
            step ~right ~conds:[];
            collect right

          | Int _ -> rewrite_to_true ()
          | Char _ -> rewrite_to_true ()
          | String _ -> rewrite_to_true ()
          | Concat [] -> rewrite_to_true ()

          | Concat es ->
            let right = E.conj (List.map ~f:is_defined es) in
            step ~right ~conds:[];
            collect right

          (* This will become unnecessary once pointers are rewritten into vanilla
             expressions, as per thesis *)
          | Ptr (_, pos) ->
            let defined_offset (offset, _) =
              match offset with
              | Flat e -> Some (is_defined e)
              | Index _ | Attr _ | Field _ -> None
            in
            E.conj (List.filter_map ~f:defined_offset pos) |> collect

          | Struct (fields, _, _, e) ->
            E.conj (is_defined e :: List.map ~f:is_defined (Str_map.values fields)) |> collect

          | Array (elems, _, _) ->
            E.conj (List.map (Int_map.values elems) ~f:is_defined) |> collect

          | Annotation (_, e) ->
            Sym (Defined, [e]) |> collect_even_if_simplifying

          | Var _ as e -> default e
          | Unknown _ as e -> default e
          end

        | Sym (Defined, _) -> assert false

        (* Unlike for val and len, we don't need to replace BS by a yices
           compatible form, because it is defined with bitstringbot as domain in
           yices, so returning bottom is not a problem.  *)
        | BS (e, itype) ->
          let e' = collect ~mode:`Simplify e in
          if e <> e'
          (* Re-collecting to deal with things like
             (len(msg{12, (msg{4, 8})_[u,8]}:fixed_20_nonce))^[u,8] *)
          then collect (BS (e', itype))
          (* Need to appply again with our own mode to make sure all
             yices-compatibility transformations are applied. *)
          else BS (collect ~mode e', itype)

        (*
          Replacing vals by their Yices versions.
        *)
        | Val (e, itype) ->
          begin match mode with
          | `Simplify | `Simplify_step ->
            e_top
          | `Query | `Assert ->
            let right = Sym (Val_y itype, [e]) in
            step ~right ~conds:[is_defined e];
            Sym (Val_y itype, [collect e])
          end

        (*
          Falling through or turning into opaque.
        *)

        | Annotation (a, e) ->
          Annotation (a, collect_even_if_simplifying e)

        (* TODO: inline, once GADT pattern matching is sorted. *)
        (* I suppose everything of type bitstringbot can be turned into opaque
           here. I don't turn BS into opaque, but I don't know why I
           couldn't. *)
        | Sym (Fun _, _) as e -> make_opaque e
        | Sym (Ztp, _) as e -> make_opaque e
        | Sym (Ztp_safe, _) as e -> make_opaque e
        | Sym (Undef _, _) as e -> make_opaque e
        | Sym (Cmp, _) as e -> make_opaque e
        | Sym (Op _, _) as e -> make_opaque e
        | Struct _ as e -> make_opaque e
        | Array _ as e -> make_opaque e
        | Concat _ as e -> make_opaque e
        | Sym (Field_offset _, _) as e -> make_opaque e

        | Sym (Opaque, _) as e -> fail_already_rewritten e
        | Sym (Len_y, _) as e -> fail_already_rewritten e
        | Sym (Val_y _, _) as e -> fail_already_rewritten e

        | Sym (Bs_eq, _) as e -> default e
        | Sym (Int_op _, _) as e -> default e
        | Sym (Int_cmp _, _) as e -> default e
        | Sym (Logical _, _) as e -> default e
        | Sym (Ptr_len, _) as e -> default e
        | Sym (Cast _, _) as e -> default e
        | Sym (Malloc _, _) as e -> default e
        | Sym (Replicate, _) as e -> default e
        | Sym (In_type _, _) as e -> default e
        | Sym (BS_of_truth _, _) as e -> default e
        | Sym (Truth_of_bs, _) as e -> default e
        | Int _ as e -> default e
        | String _ as e -> default e
        | Var _ as e -> default e
        | Range _ as e -> default e
        | Ptr _ as e -> default e
        | Unknown _ as e -> default e
      in
      push_debug "collect";
      DEBUG "collect(%s) %s ~> %s"
        (Mode.to_string mode) (E.to_string e) (E.to_string result);
      pop_debug "collect";
      result
    in
    let e = collect ~mode ~root e in
    while not (Queue.is_empty queued_conds) do
      let cond = Queue.pop queued_conds in
      let cond = collect ~mode:`Query ~root:cond cond in
      add_conditions ~already_rewritten:true [cond]
    done;
    let conds = Fact_set.to_list !rewritten_conds in
    let conds =
      match E.kind e with
      | Kind.Bool -> List.diff conds (E.flatten_conj e)
      | Kind.Int -> conds
      | Kind.Bitstring -> conds
    in
    push_debug "rewrite";
    DEBUG "%s: %s |- %s ~> %s"
      (Mode.to_string mode)
      (E.list_to_string conds)
      (E.to_string e_lhs)
      (E.to_string e);
    pop_debug "rewrite";
    e, conds
  in

  DEBUG "rewriting %s" (E.to_string e);
  push_debug "rewrite";
  let e, conds = rewrite ~mode:(mode :> Mode.t) ~root:e e in
  let conds = List.map conds ~f:rewrite_ptr in
  let e =
    match mode with
    | `Simplify_step -> e
    | `Assert | `Query -> rewrite_ptr e
  in
  pop_debug "rewrite";
  DEBUG "resulting e = %s" (E.to_string e);
  DEBUG "resulting conds = %s" (E.list_to_string conds);
  e, conds

let rewrite_facts ~mode es: fact list * fact list =
  let es, conds = List.map ~f:(rewrite ~mode) es |> List.split in
  let es = List.dedup (List.concat_map ~f:E.flatten_conj es) in
  let conds = List.dedup (List.concat conds) in
  es, conds

let is_opaque (type a) (e : a Exp.t) =
  match rewrite ~mode:`Assert e with
  | Sym (Opaque, _), _ -> true
  | _ -> false

module Kind = struct
  include Kind

  let to_yices_type (type a) (t : a t) =
    match t with
    | Bitstring      -> Yices.mk_type ctx "bitstringbot" (* sic *)
    | Int            -> Yices.mk_type ctx Yices.int_type_name
    | Bool           -> Yices.mk_type ctx Yices.bool_type_name
end

let add_fact_raw ?(check_consistent = true) y_e =
  push_debug "add_fact_raw";
  debug_expr "asserting_y " y_e;
  Yices.assert_simple ctx y_e;
  if check_consistent && Yices.inconsistent ctx then
  begin
    (* dump_context ctx; *)
    debug_expr "add_fact: the context has become inconsistent: " y_e;
    fail "inconsistent context";
  end;
  pop_debug "add_fact_raw"

let reset_cache () =
  cache := Int_map.empty;
  eq_cache := Pair_map.empty

let reset_facts : unit -> unit = fun () ->
  Yices.reset ctx;
  Yices.parse_command ctx theory;
  assumed_facts := [[]];
  assumed_raw_facts := [[]];
  reset_cache ()

let get_decl kind (`Mangled name) =
  try Yices.get_var_decl_from_name ctx name
  with Failure _ -> Yices.mk_var_decl ctx name (Kind.to_yices_type kind)

let translate (e_top : fact) =

  let module A = Array in

  let mk_var e =
    let k = E.kind e in
    Yices.mk_var_from_decl ctx (get_decl k (mk_exp_name e))
  in

  let rec tr : type a. a Exp.t -> Yices.expr = fun e ->
    DEBUG "translating %s" (E.dump e);
    match e with
    | Int i                  -> Yices.mk_num ctx (Int64.to_int i)
    | String _               -> mk_var e
    (* All variables are Bitstringbot except for in eval *)
    | Var _                  -> mk_var e
    | Range (e, pos, len)    -> Yices.mk_app ctx (range ()) [| tr e; tr pos; tr len |]
    | Sym (Opaque, [_]) as e -> mk_var e
    | Annotation(_, e)       -> tr e
    | BS (e, itype)          ->
      let sg = Int_type.signedness itype in
      let width = Int_type.width itype in
      Yices.mk_app ctx (bs sg) [| Yices.mk_num ctx width; tr e |]
    | Sym (sym, es) ->
      begin match sym, es with
      | (Logical True, [])         -> Yices.mk_true ctx
      | (Logical (And _), [])      -> Yices.mk_true ctx
      | (Logical Not, [a])         -> Yices.mk_not ctx (tr a)
      | (Logical (And _), es)      -> Yices.mk_and ctx (A.map tr (A.of_list es))
      | (Logical (Or _), [])       ->
        fail "wrong number of arguments: %s in fact %s" (E.dump e) (E.dump e_top)
      | (Logical (Or _), es)       -> Yices.mk_or  ctx (A.map tr (A.of_list es))
      | (Logical Implies, [a; b])  -> Yices.mk_ite ctx (tr a) (tr b) (Yices.mk_true ctx)
      | (Int_cmp Eq, [a; b])       -> Yices.mk_eq ctx (tr a) (tr b)
      | (Int_cmp Ne, [a; b])       -> Yices.mk_diseq ctx (tr a) (tr b)
      | (Int_cmp Gt, [a; b])       -> Yices.mk_gt ctx (tr a) (tr b)
      | (Int_cmp Ge, [a; b])       -> Yices.mk_ge ctx (tr a) (tr b)
      | (Int_cmp Lt, [a; b])       -> Yices.mk_lt ctx (tr a) (tr b)
      | (Int_cmp Le, [a; b])       -> Yices.mk_le ctx (tr a) (tr b)

      | (Bs_eq, [a; b])   -> Yices.mk_eq ctx (tr a) (tr b)
      | (In_type _, _)    -> mk_var e
        (* CR-someday: are we potentially confusing the solver by allowing
           simplifications inside Malloc? *)
      | (Malloc _, _)     -> mk_var e
      | (Defined, [e])    -> Yices.mk_app ctx (defined ()) [| mk_var e |]

      (* C interpretation of truth *)
      | (Truth_of_bs, [e]) -> Yices.mk_app ctx (truth ()) [| mk_var e |]
      (* IML interpretation of truth *)
      (* CR: what? *)
      | (Opaque, _)        -> Yices.mk_app ctx (truth ()) [| mk_var e |]

      | Int_op Neg, [a]        -> Yices.mk_sub ctx [| Yices.mk_num ctx 0; tr a |]
      | Int_op Minus, [e1; e2] -> Yices.mk_sub ctx [| tr e1; tr e2 |]
      | Int_op Minus, _        ->
        fail "wrong number of arguments: %s in fact %s" (E.dump e) (E.dump e_top)
      | Int_op (Plus _), []    ->
        fail "wrong number of arguments: %s in fact %s" (E.dump e) (E.dump e_top)
      | Int_op (Plus _), es    -> Yices.mk_sum ctx (A.map tr (A.of_list es))
      | Int_op (Mult _), []    ->
        fail "wrong number of arguments: %s in fact %s" (E.dump e) (E.dump e_top)
      | Int_op (Mult _), es    -> Yices.mk_mul ctx (A.map tr (A.of_list es))
      | Ptr_len, []            -> mk_var e

      | Len_y, [e]            -> Yices.mk_app ctx (len ())   [| tr e |]
      (* Not sure this is necessary, perhaps could just make it opaque. *)
      | Val_y itype, [e]      -> Yices.mk_app ctx (value (Int_type.signedness itype))  [| tr e |]
      | _ -> mk_var e
        (*fail "Solver.translate: unexpected expression %s in fact %s"
          (E.dump e) (E.dump e_top)*)
      end

    | e -> mk_var e
      (*fail "Solver.translate: unexpected expression %s in fact %s"
        (E.dump e) (E.dump e_top)*)

  in
  with_debug "Solver.translate" (fun () -> tr e_top)

let is_true_raw ?warn_if_false e =
  DEBUG "checking (with auxiliary facts) %s" (E.to_string e);
  push_debug "is_true_raw.translate";
  let ye = translate (negation e) in
  pop_debug "is_true_raw.translate";
  debug_expr "checking (yices expression)" ye;
  push_ctx ();
  Yices.assert_simple ctx ye;
  let result = match Yices.check ctx with
    | Yices.False -> true
    | Yices.Undef -> false
    | Yices.True  -> false
  in
  pop_ctx ();
  DEBUG "check result = %s" (string_of_bool result);
  begin match warn_if_false with
  | None -> ()
  | Some err ->
    if !warn_on_failed_conditions_ref && not result && not (E.Set.mem e !warn_cache) then
      begin
        warn "cannot prove %s %s" (E.to_string e) err;
        dump_facts ();
        (*
          Returns NULL model:
          push ctx;
          assert_simple ctx (silent translate (negation e));
          let model = get_model ctx in
          display_model model;
          pop ctx;
        *)
        warn_cache := E.Set.add e !warn_cache;
      end;
  end;
  result

let is_true_raw ?warn_if_false e =
  Stats.call "is_true_raw" (fun () -> is_true_raw ?warn_if_false e)

let rec simplify_bool (e : fact) =
  let is_true = function
    | Sym (Logical And _, []) -> true
    | Sym (Logical True, []) -> true
    | _ -> false
  in
  match e with
  | Sym (Logical Implies, [e1; e2]) when is_true e1 -> simplify_bool e2
  | Sym (Logical And _, [e]) -> simplify_bool e
  | Sym (Logical op, es) -> Sym (Logical op, List.map ~f:simplify_bool es)
  | e -> e

let assume es =
  let assume_one e =
    let es', conds = rewrite_facts ~mode:`Assert [e] in
    let warn_if_false =
      Printf.sprintf "arising from assuming %s" (E.to_string e)
    in
    List.iter ~f:(fun cond -> is_true_raw ~warn_if_false cond |> ignore) conds;
    add_to_fact_stack assumed_facts e;
    let e = E.conj es'|> simplify_bool in
    (* Sym (Logical Implies, [E.conj conds; E.conj es'] )
      |> simplify_bool
    in *)
    add_to_fact_stack assumed_raw_facts e;
    DEBUG "assuming %s" (E.to_string e);
    add_fact_raw (translate e);
  in
  reset_cache ();
  List.iter es ~f:assume_one

let assume es =
  Stats.call "assume" (fun () -> assume es)

let is_true e: pbool =
  DEBUG "checking %s" (E.to_string e);
  let id = E.id e in
  let result =
    match Option.try_with (fun () -> Int_map.find id !cache) with
    | Some result ->
      (* This debug is 25 % performance penalty: *)
      DEBUG "result (from cache) = %s" (string_of_bool result);
      result
    | None ->
      push_debug "is_true";
      let es', conds = rewrite_facts ~mode:`Query [e] in
      let warn_if_false = Printf.sprintf "arising from querying %s" (E.to_string e) in
      let result =
           List.for_all ~f:(is_true_raw ~warn_if_false) conds
        && List.for_all ~f:(is_true_raw) es'
      in
      pop_debug "is_true";
      DEBUG "result (not from cache): %b" result;
      result
  in
  cache := Int_map.add id result !cache;
  result

let implies facts hypotheses =
  DEBUG "checking implication: \n  %s\n  =>\n  %s" (E.list_to_string facts) (E.list_to_string hypotheses);
  push_debug "implies";
  push_ctx ();
  assume facts;
  let result = List.for_all ~f:(is_true) hypotheses in
  pop_ctx ();
  pop_debug "implies";
  DEBUG "implication result: %b" result;
  result

let implies facts hypotheses =
  Stats.call "implies" (fun () -> implies facts hypotheses)

(* TODO: change back to equal when it stabilizes *)
let equal_bitstring ?(facts = []) (a : bterm) (b : bterm) =
  if facts <> []
  then implies facts [eq_bitstring [a; b]]
  else begin
    let a_id, b_id = E.id a, E.id b in
    try Pair_map.find (a_id, b_id) !eq_cache
    with Not_found ->
      let result = is_true (eq_bitstring [a; b]) in
      eq_cache := Pair_map.add (a_id, b_id) result !eq_cache;
      result
  end

let not_equal_bitstring e1 e2 =
  if not (is_true (E.is_defined e1)) || not (is_true (E.is_defined e2)) then false
  else match e1, e2 with
  | String b1, String b2 -> b1 <> b2
  | BS (Int n1, itype1), BS (Int n2, itype2) when itype1 = itype2 ->
    n1 <> n2
  | _ -> false (* is_true (negation (eq_bitstring [e1; e2])) *)

let greater_equal (a : iterm) (b : iterm) =
  is_true (ge a b)

let equal_int ?(facts = []) a b =
  if facts = [] then is_true (eq_int [a; b])
  else implies facts [eq_int [a; b]]

let greater_equal_len (a : iterm) (b : iterm) =
  greater_equal a b
  (* match (a, b) with
    | (All, _) -> true
    | (_, All) -> false
    | (Unknown, _) | (_, Unknown) -> false
    | (x, y) -> greater_equal x y *)

let greater_equal_len_answer (a : iterm) (b : iterm) =
  if greater_equal_len a b then
    Yes
  else if greater_equal_len b a then
    No
  else
    Maybe

(*************************************************)
(** {1 Evaluation.} *)
(*************************************************)

(* TODO: cache? *)
let eval e =
  push_debug "eval";

  let warn_if_false = Printf.sprintf "arising from evaluation of %s" (E.to_string e) in
  let e, conds = rewrite ~mode:`Query e in
  DEBUG "eval: e = %s, conds = %s" (E.to_string e) (E.list_to_string conds);
  let result =
    if not (List.for_all ~f:(is_true_raw ~warn_if_false) conds)
    then begin
      DEBUG "eval: conditions not satisfied";
      None
    end
    else begin
      push_ctx ();
      let v = Var (Var.fresh "int_val", Kind.Int) in
      Yices.assert_simple ctx (translate (eq_int [v; e]));
      let result =
        match Yices.check ctx with
        | Yices.False | Yices.Undef ->
          DEBUG "eval: could not find a value";
          None
        | Yices.True ->
          let model = Yices.get_model ctx in
          let vy = get_decl Kind.Int (mk_exp_name v) in
          (*
          DEBUG "eval: got a model:";
          Yices.display_model model;
          *)
          match Option.try_with (fun () -> Yices.get_int_value model vy) with
          | None ->
            DEBUG "eval: could not extract value";
            None
          | Some value ->
            let value = Int32.to_int value in
            DEBUG "eval: a possible value is %d" value;
            (* Make sure the value is unique *)
            add_fact_raw ~check_consistent:false (translate (negation (eq_int [v; E.int value])));
            (*
            increase_debug_depth ();
            DEBUG "eval: context for checking uniqueness:";
            if debug_enabled () then Yices.dump_context ctx;
            decrease_debug_depth ();
            *)
            match Yices.check ctx with
            | Yices.False -> Some value
            | Yices.Undef
            | Yices.True  ->
              DEBUG "value is not unique";
              None
      in
      pop_ctx ();
      result
    end
  in
  pop_debug "eval";
  result

let eval = function
  | Int n ->
    let n = Int64.to_int n in
    DEBUG "eval of integer %d, nothing to do" n;
    Some n
  | e -> eval e

(*************************************************)
(** {1 Simplification.} *)
(*************************************************)

(* TODO: cache? *)
let simplify e =
  DEBUG "Solver.simplify %s" (E.to_string e);
  push_debug "Solver.simplify";
  let e', conds = rewrite ~mode:`Simplify_step e in
  let warn_if_false = Printf.sprintf "arising from simplification of %s" (E.to_string e) in
  let result =
    if List.for_all ~f:(is_true_raw ~warn_if_false) conds then e' else e
  in
  pop_debug "Solver.simplify";
  DEBUG "result: %s" (E.to_string result);
  result

(*************************************************)
(** {1 Testing.} *)
(*************************************************)

let test_implication () =
  let nonce = Var (Var.of_string "nonce", Kind.Bitstring) in
  let bs e = BS (e, Int_type.create `Unsigned 4) in
  assert
    (implies
       [eq_int [Len nonce; Int 20L ]]
       [eq_int [Len nonce; Int 20L ]]);
  assert
    (implies
       [eq_int [Len nonce; Int 20L ]]
       [eq_bitstring [bs (Len nonce); bs (Int 20L)]])

let test_bs_cancellation1 () =
  let itype = Int_type.create `Unsigned 4 in
  let eight = BS (Int 8L, itype) in
  let e = BS (Annotation (Name (Var.of_string "eight"),
                          Val (eight, itype)), itype)
  in
  assert (is_true (eq_bitstring [e; eight]))

(*
  msg{4, 8} = (len(msg{12, (msg{4, 8})_[u,8]}:fixed_20_nonce))^[u,8]

  CR: speak about different ways of assuming defined.
*)
let test_bs_cancellation2 () =
  let t = Named ("nonce", Some (Fixed 20)) in
  let itype = Int_type.create `Unsigned 8 in
  let l1 = Range (var_s "msg", Int 4L, Int 8L) in
  let e1 = Range (var_s "msg", Int 12L, Val (l1, itype)) in
  let e2 = Annotation (Type_hint t, e1) in
  let e3 = BS (Len e2, itype) in
  assert (implies
            [is_defined e2]
            [eq_bitstring [l1; e3]])

let test_annot_equality () =
  let l =
    Val (Range ((Exp.var_s "msg"), Int 4L, Int 8L),
         Int_type.create `Unsigned 8)
  in
  let e =
    Annotation (Type_hint (Named ("nonce", Some (Fixed 20))),
                Range ((Exp.var_s "msg"), Int 12L, l))
  in
  assert (implies [is_defined e] [eq_int [Len e; l]])

let test_eval () =
  assert (eval (Int 42L) = Some 42)

let with_ctx f =
  push_ctx ();
  f ();
  pop_ctx ()

let test () =
  with_ctx test_implication;
  with_ctx test_annot_equality;
  with_ctx test_eval;
  with_ctx test_bs_cancellation1;
  with_ctx test_bs_cancellation2

(* 870 lines *)
