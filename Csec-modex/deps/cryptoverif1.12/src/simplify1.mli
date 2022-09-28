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

val repl_index_list : (term * binder) list ref
val new_repl_index : binder -> binder
val map_find_indices : binder list -> (binder * term) list
val get_binder : term -> binder
val true_facts_from_simp_facts : simp_facts -> term list
val term_collisions :
  (term list * binder list * binder list * binder list * term * term * binder *
   term list option * typet list) list ref
val any_term_pat : pattern -> term
val matches_pair : term -> term -> term -> term -> bool
val eq_terms3 : term -> term -> bool
val get_index_size : binder -> int
val filter_indices_coll : term list -> binder list -> binder list -> binder list
val add_term_collisions :
  binder list * (binder * term) list * term list -> term -> term ->
  binder -> term list option -> typet list -> bool
val proba_for_term_collision :
  'a * 'b * 'c * binder list * term * term * binder *
  term list option * typet list -> probaf
val final_add_proba : unit -> setf list

module FindCompos :
  sig
    type status = Compos | Decompos | Any
    type charac_type =
        CharacType of typet
      | CharacTypeOfVar of binder
    type 'a depinfo = (binder * (status * 'a)) list option * term list
    val init_elem : 'a depinfo
    val depends : binder * 'a depinfo -> term -> bool
    val is_indep : binder * 'a depinfo -> term -> term
    val remove_dep_array_index : binder * 'a depinfo -> term -> term
    val remove_array_index : term -> term
    val find_compos : (binder * (status * 'a) ->
       term list -> (status * charac_type) option) -> 'a depinfo ->
      binder * (status * 'a) -> term -> (status * charac_type * term) option
    val find_compos_list :
      (binder * (status * 'a) -> term list -> (status * charac_type) option) ->
      'a depinfo -> (binder * (status * 'a)) list -> term ->
      (status * charac_type * term * binder * 'a) option
  end

val filter_def_list :
  binder list -> binderref list -> binderref list -> binderref list
val remove_subterms : binderref list -> binderref list -> binderref list

exception SuccessBranch of (binder * term) list * binder list
val branch_succeeds : binder list * binderref list * term * 'b ->
  dep_anal -> simp_facts -> binderref list -> unit
val add_elsefind : dep_anal -> binderref list -> simp_facts ->
  (binder list * binderref list * term * 'a) list ->
  term list * term list * elsefind_fact list
val filter_elsefind : (elsefind_fact -> bool) -> simp_facts -> simp_facts
val convert_elsefind : dep_anal -> binderref list ->
  term list * term list * elsefind_fact list -> simp_facts

val try_no_var_rec : simp_facts -> term -> term

val debug_find_unique : bool ref
val is_find_unique : binder list -> fact_info -> simp_facts ->
  (binder list * binderref list * term * 'a) list -> bool
