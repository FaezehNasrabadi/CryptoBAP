open HolKernel Parse boolLib bossLib;
open sumTheory;
open optionTheory;
open pred_setTheory;
open sigma_algebraTheory;
open listTheory;
open tautLib;
open interleavinggeneraldeductionTheory;
open parallelcompositiongeneraldeductionTheory;

val _ = new_theory "derived_rules_generaldeduction";

val traces_def =
Define`
      traces ((MTrn:('event, 'pred, 'state, 'symb) mtrel),(ded:('pred) tded)) ((Sym:'symb set),(P: 'pred set),(S: 'state)) ((Sym':'symb set),(P': 'pred set),(S': 'state)) = {t| (MTrn (Sym,P,S) t (Sym',P',S'))}
                                                                                                                                                                             `;
val comptraces_def =
Define`
      comptraces ((MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel),(Ded1:('pred1) tded)) ((MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel),(Ded2:('pred2) tded)) (ded3:('pred1 + 'pred2) tded) ((Sym:'symb set),(P: ('pred1 + 'pred2) set),(S1: 'state1),(S2: 'state2)) ((Sym':'symb set),(P': ('pred1 + 'pred2) set),(S1': 'state1),(S2': 'state2)) =
{(t: ((('event1 + 'eventS) + 'event2 + 'eventS) option list))|  
 (symbolicParlComp (MTrn1,Ded1) (MTrn2,Ded2) ded3 (Sym,P,S1,S2) t (Sym',P',S1',S2'))
}
`;
        
val IMAGE_SUM_MAP_RI_thm = store_thm(
  "IMAGE_SUM_MAP_RI",
  ``
  ∀ P n.
    PREIMAGE INR (IMAGE (SUM_MAP n I) P) = PREIMAGE INR P
                                                    ``,
                                                    rpt strip_tac >>
  Cases_on ‘P’ >-(
    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[]
    ) >>
  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[IMAGE_INSERT,SUM_MAP_CASE,PREIMAGE_def,EXTENSION] >>
  strip_tac >>
  EQ_TAC >-(
    strip_tac >-(
      Cases_on ‘x''’ THENL [
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sum_case_def] ,
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sum_case_def] ]
      ) >>
    Cases_on ‘x''’ THENL [
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sum_case_def] ,
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sum_case_def] ]
    ) >>
  strip_tac >-(
    Q.EXISTS_TAC `INR x'` >>
    rw[]
    ) >>
  Q.EXISTS_TAC `INR x'` >>
  rw[]
  );

val IMAGE_SUM_MAP_LI_thm = store_thm(
  "IMAGE_SUM_MAP_LI",
  ``
∀ P n.
PREIMAGE INL (IMAGE (SUM_MAP I n) P) = PREIMAGE INL P
``,
     rpt strip_tac >>
  Cases_on ‘P’ >-(
    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[]
    ) >>
  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[IMAGE_INSERT,SUM_MAP_CASE,PREIMAGE_def,EXTENSION] >>
  strip_tac >>
  EQ_TAC >-(
    strip_tac >-(
      Cases_on ‘x''’ THENL [
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sum_case_def] ,
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sum_case_def] ]
      ) >>
    Cases_on ‘x''’ THENL [
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sum_case_def] ,
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sum_case_def] ]
    ) >>
  strip_tac >-(
    Q.EXISTS_TAC `INL x'` >>
    rw[]
    ) >>
  Q.EXISTS_TAC `INL x'` >>
  rw[]
  );


val PREIMAGE_INL_SUM_MAP = prove(
  ``∀P n m. PREIMAGE INL (PREIMAGE SUM_MAP_Rev P) = PREIMAGE INR P``,
  SIMP_TAC std_ss [EXTENSION, IN_PREIMAGE, IN_IMAGE, combinTheory.o_THM] THEN
  REPEAT GEN_TAC THEN
  EQ_TAC THEN STRIP_TAC
     THENL [
        FULL_SIMP_TAC std_ss [SUM_MAP_Rev_def],
        FULL_SIMP_TAC std_ss [SUM_MAP_Rev_def]
  ]
);

val PREIMAGE_INR_SUM_MAP = prove(
  ``∀P n m. PREIMAGE INR (PREIMAGE SUM_MAP_Rev P) = PREIMAGE INL P``,
  SIMP_TAC std_ss [EXTENSION, IN_PREIMAGE, IN_IMAGE, combinTheory.o_THM] THEN
  REPEAT GEN_TAC THEN
  EQ_TAC THEN STRIP_TAC
     THENL [
        FULL_SIMP_TAC std_ss [SUM_MAP_Rev_def],
        FULL_SIMP_TAC std_ss [SUM_MAP_Rev_def]
  ]
  );

  
