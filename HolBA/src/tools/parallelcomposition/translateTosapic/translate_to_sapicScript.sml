
open HolKernel Parse boolLib bossLib;
open sapicplusTheory;
open messagesTheory;
open wordsTheory;
open ASCIInumbersTheory;
open Arbnumcore;
open bir_immTheory;
open integerTheory;
open Term;
open sbir_treeTheory;
open optionTheory;
open updateTheory;
open pred_setTheory;
open symb_interpretTheory;
open listTheory;


val _ = new_theory "translate_to_sapic";                

(*****************start translation Bir Exp to Sapic Term**********************)

val translate_Imm_to_string_def = Define`
translate_Imm_to_string imm =
(toString o b2n) imm
`;


val translate_birvar_to_sapicvar_def = Define`
translate_birvar_to_sapicvar (BVar str _) =
(Var str 0)
`;


val translate_birvar_to_sapicfreshname_def = Define`
translate_birvar_to_sapicfreshname (BVar str _) =
(Name FreshName str)
`;

        
val translate_bir_immtype_to_sapicterm_def = Define`
translate_bir_immtype_to_sapicterm immty =
Con (Name PubName ((toString o size_of_bir_immtype) immty))
    `;
        
      
val translate_UnaryExp_to_string_def = Define`
translate_UnaryExp_to_string ue =
(case ue of
   BIExp_ChangeSign => "ChangeSign"
 | BIExp_Not        => "Not"
 | BIExp_CLZ        => "CLZ"
 | BIExp_CLS        => "CLS"
)`;

val translate_BinExp_to_string_def = Define`
translate_BinExp_to_string be =
(case be of
   BIExp_And              => "And"
 | BIExp_Or               => "Or"
 | BIExp_Xor              => "Xor"
 | BIExp_Plus             => "Plus"
 | BIExp_Minus            => "Minus"
 | BIExp_Mult             => "Mult"
 | BIExp_Div              => "Div"
 | BIExp_SignedDiv        => "SignedDiv"
 | BIExp_Mod              => "Mod"
 | BIExp_SignedMod        => "SignedMod"
 | BIExp_LeftShift        => "LeftShift"
 | BIExp_RightShift       => "RightShift"
 | BIExp_SignedRightShift => "SignedRightShift"
)`;

val translate_BinPred_to_string_def = Define`
translate_BinPred_to_string bp =
(case bp of
   BIExp_Equal             => "Equal"
 | BIExp_NotEqual          => "NotEqual"
 | BIExp_LessThan          => "LessThan"
 | BIExp_SignedLessThan    => "SignedLessThan"
 | BIExp_LessOrEqual       => "LessOrEqual"
 | BIExp_SignedLessOrEqual => "SignedLessOrEqual"
)`;


val translate_Cast_to_string_def = Define`
translate_Cast_to_string ct =
(case ct of
   BIExp_UnsignedCast => "UnsignedCast"
 | BIExp_SignedCast   => "SignedCast"
 | BIExp_HighCast     => "HighCast"
 | BIExp_LowCast      => "LowCast"
)`;


val translate_Endian_to_string_def = Define`
translate_Endian_to_string en =
(case en of        
   BEnd_BigEndian    => "BigEndian"
 | BEnd_LittleEndian => "LittleEndian"
 | BEnd_NoEndian     => "NoEndian"
)`;


