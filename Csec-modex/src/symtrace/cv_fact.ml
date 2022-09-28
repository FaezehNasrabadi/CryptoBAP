open Exp
open Common
open Typing

module E = Exp
module S = Solver

module Stats = Stats_local

type t = Forall of (var * bitstring Type.t) list * fact

let create fun_types (e : fact) : t =
  let vs = E.vars e in
  let ts = Typing.infer_exp fun_types (Some Bool) e in
  match List.diff vs (Type_ctx.keys ts) with
  | [] -> Forall (Type_ctx.to_list ts, e)
  | vs ->
    let vs =
      List.map vs ~f:Var.to_string
      |> String.concat ~sep:", "
    in
    fail "CV_fact.make: could not infer types for %s in %s"
      vs (E.to_string e)

let create fun_types e =
  Stats.call "CV_fact.create" (fun () -> create fun_types e)
