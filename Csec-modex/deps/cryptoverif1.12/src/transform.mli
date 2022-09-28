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

val queries : (query * game) list ref
val statements : statement list ref
val collisions : collision list ref
val equivs : equiv_nm list ref
val move_new_eq : (typet * equiv_nm) list ref

val collect_public_vars : unit -> unit
val occurs_in_queries : binder -> bool
val has_array_ref : binder -> bool
val event_occurs_in_queries : funsymb -> bool

(* [auto_sa_rename p] renames variables that are defined in find
   conditions, defined several times, and have no array references *)

val auto_sa_rename : inputprocess -> inputprocess * (binder * binder list) list

(* [expand_process p] expands the expressions If, Let, and Find 
   into processes If, Let, and Find; expressions If, Let, Find
   may be left in conditions of Find, when they cannot be expanded. *)

val expand_process : inputprocess -> inputprocess

(* [sa_rename b p] renames all occurrences of b with distinct names,
   expanding code with array references to b if necessary *)

val sa_rename : binder -> inputprocess -> inputprocess * (binder * binder list) list

(* These renaming functions are used by sa_rename, but also by the
   merge arrays transformation, which is its inverse and is defined
   in mergebranches.ml *)

val rename_binder : term list -> binder -> binder -> binderref -> binderref
val rename_term : term list -> binder -> binder -> term -> term
val rename_oprocess : term list -> binder -> binder -> process -> process

(* [remove_assignments rem_set p] replaces variables with their values
   in p, as designated by rem_set *)

val remove_assignments : rem_set -> inputprocess -> inputprocess * (binder * binder list) list

(* [move_new_let move_set p] moves new/lets downwards as much as possible *)

val move_new_let : move_set -> inputprocess -> inputprocess

(* [insert_event occ s g] replaces the subprocess at occurrence [occ]
   with the event [s] in game [g] *)

val insert_event : int -> string -> game -> setf list * game


(* Set when a game is modified *)
val changed : bool ref

(* Instructions are added in advise when an instruction I cannot be fully
   performed. The added instructions correspond to suggestions of instructions
   to apply before I so that instruction I can be better performed. *)

val advise : instruct list ref

