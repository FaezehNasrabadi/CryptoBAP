open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open listTheory;
open parallelcompositionsimpleTheory;
open pairTheory wordsTheory set_sepTheory;
open quantHeuristicsTheory;

val _ = new_theory "interleaving";


val traces_def =
Define`
      traces (MTrn:('event, 'pred, 'state, 'symb) mtrel) ((Sym:'symb set),(P: 'pred set),(S: 'state)) ((Sym':'symb set),(P': 'pred set),(S': 'state)) = {t| (MTrn (Sym,P,S) t (Sym',P',S'))}
                                                                                                                                                                        `;
 val comptraces_def =
Define`
      comptraces (CMTrn:((('event1+'eventS) + ('event2 +'eventS)), ('pred1 + 'pred2), 'state1#'state2, 'symb) mtrel) ((Sym:'symb set),(P: ('pred1 + 'pred2) set),(S1: 'state1),(S2: 'state2)) ((Sym':'symb set),(P': ('pred1 + 'pred2) set),(S1': 'state1),(S2': 'state2)) = {t| (CMTrn (Sym,P,S1,S2) t (Sym',P',S1',S2'))}
`;      

val TranRelNil = new_axiom ("TranRelNil",
                            ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s. MTrn (v,p,s) [] (v,p,s)``);
val TranRelConfigEq = new_axiom ("TranRelConfigEq",
                            ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s'. (MTrn (v,p,s) [] (v',p',s')) ⇒ ((v = v')∧(p = p')∧(s = s'))``);
val TranRelSnoc = new_axiom ("TranRelSnoc",
                             ``∀(MTrn:('event, 'pred, 'state , 'symb ) mtrel) v p s v' p' s' v'' p'' s'' t e. ((MTrn (v,p,s) t (v',p',s')) ∧ (MTrn (v',p',s') [e] (v'',p'',s''))) ⇒ (MTrn (v,p,s) (e::t) (v'',p'',s''))``);

val IMAGEOUT = new_axiom ("IMAGEOUT",
                          ``∀P P'. ((IMAGE OUTR P = IMAGE OUTR P') ∧ (IMAGE OUTL P = IMAGE OUTL P')) ⇒ (P = P')``);

val TranRelSnocRevAsyncL =
new_axiom ("TranRelSnocRevAsyncL",
           ``∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) (INL e::t1) (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym',IMAGE OUTR P',S2'))) ⇒ (∃Sym'' (P'':('pred1+'pred2) set) S1''. (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym'',IMAGE OUTL P'',S1'')) ∧ (MTrn1 (Sym'',IMAGE OUTL P'',S1'') [INL e] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym'',IMAGE OUTR P'',S2')) ∧ (MTrn2 (Sym'',IMAGE OUTR P'',S2') [] (Sym',IMAGE OUTR P',S2')))``);                                   


val TranRelSnocRevAsyncR =
new_axiom ("TranRelSnocRevAsyncR",
           ``∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) (INL e::t2) (Sym',IMAGE OUTR P',S2'))) ⇒ (∃Sym'' (P'':('pred1+'pred2) set) S2''. (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym'',IMAGE OUTL P'',S1')) ∧ (MTrn1 (Sym'',IMAGE OUTL P'',S1') [] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym'',IMAGE OUTR P'',S2'')) ∧ (MTrn2 (Sym'',IMAGE OUTR P'',S2'') [INL e] (Sym',IMAGE OUTR P',S2')))``);

