(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)


open Cil
open Common

open Str
open ListLabels

(*************************************************)
(** {1 Marking of Globals} *)
(*************************************************)

let config = ref ""
let markingDone = ref false
let configDone = ref false

(**
   The following lists should not be used by any instrumentation code.
   They are only kept accessible for the purpose of config file analysis.
*)
let proxyNames = ref []
let typeNames = ref []
let blacklist = ref []
let boringNames = ref []
let fileNames = ref []


let readConfig : string -> unit = fun name ->
  if not !configDone && name <> "" then
    begin
      configDone := true;

      let curList : string list ref ref = ref proxyNames in

      let f = open_in name in

      let chooseList : string -> unit = fun s ->
	curList := match s with
	| "==== Functions" -> proxyNames
	| "==== Types"     -> typeNames
	| "==== Blacklist" -> blacklist
	| "==== Boring"    -> boringNames
        | "==== Files"     -> fileNames
	| ""               -> !curList
	| _ -> fail ("readConfig: unexpected section in config file :" ^ s)
      in

      let rec read : unit -> unit = fun () ->
	let s = trim (input_line f) in
	if s = ""      then read () else
	  if s.[0] = '/' then read () else
	    if s.[0] = '=' then begin chooseList s; read () end
	    else
	      begin
	        !curList := s :: !(!curList);
	        read ()
	      end
      in

      try read () with End_of_file -> ()
    end

(* take a look if the API already provides something *)
let typeName : typ -> string = function
  | TNamed (v, _) -> v.tname
  | TComp (v, _) -> v.cname
  | TEnum (v, _) -> v.ename
  | _ -> ""

let rec stripPtr : typ -> typ = function
  | TPtr (p, _) -> stripPtr p
  | a -> a

class markVisitorClass = object
  inherit nopCilVisitor

  method vvrbl : varinfo -> varinfo visitAction = function
  | v when v.vglob ->
    begin
      match v.vtype with
      | TFun (ret, args, _, _) ->
        (* print_endline ("considering function " ^ v.vname); *)

        let funTypes = map stripPtr (ret :: (map snd3 (argsToList args))) in

        if (mem v.vname !proxyNames)
          || ((exists (mem ~set:(!typeNames)) (map typeName funTypes))
              && not (isProxy v)
              && not (mem v.vname ~set:!blacklist))
        then markNeedsProxy v;

      | _ -> ()
    end;

    if needsProxy v || mem v.vname !boringNames then
      markOpaque v;

    addRef v;

    addChild !currentGlobal v;

    SkipChildren

  | _ -> SkipChildren

  method vinst(i) =

    (* ignore (Pretty.printf "marking instruction %a\n" (printInstr plainCilPrinter) i); *)
    match i with
    | Call (_, Lval (Var f, _), [_; CastE (_, Const (CStr s))], _) when f.vname = "dlsym" ->

      let v = makeVarinfo true s (TFun (TVoid [], None, false, [])) in
      addRef v;
      addChild !currentGlobal v;

      SkipChildren

    | _ -> DoChildren

  method vglob : global -> global list visitAction = function
  | GVar (v, _, loc) ->

    addDef v loc;
    if mem v.vname !boringNames then
      markOpaque v;

    DoChildren

  | GFun (f, loc) ->
    (* addChild g f.svar; (* Add a self-reference. Why are we doing this? *) *)
    addDef f.svar loc;

    if needsProxy f.svar || mem f.svar.vname !boringNames then
      markOpaque f.svar;

    if isProxy f.svar then markIsProxy f.svar;

    DoChildren

  | _ -> DoChildren

end

(**
   Assumes that setSrcPath has been called.
*)
let shouldSkip: file -> bool = fun f ->
  readConfig !config;
  not (List.mem !srcPath !fileNames)

let markGlobals : file -> unit = fun f ->
  if not !markingDone then
    begin
      markingDone := true;
      readConfig !config;
      visitCilFile (new markVisitorClass) f
    end

