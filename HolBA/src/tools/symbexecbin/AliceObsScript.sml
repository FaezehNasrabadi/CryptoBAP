open HolKernel Parse bossLib
open PPBackEnd;
open boolLib pairLib;
open bir_inst_liftingLib;
open bir_inst_liftingHelpersLib;
open gcc_supportLib;
open bir_obs_modelTheory;
open bir_obs_modelLib;
open AliceTheory;

val _ = new_theory "AliceObs";
    
val (_, _, _, prog_tm) =
  (dest_bir_is_lifted_prog o concl)
  (DB.fetch "Alice" "Alice_thm");
  
val prog_range       =  ((Arbnum.fromInt 0x0), (Arbnum.fromInt 0x2D1));

val entry = Arbnum.fromInt 0x0;
    
fun embexp_params_cacheable x = Arbnum.+ (Arbnum.fromInt 0x0000000, x);

val stack_pointer_portion = Arbnum.fromHexString "0x0";    

val mem_bounds =
      let
        val (mem_base, mem_len) = prog_range;
	val mem_max = Arbnum.+ (mem_base, mem_len);
	val mem_end = (Arbnum.- (Arbnum.- (mem_max, stack_pointer_portion), Arbnum.fromInt 16));
	val (sp_start, sp_end) = (Arbnum.- (mem_max, stack_pointer_portion),
				  Arbnum.- (mem_max, Arbnum.fromInt 16));
      in
	if Arbnum.< (Arbnum.+ (mem_base,stack_pointer_portion), Arbnum.- (mem_max,stack_pointer_portion)) then
          pairSyntax.mk_pair
	    (pairSyntax.mk_pair
		 (wordsSyntax.mk_wordi (embexp_params_cacheable mem_base, 64),
		  wordsSyntax.mk_wordi (embexp_params_cacheable mem_end, 64)),
	     pairSyntax.mk_pair
		 (wordsSyntax.mk_wordi (embexp_params_cacheable sp_start, 64),
		  wordsSyntax.mk_wordi (embexp_params_cacheable sp_end, 64)))
	else
	  raise ERR "scamv_phase_add_obs" "the experiment memory is not properly set"
      end;
        
fun proginst_fun prog = inst [Type`:'observation_type` |-> Type`:bir_val_t`] prog;

val lifted_prog_cons_obs = (#add_obs (get_obs_model "mem_address_pc")) mem_bounds (proginst_fun prog_tm) entry;

val _ = save_thm ("Alice_Cons_Obs_thm", EVAL “^lifted_prog_cons_obs”);

val lifted_prog_spec_obs = (#add_obs (get_obs_model "cache_speculation")) mem_bounds (proginst_fun prog_tm) entry;

val _ = save_thm ("Alice_Spec_Obs_thm",  EVAL “^lifted_prog_spec_obs”);

val _ = export_theory();



