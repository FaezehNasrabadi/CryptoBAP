open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open parallelcompositiongeneraldeductionTheory;

val _ = new_theory "parallelcompositioncombinededuction";

 
(* predicate of first program language *)
val _ = Datatype `predOne =
Const string 
| Op 'symb string
| EquOne 'symb 'symb
| EquOp 'symb predOne
| NormalP1 'pred1
         `;

(* predicate of second program language *)         
val _ = Datatype `predTwo =
K 'symb 
| EquTwo 'symb 'symb
| NormalP2 'pred2
         `;

(* a set of symbols *)         
val symbols_def =
Define`
      symbols (x:'symb) = {x}
`;


(* Sharing equalities between program languages *)        
val composeDedEqu_def =
Define`
      (composeDedEqu (P3:((('pred1,'symb) predOne) + (('pred2,'symb) predTwo)) set) ((INL ((EquOne (x:'symb) (z:'symb)):(('pred1,'symb) predOne))):((('pred1,'symb) predOne) + (('pred2,'symb) predTwo))) = (∃(y: 'symb). (((EquOne (x:'symb) (y:'symb)):(('pred1,'symb) predOne)) ∈ (PREIMAGE INL P3)) ∧ (((EquTwo (y:'symb) (z:'symb)):(('pred2,'symb) predTwo)) ∈ (PREIMAGE INR P3)))) ∧
(composeDedEqu (P3:((('pred1,'symb) predOne) + (('pred2,'symb) predTwo)) set) (INR ((EquTwo (x:'symb) (z:'symb)):(('pred2,'symb) predTwo))) = (∃(y: 'symb). (((EquOne (x:'symb) (y:'symb)):(('pred1,'symb) predOne)) ∈ (PREIMAGE INL P3)) ∧ (((EquTwo (y:'symb) (z:'symb)):(('pred2,'symb) predTwo)) ∈ (PREIMAGE INR P3))))
`;

(* Generic over-approximation *)        
val composeDedOverApprox_def =
Define`
      composeDedOverApprox (P3:((('pred1,'symb) predOne) + (('pred2,'symb) predTwo)) set) ((INR ((K (z:'symb)):(('pred2,'symb) predTwo))):((('pred1,'symb) predOne) + (('pred2,'symb) predTwo))) = (∃(x:'symb) (y: 'symb). (((K (x:'symb)):(('pred2,'symb) predTwo)) ∈ (PREIMAGE INR P3)) ∧ (((EquOne (x:'symb) (y:'symb)):(('pred1,'symb) predOne)) ∈ (PREIMAGE INL P3)) ∧ (z ∈ (symbols y)))
`;

(* Bitwise reasoning *)        
val composeDedBit_def =
Define`
      composeDedBit (P3:((('pred1,'symb) predOne) + (('pred2,'symb) predTwo)) set) ((INR ((K (y:'symb)):(('pred2,'symb) predTwo))):((('pred1,'symb) predOne) + (('pred2,'symb) predTwo))) = (∃(x:'symb) (c: string). (((K (x:'symb)):(('pred2,'symb) predTwo)) ∈ (PREIMAGE INR P3)) ∧ (((EquOp (y:'symb) (Op x c)):(('pred1,'symb) predOne)) ∈ (PREIMAGE INL P3)) ∧ ((Const c) ∈ (PREIMAGE INL P3)))
`;
       
(* combine all deduction relations *)
val combineAllDed_def =
Define `
       (combineAllDed (ded1:(('pred1,'symb) predOne) tded) (ded2:(('pred2,'symb) predTwo) tded) (P3:((('pred1,'symb) predOne) + (('pred2,'symb) predTwo)) set) (F3:((('pred1,'symb) predOne) + (('pred2,'symb) predTwo))) = (
         (composeDed ded1 ded2 P3 F3) ∨
         (composeDedEqu P3 F3) ∨
         (composeDedOverApprox P3 F3) ∨
         (composeDedBit P3 F3)  
         ))`;
       
 

