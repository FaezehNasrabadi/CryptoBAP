(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)


(*
  FIXME: you might just use
  --noPrintLn           Do not output #line directives in the output
  --commPrintLn         Print #line directives in the output, but put
                        them in comments
  --commPrintLnSparse   Print commented #line directives in the output
                        only when the line number changes.
*)

open Cil
open Str

let emptyLoc : location = {line = -1; file = ""; byte = 0}

class fundefsVisitorClass = object
  inherit nopCilVisitor

  method vglob : global -> global list visitAction = function
      
	  (* maybe need to check definitions as well? *)
	  | GVarDecl ({ vname = name; vtype = TFun _ } as f, _) ->
	      if string_match (regexp ".*_proxy$") name 0 then 
	        ChangeTo [GVarDecl (f, emptyLoc); GText ""]
	      else
	        DoChildren
          
    | _ -> DoChildren

end

let fundefs (f: file) : unit =
  visitCilFile (new fundefsVisitorClass) f

let feature : featureDescr =
  { fd_name = "fundefs";
    fd_enabled = ref false;
    fd_description = "remove duplicate function definitions and prevent #line directives to be inserted with them";
    fd_extraopt = [];
    fd_doit = fundefs;
    fd_post_check = true
  }
