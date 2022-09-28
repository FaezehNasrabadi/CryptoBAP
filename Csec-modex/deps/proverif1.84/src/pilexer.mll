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
{
open Parsing_helper
open Piparser

let create_hashtable size init =
  let tbl = Hashtbl.create size in
  List.iter (fun (key,data) -> Hashtbl.add tbl key data) init;
  tbl

(* Untyped front-end *)

let keyword_table =
  create_hashtable 11
[ "data", DATA;
  "param", PARAM;
  "private", PRIVATE;
(* Common keywords *)
  "new", NEW;
  "out", OUT;
  "in", IN;
  "if", IF;
  "then", THEN;
  "else", ELSE;
  "fun", FUN;
  "equation", EQUATION;
  "reduc", REDUCTION;
  "pred", PREDICATE;
  "process", PROCESS;
  "let", LET;
  "query", QUERY;
  "putbegin", PUTBEGIN;
  "noninterf", NONINTERF;
  "event", EVENT;
  "not", NOT;
  "elimtrue", ELIMTRUE;
  "free", FREE;
  "clauses", CLAUSES;
  "suchthat", SUCHTHAT;
  "nounif", NOUNIF;
  "phase", PHASE;
  "among", AMONG;
  "weaksecret", WEAKSECRET;
  "choice", CHOICE ]

}

rule token = parse
  "\010" | "\013" | "\013\010"
     { next_line lexbuf; token lexbuf }
| [ ' ' '\009' '\012' ] +
     { token lexbuf }
| [ 'a'-'z' 'A'-'Z' ] (( [ 'a'-'z' 'A'-'Z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255' '\'' '0'-'9' ] )*)
     { let s = Lexing.lexeme lexbuf in
	 try
	   Hashtbl.find keyword_table s
         with
           Not_found ->
             IDENT (s, extent lexbuf)
     }
| ([ '0'-'9' ]) +
     { INT (int_of_string(Lexing.lexeme lexbuf)) }
| "(*" {
         comment lexbuf;
         token lexbuf
       }
| ',' { COMMA }
| '(' { LPAREN }
| ')' { RPAREN }
| '[' { LBRACKET }
| ']' { RBRACKET }
| '|' { BAR }
| ';' { SEMI }
| '!' { REPL }
| '=' { EQUAL }
| '/' { SLASH }
| '.' { DOT }
| '*' { STAR }
| ':' { COLON }
| '&' { WEDGE }
| "->" { RED } 
| "<->" { EQUIV } 
| "<=>" { EQUIVEQ } 
| "<>" { DIFF }
| "==>" { BEFORE }
| eof { EOF }	
| _ { input_error "Illegal character" (extent lexbuf) }

and comment = parse
| "*)" { }
| "\010" | "\013" | "\013\010"
     { next_line lexbuf; comment lexbuf }
| eof { }
| _ { comment lexbuf }
