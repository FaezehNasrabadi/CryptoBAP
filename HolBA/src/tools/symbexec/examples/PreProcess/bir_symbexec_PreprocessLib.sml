structure bir_symbexec_PreprocessLib =
struct

local
    open HolKernel Parse;
    open binariesLib;
    open binariesTheory;
    open binariesCfgLib;
    open binariesMemLib;
    open bir_programSyntax;
    open bir_valuesSyntax;
    open bir_immSyntax;
    open bir_exec_typingLib;
    open bir_cfgLib;
    open bir_cfg_m0Lib;
    open bir_block_collectionLib;
    open bir_envSyntax;
    open bir_expSyntax;
    open bir_auxiliaryLib;
    open bir_immSyntax;
    open wordsSyntax;
    open String;
    open bir_program_labelsSyntax;
    open bir_block_collectionLib;
    open Redblackmap;
  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_PreprocessLib"
in
(*
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict_ prog_lbl_tms_;

val n = valOf (peek (n_dict, “BL_Address (Imm64 268437120w)”));

# val n =
   {CFGN_hc_descr = SOME "A9BE53F3 (stp x19, x20, [sp, #-32]!)",
    CFGN_lbl_tm = “BL_Address (Imm64 4235844w)”, CFGN_targets =
    [“BL_Address (Imm64 4235848w)”], CFGN_type = CFGNT_Jump}: cfg_node

*)
(* (List.length lbl_tgt) = 0
		       then
			   (“BL_Address (Imm64 0w)”, " ")
		       else
			   ((hd lbl_tgt), " ");*)
fun fun_address_dict (n:cfg_node) =
    let
        val lbl_tm   = #CFGN_lbl_tm n;
	val descr  = (valOf o #CFGN_hc_descr) n;
	val instrDes = (snd o (list_split_pred #" ") o explode) descr;
	   (* val _ = print ((implode instrDes) ^ "\n");*)
	val name_adr = if ((isPrefix "(bl " (implode instrDes)) orelse (isPrefix "(b " (implode instrDes)))
		       then let
			       val fname = (implode o fst o (list_split_pred #">") o snd o (list_split_pred #"<")) instrDes;
			   in
			       (lbl_tm, fname)
			   end
		       else (“BL_Address (Imm32 0w)”, " ");
    in
	name_adr
    end;
    
    
fun fun_addresses_dict bl_dict prog_lbl_tms =
    let
	val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict prog_lbl_tms;
	    
	val func_table = Redblackmap.mkDict Term.compare : (term, string) Redblackmap.dict;

	val fun_adr = (List.map (fn x => (fun_address_dict x)) (List.map snd (Redblackmap.listItems n_dict)));

	val func_table' = Redblackmap.insertList (func_table, fun_adr);
    in
	fst (Redblackmap.remove(func_table', “BL_Address (Imm32 0w)”))
    end;
(*
val aa = fun_addresses_dict bl_dict_  prog_lbl_tms_
    Redblackmap.listItems aa ;
*)    
end(*local*)

end (* struct *)

