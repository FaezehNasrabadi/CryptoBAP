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
(* Types module declares types of the abstract syntax
   tree and of sets of messages.
   There are recursive dependencies between these types,
   that is why they are included in the same module
*)

(* integer parameter *)

type param = { pname : string;
	       psize : int }

(* probability *)

type proba = { prname : string }

(* channel *)

type channel = { cname : string }

(* types *)

type typet = { tname : string;
	       tcat : ttcat;
	       toptions : int;
	       tsize : int }

and ttcat = 
    BitString
  | Interv of param

type find_info =
    Nothing

(* terms *)

type binder = { sname : string;
                vname : int;
		btype : typet; 
		args_at_creation : term list;
		mutable def : def_node list;
		mutable compatible : binderset;
		mutable link : linktype;
		mutable count_def : int;
	        mutable root_def_array_ref : bool;
	        mutable root_def_std_ref : bool;
	        mutable array_ref : bool;
                mutable std_ref : bool;
		mutable count_array_ref : int;
		mutable count_exclude_array_ref : int;
	        mutable priority : int }

and binderset = (* set of binders represented by a hash table *)
  { mutable nelem : int;               
    mutable table : binder list array } 

and binderref = binder * term list

(* Definition graph *)
and def_node = { above_node : def_node;
		 binders : binder list;
		 true_facts_at_def : term list;
		 def_vars_at_def : binderref list;
		 elsefind_facts_at_def : elsefind_fact list;
		 mutable future_binders : binder list;
		 mutable future_true_facts : term list;
		 mutable future_def_vars : binderref list;
	         definition : def_type }

and def_type = 
    DProcess of process
  | DInputProcess of inputprocess
  | DTerm of term
  | DFunRestr
  | DFunRepl
  | DFunArgs
  | DNone

and linktype = 
    NoLink
  | TLink of term

and funcats = 
    Std
  | Tuple 
  | Equal
  | LetEqual (* Special equality symbol for let assignments *)
  | Diff
  | Or
  | And
  | Event (* Function symbols for events *)

and funsymb = { f_name : string;
		f_type : typet list * typet; (* argument and result types *)
                f_cat : funcats;
	    	f_options : int (* options *)
              }

and term_desc = 
    Var of binder * term list (* array access *)
  | FunApp of funsymb * term list
  | TestE of term * term * term
  | FindE of (binder list * binderref list(*guaranteed defined array references*) * term * term) list * term * find_info
  | LetE of pattern * term * term * term option
  | ResE of binder * term
  | EventE of term

and term = { t_desc : term_desc;
	     t_type : typet;
	     t_occ : int;
	     t_loc : Parsing_helper.extent;
	     mutable t_facts : fact_info }

and fact_info = (term list * binderref list * def_node) option

and elsefind_fact = binder list * binderref list * term

(* Processes *)

and pattern = 
    PatVar of binder
  | PatTuple of funsymb * pattern list
  | PatEqual of term

and inputprocess_desc = 
    Nil
  | Par of inputprocess * inputprocess
  | Repl of binder * inputprocess
  | Input of (channel * term list) * pattern * process

and inputprocess =
    { i_desc : inputprocess_desc;
      i_occ : int;
      mutable i_facts : fact_info }

and process_desc =  
    Yield
  | Restr of binder * process 
  | Test of term * process * process
  | Find of (binder list * binderref list(*guaranteed defined array references*) * term * process) list * process * find_info
  | Output of (channel * term list) * term * inputprocess
  | Let of pattern * term * process * process
  | EventP of term * process

and process =
    { p_desc : process_desc;
      p_occ : int;
      mutable p_facts : fact_info }

(* Equivalences *)

type action =
    AFunApp of funsymb         (* Application of f *)
  | APatFunApp of funsymb      (* Pattern matching with f *)
  | AReplIndex                 (* Reading a replication index *)
  | AArrayAccess of int        (* Array access with n indexes *)
  | ANew of typet              (* Random number generation of type t *)
  | ANewChannel                (* Create a private channel *)
  | AIf                        (* Test *)
  | AFind of int               (* Find: one choice with n indexes to choose *)
  | AOut of typet list * typet (* Output with channel indexes of types tl and output bitstring of type t *)
  | AIn of int                 (* Record input with n channel indexes in input list *)

type game = 
    { mutable proc : inputprocess;
      mutable game_number : int }

