open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;

val _ = new_theory "parallelcompositiondeduction";

    
(* transition relation *)
val _ = Parse.type_abbrev("trel", ``:(('symb set) # ('pred set) # 'state) -> ('event option) -> (('symb set) # ('pred set) # 'state) -> bool``);    

    
(* deduction relation *)    
val _ = Parse.type_abbrev("tded", ``:('pred set) -> 'pred -> bool``);

                               

(* compose deduction relation *)
val _ = Parse.type_abbrev("ctded", ``:('pred1) tded -> ('pred2) tded -> ('pred1 + 'pred2) tded``);

val composeDed_def =
Define`
      (composeDed (ded1:('pred1) tded) (ded2:('pred2) tded) (P3:('pred1 + 'pred2) set) (INL (F1:'pred1)) = (ded1 (IMAGE OUTL P3) F1)) ∧
(composeDed (ded1:('pred1) tded) (ded2:('pred2) tded) (P3:('pred1 + 'pred2) set) (INR (F2:'pred2)) = (ded2 (IMAGE OUTR P3) F2))
`;

(* multi transitions relation *)
val _ = Parse.type_abbrev("mtrel", ``:(('symb set) # ('pred set) # 'state) -> (('event option) list) -> (('symb set) # ('pred set) # 'state) -> bool``);

(* multi transitions system *)    
val _ = Parse.type_abbrev("multransys", ``:(( 'symb, 'pred, 'state, 'event ) mtrel # ('pred) tded)``);


(* compose multi transition relation *)
val _ = Parse.type_abbrev("cmtrel", ``:('symb, 'pred1, 'state1, 'event1 + 'eventS) mtrel ->
  ('symb, 'pred2, 'state2, 'event2 + 'eventS) mtrel -> 
  ('symb, 'pred1 + 'pred2, 'state1 # 'state2, (('event1+'eventS) + ('event2 +'eventS))) mtrel``);
  


val symbolicParlComp_def =
Define  `
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) [] (Sym',P',S1',S2')) =
 (((Sym,P,S1,S2) = (Sym',P',S1',S2'))∧
  (Re1 (Sym,(IMAGE OUTL P),S1) [] (Sym,(IMAGE OUTL P),S1))∧
  (Re2 (Sym,(IMAGE OUTR P),S2) [] (Sym,(IMAGE OUTR P),S2))))  ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (NONE::ev) (Sym',P',S1',S2')) =
(∃P''.
   (∀phi. ((composeDed ded1 ded2) P'' phi) ∧ P'=P''∪{phi}) ∧
  (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P'',S1',S2'))))  ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (SOME(INL (INL (E:'event1)))::ev) (Sym'',P'',S1'',S2')) =
 (∃Sym' P' S1'. (Re1 (Sym',(IMAGE OUTL P'),S1') [SOME(INL E)] (Sym'',(IMAGE OUTL P''),S1''))∧
                ((IMAGE OUTR P') = (IMAGE OUTR P''))∧
                (Re2 (Sym',(IMAGE OUTR P'),S2') [] (Sym'',(IMAGE OUTR P''),S2')) ∧
                (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (SOME(INR (INL (E:'event2)))::ev) (Sym'',P'',S1',S2'')) =
 (∃Sym' P' S2'. (Re2 (Sym',(IMAGE OUTR P'),S2') [SOME(INL E)] (Sym'',(IMAGE OUTR P''),S2''))∧
                ((IMAGE OUTL P') = (IMAGE OUTL P''))∧
                (Re1 (Sym',(IMAGE OUTL P'),S1') [] (Sym'',(IMAGE OUTL P''),S1')) ∧
                (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (SOME(INR (INR (E:'eventS)))::ev) (Sym'',P'',S1'',S2'')) =
 (∃Sym' P' S1' S2'. (Re1 (Sym',(IMAGE OUTL P'),S1') [SOME(INR E)] (Sym'',(IMAGE OUTL P''),S1''))∧
                    (Re2 (Sym',(IMAGE OUTR P'),S2') [SOME(INR E)] (Sym'',(IMAGE OUTR P''),S2'')) ∧
                    (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((symbolicParlComp ((Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) (Sym,P,S1,S2) (SOME(INL (INR (E:'eventS)))::ev) (Sym'',P'',S1'',S2'')) =
 (∃Sym' P' S1' S2'. (Re1 (Sym',(IMAGE OUTL P'),S1') [SOME(INR E)] (Sym'',(IMAGE OUTL P''),S1''))∧
                    (Re2 (Sym',(IMAGE OUTR P'),S2') [SOME(INR E)] (Sym'',(IMAGE OUTR P''),S2''))∧
                    (symbolicParlComp (Re1,ded1) (Re2,ded2) (Sym,P,S1,S2) ev (Sym',P',S1',S2'))))
`;


val _ = set_mapped_fixity { fixity = Infixl 95,
                            term_name = "apply_symbolicParlComp",
                            tok = "||" };

val _ = overload_on ("apply_symbolicParlComp", ``symbolicParlComp``);


val _ = export_theory();

