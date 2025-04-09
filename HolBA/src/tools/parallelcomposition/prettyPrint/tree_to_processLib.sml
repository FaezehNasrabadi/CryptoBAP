structure tree_to_processLib =
struct

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
	let
	     val be =  bir_symbexec_funcLib.symbval_bexp (bir_symbexec_treeLib.find_be_val vals_lis (dest_BExp_Den pred_be));

	     (* val _ = print "\n"; *)
	     (* val _ = print (term_to_string be); *)
	     (* val _ = print "\n"; *)

	 in
	     (bir_exp_symbvar_to_symbval vals_lis be) handle e => be
	 end
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
    else pred_be) handle _ => pred_be;(*raise ERR "bir_exp_symbvar_to_symbval" ("cannot do it "^(term_to_string pred_be));*)
	 

fun simpleholset_to_list t =
  if pred_setSyntax.is_empty t then [] else
  if not (pred_setSyntax.is_insert t) then
    raise ERR "simpleholset_to_list" ("cannot handle syntax: " ^ (term_to_string t))
  else
    let val (x, rset) = pred_setSyntax.dest_insert t in
      x::(simpleholset_to_list rset)
    end;

fun vars_to_outs vars proc =
    case vars of
	([]: term list) => proc
      | h::t => (mk_ProcessAction ((mk_ChOut (mk_none(SapicTerm_t_ty),(fst(bir_exp_to_sapic_term h)))),(vars_to_outs t proc)))
	
    
fun sbir_tree_sapic_process sort_vals tree =
    case tree of
	VLeaf => ProcessNull_tm
      | VBranch ((a,b),lstr,rstr)  => mk_ProcessComb (NDC_tm,(sbir_tree_sapic_process sort_vals lstr),(sbir_tree_sapic_process sort_vals rstr))
      | VNode ((a,b),str)  =>  (
	let
	    val (name,bir_type) = dest_BVar a;
	    val namestr = stringSyntax.fromHOLstring name;
	in
	    if ((String.isSuffix "assert_true_cnd" namestr) orelse(String.isSuffix "T" namestr) orelse (String.isSuffix "init_pred" namestr) orelse (String.isSuffix "assert_false_cnd" namestr) orelse (String.isSuffix "cjmp_false_cnd" namestr) orelse (String.isSuffix "MEM" namestr) orelse (String.isSuffix "ProcState_Z" namestr) orelse (String.isSuffix "ProcState_V" namestr) orelse (String.isSuffix "ProcState_N" namestr) orelse (String.isSuffix "ProcState_C" namestr) orelse (String.isSuffix "RepEnd" namestr) orelse (String.isSuffix "R30" namestr))
	    then (sbir_tree_sapic_process sort_vals str)
	    else if ((String.isSuffix "comp_true_cnd" namestr) orelse (String.isSuffix "cjmp_true_cnd" namestr))
	    then  mk_ProcessComb (NDC_tm,(sbir_tree_sapic_process sort_vals str),(ProcessNull_tm))
		(*let
		    val be = (bir_exp_symbvar_to_symbval sort_vals b);
		    val _ = print "\n";
		    val _ = print (term_to_string be);
		    val _ = print "\n";
		in
		    mk_ProcessComb ((mk_Cond (fst(bir_exp_to_sapic_term be))),(sbir_tree_sapic_process sort_vals str),(ProcessNull_tm))
		end*)
	    else if ((String.isSuffix "Key" namestr) orelse (String.isSuffix "iv" namestr) orelse (String.isSuffix "pkP" namestr) orelse (String.isSuffix "skS" namestr) orelse (String.isSuffix "RAND_NUM" namestr) orelse (String.isSuffix "OTP" namestr) orelse (String.isSuffix "SKey" namestr)  orelse (String.isSuffix "Epriv_i" namestr)  orelse (String.isSuffix "Epriv_r" namestr) orelse (String.isSuffix "sid_i" namestr)  orelse (String.isSuffix "sid_r" namestr) )
	    then  (mk_ProcessAction ((mk_New ((sapic_term_to_name o fst o bir_exp_to_sapic_term) b)),(mk_ProcessComb(mk_Let ((fst(bir_exp_to_sapic_term (mk_BExp_Den a))),((mk_Con o sapic_term_to_name o fst o bir_exp_to_sapic_term) b)),(sbir_tree_sapic_process sort_vals str),(ProcessNull_tm)))))
	    else if ((String.isSuffix "K" namestr) orelse (String.isSuffix "Kr" namestr))
	    then
		let
		    val be = (bir_exp_symbvar_to_symbval sort_vals (mk_BExp_Den b));
		    (* val _ = print "\n"; *)
		    (* val _ = print (term_to_string be); *)
		    (* val _ = print "\n"; *)
		in
		    if (identical be (mk_BExp_Den b)) then (mk_ProcessAction ((mk_ChOut (mk_none(SapicTerm_t_ty),(fst(bir_exp_to_sapic_term b)))),(sbir_tree_sapic_process sort_vals str)))
		    else let
			    val exp_vars = (snd o dest_eq o concl o EVAL) ``(bir_vars_of_exp ^be)``;
			    val vars = (simpleholset_to_list) exp_vars;
			in	
			    (mk_ProcessAction ((mk_ChOut (mk_none(SapicTerm_t_ty),(fst(bir_exp_to_sapic_term b)))),(vars_to_outs vars (sbir_tree_sapic_process sort_vals str))))
			end
		end
	    else if (String.isSuffix "Rep" namestr)
	    then (mk_ProcessAction (Rep_tm,(sbir_tree_sapic_process sort_vals str)))
	    else if (String.isSuffix "Adv" namestr)
	    then (mk_ProcessAction ((mk_ChIn (mk_none(SapicTerm_t_ty),(fst(bir_exp_to_sapic_term b)))),(sbir_tree_sapic_process sort_vals str)))
	    else if ((String.isSuffix "event_true_cnd" namestr) orelse (String.isSuffix "event1" namestr) orelse (String.isSuffix "event2" namestr) orelse (String.isSuffix "event3" namestr) orelse (String.isSuffix "event_false_cnd" namestr))
	    then (mk_ProcessAction ((mk_Event (mk_Fact(TermFact_tm,(listSyntax.mk_list ([(read_events namestr)],SapicTerm_t_ty))))),(sbir_tree_sapic_process sort_vals str)))	 
	    else if ((is_BExp_Cast b) orelse (is_BExp_Load b) orelse (is_BExp_Store b))
	    then (sbir_tree_sapic_process sort_vals str)
	    else (mk_ProcessComb(mk_Let ((fst(bir_exp_to_sapic_term (mk_BExp_Den a))),(fst(bir_exp_to_sapic_term b))),(sbir_tree_sapic_process sort_vals str),(ProcessNull_tm)))
end)
			 
(*val be = ``
	       (BExp_Store
		    (BExp_Load (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
			  (BExp_Den (BVar "R1" (BType_Imm Bit64)))
				       BEnd_LittleEndian Bit64)
		    (BExp_Den (BVar "ADDR1" (BType_Imm Bit64)))
		    BEnd_BigEndian
		    (BExp_Const (Imm128 (42w :word128))))
	       ``;*)

end(*local*)

end (* struct *)
