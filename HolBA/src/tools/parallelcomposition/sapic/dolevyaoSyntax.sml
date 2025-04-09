structure dolevyaoSyntax :> dolevyaoSyntax =
struct

open HolKernel boolLib liteLib simpLib Parse bossLib;
open stringSyntax intSyntax;
open messagesSyntax;
open dolevyaoTheory;

val ERR = mk_HOL_ERR "dolevyaoSyntax"
val wrap_exn = Feedback.wrap_exn "dolevyaoSyntax"
	       
fun syntax_fns n d m = HolKernel.syntax_fns {n = n, dest = d, make = m} "dolevyao"

fun syntax_fns0 s = let val (tm, _, _, is_f) = syntax_fns 0
   (fn tm1 => fn e => fn tm2 =>
       if Term.same_const tm1 tm2 then () else raise e)
   (fn tm => fn () => tm) s in (tm, is_f) end;

val syntax_fns1 = syntax_fns 1 HolKernel.dest_monop HolKernel.mk_monop;

    
(* DYpred *)

val DYpred_ty = mk_type ("DYpred", []);

val (K_tm, mk_K, dest_K, is_K) = syntax_fns1 "K";
val (Fr_tm,   mk_Fr,   dest_Fr,   is_Fr)   = syntax_fns1 "Fr";
val (DotEqu_tm, mk_DotEqu, dest_DotEqu, is_DotEqu) = syntax_fns1 "DotEqu";
val (AliEqu_tm, mk_AliEqu, dest_AliEqu, is_AliEqu) = syntax_fns1 "AliEqu";

    
(* DYnsyc_event *)   

val DYnsyc_event_ty = mk_type ("DYnsyc_event", []);

val (Alias_tm, mk_Alias, dest_Alias, is_Alias) = syntax_fns1 "Alias";

    
(* DYstate *)
    
val DYstate_ty = mk_type ("DYstate", []);
    
val (ESt_tm, is_ESt) = syntax_fns0 "ESt";

end
