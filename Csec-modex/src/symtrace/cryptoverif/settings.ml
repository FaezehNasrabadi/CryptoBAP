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
open Ptree
open Types

type frontend =
    Channels
  | Oracles

let front_end = ref Channels

let lib_name = ref "default"

let diff_constants = ref true
let constants_not_tuple = ref true

let expand_letxy = ref true

let minimal_simplifications = ref true
let merge_branches = ref true
let merge_arrays = ref false
let unique_branch = ref true

let auto_sa_rename = ref true

let auto_move = ref true

let optimize_let_vars = ref false

let ignore_small_times = ref 3

let interactive_mode = ref false

let auto_advice = ref true
let no_advice_crypto = ref false
let no_advice_simplify = ref false

let backtrack_on_crypto = ref false

let simplify_after_sarename = ref true

let max_iter_simplif = ref 2
let max_iter_removeuselessassign = ref 10

let detect_incompatible_defined_cond = ref true

let do_set p v =
  match (p,v) with
    "diffConstants", S ("true",_) -> diff_constants := true
  | "diffConstants", S ("false",_) -> diff_constants := false
  | "constantsNotTuple", S ("true",_) -> constants_not_tuple := true
  | "constantsNotTuple", S ("false",_) -> constants_not_tuple := false
  | "expandAssignXY", S ("true",_) -> expand_letxy := true
  | "expandAssignXY", S ("false",_) -> expand_letxy := false
  | "minimalSimplifications", S ("true",_) -> minimal_simplifications := true
  | "minimalSimplifications", S ("false",_) -> minimal_simplifications := false
  | "mergeBranches", S ("true",_) -> merge_branches := true
  | "mergeBranches", S ("false",_) -> merge_branches := false
  | "mergeArrays", S ("true",_) -> merge_arrays := true
  | "mergeArrays", S ("false",_) -> merge_arrays := false
  | "uniqueBranch", S ("true",_) -> unique_branch := true
  | "uniqueBranch", S ("false",_) -> unique_branch := false
  | "autoSARename", S ("true",_) -> auto_sa_rename := true
  | "autoSARename", S ("false",_) -> auto_sa_rename := false
  | "autoMove", S ("true",_) -> auto_move := true
  | "autoMove", S ("false",_) -> auto_move := false
  | "optimizeVars", S ("true",_) -> optimize_let_vars := true
  | "optimizeVars", S ("false",_) -> optimize_let_vars := false
  | "interactiveMode", S ("true",_) -> interactive_mode := true
  | "interactiveMode", S ("false",_) -> interactive_mode := false
  | "autoAdvice", S ("true",_) -> auto_advice := true
  | "autoAdvice", S ("false",_) -> auto_advice := false
  | "noAdviceCrypto", S ("true",_) -> no_advice_crypto := true
  | "noAdviceCrypto", S ("false",_) -> no_advice_crypto := false
  | "noAdviceSimplify", S ("true",_) -> no_advice_simplify := true
  | "noAdviceSimplify", S ("false",_) -> no_advice_simplify := false
  | "backtrackOnCrypto", S ("true",_) -> backtrack_on_crypto := true
  | "backtrackOnCrypto", S ("false",_) -> backtrack_on_crypto := false
  | "simplifyAfterSARename", S ("true",_) -> simplify_after_sarename := true
  | "simplifyAfterSARename", S ("false",_) -> simplify_after_sarename := false
  | "detectIncompatibleDefined", S ("true",_) -> detect_incompatible_defined_cond := true
  | "detectIncompatibleDefined", S ("false",_) -> detect_incompatible_defined_cond := false
  | "ignoreSmallTimes", I n -> ignore_small_times := n
  | "maxIterSimplif", I n -> max_iter_simplif := n
  | "maxIterRemoveUselessAssign", I n -> max_iter_removeuselessassign := n
  | _ -> raise Not_found

let psize_NONINTERACTIVE = 20
let psize_PASSIVE = 10
let psize_DEFAULT = 0

let tysize_LARGE = 20
let tysize_PASSWORD = 10
let tysize_SMALL = 0

let tysize_MIN_Manual_Coll_Elim = ref 5
let tysize_MIN_Auto_Coll_Elim = ref 15
(* Determines the probabilities that are considered small enough to 
   eliminate collisions. It consists of a list of probability descriptions
   of the form ([(psize1, n1); ...; (psizek,nk)], tsize) 
   which represent probabilities of the form
   constant * (parameter of size <= psize1)^n1 * ... * 
   (parameter of size <= psizek)^nk / (type of size >= tsize) 

   The default value allows: anything/large type and 
   default parameter/password *) 
let allowed_collisions = ref [ ([max_int, max_int], tysize_LARGE); 
                               ([psize_DEFAULT, 1], tysize_PASSWORD) ]

(* Similar to allowed_collisions but for "collision" statements:
   It consists of a list of probability descriptions
   of the form [(psize1, n1); ...; (psizek,nk)] 
   which represent probabilities of the form
   constant * (parameter of size <= psize1)^n1 * ... * 
   (parameter of size <= psizek)^nk.

   The default value allows any probability formula *)
let allowed_collisions_collision = ref [ [max_int, max_int] ]

