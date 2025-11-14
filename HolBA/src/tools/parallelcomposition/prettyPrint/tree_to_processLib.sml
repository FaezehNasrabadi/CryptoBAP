structure tree_to_processLib =
struct

val simplification = ref false;

val cryptography = ref false;
    
local

    open HolKernel Parse
    open optionSyntax;
    open bir_envSyntax;
    open bir_programSyntax;
    open bir_valuesSyntax;
    open bir_immSyntax;
    open bir_expSyntax;
    open sapicplusTheory;
    open sapicplusSyntax;
    open translate_to_sapicTheory;
    open translate_to_sapicLib;
    open messagesTheory;
    open messagesSyntax;
    open bir_symbexec_treeLib;
    open bir_symbexec_funcLib;
    open bir_exp_immSyntax;
    open bir_symbexec_stateLib;
    val ERR      = Feedback.mk_HOL_ERR "tree_to_processLib"

    open sbir_treeLib;
in

(* val name = "22_RK_IChannel"; *)
fun ignore_num name = (stringSyntax.fromMLstring o implode o fst o (bir_auxiliaryLib.list_split_pred #"_") o snd o (bir_auxiliaryLib.list_split_pred #"_") o explode) name;

fun sapic_term_to_var str =
    let
	val namestr = stringSyntax.fromMLstring str;
	val trm = (mk_Var (namestr,“0:int”));
    in
	trm
    end;
 
	  
fun sapic_term_to_name trm =
    if (is_TVar trm)
    then (mk_Name (FreshName_tm, ((fst o dest_Var o dest_TVar) trm)))
    else if (is_Con trm)
    then (dest_Con trm)
    else  (mk_Name (PubName_tm, “"0"”))

fun read_events pred =
    let
	val event_names = bir_symbexec_oracleLib.read_fun_names "Event-Names";
	val pred_name = if (String.isSuffix "event_false_cnd" pred) then ("bad"^" "^(hd(event_names)))
			else if ((String.isSuffix "event_true_cnd" pred) orelse (String.isSuffix "event1" pred))
			then (List.nth (event_names, 1))
			else if (String.isSuffix "event2" pred)
			then (List.nth (event_names, 2))
			else if (String.isSuffix "event3" pred)
			then (List.nth (event_names, 3))
			else raise ERR "read_events" "cannot handle this pred";
	val namestr = stringSyntax.fromMLstring pred_name;
	val trm = mk_TVar (mk_Var (namestr,“0:int”));
    in
	trm
    end;
(*
val vals_lis = [];
val pred_be = “BExp_Den (BVar "994_R0" (BType_Imm Bit64))”*)    
fun bir_exp_symbvar_to_symbval vals_lis pred_be =
    (if (is_BExp_Const pred_be) then pred_be
    else if (is_BExp_Den pred_be) then
	(let
	     val be =  bir_symbexec_funcLib.symbval_bexp (bir_symbexec_treeLib.find_be_val vals_lis (dest_BExp_Den pred_be));

	 in
	     bir_exp_symbvar_to_symbval vals_lis be
	 end) handle e => pred_be
    else if (is_BExp_Cast pred_be) then
	let
	    val (castt, subexp, sz) = (dest_BExp_Cast) pred_be;
	in
	    mk_BExp_Cast(castt, (bir_exp_symbvar_to_symbval vals_lis subexp), sz)
	end
    else if (is_BExp_UnaryExp pred_be) then
	let
	    val (uop, subexp) = (dest_BExp_UnaryExp) pred_be;
	in
	    mk_BExp_UnaryExp(uop, (bir_exp_symbvar_to_symbval vals_lis subexp))
	end
    else if (is_BExp_BinExp pred_be) then
	let
	    val (bop, subexp1, subexp2) = (dest_BExp_BinExp) pred_be;
	in
	    mk_BExp_BinExp(bop, (bir_exp_symbvar_to_symbval vals_lis subexp1), (bir_exp_symbvar_to_symbval vals_lis subexp2))
	end
    else if (is_BExp_BinPred pred_be) then
	let 
	    val (bop, subexp1, subexp2) = (dest_BExp_BinPred) pred_be;
	in
	    mk_BExp_BinPred(bop, (bir_exp_symbvar_to_symbval vals_lis subexp1), (bir_exp_symbvar_to_symbval vals_lis subexp2))
	end
    else if (is_BExp_Load pred_be) then
	let
	    val (subexp1, subexp2, litend, bt) = (dest_BExp_Load) pred_be;
	in
	    mk_BExp_Load((bir_exp_symbvar_to_symbval vals_lis subexp1), (bir_exp_symbvar_to_symbval vals_lis subexp2), litend, bt)
	end	 
    else if (is_BExp_Store pred_be) then
	let
	    val (subexp1, subexp2, litend, subexp3) = (dest_BExp_Store) pred_be;
	in
	    mk_BExp_Store((bir_exp_symbvar_to_symbval vals_lis subexp1), (bir_exp_symbvar_to_symbval vals_lis subexp2), litend, (bir_exp_symbvar_to_symbval vals_lis subexp3))
	end
    else if (bir_bool_expSyntax.is_bir_exp_false pred_be) then (``BExp_Const (Imm1 0w)``)
    else if (bir_bool_expSyntax.is_bir_exp_true pred_be) then (``BExp_Const (Imm1 1w)``)			     
    else if (is_BExp_IfThenElse pred_be) then
	let
	    val  (subexp1, subexp2, subexp3) = (dest_BExp_IfThenElse) pred_be;
	in
	    mk_BExp_IfThenElse((bir_exp_symbvar_to_symbval vals_lis subexp1), (bir_exp_symbvar_to_symbval vals_lis subexp2), (bir_exp_symbvar_to_symbval vals_lis subexp3))
	end	
    else if (is_BExp_MemConst pred_be) then pred_be
    else if (is_BExp_MemEq pred_be) then
	let
	    val (subexp1, subexp2) = (dest_BExp_MemEq) pred_be;
	in
	    mk_BExp_MemEq((bir_exp_symbvar_to_symbval vals_lis subexp1), (bir_exp_symbvar_to_symbval vals_lis subexp2))
	end
    else pred_be) handle _ => raise ERR "bir_exp_symbvar_to_symbval" ("cannot do it "^(term_to_string pred_be));
	 

fun head_of tree = case tree of
			VLeaf => raise ERR "head_of" ("it is leaf")
		      | VBranch ((a,b),lstr,rstr)  =>  (a,b)
		      | VNode ((a,b),str)  =>  (a,b)
	
fun tail_of tree = case tree of
			VLeaf => raise ERR "tail_of" ("it is leaf")
		      | VBranch ((a,b),lstr,rstr)  =>  raise ERR "tail_of" ("it is branch")
		      | VNode ((a,b),str)  =>  str

fun is_leaf tree = case tree of
			VLeaf => true
		      | _ =>  false					       
					       
fun sbir_tree_sapic_process sort_vals tree =
    case tree of
	VLeaf => ProcessNull_tm
      | VBranch ((a,b),lstr,rstr)  => 
	let		
	    val be =  ( if (is_BExp_Den b)
			then bir_symbexec_funcLib.symbval_bexp (bir_symbexec_treeLib.find_be_val sort_vals (dest_BExp_Den b))
			else b ) handle _ => b;
	in
	    if (((is_BExp_BinExp be) orelse
		      (is_BExp_BinPred be) orelse
		      (is_BExp_MemEq be) orelse
		      (is_BExp_Cast be) orelse
		      (is_BExp_Const be) orelse
		      (is_BExp_MemConst be) orelse
		      (is_BExp_Den be) orelse
		      (is_BExp_IfThenElse be) orelse
		      (is_BExp_Load be) orelse
		      (is_BExp_Store be) orelse
		      (is_BExp_UnaryExp be)
		     ) andalso (!cryptography))
	    then if (is_leaf lstr) then	(sbir_tree_sapic_process sort_vals rstr)
		else if  (is_leaf rstr) then (sbir_tree_sapic_process sort_vals lstr)
		else if (is_BExp_BinPred be) then
		let 
		    val (bop, subexp1, subexp2) = (dest_BExp_BinPred) be;	
		in
		    if (is_BIExp_Equal bop)
		    then mk_ProcessComb ((mk_CondEq ((fst(bir_exp_to_sapic_term subexp1)),(fst(bir_exp_to_sapic_term subexp2)))),(sbir_tree_sapic_process sort_vals lstr),(sbir_tree_sapic_process sort_vals rstr))
		    else if ((is_BIExp_SignedLessThan bop) andalso (identical subexp2 ``BExp_Const (Imm32 0w)``))
		    then ( if ((String.isSuffix "tgt_true_cnd" ((fst o dest_BVar_string o fst o head_of) rstr)) orelse (String.isSuffix "tgt_false_cnd" ((fst o dest_BVar_string o fst o head_of) rstr)))
			   then (sbir_tree_sapic_process sort_vals (tail_of rstr))
			   else  (sbir_tree_sapic_process sort_vals rstr)
			 ) handle _ => (sbir_tree_sapic_process sort_vals rstr)
		    else mk_ProcessComb ((mk_CondEq ((fst(bir_exp_to_sapic_term be)),(fst(bir_exp_to_sapic_term ``BExp_Const (Imm1 1w)``)))),(sbir_tree_sapic_process sort_vals lstr),(sbir_tree_sapic_process sort_vals rstr))
		end
	    else
		mk_ProcessComb ((mk_CondEq ((fst(bir_exp_to_sapic_term be)),(fst(bir_exp_to_sapic_term ``BExp_Const (Imm1 1w)``)))),(sbir_tree_sapic_process sort_vals lstr),(sbir_tree_sapic_process sort_vals rstr))
	    else if (is_BExp_BinPred be) then
		let 
		    val (bop, subexp1, subexp2) = (dest_BExp_BinPred) be;	
		in
		    if (is_BIExp_Equal bop)
		    then mk_ProcessComb ((mk_CondEq ((fst(bir_exp_to_sapic_term subexp1)),(fst(bir_exp_to_sapic_term subexp2)))),(sbir_tree_sapic_process sort_vals lstr),(sbir_tree_sapic_process sort_vals rstr))
		    else mk_ProcessComb ((mk_CondEq ((fst(bir_exp_to_sapic_term be)),(fst(bir_exp_to_sapic_term ``BExp_Const (Imm1 1w)``)))),(sbir_tree_sapic_process sort_vals lstr),(sbir_tree_sapic_process sort_vals rstr))
		end
	    else
		mk_ProcessComb ((mk_CondEq ((fst(bir_exp_to_sapic_term be)),(fst(bir_exp_to_sapic_term ``BExp_Const (Imm1 1w)``)))),(sbir_tree_sapic_process sort_vals lstr),(sbir_tree_sapic_process sort_vals rstr))
	end
      | VNode ((a,b),str)  =>  (
	let
	    val (name,bir_type) = dest_BVar a;
	    val namestr = stringSyntax.fromHOLstring name;
	in
	    if ((String.isSuffix "assert_true_cnd" namestr) orelse(String.isSuffix "T" namestr) orelse (String.isSuffix "init_pred" namestr) orelse (String.isSuffix "assert_false_cnd" namestr) orelse (String.isSuffix "cjmp_false_cnd" namestr)  orelse (String.isSuffix "ProcState_V" namestr) orelse (String.isSuffix "ProcState_N" namestr) orelse (String.isSuffix "ProcState_C" namestr) orelse (String.isSuffix "ProcState_V*" namestr) orelse (String.isSuffix "ProcState_N*" namestr) orelse (String.isSuffix "ProcState_C*" namestr) orelse (String.isSuffix "RepEnd" namestr) orelse (String.isSuffix "R30" namestr))
	    then (if (not (!simplification))
		    then (mk_ProcessComb(mk_Let ((fst(bir_exp_to_sapic_term (mk_BExp_Den a))),(fst(bir_exp_to_sapic_term b))),(sbir_tree_sapic_process sort_vals str),(ProcessNull_tm)))
		    else (sbir_tree_sapic_process sort_vals str))
	    else if ((String.isSuffix "Key" namestr) orelse (String.isSuffix "iv" namestr) orelse (String.isSuffix "pkP" namestr) orelse (String.isSuffix "skS" namestr) orelse (String.isSuffix "RAND_NUM" namestr) orelse  (String.isSuffix "MSG" namestr)  orelse  (String.isSuffix "MASTER_KEY" namestr)  orelse (String.isSuffix "OTP" namestr) orelse (String.isSuffix "SKey" namestr)  orelse (String.isSuffix "Epriv_i" namestr)  orelse (String.isSuffix "Epriv_r" namestr) orelse (String.isSuffix "sid_i" namestr)  orelse (String.isSuffix "sid_r" namestr) )
	    then  (mk_ProcessAction ((mk_New ((sapic_term_to_name o fst o bir_exp_to_sapic_term) b)),(mk_ProcessComb(mk_Let ((fst(bir_exp_to_sapic_term (mk_BExp_Den a))),((mk_Con o sapic_term_to_name o fst o bir_exp_to_sapic_term) b)),(sbir_tree_sapic_process sort_vals str),(ProcessNull_tm)))))
	    else if ((String.isSuffix "K" namestr) orelse (String.isSuffix "Kr" namestr))
	    then (mk_ProcessAction ((mk_ChOut (mk_some(mk_TVar(mk_Var(“"att"”,“0:int”))),(fst(bir_exp_to_sapic_term b)))),(sbir_tree_sapic_process sort_vals str)))
	    else if (String.isSuffix "Rep" namestr)
	    then (mk_ProcessAction (Rep_tm,(sbir_tree_sapic_process sort_vals str)))
	    else if (String.isSuffix "Adv" namestr)
	    then (mk_ProcessAction ((mk_ChIn (mk_some(mk_TVar(mk_Var(“"att"”,“0:int”))),(fst(bir_exp_to_sapic_term b)))),(sbir_tree_sapic_process sort_vals str)))
	    else if (String.isSuffix "IChannel" namestr)
	    then (mk_ProcessAction ((mk_ChIn (mk_some(mk_TVar(mk_Var((ignore_num namestr),“0:int”))),(fst(bir_exp_to_sapic_term b)))),(sbir_tree_sapic_process sort_vals str)))
	    else if (String.isSuffix "OChannel" namestr)
	    then (mk_ProcessAction ((mk_ChOut (mk_some(mk_TVar(mk_Var((ignore_num namestr),“0:int”))),(fst(bir_exp_to_sapic_term b)))),(sbir_tree_sapic_process sort_vals str)))
	    else if ((String.isSuffix "event_true_cnd" namestr) orelse (String.isSuffix "event1" namestr) orelse (String.isSuffix "event2" namestr) orelse (String.isSuffix "event3" namestr) orelse (String.isSuffix "event_false_cnd" namestr))
	    then (mk_ProcessAction ((mk_Event (mk_Fact(TermFact_tm,(listSyntax.mk_list ([(fst(bir_exp_to_sapic_term b))],SapicTerm_t_ty))))),(sbir_tree_sapic_process sort_vals str)))
	    else if (is_BExp_Cast b) then (sbir_tree_sapic_process sort_vals str)
	    else if (String.isSuffix "observe_exp" namestr)
	    then (if (not (!simplification))
		    then (mk_ProcessAction ((mk_ChOut (mk_some(mk_TVar(mk_Var(“"att"”,“0:int”))),(fst(bir_exp_to_sapic_term b)))),(sbir_tree_sapic_process sort_vals str)))
		    else (sbir_tree_sapic_process sort_vals str))	
	    else if ((String.isSuffix "tgt_true_cnd" namestr) orelse (String.isSuffix "tgt_false_cnd" namestr) orelse (String.isSuffix "observe_cnd" namestr))
	    then (mk_ProcessAction ((mk_ChOut (mk_some(mk_TVar(mk_Var(“"att"”,“0:int”))),(fst(bir_exp_to_sapic_term b)))),(sbir_tree_sapic_process sort_vals str)))
	    else if (((is_BExp_BinExp b) orelse
		      (is_BExp_BinPred b) orelse
		      (is_BExp_MemEq b) orelse
		      (is_BExp_Cast b) orelse
		      (is_BExp_Const b) orelse
		      (is_BExp_MemConst b) orelse
		      (is_BExp_Den b) orelse
		      (is_BExp_IfThenElse b) orelse
		      (is_BExp_Load b) orelse
		      (is_BExp_Store b) orelse
		      (is_BExp_UnaryExp b)
		     ) andalso (!cryptography))
	    then(sbir_tree_sapic_process sort_vals str)
	    else (mk_ProcessComb(mk_Let ((fst(bir_exp_to_sapic_term (mk_BExp_Den a))),(fst(bir_exp_to_sapic_term b))),(sbir_tree_sapic_process sort_vals str),(ProcessNull_tm)))
	end)
			     

end(*local*)

end (* struct *)
