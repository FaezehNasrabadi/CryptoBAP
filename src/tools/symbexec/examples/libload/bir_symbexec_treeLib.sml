structure bir_symbexec_treeLib =
struct

local
    open HolKernel Parse boolLib pairLib hol88Lib numLib reduceLib tautLib
		   pairTheory numTheory prim_recTheory arithmeticTheory
		   realTheory Ho_Rewrite jrhUtils Canon_Port AC numSyntax Arbint;
    open String;
    open boolSyntax;
    open bitstringSyntax;
    open imlLib;
    open List;
    open bir_envSyntax;
    open bir_immSyntax;
    open bir_expSyntax;
    open bir_exp_immSyntax;
    open bir_symbexec_stepLib;
    open commonBalrobScriptLib;
    open bir_symbexec_oracleLib;
    open bir_symbexec_stateLib;
    open bir_symbexec_funcLib;
    open bir_symbexec_coreLib;
    open Int;
    open Redblackmap;
    open Redblackset;
    open bitstringSyntax;
    val ERR = Feedback.mk_HOL_ERR "bir_symbexec_treeLib"

in
(*

open HolKernel Parse

open binariesLib;
open binariesTheory;
open binariesCfgLib;
open binariesMemLib;
open bir_symbexec_stateLib;
open bir_symbexec_coreLib;
open bir_symbexec_stepLib;
open bir_symbexec_sumLib;
open bir_countw_simplificationLib;
open bir_block_collectionLib;
open bir_programSyntax;
open bir_valuesSyntax;
open bir_immSyntax;
open bir_exec_typingLib;
open commonBalrobScriptLib;
open binariesDefsLib;
open bir_cfgLib;
open bir_cfg_m0Lib;
open bir_symbexec_driverLib;
open Redblackmap;
open bir_symbexec_oracleLib;

val lbl_tm = ``BL_Address (Imm64 4203840w)``;

val stop_lbl_tms = [``BL_Address (Imm64 4204220w)``];
    
val syst = init_state lbl_tm prog_vars;

val pred_conjs = [``bir_exp_true``];
    
val syst = state_add_preds "init_pred" pred_conjs syst;

val _ = print "initial state created.\n\n";

val cfb = false;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict_ prog_lbl_tms_;
  
val systs = symb_exec_to_stop (abpfun cfb) n_dict bl_dict_ [syst] stop_lbl_tms [];

val exec_sts = systs;
*)


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
(*
val all_preds =
   ["2_init_pred", "37_Key", "39_T", "42_iv", "44_T", "47_K", "46_Adv",
    "53_cjmp_true_cnd", "56_Key", "58_T", "2_init_pred", "37_Key", "39_T",
    "42_iv", "44_T", "47_K", "46_Adv", "54_cjmp_false_cnd", "61_K", "60_Adv"];

val sort_preds =
   ["2_init_pred", "2_init_pred", "37_Key", "37_Key", "39_T", "39_T",
    "42_iv", "42_iv", "44_T", "44_T", "46_Adv", "46_Adv", "47_K", "47_K",
    "53_cjmp_true_cnd", "54_cjmp_false_cnd", "56_Key", "58_T", "60_Adv",
    "61_K"];

val refine_preds =
   ["61_K", "60_Adv", "58_T", "56_Key", "54_cjmp_false_cnd",
    "53_cjmp_true_cnd", "47_K", "46_Adv", "44_T", "42_iv", "39_T", "37_Key",
    "2_init_pred"];
*)
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
(*
val All_preds =
   ["2_init_pred", "37_Key", "39_T", "42_iv", "44_T", "46_Adv", "47_K",
    "53_cjmp_true_cnd", "54_cjmp_false_cnd", "56_Key", "58_T", "60_Adv",
    "61_K"];
-----------
val pred = "47_K";
val preds = ["53_cjmp_true_cnd", "54_cjmp_false_cnd", "56_Key", "58_T", "60_Adv",
    "61_K"];
val t_pred = "44_T";
val t_term = “BVar "44_T" BType_Bool”;
val t_be = “enc inputs iv”;
val pred_term = “BVar "47_K" BType_Bool”;
val k_be = “enc inputs iv”;
val result = out(c, enc inputs iv);
-------
val pred = "61_K";
val preds = [];
val t_pred = "58_T";
val t_term = “BVar "58_T" BType_Bool”;
val t_be = “BVar "57_k" (BType_Imm Bit64)”;
val pred_term = “BVar "61_K" BType_Bool”;
val k_be = “BVar "48_a" (BType_Imm Bit64)”;
val result = ();
*)
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

   
(*Translate BIR expressions to IML expressions*)
(*
val pred_be = “BExp_Const (Imm64 2840w)”; val result = "2840";
val pred_be = “BExp_Den (BVar "88_MEM" (BType_Mem Bit64 Bit8))”;
val pred_be = ``BExp_Cast BIExp_LowCast
                        (BExp_Den (BVar "R0" (BType_Imm Bit64))) Bit32``;
val pred_be = ``BExp_UnaryExp BIExp_Not
                       (BExp_Den (BVar "ProcState_C" BType_Bool))``;
val pred_be = “BExp_BinPred BIExp_Equal
          (BExp_Cast BIExp_LowCast
             (BExp_Den (BVar "16_Adv" (BType_Imm Bit64))) Bit64)
          (BExp_Const (Imm64 0w))”;
val pred_be = ``BExp_BinExp BIExp_And
		       (BExp_BinPred BIExp_LessOrEqual
 (BExp_BinExp BIExp_Plus
  (BExp_Den (BVar "5_tmp_SP_EL0" (BType_Imm Bit64)))
(BExp_Const (Imm64 24w)))
(BExp_Const (Imm64 18446744073709551607w)))
(BExp_BinExp BIExp_Or
(BExp_BinPred BIExp_NotEqual
(BExp_BinExp BIExp_Minus
(BExp_Den (BVar "5_tmp_SP_EL0" (BType_Imm Bit64)))
(BExp_Const (Imm64 24w)))
(BExp_Const (Imm64 3489660928w)))
(BExp_BinPred BIExp_LessThan
(BExp_BinExp BIExp_Mult
(BExp_Den (BVar "5_tmp_SP_EL0" (BType_Imm Bit64)))
(BExp_Const (Imm64 24w)))
(BExp_Const (Imm64 3489660928w))))``;
*)
fun BExp_to_IMLExp exec_sts pred_be =
    let
	val result = if (is_BExp_Const pred_be) then
			 (if (is_Imm128 o dest_BExp_Const) pred_be then
			      IExp_to_string (BS ((num_to_bitlist o wordsSyntax.dest_word_literal o dest_Imm128 o dest_BExp_Const) pred_be))
			  else if (is_Imm64 o dest_BExp_Const) pred_be then
			      IExp_to_string (BS ((num_to_bitlist o wordsSyntax.dest_word_literal o dest_Imm64 o dest_BExp_Const) pred_be))
			  else if (is_Imm32 o dest_BExp_Const) pred_be then
			      IExp_to_string (BS ((num_to_bitlist o wordsSyntax.dest_word_literal o dest_Imm32 o dest_BExp_Const) pred_be))
			  else if (is_Imm16 o dest_BExp_Const) pred_be then
			      IExp_to_string (BS ((num_to_bitlist o wordsSyntax.dest_word_literal o dest_Imm16 o dest_BExp_Const) pred_be))
			  else if (is_Imm8 o dest_BExp_Const) pred_be then
			      IExp_to_string (BS ((num_to_bitlist o wordsSyntax.dest_word_literal o dest_Imm8 o dest_BExp_Const) pred_be))
			  else if (is_Imm1 o dest_BExp_Const) pred_be then
			      IExp_to_string (BS ((num_to_bitlist o wordsSyntax.dest_word_literal o dest_Imm1 o dest_BExp_Const) pred_be))
			  else raise ERR "BExp_Const:BExp_to_IMLExp" "this should not happen")
		     else if (is_BExp_Den pred_be) then
			 (if identical “BType_Bool” ((snd o dest_BVar o dest_BExp_Den) pred_be) then
			      let
				  val vals_list = symb_execs_vals_term exec_sts [];
				  val pred_be_bool = symbval_bexp (find_be_val vals_list (dest_BExp_Den pred_be));
				  
			      in
				  BExp_to_IMLExp exec_sts pred_be_bool
			      end
			  else ((fst o dest_BVar_string o dest_BExp_Den) pred_be))
		     else if (is_BExp_Cast pred_be) then
			 let
			     val (castt, subexp, sz) = (dest_BExp_Cast) pred_be;
			 in
			     BExp_to_IMLExp exec_sts subexp
			 end
		     else if (is_BExp_UnaryExp pred_be) then
			 let
			     val (uop, subexp) = (dest_BExp_UnaryExp) pred_be;
			     val res = if identical uop BIExp_Not_tm then
					   ("¬")
				       else raise ERR "BExp_UnaryExp:BExp_to_IMLExp" "this should not happen"
			 in
			     (res^"("^(BExp_to_IMLExp exec_sts subexp)^")")
			 end
		     else if (is_BExp_BinExp pred_be) then
			 let
			     val (bop, subexp1, subexp2) = (dest_BExp_BinExp) pred_be;
			     val res = if identical bop BIExp_And_tm then ("BIExp_And")
				       else if identical bop BIExp_Or_tm then ("BIExp_Or")
				       else if identical bop BIExp_Plus_tm then ("BIExp_Plus")
				       else if identical bop BIExp_Minus_tm then ("BIExp_Minus")
				       else if identical bop BIExp_Mult_tm then ("BIExp_Mult")
				       else raise ERR "BExp_BinExp:BExp_to_IMLExp" "this should not happen"
			 in
			     IExp_to_string (Ops [(Var res), (Var (BExp_to_IMLExp exec_sts subexp1)), (Var (BExp_to_IMLExp exec_sts subexp2))])
			 end
		     else if (is_BExp_BinPred pred_be) then
			 let
			     val (bop, subexp1, subexp2) = (dest_BExp_BinPred) pred_be;
			     val res = if identical bop BIExp_Equal_tm then (" = ")
				       else if identical bop BIExp_NotEqual_tm then (" <> ")
				       else if identical bop BIExp_LessThan_tm then (" < ")
				       else if identical bop BIExp_LessOrEqual_tm then (" <= ")
				       else raise ERR "BExp_BinPred:BExp_to_IMLExp" "this should not happen" 
			 in
			     ((BExp_to_IMLExp exec_sts subexp1)^res^(BExp_to_IMLExp exec_sts subexp2))
			 end
		     else if (is_BExp_IfThenElse pred_be) then raise ERR "BExp_IfThenElse:BExp_to_IMLExp" "this should not happen"
		     else if (is_BExp_MemConst pred_be) then raise ERR "BExp_MemConst:BExp_to_IMLExp" "this should not happen"
		     else if (is_BExp_MemEq pred_be) then raise ERR "BExp_MemEq:BExp_to_IMLExp" "this should not happen"
		     else if (is_BExp_Load pred_be) then raise ERR "BExp_Load:BExp_to_IMLExp" "this should not happen"
		     else if (is_BExp_Store pred_be) then raise ERR "BExp_Store:BExp_to_IMLExp" "this should not happen"
		     else raise ERR "BExp_to_IMLExp" "this should not happen";

    in
	result
    end;

