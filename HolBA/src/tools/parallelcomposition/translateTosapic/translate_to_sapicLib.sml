
structure translate_to_sapicLib :> translate_to_sapicLib =
struct
open Abbrev

local
    open HolKernel Parse boolLib bossLib;
    open sapicplusTheory;
    open sapicplusSyntax;
    open messagesTheory;
    open messagesSyntax;
    open wordsTheory;
    open ASCIInumbersTheory;
    open Arbnumcore;
    open bir_immTheory;
    open bir_valuesSyntax;
    open bir_immSyntax;
    open bir_expSyntax;
    open bir_expTheory;
    open bir_envSyntax;
    open integerTheory;
    open intSyntax;
    open Term;
    open translate_to_sapicTheory;
    open simpLib;
    open Type;
    open wordsSyntax;
	 
    val ERR = mk_HOL_ERR "translate_to_sapicLib";
    val wrap_exn = Feedback.wrap_exn "translate_to_sapicLib";

in
	  
fun bir_exp_to_sapic_term exp =
    let
	val _ = ()
    in
	(* Constants *)
	(* Manual tests
         val exp = ``BExp_Const (Imm64 112w)``;
	 bir_exp_to_sapic_term exp 
	 *)
	if is_BExp_Const exp then
	    let
		val imm = dest_BExp_Const exp;
		val thm0 = SIMP_CONV (srw_ss()) [b2n_def] “(num_to_dec_string ∘ b2n) ^imm”;
		val cons = (snd o dest_eq o concl) thm0;
		val sp_name = mk_Con (mk_Name (PubName_tm, cons));
	    in
		(sp_name,thm0)
	    end
	(* Den *)
	(*
	 val exp = ``(BExp_Den (BVar "MEM" (BType_Mem Bit32 Bit8)))``;
	 val exp = “BExp_Den (BVar "oracle" (BType_Imm Bit32))”
	 *)
	else if is_BExp_Den exp then
	    let
		val (name,bir_type) = (dest_BVar o dest_BExp_Den) exp
		val thm0 = SPEC name (Thm.INST_TYPE [alpha |-> (type_of name)] EQ_REFL);
		val sp_var = mk_TVar (mk_Var (name,(“0:int”)));
	    in   
		(sp_var,thm0)
	    end

	(* Memory constants *)
	(* val exp = ``BExp_MemConst Bit64 Bit8 abcd``; 
		       ``BExp_MemConst Bit128 Bit16 amap``,
		       ``amap :128 |-> 16``
	 *)
	else if is_BExp_MemConst exp then
	    
            let 
		val (addr_bir_ty, val_bir_ty, tm_map) = dest_BExp_MemConst exp;
		val thm0 = SIMP_CONV (srw_ss()) [size_of_bir_immtype_def] “toString (((size_of_bir_immtype) ^addr_bir_ty) + ((size_of_bir_immtype) ^val_bir_ty))”; 
		val cons = (snd o dest_eq o concl) thm0;
		val sp_name = mk_Con (mk_Name (PubName_tm, cons));
	    in
		(sp_name,thm0)
            end
            handle e => raise wrap_exn "bir_exp_to_sapic_term::MemConst" e 
	(* Casts *)
	(* 
	 val exp = ``BExp_Cast BIExp_LowCast
                     (BExp_Den (BVar "R1" (BType_Imm Bit64))) Bit32``;
	 *)
	else if is_BExp_Cast exp then
            let
		val (casttyp, ex, sz) = (dest_BExp_Cast) exp;
		val thm1 = (SIMP_CONV (srw_ss()) [size_of_bir_immtype_def]) “(toString o size_of_bir_immtype) ^sz”;
		val cast_sz = (snd o dest_eq o concl) thm1;
		val cast_sz_st = mk_Con (mk_Name (PubName_tm, cast_sz));
		val (val_st,thm2) = bir_exp_to_sapic_term ex;
		val thm3 =  (SIMP_CONV (srw_ss()) [translate_Cast_to_string_def]) “translate_Cast_to_string ^casttyp”;
		val cast_ty = (snd o dest_eq o concl) thm3;
		val trm_list = (listSyntax.mk_list ([val_st,cast_sz_st],SapicTerm_t_ty));
		val fun_sig = pairSyntax.list_mk_pair [cast_ty,“(2:int)”,Public_tm, Constructor_tm];
		val sp_fun = mk_FAPP (fun_sig,trm_list);
 		val to_st_thm = CONJ (CONJ thm1 thm2) thm3;
            in
		(sp_fun,to_st_thm)
            end
            handle e => raise wrap_exn "bir_exp_to_sapic_term::Cast" e                       
	(* Unary expressions *)
	else if is_BExp_UnaryExp exp then
            (* 
             val exp = ``BExp_UnaryExp BIExp_Not
			 (BExp_BinPred BIExp_Equal
				       (BExp_Den (BVar "oracle" (BType_Imm Bit32)))
				       (BExp_Const (Imm32 0w)))``;
             *)
            let
		val (uop, bir_exp) = (dest_BExp_UnaryExp) exp
		val (exp_sap_tr,thm1) = bir_exp_to_sapic_term bir_exp
		val thm0 = (SIMP_CONV (srw_ss()) [translate_UnaryExp_to_string_def]) ``translate_UnaryExp_to_string ^uop``
		val uop_str = (snd o dest_eq o concl) thm0;
		val trm_list = (listSyntax.mk_list ([exp_sap_tr],SapicTerm_t_ty));
		val fun_sig = pairSyntax.list_mk_pair [uop_str,“(1:int)”,Public_tm, Constructor_tm];
		val sp_fun = mk_FAPP (fun_sig,trm_list);
 		val to_st_thm = CONJ thm1 thm0;
            in
		(sp_fun,to_st_thm)
            end
            handle e => raise wrap_exn "bir_exp_to_sapic_term::unary_exp" e

	(* Binary expressions *)
	else if is_BExp_BinExp exp then
            (* 
             val exp = ``(BExp_BinExp BIExp_Plus (BExp_Const (Imm64 112w)) (BExp_Const (Imm64 11w)))``;
             *)
            let
		val (bop, bir_exp1, bir_exp2) = (dest_BExp_BinExp) exp
		val (st_exp1,thm1) =  bir_exp_to_sapic_term bir_exp1
		val (st_exp2,thm2) =  bir_exp_to_sapic_term bir_exp2
		val thm0 = SIMP_CONV (srw_ss()) [translate_BinExp_to_string_def] ``translate_BinExp_to_string ^bop``;
		val st_bop = (snd o dest_eq o concl) thm0;
		val trm_list = (listSyntax.mk_list ([st_exp1,st_exp2],SapicTerm_t_ty));
		val fun_sig = pairSyntax.list_mk_pair [st_bop,“(2:int)”,Public_tm, Constructor_tm];
		val sp_fun = mk_FAPP (fun_sig,trm_list);
 		val to_st_thm = CONJ (CONJ thm1 thm2) thm0;
            in
		(sp_fun,to_st_thm)
            end
            handle e => raise wrap_exn "bir_exp_to_sapic_term::binary_exp" e
			      
	(* Binary predicates *)
	else if is_BExp_BinPred exp then
            (*
             val exp = ``BExp_BinPred BIExp_Equal
			 (BExp_Den (BVar "oracle" (BType_Imm Bit32)))
			 (BExp_Const (Imm32 0w))``;
             *)
            let
		val (bpred, bir_exp1, bir_exp2) = (dest_BExp_BinPred) exp
		val (st_exp1,thm1) =  bir_exp_to_sapic_term bir_exp1
		val (st_exp2,thm2) =  bir_exp_to_sapic_term bir_exp2
		val thm0 = SIMP_CONV (srw_ss()) [translate_BinPred_to_string_def] ``translate_BinPred_to_string ^bpred``;
		val st_bp = (snd o dest_eq o concl) thm0;
		val trm_list = (listSyntax.mk_list ([st_exp1,st_exp2],SapicTerm_t_ty));
		val fun_sig = pairSyntax.list_mk_pair [st_bp,“(2:int)”,Public_tm, Constructor_tm];
		val sp_fun = mk_FAPP (fun_sig,trm_list);
 		val to_st_thm = CONJ (CONJ thm1 thm2) thm0;
            in
		(sp_fun,to_st_thm)
            end
            handle e => raise wrap_exn "bir_exp_to_sapic_term::binary_pred" e
			      
	(* MemEq expressions *)
	else if is_BExp_MemEq exp then
            (* 
             val exp = ``
			   BExp_MemEq
			   (BExp_Den (BVar "MEM_dest" (BType_Mem Bit32 Bit8)))
			   (BExp_Const (Imm16 (42w :word16)))
			   ``;

             *)
            let
		val (bir_lhs, bir_rhs) = dest_BExp_MemEq exp
		val (lhs,lthm) = bir_exp_to_sapic_term bir_lhs
		val (rhs,rthm) = bir_exp_to_sapic_term bir_rhs
		val trm_list = (listSyntax.mk_list ([lhs,rhs],SapicTerm_t_ty));
		val fun_sig = pairSyntax.list_mk_pair[“"MemEq"”,“(2:int)”,Public_tm, Constructor_tm]
		val sp_fun = mk_FAPP (fun_sig,trm_list);
 		val to_st_thm = (CONJ lthm rthm)
            in
		(sp_fun,to_st_thm)
            end
            handle e => raise wrap_exn "bir_exp_to_sapic_term::mem_eq" e

	(* If-then-else *)
	else if is_BExp_IfThenElse exp then
            (* 
             val exp = ``BExp_IfThenElse
			 (BExp_BinPred BIExp_LessThan (BExp_Const (Imm64 112w)) (BExp_Const (Imm64 11w)))
			 (BExp_Const (Imm64 200w))
			 (BExp_Const (Imm64 404w))``;
             *)
            let
		val (bir_cond_exp, bir_then_exp, bir_else_exp) = dest_BExp_IfThenElse exp
		val (st_cond_exp,thm1) = bir_exp_to_sapic_term bir_cond_exp
		val (st_then_exp,thm2) = bir_exp_to_sapic_term bir_then_exp
		val (st_else_exp,thm3) = bir_exp_to_sapic_term bir_else_exp
		val trm_list = (listSyntax.mk_list ([st_cond_exp,st_then_exp,st_else_exp],SapicTerm_t_ty));
		val fun_sig = pairSyntax.list_mk_pair[“"IfThenElse"”,“(3:int)”,Public_tm, Destructor_tm]
		val sp_fun = mk_FAPP (fun_sig,trm_list);
 		val to_st_thm = CONJ (CONJ thm3 thm2) thm1
            in
		(sp_fun,to_st_thm)
	    end
            handle e => raise wrap_exn "bir_exp_to_sapic_term::if_then_else" e

	(* Load expressions *)
	else if is_BExp_Load exp then
            (*
	     val exp = ``
			   (BExp_Load (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
				      (BExp_BinExp BIExp_Plus
						   (BExp_Den (BVar "R1" (BType_Imm Bit64)))
						   (BExp_Const (Imm64 8w))) BEnd_LittleEndian Bit64)``
             *)
            let
		val (bir_mem, bir_addr, bir_endi, bir_val_ty) = dest_BExp_Load exp;
		val (mem_st,thm1) = bir_exp_to_sapic_term bir_mem;
		val (base_addr_st,thm2) = bir_exp_to_sapic_term bir_addr;
		val thm3 =  (SIMP_CONV (srw_ss()) [translate_Endian_to_string_def]) ``translate_Endian_to_string ^bir_endi``;
		val ld_endi = (snd o dest_eq o concl) thm3
		val ld_endi_st = mk_TVar (mk_Var (ld_endi,(“0:int”)));
		val thm4 = (SIMP_CONV (srw_ss()) [size_of_bir_immtype_def]) “(toString o size_of_bir_immtype) ^bir_val_ty”;
		val ld_sz = (snd o dest_eq o concl) thm4; 
		val ld_sz_st = mk_Con (mk_Name (PubName_tm, ld_sz)); 
		val trm_list = (listSyntax.mk_list ([mem_st,base_addr_st,ld_endi_st,ld_sz_st],SapicTerm_t_ty));
		val fun_sig = pairSyntax.list_mk_pair[“"Load"”,“(4:int)”,Public_tm, Constructor_tm];
		val sp_fun = mk_FAPP (fun_sig,trm_list);
 		val to_st_thm =  CONJ (CONJ (CONJ thm1 thm2) thm3) thm4
            in
		(sp_fun,to_st_thm)
            end
            handle e => raise wrap_exn "bir_exp_to_sapic_term::mem_load" e    
	(* Store expressions *)
	else if is_BExp_Store exp then
            (* 
             val exp = ``
			   (BExp_Store
				(BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
				(BExp_Den (BVar "ADDR1" (BType_Imm Bit64)))
				BEnd_BigEndian
				(BExp_Const (Imm128 (42w :word128))))
			   ``;
             *)
            let
		val (bir_mem, bir_addr, bir_endi, bir_val) = dest_BExp_Store exp
		val (mem_st,thm1) = bir_exp_to_sapic_term bir_mem;
		val (base_addr_st,thm2) = bir_exp_to_sapic_term bir_addr;
		val (val_st,thm3) = bir_exp_to_sapic_term bir_val;
		val thm4 = (SIMP_CONV (srw_ss()) [translate_Endian_to_string_def]) ``translate_Endian_to_string ^bir_endi``;
		val st_endi = (snd o dest_eq o concl) thm4; 
		val st_endi_st = mk_TVar (mk_Var (st_endi,(“0:int”)));
		val trm_list = (listSyntax.mk_list ([ mem_st,base_addr_st,st_endi_st,val_st],SapicTerm_t_ty));
		val fun_sig = pairSyntax.list_mk_pair[“"Store"”,“(4:int)”,Public_tm, Destructor_tm]
		val sp_fun = mk_FAPP (fun_sig,trm_list);
 		val to_st_thm =  CONJ (CONJ (CONJ thm1 thm2) thm3) thm4;
            in
		(sp_fun,to_st_thm)
            end
            handle e => raise wrap_exn "bir_exp_to_sapic_term::mem_store" e
	else if (identical exp “bir_exp_true”)
	then
		(mk_Con (mk_Name (PubName_tm, “"1"”)),(Thm.INST_TYPE [alpha |-> (type_of exp)] EQ_REFL))
	else if (identical exp “bir_exp_false”)
	then
		(mk_Con (mk_Name (PubName_tm, “"0"”)),(Thm.INST_TYPE [alpha |-> (type_of exp)] EQ_REFL))
	else
	    let
		val (name,trms) = strip_comb exp;
		val trm_list1 = map (fn x => if (is_BVar x)
					     then ((fst o bir_exp_to_sapic_term o mk_BExp_Den) x)
					     else ((fst o bir_exp_to_sapic_term) x)) trms;
		val trm_list2 = (listSyntax.mk_list (trm_list1,SapicTerm_t_ty));
		val thm_list = map (fn x => if (is_BVar x)
					     then ((snd o bir_exp_to_sapic_term o mk_BExp_Den) x)
					     else ((snd o bir_exp_to_sapic_term) x)) trms;
		val namestr = stringSyntax.fromMLstring (Parse.term_to_string name);
		val thm0 =  (SIMP_CONV (srw_ss()) []) “(int_of_num o LENGTH) ^trm_list2”;
		val trmlng = (snd o dest_eq o concl) thm0;
		val fun_sig = pairSyntax.list_mk_pair[namestr,trmlng,Public_tm, Constructor_tm]
		val sp_fun = mk_FAPP (fun_sig,trm_list2);
		val to_st_thm =  CONJ (hd thm_list) thm0;
	    in
		(sp_fun,to_st_thm)
	    end
            handle e =>
		   if (is_BVar exp)
		   then (bir_exp_to_sapic_term o mk_BExp_Den) exp
		   else
		   raise ERR "bir_exp_to_sapic_term" ("Don't know BIR expression: " ^ (term_to_string exp))
    end; 

    





	  
(*
Test:

val exp = “dec (BVar "4709_a" (BType_Imm Bit64))
     (pars1 (BVar "4576_KDF" (BType_Imm Bit64)))”

val exp = “conc1 (BVar "48_OTP" (BType_Imm Bit64))”

val exp = “BExp_Store
            (BExp_Store
                 (BExp_Den (BVar "MEM" (BType_Mem Bit64 Bit8)))
                 (BExp_BinExp BIExp_Minus
                              (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                              (BExp_Const (Imm64 48w))) BEnd_LittleEndian
                 (BExp_Den (BVar "R29" (BType_Imm Bit64))))
            (BExp_BinExp BIExp_Minus
                         (BExp_Den (BVar "SP_EL0" (BType_Imm Bit64)))
                         (BExp_Const (Imm64 40w))) BEnd_LittleEndian
            (BExp_Den (BVar "R30" (BType_Imm Bit64)))”;

val (sp_term,main_thm) = bir_exp_to_sapic_term exp;

Is main_thm true or false?--> run following

SIMP_RULE (srw_ss()) [b2n_def,translate_BinPred_to_string_def,translate_UnaryExp_to_string_def,size_of_bir_immtype_def,translate_BinExp_to_string_def,translate_Endian_to_string_def,translate_Cast_to_string_def] main_thm

 *)    
    
end (* local *)

end (* translate_to_sapicLib *)


