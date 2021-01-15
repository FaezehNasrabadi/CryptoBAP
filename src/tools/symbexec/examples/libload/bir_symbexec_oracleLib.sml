structure bir_symbexec_oracleLib =
struct

local
  open bir_symbexec_stateLib;
  open bir_symbexec_coreLib;

  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_oracleLib"
in
(*val prog_vars =
   [“BVar "R11" (BType_Imm Bit32)”, “BVar "R10" (BType_Imm Bit32)”,
    “BVar "tmp_PSR_C" BType_Bool”, “BVar "R12" (BType_Imm Bit32)”,
    “BVar "R9" (BType_Imm Bit32)”, “BVar "R8" (BType_Imm Bit32)”,
    “BVar "R6" (BType_Imm Bit32)”, “BVar "tmp_R1" (BType_Imm Bit32)”,
    “BVar "R5" (BType_Imm Bit32)”, “BVar "tmp_PC" (BType_Imm Bit32)”,
    “BVar "ModeHandler" BType_Bool”, “BVar "tmp_R3" (BType_Imm Bit32)”,
    “BVar "tmp_R2" (BType_Imm Bit32)”, “BVar "R3" (BType_Imm Bit32)”,
    “BVar "R2" (BType_Imm Bit32)”, “BVar "R1" (BType_Imm Bit32)”,
    “BVar "R0" (BType_Imm Bit32)”, “BVar "PSR_V" BType_Bool”,
    “BVar "PSR_C" BType_Bool”, “BVar "PSR_Z" BType_Bool”,
    “BVar "PSR_N" BType_Bool”, “BVar "LR" (BType_Imm Bit32)”,
    “BVar "R7" (BType_Imm Bit32)”, “BVar "R4" (BType_Imm Bit32)”,
    “BVar "MEM" (BType_Mem Bit32 Bit8)”,
    “BVar "tmp_SP_process" (BType_Imm Bit32)”,
    “BVar "SP_process" (BType_Imm Bit32)”, “BVar "countw" (BType_Imm Bit64)”];
  val lbl_tm = “BL_Address (Imm32 3076w)”;
  val syst = init_state lbl_tm prog_vars;
      val bv_countw = bir_envSyntax.mk_BVar_string ("countw", ``(BType_Imm Bit64)``);
  val syst = state_make_interval bv_countw syst;
  val pred_conjs =
   [``BExp_Cast BIExp_UnsignedCast
                 (BExp_Cast BIExp_LowCast
			    (BExp_Den (BVar "PSR_N" BType_Bool)) Bit32) Bit32``, ``BExp_Const (Imm32 136w)``];
  val syst = state_add_preds "init_pred" pred_conjs syst;*)


(*val est = ``BStmt_CJmp
                    (BExp_BinExp BIExp_Or
                       (BExp_UnaryExp BIExp_Not
                          (BExp_BinPred BIExp_Equal
                             (BExp_Den (BVar "PSR_N" BType_Bool))
                             (BExp_Den (BVar "PSR_V" BType_Bool))))
                       (BExp_Den (BVar "PSR_Z" BType_Bool)))
                    (BLE_Label (BL_Address (Imm32 12232w)))
                    (BLE_Label (BL_Address (Imm32 12228w)))``;*)
fun state_exec_try_cjmp_label_out est syst =
     let
	 val cjmp_label_match_tm = ``BStmt_CJmp xyzc (BLE_Label xyz1) (BLE_Label xyz2)``;
	 val (vs, _) = hol88Lib.match cjmp_label_match_tm est;
	 val cnd     = fst (List.nth (vs, 0));
	 val tgt1    = fst (List.nth (vs, 1));
	 val tgt2    = fst (List.nth (vs, 2));

	 (* see whether the latest addition to the path condition
		matches the unnegated or negated branch condition *)
	 val pred = SYST_get_pred syst;
	 val vals = SYST_get_vals syst;
	 val last_pred_bv = hd pred
             handle Empty => raise ERR "symb_exec_endstmt" "oh no, pred is empty!";
val _ = print_term last_pred_bv;
	 val last_pred_symbv = find_bv_val "symb_exec_endstmt" vals last_pred_bv;
	 val last_pred_exp =
             case last_pred_symbv of
		 SymbValBE (x,_) => x
               | _ => raise ERR "symb_exec_endstmt" "cannot handle symbolic value type for last pred exp";

	 (* get branch condition *)
	 val cnd_exp =
             case compute_valbe cnd syst of
		 SymbValBE (x,_) => x
               | _ => raise ERR "symb_exec_endstmt" "cannot handle symbolic value type for conditions";
     in
	 (* does unnegated condition match? *)
	 if identical cnd_exp last_pred_exp then
             tgt1
	 (* does negated condition match? *)
	 else if identical (bslSyntax.bnot cnd_exp) last_pred_exp then
             tgt2
	     
	 (* no match *)
	 else
	     tgt1
     (*we need to fix it later*)
     end;
	  
    (*  state_branch_simp
         "cjmp"
         cnd
         (SYST_update_pc tgt1)
         (SYST_update_pc tgt2)
         syst
    end
   *)



