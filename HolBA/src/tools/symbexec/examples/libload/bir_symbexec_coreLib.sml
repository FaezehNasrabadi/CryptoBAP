structure bir_symbexec_coreLib =
struct

local
    open HolKernel Parse boolLib bossLib;
    open HolBACoreSimps;
	 
  open bir_symbexec_stateLib;
  open bir_expSyntax;
  open bir_constpropLib;
  open bir_exp_helperLib;
  open binariesLib;

  val debugAssignments = false;
  val debugPaths = false;

  val ERR = Feedback.mk_HOL_ERR "bir_symbexec_coreLib"
in (* outermost local *)

(* primitive for symbolic/abstract computation for expressions *)
local
  

  fun subst_fun env vals (bev, (e, vars)) =
    let
      val bv_ofvals = find_bv_val "subst_fun" env bev;

      val (exp, vars') =
        let
          val symbv = find_bv_val "subst_fun" vals bv_ofvals;
          val expo = case symbv of
                       SymbValBE (x, _) => SOME x
                     | _ => NONE;
          val use_expo_var =
            isSome expo andalso
            (bir_expSyntax.is_BExp_Const o valOf) expo;
        in
          if use_expo_var then
            (valOf expo, vars)
          else raise ERR "subst_fun" "this is never seen"
        end
        handle _ => (mk_BExp_Den bv_ofvals, bv_ofvals::vars);
    in
      (subst_exp (bev, exp, e),
       vars')
    end;

  open bir_symbexec_compLib;

  fun compute_val_try compute_val_and_resolve_deps preds vals (besubst, besubst_vars) deps_l2 =
    let val _ = if not debugAssignments then () else
                (print "BESUBST: "; print_term besubst); in
    case compute_val_try_const_only vals (besubst, besubst_vars) deps_l2 of
        SOME x => SOME x
      | NONE => (
    case compute_val_try_single_interval vals (besubst, besubst_vars) of
        SOME x => SOME x
      | NONE => (
    case compute_val_try_expplusminusconst vals (besubst, besubst_vars) of
        SOME x => SOME x
      | NONE => (
         compute_val_try_mem compute_val_and_resolve_deps preds vals (besubst, besubst_vars)
    ))) end;

  fun compute_val_and_resolve_deps preds vals (besubst, besubst_vars) =
    let
      val deps_l2 = List.foldr (Redblackset.union)
                               symbvalbe_dep_empty
                               (List.map (deps_find_symbval "compute_val_and_resolve_deps" vals) besubst_vars);
    in
      case compute_val_try compute_val_and_resolve_deps preds vals (besubst, besubst_vars) deps_l2 of
         SOME x => x
       | NONE   =>
          let
            val deps = Redblackset.addList(deps_l2, besubst_vars);
            val be_new_val = SymbValBE (besubst, deps);
          in
            be_new_val
          end
    end;

  val sp_align_sub_const_match_tm = ``
        (BExp_BinExp BIExp_Minus
          (BExp_Align Bit64 2 (BExp_Den (BVar "SP_process" (BType_Imm Bit64))))
          (BExp_Const y))``;

  val sp_align_add_const_match_tm = ``
        (BExp_BinExp BIExp_Plus
          (BExp_Align Bit64 2 (BExp_Den (BVar "SP_process" (BType_Imm Bit64))))
          (BExp_Const y))``;

  val sp_align_r7_match_tm = ``
        (BExp_Align Bit64 2 (BExp_Den (BVar "R7" (BType_Imm Bit64))))``;

  fun simplify_be be syst =
    let
      val (vs, _) = hol88Lib.match sp_align_sub_const_match_tm be;
      val imm_val = fst (List.nth (vs, 0));

      val replacewith_tm = ``
        (BExp_BinExp BIExp_Minus
          (BExp_Den (BVar "SP_process" (BType_Imm Bit64)))
          (BExp_Const ^imm_val))``;

      val _ = if not debugAssignments then () else
              (print "- replace minus :"; print_term imm_val);

 
    in
      replacewith_tm
    end
    handle HOL_ERR _ => (
    let
      val (vs, _) = hol88Lib.match sp_align_add_const_match_tm be;
      val imm_val = fst (List.nth (vs, 0));

      val replacewith_tm = ``
        (BExp_BinExp BIExp_Plus
          (BExp_Den (BVar "SP_process" (BType_Imm Bit64)))
          (BExp_Const ^imm_val))``;

      val _ = if not debugAssignments then () else
              (print "- replace plus :"; print_term imm_val);


    in
      replacewith_tm
    end
    handle HOL_ERR _ => (
    let
      val (vs, _) = hol88Lib.match sp_align_r7_match_tm be;

      val replacewith_tm = ``
        BExp_Den (BVar "R7" (BType_Imm Bit64))``;

      val _ = if not debugAssignments then () else
              (print "- replace r7 :");


    in
      replacewith_tm
    end
    handle HOL_ERR _ => be));

in (* local *)

  val compute_val_and_resolve_deps = compute_val_and_resolve_deps;

  fun compute_valbe be syst =
    let
      val env   = SYST_get_env  syst;
      val vals  = SYST_get_vals syst;
      val preds = SYST_get_pred syst;

      val be_   = simplify_be be syst;

      val be_vars = get_birexp_vars be_;
      val besubst_with_vars = List.foldr (subst_fun env vals) (be_, []) be_vars;
    in
      compute_val_and_resolve_deps preds vals besubst_with_vars
    end;

end (* local *)
(* update exp  *)
fun abstract_exp_in_loop exp =
      if is_BExp_Const exp then
        (bir_expSyntax.mk_BExp_Den (get_bvar_fresh (bir_envSyntax.mk_BVar_string ("t", ``BType_Imm Bit64``))))
      else if is_BExp_MemConst exp then
         exp
      else if is_BExp_Den exp then
         exp
      else if is_BExp_Cast exp then
        let
          val (castt, exp1, sz) = (dest_BExp_Cast) exp;
          val exp_rw = abstract_exp_in_loop exp1;
        in
          (mk_BExp_Cast (castt, exp_rw, sz))
        end

      else if is_BExp_UnaryExp exp then
        let
          val (uop, exp1) = (dest_BExp_UnaryExp) exp;
          val exp_rw = abstract_exp_in_loop exp1;
        in
          (mk_BExp_UnaryExp (uop, exp_rw))
        end

      else if is_BExp_BinExp exp then
        let
          val (bop, exp1, exp2) = (dest_BExp_BinExp) exp;
          val exp1_rw = abstract_exp_in_loop exp1;
          val exp2_rw = abstract_exp_in_loop exp2;
        in
          (mk_BExp_BinExp (bop, exp1_rw, exp2_rw))
        end
      else if is_BExp_BinPred exp then
	  exp

      else if is_BExp_IfThenElse exp then
        let
          val (expc, expt, expf) = (dest_BExp_IfThenElse) exp;
          val expc_rw = abstract_exp_in_loop expc;
          val expt_rw = abstract_exp_in_loop expt;
          val expf_rw = abstract_exp_in_loop expf;
        in
          (mk_BExp_IfThenElse (expc_rw, expt_rw, expf_rw))
        end

      else if is_BExp_Load exp then
	  exp

      else if is_BExp_Store exp then
	  exp
      else
        raise (ERR "abstract_exp_in_loop" ("don't know BIR expression: \"" ^ (term_to_string exp) ^ "\""));	

(* primitive to compute expression and store result using fresh variable *)
  fun state_insert_symbval_from_be bv_fr be syst =
      insert_symbval bv_fr (compute_valbe be syst) syst;

      
(* primitives for adding conjuncts to the path predicate *)
  fun state_add_pred bv_str pred syst =
    let
      val bv = bir_envSyntax.mk_BVar_string (bv_str, bir_valuesSyntax.BType_Bool_tm);
      val bv_fresh = get_bvar_fresh bv;
    in
      (SYST_update_pred ((bv_fresh)::(SYST_get_pred syst)) o
       state_insert_symbval_from_be bv_fresh pred
      ) syst
    end;
      
(* primitives for adding conjuncts to the path predicate for assign *)
  fun state_add_pred_fr use_expo_var bv_fr symbv syst =
      if ((identical bir_valuesSyntax.BType_Bool_tm ((snd o bir_envSyntax.dest_BVar_string) bv_fr)) orelse use_expo_var)
      then (SYST_update_pred ((bv_fr)::(SYST_get_pred syst)) syst)
      else
	  let
	      val bv_str = (fst o bir_envSyntax.dest_BVar_string) bv_fr
	      val bv = bir_envSyntax.mk_BVar_string (bv_str, bir_valuesSyntax.BType_Bool_tm);
	  in
	      ((SYST_update_pred ((bv)::(SYST_get_pred syst)) o
		insert_symbval bv symbv
	       ) syst)
	  end;

      
(* primitive to carry out assignment *)
  fun state_assign_bv bv be syst =
    let
      val _ = if true then () else
              (print "\n\n===============\nASSIGN: "; print_term bv; print_term be);

      val symbv = compute_valbe be syst;

      
	      
      val expo = case symbv of
                    SymbValBE (x, _) => SOME x
                  | _ => NONE;


      val symbv' = case symbv of
                     SymbValBE (x, t) => (if ((is_state_inloop syst) andalso ((not o is_BExp_Const) x)) then SymbValBE ((abstract_exp_in_loop x), t) else SymbValBE (x, t))
                   | _ => symbv;
					  
	  
      val use_expo_var =
            isSome expo andalso
            (bir_expSyntax.is_BExp_Den o valOf) expo;

      val bv_fr = if use_expo_var then
                    (bir_expSyntax.dest_BExp_Den o valOf) expo
                  else
                      (get_bvar_fresh) bv;

      val _ = if ((is_state_inloop syst) andalso false)
	      then print (term_to_string bv_fr ^ " = \n")
	      else ();

      val _ = case symbv' of
                  SymbValBE (x, t) => (if ((is_state_inloop syst) andalso false) then print (term_to_string x ^ "\n\n") else ())
                | _ => ();

      val syst = state_add_pred_fr use_expo_var bv_fr symbv' syst;

    in
      (update_envvar bv bv_fr o
       (if use_expo_var then
          I
        else
          insert_symbval bv_fr symbv')
      ) syst
    end;

  fun state_make_interval bv syst =
    let
      val env    = SYST_get_env syst;
      val bv_val = find_bv_val "state_make_interval" env bv;
      val _ = if is_bvar_init bv_val then () else
              raise ERR "state_make_interval" "can only make interval values from initial variables currently";

      val exp   = ``
        BExp_BinExp BIExp_Plus
          ^(bir_expSyntax.mk_BExp_Den bv_val)
          (BExp_Const (Imm64 0w))``;

      val deps  = Redblackset.add (symbvalbe_dep_empty, bv_val);
      val symbv = SymbValInterval ((exp, exp), deps);

      val bv_fresh = (get_bvar_fresh) bv;
    in
      (update_envvar bv bv_fresh o
       insert_symbval bv_fresh symbv
      ) syst
    end;

  fun state_make_mem bv layout mem_const_fun bv_sp syst =
    let
      val env    = SYST_get_env syst;
      val bv_val = find_bv_val "state_make_mem" env bv;
      val _ = if is_bvar_init bv_val then () else
              raise ERR "state_make_mem" "can only make memory values from initial variables currently";

      val bv_sp_val = find_bv_val "state_make_mem" env bv_sp;
      val _ = if is_bvar_init bv_sp_val then () else
              raise ERR "state_make_mem" "can only make memory values from initial variables currently";


      (* constant memory (8-bit words) *)
      val mem_const = mem_const_fun;

      val mem_globl = Redblackmap.mkDict Arbnum.compare;

      (* stack memory *)
      val mem_stack = (bv_sp_val, Redblackmap.mkDict Arbnum.compare);

      val mem_parts = (mem_const, mem_globl, mem_stack);
      val deps  = Redblackset.add (symbvalbe_dep_empty, bv_val);
      val symbv = SymbValMem (bv_val, layout, mem_parts, deps);

      val bv_fresh = (get_bvar_fresh) bv;
    in
      (update_envvar bv bv_fresh o
       insert_symbval bv_fresh symbv
      ) syst
    end;


  fun state_add_preds bv_str preds syst =
    List.foldr (fn (pred, syst_) => state_add_pred bv_str pred syst_) syst preds;

(* primitive for removing the head of the path predicate *)
  fun state_remove_preds_by_suffix pred_suffix syst =
    let
      val preds = SYST_get_pred syst;
      val (preds_keep, preds_removed) =
        List.partition (not o String.isSuffix pred_suffix o
                        fst o bir_envSyntax.dest_BVar_string)
                       preds;

      (* notice: rely on tidy up state function for stale values *)
    in
      SYST_update_pred preds_keep syst
    end;

(* primitives for branching states based on a boolean condition expression *)
  fun state_branch str_prefix cnd f_bt f_bf syst =
    let
	val bv_str_t = str_prefix ^ "_true_cnd";
	val bv_str_f = str_prefix ^ "_false_cnd";

      val debugOn = debugPaths;

      val systs1 = (f_bt o state_add_pred bv_str_t cnd) syst;
      val systs2 = (f_bf o state_add_pred bv_str_f (bslSyntax.bnot cnd)) syst;
    in
      if not debugOn then
        systs1@systs2
      else
        systs1
    end;

  fun state_branch_simp str_prefix cnd f_bt f_bf syst =
      state_branch str_prefix cnd (fn s => [f_bt s]) (fn s => [f_bf s]) syst;

end (* outermost local *)

end (* struct *)
