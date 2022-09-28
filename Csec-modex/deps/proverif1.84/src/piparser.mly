%{
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
%}
%{

open Parsing_helper
open Ptree
open Piptree
exception Syntax

%}

%token CHOICE
%token STAR
%token COMMA
%token LPAREN
%token RPAREN
%token LBRACKET
%token RBRACKET
%token BAR
%token SEMI
%token NEW
%token OUT
%token IN
%token <Piptree.ident> IDENT
%token <int> INT
%token REPL
%token IF
%token THEN
%token ELSE
%token EQUAL
%token FUN
%token EQUATION
%token REDUCTION
%token PREDICATE
%token PROCESS
%token SLASH
%token DOT
%token EOF
%token LET
%token QUERY
%token BEFORE
%token PUTBEGIN
%token NONINTERF
%token EVENT
%token NOT
%token ELIMTRUE
%token FREE
%token SUCHTHAT
%token CLAUSES
%token RED
%token EQUIV
%token EQUIVEQ
%token WEDGE
%token DIFF
%token COLON
%token NOUNIF
%token PHASE
%token AMONG
%token WEAKSECRET

/* Untyped front-end only */
%token DATA
%token PARAM
%token PRIVATE


/* Precedence (from low to high) and associativities */
%right BAR 
%right WEDGE 

%start all
%type <Piptree.decl list> all

%%


/*** Untyped front-end ***/


all:
	privateopt FUN IDENT SLASH INT DOT all
	{ (FunDecl($3, $5, $1)) :: $7 }
|       DATA IDENT SLASH INT DOT all
	{ (DataFunDecl($2, $4)) :: $6 }
|	EQUATION term EQUAL term DOT all
	{ (Equation($2, $4)) :: $6 }
|	privateopt REDUCTION reduc all
	{ (Reduc($3,$1)) :: $4 }
|       PREDICATE IDENT SLASH INT neidentseq DOT all
        { (PredDecl($2, $4, $5)) :: $7 }
|       PREDICATE IDENT SLASH INT DOT all
        { (PredDecl($2, $4, [])) :: $6 }
|	LET IDENT EQUAL process DOT all
	{ (PDef($2,$4)) :: $6 }
|       NOUNIF gfactformat optint foptbindingseq DOT all
        { (NoUnif ($2,$3,$4)) :: $6 } 
|       PARAM IDENT EQUAL IDENT DOT all
        { (Param($2,S $4)) :: $6 }
|       PARAM IDENT EQUAL INT DOT all
        { (Param($2,I $4)) :: $6 }
|       QUERY queryseq DOT all
        { (Query($2)) :: $4 }
|	NONINTERF niseq DOT all
        { (Noninterf($2)) :: $4 }
|	WEAKSECRET IDENT DOT all
        { (Weaksecret($2)) :: $4 }
|	NOT gterm optphase optbindingseq DOT all
	{ (Not(((PGSimpleFact(("attacker",dummy_ext), [$2]),dummy_ext),$3),$4)) :: $6 }
|	NOT event optbindingseq DOT all
	{ (Not($2,$3)) :: $5 }
|       ELIMTRUE fact DOT all
        { (Elimtrue ($2)) :: $4 } 
|       privateopt FREE neidentseq DOT all
        { (Free($3,$1)) :: $5 }
|       CLAUSES clauses all
        { (Clauses($2)) :: $3 }
|	PROCESS process EOF
	{ [Process $2] }

privateopt:
	PRIVATE
	{ true }
	| 
	{ false }

/* Rewrite rules */

reduc:
	term EQUAL term SEMI reduc
	{ ($1,$3) :: $5 }
|	term EQUAL term DOT
	{ [($1,$3)] }


/* Terms */

term:
	IDENT LPAREN termseq RPAREN
	{ PFunApp ($1, $3), parse_extent() }
|       CHOICE LBRACKET term COMMA term RBRACKET
        { Param.has_choice := true; 
	  PFunApp(("choice specident", parse_extent()), [$3; $5]), parse_extent() }
