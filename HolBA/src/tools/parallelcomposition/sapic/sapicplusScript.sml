open HolKernel Parse boolLib bossLib;
open bagTheory;
open messagesTheory;
open synceventsTheory;
open dolevyaoTheory;

val _ = new_theory "sapicplus";

(* Sapicplus Syntax *)


(* Sapic predicates *)
val _ = Datatype `SPpred =
SP_Equ (SapicTerm_t # SapicTerm_t) (* both terms *)
| Undef
      `;
    
(* Sapic deduction relation *)
val (SPdeduction_rules, SPdeduction_ind, SPdeduction_cases)
= Hol_reln
  `(∀(p:SPpred) (Pi: SPpred set). (p ∈ Pi) ==> (SPdeduction Pi p)) ∧
(∀(t1:SapicTerm_t) (t2:SapicTerm_t) (Pi: SPpred set). (eqE t1 t2) ==> (SPdeduction Pi (SP_Equ (t1,t2)))) 
`;

        
(* Facts *)
   
val _ = Datatype `FactTag_t =
FreshFact  
| OutFact   
| InFact     
| KUFact     
| KDFact     
| DedFact  
| TermFact`;


val _ = Datatype `SapicFact_t = Fact FactTag_t (SapicTerm_t list)`;


val sapicFact_substname_def = Define`
                                    (sapicFact_substname x y (Fact tag ts) = (Fact tag (MAP (sapic_substname x y) ts)))`;

val sapicFact_substvar_def = Define`
                                   (sapicFact_substvar x y (Fact tag ts) = (Fact tag (MAP (sapic_substvar x y) ts)))`;                                        
                                   
(* Action *)

val _ = Datatype `SapicAction_t =
Rep
| New     Name_t
| ChIn    (SapicTerm_t option) SapicTerm_t
| ChOut   (SapicTerm_t option) SapicTerm_t
| Event   SapicFact_t
| Insert  SapicTerm_t SapicTerm_t
| Delete  SapicTerm_t
| Lock    SapicTerm_t
| Unlock  SapicTerm_t`;



val sapicAction_substname_def =
Define`
      (sapicAction_substname x y a = (case a of
                                        (Rep) => Rep
                                      | (New n) => New (messages$name_subst x y n)
                                      | (ChIn (SOME t1) t2) => ChIn (SOME (sapic_substname x y t1)) (sapic_substname x y t2)
                                      | (ChOut (SOME t1) t2) => ChOut (SOME (sapic_substname x y t1)) (sapic_substname x y t2)
                                      | (ChIn (NONE) t) => ChIn NONE (sapic_substname x y t)
                                      | (ChOut (NONE) t) => ChOut NONE (sapic_substname x y t)
                                      | (Event f) => Event (sapicFact_substname x y f)
                                      | (Insert t1 t2) => Insert (sapic_substname x y t1) (sapic_substname x y t2)
		                      | (Delete t) => Delete (sapic_substname x y t)
		                      | (Lock t) => Lock (sapic_substname x y t)
		                      | (Unlock t) => Unlock (sapic_substname x y t)
                                     ))`;
      

val sapicAction_substvar_def =
Define`
      (sapicAction_substvar x y a = (case a of
                                       (Rep) => Rep
                                     | (New n) => New n
                                     | (ChIn (SOME t1) t2) => ChIn (SOME (sapic_substvar x y t1)) (sapic_substvar x y t2)
                                     | (ChOut (SOME t1) t2) => ChOut (SOME (sapic_substvar x y t1)) (sapic_substvar x y t2)
                                     | (ChIn (NONE) t) => ChIn NONE (sapic_substvar x y t)
                                     | (ChOut (NONE) t) => ChOut NONE (sapic_substvar x y t)
                                     | (Event f) => Event (sapicFact_substvar x y f)
                                     | (Insert t1 t2) => Insert (sapic_substvar x y t1) (sapic_substvar x y t2)
		                     | (Delete t) => Delete (sapic_substvar x y t)
		                     | (Lock t) => Lock (sapic_substvar x y t)
		                     | (Unlock t) => Unlock (sapic_substvar x y t)
                                    ))`;
      
(* Processes *)

val _ = Datatype `ProcessCombinator_t =
Parallel
| NDC
| CondEq       SapicTerm_t SapicTerm_t
| Cond         SapicTerm_t
| Lookup       SapicTerm_t Var_t
| Let          SapicTerm_t SapicTerm_t
| ProcessCall  string (SapicTerm_t list)`;



val processCombinator_substname_def =
Define`
      (processCombinator_substname x y c = (case c of
                                              Parallel           => Parallel
		                            | NDC                => NDC
		                            | (CondEq t1 t2)     => CondEq (sapic_substname x y t1) (sapic_substname x y t2)
                                            | (Cond t)           => Cond (sapic_substname x y t)
		                            | (Lookup t v)       => Lookup (sapic_substname x y t) v
		                            | (Let t1 t2)        => Let (sapic_substname x y t1) (sapic_substname x y t2)
		                            | (ProcessCall s ts) => ProcessCall s (MAP (sapic_substname x y) ts)
                                           ))`;

val processCombinator_substvar_def =
Define`
      (processCombinator_substvar x y c = (case c of
                                             Parallel           => Parallel
		                           | NDC                => NDC
		                           | (CondEq t1 t2)     => CondEq (sapic_substvar x y t1) (sapic_substvar x y t2)
                                           | (Cond t)           => Cond (sapic_substvar x y t)
		                           | (Lookup t v)       => Lookup (sapic_substvar x y t) v
		                           | (Let t1 t2)        => Let (sapic_substvar x y t1) (sapic_substvar x y t2)
		                           | (ProcessCall s ts) => ProcessCall s (MAP (sapic_substvar x y) ts)
                                          ))`;
      

