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
open arm8_vs_bir_comp_attackerTheory;
open refinementTheory;
open parallelcompositionconcreteTheory;
open interleavingconcreteTheory;
open WinitexampleTheory;
val _ = new_theory "bir_comp_attacker_vs_sbir_comp_DY";

val bir_traces_thm =
INST_TYPE [``:'cstate`` |-> ``:bir_state_t``,``:'cevent`` |-> ``:('cevent + 'ceventS)``] interleavingconcreteTheory.traces_def;
val bir_traces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) bir_traces_thm;
val bir_traces_def = Define `
    bir_traces = ^(bir_traces_t)
`;

    
val att_traces_thm =
INST_TYPE [``:'cevent`` |-> ``:('attevent + 'ceventS)``] interleavingconcreteTheory.traces_def;
val att_traces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) att_traces_thm;
val att_traces_def = Define `
    att_traces = ^(att_traces_t)
`;
    
val sbir_traces_thm =
INST_TYPE [``:'symb`` |-> ``:Var_t``,``:'pred`` |-> ``:bir_exp_t``,``:'state`` |-> ``:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree``,``:'event`` |-> ``:(sbir_event + (Name_t, Sig_t, Var_t) sync_event)``] derived_rules_generaldeductionTheory.traces_def;
val sbir_traces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) sbir_traces_thm;
val sbir_traces_def = Define `
    sbir_traces = ^(sbir_traces_t)
`;
    
val DY_traces_thm =
INST_TYPE [``:'symb`` |-> ``:Var_t``,``:'pred`` |-> ``:DYpred``,``:'state`` |-> ``:DYstate``,``:'event`` |-> ``:(DYnsyc_event + (Name_t, Sig_t, Var_t) sync_event)``] derived_rules_generaldeductionTheory.traces_def;
val DY_traces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) DY_traces_thm;
val DY_traces_def = Define `
    DY_traces = ^(DY_traces_t)
`;

val bir_att_comptraces_thm =
INST_TYPE [``:'cevent1`` |-> ``:'cevent``,``:'cevent2`` |-> ``:'attevent``,``:'cstate1`` |-> ``:bir_state_t``,``:'cstate2`` |-> ``:'cstate``] interleavingconcreteTheory.comptraces_def;
val bir_att_comptraces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) bir_att_comptraces_thm;
val bir_att_comptraces_def = Define `
    bir_att_comptraces = ^(bir_att_comptraces_t)
`;

val sbir_DY_comptraces_thm =
INST_TYPE [``:'symb`` |-> ``:Var_t``,``:'pred1`` |-> ``:bir_exp_t``,``:'state1`` |-> ``:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree``,``:'event1`` |-> ``:sbir_event``,``:'pred2`` |-> ``:DYpred``,``:'state2`` |-> ``:DYstate``,``:'event2`` |-> ``:DYnsyc_event``,``:'eventS`` |-> ``:(Name_t, Sig_t, Var_t) sync_event``] derived_rules_generaldeductionTheory.comptraces_def;
val sbir_DY_comptraces_t = (fst o strip_comb o fst o dest_eq o snd o strip_forall o concl) sbir_DY_comptraces_thm;
val sbir_DY_comptraces_def = Define `
    sbir_DY_comptraces = ^(sbir_DY_comptraces_t)
`;


