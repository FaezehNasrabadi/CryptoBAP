open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;

val _ = new_theory "parallelcompositionsimple";

    
(* transition relation *)
val _ = Parse.type_abbrev("trel", ``:(('symb set) # ('pred set) # 'state) -> 'event -> (('symb set) # ('pred set) # 'state) -> bool``);    

    
(* deduction relation *)    
val _ = Parse.type_abbrev("tded", ``:('pred set) -> 'pred -> bool``);
   
    
(* transition system *)    
val _ = Parse.type_abbrev("transitionsystem", ``:(( 'symb, 'pred, 'state, 'event ) trel # ('pred) tded)``);


val _ = Parse.type_abbrev("ComOpr", 
  ``:('symb, 'pred1, 'state1, 'event1 + 'eventS) transitionsystem ->
  ('symb, 'pred2, 'state2, 'event2 + 'eventS) transitionsystem -> 
  ('symb, 'pred1 + 'pred2, 'state1 # 'state2, (('event1+'eventS) + ('event2 +'eventS))) transitionsystem``);


(* compose deduction relation *)
val _ = Parse.type_abbrev("ctded", ``:('pred1) tded -> ('pred2) tded -> ('pred1 + 'pred2) tded``);

val composeDed_def =
Define`
      (composeDed (ded1:('pred1) tded) (ded2:('pred2) tded) (P3:('pred1 + 'pred2) set) (INL (F1:'pred1)) = (ded1 (IMAGE OUTL P3) F1)) ∧
(composeDed (ded1:('pred1) tded) (ded2:('pred2) tded) (P3:('pred1 + 'pred2) set) (INR (F2:'pred2)) = (ded2 (IMAGE OUTR P3) F2))
`;



(* multi transitions relation *)
val _ = Parse.type_abbrev("mtrel", ``:(('symb set) # ('pred set) # 'state) -> ('event list) -> (('symb set) # ('pred set) # 'state) -> bool``);

(* multi transitions system *)    
val _ = Parse.type_abbrev("multransys", ``:(( 'symb, 'pred, 'state, 'event ) mtrel # ('pred) tded)``);


(* compose multi transition relation *)
val _ = Parse.type_abbrev("cmtrel", ``:('symb, 'pred1, 'state1, 'event1 + 'eventS) mtrel ->
  ('symb, 'pred2, 'state2, 'event2 + 'eventS) mtrel -> 
  ('symb, 'pred1 + 'pred2, 'state1 # 'state2, (('event1+'eventS) + ('event2 +'eventS))) mtrel``);


val composeMuRe_def =
Define  `
((composeMuRe (Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel) (Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel) (Sym,P,S1,S2) [] (Sym',P',S1',S2')) =
         (((Sym,P,S1,S2) = (Sym',P',S1',S2'))∧(Re1 (Sym,(IMAGE OUTL P),S1) [] (Sym,(IMAGE OUTL P),S1))∧(Re2 (Sym,(IMAGE OUTR P),S2) [] (Sym,(IMAGE OUTR P),S2))))  ∧
((composeMuRe (Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel) (Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel) (Sym,P,S1,S2) ((INL (INL (E:'event1)))::ev) (Sym'',P'',S1'',S2')) =
 (∃Sym' P' S1'. (Re1 (Sym',(IMAGE OUTL P'),S1') [INL E] (Sym'',(IMAGE OUTL P''),S1''))∧((IMAGE OUTR P') = (IMAGE OUTR P''))∧(Re2 (Sym',(IMAGE OUTR P'),S2') [] (Sym'',(IMAGE OUTR P''),S2')) ∧(composeMuRe Re1 Re2 (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((composeMuRe (Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel) (Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel) (Sym,P,S1,S2) ((INR (INL (E:'event2)))::ev) (Sym'',P'',S1',S2'')) =
 (∃Sym' P' S2'. (Re2 (Sym',(IMAGE OUTR P'),S2') [INL E] (Sym'',(IMAGE OUTR P''),S2''))∧((IMAGE OUTL P') = (IMAGE OUTL P''))∧(Re1 (Sym',(IMAGE OUTL P'),S1') [] (Sym'',(IMAGE OUTL P''),S1')) ∧(composeMuRe Re1 Re2 (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((composeMuRe (Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel) (Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel) (Sym,P,S1,S2) ((INR (INR (E:'eventS)))::ev) (Sym'',P'',S1'',S2'')) =
 (∃Sym' P' S1' S2'. (Re1 (Sym',(IMAGE OUTL P'),S1') [INR E] (Sym'',(IMAGE OUTL P''),S1''))∧(Re2 (Sym',(IMAGE OUTR P'),S2') [INR E] (Sym'',(IMAGE OUTR P''),S2'')) ∧ (composeMuRe Re1 Re2 (Sym,P,S1,S2) ev (Sym',P',S1',S2')))) ∧
((composeMuRe (Re1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel) (Re2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel) (Sym,P,S1,S2) ((INL (INR (E:'eventS)))::ev) (Sym'',P'',S1'',S2'')) =
 (∃Sym' P' S1' S2'. (Re1 (Sym',(IMAGE OUTL P'),S1') [INR E] (Sym'',(IMAGE OUTL P''),S1''))∧(Re2 (Sym',(IMAGE OUTR P'),S2') [INR E] (Sym'',(IMAGE OUTR P''),S2''))∧ (composeMuRe Re1 Re2 (Sym,P,S1,S2) ev (Sym',P',S1',S2'))))
`;


(* compose multi transition system *)
val _ = Parse.type_abbrev("MulComOpr", 
  ``:('symb, 'pred1, 'state1, 'event1 + 'eventS) multransys ->
  ('symb, 'pred2, 'state2, 'event2 + 'eventS) multransys -> 
  ('symb, 'pred1 + 'pred2, 'state1 # 'state2, (('event1+'eventS) + ('event2 +'eventS))) multransys``);

val composeMultiOperation_def =
Define`
      (composeMultiOperation ((rel1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1:('pred1) tded)) ((rel2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2:('pred2) tded)) = (composeMuRe rel1 rel2, composeDed ded1 ded2): ('symb, 'pred1 + 'pred2, 'state1 # 'state2, (('event1+'eventS) + ('event2 +'eventS))) multransys)
      `;   

val _ = set_mapped_fixity { fixity = Infixl 95,
                            term_name = "apply_composeMultiOperation",
                            tok = "||" };

val _ = overload_on ("apply_composeMultiOperation", ``composeMultiOperation``);


val _ = export_theory();

