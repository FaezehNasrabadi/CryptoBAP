open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open parallelcompositionconcreteTheory;
open interleavingconcreteTheory;
open parallelcompositiondeductionTheory;
open interleavingdeductionTheory;
open derived_rules_deductionTheory;

val _ = new_theory "traceinclusion";

    
val _ = Theory.new_constant("InterpretStOne", ``:'state1 -> 'cstate1``);

val _ = Theory.new_constant("InterpretEvOne", ``:'event1 -> 'cevent1``);

val _ = Theory.new_constant("InterpretStTwo", ``:'state2 -> 'cstate2``);

val _ = Theory.new_constant("InterpretEvTwo", ``:'event2 -> 'cevent2``);

val _ = Theory.new_constant("InterpretEvSyn", ``:'eventS -> 'ceventS``);    

val _ = Theory.new_constant("InterpretRelOne", ``:(( 'event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel # ('pred1) tded) -> ('cevent1 + 'ceventS, 'cstate1) mctrel``);

val _ = Theory.new_constant("InterpretRelTwo", ``:(( 'event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel # ('pred2) tded) -> ( 'cevent2 + 'ceventS, 'cstate2) mctrel``);

val _ = Theory.new_constant("InterpretEvOneSyn", ``:('event1 + 'eventS) option list -> ('cevent1 + 'ceventS) list ``);

val _ = Theory.new_constant("InterpretEvTwoSyn", ``:('event2 + 'eventS) option list -> ('cevent2 + 'ceventS) list ``);

val _ = Theory.new_constant("RevInterpretEvOneSyn", ``:('cevent1 + 'ceventS) list -> ('event1 + 'eventS) option list``);

val _ = Theory.new_constant("RevInterpretEvTwoSyn", ``:('cevent2 + 'ceventS) list -> ('event2 + 'eventS) option list ``);
    
val _ = Theory.new_constant("InterpretEvComp", ``:(('event1+'eventS) + ('event2 +'eventS)) option list -> (('cevent1+'ceventS) + ('cevent2 +'ceventS)) list``);


val applyfunEvOneSyn = new_axiom ("applyfunEvOneSyn",
                                  ``∀t. (InterpretEvOneSyn:('event1 + 'eventS) option list -> ('cevent1 + 'ceventS) list) ((RevInterpretEvOneSyn:('cevent1 + 'ceventS) list -> ('event1 + 'eventS) option list) t) = t``);

val applyfunEvTwoSyn = new_axiom ("applyfunEvTwoSyn",
                            ``∀t. (InterpretEvTwoSyn:('event2 + 'eventS) option list -> ('cevent2 + 'ceventS) list ) ((RevInterpretEvTwoSyn:('cevent2 + 'ceventS) list -> ('event2 + 'eventS) option list) t) = t``);                                  

val binterl_Rev = new_axiom ("binterl_Rev",
                                ``∀t t1 t2.
                                     binterl t1 t2 ((InterpretEvComp:(('event1+'eventS) + ('event2 +'eventS)) option list -> (('cevent1+'ceventS) + ('cevent2 +'ceventS)) list) t) ⇒
                                   (binterl ((RevInterpretEvOneSyn:('cevent1 + 'ceventS) list -> ('event1 + 'eventS) option list) t1) ((RevInterpretEvTwoSyn:('cevent2 + 'ceventS) list -> ('event2 + 'eventS) option list) t2) t)``);
                                   
val subset_one_def = Define `
    subset_one C S = (∀(x: ('event1 + 'eventS) option list). ((InterpretEvOneSyn x):('cevent1 + 'ceventS) list) ∈ C ⇒ x ∈ S)
`;

val subset_two_def = Define `
    subset_two C S = (∀(x: ('event2 + 'eventS) option list). ((InterpretEvTwoSyn x):('cevent2 + 'ceventS) list) ∈ C ⇒ x ∈ S)
                     `;

val subset_comp_def = Define `
    subset_comp C S = (∀(x: (('event1+'eventS) + ('event2 +'eventS)) option list). ((InterpretEvComp x):(('cevent1+'ceventS) + ('cevent2 +'ceventS)) list) ∈ C ⇒ x ∈ S)
                      `;
             
val compose_vs_modules_conc_symb_thm = store_thm(
  "compose_vs_modules_conc_symb_thm",
  ``!Sym Sym' P P' S1 S1' S2 S2' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (Ded1:('pred1) tded) (Ded2:('pred2) tded).
(
     (subset_one
      (traces ((InterpretRelOne:(( 'event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel # ('pred1) tded) -> ('cevent1 + 'ceventS, 'cstate1) mctrel) (MTrn1,Ded1)) ((InterpretStOne:'state1 -> 'cstate1) S1) ((InterpretStOne:'state1 -> 'cstate1) S1'))
      (traces (MTrn1,Ded1) (Sym,(IMAGE OUTL P),S1) (Sym',(IMAGE OUTL P'),S1'))) ∧
     (subset_two
      (traces ((InterpretRelTwo:(( 'event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel # ('pred2) tded) -> ( 'cevent2 + 'ceventS, 'cstate2) mctrel) (MTrn2,Ded2)) ((InterpretStTwo:'state2 -> 'cstate2) S2) ((InterpretStTwo:'state2 -> 'cstate2) S2'))
      (traces (MTrn2,Ded2) (Sym,(IMAGE OUTR P),S2) (Sym',(IMAGE OUTR P'),S2')))
) ==>
(subset_comp
   (comptraces (composeMuRe ((InterpretRelOne:(( 'event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel # ('pred1) tded) -> ('cevent1 + 'ceventS, 'cstate1) mctrel) (MTrn1,Ded1)) ((InterpretRelTwo:(( 'event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel # ('pred2) tded) -> ( 'cevent2 + 'ceventS, 'cstate2) mctrel) (MTrn2,Ded2))) (((InterpretStOne:'state1 -> 'cstate1) S1),((InterpretStTwo:'state2 -> 'cstate2) S2)) (((InterpretStOne:'state1 -> 'cstate1) S1'),((InterpretStTwo:'state2 -> 'cstate2) S2')))
   (comptraces (MTrn1,Ded1) (MTrn2,Ded2) (Sym,P,S1,S2) (Sym',P',S1',S2'))
) ``
  ,
rewrite_tac[binterleave_composition_concrete,binterleave_composition_deduction,interleavingconcreteTheory.binterleave_ts,interleavingdeductionTheory.binterleave_ts,derived_rules_deductionTheory.traces_def,interleavingconcreteTheory.traces_def]>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [subset_one_def,subset_two_def,subset_comp_def]>>
rw[]>>
PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`((RevInterpretEvTwoSyn:('cevent2 + 'ceventS) list -> ('event2 + 'eventS) option list) (t2:(('cevent2+'ceventS) list)))`]))>>
PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`((RevInterpretEvOneSyn:('cevent1 + 'ceventS) list -> ('event1 + 'eventS) option list) (t1:(('cevent1+'ceventS) list)))`]))>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [applyfunEvOneSyn,applyfunEvTwoSyn]>>            
RES_TAC>>
Q.EXISTS_TAC `((RevInterpretEvOneSyn:('cevent1 + 'ceventS) list -> ('event1 + 'eventS) option list) t1)` >>
Q.EXISTS_TAC `((RevInterpretEvTwoSyn:('cevent2 + 'ceventS) list -> ('event2 + 'eventS) option list) t2)` >>       metis_tac[binterl_Rev]
        );  
val _ = export_theory();

