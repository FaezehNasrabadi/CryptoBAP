(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common

open Exp
open Iml

module Type_ctx : sig
  type t

  val empty : t
  val singleton : Var.t -> bitstring Type.t -> t
  val add : Var.t -> bitstring Type.t -> t -> t
  val maybe_find : Var.t -> t -> bitstring Type.t option
  val find : Var.t -> t -> bitstring Type.t
  val find_with_default : Var.t -> t -> bitstring Type.t
  val mem : Var.t -> t -> bool
  val merge : t list -> t
  val of_list : (Var.t * bitstring Type.t) list -> t
  val to_list : t -> (Var.t * bitstring Type.t) list
  val dump : t -> unit
  val keys : t -> var list
  (* CR: don't use this since var_types are never explicitly checked. *)
  val facts : t -> fact list
end

module Fun_type_ctx : sig
  type t

  module Key : sig
    type 'a t = (bitstring, 'a) Sym.t
  end

  module Value : sig
    type 'a t = (bitstring, 'a) Fun_type.t
  end

  type 'b consumer = { f : 'a. 'a Key.t -> 'a Value.t -> 'b }

  val empty : t
  val add : 'a Key.t -> 'a Value.t -> t -> t
  val add_primed :'a Key.t -> t -> t
  val find : 'a Key.t -> t -> 'a Value.t
  val maybe_find : 'a Key.t -> t -> 'a Value.t option
  val mem : 'a Key.t -> t -> bool
  val of_list : ('a Key.t * 'a Value.t) list -> t
  val map_bindings : t -> 'b consumer -> 'b list
  val compatible_union : t list -> t
  val disjoint_union : t list -> t

  val dump : t -> unit
end

(* CR: trusting var types returned by these functions is questionable since they
   are not verified by typechecking. *)
val infer_exp : Fun_type_ctx.t -> 'a Type.t option -> 'a exp -> Type_ctx.t
val infer : trusted_types : Fun_type_ctx.t -> iml -> Type_ctx.t

val derive_unknown_types
  :  trusted_types : Fun_type_ctx.t
  -> Type_ctx.t
  -> iml
  -> Fun_type_ctx.t

val check
  :  all_types : Fun_type_ctx.t
  -> trusted_types : Fun_type_ctx.t
  -> Type_ctx.t
  -> fact list
  -> iml
  -> iml

val casts : iml -> (bitstring Type.t * bitstring Type.t) list

(**
   Check robust safety of encoders, as defined in the paper.
*)
val check_robust_safety : bitstring Sym_defs.t -> Fun_type_ctx.t -> unit

(**
   Check that all functions for which we don't have a definition have a type.
*)
val check_missing_types
  :  trusted_types:Fun_type_ctx.t
  -> inferred_types:Fun_type_ctx.t
  -> iml
  -> unit

val test : unit -> unit
