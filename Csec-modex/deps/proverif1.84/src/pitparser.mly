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
open Pitptree
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
%token <Pitptree.ident> IDENT
%token <Pitptree.ident> STRING
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
%token PARAM

/* Typed front-end only */
%token TYPE
%token SET
%token FORALL
%token CONST
%token INJEVENT
%token OR
%token CHANNEL
%token LETFUN
%token DEFINE
%token EXPAND
%token YIELD
%token LEQ
%token PROBA
%token LBRACE
%token RBRACE
%token PROOF
/* Tables of keys */
%token TABLE
%token INSERT
%token GET

/* Precedence (from low to high) and associativities */
%nonassoc BEFORE
%right BAR 
%right OR
%right WEDGE 
%nonassoc EQUAL
%nonassoc DIFF

%start all
%type <Pitptree.tdecl list * Pitptree.tprocess> all

%start lib
%type <Pitptree.tdecl list> lib

%%

/*** Typed front-end ***/

lib:
        TYPE IDENT options DOT lib
        { (* Options are ignored, they are supported for compatibility with
             CryptoVerif only *)
          TTypeDecl($2) :: $5 }
| 	FUN IDENT LPAREN typeidseq RPAREN COLON typeid options DOT lib
	{ (TFunDecl($2, $4, $7, $8)) :: $10 }
|       CONST neidentseq COLON typeid options DOT lib
        { (List.map (fun x -> TConstDecl(x, $4, $5)) $2) @ $7 }
|	EQUATION forallvartype term EQUAL term DOT lib
	{ (TEquation($2, $3, $5)) :: $7 }
|	REDUCTION treduc options DOT lib
	{ (TReduc($2,$3)) :: $5 }
|       EVENT IDENT DOT lib
        { (TEventDecl($2, [])) :: $4 }
|       EVENT IDENT LPAREN typeidseq RPAREN DOT lib
        { (TEventDecl($2, $4)) :: $7 }
|       PREDICATE IDENT LPAREN typeidseq RPAREN options DOT lib
        { (TPredDecl($2, $4, $6)) :: $8 }
|       PREDICATE IDENT options DOT lib
        { (TPredDecl($2, [], $3)) :: $5 }
|       TABLE IDENT LPAREN typeidseq RPAREN DOT lib
        { (TTableDecl($2, $4)) :: $7 }
|	LET IDENT EQUAL tprocess DOT lib
	{ (TPDef($2,[],$4)) :: $6 }
|       LET IDENT LPAREN vartype RPAREN EQUAL tprocess DOT lib
        { (TPDef($2,$4,$7)) :: $9 }
|       LETFUN IDENT EQUAL pterm DOT lib
        { (TLetFun($2,[],$4)) :: $6 }
|       LETFUN IDENT LPAREN vartype RPAREN EQUAL pterm DOT lib
        { (TLetFun($2,$4,$7)) :: $9 }
|       SET IDENT EQUAL IDENT DOT lib
        { (TSet($2,S $4)) :: $6 }
|       SET IDENT EQUAL INT DOT lib
        { (TSet($2,I $4)) :: $6 }
|       NOUNIF nevartype SEMI tfnebindingseq DOT lib
        { (TNoUnif ($2, $4)) :: $6 } 
|       NOUNIF tfnebindingseq DOT lib
        { (TNoUnif ([], $2)) :: $4 } 
|       QUERY nevartype SEMI tqueryseq DOT lib
        { (TQuery($2,$4)) :: $6 }
|       QUERY tqueryseq DOT lib
        { (TQuery([],$2)) :: $4 }
|	NONINTERF nevartype SEMI niseq DOT lib
        { (TNoninterf($2, $4)) :: $6 }
|	NONINTERF niseq DOT lib
        { (TNoninterf([], $2)) :: $4 }
|	WEAKSECRET IDENT DOT lib
        { (TWeaksecret($2)) :: $4 }
|	NOT nevartype SEMI gterm DOT lib
	{ (TNot($2, $4)) :: $6 }
|	NOT gterm DOT lib
	{ (TNot([], $2)) :: $4 }
|       PARAM neidentseq DOT lib
        { (* Supported for compatility with CryptoVerif only *)
          $4 }
|       PROBA IDENT DOT lib
        { (* Supported for compatility with CryptoVerif only *)
          $4 }
|       PROOF LBRACE proof RBRACE lib
        { (* Supported for compatility with CryptoVerif only *)
          $5 }
|       ELIMTRUE nevartype SEMI term DOT lib
        { (TElimtrue ($2,$4)) :: $6 } 
|       ELIMTRUE term DOT lib
        { (TElimtrue ([],$2)) :: $4 } 
