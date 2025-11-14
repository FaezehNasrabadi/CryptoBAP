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
val Equ_tm : term
val dest_Equ : term -> term
val is_Equ : term -> bool
val mk_Equ : term -> term
val DYnsyc_event_ty : hol_type
val Alias_tm : term
val dest_Alias : term -> term
val is_Alias : term -> bool
val mk_Alias : term -> term
val DYstate_ty : hol_type
val ESt_tm : term
val is_ESt : term -> bool			       

end