val TranRelSnocRevSync =
new_axiom ("TranRelSnocRevSync",
           ``∀(MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Sym P S1 S2 Sym' P' S1' S2' t1 t2 e.
                                                                        ((MTrn1 (Sym,IMAGE OUTL P,S1) (INR e::t1) (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) (INR e::t2) (Sym',IMAGE OUTR P',S2'))) ⇒ (∃Sym'' (P'':('pred1+'pred2) set) S1'' S2''. (MTrn1 (Sym,IMAGE OUTL P,S1) t1 (Sym'',IMAGE OUTL P'',S1'')) ∧ (MTrn1 (Sym'',IMAGE OUTL P'',S1'') [INR e] (Sym',IMAGE OUTL P',S1')) ∧ (MTrn2 (Sym,IMAGE OUTR P,S2) t2 (Sym'',IMAGE OUTR P'',S2'')) ∧ (MTrn2 (Sym'',IMAGE OUTR P'',S2'') [INR e] (Sym',IMAGE OUTR P',S2')))``);                                                                        

                    
(* Binary interleaving of traces *)
Inductive binterl:
[~nil:]
  (binterl [] [] []) /\
[~left:]
  (((binterl (t1:('event1 + 'eventS) list) (t2:('event2 + 'eventS) list) t) /\ (t1' = ((INL e1)::t1)) /\ (t' = ((INL (INL e1))::t))) ==> (binterl t1' t2 t')) /\
[~right:]                                                                        
  (((binterl (t1:('event1 + 'eventS) list) (t2:('event2 + 'eventS) list) t) /\ (t2' = ((INL e2)::t2)) /\ (t' = ((INR (INL e2))::t))) ==> (binterl t1 t2' t')) /\
[~syncR:]                                                                        
  (((binterl (t1:('event1 + 'eventS) list) (t2:('event2 + 'eventS) list) t) /\ (t1' = ((INR e)::t1)) /\ (t2' = ((INR e)::t2)) /\ (t' = ((INR (INR e))::t))) ==> (binterl t1' t2' t')) /\
[~syncL:]                                                                        
  (((binterl (t1:('event1 + 'eventS) list) (t2:('event2 + 'eventS) list) t) /\ (t1' = ((INR e)::t1)) /\ (t2' = ((INR e)::t2)) /\ (t' = ((INL (INR e))::t))) ==> (binterl t1' t2' t'))
/\
[~movesL:]                                                                        
  ((binterl ((INL e1)::(t1:('event1 + 'eventS) list)) (t2:('event2 + 'eventS) list) (INL (INL e1)::t)) ==> (binterl t1 t2 t)) /\
[~movesR:]                                                                        
  ((binterl (t1:('event1 + 'eventS) list) ((INL e2)::(t2:('event2 + 'eventS) list)) (INR (INL e2)::t)) ==> (binterl t1 t2 t)) /\
[~movesSL:]                                                                        
  ((binterl ((INR e)::(t1:('event1 + 'eventS) list)) ((INR e)::(t2:('event2 + 'eventS) list)) (INL (INR e)::t)) ==> (binterl t1 t2 t)) /\
[~movesSR:]                                                                        
  ((binterl ((INR e)::(t1:('event1 + 'eventS) list)) ((INR e)::(t2:('event2 + 'eventS) list)) (INR (INR e)::t)) ==> (binterl t1 t2 t))  
End

val binterl_Empty = new_axiom ("binterl_Empty",
                               ``∀t1 t2. binterl t1 t2 [] ⇒ ((t1 = []) ∧(t2 = []))``);

val binterl_moveSL = new_axiom ("binterl_moveSL",
                                ``∀e t t1 t2.
                                     binterl t1 t2 (INL (INR e)::t) ⇒
                                   (∃t1' t2'. (t1 = (INR e)::t1') ∧(t2 = (INR e)::t2'))``);
val binterl_moveSR = new_axiom ("binterl_moveSR",
                                ``∀e t t1 t2.
                                     binterl t1 t2 (INR (INR e)::t) ⇒
                                  (∃t1' t2'. (t1 = (INR e)::t1') ∧(t2 = (INR e)::t2'))``);

 val binterl_moveAL = new_axiom ("binterl_moveAL",
                               ``∀e1 t t1 t2.
                                     binterl t1 t2 (INL (INL e1)::t) ⇒
                                  (∃t1'. (t1 = (INL e1)::t1'))``);
val binterl_moveAR = new_axiom ("binterl_moveAR",
                               ``∀e2 t t1 t2.
                                     binterl t1 t2 (INR (INL e2)::t) ⇒
                                  (∃t2'. (t2 = (INL e2)::t2'))``);                                  
  

Definition binterleave_ts:
  binterleave_ts ts1 ts2 = {t| ∃t1 t2. (t1 ∈ ts1) ∧ (t2 ∈ ts2) ∧ (binterl t1 t2 t)}
End

val binterleave_trace_comp_to_decomp_thm = store_thm(
  "binterleave_trace_comp_to_decomp",
  ``
  ∀t Sym P S1 S2 Sym' P' S1' S2' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Ded1 Ded2. 
    ((FST ((MTrn1,Ded1) || (MTrn2,Ded2))) (Sym,P,S1,S2) t (Sym',P',S1',S2'))
    ⇒
    (∃t1 t2. (MTrn1 (Sym,(IMAGE OUTL P),S1) t1 (Sym',(IMAGE OUTL P'),S1')) ∧ (MTrn2 (Sym,(IMAGE OUTR P),S2) t2 (Sym',(IMAGE OUTR P'),S2')) ∧ (binterl t1 t2 t))
    ``,

    GEN_TAC >>
    rewrite_tac[composeMultiOperation_def] >>
  Induct_on `t` >- (
    rpt strip_tac >>
    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
    Q.EXISTS_TAC `[]` >>
    Q.EXISTS_TAC `[]` >>
    rw[binterl_nil]) >>
  gen_tac >>
  Cases_on `h` >- (
    Cases_on `x` >-(
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
      rpt strip_tac >>
      PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'''`,`P'''`,`S1'''`,`S2'`,`MTrn1`,`MTrn2`])) >>
      RES_TAC >>
      Q.EXISTS_TAC `(INL x')::t1` >>
      Q.EXISTS_TAC `t2` >>
      rw[binterl_left] >-
       (metis_tac[TranRelSnoc]) >>
       metis_tac[TranRelNil,TranRelSnoc,TranRelConfigEq]
      ) >>
    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
    rpt strip_tac >>
    PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'''`,`P'''`,`S1'''`,`S2'''`,`MTrn1`,`MTrn2`])) >>
    RES_TAC >>
    Q.EXISTS_TAC `(INR y)::t1` >>
    Q.EXISTS_TAC `(INR y)::t2` >>
    rw[binterl_syncL] >-
     (metis_tac[TranRelSnoc])  >>
    metis_tac[TranRelSnoc]
    ) >>
    Cases_on `y` >- (
    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
    rpt strip_tac >>
    PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'''`,`P'''`,`S1'`,`S2'''`,`MTrn1`,`MTrn2`])) >>
    RES_TAC >>
    Q.EXISTS_TAC `t1` >>
    Q.EXISTS_TAC `(INL x)::t2` >>
    rw[binterl_right] >-
     ( metis_tac[TranRelNil,TranRelSnoc,TranRelConfigEq]) >>
    metis_tac[TranRelSnoc])>>
  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
  rpt strip_tac >>
  PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'''`,`P'''`,`S1'''`,`S2'''`,`MTrn1`,`MTrn2`])) >>
  RES_TAC >>
  Q.EXISTS_TAC `(INR y')::t1` >>
  Q.EXISTS_TAC `(INR y')::t2` >>
  rw[binterl_syncR] >-
   (metis_tac[TranRelSnoc])  >>
  metis_tac[TranRelSnoc]
  );

val binterleave_trace_decomp_to_comp_thm = store_thm(
  "binterleave_trace_decomp_to_comp",
  ``∀t Sym P S1 S2 Sym' P' S1' S2' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Ded1 Ded2. 
       (∃t1 t2. (MTrn1 (Sym,(IMAGE OUTL P),S1) t1 (Sym',(IMAGE OUTL P'),S1')) ∧ (MTrn2 (Sym,(IMAGE OUTR P),S2) t2 (Sym',(IMAGE OUTR P'),S2')) ∧ (binterl t1 t2 t))
     ⇒
     ((FST ((MTrn1,Ded1) || (MTrn2,Ded2))) (Sym,P,S1,S2) t (Sym',P',S1',S2'))
     ``,
     rewrite_tac[composeMultiOperation_def] >>
     GEN_TAC >>
     Induct_on `t` >-
      (rpt strip_tac >>
       IMP_RES_TAC binterl_Empty >>
       rw[]>>
       FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
       metis_tac[TranRelConfigEq,IMAGEOUT]) >>
     gen_tac >>
     Cases_on `h` >-
      ( Cases_on `x` >-
         (FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
          rpt strip_tac >>
          IMP_RES_TAC binterl_moveAL >>
          rw[] >>
          IMP_RES_TAC TranRelSnocRevAsyncL >>
          Q.EXISTS_TAC `Sym''` >>
          Q.EXISTS_TAC `P''` >>
          Q.EXISTS_TAC `S1''` >>
          rw[]
          >- (metis_tac[TranRelConfigEq,IMAGEOUT]) >>
          PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym''`,`P''`,`S1''`,`S2'`,`MTrn1`,`MTrn2`])) >>
          IMP_RES_TAC binterl_movesL >>
          RES_TAC) >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
        rpt strip_tac >>
        IMP_RES_TAC binterl_moveSL >>
        rw[] >>
        IMP_RES_TAC TranRelSnocRevSync >>
        Q.EXISTS_TAC `Sym''` >>
        Q.EXISTS_TAC `P''` >>
        Q.EXISTS_TAC `S1''` >>
        Q.EXISTS_TAC `S2''` >>
        rw[] >>
        PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym''`,`P''`,`S1''`,`S2''`,`MTrn1`,`MTrn2`])) >>
        IMP_RES_TAC binterl_movesSL >>
        RES_TAC) >>
     Cases_on `y` >- (
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
      rpt strip_tac >>
      IMP_RES_TAC binterl_moveAR >>
      rw[] >>
      IMP_RES_TAC TranRelSnocRevAsyncR >>
      Q.EXISTS_TAC `Sym''` >>
      Q.EXISTS_TAC `P''` >>
      Q.EXISTS_TAC `S2''` >>
      rw[] >-
       ( metis_tac[TranRelConfigEq,IMAGEOUT]) >>
      PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym''`,`P''`,`S1'`,`S2''`,`MTrn1`,`MTrn2`])) >>
      IMP_RES_TAC binterl_movesR >>
      RES_TAC) >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [composeMuRe_def] >>
     rpt strip_tac >>
     IMP_RES_TAC binterl_moveSR >>
     rw[] >>
     IMP_RES_TAC TranRelSnocRevSync >>
     Q.EXISTS_TAC `Sym''` >>
     Q.EXISTS_TAC `P''` >>
     Q.EXISTS_TAC `S1''` >>
     Q.EXISTS_TAC `S2''` >>
     rw[] >>
     PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym''`,`P''`,`S1''`,`S2''`,`MTrn1`,`MTrn2`])) >>
     IMP_RES_TAC binterl_movesSR >>
     RES_TAC
  );


val binterleave_trace_thm = store_thm(
  "binterleave_trace",
  ``∀t Sym P S1 S2 Sym' P' S1' S2' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Ded1 Ded2. 
       ((FST ((MTrn1,Ded1) || (MTrn2,Ded2))) (Sym,P,S1,S2) t (Sym',P',S1',S2'))
     ⇔
       (∃t1 t2. (MTrn1 (Sym,(IMAGE OUTL P),S1) t1 (Sym',(IMAGE OUTL P'),S1')) ∧ (MTrn2 (Sym,(IMAGE OUTR P),S2) t2 (Sym',(IMAGE OUTR P'),S2')) ∧ (binterl t1 t2 t))
       ``,
     rpt gen_tac >>
     EQ_TAC >>
     rewrite_tac[binterleave_trace_comp_to_decomp_thm] >>
     rewrite_tac[binterleave_trace_decomp_to_comp_thm]
  );

val binterleave_composition_thm = store_thm(
  "binterleave_composition", ``
  ∀Sym P S1 S2 Sym' P' S1' S2' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) Ded1 Ded2.
   (comptraces (FST((MTrn1,Ded1) || (MTrn2,Ded2))) (Sym,P,S1,S2) (Sym',P',S1',S2'))                           
  = (binterleave_ts (traces MTrn1 (Sym,(IMAGE OUTL P),S1) (Sym',(IMAGE OUTL P'),S1')) (traces MTrn2 (Sym,(IMAGE OUTR P),S2) (Sym',(IMAGE OUTR P'),S2')))
``,
rewrite_tac[binterleave_ts,traces_def,comptraces_def,EXTENSION] >>
rw[] >>
rewrite_tac[binterleave_trace_thm]   
  ); 
  

val compose_vs_modules_thm = store_thm(
  "compose_vs_modules_thm", ``
                          !Sym Sym' Sym'' Sym''' P P' P'' P''' S1 S1' S1'' S1''' S2 S2' S2'' S2''' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn1':('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (MTrn2':('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (Ded1:('pred1) tded) (Ded1':('pred1) tded) (Ded2:('pred2) tded) (Ded2':('pred2) tded).
                             (((traces MTrn1 (Sym,(IMAGE OUTL P),S1) (Sym',(IMAGE OUTL P'),S1')) ⊆ (traces MTrn1' (Sym'',(IMAGE OUTL P''),S1'') (Sym''',(IMAGE OUTL P'''),S1'''))) ∧ ((traces MTrn2 (Sym,(IMAGE OUTR P),S2) (Sym',(IMAGE OUTR P'),S2')) ⊆ (traces MTrn2' (Sym'',(IMAGE OUTR P''),S2'') (Sym''',(IMAGE OUTR P'''),S2''')))
                             ) ==> ((comptraces (FST((MTrn1,Ded1) || (MTrn2,Ded2))) (Sym,P,S1,S2) (Sym',P',S1',S2')) ⊆ (comptraces (FST((MTrn1',Ded1') || (MTrn2',Ded2'))) (Sym'',P'',S1'',S2'') (Sym''',P''',S1''',S2'''))) ``
  ,
  rewrite_tac[binterleave_composition_thm,binterleave_ts] >>
  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [SUBSET_DEF] >>
  metis_tac[]
  );

 

val _ = export_theory();
