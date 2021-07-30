structure bir_symbexec_funcLib =
struct

local
    open bir_symbexec_stateLib;
    open bir_symbexec_coreLib;
    open bir_block_collectionLib;
    open bir_envSyntax;
    open bir_expSyntax;
    open Redblackmap;
  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_funcLib"
in

val _ = Parse.type_abbrev("hmac", ``:bir_var_t list -> bir_exp_t``);

val _ = Parse.type_abbrev("enc", ``:bir_var_t list -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("dec", ``:bir_var_t list -> bir_exp_t``);

(* read int from file *)
fun readint_inputs filename =
    let
	val fullfilename = Path.mkAbsolute{path = filename,
                                        relativeTo = FileSys.getDir()};

        val ins = TextIO.openIn fullfilename;
	val _ = TextIO.inputN(ins,52);

    fun loop ins =

        case TextIO.scanStream(IntInf.scan StringCvt.DEC) ins of

    SOME int => int :: loop ins

    | NONE => []

          in
 loop ins before TextIO.closeIn ins

    end;
    
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
	 val var =  bir_envSyntax.mk_BVar_string (bv_str, “BType_Imm Bit64”);
    in
	var
    end;
		
fun encrypt inputs iv =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(enc
			     (inputs)
			     (iv))``;

    in
	dest_BStmt_Assign stmt
    end;

fun decrypt inputs =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(dec
			     (inputs))``;

    in
	dest_BStmt_Assign stmt
    end;

fun HMac inputs =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(hmac
			     (inputs))``;

    in
	dest_BStmt_Assign stmt
    end;
fun symbval_bexp symbv =
    let
	val bexp =
	    case symbv of
		SymbValBE (exp,_) => exp
              | SymbValInterval ((exp1,exp2), _) => exp1 (* we need to fix it later*)
              | SymbValMem (exp, _, _, _) => exp (* we need to fix it later*)
	      | _ => raise ERR "symbval_bexp" "cannot handle symbolic value type";
    in
	bexp
    end;

fun update_symbval new_symbval Fr_bv syst =
    let
	val symbv' = SymbValBE (new_symbval,symbvalbe_dep_empty);
	val syst = insert_symbval Fr_bv symbv' syst;

    in
	syst
    end;
  
fun store_link bl_stmts syst =
    let
	val s_tm = (fst o listSyntax.dest_list) bl_stmts;
	val s_tm_0 = List.nth (s_tm, 0);
	val (bv, be) = dest_BStmt_Assign s_tm_0; (* extract bir expression *)
	val Fr_bv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("R30", “BType_Imm Bit64”)); (* generate a fresh iv *)
	val syst =  update_envvar bv Fr_bv syst; (* update environment *)
	val syst = update_symbval be Fr_bv syst; (* update symbolic value *)
    in
	syst
    end;

fun update_pc syst =
    let
	val bv = ``BVar "R30" (BType_Imm Bit64)``;

	val symbv = get_state_symbv "symbv not found" bv syst;
  
	val be = symbval_bexp symbv; (* extract bir expression *) 

	val tgt = (mk_BL_Address o bir_expSyntax.dest_BExp_Const) be; (* make next address *)
	    
	val systs = List.map (SYST_update_pc tgt) [syst];(* update symb_state list with new pc *)

    in
	systs
    end;

fun update_path bv syst =
    let
	 val Fr_bv = Fr bv;
	 val syst = SYST_update_pred ((Fr_bv)::(SYST_get_pred syst)) syst;
    in
	syst
    end;

fun state_add_path bv_str pred syst =
    let
      val bv = bir_envSyntax.mk_BVar_string (bv_str, bir_valuesSyntax.BType_Bool_tm);
      val bv_fresh = get_bvar_fresh bv;
    in
      (SYST_update_pred ((bv_fresh)::(SYST_get_pred syst)) o
       update_symbval pred bv_fresh
      ) syst
    end;
    
fun update_lib_syst be Fr_bv syst =
    let
	
	val bv0 = ``BVar "R0" (BType_Imm Bit64)``;
		  
	val syst =  update_envvar bv0 Fr_bv syst; (* update environment *)  
	
	val syst = update_symbval be Fr_bv syst; (* update symbolic value *)
	
	val syst = state_add_path "T" be syst; (* update path condition *)

    in
	syst
    end;
    
fun compute_inputs n syst =
    let
	val Rn = ("R" ^ (IntInf.toString n));

	val be = bir_envSyntax.mk_BVar_string (Rn, ``BType_Imm Bit64``);
	    
	val be_r = (symbval_bexp o get_state_symbv " vals not found " be) syst;

	val n = n-1;
	val inputs = if (n < 0)
		     then []
		     else
			 be_r :: compute_inputs n syst;
    in
	inputs

    end;

fun add_knowledge bv syst =
    let
	val symbv = get_state_symbv "symbv not found" bv syst;
	    
	val be = symbval_bexp symbv;

	val syst = state_add_path "K" be syst;
    in
       syst
    end;
    
fun add_knowledges_to_adv n syst =
    let
	val Rn = ("R" ^ (IntInf.toString n));
	val be = mk_BVar_string (Rn, ``BType_Imm Bit64``);
	    
	val syst = add_knowledge be syst;

	val n = n-1;
	val syst = if (n < 0)
		     then syst
		     else
			 add_knowledges_to_adv n syst;
    in
	syst

    end;  

fun Adv av syst =
    let
	val n = List.nth (readint_inputs "Adversary-number of inputs", 0);

	val syst =  add_knowledges_to_adv (n-1) syst;

	val syst =  update_envvar ``BVar "R0" (BType_Imm Bit64)`` av syst; (* update environment *) 

	val Fn_av = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("a", “BType_Imm Bit64”)); (* generate a fresh name *)

	val syst = update_symbval Fn_av av syst; (* update symbolic value *)

	val syst = update_path av syst; (* update path condition *)	    
    in
	syst
    end;
        
fun new_key syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	
	
	val syst = update_path vn syst; (* update path condition *)

	val Fn_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("k", “BType_Imm Bit64”)); (* generate a fresh name *)
	    
	val syst = update_lib_syst Fn_vn vn syst; (* update syst *)
	    
    in
	syst
    end;   

fun Encryption syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs (n-2) syst; (* get values *)
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
	
	val syst = update_path iv syst; (* update path condition *)  

	val (C_bv, C_be) = encrypt inputs iv; (* encrypt with iv *)

	val Fr_Enc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Enc) (C_bv)``; (* assign value of R0 to the fresh variable *)
	
	val syst = update_lib_syst C_be Fr_Enc syst; (* update syst *)
	
    in
	syst
    end;
 
fun Decryption syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs (n-1) syst; (* get values *)

	val (M_bv, M_be) = decrypt inputs; (* decrypt with iv *)

	val Fr_Dec = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Dec) (M_bv)``; (* assign value of R0 to the fresh variable *)
	    
	val syst = update_lib_syst M_be Fr_Dec syst; (* update syst *)
	    		    
    in
	syst
    end;

fun HMAC syst =
    let
	val n = List.nth (readint_inputs "Library-number of inputs", 0);

	val syst = new_key syst;
	    
	val inputs = compute_inputs (n-1) syst; (* get values *)
	
	val (M_bv, M_be) = HMac inputs; (* decrypt with iv *)

	val Fr_Hmac = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("HMAC", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Hmac) (M_bv)``; (* assign value of R0 to the fresh variable *)
	    
	val syst = update_lib_syst M_be Fr_Hmac syst; (* update syst *)
	    		    
    in
	syst
    end;
  
end(*local*)

end (* struct *)

