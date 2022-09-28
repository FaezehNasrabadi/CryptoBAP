(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

(**
   Symbolic expressions.
*)

open Common
open Type

type var = Var.t

type 'a t =
| Int : intval -> int t

| Char : char -> int t
(** An int with given ascii value. *)

| String : char list -> bitstring t
(** We use char list instead of string as a reminder to escape each character
    if it is not printable. *)

| Var : var * 'a Kind.t -> 'a t

| Sym : ('a, 'b) Sym.t * 'a t list -> 'b t
  (** [Sym s es] is an application of a symbolic function [s(e1, e2, ...)].  *)

| Range : bitstring t * int t * int t -> bitstring t
  (** A substring of a given expression with given start position and length.  A
      position is a point between two characters or at the beginning or end of
      the string.  Given a string of length [l], the first position is [0], the
      last is [l].  *)

| Concat : bitstring t list -> bitstring t

| Len : bitstring t -> int t

| BS : int t * Int_type.t -> bitstring t

| Val : bitstring t * Int_type.t -> int t

| Struct
    :  (bitstring t Str_map.t) * (bitstring t Str_map.t) * int t * bitstring t
  -> bitstring t
  (** The first component are the real fields, the second are the crypto attributes.
      The last component is the value of underlying memory at the time the struct
      has been created.  This will get removed as soon as I transition to static
      implementation. *)

| Array : (bitstring t Int_map.t) * int t * int t -> bitstring t
  (** Contains total length and element length.

      A good alternative is to use native array, but it only makes sense if I know the
      number of elements in advance.  This can be done, but I don't see overwhelming
      advantages and I'm too lazy to change right now, thus sticking to a sparse
      representation.

      At some point might have to use [Map] here, if there is need to generalize indices
      to arbitrary expressions.  *)

| Ptr : base * pos -> bitstring t
  (** Invariants (being reviewed):

      - The offset list is never empty.

      - The sequence of offset steps is decreasing, except that step may be
      [Unknown] for attribute offsets.

      - An attribute offset always comes last.

      - The first field or context offset is preceded by an index offset.

      - A field, context, or index offset is never preceded by a flat offset.
  *)

| Unknown : 'a Kind.t -> 'a t
  (** Used in length context only, where the value is not known or is not relevant. *)
  (* FIXME: shouldn't unknown be given an index to prevent it being equal to other
     unknowns? *)
| Annotation : 'a annotation * 'a t -> 'a t

and 'a annotation =
| Type_hint of 'a imltype
| Name of var
(* The following annotations contain the definition of the corresponding
   symbol. *)
| Parser : bitstring t -> bitstring annotation
(* (def, c) is a parser that fails if the argument is not in the range of the
   encoder c. Only used in pvtrace. *)
| Pi_parser : (bitstring t * Sym.bfun) -> bitstring annotation
| Encoder : bitstring t -> bitstring annotation
| Auxiliary : bool t -> bool annotation
| Arith : bitstring t -> bitstring annotation

(** Not the same as lhost in CIL *)
and base =
(* CR-someday: track sizes of stack pointers *)
| Stack of string
(** (Old) Name and unique id of variable. Note that this way variables from
    different calls of the same function will be mapped to the same base, but not
    variables from different functions. *)
| Heap of (id * int t list * int t)
(** Contains lengths of previous mallocs and the size of the allocated area. *)
(* CR-someday: make sure these are not dereferenced. *)
| Abs of intval
  (** An absolute pointer value to deal with cases like:
      {[
        // signal.h:
  typedef void ( *__sighandler_t) (int);
          // signum.h:
          /* Fake signal functions.  */
            #define SIG_ERR ((__sighandler_t) -1)       /* Error return.  */
            #define SIG_DFL ((__sighandler_t) 0)        /* Default action.  */
            #define SIG_IGN ((__sighandler_t) 1)        /* Ignore signal.  */
      ]}
  *)

and offset_val =
| Field of string
| Attr of string
| Index of int
  (* Not intval, cause ocaml is really clumsy with that - you can't even
     subtract it easily *)
  (* For now flat offsets are true ints, unlike in the thesis *)
| Flat of int t
  (** Flat offsets always measured in bytes *)

(** Offset value together with offset step *)
and offset = offset_val * int t

and pos = offset list

type 'a exp = 'a t

type iterm = int t
type bterm = bitstring t
type fact = bool t

type any = Any : 'a t -> any

(*************************************************)
(** {1 Collections} *)
(*************************************************)

module Kind : module type of Kind with type 'a t = 'a Kind.t

module Base_map : Map.S with type key = base

module Fact_set : Set.S with type elt = fact

module Set : sig
  type 'a exp = 'a t
  include Set.S with type elt = any

  val add : 'a exp -> t -> t
  val mem : 'a exp -> t -> bool
end

module Key : sig
  type 'a t = 'a exp
  include GADT_key with type 'a t := 'a t
                   and module Kind = Kind
end

module Map_any : module type of Common.Map_any (Kind) (Key)

(*************************************************)
(** {1 Traversal} *)
(*************************************************)

type 'b map = { f : 'a. 'a t -> 'b }
type descend = { descend : 'a. 'a t -> 'a t }

(**
   Does not include lengths for non-range expressions.
*)
val map_children : 'b map ->  _ t -> 'b list
val iter_children : unit map -> _ t -> unit

(**
   Not going into lengths for non-range expressions.
*)
val descend : descend -> 'a t -> 'a t

(*************************************************)
(** {1 Typing } *)
(*************************************************)

val invariant  : _ t -> unit
val itype      : int t -> Int_type.t option
val itype_exn  : int t -> Int_type.t
val kind       : 'a t -> 'a Kind.t
val coerce     : 'a Kind.t -> _ t -> 'a t option
val equal      : 'a t -> 'b t -> ('a, 'b) Type_equal.t option
val phys_equal : 'a t -> 'b t -> ('a, 'b) Type_equal.t option

(*************************************************)
(** {1 IDs} *)
(*************************************************)

val id : _ t -> int
val reset_ids : unit -> unit

val serialize_state : out_channel -> unit
val deserialize_state : in_channel -> unit

(*************************************************)
(** {1 Arithmetics} *)
(*************************************************)

val zero : iterm
val one  : iterm

val sum  : iterm list -> iterm
val minus : iterm -> iterm -> iterm
val prod : iterm list -> iterm

(* Some minimal arithmetic simplifications. Only for esthetic reasons since
   Yices would do its own simplifications anyway. *)

(** Does not do constant folding - this way we might see more about the history
    of the expression. *)
val arith_simplify : iterm -> iterm

(*************************************************)
(** {1 Pointers} *)
(*************************************************)

val ptr_size : base -> int t option
val malloc_expr : int t list -> int t

(*---------------------------
  To be removed
-----------------------------*)

val is_zero_offset_val : offset_val -> bool
val is_zero_pos : pos -> bool
val is_field_offset_val : offset_val -> bool

(*************************************************)
(** {1 Misc} *)
(*************************************************)

val var_s : string -> bterm
val var : var -> bterm
val encoder : bterm list -> bterm
val range : bterm -> iterm -> iterm -> bterm
val int : int -> int t
val string : string -> bterm

val zero_byte : bterm

(* CR-someday: this is not a full abstraction since
   [Transformations.normal_form] explicitly enumerates the caess of this
   function. However, changing this function will cause [normal_form] to fail,
   so at least we will notice. Think of some refactoring to make this better. *)
val is_cryptographic : bterm -> bool
val is_constant : _ t -> bool
val is_tag : bitstring t -> bool
val is_constant_integer_expression : iterm -> bool
val is_constant_integer_fact : fact -> bool
val contains_sym : (_, _) Sym.t -> _ t -> bool

val vars : _ t -> var list

val refcount : var -> _ t -> int

val subst   : var list -> 'b t list  -> 'a t -> 'a t
val subst_v : var list -> var list -> 'a t -> 'a t

val remove_annotations : 'a t -> 'a t

val len : bterm -> iterm

val apply : ('a, 'b) Sym.t -> any list -> 'b t

(** Make sure all subexpressions are physically distinct. Only used in
    Derivation. *)
val unfold : 'a t -> 'a t

(*************************************************)
(** {1 Facts} *)
(*************************************************)

val eq_bitstring : bterm list -> fact
val eq_int : iterm list -> fact
val gt : iterm -> iterm -> fact
val ge : iterm -> iterm -> fact

val is_defined : _ exp -> fact

val true_fact : fact

val conj : fact list -> fact
val disj : fact list -> fact

val flatten_conj : fact -> fact list

val in_type : bterm -> bitstring Type.t -> fact

val negation : fact -> fact
val implication : fact list -> fact list -> fact

(* CR: make this part of solver rewriting? *)
(** The truth function from the thesis that takes C bool expressions and converts
    them to expressions of type Bool.  In particular, all bool C operators (LNot,
    LAnd, ...) are replaced by "proper" bool operators (Not, And, ...).  *)
val truth : bterm -> fact

module Range : sig
  type t = Int_type.t

  val contains : t -> iterm -> fact list
  val subset : t -> t -> bool
end

(********************************************************)
(** {1 Function Definitions} *)
(********************************************************)

module Sym_defs : sig
  include module type of Sym.Map(Key)

  (** We represent a lambda expression with n arguments by an expression
     containing variables [(mk_arg 0)] to [(mk_arg (n - 1))].  *)
  type 'a def = 'a exp

  val to_string : _ t -> string

  val print : _ t -> unit
end

val mk_arg : int -> var

val mk_arg_len : int -> int t

(* CR-someday: it feels like this should return exp list. *)
val mk_formal_args : int -> var list

val show_fun : ('a, 'b) Sym.t -> 'b t -> string

val expand_defs : 'a t -> 'a t

val defs_to_string : _ t -> string option

val parsers : _ t -> bitstring Sym_defs.t
val encoders : _ t -> bitstring Sym_defs.t
val arith : _ t -> bitstring Sym_defs.t
val auxiliary : _ t -> bool Sym_defs.t

val is_def_annotation : _ annotation -> bool

(*************************************************)
(** {1 Show} *)
(*************************************************)

val to_string : _ t -> string
val dump : _ t -> string
val dump_list : _ t list -> string
val list_to_string : ?newline:bool -> _ t list -> string
val base_to_string : base -> string
val offset_to_string : offset -> string

module Wrap : sig
  type t =
    { wrap_after : int
    ; wrap_to    : int
    ; sep        : string
    }
end

val latex : ?wrap:Wrap.t -> _ t -> string
