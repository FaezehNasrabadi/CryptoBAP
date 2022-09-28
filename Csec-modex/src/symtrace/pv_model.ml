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
open Typing
open Transform
open Cv_transform

module E = Exp
module S = Solver


open Printf

module Piml = struct
  (* Same as IML, but with strong lets and equality tests. *)
  type stmt =
  | Let of Pat.t * bterm
  | Eq_test of bterm * bterm
  | Test of fact
  | Assume of fact
  | In of var list
  | Out of bterm list
  | New of var * bitstring Type.t
  | Event of string * bterm list
  | Yield
  | Comment of string

  let facts = function
    | Test fact | Assume fact -> [Exp.expand_defs fact]
    | Let (VPat v, e) ->
      let v = Var (v, Kind.Bitstring) in
      let e = E.expand_defs e in
      [ Exp.eq_bitstring [ v; e ]
      ; Exp.eq_int [Len v; Len e] ]
    | Eq_test (e1, e2) -> [Exp.eq_bitstring [e1; e2]]
    | In vs -> List.map vs ~f:(fun v -> Exp.is_defined (Var (v, Kind.Bitstring)))
    | New (v, t) -> [Exp.in_type (Var (v, Kind.Bitstring)) t]
    | _ -> []

  type t = stmt list

  let rec remove_assumptions = function
    | Assume _ :: p -> remove_assumptions p
    | s :: p -> s :: remove_assumptions p
    | [] -> []

  let descend {Exp.descend = f} = function
    | Let (pat, e) -> Let(pat, f e)
    | Test e -> Test (f e)
    | Eq_test (e1, e2) -> Eq_test (f e1, f e2)
    | Assume e -> Assume (f e)
    | In vs -> In vs
    | Out es -> Out (List.map ~f es)
    | New (v, t) -> New (v, t)
    | Event (ev, es) -> Event (ev, List.map ~f es)
    | Yield -> Yield
    | Comment s -> Comment s

  let map f p =
    List.map ~f:(descend f) p

  let is_auxiliary_test = function
    | Test (Sym (Sym.Fun _, _)) -> false
    | Test _ -> true
    | _ -> false
end

type t = {
  client : Piml.t;
  server : Piml.t;
  template : Template.t;
  fun_types : Fun_type_ctx.t;
  syms : Syms.t
}

(* The resulting process remains well-typed and has functions that are type-safe
   up to failure. *)
