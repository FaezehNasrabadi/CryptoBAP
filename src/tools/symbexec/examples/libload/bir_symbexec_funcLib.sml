structure bir_symbexec_funcLib =
struct

local
  open bir_symbexec_stateLib;
  open bir_symbexec_coreLib;
  open bir_block_collectionLib;
  open Redblackmap;
  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_funcLib"
in

val func_table  = Redblackmap.insert(Redblackmap.mkDict Term.compare,``(BL_Address (Imm32 2002w))``, ``(BStmt_Assign (BVar "R0" (BType_Imm Bit32)) (BExp_Const (Imm32 (4w :word32))) :α bir_stmt_basic_t)``);

   (* listItems func_table;*)

val func_table  = Redblackmap.insert(func_table, ``(BL_Address (Imm32 2004w))``, ``(BStmt_Assign (BVar "R0" (BType_Imm Bit32)) (BExp_Const (Imm32 (36w :word32))))``);
val func_table  = Redblackmap.insert(func_table, ``(BL_Address (Imm32 2006w))``, ``(BStmt_Assign (BVar "R0" (BType_Imm Bit32)) (BExp_Const (Imm32 (0w :word32))))``);
(*listItems func_table;
val lbl_tm = ``(BL_Address (Imm32 2004w))``;*)

fun all_func lbl_tm =
    let
	val stmts = (valOf o (lookup_block_dict func_table)) lbl_tm;
    in
	stmts
    end;

(*val prog_vars =
   [“BVar "R11" (BType_Imm Bit32)”, “BVar "R10" (BType_Imm Bit32)”];
  val lbl_tm = “BL_Address (Imm32 3076w)”;
  val syst = init_state lbl_tm prog_vars;*)

fun random_key syst =
     let    
	 val bv_fresh = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit32”)); (* generate a fresh variable *)
	 val pred = SYST_get_pred syst; (* get current path condition *)
	 val syst = SYST_update_pred ((bv_fresh)::(pred)) syst;(* add the fresh variable to path condition and update state*)
    in
	syst
    end;   
(*
val _ = Parse.type_abbrev("Senc", ``:word32 -> word32 -> word32 -> word32``); 

val _ = Parse.type_abbrev("Sdec", ``:word32 -> word32 -> word32 -> word32``);

fun senc m k n =
    let
	val b = AES k n;
	val c = b xor m;
    in
	c
    end;

fun sdec c k n =
    let
	val b = AES k n;
	val m = b xor c; 
    in
	m
    end;
*)    
end(*local*)

end (* struct *)

