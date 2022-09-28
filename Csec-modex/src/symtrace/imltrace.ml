(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)

open Common

open Symex

let setup_debug () =
  set_debug (fun labels ->
    let at_most_n_under n l =
      match List.find_index ((=) l) labels with
      | None -> false
      | Some i -> i <= n
    in
    at_most_n_under 1 "execute"
    || at_most_n_under (-1) "In"
    || at_most_n_under (-1) "is_true"
    || at_most_n_under (-1) "deep_simplify"
    (* || at_most_n_under 0 "rewrite" *)
    (* || under "rewrite" *)
    || false)

let main () =
  setup_debug ();

  let client = execute_file (open_in Sys.argv.(1)) in
  let server = execute_file (open_in Sys.argv.(2)) in

  (*
    Iml.Exp.clip_enabled := false;
  *)

  (*
    if debug_enabled () then prerr_endline "";
    if debug_enabled () then List.iter (fun s -> prerr_endline (Stmt.dump s)) client;
    if debug_enabled () then List.iter (fun s -> prerr_endline (Stmt.dump s)) server;
  *)
  if debug_enabled () then prerr_endline "";
  if debug_enabled () then prerr_endline (Iml.to_string client);
  if debug_enabled () then prerr_endline (Iml.to_string server);
  if debug_enabled () then prerr_endline "";

  (* With comments the blessed tests are unstable across machines because of
     full paths to source files. *)
  let client = Iml.remove_comments client in
  let server = Iml.remove_comments server in

  print_endline "let A = ";
  print_endline (Iml.to_string client);
  print_endline "let B = ";
  print_endline (Iml.to_string server);

  raw_out (open_out_bin Sys.argv.(3)) client server;

  dump_called_funs ();

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

Printexc.print main ()
