structure bir_symbexec_stepLib =
struct

local
  open bir_symbexec_stateLib;
  open bir_symbexec_coreLib;
  open binariesLib;
  open Term;
  open Hol_pp;
  open HolKernel Parse boolLib bossLib;
  open HolBACoreSimps;
  open bir_expSyntax;
  open bir_programSyntax;
  open bir_immSyntax;
  open bir_envSyntax;

  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_stepLib"
  val wrap_exn = Feedback.wrap_exn   "bir_symbexec_stepLib"
		 
in (* outermost local *)

(* execution of a basic statement *)
local
  (* basic statement execution functions *)

  val bv_countw = bir_envSyntax.mk_BVar_string ("countw", ``(BType_Imm Bit64)``);
  fun state_exec_assign (bv, be) syst =
    if identical bv bv_countw andalso bir_expSyntax.is_BExp_IfThenElse be then
      let
        val (cnd, be1, be2) = bir_expSyntax.dest_BExp_IfThenElse be;
      in
	  if (bir_bool_expSyntax.is_bir_exp_true cnd) then [state_assign_bv bv be1 syst]
	  else if (bir_bool_expSyntax.is_bir_exp_false cnd) then [state_assign_bv bv be2 syst]
	  else
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
    (* no update if state is not running or in loop *)
    if (not (state_is_running syst orelse is_state_inloop syst)) then
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
    val jmp_label_match_tm = ``BStmt_Jmp (BLE_Label xyz)``;
  fun state_exec_try_jmp_label est syst =
    SOME (
    let
      val (vs, _) = hol88Lib.match jmp_label_match_tm est;
      val tgt     = (fst o hd) vs;
    in
      [SYST_update_pc tgt syst]
    end
    )
    handle HOL_ERR _ => NONE;

  val cjmp_label_match_tm = ``BStmt_CJmp xyzc (BLE_Label xyz1) (BLE_Label xyz2)``;
  exception state_exec_try_cjmp_exn;
  fun state_exec_try_cjmp_label est syst =
    SOME (
    let
	
      val (vs, _) = hol88Lib.match cjmp_label_match_tm est;
      val cnd     = fst (List.nth (vs, 0));
      val tgt1    = fst (List.nth (vs, 1));
      val tgt2    = fst (List.nth (vs, 2));
      val be      = if (is_BExp_Den cnd) then (bir_symbexec_funcLib.symbval_bexp (bir_symbexec_stateLib.get_state_symbv "CJmp" (dest_BExp_Den cnd) syst)) else cnd;

    in
	if ((bir_bool_expSyntax.is_bir_exp_true cnd) orelse (bir_bool_expSyntax.is_bir_exp_true be)) then [SYST_update_pc tgt1 syst]
	else if ((bir_bool_expSyntax.is_bir_exp_false cnd) orelse (bir_bool_expSyntax.is_bir_exp_false be)) then [SYST_update_pc tgt2 syst]
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

  fun exist_in_prog tgts ex_tgts =
      let
	  val res = if (List.exists (fn x => identical (hd tgts) x) prog_lbl_tms_)
		    then (hd tgts)::ex_tgts
		    else ex_tgts;
      in
	  if (List.null (tl tgts))
	  then  res
	  else (exist_in_prog (tl tgts) res)
      end;

(* add term for target equality *)       
fun add_tgt_equ tgt be =
    let

	val pred = ``(BExp_BinPred BIExp_Equal
		      ^tgt
		      ^be)
		     ``;   

    in
	pred
    end;
  val jmp_exp_var_match_tm = ``BStmt_Jmp (BLE_Exp x)``;
  exception state_exec_try_jmp_exp_var_exn;
  fun state_exec_try_jmp_exp_var n_dict lbl_tm est syst =
      SOME (
      let
	  val (vs, _) = hol88Lib.match jmp_exp_var_match_tm est
              handle _ => (
                     print ("couldn't match end statement: " ^ (term_to_string est) ^ "\n");
                     raise ERR "couldn't match" (term_to_string est));

	  val _ = if not (bir_symbexec_oracleLib.is_indirect_jmp n_dict lbl_tm) then raise state_exec_try_jmp_exp_var_exn
		  else raise state_exec_try_jmp_exp_var_exn;
    
	  val be_tgt  = (fst o hd) vs;

	      
	  val tgt = ``BVar "target" (BType_Imm Bit64)``;
	  val sy_tgt = get_bvar_init tgt;
	  val env  = (SYST_get_env syst);
	  val new_env = Redblackmap.insert (env,tgt,sy_tgt);
	  val syst = SYST_update_env new_env syst;
	      
	  val cnd = add_tgt_equ (bir_expSyntax.mk_BExp_Den tgt) be_tgt;
	  val syst = bir_symbexec_coreLib.state_add_pred "assert_true_cnd" cnd syst;
	      
	  val tgts = (check_feasible_exp be_tgt syst);	   
	      
	  val _ = if (List.null tgts) then raise state_exec_try_jmp_exp_var_exn
		  else ();

	  val targets =  List.map (fn t => (mk_BL_Address o bir_expSyntax.dest_BExp_Const) t) tgts;

	  val ts =  exist_in_prog targets [];
	  (* val _ = List.map (fn t => print (term_to_string(t)^"\n") ts); *)
      in
	  List.map (fn t => SYST_update_pc t syst) ts
      end
      )
      handle state_exec_try_jmp_exp_var_exn => NONE
           | e => raise wrap_exn ("state_exec_try_jmp_exp_var::") e;

  

  fun state_exec_try_jmp_exp_var_no_const syst =
      let
	  val indjmps = SYST_get_indjmp syst;
	  val tgt = (mk_BL_Address o bir_expSyntax.dest_BExp_Const o hd) indjmps;
	  val syst = SYST_update_indjmp (tl indjmps) syst;    
      in
	  [SYST_update_pc tgt syst]
      end;
    
in (* local *)
  fun symb_exec_endstmt n_dict lbl_tm est syst = (
    (* no update if state is not running or in loop *)
    if (not (state_is_running syst orelse is_state_inloop syst)) then [syst] else
    (* try to match direct jump *)
    case state_exec_try_jmp_label est syst of
       SOME systs => systs
     | NONE       => (
    (* try to match direct branch *)
    case state_exec_try_cjmp_label est syst of
       SOME systs => systs
     | NONE       => (
    (* try to match indirect jump *)
    case state_exec_try_jmp_exp_var n_dict lbl_tm est syst of
       SOME systs => systs
     | NONE       => (
       state_exec_try_jmp_exp_var_no_const syst
    ))))
   handle e =>
     raise wrap_exn (term_to_string lbl_tm) e;
end (* local *)

local
    open bir_block_collectionLib;

    val symb_exec_to_stop_last_print = ref (NONE : Time.time option);
in (* local *)


(* handle adversary code *)
fun symb_exec_adversary_block abpfun n_dict bl_dict syst =
    let val lbl_tm = SYST_get_pc syst; in
	    let
		(* val _ = print ("Adv \n"); *)
		val bl = (valOf o (lookup_block_dict bl_dict)) lbl_tm;

		val (lbl_block_tm, bl_stmts, est) = dest_bir_block bl;

		val syst = if ((not o List.null o fst o listSyntax.dest_list) bl_stmts)
		   then
		        bir_symbexec_funcLib.store_link bl_stmts syst(* store link register *)
		   else
		       syst;		    	

		val av = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Adv", “BType_Mem Bit64 Bit8”)); (* generate a fresh variable *)

		val syst = bir_symbexec_funcLib.Adv av syst; (* update env, vals & pred *)
		    
		val systs = if ((not o List.null o fst o listSyntax.dest_list) bl_stmts)
			    then
				[bir_symbexec_funcLib.update_pc syst](* update symb_state with new pc *)
			    else		
				let
				    val wpc = (bir_immSyntax.dest_Imm64 o dest_BL_Address) lbl_tm;
				    val incpc = (rhs o concl o EVAL o wordsSyntax.mk_word_add) (wpc,``4w:word64``);
				    val tgt = (mk_BL_Address o bir_immSyntax.mk_Imm64) incpc;
				in
				    [SYST_update_pc tgt syst](* update symb_state  with new pc *)
				end;

		val systs_processed = abpfun systs; 
	    in
		systs_processed
	    end
	    handle e => raise wrap_exn ("symb_exec_adversary_block::" ^ term_to_string lbl_tm) e end;

(* handle library code *)
fun symb_exec_library_block abpfun n_dict bl_dict adr_dict syst =
    let val lbl_tm = SYST_get_pc syst; in
	let
	    val _ = if true then () else
		    print_term (lbl_tm);
	    val bl = (valOf o (lookup_block_dict bl_dict)) lbl_tm;

		val (lbl_block_tm, bl_stmts, est) = dest_bir_block bl;

		val syst = if ((not o List.null o fst o listSyntax.dest_list) bl_stmts)
		   then
		        bir_symbexec_funcLib.store_link bl_stmts syst(* store link register *)
		   else
		       syst;		    	

		val lib_type = bir_symbexec_oracleLib.lib_oracle adr_dict lbl_tm syst; (* detect type of library call *)

		val _ = if true then () else
			if (lib_type = "C_Lib") then () else
			print ("Lib type: " ^ (lib_type) ^ "\n");

(* For WireGuard case-study *)
		val systs = if (lib_type = "HMAC_send") then [bir_symbexec_funcLib.HMAC_Send syst]
			    else if (lib_type = "HMAC_receive") then [bir_symbexec_funcLib.HMAC_Receive syst]
			    else if (lib_type = "NewKey") then [bir_symbexec_funcLib.new_key syst]
			    else if (lib_type = "SKey") then [bir_symbexec_funcLib.session_key syst]
			    else if (lib_type = "Encryption") then [bir_symbexec_funcLib.Encryption syst]
			    else if (lib_type = "Decryption") then [bir_symbexec_funcLib.Decryption syst]
			    else if (lib_type = "Signature") then [bir_symbexec_funcLib.Signature syst]
			    else if (lib_type = "Verify") then [bir_symbexec_funcLib.Verify syst]
			    else if (lib_type = "MEMcpy") then [bir_symbexec_funcLib.New_memcpy syst]
			    else if (lib_type = "LoadFile") then [bir_symbexec_funcLib.Load_file syst]
			    else if (lib_type = "OTP") then [bir_symbexec_funcLib.One_Time_Pad syst]
			    else if (lib_type = "RNG") then [bir_symbexec_funcLib.Random_Number syst]
			    else if (lib_type = "XOR") then [bir_symbexec_funcLib.Xor syst]
			    else if (lib_type = "kdfPtoS") then [bir_symbexec_funcLib.KeyDF1 syst]
			    else if (lib_type = "kdfStoP") then [bir_symbexec_funcLib.KeyDF2 syst]
			    else if (lib_type = "concat") then [bir_symbexec_funcLib.Concat syst]
			    else if (lib_type = "Concat1") then [bir_symbexec_funcLib.KeyDF22 syst]
			    else if (lib_type = "Concat2") then [bir_symbexec_funcLib.Concat2 syst]
			    else if (lib_type = "Pars1") then [bir_symbexec_funcLib.Parse1 syst]
			    else if (lib_type = "Pars2") then [bir_symbexec_funcLib.Parse2 syst]
			    else if (lib_type = "compare") then (bir_symbexec_funcLib.Compare syst)
			    else if (lib_type = "Fail") then [SYST_update_status BST_AssumptionViolated_tm syst]
			    else if ((lib_type = "event1") orelse (lib_type = "event2") orelse (lib_type = "event3")) then (bir_symbexec_funcLib.Event lib_type syst)
			    else [syst];
(*
(* For other case-studies *)
		val systs = if (lib_type = "HMAC_send") then [bir_symbexec_funcLib.HMAC_Send syst]
			    else if (lib_type = "HMAC_receive") then [bir_symbexec_funcLib.HMAC_Receive syst]
			    else if (lib_type = "NewKey") then [bir_symbexec_funcLib.new_key syst]
			    else if (lib_type = "SKey") then [bir_symbexec_funcLib.session_key syst]
			    else if (lib_type = "Encryption") then [bir_symbexec_funcLib.Encryption syst]
			    else if (lib_type = "Decryption") then [bir_symbexec_funcLib.Decryption syst]
			    else if (lib_type = "Signature") then [bir_symbexec_funcLib.Signature syst]
			    else if (lib_type = "Verify") then bir_symbexec_funcLib.Verify syst
			    else if (lib_type = "MEMcpy") then [bir_symbexec_funcLib.New_memcpy syst]
			    else if (lib_type = "LoadFile") then [bir_symbexec_funcLib.Load_file syst]
			    else if (lib_type = "OTP") then [bir_symbexec_funcLib.One_Time_Pad syst]
			    else if (lib_type = "RNG") then [bir_symbexec_funcLib.Random_Number syst]
			    else if (lib_type = "XOR") then [bir_symbexec_funcLib.Xor syst]
			    else if (lib_type = "kdfPtoS") then [bir_symbexec_funcLib.KDF syst]
			    else if (lib_type = "kdfStoP") then [bir_symbexec_funcLib.KDF syst]
			    else if (lib_type = "concat") then [bir_symbexec_funcLib.Concat syst]
			    else if (lib_type = "Concat1") then [bir_symbexec_funcLib.Concat1 syst]
			    else if (lib_type = "Concat2") then [bir_symbexec_funcLib.Concat2 syst]
			    else if (lib_type = "Pars1") then [bir_symbexec_funcLib.Parse1 syst]
			    else if (lib_type = "Pars2") then [bir_symbexec_funcLib.Parse2 syst]
			    else if (lib_type = "compare") then (bir_symbexec_funcLib.Compare syst)
			    else if (lib_type = "Fail") then [SYST_update_status BST_AssumptionViolated_tm syst]
			    else if ((lib_type = "event1") orelse (lib_type = "event2") orelse (lib_type = "event3")) then (bir_symbexec_funcLib.Event lib_type syst)
			    else [syst];
 *)
		val systs = if ((not o List.null o fst o listSyntax.dest_list) bl_stmts)
			    then
				(List.map (fn x => bir_symbexec_funcLib.update_pc x) systs)(* update symb_state with new pc *)
			    else		
				let
				    val wpc = (bir_immSyntax.dest_Imm64 o dest_BL_Address) lbl_tm;
				    val incpc = (rhs o concl o EVAL o wordsSyntax.mk_word_add) (wpc,``4w:word64``);
				    val tgt = (mk_BL_Address o bir_immSyntax.mk_Imm64) incpc;
				in
				    (List.map (fn x => SYST_update_pc tgt x) systs)(* update symb_state  with new pc *)
				end;
		    val debugOn = false;
	     val _ = if not debugOn then () else
		     (print_term bl; print "\n ==================== \n\n");

		val systs_processed = abpfun systs; 
	    in
		systs_processed
	    end
	    handle e => raise wrap_exn ("symb_exec_library_block::" ^ term_to_string lbl_tm) e end;
    
(* function for run a normal symbolic execution block *)
fun symb_exec_normal_block abpfun n_dict bl_dict syst =
	let val lbl_tm = SYST_get_pc syst; in
	    let
		val _ = if true then () else
			print_term (lbl_tm);
	     val bl = (valOf o (lookup_block_dict bl_dict)) lbl_tm;
	     val (lbl_block_tm, stmts, est) = dest_bir_block bl;

	     val _ = if true then () else
		     print_term (SYST_get_status syst);

	     val _ = if true then () else
		     print_term (lbl_block_tm);

	     val _ = if true then () else
		     print_term (est);

	     val s_tms = (fst o listSyntax.dest_list) stmts;


	     val syst = if bir_symbexec_oracleLib.is_function_call n_dict lbl_tm
		     then
			 if ((not o List.null o fst o listSyntax.dest_list) stmts)
			 then
			     let
				 val s_tm_0 = List.nth (s_tms, 0);
				 val (bv, be) = dest_BStmt_Assign s_tm_0;
				 val indjmps = SYST_get_indjmp syst;   
			     in
				 SYST_update_indjmp (be::indjmps) syst
			     end
			 else syst
		     else syst;
		 
	     val debugOn = false;
	     val _ = if not debugOn then () else
		     (print_term bl; print "\n ==================== \n\n");

	     val systs2 = List.foldl (fn (s, systs) => List.concat(List.map (fn x => symb_exec_stmt (s,x)) systs)) [syst] s_tms;   
	     (* generate list of states from end statement *)

	    val systs =  List.concat(List.map (symb_exec_endstmt n_dict lbl_tm est) systs2);
	    val systs_processed = abpfun systs;
			 
	    in
		systs_processed
	    end
    handle e => raise wrap_exn ("symb_exec_normal_block::" ^ term_to_string lbl_tm) e end;

fun state_exec_loop_true bl_dict syst =
    let
	val lbl_tm = SYST_get_pc syst;

	val exit_adr = bir_symbexec_loopLib.next_pc lbl_tm;
	    
	val bl = (valOf o (lookup_block_dict bl_dict)) lbl_tm;

	val (lbl_block_tm, stmts, est) = dest_bir_block bl;
	    
	val cjmp_label_match_tm = ``BStmt_CJmp xyzc (BLE_Label xyz1) (BLE_Label xyz2)``;
	val (vs, _) = hol88Lib.match cjmp_label_match_tm est;
	val cnd     = fst (List.nth (vs, 0));
	val tgt1    = fst (List.nth (vs, 1));
	val tgt2    = fst (List.nth (vs, 2));
    in
	if (identical tgt1 exit_adr)
	then (SYST_update_pc tgt2 syst)
	else (SYST_update_pc tgt1 syst)
    end;

exception state_exec_try_loop_exn;   
fun symb_exec_loop_block abpfun n_dict bl_dict adr_dict syst =
    let val lbl_tm = SYST_get_pc syst; in
	let
		
	    val systs_processed = if (is_state_inloop syst) then
			   let
			       val exit_adr = bir_symbexec_loopLib.next_pc lbl_tm;
				   
			       val syst = SYST_update_pc exit_adr syst;

			       val syst = SYST_update_status BST_Running_tm syst;

			       val bv_repend = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("RepEnd", “BType_Imm Bit64”)); (* generate a fresh variable *)

			       val Fr_bv =  bir_symbexec_funcLib.Fr bv_repend;
			       val syst =  SYST_update_pred ((Fr_bv)::(SYST_get_pred syst)) syst;
			       val syst =  bir_symbexec_funcLib.update_symbval (mk_BExp_Den bv_repend) Fr_bv syst; (* update symbolic value *)

			       val systs_processed = abpfun ([syst]);
				   
			       val _ = print("exit loop "^(term_to_string exit_adr)^"\n");
			   in
			       systs_processed
			   end
		       else if (state_is_running syst) then
			   let
			       val _ = print("enter loop "^(term_to_string lbl_tm)^"\n");

			       (* val _ = loop_flag := true; *)

			       val bv_rep = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Rep", “BType_Imm Bit64”)); (* generate a fresh variable *)

			       val Fr_bv =  bir_symbexec_funcLib.Fr bv_rep;
			       val syst =  SYST_update_pred ((Fr_bv)::(SYST_get_pred syst)) syst;
			       val syst =  bir_symbexec_funcLib.update_symbval (mk_BExp_Den bv_rep) Fr_bv syst; (* update symbolic value *)
				   
			       val syst = state_exec_loop_true bl_dict syst;
				   
			       val syst = SYST_update_status BST_InLoop_tm syst;

			       val pc_type = bir_symbexec_oracleLib.fun_oracle adr_dict (SYST_get_pc syst) syst;
				   
			       val systs_processed =  if (pc_type = "Adversary") then symb_exec_adversary_block abpfun n_dict bl_dict syst
						      else if (pc_type = "Library") then symb_exec_library_block abpfun n_dict bl_dict adr_dict syst
						      else if (pc_type = "Loop") then symb_exec_loop_block abpfun n_dict bl_dict adr_dict syst
						      else symb_exec_normal_block abpfun n_dict bl_dict syst;

			   in
			       systs_processed
			   end
			   else raise state_exec_try_loop_exn;
				   
	in
	    systs_processed
	end
	handle e => raise wrap_exn ("symb_exec_loop_block::" ^ term_to_string lbl_tm) e end;
    
