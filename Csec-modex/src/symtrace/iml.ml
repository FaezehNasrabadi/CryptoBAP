(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common
open Printf
open Exp

module Pat = struct
  type t =
  | VPat of Var.t
  | FPat : (bitstring, bitstring) Sym.t * t list -> t
  | Underscore

  let rec vars = function
    | FPat (_, pats) -> List.concat_map ~f:vars pats
    | VPat v -> [v]
    | Underscore -> []

  let rec dump = function
    | VPat v -> Var.to_string v
    | FPat (f, ps) ->
      sprintf "%s(%s)"
        (Sym.to_string f)
        (String.concat ~sep:", " (List.map ~f:dump ps))
    | Underscore -> "_"

  let vpat v =
    VPat (Var.of_string v)
end

module Stmt = struct
  open Exp

  type t =
  | Let of Pat.t * bterm
  (**
     [Test e; P = if e then P else 0]
  *)
  | Test of fact
  | Eq_test of bterm * bterm
  | Assume of fact
  | In of var list
  | Out of bterm list
  | New of var * bitstring Type.t
  | Event of string * bterm list
  | Yield
  | Comment of string

  type stmt = t

  let map_children { Exp.f } = function
    | Let (_, e) -> [f e]
    | Test e -> [f e]
    | Eq_test (e1, e2) -> [f e1; f e2]
    | Assume e -> [f e]
    | In _ -> []
    | Out es -> List.map ~f es
    | New _ -> []
    | Event (_ev, es) -> List.map ~f es
    | Yield -> []
    | Comment _ -> []

  let iter_children map t =
    ignore (map_children map t)

  let exists_child map t =
    let results = map_children map t in
    List.exists results ~f:Fn.id

  let descend {Exp.descend = f} = function
    | Let (pat, e) -> Let(pat, f e)
    | Test e -> Test (f e)
    | Eq_test (e1, e2) -> Eq_test (f e1, f e2)
    | Assume e -> Assume (f e)
    | In vs -> In vs
    | Out es -> Out (List.map ~f es)
    | New (v, t) -> New (v, t)
    | Event (ev, es) -> Event (ev, List.map ~f es)
    | Yield -> Yield
    | Comment s -> Comment s

  let to_string t =
    match t with
    | In [v] ->
      "in(c, " ^ Var.to_string v ^ ");";

    | In vs ->
      List.map vs ~f:Var.to_string
      |> String.concat ~sep:", "
      |> sprintf "in(c, (%s));";

    | New (v, t) ->
      "new " ^ Var.to_string v ^ ": " ^ Type.to_string t ^ ";"

    | Out [e] ->
      "out(c, " ^ Exp.to_string e ^ ");";

    | Out es ->
      "out(c, (" ^ String.concat ~sep:", " (List.map ~f:Exp.to_string es) ^ "));";

    | Test e ->
      "if " ^ Exp.to_string e ^ " then "

    | Eq_test (e1, e2) ->
      "ifeq " ^ Exp.to_string e1 ^ " = " ^ Exp.to_string e2 ^ " then "

    | Assume e ->
      Printf.sprintf "assume %s in" (Exp.to_string e)

    | Event (name, es) ->
      "event " ^ name ^ "(" ^ String.concat ~sep:", " (List.map ~f:Exp.to_string es) ^ ");"

    | Let (pat, e) ->
      "let " ^ Pat.dump pat ^ " = " ^ Exp.to_string e ^ " in"

    | Yield -> "yield ."

    | Comment s -> sprintf "(* %s *)" s

  let to_string t =
    let defs = map_children { f = Exp.defs_to_string } t in
    match String.concat_some defs ~sep:"\n  " with
    | None -> to_string t
    | Some defs ->
      sprintf "  (* %s *)\n%s" defs (to_string t)

  let subst vs es t =
    descend {Exp.descend = (fun e -> Exp.subst vs es e)} t

  let vars s = map_children {Exp.f = Exp.vars} s |> List.concat

  let remove_annotations t =
    descend {Exp.descend = Exp.remove_annotations} t

  let is_auxiliary_test = function
    | Test (Sym (Sym.Fun _, _)) -> false
    | Test _ -> true
    | _ -> false

  let make_test (e : fact) =
    let open Sym in
    match e with
    | Sym (Bs_eq, [e1; e2]) as e ->
      if (Exp.is_cryptographic e1 && Exp.is_cryptographic e2)
      then Eq_test (e1, e2)
      else Test e
    | e -> Test e

  let facts = function
    | Test fact | Assume fact -> [Exp.expand_defs fact]
    | Eq_test (e1, e2) -> [Exp.eq_bitstring [e1; e2]]
    | In vs -> List.map vs ~f:(fun v -> Exp.is_defined (Var (v, Kind.Bitstring)))
    | New (v, t) -> [Exp.in_type (Var (v, Kind.Bitstring)) t]
    | _ -> []

  let parsers t =
    map_children { f = Exp.parsers } t |> Sym_defs.disjoint_union

  let encoders t =
    map_children { f = Exp.encoders } t |> Sym_defs.disjoint_union

  let arith t =
    map_children { f = Exp.arith } t |> Sym_defs.disjoint_union

  let auxiliary t =
    map_children { f = Exp.auxiliary } t |> Sym_defs.disjoint_union
end

open Stmt
open Pat

type t = Stmt.t list
type iml = t

let map descend p = List.map ~f:(Stmt.descend descend) p
let iter f p = List.iter ~f:(fun s -> Stmt.iter_children f s) p

let refcount v p =
  List.sum_with (fun s ->
    Stmt.map_children {Exp.f = fun e -> Exp.refcount v e} s |> List.sum) p

let vars p = List.concat_map ~f:Stmt.vars p

let rec free_vars = function
  | Let (VPat v, e) :: p ->
    List.remove v (Exp.vars e @ free_vars p)
  | New (v, _t) :: p ->
    List.remove v (free_vars p)
  | In vs :: p ->
    List.diff (free_vars p) vs
  | s :: p ->
    Stmt.vars s @ free_vars p
  | [] -> []

let rec subst vs es =
  let subst_under_binding p v =
    let vs, es =
      List.combine vs es
      |> List.filter ~f:(fun (v', e) ->
        if v' = v then false
        else if List.mem v ~set:(Exp.vars e) && refcount v' p > 0
        then
          fail "subst: variable %s captures a variable in substitution %s ~> %s"
            (Var.to_string v)
            (Var.to_string v')
            (Exp.to_string e)
        else true)
      |> List.split
    in
    subst vs es p
  in
  function
  | [] -> []
  | s :: p ->
    let s = Stmt.subst vs es s in
    match s with
    | New (v, _) ->
      s :: subst_under_binding p v
    | Let (pat, _) ->
      let vs' = Pat.vars pat in
      s :: List.fold_left ~f:subst_under_binding ~init:p vs'
    | In vs' ->
      s :: List.fold_left ~f:subst_under_binding ~init:p vs'
    | s -> s :: subst vs es p

let subst_v vs vs' e =  subst vs (List.map ~f:Exp.var vs') e

let to_string p =
  String.concat ~sep:"\n" (List.map ~f:Stmt.to_string p) ^ "\n"

let remove_annotations p =
  List.map p ~f:Stmt.remove_annotations

let parsers t =
  List.map t ~f:Stmt.parsers |> Sym_defs.compatible_union

let encoders t =
  List.map t ~f:Stmt.encoders |> Sym_defs.compatible_union

let arith t =
  List.map t ~f:Stmt.arith |> Sym_defs.compatible_union

let auxiliary t =
  List.map t ~f:Stmt.auxiliary |> Sym_defs.compatible_union

let rec remove_assumptions = function
  | Assume _ :: p -> remove_assumptions p
  | s :: p -> s :: remove_assumptions p
  | [] -> []

(*************************************************)
(** {1 Comments} *)
(*************************************************)

let filter_with_comments ~f p =
  let rec filter = function
    | Comment _ :: s :: p when not (f s) -> filter p
    | s :: p when not (f s) -> filter p
    | s :: p -> s :: filter p
    | [] -> []
  in
  filter p

let rec remove_comments = function
  | Comment _ :: p -> remove_comments p
  | s :: p -> s :: remove_comments p
  | [] -> []

(* 1490 lines *)

