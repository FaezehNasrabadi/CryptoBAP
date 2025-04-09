structure bir_symbexec_oracleLib =
struct

local
    open binariesLib;
    open bir_symbexec_stateLib;
    open bir_symbexec_coreLib;
    open IntInf;
    open TextIO;
    open Redblackmap;
    open List;
    open bir_auxiliaryLib;
    open bir_cfgLib;
    open bir_cfg_m0Lib;
    open bir_expSyntax;
    open bir_programSyntax;
    open bir_immSyntax;
    open bir_envSyntax;
    open Hol_pp;
    open Term;
    open liteLib;
    open HolKernel Parse boolLib bossLib;
    open HolBACoreSimps;
    val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_oracleLib"
in

(* detect function call based on label of block *)
fun is_function_call (n_dict : (term, cfg_node) dict) (lbl_tm : term) =
    let
	val n_op = Redblackmap.peek(n_dict, lbl_tm);
	val exist = if is_none n_op
		    then false
		    else
			let
			    val n = valOf n_op;
			    val descr  = (valOf o #CFGN_hc_descr) n;
			    val instrDes = (snd o (list_split_pred #" ") o explode) descr;
			in
			    if ((String.isPrefix "(bl " (implode instrDes)) orelse (String.isPrefix "(b " (implode instrDes)) orelse (String.isPrefix "(blr " (implode instrDes)))
			    then true
			    else false
			  end;
    in
	exist
    end;

(* detect indirect jumps based on label of block *)

fun is_indirect_jmp (n_dict : (term, cfg_node) dict) (lbl_tm : term) =
    let
	val n_op = Redblackmap.peek(n_dict, lbl_tm);
	val exist = if is_none n_op
		    then false
		    else
			let
			    val n = valOf n_op;
			    val descr  = (valOf o #CFGN_hc_descr) n;
			    val instrDes = (snd o (list_split_pred #" ") o explode) descr;
			in
			    if (String.isPrefix "(blr " (implode instrDes))
			    then true
			    else false
			  end;
    in
	exist
    end;  

(* fetch address of cjmp *)
fun state_exec_try_cjmp_label_out est syst =
     let
	 val cjmp_label_match_tm = ``BStmt_CJmp xyzc (BLE_Label xyz1) (BLE_Label xyz2)``;
	 val (vs, _) = hol88Lib.match cjmp_label_match_tm est;
	 val cnd     = fst (List.nth (vs, 0));
	 val tgt1    = fst (List.nth (vs, 1));
	 val tgt2    = fst (List.nth (vs, 2));

	 val cnd_exp_bool = if bir_expSyntax.is_BExp_Den cnd then
				bir_expSyntax.dest_BExp_Den cnd
			    else cnd;
				
     in
	 if bir_bool_expSyntax.is_bir_exp_true cnd_exp_bool then
             tgt1
	 else 
             tgt2

     end;


(* fetch address of jump from expression variable *)
fun state_exec_try_jmp_exp_var_out est syst =
    let
	val indjmps = SYST_get_indjmp syst;
	val tgt = (mk_BL_Address o bir_expSyntax.dest_BExp_Const o hd) indjmps;
    in
	tgt 
    end;

(* convert term into an integer *)    
fun sint_of_term tm =
  tm |> wordsSyntax.dest_word_literal |> Arbnum.toLargeInt
  handle Overflow => raise ERR "sint_of_term"
                       ("integer " ^ term_to_string tm ^ " too large")
       | HOL_ERR _ => raise ERR "sint_of_term"
                       ("could not convert ``" ^ term_to_string tm ^
                        "`` to an integer");

fun in_range (mn:int,mx:int) tm =
    let val v = sint_of_term tm in
	mn <= v andalso v <= mx
    end handle HOL_ERR _ => false | Overflow => false;

fun equal_address address tm =
    let val v = sint_of_term tm in
     address <= v andalso v <= address
    end handle HOL_ERR _ => false | Overflow => false;
     
(* read int from file *)
fun readint_type filename =
    let
	val fullfilename = Path.mkAbsolute{path = filename,
                                        relativeTo = FileSys.getDir()};

        val ins = TextIO.openIn fullfilename;
	val _ = TextIO.inputN(ins,91);

    fun loop ins =

        case TextIO.scanStream(IntInf.scan StringCvt.DEC) ins of

    SOME int => int :: loop ins

    | NONE => []

          in
 loop ins before TextIO.closeIn ins

  end;

(* read function names from file *)
fun read_fun_names filename =
    let
	val fullfilename = OS.Path.mkAbsolute{path = filename,
                                        relativeTo = OS.FileSys.getDir()};

        val ins = TextIO.openIn fullfilename;
	val _ = TextIO.inputLine ins;

    fun loop ins =

        case (TextIO.inputLine ins) of

    SOME name => ((implode o fst o (bir_auxiliaryLib.list_split_pred #"\n") o explode) name :: loop ins)

    | NONE => []

          in
 (loop ins) before (TextIO.closeIn ins)

    end;

(* detect name exists in function names *)    
fun exist_in_dict fun_name file_name =
    let
	val Names_list = read_fun_names file_name;
    in
	(List.exists (fn x => x=fun_name) Names_list)
    end;

     
fun fun_oracle_type_label adr_dict label =
    let
	open String;
	     
	val exist_dict = Redblackmap.peek(adr_dict, label);
	    
	val lbl = 
	    (*critical section that no one must not jump to it*)
	    if (case exist_dict of
		    SOME x => (exist_in_dict x "Adversary-Function-Names")
		  | NONE => false)
	    then
		"Adversary"
	    (*part of memory that library functions exist*)
	    else if (case exist_dict of
			 SOME x => (exist_in_dict x "Function-Names")
		       | NONE => false)
	    then
		"Library"
            (*part of memory that loops exist*)
	    else if (case exist_dict of
		    SOME x => ((x >= "loop") andalso (x <= "loop"))
		  | NONE => false)
	    then
		"Loop"
	    (*jump to other part of memory is normal*)
	    else 
		"Normal";
	    
    in
	lbl
    end;

(* find address of function call *)     
fun fun_oracle_Address est syst =
    let
	val target_label = if is_BStmt_CJmp est then state_exec_try_cjmp_label_out est syst
			   else if is_BStmt_Halt est then (bir_expSyntax.dest_BExp_Const o dest_BStmt_Halt) est
			   else if (is_BLE_Label o dest_BStmt_Jmp) est then (dest_BLE_Label o dest_BStmt_Jmp) est
			   else if (is_BLE_Exp o dest_BStmt_Jmp) est then state_exec_try_jmp_exp_var_out est syst
			   else raise ERR "fun_orcle_Address" ("cannot handle target label " ^ (term_to_string est));
    in
	target_label
    end;

 (* detect type of function call *)   
fun fun_oracle adr_dict lbl_tm syst =
	(fun_oracle_type_label adr_dict lbl_tm);


(* detect type of cryptographic function call *)    
fun lib_oracle_type_label adr_dict label =
    let

	val C_fun_names = read_fun_names "Cryptographic-Functions-Names";
	

	val find_from_dict = Redblackmap.find(adr_dict, label);
	    (* val _ = print ("\n"^find_from_dict^"\n"); *)
	val lbl = 
	    (*part of memory that new key functions exist*)
	    if (find_from_dict = (List.nth (C_fun_names, 0))) then
		"NewKey"
	    (*part of memory that encryption functions exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 1))) then
		"Encryption"
	    (*part of memory that decryption functions exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 2))) then
		"Decryption"
	    (*part of memory that HMAC_send functions exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 3))) then
		"HMAC_send"
	    (*part of memory that HMAC_receive functions exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 4))) then
		"HMAC_receive"
	    (*part of memory that MEMcpy functions exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 5))) then
		"MEMcpy"
	    (*part of memory that first event function exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 6))) then
		"event1"
	    (*part of memory that second event function exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 7))) then
		"event2"
	    (*part of memory that fail function exist*)
	    else if ((find_from_dict = (List.nth (C_fun_names, 8))) orelse (find_from_dict = (List.nth (C_fun_names, 9))) orelse (find_from_dict = (List.nth (C_fun_names, 14))) orelse (find_from_dict = (List.nth (C_fun_names, 20))) orelse (find_from_dict = (List.nth (C_fun_names, 21))) orelse (find_from_dict = (List.nth (C_fun_names, 22))) orelse (find_from_dict = (List.nth (C_fun_names, 23)))) then
		"Fail"
	    (*part of memory that OTP function exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 10))) then
		"OTP"
	    (*part of memory that random number generator function exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 11))) then
		"RNG"
	    (*part of memory that XOR function exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 12))) then
		"XOR"
	    else if (find_from_dict = (List.nth (C_fun_names, 13))) then
		"SKey"
	    else if (find_from_dict = (List.nth (C_fun_names, 15))) then
		"Signature"
	    else if (find_from_dict = (List.nth (C_fun_names, 16))) then
		"Verify"
	    else if ((find_from_dict = (List.nth (C_fun_names, 17))) orelse (find_from_dict = (List.nth (C_fun_names, 18))) orelse (find_from_dict = (List.nth (C_fun_names, 19)))) then
		"LoadFile"
	    else if (find_from_dict = (List.nth (C_fun_names, 24))) then
		"kdfPtoS"
	    else if (find_from_dict = (List.nth (C_fun_names, 25))) then
		"kdfStoP"
		(*part of memory that third event function exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 26))) then
		"event3"
	    else if (find_from_dict = (List.nth (C_fun_names, 27))) then
		"concat"
	    else if (find_from_dict = (List.nth (C_fun_names, 28))) then
		"NewKey"
	    else if (find_from_dict = (List.nth (C_fun_names, 29))) then
		"Concat1"
	    else if (find_from_dict = (List.nth (C_fun_names, 30))) then
		"Concat2"
	    else if (find_from_dict = (List.nth (C_fun_names, 31))) then
		"Pars1"
	    else if (find_from_dict = (List.nth (C_fun_names, 32))) then
		"Pars2"
	    else if (find_from_dict = (List.nth (C_fun_names, 33))) then
		"compare"
	    else
		"C_Lib";
	    
    in
	lbl
    end;

fun lib_oracle adr_dict lbl_tm syst =
    	(lib_oracle_type_label adr_dict lbl_tm);
  
    
end(*local*)

end (* struct *)




    