val translate_birexp_to_sapicterm_def = Define`
                                               translate_birexp_to_sapicterm exp =
 (case exp of
    BExp_Const c                      => Con (Name PubName (translate_Imm_to_string c))
  | BExp_MemConst v1 v2 v3            => Con (Name PubName (toString ((size_of_bir_immtype v1) + (size_of_bir_immtype v2))))
  | BExp_Den bv                       => TVar (translate_birvar_to_sapicvar bv)
  | BExp_Load e1 e2 a b               => FAPP ("Load",(2, Public, Constructor)) [(translate_birexp_to_sapicterm e1);(translate_birexp_to_sapicterm e2)]
  | BExp_Store e1 e2 a e3             => FAPP ("Store",(3, Public, Destructor)) [(translate_birexp_to_sapicterm e1);(translate_birexp_to_sapicterm e2);(translate_birexp_to_sapicterm e3)]
  | BExp_UnaryExp ue e                => FAPP ((translate_UnaryExp_to_string ue),(1, Public, Constructor)) [(translate_birexp_to_sapicterm e)]
  | BExp_BinExp be e1 e2              => FAPP ((translate_BinExp_to_string be),(2, Public, Constructor)) [(translate_birexp_to_sapicterm e1);(translate_birexp_to_sapicterm e2)]
  | BExp_BinPred bp e1 e2             => FAPP ((translate_BinPred_to_string bp),(2, Public, Constructor)) [(translate_birexp_to_sapicterm e1);(translate_birexp_to_sapicterm e2)]
  | BExp_MemEq e1 e2                  => FAPP ("MemEq",(2, Public, Constructor)) [(translate_birexp_to_sapicterm e1);(translate_birexp_to_sapicterm e2)]
  | BExp_IfThenElse e1 e2 e3          => FAPP ("IfThenElse",(3, Public, Destructor)) [(translate_birexp_to_sapicterm e1);(translate_birexp_to_sapicterm e2);(translate_birexp_to_sapicterm e3)]
  | BExp_Cast v8 v9 v10               => FAPP ((translate_Cast_to_string v8),(2, Public, Constructor)) [(translate_birexp_to_sapicterm v9);(Con (Name PubName ((toString o size_of_bir_immtype) v10)))]
 ) 
 `;

val translate_BinPred_to_SPpred_def = Define`
                                            translate_BinPred_to_SPpred exp =
(case exp of
   BExp_BinPred bp e1 e2 => (case bp of
                               BIExp_Equal => SP_Equ((translate_birexp_to_sapicterm e1),(translate_birexp_to_sapicterm e2))
                             | _ => Undef
                            )
 | _                     => Undef
) 
`;        
(*****************end translation Bir Exp to Sapic Term**********************)
                 
val sbirEvent_to_sapicFact_def = Define `
sbirEvent_to_sapicFact e =
(case e of
  P2A v     => (Fact OutFact [(translate_birexp_to_sapicterm (BExp_Den v))])
| A2P v     => (Fact InFact [(TVar (translate_birvar_to_sapicvar v))])
| Sync_Fr v => (Fact FreshFact [(Con (translate_birvar_to_sapicfreshname v))])
| Event v   => (Fact TermFact [(translate_birexp_to_sapicterm (BExp_Den v))])
| Crypto v  => (Fact DedFact [(translate_birexp_to_sapicterm (BExp_Den v))])
| Assign v  => (Fact DedFact [(translate_birexp_to_sapicterm (BExp_Den v))])
| Loop v    => (Fact TermFact [(translate_birexp_to_sapicterm (BExp_Den v))])
| Branch v  => (Fact TermFact [(translate_birexp_to_sapicterm (BExp_Den v))])
| Silent    => (Fact TermFact [])
        )
  `;

  
val symbtree_to_sapic_def = Define`
(symbtree_to_sapic (SLeaf) = ProcessNull) /\
(symbtree_to_sapic (SNode (Silent,i,H) st) = (symbtree_to_sapic st)) /\
(symbtree_to_sapic (SNode ((Event v),i,H) st) =
(ProcessAction (Event (Fact TermFact [(translate_birexp_to_sapicterm (BExp_Den v))])) (symbtree_to_sapic st))) /\
(symbtree_to_sapic (SNode ((Assign v),i,H) st) =
(ProcessComb  (Let (TVar (translate_birvar_to_sapicvar (BVar "let" (BType_Imm Bit64)))) (translate_birexp_to_sapicterm (BExp_Den v))) (symbtree_to_sapic st) (ProcessNull))) /\
(symbtree_to_sapic (SNode ((Crypto v),i,H) st) =
(ProcessComb  (Let (TVar (translate_birvar_to_sapicvar (BVar "let" (BType_Imm Bit64)))) (translate_birexp_to_sapicterm (BExp_Den v))) (symbtree_to_sapic st) (ProcessNull))) /\
(symbtree_to_sapic (SNode ((Loop v),i,H) st) = (ProcessAction  Rep (symbtree_to_sapic st)))  /\
(symbtree_to_sapic (SNode ((P2A v),i,H) st) = (ProcessAction (ChOut (SOME (TVar (Var "Channel" 0))) (translate_birexp_to_sapicterm (BExp_Den v))) (symbtree_to_sapic st))) /\
(symbtree_to_sapic (SNode ((A2P v),i,H) st) = (ProcessAction (ChIn (SOME (TVar (Var "Channel" 0))) (TVar (translate_birvar_to_sapicvar v))) (symbtree_to_sapic st))) /\
(symbtree_to_sapic (SNode ((Sync_Fr v),i,H) st) = (ProcessAction (New (translate_birvar_to_sapicfreshname v)) (symbtree_to_sapic st)))/\
(symbtree_to_sapic (SBranch (Branch v,i,H) lst rst) =
(ProcessComb NDC (symbtree_to_sapic lst) (symbtree_to_sapic rst))) /\
(symbtree_to_sapic _ = ProcessNull)`;


