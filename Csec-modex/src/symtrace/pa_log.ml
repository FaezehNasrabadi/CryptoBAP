(* Copyright (c) 2012 Lukasz Kaiser (http://sourceforge.net/u/lukaszkaiser/profile/)
 * Copyright (c) 2014 Mihhail Aizatulin (avatar@hot.ee)
 *
 * See LICENSE file for copyright notice.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See LICENSE
 * for details.
 *)

(* Uses functions defined in the Debug section in common.ml *)

open Camlp4
module Id : Sig.Id =
struct
  let name = "pa_log"
  let version = "0.1"
end
module Make (Syntax : Sig.Camlp4Syntax) =
struct
  open Sig
  include Syntax
    EXTEND Gram
    expr: LEVEL "apply"
    [ [
      (* Doesn't look like this can be done with quotations: those cannot affect their
         arguments. *)
      "DEBUG"; form = NEXT; xs = LIST0 NEXT ->
      let sprint_apps = List.fold_left
        (fun appl exp -> <:expr< $appl$ $exp$ >>)
        <:expr< Printf.sprintf $form$ >>
        xs
      in
      <:expr<
        if debug_enabled ()
        then
          let s = $sprint_apps$ in
          prerr_endline (decorate_debug s)
        else ()
          >>
    ] ];
  END
end
module M = Register.OCamlSyntaxExtension(Id)(Make)
