open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open listTheory;
open parallelcompositiongeneraldeductionTheory;
open pairTheory wordsTheory;
open quantHeuristicsTheory;


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
[~movesLN:]                                                                        
  ((binterl (SOME (INL e1)::(t1:('event1 + 'eventS) option list)) (NONE::(t2:('event2 + 'eventS) option list)) (SOME (INL (INL e1))::t)) ==> (binterl t1 t2 t)) /\
[~movesL:]                                                                        
  ((binterl (SOME (INL e1)::(t1:('event1 + 'eventS) option list)) (t2:('event2 + 'eventS) option list) (SOME (INL (INL e1))::t)) ==> (binterl t1 t2 t)) /\
[~movesRN:]                                                                        
  ((binterl (NONE::(t1:('event1 + 'eventS) option list)) (SOME (INL e2)::(t2:('event2 + 'eventS) option list)) (SOME (INR (INL e2))::t)) ==> (binterl t1 t2 t)) /\
[~movesR:]                                                                        
  ((binterl (t1:('event1 + 'eventS) option list) (SOME (INL e2)::(t2:('event2 + 'eventS) option list)) (SOME (INR (INL e2))::t)) ==> (binterl t1 t2 t)) /\
[~movesSL:]                                                                        
  ((binterl (SOME (INR e)::(t1:('event1 + 'eventS) option list)) (SOME (INR e)::(t2:('event2 + 'eventS) option list)) (SOME (INL (INR e))::t)) ==> (binterl t1 t2 t)) /\
[~movesSR:]                                                                        
  ((binterl (SOME (INR e)::(t1:('event1 + 'eventS) option list)) (SOME (INR e)::(t2:('event2 + 'eventS) option list)) (SOME (INR (INR e))::t)) ==> (binterl t1 t2 t)) /\
[~movenone:]                                                                        
  ((binterl (NONE::(t1:('event1 + 'eventS) option list)) (NONE::(t2:('event2 + 'eventS) option list)) (NONE::t)) ==> (binterl t1 t2 t))  /\
[~movecombinenone:]                                                                        
  ((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) (NONE::t)) ==> (binterl t1 t2 t)) /\
[~moveB:]
  (((binterl ((h1::t1):('event1 + 'eventS) option list) ((h2::t2):('event2 + 'eventS) option list) (h::t))∧(binterl [h1] [h2] [h])) ==> (binterl t1 t2 t))/\
[~moveF:]
  (((binterl t1 t2 t) ∧ (binterl [h1] [h2] [h])) ==> (binterl ((h1::t1):('event1 + 'eventS) option list) ((h2::t2):('event2 + 'eventS) option list) (h::t))) /\
[~single:]
  (((binterl t1 t2 t) ∧ (binterl ((h1::t1):('event1 + 'eventS) option list) ((h2::t2):('event2 + 'eventS) option list) (h::t))) ==> (binterl [h1] [h2] [h]))
End


Definition binterleave_ts:
  binterleave_ts ts1 ts2 = {t| ∃t1 t2. (t1 ∈ ts1) ∧ (t2 ∈ ts2) ∧ (binterl t1 t2 t)}
End


val doubleLeftMTrn_def =
Define`
      doubleLeftMTrn (MTrn:('event + 'eventS, 'pred, 'state, 'symb) mtrel) (v,(p: ('predL + 'pred) -> bool),(c:'stateL),s) (t:(('event + 'eventS)+('eventL + 'eventS)) option list) (v',(p': ('predL + 'pred) -> bool),(c':'stateL),s')  = (MTrn (v,(IMAGE OUTR p),s) (MAP (OPTION_MAP OUTL) t) (v',(IMAGE OUTR p'),s'))
`;

val doubleRightMTrn_def =
Define`
      doubleRightMTrn (MTrn:('event + 'eventS, 'pred, 'state, 'symb) mtrel) (v,(p: ('pred + 'predR) -> bool),s,(c:'stateR)) (t:(('event + 'eventS)+('eventR + 'eventS)) option list) (v',(p': ('pred + 'predR) -> bool),s',(c':'stateR))  = (MTrn (v,(IMAGE OUTL p),s) (MAP (OPTION_MAP OUTL) t) (v',(IMAGE OUTL p'),s'))
`;


val doubleLeftDed_def =
Define `
       (doubleLeftDed (ded: ('pred) tded) (p: ('predL + 'pred) -> bool) (phi: ('predL + 'pred))  =  (ded (IMAGE OUTR p) (OUTR phi))
       )`;  
        
