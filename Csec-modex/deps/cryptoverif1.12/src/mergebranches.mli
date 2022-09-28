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

(* Test equality of processes modulo renaming of variables.
   Used to simplify tests and find: when all branches are equal,
   the test/find can be removed.
   There is room for more general equivalences between processes,
   but this is already a first step.
 *)

val equal_oprocess :
    simp_facts -> process -> process -> bool
val equal_term_with_find :
    simp_facts -> term -> term -> bool
val can_merge_all_branches_findE :
    term -> simp_facts -> (binder list * binderref list * term * term) list -> term -> bool 
val can_merge_one_branch_findE :
    term -> simp_facts -> (binder list * binderref list * term * term) -> term -> bool 
val can_merge_all_branches_find :
    process -> simp_facts -> (binder list * binderref list * term * process) list -> process -> bool 
val can_merge_one_branch_find :
    process -> simp_facts -> (binder list * binderref list * term * process) -> process -> bool 


(* [merge_arrays simplify_internal_info bll mode g] merges arrays 
   contained in [bll] in game [g]. [bll] is a list of list of variables, say
   bll = [[b11, ..., b1n],[b21, ..., b2n], ..., [bk1, ..., bkn]]
   Each list [bi1,...,bin] corresponds to variables to merge together; they
   are merged to bi1. See comments in mergebranches.ml for more details. *)

val merge_arrays : simplify_internal_info_t -> (binder * Parsing_helper.extent) list list -> merge_mode -> game -> 
  game * setf list * simplify_internal_info_t * ins_updater

(* [merge_branches simplify_internal_info g] merges branches of find
   as much as possible in game [g] *)

val merge_branches : simplify_internal_info_t -> game -> 
  game * setf list * simplify_internal_info_t * ins_updater
