(*
	Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
	This file is distributed as part of csec-tools under a BSD license.
	See LICENSE file for copyright notice.
*)

(**
  Outputs all pairs (v, w) such that v is opaque, w is proxied and
  w is reachable from v.

  Quadratic implementation.
*)

open List

open Common

let isOpaque (_, glob) = glob.opaque && (not glob.needs_proxy)

let isProxy glob = glob.needs_proxy

let printEdge (v, w) =
  print_endline (v.name ^ " " ^ w.name)

let reachable v g : glob list =

  (* Make this a set if you don't want to be quadratic *)
  let visited : glob list ref = ref [] in

  let children : glob -> glob list = fun v ->
    map snd (filter (fun (src, _) -> src = v) g)
  in

  let rec visit : glob -> unit = fun v ->
    if not (mem v !visited)
    then begin
      visited := v :: !visited;
      iter visit (children v);
    end
  in
  visit v; !visited

let badPairs callgraph : glob edge list =

  let badSuccessors : glob -> glob edge list = fun v ->
    map (fun w -> (v, w)) (filter isProxy (reachable v callgraph))
  in

  let opaque_nodes = map snd (filter isOpaque (StrMap.bindings !globs)) in
  concat (map badSuccessors opaque_nodes)

;;
begin
  readInfo "callgraph.out" "globs.out";
  let callgraph = get_callgraph () in
  iter printEdge (badPairs callgraph);
  (* print_endline "digraph {";
  (* print_endline "size=190"; *)
  print_endline "node [shape=none]"; *)
  (* iter print_edge (filter (function (v, w) -> mem v main_cc) graph); *)
  (* print_endline "}"; *)
end;
