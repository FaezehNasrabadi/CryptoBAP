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
	(* generate a fresh variable *)
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit32”));

	(* update path condition *)
	val biv = Fr iv;
	val syst = SYST_update_pred ((biv)::(SYST_get_pred syst)) syst;

	val senc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit32”));
	val stmt = ``BStmt_Assign (senc)
			(enc
			     (BVar "R0" (BType_Imm Bit32))
			     (iv)
			     (BVar "R1" (BType_Imm Bit32)))``;

	(* update environment *)
	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	val env   = SYST_get_env syst;
	val env'  = Redblackmap.insert (env, bv, senc);
	val syst = (SYST_update_env env') syst;

    in
	syst
    end;
 
fun Decryption syst =
    let
	val pred = SYST_get_pred syst;
	val (pred_y, pred_n) =  List.partition (String.isSuffix "_iv" o fst o bir_envSyntax.dest_BVar_string) pred;
	val last_pred_bv = hd pred_y
            handle Empty => raise ERR "Decryption" "pred is empty!";

	val iv = rev_Fr last_pred_bv;

	val sdec = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit32”));
	val stmt = ``BStmt_Assign (sdec)
			(dec
			     (BVar "R0" (BType_Imm Bit32))
			     (iv)
			     (BVar "R1" (BType_Imm Bit32)))``;

	(* update environment *)
	val bv = ``BVar "R0" (BType_Imm Bit32)``;
	val env   = SYST_get_env syst;
	val env'  = Redblackmap.insert (env, bv, sdec);
	val syst = (SYST_update_env env') syst;

	(* update path condition *)
	val (bv_str, _) = bir_envSyntax.dest_BVar_string last_pred_bv;
	val (pred_keep, _) =  List.partition (not o String.isSuffix bv_str o fst o bir_envSyntax.dest_BVar_string) pred;
	val syst = SYST_update_pred pred_keep syst;
	    
    in
	syst
    end;
  
end(*local*)

end (* struct *)

