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
| Assign bir_var_t
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
 | (Assign v) => (∃ i H st. (tre = (SNode ((Assign v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,(symb_interpr_update H ((BVar "let" (BType_Imm Bit64)), SOME (BExp_Den v))))))
 | (Crypto v) => (∃ i H st. (tre = (SNode ((Crypto v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,(symb_interpr_update H ((BVar "let" (BType_Imm Bit64)), SOME (BExp_Den v))))))
 | (A2P v) => (∃ i H st. (tre = (SNode ((A2P v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,(symb_interpr_update H ((BVar "Adv" (BType_Imm Bit64)), SOME (BExp_Den v))))))
 | (Sync_Fr v) => (∃ i H st. (tre = (SNode ((Sync_Fr v),i,H) st)) ∧ (tre' = st) ∧ ((val_of_tree tre') = SOME (Silent,i+1,(symb_interpr_update H ((BVar "RNG" (BType_Imm Bit64)), SOME (BExp_Den v))))))             
| (Branch v) => (∃ i H lst rst. (tre = (SBranch ((Branch v),i,H) lst rst)) ∧ ((tre' = lst) ∨ (tre' = rst)) ∧ ((val_of_tree tre') = SOME (Silent,i+1,H)))
)
`;  
   

val execute_symbolic_tree_def =
Define `execute_symbolic_tree tre Eve tre' =
(case Eve of
   [] => (tre = tre')
 | (e::ev) => (∃tre''. (execute_symbolic_tree tre ev tre'') ∧ (single_step_execute_symbolic_tree tre'' e tre'))
)
`;

val symbolic_tree_transition_with_symb_def =
Define `symbolic_tree_transition_with_symb (Sym,P,tre) Eve (Sym',P',tre') =
(case Eve of
   NONE => ((Sym = Sym') ∧ (P = P') ∧ (tre = tre'))
 | SOME ((INL e):(sbir_event + (Name_t, Sig_t, Var_t) sync_event)) => (single_step_execute_symbolic_tree tre e tre')
 | SOME ((INR e):(sbir_event + (Name_t, Sig_t, Var_t) sync_event)) => ((Sym = Sym') ∧ (P = P') ∧ (tre = tre'))
)
`;        

Inductive symbolic_tree_multi_transitions_with_symb:
[~nil:]
  (symbolic_tree_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:('SPpred -> bool)),(tr:((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))) [] ((Sym:(Var_t -> bool)),(P:('SPpred -> bool)),(tr:((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree)))) /\
[~moveF:]
  (((symbolic_tree_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:('SPpred -> bool)),(tr:((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))) ev ((Sym'':(Var_t -> bool)),(P'':('SPpred -> bool)),(tr'':((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))))∧(symbolic_tree_transition_with_symb ((Sym'':(Var_t -> bool)),(P'':('SPpred -> bool)),(tr'':((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))) e ((Sym':(Var_t -> bool)),(P':('SPpred -> bool)),(tr':((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))))) ==> (symbolic_tree_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:('SPpred -> bool)),(tr:((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))) (e::ev) ((Sym':(Var_t -> bool)),(P':('SPpred -> bool)),(tr':((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))))) /\
[~moveB:]
  (((symbolic_tree_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:('SPpred -> bool)),(tr:((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))) (e::ev) ((Sym':(Var_t -> bool)),(P':('SPpred -> bool)),(tr':((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))))∧(symbolic_tree_transition_with_symb ((Sym'':(Var_t -> bool)),(P'':('SPpred -> bool)),(tr'':((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))) e ((Sym':(Var_t -> bool)),(P':('SPpred -> bool)),(tr':((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))))) ==>
(symbolic_tree_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:('SPpred -> bool)),(tr:((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))) ev ((Sym'':(Var_t -> bool)),(P'':('SPpred -> bool)),(tr'':((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree)))))
End        

val traces_of_tree_def  = Define`
traces_of_tree tre = {e| ∃tre'. (execute_symbolic_tree tre e tre')}`;

val traces_of_tree_with_symb_def  = Define`
                                          traces_of_tree_with_symb ((Sym:(Var_t -> bool)),(P:('SPpred -> bool)),(tr:((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))) ((Sym':(Var_t -> bool)),(P':('SPpred -> bool)),(tr':((sbir_event, real, (bir_var_t, bir_exp_t) symb_interpret_t) stree))) = {e| (symbolic_tree_multi_transitions_with_symb (Sym,P,tr) e (Sym',P',tr'))}`;

val _ = export_theory();

