  (*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
  *)

open Common

(* TODO: introduce tuple types so that we can check arities of symbols. This
   will also allow to treat Replicate more gracefully. *)
type ('a, 'b) t = 'a Type.t list * 'b Type.t

type any = Any : (bitstring, 'b) t -> any

val to_string : (_, _) t -> string
val of_string : string -> any

val arity : (_, _) t -> int
val kind : (_, 'a) t -> 'a Type.Kind.t

