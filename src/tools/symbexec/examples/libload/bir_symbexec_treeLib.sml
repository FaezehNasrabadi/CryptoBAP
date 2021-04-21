structure bir_symbexec_treeLib =
struct

local
    open imlLib;
    open List;
    open bir_immSyntax;
    open bir_symbexec_stepLib;
    open commonBalrobScriptLib;
    open bir_symbexec_oracleLib;
    open bir_symbexec_stateLib;
    open bir_symbexec_funcLib;
    open bir_symbexec_coreLib;
    val ERR = Feedback.mk_HOL_ERR "bir_symbexec_treeLib"
    val Sym_Exe_i = ref (0:int);
    fun get_Sym_Exe_counter () =
	let val i = !Sym_Exe_i; in
	    (Sym_Exe_i := i + 1; i) end;

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
		  [BStmt_Assign (BVar "R5" (BType_Imm Bit64))
				(BExp_Cast BIExp_UnsignedCast
					   (BExp_BinExp BIExp_Plus
							(BExp_Cast BIExp_LowCast
								   (BExp_Den (BVar "R5" (BType_Imm Bit64))) Bit64)
							(BExp_Const (Imm64 2w))) Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2840w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2840w) "14000002 (b 30 <.text+0x30>)";
		  bb_statements := [];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2848w)))|>;
						 <|bb_label := BL_Address_HC (Imm64 2844w) "110004A5 (add w5, w5, #0x1)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R5" (BType_Imm Bit64))
				(BExp_Cast BIExp_UnsignedCast
					   (BExp_BinExp BIExp_Plus
							(BExp_Cast BIExp_LowCast
								   (BExp_Den (BVar "R5" (BType_Imm Bit64))) Bit64)
							(BExp_Const (Imm64 1w))) Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2848w)))|>;
						 <|bb_label := BL_Address (Imm64 2848w); bb_statements := [];
		  bb_last_statement := BStmt_Halt (BExp_Const (Imm64 0w))|>]``;
    
  
val bl_dict  = bir_block_collectionLib.gen_block_dict prog;
val prog_lbl_tms = bir_block_collectionLib.get_block_dict_keys bl_dict;
val prog_lbl_tms_0 = “BL_Address (Imm64 2802w)”;
val prog_vars = bir_exec_typingLib.gen_vars_of_prog prog;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict prog_lbl_tms;
val stop_lbl_tms = [“BL_Address (Imm64 2848w)”];
    
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

val systs = bir_symbexec_stepLib.symb_exec_to_stop (commonBalrobScriptLib.abpfun cfb) n_dict bl_dict [syst] stop_lbl_tms [];




val exec_st = hd(systs);
val pred = “BVar "fr_31_K" BType_Bool”;
val envs = SYST_get_vals exec_st;
val bb = Redblackmap.listItems(envs);
open Redblackmap;
*)

fun D_to_In pred_name = (I_In [pred_name]);
    
fun Fr_to_New pred_name = (I_New (pred_name, N(64)));    


fun find_previous_T exec_st preds =
    let
	val syst_preds = SYST_get_pred exec_st;

	val previous_preds = drop(syst_preds, (length preds));
	    
	val (preds_keep, preds_removed) = List.partition (String.isSuffix "T" o fst o bir_envSyntax.dest_BVar_string) previous_preds;

    in
	hd(preds_keep)
    end;
    

fun K_to_Out exec_st pred preds =
    let
	val t_pred = find_previous_T exec_st preds;

	val vals = SYST_get_vals exec_st;

	val t_be = symbval_bexp (find_bv_val ("K_to_Out::symbv not found") vals t_pred);
	    
	val k_be =  symbval_bexp (find_bv_val ("K_to_Out::symbv not found") vals t_pred);

	val result = if (Term.term_eq t_be k_be) then (to_string (I_Out [(Var (term_to_string k_be))]))
		     else ();

    in
	result
    end;
    
   
(* execute one path *)
fun path_of_tree exec_st [] =
    ()
  | path_of_tree exec_st (pred::preds) =
    let
	val pred_name = (fst o bir_envSyntax.dest_BVar_string) pred;

	val Act = if (String.isSuffix "Key" pred_name) then (to_string o Fr_to_New) pred_name
		  else if (String.isSuffix "iv" pred_name) then (to_string o Fr_to_New) pred_name
		  else if (String.isSuffix "K" pred_name) then (K_to_Out exec_st pred preds)
		  else if (String.isSuffix "Adv" pred_name) then (to_string o D_to_In) pred_name
		  else ();
	    
    in
	path_of_tree exec_st preds
    end; 
    
(* execute all paths *)
fun symb_exec_to_tree [] =
        ()
  | symb_exec_to_tree (exec_st::exec_sts) =
    let
	val preds = SYST_get_pred exec_st;
	    
	val state_number = ("Symbolic Execution State " ^ (Int.toString (get_Sym_Exe_counter ())));

	val _ = print ("\n" ^ state_number ^ "\n");

	val _ = path_of_tree exec_st (rev preds);

    in	
	symb_exec_to_tree exec_sts
    end;
   

end(*local*)

end (* struct *)

