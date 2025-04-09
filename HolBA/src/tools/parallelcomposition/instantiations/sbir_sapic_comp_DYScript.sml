
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

val _ = new_theory "sbir_sapic_comp_DY";

   
val comptraces_sapic_def =
Define`
      comptraces_sapic
      ((MTrn1:(SapicFact_t + (Name_t,Sig_t,Var_t) sync_event, SPpred, sapic_position_configuration_t, Var_t) mtrel),(Ded1:(SPpred) tded))
      ((MTrn2:(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event, DYpred, DYstate, Var_t) mtrel),(Ded2:(DYpred) tded))
      ded3
      ((Sym:Var_t set),(P: (SPpred + DYpred) set),(S1: sapic_position_configuration_t),(S2: DYstate))
      ((Sym':Var_t set),(P': (SPpred + DYpred) set),(S1': sapic_position_configuration_t),(S2': DYstate))
=
{(t:((SapicFact_t + (Name_t,Sig_t,Var_t) sync_event)+(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event)) option list)|  
 (symbolicParlComp (MTrn1,Ded1) (MTrn2,Ded2) ded3 (Sym,P,S1,S2) t (Sym',P',S1',S2'))
}
`;

val comptraces_tree_def =
Define`
      comptraces_tree
      ((MTrn1:((sbir_event + (Name_t, Sig_t,Var_t) sync_event), bir_exp_t, (sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree, Var_t) mtrel),(Ded1:(bir_exp_t) tded))
      ((MTrn2:(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event, DYpred, DYstate, Var_t) mtrel),(Ded2:(DYpred) tded))
      ded3
      ((Sym:Var_t set),(P: (bir_exp_t + DYpred) set),(S1: (sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree),(S2: DYstate))
      ((Sym':Var_t set),(P': (bir_exp_t + DYpred) set),(S1': (sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree),(S2': DYstate))
=
{(t: (((sbir_event + (Name_t,Sig_t, Var_t) sync_event) + DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event) option list))|  
 (symbolicParlComp (MTrn1,Ded1) (MTrn2,Ded2) ded3 (Sym,P,S1,S2) t (Sym',P',S1',S2'))
}
`;

val sbirEvent_vs_Sync_to_sapicFact_vs_Sync_def =
Define`
      sbirEvent_vs_Sync_to_sapicFact_vs_Sync Ev =
( case Ev of
    NONE => NONE
  | SOME ((INL e):(sbir_event + (Name_t,Sig_t, Var_t) sync_event)) => SOME ((INL (sbirEvent_to_sapicFact e)):(SapicFact_t + (Name_t,Sig_t,Var_t) sync_event))
  | SOME ((INR e):(sbir_event + (Name_t,Sig_t, Var_t) sync_event)) => SOME ((INR e):(SapicFact_t + (Name_t,Sig_t,Var_t) sync_event))
)
`;

val sbirEvent_vs_DY_to_sapicFact_vs_DY_def =
Define`
      sbirEvent_vs_DY_to_sapicFact_vs_DY Ev =
( case Ev of
    NONE => NONE
  | SOME ((INL (INL e)):((sbir_event + (Name_t, Sig_t,Var_t) sync_event) + DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event)) => SOME ((INL (INL (sbirEvent_to_sapicFact e))):((SapicFact_t + (Name_t,Sig_t,Var_t) sync_event)+(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event)))
  | SOME ((INL (INR e)):((sbir_event + (Name_t, Sig_t,Var_t) sync_event) + DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event)) => SOME ((INL (INR e)):((SapicFact_t + (Name_t,Sig_t,Var_t) sync_event)+(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event)))
  | SOME ((INR (INL e)):((sbir_event + (Name_t, Sig_t,Var_t) sync_event) + DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event)) => SOME ((INR (INL e)):((SapicFact_t + (Name_t,Sig_t,Var_t) sync_event)+(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event)))
  | SOME ((INR (INR e)):((sbir_event + (Name_t, Sig_t,Var_t) sync_event) + DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event)) => SOME ((INR (INR e)):((SapicFact_t + (Name_t,Sig_t,Var_t) sync_event)+(DYnsyc_event + (Name_t,Sig_t,Var_t) sync_event)))
)
`;


