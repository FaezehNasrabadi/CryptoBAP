structure bir_symbexec_funcLib =
struct

local
  open bir_symbexec_stateLib;
  open bir_symbexec_coreLib;
  open bir_block_collectionLib;
  open Redblackmap;
  val ERR      = Feedback.mk_HOL_ERR "bir_symbexec_funcLib"
in
(*
val prog = ``BirProgram
		 [<|bb_label :=
		  BL_Address_HC (Imm64 2802w)
				"52800000 (mov w0, #0x0 // #0)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
				(BExp_Const (Imm64 0w))];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2804w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2804w) "11000400 (add w0, w0, #0x1)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R0" (BType_Imm Bit64))
				(BExp_Cast BIExp_UnsignedCast
					   (BExp_BinExp BIExp_Plus
							(BExp_Cast BIExp_LowCast
								   (BExp_Den (BVar "R0" (BType_Imm Bit64)))Bit64)
							(BExp_Const (Imm64 1w)))Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2808w)))|>;
						 <|bb_label := BL_Address_HC (Imm64 2808w) "2A0003E5 (mov w5, w0)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R5" (BType_Imm Bit64))
				(BExp_Cast BIExp_UnsignedCast
					   (BExp_Cast BIExp_LowCast
						      (BExp_Den (BVar "R0" (BType_Imm Bit64)))Bit64)Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2812w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2812w) "94000040 (bl 10c <.text+0x10c>)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
				(BExp_Const (Imm64 2814w))];
		  bb_last_statement :=
		  BStmt_Jmp (BLE_Label (BL_Address (Imm64 2002w)))|>;
<|bb_label := BL_Address_HC (Imm64 2814w) "2A0003E2 (mov w2, w0)";
         bb_statements :=
           [BStmt_Assign (BVar "R6" (BType_Imm Bit64))
              (BExp_Cast BIExp_UnsignedCast
                 (BExp_Cast BIExp_LowCast
                    (BExp_Den (BVar "R0" (BType_Imm Bit64)))Bit64)Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2816w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2816w)
				"52800121 (mov w1, #0x9// #9)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R1" (BType_Imm Bit64))
				(BExp_Const (Imm64 9w))];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2820w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2820w) "94000080 (bl 214 <.text+0x214>)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
				(BExp_Const (Imm64 2822w))];
		  bb_last_statement :=
		  BStmt_Jmp (BLE_Label (BL_Address (Imm64 2202w)))|>;
<|bb_label := BL_Address_HC (Imm64 2822w) "2A0003E2 (mov w2, w0)";
         bb_statements :=
           [BStmt_Assign (BVar "R8" (BType_Imm Bit64))
              (BExp_Cast BIExp_UnsignedCast
                 (BExp_Cast BIExp_LowCast
                    (BExp_Den (BVar "R0" (BType_Imm Bit64)))Bit64)Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2824w)))|>;

			    <|bb_label :=
		  BL_Address_HC (Imm64 2824w) "940000C0 (bl 318 <.text+0x318>)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R30" (BType_Imm Bit64))
				(BExp_Const (Imm64 2828w))];
		  bb_last_statement :=
		  BStmt_Jmp (BLE_Label (BL_Address (Imm64 02w)))|>;
			    <|bb_label := BL_Address_HC (Imm64 2828w) "7100001F (cmp w0, #0x0)";
		  bb_statements :=
		  [BStmt_Assign (BVar "ProcState_C" BType_Bool) bir_exp_true;
		   BStmt_Assign (BVar "ProcState_N" BType_Bool)
				(BExp_MSBBit64
					  (BExp_Cast BIExp_LowCast
						     (BExp_Den (BVar "R0" (BType_Imm Bit64)))Bit64));
		   BStmt_Assign (BVar "ProcState_V" BType_Bool) bir_exp_false;
		   BStmt_Assign (BVar "ProcState_Z" BType_Bool)
				(BExp_BinPred BIExp_Equal
					      (BExp_Cast BIExp_LowCast
							 (BExp_Den (BVar "R0" (BType_Imm Bit64)))Bit64)
					      (BExp_Const (Imm64 0w)))];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2832w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2832w)
				"54000060 (b.eq 2c <.text+0x2c> // b.none)";
		  bb_statements := [];
		  bb_last_statement :=
		  BStmt_CJmp (BExp_Den (BVar "ProcState_Z" BType_Bool))
			     (BLE_Label (BL_Address (Imm64 2844w)))
			     (BLE_Label (BL_Address (Imm64 2836w)))|>;
			     <|bb_label := BL_Address_HC (Imm64 2836w) "110008A5 (add w5, w5, #0x2)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R5" (BType_Imm Bit64))
				(BExp_Cast BIExp_UnsignedCast
					   (BExp_BinExp BIExp_Plus
							(BExp_Cast BIExp_LowCast
								   (BExp_Den (BVar "R5" (BType_Imm Bit64)))Bit64)
							(BExp_Const (Imm64 2w)))Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2840w)))|>;
						 <|bb_label :=
		  BL_Address_HC (Imm64 2840w) "14000002 (b 30 <.text+0x30>)";
		  bb_statements := [];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2848w)))|>;
						 <|bb_label := BL_Address_HC (Imm64 2844w) "110004A5 (add w5, w5, #0x1)";
		  bb_statements :=
		  [BStmt_Assign (BVar "R5" (BType_Imm Bit64))
				(BExp_Cast BIExp_UnsignedCast
					   (BExp_BinExp BIExp_Plus
							(BExp_Cast BIExp_LowCast
								   (BExp_Den (BVar "R5" (BType_Imm Bit64)))Bit64)
							(BExp_Const (Imm64 1w)))Bit64)];
		  bb_last_statement := BStmt_Jmp (BLE_Label (BL_Address (Imm64 2848w)))|>;
						 <|bb_label := BL_Address (Imm64 2848w); bb_statements := [];
		  bb_last_statement := BStmt_Halt (BExp_Const (Imm64 0w))|>]``;
    
  
