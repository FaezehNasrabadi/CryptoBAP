structure bir_symbexec_treeLib =
struct

local
    open bir_symbexec_stateLib;
    open bir_symbexec_coreLib;
    val ERR = Feedback.mk_HOL_ERR "bir_symbexec_treeLib"
    val Sym_Exe_i = ref (0:int);
    fun get_Sym_Exe_counter () =
	let val i = !Sym_Exe_i; in
	    (Sym_Exe_i := i + 1; i) end;

in
    
(* execute one path *)
fun path_of_tree [] Acts =
    (Acts)
  | path_of_tree (pred::preds) Acts =
    let
	val pred_name = (fst o bir_envSyntax.dest_BVar_string) pred;

	val Act = if (String.isSuffix "init_pred" pred_name) then ["Root"]
		  else if (String.isSuffix "assert_true_cnd" pred_name) then []
		  else if (String.isSuffix "cjmp_true_cnd" pred_name) then ["cjmp_true_cnd"]
		  else if (String.isSuffix "assert_false_cnd" pred_name) then []
		  else if (String.isSuffix "cjmp_false_cnd" pred_name) then ["cjmp_false_cnd"]
		  else if (String.isSuffix "Key" pred_name) then ["Key"]
		  else if (String.isSuffix "iv" pred_name) then ["iv"]
		  else if (String.isSuffix "T" pred_name) then ["T"]
		  else if (String.isSuffix "K" pred_name) then ["K"]
		  else if (String.isSuffix "Adv" pred_name) then ["Adv"]
		  else raise ERR "path_of_tree" ("unknown pred name for: " ^(pred_name));
	    
	val Acts = Act@Acts;
    in
	path_of_tree preds Acts
    end; 
    
(* execute all paths *)
fun symb_exec_to_tree [] All_Acts =
        (All_Acts)
  | symb_exec_to_tree (exec_st::exec_sts) All_Acts =
    let
	val preds = SYST_get_pred exec_st;
	    
	val state_number = ("Symbolic Execution State " ^ (Int.toString (get_Sym_Exe_counter ())));

	val Acts = path_of_tree preds [state_number ^ "\n\n"];

	val All_Acts = Acts@All_Acts;

    in	
	symb_exec_to_tree exec_sts All_Acts
    end;
  
  
end(*local*)

end (* struct *)