val _ = Datatype `Process_t =
ProcessNull
|   ProcessComb    ProcessCombinator_t Process_t Process_t
|   ProcessAction  SapicAction_t Process_t`;        


val process_substname_def =
Define`
      (process_substname x y p = (case p of
                                    ProcessNull           => ProcessNull
                                  |   (ProcessComb c p1 p2) => ProcessComb (processCombinator_substname x y c) (process_substname x y p1) (process_substname x y p2)
                                  |   (ProcessAction  a p')  => ProcessAction (sapicAction_substname x y a) (process_substname x y p')
                                                                              
                                 ))`;

val process_substvar_def =
Define`
      (process_substvar x y p = (case p of
                                   ProcessNull           => ProcessNull
                                 |   (ProcessComb c p1 p2) => ProcessComb (processCombinator_substvar x y c) (process_substvar x y p1) (process_substvar x y p2)
                                 |   (ProcessAction  a p')  => ProcessAction (sapicAction_substvar x y a) (process_substvar x y p')
                                                                             
                                ))`;
      
(* Substitution *)

val _ = Datatype `sapic_substitution_t =
Substitution (Var_t -> (SapicTerm_t option))
             `;    

val sapic_substitution_get_def = Define `
                                        sapic_substitution_get (Substitution Sb) symb = Sb symb
                                                                                           `;

val sapic_substitution_dom_def = Define `
                                        sapic_substitution_dom (Substitution S) = {vars | S vars <> NONE}
                                                                                  `;
val sapic_substitution_update_def = Define `
                                           sapic_substitution_update (Substitution S) (symb, vo) = Substitution ((symb =+ vo) S)
                                                                                                                `;
val substitvn_to_term_def =
Define`
      (substitvn_to_term (Substitution S) (Con n)  = (Con n)) ∧
(substitvn_to_term (Substitution S) (TVar v) = (if (v ∈ sapic_substitution_dom (Substitution S)) then (THE (S v)) else (TVar v)))`;


val substitfun_to_term_def =
Define`
      (substitfun_to_term (Substitution S) (FAPP n' ts) = (FAPP n' (MAP (substitvn_to_term (Substitution S)) ts)))`;


val substitution_to_term_def = Define`
                                     (substitution_to_term (Substitution S) t = (case t of
                                                                                   (FAPP n ts) => substitfun_to_term (Substitution S) (FAPP n ts)
                                                                                 | _ =>  substitvn_to_term (Substitution S) _                                                            
                                                                                ))
                                     `;


(* Renaming *)

val _ = Datatype `sapic_renaming_t =
Renaming (Var_t -> (SapicTerm_t option))
         `;    

val sapic_renaming_get_def = Define `
                                    sapic_renaming_get (Renaming Sb) symb = Sb symb
                                                                               `;

val sapic_renaming_dom_def = Define `
                                    sapic_renaming_dom (Renaming S) = {vars | S vars <> NONE}
                                                                      `;                                        
val sapic_renaming_update_def = Define `
                                       sapic_renaming_update (Renaming S) (symb, vo) = Renaming ((symb =+ vo) S)
                                                                                                `;

val sapic_renaming_extend_def = Define `
                                       sapic_renaming_extend H_extra H_base =
(Renaming (\symb.
             if symb IN (sapic_renaming_dom H_base) then
               sapic_renaming_get H_base symb
             else
               sapic_renaming_get H_extra symb))
`;


(* Renaming Names *)

val _ = Datatype `sapic_name_renaming_t =
NameRenaming (Name_t -> (SapicTerm_t option))
             `;    

val sapic_name_renaming_get_def = Define `
                                         sapic_name_renaming_get (NameRenaming Sb) symb = Sb symb
                                                                                             `;

val sapic_name_renaming_dom_def = Define `
                                         sapic_name_renaming_dom (NameRenaming S) = {vars | S vars <> NONE}
                                                                                    `;                                        
val sapic_name_renaming_update_def = Define `
                                            sapic_name_renaming_update (NameRenaming S) (symb, vo) = NameRenaming ((symb =+ vo) S)
                                                                                                                  `;

val sapic_name_renaming_extend_def = Define `
                                            sapic_name_renaming_extend H_extra H_base =
(NameRenaming (\symb.
                 if symb IN (sapic_name_renaming_dom H_base) then
                   sapic_name_renaming_get H_base symb
                 else
                   sapic_name_renaming_get H_extra symb))
`;


(* State *)  
val _ = Datatype `sapic_state_t =
State (SapicTerm_t -> (SapicTerm_t option))
      `;      
      

(* Configuration *)

val _ = Datatype `sapic_configuration_t =
Config ((Name_t set) # sapic_state_t # (Process_t multiset) # sapic_substitution_t # (SapicTerm_t set))
       `;       
       

val get_substitution_conf_def = Define `
                                       get_substitution_conf (Config (Ns,St,Pold,Sb,Al)) = Sb
                                                                                           `;

                                                                                           
(* Labeled Transition System *)      
val _ = Datatype `sapic_lts_t =
LTS (sapic_configuration_t -> (SapicFact_t list)  -> sapic_configuration_t -> bool)
    `;


