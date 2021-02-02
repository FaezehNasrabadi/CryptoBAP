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
   [``BVar "R1" (BType_Imm Bit32)``, ``BVar "R0" (BType_Imm Bit32)``, ``BVar "R2" (BType_Imm Bit32)``];
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

fun decrypt bv_r0 iv bv_r2 =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit32))
			(dec
			     (bv_r0)
			     (iv)
			     (bv_r2))``;

    in
	dest_BStmt_Assign stmt
    end;

fun update_symbval new_symbval bv syst =
    let
	val vals  = SYST_get_vals syst;
	val deps = deps_find_symbval "deps of symbv" vals bv;
	val symbv' = SymbValBE (new_symbval,deps);   
	val vals' = Redblackmap.insert (vals, bv, symbv');

    in
	(SYST_update_vals vals') syst
    end;
    
fun update_pc bl_stmts syst =
    let
	val s_tm = (fst o listSyntax.dest_list) bl_stmts;
	val s_tm_0 = List.nth (s_tm, 0);
	val (_, be) = dest_BStmt_Assign s_tm_0; (* extract bir expression *)
	val tgt = (mk_BL_Address o bir_expSyntax.dest_BExp_Const) be; (* make next address *)
	    
	val systs = List.map (SYST_update_pc tgt) [syst];(* update symb_state list with new pc *)

    in
	systs
    end;
    
fun new_key syst =
    let
	(* generate a fresh variable *)
	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit32”));

	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	val syst =  update_envvar bv vn syst; (* update environment *)
	val syst = update_symbval vn bv syst; (* update symbolic value *)
	    
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

	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	    
	val syst =  update_envvar bv Fr_Enc syst; (* update environment *)
	val syst = update_symbval C_be bv syst; (* update symbolic value *)
	    	     
    in
	syst
    end;
 
fun Decryption syst =
    let
	(* get value from environment *)
	val env   = SYST_get_env syst;

	val iv = find_bv_val "bv_r1 not found" env ``BVar "R1" (BType_Imm Bit32)``;
	val bv_r0 = find_bv_val "bv_r0 not found" env ``BVar "R0" (BType_Imm Bit32)``;
	val bv_r2 = find_bv_val "bv_r2 not found" env ``BVar "R2" (BType_Imm Bit32)``;

	val (M_bv, M_be) = decrypt bv_r0 iv bv_r2; (* decrypt with iv *)

	val Fr_Dec = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit32”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Dec) (M_bv)``; (* assign value of R0 to the fresh variable *)

	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	    
	val syst =  update_envvar bv Fr_Dec syst; (* update environment *)
	val syst = update_symbval M_be bv syst; (* update symbolic value *)
			    
    in
	syst
    end;
  
end(*local*)

end (* struct *)

