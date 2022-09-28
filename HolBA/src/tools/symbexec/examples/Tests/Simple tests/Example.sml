open HolKernel Parse

open binariesLib;
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
open bir_symbexec_funcLib;
     
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
val systs = symb_exec_to_stop (commonBalrobScriptLib.abpfun cfb) n_dict bl_dict [syst] stop_lbl_tms [];
    (*listItems(SYST_get_env (hd systs));
      listItems(SYST_get_vals (hd systs));*)
val _ = print "finished exploration of all paths.\n";
val _ = print ("number of paths found: " ^ (Int.toString (length systs)));
val _ = print "\n\n";

(*
val systs = symb_exec_to_stop (commonBalrobScriptLib.abpfun cfb) n_dict bl_dict [syst] stop_lbl_tms systs;*)
val _ = print "finished exploration of all paths.\n";
val _ = print ("number of paths found: " ^ (Int.toString (length systs)));
val _ = print "\n\n";
 (* listItems(SYST_get_env (hd systs));
    listItems(SYST_get_vals ((hd o tl) systs));*)
    
val (systs_noassertfailed, systs_assertfailed) =
  List.partition (fn syst => not (identical (SYST_get_status syst) BST_AssertionViolated_tm)) systs;
val _ = print ("number of \"no assert failed\" paths found: " ^ (Int.toString (length systs_noassertfailed)));
val _ = print "\n\n";
(*
val _ = bir_symbexec_treeLib.symb_exec_to_tree (rev systs);
val _ = print "finished traversing the tree.\n\n";
val _ = print ("Tree of Symbolic Execution Output: \n\n" ^ (List.foldr (fn (x,s) => s ^ "\n" ^ (x)) "" (rev Acts)));*)
   

 val Acts = bir_symbexec_treeLib.sym_exe_to_IML systs;
(*val _ = print "finished traversing the tree.\n\n";
val _ = print ("Tree of Symbolic Execution Output: \n\n" ^ (List.foldr (fn (x,s) => s ^ "\n" ^ (x)) "" (Acts)));*)
val _ = print "();\n\n";
