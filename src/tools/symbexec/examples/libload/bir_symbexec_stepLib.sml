structure bir_symbexec_stepLib =
struct

local
  open bir_symbexec_stateLib;
  open bir_symbexec_coreLib;

  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_stepLib"
  val wrap_exn = Feedback.wrap_exn   "bir_symbexec_stepLib"
in (* outermost local *)

(* execution of a basic statement *)
local
  (* basic statement execution functions *)
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
  val lbl_tm = “BL_Address (Imm32 2820w)”;
  val syst = init_state lbl_tm prog_vars;
  val bv_countw = bir_envSyntax.mk_BVar_string ("countw", ``(BType_Imm Bit64)``);
  val syst = state_make_interval bv_countw syst;
  val SymbState systr = syst;
  val s = ``BStmt_Assign (BVar "R5" (BType_Imm Bit32)) (BExp_Den (BVar "R4" (BType_Imm Bit32)))``;
  val (bv, be) = dest_BStmt_Assign s;
val prog = ``BirProgram
      [<|bb_label :=
           BL_Address_HC (Imm32 2820w) "94000024 (bl a4 <.text+0xa4>)";
         bb_statements :=
           [BStmt_Assign (BVar "R30" (BType_Imm Bit32))
              (BExp_Const (Imm32 2824w))];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 2202w)))|>;
<|bb_label := BL_Address_HC (Imm32 2824w) "2A0003E3 (mov w3, w0)";
         bb_statements :=
           [BStmt_Assign (BVar "R3" (BType_Imm Bit32))
              (BExp_Cast BIExp_UnsignedCast
                 (BExp_Cast BIExp_LowCast
                    (BExp_Den (BVar "R0" (BType_Imm Bit32))) Bit32) Bit32)];
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 2828w)))|>;]``;
val bl_dict  = bir_block_collectionLib.gen_block_dict prog;
val prog_lbl_tms = bir_block_collectionLib.get_block_dict_keys bl_dict;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict prog_lbl_tms;
*)
  
  (* TODO: this branching can be considered a hack because of
           the way that countw is assigned to for conditional branches *)
  val bv_countw = bir_envSyntax.mk_BVar_string ("countw", ``(BType_Imm Bit64)``);
  fun state_exec_assign (bv, be) syst =
    if identical bv bv_countw andalso bir_expSyntax.is_BExp_IfThenElse be then
      let
        val (cnd, be1, be2) = bir_expSyntax.dest_BExp_IfThenElse be;
      in
        state_branch "assign"
                     cnd
                     (state_exec_assign (bv, be1))
                     (state_exec_assign (bv, be2))
                     syst
      end
    else
      [state_assign_bv bv be syst];

  fun state_exec_assert cnd syst =
        state_branch_simp
           "assert"
           cnd
           (I)
           (SYST_update_status BST_AssertionViolated_tm)
           syst;

  fun state_exec_assume cnd syst =
        state_branch_simp
           "assume"
           cnd
           (I)
           (SYST_update_status BST_AssumptionViolated_tm)
           syst;



  fun state_exec_observe (id_tm, cnd_tm, exps_tm, ofun_tm) syst =
    let
      val _  = if numSyntax.is_numeral id_tm then () else
               raise ERR "symb_exec_stmt_observe" "the observation id has to be a numeral.";
      val id = numSyntax.dest_numeral id_tm;

      val (exp_tms,_) = listSyntax.dest_list exps_tm;

      val cnd_bv = bir_envSyntax.mk_BVar_string ("observe_cnd", bir_valuesSyntax.BType_Bool_tm);

      fun fold_exp (exp_tm, (exp_bvs, insert_fun)) =
        let
          val exp_ty = (optionSyntax.dest_some o bir_exp_helperLib.get_type_of_bir_exp) exp_tm
                       handle e => raise wrap_exn "state_exec_observe::typpeofthm not as expected" e;
          val exp_bv = bir_envSyntax.mk_BVar_string ("observe_exp", exp_ty);
        in
          (exp_bv::exp_bvs, (state_insert_symbval_from_be exp_bv exp_tm) o insert_fun)
        end;
      val (exp_bvs, insert_fun) = List.foldr fold_exp ([],I) exp_tms; 

      val obs = (id, cnd_bv, exp_bvs, ofun_tm);
      val obss' = obs::(SYST_get_obss syst);
    in
      [(SYST_update_obss obss' o
        insert_fun o
        state_insert_symbval_from_be cnd_bv cnd_tm
        ) syst]
    end;

  open bir_programSyntax;
