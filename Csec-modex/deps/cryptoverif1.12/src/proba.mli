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

(* 1. Is a type large? (i.e. the inverse of its cardinal is negligible) *)

(* Returns true when the type has size >= Settings.tysize_MIN_Auto_Coll_Elim
   i.e. collisions should be automatically elimminated on this type. *)
val is_large : typet -> bool

(* Returns true when the type has size >= Settings.tysize_MIN_Manual_Coll_Elim
   i.e. collisions can be eliminated on this type, but may require manual instructions. *)
val is_passwd : typet -> bool

(* Returns true when collisions should be eliminated on the considered term
   This includes two cases:
   a. the type has size >= Settings.tysize_MIN_Auto_Coll_Elim
   b. the type has size >= Settings.tysize_MIN_Manual_Coll_Elim
   and the elimination of collisions on this value has been explicitly 
   requested by the user (arguments of command "simplify") *)
val is_large_term : term -> bool

(* 2. Cardinality operations *) 

val card : typet -> probaf
val card_index : binder -> probaf

(* 3. Computation of probabilities of collisions *)

(* [is_small_enough_coll_elim (proba_l, proba)] tests if 
   [proba_l/proba] is considered small enough to eliminate collisions *)
val is_small_enough_coll_elim : probaf list * probaf -> bool

(* [collect_array_indexes accu t] adds in [accu] the array indices that
   occur in the term [t]. *)
val collect_array_indexes : binder list ref -> term -> unit

(* [add_elim_collisions b1 b2] add the probability of collision between
   [b1] and [b2]
   Returns true when the probability is considered small enough to
   eliminate collisions, and false otherwise. (In the latter case,
   the probability is obviously not counted, and the collisions must
   not be eliminated by the caller.) *)
val add_elim_collisions : binder -> binder -> bool

(* [add_proba_red t1 t2 proba tl] adds the probability change that
   happens when reducing [t1] into [t2] using a "collision" statement.
   [proba] is the probability formula in that collision statement.
   [tl] is the correspondence between the "new" in the collision statement
   and the "new" in the process. 
   Returns true when the probability is considered small enough to
   eliminate collisions, and false otherwise. (In the latter case,
   the probability is obviously not counted, and the collisions must
   not be eliminated by the caller.) *)
val add_proba_red : term -> term -> probaf -> (binder * term) list -> bool

(* [reset coll_elim internal_info g] initializes probability counting.
   [g] is the whole game. [coll_elim] is the list of arguments of the
   "simplify" commands, which determines on which data of type marked 
   [passwd] we will eliminate collisions. [internal_info] records
   already eliminated collisions. *)
val reset : string list -> simplify_internal_info_t -> game -> unit

(* [final_add_proba coll_list] computes the final probability of
   collisions. [coll_list] is a list of probabilities of complex collisions
   coming from dependency analsysis, to be added to other probabilities
   of collisions. *)
val final_add_proba : probaf list -> setf list

(* [final_internal_info()] returns the new value of the internal info
   that stores already eliminated collisions. *)
val final_internal_info : unit -> simplify_internal_info_t

(* [get_current_state()] returns the current state of eliminated collisions,
   to be restored by [restore_state internal_info] in case we want to undo
   the collision eliminations done between [get_current_state] and 
   [restore_state]. *)
val get_current_state : unit -> simplify_internal_info_t
val restore_state : simplify_internal_info_t -> unit
