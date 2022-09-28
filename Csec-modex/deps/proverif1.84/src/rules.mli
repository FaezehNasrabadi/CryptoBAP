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
val add_not : Types.fact -> unit
val add_elimtrue : int * Types.fact -> unit
val add_equiv : Types.fact list * Types.fact * int -> unit

exception FalseConstraint
val simplify_constra_list : Types.fact list -> Types.constraints list list -> Types.constraints list list
val implies_constra_list : Types.fact list -> Types.constraints list list -> Types.constraints list list -> unit -> unit
val reorder : Types.fact list -> Types.fact list

val completion : Types.reduction list -> unit
val query_goal_std : Types.fact -> Types.reduction list

val main_analysis : Types.reduction list -> Types.fact list -> unit
val bad_derivable : Types.reduction list -> Types.reduction list
val sound_bad_derivable : Types.reduction list -> Types.reduction list


val reset : unit -> unit
