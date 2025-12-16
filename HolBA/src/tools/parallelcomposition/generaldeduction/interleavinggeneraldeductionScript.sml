open HolKernel Parse boolLib bossLib;
open metisLib;
open sumTheory;
open pred_setTheory;
open listTheory;
open parallelcompositiongeneraldeductionTheory;
open pairTheory wordsTheory;
open quantHeuristicsTheory;
open boolTheory;
open tautLib;
open optionTheory;
open rich_listTheory;
     
val _ = new_theory "interleavinggeneraldeduction";

                                                                      
(* Binary interleaving of traces *)
Inductive binterl:
[~nil:]
  (binterl [] [] []) /\
[~none:]
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t1' = (NONE::t1)) /\ (t2' = (NONE::t2)) /\ (t' = (NONE::t))) ==> (binterl t1' t2' t')) /\
[~combinenone:]
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t' = (NONE::t))) ==> (binterl t1 t2 t')) /\
[~left:]
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t1' = (SOME (INL e1)::t1)) /\ (t' = (SOME (INL (INL e1))::t))) ==> (binterl t1' t2 t')) /\
[~right:]                                                                        
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t2' = (SOME (INL e2)::t2)) /\ (t' = (SOME (INR (INL e2))::t))) ==> (binterl t1 t2' t')) /\
[~leftN:]
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t1' = (SOME (INL e1)::t1)) /\ (t2' = (NONE::t2)) /\ (t' = (SOME (INL (INL e1))::t))) ==> (binterl t1' t2' t')) /\
[~rightN:]                                                                        
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t1' = (NONE::t1)) /\ (t2' = (SOME (INL e2)::t2)) /\ (t' = (SOME (INR (INL e2))::t))) ==> (binterl t1' t2' t')) /\
[~syncR:]                                                                        
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t1' = (SOME (INR e)::t1)) /\ (t2' = (SOME (INR e)::t2)) /\ (t' = (SOME (INR (INR e))::t))) ==> (binterl t1' t2' t')) /\
[~syncL:]                                                                        
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t1' = (SOME (INR e)::t1)) /\ (t2' = (SOME (INR e)::t2)) /\ (t' = (SOME (INL (INR e))::t))) ==> (binterl t1' t2' t')) /\
[~movesL:]                                                                        
  ((binterl (SOME (INL e1)::(t1:('event1 + 'eventS) option list)) (t2:('event2 + 'eventS) option list) (SOME (INL (INL e1))::t)) ==> (binterl t1 t2 t)) /\
[~movesR:]                                                                        
  ((binterl (t1:('event1 + 'eventS) option list) (SOME (INL e2)::(t2:('event2 + 'eventS) option list)) (SOME (INR (INL e2))::t)) ==> (binterl t1 t2 t)) /\
[~movesSL:]                                                                        
  ((binterl (SOME (INR e)::(t1:('event1 + 'eventS) option list)) (SOME (INR e)::(t2:('event2 + 'eventS) option list)) (SOME (INL (INR e))::t)) ==> (binterl t1 t2 t)) /\
[~movesSR:]                                                                        
  ((binterl (SOME (INR e)::(t1:('event1 + 'eventS) option list)) (SOME (INR e)::(t2:('event2 + 'eventS) option list)) (SOME (INR (INR e))::t)) ==> (binterl t1 t2 t)) /\
[~moveF:]
  (((binterl t1 t2 t) ∧ (binterl [h1] [h2] [h])) ==> (binterl ((h1::t1):('event1 + 'eventS) option list) ((h2::t2):('event2 + 'eventS) option list) (h::t))) /\
[~movecombinenone:]                                                                        
  ((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) (NONE::t)) ==> (binterl t1 t2 t))
End

Definition binterleave_ts:
  binterleave_ts ts1 ts2 = {t| ∃t1 t2. (t1 ∈ ts1) ∧ (t2 ∈ ts2) ∧ (binterl t1 t2 t)}
End

val TransDisable_def =
Define`TransDisable (ded3:('pred1 + 'pred2) tded) ((MTrn1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1: 'pred1 tded)) ((MTrn2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2: 'pred2 tded)) =
(∀Sym P S1 S2 Sym' P' S1' S2' t1 t2 phi.
                         ((MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL P',S1')) ∧
                          (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR P',S2')) ∧
                          (combineAllDed ded1 ded2 ded3 P' phi)) ⇒
                          ((MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL (P' ∪ {phi}),S1')) ∧
                           (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR (P' ∪ {phi}),S2'))))
        `;

