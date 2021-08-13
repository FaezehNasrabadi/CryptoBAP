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


    val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_oracleLib"
in
(*val est = ``BStmt_CJmp (BExp_Den (BVar "ProcState_Z" BType_Bool))
			     (BLE_Label (BL_Address (Imm64 2844w)))
			     (BLE_Label (BL_Address (Imm64 2836w)))``;*)
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
    (*
val lbl_tm = ``BL_Address (Imm64 4280w)``;

val stop_lbl_tms = [``BL_Address (Imm64 4460w)``];
    
val syst = init_state lbl_tm prog_vars;

val pred_conjs = [``bir_exp_true``];
    
val syst = state_add_preds "init_pred" pred_conjs syst;

val _ = print "initial state created.\n\n";

val cfb = false;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict_ prog_lbl_tms_;
  
val systs = bir_symbexec_stepLib.symb_exec_to_stop (abpfun cfb) n_dict bl_dict_ [syst] stop_lbl_tms [];*)
(*val est = ``BStmt_Jmp
                    (BLE_Exp (BExp_Den (BVar "R17" (BType_Imm Bit64))))``;*)

fun state_exec_try_jmp_exp_var_out est syst =
    let

	 val jmp_exp_var_match_tm = ``BStmt_Jmp (BLE_Exp x)``;
	 val (vs, _) = hol88Lib.match jmp_exp_var_match_tm est;

	 val be_tgt  = (fst o hd) vs;

	 open bir_countw_simplificationLib;
	 val bvalo = eval_exp_in_syst be_tgt syst;
    

	 open bir_valuesSyntax;
	 open optionSyntax;
	      
	 val tgt = 
	     if is_some bvalo then (mk_BL_Address o dest_BVal_Imm o dest_some) bvalo
	     else ``BL_Address (Imm64 4212w)``;(*we need to fix it later*)
	 (*
	val _ = print ("inter\n");
	 val jmp_exp_var_match_tm = ``BStmt_Jmp (BLE_Exp x)``;
	val (vs, _) = hol88Lib.match jmp_exp_var_match_tm est
                    handle _ => (
                      print ("couldn't match end statement: " ^ (term_to_string est) ^ "\n");
                      raise ERR "couldn't match" (term_to_string est));
      val be_tgt  = (fst o hd) vs;

      open bir_countw_simplificationLib;
      val bvalo = eval_exp_in_syst be_tgt syst;

      open bir_valuesSyntax;
      open optionSyntax;
      val tgt = (mk_BL_Address o dest_BVal_Imm o dest_some) bvalo
                handle _ => (
                  print ("state_exec_try_jmp_exp_var::no const: " ^
                         (term_to_string bvalo) ^ " ;; " ^ 
                         (term_to_string be_tgt) ^ "\n");
                  raise ERR "state_exec_try_jmp_exp_var_out"
			    ("target value is no const: " ^ (term_to_string bvalo)));
	  val _ = print ("exit\n" ^ (term_to_string tgt));*)

    in
	tgt 
    end;

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
	val fullfilename = Path.mkAbsolute{path = filename,
                                        relativeTo = FileSys.getDir()};

        val ins = TextIO.openIn fullfilename;
	val _ = TextIO.inputLine ins;

    fun loop ins =

        case TextIO.inputLine ins of

    SOME name => (implode o fst o (bir_auxiliaryLib.list_split_pred #"\n") o explode) name :: loop ins

    | NONE => []

          in
 loop ins before TextIO.closeIn ins

    end;
		
fun exist_in_dict fun_name file_name =
    let
	val Names_list = read_fun_names file_name;
    in
	(List.exists (fn x => x=fun_name) Names_list)
    end;

fun fun_oracle_type_label label =
    let
	val adr_dict = bir_symbexec_PreprocessLib.fun_addresses_dict bl_dict_ prog_lbl_tms_;

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
	    (*jump to other part of memory is normal*)
	    else 
		"Normal";
	    
    in
	lbl
    end;

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

fun fun_oracle est syst =
    let
	val target_label = fun_oracle_Address est syst;
    in
	(fun_oracle_type_label target_label)
    end;

fun lib_oracle_type_label label =
    let

	val C_fun_names = read_fun_names "Cryptographic-Functions-Names";
	val adr_dict = bir_symbexec_PreprocessLib.fun_addresses_dict bl_dict_ prog_lbl_tms_;

	val find_from_dict = Redblackmap.find(adr_dict, label);
	    
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
	    (*part of memory that HMAC functions exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 3))) then
		"HMAC"
	    (*part of memory that MEMcpy functions exist*)
	    else if (find_from_dict = (List.nth (C_fun_names, 4))) then
		"MEMcpy"
	    else
		"C_Lib";
	    
    in
	lbl
    end;

fun lib_oracle est syst =
    let
	val target_label = fun_oracle_Address est syst;
    in
	(lib_oracle_type_label target_label)
    end;    
    
end(*local*)

end (* struct *)




    

