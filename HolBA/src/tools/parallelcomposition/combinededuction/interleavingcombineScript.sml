open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open listTheory;
open parallelcompositioncombinedeductionTheory;
open pairTheory wordsTheory set_sepTheory;
open quantHeuristicsTheory;


val _ = new_theory "interleavingcombine";

val TranRelNil = new_axiom ("TranRelNil",
                            ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s. MTrn (v,p,s) [] (v,p,s)``);
val TranRelConfigEq = new_axiom ("TranRelConfigEq",
                            ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s'. (MTrn (v,p,s) [] (v',p',s')) ⇒ ((v = v')∧(p = p')∧(s = s'))``);
val TranRelSnoc = new_axiom ("TranRelSnoc",
                             ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s' v'' p'' s'' t e. ((MTrn (v,p,s) t (v',p',s')) ∧ (MTrn (v',p',s') [e] (v'',p'',s''))) ⇒ (MTrn (v,p,s) (e::t) (v'',p'',s''))``);

val IMAGEOUT = new_axiom ("IMAGEOUT",
                          ``∀P P'. ((IMAGE OUTR P = IMAGE OUTR P') ∧ (IMAGE OUTL P = IMAGE OUTL P')) ⇒ (P = P')``);

val DedRelAll = new_axiom ("DedRelAll",
                          ``∀(ded1:(('pred1,'symb) predOne) tded) (ded2:(('pred2,'symb) predTwo) tded) (MTrn1:('event1 + 'eventS, (('pred1,'symb) predOne), 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, (('pred2,'symb) predTwo), 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' P'' t1 t2 phi.
                            ((MTrn1 (Sym',IMAGE OUTL P'',S1') [NONE] (Sym',IMAGE OUTL P'' ∪ {OUTL phi},S1')) ∧
                          (MTrn2 (Sym',IMAGE OUTR P'',S2') [NONE] (Sym',IMAGE OUTR P'' ∪ {OUTR phi},S2')) ∧
                          (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P'',S1')) ∧
                          (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P'',S2')) ∧
                          (combineAllDed ded1 ded2 P'' phi))
                             ⇒
                             ((MTrn1 (Sym,IMAGE OUTL P,S1) (NONE::t1) (Sym',IMAGE OUTL P'' ∪ {OUTL phi},S1')) ∧
                              (MTrn2 (Sym,IMAGE OUTR P,S2) (NONE::t2) (Sym',IMAGE OUTR P'' ∪ {OUTR phi},S2')))``);
                              
val DedRelINL = new_axiom ("DedRelINL",
                          ``∀(ded1:(('pred1,'symb) predOne) tded) (MTrn1:('event1 + 'eventS, (('pred1,'symb) predOne), 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, (('pred2,'symb) predTwo), 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' P'' t1 t2 x.
                            ((MTrn1 (Sym',IMAGE OUTL P'',S1') [NONE] (Sym',IMAGE OUTL P'' ∪ {x},S1')) ∧
                          (MTrn2 (Sym',IMAGE OUTR P'',S2') [NONE] (Sym',IMAGE OUTR P'' ∪ {OUTR (INL x)},S2')) ∧
                          (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P'',S1')) ∧
                          (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P'',S2')) ∧
                          (ded1 (IMAGE OUTL P'') x))
                             ⇒
                             ((MTrn1 (Sym,IMAGE OUTL P,S1) (NONE::t1) (Sym',IMAGE OUTL P'' ∪ {x},S1')) ∧
                              (MTrn2 (Sym,IMAGE OUTR P,S2) (NONE::t2) (Sym',IMAGE OUTR P'' ∪ {OUTR (INL x)},S2')))``);
                              
val DedRelINR = new_axiom ("DedRelINR",
                          ``∀(ded2:(('pred2,'symb) predTwo) tded) (MTrn1:('event1 + 'eventS, (('pred1,'symb) predOne), 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, (('pred2,'symb) predTwo), 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' P'' t1 t2 x.
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
           ``∀(MTrn1:('event1 + 'eventS, (('pred1,'symb) predOne), 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, (('pred2,'symb) predTwo), 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) ((SOME (INL e))::t1) (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P',S2'))) ⇒ (∃Sym'' (P'':((('pred1,'symb) predOne)+(('pred2,'symb) predTwo)) set) S1''. (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym'',IMAGE OUTL P'',S1'')) ∧ (MTrn1 (Sym'',IMAGE OUTL P'',S1'') [SOME (INL e)] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym'',IMAGE OUTR P'',S2')) ∧ (MTrn2 (Sym'',IMAGE OUTR P'',S2') [] (Sym',IMAGE OUTR P',S2')))``);                                   


val TranRelSnocRevAsyncR =
new_axiom ("TranRelSnocRevAsyncR",
           ``∀(MTrn1:('event1 + 'eventS, (('pred1,'symb) predOne), 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, (('pred2,'symb) predTwo), 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) (SOME (INL e)::t2) (Sym',IMAGE OUTR P',S2'))) ⇒ (∃Sym'' (P'':((('pred1,'symb) predOne)+(('pred2,'symb) predTwo)) set) S2''. (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym'',IMAGE OUTL P'',S1')) ∧ (MTrn1 (Sym'',IMAGE OUTL P'',S1') [] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym'',IMAGE OUTR P'',S2'')) ∧ (MTrn2 (Sym'',IMAGE OUTR P'',S2'') [SOME (INL e)] (Sym',IMAGE OUTR P',S2')))``);

val TranRelSnocRevSync =
new_axiom ("TranRelSnocRevSync",
           ``∀(MTrn1:('event1 + 'eventS, (('pred1,'symb) predOne), 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, (('pred2,'symb) predTwo), 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) (SOME (INR e)::t1) (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) (SOME (INR e)::t2) (Sym',IMAGE OUTR P',S2'))) ⇒ (∃Sym'' (P'':((('pred1,'symb) predOne)+(('pred2,'symb) predTwo)) set) S1'' S2''. (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym'',IMAGE OUTL P'',S1'')) ∧ (MTrn1 (Sym'',IMAGE OUTL P'',S1'') [SOME (INR e)] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym'',IMAGE OUTR P'',S2'')) ∧ (MTrn2 (Sym'',IMAGE OUTR P'',S2'') [SOME (INR e)] (Sym',IMAGE OUTR P',S2')))``);                                                                        

val TranRelSnocRevSync =
new_axiom ("TranRelSnocRevNone",
           ``∀(MTrn1:('event1 + 'eventS, (('pred1,'symb) predOne), 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, (('pred2,'symb) predTwo), 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) (NONE::t1) (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) (NONE::t2) (Sym',IMAGE OUTR P',S2'))) ⇒ (∃(P'':((('pred1,'symb) predOne)+(('pred2,'symb) predTwo)) set). (∀(Ded1:(('pred1,'symb) predOne) tded) (Ded2:(('pred2,'symb) predTwo) tded) phi. (combineAllDed Ded1 Ded2 P'' phi) ∧ P'=P''∪{phi}) ∧ (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P'',S1')) ∧ (MTrn1 (Sym',IMAGE OUTL P'',S1') [NONE] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P'',S2')) ∧ (MTrn2 (Sym',IMAGE OUTR P'',S2') [NONE] (Sym',IMAGE OUTR P',S2')))``);
                                                                        
(* Binary interleaving of traces *)
Inductive binterl:
[~nil:]
  (binterl [] [] []) /\
[~none:]
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t1' = (NONE::t1)) /\ (t2' = (NONE::t2)) /\ (t' = (NONE::t))) ==> (binterl t1' t2' t')) /\
[~left:]
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t1' = (SOME (INL e1)::t1)) /\ (t' = (SOME (INL (INL e1))::t))) ==> (binterl t1' t2 t')) /\
[~right:]                                                                        
  (((binterl (t1:('event1 + 'eventS) option list) (t2:('event2 + 'eventS) option list) t) /\ (t2' = (SOME (INL e2)::t2)) /\ (t' = (SOME (INR (INL e2))::t))) ==> (binterl t1 t2' t')) /\
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
[~movenone:]                                                                        
  ((binterl (NONE::(t1:('event1 + 'eventS) option list)) (NONE::(t2:('event2 + 'eventS) option list)) (NONE::t)) ==> (binterl t1 t2 t)) 
End

val binterl_Empty = new_axiom ("binterl_Empty",
                               ``∀t1 t2. binterl t1 t2 [] ⇒ ((t1 = []) ∧(t2 = []))``);
                               
val binterl_moveSL = new_axiom ("binterl_moveNONE",
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
  

Definition binterleave_ts:
  binterleave_ts ts1 ts2 = {t| ∃t1 t2. (t1 ∈ ts1) ∧ (t2 ∈ ts2) ∧ (binterl t1 t2 t)}
End


val _ = export_theory();