val TransEnable_def =
Define`TransEnable (ded3:('pred1 + 'pred2) tded) ((MTrn1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1: 'pred1 tded)) ((MTrn2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2: 'pred2 tded)) =
(∀Sym P S1 S2 Sym' P' S1' S2' t1 t2 phi.
   ((MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL (P' ∪ {phi}),S1')) ∧
    (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR (P' ∪ {phi}),S2')) ∧
    (combineAllDed ded1 ded2 ded3 P' phi)) ⇒
   ((MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL P',S1')) ∧
    (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR P',S2'))))
`;
   
    
val doubleLeftMTrn_def =
Define`
      doubleLeftMTrn (MTrn:('event + 'eventS, 'pred, 'state, 'symb) mtrel) (v,(p: ('predL + 'pred) -> bool),(c:'stateL),s) (t:(('event + 'eventS)+('eventL + 'eventS)) option list) (v',(p': ('predL + 'pred) -> bool),(c':'stateL),s')  = (MTrn (v,(PREIMAGE INR p),s) (MAP (OPTION_MAP OUTL) t) (v',(PREIMAGE INR p'),s'))
`;

val doubleRightMTrn_def =
Define`
      doubleRightMTrn (MTrn:('event + 'eventS, 'pred, 'state, 'symb) mtrel) (v,(p: ('pred + 'predR) -> bool),s,(c:'stateR)) (t:(('event + 'eventS)+('eventR + 'eventS)) option list) (v',(p': ('pred + 'predR) -> bool),s',(c':'stateR))  = (MTrn (v,(PREIMAGE INL p),s) (MAP (OPTION_MAP OUTL) t) (v',(PREIMAGE INL p'),s'))
`;


val doubleLeftDed_def =
Define `
       (doubleLeftDed (ded: ('pred) tded) (p: ('predL + 'pred) -> bool) (phi: ('predL + 'pred))  =  (ded (PREIMAGE INR p) (OUTR phi))
       )`;  
        
val doubleRightDed_def =
Define `
       (doubleRightDed (ded: ('pred) tded) (p: ('pred + 'predR) -> bool) (phi: ('pred + 'predR))  =  (ded (PREIMAGE INL p) (OUTL phi))
       )`;


val pred_sum_map_def = Define`
  pred_sum_map
    (x : ('pred1 + 'pred2) + ('pred1 + 'pred2) + 'pred3)
    : (('pred1 + 'pred2 + 'pred3) + 'pred2 + 'pred3) =
  case x of
      (* first ('pred1 + 'pred2) *)
      INL (INL (ll:'pred1))           => INL (INL ll)                 
    | INL (INR (lr:'pred2))           => INL (INR (INL lr))           

      (* second ('pred1 + 'pred2) *)
    | INR (INL (INL (rll:'pred1)))    => INL (INL rll)                
    | INR (INL (INR (rlr:'pred2)))    => INR (INL rlr)                

      (* trailing 'pred3 *)
    | INR (INR (rr:'pred3))           => INR (INR rr)                 
`;



val prSum_def = Define`
  prSum
    (P : (('pred1 + 'pred2) + ('pred1 + 'pred2) + 'pred3) -> bool)
    : (('pred1 + 'pred2 + 'pred3) + 'pred2 + 'pred3) -> bool =
  IMAGE pred_sum_map P
`;


val prSumRev_def = Define`
  prSumRev
    (Q : (('pred1 + 'pred2 + 'pred3) + 'pred2 + 'pred3) -> bool)
    : (('pred1 + 'pred2) + ('pred1 + 'pred2) + 'pred3) -> bool =
  PREIMAGE pred_sum_map Q
`;
        

val SUM_PREIMAGE_CHAR = store_thm
                        ("SUM_PREIMAGE_CHAR",
                         ``!P P' : ('a + 'b) set.
                                   (PREIMAGE INL P = PREIMAGE INL P') /\
                                   (PREIMAGE INR P = PREIMAGE INR P')
                                   ==> P = P'``,
                                             REPEAT GEN_TAC THEN STRIP_TAC THEN
                         FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[EXTENSION] THEN
                         GEN_TAC THEN
                         Cases_on `x` THEN
                         rw[]); 
        
