%{
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
%}
%{

open Parsing_helper
open Ptree
exception Syntax

let repl_counter = ref 0

let new_repl_occ () =
  incr repl_counter;
  !repl_counter

let cst_true = (PIdent ("true", dummy_ext), dummy_ext)

let dummy_channel = ("@dummy_channel", dummy_ext)

%}

%token COMMA
%token LPAREN
%token RPAREN
%token LBRACKET
%token RBRACKET
%token BAR
%token SEMI
%token COLON
%token NEW
%token OUT
%token IN
%token <Ptree.ident> IDENT
%token <Ptree.ident> STRING
%token <int> INT
%token <float> FLOAT
%token REPL
%token LEQ
%token IF
%token THEN
%token ELSE
%token FIND
%token ORFIND
%token SUCHTHAT
%token DEFINED
%token EQUAL
%token DIFF
%token FUN
%token FORALL
%token PARAM
%token PROBA
%token TYPE
%token PROCESS
%token DOT
%token EOF
%token LET
%token QUERY
%token SECRET
%token SECRET1
%token AND
%token OR
%token CONST
%token CHANNEL
%token EQUIV
%token EQUIVLEFT
%token EQUIVRIGHT
%token MAPSTO
%token DEF
%token MUL
%token DIV
%token ADD
%token SUB
%token POWER
%token SET
%token COLLISION
%token EVENT
%token IMPLIES
%token TIME
%token YIELD
%token OTHERUSES
%token MAXLENGTH
%token LENGTH
%token MAX
%token COUNT
%token NEWCHANNEL
%token INJ
%token DEFINE
%token EXPAND
%token LBRACE
%token RBRACE
%token PROOF

/* Precedence (from low to high) and associativities */
%left BAR
%right OR
%right AND
%left ADD SUB
%left MUL DIV
%nonassoc EQUAL
%nonassoc DIFF

%start all
%type <Ptree.decl list * Ptree.process_e> all

%start lib
%type <Ptree.decl list> lib

%start instruct
%type <Ptree.process_e> instruct

%start term
%type <Ptree.term_e> term

%start allowed_coll
%type <((Ptree.ident * int) list * Ptree.ident option) list> allowed_coll

%%

lib:
	FUN IDENT LPAREN identlist RPAREN COLON IDENT options DOT lib
	{ (FunDecl($2, $4, $7, $8)) :: $10 }
|       EVENT IDENT DOT lib
        { (EventDecl($2, [])) :: $4 }
|       EVENT IDENT LPAREN identlist RPAREN DOT lib
        { (EventDecl($2, $4)) :: $7 }
|	FORALL vartypelist SEMI term DOT lib
	{ (Statement($2, $4)) :: $6 }
|	LET IDENT EQUAL process DOT lib
	{ (PDef($2,$4)) :: $6 }
|       SET IDENT EQUAL IDENT DOT lib
        { (Setting($2,S $4)) :: $6 }
|       SET IDENT EQUAL INT DOT lib
        { (Setting($2,I $4)) :: $6 }
|       QUERY queryseq DOT lib
        { (Query($2)) :: $4 }
|       PARAM neidentlist options DOT lib
        { (List.map (fun x -> (ParamDecl(x, $3))) $2) @ $5 }
|       PROBA IDENT DOT lib
        { (ProbabilityDecl($2)) :: $4 }
|       CONST neidentlist COLON IDENT DOT lib
        { (List.map (fun x -> (ConstDecl(x,$4))) $2) @ $6 }
|       CHANNEL neidentlist DOT lib 
        { (List.map (fun x -> (ChannelDecl(x))) $2) @ $4 }
|       TYPE IDENT options DOT lib
        { (TypeDecl($2,$3)) :: $5 }
|       EQUIV eqmember EQUIVLEFT probaf EQUIVRIGHT optpriority eqmember DOT lib
        { (EqStatement($2, $7, $4, $6)) :: $9 }
|       COLLISION newlist FORALL vartypelist SEMI term EQUIVLEFT probaf EQUIVRIGHT term DOT lib
        { (Collision($2, $4, $6, $8, $10)) :: $12 }