in (* local *)
  fun symb_exec_stmt (s, syst) =
    (* no update if state is not running *)
    if (not o state_is_running) syst then
      [syst]
    (* assignment *)
    else if is_BStmt_Assign s then
      state_exec_assign (dest_BStmt_Assign s) syst
    (* assert and assume *)
    else if is_BStmt_Assert s then
      state_exec_assert (dest_BStmt_Assert s) syst
    else if is_BStmt_Assume s then
      state_exec_assume (dest_BStmt_Assume s) syst
    (* observations *)
    else if is_BStmt_Observe s then
      state_exec_observe (dest_BStmt_Observe s) syst
    else raise ERR "symb_exec_stmt" ("unknown statement type for: " ^ (term_to_string s));
end (* local *)

(* execution of an end statement *)
local
  (*val est = `` BStmt_Jmp (BLE_Label (BL_Address (Imm32 3080w)))``;*)
    val jmp_label_match_tm = ``BStmt_Jmp (BLE_Label xyz)``;
    fun state_exec_try_jmp_label est syst =
    SOME (
    let

      val (vs, _) = hol88Lib.match jmp_label_match_tm est;
      val tgt = (fst o hd) vs;
     
    in
	    [SYST_update_pc tgt syst] 
    end
    )
    handle HOL_ERR _ => NONE;
 (*val est = ``BStmt_CJmp
                    (BExp_BinExp BIExp_Or
                       (BExp_UnaryExp BIExp_Not
                          (BExp_BinPred BIExp_Equal
                             (BExp_Den (BVar "PSR_N" BType_Bool))
                             (BExp_Den (BVar "PSR_V" BType_Bool))))
                       (BExp_Den (BVar "PSR_Z" BType_Bool)))
                    (BLE_Label (BL_Address (Imm32 12232w)))
                    (BLE_Label (BL_Address (Imm32 12228w)))``;*)
  val cjmp_label_match_tm = ``BStmt_CJmp xyzc (BLE_Label xyz1) (BLE_Label xyz2)``;
  fun state_exec_try_cjmp_label est syst =
    SOME (
    let
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
        [(SYST_update_pc tgt1
         ) syst]
      (* does negated condition match? *)
      else if identical (bslSyntax.bnot cnd_exp) last_pred_exp then
        [(SYST_update_pc tgt2
         ) syst]
      (* no match *)
      else
      state_branch_simp
         "cjmp"
         cnd
         (SYST_update_pc tgt1)
         (SYST_update_pc tgt2)
         syst
    end
    )
      handle HOL_ERR _ => NONE;
 (*val est = ``BStmt_Jmp
                    (BLE_Exp
                       (BExp_BinExp BIExp_Plus (BExp_Const (Imm32 1092w))
				    (BExp_Const (Imm32 10524w))))``;   *)
      
  val jmp_exp_var_match_tm = ``BStmt_Jmp (BLE_Exp x)``;
  exception state_exec_try_jmp_exp_var_exn;
  fun state_exec_try_jmp_exp_var est syst =
    SOME (
    let
      val (vs, _) = hol88Lib.match jmp_exp_var_match_tm est
                    handle _ => (
                      print ("couldn't match end statement: " ^ (term_to_string est) ^ "\n");
                      raise ERR "couldn't match" (term_to_string est));
      val be_tgt  = (fst o hd) vs;

      open bir_countw_simplificationLib;
      val bvalo = eval_exp_in_syst be_tgt syst
                  handle e => (
                    print ("ooops, something went wrong in evaluation: " ^ (term_to_string be_tgt) ^ "\n");
                    raise wrap_exn ("ooops, something went wrong in evaluation: " ^ (term_to_string be_tgt)) e);

      open bir_valuesSyntax;
      open optionSyntax;
      val tgt = (mk_BL_Address o dest_BVal_Imm o dest_some) bvalo
                handle _ => (
                  print ("state_exec_try_jmp_exp_var::no const: " ^
                         (term_to_string bvalo) ^ " ;; " ^ 
                         (term_to_string be_tgt) ^ "\n");
                  raise state_exec_try_jmp_exp_var_exn);(*ERR "state_exec_try_jmp_exp_var"
                    ("target value is no const: " ^ (term_to_string bvalo)));*)
    in
      [SYST_update_pc tgt syst]
    end
    )
    handle state_exec_try_jmp_exp_var_exn => NONE
         | e => raise wrap_exn ("state_exec_try_jmp_exp_var::") e;

  open bir_cfgLib;

  fun state_exec_from_cfg n_dict lbl_tm syst =
    let
      val n:cfg_node = binariesCfgLib.find_node n_dict lbl_tm;
      val n_type  = #CFGN_type n;
      val _       = if cfg_nodetype_is_call n_type orelse
                       cfg_node_type_eq (n_type, CFGNT_Jump) then () else
                    raise ERR "symb_exec_endstmt" ("can only handle a call or a jump here, problem at " ^ (term_to_string lbl_tm));
      val n_targets  = #CFGN_targets n;
      val lbl_tms = n_targets;
    in
      List.map (fn t => SYST_update_pc t syst) lbl_tms
    end;
      
