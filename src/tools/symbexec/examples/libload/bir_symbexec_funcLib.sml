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

val _ = Parse.type_abbrev("hash2", ``:bir_var_t -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("hash3", ``:bir_var_t -> bir_var_t -> bir_var_t -> bir_exp_t``);    

val _ = Parse.type_abbrev("exclusive_or", ``:bir_var_t -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("enc", ``:bir_var_t -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("enc1", ``:bir_var_t -> bir_var_t -> bir_var_t -> bir_exp_t``);    

val _ = Parse.type_abbrev("sign", ``:bir_var_t list -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("verify", ``:bir_var_t list -> bir_var_t -> bir_exp_t``);
    
val _ = Parse.type_abbrev("dec", ``:bir_var_t -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("concatenate", ``:bir_var_t list -> bir_exp_t``);

val _ = Parse.type_abbrev("conc1", ``:bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("conc2", ``:bir_var_t -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("conc3", ``:bir_var_t -> bir_var_t -> bir_exp_t``);
    
val _ = Parse.type_abbrev("pars1", ``:bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("pars2", ``:bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("pars3", ``:bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("pars4", ``:bir_var_t -> bir_exp_t``);    

val _ = Parse.type_abbrev("kgen1", ``:bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("kgen", ``:bir_var_t -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("kdfPtoS", ``:bir_var_t -> bir_var_t -> bir_exp_t``);

val _ = Parse.type_abbrev("kdfStoP", ``:bir_var_t -> bir_var_t -> bir_exp_t``);    
    
    
(*
val bv_mem = ``BExp_Store (BExp_Den (BVar "160_MEM" (BType_Mem Bit64 Bit8)))
  (BExp_Den (BVar "163_R0" (BType_Imm Bit64))) BEnd_LittleEndian
  (BExp_Const (Imm8 2w))
``;



*)
    
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

fun Encrypt input1 input2 input3 =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (enc1
			  ( response)
			  ( ^input2)
			  ( ^input3))``;

    in
	dest_BStmt_Assign stmt
    end;

fun Encrypt2 input1 input2 =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (enc
			  ( ^input1)
			  ( ^input2))``;

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
    
fun ver input pkP =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(verify
			     ( ^input)
			     (pkP))``;

    in
	dest_BStmt_Assign stmt
    end;
    
fun decrypt Cipher SK =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(dec
			     ( ^Cipher)
			     ( ^SK))``;

    in
	dest_BStmt_Assign stmt
    end;

fun XOR input pad =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (exclusive_or
			  ( ^input)
			  ( pad))``;

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
			     ( ^inputs))``;

 val inputs = ``BExp_Const (Imm8 2w)``;
 val iv = ``BVar "1_iv" (BType_Imm Bit64)``;
*)

fun HMac2 inputs key =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (hash2
			  ( ^inputs)
			  ( keyAB))``;
    in
	dest_BStmt_Assign stmt
    end;

fun HMac3 input1 input2 key =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (hash3
			  ( ^input1)
			  ( ^input2)
			  ( pkS))``;
    in
	dest_BStmt_Assign stmt
    end;
    
fun Conc1 input =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (conc1
			  ( ^input))``;
    in
	dest_BStmt_Assign stmt
    end;

fun Conc2 input1 input2 =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (conc2
			  ( clientID)
			  ( ^input2))``;
    in
	dest_BStmt_Assign stmt
    end;
    
fun Conc3 input1 input2 =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (conc3
			  ( request)
			  ( ^input2))``;
    in
	dest_BStmt_Assign stmt
    end;    

fun Pars1 input =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (pars1
			  ( ^input))``;
    in
	dest_BStmt_Assign stmt
    end;

fun Pars2 input =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (pars2
			  ( ^input))``;
    in
	dest_BStmt_Assign stmt
    end;    

fun Pars3 input =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (pars3
			  ( ^input))``;
    in
	dest_BStmt_Assign stmt
    end; 

fun Pars4 input =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (pars4
			  ( ^input))``;
    in
	dest_BStmt_Assign stmt
    end;
    
fun Kgen1 input =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (kgen1
			  ( ^input))``;
    in
	dest_BStmt_Assign stmt
    end;    

fun Kgen2 input1 input2 =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (kgen
			  ( g)
			  ( ^input2))``;
    in
	dest_BStmt_Assign stmt
    end;

fun Kgen3 input1 input2 =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (kgen
			  ( ^input1)
			  ( ^input2))``;
    in
	dest_BStmt_Assign stmt
    end;

fun KDfPtoS input1 input2 =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (kdfPtoS
			  ( ^input1)
			  ( ^input2))``;
    in
	dest_BStmt_Assign stmt
    end;

fun KDfStoP input1 input2 =
    let

	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
		     (kdfStoP
			  ( ^input1)
			  ( ^input2))``;
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
	    
	val bv_mem =  “BVar "MEM" (BType_Mem Bit64 Bit8)”;

	val _ = print ("bv_mem " ^ term_to_string bv_mem^"\n");

	val be_mem =  (symbval_bexp o get_state_symbv " be not found " bv_mem) syst;
	    
	val _ = print ("be_mem " ^ term_to_string be_mem^"\n");

	val (exp1,exp2,endi,exp3) = dest_BExp_Store be_mem;

	val be_r = if (is_BExp_Cast exp3)
		   then
		       let
			   val (exp,bv,bit) = dest_BExp_Cast exp3;
			   val bv_s =  dest_BExp_Den bv;
		       in
			   (symbval_bexp o get_state_symbv " vals not found " bv_s) syst
		       end
		   else if (is_BExp_Den exp3)
		   then
		       let
			   val bv_s = dest_BExp_Den exp3;
		       in
			   ((symbval_bexp o get_state_symbv " vals not found " bv_s) syst) handle e => bv_s
		       end
		   else if (is_BExp_Const exp3)
		   then
		       exp3
		   else raise ERR "compute_inputs_mem" "this should not happen";
val _ = print ("be_mem " ^ term_to_string be_r^"\n");
(*
	val n = n-1;
	val inputs = if (n < 0)
		     then []
		     else
			 be_r :: compute_inputs_mem n syst;
*)		    
	
    in
	be_r
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
	(* val syst = update_symbval be bv syst;  update symbolic value *)
	
	val bv_mem = find_bv_val ("store_mem::bv in env not found") (SYST_get_env syst) “BVar "MEM" (BType_Mem Bit64 Bit8)”;
		     
	val be_add = (symbval_bexp o get_state_symbv "store_mem::vals not found " “BVar "SP_EL0" (BType_Imm Bit64)”) syst;

	val endi = “BEnd_LittleEndian”;
	    
	val be = (mk_BExp_Store (mk_BExp_Den(bv_mem), be_add, endi, mk_BExp_Den(bv)));

	val Fr_mem = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("MEM", “BType_Mem Bit64 Bit8”));

	val syst =  update_envvar “BVar "MEM" (BType_Mem Bit64 Bit8)” Fr_mem syst; (* update environment *)  
	
	val syst = update_symbval be Fr_mem syst; (* update symbolic value *)

	(*val syst = update_path bv syst;  update path condition *)
    in
	syst
    end;     

fun store_mem_r0 be bv syst =
    let
	val fr_bv = Fr bv;

	    val _ = print ("bv " ^ term_to_string bv^"\n");
	    val _ = print ("be " ^ term_to_string be^"\n");
	

	val syst = (SYST_update_pred ((fr_bv)::(SYST_get_pred syst)) o update_symbval be fr_bv) syst;
	    
	(*val syst = update_symbval be bv syst;  update symbolic value *)
	
	val bv_mem = find_bv_val ("store_mem::bv in env not found") (SYST_get_env syst) “BVar "MEM" (BType_Mem Bit64 Bit8)”;
		     
	val be_add = (symbval_bexp o get_state_symbv "store_mem::vals not found " “BVar "SP_EL0" (BType_Imm Bit64)”) syst handle e =>mk_BExp_Den(``BVar "sy_SP_EL0" (BType_Imm Bit64)``);

	val endi = “BEnd_LittleEndian”;
	    
	val be_mem = (mk_BExp_Store (mk_BExp_Den(bv_mem), be_add, endi, mk_BExp_Den(bv)));

	val Fr_mem = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("MEM", “BType_Mem Bit64 Bit8”));

	val syst =  update_envvar “BVar "MEM" (BType_Mem Bit64 Bit8)” Fr_mem syst; (* update environment *)  
	
	val syst = update_symbval be_mem Fr_mem syst; (* update symbolic value *)

	val bv0 = ``BVar "R0" (BType_Imm Bit64)``;

	val Fr_r0 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("R0", “BType_Mem Bit64 Bit8”));
		  
	val syst =  update_envvar bv0 Fr_r0 syst; (* update environment *)  
	
	val syst = update_symbval be_add Fr_r0 syst; (* update symbolic value *)

	    
    in
	syst
    end;     

fun store_advmem be bv syst =
    let
	val fr_bv = Fr bv;

	val syst = (SYST_update_pred ((fr_bv)::(SYST_get_pred syst)) o update_symbval be fr_bv) syst;
	    
	val syst = update_symbval be bv syst;  (*update symbolic value *)
	(*
	val bv_mem = find_bv_val ("store_advmem::bv in env not found") (SYST_get_env syst) “BVar "Adv_MEM" (BType_Mem Bit64 Bit8)”;
		     
	val be_add = (symbval_bexp o get_state_symbv "store_mem::vals not found " “BVar "SP_EL0" (BType_Imm Bit64)”) syst;

	val endi = “BEnd_LittleEndian”;
	    
	val be_mem = (mk_BExp_Store (mk_BExp_Den(bv_mem), be_add, endi, mk_BExp_Den(bv)));

	val Fr_mem = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Adv_MEM", “BType_Mem Bit64 Bit8”));

	val syst =  update_envvar “BVar "Adv_MEM" (BType_Mem Bit64 Bit8)” Fr_mem syst; (* update environment *)  
	
	val syst = update_symbval be_mem Fr_mem syst; (* update symbolic value *)*)

	    
    in
	syst
    end;     

    
fun add_knowledge_r0 bv syst =
    let
	val syst = state_add_path "Kr" bv syst;

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


fun find_adv_name syst =
    let
	 val bv_adv = “BVar "Adv_MEM" (BType_Mem Bit64 Bit8)”;

	(*val _ = print ("bv_adv " ^ term_to_string bv_mem^"\n");*)

	val be_adv =  (symbval_bexp o get_state_symbv " be not found " bv_adv) syst;
    in
	be_adv

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

fun update_key be bv syst =
    let
	val bv_key = ``BVar "key" (BType_Imm Bit64)``;

	val syst =  update_envvar bv_key bv syst;

	val fr_bv = Fr bv;

	val syst = (SYST_update_pred ((fr_bv)::(SYST_get_pred syst)) o update_symbval be fr_bv) syst;
	    
	val syst = update_symbval be bv syst;

    (*
	val Fr_bv = Fr bv;

	val syst = (SYST_update_pred ((Fr_bv)::(SYST_get_pred syst)) o update_symbval be Fr_bv) syst;

	val syst = update_path bv  syst;

	val bv_key = ``BVar "key" (BType_Imm Bit64)``;

	val syst =  update_envvar bv_key bv syst;
	    
	val syst = update_symbval be bv syst; (* update symbolic value *)*)

    in
	syst
    end;    
    
fun Adv av syst =
    let

	val syst =  update_envvar “BVar "Adv_MEM" (BType_Mem Bit64 Bit8)” av syst; (* update environment *) 

	val Fn_av = mk_BExp_Den(get_bvar_fresh (bir_envSyntax.mk_BVar_string ("a", “BType_Imm Bit64”))); (* generate a fresh name *)

 (*	val syst = update_symbval Fn_av av syst; update symbolic value *)

	val syst = store_advmem Fn_av av syst;
	    
	(*val syst = update_with_fresh_name Fn_av av syst;*)
	    
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
    
fun Concat1 syst =
    let
	val flag = true;

	val input = if (flag = true)
		    then (compute_inputs_mem (1) syst)
		    else (find_adv_name syst);

	val (C_bv, C_be) = Conc1 input;
	    
	val Fr_conc1 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Conc1", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 C_be Fr_conc1 syst; (* update syst *)

    in
	syst
    end;

fun Concat2 syst =
    let
	val input = compute_inputs_mem (1) syst; (* get values *)

	val str = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("str", “BType_Imm Bit64”)); (* generate a fresh iv *)    
		    
	val (C_bv, C_be) = Conc2 str input; (* Concat with string *)
	    
	val Fr_conc2 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Conc2", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 C_be Fr_conc2 syst; (* update syst *)

	val syst = add_knowledge_r0 Fr_conc2 syst;  (*The adversary has a right to know *)

    in
	syst
    end;

    
fun Parse1 syst =
    let
	val be_adv = find_adv_name syst;
		    
	val (P_bv, P_be) = Pars1 be_adv; (* Parse input *)
	    
	val Fr_par1 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Pars1", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 P_be Fr_par1 syst; (* update syst *)

    in
	syst
    end;

fun Parse2 syst =
    let
	
	val be_adv = find_adv_name syst;   
		    
	val (P_bv, P_be) = Pars2 be_adv; (* Parse inputs *)
	    
	val Fr_par2 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Pars2", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 P_be Fr_par2 syst; (* update syst *)

    in
	syst
    end;

fun Parse3 syst =
    let
	
	val input = compute_inputs_mem (1) syst; (* get values *) 
		    
	val (P_bv, P_be) = Pars3 input; (* Parse inputs *)
	    
	val Fr_par3 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Pars3", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val syst = store_mem_r0 P_be Fr_par3 syst; (* update syst *)

	val syst = hd(Event "event1" syst);    
	    

    in
	syst
    end;


fun Parse4 msg syst =
    let  
		    
	val (P_bv, P_be) = Pars4 msg; (* Parse inputs *)
	    
	val Fr_par4 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Pars4", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 P_be Fr_par4 syst; (* update syst *)

	val lk = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("lk", “BType_Imm Bit64”));

	val syst = update_key Fr_par4 lk syst;

    in
	syst
    end;    

fun Concat3 syst =
    let
	val syst = Parse1 syst;
	    
	val input = compute_inputs_mem (1) syst; (* get values *)

	val str = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("str", “BType_Imm Bit64”));   
		    
	val (C_bv, C_be) = Conc2 str input; (* Concat with string *)
	    
	val Fr_conc2 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Conc2", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 C_be Fr_conc2 syst; (* update syst *)

    in
	syst
    end;    

fun Concat4 syst =
    let
	val syst = Parse1 syst;
	    
	val input = compute_inputs_mem (1) syst; (* get values *)
		    
	val (C_bv, C_be) = Conc1 input; (* Concat with string *)
	    
	val Fr_conc1 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Conc1", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 C_be Fr_conc1 syst; (* update syst *)

    in
	syst
    end;    

fun Concat5 syst =
    let
	val syst = Parse1 syst;
	    
	val input = compute_inputs_mem (1) syst; (* get values *)

	val str = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("str", “BType_Imm Bit64”)); (* generate a fresh iv *) 
		    
	val (C_bv, C_be) = Conc2 input str; (* Concat with string *)
	    
	val Fr_conc2 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Conc2", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 C_be Fr_conc2 syst; (* update syst *)

    in
	syst
    end;

fun Concat6 syst =
    let
	val input = (symbval_bexp o get_state_symbv "concat6::bv in env not found"  ``BVar "key" (BType_Imm Bit64)``) syst;

	val str = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("str", “BType_Imm Bit64”));   
		    
	val (C_bv, C_be) = Conc3 str input; (* Concat with string *)
	    
	val Fr_conc3 = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Conc3", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 C_be Fr_conc3 syst; (* update syst *)

    in
	syst
    end;     
      



fun Compare syst =
    let

	val input1 = compute_inputs_mem (1) syst;

	val syst = Parse2 syst;
	    
	val input2 = compute_inputs_mem (1) syst;

	val D_input1 = mk_BExp_Den(input1);

	val D_input2 = mk_BExp_Den(input2);

	val cnd = ``BExp_BinPred BIExp_Equal
		    ( ^D_input1)
		    ( ^D_input2)``;
		  
	val systs1 = ((Event "event3") o I o state_add_path "comp_true_cnd" cnd) syst;
	val systs2 = ((Event "event3") o I o state_add_path "comp_false_cnd" (bslSyntax.bnot cnd)) syst;

	    
    in
	systs1@systs2
    end;

fun Compare1 syst =
    let

	val input1 = compute_inputs_mem (1) syst;

	val syst = Parse3 syst;
	    
	val input2 = compute_inputs_mem (1) syst;

	val D_input1 = mk_BExp_Den(input1);

	val D_input2 = mk_BExp_Den(input2);

	val cnd = ``BExp_BinPred BIExp_Equal
		    ( ^D_input1)
		    ( ^D_input2)``;
		  
	val systs1 = ((Event "event1") o I o state_add_path "comp_true_cnd" cnd) syst;
	val systs2 = ((Event "event1") o I o state_add_path "comp_false_cnd" (bslSyntax.bnot cnd)) syst;

	    
    in
	systs1@systs2
    end;

fun Compare2 syst =
    let

	val input1 = compute_inputs_mem (1) syst;

	val D_input1 = mk_BExp_Den(input1);


	val cnd = ``BExp_BinPred BIExp_Equal
		    ( ^D_input1)
		    (bir_exp_true)``;
		  
	val systs1 = ((Event "event2") o I o state_add_path "comp_true_cnd" cnd) syst;
	val systs2 = ((Event "event2") o I o state_add_path "comp_false_cnd" (bslSyntax.bnot cnd)) syst;

	    
    in
	systs1@systs2
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

fun KdfPtoS key hash syst =
    let
	val vn =  get_bvar_fresh (bir_envSyntax.mk_BVar_string ("PtoS", “BType_Imm Bit64”)); (* generate a fresh variable *)	  

	val (s_bv, s_be) = KDfPtoS key hash; (* generate key based on a seed *)

	val Fr_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("kPS", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val syst = store_mem_r0 s_be Fr_vn syst; (* update syst *) 

	val syst = update_key Fr_vn vn syst;
	    
    in
	syst
    end;     

fun KdfStoP key hash syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("StoP", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val (s_bv, s_be) = KDfStoP key hash;

	val Fr_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("kSP", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val syst = store_mem_r0 s_be Fr_vn syst; (* update syst *) 	
	    
    in
	syst
    end;
    
fun session_key1 syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("SKey", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val syst = update_path vn syst;  (*update path condition *)
	    
	val (s_bv, s_be) = Kgen1 vn; (* generate key based on a seed *)

	val Fr_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("sk", “BType_Imm Bit64”)); (* generate a fresh name *)

	val syst = store_mem_r0 s_be Fr_vn syst; (* update syst *) 

	val syst = update_key Fr_vn vn syst;


    in
	syst
    end;

fun DH_key vn syst =
    let

	val be_adv = find_adv_name syst;
	    
	val (s_bv, s_be) = Kgen3 be_adv vn; (* generate key based on a seed *)

	val Fr_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("kAB", “BType_Imm Bit64”)); (* generate a fresh name *)

	val syst = store_mem_r0 s_be Fr_vn syst; (* update syst *) 

	val syst = update_key Fr_vn vn syst;

    in
	syst
    end;
    
fun session_key syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("SKey", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val syst = update_path vn syst;  (*update path condition *)

	val g = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("g", “BType_Imm Bit64”)); (* generate a fresh name *)
	    
	val (s_bv, s_be) = Kgen2 g vn; (* generate key based on a seed *)

	val Fr_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("sk", “BType_Imm Bit64”)); (* generate a fresh name *)

	val syst = add_knowledge_r0 Fr_vn syst;  (*The adversary has a right to know *)    

	val syst = DH_key vn syst;

	val syst = store_mem_r0 s_be Fr_vn syst; (* update syst *)

    in
	syst
    end;
    
(*
RPC-enc client    
fun new_key syst =
    let

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	

	val Fr_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("kAB", “BType_Imm Bit64”)); (* generate a fresh name *)
	    
	val syst = store_mem_r0 vn Fr_vn syst; (* update syst *)    
	    
    in
	syst
    end;   

fun Encryption syst =
    let
	val syst = Concat6 syst;
	    
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val input = compute_inputs_mem (n-2) syst; (* get values *)

	val syst =  new_key syst;

	val key = compute_inputs_mem (1) syst;
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
	
	val syst = update_path iv syst;  (*update path condition *)  

	val (C_bv, C_be) = Encrypt input key iv; (* encrypt with iv *)

	val Fr_Enc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 C_be Fr_Enc syst; (* update syst *)

	val syst = Concat2 syst;
	
    in
	syst
    end;
 
fun Decryption syst =
    let
	val input = (symbval_bexp o get_state_symbv "Dec::bv in env not found"  ``BVar "key" (BType_Imm Bit64)``) syst; 
	
	val be_adv = find_adv_name syst;
		    
	val (M_bv, M_be) = decrypt be_adv input; (* decrypt with iv *)

	val Fr_Dec = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val syst = store_mem_r0 M_be Fr_Dec syst; (* update syst *)

	val syst = hd(Event "event2" syst);
	    		    
    in
	syst
    end;
 
RPC-enc server  
fun new_key syst =
    let
	val syst = Parse1 syst;

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	

	val Fr_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("kAB", “BType_Imm Bit64”)); (* generate a fresh name *)
	    
	val syst = store_mem_r0 vn Fr_vn syst; (* update syst *)    
	    
    in
	syst
    end;
    
fun Encryption syst =
    let
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val input = compute_inputs_mem (n-2) syst; (* get values *)
	    
	val key = (symbval_bexp o get_state_symbv "Dec::bv in env not found"  ``BVar "key" (BType_Imm Bit64)``) syst; 
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
	
	val syst = update_path iv syst;  (*update path condition *)  

	val (C_bv, C_be) = Encrypt input key iv; (* encrypt with iv *)

	val Fr_Enc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 C_be Fr_Enc syst; (* update syst *)

	val syst = add_knowledge_r0 Fr_Enc syst;  (*The adversary has a right to know *)
	
    in
	syst
    end;
 
fun Decryption syst =
    let
	val syst =  new_key syst;

	val key = compute_inputs_mem (1) syst;

	val syst = Parse2 syst;
	    
	val cipher = compute_inputs_mem (1) syst;
		    
	val (M_bv, M_be) = decrypt cipher key; (* decrypt with key *)

	val Fr_Dec = (get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit64”))); (* generate a fresh variable *)

	val syst = store_mem_r0 M_be Fr_Dec syst; (* update syst *)

	val syst = Parse3 syst;

	val syst = Parse4 Fr_Dec syst;

	val syst = Encryption syst;
	    		    
    in
	syst
    end;