(*Extract BIR expressions from pred name*)
(*
val pred = "165_assert_true_cnd";
val pred_term = “BVar "23_cjmp_true_cnd" BType_Bool”;
val pred_be = “BExp_Den (BVar "22_ProcState_Z" BType_Bool)”;
*)
   
fun IMLExp_from_pred exec_sts pred =
    let

	val vals_list = symb_execs_vals_term exec_sts [];

	val pred_term = bir_envSyntax.mk_BVar_string(pred, “BType_Bool”);
	    
	val pred_be = symbval_bexp (find_be_val vals_list pred_term);

	(*val _ = let val IFile = TextIO.openAppend "Symbolic Execution Preds Vals.txt"; in TextIO.output (IFile, (term_to_string pred_be) ^ "\n ----------------- \n" ); TextIO.flushOut IFile end;*)

	val pred_IML_Exp = BExp_to_IMLExp exec_sts pred_be;

    in
	pred_IML_Exp
    end;
    
(*Translate paths to IML*)
(*
val pred = "37_Key";
val preds = ["39_T", "42_iv", "44_T", "46_Adv", "47_K",
    "53_cjmp_true_cnd", "54_cjmp_false_cnd", "56_Key", "58_T", "60_Adv",
    "61_K"];
val Act = new 37_Key: 64;

val pred = "60_Adv";
val preds = ["61_K"];
val Act = in(c, 60_Adv);
 *)