|       COLLISION newlist term EQUIVLEFT probaf EQUIVRIGHT term DOT lib
        { (Collision($2, [], $3, $5, $7)) :: $9 }
|       DEFINE IDENT LPAREN identlist RPAREN LBRACE lib RBRACE lib
        { (Define($2, $4, $7)) :: $9 }
|       EXPAND IDENT LPAREN identlist RPAREN DOT lib
        { (Expand($2, $4)) :: $7 }
|       PROOF LBRACE proof RBRACE lib
        { (Proofinfo($3))::$5 }
| 
        { [] }


prooftoken:
        IDENT
        { $1 }
|       STRING
        { $1 }
|       INT
        { string_of_int $1, parse_extent() }
|       MUL
        { "*", parse_extent() }
|       DOT
        { ".", parse_extent() }
|       SET
        { "set", parse_extent() }
|       EQUAL
        { "=", parse_extent() }
|       COMMA
        { ",", parse_extent() }

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

options:
        LBRACKET neidentlist RBRACKET
        { $2 }
| 
        { [] }

all:
        lib PROCESS process EOF
	{ $1 , $3 }

identlist:
        
        { [] }
|       neidentlist
        { $1 }

neidentlist:
        IDENT 
        { [$1] }
|       IDENT COMMA neidentlist
        { $1 :: $3 }

vartypelist:

        { [] }
|       nevartypelist
        { $1 }

nevartypelist:
        IDENT COLON IDENT
        { [($1, $3)] }
|       IDENT COLON IDENT COMMA nevartypelist
        { ($1, $3) :: $5 }

term:
	IDENT LPAREN termseq RPAREN
	{ PFunApp ($1, $3), parse_extent() }
|       INJ COLON IDENT 
        { PInjEvent($3, []), parse_extent() }
|       INJ COLON IDENT LPAREN termseq RPAREN
        { PInjEvent($3, $5), parse_extent() }
|	IDENT
	{ PIdent ($1), parse_extent() }
|       IDENT LBRACKET termseq RBRACKET
        { PArray ($1, $3), parse_extent() }
|	LPAREN termseq RPAREN
	{ match $2 with
	    [t] -> t (* Allow parentheses for priorities of infix operators;
			Tuples cannot have one element. *)
	  | l -> PTuple(l), parse_extent() }
|       IF findcond THEN term ELSE term
        { begin
	  match $2 with
	    ([],t) -> PTestE(t, $4, $6)
	  | (def_list, t) -> 
	      PFindE([([], def_list, t, $4)], $6, [])
	  end, parse_extent() }
|       FIND options findlistterm ELSE term
        { PFindE($3, $5, $2), parse_extent() }
|       LET pattern EQUAL term IN term ELSE term
        { PLetE($2,$4,$6,Some $8), parse_extent() }
|       LET pattern EQUAL term IN term
        { PLetE($2,$4,$6,None), parse_extent() }
| 	NEW IDENT COLON IDENT SEMI term
	{ PResE($2, $4, $6), parse_extent() }
|       EVENT IDENT
        { PEventE($2), parse_extent() }
|       term EQUAL term
        { PEqual($1, $3), parse_extent() }
|       term DIFF term
        { PDiff($1, $3), parse_extent() }
|       term OR term
        { POr($1, $3), parse_extent() }
|       term AND term
        { PAnd($1, $3), parse_extent() }

vref:
    IDENT LBRACKET termseq RBRACKET
    { $1,$3 }
|   IDENT
    { $1, [] }
    
otherusescond:
    OTHERUSES LPAREN vreflist MAPSTO vref RPAREN
    { None }
|   OTHERUSES LPAREN vref RPAREN
    { None }

vreflist:
    vref
    { [$1] }
|   vref COMMA vreflist
    { $1::$3 }

findcond1:
    DEFINED LPAREN vreflist RPAREN AND otherusescond AND term
    { ($3, $8) }
|   DEFINED LPAREN vreflist RPAREN AND otherusescond
    { ($3, cst_true) }
|   DEFINED LPAREN vreflist RPAREN AND term
    { ($3, $6) }
|   DEFINED LPAREN vreflist RPAREN 
    { ($3, cst_true) }

