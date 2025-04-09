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

val _ = new_theory "combined_deduction";


val composeDedOverApprox_def =
Define`
      composeDedOverApprox (P:(bir_exp_t + DYpred -> bool)) ((INR ((K (z:SapicTerm_t)):DYpred)):(bir_exp_t + DYpred)) =
(∃(x :bir_exp_t) (y :bir_exp_t) (v:bir_var_t).
   (((K ((translate_birexp_to_sapicterm x):SapicTerm_t)):DYpred) ∈ (IMAGE OUTR P)) ∧
   (((BExp_BinPred BIExp_Equal x y):bir_exp_t) ∈ (IMAGE OUTL P)) ∧
   (v ∈ (bir_vars_of_exp y)) ∧
   (z = (translate_birexp_to_sapicterm (BExp_Den v)))
)
`;


val composeDedOverApproxSapic_def =
Define`
      composeDedOverApproxSapic (P:(SPpred + DYpred -> bool)) ((INR ((K (z:SapicTerm_t)):DYpred)):(SPpred + DYpred)) =
(∃(x :SapicTerm_t) (y :SapicTerm_t) (v:Var_t).
   (((K (x)):DYpred) ∈ (IMAGE OUTR P)) ∧
   ((SP_Equ(x,y)) ∈ (IMAGE OUTL P)) ∧
   (v ∈ (fv y)) ∧
   (z = (TVar v))
)
`;

        
val _ = export_theory();
