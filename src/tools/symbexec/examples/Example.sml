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
     
val prog = ``BirProgram
      [<|bb_label :=
           BL_Address_HC (Imm32 0w)
             "52800000 (mov w0, #0x0                    // #0)";
         bb_statements :=
           [BStmt_Assign (BVar "R0" (BType_Imm Bit32))
              (BExp_Const (Imm32 0w))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 4w)))|>;
       <|bb_label := BL_Address_HC (Imm32 4w) "11000400 (add w0, w0, #0x1)";
         bb_statements :=
           [BStmt_Assign (BVar "R0" (BType_Imm Bit32))
                     (BExp_BinExp BIExp_Plus
                        (BExp_Den (BVar "R0" (BType_Imm Bit32)))
                        (BExp_Const (Imm32 1w)))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 8w)))|>;
       <|bb_label := BL_Address_HC (Imm32 8w) "94000020 (bl 88 <.text+0x88>)";
         bb_statements :=
           [BStmt_Assign (BVar "R30" (BType_Imm Bit32))
              (BExp_Const (Imm32 12w))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 2002w)))|>;
       <|bb_label := BL_Address_HC (Imm32 2002w) "hc_NewKey";
         bb_statements :=
           [BStmt_Assign (BVar "R0" (BType_Imm Bit32)) (BExp_Const (Imm32 (4w :word32)))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 12w)))|>;
	<|bb_label := BL_Address_HC (Imm32 12w) "2A0003E2 (mov w2, w0)";
         bb_statements :=
           [BStmt_Assign (BVar "R2" (BType_Imm Bit32))
              (BExp_Cast BIExp_UnsignedCast
                 (BExp_Cast BIExp_LowCast
                    (BExp_Den (BVar "R0" (BType_Imm Bit32))) Bit32) Bit32)];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 16w)))|>;
	<|bb_label :=
           BL_Address_HC (Imm32 16w)
             "52800121 (mov w1, #0x9                    // #9)";
         bb_statements :=
           [BStmt_Assign (BVar "R1" (BType_Imm Bit32))
              (BExp_Const (Imm32 9w))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 20w)))|>;
       <|bb_label :=
           BL_Address_HC (Imm32 20w) "94000024 (bl a4 <.text+0xa4>)";
         bb_statements :=
           [BStmt_Assign (BVar "R30" (BType_Imm Bit32))
              (BExp_Const (Imm32 24w))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 2004w)))|>;
       <|bb_label := BL_Address_HC (Imm32 2004w) "hc_Enc(k,m)";
         bb_statements :=
           [BStmt_Assign (BVar "R0" (BType_Imm Bit32)) (BExp_Const (Imm32 (36w :word32)))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 24w)))|>;
       <|bb_label := BL_Address_HC (Imm32 24w) "2A0003E3 (mov w3, w0)";
         bb_statements :=
           [BStmt_Assign (BVar "R3" (BType_Imm Bit32))
              (BExp_Cast BIExp_UnsignedCast
                 (BExp_Cast BIExp_LowCast
                    (BExp_Den (BVar "R0" (BType_Imm Bit32))) Bit32) Bit32)];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 28w)))|>;
	<|bb_label :=
           BL_Address_HC (Imm32 28w) "94000028 (bl 72 <.text+0x72>)";
         bb_statements :=
           [BStmt_Assign (BVar "R30" (BType_Imm Bit32))
              (BExp_Const (Imm32 32w))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 2006w)))|>;
	<|bb_label := BL_Address_HC (Imm32 2006w) "hc_Adv(c)";
         bb_statements :=
           [BStmt_Assign (BVar "R0" (BType_Imm Bit32)) (BExp_Const (Imm32 (0w :word32)))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 32w)))|>;

      ]``;
 
val bl_dict  = bir_block_collectionLib.gen_block_dict prog;
val prog_lbl_tms = bir_block_collectionLib.get_block_dict_keys bl_dict;
val prog_lbl_tms_0 = List.nth (prog_lbl_tms, 0);
val prog_vars = bir_exec_typingLib.gen_vars_of_prog prog;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict prog_lbl_tms;
val stop_lbl_tms = [“BL_Address (Imm32 16w)”];
(*val stop_lbl_tms = find_func_ends n_dict entry_label;
val stop_lbl_tms = (List.map #CFGN_lbl_tm o
                          List.filter (fn n => node_to_rel_symbol n = entry_label andalso
                                               cfg_node_type_eq (#CFGN_type n, CFGNT_Return))
                         ) (List.map snd (Redblackmap.listItems n_dict));*)
val syst = init_state prog_lbl_tms_0 prog_vars;

val pred_conjs =
   [``BExp_Cast BIExp_UnsignedCast
                 (BExp_Cast BIExp_LowCast
			    (BExp_Den (BVar "R0" (BType_Imm Bit32))) Bit32) Bit32``, ``BExp_Const (Imm32 120w)``];

val syst = state_add_preds "init_pred" pred_conjs syst;
val _ = print "initial state created.\n\n";

val cfb = false;

val systs = symb_exec_to_stop (commonBalrobScriptLib.abpfun cfb) n_dict bl_dict [syst] stop_lbl_tms [];
val _ = print "finished exploration of all paths.\n";
val _ = print ("number of paths found: " ^ (Int.toString (length systs)));
val _ = print "\n\n";

val stop_lbl_tms = [“BL_Address (Imm32 32w)”];
val systs = symb_exec_to_stop (commonBalrobScriptLib.abpfun cfb) n_dict bl_dict [syst] stop_lbl_tms systs;
val _ = print "finished exploration of all paths.\n";
val _ = print ("number of paths found: " ^ (Int.toString (length systs)));
val _ = print "\n\n";

    
val (systs_noassertfailed, systs_assertfailed) =
  List.partition (fn syst => not (identical (SYST_get_status syst) BST_AssertionViolated_tm)) systs;
val _ = print ("number of \"no assert failed\" paths found: " ^ (Int.toString (length systs_noassertfailed)));
val _ = print "\n\n";
(*Redblackmap.listItems bl_dict;*)
