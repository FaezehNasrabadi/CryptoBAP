type token =
  | COMMA
  | LPAREN
  | RPAREN
  | LBRACKET
  | RBRACKET
  | SEMI
  | COLON
  | IDENT of (Ptree.ident)
  | INT of (int)
  | RED
  | EQUIV
  | EQUIVEQ
  | EQUAL
  | FUN
  | EQUATION
  | QUERY
  | NOUNIF
  | SLASH
  | STAR
  | DOT
  | WEDGE
  | EOF
  | NOT
  | ELIMTRUE
  | DIFF
  | PREDICATE
  | REDUCTION
  | DATA
  | PARAM
  | CLAUSES
  | CONST
  | SET
  | NAME
  | TYPE
  | FORALL

open Parsing;;
let _ = parse_error;;
# 2 "parser.mly"
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
# 31 "parser.mly"

open Parsing_helper
open Ptree
exception Syntax

# 75 "parser.ml"
let yytransl_const = [|
  257 (* COMMA *);
  258 (* LPAREN *);
  259 (* RPAREN *);
  260 (* LBRACKET *);
  261 (* RBRACKET *);
  262 (* SEMI *);
  263 (* COLON *);
  266 (* RED *);
  267 (* EQUIV *);
  268 (* EQUIVEQ *);
  269 (* EQUAL *);
  270 (* FUN *);
  271 (* EQUATION *);
  272 (* QUERY *);
  273 (* NOUNIF *);
  274 (* SLASH *);
  275 (* STAR *);
  276 (* DOT *);
  277 (* WEDGE *);
    0 (* EOF *);
  278 (* NOT *);
  279 (* ELIMTRUE *);
  280 (* DIFF *);
  281 (* PREDICATE *);
  282 (* REDUCTION *);
  283 (* DATA *);
  284 (* PARAM *);
  285 (* CLAUSES *);
  286 (* CONST *);
  287 (* SET *);
  288 (* NAME *);
  289 (* TYPE *);
  290 (* FORALL *);
    0|]

let yytransl_block = [|
  264 (* IDENT *);
  265 (* INT *);
    0|]

let yylhs = "\255\255\
\003\000\003\000\003\000\003\000\005\000\005\000\004\000\004\000\
\006\000\006\000\007\000\007\000\007\000\007\000\007\000\009\000\
\009\000\008\000\008\000\010\000\010\000\011\000\011\000\012\000\
\012\000\013\000\013\000\013\000\013\000\014\000\014\000\015\000\
\015\000\016\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\017\000\017\000\017\000\
\018\000\018\000\018\000\018\000\019\000\019\000\020\000\021\000\
\021\000\022\000\022\000\023\000\023\000\024\000\024\000\002\000\
\002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\000\000\000\000"

let yylen = "\002\000\
\004\000\003\000\004\000\001\000\003\000\001\000\001\000\000\000\
\003\000\001\000\004\000\003\000\004\000\001\000\002\000\003\000\
\001\000\001\000\000\000\002\000\000\000\001\000\000\000\003\000\
\003\000\003\000\001\000\003\000\003\000\003\000\001\000\003\000\
\002\000\003\000\006\000\006\000\006\000\004\000\005\000\004\000\
\004\000\007\000\006\000\006\000\003\000\004\000\001\000\003\000\
\003\000\001\000\003\000\003\000\003\000\001\000\004\000\005\000\
\003\000\003\000\000\000\004\000\003\000\003\000\000\000\004\000\
\006\000\010\000\007\000\007\000\006\000\004\000\007\000\005\000\
\006\000\004\000\006\000\004\000\008\000\005\000\006\000\006\000\
\003\000\002\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\082\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\083\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\007\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\033\000\000\000\000\000\000\000\
\045\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\081\000\000\000\000\000\000\000\000\000\000\000\
\000\000\002\000\000\000\000\000\000\000\024\000\025\000\038\000\
\000\000\000\000\000\000\000\000\034\000\018\000\020\000\000\000\
\040\000\041\000\000\000\000\000\030\000\032\000\026\000\028\000\
\029\000\000\000\000\000\000\000\000\000\022\000\000\000\058\000\
\000\000\000\000\000\000\048\000\070\000\000\000\000\000\000\000\
\000\000\000\000\074\000\000\000\076\000\000\000\000\000\000\000\
\000\000\000\000\000\000\061\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\064\000\000\000\005\000\001\000\003\000\
\000\000\000\000\000\000\000\000\015\000\000\000\039\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\055\000\072\000\000\000\000\000\000\000\000\000\062\000\
\078\000\000\000\053\000\060\000\049\000\051\000\052\000\000\000\
\000\000\000\000\000\000\035\000\037\000\012\000\000\000\000\000\
\016\000\000\000\036\000\043\000\044\000\009\000\000\000\000\000\
\056\000\069\000\000\000\073\000\075\000\000\000\000\000\079\000\
\080\000\065\000\011\000\013\000\042\000\000\000\068\000\071\000\
\000\000\067\000\000\000\077\000\000\000\066\000"