|       CHANNEL neidentseq DOT lib
        { (* For compatibility with CryptoVerif, allow 
               channel c1...cn. 
             as a synonym for 
               free c1...cn:channel. *)
          (List.map (fun x -> TFree(x, ("channel", dummy_ext), [])) $2) @ $4 }
|       FREE neidentseq COLON typeid options DOT lib
        { (List.map (fun x -> TFree(x, $4, $5)) $2) @ $7 }
|       CLAUSES tclauses lib
        { (TClauses($2)) :: $3 }
|       DEFINE IDENT LBRACE lib RBRACE lib
        { (TDefine($2, [], $4)) :: $6 }
|       DEFINE IDENT LPAREN typeidseq RPAREN LBRACE lib RBRACE lib
        { (TDefine($2, $4, $7)) :: $9 }
|       EXPAND IDENT LPAREN typeidseq RPAREN DOT lib
        { (TExpand($2, $4)) :: $7 }
| 
        { [] }

all: 
        lib PROCESS tprocess EOF
	{ $1, $3 }

/* Proofs (for CryptoVerif compatibility only) */

prooftoken:
        IDENT
        { $1 }
|       STRING
        { $1 }
|       STAR
        { "*", parse_extent() }
|       DOT
        { ".", parse_extent() }

proofcommand:
        prooftoken
        { [$1] }
|       prooftoken proofcommand
        { $1 :: $2 }

proof:
        proofcommand
	{ [$1] }
|       proofcommand SEMI proof
        { $1 :: $3 }

/* Options, environments, ... */

options:
        LBRACKET neidentseq RBRACKET
        { $2 }
| 
        { [] }

neidentseq:
  IDENT COMMA neidentseq
    { $1 :: $3 }
| IDENT
    { [$1] }

nevartype:
        IDENT COLON typeid COMMA nevartype
        { ($1,$3)::$5 }
|
        IDENT COLON typeid
        { [($1,$3)] }

vartype:
        nevartype
        { $1 }
| 
        { [] }

forallvartype:
        FORALL nevartype SEMI
        { $2 }
| 
        { [] }

typeid:
        IDENT
        { $1 }
|       CHANNEL 
        { (* channel is allowed as a type, even though it is also a keyword for the declaration channel c1...cn. *)
          "channel", parse_extent() }

typeidseq:
        netypeidseq
        { $1 }
| 
        { [] }

netypeidseq:
  typeid COMMA netypeidseq
    { $1 :: $3 }
| typeid
    { [$1] }

/* Terms */

term:
	IDENT LPAREN termseq RPAREN
	{ PFunApp ($1, $3), parse_extent() }
|       CHOICE LBRACKET term COMMA term RBRACKET
        { Param.has_choice := true; 
	  PFunApp(("choice", parse_extent()), [$3; $5]), parse_extent() }
|	IDENT
	{ PIdent ($1), parse_extent() }
|       term EQUAL term
        { PFunApp(("=", parse_extent()), [$1; $3]), parse_extent() }
|       term DIFF term
        { PFunApp(("<>", parse_extent()), [$1; $3]), parse_extent() }
|       NOT LPAREN term RPAREN
        { PFunApp(("not", parse_extent()), [$3]), parse_extent() }
|       term OR term
        { PFunApp(("||", parse_extent()), [$1; $3]), parse_extent() }
|       term WEDGE term
        { PFunApp(("&&", parse_extent()), [$1; $3]), parse_extent() }
|	LPAREN termseq RPAREN
	{ match $2 with
	  [t] -> t   (* Allow parentheses for priorities of infix operators;
			Tuples cannot have one element. *)
	| l -> PTuple (l), parse_extent() }

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

/* Noninterf */

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
  
tqueryseq:
    tquery SEMI tqueryseq
    { $1 :: $3 }
|   tquery 
    { [$1] }

tquery:
    gterm
    { PRealQuery($1) }
|   PUTBEGIN EVENT COLON neidentseq
    { PPutBegin(false, $4) }
|   PUTBEGIN INJEVENT COLON neidentseq
    { PPutBegin(true, $4) }

gterm:
	IDENT LPAREN gtermseq RPAREN
	{ PGFunApp ($1, $3), parse_extent() }
|	IDENT
	{ PGIdent ($1), parse_extent() }
|       IDENT LPAREN gtermseq RPAREN PHASE INT
        { PGPhase($1, $3, $6), parse_extent() }
|       gterm EQUAL gterm
        { PGFunApp(("=", parse_extent()), [$1; $3]), parse_extent() }
|       gterm DIFF gterm
        { PGFunApp(("<>", parse_extent()), [$1; $3]), parse_extent() }
