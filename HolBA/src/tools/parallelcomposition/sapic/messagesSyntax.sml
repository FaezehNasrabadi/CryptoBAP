structure messagesSyntax :> messagesSyntax =
struct

open HolKernel boolLib liteLib simpLib Parse bossLib;
open stringSyntax intSyntax;
open messagesTheory;

val ERR = mk_HOL_ERR "messagesSyntax"
val wrap_exn = Feedback.wrap_exn "messagesSyntax"
	       
fun syntax_fns n d m = HolKernel.syntax_fns {n = n, dest = d, make = m} "messages"

fun syntax_fns0 s = let val (tm, _, _, is_f) = syntax_fns 0
   (fn tm1 => fn e => fn tm2 =>
       if Term.same_const tm1 tm2 then () else raise e)
   (fn tm => fn () => tm) s in (tm, is_f) end;

val syntax_fns1 = syntax_fns 1 HolKernel.dest_monop HolKernel.mk_monop;
val syntax_fns2 = syntax_fns 2 HolKernel.dest_binop HolKernel.mk_binop;

    
(* NameTag_t *)

val NameTag_t_ty = mk_type ("NameTag_t", []);

val (FreshName_tm, is_FreshName) = syntax_fns0 "FreshName";
val (PubName_tm,   is_PubName)   = syntax_fns0 "PubName";
val (NodeName_tm,  is_NodeName)  = syntax_fns0 "NodeName";
    
(* Name_t *)   

val Name_t_ty = mk_type ("Name_t", []);

val (Name_tm, mk_Name, dest_Name, is_Name) = syntax_fns2 "Name";
    
(* Var_t *)

val Var_t_ty = mk_type ("Var_t", []);

val (Var_tm, mk_Var, dest_Var, is_Var) = syntax_fns2 "Var";

(* Privacy_t *)    
val Privacy_t_ty = mk_type ("Privacy_t", []);

val (Private_tm,  is_Private)  = syntax_fns0 "Private";
val (Public_tm,   is_Public)   = syntax_fns0 "Public";

    
(* Constructability_t *)

val Constructability_t_ty = mk_type ("Constructability_t", []);

val (Constructor_tm,  is_Constructor)  = syntax_fns0 "Constructor";
val (Destructor_tm,   is_Destructor)   = syntax_fns0 "Destructor";

(***************)
(* SapicTerm_t *)
(***************)

val SapicTerm_t_ty = mk_type ("SapicTerm_t", []);

val (Con_tm,  mk_Con,  dest_Con,  is_Con)  = syntax_fns1 "Con";
val (TVar_tm, mk_TVar, dest_TVar, is_TVar) = syntax_fns1 "TVar";
val (FAPP_tm, mk_FAPP, dest_FAPP, is_FAPP) = syntax_fns2 "FAPP";

end