val sim_def = Define`
                   ( sim Tr (Pconfig (Pro,i,Re,NRe)) =
                     ((Pro = (symbtree_to_sapic Tr)) ∧
                        (i = THE (position_in_tree Tr))∧
                      ((sapic_renaming_dom Re = IMAGE translate_birvar_to_sapicvar (symb_interpr_dom (THE (env_of_tree Tr)))))
                      ))
`;       

              

val symbtree_to_sapic_initial_state_simulation_thm = store_thm(
  "symbtree_to_sapic_initial_state_simulation_thm",
  ``
∀T0 C0 H0 Re0 NRe0.
        (((val_of_tree T0) = SOME (Silent,0,H0)) ∧
        (C0 = (Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)))∧
        ((symb_interpr_dom H0) = {})∧
        (sapic_renaming_dom Re0 = {}))
         ⇒ (sim T0 C0)``,  
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)>>
IMP_RES_TAC env_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)

        
val symbtree_to_sapic_single_step_simulation_thm = store_thm(
  "symbtree_to_sapic_single_step_simulation_thm",
  ``
∀E Tree Tree' Pro i Re NRe.
        (((single_step_execute_symbolic_tree Tree E Tree' ) ∧ (sim Tree (Pconfig (Pro,i,Re,NRe))))
         ⇒ (∃Pro' i' Re' NRe' Ev. (sim Tree' (Pconfig (Pro',i',Re',NRe'))) ∧ (sapic_position_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe'))) ∧ (Ev = sbirEvent_to_sapicFact E)))``,                                                                                                               
gen_tac >>
  Cases_on ‘E’ >- (
    rewrite_tac[sbirEvent_to_sapicFact_def] >>
rw[single_step_execute_symbolic_tree_def]>>
IMP_RES_TAC sim_def>>
ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def] >>
ASM_SIMP_TAC (srw_ss()) [sapic_position_transition_def]>>
ASM_SIMP_TAC (srw_ss()) [sapic_position_out_transition_def]>>
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)>>
IMP_RES_TAC env_of_val_thm>>
rewrite_tac[env_of_tree_def]>>
ASM_SIMP_TAC (srw_ss()) []
)
(*end of P2A*)
  >-(
    rewrite_tac[sbirEvent_to_sapicFact_def] >>
rw[single_step_execute_symbolic_tree_def]>>
IMP_RES_TAC sim_def>>
ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def,sapic_position_transition_def]>>
ASM_SIMP_TAC (srw_ss()) [sapic_position_in_transition_def]>>
Cases_on ‘H’ >-(
Cases_on ‘Re’ >-(
rewrite_tac[sapic_renaming_update_def] >>
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm >>
ASM_SIMP_TAC (srw_ss()) []
)
>-(
IMP_RES_TAC env_of_val_thm >>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sapic_renaming_update_def,symb_interpr_dom_def,sapic_renaming_dom_def,symb_interpr_update_def,env_of_tree_def,IMAGE_DEF,EXTENSION]>>
gen_tac >>
PAT_X_ASSUM ``!x. A `` (ASSUME_TAC o (Q.SPECL [`x`]))>>
rw[UPDATE_def]>-(
Q.EXISTS_TAC `BVar "Adv" (BType_Imm Bit64)`>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [translate_birvar_to_sapicvar_def]
)>>
eq_tac >-(
rpt strip_tac >>
Q.EXISTS_TAC `x'` >>                       
ASM_SIMP_TAC (srw_ss()) []>>
Cases_on ‘x' = BVar "Adv" (BType_Imm Bit64)’>>
ASM_SIMP_TAC (srw_ss()) []
) >>
rpt strip_tac >>
Q.EXISTS_TAC `x'` >>                        
ASM_SIMP_TAC (srw_ss()) [] >>
Cases_on ‘x' = BVar "Adv" (BType_Imm Bit64)’ >>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [translate_birvar_to_sapicvar_def]
))))
(*end of A2P*)
  >-(
    rewrite_tac[sbirEvent_to_sapicFact_def] >>
rw[single_step_execute_symbolic_tree_def]>>
IMP_RES_TAC sim_def>>
ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def,sapic_position_transition_def]>>
ASM_SIMP_TAC (srw_ss()) [sapic_position_new_transition_def]>>
Cases_on ‘H’ >>
Cases_on ‘Re’ >>
Cases_on ‘NRe’ >>
rewrite_tac[sapic_renaming_update_def,sapic_name_renaming_update_def] >>
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)
>-(
IMP_RES_TAC env_of_val_thm>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sapic_renaming_update_def,symb_interpr_dom_def,sapic_renaming_dom_def,symb_interpr_update_def,env_of_tree_def,IMAGE_DEF,EXTENSION]>>
gen_tac>>
PAT_X_ASSUM ``!x. A `` (ASSUME_TAC o (Q.SPECL [`x`]))>>
rw[UPDATE_def]>-(
Q.EXISTS_TAC `BVar "RNG" (BType_Imm Bit64)`>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [translate_birvar_to_sapicvar_def]
)>>
eq_tac >-(
rpt strip_tac >>
Q.EXISTS_TAC `x'` >>                         
ASM_SIMP_TAC (srw_ss()) [] >>
Cases_on ‘x' = BVar "RNG" (BType_Imm Bit64)’ >>
ASM_SIMP_TAC (srw_ss()) []
) >>
rpt strip_tac >>
Q.EXISTS_TAC `x'` >>                       
ASM_SIMP_TAC (srw_ss()) [] >>
Cases_on ‘x' = BVar "RNG" (BType_Imm Bit64)’>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [translate_birvar_to_sapicvar_def]
))
(*end of Sync_Fr*)
  >-(
    rewrite_tac[sbirEvent_to_sapicFact_def] >>
rw[single_step_execute_symbolic_tree_def]>>
IMP_RES_TAC sim_def>>
ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def] >>
ASM_SIMP_TAC (srw_ss()) [sapic_position_transition_def]>>
ASM_SIMP_TAC (srw_ss()) [sapic_position_event_transition_def]>>
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)>>
IMP_RES_TAC env_of_val_thm>>
rewrite_tac[env_of_tree_def]>>
ASM_SIMP_TAC (srw_ss()) []
)
(*end of Event*)
  >-(
    rewrite_tac[sbirEvent_to_sapicFact_def] >>
rw[single_step_execute_symbolic_tree_def]>>
IMP_RES_TAC sim_def>>
ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def,sapic_position_transition_def]>>
ASM_SIMP_TAC (srw_ss()) [sapic_position_let_true_transition_def,sapic_position_let_false_transition_def]>>
Cases_on ‘H’ >>
Cases_on ‘Re’ >>
Cases_on ‘NRe’ >>
rewrite_tac[sapic_renaming_update_def,sapic_name_renaming_update_def] >>
Q.EXISTS_TAC `symbtree_to_sapic Tree'` >>
Q.EXISTS_TAC `i'+1` >>
Q.EXISTS_TAC ` Renaming f'⦇Var "let" 0 ↦ SOME (translate_birexp_to_sapicterm (BExp_Den b))⦈ ` >>
Q.EXISTS_TAC `NameRenaming f''` >>
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)
>-(
IMP_RES_TAC env_of_val_thm>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sapic_renaming_update_def,symb_interpr_dom_def,sapic_renaming_dom_def,symb_interpr_update_def,env_of_tree_def,IMAGE_DEF,EXTENSION]>>
gen_tac >>
PAT_X_ASSUM ``!x. A `` (ASSUME_TAC o (Q.SPECL [`x`]))>>
rw[UPDATE_def]>-(
Q.EXISTS_TAC `BVar "let" (BType_Imm Bit64)`>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [translate_birvar_to_sapicvar_def]
)>>
eq_tac >-(
rpt strip_tac >>
Q.EXISTS_TAC `x'` >>                       
ASM_SIMP_TAC (srw_ss()) []>>
Cases_on ‘x' = BVar "let" (BType_Imm Bit64)’>>
ASM_SIMP_TAC (srw_ss()) []
)>>
rpt strip_tac >>
Q.EXISTS_TAC `x'`  >>                      
ASM_SIMP_TAC (srw_ss()) []>>
Cases_on ‘x' = BVar "let" (BType_Imm Bit64)’>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [translate_birvar_to_sapicvar_def]
))
  (*end of Crypto*)
  >-(
    rewrite_tac[sbirEvent_to_sapicFact_def] >>
rw[single_step_execute_symbolic_tree_def]>>
IMP_RES_TAC sim_def>>
ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def,sapic_position_transition_def]>>
ASM_SIMP_TAC (srw_ss()) [sapic_position_let_true_transition_def,sapic_position_let_false_transition_def]>>
Cases_on ‘H’ >>
Cases_on ‘Re’ >>
Cases_on ‘NRe’ >>
rewrite_tac[sapic_renaming_update_def,sapic_name_renaming_update_def] >>
Q.EXISTS_TAC `symbtree_to_sapic Tree'` >>
Q.EXISTS_TAC `i'+1` >>
Q.EXISTS_TAC ` Renaming f'⦇Var "let" 0 ↦ SOME (translate_birexp_to_sapicterm (BExp_Den b))⦈ ` >>
Q.EXISTS_TAC `NameRenaming f''` >>
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)
>-(
IMP_RES_TAC env_of_val_thm>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [sapic_renaming_update_def,symb_interpr_dom_def,sapic_renaming_dom_def,symb_interpr_update_def,env_of_tree_def,IMAGE_DEF,EXTENSION]>>
gen_tac >>
PAT_X_ASSUM ``!x. A `` (ASSUME_TAC o (Q.SPECL [`x`]))>>
rw[UPDATE_def]>-(
Q.EXISTS_TAC `BVar "let" (BType_Imm Bit64)`>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [translate_birvar_to_sapicvar_def]
)>>
eq_tac >-(
rpt strip_tac >>
Q.EXISTS_TAC `x'` >>                       
ASM_SIMP_TAC (srw_ss()) []>>
Cases_on ‘x' = BVar "let" (BType_Imm Bit64)’>>
ASM_SIMP_TAC (srw_ss()) []
)>>
rpt strip_tac >>
Q.EXISTS_TAC `x'`  >>                      
ASM_SIMP_TAC (srw_ss()) []>>
Cases_on ‘x' = BVar "let" (BType_Imm Bit64)’>>
FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [translate_birvar_to_sapicvar_def]
      ) )
