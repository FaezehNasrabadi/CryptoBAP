(*************************************************************
 *                                                           *
 *       Cryptographic protocol verifier                     *
 *                                                           *
 *       Bruno Blanchet and Xavier Allamigeon                *
 *                                                           *
 *       Copyright (C) INRIA, LIENS, MPII 2000-2009          *
 *                                                           *
 *************************************************************)

(*

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details (in file LICENSE).

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*)
(* This module contains basic functions to manipulate terms modulo
   an equational theory *)

(* Register an equation *)
val register_equation : Types.term * Types.term -> unit

(* returns true when at least one equation has been registered since last
   call to record_eqs *)
val hasEquationsToRecord : unit -> bool

(* returns true when at least one equation has been registered *)
val hasEquations : unit -> bool

(* Transforms equations into "equational destructors" *)
val record_eqs : unit -> unit


val close_term_eq : (Types.term -> unit) -> Types.term -> unit
val close_term_list_eq : (Types.term list -> unit) -> Types.term list -> unit
val close_fact_eq : (Types.fact -> unit) -> Types.fact -> unit
val close_fact_list_eq : (Types.fact list -> unit) -> Types.fact list -> unit
val close_rule_eq : (Types.reduction -> unit) -> Types.reduction -> unit
val close_rule_destr_eq : (Types.fact list * Types.fact * Types.constraints list list -> unit) -> Types.fact list * Types.fact * Types.constraints list list -> unit

(* Unification modulo the equational theory *)
val unify_modulo : (unit -> 'a) -> Types.term -> Types.term -> 'a
val unify_modulo_list : (unit -> 'a) -> Types.term list -> Types.term list -> 'a
val unify_modulo_env : (unit -> 'a) -> (Types.binder * Types.term) list -> (Types.binder * Types.term) list -> 'a

val copy_remove_syntactic : Types.term -> Types.term
val copy_remove_syntactic_fact : Types.fact -> Types.fact
val copy_remove_syntactic_constra : Types.constraints list -> Types.constraints list
val remove_syntactic_term : Types.term -> Types.term
val remove_syntactic_fact : Types.fact -> Types.fact
val remove_syntactic_constra : Types.constraints list -> Types.constraints list

(* Closes destructor reductions under the equational theory *)
val close_destr_eq : Types.funsymb -> (Types.term list * Types.term) list -> (Types.term list * Types.term) list

(* Simplifies a term using the equations *)
exception Reduces
val simp_eq : Types.term -> Types.term
