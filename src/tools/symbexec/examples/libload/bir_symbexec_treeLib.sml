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
(*
val prog = ``BirProgram
		 [<|bb_label :=
		  BL_Address_HC (Imm64 2802w)
				"52800000 (mov w0, #0x0 // #0)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
				(BExp_Const (Imm64 0w))];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2804w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2804w) "11000400 (add w0, w0, #0x1)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
				(BExp_Cast BIExp_UnsignedCast
					   (BExp_BinExp BIExp_Plus
							(BExp_Cast BIExp_LowCast
								   (BExp_Den (BVar "R0" (BType_Imm Bit64))) Bit64)
							(BExp_Const (Imm64 1w))) Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2808w)))|>;
						 <|bb_label := BL_Address_HC (Imm64 2808w) "2A0003E5 (mov w5, w0)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R5" (BType_Imm Bit64))
				(BExp_Cast BIExp_UnsignedCast
					   (BExp_Cast BIExp_LowCast
						      (BExp_Den (BVar "R0" (BType_Imm Bit64))) Bit64) Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2812w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2812w) "94000040 (bl 10c <.text+0x10c>)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
				(BExp_Const (Imm64 2816w))];
		  bb_last_statement :=
		  BStmt_Jmp (BLE_Label (BL_Address (Imm64 2002w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2816w)
				"52800121 (mov w1, #0x9// #9)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R1" (BType_Imm Bit64))
				(BExp_Const (Imm64 9w))];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2820w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2820w) "94000080 (bl 214 <.text+0x214>)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
				(BExp_Const (Imm64 2824w))];
		  bb_last_statement :=
		  BStmt_Jmp (BLE_Label (BL_Address (Imm64 2202w)))|>;

			    <|bb_label :=
		  BL_Address_HC (Imm64 2824w) "940000C0 (bl 318 <.text+0x318>)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
				(BExp_Const (Imm64 2828w))];
		  bb_last_statement :=
		  BStmt_Jmp (BLE_Label (BL_Address (Imm64 02w)))|>;
			    <|bb_label := BL_Address_HC (Imm64 2828w) "7100001F (cmp w0, #0x0)";
		  bb_statements :=
		  [BStmt_Assign (BVar "ProcState_C" BType_Bool) bir_exp_true;
		   BStmt_Assign (BVar "ProcState_N" BType_Bool)
				(BExp_MSB Bit64
					  (BExp_Cast BIExp_LowCast
						     (BExp_Den (BVar "R0" (BType_Imm Bit64))) Bit64));
		   BStmt_Assign (BVar "ProcState_V" BType_Bool) bir_exp_false;
		   BStmt_Assign (BVar "ProcState_Z" BType_Bool)
				(BExp_BinPred BIExp_Equal
					      (BExp_Cast BIExp_LowCast
							 (BExp_Den (BVar "R0" (BType_Imm Bit64))) Bit64)
					      (BExp_Const (Imm64 0w)))];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2832w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2832w)
				"54000060 (b.eq 2c <.text+0x2c> // b.none)";
		  bb_statements := [];
		  bb_last_statement :=
		  BStmt_CJmp (BExp_Den (BVar "ProcState_Z" BType_Bool))
			     (BLE_Label (BL_Address (Imm64 2844w)))
			     (BLE_Label (BL_Address (Imm64 2836w)))|>;
			     <|bb_label := BL_Address_HC (Imm64 2836w) "110008A5 (add w5, w5, #0x2)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
				(BExp_Const (Imm64 2840w))];
		  bb_last_statement :=
		  BStmt_Jmp (BLE_Label (BL_Address (Imm64 04w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2840w) "14000002 (b 30 <.text+0x30>)";
		  bb_statements := [];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2848w)))|>;
						 <|bb_label := BL_Address_HC (Imm64 2844w) "110004A5 (add w5, w5, #0x1)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
				(BExp_Const (Imm64 2848w))];
		  bb_last_statement :=
		  BStmt_Jmp (BLE_Label (BL_Address (Imm64 2002w)))|>;
						 <|bb_label := BL_Address (Imm64 2848w); bb_statements := [];
		  bb_last_statement := BStmt_Halt (BExp_Const (Imm64 0w))|>]``;
    
  
val bl_dict  = bir_block_collectionLib.gen_block_dict prog;
val prog_lbl_tms = bir_block_collectionLib.get_block_dict_keys bl_dict;
val prog_lbl_tms_0 = “BL_Address (Imm64 2802w)”;
val prog_vars = bir_exec_typingLib.gen_vars_of_prog prog;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict prog_lbl_tms;

    
val syst = init_state prog_lbl_tms_0 prog_vars;

val Fr_bval = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("init", “BType_Imm Bit64”));
val bv = ``BVar "R0" (BType_Imm Bit64)``;
val deps = Redblackset.add (symbvalbe_dep_empty, bv);
val symbv = SymbValBE (Fr_bval,deps);
val Fr_bv = get_bvar_fresh bv;
val syst = bir_symbexec_stateLib.insert_symbval Fr_bv symbv syst;

val pred_conjs = [``bir_exp_true``];

val syst = state_add_preds "init_pred" pred_conjs syst;
val _ = print "initial state created.\n\n";


val cfb = false;
val stop_lbl_tms = [“BL_Address (Imm64 2848w)”];
val systs = symb_exec_to_stop (commonBalrobScriptLib.abpfun cfb) n_dict bl_dict [syst] stop_lbl_tms [];*)


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

