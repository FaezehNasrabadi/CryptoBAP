open Sym
open Exp
open Iml
open Iml.Stmt
open Common
open Typing
open Transform
open Cv_transform

open Printf

type t = {
  client : iml;
  server : iml;
  template : Template.t;
  var_types : Type_ctx.t;
  fun_types : Fun_type_ctx.t;

  primed : Sym.any_bitstring list;

  syms : Syms.t;
}

let encoders t =
  Syms.encoders t.syms

let parsers t =
  Syms.parsers t.syms

let arith t =
  Syms.arith t.syms

let auxiliary t =
  Syms.auxiliary t.syms

let rec collect_primed :
type a. a exp -> Sym.any_bitstring list =
  fun e ->
    match e with
    | Sym (Fun _ as sym, es) ->
      begin match Sym.unprime sym with
      | Some sym ->
        Sym.Any_bitstring sym :: List.concat_map es ~f:collect_primed
      | None -> List.concat_map es ~f:collect_primed
      end
    | e -> List.concat (Exp.map_children { f = collect_primed } e)

(* CR-soon: consider using Fun_type_ctx.add_primed. *)
let add_primed t =
  let auxiliary_facts = Syms.auxiliary_facts t.syms t.fun_types in
  let originals =
    List.concat_map auxiliary_facts ~f:(fun (Cv_fact.Forall (_, fact)) ->
      collect_primed fact)
    |> List.dedup
  in
  let fun_types =
    List.fold_left originals ~init:t.fun_types ~f:(fun fun_types (Any_bitstring sym) ->
      let t = Fun_type_ctx.find sym t.fun_types in
      Fun_type_ctx.add (Sym.prime sym) t fun_types)
  in
  let primed =
    List.map originals ~f:(fun (Any_bitstring sym) -> Any_bitstring (Sym.prime sym))
  in
  { t with fun_types; primed }


(*************************************************)
(** {1 CV Output} *)
(*************************************************)

