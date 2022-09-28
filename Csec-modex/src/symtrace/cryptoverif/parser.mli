type token =
  | COMMA
  | LPAREN
  | RPAREN
  | LBRACKET
  | RBRACKET
  | BAR
  | SEMI
  | COLON
  | NEW
  | OUT
  | IN
  | IDENT of (Ptree.ident)
  | STRING of (Ptree.ident)
  | INT of (int)
  | FLOAT of (float)
  | REPL
  | LEQ
  | IF
  | THEN
  | ELSE
  | FIND
  | ORFIND
  | SUCHTHAT
  | DEFINED
  | EQUAL
  | DIFF
  | FUN
  | FORALL
  | PARAM
  | PROBA
  | TYPE
  | PROCESS
  | DOT
  | EOF
  | LET
  | QUERY
  | SECRET
  | SECRET1
  | AND
  | OR
  | CONST
  | CHANNEL
  | EQUIV
  | EQUIVLEFT
  | EQUIVRIGHT
  | MAPSTO
  | DEF
  | MUL
  | DIV
  | ADD
  | SUB
  | POWER
  | SET
  | COLLISION
  | EVENT
  | IMPLIES
  | TIME
  | YIELD
  | OTHERUSES
  | MAXLENGTH
  | LENGTH
  | MAX
  | COUNT
  | NEWCHANNEL
  | INJ
  | DEFINE
  | EXPAND
  | LBRACE
  | RBRACE
  | PROOF

val all :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ptree.decl list * Ptree.process_e
val lib :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ptree.decl list
val instruct :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ptree.process_e
val term :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ptree.term_e
val allowed_coll :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> ((Ptree.ident * int) list * Ptree.ident option) list
