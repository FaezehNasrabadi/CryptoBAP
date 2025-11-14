open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open sigma_algebraTheory;
open listTheory;
open tautLib;
open interleavingdeductionTheory;
open parallelcompositiondeductionTheory;
open translate_to_sapicTheory;
open derived_rules_deductionTheory;
open sbir_treeTheory;
open sapicplusTheory;
open messagesTheory;
open dolevyaoTheory;

val _ = new_theory "sbir_sapic_comp_DY";

     
val compose_sbir_sapic_vs_DY_thm = store_thm(
  "compose_sbir_sapic_vs_DY_thm",
  ``∀T0 Re0 NRe0 i Re NRe Tre Sym Sym' P P' S2 S2' (MTrn1:('event1 + (Name_t, Var_t) sync_event, 'pred1, ((sbir_event, real, (bir_var_t, γ) symb_interpret_t) stree), Var_t) mtrel) (MTrn1':('event1 + (Name_t, Var_t) sync_event, 'pred1, sapic_position_configuration_t, Var_t) mtrel) (Ded1:('pred1) tded).
  ((sim T0 (Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0))) ∧
   ((traces (MTrn1,Ded1) (Sym,(IMAGE OUTL P),T0) (Sym',(IMAGE OUTL P'),Tre)) ⊆ (traces (MTrn1',Ded1) (Sym,(IMAGE OUTL P),(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0))) (Sym',(IMAGE OUTL P'),(Pconfig ((symbtree_to_sapic Tre,i,Re,NRe)))))))
      ==> ((comptraces (MTrn1,Ded1) (DYmultranrel,DYdeduction) (Sym,P,T0,S2) (Sym',P',Tre,S2')) ⊆ (comptraces (MTrn1',Ded1) (DYmultranrel,DYdeduction) (Sym,P,(Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)),S2) (Sym',P',(Pconfig ((symbtree_to_sapic Tre,i,Re,NRe))),S2'))) ``,
  rewrite_tac[binterleave_composition_deduction,binterleave_ts,symbtree_to_sapic_trace_inclusion_thm] >>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [SUBSET_DEF] >>
     metis_tac[]
              );




val _ = export_theory();
