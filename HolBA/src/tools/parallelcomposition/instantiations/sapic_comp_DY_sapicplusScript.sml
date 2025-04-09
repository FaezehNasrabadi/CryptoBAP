open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open sigma_algebraTheory;
open listTheory;
open tautLib;
open interleavinggeneraldeductionTheory;
open parallelcompositiongeneraldeductionTheory;
open translate_to_sapicTheory;
open derived_rules_generaldeductionTheory;
open sbir_treeTheory;
open sapicplusTheory;
open messagesTheory;
open dolevyaoTheory;
open combined_deductionTheory;

val _ = new_theory "sapic_comp_DY_sapicplus";



val spaicplus_to_sapic_vs_DY_single_transition_thm = store_thm(
  "spaicplus_to_sapic_vs_DY_single_transition_thm",
  ``∀e Re' NRe' i' i Re NRe Pr' Pr (Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(SPpred + DYpred -> bool)) (P':(SPpred + DYpred -> bool)) (Ded:(SPpred) tded) (ded3:(SPpred + DYpred) tded).
       sapic_plus_position_transition_with_symb (Sym,P,(Pconfig_plus (Pr,i,Re,NRe))) e
       (Sym',P',(Pconfig_plus (Pr',i',Re',NRe'))) ⇒
     ∃e1 e2.
       sapic_position_transition_with_symb (Sym,IMAGE OUTL P,(Pconfig (Pr,i,Re,NRe))) e1
                                           (Sym',IMAGE OUTL P',(Pconfig (Pr',i',Re',NRe'))) ∧
       DYtranrel (Sym,IMAGE OUTR P,ESt) e2 (Sym',IMAGE OUTR P',ESt) ∧
       binterl [e1] [e2] [e]``,

               GEN_TAC >>
     Cases_on ‘e’ >- (
      rw[sapic_plus_position_transition_with_symb_def]>>
      Q.EXISTS_TAC `NONE` >>
      Q.EXISTS_TAC `NONE` >>
      rw[sapic_position_transition_with_symb_def,DYtranrel_def]>>
      metis_tac[binterl_def]
      )
     (*end of NONE*)
     >> (
      Cases_on `x` >- (
        Cases_on `x'` >- (
          Cases_on `x` >- (
            rw[sapic_plus_position_transition_with_symb_def] >>
            Cases_on `l` >- (        
              FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[]) >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[] >>
            Cases_on `t` >>        
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[] >> (
              Cases_on `F'` >-(
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[FactTag_t_distinct,FactTag_t_case_def] >> 
                Cases_on `h` >-(
                  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[SapicTerm_t_distinct,SapicTerm_t_case_def] >>
                  IMP_RES_TAC sapic_plus_position_new_transition_def >>                          
                  rw[] >>
                  Q.EXISTS_TAC `(SOME (INL (Fact FreshFact [Con N])))` >>
                  Q.EXISTS_TAC `NONE` >>
                  rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_new_transition_def,DYtranrel_def] >>
                  metis_tac[binterl_moveALN,binterl_nil]
                  ) >>
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[SapicTerm_t_distinct,SapicTerm_t_case_def] >>
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[SapicTerm_t_distinct,SapicTerm_t_case_def] 
                ) (*FreshFact*) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[FactTag_t_distinct,FactTag_t_case_def] >>
                IMP_RES_TAC sapic_plus_position_out_transition_def >>                          
                rw[] >>
                Q.EXISTS_TAC `(SOME (INL (Fact OutFact [h])))` >>
                Q.EXISTS_TAC `NONE` >>
                rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_out_transition_def,DYtranrel_def] >>
                metis_tac[binterl_moveALN,binterl_nil]
                ) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[FactTag_t_distinct,FactTag_t_case_def] >>
                Cases_on `h` >-(
                  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[SapicTerm_t_distinct,SapicTerm_t_case_def]
                  ) >-(
                  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[SapicTerm_t_distinct,SapicTerm_t_case_def] >>    
                  IMP_RES_TAC sapic_plus_position_in_transition_def >>                          
                  rw[] >>
                  Q.EXISTS_TAC `(SOME (INL (Fact InFact [TVar V])))` >>
                  Q.EXISTS_TAC `NONE` >>
                  rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_in_transition_def,DYtranrel_def] >>
                  metis_tac[binterl_moveALN,binterl_nil]
                  ) >> 
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[SapicTerm_t_distinct,SapicTerm_t_case_def]
                ) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[FactTag_t_distinct,FactTag_t_case_def]
                ) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[FactTag_t_distinct,FactTag_t_case_def]
                ) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[FactTag_t_distinct,FactTag_t_case_def] >- (
                  IMP_RES_TAC sapic_plus_position_let_false_transition_def >>                          
                  rw[] >>
                  Q.EXISTS_TAC `(SOME (INL (Fact DedFact [h])))` >>
                  Q.EXISTS_TAC `NONE` >>
                  rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_let_false_transition_def,DYtranrel_def] >>
                  metis_tac[binterl_moveALN,binterl_nil]
                  ) >>
                IMP_RES_TAC sapic_plus_position_let_true_transition_def >>                          
                rw[] >>
                Q.EXISTS_TAC `(SOME (INL (Fact DedFact [h])))` >>
                Q.EXISTS_TAC `NONE` >>
                rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_let_true_transition_def,DYtranrel_def] >>
                metis_tac[binterl_moveALN,binterl_nil]
                ) >>
              FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[FactTag_t_distinct,FactTag_t_case_def] >>
              Cases_on ‘Pr’ >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def]
                ) (*ProcessNull*) >- (
                Cases_on ‘P2’ >- (
                  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def]
                  ) >- (
                  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def] >- (
                    IMP_RES_TAC sapic_plus_position_ndc_transition_def >>
                    Q.EXISTS_TAC `(SOME (INL (Fact TermFact [t])))` >>
                    Q.EXISTS_TAC `NONE` >>
                    rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_ndc_transition_def,DYtranrel_def] >>
                    metis_tac[binterl_moveALN,binterl_nil]
                    ) >>
                  IMP_RES_TAC sapic_plus_position_ndc_transition_def >>
                  Q.EXISTS_TAC `(SOME (INL (Fact TermFact [t])))` >>
                  Q.EXISTS_TAC `NONE` >>
                  rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_ndc_transition_def,DYtranrel_def] >>
                  metis_tac[binterl_moveALN,binterl_nil]
                  ) (*NDC*) >- (
                  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def] >- (
                    IMP_RES_TAC sapic_plus_position_conditional_true_transition_def >>
                    Q.EXISTS_TAC `(SOME (INL (Fact TermFact [e])))` >>
                    Q.EXISTS_TAC `NONE` >>
                    rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_conditional_true_transition_def,DYtranrel_def] >>
                    metis_tac[binterl_moveALN,binterl_nil]
                    ) >>
                    IMP_RES_TAC sapic_plus_position_conditional_false_transition_def >>
                    Q.EXISTS_TAC `(SOME (INL (Fact TermFact [e])))` >>
                    Q.EXISTS_TAC `NONE` >>
                    rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_conditional_false_transition_def,DYtranrel_def] >>
                    metis_tac[binterl_moveALN,binterl_nil]
                  ) >- (
                  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def]
                  )  >- (
                  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def]
                  ) >- (
                  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def]
                  )  >>
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def]
                )(*ProcessComb*) >>
              Cases_on ‘S'’ >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]>>
                IMP_RES_TAC sapic_plus_position_replication_transition_def >>
                Q.EXISTS_TAC `(SOME (INL (Fact TermFact [t])))` >>
                Q.EXISTS_TAC `NONE` >>
                rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_replication_transition_def,DYtranrel_def] >>
                metis_tac[binterl_moveALN,binterl_nil]
                )(*Rep*) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
                ) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
                ) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
                ) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def] >>
                IMP_RES_TAC sapic_plus_position_event_transition_def >>
                Q.EXISTS_TAC `(SOME (INL (Fact TermFact [t])))` >>
                Q.EXISTS_TAC `NONE` >>
                rw[sapic_position_transition_with_symb_def,sapic_position_transition_def,sapic_position_event_transition_def,DYtranrel_def] >>
                metis_tac[binterl_moveALN,binterl_nil]
                )(*Event*) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
                ) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
                ) >- (
                FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
                ) >> 
              FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
              (*SapicAction*)
              (*TermFact*)
              )          
            )
          )
        (*end of cases on x*)
        >> (
          Cases_on `y` >- (
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INR (P2A v)))` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveSLN,binterl_nil]
            ) >- (
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INR (A2P v)))` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveSLN,binterl_nil]
            ) >- (
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INR (Crypto p)))` >>
            Cases_on `p` >>
            Cases_on `r` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveSLN,binterl_nil]
            ) >- (
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INR (Sync_Fr n)))` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveSLN,binterl_nil]
            )
          )
        )
      (*end of cases on x'*)
      >> (
        Cases_on `y` >- (
          Cases_on `x` >- (                
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INL (Silent N)))` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveARN,binterl_nil]
            ) >- (                
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INL (Ded D)))` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveARN,binterl_nil]
            )
            >> (
            Cases_on `p`  >>
            rw[sapic_plus_position_transition_with_symb_def] >>                                                                                      
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INL (Alias (q,r))))` >>
            IMP_RES_TAC DYtranrel_def >>
            reverse (FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sapic_position_transition_with_symb_def,sapic_position_transition_def]) >>
            metis_tac[binterl_moveARN,binterl_nil]
            )
          ) >> (
          Cases_on `y'` >- (
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INR (P2A v)))` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveSRN,binterl_nil]
            ) >- (
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INR (A2P v)))` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveSRN,binterl_nil]
            ) >- (
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INR (Crypto p)))` >>
            Cases_on `p` >>
            Cases_on `r` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveSRN,binterl_nil]
            ) >- (
            rw[sapic_plus_position_transition_with_symb_def] >>
            Q.EXISTS_TAC `NONE` >>
            Q.EXISTS_TAC `(SOME (INR (Sync_Fr n)))` >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_position_transition_with_symb_def,DYtranrel_def] >>
            metis_tac[binterl_moveSRN,binterl_nil]
            )
          )
        )
      )
  (*end of SOME*)
  )



val sapic_vs_DY_to_spaicplus_single_transition_thm = store_thm(
  "sapic_vs_DY_to_spaicplus_single_transition_thm",
  ``∀e Re' NRe' i' i Re NRe Pr' Pr (Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(SPpred + DYpred -> bool)) (P':(SPpred + DYpred -> bool)) (Ded:(SPpred) tded) (ded3:(SPpred + DYpred) tded).
       (∃e1 e2.
          sapic_position_transition_with_symb (Sym,IMAGE OUTL P,(Pconfig (Pr,i,Re,NRe))) e1
                                              (Sym',IMAGE OUTL P',(Pconfig (Pr',i',Re',NRe'))) ∧
          DYtranrel (Sym,IMAGE OUTR P,ESt) e2 (Sym',IMAGE OUTR P',ESt) ∧
          binterl [e1] [e2] [e]) ⇒
     (sapic_plus_position_transition_with_symb (Sym,P,(Pconfig_plus (Pr,i,Re,NRe))) e
      (Sym',P',(Pconfig_plus (Pr',i',Re',NRe')))) 
     ``,
     GEN_TAC >>
     Induct_on `e` >-
      (rpt strip_tac >>
       IMP_RES_TAC binterl_moveNONE >>
       rw[]>>
       FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sapic_plus_position_transition_with_symb_def] >>
       IMP_RES_TAC DYtranrel_def >>
       ASM_SIMP_TAC (srw_ss()) [] >>      
       IMP_RES_TAC sapic_position_transition_with_symb_def 
       >- (metis_tac[IMAGEOUT])  >>              
       metis_tac[IMAGEOUT]
      )(*end of NONE *)
     >>
     Cases_on ‘a’ >- (
      Cases_on ‘x’ >- (
        rpt strip_tac >>
        IMP_RES_TAC binterl_moveNAL >>
        rw[] >>
        IMP_RES_TAC sapic_position_transition_with_symb_def >>
        Cases_on ‘Pr’ >- (
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def]
          )(*ProcessNull*) >-(
          Cases_on ‘P2’ >- (       
            IMP_RES_TAC sapic_position_transition_def >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def]
            )(*Parallel*) >- (       
            IMP_RES_TAC sapic_position_transition_def >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def] >>
            IMP_RES_TAC sapic_position_ndc_transition_def >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_ndc_transition_def]
            ) (*NDC*) >- (       
            IMP_RES_TAC sapic_position_transition_def >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def] >- (
              IMP_RES_TAC sapic_position_conditional_true_transition_def >>
              IMP_RES_TAC DYtranrel_def >>
              rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_conditional_true_transition_def]
              ) >>
            IMP_RES_TAC sapic_position_conditional_false_transition_def >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_conditional_false_transition_def]    
            ) (*CondEq*) >- (       
            IMP_RES_TAC sapic_position_transition_def >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def]
            ) (*Cond*)>- (       
            IMP_RES_TAC sapic_position_transition_def >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def]
            ) (*Lookup*) >-(
            IMP_RES_TAC sapic_position_transition_def >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def] >- (
              IMP_RES_TAC sapic_position_let_true_transition_def >>
              IMP_RES_TAC DYtranrel_def >>
              rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_let_true_transition_def]
              ) (*true*) >>
            IMP_RES_TAC sapic_position_let_false_transition_def >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_let_false_transition_def]
            ) (*Let*) >>
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,ProcessCombinator_t_distinct,ProcessCombinator_t_case_def]
          )(*ProcessComb*) >>
        Cases_on ‘S'’ >- (
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]>>
          IMP_RES_TAC sapic_position_replication_transition_def >>
          IMP_RES_TAC DYtranrel_def >>
          rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_replication_transition_def]
          )(*Rep*)>-(
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]>>
          IMP_RES_TAC sapic_position_new_transition_def >>
          IMP_RES_TAC DYtranrel_def >>
          rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_new_transition_def]
          )(*New*)>- (
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]>>
          Cases_on ‘S''’ >-(
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[SapicTerm_t_distinct,SapicTerm_t_case_def]   
            )(*Con*)>-(
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[SapicTerm_t_distinct,SapicTerm_t_case_def] >>
            Cases_on ‘o'’ >-(
              FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[]
              )(*NONE*) >>
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[] >>
            IMP_RES_TAC sapic_position_in_transition_def >>
            IMP_RES_TAC DYtranrel_def >>
            rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_in_transition_def]
            )(*TVar*) >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[SapicTerm_t_distinct,SapicTerm_t_case_def]            
          )(*ChIn*)>-(
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]>>
          Cases_on ‘o'’ >-(
            FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[]
            )(*NONE*) >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[] >>
          IMP_RES_TAC sapic_position_out_transition_def >>
          IMP_RES_TAC DYtranrel_def >>
          rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_out_transition_def]
          )(*ChOut*)>-(
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]>>
          IMP_RES_TAC sapic_position_event_transition_def >>
          IMP_RES_TAC DYtranrel_def >>
          rw[sapic_plus_position_transition_with_symb_def,sapic_plus_position_event_transition_def]
          )(*Event*) >- (
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
          )(*Insert*) >- (
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
          )(*Delete*) >- (
          IMP_RES_TAC sapic_position_transition_def >>
          FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
          )(*Lock*) >>
        IMP_RES_TAC sapic_position_transition_def >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[Process_t_distinct,Process_t_case_def,SapicAction_t_distinct,SapicAction_t_case_def]
        (*Unlock*)              
        (*ProcessAction*)
        (*end of Process*)
        )(*end of (SOME (INL (INL x')))*) >>                  
      Cases_on ‘y’ >- (
        rpt strip_tac >>
        IMP_RES_TAC binterl_moveSL >>
        rw[] >>
        IMP_RES_TAC sapic_position_transition_with_symb_def >>
        IMP_RES_TAC DYtranrel_def >>
        rw[sapic_plus_position_transition_with_symb_def]
        )(*end of 1-Case of (SOME (INL (INR y))) => P2A *) >- (
        rpt strip_tac >>
        IMP_RES_TAC binterl_moveSL >>
        rw[] >>
        IMP_RES_TAC sapic_position_transition_with_symb_def >>
        IMP_RES_TAC DYtranrel_def >>
        rw[sapic_plus_position_transition_with_symb_def]
        )(*A2P*) >- (
        rpt strip_tac >>
        IMP_RES_TAC binterl_moveSL >>
        rw[] >>
        IMP_RES_TAC sapic_position_transition_with_symb_def >>
        IMP_RES_TAC DYtranrel_def >>
        rw[sapic_plus_position_transition_with_symb_def]
        )(*Crypto*) >>
      rpt strip_tac >>
      IMP_RES_TAC binterl_moveSL >>
      rw[] >>
      IMP_RES_TAC sapic_position_transition_with_symb_def >>
      IMP_RES_TAC DYtranrel_def >>
      rw[sapic_plus_position_transition_with_symb_def]
      )(*end of (SOME (INL x))*) >>
     Cases_on ‘y’ >- (
      Cases_on ‘x’ >- (
        rpt strip_tac >>
        IMP_RES_TAC binterl_moveNAR >>
        rw[] >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sapic_plus_position_transition_with_symb_def,DYnsyc_event_distinct,DYnsyc_event_case_def] >>
        metis_tac[sapic_position_transition_with_symb_def]                       
        )(*Silent*)>- (
        rpt strip_tac >>
        IMP_RES_TAC binterl_moveNAR >>
        rw[] >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sapic_plus_position_transition_with_symb_def,DYnsyc_event_distinct,DYnsyc_event_case_def] >>
        metis_tac[sapic_position_transition_with_symb_def]                       
        )(*Ded*) >>
      rpt strip_tac >>
      IMP_RES_TAC binterl_moveNAR >>
      rw[] >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss)[sapic_plus_position_transition_with_symb_def,DYnsyc_event_distinct,DYnsyc_event_case_def] >>
      Cases_on ‘p’ >>              
      rw[]
      >- (metis_tac[sapic_position_transition_with_symb_def])
      >- (metis_tac[sapic_position_transition_with_symb_def])
      >- (metis_tac[sapic_position_transition_with_symb_def])
      >- (metis_tac[sapic_position_transition_with_symb_def])
      >> metis_tac[sapic_position_transition_with_symb_def]
      (*Alias*)              
      )(*end of 1-Case of (SOME (INR y)) *) >>
     Cases_on ‘y'’  >- (
      rpt strip_tac >>
      IMP_RES_TAC binterl_moveSR >>
      rw[] >>
      IMP_RES_TAC sapic_position_transition_with_symb_def >>
      IMP_RES_TAC DYtranrel_def >>
      rw[sapic_plus_position_transition_with_symb_def]
      )(*end of 1-Case of (SOME (INR (INR y))) => P2A *) >- (
      rpt strip_tac >>
      IMP_RES_TAC binterl_moveSR >>
      rw[] >>
      IMP_RES_TAC sapic_position_transition_with_symb_def >>
      IMP_RES_TAC DYtranrel_def >>
      rw[sapic_plus_position_transition_with_symb_def]
      )(*A2P*) >>
     rpt strip_tac >>
     IMP_RES_TAC binterl_moveSR >>
     rw[] >>
     IMP_RES_TAC sapic_position_transition_with_symb_def >>
     IMP_RES_TAC DYtranrel_def >>
     rw[sapic_plus_position_transition_with_symb_def]
  )(*end of theorem*)      


val sapic_vs_DY_EQ_spaicplus_single_transition_thm = store_thm(
  "sapic_vs_DY_EQ_spaicplus_single_transition_thm",
  ``∀e Re' NRe' i' i Re NRe Pr' Pr (Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(SPpred + DYpred -> bool)) (P':(SPpred + DYpred -> bool)) (Ded:(SPpred) tded) (ded3:(SPpred + DYpred) tded).
       (∃e1 e2.
          sapic_position_transition_with_symb (Sym,IMAGE OUTL P,(Pconfig (Pr,i,Re,NRe))) e1
                                              (Sym',IMAGE OUTL P',(Pconfig (Pr',i',Re',NRe'))) ∧
          DYtranrel (Sym,IMAGE OUTR P,ESt) e2 (Sym',IMAGE OUTR P',ESt) ∧
          binterl [e1] [e2] [e]) =
     (sapic_plus_position_transition_with_symb (Sym,P,(Pconfig_plus (Pr,i,Re,NRe))) e
      (Sym',P',(Pconfig_plus (Pr',i',Re',NRe')))) 
     ``,
     rpt gen_tac >>
     EQ_TAC >>
     rewrite_tac[sapic_vs_DY_to_spaicplus_single_transition_thm] >>
     rewrite_tac[spaicplus_to_sapic_vs_DY_single_transition_thm]
  )
                                                              

val spaicplus_to_sapic_vs_DY_multi_transitions_thm = store_thm(
  "spaicplus_to_sapic_vs_DY_multi_transitions_thm",
  ``∀t Re0 NRe0 i Re NRe Pr0 Pr (Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(SPpred + DYpred -> bool)) (P':(SPpred + DYpred -> bool)) (Ded:(SPpred) tded) (ded3:(SPpred + DYpred) tded).
       sapic_plus_position_multi_transitions_with_symb (Sym,P,(Pconfig_plus (Pr0,0,Re0,NRe0))) t
       (Sym',P',(Pconfig_plus (Pr,i,Re,NRe))) ⇒
     ∃t1 t2.
       sapic_position_multi_transitions_with_symb (Sym,IMAGE OUTL P,(Pconfig (Pr0,0,Re0,NRe0))) t1
                                                  (Sym',IMAGE OUTL P',(Pconfig (Pr,i,Re,NRe))) ∧
       DYmultranrel (Sym,IMAGE OUTR P,ESt) t2 (Sym',IMAGE OUTR P',ESt) ∧
       binterl t1 t2 t``,
               GEN_TAC >>
     Induct_on `t` >- (
      rpt strip_tac >>
      IMP_RES_TAC TranRelConfigEq >>
      Q.EXISTS_TAC `[]` >>
      Q.EXISTS_TAC `[]` >>
      rw[binterl_nil,TranRelConfigEq,DYmultranrel_def] >>
      metis_tac[sapic_position_multi_transitions_with_symb_nil]
      ) >>
     rpt strip_tac >>
     IMP_RES_TAC TranRelSnocRev >>
     PAT_X_ASSUM ``!v' s' p'. A`` (ASSUME_TAC o (Q.SPECL [`Sym''`,`(Pconfig_plus (Pr'',i'',Re'',NRe''))`,`P''`])) >>
     PAT_X_ASSUM ``!v' s' p'. A`` (ASSUME_TAC o (Q.SPECL [`Sym''`,`(Pconfig_plus (Pr'',i'',Re'',NRe''))`,`P''`])) >>                     
     PAT_X_ASSUM ``!Re0 NRe0 i Re NRe Pr0 Pr Sym Sym' P P' Ded ded3. A`` (ASSUME_TAC o (Q.SPECL [`Re0`,`NRe0`,`i''`,`Re''`,`NRe''`,`Pr0`,`Pr''`,`Sym`,`Sym''`,`P`,`P''`,`ded`,`ded3`]))>>
     RES_TAC >>
     IMP_RES_TAC sapic_plus_position_with_symb_single >>
     IMP_RES_TAC spaicplus_to_sapic_vs_DY_single_transition_thm >>             
     Q.EXISTS_TAC `e1::t1` >>
     Q.EXISTS_TAC `e2::t2` >>
     metis_tac[sapic_position_multi_transitions_with_symb_moveF,DYmultranrel_move,binterl_moveF]
  )


val sapic_vs_DY_to_spaicplus_multi_transitions_thm = store_thm(
  "sapic_vs_DY_to_spaicplus_multi_transitions_thm",
  ``∀t Re0 NRe0 i Re NRe Pr0 Pr (Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(SPpred + DYpred -> bool)) (P':(SPpred + DYpred -> bool)) (Ded:(SPpred) tded) (ded3:(SPpred + DYpred) tded).
       (∃t1 t2.
          sapic_position_multi_transitions_with_symb (Sym,IMAGE OUTL P,(Pconfig (Pr0,0,Re0,NRe0))) t1
                                                     (Sym',IMAGE OUTL P',(Pconfig (Pr,i,Re,NRe))) ∧
          DYmultranrel (Sym,IMAGE OUTR P,ESt) t2 (Sym',IMAGE OUTR P',ESt) ∧
          binterl t1 t2 t) ⇒
     (sapic_plus_position_multi_transitions_with_symb (Sym,P,(Pconfig_plus (Pr0,0,Re0,NRe0))) t
      (Sym',P',(Pconfig_plus (Pr,i,Re,NRe))))
     ``,
     GEN_TAC >>
     Induct_on `t` >- (
      rpt strip_tac >>
      IMP_RES_TAC binterl_Empty >>
      rw[] >>
      IMP_RES_TAC TranRelConfigEq >>
      rw[]>>
      metis_tac[sapic_plus_position_multi_transitions_with_symb_nil,IMAGEOUT]
      ) >>
     rpt strip_tac >>
     IMP_RES_TAC binterl_NotEmpty >>
     rw[] >>
     IMP_RES_TAC TranRelSnocBack >>
     PAT_X_ASSUM ``!v' s' p'. A`` (ASSUME_TAC o (Q.SPECL [`Sym''`,`ESt`,`IMAGE OUTR (P'':(SPpred + DYpred -> bool))`])) >>
     PAT_X_ASSUM ``!v' s' p'. A`` (ASSUME_TAC o (Q.SPECL [`Sym''`,`ESt`,`IMAGE OUTR (P'':(SPpred + DYpred -> bool))`])) >>
     PAT_X_ASSUM ``!v' s' p'. A`` (ASSUME_TAC o (Q.SPECL [`Sym''`,`(Pconfig (Pr'',i'',Re'',NRe''))`,`IMAGE OUTL (P'':(SPpred + DYpred -> bool))`])) >>
     PAT_X_ASSUM ``!v' s' p'. A`` (ASSUME_TAC o (Q.SPECL [`Sym''`,`(Pconfig (Pr'',i'',Re'',NRe''))`,`IMAGE OUTL (P'':(SPpred + DYpred -> bool))`])) >>
     IMP_RES_TAC binterl_Conj >>
     PAT_X_ASSUM ``!Re0 NRe0 i Re NRe Pr0 Pr Sym Sym' P P' Ded ded3. A`` (ASSUME_TAC o (Q.SPECL [`Re0`,`NRe0`,`i''`,`Re''`,`NRe''`,`Pr0`,`Pr''`,`Sym`,`Sym''`,`P`,`P''`,`ded`,`ded3`]))>>          RES_TAC  >>
     IMP_RES_TAC DYmultranrel_single >>
     IMP_RES_TAC sapic_position_with_symb_single >>
     IMP_RES_TAC sapic_vs_DY_to_spaicplus_single_transition_thm >> 
     IMP_RES_TAC sapic_plus_position_with_symb_single >>
     metis_tac[sapic_plus_position_multi_transitions_with_symb_moveF]
  )


val sapic_vs_DY_EQ_spaicplus_multi_transitions_thm = store_thm(
  "sapic_vs_DY_EQ_spaicplus_multi_transitions_thm",
  ``∀t Re0 NRe0 i Re NRe Pr0 Pr (Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(SPpred + DYpred -> bool)) (P':(SPpred + DYpred -> bool)).
       (∃t1 t2.
          sapic_position_multi_transitions_with_symb (Sym,IMAGE OUTL P,(Pconfig (Pr0,0,Re0,NRe0))) t1
                                                     (Sym',IMAGE OUTL P',(Pconfig (Pr,i,Re,NRe))) ∧
          DYmultranrel (Sym,IMAGE OUTR P,ESt) t2 (Sym',IMAGE OUTR P',ESt) ∧
          binterl t1 t2 t) =
     (sapic_plus_position_multi_transitions_with_symb (Sym,P,(Pconfig_plus (Pr0,0,Re0,NRe0))) t
      (Sym',P',(Pconfig_plus (Pr,i,Re,NRe)))) 
     ``,
     rpt strip_tac>>
     EQ_TAC>>
     rewrite_tac[sapic_vs_DY_to_spaicplus_multi_transitions_thm] >>
     rewrite_tac[spaicplus_to_sapic_vs_DY_multi_transitions_thm] 
  )


val comptraces_sapic_vs_DY_EQ_sapic_plus_traces_thm = store_thm(
  "comptraces_sapic_vs_DY_EQ_sapic_plus_traces_thm",
  ``∀t Re0 NRe0 i Re NRe Pr0 Pr (Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(SPpred + DYpred -> bool)) (P':(SPpred + DYpred -> bool)).
       (
       (TransDisable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction)) ∧
       (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
       )⇒
       (
       (comptraces (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,P,(Pconfig (Pr0,0,Re0,NRe0)),ESt) (Sym',P',(Pconfig (Pr,i,Re,NRe)),ESt)) =
       (sapic_plus_traces sapic_plus_position_multi_transitions_with_symb (Sym,P,(Pconfig_plus (Pr0,0,Re0,NRe0))) (Sym',P',(Pconfig_plus (Pr,i,Re,NRe))))
       )``,
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [binterleave_ts,traces_def,comptraces_def,EXTENSION,sapic_plus_traces_def,IN_DEF,SUBSET_INTER_ABSORPTION,INTER_DEF] >>
     rw[] >>
     EQ_TAC >-(
      rw[] >>
      IMP_RES_TAC binterleave_composition_generaldeduction_subseteq >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [binterleave_ts,traces_def,comptraces_def,EXTENSION,sapic_plus_traces_def,IN_DEF,SUBSET_INTER_ABSORPTION,INTER_DEF] >>
      PAT_X_ASSUM ``!Sym' Sym S2' S2 S1' S1 P' P x. A`` (ASSUME_TAC o (Q.SPECL [`Sym'`,`Sym`,`ESt`,`ESt`,`Pconfig (Pr,i,Re,NRe)`,`Pconfig (Pr0,0,Re0,NRe0)`,`P'`,`P`,`x`])) >>
      RES_TAC >>
      metis_tac[sapic_vs_DY_EQ_spaicplus_multi_transitions_thm] 
      ) >>
      rw[] >>
      IMP_RES_TAC binterleave_composition_generaldeduction_supseteq >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [binterleave_ts,traces_def,comptraces_def,EXTENSION,sapic_plus_traces_def,IN_DEF,SUBSET_INTER_ABSORPTION,INTER_DEF] >>
      PAT_X_ASSUM ``!Sym' Sym S2' S2 S1' S1 P' P x. A`` (ASSUME_TAC o (Q.SPECL [`Sym'`,`Sym`,`ESt`,`ESt`,`Pconfig (Pr,i,Re,NRe)`,`Pconfig (Pr0,0,Re0,NRe0)`,`P'`,`P`,`x`])) >>
      RES_TAC >>
      metis_tac[sapic_vs_DY_EQ_spaicplus_multi_transitions_thm] 
)



val _ = export_theory();