val binterl_sbir_to_sapic_thm = store_thm(
  "binterl_sbir_to_sapic_thm",
  ``∀t t1 t2.
       binterl t1 t2 t
     ==>
     binterl (MAP sbirEvent_vs_Sync_to_sapicFact_vs_Sync t1) t2
             (MAP sbirEvent_vs_DY_to_sapicFact_vs_DY t) ``,
             gen_tac >>
     Induct_on ‘t’ >-(
      rpt strip_tac >>     
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [MAP] >>
      IMP_RES_TAC binterl_Empty >>
      rw[binterl_nil]
      )(*Nil*) >>
     rpt strip_tac >>
     IMP_RES_TAC binterl_NotEmpty >>
     rw[] >>
     PAT_X_ASSUM ``!t1 t2. A`` (ASSUME_TAC o (Q.SPECL [‘(t1':(sbir_event + (Name_t,Sig_t, Var_t) sync_event) option list)’,‘(t2':(DYnsyc_event + (Name_t, Sig_t,Var_t) sync_event) option list)’])) >>
     IMP_RES_TAC binterl_Conj >>
     RES_TAC >>
     Cases_on ‘h’ >-(
      IMP_RES_TAC binterl_moveNONE >>
      rw[] >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sbirEvent_vs_DY_to_sapicFact_vs_DY_def,sbirEvent_vs_Sync_to_sapicFact_vs_Sync_def] >>  
      metis_tac[binterl_none]
      )(*NONE*) >>
     Cases_on ‘x’ >- (
      Cases_on ‘x'’ >- (
        IMP_RES_TAC binterl_moveNAL >>
        rw[] >>
        FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sbirEvent_vs_DY_to_sapicFact_vs_DY_def,sbirEvent_vs_Sync_to_sapicFact_vs_Sync_def] >>
        metis_tac [binterl_leftN]       
        )(*(INL (INL x))*) >>
      IMP_RES_TAC binterl_moveSL >>
      rw[] >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sbirEvent_vs_DY_to_sapicFact_vs_DY_def,sbirEvent_vs_Sync_to_sapicFact_vs_Sync_def] >>
      metis_tac [binterl_syncL]
      )(*INL x'*) >> 
     Cases_on ‘y’ >- (
      IMP_RES_TAC binterl_moveNAR >>
      rw[] >>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sbirEvent_vs_DY_to_sapicFact_vs_DY_def,sbirEvent_vs_Sync_to_sapicFact_vs_Sync_def] >>
      metis_tac [binterl_rightN]      
      )(*(INR (INL x))*) >>
     IMP_RES_TAC binterl_moveSR >>
     rw[] >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sbirEvent_vs_DY_to_sapicFact_vs_DY_def,sbirEvent_vs_Sync_to_sapicFact_vs_Sync_def] >>
     metis_tac [binterl_syncR]
  );

val compose_sbir_sapic_vs_DY_thm = store_thm(
  "compose_sbir_sapic_vs_DY_thm",
  ``∀T0 Re0 NRe0 i Re NRe Tre (Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(bir_exp_t + DYpred -> bool)) (P':(bir_exp_t + DYpred -> bool)) (DedTr:(bir_exp_t) tded).
(
((IMAGE (MAP sbirEvent_vs_Sync_to_sapicFact_vs_Sync) (traces_of_tree_with_symb (Sym,IMAGE OUTL P,T0) (Sym',IMAGE OUTL P',Tre))) ⊆ (traces_of_sapic_with_symb (Sym,IMAGE OUTL (IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0))) (Sym',IMAGE OUTL (IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((symbtree_to_sapic Tre),i,Re,NRe))))) ∧
        (TransDisable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,DedTr) (DYmultranrel,DYdeduction)) ∧
      (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
    ) ==> (
      (IMAGE (MAP sbirEvent_vs_DY_to_sapicFact_vs_DY) (comptraces_tree (symbolic_tree_multi_transitions_with_symb,DedTr) (DYmultranrel,DYdeduction) composeDedOverApprox (Sym,P,T0,ESt) (Sym',P',Tre,ESt))) ⊆
      (comptraces_sapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)),ESt) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((symbtree_to_sapic Tre),i,Re,NRe)),ESt))
      ) ``,
        rpt gen_tac >>      
     rewrite_tac[binterleave_ts,traces_def,comptraces_def,EXTENSION,traces_of_tree_with_symb_def,traces_of_sapic_with_symb_def,EXTENSION,SUBSET_DEF,comptraces_tree_def, comptraces_sapic_def,binterleave_ts] >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [SUBSET_DEF] >>
     rw[] >>
     IMP_RES_TAC binterleave_trace_comp_to_decomp_generaldeduction >>
     IMP_RES_TAC binterl_sbir_to_sapic_thm >>
     PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`(MAP sbirEvent_vs_Sync_to_sapicFact_vs_Sync t1)`])) >>
     RES_TAC  >>
     FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sbirEvent_vs_Sync_to_sapicFact_vs_Sync_def,MAP] >>              
     metis_tac[binterleave_trace_decomp_to_comp_generaldeduction,IMAGE_SUM_MAP_RI]
  );



val _ = export_theory();
