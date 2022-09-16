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

val _ = Parse.type_abbrev("hash", ``:bir_var_t list -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("exclusive_or", ``:bir_var_t list -> bir_exp_t``);

val _ = Parse.type_abbrev("enc", ``:bir_var_t list -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("sign", ``:bir_var_t list -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("verify", ``:bir_var_t list -> bir_var_t -> bir_exp_t``);
    
val _ = Parse.type_abbrev("dec", ``:bir_var_t list -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("concatenate", ``:bir_var_t list -> bir_exp_t``);

val bv_mem = ``(BExp_Store
                        (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                        (BExp_BinExp BIExp_Plus
                           (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                           (BExp_Const (Imm64 15w))) BEnd_LittleEndian
                        (BExp_Cast BIExp_LowCast
				   (BExp_Den (BVar "R0" (BType_Imm Bit64))) Bit8))``;




    
(* read int from file *)
fun readint_inputs filename =
    let
	val fullfilename = Path.mkAbsolute{path = filename,
                                        relativeTo = FileSys.getDir()};

        val ins = TextIO.openIn fullfilename;
	val _ = TextIO.inputN(ins,58);

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
		
fun encrypt inputs kSP =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(enc
			     (message)
			     (SK))``;

    in
	dest_BStmt_Assign stmt
    end;

fun Sign inputs skS =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(sign
			     (inputs)
			     (skS))``;

    in
	dest_BStmt_Assign stmt
    end;
    
fun ver inputs pkP =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(verify
			     (inputs)
			     (PKc))``;

    in
	dest_BStmt_Assign stmt
    end;
    
fun decrypt Cipher SK =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(dec
			     (Cipher)
			     (SK))``;

    in
	dest_BStmt_Assign stmt
    end;

fun XOR inputs =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (exclusive_or
			  (inputs))``;

    in
	dest_BStmt_Assign stmt
    end;

fun CON inputs =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (concatenate
			  (inputs))``;

    in
	dest_BStmt_Assign stmt
    end;
    
(*open List;
     open stringSyntax;
     val str = "";
	 val inputs = ``BVar "R3" (BType_Imm Bit64)``;
val inputs = [``BVar "R3" (BType_Imm Bit64)``, ``BVar "R1" (BType_Imm Bit64)``, ``BVar "R2" (BType_Imm Bit64)``];
val str_a = (List.foldr (fn (x,s) => (term_to_string x)^","^s) "" (inputs));
val b = fromMLstring str_a;
open Term;
val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(hmac
			     ( ^inputs))``;*)

fun HMac inputs pkS =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (hash
			  (inputs)
			  (pkS))``;
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

fun update_symbval new_be Fr_bv syst =
    let

	val deps = Redblackset.add (symbvalbe_dep_empty, Fr_bv);

	val symbv' = SymbValBE (new_be,deps);

	val syst = insert_symbval Fr_bv symbv' syst;

    in
	syst
    end;
  

fun store_link bl_stmts syst =
    let
	val s_tm = (fst o listSyntax.dest_list) bl_stmts;
	val s_tm_0 = List.nth (s_tm, 0);
	val (bv, be) = dest_BStmt_Assign s_tm_0; (* extract bir expression *)
	val Fr_bv = get_bvar_fresh bv; (* generate a fresh link *)
	val syst =  update_envvar bv Fr_bv syst; (* update environment *)
	val symbv = bir_symbexec_coreLib.compute_valbe be syst;
	val syst = insert_symbval Fr_bv symbv syst; (* update symbolic value *)

    in
	syst
    end;

fun update_pc syst =
    let
	val bv = ``BVar "R30" (BType_Imm Bit64)``;

	val symbv = get_state_symbv "symbv not found" bv syst;
  
	val be = symbval_bexp symbv; (* extract bir expression *) 

	val tgt = (mk_BL_Address o bir_expSyntax.dest_BExp_Const) be; (* make next address *)
	    
	val syst = SYST_update_pc tgt syst;(* update symb_state  with new pc *)

    in
	syst
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
    
fun compute_inputs_mem n syst =
    let
	    
	val bv_mem = find_bv_val ("compute_inputs_mem::bv in env not found") (SYST_get_env syst) “BVar "MEM" (BType_Mem Bit64 Bit8)”;

	val (exp1,exp2,endi,exp3) = dest_BExp_Store bv_mem;

	val bv_s = if (is_BExp_Cast exp3)
		   then
		       let
			   val (exp,bv,bit) = dest_BExp_Cast exp3;
		       in
			   dest_BExp_Den bv
		       end
		   else if (is_BExp_Den exp3)
		       then
			   dest_BExp_Den exp3
		       else raise ERR "compute_inputs_mem" "this should not happen";


	val be_r = (symbval_bexp o get_state_symbv " vals not found " bv_s) syst;

	val n = n-1;
	val inputs = if (n < 0)
		     then []
		     else
			 be_r :: compute_inputs_mem n syst;
		    
	
    in
	inputs
    end;
    
fun compute_inputs_reg n syst =
    let
	val Rn = ("R" ^ (IntInf.toString n));

	val be = bir_envSyntax.mk_BVar_string (Rn, ``BType_Imm Bit64``);
	    
	val be_r = (symbval_bexp o get_state_symbv " vals not found " be) syst;

	val n = n-1;
	val inputs = if (n < 0)
		     then []
		     else
			 be_r :: compute_inputs_reg n syst;
    in
	inputs

    end;

fun store_mem be bv syst =
    let
	val syst = update_symbval be bv syst; (* update symbolic value *)
	
	val bv_mem = find_bv_val ("store_mem::bv in env not found") (SYST_get_env syst) “BVar "MEM" (BType_Mem Bit64 Bit8)”;
		     
	val be_add = (symbval_bexp o get_state_symbv "store_mem::vals not found " “BVar "SP_EL0" (BType_Imm Bit64)”) syst;

	val endi = “BEnd_LittleEndian”;
	    
	val be = (mk_BExp_Store (mk_BExp_Den(bv_mem), be_add, endi, mk_BExp_Den(bv)));

	val Fr_mem = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("MEM", “BType_Mem Bit64 Bit8”));

	val syst =  update_envvar “BVar "MEM" (BType_Mem Bit64 Bit8)” Fr_mem syst; (* update environment *)  
	
	val syst = update_symbval be Fr_mem syst; (* update symbolic value *)
    in
	syst
    end;     

fun store_mem_r0 be bv syst =
    let
	val syst = update_symbval be bv syst; (* update symbolic value *)
	
	val bv_mem = find_bv_val ("store_mem::bv in env not found") (SYST_get_env syst) “BVar "MEM" (BType_Mem Bit64 Bit8)”;
		     
	val be_add = (symbval_bexp o get_state_symbv "store_mem::vals not found " “BVar "SP_EL0" (BType_Imm Bit64)”) syst;

	val endi = “BEnd_LittleEndian”;
	    
	val be = (mk_BExp_Store (mk_BExp_Den(bv_mem), be_add, endi, mk_BExp_Den(bv)));

	val Fr_mem = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("MEM", “BType_Mem Bit64 Bit8”));

	val syst =  update_envvar “BVar "MEM" (BType_Mem Bit64 Bit8)” Fr_mem syst; (* update environment *)  
	
	val syst = update_symbval be Fr_mem syst; (* update symbolic value *)

	val bv0 = ``BVar "R0" (BType_Imm Bit64)``;

	val Fr_r0 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("R0", “BType_Mem Bit64 Bit8”));
		  
	val syst =  update_envvar bv0 Fr_r0 syst; (* update environment *)  
	
	val syst = update_symbval be_add Fr_r0 syst; (* update symbolic value *)
	    
    in
	syst
    end;     

   
fun add_knowledge bv syst =
    let
	val symbv = SOME (get_state_symbv "symbv not found" bv syst)
	    handle _ => NONE;

	val syst = if (is_some symbv)
		   then
		       let
			   val be = symbval_bexp (valOf symbv);
			   val be = if (is_BVar be)
				    then ((stringSyntax.fromMLstring o fst o dest_BVar_string) be)
				    else
					be;
		       in
			   state_add_path "K" be syst
		       end
		   else
		       syst;
    in
       syst
    end;

fun add_knowledges_to_adv n syst =
    let
	val Rn = ("R" ^ (IntInf.toString n));

	val bv = mk_BVar_string (Rn, ``BType_Imm Bit64``);
	    
	val syst = add_knowledge bv syst;

	val n = IntInf.- (n,1);
	val syst = if (IntInf.< (n,0))
		     then syst
		     else
			 add_knowledges_to_adv n syst;
    in
	syst

    end;  

fun update_with_fresh_name be bv syst =
    let
	
	val Fr_bv = Fr bv;
	    
	val bv0 = ``BVar "R0" (BType_Imm Bit64)``;
		  
	val syst =  update_envvar bv0 Fr_bv syst; (* update environment *)  
	
	val syst = update_symbval be Fr_bv syst; (* update symbolic value *)
	
	val syst = update_path bv syst; (* update path condition *)

    in
	syst
    end;
    
fun Adv av syst =
    let
	val n = List.nth (readint_inputs "Adversary-number of inputs", 0);

	val syst =  add_knowledges_to_adv (n-1) syst;

	val syst =  update_envvar ``BVar "R0" (BType_Imm Bit64)`` av syst; (* update environment *) 

	val Fn_av = mk_BExp_Den(get_bvar_fresh (bir_envSyntax.mk_BVar_string ("a", “BType_Imm Bit64”))); (* generate a fresh name *)

	val syst = update_symbval Fn_av av syst; (* update symbolic value *)

	val syst = update_with_fresh_name Fn_av av syst;	    
    in
	syst
    end;
        

fun Event lib_type syst =
    let

	val event_names = bir_symbexec_oracleLib.read_fun_names "Event-Names";

	val systs = if (hd(event_names) = "HMAC_receive")
		    then
			(state_branch_simp
			 "event"
			 (``bir_exp_true``)
			 (I)
			 (I)
			 syst)
		    else
			[state_add_path lib_type ``bir_exp_true`` syst];
	    
    in
	systs
    end;   

fun One_Time_Pad syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("OTP", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	
	
	val syst = update_path vn syst; (* update path condition *)

	val Fn_vn = mk_BExp_Den(get_bvar_fresh (bir_envSyntax.mk_BVar_string ("otp", “BType_Imm Bit64”))); (* generate a fresh name *)
	    
	val syst = update_with_fresh_name Fn_vn vn syst;
	    
	(* val syst = state_add_path "nonce" Fn_vn syst; (* update path condition *) *)

	val syst = update_lib_syst Fn_vn vn syst; (* update syst *)
	    
    in
	syst
    end; 

fun Random_Number syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("RAND_NUM", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	
	
	val syst = update_path vn syst; (* update path condition *)

	val Fn_vn = mk_BExp_Den(get_bvar_fresh (bir_envSyntax.mk_BVar_string ("rand_num", “BType_Imm Bit64”))); (* generate a fresh name *)
	    
	val syst = update_with_fresh_name Fn_vn vn syst;

	(* val syst = state_add_path "nonce" Fn_vn syst; (* update path condition *)  *)   

	val syst = update_lib_syst Fn_vn vn syst; (* update syst *)
	    
    in
	syst
    end;

fun kdfPtoS syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("PtoS", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	
	
	val syst = update_path vn syst; (* update path condition *)

	val Fn_vn = mk_BExp_Den(get_bvar_fresh (bir_envSyntax.mk_BVar_string ("pTOs", “BType_Imm Bit64”))); (* generate a fresh name *)
	    
	val syst = update_with_fresh_name Fn_vn vn syst;

	val syst = state_add_path "kPS" Fn_vn syst; (* update path condition *)

	val syst = update_lib_syst Fn_vn vn syst; (* update syst *)
	    
    in
	syst
    end;     

fun kdfStoP syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("StoP", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	
	
	val syst = update_path vn syst; (* update path condition *)

	val Fn_vn = mk_BExp_Den(get_bvar_fresh (bir_envSyntax.mk_BVar_string ("sTOp", “BType_Imm Bit64”))); (* generate a fresh name *)
	    
	val syst = update_with_fresh_name Fn_vn vn syst;

	val syst = state_add_path "kSP" Fn_vn syst; (* update path condition *)   

	val syst = update_lib_syst Fn_vn vn syst; (* update syst *)
	    
    in
	syst
    end;
    
fun session_key syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("SKey", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	
	
	val syst = update_path vn syst; (* update path condition *)

	val Fn_vn = mk_BExp_Den(get_bvar_fresh (bir_envSyntax.mk_BVar_string ("sk", “BType_Imm Bit64”))); (* generate a fresh name *)
	    
	val syst = update_with_fresh_name Fn_vn vn syst;

	val syst = state_add_path "kS" vn syst; (* update path condition *)   

	val syst = update_lib_syst Fn_vn vn syst; (* update syst *)

    in
	syst
    end;
    
fun new_key syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	

	val Fn_vn = mk_BExp_Den(get_bvar_fresh (bir_envSyntax.mk_BVar_string ("k", “BType_Imm Bit64”))); (* generate a fresh name *)
	    
	val syst = update_with_fresh_name Fn_vn vn syst;

	val syst = state_add_path "kAB" vn syst; (* update path condition *)
	    
(*	val syst = update_lib_syst Fn_vn vn syst;  update syst for Libs *)
	    
    in
	syst
    end;   

fun Encryption syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs_mem (n-2) syst; (* get values *)
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
	
(*	val syst = update_path iv syst;  update path condition *)  

	val (C_bv, C_be) = encrypt inputs iv; (* encrypt with iv *)

	val Fr_Enc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Enc) (C_bv)``; (* assign value of R0 to the fresh variable *)
	
	val syst = state_add_path "cipher" C_be syst; (* update path condition *)
	    
	val syst = update_lib_syst C_be Fr_Enc syst; (* update syst *)

	val syst = add_knowledges_to_adv 0 syst; (*The adversary has a right to know the output of the encryption function.*)
	
    in
	syst
    end;
 
fun Decryption syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val Cipher = compute_inputs_mem (n-1) syst; (* get values *)

	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
		    
	val (M_bv, M_be) = decrypt Cipher iv; (* decrypt with iv *)

	val Fr_Dec = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Dec) (M_bv)``; (* assign value of R0 to the fresh variable *)
	    
	val syst = state_add_path "msg" M_be syst; (* update path condition *)
	    
	val syst = update_lib_syst M_be Fr_Dec syst; (* update syst *)
	    		    
    in
	syst
    end;

fun Signature syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs_mem (n-2) syst; (* get values *)
	    
	val sk = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("SKc", “BType_Imm Bit64”)); (* generate a fresh sk *)
	
 (*	val syst = update_path sk syst; update path condition *)  

	val (S_bv, S_be) = Sign inputs sk; (* Sign with sk *)

	val Fr_Sig = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Sig", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Sig) (S_bv)``; (* assign value of R0 to the fresh variable *)
	
	val syst = state_add_path "signature" S_be syst; (* update path condition *)
	    
	val syst = update_lib_syst S_be Fr_Sig syst; (* update syst *)

	val syst = add_knowledges_to_adv 0 syst; (*The adversary has a right to know the output of the signature function.*)
	
    in
	syst
    end;


 fun Verify syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs_mem (n-2) syst; (* get values *)
	    
	val pk = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("PKc", “BType_Imm Bit64”)); (* generate a fresh sk *)
	
	 (*val syst = update_path pk syst; update path condition *)  

	val (V_bv, V_be) = ver inputs pk; (* Sign with sk *)

	val Fr_Ver = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Ver", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Ver) (V_bv)``; (* assign value of R0 to the fresh variable *)
	
	val syst = state_add_path "ver" V_be syst; (* update path condition *)
	    
	val syst = update_lib_syst Fr_Ver Fr_Ver syst; (* update syst *)
	
    in
	syst
    end;

     
fun HMAC_Send syst =
    let
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	    
	val inputs = compute_inputs_mem (n-1) syst; (* get values *)
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
		    
	val (M_bv, M_be) = HMac inputs iv; (* HMac with key *)

	val Fr_Hmac = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("HMAC", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Hmac) (M_bv)``; (* assign value of R0 to the fresh variable *)

	val syst = state_add_path "Hmac" M_be syst; (* update path condition *)
	    
	val syst = update_lib_syst M_be Fr_Hmac syst; (* update syst *)

	(*val syst = add_knowledges_to_adv 0 syst;  The adversary has a right to know the output of the hmac function.*)

    in
	syst
    end;

fun HMAC_Receive syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
 
	val inputs = compute_inputs_mem (n-1) syst; (* get values *)
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
	    
	val (M_bv, M_be) = HMac inputs iv; (* HMac with key *)

	val Fr_Hmac = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("HMAC", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Hmac) (M_bv)``; (* assign value of R0 to the fresh variable *)

	val syst = state_add_path "msg" M_be syst; (* update path condition *)
	    
	val syst = update_lib_syst M_be Fr_Hmac syst; (* update syst *)

    in
	syst
    end;

    
fun Xor syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs_mem (n-2) syst; (* get values *) 

	val (x_bv, x_be) = XOR inputs; (* xor inputs *)

	val Fr_Xor = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("XOR", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Xor) (x_bv)``; (* assign value of R0 to the fresh variable *)

	val syst = state_add_path "XOR" x_be syst; (* update path condition *)

	val syst = update_lib_syst x_be Fr_Xor syst; (* update syst *)

	
	
    in
	syst
    end;


fun Concat syst =
    let
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs_mem (n-2) syst; (* get values *) 

	val (x_bv, x_be) = CON inputs; (* Con inputs *)

	val Fr_Con = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("concat", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Con) (x_bv)``; (* assign value of R0 to the fresh variable *)

	val syst = state_add_path "concat" x_be syst; (* update path condition *)

	val syst = update_lib_syst x_be Fr_Con syst; (* update syst *)

	val syst = add_knowledges_to_adv 0 syst; (*The adversary has a right to know the output of the encryption function.*)
	
    in
	syst
    end;

fun New_memcpy syst =
    let
	
	val bv_mem = find_bv_val ("New_memcpy::bv in env not found") (SYST_get_env syst) “BVar "MEM" (BType_Mem Bit64 Bit8)”;
		    
	val bv_r1 = find_bv_val ("New_memcpy::bv in env not found") (SYST_get_env syst) “BVar "R1" (BType_Imm Bit64)”;

	val be_r0 = (symbval_bexp o get_state_symbv " New_memcpy::vals not found " “BVar "R0" (BType_Imm Bit64)”) syst;

	val endi = “BEnd_LittleEndian”;
	    
	val be = (mk_BExp_Store (mk_BExp_Den(bv_mem), be_r0, endi, mk_BExp_Den(bv_r1)));

	val Fr_mem = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("MEM", “BType_Mem Bit64 Bit8”));

	val syst =  update_envvar “BVar "MEM" (BType_Mem Bit64 Bit8)” Fr_mem syst; (* update environment *)  
	
	val syst = update_symbval be Fr_mem syst; (* update symbolic value *)
    in
	syst
    end;


   
(*    
fun Load_file syst =
    let
	
	val bv_mem = find_bv_val ("New_memcpy::bv in env not found") (SYST_get_env syst) “BVar "MEM" (BType_Mem Bit64 Bit8)”;
		    
	val Fr_load = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Load", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val endi = “BEnd_LittleEndian”;

	val Vtype = “Bit64”;
		    
	val be = (mk_BExp_Load (mk_BExp_Den(bv_mem), mk_BExp_Den(Fr_load), endi, Vtype));

	val Fr_r1 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("R1", “BType_Imm Bit64”));

	val syst =  update_envvar “BVar "R1" (BType_Imm Bit64)” Fr_r1 syst; (* update environment *)  
	
	val syst = update_symbval be Fr_r1 syst; (* update symbolic value *)
    in
	syst
    end;
 *)

fun Load_file syst =
    let
	
	val lf = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Load", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	

	val Fn_lf = mk_BExp_Den(get_bvar_fresh (bir_envSyntax.mk_BVar_string ("load", “BType_Imm Bit64”))); (* generate a fresh name *)
	    
	val syst = update_with_fresh_name Fn_lf lf syst;

	val syst = state_add_path "L_File" Fn_lf syst; (* update path condition *)

    in
	syst
    end;

    
end(*local*)

end (* struct *)

