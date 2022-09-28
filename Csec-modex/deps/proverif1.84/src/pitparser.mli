type token =
  | CHOICE
  | STAR
  | COMMA
  | LPAREN
  | RPAREN
  | LBRACKET
  | RBRACKET
  | BAR
  | SEMI
  | NEW
  | OUT
  | IN
  | IDENT of (Pitptree.ident)
  | STRING of (Pitptree.ident)
  | INT of (int)
  | REPL
  | IF
  | THEN
  | ELSE
  | EQUAL
  | FUN
  | EQUATION
  | REDUCTION
  | PREDICATE
  | PROCESS
  | SLASH
  | DOT
  | EOF
  | LET
  | QUERY
  | BEFORE
  | PUTBEGIN
  | NONINTERF
  | EVENT
  | NOT
  | ELIMTRUE
  | FREE
  | SUCHTHAT
  | CLAUSES
  | RED
  | EQUIV
  | EQUIVEQ
  | WEDGE
  | DIFF
  | COLON
  | NOUNIF
  | PHASE
  | AMONG
  | WEAKSECRET
  | PARAM
  | TYPE
  | SET
  | FORALL
  | CONST
  | INJEVENT
  | OR
  | CHANNEL
  | LETFUN
  | DEFINE
  | EXPAND
  | YIELD
  | LEQ
  | PROBA
  | LBRACE
  | RBRACE
  | PROOF
  | TABLE
  | INSERT
  | GET

val all :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Pitptree.tdecl list * Pitptree.tprocess
val lib :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Pitptree.tdecl list