(*val est = ``BStmt_Jmp
                    (BLE_Exp (BExp_Den (BVar "tmp_PC" (BType_Imm Bit32))))``;*)

fun state_exec_try_jmp_exp_var_out est syst =
    let
	 val jmp_exp_var_match_tm = ``BStmt_Jmp (BLE_Exp x)``;
	 val (vs, _) = hol88Lib.match jmp_exp_var_match_tm est;

	 val be_tgt  = (fst o hd) vs;

	 open bir_countw_simplificationLib;
	 val bvalo = eval_exp_in_syst be_tgt syst;
    

	 open bir_valuesSyntax;
	 open optionSyntax;
	      
	 val tgt = 
	     if is_some bvalo then (mk_BL_Address o dest_BVal_Imm o dest_some) bvalo
	     else ``BL_Address (Imm32 2802w)``;(*we need to fix it later*)
    in
	tgt 
    end;
    

      
(*val tm = “3076w”;*) 
fun sint_of_term tm =
  tm |> wordsSyntax.dest_word_literal |> Arbnum.toInt
  handle Overflow => raise ERR "sint_of_term"
                       ("integer " ^ term_to_string tm ^ " too large")
       | HOL_ERR _ => raise ERR "sint_of_term"
                       ("could not convert ``" ^ term_to_string tm ^
                        "`` to an integer");
fun in_range (mn,mx) tm =
    let val v = sint_of_term tm in
      mn <= v andalso v <= mx
    end handle HOL_ERR _ => false | Overflow => false;

(*val label = “3076w”;*)    
fun fun_oracle_type_label label =
    let
	val lbl = 
	    (*critical section that no one must not jump to it*)
	    if (in_range (0,2000) label) then
		"Adversary"
	    (*part of memory that library functions exist*)
	    else if (in_range (2001,2800) label) then
		"Library"
	    (*jump to other part of memory is normal*)
	    else if (in_range (2801,268439552) label) then
		"Normal"
	    else
		raise ERR "fun_oracle_type_label" ("cannot handle label " ^ (term_to_string label));
    in
	lbl
    end;

fun fun_oracle_Address est syst =
    let
	      val target_label = if is_BStmt_CJmp est then state_exec_try_cjmp_label_out est syst
				 else if is_BStmt_Halt est then (bir_expSyntax.dest_BExp_Const o dest_BStmt_Halt) est
				 else if (is_BLE_Label o dest_BStmt_Jmp) est then (dest_BLE_Label o dest_BStmt_Jmp) est
				 else if (is_BLE_Exp o dest_BStmt_Jmp) est then state_exec_try_jmp_exp_var_out est syst
				 else raise ERR "fun_orcle" ("cannot handle target label " ^ (term_to_string est));
	  in
	      target_label
	  end;
(*
val est = `` BStmt_Jmp (BLE_Label (BL_Address (Imm32 2886w)))``;
val est = ``BStmt_Halt (BExp_Const (Imm32 136w))``;
*)
fun fun_oracle est syst =
    let
	      val target_label = fun_oracle_Address est syst;
		       
	      val target_label_type =
		  if is_BL_Address target_label
		  then (fun_oracle_type_label o bir_immSyntax.dest_Imm32 o dest_BL_Address) target_label
		  else if is_BL_Label target_label
		  then (term_to_string o dest_BL_Label) target_label
		  else if bir_immSyntax.is_Imm32 target_label
		  then (fun_oracle_type_label o bir_immSyntax.dest_Imm32) target_label
		  else raise ERR "fun_orcle" ("cannot handle target label num " ^ (term_to_string target_label));

	  in
	      target_label_type
	  end;

(*val label = “2002w”;*)    
fun lib_oracle_type_label label =
    let
	val lbl = 
	     (*part of memory that new key functions exist*)
	    if (in_range (2001,2200) label) then
		"NewKey"
	    (*part of memory that encryption functions exist*)
	    else if (in_range (2201,2500) label) then
		"Encryption"
	    (*part of memory that decryption functions exist*)
	    else if (in_range (2501,2800) label) then
		"Decryption"
	    else
		raise ERR "lib_oracle_type_label" ("cannot handle label " ^ (term_to_string label));
    in
	lbl
    end;
    
(*val lbl_tm = “BL_Address (Imm32 2002w)”;*)

fun lib_oracle est syst =
    let
	      val target_label = fun_oracle_Address est syst;
		       
	      val lib_type =
		  if is_BL_Address target_label
		  then (lib_oracle_type_label o bir_immSyntax.dest_Imm32 o dest_BL_Address) target_label
		  else if is_BL_Label target_label
		  then (term_to_string o dest_BL_Label) target_label
		  else if bir_immSyntax.is_Imm32 target_label
		  then (lib_oracle_type_label o bir_immSyntax.dest_Imm32) target_label
		  else raise ERR "fun_orcle" ("cannot handle target label num " ^ (term_to_string target_label));

	  in
	      lib_type
	  end;    
    
end(*local*)

end (* struct *)




    

