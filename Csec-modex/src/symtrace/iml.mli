(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common

module Pat : sig
  type t =
  | VPat of Var.t
  | FPat : (bitstring, bitstring) Sym.t * t list -> t
  | Underscore

  val dump : t -> string

  val vpat : string -> t
end

module Stmt : sig
  open Exp

  type t =
  | Let of Pat.t * bterm
  (**
     [Test e; P = if e then P else 0]
  *)
  | Test of fact
  (* Special form. *)
  | Eq_test of bterm * bterm
  | Assume of fact
  | In of var list
  | Out of bterm list
  | New of var * bitstring Type.t
  | Event of string * bterm list
  | Yield
  | Comment of string

  type stmt = t

  val to_string : t -> string

  val map_children : 'a Exp.map -> t -> 'a list
  val iter_children : unit Exp.map -> t -> unit
  val exists_child : bool Exp.map -> t -> bool

  val descend : Exp.descend -> t -> t

  val subst : var list -> Exp.bterm list -> t -> t

  val vars : t -> var list

  val remove_annotations : t -> t

  val make_test : fact -> t

  val is_auxiliary_test : t -> bool

  val facts : t -> fact list
end

open Exp
open Stmt

type t = stmt list
type iml = t

val map : Exp.descend -> t -> t
val iter : unit Exp.map -> t -> unit

val refcount : var -> t -> int

val vars : t -> var list

val free_vars : t -> var list

val to_string : t -> string

(**
   Fails on capture.
*)
val subst   : var list -> bterm list -> t -> t
val subst_v : var list -> var   list -> t -> t

val filter_with_comments : f:(stmt -> bool) -> t -> t
val remove_comments : t -> t

val remove_annotations : t -> t
val remove_assumptions : t -> t

val parsers : t -> bitstring Sym_defs.t
val encoders : t -> bitstring Sym_defs.t
val arith : t -> bitstring Sym_defs.t
val auxiliary : t -> bool Sym_defs.t