*)
fun new_key syst =
    let
	val syst = Parse1 syst;

	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit64”)); (* generate a fresh variable *)	    	

	val Fr_vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("kAB", “BType_Imm Bit64”)); (* generate a fresh name *)
	    
	val syst = store_mem_r0 vn Fr_vn syst; (* update syst *)    
	    
    in
	syst
    end;
    
fun Decryption syst =
    let
	val av = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Adv", “BType_Mem Bit64 Bit8”)); (* generate a fresh variable *)

	val syst = Adv av syst;

	val key = (symbval_bexp o get_state_symbv "Dec::bv in env not found"  ``BVar "key" (BType_Imm Bit64)``) syst; 

	val be_adv = find_adv_name syst;
		    
	val (M_bv, M_be) = decrypt be_adv key; (* decrypt with key *)

	val Fr_Dec = (get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit64”))); (* generate a fresh variable *)

	val syst = store_mem_r0 M_be Fr_Dec syst; (* update syst *)
	    		    
    in
	syst
    end;
    
fun Encryption syst =
    let
	val key = compute_inputs_mem (1) syst; (* get values *)
	    
	val syst = Decryption syst;

	val msg = compute_inputs_mem (1) syst; (* get values *)   

	val (C_bv, C_be) = Encrypt2 msg key; (* encrypt with iv *)

	val Fr_Enc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit64”)); (* generate a fresh variable *)
	    
	val syst = store_mem_r0 C_be Fr_Enc syst; (* update syst *)

	val syst = add_knowledge_r0 Fr_Enc syst;  (*The adversary has a right to know *)
	
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
	 val syst = Decryption syst;

	 val input = compute_inputs_mem (1) syst; (* get values *)
	     
	 val pk = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("PKc", “BType_Imm Bit64”)); (* generate a fresh sk *)

	 val (V_bv, V_be) = ver input pk; (* Sign with sk *)

	 val Fr_Ver = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Ver", “BType_Imm Bit64”)); (* generate a fresh variable *)

	 val syst = store_mem_r0 V_be Fr_Ver syst; (* update syst *)

	 val syst = hd(Compare2 syst);
	     	     
     in
	 syst
     end;

