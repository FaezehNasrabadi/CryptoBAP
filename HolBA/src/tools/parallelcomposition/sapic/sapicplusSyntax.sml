structure sapicplusSyntax :> sapicplusSyntax =
struct

open HolKernel boolLib liteLib simpLib Parse bossLib;
open stringSyntax intSyntax;
open messagesSyntax;
open sapicplusTheory;

val ERR = mk_HOL_ERR "sapicplusSyntax"
val wrap_exn = Feedback.wrap_exn "sapicplusSyntax"
	       
fun syntax_fns n d m = HolKernel.syntax_fns {n = n, dest = d, make = m} "sapicplus"

fun syntax_fns0 s = let val (tm, _, _, is_f) = syntax_fns 0
   (fn tm1 => fn e => fn tm2 =>
       if Term.same_const tm1 tm2 then () else raise e)
   (fn tm => fn () => tm) s in (tm, is_f) end;

val syntax_fns1 = syntax_fns 1 HolKernel.dest_monop HolKernel.mk_monop;
val syntax_fns2 = syntax_fns 2 HolKernel.dest_binop HolKernel.mk_binop;
val syntax_fns3 = syntax_fns 3 HolKernel.dest_triop HolKernel.mk_triop;
    
(* FactTag_t *)

val FactTag_t_ty = mk_type ("FactTag_t", []);

val (FreshFact_tm, is_FreshFact) = syntax_fns0 "FreshFact";
val (OutFact_tm,   is_OutFact)   = syntax_fns0 "OutFact";
val (InFact_tm,    is_InFact)    = syntax_fns0 "InFact";
val (KUFact_tm,    is_KUFact)    = syntax_fns0 "KUFact";
val (KDFact_tm,    is_KDFact)    = syntax_fns0 "KDFact";
val (DedFact_tm,   is_DedFact)   = syntax_fns0 "DedFact";
val (TermFact_tm,  is_TermFact)  = syntax_fns0 "TermFact";
    
(* SapicFact_t *)   

val SapicFact_t_ty = mk_type ("SapicFact_t", []);

val (Fact_tm, mk_Fact, dest_Fact, is_Fact) = syntax_fns2 "Fact";
    
    
(* SapicAction_t *)

val SapicAction_t_ty = mk_type ("SapicAction_t", []);

val (Rep_tm,    is_Rep) = syntax_fns0 "Rep";
val (New_tm,    mk_New,    dest_New,    is_New)    = syntax_fns1 "New";
val (ChIn_tm,   mk_ChIn,   dest_ChIn,   is_ChIn)   = syntax_fns2 "ChIn";
val (ChOut_tm,  mk_ChOut,  dest_ChOut,  is_ChOut)  = syntax_fns2 "ChOut";
val (Event_tm,  mk_Event,  dest_Event,  is_Event)  = syntax_fns1 "Event";
val (Insert_tm, mk_Insert, dest_Insert, is_Insert) = syntax_fns2 "Insert";
val (Delete_tm, mk_Delete, dest_Delete, is_Delete) = syntax_fns1 "Delete";
val (Lock_tm,   mk_Lock,   dest_Lock,   is_Lock)   = syntax_fns1 "Lock";
val (Unlock_tm, mk_Unlock, dest_Unlock, is_Unlock) = syntax_fns1 "Unlock";

(* ProcessCombinator_t *)
    
val ProcessCombinator_t_ty = mk_type ("ProcessCombinator_t", []);

val (Parallel_tm,    is_Parallel)                                         = syntax_fns0 "Parallel";
val (NDC_tm,         is_NDC)                                              = syntax_fns0 "NDC";
val (CondEq_tm,      mk_CondEq,       dest_CondEq,       is_CondEq)       = syntax_fns2 "CondEq";
val (Cond_tm,        mk_Cond,         dest_Cond,         is_Cond)         = syntax_fns1 "Cond";
val (Lookup_tm,      mk_Lookup,       dest_Lookup,       is_Lookup)       = syntax_fns2 "Lookup";
val (Let_tm,         mk_Let,          dest_Let,          is_Let)          = syntax_fns2 "Let";
val (ProcessCall_tm, mk_ProcessCall,  dest_ProcessCall,  is_ProcessCall)  = syntax_fns2 "ProcessCall";
    
(* Process_t *)

val Process_t_ty = mk_type ("Process_t", []);

val (ProcessNull_tm,   is_ProcessNull)                                         = syntax_fns0 "ProcessNull";
val (ProcessComb_tm,   mk_ProcessComb,   dest_ProcessComb,   is_ProcessComb)   = syntax_fns3 "ProcessComb";
val (ProcessAction_tm, mk_ProcessAction, dest_ProcessAction, is_ProcessAction) = syntax_fns2 "ProcessAction";


(* sapic_substitution_t *)

val sapic_substitution_t_ty = mk_type ("sapic_substitution_t", []);

val (Substitution_tm,  mk_Substitution,  dest_Substitution,  is_Substitution)  = syntax_fns1 "Substitution";

    
(* sapic_state_t *)
    
val sapic_state_t_ty = mk_type ("sapic_state_t", []);
    
val (State_tm, mk_State, dest_State, is_State) = syntax_fns1 "State";

    
(* sapic_configuration_t *)
    
val sapic_configuration_t_ty = mk_type ("sapic_configuration_t", []);
    
val (Config_tm, mk_Config, dest_Config, is_Config) = syntax_fns1 "Config";

    
(* sapic_lts_t *)
    
val sapic_lts_t_ty = mk_type ("sapic_lts_t", []);
    
val (LTS_tm, mk_LTS, dest_LTS, is_LTS) = syntax_fns1 "LTS";

end
