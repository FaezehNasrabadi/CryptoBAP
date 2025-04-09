open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;

val _ = new_theory "parallelcompositionconcrete";

    
(* transition relation *)
val _ = Parse.type_abbrev("ctrel", ``:'state -> 'event -> 'state -> bool``);    

    

val _ = Parse.type_abbrev("ComOpr", 
  ``:('cstate1,'cevent1 + 'ceventS) ctrel ->
  ('cstate2, 'cevent2 + 'ceventS) ctrel -> 
  ('cstate1 # 'cstate2, (('cevent1+'ceventS) + ('cevent2 +'ceventS))) ctrel``);


(* multi transitions relation *)
val _ = Parse.type_abbrev("mctrel", ``:'state -> ('event list) -> 'state -> bool``);


(* compose multi transition relation *)
val _ = Parse.type_abbrev("cmctrel", ``:('cstate1, 'cevent1 + 'ceventS) mctrel ->
  ('cstate2, 'cevent2 + 'ceventS) mctrel -> 
  ('cstate1 # 'cstate2, (('cevent1+'ceventS) + ('cevent2 +'ceventS))) mctrel``);
     

val composeMuRe_def =
Define  `
((composeMuRe (Re1:(('cevent1 + 'ceventS), 'cstate1) mctrel) (Re2:(('cevent2 + 'ceventS), 'cstate2) mctrel) (S1,S2) [] (S1',S2')) =
         (((S1,S2) = (S1',S2'))∧(Re1 S1 [] S1)∧(Re2 S2 [] S2)))  ∧
((composeMuRe (Re1:(('cevent1 + 'ceventS), 'cstate1) mctrel) (Re2:(('cevent2 + 'ceventS), 'cstate2) mctrel) (S1,S2) ((INL (INL (E:'cevent1)))::ev) (S1'',S2')) =
 (∃S1'. (Re1 S1' [INL E] S1'')∧(Re2 S2' [] S2') ∧(composeMuRe Re1 Re2 (S1,S2) ev (S1',S2')))) ∧
((composeMuRe (Re1:(('cevent1 + 'ceventS), 'cstate1) mctrel) (Re2:(('cevent2 + 'ceventS), 'cstate2) mctrel) (S1,S2) ((INR (INL (E:'cevent2)))::ev) (S1',S2'')) =
 (∃S2'. (Re2 S2' [INL E] S2'')∧(Re1 S1' [] S1') ∧(composeMuRe Re1 Re2 (S1,S2) ev (S1',S2')))) ∧
((composeMuRe (Re1:(('cevent1 + 'ceventS), 'cstate1) mctrel) (Re2:(('cevent2 + 'ceventS), 'cstate2) mctrel) (S1,S2) ((INR (INR (E:'ceventS)))::ev) (S1'',S2'')) =
 (∃S1' S2'. (Re1 S1' [INR E] S1'')∧(Re2 S2' [INR E] S2'') ∧ (composeMuRe Re1 Re2 (S1,S2) ev (S1',S2')))) ∧
((composeMuRe (Re1:(('cevent1 + 'ceventS), 'cstate1) mctrel) (Re2:(('cevent2 + 'ceventS), 'cstate2) mctrel) (S1,S2) ((INL (INR (E:'ceventS)))::ev) (S1'',S2'')) =
 (∃S1' S2'. (Re1 S1' [INR E] S1'')∧(Re2 S2' [INR E] S2'')∧ (composeMuRe Re1 Re2 (S1,S2) ev (S1',S2'))))
`;


val _ = set_mapped_fixity { fixity = Infixl 95,
                            term_name = "apply_composeMuRe",
                            tok = "||" };

val _ = overload_on ("apply_composeMuRe", ``composeMuRe``);

val _ = export_theory();