val doubleRightDed_def =
Define `
       (doubleRightDed (ded: ('pred) tded) (p: ('pred + 'predR) -> bool) (phi: ('pred + 'predR))  =  (ded (IMAGE OUTL p) (OUTL phi))
       )`;

       
val prSum_def =
Define`
      prSum (P :(('pred1 + 'pred2) + ('pred1 + 'pred2) + 'pred3) -> bool) (P' :('pred1 + 'pred2 + 'pred3) + 'pred2 + 'pred3) =
(∀x. (x ∈ P) ∧
(case x of
  INL (INL (ll : 'pred1)) => (ll = (OUTL (OUTL P')))
| INR (INR (rr: 'pred3)) => (rr = (OUTR (OUTR P')))
| INL (INR (lr : 'pred2)) => (lr = (OUTL (OUTR (OUTL P'))))
| INR (INL (INL (rll : 'pred1))) => (rll = (OUTL (OUTL P')))
| INR (INL (INR (rlr : 'pred2))) => (rlr = (OUTL (OUTR P')))
))
`;


val prSumRev_def =
Define`
      prSumRev (P :(('pred1 + 'pred2 + 'pred3) + 'pred2 + 'pred3) -> bool) (P' :('pred1 + 'pred2) + ('pred1 + 'pred2) + 'pred3)  =
(∀x. (x ∈ P) ∧
(case x of
  INL (INL (ll : 'pred1)) => (ll = (OUTL (OUTL P'))) 
| INR (INR (rr: 'pred3)) => (rr = (OUTR (OUTR P')))
| INL (INR (INL (lrl : 'pred2))) => (lrl = (OUTR (OUTL (OUTR P'))))
| INR (INL (rl : 'pred2)) => (rl = (OUTR (OUTL (OUTR P'))))
| INL (INR (INR (lrr : 'pred3))) => (lrr = (OUTR (OUTR P'))) 
))
`;
        
val prSum_Eq = new_axiom ("prSum_Eq",
                               ``∀P P'. P = P' ⇔ prSum P = prSum P'``);

val prSum_prSumRev = new_axiom ("prSum_prSumRev",
                          ``∀P P'. (P = (prSum P')) ⇔ ((prSumRev P) = P')``);
                          
val prSum_Rev = new_axiom ("prSum_Rev",
                           ``∀P. (prSum (prSumRev P)) = P``);

val Rev_prSum = new_axiom ("Rev_prSum",
                          ``∀P. (prSumRev (prSum P)) = P``);
                          
val binterl_Empty = new_axiom ("binterl_Empty",
                               ``∀t1 t2. binterl t1 t2 [] ⇒ ((t1 = []) ∧(t2 = []))``);

val binterl_Conj = new_axiom ("binterl_Conj",
                              ``∀h1 t1 h2 t2 h t. (binterl ((h1::t1):('event1 + 'eventS) option list) ((h2::t2):('event2 + 'eventS) option list) (h::t)) ⇒ ((binterl t1 t2 t) ∧ (binterl [h1] [h2] [h]))``);

val binterl_NotEmpty = new_axiom ("binterl_NotEmpty",
                                  ``∀t1 t2. binterl t1 t2 (h::t) ⇒ (∃h1 t1' h2 t2'. (t1 = (h1::t1'))∧(t2 = (h2::t2')))``);

val binterl_EmptyRev = new_axiom ("binterl_EmptyRev",
                                  ``∀t. binterl [] [] t ⇒ (t = [])``);
                               
val binterl_moveNONE = new_axiom ("binterl_moveNONE",
                                ``∀e t t1 t2.
                                     binterl t1 t2 (NONE::t) ⇒
                                   (∃t1' t2'. (t1 = NONE::t1') ∧(t2 = NONE::t2'))``);                               

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
                                  
val binterl_moveAR = new_axiom ("binterl_moveAR",
                               ``∀e2 t t1 t2.
                                     binterl t1 t2 (SOME (INR (INL e2))::t) ⇒
                                  (∃t2'. (t2 = SOME (INL e2)::t2'))``);


 val binterl_moveNAL = new_axiom ("binterl_moveNAL",
                               ``∀e1 t t1 t2.
                                     binterl t1 t2 (SOME (INL (INL e1))::t) ⇒
                                  (∃t1' t2'. (t1 = SOME (INL e1)::t1') ∧ (t2 = NONE::t2'))``);

val binterl_moveNAR = new_axiom ("binterl_moveNAR",
                                 ``∀e2 t t1 t2.
                                       binterl t1 t2 (SOME (INR (INL e2))::t) ⇒
                                    (∃t1' t2'. (t2 = SOME (INL e2)::t2') ∧ (t1 = NONE::t1'))``);


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
 