(* Symbolic Parallel Composition *)
val symbolicParlComp_def =
Define  `
((symbolicParlComp ((Re1:(('event1 + 'eventS), (('pred1,'symb) predOne), 'state1, 'symb) mtrel),(ded1:(('pred1,'symb) predOne) tded)) ((Re2:(('event2 + 'eventS), (('pred2,'symb) predTwo), 'state2, 'symb) mtrel),(ded2:(('pred2,'symb) predTwo) tded)) (Sym,P,S1,S2) [] (Sym',P',S1',S2')) =
 (((Sym,P,S1,S2) = (Sym',P',S1',S2'))∧
  (Re1 (Sym,(PREIMAGE INL P),S1) [] (Sym,(PREIMAGE INL P),S1))∧
  (Re2 (Sym,(PREIMAGE INR P),S2) [] (Sym,(PREIMAGE INR P),S2))))  ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), (('pred1,'symb) predOne), 'state1, 'symb) mtrel),(ded1:(('pred1,'symb) predOne) tded)) ((Re2:(('event2 + 'eventS), (('pred2,'symb) predTwo), 'state2, 'symb) mtrel),(ded2:(('pred2,'symb) predTwo) tded)) (Sym,P,S1,S2) (NONE::ev) (Sym',P',S1',S2')) =
(∃P''.
   (∀phi. (combineAllDed ded1 ded2 P'' phi) ∧ (P'=P''∪{phi})) ∧
  (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P'',S1',S2'))))  ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), (('pred1,'symb) predOne), 'state1, 'symb) mtrel),(ded1:(('pred1,'symb) predOne) tded)) ((Re2:(('event2 + 'eventS), (('pred2,'symb) predTwo), 'state2, 'symb) mtrel),(ded2:(('pred2,'symb) predTwo) tded)) (Sym,P,S1,S2) (SOME(INL (INL (E:'event1)))::ev) (Sym'',P'',S1'',S2')) =
 (∃Sym' P' S1'. (Re1 (Sym',(PREIMAGE INL P'),S1') [SOME(INL E)] (Sym'',(PREIMAGE INL P''),S1''))∧
                ((PREIMAGE INR P') = (PREIMAGE INR P''))∧
                (Re2 (Sym',(PREIMAGE INR P'),S2') [] (Sym'',(PREIMAGE INR P''),S2')) ∧
                (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), (('pred1,'symb) predOne), 'state1, 'symb) mtrel),(ded1:(('pred1,'symb) predOne) tded)) ((Re2:(('event2 + 'eventS), (('pred2,'symb) predTwo), 'state2, 'symb) mtrel),(ded2:(('pred2,'symb) predTwo) tded)) (Sym,P,S1,S2) (SOME(INR (INL (E:'event2)))::ev) (Sym'',P'',S1',S2'')) =
 (∃Sym' P' S2'. (Re2 (Sym',(PREIMAGE INR P'),S2') [SOME(INL E)] (Sym'',(PREIMAGE INR P''),S2''))∧
                ((PREIMAGE INL P') = (PREIMAGE INL P''))∧
                (Re1 (Sym',(PREIMAGE INL P'),S1') [] (Sym'',(PREIMAGE INL P''),S1')) ∧
                (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), (('pred1,'symb) predOne), 'state1, 'symb) mtrel),(ded1:(('pred1,'symb) predOne) tded)) ((Re2:(('event2 + 'eventS), (('pred2,'symb) predTwo), 'state2, 'symb) mtrel),(ded2:(('pred2,'symb) predTwo) tded)) (Sym,P,S1,S2) (SOME(INR (INR (E:'eventS)))::ev) (Sym'',P'',S1'',S2'')) =
 (∃Sym' P' S1' S2'. (Re1 (Sym',(PREIMAGE INL P'),S1') [SOME(INR E)] (Sym'',(PREIMAGE INL P''),S1''))∧
                    (Re2 (Sym',(PREIMAGE INR P'),S2') [SOME(INR E)] (Sym'',(PREIMAGE INR P''),S2'')) ∧
                    (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), (('pred1,'symb) predOne), 'state1, 'symb) mtrel),(ded1:(('pred1,'symb) predOne) tded)) ((Re2:(('event2 + 'eventS), (('pred2,'symb) predTwo), 'state2, 'symb) mtrel),(ded2:(('pred2,'symb) predTwo) tded)) (Sym,P,S1,S2) (SOME(INL (INR (E:'eventS)))::ev) (Sym'',P'',S1'',S2'')) =
 (∃Sym' P' S1' S2'. (Re1 (Sym',(PREIMAGE INL P'),S1') [SOME(INR E)] (Sym'',(PREIMAGE INL P''),S1''))∧
                    (Re2 (Sym',(PREIMAGE INR P'),S2') [SOME(INR E)] (Sym'',(PREIMAGE INR P''),S2''))∧
                    (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2'))))
`;


val _ = set_mapped_fixity { fixity = Infixl 95,
                            term_name = "apply_symbolicParlComp",
                            tok = "||" };

val _ = overload_on ("apply_symbolicParlComp", ``symbolicParlComp``);


val _ = export_theory();