findcond:
    findcond1
    { $1 }
|   term
    { ([], $1) }
|   LPAREN findcond1 RPAREN
    { $2 }

findoneterm:
    tidentseq SUCHTHAT findcond THEN term
    { let (def_list, t) = $3 in
      ($1, def_list, t, $5) }

findlistterm:
    findoneterm
    { [$1] }
|   findoneterm ORFIND findlistterm
    { $1 :: $3 }

netidentseq:
    IDENT LEQ IDENT
    { [$1,$3] }
|   IDENT LEQ IDENT COMMA netidentseq
    { ($1,$3)::$5 }

tidentseq:
    netidentseq
    { $1 }
| 
    { [] }

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

process:
	LPAREN process RPAREN
	{ $2 }
|	IDENT
	{ PLetDef $1, parse_extent() }
|	REPL IDENT process
	{ PRepl (new_repl_occ(),None,$2,$3), parse_extent() }
|	REPL IDENT LEQ IDENT process
	{ PRepl (new_repl_occ(),Some $2,$4,$5), parse_extent() }
|	INT 
	{ let x = $1 in
	  if x = 0 then PNil, parse_extent() else 
          input_error ("The only integer in a process is 0 for the nil process") (parse_extent()) }
| 	NEW IDENT COLON IDENT optprocess
	{ PRestr($2, $4, $5), parse_extent() }
|	IF findcond THEN process optelse
        { match $2 with
	    ([], t) -> PTest(t, $4, $5), parse_extent()
	  | (def_list, t) -> 
	      PFind([([], def_list, t, $4)], $5, []), parse_extent() }
|       FIND options findlistproc optelse
        { PFind($3,$4,$2), parse_extent() }
|       EVENT IDENT optprocess
        { PEvent((PFunApp($2, []), parse_extent()), $3), parse_extent() }
|       EVENT IDENT LPAREN termseq RPAREN optprocess
        { PEvent((PFunApp($2, $4), parse_extent()), $6), parse_extent() }
| 	LET pattern EQUAL term
	{ PLet($2,$4,(PYield, parse_extent()),(PYield, parse_extent())), parse_extent() }
| 	LET pattern EQUAL term IN process optelse
	{ PLet($2,$4,$6,$7), parse_extent() }
|	IN LPAREN term COMMA pattern RPAREN optprocess
	{ PInput($3,$5,$7), parse_extent() }
|	OUT LPAREN term COMMA term RPAREN optinputprocess
	{ POutput($3,$5,$7), parse_extent() }
|       YIELD
        { PYield, parse_extent() }
|	process BAR process
	{ PPar($1,$3), parse_extent() }

findoneproc:
    tidentseq SUCHTHAT findcond THEN process
    { let (def_list, t) = $3 in
      ($1, def_list, t, $5) }

findlistproc:
    findoneproc
    { [$1] }
|   findoneproc ORFIND findlistproc
    { $1 :: $3 }

optprocess:
        SEMI process
        { $2 }
|       
        { PYield, parse_extent() }        

optinputprocess:
        SEMI process
        { $2 }
|       
        { PNil, parse_extent() }        

optelse:
        ELSE process
        { $2 }
|
        { PYield, parse_extent() }

pattern:
  IDENT
    { PPatVar($1,None), parse_extent() }
| IDENT COLON IDENT
    { PPatVar($1,Some $3), parse_extent() }
| IDENT LPAREN patternseq RPAREN
    { PPatFunApp($1,$3), parse_extent() }
| LPAREN patternseq RPAREN
    {  match $2 with
	    [t] -> t (* Allow parentheses for priorities of infix operators;
			Tuples cannot have one element. *)
	  | l -> PPatTuple($2), parse_extent() }
| EQUAL term
    { PPatEqual($2), parse_extent() }

nepatternseq:
  pattern COMMA nepatternseq
    { $1 :: $3 }
| pattern
    { [$1] }

patternseq:
  nepatternseq
    { $1 }
| 
    { [] }

queryseq:
    query
    { [$1] }
|   query COMMA queryseq
    { $1::$3 }