(* execution of a whole block *)
    fun symb_exec_block abpfun n_dict bl_dict adr_dict syst =
	let val lbl_tm = SYST_get_pc syst; in
		let
		    val pc_type = bir_symbexec_oracleLib.fun_oracle adr_dict lbl_tm syst;

		    val _ = if true then () else
			    print_term (lbl_tm);
		    val _ = if true then () else
			    print ("pc_type: " ^ (pc_type) ^ "\n");
		in
		    if (pc_type = "Adversary") then symb_exec_adversary_block abpfun n_dict bl_dict syst
		    else if (pc_type = "Library") then symb_exec_library_block abpfun n_dict bl_dict adr_dict syst
		    else if (pc_type = "Loop") then symb_exec_loop_block abpfun n_dict bl_dict adr_dict syst
		    else symb_exec_normal_block abpfun n_dict bl_dict syst
		end
	    handle e => raise wrap_exn ("symb_exec_block::" ^ term_to_string lbl_tm) e end;

  (* execution of blocks until not running anymore or end label set is reached *)
  fun symb_exec_to_stop _      _      _       []                  _            _ acc =
        (symb_exec_to_stop_last_print := NONE; acc)
    | symb_exec_to_stop abpfun n_dict bl_dict (exec_st::exec_sts) stop_lbl_tms adr_dict acc =
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
            (not (state_is_running syst orelse is_state_inloop syst));
	      
          val exec_stopped = is_state_stopped exec_st;

          val _ = if (not exec_stopped) orelse true then () else
                  print ("stops: " ^ (Int.toString ((List.length acc) + 1)) ^ "\n");

          val sts = if exec_stopped then [] else
                    symb_exec_block abpfun n_dict bl_dict adr_dict exec_st;

	  val new_exec_sts = sts@exec_sts;
          val new_acc = if exec_stopped then
                          exec_st::acc
                        else
                            acc;

        in
          symb_exec_to_stop abpfun n_dict bl_dict new_exec_sts stop_lbl_tms adr_dict new_acc
        end;
end (* local *)

end (* outermost local *)

end (* struct *)