val OUTR_INL_FUN_thm = new_axiom("OUTR_INL_FUN", ``         
∀x n.
 OUTR (INL x) = n x``);

val OUTL_INR_FUN_thm = new_axiom("OUTL_INR_FUN", ``      
∀x n.
 OUTL (INR x) = n x``);

val TranRelNil = new_axiom ("TranRelNil",
                            ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s. MTrn (v,p,s) [] (v,p,s)``);
val TranRelConfigEq = new_axiom ("TranRelConfigEq",
                                 ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s'. (MTrn (v,p,s) [] (v',p',s')) ⇒ ((v = v')∧(p = p')∧(s = s'))``);

val TranRelSnoc = new_axiom ("TranRelSnoc",
                             ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s' v'' p'' s'' t e. ((MTrn (v,p,s) t (v',p',s')) ∧ (MTrn (v',p',s') [e] (v'',p'',s''))) ⇒ (MTrn (v,p,s) (e::t) (v'',p'',s''))``);

val TranRelSnocBack = new_axiom ("TranRelSnocBack",
                             ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s' v'' p'' s'' t e. (MTrn (v,p,s) (e::t) (v'',p'',s'')) ⇒ ((MTrn (v,p,s) t (v',p',s')) ∧ (MTrn (v',p',s') [e] (v'',p'',s'')))``);
                             
val TranRelSnocRev = new_axiom ("TranRelSnocRev",
                             ``∀(MTrn:(('event1 + 'event3) + ('event2 + 'event3), ('pred1 + 'pred2), 'state , 'symb ) mtrel) v p s v' p' s' v'' p'' s'' t e. (MTrn (v,p,s) (e::t) (v'',p'',s'')) ⇒ ((MTrn (v,p,s) t (v',p',s')) ∧ (MTrn (v',p',s') [e] (v'',p'',s'')))``);
                                 
val IMAGEOUT = new_axiom ("IMAGEOUT",
                          ``∀P P'. ((IMAGE OUTR P = IMAGE OUTR P') ∧ (IMAGE OUTL P = IMAGE OUTL P')) ⇒ (P = P')``);

val combineAllDedRev21 = new_axiom ("combineAllDedRev21",
                          ``∀(ded1:('pred1) tded) (ded2:('pred2) tded) (ded3:('pred1 + 'pred2) tded) P phi (m: 'pred2 -> 'pred1) (n: 'pred1 -> 'pred2).
                                                  combineAllDed ded2 ded1 (RevDed ded3) P (SUM_MAP n m phi) = combineAllDed ded1 ded2 ded3 (IMAGE (SUM_MAP m n) P) phi``);

val combineAllDedRev12 = new_axiom ("combineAllDedRev12",
                          ``∀(ded1:('pred1) tded) (ded2:('pred2) tded) (ded3:('pred1 + 'pred2) tded) P phi (m: 'pred2 -> 'pred1) (n: 'pred1 -> 'pred2).
                                                  combineAllDed ded1 ded2 ded3 P ((SUM_MAP m n) phi) = combineAllDed ded2 ded1 (RevDed ded3) (IMAGE (SUM_MAP n m) P) phi``);
                                                  
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
                        
val DedRelINL = new_axiom ("DedRelINL",
                          ``∀(ded1:('pred1) tded) (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (ded3:('pred1 + 'pred2) tded) Sym P S1 S2 Sym' P' S1' S2' P'' t1 t2 x.
                            ((MTrn1 (Sym',IMAGE OUTL P'',S1') [NONE] (Sym',IMAGE OUTL P'' ∪ {x},S1')) ∧
                          (MTrn2 (Sym',IMAGE OUTR P'',S2') [NONE] (Sym',IMAGE OUTR P'' ∪ {OUTR (INL x)},S2')) ∧
                          (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P'',S1')) ∧
                          (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P'',S2')) ∧
                          (ded1 (IMAGE OUTL P'') x))
                             ⇒
                             ((MTrn1 (Sym,IMAGE OUTL P,S1) (NONE::t1) (Sym',IMAGE OUTL P'' ∪ {x},S1')) ∧
                              (MTrn2 (Sym,IMAGE OUTR P,S2) (NONE::t2) (Sym',IMAGE OUTR P'' ∪ {OUTR (INL x)},S2')))``);
                              
val DedRelINR = new_axiom ("DedRelINR",
                          ``∀(ded2:('pred2) tded) (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (ded3:('pred1 + 'pred2) tded) Sym P S1 S2 Sym' P' S1' S2' P'' t1 t2 x.
                            ((MTrn1 (Sym',IMAGE OUTL P'',S1') [NONE] (Sym',IMAGE OUTL P'' ∪ {OUTL (INR x)},S1')) ∧
                          (MTrn2 (Sym',IMAGE OUTR P'',S2') [NONE] (Sym',IMAGE OUTR P'' ∪ {x},S2')) ∧
                          (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P'',S1')) ∧
                          (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P'',S2')) ∧
                          (ded2 (IMAGE OUTR P'') x))
                             ⇒
                             ((MTrn1 (Sym,IMAGE OUTL P,S1) (NONE::t1) (Sym',IMAGE OUTL P'' ∪ {OUTL (INR x)},S1')) ∧
                              (MTrn2 (Sym,IMAGE OUTR P,S2) (NONE::t2) (Sym',IMAGE OUTR P'' ∪ {x},S2')))``);
                              
val TranRelSnocRevAsyncL =
new_axiom ("TranRelSnocRevAsyncL",
           ``∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) ((SOME (INL e))::t1) (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P',S2'))) ⇒ (∃Sym'' (P'':('pred1+'pred2) set) S1''. (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym'',IMAGE OUTL P'',S1'')) ∧ (MTrn1 (Sym'',IMAGE OUTL P'',S1'') [SOME (INL e)] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym'',IMAGE OUTR P'',S2')) ∧ (MTrn2 (Sym'',IMAGE OUTR P'',S2') [] (Sym',IMAGE OUTR P',S2')))``);                                   


val TranRelSnocRevAsyncR =
new_axiom ("TranRelSnocRevAsyncR",
           ``∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) (SOME (INL e)::t2) (Sym',IMAGE OUTR P',S2'))) ⇒ (∃Sym'' (P'':('pred1+'pred2) set) S2''. (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym'',IMAGE OUTL P'',S1')) ∧ (MTrn1 (Sym'',IMAGE OUTL P'',S1') [] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym'',IMAGE OUTR P'',S2'')) ∧ (MTrn2 (Sym'',IMAGE OUTR P'',S2'') [SOME (INL e)] (Sym',IMAGE OUTR P',S2')))``);

val TranRelSnocRevSync =
new_axiom ("TranRelSnocRevSync",
           ``∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) (SOME (INR e)::t1) (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) (SOME (INR e)::t2) (Sym',IMAGE OUTR P',S2'))) ⇒ (∃Sym'' (P'':('pred1+'pred2) set) S1'' S2''. (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym'',IMAGE OUTL P'',S1'')) ∧ (MTrn1 (Sym'',IMAGE OUTL P'',S1'') [SOME (INR e)] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym'',IMAGE OUTR P'',S2'')) ∧ (MTrn2 (Sym'',IMAGE OUTR P'',S2'') [SOME (INR e)] (Sym',IMAGE OUTR P',S2')))``);                                                                        

val TranRelSnocRevSync =
new_axiom ("TranRelSnocRevNone",
           ``
           ∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2.
             ((MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P',S2')))
             ⇒ (∃(P'':('pred1+'pred2) set). (∀(Ded1:('pred1) tded) (Ded2:('pred2) tded) (Ded3:('pred1 + 'pred2) tded) phi. (combineAllDed Ded1 Ded2 Ded3 P'' phi) ∧ P'=P''∪{phi}) ∧
                                            (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P'',S1')) ∧
                                            (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P'',S2')))``);

val TransDisable_def =
Define`TransDisable (ded3:('pred1 + 'pred2) tded) ((MTrn1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1: 'pred1 tded)) ((MTrn2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2: 'pred2 tded)) =
(∀Sym P S1 S2 Sym' P' S1' S2' t1 t2 phi.
                         ((MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P',S1')) ∧
                          (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P',S2')) ∧
                          (combineAllDed ded1 ded2 ded3 P' phi)) ⇒
                          ((MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P' ∪ {OUTL phi},S1')) ∧
                           (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P' ∪ {OUTR phi},S2'))))
        `;

val TransEnable_def =
Define`TransEnable (ded3:('pred1 + 'pred2) tded) ((MTrn1:(('event1 + 'eventS), 'pred1, 'state1, 'symb) mtrel),(ded1: 'pred1 tded)) ((MTrn2:(('event2 + 'eventS), 'pred2, 'state2, 'symb) mtrel),(ded2: 'pred2 tded)) =
(∀Sym P S1 S2 Sym' P' S1' S2' t1 t2 phi.
   ((MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P' ∪ {OUTL phi},S1')) ∧
    (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P' ∪ {OUTR phi},S2')) ∧
    (combineAllDed ded1 ded2 ded3 P' phi)) ⇒
   ((MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P',S1')) ∧
    (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P',S2'))))
`;
        
val _ = export_theory();