query:
    SECRET IDENT
    { PQSecret $2 }
|   SECRET1 IDENT
    { PQSecret1 $2 }
|   vartypelist SEMI EVENT term IMPLIES term 
    { PQEvent($1, $4, $6) }
|   EVENT term IMPLIES term 
    { PQEvent([], $2, $4) }

eqmember:
    funmode
    { [$1], parse_extent() }
|   funmode COMMA eqmember
    { $1 :: (fst $3), parse_extent() }


funmode:
    fungroup
    { $1,None, parse_extent() }
|   fungroup LBRACKET IDENT RBRACKET
    { $1,Some $3, parse_extent() }

newlist:
    
    { [] }
|   NEW IDENT COLON IDENT SEMI newlist
    { ($2,$4)::$6 }

newlistopt:
    
    { [] }
|   NEW IDENT COLON IDENT options SEMI newlistopt
    { ($2,$4,$5)::$7 }

funlist:
    fungroup
    { [$1] }
|   fungroup COMMA funlist
    { $1 :: $3 }

optpriority:
    options LBRACKET INT RBRACKET 
    { $3, $1 }
|   LBRACKET INT RBRACKET options
    { $2, $4 }
|   options
    { 0, $1 }

vartypeilist:

        { [] }
|       nevartypeilist
        { $1 }

nevartypeilist:
        IDENT COLON IDENT
        { [($1, Tid $3)] }
|       IDENT COLON IDENT COMMA nevartypeilist
        { ($1, Tid $3) :: $5 }
|       IDENT LEQ IDENT
        { [($1, TBound $3)] }
|       IDENT LEQ IDENT COMMA nevartypeilist
        { ($1, TBound $3) :: $5 }

fungroup:
    LPAREN vartypeilist RPAREN optpriority MAPSTO term 
    { PFun(dummy_channel, $2, $6, $4) }
|   LPAREN vartypeilist RPAREN IDENT optpriority MAPSTO newlistopt term 
    { PReplRestr((new_repl_occ(), None, $4), $7, [PFun(dummy_channel, $2, $8, $5)]) }
|   IDENT LPAREN vartypeilist RPAREN optpriority DEF term 
    { PFun($1, $3, $7, $5) }
|   REPL IDENT newlistopt fungroup
    { PReplRestr((new_repl_occ(), None, $2), $3, [$4]) }
|   REPL IDENT newlistopt LPAREN funlist RPAREN
    { PReplRestr((new_repl_occ(), None, $2), $3, $5) }
|   REPL IDENT LEQ IDENT newlistopt fungroup
    { PReplRestr((new_repl_occ(), Some $2, $4), $5, [$6]) }
|   REPL IDENT LEQ IDENT newlistopt LPAREN funlist RPAREN
    { PReplRestr((new_repl_occ(), Some $2, $4), $5, $7) }

probaf:
        LPAREN probaf RPAREN
        { $2 }
|       probaf ADD probaf
        { PAdd($1,$3), parse_extent() }
|       probaf SUB probaf
        { PSub($1, $3), parse_extent() }
|       probaf MUL probaf
        { PProd($1,$3), parse_extent() }
|       probaf DIV probaf
        { PDiv($1,$3), parse_extent() }
|       MAX LPAREN probaflist RPAREN
        { PMax($3), parse_extent() }
|       IDENT
        { (PPIdent $1), parse_extent() }
|       COUNT IDENT
        { (PCount $2), parse_extent() }
|       IDENT LPAREN probaflist RPAREN
        { (PPFun($1,$3)), parse_extent() }
|       BAR IDENT BAR
        { PCard($2), parse_extent() }
|       TIME
        { PTime, parse_extent() }
|       TIME LPAREN IDENT probaflistopt RPAREN
        { PActTime(PAFunApp $3, $4), parse_extent() }
|       TIME LPAREN LET IDENT probaflistopt RPAREN
        { PActTime(PAPatFunApp $4, $5), parse_extent() }
|       TIME LPAREN REPL RPAREN
        { PActTime(PAReplIndex, []), parse_extent() }
|       TIME LPAREN LBRACKET INT RBRACKET RPAREN
        { PActTime(PAArrayAccess $4, []), parse_extent() }
