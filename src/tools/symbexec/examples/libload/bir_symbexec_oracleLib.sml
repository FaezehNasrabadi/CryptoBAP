structure bir_symbexec_oracleLib =
struct

local
  open bir_symbexec_stateLib;
  open bir_symbexec_coreLib;

  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_oracleLib"
in


(*val tm = “3076w”;*) 
fun sint_of_term tm =
  tm |> wordsSyntax.dest_word_literal |> Arbnum.toInt
  handle Overflow => raise ERR "sint_of_term"
                       ("integer " ^ term_to_string tm ^ " too large")
       | HOL_ERR _ => raise ERR "sint_of_term"
                       ("could not convert ``" ^ term_to_string tm ^
                        "`` to an integer");
fun in_range (mn,mx) tm =
    let val v = sint_of_term tm in
      mn <= v andalso v <= mx
    end handle HOL_ERR _ => false | Overflow => false;

(*val label = “3076w”;*)    
fun fun_oracle_type_label label =
    let
	val lbl = 
	    (*critical section that no one must not jump to it*)
	    if (in_range (0,2000) label) then
		"Adversary"
	    (*part of memory that library functions exist*)
	    else if (in_range (2001,2800) label) then
		"Library"
	    (*jump to other part of memory is normal*)
	    else if (in_range (2801,268439552) label) then
		"Normal"
	    else
		raise ERR "fun_oracle_type_label" ("cannot handle label " ^ (term_to_string label));
    in
	lbl
    end;

(*val lbl_tm = “BL_Address (Imm32 3076w)”;*)
fun fun_oracle lbl_tm =
    let
	      val pc_type = (fun_oracle_type_label o bir_immSyntax.dest_Imm32 o dest_BL_Address) lbl_tm;

	  in
	      pc_type
    end;
    
(*val label = “2002w”;*)    
fun lib_oracle_type_label label =
    let
	val lbl = 
	     (*part of memory that encryption functions exist*)
	    if (in_range (2001,2400) label) then
		"Encryption"
	    (*part of memory that decryption functions exist*)
	    else if (in_range (2401,2800) label) then
		"Decryption"
	    else
		raise ERR "lib_oracle_type_label" ("cannot handle label " ^ (term_to_string label));
    in
	lbl
    end;
    
(*val lbl_tm = “BL_Address (Imm32 2002w)”;*)
fun lib_oracle lbl_tm =
    let
	      val pc_type = (lib_oracle_type_label o bir_immSyntax.dest_Imm32 o dest_BL_Address) lbl_tm;

	  in
	      pc_type
    end;    
end(*local*)

end (* struct *)

