(*************************************************************
 *                                                           *
 *       Cryptographic protocol verifier                     *
 *                                                           *
 *       Bruno Blanchet                                      *
 *                                                           *
 *       Copyright (C) ENS, CNRS, INRIA, 2005-2011           *
 *                                                           *
 *************************************************************)

(*

    Copyright ENS, CNRS, INRIA 
    contributor: Bruno Blanchet, Bruno.Blanchet@ens.fr
    
This software is a computer program whose purpose is to verify 
cryptographic protocols in the computational model.

This software is governed by the CeCILL-B license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the CeCILL-B
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the CeCILL-B license and that you accept its terms.

*)
open Types

val repeat : int -> 'a -> 'a list
val skip : int -> 'a list -> 'a list
val split : int -> 'a list -> ('a list * 'a list)
val find_in_list : 'a -> 'a list -> int
val equal_lists : ('a -> 'a -> bool) -> 'a list -> 'a list -> bool
val equal_instruct : instruct -> instruct -> bool
val add_eq : instruct -> instruct list -> instruct list
val union_eq : instruct list -> instruct list -> instruct list
val map_concat : ('a -> instruct list) -> 'a list -> instruct list
val union_setf : setf list list -> setf list
val lsuffix : int -> 'a list -> 'a list
val remove_suffix : int -> 'a list -> 'a list

val type_for_param : param -> typet
val param_from_type : typet -> param

val binder_from_term : term -> binder
val term_from_binder : binder -> term
val term_from_binderref : binderref -> term
val build_term : term -> term_desc -> term
val build_term2 : term -> term_desc -> term
val build_term_type : typet -> term_desc -> term

val iproc_from_desc : inputprocess_desc -> inputprocess
val oproc_from_desc : process_desc -> process
val iproc_from_desc2 : inputprocess -> inputprocess_desc -> inputprocess
val oproc_from_desc2 : process -> process_desc -> process
val nil_proc : inputprocess
val yield_proc : process

val cst_for_type : typet -> term

val is_restr : binder -> bool
val is_repl : binder -> bool
val is_assign : binder -> bool

val current_bound_vars : Types.binder list ref
val cleanup : unit -> unit
val link : Types.binder -> Types.linktype -> unit
val auto_cleanup : (unit -> 'a) -> 'a

val vcounter : int ref
val new_occ : unit -> int
val new_vname : unit -> int
val new_binder : binder -> binder
val create_binder : string -> int -> typet -> term list -> binder

val copy_term : term -> term
val subst : binder list -> term list -> term -> term

val copy_term3 : term -> term
val subst3 : (binder * term) list -> term -> term
val subst_def_list3 : (binder * term) list -> binderref list -> binderref list
val subst_oprocess3 : (binder * term) list -> process -> process

val equal_terms : term -> term -> bool
val equal_term_lists : term list -> term list -> bool 
val equal_probaf : probaf -> probaf -> bool
val len_common_suffix : term list -> term list -> int

val equal_binderref : binderref -> binderref -> bool
val mem_binderref : binderref -> binderref list -> bool
val add_binderref : binderref -> binderref list ref -> unit
val setminus_binderref : binderref list -> binderref list -> binderref list
val inter_binderref : binderref list -> binderref list -> binderref list

val get_deflist_subterms : binderref list ref -> term -> unit
val get_deflist_process : binderref list ref -> inputprocess -> unit
val get_deflist_oprocess : binderref list ref -> process -> unit

val refers_to : binder -> term -> bool
val refers_to_br : binder -> binderref -> bool
val refers_to_pat : binder -> pattern -> bool
val refers_to_process : binder -> inputprocess -> bool
val refers_to_oprocess : binder -> process -> bool
val refers_to_fungroup :  binder -> fungroup -> bool

val refers_to_nodef : binder -> term -> bool
val refers_to_process_nodef : binder -> process -> bool

val vars_from_pat : binder list -> pattern -> binder list
val occurs_in_pat : binder -> pattern -> bool

val is_true : term -> bool
val is_false : term -> bool

val make_and_ext : Parsing_helper.extent -> term -> term -> term
val make_or_ext : Parsing_helper.extent -> term -> term -> term
val make_equal_ext : Parsing_helper.extent -> term -> term -> term
val make_diff_ext : Parsing_helper.extent -> term -> term -> term

val make_and : term -> term -> term
val make_or : term -> term -> term
val make_and_list : term list -> term
val make_or_list : term list -> term
val make_not : term -> term
val make_equal : term -> term -> term
val make_let_equal : term -> term -> term
val make_diff : term -> term -> term
val make_true : unit -> term
val make_false : unit -> term

val or_and_form : term -> term

val is_tuple : term -> bool
val is_pat_tuple : pattern -> bool

val intersect : ('a -> 'a -> bool) -> 'a list -> 'a list -> 'a list

val put_lets : pattern list -> term list -> process -> process -> process
val put_lets_term : pattern list -> term list -> term -> term option -> term
exception Impossible
val split_term : funsymb -> term -> term list

val move_occ_process : inputprocess -> inputprocess

val term_from_pat : pattern -> term
val get_type_for_pattern : pattern -> typet

val not_deflist : binder -> elsefind_fact -> bool
val not_deflist_l : binder list -> elsefind_fact -> bool

val close_def_subterm : binderref list ref -> binderref -> unit
val close_def_term : binderref list ref -> term -> unit
val def_term : def_node -> term list -> binderref list -> term -> def_node
val build_def_process : (term * fact_info) list ref option -> inputprocess -> unit
val add_def_vars_node : binder list -> def_node -> binder list

val cleanup_array_ref : unit -> unit
val array_ref_eqside : eqmember -> unit
val array_ref_process : inputprocess -> unit
val has_array_ref : binder -> bool

val exclude_array_ref_term : binder list -> term -> unit
val exclude_array_ref_def_list : binder list -> binderref list -> unit
val exclude_array_ref_pattern : binder list -> pattern -> unit
val cleanup_exclude_array_ref : unit -> unit
val all_vars_exclude : binder list ref
val has_array_ref_non_exclude : binder -> bool

val union : 'a list -> 'a list -> 'a list (* union using physical equality *)

val compatible_empty : binderset
val empty_comp_process : inputprocess -> unit
val build_compatible_defs : inputprocess -> unit
val is_compatible : binderref -> binderref -> bool
