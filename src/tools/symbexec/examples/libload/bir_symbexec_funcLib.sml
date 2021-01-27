structure bir_symbexec_funcLib =
struct

local
  open bir_symbexec_stateLib;
  open bir_symbexec_coreLib;
  open bir_block_collectionLib;
  open Redblackmap;
  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_funcLib"
in
(*val prog_vars =
   [];
  val lbl_tm = “BL_Address (Imm32 2808w)”;
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
         bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm32 2202w)))|>;]``;
val bl_dict  = bir_block_collectionLib.gen_block_dict prog;
*)

(*val _ = Parse.type_abbrev("key", ``:bir_exp_t -> bir_exp_t``);*)
    
val _ = Parse.type_abbrev("enc", ``:bir_var_t -> bir_var_t -> bir_var_t -> bir_exp_t``); 

val _ = Parse.type_abbrev("dec", ``:bir_var_t -> bir_var_t -> bir_var_t -> bir_exp_t``);
	      
(* NewKey = key(R1) 
val func_table  = Redblackmap.insert(Redblackmap.mkDict Term.compare,``(BL_Address (Imm32 2002w))``,
				     ``(BStmt_Assign (BVar "R0" (BType_Imm Bit32))
						     (key
							  (BExp_Den (BVar "R1" (BType_Imm Bit32)))):α bir_stmt_basic_t)``);

(* Enc(k,m) = enc(k,n,m) = enc(R1,R2,R3) *)
val func_table  = Redblackmap.insert(Redblackmap.mkDict Term.compare,``(BL_Address (Imm32 2002w))``,
				     ``(BStmt_Assign (BVar "R0" (BType_Imm Bit32))
								   (enc
									(BExp_Den (BVar "R0" (BType_Imm Bit32)))
									(BExp_Den (BVar "iv" (BType_Imm Bit32)))
									(BExp_Den (BVar "R1" (BType_Imm Bit32)))):α bir_stmt_basic_t)``);    

(* Dec(k,m) = dec(k,n,m) = dec(R1,R2,R3) *) 
val func_table  = Redblackmap.insert(func_table, ``(BL_Address (Imm32 2502w))``,
				     ``(BStmt_Assign (BVar "R0" (BType_Imm Bit32))
								   (dec
									(BExp_Den (BVar "R1" (BType_Imm Bit32)))
									(BExp_Den (BVar "R2" (BType_Imm Bit32)))
									(BExp_Den (BVar "R3" (BType_Imm Bit32)))))``);*)

(*listItems func_table;
val lbl_tm = ``(BL_Address (Imm32 2002w))``;*)
(*
fun all_func lbl_tm =
    let
	val stmts = (valOf o (lookup_block_dict func_table)) lbl_tm;
    in
	stmts
    end;
*)
(*val prog_vars =
   [“BVar "R11" (BType_Imm Bit32)”, “BVar "R10" (BType_Imm Bit32)”];
  val lbl_tm = “BL_Address (Imm32 2202w)”;
  val syst = init_state lbl_tm prog_vars;
  val stmts = all_func lbl_tm;
      listItems env';
 *)
    
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

fun enc iv =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit32))
			(enc
			     (BVar "R0" (BType_Imm Bit32))
			     (iv)
			     (BVar "R1" (BType_Imm Bit32)))``;
	val (bv, _) = dest_BStmt_Assign stmt;

    in
	bv
    end;

fun dec iv =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit32))
			(dec
			     (BVar "R0" (BType_Imm Bit32))
			     (iv)
			     (BVar "R2" (BType_Imm Bit32)))``;
	val (bv, _) = dest_BStmt_Assign stmt;

    in
	bv
    end;

fun new_key syst =
    let
	(* generate a fresh variable *)
	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit32”));

	(* update environment *)
	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	val env   = SYST_get_env syst;
	val env'  = Redblackmap.insert (env, bv, vn);
	val syst = (SYST_update_env env') syst;
	    
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

	val Cipher = enc iv; (* encrypt with iv *)

	val Fr_Enc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit32”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Enc) (Cipher)``; (* assign value of R0 to the fresh variable *)

	(* update environment *)
	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	val env   = SYST_get_env syst;
	val env'  = Redblackmap.insert (env, bv, Fr_Enc);
	val syst = (SYST_update_env env') syst;

    in
	syst
    end;
 
fun Decryption syst =
    let

	val iv = ``BVar "R1" (BType_Imm Bit32)``; (* input from user *)

	val Msg = dec iv; (* decrypt with iv *)

	val Fr_Dec = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit32”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Dec) (Msg)``; (* assign value of R0 to the fresh variable *)

	(* update environment *)
	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	val env   = SYST_get_env syst;
	val env'  = Redblackmap.insert (env, bv, Fr_Dec);
	val syst = (SYST_update_env env') syst;
	    
    in
	syst
    end;
  
end(*local*)

end (* struct *)