|       NOT LPAREN gterm RPAREN
        { PGFunApp(("not", parse_extent()), [$3]), parse_extent() }
|       gterm OR gterm
        { PGFunApp(("||", parse_extent()), [$1; $3]), parse_extent() }
|       gterm WEDGE gterm
        { PGFunApp(("&&", parse_extent()), [$1; $3]), parse_extent() }
|       EVENT LPAREN gtermseq RPAREN
        { PGFunApp(("event",parse_extent()), $3), parse_extent() }
|       INJEVENT LPAREN gtermseq RPAREN
        { PGFunApp(("inj-event",parse_extent()), $3), parse_extent() }
|       gterm BEFORE gterm
        { PGFunApp(("==>", parse_extent()), [$1;$3]), parse_extent() }
|	LPAREN gtermseq RPAREN
	{ match $2 with
	  [t] -> t   (* Allow parentheses for priorities of infix operators;
			Tuples cannot have one element. *)
	| l -> PGTuple (l), parse_extent() }
|       NEW IDENT LBRACKET bindingseq RBRACKET
        { PGName ($2, $4), parse_extent() }
|       NEW IDENT 
        { PGName ($2, []), parse_extent() }
|       LET IDENT EQUAL gterm IN gterm 
        { PGLet($2, $4, $6), parse_extent() }

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

/* Nounif */

tfnebindingseq: 
        LET IDENT EQUAL gformat IN tfnebindingseq
        { BFLet($2, $4, $6) }
|       IDENT LPAREN gformatseq RPAREN optphase optint
        { BFNoUnif(($1,$3,$5), $6) }
|       IDENT optint
        { BFNoUnif(($1,[],-1),$2) }

optphase:
    PHASE INT
    { $2 }
| 
    { -1 }

optint:
    SLASH INT
    { $2 }
| 
    { -1 }

gformat:
	IDENT LPAREN gformatseq RPAREN
	{ PFGFunApp ($1, $3), parse_extent() }
|       NOT LPAREN gformat RPAREN
        { PFGFunApp(("not", parse_extent()), [$3]), parse_extent() }
|	IDENT
	{ PFGIdent ($1), parse_extent() }
|	LPAREN gformatseq RPAREN
	{ match $2 with
	  [t] -> t   (* Allow parentheses for priorities of infix operators;
			Tuples cannot have one element. *)
	| l -> PFGTuple ($2), parse_extent() }
|       NEW IDENT LBRACKET fbindingseq RBRACKET
        { PFGName ($2, $4), parse_extent() }
|       NEW IDENT 
        { PFGName ($2, []), parse_extent() }
|       STAR IDENT
        { PFGAny ($2), parse_extent() }
|       LET IDENT EQUAL gformat IN gformat
        { PFGLet($2, $4, $6), parse_extent() }


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

/* Rewrite rules */

treduc:
	forallvartype term EQUAL term SEMI treduc
	{ ($1,$2,$4) :: $6 }
|	forallvartype term EQUAL term 
	{ [$1,$2,$4] }

/* Clauses */

tclause: 
        term RED term
        { PClause($1,$3) }
|       term
        { PFact($1) }
|       term EQUIV term
        { PEquiv($1,$3,true) }
|       term EQUIVEQ term
        { PEquiv($1,$3,false) }

tclauses:
	forallvartype tclause SEMI tclauses
	{ ($1,$2) :: $4 }
|	forallvartype tclause DOT
	{ [$1,$2] }

/* Process */

tprocess:
	LPAREN tprocess RPAREN
	{ $2 }
|	IDENT
	{ PLetDef ($1,[]) }
|       IDENT LPAREN ptermseq RPAREN
        { PLetDef ($1, $3) }
|	REPL tprocess
	{ PRepl $2 }
|	REPL IDENT LEQ IDENT tprocess 
	{ (* For convergence with CryptoVerif, we allow an identifier (bound on the number of copies) after a replication; it is simply ignored in ProVerif. *)
          PRepl $5 }
|	INT 
	{ let x = $1 in
	  if x = 0 then PNil else 
          input_error ("The only integer in a process is 0 for the nil process") (parse_extent()) }
|       YIELD  
        { (* For convergence with CryptoVerif, we allow yield instead of 0 *)
          PNil }
| 	NEW IDENT COLON typeid SEMI tprocess
	{ PRestr($2, $4, $6) }
|	IF pterm THEN tprocess ELSE tprocess
	{ PTest($2,$4,$6) }
|	IF pterm THEN tprocess
	{ PTest($2,$4,PNil) }
|	IN LPAREN pterm COMMA tpattern RPAREN opttprocess
	{ PInput($3,$5,$7) }
