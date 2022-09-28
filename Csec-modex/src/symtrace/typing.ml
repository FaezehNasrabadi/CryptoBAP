(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common

open Type
open Sym
open Exp
open Iml
open Iml.Pat
open Iml.Stmt

module E = Exp
module S = Solver

module Type_ctx = struct
  module Map = Var.Map
  type 'a map = 'a Map.t
  type t = bitstring Type.t map
  include (Map : Custom_map with type 'a t := 'a map
                            and type key = Var.t)

  let dump t =
    iter (fun v t ->
      prerr_endline (Printf.sprintf "%s: %s"
                       (Var.to_string v)
                       (Type.to_string t))) t;
    prerr_endline ""

  let merge ts =
    let merge_types _key t1 t2 = Some (Type.intersection t1 t2) in
    merge ~f:merge_types ts

  let find_with_default v t =
    match maybe_find v t with
    | Some typ -> typ
    | None -> Type.Bitstring

  let facts t =
    to_list t
    |> List.map ~f:(fun (v, typ) -> E.in_type (Var (v, Kind.Bitstring)) typ)
end

module Fun_type_ctx = struct
  module Key = struct
    type 'a t = (bitstring, 'a) Sym.t
  end

  module Value = struct
    type 'a t = (bitstring, 'a) Fun_type.t

    module Kind = Kind
    let kind (_, t) = Type.kind t
  end

  include Sym.Map_any (Value)

  let dump t =
    iter t {f = fun f t ->
      prerr_endline (Sym.cv_declaration f t) };
    prerr_endline ""

  let add_primed f (t : t) : t =
    let typ = find f t in
    add (Sym.prime f) typ t
end

let exp_type fun_types var_types e =
  let rec exp_type : type a. a exp -> a Type.t option = function
    | Var (v, Kind.Bitstring) ->
      (Type_ctx.maybe_find v var_types : bitstring Type.t option)
    | Annotation (Type_hint t, _) -> Some t
    | Annotation (_, e) -> exp_type e
    | Sym (Fun _ as sym, _) ->
      Option.map (Fun_type_ctx.maybe_find sym fun_types) ~f:snd
    | e -> fail "Typing.exp_type: %s" (E.to_string e)
  in
  exp_type e