(*end of Assign*)
  >-(
    rewrite_tac[sbirEvent_to_sapicFact_def] >>
rw[single_step_execute_symbolic_tree_def]>>
IMP_RES_TAC sim_def>>
ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def] >>
ASM_SIMP_TAC (srw_ss()) [sapic_position_transition_def]>>
ASM_SIMP_TAC (srw_ss()) [sapic_position_replication_transition_def]>>
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)>>
IMP_RES_TAC env_of_val_thm>>
rewrite_tac[env_of_tree_def]>>
ASM_SIMP_TAC (srw_ss()) []
)
(*end of Loop*)      
  >-(
    rewrite_tac[sbirEvent_to_sapicFact_def] >>
rw[single_step_execute_symbolic_tree_def]
>-(
IMP_RES_TAC sim_def>>
ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def] >>
ASM_SIMP_TAC (srw_ss()) [sapic_position_transition_def]>>
ASM_SIMP_TAC (srw_ss()) [sapic_position_ndc_transition_def]>>
Q.EXISTS_TAC `symbtree_to_sapic Tree'` >>
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)>>
IMP_RES_TAC env_of_val_thm>>
rewrite_tac[env_of_tree_def]>>
ASM_SIMP_TAC (srw_ss()) []
)
>-(
IMP_RES_TAC sim_def>>
ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def] >>
ASM_SIMP_TAC (srw_ss()) [sapic_position_transition_def]>>
ASM_SIMP_TAC (srw_ss()) [sapic_position_ndc_transition_def]>>
Q.EXISTS_TAC `symbtree_to_sapic Tree'` >>
rw[sim_def] >-(
IMP_RES_TAC position_of_val_thm>>
ASM_SIMP_TAC (srw_ss()) []
)>>
IMP_RES_TAC env_of_val_thm>>
rewrite_tac[env_of_tree_def]>>
ASM_SIMP_TAC (srw_ss()) []             
))
(*end of Branch *)  
  >-(
    rewrite_tac[sbirEvent_to_sapicFact_def] >>
    rw[single_step_execute_symbolic_tree_def]>>
    IMP_RES_TAC sim_def>>
    ASM_SIMP_TAC (srw_ss()) [symbtree_to_sapic_def,position_in_tree_def] >>
    Q.EXISTS_TAC `symbtree_to_sapic Tree'` >>
    Q.EXISTS_TAC `i'` >>
    Q.EXISTS_TAC `Re` >>
    Q.EXISTS_TAC `NRe` >>
    rw[sim_def,PConfigNoStep] >-(
      IMP_RES_TAC position_of_val_thm>>
      ASM_SIMP_TAC (srw_ss()) []
      )>>
    IMP_RES_TAC env_of_val_thm>>
    rewrite_tac[env_of_tree_def]>>
    ASM_SIMP_TAC (srw_ss()) []
    )
  (*end of silent *)
  );

        
      
