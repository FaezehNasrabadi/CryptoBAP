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

open Yices;;

print_endline (version ());;

let ex1 =
  let ctx = mk_context () in
  let a = mk_bool_var ctx "a"
  and b = mk_bool_var ctx "b"
  and c = mk_bool_var ctx "c" in
  let aandb = mk_and ctx [| a ; b |]
  and cimpliesnotb = mk_or ctx [| mk_not ctx c ; mk_not ctx b |] in
  let _ = assert_retractable ctx aandb
  and _ = assert_retractable ctx cimpliesnotb
  in begin
  match check ctx with
  | True ->
    print_endline "true";
    let m = get_model ctx
    and print_value m v =
      match get_value m v with
      | True -> print_endline ((get_var_decl_name v)^": true")
      | False -> print_endline ((get_var_decl_name v)^": false")
      | Undef -> print_endline ((get_var_decl_name v)^": undef")
    in iter_bool_var_decl (print_value m) ctx
  | False -> print_endline "false"
  | Undef -> print_endline "undef"
  end; del_context ctx;;

let ex2 =
  let ctx = mk_context () in
  let it = mk_type ctx int_type_name in
  let dv = mk_var_decl ctx "v" it in
    assert_simple ctx (mk_eq ctx (mk_var_from_decl ctx dv) (mk_num ctx 1));
    match check ctx with
    | True -> let m = get_model ctx in
      print_endline (get_arith_value_as_string m dv)
    |_ -> failwith "bad verdict"

