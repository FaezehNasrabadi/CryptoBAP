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

val display_occurrences : bool ref
val display_arrays : bool ref
val display_list : ('a -> unit) -> 'a list -> unit

val ends_with_underscore_number : string -> bool
val binder_to_string : binder -> string
val display_binder : binder -> unit
val display_var : term list -> binder -> term list -> unit
val display_term : term list -> term -> unit
val display_statement : statement -> unit
val display_pattern : term list -> pattern -> unit
val display_proba : int -> probaf -> unit
val display_set : setf list -> unit
val display_equiv : equiv_nm -> unit
val display_oprocess : term list -> string -> process -> unit
val display_process : inputprocess -> unit

val display_bl_assoc : binder list -> unit
val display_query : query * game -> unit
val display_instruct : instruct -> unit

(* The next functions are made public so that displaytex can call them *)

val proba_table : ((query * game) * (setf list * state)) list ref

exception NotBoundEvent of funsymb * game

(* [compute_proba q p s] returns a computation of probabilities 
of query [q] in state [s]. [p] is the probability of [q] in the game
that proves it (corresponding to the last elimination of collisions).
When the obtained probability refers to the probability of executing
event [e] in game [g], and that probability has not been bounded, raises
[NotBoundEvent(e,g)]. The returned probability is guaranteed not to
contain [SetEvent]. *)

val compute_proba : query * game -> setf list -> state -> setf list

(* [proba_since g s] returns the probability of distinguishing game [g]
from the game corresponding to state [s] *)

val proba_since : game -> state -> setf list

(* [proba_from_set q p] converts the probability [p] represented as
a [setf list] into a probability represented as a [probaf].
[p] must not contain [SetEvent]. *)

val proba_from_set : setf list -> probaf
val proba_from_set_may_double : query * game -> setf list -> probaf


val display_state : state -> unit

