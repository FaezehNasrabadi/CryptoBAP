
open HolKernel Parse boolLib bossLib;
open HolBACoreSimps;
open HolBASimps;
open boolTheory;
open pred_setTheory;
open simpLib;
open symb_interpretTheory;

val _ = new_theory "sbir_tree";

(* SBIR events *) 
val _ = Datatype `sbir_event =
P2A bir_var_t
| A2P bir_var_t
| Sync_Fr bir_var_t
| Event bir_var_t
| Crypto bir_var_t
| Loop bir_var_t
| Branch bir_var_t
| Silent
  `;

val _ = Datatype `stree =
SLeaf
| SNode ('a # 'b # 'c) stree
| SBranch ('a # 'b # 'c) stree stree
	  `;

val val_of_tree_def = Define`
(val_of_tree (SLeaf) = NONE) /\
(val_of_tree (SNode n st) = SOME n) /\
(val_of_tree (SBranch n lst rst) = SOME n)`;
                                          

val position_in_tree_def = Define`
(position_in_tree (SLeaf) = NONE) /\
(position_in_tree (SNode (e,p,f) st) = SOME p) /\
(position_in_tree (SBranch (e,p,f) lst rst) = SOME p)`;


val event_of_tree_def = Define`
(event_of_tree (SLeaf) = NONE) /\
(event_of_tree (SNode (e,p,f) st) = SOME e) /\
(event_of_tree (SBranch (e,p,f) lst rst) = SOME e)`;

val env_of_tree_def = Define`
(env_of_tree (SLeaf) = NONE) /\
(env_of_tree (SNode (e,p,f) st) = SOME f) /\
(env_of_tree (SBranch (e,p,f) lst rst) = SOME f)`;

val _ = Datatype `sbir_pc_t =
  | PC_Normal 
  | PC_Event
  | PC_In
  | PC_Out
  | PC_Cr
  | PC_Fr
  | PC_Loop
  | PC_Branch
    `;
    
val _ = Datatype `sbir_environment_t = SEnv (bir_var_t -> (bir_exp_t option))`;

val symb_env_dom_def = Define `
    symb_env_dom (SEnv ro) = {symb | ro symb <> NONE}
                             `;

val symb_env_update_def = Define `
    symb_env_update (SEnv ro) (symb, vo) = SEnv ((symb =+ vo) ro)
                                                `;

val symb_env_get_def = Define `
    symb_env_get (SEnv ro) symb = ro symb
                                     `;

val env_of_val_thm = store_thm(
  "env_of_val_thm",
  ``∀Tree e i h. ((val_of_tree Tree) = SOME (e,i,h)) ⇒ ((env_of_tree Tree) = SOME h)``,
                                                                                    GEN_TAC >>
     Cases_on ‘Tree’ >>
     ASM_SIMP_TAC (srw_ss()) [val_of_tree_def] >>
     Cases_on ‘p’ >>
     Cases_on ‘r’ >>
     ASM_SIMP_TAC (srw_ss()) [val_of_tree_def,env_of_tree_def] >>
     Cases_on ‘p’ >>
     Cases_on ‘r’ >>
     ASM_SIMP_TAC (srw_ss()) [val_of_tree_def,env_of_tree_def]           
  );

val position_of_val_thm = store_thm(
  "position_of_val_thm",
  ``∀Tree e i h. ((val_of_tree Tree) = SOME (e,i,h)) ⇒ ((position_in_tree Tree) = SOME i)``,
                                                                                    GEN_TAC >>
     Cases_on ‘Tree’ >>
     ASM_SIMP_TAC (srw_ss()) [val_of_tree_def] >>
     Cases_on ‘p’ >>
     Cases_on ‘r’ >>
     ASM_SIMP_TAC (srw_ss()) [val_of_tree_def,position_in_tree_def] >>
     Cases_on ‘p’ >>
     Cases_on ‘r’ >>
     ASM_SIMP_TAC (srw_ss()) [val_of_tree_def,position_in_tree_def]           
  );
  

val single_step_execute_symbolic_tree_def =
Define`single_step_execute_symbolic_tree tre ev tre' =
(case ev of
   Silent => (∃ i H st. (tre = (SNode (Silent,i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i,H)))
 | (Event v) => (∃ i H st. (tre = (SNode ((Event v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,H)))
 | (Loop v) => (∃ i H st. (tre = (SNode ((Loop v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,H)))
 | (P2A v) => (∃ i H st. (tre = (SNode ((P2A v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,H)))
 | (Crypto v) => (∃ i H st. (tre = (SNode ((Crypto v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,(symb_interpr_update H ((BVar "crypto" (BType_Imm Bit64)), SOME (BExp_Den v))))))
 | (A2P v) => (∃ i H st. (tre = (SNode ((A2P v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,(symb_interpr_update H ((BVar "Adv" (BType_Imm Bit64)), SOME (BExp_Den v))))))
 | (Sync_Fr v) => (∃ i H st. (tre = (SNode ((Sync_Fr v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,(symb_interpr_update H ((BVar "RNG" (BType_Imm Bit64)), SOME (BExp_Den v))))))             
| (Branch v) => (∃ i H lst rst. (tre = (SBranch ((Branch v),i,H) lst rst)) ∧ ((tre' = lst) ∨ (tre' = rst)) ∧ ((val_of_tree tre') = SOME (Silent,i+1,H)))
)
`;  
   

val execute_symbolic_tree_def =
Define`execute_symbolic_tree tre Eve tre' =
(case Eve of
   [] => (tre = tre')
 | (e::ev) => (∃tre''. (execute_symbolic_tree tre ev tre'') ∧ (single_step_execute_symbolic_tree tre'' e tre'))
)
`;


val traces_of_tree_def  = Define`
traces_of_tree tre = {e| ∃tre'. (execute_symbolic_tree tre e tre')}`;

val _ = export_theory();