|	IDENT
	{ PIdent ($1), parse_extent() }
|	LPAREN termseq RPAREN
	{ PTuple ($2), parse_extent() }

netermseq:
	term COMMA netermseq
	{ $1 :: $3 }
|	term 
	{ [$1] }

termseq:
        netermseq
        { $1 }
| 
        { [] }

neidentseq:
  IDENT COMMA neidentseq
    { $1 :: $3 }
| IDENT
    { [$1] }

ni:
  IDENT AMONG LPAREN netermseq RPAREN
    { ($1, Some $4) }
| IDENT
    { ($1, None) }

niseq:
  ni COMMA niseq
    { $1 :: $3 }
| ni
    { [$1] }

/* Queries */
  
gterm:
	IDENT LPAREN gtermseq RPAREN
	{ PGFunApp ($1, $3), parse_extent() }
|	IDENT
	{ PGIdent ($1), parse_extent() }
|	LPAREN gtermseq RPAREN
	{ PGTuple ($2), parse_extent() }
|       IDENT LBRACKET bindingseq RBRACKET
        { PGName ($1, $3), parse_extent() }

negtermseq:
	gterm COMMA negtermseq
	{ $1 :: $3 }
|	gterm 
	{ [$1] }

gtermseq:
        negtermseq
        { $1 }
| 
        { [] }


nesbindingseq: 
        REPL INT EQUAL gterm SEMI nesbindingseq
        { (("!" ^ (string_of_int ($2)), parse_extent()), $4) :: $6 }
|       REPL INT EQUAL gterm
        { [(("!" ^ (string_of_int ($2)), parse_extent()), $4)] }
|       IDENT EQUAL gterm SEMI nesbindingseq
        { ($1, $3) :: $5 }
|       IDENT EQUAL gterm
        { [($1, $3)] }

bindingseq:
        nesbindingseq
        { $1 }
|       
        { [] }

nebindingseq: 
        IDENT EQUAL gterm SEMI nebindingseq
        { ($1, $3) :: $5 }
|       IDENT EQUAL gterm
        { [($1, $3)] }

optbindingseq:
        SEMI nebindingseq
        { $2 }
|       
        { [] }

gfact:
	IDENT COLON gtermseq
	{ PGSimpleFact($1,$3), parse_extent() }
|       gterm DIFF gterm
        { PGNeq($1,$3), parse_extent() }
|       gterm EQUAL gterm
        { PGEqual($1, $3), parse_extent() }

event:
    gfact optphase
    { ($1,$2) }

queryseq:
    query SEMI queryseq
    { $1 :: $3 }
|   query 
    { [$1] }

query:
    event
    { PRealQuery(PBefore($1, PFalse)) }
|   realquery
    { PRealQuery($1) }
|   PUTBEGIN IDENT COLON neidentseq
    { PPutBegin($2, $4) }
|   LET IDENT EQUAL gterm
    { PBinding($2,$4) }


realquery:
    event BEFORE hyp
    { PBefore($1, $3) }

hyp:
    hyp BAR hyp
    { POr($1, $3) }
|   hyp WEDGE hyp
    { PAnd($1, $3) }
|   LPAREN hyp RPAREN
    { $2 }
|   event
    { PQEvent($1) }
|   LPAREN realquery RPAREN
    { PNestedQuery($2) }

/* Nounif */

gformat:
	IDENT LPAREN gformatseq RPAREN
	{ PFGFunApp ($1, $3), parse_extent() }
|	IDENT
	{ PFGIdent ($1), parse_extent() }
|	LPAREN gformatseq RPAREN
	{ PFGTuple ($2), parse_extent() }
|       IDENT LBRACKET fbindingseq RBRACKET
        { PFGName ($1, $3), parse_extent() }
|       STAR IDENT
        { PFGAny ($2), parse_extent() }

negformatseq:
	gformat COMMA negformatseq
	{ $1 :: $3 }
|	gformat 
	{ [$1] }

gformatseq:
        negformatseq
        { $1 }
