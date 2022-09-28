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

open Types

(* The type of processes has been moved to the module types.mli
   because it is needed in the environment values for letfun, and the
   environments are needed for terms in queries that cannot be
   expanded before process translation *)

(* Correspondence queries *)

type event =
    QSEvent of bool (* true when injective *) * term
  | QFact of predicate * term list
  | QNeq of term * term
  | QEq of term * term

type realquery = Before of event * hypelem list list

and hypelem =
    QEvent of event
  | NestedQuery of realquery

type query = 
    PutBegin of bool (* true when injective *) * funsymb list
  | RealQuery of realquery

type eventstatus =
    { mutable end_status : onestatus;
      mutable begin_status : onestatus }

(* Equivalence queries *)

type eq_query =
    ChoiceQuery 
  | NonInterfQuery of (Types.funsymb * Types.term list option) list
  | WeakSecret of Types.funsymb

(* Types of reduction steps, for trace reconstruction *)

type reduc_type =
  | RNil of int
  | RPar of int 
  | RRepl of int * int
  | RRestr of int * funsymb * term
  | RLet1 of int * pattern * term 
  | RLet2 of int * pattern * term
  | RInput of int * term * pattern * term
  | ROutput1 of int * term * term 
  | ROutput2 of int * term * term
  | ROutput3 of int * term * term
  | RTest1 of int * term * term 
  | RTest2 of int * term * term
  | RTest3 of int * term * term
  | RBegin1 of int * term
  | RBegin2 of int * term
  | REnd of int * term
  | RPhase of int
  | RLetFilter1 of int * binder list * fact 
  | RLetFilter2 of int * binder list * fact 
  | RLetFilter3 of int * binder list * fact 
  | RIO of int * term * pattern * int * term * term
  | RIO2 of int * term * pattern * int * term * term
  | RInsert1 of int * term 
  | RInsert2 of int * term
  | RGet of int * pattern * term * term
  | RInit