type probaf = 
    Proba of proba * probaf list
  | Count of param
  | OCount of channel
  | Add of probaf * probaf
  | Mul of probaf * probaf
  | Cst of float
  | Zero
  | Sub of probaf * probaf
  | Div of probaf * probaf
  | Max of probaf list
  | Card of typet
  | AttTime (* Time of the attacker *)
  | Time of game * probaf (* Time i = runtime of game number i *)
  | ActTime of action * probaf list 
  | Maxlength of game * term
  | TypeMaxlength of typet
  | Length of funsymb * probaf list

type mode =
    ExistEquiv | AllEquiv

type options =
    StdOpt | RequiredOpt

type restropt =
    NoOpt | Unchanged | DontKnow

type fungroup =
    ReplRestr of binder(*replication*) * (binder * restropt) list(*restrictions*) * fungroup list
  | Fun of channel * binder list(*inputs*) * term * (int(*priority*) * options)

type eqmember = 
    (fungroup * mode) list

type set_proba_rec = { mutable set_name : string; proba : probaf } 

type setf =
    SetProba of set_proba_rec
  | SetEvent of funsymb * game

type eqopt =
    StdEqopt | ManualEqopt | PrioEqopt of int

type eqopt2 =
    Decisional | Computational

type equiv = eqmember * eqmember * setf list * eqopt * eqopt2

type def_check = term list

type equiv_nm = equiv * (binder * binder * def_check) list 
        (* equivalence with name mapping *)

(* Logical statements *)

type statement = binder list * term

(* Collision statements *)

type collision = binder list(*restrictions*) * binder list(*forall*) *
      term * probaf * term

(* Queries *)

type qterm =
    QEvent of bool(*true when injective*) * term
  | QTerm of term
  | QAnd of qterm * qterm
  | QOr of qterm * qterm

type query = 
    QSecret1 of binder
  | QSecret of binder
  | QEventQ of (bool(*true when injective*) * term) list * qterm
  | AbsentQuery
  
(* Instructions for modifying games *)

(* For removal of assignments *)
type rem_set =
    All
  | OneBinder of binder
  | SubstOneBinder of binder * int(*occurrence*) 
  | Minimal

type move_set =
    MAll
  | MNoArrayRef
  | MLet
  | MNew
  | MNewNoArrayRef
  | MOneBinder of binder

type merge_mode =
    MNoBranchVar
  | MCreateBranchVar
  | MCreateBranchVarAtProc of process list * binder list
  | MCreateBranchVarAtTerm of term list * binder list

type instruct =
    ExpandIfFind
  | Simplify of string list(*occurrences, variables, or types for collision elimination of password types*)
  | RemoveAssign of rem_set
  | SArenaming of binder
  | MoveNewLet of move_set
  | CryptoTransf of equiv_nm * binder list
  | InsertEvent of string(*event name*) * int(*occurrence of insertion*) 
  | InsertInstruct of string(*instruction*) * Parsing_helper.extent * int (*occurrence of insertion*) * Parsing_helper.extent
  | ReplaceTerm of string(*term*) * Parsing_helper.extent * int (*occurrence of replacement*) * Parsing_helper.extent
  | MergeArrays of (binder * Parsing_helper.extent) list list * merge_mode
  | MergeBranches
  | Proof of ((query * game) * setf list) list

type ins_updater = (instruct -> instruct list) option

(* State. Used to remember a sequence of game modifications *)

type simplify_internal_info_t = 
    (binder * binder) list * (term * term * probaf * (binder * term) list) list

type state =
    { game : game;
      simplify_internal_info : simplify_internal_info_t;
      prev_state : (instruct * setf list * state) option }

(* Result of a cryptographic transformation *)
type trans_res =
    TSuccess of setf list * game * simplify_internal_info_t
  | TFailure of (equiv_nm * binder list * instruct list) list

(* Environment.
   May contain function symbols, variables, ...
   Is a map from strings to the description of the ident *)

type env_entry =
    EFunc of funsymb
  | EEvent of funsymb
  | EParam of param
  | EProba of proba
  | EType of typet
  | EVar of binder
  | EChannel of channel
  | EProcess of Ptree.process_e

type simp_facts = term list * term list * elsefind_fact list
type dep_anal = simp_facts -> term -> term -> bool

exception NoMatch
exception Contradiction
