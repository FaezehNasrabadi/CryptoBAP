(*
	Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
	This file is distributed as part of csec-tools under a BSD license.
	See LICENSE file for copyright notice.
*)

(**
  Outputs all pairs (v, w) such that v is a proxy, w is an opaque function called from v
  and v <> w_proxy.
*)

module List = ListLabels

open Common

let bad_calls callgraph : glob edge list =

  let bad_edge (v, w) =
    v.is_proxy
    && w.opaque
    (* && not w.is_vararg *)
    && v.name <> proxy_name w.name
  in
  List.filter callgraph ~f:bad_edge

let show_glob glob =
  Printf.sprintf "%s(%s)" glob.name (Option.value glob.locdef ~default:"unknown location")

let print_edge (v, w) =
  print_endline (show_glob v ^ " -> " ^ show_glob w)

;;
begin
  readInfo "callgraph.out" "globs.out";
  let callgraph = get_callgraph () in
  List.iter ~f:print_edge (bad_calls callgraph);
end;