let yydgoto = "\003\000\
\014\000\027\000\050\000\069\000\070\000\150\000\132\000\133\000\
\134\000\079\000\151\000\040\000\041\000\042\000\043\000\036\000\
\051\000\113\000\114\000\054\000\052\000\061\000\062\000\110\000"

let yysindex = "\105\000\
\214\255\170\255\000\000\019\255\022\255\058\255\048\255\058\255\
\058\255\063\255\058\255\072\255\075\255\000\000\085\255\069\255\
\077\255\089\255\077\255\077\255\092\255\069\255\110\255\137\255\
\147\255\155\255\000\000\126\255\022\255\066\255\165\255\136\255\
\159\255\174\255\181\255\172\255\185\255\206\255\217\255\211\255\
\008\255\138\255\227\000\220\255\231\255\243\255\242\255\022\255\
\167\255\227\255\232\255\247\255\013\255\172\255\248\255\235\255\
\250\255\239\255\252\255\112\255\079\255\004\001\254\255\249\255\
\001\000\245\255\002\000\006\000\007\000\000\000\022\255\022\255\
\022\255\022\255\022\255\214\255\067\255\003\000\251\255\214\255\
\214\255\004\000\058\255\058\255\000\000\058\255\058\255\058\255\
\000\000\005\000\119\255\008\000\010\000\012\000\009\000\022\255\
\011\000\022\255\170\255\079\255\067\255\013\000\015\000\170\255\
\079\255\170\255\079\255\008\000\008\000\014\000\168\255\255\255\
\016\255\186\255\000\000\016\000\125\255\017\000\170\255\018\000\
\022\255\000\000\023\000\022\000\019\000\000\000\000\000\000\000\
\067\255\171\255\020\000\028\000\000\000\000\000\000\000\214\255\
\000\000\000\000\008\000\211\255\000\000\000\000\000\000\000\000\
\000\000\021\000\024\000\025\000\029\000\000\000\032\000\000\000\
\022\255\033\000\030\000\000\000\000\000\026\000\034\000\170\255\
\038\000\172\255\000\000\027\000\000\000\031\000\039\000\043\000\
\170\255\079\255\069\255\000\000\079\255\079\255\079\255\045\000\
\035\000\036\000\037\000\000\000\214\255\000\000\000\000\000\000\
\214\255\040\000\067\255\067\255\000\000\067\255\000\000\041\000\
\214\255\214\255\214\255\008\000\046\000\042\000\000\000\242\255\
\170\255\000\000\000\000\044\000\170\255\170\255\045\000\000\000\
\000\000\255\255\000\000\000\000\000\000\000\000\000\000\047\000\
\170\255\170\255\170\255\000\000\000\000\000\000\051\000\053\000\
\000\000\214\255\000\000\000\000\000\000\000\000\052\000\170\255\
\000\000\000\000\170\255\000\000\000\000\048\000\170\255\000\000\
\000\000\000\000\000\000\000\000\000\000\045\000\000\000\000\000\
\170\255\000\000\050\000\000\000\170\255\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\080\255\
\000\000\000\000\000\000\000\000\000\000\080\255\000\000\000\000\
\000\000\000\000\000\000\000\000\056\000\041\255\000\000\253\255\
\000\000\000\000\000\000\054\000\000\000\000\000\000\000\141\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\070\255\000\000\000\000\000\000\000\000\054\000\000\000\000\000\
\000\000\000\000\000\000\055\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\201\255\000\000\000\000\056\000\058\000\
\000\000\213\255\000\000\000\000\200\255\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\062\000\000\000\000\000\000\000\056\000\
\000\000\000\000\000\000\000\000\063\000\000\000\000\000\000\000\
\000\000\000\000\000\000\062\000\000\000\000\000\053\255\237\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\063\000\030\255\000\000\020\255\000\000\000\000\000\000\000\000\
\000\000\000\000\057\000\198\255\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\029\255\000\000\000\000\000\000\
\000\000\000\000\065\000\000\000\000\000\000\000\000\000\000\000\
\000\000\054\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\080\255\000\000\000\000\000\000\000\000\055\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\063\000\064\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\099\255\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\055\000\000\000\
\000\000\205\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\055\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\192\255\163\255\093\000\203\255\167\000\152\255\000\000\164\255\
\116\000\209\255\158\255\049\000\000\000\225\000\244\000\000\000\
\240\255\000\000\159\000\229\000\238\255\062\001\164\000\088\255"

