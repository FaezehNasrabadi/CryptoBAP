(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common

(* We shall use GADTs to make sure that all our expression are well-typed with
   respect to the following 3-types: bitstring, int, and bool. There is no
   significance in int and bool being the same as the system int and bool type,
   the types are only used as phantom types. *)

module Kind : sig
  type 'a t =
  | Bool : bool t
  | Int : int t
  | Bitstring : bitstring t

  val to_string : _ t -> string

  val equal : 'a t -> 'b t -> ('a, 'b) Type_equal.t option
end

module Int_type : sig
  module Signedness : sig
    type t = [ `Signed | `Unsigned ]
    val to_string : t -> string
  end
  type width = int
  type t

  val signedness : t -> Signedness.t
  val width : t -> int
  val create : Signedness.t -> int -> t

  val to_string : t -> string
  val of_string : string -> t

  val latex : ?y : bool ->  t -> string

  val int : t
  val size_t : t
  val ptr : t
end

  (* Not using CV typet, because it contains options that we don't care about, and so is
     not equatable.  *)
  (* TODO: use polymorphic variants to prove to the compiler that Cast_to_int may only
     contain Bs_int *)
type 'a t =
| Bitstringbot : bitstring t               (** All strings and bottom. *)
| Bitstring : bitstring t                  (** All machine-representable strings *)
| Fixed : int -> bitstring t               (** All strings of a given length *)
| Bounded : int -> bitstring t             (** All strings up to a given length *)
| Ptr : bitstring t
| Bs_int : Int_type.t -> bitstring t
  (* A named type with an optional type definition. Named (_, None) may not contain
     bottom. *)
| Named : string * bitstring t option -> bitstring t
  (* Bool does not include bottom *)
  (* CR: make sure you can say the same about Bitstring - right now you use it as a
     synonym for Bitstringbot. *)
| Bool : bool t
  (* Integers and bottom. *)
| Int : int t

type 'a imltype = 'a t

val kind : 'a t -> 'a Kind.t

type any = Any : 'a t -> any

val of_string_bitstring : string -> bitstring t
val of_string : string -> any
val to_string : 'a t -> string
val latex : 'a t -> string

val subtype : 'a t -> 'a t -> bool
val intersection : 'a t -> 'a t -> 'a t
val union : 'a t -> 'a t -> 'a t

val strip_name : 'a t -> 'a t

val has_fixed_length : bitstring t -> bool
val is_bounded : bitstring t -> bool
val is_defined : bitstring t -> bool

val equal : _ t -> _ t -> bool