val SUM_MAP_Rev_SUM_MAP = prove(``∀phi.  (SUM_MAP_Rev (SUM_MAP_Rev phi)) = phi`` ,
                                         REPEAT GEN_TAC >>
                                         Cases_on ‘phi’ >-(
                                           metis_tac[ISL,OUTL,OUTR,SUM_MAP_Rev_def]
                                           ) >>
                                         metis_tac[ISL,OUTL,OUTR,SUM_MAP_Rev_def]
                                     );  

val PREIMAGE_SUM_MAP_PREIMAGE = prove(``∀P.  (PREIMAGE SUM_MAP_Rev (PREIMAGE SUM_MAP_Rev P)) = P`` ,
                                         SIMP_TAC std_ss [EXTENSION, IN_PREIMAGE, IN_IMAGE, combinTheory.o_THM] THEN
                                         REPEAT GEN_TAC >>
                                         Cases_on ‘x’ >-(
                                           metis_tac[ISL,OUTL,OUTR,SUM_MAP_Rev_def]
                                           ) >>
                                         metis_tac[ISL,OUTL,OUTR,SUM_MAP_Rev_def]
                                     );
                                     
                                     
val PREIMAGE_SUM_MAP_Phi = prove(``∀phi.  PREIMAGE SUM_MAP_Rev {SUM_MAP_Rev phi} = {phi}`` ,
                                    SIMP_TAC std_ss [EXTENSION, IN_PREIMAGE, IN_IMAGE, combinTheory.o_THM] THEN
                                    REPEAT GEN_TAC >>
                                    Cases_on ‘phi’ >-(
                                      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def] >>
                                      EQ_TAC >-(
                                        Cases_on ‘x’ THENL [
                                            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL],
                                            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL]
                                          ]) >>
                                      rw[]
                                      ) >>        
                                    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def] >>
                                    EQ_TAC >-(
                                      Cases_on ‘x’ THENL [
                                          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL],
                                          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL]
                                        ]) >>
                                    rw[]
                                );


val combineAllDedRev12 = prove (
                                ``∀(ded1:('pred1) tded) (ded2:('pred2) tded) (ded3:('pred1 + 'pred2) tded) P phi.
                                                        combineAllDed ded1 ded2 ded3 P (SUM_MAP_Rev phi) =  combineAllDed ded2 ded1 (RevDed ded3) (PREIMAGE SUM_MAP_Rev P) phi``,
                                                                                                                          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[combineAllDed_def,RevDed_def] >>
                                   REPEAT GEN_TAC THEN
                                   EQ_TAC >- (
                                    STRIP_TAC >-(
                                      Cases_on ‘phi’ >- (
                                        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def,composeDed_def] >>
                                        metis_tac[PREIMAGE_INL_SUM_MAP]     
                                        ) >>
                                      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def,composeDed_def] >>
                                      metis_tac[PREIMAGE_INR_SUM_MAP]     
                                      ) >>
                                    metis_tac[PREIMAGE_SUM_MAP_PREIMAGE]
                                    ) >>
                                   STRIP_TAC >-(
                                    Cases_on ‘phi’ >- (
                                      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def,composeDed_def] >>
                                      metis_tac[PREIMAGE_INL_SUM_MAP]     
                                      ) >>
                                    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def,composeDed_def] >>
                                    metis_tac[PREIMAGE_INR_SUM_MAP]     
                                    ) >>
                                   metis_tac[PREIMAGE_SUM_MAP_PREIMAGE]
                               );

val combineAllDedRev21 =  prove (
  ``∀(ded1:('pred1) tded) (ded2:('pred2) tded) (ded3:('pred1 + 'pred2) tded) P phi.
                          combineAllDed ded2 ded1 (RevDed ded3) P (SUM_MAP_Rev phi) = combineAllDed ded1 ded2 ded3 (PREIMAGE SUM_MAP_Rev P) phi``,
                                                                                                    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[combineAllDed_def,RevDed_def] >>
     REPEAT GEN_TAC THEN
     EQ_TAC >- (
      STRIP_TAC >-(
        Cases_on ‘phi’ >- (
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def,composeDed_def] >>
          metis_tac[PREIMAGE_INL_SUM_MAP]     
          ) >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def,composeDed_def] >>
        metis_tac[PREIMAGE_INR_SUM_MAP]     
        ) >>
      metis_tac[SUM_MAP_Rev_SUM_MAP]
      ) >>
     STRIP_TAC >-(
      Cases_on ‘phi’ >- (
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def,composeDed_def] >>
        metis_tac[PREIMAGE_INL_SUM_MAP]     
        ) >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def,composeDed_def] >>
      metis_tac[PREIMAGE_INR_SUM_MAP]     
      ) >>
     metis_tac[SUM_MAP_Rev_SUM_MAP]

  );

