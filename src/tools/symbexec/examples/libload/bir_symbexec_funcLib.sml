structure bir_symbexec_funcLib =
struct

local
  open bir_symbexec_stateLib;
  open bir_symbexec_coreLib;
  open bir_block_collectionLib;
  open Redblackmap;
  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_funcLib"
in
(*
 val prog_vars =
   [``BVar "R1" (BType_Imm Bit32)``, ``BVar "R0" (BType_Imm Bit32)``, ``BVar "R2" (BType_Imm Bit32)``, “BVar "R30" (BType_Imm Bit32)”];
  val lbl_tm = “BL_Address (Imm32 2802w)”;
  val syst = init_state lbl_tm prog_vars;
  val bv = ``BVar "R0" (BType_Imm Bit32)``;
  val deps = Redblackset.add (symbvalbe_dep_empty, bv);
  val symbv = SymbValBE (bv,deps);
  val syst = bir_symbexec_stateLib.insert_symbval bv symbv syst;
      Redblackset.listItems(deps);
      listItems(SYST_get_env syst);
      listItems(SYST_get_vals syst);
*)
  
val _ = Parse.type_abbrev("enc", ``:bir_var_t -> bir_var_t -> bir_var_t -> bir_exp_t``); 

val _ = Parse.type_abbrev("dec", ``:bir_var_t -> bir_var_t -> bir_var_t -> bir_exp_t``);
  
fun Fr var =
    let
	 val (bv_str, _) = bir_envSyntax.dest_BVar_string var;
	 val bv =  bir_envSyntax.mk_BVar_string (bv_str, bir_valuesSyntax.BType_Bool_tm);
    in
	bv
    end;

fun rev_Fr bv =
    let
	 val (bv_str, _) = bir_envSyntax.dest_BVar_string bv;
	 val var =  bir_envSyntax.mk_BVar_string (bv_str, “BType_Imm Bit32”);
    in
	var
    end;

fun deduce bv_fresh bv_r0 =
    let
	val stmt = ``BStmt_Assign (BVar "R0" BType_Bool)
		     (BExp_BinPred BIExp_NotEqual
				   (BExp_Den (bv_fresh))
				   (BExp_Den (bv_r0)))``;
    in
	dest_BStmt_Assign stmt
    end;
    
fun encrypt bv_r0 iv bv_r1 =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit32))
			(enc
			     (bv_r0)
			     (iv)
			     (bv_r1))``;

    in
	dest_BStmt_Assign stmt
    end;

fun decrypt bv_r6 bv_r7 bv_r8 =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit32))
			(dec
			     (bv_r6)
			     (bv_r7)
			     (bv_r8))``;

    in
	dest_BStmt_Assign stmt
    end;

fun symbval_bexp symbv =
    let
	val bexp =
	    case symbv of
		SymbValBE (exp,_) => exp
              | SymbValInterval ((exp1,exp2), _) => exp1 (* we need to fix it later*)
              | SymbValMem (exp, _, _, _) => exp (* we need to fix it later*)
	      | _ => raise ERR "symbval_bexp" "cannot handle symbolic value type";
    in
	bexp
    end;

fun update_symbval new_symbval Fr_bv syst =
    let
	val symbv' = SymbValBE (new_symbval,symbvalbe_dep_empty);
	val syst = insert_symbval Fr_bv symbv' syst;

    in
	syst
    end;
  
fun store_link bl_stmts syst =
    let
	val s_tm = (fst o listSyntax.dest_list) bl_stmts;
	val s_tm_0 = List.nth (s_tm, 0);
	val (bv, be) = dest_BStmt_Assign s_tm_0; (* extract bir expression *)
	val Fr_bv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("R30", “BType_Imm Bit32”)); (* generate a fresh iv *)
	val syst =  update_envvar bv Fr_bv syst; (* update environment *)
	val syst = update_symbval be Fr_bv syst; (* update symbolic value *)
    in
	syst
    end;

