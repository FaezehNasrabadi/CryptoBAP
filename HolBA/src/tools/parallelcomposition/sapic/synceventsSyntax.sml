structure synceventsSyntax :> synceventsSyntax =
struct

open HolKernel boolLib liteLib simpLib Parse bossLib;
open synceventsTheory;

val ERR = mk_HOL_ERR "synceventsSyntax"
val wrap_exn = Feedback.wrap_exn "synceventsSyntax"
	       
fun syntax_fns n d m = HolKernel.syntax_fns {n = n, dest = d, make = m} "syncevents"

val syntax_fns1 = syntax_fns 1 HolKernel.dest_monop HolKernel.mk_monop;
    

(* sync_event *)

fun mk_sync_event_ty ty1 ty2 = mk_type ("sync_event", [ty1,ty2]);

fun dest_sync_event_ty ty =
   case total dest_thy_type ty
    of SOME {Tyop="sync_event", Thy="syncevents", Args=[ty1,ty2]} => (ty1,ty2)
     | other => raise ERR "dest_sync_event_ty" ""

val is_sync_event_ty = can dest_sync_event_ty;

val (P2A_tm,  mk_P2A,  dest_P2A,  is_P2A)  = syntax_fns1 "P2A";
val (A2P_tm, mk_A2P, dest_A2P, is_A2P) = syntax_fns1 "A2P";
val (Sync_Fr_tm, mk_Sync_Fr, dest_Sync_Fr, is_Sync_Fr) = syntax_fns1 "Sync_Fr";



end
