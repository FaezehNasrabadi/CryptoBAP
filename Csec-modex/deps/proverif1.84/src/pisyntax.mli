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
open Pitypes

val query_list : Piptree.query list list ref

val parse_file : string -> process
val display : unit -> unit
val transl_query : Piptree.query list -> query list
val query_to_facts : query list -> fact list
val update_arity_names : query -> query
val get_noninterf_queries : unit -> (funsymb * term list option) list list
val get_weaksecret_queries : unit -> funsymb list
val get_not : unit -> event list
val get_nounif : unit -> (fact_format * int) list