module Aux_fact = struct
  include Syms.Aux_fact

  let show_relation
      ((arg_types1, _), c1)
      ((arg_types2, _), c2)
      op =
    let id = ref 0 in

    let formal_arg _ =
      id := !id + 1;
      "var" ^ string_of_int !id
    in
    let show_arg v t =
      v ^ ": " ^ Type.to_string t
    in

    let args1 = List.map ~f:formal_arg arg_types1 in
    let args2 =
      if op = "<>" then List.map ~f:formal_arg arg_types2
      else args1
    in
    let all_args =
      List.dedup (List.map2 ~f:show_arg args1 arg_types1
                  @ List.map2 ~f:show_arg args2 arg_types2)
    in
    sprintf "forall %s;\n  %s(%s) %s %s(%s)."
      (String.concat ~sep:", " all_args)
      (Sym.to_string c1) (String.concat ~sep:", " args1)
      op
      (Sym.to_string c2) (String.concat ~sep:", " args2)

  let to_string = function
    | Disjoint (s, s') -> show_relation s s' "<>"
    | Equal    (s, s') -> show_relation s s' "="
end

module Cv_fact = struct
  include Cv_fact

  let to_string (Forall (args, e)) =
    let show_var (v, t) = Var.to_string v ^ ": " ^ Type.to_string t in
    "forall " ^ String.concat ~sep:", " (List.map ~f:show_var args)
    ^ ";\n\t" ^ E.to_string e ^ "."
end

let printf a = fprintf Common.out_channel a

let show_cv_stmt: Stmt.t -> string = fun s ->

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

  and show_in_var t name = Var.to_string name ^ ": " ^ Type.to_string t in

  match s with
    | In [v] ->
      "in(c_in, " ^ show_in_var Bitstring v ^ ");";

    | In vs ->
      "in(c_in, (" ^ String.concat ~sep:", " (List.map ~f:(show_in_var Bitstring) vs) ^ "));";

    | New (v, t) ->
      "new " ^ show_in_var t v ^ ";";

    | Out [e] ->
      "out(c_out, " ^ show_exp_body e ^ ");";

    | Out es ->
      "out(c_out, (" ^ String.concat ~sep:", " (List.map ~f:show_exp_body es) ^ "));";

    | Eq_test (e1, e2) ->
      "if " ^ show_exp_body e1 ^ " = " ^ show_exp_body e2 ^ " then "

    | Test e ->
      "if " ^ show_exp_body e ^ " then "

    | Assume _ -> assert false

    | Event (name, es) ->
      "event " ^ name ^ "(" ^ String.concat ~sep:", " (List.map ~f:show_exp_body es) ^ ");"

    | Let (pat, e) ->
      "let " ^ Pat.dump pat ^ " = " ^ show_exp_body e ^ " in"

    | Yield -> "yield ."

    | Comment s -> sprintf "(* %s *)" s

let show_cv_process p =
  let zero =
    if p = [] then " 0 .\n" else
    match List.last p with
      | Yield -> "\n"
      | _ -> " 0 .\n"
  in
  let result = String.concat ~sep:"\n" (List.map ~f:show_cv_stmt p) ^ zero in
  result

let print model =
  let {
    client; 
    server;
    template;
    var_types = _;
    fun_types;
    primed;
    syms
  } = model
  in
  let parsers = parsers model in
  let encoders = encoders model in
  let auxiliary = auxiliary model in
  let arith = arith model in
  let casts = List.dedup (Typing.casts client @ Typing.casts server) in
  let parsing_eqs = Syms.parsing_eqs syms fun_types in
  let encoder_facts = Syms.encoder_facts syms fun_types in
  let arithmetic_facts = Syms.arithmetic_facts syms fun_types in
  let auxiliary_facts = Syms.auxiliary_facts syms fun_types in
  let zero_funs = Syms.zero_funs syms fun_types in
  let zero_facts = Syms.zero_facts syms fun_types in
  let print_fun_def is_injective sym def =
    if Template.is_defined template sym
    then
      printf "(* %s is already defined in the template *)\n\n" (Sym.to_string sym)
    else begin
      begin match def with
      | Unknown _ -> ()
      | def -> print_endline ("(* " ^ E.show_fun sym def ^ " *)")
      end;
      let compos = if is_injective then " [compos]." else "." in
      match sym with
      | Fun (s, (0, _)) ->
        let _, t = Fun_type_ctx.find sym fun_types in
        print_endline ("const " ^ s ^ ": " ^ Type.to_string t ^ ".");
        print_endline ""
      | sym ->
        print_endline ("fun "
                       ^ Sym.cv_declaration sym (Fun_type_ctx.find sym fun_types)
                       ^ compos);
        print_endline ""
    end
  in
  let print_encoder sym def =
    (* All our encoders are robustly injective. *)
    print_fun_def true sym def;
  in
  let print_cast (t, t') =
    print_endline ("fun " ^ Sym.to_string (Cast (t, t'))
                   ^ "(" ^ Type.to_string t ^ "): " ^ Type.to_string t' ^ " [compos].")
  in
  let print_arithmetic sym def =
    let is_injective = is_injective_arithmetic def in
    print_fun_def is_injective sym def
  in
  (* TODO: most of these can now be printed by converting to Cv_facts *)
  let print_cast_eq (t, t') =
    (* check that the inverse function is defined at all *)
    if List.mem (t', t) ~set:casts && Type.subtype t t' then
      begin
        print_endline ("forall x: " ^ Type.to_string t ^ ";");
        print_endline ("  " ^ Sym.to_string (Cast (t', t)) ^ "(" ^ Sym.to_string (Cast (t, t')) ^ "(x)) = x.")
      end
  in
  (*
    let print_constant name def =
    let t = Type_ctx.find name model.var_types in
    print_endline ("(* " ^ E.dump def ^ " *)");
    print_endline ("const " ^ name ^ ": " ^ Type.to_string t ^ ".")
    in
  *)
  let print_aux_fact fact = print_endline (Aux_fact.to_string fact) in
  let print_cv_fact fact = print_endline (Cv_fact.to_string fact) in

  List.iter ~f:print_endline (Template.crypto template);

  (*
    print_endline "\n(*************************** \n Constants \n***************************)\n";
    Var.Map.iter print_constant model.constants;
  *)

  print_endline "\n(*************************** \n  Formatting Functions \n***************************)\n";
  Sym_defs.iter ~f:print_encoder encoders;
  Sym_defs.iter ~f:(print_fun_def false) parsers;
  print_endline "";
  List.iter ~f:print_aux_fact encoder_facts;

  print_endline "\n(*************************** \n  Parsing Equations \n***************************)\n";
  List.iter ~f:(fun eq ->
    print_endline (Syms.Parsing_eq.to_string ~fun_types eq)) parsing_eqs;

  print_endline "\n(*************************** \n  Arithmetic Functions \n***************************)\n";
  Sym_defs.iter ~f:print_arithmetic arith;
  List.iter ~f:print_aux_fact arithmetic_facts;

  print_endline "\n(*************************** \n  Auxiliary Tests \n***************************)\n";
  Sym_defs.iter ~f:(print_fun_def false) auxiliary;

  print_endline "\n(*************************** \n  Zero Functions \n***************************)\n";
  Sym_defs.iter ~f:(print_fun_def false) zero_funs;

  print_endline "\n(*************************** \n  Primed Functions \n***************************)\n";
  List.iter primed ~f:(fun (Any_bitstring sym) ->
    print_fun_def false sym (Unknown (Sym.kind sym)));

  print_endline "\n(*************************** \n  Typecasting \n***************************)\n";
  List.iter ~f:print_cast casts;
  List.iter ~f:print_cast_eq casts;

  print_endline "\n(*************************** \n  Auxiliary Facts \n***************************)\n";
  List.iter ~f:print_cv_fact auxiliary_facts;

  print_endline "\n(*************************** \n  Zero Facts \n***************************)\n";
  List.iter ~f:print_cv_fact zero_facts;

  print_endline "";

  List.iter ~f:print_endline (Template.crypto2 template);
  List.iter ~f:print_endline (Template.query template);

  print_endline "\n(*************************** \n  Model \n***************************)\n";
  let client_proc = show_cv_process (Iml.remove_assumptions client) in
  let server_proc = show_cv_process (Iml.remove_assumptions server) in
  print_endline "let client = ";
  print_endline client_proc;
  print_endline "let server = ";
  print_endline server_proc;

  List.iter ~f:print_endline (Template.envp template)

let make ~client ~server ?(for_pv = false) template =
  let server = server |> Iml.remove_comments in
  let client = client |> Iml.remove_comments in

  debug_iml client server "initial IML";

  error_if_undefs server;
  error_if_undefs client;

  let server = remove_trailing_computations server in
  let client = remove_trailing_computations client in
  debug_iml client server "IML after removing trailing computations";

  let server = rewrite_xor server in
  let client = rewrite_xor client in
  debug_iml client server "IML after XOR rewriting";

  let server = rewrite_crypto_arithmetic_comparisons server in
  let client = rewrite_crypto_arithmetic_comparisons client in
  debug_iml client server "IML after arithmetic comparison rewriting";

  let server = normal_form server in
  let client = normal_form client in
  debug_iml client server "IML in normal form";
(*
  let client = apply_name_annotations client in
  let server = apply_name_annotations server in
  debug_iml client server "IML after applying all name annotations";*)

  let client = extract_syms client in
  let server = extract_syms server in
  debug_iml client server "IML after the abstraction step";

  let syms = Syms.disjoint_union
    [ Syms.create client; Syms.create server ]
  in

  (************************
     Typechecking
  *************************)

  let template_var_types = Template.var_types template in
  let trusted_types = Template.fun_types template in
  prerr_title "Template Function Types: ";
  Fun_type_ctx.dump trusted_types;
  prerr_title "Template Variable Types: ";
  Type_ctx.dump template_var_types;

  let inferred_var_types = Type_ctx.merge [Typing.infer ~trusted_types client;
                                           Typing.infer ~trusted_types server]
  in
  prerr_title "Inferred Variable Types";
  Type_ctx.dump inferred_var_types;
  let var_types = Type_ctx.merge [template_var_types; inferred_var_types] in

  let client_formatter_types =
    Typing.derive_unknown_types ~trusted_types var_types client
  in
  let server_formatter_types =
    Typing.derive_unknown_types ~trusted_types var_types server
  in

  Typing.check_missing_types
    ~trusted_types ~inferred_types:client_formatter_types client;
  Typing.check_missing_types
    ~trusted_types ~inferred_types:server_formatter_types server;

  prerr_title "Inferred Client Types";
  Fun_type_ctx.dump client_formatter_types;

  prerr_title "Inferred Server Types";
  Fun_type_ctx.dump server_formatter_types;

  let fun_types =
    Fun_type_ctx.compatible_union
      [trusted_types; client_formatter_types; server_formatter_types]
  in

 (*  push_debug "Typing.check";
  let all_types = fun_types in
  let client = Typing.check ~trusted_types ~all_types template_var_types [] client in
  let server = Typing.check ~trusted_types ~all_types template_var_types [] server in
  pop_debug "Typing.check";*)

  debug_iml client server "IML after typechecking";

  with_debug "Typing.check_robust_safety" (fun () ->
    Typing.check_robust_safety (Syms.encoders syms) fun_types);

  (************************
     Sym renaming
  *************************)

  let client = rename_syms syms fun_types client in
  let server = rename_syms syms fun_types server in
  debug_iml client server "IML after sym renaming";

  let syms = Syms.compatible_union
    [ Syms.create client; Syms.create server ]
  in

  (************************
     Type-based warnings
  *************************)

  Syms.check_encoders_are_robustly_injective syms fun_types;

  (************************
     Template assertions
  *************************)

  (*Template.check_assertions template (Syms.binary_defs syms);*)

  let client, server =
    if for_pv then client, server
    else begin
      (*****************************
         Pattern matching
      ******************************)

      push_debug "match_inverse";
      let client = match_inverse client in
      let server = match_inverse server in
      pop_debug "match_inverse";

      push_debug "parsing_safety";
      let client = match_safe_parsers fun_types syms [] client in
      let server = match_safe_parsers fun_types syms [] server in
      pop_debug "parsing_safety";

      let client = merge_patterns ~fun_types client in
      let server = merge_patterns ~fun_types server in
      debug_iml client server "IML after inserting pattern matching";

      (********************************************
         Bring the process into IO-alternating form
      *********************************************)

      let client = merge_in_out client in
      let server = merge_in_out server in

      debug_iml client server "IML after merging inputs and outputs";

      client, server
    end
  in

  (************************
     Auxiliary tests
  *************************)

  push_debug "remove_redundant_auxiliary";
  let server = remove_redundant_tests var_types server in
  let client = remove_redundant_tests var_types client in
  pop_debug "remove_redundant_auxiliary";

  debug_iml client server "IML after removing redundant auxiliary tests";

  (* Recompute syms since some parsers and auxiliary tests might be gone now. *)
  let syms = Syms.compatible_union
    [ Syms.create client; Syms.create server ]
  in

  prerr_title "Done recomputing syms";

  (************************
     Zero facts
  *************************)

  let zero_fun_types = Syms.zero_types syms fun_types in
  let fun_types = Fun_type_ctx.compatible_union [fun_types; zero_fun_types] in

  prerr_title "Done computing zero types";


  let model = {
    client; server;
    template;
    var_types;
    fun_types;
    primed = [];
    syms
  }
  in

  let model = add_primed model in
  prerr_title "Done adding primed functions";
  model
