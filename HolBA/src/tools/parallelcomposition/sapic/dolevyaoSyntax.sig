signature dolevyaoSyntax =
sig
    include Abbrev

val DYpred_ty : hol_type
val K_tm : term
val dest_K : term -> term
val is_K : term -> bool
val mk_K : term -> term
val Fr_tm : term
val dest_Fr : term -> term
val is_Fr : term -> bool
val mk_Fr : term -> term
val DotEqu_tm : term
val dest_DotEqu : term -> term
val is_DotEqu : term -> bool
val mk_DotEqu : term -> term
val AliEqu_tm : term
val dest_AliEqu : term -> term
val is_AliEqu : term -> bool
val mk_AliEqu : term -> term
val DYnsyc_event_ty : hol_type
val Alias_tm : term
val dest_Alias : term -> term
val is_Alias : term -> bool
val mk_Alias : term -> term
val DYstate_ty : hol_type
val ESt_tm : term
val is_ESt : term -> bool			       

end
