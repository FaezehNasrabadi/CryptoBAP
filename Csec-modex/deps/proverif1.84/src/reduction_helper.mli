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

val main_process : process ref
val min_choice_phase : int ref

val get_pat_type : pattern -> typet
val new_var_pat1 : pattern -> binder
val new_var_pat : pattern -> term
val get_pat_vars : pattern -> binder list
val occurs_var_pat : binder -> pattern -> bool
val occurs_var_proc : binder -> process -> bool

val need_vars_in_names : (string * string * Parsing_helper.extent) list ref
val get_need_vars : string -> (string * Parsing_helper.extent) list

val findi : ('a -> bool) -> 'a list -> int * 'a
val skip : int -> 'a list -> 'a list
val replace_at : int -> 'a -> 'a list -> 'a list
val remove_at : int -> 'a list -> 'a list
val add_at : int -> 'a -> 'a list -> 'a list
val order_of_int : int -> string
val itern : ('a -> unit) -> int -> 'a list -> unit
val funsymb_from_funspec : funspec -> funsymb

val equal_terms_modulo : term -> term -> bool
val equal_open_terms_modulo : term -> term -> bool
val equal_facts_modulo : fact -> fact -> bool
val match_modulo : (unit -> 'a) -> term -> term -> 'a
val match_modulo_list :
  (unit -> 'a) -> term list -> term list -> 'a

val get_name_charac : term -> funsymb list
val init_name_mapping : funsymb list -> unit
val add_name_for_pat : term -> funsymb
val add_new_name : typet -> funsymb

val display_tag : hypspec list -> term list -> unit
val display_step : Pitypes.reduc_type -> unit

val public_free : term list ref

val match_equiv : (unit -> 'a) -> fact -> fact -> 'a
val match_equiv_list :
  (unit -> 'a) -> fact list -> fact list -> 'a

val fact_subst :
  fact -> funsymb -> term -> fact
val process_subst :
  process -> funsymb -> term -> process

val copy_binder : binder -> binder
val copy_pat : pattern -> pattern
val copy_process : process -> process

val close_term : term -> unit
val close_tree : fact_tree -> unit

val copy_closed : term -> term
val copy_closed_remove_syntactic : term -> term

val rev_name_subst : term -> term
val rev_name_subst_list : term list -> term list
val rev_name_subst_fact : fact -> fact

val follow_link : term -> term
val close_tree_collect_links : (binder * linktype) list ref -> fact_tree -> unit

val getphase : predicate -> int
