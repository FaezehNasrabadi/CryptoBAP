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
(* Types module declares types of the abstract syntax
   tree and of sets of messages.
   There are recursive dependencies between these types,
   that is why they are included in the same module
*)

open Stringmap

type occurrence = int

(* Types *)

type typet = { tname : string }

(* Information for predicates. The integer argument corresponds
   to the phase of the predicate *)
type info = 
    Attacker of int * typet
  | Mess of int * typet
  | InputP of int 
  | OutputP of int
  | AttackerBin of int * typet
  | MessBin of int * typet
  | InputPBin of int
  | OutputPBin of int
  | AttackerGuess of typet
  | Compromise of typet
  | Equal of typet
  | Table of int
  | TableBin of int
  | PolymPred of string * int(*value of p_prop*) * typet list

type predicate = { p_name: string;
                   p_type: typet list;
		   mutable p_prop: int;
		   mutable p_info: info list }

type binder = { sname : string;
                vname : int;
		btype : typet;
		mutable link : linktype }

(* Environment elements; environments are needed for terms in queries
   that cannot be expanded before process translation, see link PGTLink
   below *)

and envElement = 
    EFun of funsymb
  | EVar of binder
  | EName of funsymb
  | EPred of predicate
  | EEvent of funsymb
  | EType of typet
  | ETable of funsymb
  | ELetFun of binder list * (process list -> process) * term list * typet

(* Processes: patterns *)

and pattern = 
    PatVar of binder
  | PatTuple of funsymb * pattern list
  | PatEqual of term

(* Processes themselves *)

and process = 
    Nil
  | Par of process * process
  | Repl of process * occurrence
  | Restr of funsymb * process 
  | Test of term * term * process * process * occurrence
  | Input of term * pattern * process * occurrence
  | Output of term * term * process * occurrence
  | Let of pattern * term * process * process * occurrence
  | LetFilter of binder list * fact * process * process * occurrence
  | Event of term  * process * occurrence
  | Insert of term * process * occurrence
  | Get of pattern * term * process * occurrence
  | Phase of int * process

and linktype = 
    NoLink
  | VLink of binder
  | TLink of term
  | TLink2 of term (* used only in reduction.ml *)
  | FLink of format (* used only in syntax.ml *)
  | PGLink of Piptree.gterm_e (* used only in pisyntax.ml *)
  | PGTLink of envElement StringMap.t * Pitptree.gterm_e (* used only in pitsyntax.ml *)

and name_info = { mutable prev_inputs : term option;
		  mutable prev_inputs_meaning : string list }

and funcats = 
    Red of (term list * term) list
  | Eq of (term list * term) list
  | Tuple 
  | Name of name_info
  | SpecVar of binder
  | Syntactic of funsymb	
  | General_var
  | Choice

and funsymb = { f_name : string;
		mutable f_type : typet list * typet; (* type of the arguments, type of the result *)
                mutable f_cat : funcats;
		f_initial_cat : funcats; (* Used to memorize f_cat before closing using the
                                            equational theory. The initial f_cat is used in reduction.ml,
					    and also in check_several_types *)
	    	f_private : bool; (* true when the function cannot be applied by the adversary *)
		f_options : int
              }

and term = 
    Var of binder
  | FunApp of funsymb * term list

(* Format, to represent facts with jokers *)

and format = 
    FVar of binder
  | FFunApp of funsymb * format list
  | FAny of binder

and fact_format = predicate * format list

and fact = 
    Pred of predicate * term list
  | Out of term * (binder * term) list

(* The following constraints are simple constraints.
   A list of simple constraints is a constraint, and represents the OR
   of the simple constraints.
   A list of constraints represents the AND of the simple constraints.
   TRUE can be represented by the list of constraints [].
   FALSE can be represented by any list of constraints that contains [],
   but these representations of FALSE are not used in the program:
   a false constraint leads to the immediate removal of the rule.
*)

type constraints = Neq of term * term

(* Rule descriptions *)

type funspec =
    Func of funsymb
  | Proj of funsymb * int  (* For projections corresponding to data constructors *)

type onestatus =
    No | NonInj | Inj

type hypspec =
    ReplTag of occurrence * int(*Number of elements of name_params after it*)
  | InputTag of occurrence
  | BeginEvent of occurrence
  | BeginFact
  | LetFilterTag of occurrence
  | LetFilterFact
  | OutputTag of occurrence
  | TestTag of occurrence
  | LetTag of occurrence
  | TestUnifTag of occurrence
  | TestUnifTag2 of occurrence
  | InputPTag of occurrence
  | OutputPTag of occurrence
  | InsertTag of occurrence
  | GetTag of occurrence

type label =
    ProcessRule of hypspec list * term list 
  | ProcessRule2 of hypspec list * term list * term list 
  | Apply of funspec * predicate
  | TestApply of funspec * predicate
  | TestEq of predicate
  | LblEquiv
  | LblClause
  | LblEq
  | Rl of predicate * predicate
  | Rs of predicate * predicate
  | Ri of predicate * predicate
  | Ro of predicate * predicate
  | TestComm of predicate * predicate
  | InputSecr of predicate
  | OutputSecr of predicate
  | WeakSecr
  | Rn of predicate
  | Init
  | PhaseChange
  | TblPhaseChange
  | LblComp
  | LblNone
  | Elem of predicate list * predicate
  | TestUnif

(* Rules *)

type history = 
    Rule of int * label * fact list * fact * constraints list list
  | Removed of int * int * history
  | Any of int * history
  | Empty of fact
  | HEquation of int * fact * fact * history
  | Resolution of history * int * history

type reduction = fact list * fact * history * constraints list list

(* Equational theory *)

type equation = term * term

(* Proof history *)

type fact_tree_desc =
    FHAny
  | FEmpty
  | FRemovedWithProof of fact_tree
  | FRule of int * label * constraints list list * fact_tree list
  | FEquation of fact_tree

and fact_tree = 
    { mutable desc: fact_tree_desc;
      mutable thefact: fact;
    } 