(* Sapic Semantics*)

(* Null rule *)
val sapic_null_transition_def = Define `
                                       sapic_null_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps.
   (Pold = (BAG_UNION Ps {|ProcessNull|})) /\
   (Pnew = Ps) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;                        


(* Parallel rule *)
val sapic_parallel_transition_def = Define `
                                           sapic_parallel_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P Q.
   (Pold = (BAG_UNION Ps {|ProcessComb Parallel P Q|})) /\
   (Pnew = (BAG_UNION (BAG_UNION Ps {|P|}) {|Q|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;

              
(* Replication rule *)
val sapic_replication_transition_def = Define `
                                              sapic_replication_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P.
   (Pold = (BAG_UNION Ps {|ProcessAction Rep P|})) /\
   (Pnew = (BAG_UNION (BAG_UNION Ps {|P|}) {|ProcessAction Rep P|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;
              
(* Event rule *)
val sapic_event_transition_def = Define `
                                        sapic_event_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P Fc.
   (Pold = (BAG_UNION Ps {|ProcessAction (Event Fc) P|})) /\
   (Pnew = (BAG_UNION Ps {|P|})) /\
   (Ev = [Fc]) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;


val _ = Theory.new_constant("termholds", ``:SapicTerm_t -> bool``);

(* Conditional true rule *)
val sapic_conditional_true_transition_def = Define `
                                                   sapic_conditional_true_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P Q t.
   (Pold = (BAG_UNION Ps {|ProcessComb (Cond t) P Q|})) /\
   (termholds t) /\
   (Pnew = (BAG_UNION Ps {|P|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;
              

(* Conditional false rule *)
val sapic_conditional_false_transition_def = Define `
                                                    sapic_conditional_false_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P Q t.
   (Pold = (BAG_UNION Ps {|ProcessComb (Cond t) P Q|})) /\
   (¬(termholds t)) /\
   (Pnew = (BAG_UNION Ps {|Q|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`; 
              
(* Conditional eq true rule *)
val sapic_conditional_eq_true_transition_def = Define `
                                                      sapic_conditional_eq_true_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P Q t1 t2.
   (Pold = (BAG_UNION Ps {|ProcessComb (CondEq t1 t2) P Q|})) /\
   (t1 = t2) /\
   (Pnew = (BAG_UNION Ps {|P|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;
              

(* Conditional eq false rule *)
val sapic_conditional_eq_false_transition_def = Define `
                                                       sapic_conditional_eq_false_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P Q t1 t2.
   (Pold = (BAG_UNION Ps {|ProcessComb (CondEq t1 t2) P Q|})) /\
   (t1 ≠ t2) /\
   (Pnew = (BAG_UNION Ps {|Q|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;                                        


(* Delete rule *)
val sapic_delete_transition_def = Define `
                                         sapic_delete_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P S t.
   (Pold = (BAG_UNION Ps {|ProcessAction (Delete t) P|})) /\
   (Pnew = (BAG_UNION Ps {|P|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = State S) /\
   (St' = State ((t =+ NONE) S)) /\
   (Sb = Sb') /\
   (Al = Al'))`;

              
(* Insert rule *)
val sapic_insert_transition_def = Define `
                                         sapic_insert_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P S t1 t2.
   (Pold = (BAG_UNION Ps {|ProcessAction (Insert t1 t2) P|})) /\
   (Pnew = (BAG_UNION Ps {|P|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = State S) /\
   (St' = State ((t1 =+ SOME t2) S)) /\
   (Sb = Sb') /\
   (Al = Al'))`;


(* Lock rule *)
val sapic_lock_transition_def = Define `
                                       sapic_lock_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P t.
   (Pold = (BAG_UNION Ps {|ProcessAction (Lock t) P|})) /\
   (Pnew = (BAG_UNION Ps {|P|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (t NOTIN Al) /\
   (Al' = (t INSERT Al) ))`;



(* Unlock rule *)
val sapic_unlock_transition_def = Define `
                                         sapic_unlock_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∀t'.∃Ps P t.
       (Pold = (BAG_UNION Ps {|ProcessAction (Unlock t) P|})) /\
       (Pnew = (BAG_UNION Ps {|P|})) /\
       (Ev = []) /\
       (Ns = Ns') /\
       (St = St') /\
       (Sb = Sb') /\
       (t = t') ∧
       (Al' = (Al DELETE t') ))`;                                



(* Lookup false rule *)
val sapic_lookup_false_transition_def = Define `
                                               sapic_lookup_false_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∀t'.∃Ps P Q S t x.
       (Pold = (BAG_UNION Ps {|ProcessComb (Lookup t x) P Q|})) /\
       (Pnew = (BAG_UNION Ps {|Q|})) /\
       (Ev = []) /\
       (Ns = Ns') /\
       (St = State S) ∧
       (t = t') ∧
       (S t' = NONE) ∧
       (St = St') /\
       (Sb = Sb') /\
       (Al' = Al))`;

                  
(* Lookup true rule *)
val sapic_lookup_true_transition_def = Define `
                                              sapic_lookup_true_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P Q S t t' u x.
   (Pold = (BAG_UNION Ps {|ProcessComb (Lookup t x) P Q|})) /\
   (Pnew = (BAG_UNION Ps {|(process_substvar x u P)|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = State S) ∧
   (t = t') ∧
   (S t' = (SOME u)) ∧
   (St = St') /\
   (Sb = Sb') /\
   (Al' = Al))`;

              
(* New rule *)
val sapic_new_transition_def = Define `
                                      sapic_new_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P N N' n'.
   (Pold = (BAG_UNION Ps {|ProcessAction (New N) P|})) /\
   (Pnew = (BAG_UNION Ps {|(process_substname N (Con N') P)|})) /\
   (Ev = []) /\
   (N' = Name FreshName n') /\
   (N' NOTIN Ns) /\	
   (Ns' = (N' INSERT Ns)) /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;   


(* K rule *)
val sapic_K_transition_def = Define `
                                    sapic_K_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃R t.
   (Pold = Pnew) /\
   (t = substitution_to_term Sb R) /\
   (Ev = [(Fact KUFact [t])]) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;

              
(* In rule *)
val sapic_in_transition_def = Define `
                                     sapic_in_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P t x R R'.
   (Pold = (BAG_UNION Ps {|ProcessAction (ChIn (SOME t) (TVar x)) P|})) /\
   (Pnew = (BAG_UNION Ps {|(process_substvar x (substitution_to_term Sb R') P)|})) /\
   (Ev = [(Fact InFact [R;R']);(Fact KUFact [t;(substitution_to_term Sb R')])]) /\
   (is_ground_term (substitution_to_term Sb R')) /\
   (t = (substitution_to_term Sb R)) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;   

              
(* Out rule *)
val sapic_out_transition_def = Define `
                                      sapic_out_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P t1 t2 n R S.
   (Pold = (BAG_UNION Ps {|ProcessAction (ChOut (SOME t1) t2) P|})) /\
   (Pnew = (BAG_UNION Ps {|P|})) /\
   (Ev = [(Fact OutFact [R]);(Fact KUFact [t1])]) /\
   (is_ground_term t2) /\
   (t1 = (substitution_to_term Sb R)) /\
   (n = (((int_of_num o list$LENGTH o list$SET_TO_LIST o sapic_substitution_dom) Sb)+1)) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Substitution S) /\
   (Sb' = Substitution (((Var "att" n) =+ (SOME t2)) S)) /\
   (Al = Al'))`; 


(* Out-In rule *)
val sapic_out_in_transition_def = Define `
                                         sapic_out_in_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P t t1 t2 x.
   (Pold = (BAG_UNION Ps {|ProcessAction (ChOut (SOME t1) t2) (ProcessAction (ChIn (SOME t) (TVar x)) P)|})) /\
   (Pnew = (BAG_UNION Ps {|(process_substvar x t2 P)|})) /\
   (Ev = []) /\
   (is_ground_term t2) /\
   (t = t1) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;


(* Let true rule *)
val sapic_let_true_transition_def = Define `
                                           sapic_let_true_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P Q t1 t2.
   (Pold = (BAG_UNION Ps {|ProcessComb (Let t1 t2) P Q|})) /\
   (t1 = t2) /\
   (Pnew = (BAG_UNION Ps {|P|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`;
              

(* Let false rule *)
val sapic_let_false_transition_def = Define `
                                            sapic_let_false_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pnew,Sb',Al')) =
(∃Ps P Q t1 t2.
   (Pold = (BAG_UNION Ps {|ProcessComb (Let t1 t2) P Q|})) /\
   (t1 ≠ t2) /\
   (Pnew = (BAG_UNION Ps {|Q|})) /\
   (Ev = []) /\
   (Ns = Ns') /\
   (St = St') /\
   (Sb = Sb') /\
   (Al = Al'))`; 


              
(* Transition relation *)
val sapic_transition_def = Define `
                                  (sapic_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')) =
                                   (∃Ps Pn.
                                      if ((Ns = Ns')∧(St = St')∧(Pold = Pold')∧(Sb = Sb')∧(Al = Al')∧(Ev = []))
                                      then (T)
                                      else
                                        (Pold = (BAG_UNION Ps {|Pn|})) ∧ (case Pn of
                                                                            (ProcessNull) => (sapic_null_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessComb Parallel P Q) => (sapic_parallel_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessAction Rep P) => (sapic_replication_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessAction (Event Fc) P) => (sapic_event_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessComb (Cond t) P Q) => ((sapic_conditional_true_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al'))) ∨ (sapic_conditional_false_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al'))))
                                                                          | (ProcessComb (CondEq t1 t2) P Q) => ((sapic_conditional_eq_true_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al'))) ∨ (sapic_conditional_eq_false_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al'))))
                                                                          | (ProcessAction (Delete t) P) => (sapic_delete_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessAction (Insert t1 t2) P) => (sapic_insert_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessAction (Lock t) P) => (sapic_lock_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessAction (Unlock t) P) => (sapic_unlock_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessComb (Lookup t x) P Q) => ((sapic_lookup_false_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al'))) ∨ (sapic_lookup_true_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al'))))
                                                                          | (ProcessAction (ChIn (SOME t) (TVar x)) P) => (sapic_in_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessAction (ChOut (SOME t1) t2) P) => (sapic_out_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessAction (ChOut (SOME t1) t2) (ProcessAction (ChIn (SOME t) (TVar x)) P)) => (sapic_out_in_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                          | (ProcessComb (Let t1 t2) P Q) => ((sapic_let_true_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al'))) ∨ (sapic_let_false_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al'))))
                                                                          | (ProcessAction (New N) P) => (sapic_new_transition (Config (Ns,St,Pold,Sb,Al)) Ev (Config (Ns',St',Pold',Sb',Al')))
                                                                                                         
                                                                         )))`;
                                  

                                  
(* Detect a silent transition *)
val is_a_silent_transition_def = Define `
                                        is_a_silent_transition (Config (Ns,St,Ps,Sb,Al)) Ev (Config (Ns',St',Ps',Sb',Al')) =
(case Ev of
   [] => T
 | _  => F)
`;


(* Sapic Semantics with position *)
val _ = Theory.new_constant("apply", ``:Process_t -> sapic_renaming_t -> Process_t``);
val _ = Theory.new_constant("position", ``:Process_t -> real -> Process_t``);
val _ = Theory.new_constant("applyName", ``:Process_t -> sapic_name_renaming_t -> Process_t``);

val _ = Datatype `sapic_position_configuration_t =
Pconfig (Process_t # real # sapic_renaming_t # sapic_name_renaming_t)
        `;

val PConfigEq = new_axiom ("PConfigEq",
                           ``∀p r re nre p' r' re' nre'. (Pconfig (p,r,re,nre) = Pconfig (p',r',re',nre')) ⇒ ((r = r')∧(p = p')∧(re = re')∧(nre = nre'))``);                


(* Replication rule *)
val sapic_position_replication_transition_def = Define `
                                                       sapic_position_replication_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P t.
   (Pro = ProcessAction Rep P) /\
   (Pro' = P) /\
   (Ev = (Fact TermFact [t])) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;

                
(* Event rule *)
val sapic_position_event_transition_def = Define `
                                                 sapic_position_event_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P Fc t.
   (Pro = ProcessAction (Event Fc) P) /\
   (Pro' = P) /\
   (Fc = (Fact TermFact [t])) /\
   (Ev = Fc) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;

(* NDC *)
val sapic_position_ndc_transition_def = Define `
                                               sapic_position_ndc_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P Q t.
   (Pro = (ProcessComb NDC P Q)) /\
   ((Pro' = P) ∨ (Pro' = Q)) /\
   (Ev = (Fact TermFact [t])) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;
                
(* Conditional true rule *)
val sapic_position_conditional_true_transition_def = Define `
                                                            sapic_position_conditional_true_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P Q e t1 t2.
   (Pro = (ProcessComb (CondEq t1 t2) P Q)) /\
   (Pro' = P) /\
   (eqE t1 t2) /\
   (Ev = (Fact TermFact [e])) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;
                

(* Conditional false rule *)
val sapic_position_conditional_false_transition_def = Define `
                                                             sapic_position_conditional_false_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P Q e t1 t2.
   (Pro = (ProcessComb (CondEq t1 t2) P Q)) /\
   (Pro' = Q) /\
   (¬(eqE t1 t2)) /\
   (Ev = (Fact TermFact [e])) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;

                
(* New rule *)
val sapic_position_new_transition_def = Define `
                                               sapic_position_new_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P N.
   (Pro = ProcessAction (New N) P) /\
   (Pro' = P) /\
   (Ev = (Fact FreshFact [(Con N)])) /\
   (NRe' = (sapic_name_renaming_update NRe (N, SOME (Con N)))) /\
   (i' = i+1) /\
   (Re' = (sapic_renaming_update Re ((Var "RNG" 0), SOME (Con N)))))`;
                                                                    
(* K rule *)
val sapic_position_k_transition_def = Define `
                                             sapic_position_k_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃t.
   (Pro' = Pro) /\
   (Ev = (Fact KUFact [t])) /\
   (Re' = (sapic_renaming_update Re ((Var "Adv" 0), SOME (t)))) /\
   (i' = i+1) /\
   (NRe = NRe'))`;
                
(* In rule *)
val sapic_position_in_transition_def = Define `
                                              sapic_position_in_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P t x.
   (Pro = ProcessAction (ChIn (SOME t) (TVar x)) P) /\
   (Pro' = P) /\
   (Ev = (Fact InFact [(TVar x)])) /\
   (Re' = (sapic_renaming_update Re ((Var "Adv" 0), SOME (TVar x)))) /\
   (i' = i+1) /\
   (NRe = NRe'))`;   

                
(* Out rule *)
val sapic_position_out_transition_def = Define `
                                               sapic_position_out_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P t1 t2.
   (Pro = ProcessAction (ChOut (SOME t1) t2) P) /\
   (Pro' = P) /\
   (Ev = (Fact OutFact [t2])) /\
   (Re' = Re) /\
   (i' = i+1) /\
   (NRe = NRe'))`; 

                
(* Let true rule *)
val sapic_position_let_true_transition_def = Define `
                                                    sapic_position_let_true_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P Q t1 t2.
   (Pro = ProcessComb (Let t1 t2) P Q) /\
   (t1 = t2) /\
   (Ev = (Fact DedFact [t2])) /\
   (Pro' = P) /\
   (Re' = (sapic_renaming_update Re ((Var "let" 0), SOME t2))) ∧
   (i' = i+1) /\
   (NRe = NRe'))`; 
                

(* Let false rule *)

val sapic_position_let_false_transition_def = Define `
                                                     sapic_position_let_false_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) =
(∃P Q t1 t2.
   (Pro = ProcessComb (Let t1 t2) P Q) /\
   (t1 ≠ t2) /\
   (Ev = (Fact DedFact [t2])) /\
   (Pro' = P) /\
   (Re' = (sapic_renaming_update Re ((Var "let" 0), SOME t2))) ∧
   (i' = i+1) /\
   (NRe = NRe'))`; 


                
(* Transition relation *)
val sapic_position_transition_def = Define `
                                           sapic_position_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')) = (
  (case Pro of
     (ProcessAction Rep P) => (sapic_position_replication_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')))
   | (ProcessAction (Event Fc) P) => (sapic_position_event_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')))
   | (ProcessComb NDC P Q) => (sapic_position_ndc_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')))
   | (ProcessComb (CondEq t1 t2) P Q) => ((sapic_position_conditional_true_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe'))) ∨ (sapic_position_conditional_false_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe'))))
   | (ProcessAction (ChIn (SOME t) (TVar x)) P) => (sapic_position_in_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')))
   | (ProcessAction (ChOut (SOME t1) t2) P) => (sapic_position_out_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')))
   | (ProcessComb (Let t1 t2) P Q) => ((sapic_position_let_true_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe'))) ∨ (sapic_position_let_false_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe'))))
   | (ProcessAction (New N) P) => (sapic_position_new_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')))
   | _ => F

  )
  )`;

val PConfigNoStep = new_axiom ("PConfigNoStep",
                               ``∀p r re nre. (sapic_position_transition (Pconfig (p,r,re,nre)) (Fact TermFact []) (Pconfig (p,r,re,nre))) = T``);                

(* sapic_position_multi_transitions *)
Inductive sapic_position_multi_transitions:
[~nil:]
  (sapic_position_multi_transitions (Pconfig (Pro,i,Re,NRe)) [] (Pconfig (Pro,i,Re,NRe))) /\
[~move:]
  (((sapic_position_multi_transitions (Pconfig (Pro,i,Re,NRe)) ev (Pconfig (Pro'',i'',Re'',NRe'')))∧(sapic_position_transition (Pconfig (Pro'',i'',Re'',NRe'')) e (Pconfig (Pro',i',Re',NRe')))) ==> (sapic_position_multi_transitions (Pconfig (Pro,i,Re,NRe)) (e::ev) (Pconfig (Pro',i',Re',NRe'))))  
End

val sapic_position_transition_with_symb_def = Define `
                                                     (sapic_position_transition_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) NONE ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe'))) =
                                                      (((Sym = Sym') ∨ (∃y. Sym' = Sym ∪ {y})) ∧ (P = P') ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                     ) ∧
(sapic_position_transition_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) (SOME ((INL Ev):(SapicFact_t + (Name_t, Sig_t, Var_t) sync_event))) ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe'))) = (sapic_position_transition (Pconfig (Pro,i,Re,NRe)) Ev (Pconfig (Pro',i',Re',NRe')))
) ∧
(sapic_position_transition_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) (SOME ((INR Ev):(SapicFact_t + (Name_t, Sig_t, Var_t) sync_event))) ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe'))) = ((Sym = Sym') ∧ (P = P') ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
)`;            

Inductive sapic_position_multi_transitions_with_symb:
[~nil:]
  (sapic_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) [] ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe)))) /\
[~moveF:]
  (((sapic_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) ev ((Sym'':(Var_t -> bool)),(P'':(SPpred -> bool)),(Pconfig (Pro'',i'',Re'',NRe''))))∧(sapic_position_transition_with_symb ((Sym'':(Var_t -> bool)),(P'':(SPpred -> bool)),(Pconfig (Pro'',i'',Re'',NRe''))) e ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe'))))) ==> (sapic_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) (e::ev) ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe'))))) /\
[~moveB:]
  (((sapic_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) (e::ev) ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe'))))∧(sapic_position_transition_with_symb ((Sym'':(Var_t -> bool)),(P'':(SPpred -> bool)),(Pconfig (Pro'',i'',Re'',NRe''))) e ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe'))))) ==>
   (sapic_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) ev ((Sym'':(Var_t -> bool)),(P'':(SPpred -> bool)),(Pconfig (Pro'',i'',Re'',NRe'')))))
End

val sapic_position_with_symb_single = new_axiom ("sapic_position_with_symb_single",
                                                 ``∀e Sym Sym' P P' Pro Pro' NRe NRe' Re Re' i i'. (sapic_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) [e] ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe')))) = (sapic_position_transition_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) e ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe')))) ``);                


val traces_of_sapic_with_symb_def  = Define`
                                           traces_of_sapic_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe'))) = {e| (sapic_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred -> bool)),(Pconfig (Pro,i,Re,NRe))) e ((Sym':(Var_t -> bool)),(P':(SPpred -> bool)),(Pconfig (Pro',i',Re',NRe'))))}`;

val traces_of_sapic_def  = Define`
                                 traces_of_sapic (Pconfig (Pro,i,Re,NRe)) = {e| ∃Pro' i' Re' NRe'. (sapic_position_multi_transitions (Pconfig (Pro,i,Re,NRe)) e (Pconfig (Pro',i',Re',NRe')))}`;
                                                                                                                                                                                              
                                                                                                                                                                                              


val _ = Datatype `sapic_plus_position_configuration_t =
Pconfig_plus (Process_t # real # sapic_renaming_t # sapic_name_renaming_t)
             `;

val PConfigEq_plus = new_axiom ("PConfigEq_plus",
                                ``∀p r re nre p' r' re' nre'. (Pconfig_plus (p,r,re,nre) = Pconfig_plus (p',r',re',nre')) ⇒ ((r = r')∧(p = p')∧(re = re')∧(nre = nre'))``);                


(* Replication rule *)
val sapic_plus_position_replication_transition_def = Define `
                                                            sapic_plus_position_replication_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P t.
   (Pro = ProcessAction Rep P) /\
   (Pro' = P) /\
   (Ev = SOME (INL (INL (Fact TermFact [t])))) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;

                
(* Event rule *)
val sapic_plus_position_event_transition_def = Define `
                                                      sapic_plus_position_event_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P Fc t.
   (Pro = ProcessAction (Event Fc) P) /\
   (Fc = (Fact TermFact [t])) /\
   (Pro' = P) /\
   (Ev = SOME (INL (INL (Fact TermFact [t])))) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;

(* NDC *)
val sapic_plus_position_ndc_transition_def = Define `
                                               sapic_plus_position_ndc_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P Q t.
   (Pro = (ProcessComb NDC P Q)) /\
   ((Pro' = P) ∨ (Pro' = Q)) /\
   (Ev = SOME (INL (INL (Fact TermFact [t])))) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;
                        
(* Conditional true rule *)
val sapic_plus_position_conditional_true_transition_def = Define `
                                                                 sapic_plus_position_conditional_true_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P Q e t1 t2.
   (Pro = (ProcessComb (CondEq t1 t2) P Q)) /\
   (Pro' = P) /\
   (eqE t1 t2) /\
   (Ev = SOME (INL (INL (Fact TermFact [e])))) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;
                

(* Conditional false rule *)
val sapic_plus_position_conditional_false_transition_def = Define `
                                                                  sapic_plus_position_conditional_false_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P Q e t1 t2.
   (Pro = (ProcessComb (CondEq t1 t2) P Q)) /\
   (Pro' = Q) /\
   (¬(eqE t1 t2)) /\
   (Ev = SOME (INL (INL (Fact TermFact [e])))) /\
   (i' = i+1) /\
   (Re = Re') /\
   (NRe = NRe'))`;

                
(* New rule *)
val sapic_plus_position_new_transition_def = Define `
                                                    sapic_plus_position_new_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P N.
   (Pro = ProcessAction (New N) P) /\
   (Pro' = P) /\
   (Ev = SOME (INL (INL (Fact FreshFact [(Con N)])))) /\
   (NRe' = (sapic_name_renaming_update NRe (N, SOME (Con N)))) /\
   (i' = i+1) /\
   (Re' = (sapic_renaming_update Re ((Var "RNG" 0), SOME (Con N)))))`;
                                                                    
(* K rule *)
val sapic_plus_position_k_transition_def = Define `
                                                  sapic_plus_position_k_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃t.
   (Pro' = Pro) /\
   (Ev = SOME (INL (INL (Fact KUFact [t])))) /\
   (Re' = (sapic_renaming_update Re ((Var "Adv" 0), SOME t))) /\
   (i' = i+1) /\
   (NRe = NRe'))`;
                
(* In rule *)
val sapic_plus_position_in_transition_def = Define `
                                                   sapic_plus_position_in_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P t x.
   (Pro = ProcessAction (ChIn (SOME t) (TVar x)) P) /\
   (Pro' = P) /\
   (Ev = SOME (INL (INL (Fact InFact [(TVar x)])))) /\
   (Re' = (sapic_renaming_update Re ((Var "Adv" 0), SOME (TVar x)))) /\
   (i' = i+1) /\
   (NRe = NRe'))`;   

                
(* Out rule *)
val sapic_plus_position_out_transition_def = Define `
                                                    sapic_plus_position_out_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P t1 t2.
   (Pro = ProcessAction (ChOut (SOME t1) t2) P) /\
   (Pro' = P) /\
   (Ev = SOME (INL (INL (Fact OutFact [t2])))) /\
   (Re' = Re) /\
   (i' = i+1) /\
   (NRe = NRe'))`;                

(* Let true rule *)
val sapic_plus_position_let_true_transition_def = Define `
                                                         sapic_plus_position_let_true_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P Q t1 t2.
   (Pro = ProcessComb (Let t1 t2) P Q) /\
   (t1 = t2) /\
   (Ev = SOME (INL (INL (Fact DedFact [t2])))) /\
   (Pro' = P) /\
   (Re' = (sapic_renaming_update Re ((Var "let" 0), SOME t2))) ∧
   (i' = i+1) /\
   (NRe = NRe'))`; 
                

(* Let false rule *)

val sapic_plus_position_let_false_transition_def = Define `
                                                          sapic_plus_position_let_false_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')) =
(∃P Q t1 t2.
   (Pro = ProcessComb (Let t1 t2) P Q) /\
   (t1 ≠ t2) /\
   (Ev = SOME (INL (INL (Fact DedFact [t2])))) /\
   (Pro' = P) /\
   (Re' = (sapic_renaming_update Re ((Var "let" 0), SOME t2))) ∧
   (i' = i+1) /\
   (NRe = NRe'))`;

val sapic_plus_position_transition_with_symb_def = Define `
                                                          (sapic_plus_position_transition_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),((Pconfig_plus (Pro,i,Re,NRe)):sapic_plus_position_configuration_t)) (Ev:((SapicFact_t + (Name_t, Sig_t, Var_t) sync_event)+(DYnsyc_event + (Name_t, Sig_t, Var_t) sync_event)) option) ((Sym':(Var_t -> bool)),(P':(SPpred + DYpred -> bool)),((Pconfig_plus (Pro',i',Re',NRe')):sapic_plus_position_configuration_t)) =
                                                           (case Ev of
                                                              SOME (INR (INL (Alias (x,y)))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INL (Alias (x,y)))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            |  SOME (INR (INL (Ded p))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INL (Ded p))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))                                                                                                       
                                                            | SOME (INR (INR (A2P x))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INR (A2P x))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | SOME (INL (INR (A2P x))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INR (A2P x))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | SOME (INR (INR (Crypto V))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INR (Crypto V))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | SOME (INL (INR (Crypto V))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INR (Crypto V))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | SOME (INR (INR (P2A Y))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INR (P2A Y))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | SOME (INL (INR (P2A Y))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INR (P2A Y))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | SOME (INR (INR (Sync_Fr N))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INR (Sync_Fr N))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | SOME (INL (INR (Sync_Fr N))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INR (Sync_Fr N))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | SOME (INR (INL (Silent N))) => ((DYtranrel (Sym,IMAGE OUTR P,ESt) (SOME (INL (Silent N))) (Sym',IMAGE OUTR P',ESt)) ∧ (IMAGE OUTL P' = IMAGE OUTL P) ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | SOME (INL (INL (Fact OutFact [t2]))) => ((sapic_plus_position_out_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe'))) ∧ (IMAGE OUTR P' = IMAGE OUTR P) ∧ (Sym = Sym'))
                                                            | SOME (INL (INL (Fact InFact [(TVar x)]))) => ((sapic_plus_position_in_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe'))) ∧ (IMAGE OUTR P' = IMAGE OUTR P) ∧ (Sym = Sym'))             
                                                            | SOME (INL (INL (Fact DedFact [t2]))) => (((sapic_plus_position_let_false_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')))∨(sapic_plus_position_let_true_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')))) ∧ (IMAGE OUTR P' = IMAGE OUTR P) ∧ (Sym = Sym'))
                                                            | SOME (INL (INL (Fact FreshFact [(Con N)]))) => ((sapic_plus_position_new_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe'))) ∧ (IMAGE OUTR P' = IMAGE OUTR P) ∧ (Sym = Sym'))
                                                            | SOME (INL (INL (Fact TermFact [t])))  => ((IMAGE OUTR P' = IMAGE OUTR P) ∧ (Sym = Sym') ∧
                                                                                                        (case Pro of
                                                                                                           (ProcessAction Rep P) => (sapic_plus_position_replication_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')))
                                                                                                         | (ProcessAction (Event Fc) P) =>  (sapic_plus_position_event_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')))
                                                                                                         | (ProcessComb NDC P Q) => (sapic_plus_position_ndc_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe')))
                                                                                                         | (ProcessComb (CondEq t1 t2) P Q) => ((sapic_plus_position_conditional_true_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe'))) ∨ (sapic_plus_position_conditional_false_transition (Pconfig_plus (Pro,i,Re,NRe)) Ev (Pconfig_plus (Pro',i',Re',NRe'))))
                                                                                                                                                                                                        
                                                                                                         | _ => F
                                                                                                        )) 
                                                            | NONE => ((Sym = Sym') ∧ (P = P') ∧ (Pro = Pro') ∧ (i = i') ∧ (Re = Re') ∧ (NRe = NRe'))
                                                            | _ => F
                                                           )
                                                          )`;

Inductive sapic_plus_position_multi_transitions_with_symb:
[~nil:]
  (sapic_plus_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe))) [] ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe)))) /\
[~moveF:]
  (((sapic_plus_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe))) ev ((Sym'':(Var_t -> bool)),(P'':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro'',i'',Re'',NRe''))))∧(sapic_plus_position_transition_with_symb ((Sym'':(Var_t -> bool)),(P'':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro'',i'',Re'',NRe''))) e ((Sym':(Var_t -> bool)),(P':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro',i',Re',NRe'))))) ==> (sapic_plus_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe))) (e::ev) ((Sym':(Var_t -> bool)),(P':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro',i',Re',NRe'))))) /\
