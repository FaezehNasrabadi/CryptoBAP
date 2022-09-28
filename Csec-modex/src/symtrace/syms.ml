open Sym
open Exp
open Common
open Typing

module E = Exp
module S = Solver

module Stats = Stats_local

module Parsing_eq = struct
  type t =
    { p : bfun (* parser is a keyword in camlp4? *)
    ; c : bfun
    ; i : int
    }

  let to_string ?fun_types {p; c; i} =
    let arity = Sym.arity c in
    let args = mk_formal_args arity |> List.map ~f:Var.to_string in
    let header =
      match fun_types with
      | None -> ""
      | Some fun_types ->
        let ts, _ = Fun_type_ctx.find c fun_types in
        List.map2 ~f:(fun arg t -> arg ^ ": " ^ Type.to_string t) args ts
        |> String.concat ~sep:", "
        |> Printf.sprintf "forall %s;\n"
    in
    Printf.sprintf "%s%s(%s(%s)) = %s."
      header
      (Sym.to_string p)
      (Sym.to_string c)
      (String.concat ~sep:", " args)
      (E.mk_arg i |> Var.to_string)

  let find_match ts ~p ~c =
    List.find_map ts ~f:(fun {p = p'; c = c'; i} ->
      if p = p' && c = c' then Some i else None)

  let matching_encoders ts p =
    List.filter_map ts ~f:(fun {p = p'; c; i} ->
      if p = p' then Some (c, i) else None)
end

module Aux_fact = struct
  type fun_decl = (bitstring, bitstring) Fun_type.t * bfun

  type t =
  | Disjoint of (fun_decl * fun_decl)
  | Equal of (fun_decl * fun_decl)

  let sort (typ1, f1) (typ2, f2) =
    if f1 <= f2
    then (typ1, f1), (typ2, f2)
    else (typ2, f2), (typ1, f1)

  let sort = function
    | Disjoint (decl1, decl2) -> Disjoint (sort decl1 decl2)
    | Equal (decl1, decl2) -> Equal (sort decl1 decl2)

  (* Assumes robust safety (well-definedness of both expressions. *)
  let is_disjoint es es' =
    let facts = [ E.is_defined (Concat es); E.is_defined (Concat es')] in
    let rec scan = function
      | e :: es, e' :: es' when S.equal_int ~facts (Len e) (Len e') ->
        if is_tag e && is_tag e' && S.not_equal_bitstring e e'
        then true
        else scan (es, es')
      | _ -> false
    in
    scan (es, es')

  let is_equal t t' e e' =
    e = e' && t = t'

  let fun_fact fun_types (s, e) (s', e') =
    let t  = Fun_type_ctx.find s  fun_types in
    let t' = Fun_type_ctx.find s' fun_types in
    if is_equal t t' e e' then Some (Equal ((t, s), (t', s')))
    else match e, e' with
    | Concat es, Concat es' ->
      if is_disjoint es es' then Some (Disjoint ((t, s), (t', s')))
      else None
    | _ -> None

  let rec fun_facts fun_types (cs : (bfun * bitstring Sym_defs.def) list) : t list =
    match cs with
    | c :: cs ->
      List.filter_map ~f:(fun_fact fun_types c) cs @ fun_facts fun_types cs
    | [] -> []

  let is_valid = function
    | Equal ((t1, _), (t2, _)) -> t1 = t2
    | Disjoint (((_, t1), _), ((_, t2), _)) -> t1 = t2

  let fun_facts fun_types cs =
    List.filter (fun_facts fun_types cs) ~f:is_valid
    |> List.map ~f:sort
end


(*************************************************)
(** {1 Zero functions} *)
(*************************************************)

module Zero_funs = struct
  (* Types for which we need to generate ZT, ZT', and possibly Zero_t *)
  type t = bitstring Type.t list ref

  (* Bitstring zeros may be used in auxiliary_facts. *)
  let create () = ref [Type.Bitstring]

  let disjoint_union ts =
    List.map ts ~f:(fun t -> !t)
    |> List.concat
    |> List.dedup
    |> ref

  let zero_fun t typ =
    t := typ :: !t;
    Sym.make ("Z" ^ Type.to_string typ) ~arity:1

  (* Assume that zero_fun will be called for all of these, so no need to add to zts. *)
  let zero_fun_prime t =
    Sym.make ("Z" ^ Type.to_string t ^ "_prime") ~arity:1

  let zero_sym t typ =
    t := typ :: !t;
    make_const ("zero_" ^ Type.to_string typ)

  let zero_defs t =
    (* Suitable for generating sym_defs and Fun_type_ctx.t *)
    let z_fun_info typ =
      let zt = zero_fun t typ in
      let zt' = zero_fun_prime typ in
      let zero_t = zero_sym t typ in
      [(zt,  Unknown Kind.Bitstring), (zt,  ([typ], typ));
       (zt', Unknown Kind.Bitstring), (zt', ([typ], typ))]
      @ if Type.has_fixed_length typ
        then [(zero_t, Unknown Kind.Bitstring), (zero_t, ([], typ))]
        else []
    in
    let z_defs, z_types =
      List.concat_map ~f:z_fun_info (List.dedup !t) |> List.split
    in
    let z_defs = Sym_defs.of_list z_defs in
    let z_types = Fun_type_ctx.of_list z_types in
    z_defs, z_types
end

type t =
  { encoders : bitstring Sym_defs.t
  ; parsers : bitstring Sym_defs.t
  ; arith   : bitstring Sym_defs.t
  ; auxiliary : bool Sym_defs.t
  ; casts: (bitstring Type.t * bitstring Type.t) list
  ; zero_funs : Zero_funs.t
  }

let create iml =
  let encoders = Iml.encoders iml in
  let parsers = Iml.parsers iml in
  let arith = Iml.arith iml in
  let auxiliary = Iml.auxiliary iml in
  let casts = List.dedup (Typing.casts iml) in
  let zero_funs = Zero_funs.create () in
  { encoders
  ; parsers
  ; arith
  ; auxiliary
  ; casts
  ; zero_funs
  }

let create iml =
  Stats.call "create" (fun () -> create iml)

let encoders t = t.encoders
let parsers t = t.parsers
let arith t = t.arith
let auxiliary t = t.auxiliary
let casts t = t.casts
let zero_funs t = t.zero_funs

let binary_defs t =
  Sym_defs.disjoint_union [ encoders t; parsers t; arith t ]

let union ~how ts =
  let sym_defs_union =
    match how with
    | `Disjoint -> Sym_defs.disjoint_union
    | `Compatible -> Sym_defs.compatible_union
  in
  let union f =
    List.map ts ~f |> sym_defs_union
  in
  let encoders = union encoders in
  let parsers = union parsers in
  let arith = union arith in
  let auxiliary = union auxiliary in
  let casts =
    List.map ts ~f:casts
    |> List.concat
    |> List.dedup
  in
  let zero_funs =
    List.map ts ~f:zero_funs |> Zero_funs.disjoint_union
  in
  { encoders
  ; parsers
  ; arith
  ; auxiliary
  ; casts
  ; zero_funs
  }

let disjoint_union =
  union ~how:`Disjoint

let compatible_union =
  union ~how:`Compatible

let def t sym =
  Sym_defs.find sym (binary_defs t)

let arithmetic_facts t fun_types =
  Aux_fact.fun_facts fun_types (Sym_defs.to_list (arith t))

let arithmetic_facts t fun_types =
  Stats.call "arithmetic_facts" (fun () -> arithmetic_facts t fun_types)

let encoder_facts t fun_types =
  Aux_fact.fun_facts fun_types (Sym_defs.to_list (encoders t)
                                @ Sym_defs.to_list (parsers t))

let encoder_facts t fun_types =
  Stats.call "encoder_facts" (fun () -> encoder_facts t fun_types)

(*************************************************)
(** {1 Parsing Rules} *)
(*************************************************)

let parsing_eqs t fun_types =

  let parsing_eqs : Parsing_eq.t list ref = ref [] in

  let check_type nargs p c e =
    let (pts, pt) = Fun_type_ctx.find p fun_types in
    let (cts, ct) = Fun_type_ctx.find c fun_types in
    let result =
      if pts <> [ct] then false
      else begin
        let args = mk_formal_args nargs |> List.map ~f:E.var in
        List.any (List.map2 ~f:(fun arg t -> arg = e && t = pt) args cts)
      end
    in
    begin if not result then match e with
    | Var _ ->
      info ("derived equation %s(%s(...)) = %s but the types don't match,\n"
             ^^ "  %s: %s, and %s: %s")
        (Sym.to_string p) (Sym.to_string c) (E.to_string e)
        (Sym.to_string c) (Fun_type.to_string (cts, ct))
        (Sym.to_string p) (Fun_type.to_string (pts, pt))
    | _ -> ()
    end;
    result
  in

  let apply_parser p parser_def c encoder_def =
    let parser_arg = mk_arg 0 in
    let encoder_args = E.mk_formal_args (Sym.arity c) |> List.map ~f:E.var in
    let e = E.subst [parser_arg] [encoder_def] parser_def in
    DEBUG "apply_parser: e after subst arg = %s" (E.dump e);
    let e' = Simplify.full_simplify e in
    DEBUG "apply_parser %s to %s: \n  %s \n  ~> %s  \n"
      (Sym.to_string p) (Sym.to_string c)
      (E.dump e) (E.dump e');
    if not (check_type (Sym.arity c) p c e')
    then []
    else match List.find_index ((=) e') encoder_args with
    | Some i ->  [{Parsing_eq. p; c; i}]
    | None -> fail "Parsing result is not a encoder argument: %s" (E.to_string e')
  in

  let compute_rules_for_encoder f_c encoder_def =
    let parsers = Sym_defs.to_list (parsers t) in
    let (ts, _) = Fun_type_ctx.find f_c fun_types in
    let arg_facts =
      List.mapi ts ~f:(fun i t ->
        E.in_type (Var (mk_arg i, Kind.Bitstring)) t)
    in
    S.assume arg_facts;
    (* S.assume (E.is_defined encoder_def); *)

    (* We expect some conditions to fail when the parser doesn't match. *)
    S.warn_on_failed_conditions false;
    let new_eqs =
      List.concat_map ~f:(fun (f_p, parser_def) ->
        apply_parser f_p parser_def f_c encoder_def)
        parsers
    in
    S.warn_on_failed_conditions true;
    S.reset_facts ();
    parsing_eqs := new_eqs @ !parsing_eqs;
  in

  let check_parser_is_matched p _ =
    if List.exists !parsing_eqs ~f:(fun {Parsing_eq. p = p'; _} -> p = p') then ()
    (* A corresponding warning for encoders would not be good because sometimes
       we send tag|msg together, but receive tag and msg separately. *)
    else warn "No parsing equation for %s" (Sym.to_string p)
  in

  Sym_defs.iter ~f:compute_rules_for_encoder (encoders t);
  Sym_defs.iter ~f:check_parser_is_matched (parsers t);
  !parsing_eqs

let parsing_eqs t fun_types =
  Stats.call "parsing_eqs" (fun () -> parsing_eqs t fun_types)

(********************************************************)
(** {1 Auxiliary Test Properties} *)
(********************************************************)

(*
  There are two ways to check
    (len(x) = len(y)) => (def[x/arg] = def[y/arg]).

  The first way is to do length substitutions and then check syntactic equality.
  One needs to expand lengths because of things like
    !(cast_to_int[false,4,false,8](len("p"|len54|x92|x93)) <= (i5 + cast_to_int[false,4,false,8](len55)))

  The other way is to use the solver directly, but then you need to show overflow safety
  as well. When formalising, you need to replace auxiliary facts by hardened facts that
  check overflow safety.

  The second option is conceptually simpler, but less efficient. Another problem with the
  second option is that it is tricky to tell the solver to assume overflow safety for an
  expression. One cannot just extract the overflow safety fact, because that itself may
  not be overflow safe. For these reasons I'm using the first option now.

  Another reason for checking syntactic equality is that we actually want to simplify the
  expressions
*)
let auxiliary_facts t fun_types =
  let encoders = encoders t in
  let auxiliary = auxiliary t in
  let zero_funs = t.zero_funs in
  (* facts for a single auxiliary test *)
  let facts fun_types sym def arg_types =
    let num_args = List.length arg_types in
    let args = mk_formal_args num_args in
    let zero_of v t =
      Sym (Zero_funs.zero_fun zero_funs t, [Var (v, Kind.Bitstring)])
    in
    let replace_len v =
      let rec replace : type a. a exp -> a exp = function
        | Len (Var (v', Kind.Bitstring)) when v' = v ->
          Var (Var.fresh "len", Kind.Int)
        | e -> E.descend {E.descend = replace} e
      in
      replace
    in
    let rec expand_lens : type a. a exp -> a exp = function
      | Len (Concat es) ->
        List.map ~f:E.len es |> E.sum |> expand_lens
      | e -> E.descend {E.descend = expand_lens} e
    in
    let can_erase arg =
      let x = Var (Var.fresh "x", Kind.Bitstring) in
      let y = Var (Var.fresh "y", Kind.Bitstring) in
      let def = replace_len arg def in
      let def_x = E.subst [arg] [x] def in
      let def_y = E.subst [arg] [y] def in
      DEBUG "can_erase: comparing \n%s and \n%s" (E.to_string def_x) (E.to_string def_y);
      def_x = def_y
    in
    let encoder_pairs arg t =
      let pair c =
        match Fun_type_ctx.maybe_find c fun_types with
          (* I don't exactly understand why restricting to the same type is enough, but it
             feels like it should be enough, and it looks like it is. *)
        | Some (ts, t') when t = t' ->
          let c_def = Sym_defs.find c encoders in

          (* Rename args of c_def to avoid collision with args of def. *)
          let c_args = List.map ~f:(fun _ -> Var.fresh "c_arg") (1 -- (Sym.arity c)) in
          let c_def = E.subst_v (mk_formal_args (Sym.arity c)) c_args c_def in
          (* For simplifcation. *)
          S.assume [E.is_defined c_def];

          (* We expect some conditions to fail when trying to simplify something that's
             impossible to simplify. *)
          S.warn_on_failed_conditions false;
          let def =
            E.subst [arg] [c_def] def
            (* We may be substituting an encoder inside a parser, so we need to
               simplify. *)
            |> Simplify.full_simplify
            (* Deal with stuff like
               {[
                 !(cast_to_int[false,4,false,8](len("p"|len54|x92|x93)) <=
                     (i5 + cast_to_int[false,4,false,8](len55)))
               ]}
            *)
            |> expand_lens
            (* Replace all argument lengths by fresh variables *)
            |> fun init -> List.fold_right ~f:replace_len ~init c_args
          in
          S.warn_on_failed_conditions true;

          let xs = List.map ~f:(fun _ -> Var.fresh "x") (1 -- (Sym.arity c)) in
          let ys = List.map ~f:(fun _ -> Var.fresh "y") (1 -- (Sym.arity c)) in
          let def_x = E.subst_v c_args xs def in
          let def_y = E.subst_v c_args ys def in
          DEBUG "encoder_pairs: comparing \n%s and \n%s" (E.to_string def_x) (E.to_string def_y);
          if def_x = def_y then
            let zxs = List.map2 ~f:zero_of xs ts in
            let xs = List.map ~f:E.var xs in
            Some (Sym (c, xs), Sym (prime c, zxs))
          else None
        | _ -> None
      in
      List.filter_map ~f:pair (Sym_defs.keys encoders)
    in
    let mk_fact sym1 sym2 arg_pairs =
      let args1, args2 = List.split arg_pairs in
      if args1 = args2 then []
      else
        [ Sym (Logical Logical.Eq, [Sym (sym1, args1); Sym (sym2, args2)])
          |> Cv_fact.create fun_types
        ]
    in
    let var x = Var (x, Kind.Bitstring) in
    (* First phase: zero out things that can be zeroed out completely. *)
    let x_facts =
      List.map2 arg_types args ~f:(fun t -> function
      | x when can_erase x -> var x, zero_of x t
      | x -> var x, var x)
      |> mk_fact sym (prime sym)
    in
    (* Apply the rewriting to the result of the previous phase if any. *)
    let sym =
      match x_facts with
      | [] -> sym
      | _ -> prime sym
    in
    (* Second phase: rewrite specific encoders.*)
    let mk_encoder_fact x e1 e2 =
      List.map args ~f:(function
      | x' when x' = x -> e1, e2
      | x -> var x, var x)
      |> mk_fact sym sym
    in
    let encoder_facts =
      List.map2 args arg_types ~f:(fun x t ->
        if can_erase x then []
        else List.concat_map (encoder_pairs x t) ~f:(fun (e1, e2) ->
          mk_encoder_fact x e1 e2))
      |> List.concat
    in
    x_facts @ encoder_facts
  in
  S.reset_facts ();
  let fun_types =
    List.fold (Sym_defs.keys auxiliary) ~init:fun_types ~f:(fun fun_types f ->
      Fun_type_ctx.add_primed f fun_types)
  in
  Sym_defs.to_list auxiliary
  |> List.concat_map ~f:(fun (sym, def) ->
    DEBUG "Auxiliary facts: checking %s: %s" (Sym.to_string sym) (E.to_string def);
    let (ts, _) = Fun_type_ctx.find sym fun_types in
    facts fun_types sym def ts)

let auxiliary_facts t fun_types =
  Stats.call "Syms.auxiliary_facts" (fun () -> auxiliary_facts t fun_types)

(*************************************************)
(** {1 Injectivity} *)
(*************************************************)

let is_robustly_injective fun_types sym def =
  let rec scan lens ts = function
    | e :: es when E.is_tag e -> scan lens ts es
    | BS (Len v, _) :: es -> scan (v :: lens) ts es
    | Var _ as v :: es ->
      if (Type.has_fixed_length (List.hd ts)) || List.mem v ~set:lens
      then scan lens (List.tl ts) es
      else List.for_all es ~f:E.is_tag
    | [] -> true
    | _ :: _ -> fail "Malformed concat: %s" (Exp.to_string def)
  in
  match def with
  | Concat es ->
    let (ts, _) = Fun_type_ctx.find sym fun_types in
    scan [] ts es
  | _ -> false

let check_encoders_are_robustly_injective t fun_types =
  Sym_defs.iter (encoders t) ~f:(fun f_c def ->
    if not (is_robustly_injective fun_types f_c def)
    then fail "Encoder not injective: %s" (E.show_fun f_c def))

(*************************************************)
(** {1 Regularity Properties} *)
(*************************************************)

(**
  Return the zero equations, zero function definitions and types
  (including definitions and types for zero constants of fixed types).

  Generate the following equations:

    - for each conc : T1 x ... x Tn -> T
      ZT(conc(x1, ..., xn)) = ZT'(conc(ZT1(x1), ..., ZTn(xn)))

    - for each cast_T1_T2:
      ZT2(cast_T1_T2(x)) = ZT2'(cast_T1_T2(ZT1(x)))

    - for each fixed type T that occurs anywhere in argument types in fun_types:
      ZT(x) = Zero_T
*)
let zero_facts t fun_types =
  let encoders = encoders t in
  let casts = casts t in
  let zero_funs = t.zero_funs in

  let zero_of e t = Sym (Zero_funs.zero_fun zero_funs t, [e]) in

  let encoder_fact c =
    let ts, t = Fun_type_ctx.find c fun_types in
    let args = mk_formal_args (Sym.arity c) |> List.map ~f:E.var in
    let zt = Zero_funs.zero_fun zero_funs t in
    let zt' = Zero_funs.zero_fun_prime t in
    E.eq_bitstring [Sym (zt, [Sym (c, args)]);
                    Sym (zt', [Sym (c, List.map2 ~f:zero_of args ts)])]
  in

  let cast_fact (t1, t2) =
    let sym = Cast (t1, t2) in
    let x = E.var_s "x" in
    let zt2 = Zero_funs.zero_fun zero_funs t2 in
    let zt2' = Zero_funs.zero_fun_prime t2 in
    E.eq_bitstring [Sym (zt2,  [Sym (sym, [x])]);
                    Sym (zt2', [Sym (sym, [zero_of x t1])])]
  in

  let const_fact t =
    let zt = Zero_funs.zero_fun zero_funs t in
    let zero_t = Sym (Zero_funs.zero_sym zero_funs t, []) in
    let x = E.var_s "x" in
    E.eq_bitstring [Sym (zt, [x]); zero_t]
  in

  let encoder_facts = List.map ~f:encoder_fact (Sym_defs.keys encoders) in
  let cast_facts = List.map ~f:cast_fact casts in
  let fixed_types =
    Fun_type_ctx.map_bindings fun_types
      { Fun_type_ctx.f = fun _ (ts, _) -> ts }
    |> List.concat
    |> List.filter ~f:Type.has_fixed_length
    |> List.dedup
  in
  let const_facts = List.map ~f:const_fact fixed_types in
  let _, z_types = Zero_funs.zero_defs zero_funs in
  let facts =
    List.map
      (encoder_facts @ cast_facts @ const_facts)
      ~f:(Cv_fact.create (Fun_type_ctx.compatible_union [fun_types; z_types]))
  in
  facts

let zero_facts t fun_types =
  Stats.call "zero_facts" (fun () -> zero_facts t fun_types)

let zero_funs t fun_types =
  ignore (zero_facts t fun_types);
  Zero_funs.zero_defs t.zero_funs |> fst

let zero_types t fun_types =
  ignore (zero_facts t fun_types);
  Zero_funs.zero_defs t.zero_funs |> snd

(*
  prerr_title "Parsing Equations";
  List.iter (Syms.parsing_eqs syms) ~f:(fun eq ->
    prerr_endline (show_parsing_eq ~fun_types eq));

  prerr_title "Parsing Equations (again)";
  List.iter parsing_eqs ~f:(fun eq ->
    prerr_endline (show_parsing_eq ~fun_types eq));

*)

(*************************************************)
(** {1 Regularity checking (PV only)} *)
(*************************************************)

let is_disjoint t f f' =
  match Sym_defs.find f (encoders t), Sym_defs.find f' (encoders t) with
  | Concat es, Concat es' -> Aux_fact.is_disjoint es es'
  | _ -> assert false

let is_equal t fun_types f f' =
  let typ  = Fun_type_ctx.find f  fun_types in
  let typ' = Fun_type_ctx.find f' fun_types in
  Aux_fact.is_equal typ typ'
    (Sym_defs.find f  (encoders t))
    (Sym_defs.find f' (encoders t))

let check_is_regular t fun_types =
  let encoders = Sym_defs.keys (encoders t) in
  let parsers = Sym_defs.keys (parsers t) in
  List.iter encoders ~f:(fun f ->
    (* Condition 1: every return is bounded. *)
    let _, result_type = Fun_type_ctx.find f fun_types in
    if not (Type.is_bounded result_type)
    then warn "[formatting regularity] result type %s of %s is not bounded"
      (Type.to_string result_type) (Sym.to_string f);
    (* Condition 4; all encoders are disjoint *)
    List.iter encoders ~f:(fun f' ->
      if not (is_equal t fun_types f f') && not (is_disjoint t f f')
      then warn "[formatting regularity] Not equal or disjoint: %s and %s"
        (Sym.to_string f) (Sym.to_string f'))
  );
  (* Condition 2: there is an injection from parsers to encoders and argument
     positions. *)
  let parsing_eqs = parsing_eqs t fun_types in
  List.concat_map parsers ~f:(Parsing_eq.matching_encoders parsing_eqs)
  |> List.find_all_dups
  |> function
    | [] -> ()
    | _ ->
      warn "[formatting regularity] \
two parsers match the same encoder at the same position"
