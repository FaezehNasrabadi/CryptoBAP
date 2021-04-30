structure bir_symbexec_oracleLib =
struct

local
  open bir_symbexec_stateLib;
  open bir_symbexec_coreLib;
  open IntInf;
  open TextIO;

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

(*val est = ``BStmt_Jmp
                    (BLE_Exp (BExp_Den (BVar "tmp_PC" (BType_Imm Bit32))))``;*)

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
	     else ``BL_Address (Imm64 2802w)``;(*we need to fix it later*)
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
fun in_range (mn,mx) tm =
    let val v = sint_of_term tm in
      mn <= v andalso v <= mx
    end handle HOL_ERR _ => false | Overflow => false;

(* read int from file *)
fun readint_type filename =
    let
	val fullfilename = Path.mkAbsolute{path = filename,
                                        relativeTo = FileSys.getDir()};

        val ins = TextIO.openIn fullfilename;
	val _ = TextIO.inputN(ins,104);

    fun loop ins =

        case TextIO.scanStream(IntInf.scan StringCvt.DEC) ins of

    SOME int => int :: loop ins

    | NONE => []

          in
 loop ins before TextIO.closeIn ins

  end;
    
fun fun_oracle_type_label label =
    let
	
	val Int_list = readint_type "Function-Addresses";
	
	val lbl = 
	    (*critical section that no one must not jump to it*)
	    if (in_range((List.nth (Int_list, 0)),(List.nth (Int_list, 1))) label) then
		"Adversary"
	    (*part of memory that library functions exist*)
	    else if ((in_range((List.nth (Int_list, 2)),(List.nth (Int_list, 3))) label) orelse (in_range((List.nth (Int_list, 6)),(List.nth (Int_list, 7))) label)) then
		"Library"
	    (*jump to other part of memory is normal*)
	    else if (in_range((List.nth (Int_list, 4)),(List.nth (Int_list, 5))) label) then
		"Normal"
	    else
		raise ERR "fun_oracle_type_label" ("cannot handle label " ^ (term_to_string label));
	    
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
(*
val est = `` BStmt_Jmp (BLE_Label (BL_Address (Imm64 2886w)))``;
val est = ``BStmt_Halt (BExp_Const (Imm64 136w))``;
*)
fun fun_oracle est syst =
    let
	      val target_label = fun_oracle_Address est syst;
		       
	      val target_label_type =
		  if is_BL_Address target_label
		  then (fun_oracle_type_label o bir_immSyntax.dest_Imm64 o dest_BL_Address) target_label
		  else if is_BL_Label target_label
		  then (term_to_string o dest_BL_Label) target_label
		  else if bir_immSyntax.is_Imm64 target_label
		  then (fun_oracle_type_label o bir_immSyntax.dest_Imm64) target_label
		  else raise ERR "fun_orcle" ("cannot handle target label num " ^ (term_to_string target_label));

	  in
	      target_label_type
	  end;

(*val label = “2002w”;*)    
fun lib_oracle_type_label label =
    let

	val Int_list = readint_type "Library-Addresses";

	val lbl = 
	    (*part of memory that new key functions exist*)
	    if ((in_range((List.nth (Int_list, 0)),(List.nth (Int_list, 1))) label) orelse (in_range((List.nth (Int_list, 2)),(List.nth (Int_list, 3))) label)) then
		"C_Lib"
	    else if (in_range((List.nth (Int_list, 4)),(List.nth (Int_list, 5))) label) then
		"NewKey"
	    (*part of memory that encryption functions exist*)
	    else if (in_range((List.nth (Int_list, 6)),(List.nth (Int_list, 7))) label) then
		"Encryption"
	    (*part of memory that decryption functions exist*)
	    else if (in_range((List.nth (Int_list, 8)),(List.nth (Int_list, 9))) label) then
		"Decryption"
	    else
		raise ERR "lib_oracle_type_label" ("cannot handle label " ^ (term_to_string label));
	    
    in
	lbl
    end;
    
(*val lbl_tm = “BL_Address (Imm64 2002w)”;*)

fun lib_oracle est syst =
    let
	      val target_label = fun_oracle_Address est syst;
		       
	      val lib_type =
		  if is_BL_Address target_label
		  then (lib_oracle_type_label o bir_immSyntax.dest_Imm64 o dest_BL_Address) target_label
		  else if is_BL_Label target_label
		  then (term_to_string o dest_BL_Label) target_label
		  else if bir_immSyntax.is_Imm64 target_label
		  then (lib_oracle_type_label o bir_immSyntax.dest_Imm64) target_label
		  else raise ERR "lib_orcle" ("cannot handle target label num " ^ (term_to_string target_label));

	  in
	      lib_type
	  end;    
    
end(*local*)

end (* struct *)




    