let yytablesize = 335
let yytable = "\055\000\
\057\000\059\000\056\000\058\000\168\000\157\000\102\000\216\000\
\159\000\167\000\163\000\128\000\165\000\084\000\101\000\137\000\
\138\000\123\000\124\000\097\000\126\000\171\000\017\000\029\000\
\017\000\180\000\028\000\085\000\094\000\030\000\014\000\010\000\
\014\000\010\000\014\000\172\000\186\000\017\000\238\000\017\000\
\192\000\004\000\154\000\004\000\112\000\004\000\004\000\014\000\
\010\000\014\000\004\000\004\000\004\000\004\000\034\000\035\000\
\037\000\038\000\047\000\029\000\004\000\004\000\047\000\047\000\
\047\000\032\000\203\000\071\000\129\000\072\000\039\000\191\000\
\047\000\047\000\130\000\209\000\004\000\251\000\029\000\044\000\
\029\000\059\000\045\000\158\000\049\000\131\000\111\000\059\000\
\164\000\047\000\166\000\230\000\046\000\004\000\223\000\224\000\
\053\000\031\000\033\000\060\000\033\000\033\000\047\000\033\000\
\046\000\001\000\002\000\234\000\046\000\046\000\046\000\236\000\
\237\000\108\000\204\000\109\000\220\000\063\000\046\000\046\000\
\221\000\068\000\001\000\240\000\241\000\242\000\147\000\148\000\
\227\000\228\000\229\000\140\000\177\000\178\000\143\000\144\000\
\145\000\071\000\247\000\072\000\095\000\248\000\074\000\067\000\
\064\000\250\000\027\000\086\000\087\000\088\000\031\000\031\000\
\031\000\210\000\065\000\252\000\213\000\214\000\215\000\254\000\
\027\000\245\000\066\000\068\000\068\000\125\000\068\000\127\000\
\096\000\096\000\072\000\072\000\187\000\097\000\188\000\033\000\
\033\000\073\000\033\000\033\000\033\000\233\000\075\000\015\000\
\016\000\017\000\018\000\077\000\068\000\078\000\156\000\019\000\
\020\000\076\000\021\000\173\000\174\000\175\000\022\000\023\000\
\024\000\025\000\026\000\006\000\080\000\006\000\006\000\031\000\
\031\000\031\000\006\000\006\000\006\000\068\000\054\000\054\000\
\054\000\019\000\008\000\019\000\006\000\006\000\008\000\008\000\
\008\000\081\000\089\000\004\000\005\000\006\000\007\000\083\000\
\008\000\008\000\082\000\008\000\009\000\090\000\010\000\011\000\
\012\000\013\000\050\000\091\000\092\000\198\000\054\000\054\000\
\054\000\093\000\098\000\099\000\100\000\103\000\104\000\105\000\
\050\000\107\000\106\000\115\000\116\000\117\000\121\000\118\000\
\119\000\122\000\120\000\135\000\139\000\146\000\136\000\149\000\
\097\000\152\000\155\000\170\000\004\000\153\000\161\000\176\000\
\179\000\183\000\184\000\189\000\190\000\196\000\200\000\182\000\
\160\000\169\000\197\000\199\000\202\000\181\000\185\000\101\000\
\193\000\207\000\222\000\194\000\195\000\201\000\205\000\208\000\
\109\000\225\000\206\000\141\000\231\000\243\000\217\000\218\000\
\219\000\244\000\008\000\246\000\226\000\232\000\008\000\235\000\
\023\000\019\000\239\000\249\000\019\000\253\000\057\000\142\000\
\211\000\021\000\063\000\162\000\023\000\048\000\212\000"