val symbtree_to_sapic_trace_simulation_thm = store_thm(
  "symbtree_to_sapic_trace_simulation_thm",
  ``
∀E Tree Tree' Pro i Re NRe.
        (((execute_symbolic_tree Tree E Tree' ) ∧ (sim Tree (Pconfig (Pro,i,Re,NRe))))
         ⇒ (∃Pro' i' Re' NRe' Ev. (sim Tree' (Pconfig (Pro',i',Re',NRe'))) ∧ (sapic_position_multi_transitions (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe'))) ∧ (Ev = MAP sbirEvent_to_sapicFact E))) ``,

gen_tac>>
  Induct_on ‘E’ >-(
    rewrite_tac[sbirEvent_to_sapicFact_def]>>
    rw[execute_symbolic_tree_def]>>
    Q.EXISTS_TAC `Pro` >>
    Q.EXISTS_TAC `i` >>
    Q.EXISTS_TAC `Re` >>
    Q.EXISTS_TAC `NRe` >>
    ASM_SIMP_TAC (srw_ss()) []>>
    rw[sapic_position_multi_transitions_nil]    
    )>>
    rpt strip_tac>>
    IMP_RES_TAC execute_symbolic_tree_def>>
    FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) []>>
    PAT_X_ASSUM ``!Tree Tree' Pro i Re NRe. A`` (ASSUME_TAC o (Q.SPECL [`Tree`,`tre''`,`Pro`,`i`,`Re`,`NRe`])) >>
    RES_TAC>>
    IMP_RES_TAC symbtree_to_sapic_single_step_simulation_thm>>          
    Q.EXISTS_TAC `Pro''''` >>
    Q.EXISTS_TAC `i''''` >>
    Q.EXISTS_TAC `Re''''` >>
    Q.EXISTS_TAC `NRe''''` >>
    ASM_SIMP_TAC (srw_ss()) []>>
    metis_tac[sapic_position_multi_transitions_move]      
);


