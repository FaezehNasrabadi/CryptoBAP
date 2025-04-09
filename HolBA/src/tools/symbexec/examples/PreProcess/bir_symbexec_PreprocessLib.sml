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
    open Term;
  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_PreprocessLib"
in
    
(* Find nodes with branch*)
fun fun_address_dict (n:cfg_node) =
    let
        val lbl_tm   = #CFGN_lbl_tm n;
	val descr  = (valOf o #CFGN_hc_descr) n;
	val instrDes = (snd o (list_split_pred #" ") o explode) descr;
	   (* val _ = print ((implode instrDes) ^ "\n"); *)
	val name_adr = if (isPrefix "(bl " (implode instrDes))
		       then let
			       val fname = (implode o fst o (list_split_pred #">") o snd o (list_split_pred #"<")) instrDes;
			   in
			       (lbl_tm, fname)
			   end
		       else if (isPrefix "(blr " (implode instrDes))
		       then let
			       val fname = (implode o fst o (list_split_pred #")") o snd o (list_split_pred #" ")) instrDes;
			   in
			       (lbl_tm, fname)
			   end
		       else if (isPrefix "(b " (implode instrDes))
		       then let
			       val fname = if (isPrefix "(b <" (implode instrDes))
					   then
					       (implode o fst o (list_split_pred #">") o snd o (list_split_pred #"<")) instrDes
					   else
					       (implode o fst o (list_split_pred #")") o snd o (list_split_pred #" ")) instrDes
			   in
			       (lbl_tm, fname)
			   end
		       else (“BL_Address (Imm32 0w)”, " ");
    in
	name_adr
    end;
    
(* Find address of nodes with branch*)     
fun fun_addresses_dict bl_dict prog_lbl_tms =
    let
	val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict prog_lbl_tms;
	    
	val func_table = Redblackmap.mkDict Term.compare : (term, string) Redblackmap.dict;

	val fun_adr = (List.map (fn x => (fun_address_dict x)) (List.map snd (Redblackmap.listItems n_dict)));

	val func_table' = Redblackmap.insertList (func_table, fun_adr);
    in
	fst (Redblackmap.remove(func_table', “BL_Address (Imm32 0w)”))
    end;
  
end(*local*)

end (* struct *)
