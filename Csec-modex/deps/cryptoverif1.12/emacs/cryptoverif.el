;;
;; mode for .cv files 
;;

(defvar cryptoverif-kw '("new" "out" "channel" "if" "then" "else" "find" "orfind" "suchthat" "fun" "param" "forall" "proba" "type" "equiv" "process" "let" "in" "query" "secret" "secret1" "const" "set" "defined" "collision" "event" "time" "yield" "otheruses" "maxlength" "length" "max" "newChannel" "inj" "define" "expand" "proof") "Cryptoverif keywords")

(defvar cryptoverif-builtin '("noninteractive" "bounded" "fixed" "large" "password" "compos" "decompos" "uniform" "commut" "manual" "computational" "unchanged" "exist" "all") "Cryptoverif builtins")

;; build optimal regular expression from list of keywords
;; 'words if for taking full words only, not subwords
(defvar cryptoverif-kw-regexp (regexp-opt cryptoverif-kw 'words))
(defvar cryptoverif-builtin-regexp (regexp-opt cryptoverif-builtin 'words))

(defvar cryptoverif-connectives-regexp "\|\|\\|&&\\|<-\\|==>\\|<=(\\|)=>\\|<=\\|:=")

(setq cryptoverifKeywords
 `((,cryptoverif-kw-regexp . font-lock-keyword-face)
   (,cryptoverif-builtin-regexp . font-lock-builtin-face)
   (,cryptoverif-connectives-regexp . font-lock-reference-face)
  )
)

(define-derived-mode cryptoverif-mode fundamental-mode
  (setq font-lock-defaults '(cryptoverifKeywords))
  (setq mode-name "Cryptoverif")

;; comment highlighting
  (modify-syntax-entry ?\( "()1" cryptoverif-mode-syntax-table)
  (modify-syntax-entry ?\) ")(4" cryptoverif-mode-syntax-table)
  (modify-syntax-entry ?* ". 23" cryptoverif-mode-syntax-table)

;; _ and ' belong to ordinary identifiers
  (modify-syntax-entry ?_ "w" cryptoverif-mode-syntax-table)
  (modify-syntax-entry ?' "w" cryptoverif-mode-syntax-table)
)

;;
;; mode for .ocv files (oracles mode)
;;

(defvar cryptoverifo-kw '("if" "then" "else" "find" "orfind" "suchthat" "fun" "param" "forall" "proba" "type" "equiv" "process" "let" "in" "query" "secret" "secret1" "const" "set" "defined" "collision" "event" "time" "end" "otheruses" "maxlength" "length" "max" "newOracle" "inj" "foreach" "do" "return" "define" "expand" "proof") "Cryptoverif keywords")

(defvar cryptoverifo-builtin '("noninteractive" "bounded" "fixed" "large" "password" "compos" "decompos" "uniform" "commut" "manual" "computational" "unchanged" "exist" "all") "Cryptoverif builtins")

(defvar cryptoverifo-kw-regexp (regexp-opt cryptoverifo-kw 'words))
(defvar cryptoverifo-builtin-regexp (regexp-opt cryptoverifo-builtin 'words))

(defvar cryptoverifo-connectives-regexp "\|\|\\|&&\\|<-R\\|<-\\|==>\\|<=(\\|)=>\\|<=\\|:=\\|<-")

(setq cryptoverifoKeywords
 `((,cryptoverifo-kw-regexp . font-lock-keyword-face)
   (,cryptoverifo-builtin-regexp . font-lock-builtin-face)
   (,cryptoverifo-connectives-regexp . font-lock-reference-face)
  )
)

(define-derived-mode cryptoverifo-mode fundamental-mode
  (setq font-lock-defaults '(cryptoverifoKeywords))
  (setq mode-name "Cryptoverif Oracles")

;; comment highlighting
  (modify-syntax-entry ?\( "()1" cryptoverifo-mode-syntax-table)
  (modify-syntax-entry ?\) ")(4" cryptoverifo-mode-syntax-table)
  (modify-syntax-entry ?* ". 23" cryptoverifo-mode-syntax-table)

;; _ and ' belong to ordinary identifiers
  (modify-syntax-entry ?_ "w" cryptoverifo-mode-syntax-table)
  (modify-syntax-entry ?' "w" cryptoverifo-mode-syntax-table)
)

