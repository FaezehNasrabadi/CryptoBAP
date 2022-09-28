(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common
open Typing
open Transform
open Sym
open Exp

module CV = Cryptoverif

open CV.Types
open CV.Syntax
open CV.Stringmap

module Assertion = struct
  type t =
  | Def of (bfun * string)
end

type t =
  { crypto: string list
  (** Printed after the automatically generated facts *)
  ; crypto2: string list
  ; query : string list
  ; envp: string list
  (**
     This part is dropped.
  *)
  ; model: string list
  ; var_types : Type_ctx.t
  ; fun_types : Fun_type_ctx.t
  ; assertions : Assertion.t list
}

let crypto t = t.crypto
let crypto2 t = t.crypto2
let query t = t.query
let envp t = t.envp
let model t = t.model
let var_types t = t.var_types
let fun_types t = t.fun_types

(* CR: for some weird reason bitstringbot becomes bitstring, look at injbot. *)
let collect_types env q =

  let types = ref [] in
  let fun_types = ref Fun_type_ctx.empty in

  let add_var_type (v : Var.t) (t : typet) =
    match Option.try_with (fun () ->
      Type.of_string_bitstring t.tname)
    with
    | None ->
      info ("add_var_type: ignoring variabe %s"
            ^^ " because it has a non-bitstring type.") (Var.to_string v)
    | Some t ->
      types := (v, t) :: !types
  in

  let add_fun_type (f : string) ((ts, t) : typet list * typet) =
    match Option.try_with (fun () ->
      List.map ts ~f:(fun t -> Type.of_string_bitstring t.tname))
    with
    | None ->
      info ("add_fun_type: ignoring function %s"
            ^^ " because it contains a non-bitstring argument type.") f
    | Some ts ->
      let Type.Any t = Type.of_string t.tname in
      let kind = Type.kind t in
      let sym = Sym.Fun (f, (List.length ts, kind)) in
      fun_types := Fun_type_ctx.add sym (ts, t) !fun_types
  in

  let collect_env_types env =
    let do_entry : string -> env_entry -> unit = fun _ -> function
      | EFunc f ->
        (* Constants are encoded as functions with no arguments, but we want to treat
           them as variables in our typechecking. This currently forces us to ignore
           variables false and true, which hopefully will not become a problem. It
           should be easy to treat constants as functions though if that ever becomes
           necessary.  *)
        begin match f.f_type with
        | ([], t) -> add_var_type (Var.of_string f.f_name) t
        | t       -> add_fun_type f.f_name t
        end
      | EEvent f ->
        (* for some reason it adds an extra bitstring parameter in front of the ones I
           define *)
        let (atypes, rtype) = f.f_type in
        add_fun_type f.f_name (List.tl atypes, rtype)
      | EVar b ->
        add_var_type (Var.of_string b.sname) b.btype
      | _ -> ()
    in
    StringMap.iter do_entry env
  in

  let rec collect_input_process_types : inputprocess -> unit = fun q ->
    let rec collect_pattern : pattern -> unit = function
      | PatVar b ->
        add_var_type (Var.of_string b.sname) b.btype
      | PatTuple (_, pats) ->
        List.iter ~f:collect_pattern pats
      | PatEqual _ -> ()
    in
    match q.i_desc with
    | Nil -> ()
    | Par (q, q') ->
      collect_input_process_types q;
      collect_input_process_types q'
    | Repl (_, q) ->
      collect_input_process_types q
    | Input (_, pat, q) ->
      collect_pattern pat;
      collect_output_process_types q

  and collect_output_process_types : process -> unit = fun p ->
    match p.p_desc with
    | Yield -> ()
    | Restr (b, p) ->
      add_var_type (Var.of_string b.sname) b.btype;
      collect_output_process_types p
    | Test (_, p, p') ->
      collect_output_process_types p;
      collect_output_process_types p'
    | Find _ -> fail "collect_types: unexpected find construct"
    | Output (_, _, q) ->
      collect_input_process_types q
    | Let (pat, _, p, p') ->
      collect_pattern_types pat;
      collect_output_process_types p;
      collect_output_process_types p'
    | EventP (_, p) -> collect_output_process_types p

  and collect_pattern_types: pattern -> unit = function
    | PatVar b ->
      add_var_type (Var.of_string b.sname) b.btype
    | PatTuple (_, pats) ->
      List.iter ~f:collect_pattern_types pats
    | PatEqual _ -> ()
  in

  collect_env_types env;
  collect_input_process_types q;
  Type_ctx.of_list !types, !fun_types


let read ~cv_lib ~cv ?pv () =

  let crypto = ref [] in
  let crypto2 = ref [] in
  let query = ref [] in
  let envp = ref [] in
  let model = ref [] in

  let rec split_template: string list ref -> string list -> unit = fun dest -> function
    | l1 :: l2 :: ls' when String.trim l2 = "<Environment>" ->
      split_template envp (((l1 ^ "\n" ^ l2) :: ls'))
    | l1 :: l2 :: ls' when String.trim l2 = "<Query>" ->
      split_template query (((l1 ^ "\n" ^ l2) :: ls'))
    | l1 :: l2 :: ls' when String.trim l2 = "<Model>" ->
      split_template model (((l1 ^ "\n" ^ l2) :: ls'))
    | _ :: l2 :: _ when String.trim l2 = "<Type hints>" ->
      (* Using assertions (see check_assertions) is the new way of doing this. *)
      failwith "<Type hints> are deprecated"
    | l1 :: l2 :: ls' when String.trim l2 = "<Crypto2>" ->
      split_template crypto2 (((l1 ^ "\n" ^ l2) :: ls'))
    | l :: ls'  -> dest := !dest @ [l]; split_template dest ls'
    | [] -> ()
  in
  let rec extract_assertions = function
    | "(* ASSERT_DEFINITION" :: l1 :: l2 :: "*)" :: ls ->
      let l1 = String.trim l1 in
      let l2 = String.trim l2 in
      let sym = Sym.of_string_bitstring l1 in
      Assertion.Def (sym, l2) :: extract_assertions ls
    | _ :: ls -> extract_assertions ls
    | [] -> []
  in
  let cv_lines =
    Common.read_file (open_in cv)
  in
  let lines =
    match pv with
    | None -> cv_lines
    | Some pv ->
      Common.read_file (open_in pv)
  in
  split_template crypto lines;
  Cryptoverif.Settings.lib_name := cv_lib;
  let (_, _, _, _, _, _, q) = read_file cv in
  let var_types, fun_types = collect_types !CV.Stringmap.env q in
  let assertions = extract_assertions (lines @ cv_lines) in
  { crypto = !crypto; crypto2 = !crypto2; query = !query;
    envp = !envp; model = !model; var_types; fun_types; assertions }

let read_cv ~cv_lib ~cv =
  read ~cv_lib ~cv ()

let read_pv ~cv_lib ~cv ~pv =
  read ~cv_lib ~cv ~pv ()

let is_defined_in_pv t sym =
  let regex =
    Printf.sprintf "data %s" (Sym.to_string sym) |> Str.regexp_string
  in
  List.exists (t.crypto @ t.crypto2) ~f:(fun line ->
    Str.string_match regex line 0)

let is_defined t sym =
  if Fun_type_ctx.mem sym t.fun_types then true
  else match sym with
  | Sym.Fun (f, _) ->
    Type_ctx.mem (Var.of_string f) t.var_types
  | _ -> false

let check_assertions t defs =
  List.iter t.assertions ~f:(function Assertion.Def (sym, def) ->
    match Sym_defs.maybe_find sym defs with
    | None ->
      fail "check_assertions: %s not found in model" (Sym.to_string sym)
    | Some def' ->
      if E.to_string def' <> def
      then fail "check_assertions: %s asserted to be %s but is %s"
        (Sym.to_string sym) def (E.to_string def'))
