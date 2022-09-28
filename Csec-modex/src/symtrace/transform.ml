(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common

open Type
open Sym
open Sym.Op
open Exp
open Iml
open Iml.Pat
open Iml.Stmt
open Typing

module E = Exp
module S = Solver

(*************************************************)
(** {1 XOR rewriting} *)
(*************************************************)

(* Make sure that XOR will be treated as cryptographic function. *)
(* CR-someday: this might be done on a per-case bases using a plugin. *)

let rewrite_xor p =

  let assumptions = ref [] in

  let rec rewrite : type a. a exp -> a exp = function
    | Sym (Op (BXor, ([t1; t2], t)), [e1; e2]) ->
      let e1 = rewrite e1 in
      let e2 = rewrite e2 in
      let e = Sym (Fun ("XOR", (2, Kind.Bitstring)), [e1; e2]) in
      let fact =
        E.implication
          [E.in_type e1 t1; E.in_type e2 t2]
          [E.in_type e t]
      in
      assumptions := Assume fact :: !assumptions;
      e
    | e -> E.descend {E.descend = rewrite} e
  in
  let rewrite s =
    let s = Stmt.descend {E.descend = rewrite} s in
    let result = !assumptions @ [s] in
    assumptions := [];
    result
  in
  List.concat_map ~f:rewrite p

(*************************************************)
(** {1 Crypto-arithmetic comparison rewriting} *)
(*************************************************)

(* Deal with DSA_verify(...) == 1

   We can't easily turn this into bitstring comparison because Val is not necessarily
   injective.
*)
let rewrite_crypto_arithmetic_comparisons p =
  let is_interesting = function
    | Var _ -> true
    | Sym (Fun _, _) -> true
    | _ -> false
  in
  let rewrite s =
    match s with
    | Test (Sym (Int_cmp Cmp.Eq, [Val (e, _); Int n])) when is_interesting e ->
      (* Because we preserve the original test, we don't need to mention the conversion
         type. *)
      let f = Printf.sprintf "value_equal_%d" (Int64.to_int n) in
      [s; Test (Sym (Fun (f, (1, Kind.Bool)), [e]))]
    | s -> [s]
  in
  List.concat_map ~f:rewrite p

(*************************************************)
(** {1 Error if IML contains undef *)
(*************************************************)

let error_if_undefs p =
  let rec error : type a. a exp -> unit = function
    | Sym (Undef _, _) -> fail "IML contains undef"
    | e -> E.iter_children {E.f = error} e
  in
  Iml.iter {E.f = error} p

(*************************************************)
(** {1 Let simplification} *)
(*************************************************)

let simplify_lets p =
  let rec simplify defs = function
    | Let (VPat v, Var (v', Kind.Bitstring)) :: p ->
      simplify defs (Iml.subst_v [v] [v'] p)
    | Let (VPat v, _) :: p when Iml.refcount v p = 0 -> simplify defs p
    | Let (VPat v, e) :: p ->
      begin match Option.try_with (fun () -> List.assoc e defs) with
      | Some v' ->
        simplify defs (Iml.subst_v [v] [v'] p)
      | None ->
        Let (VPat v, e) :: simplify ((e, v) :: defs) p
      end
    | s :: p -> s :: simplify defs p
    | [] -> []
  in
  simplify [] p

(*************************************************)
(** {1 Name annotations} *)
(*************************************************)

(**
  Changes things like
   {[
    new var1: fixed_n;
    let var2 = var1 in
    let named_var = var2 in P
   ]}
  (where there is a name annotation on var2) to
   {[
     new named_var: fixed_n in P
   ]}
  while checking that var1 does not occur in P.

  No renaming is done to free variables of course.

  Name annotations get removed in the end.
*)

let apply_name_annotations p =

  let free_vars = Iml.free_vars p in

  (*
    Which variable should be renamed to which? No loops.
  *)
  let names = ref Var.Map.empty in

  let rec resolve name =
    match Var.Map.maybe_find name !names with
      | Some name' -> resolve name'
      | None -> name
  in

  (* Rename v1 and all members of its equivalence class to v2. *)
  let rec rename v1 v2 =
    match Var.Map.maybe_find v1 !names with
      | None ->
        (* We are at the top of the chain, add a new element above it *)
        if v1 <> v2 then
          names := Var.Map.add v1 v2 !names
      | Some v1' ->
        if v1 = v2 then
          (* v1 will become the new top, so we remove its own renaming *)
          names := Var.Map.remove v1 !names;
        rename v1' v2
  in

  let exp_name = function
    | Var (v, _) -> Some v
    | Annotation (Name name, _) -> Some name
    (* Don't rename variables inside annotations, since annotations will not be removed by
       simplify_lets. *)
    (* | Annotation (_, e) -> exp_name e *)
    | _ -> None
  in

  let rec collect_names_e : type a. a exp -> unit = function
    | Annotation (Name name, e) ->
      begin match exp_name e with
        (* Do not rename free variables *)
        | Some name' when not (List.mem name' ~set:free_vars) ->
          rename name' name
        | _ -> ()
      end;
      collect_names_e e
    | e ->
      E.iter_children {E.f = collect_names_e } e
  in

  let collect_names = function
    | Let (VPat v, e) ->
      begin match exp_name e with
        | Some name -> rename v name
        | _ -> ()
      end
    | _ -> ()
  in

  (* We do substitution without regard for capture *)
  let subst_v vs vs' = Iml.map {E.descend = fun e -> E.subst_v vs vs' e} in

  (* Rename variables according to collected names *)
  let rec rename_vars = function
    | Let (VPat v, e) :: p ->
      let v' = resolve v in
      Let (VPat v', e) :: rename_vars (subst_v [v] [v'] p)
    | New (v, t) :: p ->
      let v' = resolve v in
      New (v', t) :: rename_vars (subst_v [v] [v'] p)
    | In vs :: p ->
      let vs' = List.map ~f:resolve vs in
      In vs' :: rename_vars (subst_v vs vs' p)
    | s :: p -> s :: rename_vars p
    | [] -> []
  in

  let rec remove_name_annotations : type a. a exp -> a exp = function
    | Annotation (Name _, e) -> remove_name_annotations e
    | e -> E.descend {E.descend = remove_name_annotations} e
  in

  List.iter ~f:collect_names p;
  (* It is important that this comes second,
     to make sure annotation renamings override
     assignment renamings *)
  Iml.iter {E.f = collect_names_e} p;
 rename_vars p |> Iml.map {E.descend = remove_name_annotations} |> simplify_lets

(*************************************************)
(** {1 Normal Form} *)
(*************************************************)

let sort_defs defs =
  let gt s s' =
    match s, s' with
      | Let (_, e), Let (VPat v, _) -> List.mem v ~set:(E.vars e)
      | _ -> false
  in
  List.topsort gt defs

let normal_form p =
  let rec normalize p =

    let defs = ref [] in

    let mk_var = function
      | Var (v, Kind.Bitstring) -> Var (v, Kind.Bitstring)
      | e ->
        let v = Var.fresh "" in
        defs := Let (VPat v, e) :: !defs;
        Var (v, Kind.Bitstring)
    in

    let is_length_of e_l e =
      match e_l with
      | BS (l, _) ->
        S.equal_int l (Len e)
      | e_l ->
        match Simplify.full_simplify (Len e) with
        | Val (e_l', _) ->
          S.equal_bitstring e_l e_l'
        | _ -> false
    in

    (* remove expressions that are themselves lengths of an expression that follows *)
    let rec remove_lens = function
      | e :: es ->
        if List.exists ~f:(fun e' -> is_length_of e e') es
        then remove_lens es
        else e :: remove_lens es
      | [] -> []
    in

    (* CR-soon this shouldn't be necessary since we can use typing to prove
       injectivity. Then you can also stop collecting facts in normalization. *)
    (*
      This is the heuristic part - we convert an expression like
      20 | 20 | x | y,
      where len(x) = 20 and len(y) = 20 to
      len(x) | len(y) | x | y

      args is the list of arguments that we haven't found a length for yet.
    *)
    let rec explicate_lens args = function
      | [] -> []
      | e :: es ->
        match S.eval (Len e) with
        | None ->
          e :: explicate_lens args es
        | Some width ->
          let itype = Int_type.create `Unsigned width in
          match
            List.find_and_remove args ~f:(fun e' ->
              S.equal_bitstring e (BS (Len e', itype)))
          with
          | None -> e :: explicate_lens args es
          | Some (e', args) ->
            BS (Len e', itype) :: explicate_lens args es
    in

    let rec extract_non_cryptographic : type a. a exp -> a exp = fun e ->
      match e, E.kind e with
      | e, Kind.Bitstring when E.is_cryptographic e ->
        mk_var (extract (e : bterm))
      | e, _ ->
        E.descend {E.descend = extract_non_cryptographic} e

    (* Variables for same expressions will later be unified by simplify_lets *)
    and extract_encoder = function
      | e when is_tag e -> e
      | BS (Len e, itype) -> BS (Len (mk_var (extract e)), itype)
      | e -> mk_var (extract e)

    and extract_parser : type a. bterm -> bterm -> a exp -> a exp = fun v m e ->
      let descend e = extract_parser v m e in
      match e, E.kind e with
      | e, Kind.Bitstring when S.equal_bitstring m e -> v
      | e, Kind.Int when S.equal_int (Len m) e -> Len v
      | Sym (Int_op _, _), _             -> E.descend {E.descend} e
      | Sym (Op (Cast_to_int, _), _), _  -> E.descend {E.descend} e
      | Val _, _                         -> E.descend {E.descend} e
      | BS _, _                          -> E.descend {E.descend} e
      | Range _, _                       -> E.descend {E.descend} e
      | Int _, _                         -> E.descend {E.descend} e
      | e, _ -> fail "normal_form: unexpected parser subexpression %s" (E.dump e) (* mk_var (extract e) *)

    and extract_fun = function
      | Sym (Fun _ as f, es)  ->
        Sym (f, List.map ~f:extract_fun (es : bterm list))
      | e -> mk_var (extract e)

    and extract (e : bterm) =
      match e with
      | Concat es ->
        let args = remove_lens (List.filter ~f:(non is_tag) es) in
        let es = explicate_lens args es in
        DEBUG "extract encoder: args = %s" (E.list_to_string args);
        DEBUG "extract encoder: es = %s" (E.list_to_string es);
        Concat (List.map ~f:extract_encoder es)

      | Range (Range _, _, _) ->
        fail "extract_parsers: nested ranges not supported: %s" (E.dump e)

      | Range (m, _, _) ->
        let v = mk_var (extract m) in
        extract_parser v m e

      | Var (v, t) -> Var (v, t)

      | Sym (Fun _, _) -> extract_fun e

      | Annotation (a, e) -> Annotation (a, mk_var (extract e))

      | e when not (E.is_cryptographic e) -> extract_non_cryptographic e

      | _ -> assert false
    in
    match p with
    | Assume e :: p ->
      S.assume [e];
      Assume e :: normalize p
    | Let (VPat v, e) :: p ->
      S.assume [E.eq_bitstring [Var (v, Kind.Bitstring); e]];
      let e = extract e in
      sort_defs !defs @ (Let (VPat v, e) :: normalize p)
    | Let _ :: _ ->
      fail "normal_form: impossible: let patterns unexpected"
    | In vs as s :: p ->
      List.iter ~f:(fun v ->
        S.assume [E.is_defined (Var (v, Kind.Bitstring))]) vs;
      s :: normalize p
    | New (v, t) as s :: p ->
      S.assume [E.in_type (Var (v, Kind.Bitstring)) t];
      s :: normalize p
    | Test _ as s :: p when Stmt.is_auxiliary_test s ->
      S.assume (Stmt.facts s);
      s :: normalize p
    | (Test _ | Eq_test _ | Out _ | Event _ | Yield | Comment _ ) as s :: p ->
      let move_out_bitstring (e : bterm) =
        match e with
        | Concat _ | Range _ | Annotation _ -> mk_var (extract e)
        | Var _ -> extract e
        | Sym (Fun _, _) -> extract e
        | e when not (E.is_cryptographic e) -> mk_var (extract e)
        | e ->
          fail "Normal form: impossible (1): %s" (E.to_string e)
      in
      let move_out (type a) (e : a exp) : a exp =
        match E.kind e with
        | Kind.Bitstring -> move_out_bitstring e
        | Kind.Int -> fail "Normal form: impossible (2): %s" (E.to_string e)
        | Kind.Bool ->
          match e with
          | Sym (Fun (f, t), es) ->
            Sym (Fun (f, t), List.map ~f:extract_fun es)
          | e -> extract_non_cryptographic e
      in
      S.assume (Stmt.facts s);
      let s = Stmt.descend {E.descend = move_out} s in
      sort_defs !defs @ (s :: normalize p)
    | [] -> []
  in
  push_debug "normal_form";
  S.reset_facts ();
  let p = normalize p in
  S.reset_facts ();
  pop_debug "normal_form";
	normalize p	
 (* simplify_lets p *)

let test_normal_form_encoder () =
  let var = E.var_s in
  let itype = Int_type.create `Unsigned 8 in
  let l1 = Range (var "msg", Int 4L, Int 8L) in
  let e1 = Range (var "msg", Int 12L, Val (l1, itype)) in
  let t = Named ("nonce", Some (Fixed 20)) in
  let e = Concat [E.string "msg"; l1; BS (Int 20L, itype);
                  Annotation (Type_hint t, e1); var "nonce"; var "host"]
  in
  let p = [ New (Var.of_string "nonce", t)
          ; Assume (E.is_defined e)
          ; Out [e] ]
  in
  let p' = [ New (Var.of_string "nonce", t)
           ; Assume (E.is_defined e)
           ; Let (vpat "var3", e1)
           ; Let (vpat "var4", Annotation (Type_hint t, var "var3"))
           ; Let (vpat "var5", Concat [ E.string "msg"
                                      ; BS (Len (var "var4"), itype)
                                      ; BS (Len (var "nonce"), itype)
                                      ; var "var4"; var "nonce"; var "host"])
           ; Out [var "var5"] ]
  in
  test_result ~expect:p' (normal_form p) Iml.to_string;
  S.reset_facts ()

let test_normal_form_fun () =
  let f = Sym.make "f" ~arity:1 in
  let var = E.var_s in
  let e_c = Concat [var "msg1"; var "msg2"] in
  let e = Sym (f, [e_c]) in
  let p = [ Assume (E.is_defined e); Out [e] ] in
  let p' = [ Assume (E.is_defined e)
           ; Let (vpat "var1", e_c)
           ; Out [Sym (f, [var "var1"])] ]
  in
  test_result ~expect:p' (normal_form p) Iml.to_string;
  S.reset_facts ()

(*************************************************)
(** {1 Extraction helper} *)
(*************************************************)

let extract_def e =
  let vs = E.vars e in
  let args = E.mk_formal_args (List.length vs) |> List.map ~f:E.var in
  let e = E.subst vs args e in
  vs, e

(*************************************************)
(** {1 Arithmetic expressions} *)
(*************************************************)

(* CR-soon: this isn't an int expression, so rename to something less suggestive
   of that. *)
let extract_arithmetic p : iml =
  let extract = function
    | Let (v, e) when not (E.is_cryptographic e) ->
      let vs, def = extract_def e in
      let f = Sym.new_arith ~arity:(List.length vs) in
      let args = List.map ~f:E.var vs in
      let e = Annotation (Arith def, Sym (f, args)) in
      Let (v, e)
    | s -> s
  in
  List.map ~f:extract p

let is_injective_arithmetic = function
  | Sym (Op (Op.Cast_to_int, ([Bs_int t1], Bs_int t2)), [Var _]) ->
    Int_type.signedness t1 = Int_type.signedness t2
    && Int_type.width t1 <= Int_type.width t2
  | _ -> false

(*************************************************)
(** {1 Encoders} *)
(*************************************************)

let extract_encoders p : iml =
  (*
    Check whether the encoder definition only consists of formal arguments
    (no lengths or tags).
  *)
  let rec is_trivial_encoder : bterm list -> bool = function
    | Var _ :: es -> is_trivial_encoder es
    | [] -> true
    | _ :: _ -> false
  in
  let extract = function
    | Let (v, (Concat es as e)) ->
      DEBUG "extract, e = %s" (E.dump (Concat es));
      let vs, def = extract_def e in
      let f_c = Sym.new_encoder ~arity:(List.length vs) in
      DEBUG "extract, e_new = %s" (E.dump def);
      begin match def with
      | Concat es when is_trivial_encoder es ->
        fail
          "The encoderenation does not contain argument lengths or tags. This may lead to non-termination. %s"
          (E.dump def)
      | _ -> ()
      end;
      let args = List.map ~f:E.var vs in
      Let (v, Annotation (Encoder def, Sym (f_c, args)))
    | s -> s
  in
  List.map ~f:extract p

(*************************************************)
(** {1 Extracting Parsers} *)
(*************************************************)

let extract_parsers p =
  let extract = function
    | Let (v_pat, (Range (Var (v, _), _, _) as e)) ->
      DEBUG "adding parser for the expression %s" (E.to_string e);
      let vs, def = extract_def e in
      if vs <> [v] then fail "extract_parsers: impossible";
      let f_p = Sym.new_parser () in
      let args = List.map ~f:E.var vs in
      let e = Annotation (Parser def, Sym (f_p, args)) in
      Let (v_pat, e)
    | s -> s
  in
  List.map ~f:extract p

(*************************************************)
(** {1 Extracting Auxiliary Test Conditions} *)
(*************************************************)

let extract_auxiliary p : iml =
  let rec extract = function
    | Test (Sym (Fun _, _)) as s :: p ->
      s :: extract p
    | Test e :: p ->
      let vs, def = extract_def e in
      let f = Sym.new_auxiliary ~arity:(List.length vs) in
      let args = List.map ~f:E.var vs in
      let e = Annotation (Auxiliary def, Sym (f, args)) in
      Test e :: extract p
    | s :: p -> s :: extract p
    | [] -> []
  in
  extract p

(*************************************************)
(** {1 Abstraction step} *)
(*************************************************)

let extract_syms p : iml =
  p |> extract_encoders |> extract_parsers
  |> extract_arithmetic |> extract_auxiliary

(*************************************************)
(** {1 Removing Redundant Test Conditions} *)
(*************************************************)

(* CR: this is one particular case where we rely on validity of var_types even
   though we never explicitly check it. *)
let remove_redundant_tests var_types p =
  let rec remove_casts : type a. a exp -> a exp = function
    | Sym (Cast _, [e]) -> remove_casts e
    | e -> E.descend {descend = remove_casts } e
  in
  let assume_var_types () =
    Type_ctx.to_list var_types
    |> List.iter ~f:(fun (v, t) ->
      S.assume [E.in_type (Var (v, Kind.Bitstring)) t])
  in
  let rec remove = function
    | [] -> []
    | stmt :: p ->
      match stmt with
      | Test fact ->
        let fact = remove_casts fact |> E.expand_defs in
        if S.is_true fact then remove p
        else begin
          S.assume [fact];
          stmt :: remove p
        end
      | stmt ->
        S.assume (Stmt.facts stmt);
        stmt :: remove p
  in
  S.reset_facts ();
  assume_var_types ();
  remove p


(*************************************************)
(** {1 Parsing Safety} *)
(*************************************************)

(* CR-soon: make this work with all robustly injective encoders. *)
let rec mk_parsers ls ps es e_c =
  let open Sym.Arith in
  let x = Var (mk_arg 0, Kind.Bitstring) in
  match e_c with
    | e_i :: e_c ->
      let l =
        match e_i, e_c with
        | _, [] ->
          Sym (Int_op Minus, [Len x; E.sum ls])
        | Var _ as v, _ ->
          begin
          (* DEBUG "looking for %s in %s" (E.dump v) (E.dump_list es); *)
          (* Need comparison in this order as es will contain lengths of lengths *)
            List.combine es ps
            |> List.first_some ~f:(function
              | (BS (Len v', itype), p) when v = v' -> Some (Val (p, itype))
              | _ -> None)
            |> Option.value_exn
          end
        (* Note that we can't just use len(e_i) here since we don't assume
           anything about x_i and so need to get completely rid of these
           variables. *)
        | BS (_, itype), _ ->
          E.int (Int_type.width itype)
        | e_i, _ ->
          match S.eval (Len e_i) with
          | Some n -> E.int n
          | None -> fail "mk_parsers: Cannot determine width of %s" (E.to_string e_i)
      in
      let p = Range (x, E.sum ls, l) in
      mk_parsers (ls @ [l]) (ps @ [p]) (es @ [e_i]) e_c

    | [] -> ps

let rec tag_facts ps e_c =
  match ps, e_c with
    | _ :: ps, (BS (Len _, _) | Var _) :: e_c ->
      tag_facts ps e_c
    | p :: ps, e_t :: e_c ->
      E.eq_bitstring [p; e_t] :: tag_facts ps e_c
    | [], [] -> []
    | _ -> failwith "tag_facts: impossible"

let intype_facts ts ps e_c =
  let args =
    List.combine ps e_c
    |> List.filter_map ~f:(fun (p_i, e_i) ->
      match e_i with
      | Var _ -> Some p_i
      | _ -> None)
  in
  List.map2 args ts ~f:E.in_type

let inrange fun_types e c c_def =
  let (arg_types, _) = Fun_type_ctx.find c fun_types in
  let x = mk_arg 0 in
  match c_def with
  | Concat e_c ->

    let ps = mk_parsers [] [] [] e_c in
    DEBUG "inrange: parsers: %s\n" (E.list_to_string ps);
    let fields = List.map ~f:E.is_defined ps in
    let tags = tag_facts ps e_c in
    let intype_facts = intype_facts arg_types ps e_c in

    List.map ~f:(E.subst [x] [e]) (fields @ tags @ intype_facts)

  | _ -> fail "inrange: encoder expected"

let is_inrange fun_types facts e c c_def =
  match c_def with
  | Concat _ ->
    push_debug "inrange";
    let parse_facts = inrange fun_types e c c_def in
    pop_debug "inrange";
    S.implies facts parse_facts
  | _ -> false

let check_encoder_safety fun_types facts e c c_def =
  DEBUG "Checking parsing safety of %s(...) = %s" (Sym.to_string c) (E.to_string e);
  let result = is_inrange fun_types facts e c c_def in
  DEBUG "Result = %b" result;
  result

let match_encoder fun_types parsing_eqs facts p e (c, c_def) =
  match Syms.Parsing_eq.find_match parsing_eqs ~p ~c with
  | Some i ->
    DEBUG "Found parsing equation for %s(%s)" (Sym.to_string p) (Sym.to_string c);
    if not (check_encoder_safety fun_types facts e c c_def)
    then None
    else Some (c, i)
  | _ ->
    DEBUG "Found no parsing equation for %s(%s)" (Sym.to_string p) (Sym.to_string c);
    None

let safe_parse fun_types (encoders : bitstring Sym_defs.t) parsing_eqs facts f_p e =
  DEBUG "Checking parsing safety for %s(%s)" (Sym.to_string f_p) (E.to_string e);
  let result =
    List.filter_map
      ~f:(match_encoder fun_types parsing_eqs facts f_p e)
      (Sym_defs.to_list encoders)
  in
  match result with
  | [] ->
    DEBUG "Parsing %s(%s) is not safe" (Sym.to_string f_p) (E.to_string e);
    None
  | [c, i] ->
    DEBUG "%s(%s) safely parses %s at position %d"
      (Sym.to_string f_p) (E.to_string e) (Sym.to_string c) i;
    Some (c, i)
  | (c, i) :: _ :: _ as cs ->
    let cs =
      List.map cs ~f:(fun (c, i) ->
        Printf.sprintf "%s at position %d" (Sym.to_string c) i)
      |> String.concat ~sep:", "
    in
    warn "Several safe parsing candidates for %s: %s, taking first"
      (Sym.to_string f_p) cs;
    Some (c, i)

(*************************************************)
(** {1 Trailing computation} *)
(*************************************************)

(**
  Remove unobservable computations at the end of a process.
*)
let remove_trailing_computations p =

  let rec remove p =
    match p with
    | (Out _ | Event _) :: _ -> p
    | _ :: p -> remove p
    | [] -> []
  in

  List.rev (remove (List.rev p))

(*************************************************)
(** {1 Renaming of syms based on equalities} *)
(*************************************************)

(* We don't really need this for CV since we can add rewriting rules, but we are
   using this for PV. I didn't try PV's equational theories. *)
let rename_syms syms fun_types p =
  let facts =
    Syms.arithmetic_facts syms fun_types @ Syms.encoder_facts syms fun_types
  in
  let rec rename f =
    List.find_map facts ~f:(function
      | Syms.Aux_fact.Equal ((typ1, f1), (typ2, f2)) when f = f2 && typ1 = typ2 ->
        Some f1
      | _ -> None)
    |> function
    | Some f -> rename f
    | None -> f
  in
  let rename = function
    | Let (VPat v, Annotation ((Arith _ | Encoder _) as ann,
                               Sym (Fun _ as f, es))) ->
      let f = rename f in
      Let (VPat v, Annotation (ann, Sym (f, es)))
    | stmt -> stmt
  in
  List.map p ~f:rename

(*************************************************)
(** {1 Testing} *)
(*************************************************)

let test () =
  push_debug "Transform.test";
  Var.reset_fresh ();
  test_normal_form_encoder ();
  Var.reset_fresh ();
  test_normal_form_fun ();
  pop_debug "Transform.test"

(* 1300 lines *)