val pred_sum_map_INJ = new_axiom ("pred_sum_map_INJ",``∀x y. pred_sum_map x = pred_sum_map y ⇒ x = y``);        

val prSum_Eq = store_thm
               ("prSum_Eq",
                ``∀P P'. P = P' ⇔ prSum P = prSum P'``,
                                                  REPEAT STRIP_TAC >>
                   EQ_TAC >-
                    (rw [EXTENSION, prSum_def, IMAGE_DEF]) >>
                   rw [EXTENSION, prSum_def, IMAGE_DEF] >>
                   EQ_TAC >- (
                    STRIP_TAC >>
                    PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [‘pred_sum_map x’]))  >>
                    IMP_RES_TAC EQ_IMP_THM >>
                    rw[] >>
                    IMP_RES_TAC  pred_sum_map_INJ >>
                    rw[]) >>
                   STRIP_TAC >>
                   PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [‘pred_sum_map x’]))  >>
                   IMP_RES_TAC EQ_IMP_THM >>
                   rw[] >>
                   IMP_RES_TAC  pred_sum_map_INJ >>
                   rw[]);
                          

val Rev_prSum = store_thm
                ("Rev_prSum",
                 ``∀P. prSumRev (prSum P) = P``,
                                             rpt STRIP_TAC >>
                    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[prSum_def, prSumRev_def, IMAGE_DEF, PREIMAGE_def,EXTENSION] >>
                    GEN_TAC >>
                    metis_tac[pred_sum_map_INJ]
                );


val binterl_Empty = new_axiom ("binterl_Empty",
                               ``∀t1 t2. binterl t1 t2 [] ⇒ ((t1 = []) ∧(t2 = []))``);
                              

val binterl_moveSL = new_axiom ("binterl_moveSL",
                                ``∀e t t1 t2.
                                     binterl t1 t2 (SOME (INL (INR e))::t) ⇒
                                   (∃t1' t2'. (t1 = SOME (INR e)::t1') ∧(t2 = SOME (INR e)::t2'))``);
                                   
val binterl_moveSR = new_axiom ("binterl_moveSR",
                                ``∀e t t1 t2.
                                     binterl t1 t2 (SOME (INR (INR e))::t) ⇒
                                   (∃t1' t2'. (t1 = SOME (INR e)::t1') ∧(t2 = SOME (INR e)::t2'))``);
                                    
val binterl_moveAL = new_axiom ("binterl_moveAL",
                               ``∀e1 t t1 t2.
                                     binterl t1 t2 (SOME (INL (INL e1))::t) ⇒
                                  (∃t1'. (t1 = SOME (INL e1)::t1'))``);
                                  

val binterl_moveALN = new_axiom ("binterl_moveALN",
                               ``∀e1.
                                     binterl [SOME (INL e1)] [NONE] [SOME (INL (INL e1))] =
                                  (binterl [] [] [])``);

val binterl_moveSLN = new_axiom ("binterl_moveSLN",
                               ``∀e2.
                                     binterl [NONE] [SOME (INR e2)] [SOME (INL (INR e2))] =
                                  (binterl [] [] [])``);

val binterl_moveSRN = new_axiom ("binterl_moveSRN",
                                 ``∀e2.                                  
                                      binterl [NONE] [SOME (INR e2)] [SOME (INR (INR e2))] =
                                    (binterl [] [] [])``);

val binterl_moveARN = new_axiom ("binterl_moveARN",
                               ``∀e2.
binterl [NONE] [SOME (INL e2)] [SOME (INR (INL e2))] =
                                  (binterl [] [] [])``);

val binterl_moveNONE = new_axiom ("binterl_moveNONE",
                                ``∀e t t1 t2.
                                     binterl t1 t2 (NONE::t) ⇒
                                   (∃t1' t2'. (t1 = NONE::t1') ∧(t2 = NONE::t2'))``);

val binterl_moveNAR = new_axiom ("binterl_moveNAR",
                                 ``∀e2 t t1 t2.
                                       binterl t1 t2 (SOME (INR (INL e2))::t) ⇒
                                    (∃t1' t2'. (t2 = SOME (INL e2)::t2') ∧ (t1 = NONE::t1'))``);

