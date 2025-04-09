open HolKernel Parse boolLib bossLib;
open messagesTheory;
open synceventsTheory;
open listTheory;

val _ = new_theory "dolevyao";


(* Dolev-Yao predicates *)
val _ = Datatype `DYpred =
K SapicTerm_t (* Adversary can deduce term *)
| Fr SapicTerm_t (* Term is fresh *)
| DotEqu (SapicTerm_t # SapicTerm_t) (* both terms *)
| AliEqu (Var_t # SapicTerm_t) (* both terms *)
      `;
    
(* val _ = Theory.new_constant("eqE", ``:SapicTerm_t -> SapicTerm_t -> bool``); *)


Inductive eqE:
[~ref:]
  (∀(t:SapicTerm_t). (eqE t t)) /\
[~sym:]
(∀(t1:SapicTerm_t) (t2:SapicTerm_t). (eqE t1 t2) ==> (eqE t2 t1)) /\
[~tran:]
(∀(t1:SapicTerm_t) (t2:SapicTerm_t) (t3:SapicTerm_t). ((eqE t1 t2)  /\ (eqE t2 t3) )==> (eqE t1 t3)) 
End        
    
val eqE_not = new_axiom ("eqE_not",
                               ``(∀(t1:SapicTerm_t) (t2:SapicTerm_t). (t1 ≠ t2) ==> (¬(eqE t1 t2)))``);

(* Dolev-Yao deduction relation *)
val (DYdeduction_rules, DYdeduction_ind, DYdeduction_cases)
= Hol_reln
  `(∀(p:DYpred) (Pi: DYpred set). (p ∈ Pi) ==> (DYdeduction Pi p)) ∧
  (∀(n:SapicTerm_t) (Pi: DYpred set). (n = (Con (Name (PubName:NameTag_t) (str:string)))) ==> (DYdeduction Pi (K n))) ∧
(∀(sig:(string # (int # Privacy_t # Constructability_t))) (tl:SapicTerm_t list) (Pi: DYpred set). (EVERY (DYdeduction Pi) (MAP K tl)) ==> (DYdeduction Pi (K (FAPP sig tl)))) ∧
(∀(t1:SapicTerm_t) (t2:SapicTerm_t) (Pi: DYpred set). ((DYdeduction Pi (K t1)) ∧ (DYdeduction Pi (DotEqu (t1,t2)))) ==> (DYdeduction Pi (K t2))) ∧
(∀(n1:SapicTerm_t) (n2:SapicTerm_t) (Pi: DYpred set). ((DYdeduction Pi (Fr n1)) ∧ (DYdeduction Pi (DotEqu (n1,n2)))) ==> (DYdeduction Pi (Fr n2))) ∧
(∀(t1:SapicTerm_t) (t2:SapicTerm_t) (v:Var_t) (Pi: DYpred set). ((DYdeduction Pi (K t1)) ∧ (DYdeduction Pi (AliEqu (v,t2)))) ==> (DYdeduction Pi (K (sapic_substvar v t2 t1)))) ∧
(∀(t1:SapicTerm_t) (t2:SapicTerm_t) (Pi: DYpred set). (eqE t1 t2) ==> (DYdeduction Pi (DotEqu (t1,t2)))) 
`;

(* Dolev-Yao non-synchronous events *)        
val _ = Datatype
        `DYnsyc_event =
Silent Name_t
| Ded DYpred
| Alias (Var_t # SapicTerm_t)
        `;

        
(* Dolev-Yao state *)
val _ = Datatype
        `DYstate =
ESt       (* empty state *)
`;
          
        
(* Dolev-Yao transition relation *)
val DYtranrel_def =
Define` 
      (DYtranrel (Sym,Pi,ESt) (SOME (INR (P2A Y))) (Sym',Pi',ESt) = ((Y ∉ Sym) ∧ (Pi' = Pi∪{K (TVar Y)}) ∧ (Sym = Sym'))) ∧
      (DYtranrel (Sym,Pi,ESt) (SOME (INL (Alias (X',Y')))) (Sym',Pi',ESt) = ((X' ∉ Sym) ∧ (Sym' = Sym∪{X'}) ∧ (Pi' = Pi∪{AliEqu(X',Y')}))) ∧
      (DYtranrel (Sym,Pi,ESt) (SOME (INR (Crypto (S,XL,Y)))) (Sym',Pi',ESt) = ((EVERY Sym XL) ∧ (Y ∉ Sym) ∧ (Sym' = Sym∪{Y}) ∧ (Pi' = Pi∪{AliEqu(Y,(FAPP S (MAP TVar XL)))}))) ∧
      (DYtranrel (Sym,Pi,ESt) (SOME (INR (A2P X))) (Sym',Pi',ESt) = ((K (TVar X) ∈ Pi) ∧ (Pi = Pi') ∧ (Sym = Sym'))) ∧
      (DYtranrel (Sym,Pi,ESt) (SOME (INL (Silent n))) (Sym',Pi',ESt) = ((Fr (Con n) ∉ Pi ) ∧ (Pi' = Pi∪{(Fr (Con n));(K (Con n))}) ∧ (Sym = Sym'))) ∧
      (DYtranrel (Sym,Pi,ESt) (SOME (INR (Sync_Fr n'))) (Sym',Pi',ESt) = ((Fr (Con n') ∉ Pi ) ∧ (Pi' = Pi∪{Fr (Con n')}) ∧ (Sym = Sym'))) ∧
      (DYtranrel (Sym,Pi,ESt) (SOME (INL (Ded p))) (Sym',Pi',ESt) = ((Pi' = Pi∪{p}) ∧ (DYdeduction Pi p) ∧ (Sym = Sym'))) ∧
      (DYtranrel (Sym,Pi,ESt) (NONE) (Sym',Pi',ESt) = ((Pi = Pi') ∧ (Sym = Sym')))
`;                                      


(* Dolev-Yao multi transition relation *)
Inductive DYmultranrel:
[~nil:]
  (DYmultranrel ((Sym:(Var_t -> bool)),(P:(DYpred -> bool)),ESt) ([]:(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event) option list) ((Sym:(Var_t -> bool)),(P:(DYpred -> bool)),ESt)) /\
[~move:]
  (
  ((DYmultranrel ((Sym:(Var_t -> bool)),(P:(DYpred -> bool)),ESt) (ev:(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event) option list) ((Sym'':(Var_t -> bool)),(P'':(DYpred -> bool)),ESt)) /\
   (DYtranrel ((Sym'':(Var_t -> bool)),(P'':(DYpred -> bool)),ESt) (e:(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event) option) ((Sym':(Var_t -> bool)),(P':(DYpred -> bool)),ESt))) ==>
  ((DYmultranrel ((Sym:(Var_t -> bool)),(P:(DYpred -> bool)),ESt) ((e::ev):(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event) option list) ((Sym':(Var_t -> bool)),(P':(DYpred -> bool)),ESt)))
  )
End

val DYmultranrel_single = new_axiom ("DYmultranrel_single",
                                     ``∀e Sym Sym' P P'.
                                              (DYmultranrel ((Sym:(Var_t -> bool)),(P:(DYpred -> bool)),ESt) ([e]:(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event) option list) ((Sym':(Var_t -> bool)),(P':(DYpred -> bool)),ESt)) =
  (DYtranrel ((Sym:(Var_t -> bool)),(P:(DYpred -> bool)),ESt) (e:(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event) option) ((Sym':(Var_t -> bool)),(P':(DYpred -> bool)),ESt)) ``);
                                                 
val _ = export_theory();
