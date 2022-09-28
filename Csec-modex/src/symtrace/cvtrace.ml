(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common

module Stats = Stats_local

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
    begin
      at_most_n_under (-1) "Typing.check"
      || at_most_n_under (1) "Syms.auxiliary_facts"
      || at_most_n_under (1) "full_simplify"
      || at_most_n_under (-1) "implies"
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
      || at_most_n_under (-1) "Custom_map.find"
    end
  )
;;


(*************************************************)
(** {1 Main} *)
(*************************************************)

let main () =
  let (client) = Symex.exe_file (open_in Sys.argv.(1)) in
  let (server) = Symex.exe_file (open_in Sys.argv.(2)) in
  let template = Template.read_cv ~cv_lib:Sys.argv.(3) ~cv:Sys.argv.(4) in
  let model = Cv_model.make ~client ~server template in
  Cv_model.print model;
  Stats.print ()

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