val binterl_moveNAL = new_axiom ("binterl_moveNAL",
                               ``∀e1 t t1 t2.
                                     binterl t1 t2 (SOME (INL (INL e1))::t) ⇒
                                  (∃t1' t2'. (t1 = SOME (INL e1)::t1') ∧ (t2 = NONE::t2'))``);

val TranRelSnocRev = new_axiom ("TranRelSnocRev",
                                ``∀(MTrn:(('event1 + 'event3) + ('event2 + 'event3), ('pred1 + 'pred2), 'state , 'symb ) mtrel) v p s v' p' s' v'' p'' s'' t e. (MTrn (v,p,s) (e::t) (v'',p'',s'')) ⇒ ((MTrn (v,p,s) t (v',p',s')) ∧ (MTrn (v',p',s') [e] (v'',p'',s'')))``);
                                
val TranRelSnocBack = new_axiom ("TranRelSnocBack",
                             ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s' v'' p'' s'' t e. (MTrn (v,p,s) (e::t) (v'',p'',s'')) ⇒ ((MTrn (v,p,s) t (v',p',s')) ∧ (MTrn (v',p',s') [e] (v'',p'',s'')))``);

val binterl_NotEmpty = new_axiom ("binterl_NotEmpty",
                                  ``∀t1 t2 h t. binterl t1 t2 (h::t) ⇒ (∃h1 t1' h2 t2'. (t1 = (h1::t1'))∧(t2 = (h2::t2')))``);


                                   
val binterl_Conj = new_axiom ("binterl_Conj",
                              ``∀h1 t1 h2 t2 h t. (binterl ((h1::t1):('event1 + 'eventS) option list) ((h2::t2):('event2 + 'eventS) option list) (h::t)) ⇒ ((binterl t1 t2 t) ∧ (binterl [h1] [h2] [h]))``);

val binterl_moveAR =
new_axiom ("binterl_moveAR",
           ``∀e2 (t:(('event1 + 'eventS) + 'event2 + 'eventS) option list) (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list).
                 binterl t1 t2 (SOME (INR (INL e2))::t) ⇒
              (∃t2'. (t2 = SOME (INL e2)::t2'))``);

                              
val DedRelINL = new_axiom ("DedRelINL",
                          ``∀(ded1:('pred1) tded) (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' P'' t1 t2 x.
                            (
                          (MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL P'',S1')) ∧
                          (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR P'',S2')) ∧
                          (ded1 (PREIMAGE INL P'') x))
                             ⇒
                             ((MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL (P'' ∪ {INL x}),S1')) ∧
                              (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR (P'' ∪ {INL x}),S2')))``);
                              
val DedRelINR = new_axiom ("DedRelINR",
                          ``∀(ded2:('pred2) tded) (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' P'' t1 t2 x.
                            (
                          (MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL P'',S1')) ∧
                          (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR P'',S2')) ∧
                          (ded2 (PREIMAGE INR P'') x))
                             ⇒
                             ((MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL (P'' ∪ {INR x}),S1')) ∧
                              (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR (P'' ∪ {INR x}),S2')))``);
                              
val TranRelNil = new_axiom ("TranRelNil",
                            ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s. MTrn (v,p,s) [] (v,p,s)``);
val TranRelConfigEq = new_axiom ("TranRelConfigEq",
                                 ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s'. (MTrn (v,p,s) [] (v',p',s')) ⇒ ((v = v')∧(p = p')∧(s = s'))``);

val TranRelSnoc = new_axiom ("TranRelSnoc",
                             ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s' v'' p'' s'' t e. ((MTrn (v,p,s) t (v',p',s')) ∧ (MTrn (v',p',s') [e] (v'',p'',s''))) ⇒ (MTrn (v,p,s) (e::t) (v'',p'',s''))``);
       
                                                  
val combineAllDedprSum12 = new_axiom ("combineAllDedprSum12",
                          ``∀phi ded12 ded3 comded3 P'' P' ded1 ded23 comded1.
          (combineAllDed ded12 ded3 comded3 P'' phi ∧
          P' = P'' ∪ {phi})
⇒
        (∀phi.
          combineAllDed ded1 ded23 comded1 (prSum P'')
                        phi ∧ prSum P' = prSum P'' ∪ {phi})``);

val combineAllDedprSum23 = new_axiom ("combineAllDedprSum23",
                          ``∀phi ded12 ded3 comded3 P'' P' ded1 ded23 comded1.
          ( combineAllDed ded1 ded23 comded1 P'' phi ∧
          prSum P' = P'' ∪ {phi})
⇒
        (∀phi.
          combineAllDed ded12 ded3 comded3 (prSumRev P'')
            phi ∧ P' = prSumRev P'' ∪ {phi})``);
                             
val TranRelSnocRevAsyncL =
new_axiom ("TranRelSnocRevAsyncL",
           ``∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,PREIMAGE INL P,S1) ((SOME (INL e))::t1) (Sym',PREIMAGE INL P',S1')) ∧ (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR P',S2'))) ⇒ (∃Sym'' (P'':('pred1+'pred2) set) S1''. (MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym'',PREIMAGE INL P'',S1'')) ∧ (MTrn1 (Sym'',PREIMAGE INL P'',S1'') [SOME (INL e)] (Sym',PREIMAGE INL P',S1')) ∧ (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym'',PREIMAGE INR P'',S2')) ∧ (MTrn2 (Sym'',PREIMAGE INR P'',S2') [] (Sym',PREIMAGE INR P',S2')))``);                                   


val TranRelSnocRevAsyncR =
new_axiom ("TranRelSnocRevAsyncR",
           ``∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL P',S1')) ∧ (MTrn2 (Sym,PREIMAGE INR P,S2) (SOME (INL e)::t2) (Sym',PREIMAGE INR P',S2'))) ⇒ (∃Sym'' (P'':('pred1+'pred2) set) S2''. (MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym'',PREIMAGE INL P'',S1')) ∧ (MTrn1 (Sym'',PREIMAGE INL P'',S1') [] (Sym',PREIMAGE INL P',S1')) ∧ (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym'',PREIMAGE INR P'',S2'')) ∧ (MTrn2 (Sym'',PREIMAGE INR P'',S2'') [SOME (INL e)] (Sym',PREIMAGE INR P',S2')))``);

val TranRelSnocRevSync =
new_axiom ("TranRelSnocRevSync",
           ``∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,PREIMAGE INL P,S1) (SOME (INR e)::t1) (Sym',PREIMAGE INL P',S1')) ∧ (MTrn2 (Sym,PREIMAGE INR P,S2) (SOME (INR e)::t2) (Sym',PREIMAGE INR P',S2'))) ⇒ (∃Sym'' (P'':('pred1+'pred2) set) S1'' S2''. (MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym'',PREIMAGE INL P'',S1'')) ∧ (MTrn1 (Sym'',PREIMAGE INL P'',S1'') [SOME (INR e)] (Sym',PREIMAGE INL P',S1')) ∧ (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym'',PREIMAGE INR P'',S2'')) ∧ (MTrn2 (Sym'',PREIMAGE INR P'',S2'') [SOME (INR e)] (Sym',PREIMAGE INR P',S2')))``);                                                                        

val TranRelSnocRevNone =
new_axiom ("TranRelSnocRevNone",
           ``
           ∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2.
             ((MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL P',S1')) ∧ (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR P',S2')))
             ⇒ (∃(P'':('pred1+'pred2) set). (∀(Ded1:('pred1) tded) (Ded2:('pred2) tded) (Ded3:('pred1 + 'pred2) tded) phi. (combineAllDed Ded1 Ded2 Ded3 P'' phi) ∧ P'=P''∪{phi}) ∧
                                            (MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL P'',S1')) ∧
                                            (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR P'',S2')))``);

val TranRelSnocRevNoneComp =
new_axiom ("TranRelSnocRevNoneComp",
           ``
           ∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2.
             ((MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL P',S1')) ∧ (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR P',S2')))
             ⇒ (∃(P'':('pred1+'pred2) set). (∀(Ded1:('pred1) tded) (Ded2:('pred2) tded) phi. ((composeDed Ded1 Ded2) P'' phi) ∧ P'=P''∪{phi})  ∧
                                            (MTrn1 (Sym,PREIMAGE INL P,S1) t1 (Sym',PREIMAGE INL P'',S1')) ∧
                                            (MTrn2 (Sym,PREIMAGE INR P,S2) t2 (Sym',PREIMAGE INR P'',S2')))``);

     
val _ = export_theory();