fun update_pc syst =
    let
	val bv = ``BVar "R30" (BType_Imm Bit32)``;

	val symbv = get_state_symbv "symbv not found" bv syst;

	val be = symbval_bexp symbv; (* extract bir expression *) 

	val tgt = (mk_BL_Address o bir_expSyntax.dest_BExp_Const) be; (* make next address *)
	    
	val systs = List.map (SYST_update_pc tgt) [syst];(* update symb_state list with new pc *)

    in
	systs
    end;

fun Adv bv_fresh syst =
    let
	(* get value from environment *)
	val env   = SYST_get_env syst;

	val bv_r0 = find_bv_val "bv_r0 not found" env ``BVar "R0" (BType_Imm Bit32)``;

	val (A_bv, A_be) = deduce bv_fresh bv_r0;

	val syst = SYST_update_pred ((A_bv)::(SYST_get_pred syst)) syst;(* add bool value to path condition and update state*)   

	val bv = ``BVar "R0" (BType_Imm Bit32)``;
		 
	val syst =  update_envvar bv bv_fresh syst; (* update environment *)

	val Fr_bv = get_bvar_fresh bv;
	    
	val syst = update_symbval bv_fresh Fr_bv syst; (* update symbolic value *)
	val syst = update_symbval A_be A_bv syst; (* update symbolic value for deduction *)
	    
    in
	syst
    end;
        
fun new_key syst =
    let
	(* generate a fresh variable *)
	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit32”));

	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	val syst =  update_envvar bv vn syst; (* update environment *)
	val Fr_bv = get_bvar_fresh bv;	    
	val syst = update_symbval vn Fr_bv syst; (* update symbolic value *)
	    
	(* update path condition *)
	val Fr_vn = Fr vn;
	val syst = SYST_update_pred ((Fr_vn)::(SYST_get_pred syst)) syst;
    in
	syst
    end;   

fun Encryption syst =
    let
	
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit32”)); (* generate a fresh iv *)

	(* update path condition *)
	val biv = Fr iv;
	val syst = SYST_update_pred ((biv)::(SYST_get_pred syst)) syst;

	(* get value from environment *)
	val env   = SYST_get_env syst;

	val bv_r0 = find_bv_val "bv_r0 not found" env ``BVar "R0" (BType_Imm Bit32)``;
	val bv_r1 = find_bv_val "bv_r1 not found" env ``BVar "R1" (BType_Imm Bit32)``;

	val (C_bv, C_be) = encrypt bv_r0 iv bv_r1; (* encrypt with iv *)

	val Fr_Enc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit32”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Enc) (C_bv)``; (* assign value of R0 to the fresh variable *)
	    
	(* update environment *)
	val bv0 = ``BVar "R0" (BType_Imm Bit32)``;
	val bv7 = ``BVar "R7" (BType_Imm Bit32)``;
	    
	val syst =  update_envvar bv0 Fr_Enc syst;
	val syst =  update_envvar bv7 iv syst; 

	(* update symbolic value *)
	val Fr_bv0 = get_bvar_fresh bv0;
	val syst = update_symbval C_be Fr_bv0 syst;
	val Fr_bv7 = get_bvar_fresh bv7;
	val syst = update_symbval iv Fr_bv7 syst;     
	    	     
    in
	syst
    end;
 
fun Decryption syst =
    let
	(* get value from environment *)
	val env   = SYST_get_env syst;

	val bv_r6 = find_bv_val "bv_r6 not found" env ``BVar "R6" (BType_Imm Bit32)``;
	val bv_r7 = find_bv_val "bv_r7 not found" env ``BVar "R7" (BType_Imm Bit32)``;
	val bv_r8 = find_bv_val "bv_r8 not found" env ``BVar "R8" (BType_Imm Bit32)``;

	val (M_bv, M_be) = decrypt bv_r6 bv_r7 bv_r8; (* decrypt with iv *)

	val Fr_Dec = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit32”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Dec) (M_bv)``; (* assign value of R0 to the fresh variable *)

	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	    
	val syst =  update_envvar bv Fr_Dec syst; (* update environment *)
	val Fr_bv = get_bvar_fresh bv;
	val syst = update_symbval M_be Fr_bv syst; (* update symbolic value *)
			    
    in
	syst
    end;
  
end(*local*)

end (* struct *)