val bl_dict  = bir_block_collectionLib.gen_block_dict prog;
val prog_lbl_tms = bir_block_collectionLib.get_block_dict_keys bl_dict;
val prog_lbl_tms_0 = “BL_Address (Imm64 2802w)”;
val prog_vars = bir_exec_typingLib.gen_vars_of_prog prog;
val n_dict = bir_cfgLib.cfg_build_node_dict bl_dict prog_lbl_tms;
val stop_lbl_tms = [“BL_Address (Imm64 2824w)”];
    
val syst = init_state prog_lbl_tms_0 (``BVar "R7" (BType_Imm Bit64)``::prog_vars);

val Fr_bval = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("init", “BType_Imm Bit64”));
val bv = ``BVar "R0" (BType_Imm Bit64)``;
val deps = Redblackset.add (symbvalbe_dep_empty, bv);
val symbv = SymbValBE (Fr_bval,deps);
val Fr_bv = get_bvar_fresh bv;
val syst = bir_symbexec_stateLib.insert_symbval Fr_bv symbv syst;

val pred_conjs = [``bir_exp_true``];

val syst = state_add_preds "init_pred" pred_conjs syst;

val cfb = false;

listItems(SYST_get_env syst);
      listItems(SYST_get_vals syst);

*)

val _ = Parse.type_abbrev("enc", ``:bir_var_t -> bir_var_t -> bir_var_t -> bir_exp_t``); 

val _ = Parse.type_abbrev("dec", ``:bir_var_t -> bir_var_t -> bir_var_t -> bir_exp_t``);
  
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

fun encrypt be_r0 iv be_r1 =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(enc
			     (be_r0)
			     (iv)
			     (be_r1))``;

    in
	dest_BStmt_Assign stmt
    end;

fun decrypt be_r6 be_r7 be_r8 =
    let
	val stmt = ``BStmt_Assign (BVar "R0" (BType_Imm Bit64))
			(dec
			     (be_r6)
			     (be_r7)
			     (be_r8))``;

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

fun update_path pred syst =
    let
	 val syst = SYST_update_pred ((pred)::(SYST_get_pred syst)) syst;
	 val syst = update_symbval pred pred syst;
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


fun add_knowledge bv syst =
    let
	val symbv = get_state_symbv "symbv not found" bv syst;
	    
	val be = symbval_bexp symbv;

	val syst = state_add_path "K" be syst;
    in
       syst
    end;
    
fun add_knowledges_to_adv syst =
    let
	val syst =  add_knowledge “BVar "R0" (BType_Imm Bit64)” syst;
	val syst =  add_knowledge “BVar "R1" (BType_Imm Bit64)” syst;
