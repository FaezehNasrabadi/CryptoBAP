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

type frontend =
    Channels
  | Oracles

val front_end : frontend ref

val lib_name : string ref

val diff_constants : bool ref
val constants_not_tuple : bool ref 

val expand_letxy : bool ref

val minimal_simplifications : bool ref
val merge_branches : bool ref
val merge_arrays : bool ref
val unique_branch : bool ref

val auto_sa_rename : bool ref

val auto_move : bool ref

val optimize_let_vars : bool ref
val ignore_small_times : int ref
val interactive_mode : bool ref
val auto_advice : bool ref
val no_advice_crypto : bool ref
val no_advice_simplify : bool ref

val backtrack_on_crypto : bool ref
val simplify_after_sarename : bool ref


val max_iter_simplif : int ref
val max_iter_removeuselessassign : int ref

val detect_incompatible_defined_cond : bool ref

val do_set : string -> Ptree.pval -> unit

(* Parameter sizes *)
val psize_NONINTERACTIVE : int
val psize_PASSIVE : int
val psize_DEFAULT : int

(* Type sizes *)
val tysize_LARGE : int
val tysize_PASSWORD : int
val tysize_SMALL : int

val tysize_MIN_Manual_Coll_Elim : int ref
val tysize_MIN_Auto_Coll_Elim : int ref
(* Determines the probabilities that are considered small enough to 
   eliminate collisions. It consists of a list of probability descriptions
   of the form ([(psize1, n1); ...; (psizek,nk)], tsize) 
   which represent probabilities of the form
   constant * (parameter of size <= psize1)^n1 * ... * 
   (parameter of size <= psizek)^nk / (type of size >= tsize) *) 
val allowed_collisions : ((int * int) list * int) list ref

(* Similar to allowed_collisions but for "collision" statements:
   It consists of a list of probability descriptions
   of the form [(psize1, n1); ...; (psizek,nk)] 
   which represent probabilities of the form
   constant * (parameter of size <= psize1)^n1 * ... * 
   (parameter of size <= psizek)^nk. *)
val allowed_collisions_collision : (int * int) list list ref

val tyopt_CHOOSABLE : int
val tyopt_BOUNDED : int

val fopt_COMPOS : int
val fopt_DECOMPOS : int
val fopt_UNIFORM : int
val fopt_COMMUT : int

val tex_output : string ref

val t_bitstring : typet
val t_bitstringbot : typet
val t_bool : typet
(*For precise computation of the runtime only*)
val t_unit : typet
(* For events in terms; they have a type compatible with any type*)
val t_any : typet

val c_true : funsymb
val c_false : funsymb

val f_comp : funcats -> typet -> typet -> funsymb
val f_or : funsymb
val f_and : funsymb
val f_not : funsymb

val get_tuple_fun : typet list -> funsymb

(*For precise computation of the runtime only*)
val t_interv : typet
val f_plus : funsymb
val f_mul : funsymb
val get_inverse : funsymb -> int -> funsymb