|       TIME LPAREN EQUAL IDENT probaflistopt RPAREN
        { PActTime(PACompare $4, $5), parse_extent() }
|       TIME LPAREN LPAREN identlist RPAREN probaflistopt RPAREN
        { PActTime(PAAppTuple $4, $6), parse_extent() }
|       TIME LPAREN LET LPAREN identlist RPAREN probaflistopt RPAREN
        { PActTime(PAPatTuple $5, $7), parse_extent() }
|       TIME LPAREN AND RPAREN
        { PActTime(PAAnd, []), parse_extent() }
|       TIME LPAREN OR RPAREN
        { PActTime(PAOr, []), parse_extent() }
|       TIME LPAREN NEW IDENT RPAREN
        { PActTime(PANew $4, []), parse_extent() }
|       TIME LPAREN NEWCHANNEL RPAREN
        { PActTime(PANewChannel, []), parse_extent() }
|       TIME LPAREN IF RPAREN
        { PActTime(PAIf, []), parse_extent() }
|       TIME LPAREN FIND INT RPAREN
        { PActTime(PAFind $4, []), parse_extent() }
|       TIME LPAREN OUT IDENT probaflistopt RPAREN
        { PActTime(PAOut([], $4), $5), parse_extent() }
|       TIME LPAREN OUT LBRACKET neidentlist RBRACKET IDENT probaflistopt RPAREN
        { PActTime(PAOut($5, $7), $8), parse_extent() }
|       TIME LPAREN IN INT RPAREN
        { PActTime(PAIn $4, []), parse_extent() }
|       INT
        { let x = $1 in
	  if x = 0 then (PPZero,parse_extent())  else 
          (PCst x,parse_extent())  }
|       FLOAT
        { let x = $1 in
	  if x = 0.0 then (PPZero,parse_extent())  else 
	  (PFloatCst x,parse_extent())  }
|       MAXLENGTH LPAREN term RPAREN
        { PMaxlength($3), parse_extent() }
|       LENGTH LPAREN IDENT probaflistopt RPAREN
        { PLength($3, $4), parse_extent() }
|       LENGTH LPAREN LPAREN identlist RPAREN probaflistopt RPAREN
        { PLengthTuple($4, $6), parse_extent() }

probaflistopt:
       COMMA probaflist 
       { $2 }
| 
       { [] }

probaflist:
       probaf
       { [$1] }
|      probaf COMMA probaflist
       { $1 :: $3 }

/* Instructions, for manual insertion of an instruction in a game */

instruct:
    NEW IDENT COLON IDENT 
    { PRestr($2, $4, (PYield, parse_extent())), parse_extent() }
|   IF findcond THEN
    { 
      let yield = (PYield, parse_extent()) in
      match $2 with
	([], t) -> PTest(t, yield, yield), parse_extent()
      | (def_list, t) -> 
	  PFind([([], def_list, t, yield)], yield, []), parse_extent()
    }
|   FIND findlistins
    { PFind($2, (PYield, parse_extent()), []), parse_extent() }
|   EVENT IDENT
    { PEvent((PFunApp($2, []), parse_extent()), (PYield, parse_extent())), parse_extent() }
|   LET pattern EQUAL term IN
    { PLet($2,$4,(PYield, parse_extent()),(PYield, parse_extent())), parse_extent() }

findoneins:
    tidentseq SUCHTHAT findcond THEN 
    { let (def_list, t) = $3 in
      ($1, def_list, t, (PYield, parse_extent())) }

findlistins:
    findoneins
    { [$1] }
|   findoneins ORFIND findlistins
    { $1 :: $3 }

    
/* Limits on elimination of collisions */

factor:
    IDENT
    { ($1, 1) }
|   IDENT POWER INT
    { ($1, $3) }

num:
    factor MUL num
    { $1 :: $3 }
|   factor
    { [$1] }

quot:
    num DIV IDENT
    { ($1, Some $3) }
|   COLLISION MUL num
    { ($3, None) }

allowed_coll:
    quot
    { [$1] }
|   quot COMMA allowed_coll
    { $1 :: $3 }