let tyopt_CHOOSABLE = 2
let tyopt_BOUNDED = 4

let fopt_COMPOS = 1
let fopt_DECOMPOS = 2
let fopt_UNIFORM = 8
let fopt_COMMUT = 4

let tex_output = ref ""

(* Types and constants should be added to the initial environment,
as well as f_not *)
(* Types *)

let t_bitstring = { tname = "bitstring";
		    tcat = BitString;
		    toptions = 0;
		    tsize = tysize_LARGE }

let t_bitstringbot = { tname = "bitstringbot";
		       tcat = BitString;
		       toptions = 0;
		       tsize = tysize_LARGE }

let t_bool = { tname = "bool";
	       tcat = BitString;
	       toptions = tyopt_CHOOSABLE + tyopt_BOUNDED;
	       tsize = 0 }

(* For precise computation of the runtime only*)
let t_unit = { tname = "unit";
	       tcat = BitString;
	       toptions = tyopt_BOUNDED;
	       tsize = 0}

(* For events in terms; they have a type compatible with any type*)
let t_any = { tname = "any";
	      tcat = BitString;
	      toptions = 0;
	      tsize = 0 }

(* Constants *)

let c_true = { f_name = "true";
	       f_type = [],t_bool;
	       f_cat = Std;
	       f_options = 0 }

let c_false = { f_name = "false";
	       f_type = [],t_bool;
	       f_cat = Std;
	       f_options = 0 }

(* Functions *)

let f_and = { f_name = "&&";
	      f_type = [t_bool; t_bool], t_bool;
	      f_cat = And;
	      f_options = fopt_COMMUT }

let f_or = { f_name = "||";
	     f_type = [t_bool; t_bool], t_bool;
	     f_cat = Or;
	     f_options = fopt_COMMUT }

module HashedType =
  struct
    type t = Types.funcats * Types.typet
    let equal (cat1, t1) (cat2, t2) = (cat1 == cat2) && (t1 == t2)
    let hash = Hashtbl.hash
  end

module TypeHashtbl = Hashtbl.Make(HashedType)

let comp_funs = TypeHashtbl.create 7

let f_comp cat t t2 =
  if t != t2 then
    Parsing_helper.internal_error "Comparisons for compatible types only";
  try 
    TypeHashtbl.find comp_funs (cat,t)
  with Not_found ->
    let r = { f_name = 
	      begin
		match cat with
		  Equal -> "="
		| Diff -> "<>"
		| LetEqual -> ">>="
		| _ -> Parsing_helper.internal_error "no comparison for this category"
	      end;
	      f_type = [t; t], t_bool;
	      f_cat = cat;
	      f_options = if cat == Equal || cat == Diff then fopt_COMMUT else 0 }
    in
    TypeHashtbl.add comp_funs (cat,t) r;
    r

let f_not = { f_name = "not";
	      f_type = [t_bool], t_bool;
	      f_cat = Std;
	      f_options = 0 }


(* Create tuple function of given type *)

module HashedTypeList =
  struct
    type t = Types.typet list
    let equal x1 x2 = (List.length x1 == List.length x2) && (List.for_all2 (==) x1 x2)
    let hash = Hashtbl.hash
  end

module TypeListHashtbl = Hashtbl.Make(HashedTypeList)

let tuple_fun_table = TypeListHashtbl.create 7

let get_tuple_fun tl =
  try 
    TypeListHashtbl.find tuple_fun_table tl
  with Not_found ->
    let f = { f_name = "";
	      f_cat = Tuple;
	      f_type = tl, t_bitstring;
	      f_options = fopt_COMPOS }
    in
    TypeListHashtbl.add tuple_fun_table tl f;
    f

(*For precise computation of the runtime only*)

let t_interv = { tname ="[1,*]";
		 tcat = Interv { pname = "N*"; psize = 0 };
		 toptions = tyopt_BOUNDED;
	         tsize = 0 }

let f_plus = { f_name = "+";
	       f_type = [t_interv; t_interv],t_interv;
	       f_cat = Std;
	       f_options = fopt_COMMUT }

let f_mul = { f_name = "*";
	      f_type = [t_interv; t_interv],t_interv;
	      f_cat = Std;
	      f_options = fopt_COMMUT }

module HashedFunInt =
  struct
    type t = funsymb * int
    let equal (x1,y1) (x2,y2) = (x1 == x2) && (y1 == y2)
    let hash = Hashtbl.hash
  end

module FunIntHashtbl = Hashtbl.Make(HashedFunInt)

let inverse_table = FunIntHashtbl.create 7

let get_inverse f n = 
  if f.f_options land fopt_COMPOS == 0 then
    Parsing_helper.internal_error "Can get inverse only for COMPOS functions";
  if (n < 1) || (n > (List.length (fst f.f_type))) then
    Parsing_helper.internal_error "Arity error in get_inverse";
  try
    FunIntHashtbl.find inverse_table (f,n)
  with Not_found ->
    let finv = { f_name = f.f_name ^ "^-1_" ^ (string_of_int n);
		 f_type = [snd f.f_type], (List.nth (fst f.f_type) (n-1));
		 f_cat = Std;
		 f_options = fopt_DECOMPOS }
    in
    FunIntHashtbl.add inverse_table (f,n) finv;
    finv