let cast t t' e =
  if t = t' then e else
    Sym (Cast (t, t'), [e])

let rec casts p =
  let rec casts_e
      : type a. a exp -> (bitstring Type.t * bitstring Type.t) list = fun e ->
        let cs = E.map_children { E.f = casts_e } e |> List.concat in
        match e with
        | Sym (Cast (t, t'), _) -> (t, t') :: cs
        | _ -> cs
  in
  match p with
  | s :: p ->
    List.concat (Stmt.map_children { E.f = casts_e } s) @ casts p
  | [] -> []

let rec infer_exp
    : type a. Fun_type_ctx.t -> a Type.t option -> a exp -> Type_ctx.t
  = fun fun_types t e ->
    match e with
    | Var (v, Kind.Bitstring) ->
      begin match t with
      | None -> Type_ctx.empty
      | Some t -> Type_ctx.singleton v t
      end

    | Annotation (Type_hint t, e) -> infer_exp fun_types (Some t) e

    | Sym (Fun _ as f, es) ->
      begin match Fun_type_ctx.maybe_find f fun_types with
      | None ->
        Type_ctx.merge (List.map ~f:(infer_exp fun_types None) es)
      | Some (ts, _) ->
        Type_ctx.merge (List.map2 es ts ~f:(fun e t ->
          infer_exp fun_types (Some t) e))
      end

    | Annotation(_, e) -> infer_exp fun_types t e

    | Sym (Cast (t, _), [e]) ->
      infer_exp fun_types (Some t) e

    | Sym (Logical Logical.Eq, [e1; e2]) ->
      Type_ctx.merge [infer_exp fun_types (Some Type.Bool) e1;
                      infer_exp fun_types (Some Type.Bool) e2]

    | Sym (Bs_eq, [e1; e2]) ->
      Type_ctx.merge [infer_exp fun_types None e1;
                      infer_exp fun_types None e2]

    | e -> fail "infer_exp: unexpected expression %s" (E.dump e)


let infer ~(trusted_types: Fun_type_ctx.t) (p: iml) : Type_ctx.t =

  let exp_type trusted_types e = exp_type trusted_types Type_ctx.empty e in
  let infer_exp e = infer_exp trusted_types e in

  let rec infer = function
    | Let (VPat v, e) :: p ->
      let ctx_e = infer_exp None e in
      let ctx_p = infer p in
      let ctx = Type_ctx.merge [ctx_e; ctx_p] in
      begin match exp_type trusted_types e with
      | None -> ctx
      | Some t -> Type_ctx.add v t ctx
      end

    | Let ((FPat _ | Underscore), _) :: _ ->
      fail "infer_types: let patterns not supported: %s" (Iml.to_string p)

    | New (v, t) :: p ->
      let ctx = infer p in
      Type_ctx.add v t ctx

    | In vs :: p ->
      let ctx = infer p in
      List.fold_left vs ~init:ctx ~f:(fun ctx v ->
        Type_ctx.add v Bitstring ctx)

    | Test e :: p ->
      let ctx_e = infer_exp (Some Bool) e in
      let ctx_p = infer p in
      Type_ctx.merge [ctx_e; ctx_p]

    | Eq_test (e1, e2) :: p ->
      let ctx1 = infer_exp None e1 in
      let ctx2 = infer_exp None e2 in
      let ctx_p = infer p in
      Type_ctx.merge [ctx1; ctx2; ctx_p]

    | Assume _ :: p ->
      infer p

    | Event (ev, es) :: p ->
      (* Events symbols are of type bool in CV *)
      let sym = Sym.make_bool ev ~arity:(List.length es) in
      let ctx_e = infer_exp (Some Bool) (Sym (sym, es)) in
      let ctx_p = infer p in
      Type_ctx.merge [ctx_e; ctx_p]

    | Out es :: p ->
      let ctx_s = List.map ~f:(infer_exp None) es in
      let ctx_p = infer p in
      Type_ctx.merge (ctx_p :: ctx_s)

    | (Comment _ | Yield) :: p -> infer p

    | [] -> Type_ctx.empty
  in
  infer p

  (** Returns only the context for formatter functions. Merge with user functions
      yourself.

      Assumes that the process is in the formatting-normal form, that is,
      every formatter application has the form let [x = f(x1, ..., xn)].
  *)
let derive_unknown_types
    ~trusted_types
    (ctx: Type_ctx.t)
    (p: iml) : Fun_type_ctx.t =
  let find_type v = Type_ctx.find_with_default v ctx in
  let rec derive derived_types = function
    | [] -> derived_types
    | Let (VPat v, Sym (Fun _ as f, vs)) as s :: p
        when not (Fun_type_ctx.mem f trusted_types) ->
      let ts =
        List.map vs ~f:(function
        | Var (v, Kind.Bitstring) -> find_type v
        | _ -> fail "formatting-normal form expected: %s" (Stmt.to_string s))
      in
      let derived_types =
        Fun_type_ctx.add f (ts, find_type v) derived_types
      in
      derive derived_types p
    | Test (Sym (Fun _ as f, vs)) as s :: p
        when not (Fun_type_ctx.mem f trusted_types) ->
      let ts =
        List.map vs ~f:(function
        | Var (v, Kind.Bitstring) -> find_type v
        | _ -> fail "malformed test statement: %s" (Stmt.to_string s))
      in
      let derived_types =
        Fun_type_ctx.add f (ts, Bool) derived_types
      in
      derive derived_types p
    | _ :: p -> derive derived_types p
  in
  derive Fun_type_ctx.empty (Iml.remove_annotations p)

let prove_type
    (facts : fact list)
    ((arg_types, res_type) : (bitstring, bitstring) Fun_type.t)
    (f : (bitstring, bitstring) Sym.t)
    (f_def : bterm)
    (args: bterm list) : bool =

  if List.length args <> List.length arg_types then
    fail "wrong number of arguments: %s(%s)" (Sym.to_string f) (E.dump_list args);

  let formal_args = E.mk_formal_args (List.length args) in
  let e_f = E.subst formal_args args f_def in

    (*
      debug ("typecheck: e_def = " ^ E.dump e_def);
      debug ("typecheck: context = " ^ dump_list ctx);
    *)

  let arg_facts = List.map2 ~f:E.in_type args arg_types in
  let res_fact = E.in_type e_f res_type in

  DEBUG "proving type %s" (Sym.cv_declaration f (arg_types, res_type));
  S.implies (arg_facts @ facts) [res_fact]

let erase_type_annotations p =
  let rec erase : type a. a exp -> a exp = function
    | Annotation (Type_hint _, e) -> erase e
    | e -> E.descend {E.descend = erase} e
  in
  Iml.map {E.descend = erase} p

let check
    ~(all_types : Fun_type_ctx.t)
    ~(trusted_types : Fun_type_ctx.t)
    (ctx: Type_ctx.t)
    (facts: fact list)
    (p: iml) : iml =

  let typefacts ctx =
    Type_ctx.to_list ctx
    |> List.map ~f:(fun (v, t) -> E.in_type (Var (v, Type.kind t)) t)
  in

  let rec check_exp
      : type a. Type_ctx.t -> fact list -> a Type.t -> a exp -> a exp
      = fun ctx facts t' e ->
        let fail_sym f f_type =
          fail "typecheck: cannot prove type %s" (Sym.cv_declaration f f_type)
        in
        let check_fun f es def =
          let (ts, t) = Fun_type_ctx.find f all_types in
          if not (Type.equal t t')
          then fail "check_formatting %s <> %s"
            (Type.to_string t) (Type.to_string t');
          let es' = List.map2 ~f:(check_exp ctx facts) ts es in
          let e' = Sym (f, es') in
          if not (prove_type (facts @ typefacts ctx) (ts, t) f def es)
          then fail_sym f (ts, t)
          else e'
        in
        match e with
        | Var (v, Kind.Bitstring) ->
          let t = Type_ctx.find v ctx in
          if not (S.implies
                    (facts @ typefacts ctx)
                    [E.in_type (Var (v, Type.kind t')) t'])
          then fail  "cannot prove type: %s: %s"
            (Var.to_string v)
            (Type.to_string t');
          cast t t' e

        | Sym (Fun _ as f, es) ->
          let (ts, t) = Fun_type_ctx.find f trusted_types in
          let es' = List.map2 ~f:(check_exp ctx facts) ts es in
          let e' = Sym (f, es') in
          begin match Type.kind t with
          | Kind.Int -> assert false
          | Kind.Bool ->
            if t <> Bool || t' <> Bool then fail_sym f (ts, t') else e'
          | Kind.Bitstring ->
            if not (Type.subtype t t') then fail_sym f (ts, t') else cast t t' e'
          end

        (* CR-soon: actually prove the type of auxiliarys *)
        | Annotation (Auxiliary def, Sym (Fun _ as f, es)) ->
          let (ts, t) = Fun_type_ctx.find f all_types in
          let es' = List.map2 ~f:(check_exp ctx facts) ts es in
          let e' = Annotation (Auxiliary def, Sym (f, es')) in
          if t <> Bool || t' <> Bool then fail_sym f (ts, t') else e'

        | Annotation (Parser def, Sym (Fun _  as f, es)) ->
          let e' = check_fun f es def in
          Annotation (Parser def, e')

        | Annotation (Encoder def, Sym (Fun _  as f, es)) ->
          let e' = check_fun f es def in
          Annotation (Encoder def, e')

        | Annotation (Arith def, Sym (Fun _  as f, es)) ->
          let e' = check_fun f es def in
          Annotation (Arith def, e')

        (* Type annotations are only used in inference, and ignored in
           typechecking *)
        | Annotation (a, e) -> Annotation (a, check_exp ctx facts t' e)

        | e -> fail "check_exp: unexpected expression %s" (E.dump e)
  in

  let exp_type all_types ctx e = Option.value_exn (exp_type all_types ctx e) in

  let rec check ctx facts p =
    match p with
    | Let (VPat v, e) :: p ->
      let t = exp_type all_types ctx e in
      let e' = check_exp ctx facts t e in
      let p' = check (Type_ctx.add v t ctx) facts p in
      Let (VPat v, e') :: p'

    | Let (_, _) :: _ -> fail "check_types: let patterns not supported: %s" (Iml.to_string p)

    | Test e :: p ->
      let e = check_exp ctx facts Bool e in
      let p = check ctx (facts @ [E.expand_defs e]) p in
      Test e :: p

    | Eq_test (e1, e2) :: p ->
      let t1 = exp_type all_types ctx e1 in
      let t2 = exp_type all_types ctx e2 in
      let tt = Type.union t1 t2 in
      let e1 = check_exp ctx facts tt e1 in
      let e2 = check_exp ctx facts tt e2 in
      (* Not adding a non-auxiliary test to facts *)
      let p = check ctx facts p in
      Eq_test(e1, e2) :: p

    | Assume e :: p ->
      Assume e :: check ctx (facts @ [e]) p

    | In vs :: p ->
      let ctx_v = Type_ctx.of_list (List.map ~f:(fun vs -> vs, Bitstring) vs) in
      let p' = check (Type_ctx.merge [ctx; ctx_v]) facts p in
      In vs :: p'

    | New (v, t) :: p ->
        (* Not checking whether the type is fixed, because of the types created by
           Apply_nondet *)
      let p' = check (Type_ctx.add v t ctx) facts p in
      New (v, t) :: p'
      (*
        begin match Type.strip_name t with
        | Fixed _ ->
        let p' = check (Type_ctx.add v t ctx) facts p in
        New (v, t) :: p'
        | _ -> fail "fixed type expected in new expression: %s" (Stmt.to_string (New (v, t)))
        end
      *)

    | Out es :: p ->
      let es' = List.map es ~f:(fun e ->
        check_exp ctx facts (exp_type all_types ctx e) e)
      in
      let p' = check ctx facts p in
      Out es' :: p'

    | Event (ev, es) :: p ->
      let sym = Sym.make_bool ev ~arity:(List.length es) in
      let (ts, _) = Fun_type_ctx.find sym all_types in
      let es' = List.map2 ~f:(fun e t -> check_exp ctx facts t e) es ts in
      let p' = check ctx facts p in
      Event (ev, es') :: p'

    | Yield :: p -> Yield :: check ctx facts p

    | Comment s :: p -> Comment s :: check ctx facts p

    | [] -> []
  in
  erase_type_annotations (check ctx facts p)

let check_robust_safety (encoders : bitstring Sym_defs.t) (fun_types : Fun_type_ctx.t) =
  let safe f def =
    let (ts, t) = Fun_type_ctx.find f fun_types in
    let args = E.mk_formal_args (Sym.arity f) |> List.map ~f:E.var in
    if not (prove_type [] (ts, t) f def args && t <> Bitstringbot) then
      fail "function %s is not robustly safe" (Sym.cv_declaration f (ts, t));
  in
  Sym_defs.iter ~f:safe encoders

(* Give an error and perhaps a suggestion if a type is missing in a template. *)
let check_missing_types
    ~trusted_types ~inferred_types p =
  let is_missing f=
    not (Fun_type_ctx.mem f trusted_types)
  in
  let rec check : type a. a exp -> unit = function
    (* If it's a function that we introduced, never mind *)
    | Annotation (ann, Sym (Fun _, es)) when E.is_def_annotation ann ->
      List.iter ~f:check es
    | Sym (Fun _ as f, es) ->
      if is_missing f
      then begin match Fun_type_ctx.maybe_find f inferred_types with
      | Some t ->
        fail "No type found for function %s, suggested type: %s"
          (Sym.to_string f) (Sym.cv_declaration f t);
      | None ->
        fail "No type found for function %s" (Sym.to_string f);
      end;
      List.iter ~f:check es
    | e -> E.iter_children {E.f = check} e
  in
  Fun_type_ctx.dump trusted_types;
  List.iter p ~f:(function
  | Assume _ -> ()
  | stmt -> Stmt.iter_children {E.f = check} stmt)

let test_cond_checking () =
  let t1 = Type.Named ("t", None) in
  let t2 = Type.Bitstring in
  let aux = Fun ("auxiliary", (1, Kind.Bool)) in
  let f = Fun ("auxiliary", (1, Kind.Bitstring)) in
  let cast = Cast (t1, t2) in
  let v = E.var_s "v" in
  let all_types =
    Fun_type_ctx.empty
    |> Fun_type_ctx.add aux ([t2], Type.Bool)
    |> Fun_type_ctx.add f   ([t2], t1)
  in
  let var_types = Type_ctx.of_list
    [ Var.of_string "v", Type.Bitstring ]
  in
  let p = [Test (Sym (aux, [Sym (f, [v])]))] in
  let p' = check ~all_types ~trusted_types:all_types var_types [] p in
  let expect =
    [Test (Sym (aux, [Sym (cast, [Sym (f, [v])])]))] in
  test_result ~expect p' Iml.to_string

let test () =
  test_cond_checking ()