val compose_bir_attacker_vs_sbir_DY_thm = store_thm(
  "compose_bir_attacker_vs_sbir_DY_thm",
  ``
  ∀(Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(bir_exp_t + DYpred -> bool)) (P':(bir_exp_t + DYpred -> bool)) (T0:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (Tre:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (birprog:'observation_type bir_program_t) (AMTrn:('attevent + 'ceventS, 'cstate) mctrel) (sbir_Ded:(bir_exp_t) tded).

    (
    (TransEnable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) /\
     (subset_one
      (bir_traces (((bir_mrel (birprog:'observation_type bir_program_t)): bir_state_t -> ('cevent + 'ceventS) list -> bir_state_t -> bool)) ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre))
      (sbir_traces (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (Sym,(IMAGE OUTL P),T0) (Sym',(IMAGE OUTL P'),Tre))) ∧
     (subset_two
      (att_traces AMTrn ((InterpretStTwo:DYstate -> 'cstate) ESt) ((InterpretStTwo:DYstate -> 'cstate) ESt))
      (DY_traces (DYmultranrel,DYdeduction) (Sym,(IMAGE OUTR P),ESt) (Sym',(IMAGE OUTR P'),ESt)))
) ==>
(subset_comp
   (bir_att_comptraces (composeMuRe (((bir_mrel (birprog:'observation_type bir_program_t)): bir_state_t -> ('cevent + 'ceventS) list -> bir_state_t -> bool)) AMTrn) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0),((InterpretStTwo:DYstate -> 'cstate) ESt)) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre),((InterpretStTwo:DYstate -> 'cstate) ESt)))
   (sbir_DY_comptraces (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox (Sym,P,T0,ESt) (Sym',P',Tre,ESt))
)
``, 
  
rewrite_tac[sbir_DY_comptraces_def,bir_att_comptraces_def,DY_traces_def,sbir_traces_def,att_traces_def,bir_traces_def,binterleave_composition_concrete,interleavingconcreteTheory.binterleave_ts,interleavinggeneraldeductionTheory.binterleave_ts,derived_rules_generaldeductionTheory.traces_def,interleavingconcreteTheory.traces_def]>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [subset_one_def,subset_two_def,subset_comp_def]>>
  rw[]>>
 Q.EXISTS_TAC `InterpretEvComp` >>
rw[] >>
PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`((RevInterpretEvTwoSyn:('attevent + 'ceventS) list -> (DYnsyc_event + (Name_t, Sig_t, Var_t) sync_event) option list) (t2:(('attevent+'ceventS) list)))`]))>>
  PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`((RevInterpretEvOneSyn:('cevent + 'ceventS) list -> (sbir_event + (Name_t, Sig_t, Var_t) sync_event) option list) (t1:(('cevent + 'ceventS) list)))`]))>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [applyfunEvOneSyn,applyfunEvTwoSyn]>>            
RES_TAC>>
IMP_RES_TAC binterleave_composition_generaldeduction_supseteq >>
PAT_X_ASSUM ``!Sym' Sym S2' S2 S1' S1 P' P. A`` (ASSUME_TAC o (Q.SPECL [`Sym'`,`Sym`,`ESt`,`ESt`,`Tre`,`T0`,`P'`,`P`])) >>
RES_TAC >>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [SUBSET_DEF] >>
PAT_X_ASSUM ``!x. A`` (ASSUME_TAC o (Q.SPECL [`x`])) >>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [interleavinggeneraldeductionTheory.binterleave_ts,derived_rules_generaldeductionTheory.traces_def,derived_rules_generaldeductionTheory.comptraces_def] >>
IMP_RES_TAC binterl_Rev >>
RES_TAC
);

        
val birprog_t = List.nth((snd o strip_comb o concl) WinitexampleTheory.Winitexample_thm, 3);
val birprog_def = Define `
    birprog = ^(birprog_t)
`;

     
val compose_birexample_attacker_vs_sbir_DY_thm = store_thm(
  "compose_birexample_attacker_vs_sbir_DY_thm",
  ``
  ∀(Sym:(Var_t -> bool)) (Sym':(Var_t -> bool)) (P:(bir_exp_t + DYpred -> bool)) (P':(bir_exp_t + DYpred -> bool)) (T0:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (Tre:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree) (AMTrn:('attevent + 'ceventS, 'cstate) mctrel) (sbir_Ded:(bir_exp_t) tded).

        ((TransEnable composeDedOverApprox (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction)) /\
     (subset_one
      (bir_traces (((bir_mrel (birprog:'observation_type bir_program_t)): bir_state_t -> ('cevent + 'ceventS) list -> bir_state_t -> bool)) ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0) ((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre))
      (sbir_traces (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (Sym,(IMAGE OUTL P),T0) (Sym',(IMAGE OUTL P'),Tre))) ∧
     (subset_two
      (att_traces AMTrn ((InterpretStTwo:DYstate -> 'cstate) ESt) ((InterpretStTwo:DYstate -> 'cstate) ESt))
      (DY_traces (DYmultranrel,DYdeduction) (Sym,(IMAGE OUTR P),ESt) (Sym',(IMAGE OUTR P'),ESt)))
) ==>
(subset_comp
   (bir_att_comptraces (composeMuRe (((bir_mrel (birprog:'observation_type bir_program_t)): bir_state_t -> ('cevent + 'ceventS) list -> bir_state_t -> bool)) AMTrn) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) T0),((InterpretStTwo:DYstate -> 'cstate) ESt)) (((InterpretStOne:(sbir_event, real,(bir_var_t, bir_exp_t) symb_interpret_t) stree -> bir_state_t) Tre),((InterpretStTwo:DYstate -> 'cstate) ESt)))
   (sbir_DY_comptraces (symbolic_tree_multi_transitions_with_symb,sbir_Ded) (DYmultranrel,DYdeduction) composeDedOverApprox (Sym,P,T0,ESt) (Sym',P',Tre,ESt))
)
``,
metis_tac[compose_bir_attacker_vs_sbir_DY_thm]
);


val _ = export_theory();
