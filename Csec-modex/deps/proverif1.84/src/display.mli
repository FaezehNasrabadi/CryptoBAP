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
open Types

val display_occ : int -> unit
val display_keyword : string -> unit
val newline : unit -> unit
val varname : binder -> string
val display_list : ('a -> unit) -> string -> 'a list -> unit
val display_term : term -> unit
val display_term_list : term list -> unit
val display_fact : fact -> unit
val display_fact_format : fact_format -> unit
val display_constra : constraints list -> unit
val display_constra_list : constraints list list -> unit
val display_rule : reduction -> unit
val display_rule_num : reduction -> unit
val display_eq : term * term -> unit
val display_red : funsymb -> (term list * term) list -> unit

val display_term2 : term -> unit
val display_pattern : pattern -> unit
val display_fact2 : fact -> unit
val display_process : string -> process -> unit
val display_process_occ : string -> process -> unit
val display_corresp_query : Pitypes.realquery -> unit
val display_corresp_putbegin_query : Pitypes.query -> unit
val display_eq_query : Pitypes.eq_query -> unit

val display_function_name : funsymb -> unit
val display_phase : predicate -> unit


module WithLinks :
  sig
    val term : term -> unit
    val term_list : term list -> unit
    val fact : fact -> unit
    val constra : constraints list -> unit
    val concl : bool -> fact -> hypspec list -> unit
  end
