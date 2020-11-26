open HolKernel Parse

open binariesLib;
open binariesCfgLib;
open binariesMemLib;

open bir_symbexec_stateLib;
open bir_symbexec_coreLib;
open bir_symbexec_stepLib;
open bir_symbexec_sumLib;
open bir_countw_simplificationLib;

open commonBalrobScriptLib;
  

val label = "motor_set_l";

val name   = label;

val _ = print ("label = " ^ (name) ^ "\n");

val lbl_tm = (mk_lbl_tm o valOf o mem_find_symbol_addr_) name;
    
val syst_start = init_state lbl_tm prog_vars;
(*val syst_start = state_make_interval bv_countw syst_start;*)

val pc = SYST_get_pc (syst_start);
    
val _ = print ("system pc at label we know =  " ^ (term_to_string(pc)) ^ "\n");

val est = `` BStmt_Jmp (BLE_Label (BL_Address (Imm32 3072w)))``;
    
val syst_after = bir_symbexec_stepLib.state_exec_try_jmp_label est syst_start;
    
val _ = print ("updated pc to adversary code =  " ^ (term_to_string(pc')) ^ "\n");

fun insert_symbval bv_fresh symbv syst_after =
  let
    val vals  = SYST_get_vals syst_after;

    (* make sure that bv_fresh is indeed fresh and is not an initial variable *)
    val _ = if (not o is_bvar_init) bv_fresh then () else
            raise ERR "insert_symbval" ("variable cannot be an initial variable: " ^ (term_to_string bv_fresh));
    val _ = if (not o isSome o Redblackmap.peek) (vals, bv_fresh) then () else
            raise ERR "insert_symbval" ("variable needs to be fresh: " ^ (term_to_string bv_fresh));

    val vals' = Redblackmap.insert (vals, bv_fresh, symbv);
  in
      (SYST_update_vals vals') syst_after
      
  end;
    
val vals = SYST_get_vals (syst_after);
val _ = print ("symbolic value updated for fresh new variable\n");
	
	