|	OUT LPAREN pterm COMMA pterm RPAREN opttprocess
	{ POutput($3,$5,$7) }
| 	LET tpattern EQUAL pterm IN tprocess
	{ PLet($2,$4,$6,PNil) }
| 	LET tpattern EQUAL pterm 
	{ PLet($2,$4,PNil,PNil) }
| 	LET tpattern EQUAL pterm IN tprocess ELSE tprocess
	{ PLet($2,$4,$6,$8) }
|       LET nevartype SUCHTHAT pterm IN tprocess 
        { PLetFilter($2,$4,$6,PNil) }
|       LET nevartype SUCHTHAT pterm  
        { PLetFilter($2,$4,PNil,PNil) }
|       LET nevartype SUCHTHAT pterm IN tprocess ELSE tprocess
        { (* Approximating the else clause with a parallel composition
	     is not correct for trace reconstruction *)
          PLetFilter($2,$4,$6,$8) }
|       INSERT IDENT LPAREN ptermseq RPAREN opttprocess
        { PInsert($2, $4, $6) }
|       GET IDENT LPAREN tpatternseq RPAREN optinprocess
        { PGet($2, $4, (PPIdent ("true", parse_extent()), parse_extent()), $6) }
|       GET IDENT LPAREN tpatternseq RPAREN SUCHTHAT pterm optinprocess
        { PGet($2, $4, $7, $8) }
|	tprocess BAR tprocess
	{ PPar($1,$3) }
|       EVENT IDENT LPAREN ptermseq RPAREN opttprocess
        { PEvent($2, $4, $6) }
|       PHASE INT opttprocess
        { PPhase($2, $3) }

opttprocess:
        SEMI tprocess
        { $2 }
|       
        { PNil }        

optinprocess:
        IN tprocess
        { $2 }
|       
        { PNil }        

tpattern:
  IDENT
    { PPatVar($1, None) }
| IDENT COLON typeid
    { PPatVar($1, Some $3) }
| LPAREN tpatternseq RPAREN
    { match $2 with
	  [t] -> t   (* Allow parentheses for priorities of infix operators;
			Tuples cannot have one element. *)
	| l -> PPatTuple($2) }
| IDENT LPAREN tpatternseq RPAREN
    { PPatFunApp($1,$3) }
| EQUAL pterm
    { PPatEqual($2) }

nepatternseq:
  tpattern COMMA nepatternseq
    { $1 :: $3 }
| tpattern
    { [$1] }

tpatternseq:
  nepatternseq
    { $1 }
| 
    { [] }

/* Process terms */

pterm:
	IDENT LPAREN ptermseq RPAREN
	{ PPFunApp ($1, $3), parse_extent() }
|       CHOICE LBRACKET pterm COMMA pterm RBRACKET
        { Param.has_choice := true; 
	  PPFunApp(("choice", parse_extent()), [$3; $5]), parse_extent() }
|	IDENT
	{ PPIdent ($1), parse_extent() }
|       pterm EQUAL pterm
        { PPFunApp(("=", parse_extent()), [$1; $3]), parse_extent() }
|       pterm DIFF pterm
        { PPFunApp(("<>", parse_extent()), [$1; $3]), parse_extent() }
|       NOT LPAREN pterm RPAREN
        { PPFunApp(("not", parse_extent()), [$3]), parse_extent() }
|       pterm OR pterm
        { PPFunApp(("||", parse_extent()), [$1; $3]), parse_extent() }
|       pterm WEDGE pterm
        { PPFunApp(("&&", parse_extent()), [$1; $3]), parse_extent() }
| 	NEW IDENT COLON typeid SEMI pterm
	{ PPRestr($2, $4, $6), parse_extent() }
|	IF pterm THEN pterm ELSE pterm
	{ PPTest($2,$4,$6), parse_extent() }
| 	LET tpattern EQUAL pterm IN pterm
	{ PPLetIn($2,$4,$6), parse_extent() }
| 	LET tpattern EQUAL pterm IN pterm ELSE pterm
	{ PPLet($2,$4,$6,$8), parse_extent() }
|       LET nevartype SUCHTHAT pterm IN pterm ELSE pterm
        { PPLetFilter($2,$4,$6,$8), parse_extent() }
|	LPAREN ptermseq RPAREN
	{ match $2 with
	  [t] -> t   (* Allow parentheses for priorities of infix operators;
			Tuples cannot have one element. *)
	| l -> PPTuple (l), parse_extent() }

neptermseq:
	pterm COMMA neptermseq
	{ $1 :: $3 }
|	pterm 
	{ [$1] }

ptermseq:
        neptermseq
        { $1 }
| 
        { [] }

