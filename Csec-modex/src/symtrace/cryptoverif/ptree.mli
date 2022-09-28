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
(* Terms *)

type ident = string * Parsing_helper.extent

type term = PIdent of ident
          | PArray of ident * term_e list
          | PFunApp of ident * term_e list
	  | PInjEvent of ident * term_e list (* For queries only *)
	  | PTuple of term_e list
	  | PTestE of term_e * term_e * term_e
	  | PFindE of ((ident * ident) list * (ident * term_e list) list * term_e * term_e) list * term_e * ident list
	  | PLetE of pattern_e * term_e * term_e * term_e option
	  | PResE of ident * ident * term_e
	  | PEventE of ident
	  | PEqual of term_e * term_e
	  | PDiff of term_e * term_e
	  | POr of term_e * term_e
	  | PAnd of term_e * term_e

and term_e = term * Parsing_helper.extent

and pattern = PPatVar of ident * ident option(*optional type*)
  | PPatTuple of pattern_e list
  | PPatFunApp of ident * pattern_e list
  | PPatEqual of term_e

and pattern_e = pattern * Parsing_helper.extent

(* Processes *)

type process = PNil
             | PYield
	     | PPar of process_e * process_e
	     | PRepl of int(*occurrence id*) * ident option(*index*) * ident(*bound*) * process_e
 	     | PRestr of ident * ident(*type*) * process_e 
	     | PLetDef of ident
	     | PTest of term_e * process_e * process_e
	     | PFind of ((ident * ident) list * (ident * term_e list) list * term_e * process_e) list * process_e * ident list
	     | PEvent of term_e * process_e
             | PInput of term_e * pattern_e * process_e
             | POutput of term_e * term_e * process_e
	     | PLet of pattern_e * term_e * process_e * process_e
(*
	     | PPhase of int * process_e
*)

and process_e = process * Parsing_helper.extent

(* Logical statements (most often equations) *)

type statement = (ident * ident(*type*)) list * term_e

(* Equivalence statements *)

type action =
    PAFunApp of ident
  | PAPatFunApp of ident
  | PAReplIndex
  | PAArrayAccess of int
  | PACompare of ident
  | PAAppTuple of ident list
  | PAPatTuple of ident list
  | PAAnd
  | PAOr
  | PANew of ident
  | PANewChannel
  | PAIf
  | PAFind of int
  | PAOut of ident list * ident
  | PAIn of int

type probabilityf = 
    PAdd of probabilityf_e * probabilityf_e
  | PSub of probabilityf_e * probabilityf_e
  | PProd of probabilityf_e * probabilityf_e
  | PDiv of probabilityf_e * probabilityf_e
  | PMax of probabilityf_e list
  | PPIdent of ident
  | PPFun of ident * probabilityf_e list
  | PPZero
  | PCard of ident
  | PCount of ident
  | PCst of int
  | PFloatCst of float
  | PTime
  | PActTime of action * probabilityf_e list 
  | PMaxlength of term_e
  | PLength of ident * probabilityf_e list 
  | PLengthTuple of ident list * probabilityf_e list 

and probabilityf_e = probabilityf * Parsing_helper.extent

type ty =
    Tid of ident (* For normal types, designated by an ident *)
  | TBound of ident (* For interval types, designated by their bound *)

type fungroup =
    PReplRestr of (int(*occurrence*) * ident option(*index*) * ident(*repetitions*)) (*replication*) * 
	(ident * ident(*type*) * ident list(*options*)) list(*restrictions*) * fungroup list
  | PFun of ident * (ident * ty) list(*inputs*) * term_e * (int(*priority*) * ident list(*options*))

type eqmember = (fungroup * ident option * Parsing_helper.extent) list * Parsing_helper.extent

type eqstatement = eqmember * eqmember * probabilityf_e * (int * ident list(*options*))

(* Collisions *)

type collision = (ident * ident) list(*restrictions*) * (ident * ident) list(*forall*) * term_e * probabilityf_e * term_e



(* Values of parameters *)

type pval = 
    S of ident
  | I of int

(* Queries *)

type query = 
    PQSecret of ident
  | PQSecret1 of ident
  | PQEvent of (ident * ident(*type*)) list * term_e * term_e

(* Declarations *)

type decl = FunDecl of ident * ident list(*types*) * ident (*type*) * ident list(* options *)
          | EventDecl of ident * ident list(*types*) 
          | ParamDecl of ident * ident list(*options*)
	  | ProbabilityDecl of ident
	  | ConstDecl of ident * ident(*type*)
	  | ChannelDecl of ident
	  | TypeDecl of ident * ident list(*options*)
	  | Statement of statement
	  | EqStatement of eqstatement
	  | Collision of collision
	  | Setting of ident * pval
	  | PDef of ident * process_e
	  | Query of query list
	  | Define of ident * ident list * decl list
	  | Expand of ident * ident list
	  | Proofinfo of ident list list

type pall = decl list


