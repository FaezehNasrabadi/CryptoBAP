structure bir_symbexec_loopLib =
struct

local
    open HolKernel Parse
    open binariesLib;
    open binariesTheory;
    open binariesCfgLib;
    open binariesMemLib;
    open bir_programSyntax;
    open bir_valuesSyntax;
    open bir_immSyntax;
    open bir_exec_typingLib;
    open binariesDefsLib;
    open bir_cfgLib;
    open bir_cfg_m0Lib;
    open Redblackmap;
    open bir_block_collectionLib;
    val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_loopLib"
    val wrap_exn = Feedback.wrap_exn   "bir_symbexec_loopLib"

    val node_type =  ref ([]: (string * term) list);

in


fun mk_key_from_address64 i addr = (mk_BL_Address o bir_immSyntax.mk_Imm64 o wordsSyntax.mk_word) (addr, Arbnum.fromInt i);


fun print_list lst =
    List.map (fn x => print_term x) lst;

fun is_call_node adr_dict [] visited = visited
  | is_call_node adr_dict (tgt::targets) visited =
    let
	val exist_dict = Redblackmap.peek(adr_dict, tgt);
	val visited' = if (isSome exist_dict)
		       then (tgt::visited)
		       else visited;
    in
	is_call_node adr_dict targets visited'
    end;
   
fun detect_loop (g:cfg_graph) adr_dict entry visited =
  let
    val n = bir_block_collectionLib.lookup_block_dict_value (#CFGG_node_dict g) entry "traverse_graph" "n";
    val targets = #CFGN_targets n;
    val n_type  = #CFGN_type n;
    val s_type = bir_cfgLib.toString n_type
    val _ = node_type:= !node_type@[(s_type, (#CFGN_lbl_tm n))];
	
    (*val visited = is_call_node adr_dict targets visited;*)
	
    val targets_to_visit = List.filter (fn x => List.all (fn y => not (identical x y)) visited) targets;
    val result = List.foldr (fn (entry', visited') => detect_loop g adr_dict entry' visited') (entry::visited) targets_to_visit;
  in result end;


fun get_range (trace1, pattern) =
    let fun toChar t =
	  case t of "CFGNT_Jump"     => "J"
		  | "CFGNT_CondJump" => "C"
		  | "CFGNT_Halt"     => "H"
		  | "CFGNT_Basic"    => "B"
		  | "CFGNT_Call"     => "L"
		  | "CFGNT_Return"   => "R"

	fun index (str: string, substr: string) : int option =
	    let
		fun loop  (i: int) =
		    let val subt = ((String.size str) - (String.size substr))
		    in
			if (i > subt) then
			    NONE
			else if String.isSubstring (String.substring(str, i, (String.size substr))) substr then
			    SOME i
			else
			    loop (i + 1)
		    end
	    in
		loop 0
	    end
	val tc = List.foldr (fn (x, y) => x^y ) "" (List.map (fn x => toChar (fst x)) trace1)
	(* val _ = print tc *)
	(* val _ = print "\n" *)
	val pc = List.foldr (fn (x, y) => x^y ) "" (List.map (fn x => toChar x) pattern)
	(* val _ = print pc *)
	(* val _ = print "\n" *)
    in
	index(tc, pc)
    end


fun next_pc lbl_tm =
    let
	val wpc = (bir_immSyntax.dest_Imm64 o dest_BL_Address) lbl_tm;
	val incpc = (rhs o concl o EVAL o wordsSyntax.mk_word_add) (wpc,``4w:word64``);
	val tgt = (mk_BL_Address o bir_immSyntax.mk_Imm64) incpc;
    in
	tgt
    end;


(* val loop_pattern = ["CFGNT_Jump","CFGNT_Basic","CFGNT_Basic","CFGNT_Basic","CFGNT_CondJump"]; *)

fun find_loop n_dict adr_dict entries loop_pattern =
    let
	val g1 = cfg_create "toy" entries n_dict bl_dict_;
	val _ = node_type := [];
	val _ =  detect_loop  g1 adr_dict (hd (#CFGG_entries g1)) [];
	val in_loop = get_range(!node_type, loop_pattern);    
	val entry_adr = if (isSome in_loop)    
			then snd (List.nth (!node_type, ((valOf in_loop)+((List.length loop_pattern)-1))))
			else raise ERR "find_loop:get_range" "in_loop is NONE";
	(* val exit_adr = next_pc entry_adr; *)
    in
	entry_adr
    end
    
	    

    
end(*local*)

end (* struct *)