[~moveB:]
  ((
    (sapic_plus_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe))) (e::ev) ((Sym':(Var_t -> bool)),(P':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro',i',Re',NRe'))))
    ∧(sapic_plus_position_transition_with_symb ((Sym'':(Var_t -> bool)),(P'':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro'',i'',Re'',NRe''))) e ((Sym':(Var_t -> bool)),(P':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro',i',Re',NRe'))))) ==>
   (sapic_plus_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe))) ev ((Sym'':(Var_t -> bool)),(P'':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro'',i'',Re'',NRe''))))
  )
End

val sapic_plus_position_with_symb_single = new_axiom ("sapic_plus_position_with_symb_single",
                                                      ``∀e Sym Sym' P P' Pro Pro' NRe NRe' Re Re' i i'. (sapic_plus_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe))) [e] ((Sym':(Var_t -> bool)),(P':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro',i',Re',NRe')))) = (sapic_plus_position_transition_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe))) e ((Sym':(Var_t -> bool)),(P':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro',i',Re',NRe')))) ``);                


val sapic_plus_traces_def =
Define`
      sapic_plus_traces sapic_plus_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe))) ((Sym':(Var_t -> bool)),(P':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro',i',Re',NRe'))) =
{t|  
 (sapic_plus_position_multi_transitions_with_symb ((Sym:(Var_t -> bool)),(P:(SPpred + DYpred -> bool)),(Pconfig_plus (Pro,i,Re,NRe))) t ((Sym':(Var_t -> bool)),(P':(SPpred + DYpred -> bool)),(Pconfig_plus (Pro',i',Re',NRe'))))
}
`;

val _ = export_theory();
