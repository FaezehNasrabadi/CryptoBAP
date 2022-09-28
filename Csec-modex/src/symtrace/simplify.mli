(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

val simplify : 'a Exp.t -> 'a Exp.t

val full_simplify : 'a Exp.t -> 'a Exp.t

(*************************************************)
(** {1 Testing.} *)
(*************************************************)

val test : unit -> unit
