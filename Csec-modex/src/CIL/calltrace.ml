(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)


(** Finds a leaf of a graph, in the connected component of the "main" node. Prints out the
    path.

    First tries to find a path that doesn't go through proxied, opaque, or interface
    functions.  If that fails, tries again with all functions.

    Quadratic implementation. *)

open List

open Common

let notHandled glob =
  (*
     The only case where is_proxy becomes important is BN_num_bytes, which
     is preprocessed to become the proxy call, and so appears in normal code.
  *)
  not (glob.is_proxy || glob.proxied || glob.opaque || isInterfaceFun glob.name)

(**
   Return a path from [v] to [w] or an empty list if there is no path.
*)
let findLeaf allowHandled v w g =

  (* Make this a set if you don't want to be quadratic *)
  let visited : glob list ref = ref [] in
  let path    : glob list ref = ref [] in

  let children : glob -> glob list = fun v ->
    map snd (filter (fun (src, dest) -> src = v && (allowHandled || notHandled dest)) g)
  in

  let rec visit : glob -> unit = fun v ->
    if v = w then raise Exit;
    if not (mem v !visited) then
      begin
        visited := v :: !visited;
        let old_path = !path in
        path := v :: !path;
        iter visit (children v);
        path := old_path;
      end
  in
  try visit v; [] with Exit -> !path

let print_glob glob =
  Printf.printf "%s(%s)\n" glob.name (Option.value glob.locdef ~default:"unknown location")

;;
begin
  readInfo "callgraph.out" "globs.out";
  let main = StrMap.find "main" !globs in
  let dest = StrMap.find Sys.argv.(1) !globs in
  let callgraph = get_callgraph () in
  let path = (rev (findLeaf false main dest callgraph)) in
  if path <> []
  then iter print_glob path
  else begin
    print_endline "No path without proxied or opaque functions found, trying with all functions:";
    iter print_glob (rev (findLeaf true main dest callgraph))
  end
end;