let strengthen var_types fun_types syms iml : Piml.t =
  let encoders = Syms.encoders syms in
  let parsing_eqs = Syms.parsing_eqs syms fun_types in
  let is_defined e =
    match E.remove_annotations e with
    | Sym (Fun _ as f, _) ->
      let _, result_type = Fun_type_ctx.find f fun_types in
      Type.is_defined result_type
    | Var (v, _) ->
      Type.is_defined (Type_ctx.find_with_default v var_types)
    | e ->
      fail "strengthen: unexpected expression: %s" (E.to_string e)
  in
  let rec convert facts = function
    | [] -> []
    | stmt :: p ->
      DEBUG "strengthen:\n%s with\n %s"
        (Stmt.to_string stmt) (Exp.list_to_string facts);
      let p = convert (facts @ Stmt.facts stmt) p in
      match stmt with
      | Let (VPat v, e) ->
        if not (is_defined e)
        then fail "strengthen: cannot strengthen:\n%s" (Stmt.to_string stmt)
        else begin match e with
        | Annotation (Parser def, Sym (Fun _ as f_p, [e_c])) ->
          let safety = with_debug "parsing_safety" (fun () ->
            safe_parse fun_types encoders parsing_eqs facts f_p e_c)
          in
          begin match safety with
          | Some (c, _) ->
            Piml.Let (VPat v,
                      Annotation (Pi_parser (def, c), Sym (f_p, [e_c]))) :: p
          | None ->
            Piml.Let (VPat v, e) :: p
          end
        | Sym (Fun (f, _), [Sym (Fun (g, k), es)]) when is_inverse f ->
          (* CR: confirm that the type of f is defined. *)
          (* We merge g and f into one function of a new type (which we don't
             make explicit since we don't use it. We rename the resulting
             function to make sure we don't reuse the old type by accident. *)
          let g = sprintf "%s_injbot" g in
          Piml.Let (VPat v,
                    Sym (Fun (g, k), es)) :: p
        | e -> Piml.Let (VPat v, e) :: p
        end
      | Let ((FPat _ | Underscore), _) ->
        fail "Pv_model.strengthen: unsupported:\n %s." (Stmt.to_string stmt)
      | Eq_test (e1, e2) ->
        if is_defined e1 && is_defined e2
        then Piml.Eq_test (e1, e2) :: p
        else fail "strengthen: cannot strengthen:\n %s" (Stmt.to_string stmt)
      (* Propagate the rest *)
      | Test fact -> Piml.Test fact :: p
      | Assume fact -> Piml.Assume fact :: p
      | In vs -> Piml.In vs :: p
      | Out es -> Piml.Out es :: p
      | New (v, t) -> Piml.New (v, t) :: p
      | Event (ev, es) -> Piml.Event (ev, es) :: p
      | Yield -> Piml.Yield :: p
      | Comment s -> Piml.Comment s :: p
  in
  convert (Type_ctx.facts var_types) iml

let erase_conditionals var_types fun_types syms piml =
  let open Piml in
  let rec downstream_facts = function
    | [] -> []
    | (In _ | Out _) :: _ -> []
    | stmt :: p ->
      let stmt_facts = Piml.facts stmt in
      match stmt with
      | Let (VPat _, Annotation (Pi_parser (_, f_c), Sym (_, [e]))) ->
        let e = E.expand_defs e in
        inrange fun_types e f_c (Syms.def syms f_c)
        @ stmt_facts
        @ downstream_facts p
      | Let (VPat _, e) ->
        let e = E.expand_defs e in
        E.is_defined e
        :: stmt_facts
        @ downstream_facts p
      (* This might itself get erased in future, so we don't assume this. *)
      | Test _ -> downstream_facts p
      | _ -> stmt_facts @ downstream_facts p
  in
  let rec erase facts = function
    | (Test e_fact as s) :: p when Piml.is_auxiliary_test s ->
      let local_facts = facts @ downstream_facts p in
      let e = E.expand_defs e_fact in
      if not (S.implies local_facts [e])
      then warn "Cannot erase %s = %s based on facts\n %s"
        (E.to_string e_fact) (E.to_string e) (E.list_to_string local_facts);
      erase (facts @ [e]) p
    | s :: p -> s :: erase (facts @ Piml.facts s) p
    | [] -> []
  in
  erase (Type_ctx.facts var_types) piml

(* This is safe under the assumption that all functions return bottom if their
   argument is of a wrong type. *)
let remove_casts p =
  let rec remove_casts : type a. a exp -> a exp = function
    | Sym (Cast _, [e]) -> remove_casts e
    | e -> E.descend {descend = remove_casts } e
  in
  Piml.map { E.descend = remove_casts } p

let of_cv_model cv_model =
  let {
    Cv_model.
    client; server;
    template;
    var_types;
    fun_types;
    primed = _;
    syms
  } = cv_model
  in
  Syms.check_is_regular syms fun_types;
  debug_iml client server "IML before building PV model";
  push_debug "strengthen";
  let client = strengthen var_types fun_types syms client in
  let server = strengthen var_types fun_types syms server in
  pop_debug "strengthen";
  push_debug "erase_conditionals";
  let client = erase_conditionals var_types fun_types syms client in
  let server = erase_conditionals var_types fun_types syms server in
  pop_debug "erase_conditionals";
  let client = remove_casts client in
  let server = remove_casts server in
  { client;
    server;
    template;
    fun_types;
    syms
  }

(*************************************************)
(** {1 Output} *)
(*************************************************)

module Parsing_eq = struct
  include Syms.Parsing_eq

  let to_string {p; c; i} =
    let arity = Sym.arity c in
    let args = mk_formal_args arity |> List.map ~f:Var.to_string in
    Printf.sprintf "%s(%s(%s)) = %s"
      (Sym.to_string p)
      (Sym.to_string c)
      (String.concat ~sep:", " args)
      (E.mk_arg i |> Var.to_string)
end

let printf a = fprintf Common.out_channel a

let show_pv_stmt s =
  let open Piml in
  let rec show_exp_body : type a. a exp -> string = function
    | Var (v, _) -> Var.to_string v
    | Sym (Fun (s, _), []) -> s
    | Sym (s, es) ->
      begin match s with
      | Cast _ -> ()
      | Fun _ -> ()
      | s -> fail "print cv: unexpected symbol: %s" (Sym.to_string s)
      end;
      sprintf "%s(%s)"
        (Sym.to_string s)
        (String.concat ~sep:", " (List.map ~f:show_exp_body es))
    | Annotation (_, e) -> show_exp_body e
    | e -> "unexpected{" ^ E.dump e ^ "}"
  in
  match s with
    | In [v] ->
      sprintf "in(c_in, %s);" (Var.to_string v);

    | In vs ->
      let vs = List.map vs ~f:Var.to_string |> String.concat ~sep:", " in
      sprintf "in(c_in, (%s));" vs

    | New (v, _) ->
      sprintf "new %s;" (Var.to_string v);

    | Out [e] ->
      "out(c_out, " ^ show_exp_body e ^ ");";

    | Out es ->
      "out(c_out, (" ^ String.concat ~sep:", " (List.map ~f:show_exp_body es) ^ "));";

    | Eq_test (e1, e2) ->
      "if " ^ show_exp_body e1 ^ " = " ^ show_exp_body e2 ^ " then "

    | Test e ->
      "if " ^ show_exp_body e ^ " = true then "

    | Assume e ->
      Printf.sprintf "assume %s in" (show_exp_body e)

    | Event (name, es) ->
      "event " ^ name ^ "(" ^ String.concat ~sep:", " (List.map ~f:show_exp_body es) ^ ");"

    | Let (pat, e) ->
      "let " ^ Pat.dump pat ^ " = " ^ show_exp_body e ^ " in"

    | Yield -> "0 ."

    | Comment s -> sprintf "(* %s *)" s

let show_pv_process p =
  let open Piml in
  let zero =
    if p = [] then " 0 .\n" else
    match List.last p with
      | Yield -> "\n"
      | _ -> " 0 .\n"
  in
  let result = String.concat ~sep:"\n" (List.map ~f:show_pv_stmt p) ^ zero in
  result

let print model =
  let {
    client;
    server;
    fun_types;
    template;
    syms;
  } = model
  in
  let parsers = Syms.parsers syms in
  let encoders = Syms.encoders syms in
  let arith = Syms.arith syms in
  let parsing_eqs = Syms.parsing_eqs syms fun_types in
  let print_fun f _def =
    if Template.is_defined_in_pv template f
    then printf "(* %s is already defined in the template *)\n\n"
      (Sym.to_string f)
    else printf "data %s/%d.\n" (Sym.to_string f) (Sym.arity f)
  in

  List.iter ~f:print_endline (Template.crypto template);

  print_endline "\n(*************************** \n  Encoders \n***************************)\n";
  Sym_defs.iter ~f:print_fun encoders;

  print_endline "\n(******************** \n  Parsers \n********************)\n";
  Sym_defs.iter parsers ~f:(fun p _ ->
    let parsing_eqs =
      List.filter parsing_eqs ~f:(fun {Parsing_eq. p = p'; _} -> p = p')
      |> List.map ~f:Parsing_eq.to_string
    in
    printf "reduc\n  %s.\n" (String.concat parsing_eqs ~sep:";\n  "));

  print_endline "\n(*************************** \n  Arithmetic Functions \n***************************)\n";
  Sym_defs.iter ~f:print_fun arith;
  print_endline "";

  List.iter ~f:print_endline (Template.crypto2 template);
  List.iter ~f:print_endline (Template.query template);

  print_endline "\n(*************************** \n  Model \n***************************)\n";
  let client_proc = show_pv_process (Piml.remove_assumptions client) in
  let server_proc = show_pv_process (Piml.remove_assumptions server) in
  print_endline "let client = ";
  print_endline client_proc;
  print_endline "let server = ";
  print_endline server_proc;

  List.iter ~f:print_endline (Template.envp template)
