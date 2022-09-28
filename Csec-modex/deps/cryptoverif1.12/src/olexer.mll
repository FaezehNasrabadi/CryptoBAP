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
{
open Parsing_helper
open Oparser

let create_hashtable size init =
  let tbl = Hashtbl.create size in
  List.iter (fun (key,data) -> Hashtbl.add tbl key data) init;
  tbl

let keyword_table =
  create_hashtable 11
[ "if", IF;
  "then", THEN;
  "else", ELSE;
  "find", FIND;
  "orfind", ORFIND;
  "suchthat", SUCHTHAT;
  "fun", FUN;
  "param", PARAM;
  "forall", FORALL;
  "proba", PROBA;
  "type", TYPE;
  "equiv", EQUIV;
  "process", PROCESS;
  "let", LET;
  "in", IN;
  "query", QUERY;
  "secret", SECRET;
  "secret1", SECRET1;
  "const", CONST;
  "set", SET;
  "defined", DEFINED;
  "collision", COLLISION;
  "event", EVENT;
  "time", TIME;
  "end", END;
  "otheruses", OTHERUSES;
  "maxlength", MAXLENGTH;
  "length", LENGTH;
  "max", MAX;
  "newOracle", NEWORACLE;
  "inj", INJ;
  "foreach", FOREACH;
  "do", DO;
  "return", RETURN;
  "define", DEFINE;
  "expand", EXPAND;
  "proof", PROOF
]

}

rule token = parse
  "\010" | "\013" | "\013\010"
     { next_line lexbuf; token lexbuf }
| [ ' ' '\009' '\012' ] +
     { token lexbuf }
| [ '@' 'a'-'z' 'A'-'Z' ] (( [ '@' 'a'-'z' 'A'-'Z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255' '\'' '0'-'9' ] )*)
     { let s = Lexing.lexeme lexbuf in
	 try
	   Hashtbl.find keyword_table s
         with Not_found ->
	   if (not (!accept_arobase)) && (String.contains s '@') then
	     raise IllegalCharacter;
           IDENT (s, extent lexbuf)
     }
| '\"' (( [ ' ' '!' '#'-'[' ']'-'~' '\192'-'\214' '\216'-'\246' '\248'-'\255' ] )*) '\"'
    { let s = Lexing.lexeme lexbuf in
      STRING (String.sub s 1 (String.length s - 2), extent lexbuf)
    } 
| ([ '0'-'9' ]) +
    { 
      try 
        INT (int_of_string(Lexing.lexeme lexbuf))
      with Failure _ ->
	input_error "Incorrect integer" (extent lexbuf)
    }
| ([ '0'-'9' ]) + '.' ([ '0'-'9' ])*
     { FLOAT (float_of_string(Lexing.lexeme lexbuf)) }
| "(*" {
         comment lexbuf;
         token lexbuf
       }
| ',' { COMMA }
| '(' { LPAREN }
| ')' { RPAREN }
| '[' { LBRACKET }
| ']' { RBRACKET }
| '{' { LBRACE }
| '}' { RBRACE }
| '|' { BAR }
| ';' { SEMI }
| ':' { COLON }
| "<=" { LEQ }
| '=' { EQUAL }
| "<>" { DIFF }
| "&&" { AND }
| "||" { OR }
| '.' { DOT }
| "<=(" { EQUIVLEFT }
| ")=>" { EQUIVRIGHT } 
| "==>" { IMPLIES }
| "->" { MAPSTO }
| ":=" { DEF }
| "<-" { LEFTARROW }
| "<-R" { RANDOM }
| '+' { ADD }
| '-' { SUB }
| '*' { MUL }
| '/' { DIV }
| '^' { POWER }
| '#' { COUNT }
| eof { EOF }	
| _ { raise IllegalCharacter }

and comment = parse
| "*)" { }
| "\010" | "\013" | "\013\010"
     { next_line lexbuf; comment lexbuf }
| eof { }
| _ { comment lexbuf }
