
(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)


(**
  Lists all functions declared boring that are not reachable from "main" through functions
  that are neither opaque nor proxied.

  Quadratic implementation.
*)

open List

open Common

let isBad glob =
  not glob.crestified

let isHandled glob =
  glob.proxied  || glob.opaque || (isInterfaceFun glob.name)

let reachable v g =

  (* Make this a set if you don't want to be quadratic *)
  let visited : glob list ref = ref [] in

  let children : glob -> glob list = fun v ->
    map snd (filter (fun (src, _) -> src = v) g)
  in

  let rec visit v =
    if not (mem v !visited)
    then begin
      visited := v :: !visited;
      if not (isHandled v)
      then  iter visit (children v)
    end
  in
  visit v; !visited

;;
begin
  readInfo "callgraph.out" "globs.out";
  Mark.readConfig Sys.argv.(1);
  let main = StrMap.find "main" !globs in
  let callgraph = get_callgraph () in
  let reachable =
    reachable main callgraph
    |> List.map (fun glob -> glob.name)
  in
  iter print_endline (diff !Mark.boringNames reachable)
end;
