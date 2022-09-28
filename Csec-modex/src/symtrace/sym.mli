(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common
open Type

module Cmp : sig
  type t = Lt | Gt | Le | Ge | Eq | Ne
end

module Arith : sig
  type t = Plus of int | Minus | Mult of int | Div | Neg
end

module Logical : sig
  type t = And of int | Or of int | Not | Implies | True | Eq
end

  (** C operators *)
module Op : sig
    (* TODO: import these directly from CIL *)
  type t =
    BNot                                (** Bitwise complement (~) *)
  | LNot                                (** Logical Not (!) *)

  | Op_arith of Arith.t                 (** arithmetic + *)
  | Op_cmp of Cmp.t                     (** <  (arithmetic comparison) *)

    (* We don't use Index_pI *)
  | Plus_PI                              (** pointer + int *)

  | Minus_PI                             (** pointer - int *)
  | Minus_PP                             (** pointer - pointer *)
  | Mod                                 (** % *)
  | Shiftlt                             (** shift left *)
  | Shiftrt                             (** shift right *)

  | BAnd                                (** bitwise and *)
  | BXor                                (** exclusive-or *)
  | BOr                                 (** inclusive-or *)

  | LAnd                                (** logical and. Unlike other
                                         * expressions this one does not
                                         * always evaluate both operands. If
                                         * you want to use these, you must
                                         * set {!Cil.use_logical_operators}. *)
  | LOr                                 (** logical or. Unlike other
                                         * expressions this one does not
                                         * always evaluate both operands.  If
                                         * you want to use these, you must
                                         * set {!Cil.use_logical_operators}. *)

    (* These are added by us, they are not defined as ops in CIL *)
  | Cast_to_int
  | Cast_to_ptr
  | Cast_to_other
end

type name = string
type arity = int
type invocation_id = int

(* CR-soon: make Fun a placeholder for structured bitstring symbols, such as
  Inverse.
*)
type ('a, 'b) t =
  (* TODO: should take Int_type.t *)
| Op : Op.t * (bitstring, bitstring) Fun_type.t -> (bitstring, bitstring) t

| Bs_eq : (bitstring, bool) t
(** Bitstring comparison, works on bottoms too. *)
| Cmp : (bitstring, bitstring) t
  (* TODO: what about bottoms? *)
  (** Bitstring comparison returning bitstring result.  Bs_eq(x, y) = Truth(Cmp(x, y)) *)

| Int_op : Arith.t -> (int, int) t
| Int_cmp : Cmp.t -> (int, bool) t
| Logical : Logical.t -> (bool, bool) t

| Ptr_len : (_, int) t

| Malloc : int -> (int, int) t

| Cast : bitstring imltype * bitstring imltype -> (bitstring, bitstring) t

| Ztp : (bitstring, bitstring) t
  (**
     Zero-terminated prefix - up to but not including the first 0.
     Bottom if the bitstring does not contain zero.
  *)

| Ztp_safe : (bitstring, bitstring) t
  (**
     Same as Ztp, but returns the argument unchanged instead of bottom.
  *)

  (* Takes two bitstring arguments: the character to replicate and the
     replication length encoded in some manner. The length of the replication is
     set using an assertion.*)
| Replicate : (bitstring, bitstring) t
  (** Field_offset is only there for CSur, in which network data is treated as a
      structure directly. We don't try to prove safety of this. *)
| Field_offset : string -> (_, int) t
| Opaque : ('a, 'a) t
(** Used only in Solver *)
| Defined : ('a, bool) t
| In_type : 'a imltype -> ('a, bool) t
(** Defined is the same as (In_type Bitstring) *)

| Truth_of_bs : (bitstring, bool) t
| BS_of_truth : Int_type.width -> (bool, bitstring) t

(* The yices versions of len and val, see thesis. *)
| Len_y : (bitstring, int) t
| Val_y : Int_type.t -> (bitstring, int) t

(* FIXME: unify with unknown? *)
| Undef : invocation_id -> (_, bitstring) t
  (** With a tag to distinguish different undefs.
      FIXME: Do not create explicitly, use Expr.undef. *)

| Fun : name * (arity * 'b Kind.t) -> (bitstring, 'b) t

type ('a, 'b) sym = ('a, 'b) t

type bfun = (bitstring, bitstring) t

type any = Any : ('a, 'b) t -> any
type any_bitstring = Any_bitstring : (bitstring, 'b) t -> any_bitstring

val any : (_, _) t -> any

val kind : ('a, 'b) t -> 'b Kind.t

  (**
     May return bottom even if all arguments are not bottom.
  *)
val may_fail : (_, _) t -> bool
val never_fails : (_, _) t -> bool

val arity : (_, _) t -> int

val result_itype : (_, _) t -> Int_type.t option

val is_infix : (_, _) t -> bool

val to_string : (_, _) t -> string
val to_string_hum : ?show_types:bool -> (_, _) t -> string
val latex : ?show_types:bool -> (_, _) t -> string
val of_string : string -> any
val of_string_bitstring : string -> bfun

val cv_declaration : ('a, 'b) t -> ('a, 'b) Fun_type.t -> string

(* Used for writing CV equations where we don't want RHS to unify with LHS.. *)
val prime :(bitstring, 'b) t -> (bitstring, 'b) t
val unprime : (bitstring, 'b) t -> (bitstring, 'b) t option

module Key : sig
  type 'a t = (bitstring, 'a) sym
  include GADT_key with type 'a t := 'a t
                   and module Kind = Kind
end

(*************************************************)
(** {1 Helpers} *)
(*************************************************)

val make : string -> arity:int -> (bitstring, bitstring) t

val make_bool : string -> arity:int -> (bitstring, bool) t

val make_const : string -> (bitstring, bitstring) t

val new_encoder : arity:int -> (bitstring, bitstring) t

val new_parser : unit -> (bitstring, bitstring) t

val new_arith : arity:int -> (bitstring, bitstring) t

val new_auxiliary : arity:int -> (bitstring, bool) t

(*************************************************)
(** {1 Maps} *)
(*************************************************)

module Map_any : module type of Common.Map_any (Kind) (Key)

module Map (Value : GADT) : sig
  type 'a sym = (bitstring, 'a) t
  type 'a t

  val empty : unit -> 'a t
  val is_empty : _ t -> bool
  val singleton : 'a sym -> 'a Value.t -> 'a t
  val add : 'a sym -> 'a Value.t -> 'a t -> 'a t
  val maybe_find : 'a sym -> 'a t -> 'a Value.t option
  val find : 'a sym -> 'a t -> 'a Value.t
  val mem : 'a sym -> 'a t -> bool
  val iter : f:('a sym -> 'a Value.t -> unit) -> 'a t -> unit
  val disjoint_union : 'a t list -> 'a t
  val compatible_union : 'a t list -> 'a t
  val of_list : ('a sym * 'a Value.t) list -> 'a t
  val to_list : 'a t -> ('a sym * 'a Value.t) list
  val keys : 'a t -> 'a sym list
  val values : 'a t -> 'a Value.t list
  val filter : f:('a sym -> 'a Value.t -> bool) -> 'a t -> 'a t
end
