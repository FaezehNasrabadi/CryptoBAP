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
open Printf

let () =
  let ctx = mk_context () in
  let e1 = mk_fresh_bool_var ctx in
  let e2 = mk_fresh_bool_var ctx in
  let eq1 = mk_eq ctx e1 e2 in
  assert_simple ctx eq1; (* assert is a reserved keyword in ocaml *)
  dump_context ctx;
  begin match check ctx with
  | True ->
    let m = get_model ctx in
    let f b = match b with True -> "true" | False -> "false" | Undef -> "undef" in
    printf "e1 = %s\n" (f (get_value m (get_var_decl e1)));
    printf "e2 = %s\n" (f (get_value m (get_var_decl e2)));
  | False ->
    printf "unsatisfiable\n";
  | Undef ->
    printf "unknown\n";
  end;
  del_context ctx