val PREIMAGE_SUM_MAP_Rev_UNION =  prove (
  ``∀P P' phi.
       (PREIMAGE SUM_MAP_Rev P = P' ∪ {SUM_MAP_Rev phi}) <=> (P = PREIMAGE SUM_MAP_Rev P' ∪ {phi})
                                                             ``,
                                                             SIMP_TAC std_ss [EXTENSION, IN_PREIMAGE, IN_IMAGE, combinTheory.o_THM] THEN
     REPEAT GEN_TAC >>
     EQ_TAC >-(
      rpt STRIP_TAC >>
      EQ_TAC >-(
        STRIP_TAC >>
        Cases_on ‘x’ >- (
          PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INR x'`])) >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def]
          ) >>
        PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INL y`])) >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def]
        ) >>
      STRIP_TAC >>
      Cases_on ‘x’ >- (
        PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INR x'`])) >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def] >>
        rw[]
        ) >>
      PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INL y`])) >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def] >>
      rw[]
      ) >>
     rpt STRIP_TAC >>
     EQ_TAC >-(
      STRIP_TAC >>
      Cases_on ‘x’ >- (
        PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INR x'`])) >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def] >>
        rw[]
        ) >>
      PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INL y`])) >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def] >>
      rw[]
      ) >>
     STRIP_TAC >>
     Cases_on ‘x’ >- (
      PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INR x'`])) >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def] >>
      metis_tac[INR]
      ) >>
     PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INL y`])) >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def] >>
     metis_tac[INL]
  );

val symmetry_generaldeduction_thm = store_thm(
  "symmetry_generaldeduction",
  ``∀t f g  n m Sym P P' S1 S2 Sym' S1' S2'  (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (ded1:('pred1) tded) (ded2:('pred2) tded) (ded3:('pred1 + 'pred2) tded) (ded4:('pred2 + 'pred1) tded).
       (symbolicParlComp (MTrn1,ded1) (MTrn2,ded2) ded3 (Sym,P,S1,S2) t (Sym',P',S1',S2'))
     =
     (symbolicParlComp (MTrn2,ded2) (MTrn1,ded1) (RevDed ded3) (Sym,(PREIMAGE SUM_MAP_Rev P),S2,S1) (MAP (OPTION_MAP (SUM_MAP (SUM_MAP f I) (SUM_MAP g I))) t) (Sym',(PREIMAGE SUM_MAP_Rev P'),S2',S1')) 
     ``,
     GEN_TAC >>
     Induct_on `t` >- (
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[] >>
      rpt strip_tac >>
      EQ_TAC >-(
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
        rw[] >-(
          metis_tac[PREIMAGE_INL_SUM_MAP]
          ) >>
        metis_tac[PREIMAGE_INR_SUM_MAP]
        ) >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
      rw[] >-(
        Cases_on ‘P’ >-(
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[EXTENSION, IN_PREIMAGE,SUM_MAP_Rev_def] >>
          gen_tac     >>     
          Cases_on ‘x’ >- (
            PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INR x'`])) >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR]
            ) >>
          PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INL y`])) >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL]
          ) >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[IMAGE_INSERT,IMAGE_PREIMAGE,EXTENSION] >>
        gen_tac >>
        EQ_TAC >-(
          rw[] >- (
            Cases_on ‘x’ >- (
              PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INR x'`])) >>
              FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def]
              ) >>
            PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INL y`])) >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def]
            ) >>
          Cases_on ‘x'’ >- (
            PAT_X_ASSUM ``!x'. A`` (ASSUME_TAC o (Q.SPECL [`INR x''`])) >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def] >>
            metis_tac[]
            ) >>
          PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INL y`])) >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def] >>
          metis_tac[]
          )>>
        strip_tac >>
        Cases_on ‘x'’ >- (
          PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INR x''`])) >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTR,SUM_MAP_Rev_def]
          ) >>
        PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`INL y`])) >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[ISL,OUTL,SUM_MAP_Rev_def]
        ) >-(
        metis_tac[PREIMAGE_INR_SUM_MAP]
        ) >>
      metis_tac[PREIMAGE_INL_SUM_MAP]                                
      ) >>
     gen_tac >>
     Cases_on `h` >-(
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
      rpt strip_tac >>
      EQ_TAC >- (
        rpt strip_tac >>
        Q.EXISTS_TAC `PREIMAGE SUM_MAP_Rev P''` >>
        rw[] >- (
          PAT_X_ASSUM ``!phi. A`` (ASSUME_TAC o (Q.SPECL [`(SUM_MAP_Rev phi)`])) >>
          metis_tac[combineAllDedRev12] 
          ) >- (
          PAT_X_ASSUM ``!phi. A`` (ASSUME_TAC o (Q.SPECL [`(SUM_MAP_Rev phi)`])) >>
          rw[PREIMAGE_UNION,PREIMAGE_SUM_MAP_Phi]
          ) >>
        PAT_X_ASSUM ``!f g Sym P P' S1 S2 Sym' S1' S2' MTrn1 MTrn2 ded1 ded2 ded3. A`` (ASSUME_TAC o (Q.SPECL [‘f’, ‘g’, ‘Sym’, ‘P’, ‘P''’, ‘S1’, ‘S2’, ‘Sym'’, ‘S1'’, ‘S2'’, ‘MTrn1’, ‘MTrn2’, ‘ded1’, ‘ded2’, ‘ded3’])) >>
        RES_TAC
        ) >>
      rpt strip_tac >>
      Q.EXISTS_TAC `PREIMAGE SUM_MAP_Rev P''` >>
      rw[] >- (
        PAT_X_ASSUM ``!phi. A`` (ASSUME_TAC o (Q.SPECL [`(SUM_MAP_Rev phi)`])) >>
        metis_tac[combineAllDedRev21]
        ) >- (
        PAT_X_ASSUM ``!phi. A`` (ASSUME_TAC o (Q.SPECL [`(SUM_MAP_Rev phi)`])) >>                   
        metis_tac[PREIMAGE_SUM_MAP_Rev_UNION] 
        ) >>
      PAT_X_ASSUM ``!f g Sym P P' S1 S2 Sym' S1' S2' MTrn1 MTrn2 ded1 ded2 ded3. A`` (ASSUME_TAC o (Q.SPECL [‘f’, ‘g’, ‘Sym’, ‘P’, ‘PREIMAGE SUM_MAP_Rev P''’, ‘S1’, ‘S2’, ‘Sym'’, ‘S1'’, ‘S2'’, ‘MTrn1’, ‘MTrn2’, ‘ded1’, ‘ded2’, ‘ded3’])) >>       
      metis_tac[PREIMAGE_SUM_MAP_PREIMAGE]
      ) >>
     Cases_on ‘x’ >- (
      Cases_on ‘x'’ >- (
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def,OPTION_MAP_CASE,MAP,option_case_def] >>
        rpt strip_tac >>
        EQ_TAC >- (
          rw[TranRelNil] >>
          Q.EXISTS_TAC `PREIMAGE SUM_MAP_Rev P'` >>
          metis_tac[PREIMAGE_INR_SUM_MAP]
          ) >>
        rw[TranRelNil] >>
        Q.EXISTS_TAC `P'` >>
        metis_tac[PREIMAGE_INL_SUM_MAP]                       
        )>>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def,OPTION_MAP_CASE,MAP,option_case_def] >>
      rpt strip_tac >>
      EQ_TAC >- (
        rw[TranRelNil] ) >>
      rw[TranRelNil]
      ) >>
     Cases_on ‘y’ >- (
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def,OPTION_MAP_CASE,MAP,option_case_def] >>
      rpt strip_tac >>
      EQ_TAC >- (
        rw[TranRelNil] >>
        Q.EXISTS_TAC `PREIMAGE SUM_MAP_Rev P'` >>
        metis_tac[PREIMAGE_INL_SUM_MAP] 
        ) >>
      rw[TranRelNil] >>
      Q.EXISTS_TAC `P'` >>
      metis_tac[PREIMAGE_INR_SUM_MAP]
      ) >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def,OPTION_MAP_CASE,MAP,option_case_def] >>
     rpt strip_tac >>
     EQ_TAC >- (
      rw[TranRelNil] ) >>
     rw[TranRelNil]
  )




