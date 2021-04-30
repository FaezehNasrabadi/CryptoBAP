structure bir_symbexec_treeLib =
struct

local
    open HolKernel Parse boolLib pairLib hol88Lib numLib reduceLib tautLib
		   pairTheory numTheory prim_recTheory arithmeticTheory
		   realTheory Ho_Rewrite jrhUtils Canon_Port AC numSyntax Arbint;
    open String;
    open bitstringSyntax;
    open imlLib;
    open List;
    open bir_immSyntax;
    open bir_symbexec_stepLib;
    open commonBalrobScriptLib;
    open bir_symbexec_oracleLib;
    open bir_symbexec_stateLib;
    open bir_symbexec_funcLib;
    open bir_symbexec_coreLib;
    open Int;
    open Redblackmap;
    open Redblackset;	 
    val ERR = Feedback.mk_HOL_ERR "bir_symbexec_treeLib"

in

(*Collect path names*)
fun path_to_names [] Pred_Names =
    (Pred_Names)
  | path_to_names (pred::preds) Pred_Names =
    let
	val pred_name = (fst o bir_envSyntax.dest_BVar_string) pred;

	val Pred_Names = pred_name::Pred_Names;
    in
	path_to_names preds Pred_Names
    end; 

(*Collect all path names*)
fun symb_execs_preds [] All_preds =
        (All_preds)
  | symb_execs_preds (exec_st::exec_sts) All_preds =
    let
	val preds = SYST_get_pred exec_st;

	val pred_names = path_to_names preds [];

	val All_preds = pred_names@All_preds;

    in	
	symb_execs_preds exec_sts All_preds
    end;


(*Remove repeated path names*)
fun Remove_Repeated_preds (pred::[]) No_Repeat =
        (No_Repeat)
  | Remove_Repeated_preds (pred::preds) (No_Repeat: string list) =
    let
	val hd_pr = hd(preds); 
	val No_Repeat = if (pred = hd_pr)
			then No_Repeat
			else hd_pr::No_Repeat;
    in	
	Remove_Repeated_preds (preds) No_Repeat
    end;


(*Sort and refine path names*)
fun get_refine_preds_list exec_sts =
    let
	val all_preds = symb_execs_preds exec_sts [];

	val sort_preds =  sort (fn x => fn y => ((Option.valOf o Int.fromString) x) < ((Option.valOf o Int.fromString) y)) all_preds;

	val refine_preds = Remove_Repeated_preds sort_preds [hd sort_preds];
  
    in
	refine_preds
    end;
    

(*Collect all symbolic value*)
fun symb_execs_vals_term [] All_vals =
        (All_vals)
  | symb_execs_vals_term (exec_st::exec_sts) All_vals =
    let
	val vals = SYST_get_vals exec_st;

	val vals_list = Redblackmap.listItems vals;

	val All_vals = vals_list@All_vals;

    in	
	symb_execs_vals_term exec_sts All_vals
    end;


(*Find bir expression*)
fun find_be_val vals_list bv =
    let
	val find_val = List.find (fn (a,_) => Term.term_eq a bv) vals_list;
    in
	(snd o Option.valOf) find_val
    end;
  
(*Find the latest library output*)
fun find_latest_T exec_sts preds =
    let
	val syst_preds = get_refine_preds_list exec_sts;

	val previous_preds = drop(syst_preds, (length preds));
	    
	val (preds_keep, preds_removed) = List.partition (String.isSuffix "T") previous_preds;

    in
	hd(preds_keep)
    end;
    
(*Translate knowledge to IML out*)
fun K_to_Out exec_sts pred preds =
    let
	val t_pred = find_latest_T exec_sts preds;

	val vals_list = symb_execs_vals_term exec_sts [];

	val t_term = bir_envSyntax.mk_BVar_string(t_pred, “BType_Bool”);
	    
	val t_be = symbval_bexp (find_be_val vals_list t_term);

	val pred_term = bir_envSyntax.mk_BVar_string(pred, “BType_Bool”);    

	val k_be =  symbval_bexp (find_be_val vals_list pred_term);

	val result = if (Term.term_eq t_be k_be) then (to_string (I_Out [(Var (term_to_string k_be))]))
		     else ();

    in
	result
    end;

(*Translate deduce to IML in*)
fun D_to_In pred_name = (I_In [pred_name]);
    
(*Translate fresh to IML new*)
fun Fr_to_New pred_name = (I_New (pred_name, N(64)));    

(*Translate branch true to IML True*)
fun Br_True pred_name = (I_True (Var pred_name));

(*Translate assume to IML event*)
fun assume_to_event pred_name = (I_Event pred_name);    

(*Translate paths to IML*)
fun path_of_tree exec_sts [] =
    ()
  | path_of_tree exec_sts (pred::preds) =
    let

	val Act = if (String.isSuffix "assert_true_cnd" pred) then ()
		  else if (String.isSuffix "cjmp_true_cnd" pred) then (((to_string o Br_True) pred); (path_of_tree exec_sts [((hd o tl) preds)]); (to_string (I_False ())))
		  else if (String.isSuffix "assert_false_cnd" pred) then (((to_string o Br_True) pred); ((to_string o assume_to_event) "bad"); (to_string (I_False ())))
		  else if (String.isSuffix "cjmp_false_cnd" pred) then ()
		  else if (String.isSuffix "Key" pred) then (to_string o Fr_to_New) pred
		  else if (String.isSuffix "iv" pred) then (to_string o Fr_to_New) pred
		  else if (String.isSuffix "K" pred) then (K_to_Out exec_sts pred preds)
		  else if (String.isSuffix "Adv" pred) then (to_string o D_to_In) pred
		  else ();
	    
    in
	if (String.isSuffix "cjmp_false_cnd" pred)
	then path_of_tree exec_sts (tl preds)
	else path_of_tree exec_sts preds
    end;


(*Translate symbolic execution states to IML*)
fun sym_exe_to_IML exec_sts =
    let
	val refine_preds = get_refine_preds_list exec_sts;
    in
	path_of_tree exec_sts (rev refine_preds)
    end;
    

end(*local*)

end (* struct *)

