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
open Lexing

let internal_error mess =
  print_string ("Internal error: " ^ mess ^ "\nPlease report bug to Bruno.Blanchet@ens.fr, including input file and output\n");
  exit 3

(* extent, for error messages *)

type extent = Lexing.position * Lexing.position

let dummy_ext = (Lexing.dummy_pos, Lexing.dummy_pos)

let merge_ext (p1,_) (_,p2) = (p1,p2)

let next_line lexbuf =
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with 
			 pos_bol = lexbuf.lex_curr_p.pos_cnum;
			 pos_lnum = lexbuf.lex_curr_p.pos_lnum + 1 }

let extent lexbuf = 
  (Lexing.lexeme_start_p lexbuf,
   Lexing.lexeme_end_p lexbuf)

let parse_extent () =
  (Parsing.symbol_start_pos(),
   Parsing.symbol_end_pos())

let input_error mess (loc_start, loc_end) =
  if loc_start.pos_cnum = -1 then
    Printf.printf "Error: %s\n" mess
  else
(*
    Printf.printf "File \"%s\", line %d, column %d, character %d - line %d, column %d, character %d:\nError: %s\n"
      loc_start.pos_fname
      loc_start.pos_lnum (loc_start.pos_cnum - loc_start.pos_bol) loc_start.pos_cnum
      loc_end.pos_lnum loc_end.loc_column loc_end.pos_cnum
      mess

    Printf.printf "File \"%s\", line %d, characters %d-%d:\nError: %s\n"
      loc_start.pos_fname
      loc_start.pos_lnum (loc_start.pos_cnum - loc_start.pos_bol+1) (loc_start.loc_column + 1 + loc_end.loc_char - loc_start.loc_char)
      mess
*)
    Printf.printf "File \"%s\", line %d, character %d - line %d, character %d:\nError: %s\n"
      loc_start.pos_fname
      loc_start.pos_lnum (loc_start.pos_cnum - loc_start.pos_bol +1)
      loc_end.pos_lnum (loc_end.pos_cnum - loc_end.pos_bol+1)
      mess;
  exit 2

let input_warning mess (loc_start, loc_end) =
  if loc_start.pos_cnum = -1 then
    Printf.printf "Warning: %s\n" mess
  else
    Printf.printf "File \"%s\", line %d, character %d - line %d, character %d:\nWarning: %s\n"
      loc_start.pos_fname
      loc_start.pos_lnum (loc_start.pos_cnum - loc_start.pos_bol +1)
      loc_end.pos_lnum (loc_end.pos_cnum - loc_end.pos_bol+1)
      mess


let user_error mess =
  print_string mess;
  exit 2

