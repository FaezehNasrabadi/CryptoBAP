signature sapicplusSyntax =
sig
    include Abbrev

val FactTag_t_ty : hol_type
val FreshFact_tm : term
val is_FreshFact : term -> bool
val OutFact_tm : term
val is_OutFact : term -> bool
val InFact_tm  : term
val is_InFact  : term -> bool		    
val KUFact_tm  : term
val is_KUFact  : term -> bool
val KDFact_tm  : term
val is_KDFact  : term -> bool
val DedFact_tm  : term
val is_DedFact  : term -> bool
val TermFact_tm  : term
val is_TermFact  : term -> bool
val SapicFact_t_ty  : hol_type
val Fact_tm  : term
val dest_Fact  : term -> term * term
val is_Fact  : term -> bool
val mk_Fact  : term * term -> term
val SapicAction_t_ty  : hol_type
val Rep_tm  : term
val is_Rep  : term -> bool
val New_tm  : term
val dest_New  : term -> term
val is_New  : term -> bool
val mk_New  : term -> term
val ChIn_tm : term
val dest_ChIn : term -> term * term
val is_ChIn  : term -> bool
val mk_ChIn  : term * term -> term
val ChOut_tm  : term
val dest_ChOut  : term -> term * term
val is_ChOut  : term -> bool
val mk_ChOut  : term * term -> term
val Event_tm  : term
val dest_Event  : term -> term
val is_Event  : term -> bool
val mk_Event : term -> term
val Insert_tm  : term
val dest_Insert  : term -> term * term
val is_Insert : term -> bool
val mk_Insert : term * term -> term
val Delete_tm  : term
val dest_Delete : term -> term
val is_Delete : term -> bool
val mk_Delete : term -> term
val Lock_tm  : term
val dest_Lock : term -> term
val is_Lock : term -> bool
val mk_Lock : term -> term
val Unlock_tm  : term
val dest_Unlock : term -> term
val is_Unlock : term -> bool
val mk_Unlock : term -> term
val ProcessCombinator_t_ty  : hol_type
val Parallel_tm  : term
val is_Parallel : term -> bool
val NDC_tm  : term
val is_NDC : term -> bool
val CondEq_tm  : term
val dest_CondEq : term -> term * term
val is_CondEq : term -> bool
val mk_CondEq : term * term -> term
val Cond_tm  : term
val dest_Cond : term -> term
val is_Cond : term -> bool
val mk_Cond : term -> term
val Lookup_tm  : term
val dest_Lookup : term -> term * term
val is_Lookup : term -> bool
val mk_Lookup : term * term -> term
val Let_tm  : term
val dest_Let : term -> term * term
val is_Let : term -> bool
val mk_Let : term * term -> term
val ProcessCall_tm  : term
val dest_ProcessCall : term -> term * term
val is_ProcessCall : term -> bool
val mk_ProcessCall : term * term -> term
val Process_t_ty  : hol_type
val ProcessNull_tm  : term
val is_ProcessNull : term -> bool
val ProcessComb_tm  : term
val dest_ProcessComb : term -> term * term * term
val is_ProcessComb : term -> bool
val mk_ProcessComb : term * term * term -> term
val ProcessAction_tm  : term
val dest_ProcessAction : term -> term * term
val is_ProcessAction : term -> bool
val mk_ProcessAction : term * term -> term
val sapic_substitution_t_ty  : hol_type
val Substitution_tm  : term
val dest_Substitution : term -> term
val is_Substitution : term -> bool
val mk_Substitution : term -> term
val sapic_state_t_ty   : hol_type
val State_tm  : term
val dest_State : term -> term
val is_State : term -> bool
val mk_State : term -> term
val sapic_configuration_t_ty  : hol_type
val dest_Config  : term -> term
val is_Config    : term -> bool
val mk_Config    : term -> term
val sapic_lts_t_ty  : hol_type
val LTS_tm   : term
val dest_LTS  : term -> term
val is_LTS  : term -> bool
val mk_LTS  : term -> term			       

end
