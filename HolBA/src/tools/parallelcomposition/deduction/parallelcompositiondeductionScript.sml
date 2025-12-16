open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open parallelcompositiongeneraldeductionTheory;

val _ = new_theory "parallelcompositiondeduction";

val symbolicParlComp_def =
Define  `
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) [] (Sym',P',S1',S2')) =
 (((Sym,P,S1,S2) = (Sym',P',S1',S2'))∧
  (Re1 (Sym,(PREIMAGE INL P),S1) [] (Sym,(PREIMAGE INL P),S1))∧
  (Re2 (Sym,(PREIMAGE INR P),S2) [] (Sym,(PREIMAGE INR P),S2))))  ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (NONE::ev) (Sym',P',S1',S2')) =
(∃P''.
   (∀phi. ((composeDed ded1 ded2) P'' phi) ∧ P'=P''∪{phi}) ∧
  (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P'',S1',S2'))))  ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (SOME(INL (INL (E:'event1)))::ev) (Sym'',P'',S1'',S2')) =
 (∃Sym' P' S1'. (Re1 (Sym',(PREIMAGE INL P'),S1') [SOME(INL E)] (Sym'',(PREIMAGE INL P''),S1''))∧
                ((PREIMAGE INR P') = (PREIMAGE INR P''))∧
                (Re2 (Sym',(PREIMAGE INR P'),S2') [] (Sym'',(PREIMAGE INR P''),S2')) ∧
                (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (SOME(INR (INL (E:'event2)))::ev) (Sym'',P'',S1',S2'')) =
 (∃Sym' P' S2'. (Re2 (Sym',(PREIMAGE INR P'),S2') [SOME(INL E)] (Sym'',(PREIMAGE INR P''),S2''))∧
                ((PREIMAGE INL P') = (PREIMAGE INL P''))∧
                (Re1 (Sym',(PREIMAGE INL P'),S1') [] (Sym'',(PREIMAGE INL P''),S1')) ∧
                (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (SOME(INR (INR (E:'eventS)))::ev) (Sym'',P'',S1'',S2'')) =
 (∃Sym' P' S1' S2'. (Re1 (Sym',(PREIMAGE INL P'),S1') [SOME(INR E)] (Sym'',(PREIMAGE INL P''),S1''))∧
                    (Re2 (Sym',(PREIMAGE INR P'),S2') [SOME(INR E)] (Sym'',(PREIMAGE INR P''),S2'')) ∧
                    (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (SOME(INL (INR (E:'eventS)))::ev) (Sym'',P'',S1'',S2'')) =
 (∃Sym' P' S1' S2'. (Re1 (Sym',(PREIMAGE INL P'),S1') [SOME(INR E)] (Sym'',(PREIMAGE INL P''),S1''))∧
                    (Re2 (Sym',(PREIMAGE INR P'),S2') [SOME(INR E)] (Sym'',(PREIMAGE INR P''),S2''))∧
                    (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2'))))
`;


val _ = set_mapped_fixity { fixity = Infixl 95,
                            term_name = "apply_symbolicParlComp",
                            tok = "||" };

val _ = overload_on ("apply_symbolicParlComp", ``symbolicParlComp``);


val _ = export_theory();