(*	val syst =  add_knowledge “BVar "R2" (BType_Imm Bit64)” syst;
	val syst =  add_knowledge “BVar "R3" (BType_Imm Bit64)” syst;
	val syst =  add_knowledge “BVar "R4" (BType_Imm Bit64)” syst;*)
	val syst =  add_knowledge “BVar "R5" (BType_Imm Bit64)” syst;
	val syst =  add_knowledge “BVar "R6" (BType_Imm Bit64)” syst;
    in
       syst
    end;    

fun Adv av syst =
    let

	val syst =  add_knowledges_to_adv syst;
	     
	val syst =  update_envvar ``BVar "R0" (BType_Imm Bit64)`` av syst; (* update environment *)

	val syst = update_symbval av av syst; (* update symbolic value *)

	(* update path condition *)
	val Fr_av = Fr av;
	val syst = update_path Fr_av syst;	    
    in
	syst
    end;
        
fun new_key syst =
    let
	(* generate a fresh variable *)
	val vn = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Key", “BType_Imm Bit64”));

	(* update environment *)
	val bv0 = ``BVar "R0" (BType_Imm Bit64)``;
	val bv6 = ``BVar "R6" (BType_Imm Bit64)``;	  

	val syst =  update_envvar bv0 vn syst; 
	val syst =  update_envvar bv6 vn syst;	    

	val syst = update_symbval vn vn syst; (* update symbolic value *)

	(* update path condition *)
	val Fr_vn = Fr vn;
	val syst = update_path Fr_vn syst;
    in
	syst
    end;   

fun Encryption syst =
    let
	
	val iv = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("iv", “BType_Imm Bit64”)); (* generate a fresh iv *)

	(* update path condition *)
	val Fr_iv = Fr iv;
	val syst = update_path Fr_iv syst;

	(* get value *)
	val be_r0 = (symbval_bexp o get_state_symbv " vals not found " ``BVar "R0" (BType_Imm Bit64)``) syst;
	val be_r1 = (symbval_bexp o get_state_symbv " vals not found " ``BVar "R1" (BType_Imm Bit64)``) syst;	    

	val (C_bv, C_be) = encrypt be_r0 iv be_r1; (* encrypt with iv *)

	val Fr_Enc = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Enc", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Enc) (C_bv)``; (* assign value of R0 to the fresh variable *)
	    
	(* update environment *)
	val bv0 = ``BVar "R0" (BType_Imm Bit64)``;
	val bv7 = ``BVar "R7" (BType_Imm Bit64)``;
	val bv8 = ``BVar "R8" (BType_Imm Bit64)``;
		  
	val syst =  update_envvar bv0 Fr_Enc syst;
	val syst =  update_envvar bv7 iv syst; 
	val syst =  update_envvar bv8 Fr_Enc syst;
	    
	(* update symbolic value *)
	val syst = update_symbval C_be Fr_Enc syst;
	val syst = update_symbval iv iv syst;     
 	     
    in
	syst
    end;
 
fun Decryption syst =
    let
	(* get value *)
	val be_r6 = (symbval_bexp o get_state_symbv " vals not found " ``BVar "R6" (BType_Imm Bit64)``) syst;
	val be_r7 = (symbval_bexp o get_state_symbv " vals not found " ``BVar "R7" (BType_Imm Bit64)``) syst;
	val be_r8 = (symbval_bexp o get_state_symbv " vals not found " ``BVar "R8" (BType_Imm Bit64)``) syst;
	    
	val (M_bv, M_be) = decrypt be_r6 be_r7 be_r8; (* decrypt with iv *)

	val Fr_Dec = get_bvar_fresh (bir_envSyntax.mk_BVar_string ("Dec", “BType_Imm Bit64”)); (* generate a fresh variable *)

	val stmt = ``BStmt_Assign (Fr_Dec) (M_bv)``; (* assign value of R0 to the fresh variable *)

	(* update environment *)
	val bv0 = ``BVar "R0" (BType_Imm Bit64)``;
	val bv1 = ``BVar "R1" (BType_Imm Bit64)``;
	    
	val syst =  update_envvar bv0 Fr_Dec syst; 
	val syst =  update_envvar bv1 Fr_Dec syst;
	    
	val syst = update_symbval M_be Fr_Dec syst; (* update symbolic value *)
		    
    in
	syst
    end;
  
end(*local*)

end (* struct *)

