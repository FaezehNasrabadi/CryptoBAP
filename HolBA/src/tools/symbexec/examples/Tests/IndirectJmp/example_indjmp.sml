HOL_Interactive.toggle_quietdec();
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
HOL_Interactive.toggle_quietdec();

val lbl_tm = ``BL_Address (Imm64 524296w)``;

val stop_lbl_tms = [``BL_Address (Imm64 524416w)``];
    
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict_ prog_lbl_tms_;

val adr_dict = bir_symbexec_PreprocessLib.fun_addresses_dict bl_dict_ prog_lbl_tms_;
(* val b = Redblackmap.find(adr_dict,“BL_Address (Imm64 4235844w)”); 
    listItems adr_dict
    val n = valOf (peek (n_dict, “BL_Address (Imm64 948w)”));*)
val syst = init_state lbl_tm prog_vars;

val pred_conjs = [];
    
val syst = state_add_preds "init_pred" pred_conjs syst;

val _ = print "initial state created.\n\n";

val cfb = false;
val systs = symb_exec_to_stop (abpfun cfb) n_dict bl_dict_ [syst] stop_lbl_tms adr_dict [];

val _ = print "\n\n";
val _ = print "finished exploration of all paths.\n\n";
val _ = print ("number of paths found: " ^ (Int.toString (length systs)));
val _ = print "\n\n";

val (systs_noassertfailed, systs_assertfailed) =
  List.partition (fn syst => not (identical (SYST_get_status syst) BST_AssertionViolated_tm)) systs;
val _ = print ("number of \"no assert failed\" paths found: " ^ (Int.toString (length systs_noassertfailed)));
val _ = print "\n\n";
val _ = print ("number of \"assert failed\" paths found: " ^ (Int.toString (length systs_assertfailed)));
val _ = print "\n\n";

val Acts = bir_symbexec_treeLib.sym_exe_to_IML systs_noassertfailed;

val a =listItems( SYST_get_env ((hd o rev) systs));
val b =listItems( SYST_get_vals (List.nth (systs, 6)));
val c = List.map (fn x => ( snd) x) b;
val d = List.map (fn SymbValBE(x,y) => (Redblackset.listItems y)) c;
	     
