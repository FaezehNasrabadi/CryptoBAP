(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)

open Exp

type answer = Yes | No | Maybe

(**
    [true] means true, [false] means we don't know.
*)
type pbool = bool

(*************************************************)
(** {1 Checking facts} *)
(*************************************************)

val assume : fact list -> unit

val is_true : fact -> pbool

val equal_bitstring : ?facts:fact list -> bterm -> bterm -> pbool

val not_equal_bitstring : bterm -> bterm -> pbool

(** Comparison is done on numeric values. *)
val equal_int : ?facts:fact list -> iterm -> iterm -> pbool

val greater_equal : iterm -> iterm -> pbool

val greater_equal_len : iterm -> iterm -> pbool

val greater_equal_len_answer : iterm -> iterm -> answer

val implies : fact list -> fact list -> pbool

(*************************************************)
(** {1 Evaluation} *)
(*************************************************)

(**
  Evaluation of an integer expression.
  Will fail if a value is not unique or if we cannot prove that it is defined.
*)
val eval : iterm -> int option

(*************************************************)
(** {1 Simplification} *)
(*************************************************)

(* CR get rid of stepwise simplification, that's premature optimization. *)
(** Only simplifies the topmost constructor. *)
val simplify : 'a exp -> 'a exp

(** If an expression is opaque, then the simplifier does not understand its structure.  In
    particular, the solver cannot tell that simplifications inside the expression preserve
    equality. *)
val is_opaque : _ exp -> bool

(*************************************************)
(** {1 Warnings} *)
(*************************************************)

val warn_on_failed_conditions : bool -> unit

(*************************************************)
(** {1 Test} *)
(*************************************************)

val test : unit -> unit

(*************************************************)
(** {1 Tracing} *)
(*************************************************)

type trace_step =
  { trace : 'a 'b. root:'a exp -> left:'b exp -> right:'b exp -> conds:fact list -> unit }

val enable_tracing : trace_step -> unit
val disable_tracing : unit -> unit

(*************************************************)
(** {1 Reset} *)
(*************************************************)

val reset_facts : unit -> unit

val reset_cache : unit -> unit
