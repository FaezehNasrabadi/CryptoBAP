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
(* Typed front-end *)

(* Terms *)

type ident = Ptree.ident

type term = PIdent of ident
          | PFunApp of ident * term_e list
	  | PTuple of term_e list

and term_e = term * Parsing_helper.extent

(* Equational theory *)

type equation = term_e * term_e

(* Functions defined by reduction rules *)

type fundef =  (term_e * term_e) list

(* Nounif *)

type gformat =
    PFGIdent of ident
  | PFGFunApp of ident * gformat_e list
  | PFGTuple of gformat_e list
  | PFGName of ident * (ident * gformat_e) list
  | PFGAny of ident
  | PFGLet of ident * gformat_e * gformat_e

and gformat_e = gformat * Parsing_helper.extent

type nounif_t =
    BFLet of ident * gformat_e * nounif_t
  | BFNoUnif of (ident * gformat_e list * int) * int

(* Queries *)

type gterm = 
    PGIdent of ident
  | PGFunApp of ident * gterm_e list
  | PGPhase of ident * gterm_e list * int
  | PGTuple of gterm_e list
  | PGName of ident * (ident * gterm_e) list
  | PGLet of ident * gterm_e * gterm_e

and gterm_e = gterm * Parsing_helper.extent

type tquery = 
    PPutBegin of bool * ident list
	(* bool value: false -> non-inj event, true -> inj event *)
  | PRealQuery of gterm_e

(* Clauses *)

type tclause = 
    PClause of term_e * term_e 
  | PFact of term_e
  | PEquiv of term_e * term_e * bool

(* Processes *)

type pterm = 
    PPIdent of ident
  | PPFunApp of ident * pterm_e list
  | PPTuple of pterm_e list
  | PPRestr of ident * ident(*type*) * pterm_e
  | PPTest of pterm_e * pterm_e * pterm_e
  | PPLetIn of tpattern * pterm_e * pterm_e 
  | PPLet of tpattern * pterm_e * pterm_e * pterm_e 
  | PPLetFilter of (ident * ident(*type*)) list * pterm_e * pterm_e * pterm_e

and pterm_e = pterm * Parsing_helper.extent

and tpattern = 
    PPatVar of ident * ident option(*type*) 
  | PPatTuple of tpattern list
  | PPatFunApp of ident * tpattern list
  | PPatEqual of pterm_e

type tprocess = 
    PNil
  | PPar of tprocess * tprocess
  | PRepl of tprocess
  | PRestr of ident * ident(*type*) * tprocess 
  | PLetDef of ident * pterm_e list
  | PTest of pterm_e * tprocess * tprocess
  | PInput of pterm_e * tpattern * tprocess
  | POutput of pterm_e * pterm_e * tprocess
  | PLet of tpattern * pterm_e * tprocess * tprocess
  | PLetFilter of (ident * ident(*type*)) list * pterm_e * tprocess * tprocess
  | PEvent of ident * pterm_e list * tprocess
  | PPhase of int * tprocess
  | PInsert of ident * pterm_e list * tprocess
  | PGet of ident * tpattern list * pterm_e * tprocess

(* Declarations *)

type envdecl = (ident(*variable*) * ident(*type*)) list

type tdecl = 
    TTypeDecl of ident (* type declaration *)
  | TFunDecl of ident * ident list(*argument types*) * ident(*result type*) * ident list(*options*)
  | TEventDecl of ident * ident list(*argument types*)
  | TConstDecl of ident * ident(*type*) * ident list(*options*)
  | TReduc of (envdecl * term_e * term_e) list * ident list(*options*)
  | TEquation of envdecl * term_e * term_e
  | TPredDecl of ident * ident list(*argument types*) * ident list(*options*)
  | TTableDecl of ident * ident list(*argument types*)
  | TSet of ident * Ptree.pval
  | TPDef of ident * envdecl * tprocess
  | TQuery of envdecl * tquery list
  | TNoninterf of envdecl * (ident * term_e list option) list
  | TWeaksecret of ident
  | TNoUnif of envdecl * nounif_t 
  | TNot of envdecl * gterm_e
  | TElimtrue of envdecl * term_e
  | TFree of ident * ident(*type*) * ident list(*options*)
  | TClauses of (envdecl * tclause) list
  | TDefine of ident * ident list * tdecl list
  | TExpand of ident * ident list
  | TLetFun of ident * envdecl * pterm_e


