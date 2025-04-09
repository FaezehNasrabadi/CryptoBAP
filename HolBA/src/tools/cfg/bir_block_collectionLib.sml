structure bir_block_collectionLib =
struct
local

(* these dependencies probably need cleanup *)
(* ================================================ *)
open HolKernel boolLib liteLib simpLib Parse bossLib;
open bir_inst_liftingTheory
open bir_lifting_machinesTheory
open bir_lifting_machinesLib bir_lifting_machinesLib_instances;
open bir_interval_expTheory bir_update_blockTheory
open bir_exp_liftingLib bir_typing_expSyntax
open bir_typing_expTheory
open bir_extra_expsTheory
open bir_lifter_general_auxTheory
open bir_programSyntax bir_interval_expSyntax
open bir_program_labelsTheory
open bir_immTheory
open intel_hexLib
open bir_inst_liftingLibTypes
open PPBackEnd Parse

open bir_inst_liftingHelpersLib;
(* ================================================ *)

  open listSyntax;
  open wordsSyntax;

  open bir_immSyntax;

  (* error handling *)
  val libname  = "bir_block_collectionLib"
  val ERR      = Feedback.mk_HOL_ERR libname
  val wrap_exn = Feedback.wrap_exn libname

in

  fun gen_block_dict prog_tm =
    let
      val prog_bls = (fst o dest_list o dest_BirProgram) prog_tm;

      val prog_blocks_dict =
	let
	  val lbl_block_pairs =
	    List.foldr (fn (bl, l) => (
	      let
		val (lbl, _, _) = dest_bir_block bl;
		val lbl_tm      = (snd o dest_eq o concl o EVAL) lbl;
	      in
		(lbl_tm, bl)
	      end
	    )::l) [] prog_bls;

	  val _ = print ("found " ^ (Int.toString (length prog_bls))  ^ " blocks in program\n");
	in
	  Redblackmap.insertList (Redblackmap.mkDict Term.compare, lbl_block_pairs)
	end;
    in
      prog_blocks_dict
    end;

  local
    open numSyntax;
    open wordsLib;

    open HolBACoreSimps;
    open bir_programSyntax;
    open bir_program_valid_stateTheory;
  in
    fun gen_MEM_thm_block_dict prog_l_def valid_prog_thm =
      let
	val prog_l = (snd o dest_eq o concl) prog_l_def;
	val prog_l_const = (fst o dest_eq o concl) prog_l_def;
	val prog_const = (mk_BirProgram prog_l_const);

	val valid_labels_thm = CONJUNCT1 (REWRITE_RULE [bir_is_valid_program_def] valid_prog_thm);

	val label_set_thm = EVAL ``bir_labels_of_program ^prog_const``;

	val labels_mem_conv = SIMP_CONV (list_ss++WORD_ss++bir_TYPES_ss)
	  [bir_program_labelsTheory.bir_labels_of_program_REWRS, prog_l_def];

	val prep_thm0 = (CONJUNCT2 bir_get_program_block_info_by_label_valid_THM);
	val prep_thm1 = MATCH_MP prep_thm0 (REWRITE_RULE [] valid_labels_thm);
	val prep_thm  = REWRITE_RULE [EVAL ``LENGTH ^prog_l_const``] prep_thm1;

	val (_,augm_block_lst) = List.foldl (fn (bl,(i,l)) => (i+1,(i,bl)::l)) (0,[]) ((fst o dest_list) prog_l);

	(*
	val i = 1;
	val bl = snd(List.nth(augm_block_lst,(length augm_block_lst) -1 - i));
	*)

	val block_l_thm_list =
	     List.map (fn (i,bl) => (
	       (if ((!debug_trace) > 0) then (print "!") else ());
	       let
		 val i_n = mk_numeral (Arbnum.fromInt i);
		 val (lt,_,_)  = dest_bir_block bl;
		 val norm_lt = (snd o dest_eq o concl o (REWRITE_CONV [BL_Address_HC_def])) lt
			       handle UNCHANGED => lt;

		 val thm1 = SPECL [norm_lt, i_n, bl] prep_thm;

		 val thm2 = CONV_RULE (RAND_CONV (EVAL)) thm1;
		 val thm3 = (REWRITE_RULE [] thm2);

		 val _ = if ((fn t => not (identical t T)) o snd o dest_eq o concl) thm2
			 then (print_term ((concl) thm2);raise ERR "block_l_thm_list" "something went wrong")
			 else ();
		 (*
		 val el_thm = EVAL ``EL ^i_n ^prog_l_const``;
		 val thm2 = CONV_RULE (RAND_CONV (SIMP_CONV (arith_ss++bir_TYPES_ss) [el_thm])) thm1;
		 *)
	       in
		 (norm_lt,
		  CONJ
		    thm3
		    (((REWRITE_CONV [label_set_thm]) THENC EVAL) (mk_mem (norm_lt, mk_bir_labels_of_program prog_const)))
		 )
	       end
	     )) augm_block_lst;
      in
	Redblackmap.insertList (Redblackmap.mkDict Term.compare, block_l_thm_list)
      end;

    fun gen_MEM_thm_block_dict_from_lift_thm prog_l_def lift_thm =
      let
	(* val (_, mem_wi_prog_tm, mem_tm, prog_tm) = (dest_bir_is_lifted_prog o concl) t; *)

	val prog_tm = ((snd o dest_comb o concl) lift_thm);

	val valid_labels_thm = prove(``
	  bir_is_lifted_prog r mu mms p ==> bir_is_valid_labels p
	``,
	  METIS_TAC [bir_inst_liftingTheory.bir_is_lifted_prog_def]
	);

	val valid_prog_thm = prove(``bir_is_valid_program (^prog_tm)``,
	  REWRITE_TAC [bir_program_valid_stateTheory.bir_is_valid_program_def] >>
	  STRIP_TAC >- (
	    METIS_TAC [valid_labels_thm, lift_thm]
	  ) >>
	  SIMP_TAC list_ss [bir_program_valid_stateTheory.bir_program_is_empty_def, prog_l_def]
	);
      in
	gen_MEM_thm_block_dict prog_l_def valid_prog_thm
      end;

  end (* local *)

  fun lookup_block_dict bl_dict lbl_tm =
    SOME (Redblackmap.find (bl_dict, lbl_tm))
    handle NotFound => NONE;

  fun lookup_block_dict_value bl_dict lbl_tm error_src error_msg =
        case lookup_block_dict bl_dict lbl_tm of
           SOME x => x
         | NONE => raise ERR ("lookup_block_dict_value::" ^ error_src) ("value not found (" ^ (term_to_string lbl_tm) ^ ") :: " ^ error_msg);

  fun mk_key_from_address i addr = (mk_BL_Address o mk_Imm32 o mk_word) (addr, Arbnum.fromInt i);

  fun lookup_block_dict_byAddr i bl_dict addr =
      lookup_block_dict bl_dict (mk_key_from_address i addr);

  fun lookup_block_dict_byAddr32 bl_dict addr =
      lookup_block_dict_byAddr 32 bl_dict addr;
  fun lookup_block_dict_byAddr64 bl_dict addr =
      lookup_block_dict_byAddr 64 bl_dict addr;

  fun get_block_dict_keys bl_dict =
    List.map fst (Redblackmap.listItems bl_dict);

end (* local *)
end (* struct *)
