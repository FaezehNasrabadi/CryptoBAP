open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open listTheory;
open sapicplusTheory;
open parallelcompositionconcreteTheory;
open interleavingconcreteTheory;
open parallelcompositiongeneraldeductionTheory;
open interleavinggeneraldeductionTheory;
open derived_rules_generaldeductionTheory;
open bir_comp_attacker_vs_sbir_comp_DYTheory;
open arm8_vs_bir_comp_attackerTheory;
open sapic_comp_DY_sapicplusTheory;
open sbir_sapic_comp_DYTheory;
open refinementTheory;
open bir_backlifterTheory;
open bir_program_multistep_propsTheory;
open arithmeticTheory;
open bir_auxiliaryTheory;
open optionTheory;
open HolBACoreSimps;
open combined_deductionTheory;
open WinitexampleTheory;
open WrespexampleTheory;
val _ = new_theory "end_to_end_correctness";


(********************************)
(*end to end correctness result *)                                               
(********************************)
        
val end_to_end_correctness_thm = store_thm(
  "end_to_end_correctness_thm",
  ``
  !mu ms mla (birprog:'observation_type bir_program_t) (arm8prog:((64 word)# (8 word) list) list) n' lo c_st c_addr_labels
      (AMTrn:('attevent + 'ceventS, 'cstate) mctrel) Re0 NRe0 i Re NRe (Sym:(Var_t -> bool))
      (Sym':(Var_t -> bool)) (P:(bir_exp_t + DYpred -> bool)) (P':(bir_exp_t + DYpred -> bool))
      (T0:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (Tre:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (sbir_Ded:(bir_exp_t) tded)  .

    bir_is_lifted_prog arm8_bmr mu arm8prog birprog ==>
    bmr_rel arm8_bmr ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) ms ==>
    MEM (BL_Address mla) (bir_labels_of_program birprog) ==>
    (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0).bst_pc = bir_block_pc (BL_Address mla)) ==>
    EVERY (bmr_ms_mem_contains arm8_bmr ms) arm8prog ==>
    (bir_exec_to_addr_label_n birprog ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) n' =
     BER_Ended lo c_st c_addr_labels ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre)) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre) ==>
    (∃ms'.
       (
       (
       (arm8_att_comptraces (((arm8_mrel arm8prog):arm8_state -> ('cevent + 'ceventS) list -> arm8_state -> bool) || AMTrn) (ms,((InterpretStTwo:DYstate -> 'cstate) ESt)) (ms',((InterpretStTwo:DYstate -> 'cstate) ESt))) =
       (bir_att_comptraces ((bir_mrel (birprog:'observation_type bir_program_t)) || AMTrn) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0),((InterpretStTwo:DYstate -> 'cstate) ESt))  (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre),((InterpretStTwo:DYstate -> 'cstate) ESt)))
       ) ∧
       (TransEnable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) 
       )
       ==>
       (
       (subset_comp
        (bir_att_comptraces (composeMuRe (bir_mrel (birprog:'observation_type bir_program_t)) AMTrn) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0),((InterpretStTwo:DYstate -> 'cstate) ESt)) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre),((InterpretStTwo:DYstate -> 'cstate) ESt)))
        (comptraces_tree (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox (Sym,P,T0,ESt) (Sym',P',Tre,ESt))
       ) ∧
       (TransDisable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) ∧
       (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
       ) ==>
       (
       ((IMAGE (MAP sbirEvent_vs_DY_to_sapicFact_vs_DY) (comptraces_tree (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox (Sym,P,T0,ESt) (Sym',P',Tre,ESt))) ⊆
        (comptraces_sapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)),ESt) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((symbtree_to_sapic Tre),i,Re,NRe)),ESt))
       ) ∧
       (TransDisable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction)) ∧
       (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
       ) ==>
       (comptraces (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)),ESt) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((symbtree_to_sapic Tre),i,Re,NRe)),ESt)) =
       (sapic_plus_traces sapic_plus_position_multi_transitions_with_symb (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig_plus ((symbtree_to_sapic T0),0,Re0,NRe0))) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig_plus ((symbtree_to_sapic Tre),i,Re,NRe))))
    )

    ``,
    
    rpt strip_tac >>
  IMP_RES_TAC compose_arm8_bir_vs_attacker_thm >>
  PAT_X_ASSUM ``!as'' as MTrn. A `` (ASSUME_TAC o (Q.SPECL [‘(InterpretStTwo ESt)’,‘(InterpretStTwo ESt)’,‘(AMTrn)’]))>>            
  REV_FULL_SIMP_TAC std_ss [] >>
  Q.EXISTS_TAC `ms''` >>
  rw[] >>
  metis_tac[comptraces_sapic_vs_DY_EQ_sapic_plus_traces_thm]
  )

                                                                
(*******************************)
(*end to end correctness Winit *)                                               
(*******************************)

val arch_Winit_t = List.nth((snd o strip_comb o concl) WinitexampleTheory.Winitexample_thm, 0);
val arch_Winit_def = Define `
    arch_Winit = ^(arch_Winit_t)
                `;
                
val interval_Winit_t = List.nth((snd o strip_comb o concl) WinitexampleTheory.Winitexample_thm, 1);
val interval_Winit_def = Define `
    interval_Winit = ^(interval_Winit_t)
                `;
                
val arm8prog_Winit_t = List.nth((snd o strip_comb o concl) WinitexampleTheory.Winitexample_thm, 2);
val arm8prog_Winit_def = Define `
    arm8prog_Winit = ^(arm8prog_Winit_t)
             `;

val birprog_Winit_t = List.nth((snd o strip_comb o concl) WinitexampleTheory.Winitexample_thm, 3);
val birprog_Winit_def = Define `
    birprog_Winit = ^(birprog_Winit_t)
`;


val lifter_Winit_thm = REWRITE_RULE [GSYM arch_Winit_def,GSYM interval_Winit_def,GSYM arm8prog_Winit_def,GSYM birprog_Winit_def] WinitexampleTheory.Winitexample_thm;
val lifter_Winit_t = concl lifter_Winit_thm;


val end_to_end_correctness_Winit_thm = store_thm(
  "end_to_end_correctness_Winit_thm",
  ``
  !mu ms mla n' lo c_st c_addr_labels
      (AMTrn:('attevent + 'ceventS, 'cstate) mctrel) Re0 NRe0 i Re NRe (Sym:(Var_t -> bool))
      (Sym':(Var_t -> bool)) (P:(bir_exp_t + DYpred -> bool)) (P':(bir_exp_t + DYpred -> bool))
      (T0:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (Tre:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (sbir_Ded:(bir_exp_t) tded)  .

    ^lifter_Winit_t ==>
    bmr_rel arch_Winit ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) ms ==>
    MEM (BL_Address mla) (bir_labels_of_program (birprog_Winit:'observation_type bir_program_t)) ==>
    (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0).bst_pc = bir_block_pc (BL_Address mla)) ==>
    EVERY (bmr_ms_mem_contains arch_Winit ms) arm8prog_Winit ==>
    (bir_exec_to_addr_label_n (birprog_Winit:'observation_type bir_program_t) ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) n' =
     BER_Ended lo c_st c_addr_labels ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre)) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre) ==>
    (∃ms'.
       (
       (
       (arm8_att_comptraces (((arm8_mrel arm8prog_Winit):arm8_state -> ('cevent + 'ceventS) list -> arm8_state -> bool) || AMTrn) (ms,((InterpretStTwo:DYstate -> 'cstate) ESt)) (ms',((InterpretStTwo:DYstate -> 'cstate) ESt))) =
       (bir_att_comptraces ((bir_mrel (birprog_Winit:'observation_type bir_program_t)) || AMTrn) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0),((InterpretStTwo:DYstate -> 'cstate) ESt))  (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre),((InterpretStTwo:DYstate -> 'cstate) ESt)))
       ) ∧
       (TransEnable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) 
       )
       ==>
       (
       (subset_comp
        (bir_att_comptraces ((bir_mrel (birprog_Winit:'observation_type bir_program_t)) || AMTrn) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0),((InterpretStTwo:DYstate -> 'cstate) ESt))  (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre),((InterpretStTwo:DYstate -> 'cstate) ESt)))
        (comptraces_tree (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox (Sym,P,T0,ESt) (Sym',P',Tre,ESt))
       ) ∧
       (TransDisable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) ∧
       (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
       ) ==>
       (
       ((IMAGE (MAP sbirEvent_vs_DY_to_sapicFact_vs_DY) (comptraces_tree (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox (Sym,P,T0,ESt) (Sym',P',Tre,ESt))) ⊆
        (comptraces_sapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)),ESt) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((symbtree_to_sapic Tre),i,Re,NRe)),ESt))
       ) ∧
       (TransDisable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction)) ∧
       (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
       ) ==>
       (comptraces (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)),ESt) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((symbtree_to_sapic Tre),i,Re,NRe)),ESt)) =
       (sapic_plus_traces sapic_plus_position_multi_transitions_with_symb (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig_plus ((symbtree_to_sapic T0),0,Re0,NRe0))) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig_plus ((symbtree_to_sapic Tre),i,Re,NRe))))
    )


    ``,
  metis_tac[arch_Winit_def,end_to_end_correctness_thm]
  )


(*******************************)
(*end to end correctness Wresp *)                                               
(*******************************)

val arch_Wresp_t = List.nth((snd o strip_comb o concl) WrespexampleTheory.Wrespexample_thm, 0);
val arch_Wresp_def = Define `
    arch_Wresp = ^(arch_Wresp_t)
                `;
                
val interval_Wresp_t = List.nth((snd o strip_comb o concl) WrespexampleTheory.Wrespexample_thm, 1);
val interval_Wresp_def = Define `
    interval_Wresp = ^(interval_Wresp_t)
                `;
                
val arm8prog_Wresp_t = List.nth((snd o strip_comb o concl) WrespexampleTheory.Wrespexample_thm, 2);
val arm8prog_Wresp_def = Define `
    arm8prog_Wresp = ^(arm8prog_Wresp_t)
             `;

val birprog_Wresp_t = List.nth((snd o strip_comb o concl) WrespexampleTheory.Wrespexample_thm, 3);
val birprog_Wresp_def = Define `
    birprog_Wresp = ^(birprog_Wresp_t)
`;


val lifter_Wresp_thm = REWRITE_RULE [GSYM arch_Wresp_def,GSYM interval_Wresp_def,GSYM arm8prog_Wresp_def,GSYM birprog_Wresp_def] WrespexampleTheory.Wrespexample_thm;
val lifter_Wresp_t = concl lifter_Wresp_thm;


val end_to_end_correctness_Wresp_thm = store_thm(
  "end_to_end_correctness_Wresp_thm",
  ``
        
  !mu ms mla n' lo c_st c_addr_labels
      (AMTrn:('attevent + 'ceventS, 'cstate) mctrel) Re0 NRe0 i Re NRe (Sym:(Var_t -> bool))
      (Sym':(Var_t -> bool)) (P:(bir_exp_t + DYpred -> bool)) (P':(bir_exp_t + DYpred -> bool))
      (T0:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (Tre:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (sbir_Ded:(bir_exp_t) tded)  .

    ^lifter_Wresp_t ==>
    bmr_rel arch_Wresp ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) ms ==>
    MEM (BL_Address mla) (bir_labels_of_program (birprog_Wresp:'observation_type bir_program_t)) ==>
    (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0).bst_pc = bir_block_pc (BL_Address mla)) ==>
    EVERY (bmr_ms_mem_contains arch_Wresp ms) arm8prog_Wresp ==>
    (bir_exec_to_addr_label_n (birprog_Wresp:'observation_type bir_program_t) ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) n' =
     BER_Ended lo c_st c_addr_labels ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre)) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre) ==>
    (∃ms'.
       (
       (
       (arm8_att_comptraces (((arm8_mrel arm8prog_Wresp):arm8_state -> ('cevent + 'ceventS) list -> arm8_state -> bool) || AMTrn) (ms,((InterpretStTwo:DYstate -> 'cstate) ESt)) (ms',((InterpretStTwo:DYstate -> 'cstate) ESt))) =
       (bir_att_comptraces ((bir_mrel (birprog_Wresp:'observation_type bir_program_t)) || AMTrn) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0),((InterpretStTwo:DYstate -> 'cstate) ESt))  (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre),((InterpretStTwo:DYstate -> 'cstate) ESt)))
       ) ∧
       (TransEnable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) 
       )
       ==>
       (
       (subset_comp
        (bir_att_comptraces ((bir_mrel (birprog_Wresp:'observation_type bir_program_t)) || AMTrn) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0),((InterpretStTwo:DYstate -> 'cstate) ESt))  (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre),((InterpretStTwo:DYstate -> 'cstate) ESt)))
        (comptraces_tree (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox (Sym,P,T0,ESt) (Sym',P',Tre,ESt))
       ) ∧
       (TransDisable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) ∧
       (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
       ) ==>
       (
       ((IMAGE (MAP sbirEvent_vs_DY_to_sapicFact_vs_DY) (comptraces_tree (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox (Sym,P,T0,ESt) (Sym',P',Tre,ESt))) ⊆
        (comptraces_sapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)),ESt) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((symbtree_to_sapic Tre),i,Re,NRe)),ESt))
       ) ∧
       (TransDisable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction)) ∧
       (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
       ) ==>
       (comptraces (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)),ESt) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((symbtree_to_sapic Tre),i,Re,NRe)),ESt)) =
       (sapic_plus_traces sapic_plus_position_multi_transitions_with_symb (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig_plus ((symbtree_to_sapic T0),0,Re0,NRe0))) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig_plus ((symbtree_to_sapic Tre),i,Re,NRe))))
    )


    ``,
  metis_tac[arch_Wresp_def,end_to_end_correctness_thm]
  )





(***************************************************)
(*end to end correctness Winit vs Wresp vs Attacker*)                                               
(***************************************************)

  
val two_arm8s_att_comptraces_thm =
INST_TYPE [``:'cevent1`` |-> ``:('cevent + 'ceventS)``,``:'cevent2`` |-> ``:('cevent + 'ceventS)``,``:'ceventS`` |-> ``:('attevent + 'ceventS)``,``:'cstate1`` |-> ``:(arm8_state # 'cstate)``,``:'cstate2`` |-> ``:(arm8_state # 'cstate)``] interleavingconcreteTheory.comptraces_def;
val two_arm8s_att_comptraces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) two_arm8s_att_comptraces_thm;
val two_arm8s_att_comptraces_def = Define `
    two_arm8s_att_comptraces = ^(two_arm8s_att_comptraces_t)
                               `;

val two_birs_att_comptraces_thm =
INST_TYPE [``:'cevent1`` |-> ``:('cevent + 'ceventS)``,``:'cevent2`` |-> ``:('cevent + 'ceventS)``,``:'ceventS`` |-> ``:('attevent + 'ceventS)``,``:'cstate1`` |-> ``:(bir_state_t # 'cstate)``,``:'cstate2`` |-> ``:(bir_state_t # 'cstate)``] interleavingconcreteTheory.comptraces_def;
val two_birs_att_comptraces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) two_birs_att_comptraces_thm;
val two_birs_att_comptraces_def = Define `
    two_birs_att_comptraces = ^(two_birs_att_comptraces_t)
`;


val two_sbirs_DY_comptraces_thm =
INST_TYPE [``:'symb`` |-> ``:Var_t``,``:'pred1`` |-> ``:(bir_exp_t + DYpred)``,``:'state1`` |-> ``:((sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree # DYstate)``,``:'event1`` |-> ``:(sbir_event + (Name_t, Sig_t, Var_t) sync_event)``,``:'pred2`` |-> ``:(bir_exp_t + DYpred)``,``:'state2`` |-> ``:((sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree # DYstate)``,``:'event2`` |-> ``:(sbir_event + (Name_t, Sig_t, Var_t) sync_event)``,``:'eventS`` |-> ``:(DYnsyc_event + (Name_t, Sig_t, Var_t) sync_event)``] derived_rules_generaldeductionTheory.comptraces_def;
val two_sbirs_DY_comptraces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) two_sbirs_DY_comptraces_thm;
val two_sbirs_DY_comptraces_def = Define `
    two_sbirs_DY_comptraces = ^(two_sbirs_DY_comptraces_t)
                               `;

val two_sapics_DY_comptraces_thm =
INST_TYPE [``:'symb`` |-> ``:Var_t``,``:'pred1`` |-> ``:(SPpred + DYpred)``,``:'state1`` |-> ``:(sapic_position_configuration_t # DYstate)``,``:'event1`` |-> ``:(SapicFact_t + (Name_t, Sig_t, Var_t) sync_event)``,``:'pred2`` |-> ``:(SPpred + DYpred)``,``:'state2`` |-> ``:(sapic_position_configuration_t # DYstate)``,``:'event2`` |-> ``:(SapicFact_t + (Name_t, Sig_t, Var_t) sync_event)``,``:'eventS`` |-> ``:(DYnsyc_event + (Name_t, Sig_t, Var_t) sync_event)``] derived_rules_generaldeductionTheory.comptraces_def;
val two_sapics_DY_comptraces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) two_sapics_DY_comptraces_thm;
val two_sapics_DY_comptraces_def = Define `
    two_sapics_DY_comptraces = ^(two_sapics_DY_comptraces_t)
`;
                                

val sbirEvent_vs_DY_to_sapicFact_vs_DY_no_option_def =
Define `
       sbirEvent_vs_DY_to_sapicFact_vs_DY_no_option Ev =
( case Ev of
    ((INL (INL e)):((sbir_event + (Name_t, Sig_t, Var_t) sync_event) + DYnsyc_event + (Name_t,Sig_t, Var_t) sync_event)) =>  ((INL (INL (sbirEvent_to_sapicFact e))):((SapicFact_t + (Name_t,Sig_t, Var_t) sync_event)+(DYnsyc_event + (Name_t,Sig_t, Var_t) sync_event)))
  |  ((INL (INR e)):((sbir_event + (Name_t, Sig_t, Var_t) sync_event) + DYnsyc_event + (Name_t,Sig_t, Var_t) sync_event)) =>  ((INL (INR e)):((SapicFact_t + (Name_t,Sig_t, Var_t) sync_event)+(DYnsyc_event + (Name_t,Sig_t, Var_t) sync_event)))
  |  ((INR (INL e)):((sbir_event + (Name_t, Sig_t, Var_t) sync_event) + DYnsyc_event + (Name_t,Sig_t, Var_t) sync_event)) =>  ((INR (INL e)):((SapicFact_t + (Name_t,Sig_t, Var_t) sync_event)+(DYnsyc_event + (Name_t,Sig_t, Var_t) sync_event)))
  |  ((INR (INR e)):((sbir_event + (Name_t, Sig_t, Var_t) sync_event) + DYnsyc_event + (Name_t,Sig_t, Var_t) sync_event)) =>  ((INR (INR e)):((SapicFact_t + (Name_t,Sig_t, Var_t) sync_event)+(DYnsyc_event + (Name_t,Sig_t, Var_t) sync_event)))
)
`;
        
val end_to_end_correctness_Winit_vs_Wresp_vs_attacker_thm = store_thm(
  "end_to_end_correctness_Winit_vs_Wresp_vs_attacker_thm",
  ``
  !imu rmu ims rms imla rmla in' rn' ilo rlo ic_st rc_st ic_addr_labels rc_addr_labels
       (iAMTrn:(('attevent + 'ceventS), 'cstate) mctrel)
       (rAMTrn:(('attevent + 'ceventS), 'cstate) mctrel)
       iRe0 iNRe0 ii iRe iNRe (iT0:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (iTre:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree)
       rRe0 rNRe0 ri rRe rNRe (rT0:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (rTre:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree)
        (wded3Tr:(bir_exp_t + DYpred) tded) (wded4Tr:((bir_exp_t + DYpred)+(bir_exp_t + DYpred)) tded) (wded3Sp:(SPpred + DYpred) tded) (wded4Sp:((SPpred + DYpred)+(SPpred + DYpred)) tded) (sbir_Ded:(bir_exp_t) tded)  
       (Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:((bir_exp_t + DYpred) -> bool)) (P':((bir_exp_t + DYpred) -> bool)).

    ^lifter_Winit_t ==>  
    ^lifter_Wresp_t ==>
    bmr_rel arch_Winit ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iT0) ims ==>
    bmr_rel arch_Wresp ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rT0) rms ==>
    MEM (BL_Address imla) (bir_labels_of_program (birprog_Winit:'observation_type bir_program_t)) ==>
    (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iT0).bst_pc = bir_block_pc (BL_Address imla)) ==>
    MEM (BL_Address rmla) (bir_labels_of_program (birprog_Wresp:'observation_type bir_program_t)) ==>
    (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rT0).bst_pc = bir_block_pc (BL_Address rmla)) ==>
    EVERY (bmr_ms_mem_contains arch_Winit ims) arm8prog_Winit ==>                              
    EVERY (bmr_ms_mem_contains arch_Wresp rms) arm8prog_Wresp ==>
     (bir_exec_to_addr_label_n (birprog_Winit:'observation_type bir_program_t) ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iT0) in' =
     BER_Ended ilo ic_st ic_addr_labels ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iTre)) ==>      
    (bir_exec_to_addr_label_n (birprog_Wresp:'observation_type bir_program_t) ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rT0) rn' =
     BER_Ended rlo rc_st rc_addr_labels ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rTre)) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iT0) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rT0) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iTre) ==>
    ~bir_state_is_terminated ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rTre) ==>
    (∃ims' rms'.
(
       (
       (two_arm8s_att_comptraces ((((arm8_mrel arm8prog_Winit):('cevent + 'ceventS, arm8_state) mctrel) || iAMTrn) || (((arm8_mrel arm8prog_Wresp):('cevent + 'ceventS, arm8_state) mctrel) || rAMTrn))
        ((ims,((InterpretStTwo:DYstate -> 'cstate) ESt)),(rms,((InterpretStTwo:DYstate -> 'cstate) ESt)))
        ((ims',((InterpretStTwo:DYstate -> 'cstate) ESt)),(rms',((InterpretStTwo:DYstate -> 'cstate) ESt))))
       =
       (two_birs_att_comptraces ((((bir_mrel (birprog_Winit:'observation_type bir_program_t)):('cevent + 'ceventS, bir_state_t) mctrel) || iAMTrn) || (((bir_mrel (birprog_Wresp:'observation_type bir_program_t)):('cevent + 'ceventS, bir_state_t) mctrel) || rAMTrn))
        ((((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iT0),((InterpretStTwo:DYstate -> 'cstate) ESt)),(((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rT0),((InterpretStTwo:DYstate -> 'cstate) ESt)))
        ((((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iTre),((InterpretStTwo:DYstate -> 'cstate) ESt)),(((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rTre),((InterpretStTwo:DYstate -> 'cstate) ESt))))
       )∧
       (TransEnable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) 
) ==>
(
       (subset_comp
        (two_birs_att_comptraces ((((bir_mrel (birprog_Winit:'observation_type bir_program_t)):('cevent + 'ceventS, bir_state_t) mctrel) || iAMTrn) || (((bir_mrel (birprog_Wresp:'observation_type bir_program_t)):('cevent + 'ceventS, bir_state_t) mctrel) || rAMTrn))
         ((((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iT0),((InterpretStTwo:DYstate -> 'cstate) ESt)),(((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rT0),((InterpretStTwo:DYstate -> 'cstate) ESt)))
         ((((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) iTre),((InterpretStTwo:DYstate -> 'cstate) ESt)),(((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) rTre),((InterpretStTwo:DYstate -> 'cstate) ESt))))
        (two_sbirs_DY_comptraces ((symbolicParlComp (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox),wded3Tr)
         ((symbolicParlComp (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox),wded3Tr) wded4Tr
         (Sym,((IMAGE INL P):((bir_exp_t + DYpred) + (bir_exp_t + DYpred) -> bool)),(iT0,ESt),(rT0,ESt)) (Sym',((IMAGE INL P'):((bir_exp_t + DYpred) + (bir_exp_t + DYpred) -> bool)),(iTre,ESt),(rTre,ESt)))
       )∧
       (TransDisable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) ∧
       (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
) ==>
  (
       ((IMAGE (MAP (OPTION_MAP (SUM_MAP sbirEvent_vs_DY_to_sapicFact_vs_DY_no_option sbirEvent_vs_DY_to_sapicFact_vs_DY_no_option)))
         (two_sbirs_DY_comptraces ((symbolicParlComp (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox),wded3Tr)
          ((symbolicParlComp (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox),wded3Tr) wded4Tr
          (Sym,((IMAGE INL P):((bir_exp_t + DYpred) + (bir_exp_t + DYpred) -> bool)),(iT0,ESt),(rT0,ESt)) (Sym',((IMAGE INL P'):((bir_exp_t + DYpred) + (bir_exp_t + DYpred) -> bool)),(iTre,ESt),(rTre,ESt))))
        ⊆
        (two_sapics_DY_comptraces ((symbolicParlComp (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic),wded3Sp)
         ((symbolicParlComp (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic),wded3Sp) wded4Sp
         (Sym,((IMAGE INL (IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P)):((SPpred + DYpred) + (SPpred + DYpred) -> bool)),((Pconfig ((symbtree_to_sapic iT0),0,iRe0,iNRe0)),ESt),((Pconfig ((symbtree_to_sapic rT0),0,rRe0,rNRe0)),ESt))
         (Sym',((IMAGE INL (IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P')):((SPpred + DYpred) + (SPpred + DYpred) -> bool)),((Pconfig ((symbtree_to_sapic iTre),ii,iRe,iNRe)),ESt),((Pconfig ((symbtree_to_sapic rTre),ri,rRe,rNRe)),ESt)))
       )∧
       (TransDisable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction)) ∧
       (TransEnable composeDedOverApproxSapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction))
       ) ==>
       (
       (two_sapics_DY_comptraces ((symbolicParlComp (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic),wded3Sp)
        ((symbolicParlComp (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic),wded3Sp) wded4Sp
        (Sym,((IMAGE INL (IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P)):((SPpred + DYpred) + (SPpred + DYpred) -> bool)),((Pconfig ((symbtree_to_sapic iT0),0,iRe0,iNRe0)),ESt),((Pconfig ((symbtree_to_sapic rT0),0,rRe0,rNRe0)),ESt))
        (Sym',((IMAGE INL (IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P')):((SPpred + DYpred) + (SPpred + DYpred) -> bool)),((Pconfig ((symbtree_to_sapic iTre),ii,iRe,iNRe)),ESt),((Pconfig ((symbtree_to_sapic rTre),ri,rRe,rNRe)),ESt)))
       =
       (IMAGE (MAP (OPTION_MAP INL))
        (comptraces_sapic (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((ProcessComb Parallel (symbtree_to_sapic iT0) (symbtree_to_sapic rT0)),0,(sapic_renaming_extend iRe0 rRe0),(sapic_name_renaming_extend iNRe0 rNRe0))),ESt) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((ProcessComb Parallel (symbtree_to_sapic iTre) (symbtree_to_sapic rTre)),(ii + ri),(sapic_renaming_extend iRe rRe),( sapic_name_renaming_extend iNRe rNRe))),ESt)))
       ) ==>
       (comptraces (sapic_position_multi_transitions_with_symb,SPdeduction) (DYmultranrel,DYdeduction) composeDedOverApproxSapic (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig ((ProcessComb Parallel (symbtree_to_sapic iT0) (symbtree_to_sapic rT0)),0,(sapic_renaming_extend iRe0 rRe0),(sapic_name_renaming_extend iNRe0 rNRe0))),ESt) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig ((ProcessComb Parallel (symbtree_to_sapic iTre) (symbtree_to_sapic rTre)),(ii + ri),(sapic_renaming_extend iRe rRe),(sapic_name_renaming_extend iNRe rNRe))),ESt)) 
       =
       (sapic_plus_traces sapic_plus_position_multi_transitions_with_symb (Sym,(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P),(Pconfig_plus ((ProcessComb Parallel (symbtree_to_sapic iT0) (symbtree_to_sapic rT0)),0,(sapic_renaming_extend iRe0 rRe0),(sapic_name_renaming_extend iNRe0 rNRe0)))) (Sym',(IMAGE (SUM_MAP translate_BinPred_to_SPpred I) P'),(Pconfig_plus ((ProcessComb Parallel (symbtree_to_sapic iTre) (symbtree_to_sapic rTre)),(ii + ri),(sapic_renaming_extend iRe rRe),( sapic_name_renaming_extend iNRe rNRe)))))
    )

    ``,
    rewrite_tac[arch_Winit_def,arch_Wresp_def]>>
    rpt strip_tac >>
  IMP_RES_TAC compose_arm8_bir_vs_attacker_thm >>
  PAT_X_ASSUM ``!as'' as MTrn. A `` (ASSUME_TAC o (Q.SPECL [‘(InterpretStTwo ESt)’,‘(InterpretStTwo ESt)’,‘(iAMTrn)’]))>>
  PAT_X_ASSUM ``!as'' as MTrn. A `` (ASSUME_TAC o (Q.SPECL [‘(InterpretStTwo ESt)’,‘(InterpretStTwo ESt)’,‘(rAMTrn)’]))>> 
  REV_FULL_SIMP_TAC std_ss [] >>
  Q.EXISTS_TAC `ms'''` >>
  Q.EXISTS_TAC `ms''` >>
  rw[] >>
  metis_tac[comptraces_sapic_vs_DY_EQ_sapic_plus_traces_thm]
  )



  
val _ = export_theory();