fun HMAC_Send syst =
    let
	val syst = session_key syst;
	    
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	    
	val key = compute_inputs_mem (n-1) syst;

	val be_adv = find_adv_name syst;
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
		    
	val (M_bv, M_be) = HMac3 be_adv key iv; (* HMac with key *)
	    
	val Fr_Hmac = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("HMAC", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val syst = store_mem_r0 M_be Fr_Hmac syst; (* update syst *)

	val syst = hd(Event "event1" syst);

	val syst = Signature syst;

    in
	syst
    end;

fun KDF syst =
    let
	val syst = HMAC_Send syst;

	val hash = compute_inputs_mem (1) syst;

	val key = (symbval_bexp o get_state_symbv "Dec::bv in env not found"  ``BVar "key" (BType_Imm Bit64)``) syst;     

	val syst = KdfPtoS key hash syst;

	val syst = KdfStoP key hash syst;

	val syst = Encryption syst;

    in
	syst
    end;

(*		     
fun HMAC_Send syst =
    let
	val syst = Concat5 syst;

	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	    
	val inputs = compute_inputs_mem (n-1) syst; (* get values *)
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
		    
	val (M_bv, M_be) = HMac2 inputs iv; (* HMac with key *)
	    
	val Fr_Hmac = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("HMAC", “BType_Imm Bit64”)); (* generate a fresh variable *)

	(*val syst = state_add_path "Hmac" M_be syst;  update path condition *)
	    
	val syst = store_mem_r0 M_be Fr_Hmac syst; (* update syst *)

	val syst = Concat2 syst;


    in
	syst
    end;
*)
fun HMAC_Receive syst =
    let
	val syst = Concat4 syst;
	
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
 
	val inputs = compute_inputs_mem (n-1) syst; (* get values *)
	    
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)
	    
	val (M_bv, M_be) = HMac2 inputs iv; (* HMac with key *)

	val Fr_Hmac = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("HMAC", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val syst = store_mem_r0 M_be Fr_Hmac syst; (* update syst *)

	val syst = hd(Compare syst);

    in
	syst
    end;

    
fun Xor syst =
    let
	val syst = Concat1 syst;
	    
	val n = List.nth (readint_inputs "Library-number of inputs", 0);
	val inputs = compute_inputs_mem (n-1) syst; (* get values *)

	val pad = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("pad", “BType_Imm Bit64”)); (* generate a fresh iv *)    

	val (x_bv, x_be) = XOR inputs pad; (* xor inputs *)

	val Fr_Xor = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("XOR", “BType_Imm Bit64”)); (* generate a fresh variable *)

(*	val stmt = ``BStmt_Assign (Fr_Xor) (x_bv)``; (* assign value of R0 to the fresh variable *)

	val syst = state_add_path "XOR" x_be syst; (* update path condition *)

	val syst = update_lib_syst x_be Fr_Xor syst; (* update syst *)*)

	val syst = store_mem_r0 x_be Fr_Xor syst; (* update syst *)

	 (* val syst = add_knowledge_r0 Fr_Xor syst; The adversary has a right to know *)

		
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

