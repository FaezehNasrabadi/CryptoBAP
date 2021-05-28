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
open bir_symbexec_oracleLib;

(* wrap function *)

val lbl_tm = ``BL_Address (Imm64 3489667800w)``;

val stop_lbl_tms = [``BL_Address (Imm64 3489668080w)``];

(* unwrap function *)
(*      
val lbl_tm = ``BL_Address (Imm64 3489668084w)``;

val stop_lbl_tms = [``BL_Address (Imm64 3489668420w)``];
  *)
val syst = init_state lbl_tm prog_vars;

val pred_conjs = [``bir_exp_true``];
    
val syst = state_add_preds "init_pred" pred_conjs syst;

val _ = print "initial state created.\n\n";

val cfb = false;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict_ prog_lbl_tms_;

val systs = symb_exec_to_stop (abpfun cfb) n_dict bl_dict_ [syst] stop_lbl_tms [];
val _ = print "\n\n";
val _ = print "finished exploration of all paths.\n\n";
val _ = print ("number of paths found: " ^ (Int.toString (length systs)));
val _ = print "\n\n";

(*    listItems(SYST_get_pred (hd systs_noassertfailed));
      listItems(SYST_get_vals syst);
      listItems(SYST_get_pred (hd systs));
      listItems(SYST_get_vals ((hd o tl) systs));
 *)
     
val (systs_noassertfailed, systs_assertfailed) =
  List.partition (fn syst => not (identical (SYST_get_status syst) BST_AssertionViolated_tm)) systs;
val _ = print ("number of \"no assert failed\" paths found: " ^ (Int.toString (length systs_noassertfailed)));
val _ = print "\n\n";
val _ = print ("number of \"assert failed\" paths found: " ^ (Int.toString (length systs_assertfailed)));
val _ = print "\n\n";
(*
commented because of HolBA/src/shared/bir_smtLib.sml raised HOL_ERR {message = "address type other than 32bits cannot be handled currently"}
val systs_feasible = List.filter check_feasible systs_noassertfailed;
val _ = print ("number of feasible paths found: " ^ (Int.toString (length systs_feasible)));
val _ = print "\n\n";
val systs_tidiedup = List.map tidyup_state_vals systs_feasible;
*)
val systs_tidiedup = List.map tidyup_state_vals systs_noassertfailed;
val _ = print "finished tidying up all paths.\n\n";
val _ = print ("number of tidied up paths found: " ^ (Int.toString (length systs_tidiedup)));
val _ = print "\n\n";
(*
    listItems(SYST_get_vals (List.nth (systs, 44)));
 *)

 val Acts = bir_symbexec_treeLib.sym_exe_to_IML systs;
(*val _ = print "finished traversing the tree.\n\n";
val _ = print ("Tree of Symbolic Execution Output: \n\n" ^ (List.foldr (fn (x,s) => s ^ "\n" ^ (x)) "" (Acts)));*)
val _ = print "();\n\n";
