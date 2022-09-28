open Iml
open Typing

(* All the invormation is contained in [client] and [server], the rest of the
   fields can be recomputed from these two. *)
type t = {
  client : iml;
  server : iml;
  template : Template.t;
  var_types : Type_ctx.t;
  fun_types : Fun_type_ctx.t;

  primed : Sym.any_bitstring list;

  syms : Syms.t
}

val make : client:iml -> server:iml -> ?for_pv:bool -> Template.t -> t

val print : t -> unit