fun path_of_tree exec_sts [] =
    ()
  | path_of_tree exec_sts (pred::preds) =
    let

	val Act = if (String.isSuffix "assert_true_cnd" pred) then ()
		  else if (String.isSuffix "cjmp_true_cnd" pred) then (((to_string o Br_True) (IMLExp_from_pred exec_sts pred)); (if (List.length preds = 1) then () else ((path_of_tree exec_sts [((hd o tl) preds)]); (to_string (I_False ())))))
		  else if (String.isSuffix "assert_false_cnd" pred) then (((to_string o Br_True) (IMLExp_from_pred exec_sts pred)); ((to_string o assume_to_event) "bad"); (to_string (I_False ())))
		  else if (String.isSuffix "cjmp_false_cnd" pred) then ()
		  else if (String.isSuffix "Key" pred) then (to_string o Fr_to_New) pred
		  else if (String.isSuffix "iv" pred) then (to_string o Fr_to_New) pred
		  else if (String.isSuffix "K" pred) then (K_to_Out exec_sts pred preds)
		  else if (String.isSuffix "Adv" pred) then (to_string o D_to_In) pred
		  else ();
	    
    in
	if (String.isSuffix "cjmp_false_cnd" pred andalso ((not o List.null) preds))
	then path_of_tree exec_sts (tl preds)
	else path_of_tree exec_sts preds
    end;


(*Translate symbolic execution states to IML*)
(*
 val refine_preds =
     ["61_K", "60_Adv", "58_T", "56_Key", "54_cjmp_false_cnd",
      "53_cjmp_true_cnd", "47_K", "46_Adv", "44_T", "42_iv", "39_T", "37_Key",
      "2_init_pred"];
    
 Final Output:
     new 37_Key: 64;
     new 42_iv: 64;
in(c, 46_Adv);
  out(c, enc inputs iv);
  if 53_cjmp_true_cnd then
      new 56_Key: 64;
  else in(c, 60_Adv);

val exec_sts = systs;
*) 
fun sym_exe_to_IML exec_sts =
    let
	val refine_preds = get_refine_preds_list exec_sts;
    in
	path_of_tree exec_sts (rev refine_preds)
    end;
    

end(*local*)

end (* struct *)