let yycheck = "\018\000\
\019\000\020\000\019\000\020\000\109\000\099\000\054\000\176\000\
\101\000\108\000\104\000\076\000\106\000\006\001\002\001\080\000\
\081\000\071\000\072\000\007\001\074\000\006\001\003\001\002\001\
\005\001\119\000\008\001\020\001\047\000\008\001\001\001\003\001\
\003\001\005\001\005\001\020\001\129\000\018\001\207\000\020\001\
\139\000\001\001\096\000\003\001\061\000\005\001\006\001\018\001\
\020\001\020\001\010\001\011\001\012\001\013\001\006\000\008\001\
\008\000\009\000\006\001\002\001\020\001\021\001\010\001\011\001\
\012\001\008\001\160\000\002\001\002\001\004\001\008\001\136\000\
\020\001\021\001\008\001\169\000\024\001\246\000\002\001\008\001\
\002\001\002\001\008\001\100\000\008\001\019\001\008\001\008\001\
\105\000\020\001\107\000\196\000\008\001\024\001\187\000\188\000\
\008\001\005\000\006\000\008\001\008\000\009\000\034\001\011\000\
\006\001\001\000\002\000\201\000\010\001\011\001\012\001\205\000\
\206\000\002\001\162\000\004\001\181\000\008\001\020\001\021\001\
\185\000\029\000\024\001\217\000\218\000\219\000\008\001\009\001\
\193\000\194\000\195\000\083\000\008\001\009\001\086\000\087\000\
\088\000\002\001\232\000\004\001\048\000\235\000\007\001\018\001\
\008\001\239\000\006\001\010\001\011\001\012\001\010\001\011\001\
\012\001\170\000\008\001\249\000\173\000\174\000\175\000\253\000\
\020\001\226\000\008\001\071\000\072\000\073\000\074\000\075\000\
\002\001\002\001\004\001\004\001\002\001\007\001\004\001\083\000\
\084\000\013\001\086\000\087\000\088\000\200\000\024\001\014\001\
\015\001\016\001\017\001\007\001\096\000\018\001\098\000\022\001\
\023\001\020\001\025\001\010\001\011\001\012\001\029\001\030\001\
\031\001\032\001\033\001\003\001\020\001\005\001\006\001\010\001\
\011\001\012\001\010\001\011\001\012\001\121\000\010\001\011\001\
\012\001\018\001\006\001\020\001\020\001\021\001\010\001\011\001\
\012\001\020\001\000\000\014\001\015\001\016\001\017\001\021\001\
\020\001\021\001\018\001\022\001\023\001\018\001\025\001\026\001\
\027\001\028\001\006\001\013\001\002\001\153\000\010\001\011\001\
\012\001\008\001\024\001\020\001\006\001\006\001\020\001\006\001\
\020\001\006\001\020\001\000\000\007\001\013\001\001\001\007\001\
\020\001\003\001\009\001\009\001\009\001\009\001\020\001\008\001\
\007\001\006\001\008\001\021\001\024\001\013\001\008\001\008\001\
\008\001\003\001\005\001\008\001\001\001\001\001\001\001\121\000\
\020\001\020\001\003\001\003\001\003\001\020\001\020\001\002\001\
\020\001\003\001\003\001\020\001\020\001\020\001\020\001\005\001\
\004\001\190\000\020\001\083\000\007\001\003\001\020\001\020\001\
\020\001\005\001\003\001\008\001\020\001\020\001\005\001\020\001\
\003\001\003\001\020\001\020\001\005\001\020\001\006\001\084\000\
\170\000\020\001\020\001\103\000\020\001\016\000\171\000"

let yynames_const = "\
  COMMA\000\
  LPAREN\000\
  RPAREN\000\
  LBRACKET\000\
  RBRACKET\000\
  SEMI\000\
  COLON\000\
  RED\000\
  EQUIV\000\
  EQUIVEQ\000\
  EQUAL\000\
  FUN\000\
  EQUATION\000\
  QUERY\000\
  NOUNIF\000\
  SLASH\000\
  STAR\000\
  DOT\000\
  WEDGE\000\
  EOF\000\
  NOT\000\
  ELIMTRUE\000\
  DIFF\000\
  PREDICATE\000\
  REDUCTION\000\
  DATA\000\
  PARAM\000\
  CLAUSES\000\
  CONST\000\
  SET\000\
  NAME\000\
  TYPE\000\
  FORALL\000\
  "