| 
        { [] }


fnesbindingseq: 
        REPL INT EQUAL gformat SEMI fnesbindingseq
        { (("!" ^ (string_of_int ($2)), parse_extent()), $4) :: $6 }
|       REPL INT EQUAL gformat
        { [(("!" ^ (string_of_int ($2)), parse_extent()), $4)] }
|       IDENT EQUAL gformat SEMI fnesbindingseq
        { ($1, $3) :: $5 }
|       IDENT EQUAL gformat
        { [($1, $3)] }

fbindingseq:
        fnesbindingseq
        { $1 }
|       
        { [] }

fnebindingseq: 
        IDENT EQUAL gformat SEMI fnebindingseq
        { ($1, $3) :: $5 }
|       IDENT EQUAL gformat
        { [($1, $3)] }

foptbindingseq:
        SEMI fnebindingseq
        { $2 }
|       
        { [] }

gfactformat:
    IDENT COLON gformatseq optphase
    { ($1,$3,$4) }

/* Phase */

optphase:
    PHASE INT
    { $2 }
| 
    { -1 }

/* Integer */

optint:
    SLASH INT
    { $2 }
| 
    { -1 }

/* Clauses */

fact:
	IDENT COLON termseq
	{ PSimpleFact($1,$3), parse_extent() }
|       term DIFF term
        { PSNeq($1,$3), parse_extent() }
|       term EQUAL term
        { PSEqual($1, $3), parse_extent() }

factand:
	fact WEDGE factand
	{ $1 :: $3 }
|	fact
	{ [$1] }

clause: 
        factand RED fact
        { PClause($1,$3) }
|       fact
        { PClause([],$1) }
|       factand EQUIV fact
        { PEquiv($1,$3,true) }
|       factand EQUIVEQ fact
        { PEquiv($1,$3,false) }

clauses:
	clause SEMI clauses
	{ $1 :: $3 }
|	clause DOT
	{ [$1] }

/* Process */

process:
	LPAREN process RPAREN
	{ $2 }
|	IDENT
	{ PLetDef $1 }
|	REPL process
	{ PRepl $2 }
|	INT 
	{ let x = $1 in
	  if x = 0 then PNil else 
          input_error ("The only integer in a process is 0 for the nil process") (parse_extent()) }
| 	NEW IDENT SEMI process
	{ PRestr($2, $4) }
|	IF fact THEN process ELSE process
	{ PTest($2,$4,$6) }
|	IF fact THEN process
	{ PTest($2,$4,PNil) }
|	IN LPAREN term COMMA pattern RPAREN optprocess
	{ PInput($3,$5,$7) }
|	OUT LPAREN term COMMA term RPAREN optprocess
	{ POutput($3,$5,$7) }
| 	LET pattern EQUAL term IN process
	{ PLet($2,$4,$6,PNil) }
| 	LET pattern EQUAL term IN process ELSE process
	{ PLet($2,$4,$6,$8) }
|       LET neidentseq SUCHTHAT fact IN process 
        { PLetFilter($2,$4,$6,PNil) }
|       LET neidentseq SUCHTHAT fact IN process ELSE process
        { (* Approximating the else clause with a parallel composition
	     is not correct for trace reconstruction *)
          PLetFilter($2,$4,$6,$8) }
|	process BAR process
	{ PPar($1,$3) }
|       EVENT IDENT LPAREN termseq RPAREN optprocess
        { PEvent($2, $4, $6) }
|       PHASE INT optprocess
        { PPhase($2, $3) }

optprocess:
        SEMI process
        { $2 }
|       
        { PNil }        

pattern:
  IDENT
    { PPatVar($1) }
| LPAREN patternseq RPAREN
    { PPatTuple($2) }
| IDENT LPAREN patternseq RPAREN
    { PPatFunApp($1,$3) }
| EQUAL term
    { PPatEqual($2) }

patternseq:
  pattern COMMA patternseq
    { $1 :: $3 }
| pattern
    { [$1] }