val symbtree_to_sapic_trace_inclusion_thm = store_thm(
  "symbtree_to_sapic_trace_inclusion_thm",
  ``∀T0 Re0 NRe0.
    (sim T0 (Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0)))
    ⇒ ((IMAGE (MAP sbirEvent_to_sapicFact) (traces_of_tree T0)) ⊆ (traces_of_sapic (Pconfig ((symbtree_to_sapic T0),0,Re0,NRe0))))``,
  FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [traces_of_tree_def,traces_of_sapic_def,EXTENSION,IMAGE_DEF,SUBSET_DEF]>>
     rw[] >>
     Induct_on‘x'’>-(
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) [MAP,sbirEvent_to_sapicFact_def]>>
      rw[]>>
      Q.EXISTS_TAC `symbtree_to_sapic T0` >>
      Q.EXISTS_TAC `0` >>            
      Q.EXISTS_TAC `Re0` >>
      Q.EXISTS_TAC `NRe0` >>
      metis_tac[sapic_position_multi_transitions_nil]
      )
     >-(
      rpt strip_tac>>
      IMP_RES_TAC execute_symbolic_tree_def>>
      FULL_SIMP_TAC (list_ss++pred_setSimps.PRED_SET_ss++boolSimps.LIFT_COND_ss++boolSimps.EQUIV_EXTRACT_ss) []>>
      IMP_RES_TAC symbtree_to_sapic_trace_simulation_thm>>
      IMP_RES_TAC symbtree_to_sapic_single_step_simulation_thm>>
      Q.EXISTS_TAC `Pro''''''` >>
      Q.EXISTS_TAC `i''''''` >>
      Q.EXISTS_TAC `Re''''''` >>
      Q.EXISTS_TAC `NRe''''''` >>
      metis_tac[sapic_position_multi_transitions_move]
      )
  );

   
  
val _ = export_theory();
