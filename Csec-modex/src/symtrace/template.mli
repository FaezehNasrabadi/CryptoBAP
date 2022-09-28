(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common

open Exp
open Typing

type t

val crypto  : t -> string list
val crypto2 : t -> string list
val query   : t -> string list
val envp    : t -> string list
val model   : t -> string list

val var_types : t -> Type_ctx.t
val fun_types : t -> Fun_type_ctx.t

val read_cv: cv_lib:string -> cv:string -> t

(* Take the types of variables and functions from CV and the rest from PV. *)
val read_pv: cv_lib:string -> cv:string -> pv:string -> t

val is_defined : t -> (bitstring, _) Sym.t -> bool

val is_defined_in_pv : t -> (bitstring, _) Sym.t -> bool

val check_assertions : t -> bitstring Sym_defs.t -> unit
