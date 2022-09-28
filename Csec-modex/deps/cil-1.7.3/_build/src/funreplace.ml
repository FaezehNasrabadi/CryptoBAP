(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)


open Pretty
open Cil
open List

open Common

let output = ref ""

(*************************************************)
(** {1 Helpers} *)
(*************************************************)

(* This doesn't work: *)
(* let error : ('a, unit, Pretty.doc, unit) format4 -> unit = function e -> E.s (E.error e) *)

let proxy : varinfo -> varinfo = fun v ->
  let v' = { v with vname = v.vname ^ "_proxy" } in
  if v'.vstorage =  Static then
     v'.vstorage <- Extern;
  ignore (E.log "%a\n" (printGlobal defaultCilPrinter) (GVarDecl (v', locUnknown)));
  markProxied v;
  v'

(*************************************************)
(** {1 Visitors} *)
(*************************************************)


class funReplaceVisitorClass = object
  inherit nopCilVisitor

  method vvrbl : varinfo -> varinfo visitAction = function
	  | v when needsProxy v -> ChangeTo (proxy v)
			(* ignore (Errormsg.log "%a\n" d_plainlval (Var v, NoOffset)); *)

		| _ -> SkipChildren
      

  method vglob : global -> global list visitAction = function

    | GVarDecl (f, _) as g when needsProxy f ->
      (* let f' = { f with vname = f.vname ^ "_proxy" } in *)
      ChangeTo [g; GVarDecl (proxy f, locUnknown)] 
        
      (* do nothing about opaque declarations, they are handled in crestify *)

    | GFun (f, _) as g ->
      (* turn off static storage for functions to be proxied *)
      if f.svar.vstorage = Static then
        f.svar.vstorage <- NoStorage;
        
      (* no replacing in proxy functions themselves *)
      if isProxy f.svar then
        SkipChildren
      (* 
        Make sure things like tls1_prof_proxy get defined.
        FIXME: does it lead to multiple definitions?
      *)
      else if needsProxy f.svar then
        ChangeTo [GVarDecl (proxy f.svar, locUnknown); g] 
      else
        DoChildren

    | _ -> DoChildren

end

let funReplace (f: file) : unit =
  (* iterGlobals f (fun g -> ignore (E.log "%a\n" (printGlobal plainCilPrinter) g)); *)
  setSrcPath f;
  if not (Mark.shouldSkip f) then
  begin
	  Mark.markGlobals f;
	  visitCilFile (new funReplaceVisitorClass) f;
	  writeInfo f
  end

let feature : featureDescr =
  { fd_name = "funreplace";
    fd_enabled = ref false;
    fd_description = "replace some function calls with calls to proxy functions";
    fd_extraopt = [
      ("--csec-config", Arg.String (fun s -> Mark.config := s),
        " The csec instrumentation configuration file.");
      ("--funreplaceoutput", 
          Arg.String (fun s -> E.logChannel := open_append s), (* see open_append in crest *)
        " The file to write proxy function definitions to.");
      ("--root", 
          Arg.String setRootPath, 
        " The root folder of the compilation.")
      ];
    fd_doit = funReplace;
    fd_post_check = true
  }