let yynames_block = "\
  IDENT\000\
  INT\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'termseq) in
    Obj.repr(
# 93 "parser.mly"
 ( PFunApp (_1, _3) )
# 393 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'termseq) in
    Obj.repr(
# 95 "parser.mly"
 ( PTuple _2 )
# 400 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'termseq) in
    Obj.repr(
# 97 "parser.mly"
 ( PName(_1, _3) )
# 408 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ptree.ident) in
    Obj.repr(
# 99 "parser.mly"
 ( PIdent (_1) )
# 415 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'term) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'netermseq) in
    Obj.repr(
# 103 "parser.mly"
 ( _1 :: _3 )
# 423 "parser.ml"
               : 'netermseq))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'term) in
    Obj.repr(
# 105 "parser.mly"
 ( [_1] )
# 430 "parser.ml"
               : 'netermseq))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'netermseq) in
    Obj.repr(
# 109 "parser.mly"
        ( _1 )
# 437 "parser.ml"
               : 'termseq))
; (fun __caml_parser_env ->
    Obj.repr(
# 111 "parser.mly"
 ( [] )
# 443 "parser.ml"
               : 'termseq))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'neidentseq) in
    Obj.repr(
# 115 "parser.mly"
        ( _1 :: _3 )
# 451 "parser.ml"
               : 'neidentseq))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ptree.ident) in
    Obj.repr(
# 117 "parser.mly"
 ( [_1] )
# 458 "parser.ml"
               : 'neidentseq))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'formatseq) in
    Obj.repr(
# 121 "parser.mly"
 ( PFFunApp (_1, _3) )
# 466 "parser.ml"
               : 'format))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'formatseq) in
    Obj.repr(
# 123 "parser.mly"
 ( PFTuple _2 )
# 473 "parser.ml"
               : 'format))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'formatseq) in
    Obj.repr(
# 125 "parser.mly"
 ( PFName(_1, _3) )
# 481 "parser.ml"
               : 'format))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ptree.ident) in
    Obj.repr(
# 127 "parser.mly"
 ( PFIdent (_1) )
# 488 "parser.ml"
               : 'format))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Ptree.ident) in
    Obj.repr(
# 129 "parser.mly"
        ( PFAny (_2) )
# 495 "parser.ml"
               : 'format))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'format) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'neformatseq) in
    Obj.repr(
# 133 "parser.mly"
 ( _1 :: _3 )
# 503 "parser.ml"
               : 'neformatseq))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'format) in
    Obj.repr(
# 135 "parser.mly"
 ( [_1] )
# 510 "parser.ml"
               : 'neformatseq))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'neformatseq) in
    Obj.repr(
# 139 "parser.mly"
        ( _1 )
# 517 "parser.ml"
               : 'formatseq))
; (fun __caml_parser_env ->
    Obj.repr(
# 141 "parser.mly"
 ( [] )
# 523 "parser.ml"
               : 'formatseq))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 145 "parser.mly"
        ( _2 )
# 530 "parser.ml"
               : 'optint))
; (fun __caml_parser_env ->
    Obj.repr(
# 147 "parser.mly"
        ( -1 )
# 536 "parser.ml"
               : 'optint))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'neidentseq) in
    Obj.repr(
# 151 "parser.mly"
        ( _1 )
# 543 "parser.ml"
               : 'identseq))
; (fun __caml_parser_env ->
    Obj.repr(
# 153 "parser.mly"
        ( [] )
# 549 "parser.ml"
               : 'identseq))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'termseq) in
    Obj.repr(
# 159 "parser.mly"
 ( PSimpleFact(_1,_3), parse_extent() )
# 557 "parser.ml"
               : 'fact))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'term) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'term) in
    Obj.repr(
# 161 "parser.mly"
        ( PSNeq(_1,_3), parse_extent() )
# 565 "parser.ml"
               : 'fact))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'termand) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'fact) in
    Obj.repr(
# 165 "parser.mly"
        ( Clause(_1,_3) )
# 573 "parser.ml"
               : 'rule))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'fact) in
    Obj.repr(
# 167 "parser.mly"
        ( Clause([],_1) )
# 580 "parser.ml"
               : 'rule))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'termand) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'fact) in
    Obj.repr(
# 169 "parser.mly"
        ( Equiv(_1,_3,true) )
# 588 "parser.ml"
               : 'rule))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'termand) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'fact) in
    Obj.repr(
# 171 "parser.mly"
        ( Equiv(_1,_3,false) )
# 596 "parser.ml"
               : 'rule))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'fact) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'termand) in
    Obj.repr(
# 175 "parser.mly"
 ( _1 :: _3 )
# 604 "parser.ml"
               : 'termand))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'fact) in
    Obj.repr(
# 177 "parser.mly"
 ( [_1] )
# 611 "parser.ml"
               : 'termand))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rule) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'reduc) in
    Obj.repr(
# 181 "parser.mly"
 ( _1 :: _3 )
# 619 "parser.ml"
               : 'reduc))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'rule) in
    Obj.repr(
# 183 "parser.mly"
 ( [_1] )
# 626 "parser.ml"
               : 'reduc))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'formatseq) in
    Obj.repr(
# 187 "parser.mly"
 ( (_1,_3) )
# 634 "parser.ml"
               : 'factformat))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 191 "parser.mly"
        ( (FunDecl(_2, _4)) :: _6 )
# 643 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 193 "parser.mly"
        ( (DataFunDecl(_2, _4)) :: _6 )
# 652 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'term) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'term) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 195 "parser.mly"
        ( (Equation(_2, _4)) :: _6 )
# 661 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'fact) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 197 "parser.mly"
        ( (Query _2) :: _4 )
# 669 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'factformat) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'optint) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 199 "parser.mly"
        ( (NoUnif (_2,_3)) :: _5 )
# 678 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'fact) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 201 "parser.mly"
        ( (Not _2) :: _4 )
# 686 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'fact) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 203 "parser.mly"
        ( (Elimtrue _2) :: _4 )
# 694 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : int) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'identseq) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 205 "parser.mly"
        ( (PredDecl(_2, _4, _5)) :: _7 )
# 704 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : Ptree.ident) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 207 "parser.mly"
        ( (Param(_2,S _4)) :: _6 )
# 713 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.decl list) in
    Obj.repr(
# 209 "parser.mly"
        ( (Param(_2,I _4)) :: _6 )
# 722 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'reduc) in
    Obj.repr(
# 211 "parser.mly"
 ( [Reduc(_2)] )
# 729 "parser.ml"
               : Ptree.decl list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'termseq) in
    Obj.repr(
# 217 "parser.mly"
 ( PSimpleFact(_1,_3), parse_extent() )
# 737 "parser.ml"
               : 'tfact))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ptree.ident) in
    Obj.repr(
# 219 "parser.mly"
        ( PSimpleFact(_1,[]), parse_extent() )
# 744 "parser.ml"
               : 'tfact))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'term) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'term) in
    Obj.repr(
# 221 "parser.mly"
        ( PSNeq(_1,_3), parse_extent() )
# 752 "parser.ml"
               : 'tfact))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'ttermand) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'tfact) in
    Obj.repr(
# 225 "parser.mly"
        ( Clause(_1,_3) )
# 760 "parser.ml"
               : 'trule))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'tfact) in
    Obj.repr(
# 227 "parser.mly"
        ( Clause([],_1) )
# 767 "parser.ml"
               : 'trule))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'ttermand) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'tfact) in
    Obj.repr(
# 229 "parser.mly"
        ( Equiv(_1,_3,true) )
# 775 "parser.ml"
               : 'trule))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'ttermand) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'tfact) in
    Obj.repr(
# 231 "parser.mly"
        ( Equiv(_1,_3,false) )
# 783 "parser.ml"
               : 'trule))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'tfact) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'ttermand) in
    Obj.repr(
# 235 "parser.mly"
 ( _1 :: _3 )
# 791 "parser.ml"
               : 'ttermand))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'tfact) in
    Obj.repr(
# 237 "parser.mly"
 ( [_1] )
# 798 "parser.ml"
               : 'ttermand))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'formatseq) in
    Obj.repr(
# 241 "parser.mly"
 ( (_1,_3) )
# 806 "parser.ml"
               : 'tfactformat))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : Ptree.ident) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'nevartype) in
    Obj.repr(
# 245 "parser.mly"
        ( (_1,_3)::_5 )
# 815 "parser.ml"
               : 'nevartype))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ptree.ident) in
    Obj.repr(
# 248 "parser.mly"
        ( [(_1,_3)] )
# 823 "parser.ml"
               : 'nevartype))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'nevartype) in
    Obj.repr(
# 252 "parser.mly"
        ( _2 )
# 830 "parser.ml"
               : 'forallvartype))
; (fun __caml_parser_env ->
    Obj.repr(
# 254 "parser.mly"
        ( [] )
# 836 "parser.ml"
               : 'forallvartype))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'forallvartype) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'trule) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'treduc) in
    Obj.repr(
# 258 "parser.mly"
 ( (_1,_2) :: _4 )
# 845 "parser.ml"
               : 'treduc))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'forallvartype) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'trule) in
    Obj.repr(
# 260 "parser.mly"
 ( [_1,_2] )
# 853 "parser.ml"
               : 'treduc))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'neidentseq) in
    Obj.repr(
# 264 "parser.mly"
        ( _2 )
# 860 "parser.ml"
               : 'options))
; (fun __caml_parser_env ->
    Obj.repr(
# 266 "parser.mly"
        ( [] )
# 866 "parser.ml"
               : 'options))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 270 "parser.mly"
        ( TTypeDecl(_2) :: _4 )
# 874 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : Ptree.ident) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 272 "parser.mly"
        ( TNameDecl(_2,_4) :: _6 )
# 883 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 8 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 6 : 'identseq) in
    let _7 = (Parsing.peek_val __caml_parser_env 3 : Ptree.ident) in
    let _8 = (Parsing.peek_val __caml_parser_env 2 : 'options) in
    let _10 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 274 "parser.mly"
        ( (TFunDecl(_2, _4, _7, _8)) :: _10 )
# 894 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : Ptree.ident) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'options) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 276 "parser.mly"
        ( (TConstDecl(_2, _4, _5)) :: _7 )
# 904 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'forallvartype) in
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'term) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'term) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 278 "parser.mly"
        ( (TEquation(_2, _3, _5)) :: _7 )
# 914 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'nevartype) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'tfact) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 280 "parser.mly"
        ( (TQuery(_2, _4)) :: _6 )
# 923 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'tfact) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 282 "parser.mly"
        ( (TQuery([], _2)) :: _4 )
# 931 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'nevartype) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'tfactformat) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'optint) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 284 "parser.mly"
        ( (TNoUnif (_2, _4,_5)) :: _7 )
# 941 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'tfactformat) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'optint) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 286 "parser.mly"
        ( (TNoUnif ([],_2,_3)) :: _5 )
# 950 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'nevartype) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'tfact) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 288 "parser.mly"
        ( (TNot(_2,_4)) :: _6 )
# 959 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'tfact) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 290 "parser.mly"
        ( (TNot([],_2)) :: _4 )
# 967 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'nevartype) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'tfact) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 292 "parser.mly"
        ( (TElimtrue(_2,_4)) :: _6 )
# 976 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'tfact) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 294 "parser.mly"
        ( (TElimtrue([],_2)) :: _4 )
# 984 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 6 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 4 : 'identseq) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : 'options) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 296 "parser.mly"
        ( (TPredDecl(_2, _4, _6)) :: _8 )
# 994 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : Ptree.ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'options) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 298 "parser.mly"
        ( (TPredDecl(_2, [], _3)) :: _5 )
# 1003 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : Ptree.ident) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 300 "parser.mly"
        ( (TSet(_2,S _4)) :: _6 )
# 1012 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : Ptree.ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ptree.tdecl list) in
    Obj.repr(
# 302 "parser.mly"
        ( (TSet(_2,I _4)) :: _6 )
# 1021 "parser.ml"
               : Ptree.tdecl list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'treduc) in
    Obj.repr(
# 304 "parser.mly"
 ( [TReduc(_2)] )
# 1028 "parser.ml"
               : Ptree.tdecl list))
(* Entry all *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry tall *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let all (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ptree.decl list)
let tall (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 2 lexfun lexbuf : Ptree.tdecl list)
