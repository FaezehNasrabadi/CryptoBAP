(*
Copyright (c) 2009-2013, Mickaël Delahaye, http://micdel.fr

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
*)

open Yices
open Future

let res r = match r with
| True -> "true"
| False -> "false"
| Undef -> "undef"

let var ctx name typ = mk_var_from_decl ctx (mk_var_decl ctx name typ)

let () =
  print_endline "**get_lite_context**";
  let ctx = mk_context () in
  let light = get_lite_context ctx in
  let c1 = "(define x::int)" and c2 = "(assert (and (< x 3)(> x 1)))" in
  print_endline "Commands:";
  print_endline c1;
  print_endline c2;
  Yicesl.read light c1;
  Yicesl.read light c2;
  print_newline ();
  print_endline "Result:";
  let r = check ctx in
  print_endline (res r);
  if r = True then
    display_model (get_model ctx);
(* Don't do that! Yicesl.del_context light;*)
  del_context ctx

let () =
  print_endline "**mk_function_update**";
  let ctx = mk_context () in
  let ityp = mk_type ctx "int" in
  let ftyp = mk_function_type ctx [|ityp|] ityp in

  let var = var ctx in
  let f1 = var "f1" ftyp and f2 = var "f2" ftyp
  and i1 = var "i1" ityp and i2 = var "i2" ityp
  and v1 = var "v1" ityp and v2 = var "v2" ityp
  and v3 = var "v3" ityp in

  let a = mk_diseq ctx v1 v2 in
  let b = mk_diseq ctx i1 i2 in
  let c = mk_eq ctx
    (mk_function_update ctx f1 [|i1|] v1)
    (mk_function_update ctx (mk_function_update ctx f2 [|i1|] v2) [|i2|] v3)
  in

  print_endline "Assertions:";
  pp_expr a; print_newline ();
  pp_expr b; print_newline ();
  pp_expr c; print_newline ();
  print_newline ();

  assert_simple ctx a;
  let r = assert_retractable ctx b in
  assert_simple ctx c;
(*  dump_context ctx;*)
(*  print_newline ();*)
  print_endline "Result: ";
  print_endline (res (check ctx));
  print_newline ();

  print_string "Retract "; flush stdout;
  pp_expr b; print_newline ();
  print_newline ();
  retract ctx r;
(*  dump_context ctx;*)
(*  print_newline ();*)

  print_endline "Result: ";
  let r = check ctx in
  print_endline (res r);
  if r = True then
    display_model (get_model ctx);

  del_context ctx

let () =
  print_endline "**mk_tuple_literal**";
  let ctx = mk_context () in
  let ityp = mk_type ctx "int" in
  let v1 = var ctx "v1" ityp in
  let v2 = var ctx "v2" ityp in
  let v3 = var ctx "v3" ityp in
  let v4 = var ctx "v4" ityp in
  let t1 = mk_tuple_literal ctx [| v1 ; v2  |] in
  let t2 = mk_tuple_literal ctx [| v3 ; v4  |] in
  let eq = mk_eq ctx t1 t2 in

  print_endline "Assertions:";
  pp_expr eq; print_newline ();
  print_newline ();
  assert_simple ctx eq;

  print_endline "Result: ";
  let r = check ctx in
  print_endline (res r);
  if r = True then
    display_model (get_model ctx);

  del_context ctx

