open Exp
open Common
open Typing

type t = Forall of (var * bitstring Type.t) list * fact

val create : Fun_type_ctx.t -> fact -> t
