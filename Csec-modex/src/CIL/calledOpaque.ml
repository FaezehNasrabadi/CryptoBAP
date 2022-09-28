(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)


(**
   Lists all boring functions that have been called in the last execution.
*)

open List

open Common

;;
begin
  Mark.readConfig Sys.argv.(1);
  let calledFunctions = readFile Sys.argv.(2) in
  iter print_endline (nub (intersect !Mark.boringNames calledFunctions))
end;