val associativity_generaldeduction_thm = store_thm(
  "associativity_generaldeduction",
  ``∀(t:((('event1 + 'eventS)+('event2 + 'eventS))+(('event3 + 'eventS)+('event2 + 'eventS))) option list) (f: 'event3 -> 'event2) (g: 'event2 -> 'event3) (n: 'pred1 -> 'pred3) (Sym:('symb -> bool)) (Sym':('symb -> bool)) (P :(('pred1 + 'pred2) + ('pred1 + 'pred2) + 'pred3) -> bool) (P' :(('pred1 + 'pred2) + ('pred1 + 'pred2) + 'pred3) -> bool) (S1: 'state1) (S2: 'state2) (S3: 'state3) (S1': 'state1) (S2': 'state2) (S3': 'state3)
       (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (MTrn3:('event3 + 'eventS, 'pred3, 'state3, 'symb) mtrel)
       (ded1:('pred1) tded) (ded2:('pred2) tded) (ded3:('pred3) tded) (Comded12:('pred1 + 'pred2) tded) (Comded3:(('pred1 + 'pred2) + ('pred1 + 'pred2) + 'pred3) tded)
       (Comded23:('pred2 + 'pred3) tded) (Comded1:(('pred1 + 'pred2 + 'pred3) + 'pred2 + 'pred3) tded).
                         
       (symbolicParlComp
        (((symbolicParlComp (MTrn1,ded1) (MTrn2,ded2) Comded12):((('event1+'eventS) + ('event2 +'eventS)), ('pred1 + 'pred2), 'state1 # 'state2, 'symb) mtrel),Comded12)
        (((doubleLeftMTrn MTrn3:((('event3+'eventS) + ('event2 +'eventS)), (('pred1 + 'pred2) + 'pred3), ('state1 # 'state2) # 'state3, 'symb) mtrel)),((doubleLeftDed ded3):(('pred1 + 'pred2) + 'pred3) tded))
        Comded3 (Sym,P,(S1,S2),(S1,S2),S3) t (Sym',P',(S1',S2'),(S1',S2'),S3')) =
     (symbolicParlComp
      (((doubleRightMTrn MTrn1):((('event1+'eventS) + ('event3 +'eventS)), ('pred1 + ('pred2 + 'pred3)), ('state1 # ('state2 # 'state3)), 'symb) mtrel),((doubleRightDed ded1):('pred1 + ('pred2 + 'pred3)) tded))
      (((symbolicParlComp (MTrn2,ded2) (MTrn3,ded3) Comded23):((('event2+'eventS) + ('event3 +'eventS)), ('pred2 + 'pred3), 'state2 # 'state3, 'symb) mtrel),Comded23)
      Comded1 (Sym,(prSum P),(S1,S2,S3),S2,S3) (MAP (OPTION_MAP (SUM_MAP (SUM_MAP (SUM_MAP I I) (SUM_MAP g I)) (SUM_MAP (SUM_MAP f I) (SUM_MAP g I)))) t) (Sym',(prSum P'),(S1',S2',S3'),S2',S3'))
     ``,
 
     GEN_TAC >>
     Induct_on `t` >- (
      rpt strip_tac >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
      rw[TranRelNil]>>
      metis_tac[prSum_Eq]
      ) >>
     gen_tac >>
     Cases_on `h` >-(
      rpt strip_tac >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
      rw[TranRelNil]>>
      EQ_TAC >-(
        rw[] >>
        Q.EXISTS_TAC `prSum P''` >>
        metis_tac[combineAllDedprSum12]
        ) >>
      rw[] >>
      Q.EXISTS_TAC `prSumRev P''` >>
      metis_tac[combineAllDedprSum23]
      ) >>
     Cases_on ‘x’ >- (
      Cases_on ‘x'’ >- (
        rpt strip_tac >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
        rw[TranRelNil]>>
        EQ_TAC >-(
          rw[] >>        
          Q.EXISTS_TAC `prSum P'` >>
          metis_tac[]
          ) >>
        rw[] >>        
        Q.EXISTS_TAC `P'` >>
        metis_tac[]
        ) >>
      rpt strip_tac >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
      rw[TranRelNil]
      ) >>
     Cases_on ‘y’ >- (     
      rpt strip_tac >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
      rw[TranRelNil] >>
      EQ_TAC >-(
        rw[] >>        
        Q.EXISTS_TAC `prSum P'` >>
        metis_tac[]         
        ) >>             
      rw[] >>        
      Q.EXISTS_TAC `P'` >>
      metis_tac[]       
      ) >>
     rpt strip_tac >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
     rw[TranRelNil]                
  )

        
val binterleave_trace_comp_to_decomp_generaldeduction_thm = store_thm(
  "binterleave_trace_comp_to_decomp_generaldeduction",
  ``∀t Sym P S1 S2 Sym' P' S1' S2' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (ded1:('pred1) tded) (ded2:('pred2) tded) (ded3:('pred1 + 'pred2) tded).
       (TransDisable ded3 (MTrn1,ded1) (MTrn2,ded2)) ⇒
       ((symbolicParlComp (MTrn1,ded1) (MTrn2,ded2) ded3 (Sym,P,S1,S2) t (Sym',P',S1',S2'))
     ⇒
     (∃t1 t2.
        (MTrn1 (Sym,(PREIMAGE INL P),S1) t1 (Sym',(PREIMAGE INL P'),S1')) ∧
        (MTrn2 (Sym,(PREIMAGE INR P),S2) t2 (Sym',(PREIMAGE INR P'),S2')) ∧
        (binterl t1 t2 t)))``,
                          GEN_TAC >>
     Induct_on `t` >- (
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def]>>     
      rpt strip_tac >>
      Q.EXISTS_TAC `[]` >>
      Q.EXISTS_TAC `[]` >>
      metis_tac[binterl_nil]) >>
     gen_tac >>
     Cases_on `h` >- (
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[symbolicParlComp_def] >>
      rpt strip_tac >>
      PAT_X_ASSUM ``!phi. A`` (ASSUME_TAC o (Q.SPECL [`phi`])) >>
      PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2 ded1 ded2 ded3. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'`,`P''`,`S1'`,`S2'`,`MTrn1`,`MTrn2`,`ded1`,`ded2`,`ded3`]))>>
      RES_TAC >>
      Q.EXISTS_TAC `t1` >>
      Q.EXISTS_TAC `t2` >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[]>>
      metis_tac[TransDisable_def,binterl_combinenone] 
      )   >>
     Cases_on `x` >-(
      Cases_on `x'` >-(
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
        rpt strip_tac >>
        PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2 ded1 ded2 ded3. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'''`,`P'''`,`S1'''`,`S2'`,`MTrn1`,`MTrn2`,`ded1`,`ded2`,`ded3`])) >>
        RES_TAC >>
        Q.EXISTS_TAC `(SOME (INL x))::t1` >>
        Q.EXISTS_TAC `t2` >>
        metis_tac[TranRelNil,TranRelSnoc,TranRelConfigEq,binterl_left]
        ) >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
      rpt strip_tac >>
      PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'''`,`P'''`,`S1'''`,`S2'''`,`MTrn1`,`MTrn2`])) >>
      RES_TAC >>
      Q.EXISTS_TAC `(SOME (INR y))::t1` >>
      Q.EXISTS_TAC `(SOME (INR y))::t2` >>
      rw[binterl_syncL] >- (metis_tac[TranRelSnoc])  >>
      metis_tac[TranRelSnoc]
      ) >>
     Cases_on `y` >- (
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
      rpt strip_tac >>
      PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'''`,`P'''`,`S1'`,`S2'''`,`MTrn1`,`MTrn2`])) >>
      RES_TAC >>
      Q.EXISTS_TAC `t1` >>
      Q.EXISTS_TAC `(SOME (INL x))::t2` >>
      metis_tac[binterl_right,TranRelNil,TranRelSnoc,TranRelConfigEq])>>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
     rpt strip_tac >>
     PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'''`,`P'''`,`S1'''`,`S2'''`,`MTrn1`,`MTrn2`])) >>
     RES_TAC >>
     Q.EXISTS_TAC `(SOME (INR y'))::t1` >>
     Q.EXISTS_TAC `(SOME (INR y'))::t2` >>
     metis_tac[binterl_syncR,TranRelSnoc]
  );


val binterleave_composition_generaldeduction_subseteq_thm = store_thm(
  "binterleave_composition_generaldeduction_subseteq",
  ``∀Sym P S1 S2 Sym' P' S1' S2' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (Ded1:('pred1) tded) (Ded2:('pred2) tded) (ded3:('pred1 + 'pred2) tded).
         (TransDisable ded3 (MTrn1,Ded1) (MTrn2,Ded2)) ⇒
         ((comptraces (MTrn1,Ded1) (MTrn2,Ded2) ded3 (Sym,P,S1,S2) (Sym',P',S1',S2'))                           
      ⊆ (binterleave_ts (traces (MTrn1,Ded1) (Sym,(PREIMAGE INL P),S1) (Sym',(PREIMAGE INL P'),S1')) (traces (MTrn2,Ded2) (Sym,(PREIMAGE INR P),S2) (Sym',(PREIMAGE INR P'),S2'))))
       ``,
       rpt gen_tac >>      
     rewrite_tac[binterleave_ts,traces_def,comptraces_def,EXTENSION] >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [SUBSET_DEF] >>
     metis_tac[binterleave_trace_comp_to_decomp_generaldeduction_thm]   
  );

  
val binterleave_trace_decomp_to_comp_generaldeduction_thm = store_thm(
  "binterleave_trace_decomp_to_comp_generaldeduction",
  ``∀t Sym P S1 S2 Sym' P' S1' S2' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (ded1:('pred1) tded) (ded2:('pred2) tded) (ded3:('pred1 + 'pred2) tded). 
       TransEnable ded3 (MTrn1,ded1) (MTrn2,ded2) ⇒
       ((∃t1 t2. (MTrn1 (Sym,(PREIMAGE INL P),S1) t1 (Sym',(PREIMAGE INL P'),S1')) ∧ (MTrn2 (Sym,(PREIMAGE INR P),S2) t2 (Sym',(PREIMAGE INR P'),S2')) ∧ (binterl t1 t2 t))
     ⇒
     (symbolicParlComp (MTrn1,ded1) (MTrn2,ded2) ded3 (Sym,P,S1,S2) t (Sym',P',S1',S2')))
     ``,
     GEN_TAC >>
     Induct_on `t` >-
      (rpt strip_tac >>
       IMP_RES_TAC binterl_Empty >>
       rw[]>>
       FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
       metis_tac[TranRelConfigEq,SUM_PREIMAGE_CHAR]) >>
     gen_tac >>
     reverse(Cases_on `h`) >-
      (Cases_on `x` >- (
        Cases_on `x'` >- 
         (FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
          rpt strip_tac >>
          IMP_RES_TAC binterl_moveAL >>
          rw[] >>
          IMP_RES_TAC TranRelSnocRevAsyncL >>
          Q.EXISTS_TAC `Sym''` >>
          Q.EXISTS_TAC `P''` >>
          Q.EXISTS_TAC `S1''` >>
          rw[]
          >- (metis_tac[TranRelConfigEq,SUM_PREIMAGE_CHAR]) >>
          PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2 ded1 ded2 ded3. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym''`,`P''`,`S1''`,`S2'`,`MTrn1`,`MTrn2`,`ded1`,`ded2`,`ded3`])) >>
          IMP_RES_TAC binterl_movesL >>
          RES_TAC) >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
        rpt strip_tac >>
        IMP_RES_TAC binterl_moveSL >>
        rw[] >>
        IMP_RES_TAC TranRelSnocRevSync >>
        Q.EXISTS_TAC `Sym''`
        >>
        Q.EXISTS_TAC `P''` >>
        Q.EXISTS_TAC `S1''` >>
        Q.EXISTS_TAC `S2''` >>
        rw[] >>
        PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2 ded1 ded2 ded3. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym''`,`P''`,`S1''`,`S2''`,`MTrn1`,`MTrn2`,`ded1`,`ded2`,`ded3`])) >>
        IMP_RES_TAC binterl_movesSL >>
        RES_TAC)
       >>
       Cases_on `y` >- (
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
        rpt strip_tac >>
        IMP_RES_TAC binterl_moveAR >>
        rw[] >>
        IMP_RES_TAC TranRelSnocRevAsyncR >>
        Q.EXISTS_TAC `Sym''`
        >>
        Q.EXISTS_TAC `P''` >>
        Q.EXISTS_TAC `S2''` >>
        rw[]
        >- ( metis_tac[TranRelConfigEq,SUM_PREIMAGE_CHAR]) >>
        PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2 ded1 ded2 ded3. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym''`,`P''`,`S1'`,`S2''`,`MTrn1`,`MTrn2`,`ded1`,`ded2`,`ded3`])) >>
        IMP_RES_TAC binterl_movesR >>
        RES_TAC) >>
       FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
       rpt strip_tac >>
       IMP_RES_TAC binterl_moveSR >>
       rw[] >>
       IMP_RES_TAC TranRelSnocRevSync >>
       Q.EXISTS_TAC `Sym''` >>
       Q.EXISTS_TAC `P''` >>
       Q.EXISTS_TAC `S1''` >>
       Q.EXISTS_TAC `S2''` >>
       rw[] >>
       PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2 ded1 ded2 ded3. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym''`,`P''`,`S1''`,`S2''`,`MTrn1`,`MTrn2`,`ded1`,`ded2`,`ded3`])) >>
       IMP_RES_TAC binterl_movesSR >>
       RES_TAC) >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [symbolicParlComp_def] >>
     rpt strip_tac >>
     IMP_RES_TAC TranRelSnocRevNone>>
     IMP_RES_TAC binterl_movecombinenone >>
     PAT_X_ASSUM ``!Sym P S1 S2 Sym' P' S1' S2' MTrn1 MTrn2 ded1 ded2 ded3. A`` (ASSUME_TAC o (Q.SPECL [`Sym`,`P`,`S1`,`S2`,`Sym'`,`P''`,`S1'`,`S2'`,`MTrn1`,`MTrn2`,`ded1`,`ded2`,`ded3`])) >>
     RES_TAC >>
     Q.EXISTS_TAC `P''` >>
     PAT_X_ASSUM ``!Ded1 Ded2 Ded3. A`` (ASSUME_TAC o (Q.SPECL [`ded1`,`ded2`,`ded3`]))  >>
     PAT_X_ASSUM ``!Ded1 Ded2 Ded3. A`` (ASSUME_TAC o (Q.SPECL [`ded1`,`ded2`,`ded3`]))  >>
     rw[TransEnable_def] 
  );


val binterleave_composition_generaldeduction_supseteq_thm = store_thm(
  "binterleave_composition_generaldeduction_supseteq",
  ``∀Sym P S1 S2 Sym' P' S1' S2' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (Ded1:('pred1) tded) (Ded2:('pred2) tded) (ded3:('pred1 + 'pred2) tded).
         TransEnable ded3 (MTrn1,Ded1) (MTrn2,Ded2) ⇒
         ((binterleave_ts (traces (MTrn1,Ded1) (Sym,(PREIMAGE INL P),S1) (Sym',(PREIMAGE INL P'),S1')) (traces (MTrn2,Ded2) (Sym,(PREIMAGE INR P),S2) (Sym',(PREIMAGE INR P'),S2'))) ⊆
         (comptraces (MTrn1,Ded1) (MTrn2,Ded2) ded3 (Sym,P,S1,S2) (Sym',P',S1',S2')))
       ``,
         rpt gen_tac >>      
     rewrite_tac[binterleave_ts,traces_def,comptraces_def,EXTENSION] >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [SUBSET_DEF] >>
     metis_tac[binterleave_trace_decomp_to_comp_generaldeduction_thm]     
  );
  
 

val compose_vs_modules_generaldeduction_enable_disable_thm = store_thm(
  "compose_vs_modules_generaldeduction_enable_disable_thm",
  ``!Sym Sym' Sym'' Sym''' P P' P'' P''' S1 S1' S1'' S1''' S2 S2' S2'' S2''' (MTrn1:('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn1':('event1 + 'eventS, 'pred1, 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (MTrn2':('event2 + 'eventS, 'pred2, 'state2, 'symb) mtrel) (Ded1:('pred1) tded) (Ded1':('pred1) tded) (Ded2:('pred2) tded) (Ded2':('pred2) tded) (ded3:('pred1 + 'pred2) tded).
     (((traces (MTrn1,Ded1) (Sym,(PREIMAGE INL P),S1) (Sym',(PREIMAGE INL P'),S1')) ⊆ (traces (MTrn1',Ded1') (Sym'',(PREIMAGE INL P''),S1'') (Sym''',(PREIMAGE INL P'''),S1'''))) ∧
      ((traces (MTrn2,Ded2) (Sym,(PREIMAGE INR P),S2) (Sym',(PREIMAGE INR P'),S2')) ⊆ (traces (MTrn2',Ded2') (Sym'',(PREIMAGE INR P''),S2'') (Sym''',(PREIMAGE INR P'''),S2'''))) ∧
      (TransDisable ded3 (MTrn1,Ded1) (MTrn2,Ded2)) ∧
      (TransEnable ded3 (MTrn1',Ded1') (MTrn2',Ded2'))
 ) ==> ((comptraces (MTrn1,Ded1) (MTrn2,Ded2) ded3 (Sym,P,S1,S2) (Sym',P',S1',S2')) ⊆ (comptraces (MTrn1',Ded1') (MTrn2',Ded2') ded3 (Sym'',P'',S1'',S2'') (Sym''',P''',S1''',S2'''))) ``
  ,
rpt gen_tac >>      
rewrite_tac[binterleave_ts,traces_def,comptraces_def,EXTENSION] >>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [SUBSET_DEF] >>
rw[] >>
IMP_RES_TAC binterleave_trace_comp_to_decomp_generaldeduction_thm >>
PAT_X_ASSUM ``!t2. A`` (ASSUME_TAC o (Q.SPECL [`t2`])) >>
PAT_X_ASSUM ``!t1. A`` (ASSUME_TAC o (Q.SPECL [`t1`])) >>
RES_TAC >>
metis_tac[binterleave_trace_decomp_to_comp_generaldeduction_thm]
  );  



val _ = export_theory();
