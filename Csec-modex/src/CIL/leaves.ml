(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)


(**
  Compute leaves of a graph, in the connected component of the "main" node.

  Output those that are not proxied (or for which no proxy function exists), opaque or crestified

  Quadratic implementation.
*)

open List

open Common

let isBad : glob -> bool = fun glob ->
  not glob.crestified

let isHandled : glob -> bool = fun glob ->

  (* This is to remind myself to crestify the proxies properly, which is easy to forget with my opt-in scheme *)
  if glob.proxied
  then begin
    let proxy_crestified =
      try
        let proxy_glob = StrMap.find (proxy_name glob.name) !globs in
        proxy_glob.crestified
      with Not_found -> false in
    if not proxy_crestified then
      begin
        print_endline ("Error: function "
                       ^ glob.name
                       ^ " is proxied, but the proxy function is not instrumented."
                       ^ " Add the proxy source file to config.");
        exit 1;
      end;
  end;

  (* See comment in calltrace regarding is_proxy *)
  glob.is_proxy || glob.opaque || (isInterfaceFun glob.name)

let leaves : glob -> glob graph -> glob list = fun v g ->

  (* Make this a set if you don't want to be quadratic *)
  let visited : glob list ref = ref [] in
  let leaves  : glob list ref = ref [] in

  let children : glob -> glob list = fun v ->
    map snd (filter (fun (src, _) -> src = v) g)
  in

  let rec visit : glob -> unit = fun v ->
    if not (mem v !visited) && (not (isHandled v))
    then begin
      visited := v :: !visited;
      match children v with
      | [] -> leaves := v :: !leaves
      | us -> iter visit us
    end
  in
  visit v; !leaves

let print_glob glob =
  Printf.printf "%s(%s)\n" glob.name
    (Option.value glob.locdef ~default:"unknown location")

;;
begin
  readInfo "callgraph.out" "globs.out";

  if not (StrMap.mem "main" !globs)
  then begin
    print_endline "Error: main() is not instrumented. Please check your configuration file.";
    exit 1;
  end;

  let main = StrMap.find "main" !globs in
  iter print_glob (filter isBad (leaves main (get_callgraph ())))
end;
