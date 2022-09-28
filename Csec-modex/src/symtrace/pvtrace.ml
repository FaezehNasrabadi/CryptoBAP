(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common

(*************************************************)
(** {1 Debug} *)
(*************************************************)

let setup_debug () =
  set_debug (fun labels ->
    let at_most_n_under n l =
      match List.find_index ((=) l) labels with
      | None -> false
      | Some i -> i <= n
    in
    at_most_n_under (-1) "Typing.check"
    || at_most_n_under (-1) "Custom_map.find"
    || at_most_n_under (-1) "Typing.check_robust_safety"
    || at_most_n_under (-1) "parsing_eqs"
    || at_most_n_under (-1) "auxiliary_facts"
    || at_most_n_under (-1) "parsing_safety"
    || at_most_n_under (-1) "inrange"
    || at_most_n_under (-1) "remove_redundant_auxiliary"
    || at_most_n_under (-1) "parsing_eqs"
    || at_most_n_under (-1) "encoder_facts"
    || at_most_n_under (-1) "match_inverse"
    || at_most_n_under (-1) "strengthen"
    || at_most_n_under (-1) "erase_conditionals"

    (* || at_most_n_under (1) "Custom_map.find" *)

(*
    || List.length labels <= 1
*)
  )
;;

let main () =
  let (client) = Symex.exe_file (open_in Sys.argv.(1)) in
  let (server) = Symex.exe_file (open_in Sys.argv.(2)) in
  let template =
    Template.read_pv ~cv_lib:Sys.argv.(3) ~cv:Sys.argv.(4) ~pv:Sys.argv.(5)
  in
  let model =
    Cv_model.make ~client ~server template ~for_pv:true
    |> Pv_model.of_cv_model
  in
  Pv_model.print model

;;
(*
  Trying to get both the full text of the exception and
  the backtrace. Waiting for a fix for
  http://caml.inria.fr/mantis/view.php?id=5040
*)
Printexc.register_printer (function
  | Failure s -> Some s
  | _ -> None);
;;

setup_debug ()

;;

Printexc.print main ()

