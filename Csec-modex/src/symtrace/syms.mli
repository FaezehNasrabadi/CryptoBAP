open Sym
open Exp
open Common
open Typing

(** The set of functions that we are turning into abstract symbols during
    translation to PV/CV. *)

(* CR-soon: looks like you can do all of the typing first, so that
   Fun_type_ctx.t can be wrapped into Syms.
*)

(**
  [parser(encoder) = result]
*)
module Parsing_eq : sig
  type t =
    { p : bfun (* parser is a keyword in camlp4? *)
    ; c : bfun
    ; i : int
    }

  val to_string : ?fun_types:Fun_type_ctx.t -> t -> string

  val find_match : t list -> p:bfun -> c:bfun -> int option
end

module Aux_fact : sig
  type fun_decl = (bitstring, bitstring) Fun_type.t * bfun

  (* The symbols in a pair returned by functions below are ordered. *)
  type t =
  | Disjoint of (fun_decl * fun_decl)
  | Equal of (fun_decl * fun_decl)
end

type t

(* Does all the necessary computations. *)
val create : Iml.t -> t

val encoders  : t -> bitstring Sym_defs.t
val parsers   : t -> bitstring Sym_defs.t
val arith     : t -> bitstring Sym_defs.t
val auxiliary : t -> bool Sym_defs.t
val casts : t -> (bitstring Type.t * bitstring Type.t) list

val binary_defs : t -> bitstring Sym_defs.t

val def : t -> bfun -> bterm

val disjoint_union : t list -> t
val compatible_union : t list -> t

val parsing_eqs : t -> Fun_type_ctx.t -> Parsing_eq.t list

val arithmetic_facts : t -> Fun_type_ctx.t -> Aux_fact.t list
val encoder_facts : t -> Fun_type_ctx.t -> Aux_fact.t list
val auxiliary_facts : t -> Fun_type_ctx.t -> Cv_fact.t list

val zero_facts : t -> Fun_type_ctx.t -> Cv_fact.t list
val zero_funs : t -> Fun_type_ctx.t -> bitstring Sym_defs.t
val zero_types : t -> Fun_type_ctx.t -> Typing.Fun_type_ctx.t

val check_encoders_are_robustly_injective : t -> Fun_type_ctx.t -> unit

(* Assumes that all syms are type-safe. *)
val check_is_regular : t -> Fun_type_ctx.t -> unit
