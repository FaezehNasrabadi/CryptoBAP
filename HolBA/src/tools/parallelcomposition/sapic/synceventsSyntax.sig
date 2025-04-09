signature synceventsSyntax =
sig
    include Abbrev

val mk_sync_event_ty : hol_type -> hol_type -> hol_type
val dest_sync_event_ty : hol_type -> hol_type * hol_type
val is_sync_event_ty : hol_type -> bool
val P2A_tm : term
val dest_P2A : term -> term
val is_P2A : term -> bool
val mk_P2A : term -> term
val A2P_tm : term
val dest_A2P : term -> term
val is_A2P : term -> bool
val mk_A2P : term -> term
val Sync_Fr_tm : term
val dest_Sync_Fr : term -> term
val is_Sync_Fr : term -> bool
val mk_Sync_Fr : term -> term
val Crypto_tm : term
val dest_Crypto : term -> term
val is_Crypto : term -> bool
val mk_Crypto :  term -> term
			 

end