in (* local *)
  fun symb_exec_endstmt n_dict lbl_tm est syst = (
    (* no update if state is not running *)
    if (not o state_is_running) syst then [syst] else
    (* try to match direct jump *)
    case state_exec_try_jmp_label est syst of
       SOME systs => systs
     | NONE       => (
    (* try to match direct branch *)
    case state_exec_try_cjmp_label est syst of
       SOME systs => systs
     | NONE       => (
    (* try to match indirect jump *)
    case state_exec_try_jmp_exp_var est syst of
       SOME systs => systs
     | NONE       => (
    (* no match, then we have some indirection and need to rely on cfg (or it's another end statement) *)
    state_exec_from_cfg n_dict lbl_tm syst
    ))))
   handle e =>
     raise wrap_exn (term_to_string lbl_tm) e;;
end (* local *)

local
  open bir_block_collectionLib;

  val symb_exec_to_stop_last_print = ref (NONE : Time.time option);
in (* local *)

(* handle adversary code *)
fun symb_exec_adversary_block abpfun n_dict bl_dict syst =
    let val lbl_tm = SYST_get_pc syst; in
	    let
		val bl = (valOf o (lookup_block_dict bl_dict)) lbl_tm;

		val (lbl_block_tm, bl_stmts, est) = dest_bir_block bl;

		(* generate a fresh variable *)
	
		val bv_fresh = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Adv", “BType_Imm Bit32”));

		val exp = ``BExp_BinPred BIExp_NotEqual
					  (BExp_Den (bv_fresh))
					  (BExp_Den (BVar "R0" (BType_Imm Bit32)))``;
		(* update path condition *)
		val pred = SYST_get_pred syst; (* get current path condition *)
		val syst = SYST_update_pred ((exp)::(pred)) syst;(* add bir expression to path condition and update state*)

		(* update environment *)
		val bv = ``BVar "R0" (BType_Imm Bit32)``;
		val env = SYST_get_env syst; (* current environment *)
		val env'= Redblackmap.insert (env, bv, bv_fresh); (* insert bir variable and fresh variable to current environment *)
		    (*Redblackmap.listItems env';*)
		val syst = (SYST_update_env env') syst; (* update state by new environment *)	    

		(* update pc *)
		val s_tm = (fst o listSyntax.dest_list) bl_stmts;
		val s_tm_0 = List.nth (s_tm, 0);
		val (_, be) = dest_BStmt_Assign s_tm_0; (* extract bir expression *)
		val tgt = (mk_BL_Address o bir_expSyntax.dest_BExp_Const) be; (* make next address *)
		    
		val systs = List.map (SYST_update_pc tgt) [syst];(* update symb_state list with new pc *)

	    in
		systs
	    end
	    handle e => raise wrap_exn ("symb_exec_adversary_block::" ^ term_to_string lbl_tm) e end;

(* handle library code *)
fun symb_exec_library_block abpfun n_dict bl_dict syst =
    let val lbl_tm = SYST_get_pc syst; in
	    let
		val bl = (valOf o (lookup_block_dict bl_dict)) lbl_tm;

		val (lbl_block_tm, bl_stmts, est) = dest_bir_block bl;
		
		val lib_type = bir_symbexec_oracleLib.lib_oracle est syst; (* detect type of library call *)

		val _ = if false then () else
			print ("lib_type: " ^ (lib_type) ^ "\n");

		val syst = if (lib_type = "NewKey") then bir_symbexec_funcLib.new_key syst
			   else if (lib_type = "Encryption") then bir_symbexec_funcLib.Encryption syst
			   else if (lib_type = "Decryption") then bir_symbexec_funcLib.Decryption syst
			   else
			       raise ERR "funcLib" ("cannot handle" ^ (lib_type));

		(* update pc *)
		val s_tm = (fst o listSyntax.dest_list) bl_stmts;
		val s_tm_0 = List.nth (s_tm, 0);
		val (_, be) = dest_BStmt_Assign s_tm_0; (* extract bir expression *)
		val tgt = (mk_BL_Address o bir_expSyntax.dest_BExp_Const) be; (* make next address *)
		    
		val systs = List.map (SYST_update_pc tgt) [syst];(* update symb_state list with new pc *)

	    in
		systs
	    end
	    handle e => raise wrap_exn ("symb_exec_library_block::" ^ term_to_string lbl_tm) e end;

(* function for run a normal symbolic execution block *)
fun symb_exec_normal_block abpfun n_dict bl_dict syst =
	let val lbl_tm = SYST_get_pc syst; in
	 let  
	     val bl = (valOf o (lookup_block_dict bl_dict)) lbl_tm;
	     val (lbl_block_tm, stmts, est) = dest_bir_block bl;
		val _ = if true then () else
			print_term (lbl_block_tm);
		
		val s_tms = (fst o listSyntax.dest_list) stmts;

		val debugOn = false;
		val _ = if not debugOn then () else
			(print_term bl; print "\n ==================== \n\n");

		val systs2 = List.foldl (fn (s, systs) => List.concat(List.map (fn x => symb_exec_stmt (s,x)) systs)) [syst] s_tms;
		    
		(* generate list of states from end statement *)
		val systs = List.concat(List.map (symb_exec_endstmt n_dict lbl_tm est) systs2);
		(*val systs_processed = abpfun systs;*) (*we need to fix it later*)
	    in
		systs(*_processed*)
	    end
    handle e => raise wrap_exn ("symb_exec_normal_block::" ^ term_to_string lbl_tm) e end;

(* execution of a whole block *)
    fun symb_exec_block abpfun n_dict bl_dict syst =
	let val lbl_tm = SYST_get_pc syst; in
	    let
		val bl = (valOf o (lookup_block_dict bl_dict)) lbl_tm;
		val (lbl_block_tm, stmts, est) = dest_bir_block bl;
		val pc_type = bir_symbexec_oracleLib.fun_oracle est syst;
		    val _ = if false then () else
			print ("pc_type: " ^ (pc_type) ^ "\n");
	    in
		if (pc_type = "Adversary") then symb_exec_adversary_block abpfun n_dict bl_dict syst
		else if (pc_type = "Library") then symb_exec_library_block abpfun n_dict bl_dict syst
		else symb_exec_normal_block abpfun n_dict bl_dict syst
	    end
	    handle e => raise wrap_exn ("symb_exec_block::" ^ term_to_string lbl_tm) e end;

  (* execution of blocks until not running anymore or end label set is reached *)
  fun symb_exec_to_stop _      _      _       []                  _            acc =
        (symb_exec_to_stop_last_print := NONE; acc)
    | symb_exec_to_stop abpfun n_dict bl_dict (exec_st::exec_sts) stop_lbl_tms acc =
        let
          val lastTime = !symb_exec_to_stop_last_print;
          val timeToPrint = (Time.fromReal o LargeReal.-) (Time.toReal(Time.now()), LargeReal.fromInt 5);
          val _ = if not(isSome lastTime) orelse
                     Time.<(valOf lastTime, timeToPrint) then (
                    symb_exec_to_stop_last_print := SOME (Time.now());
                    print ("current number of stopped states: " ^ (Int.toString (length acc)) ^ "\n")
                  ) else ();

          fun is_state_stopped syst =
            (List.exists (fn x => identical (SYST_get_pc syst) x) stop_lbl_tms) orelse
            (not o state_is_running) syst;
	      
          val exec_stopped = is_state_stopped exec_st;

          val _ = if (not exec_stopped) orelse true then () else
                  print ("stops: " ^ (Int.toString ((List.length acc) + 1)) ^ "\n");

          val sts = if exec_stopped then [] else
                    symb_exec_block abpfun n_dict bl_dict exec_st;

          val new_exec_sts = sts@exec_sts;
          val new_acc = if exec_stopped then
                          exec_st::acc
                        else
                          acc;
        in
          symb_exec_to_stop abpfun n_dict bl_dict new_exec_sts stop_lbl_tms new_acc
        end;
end (* local *)

end (* outermost local *)

end (* struct *)
