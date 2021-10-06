structure bir_scamv_driverLib :> bir_scamv_driverLib =
struct

open HolKernel boolLib liteLib simpLib Parse bossLib;

open bir_prog_genLib;

open bir_obs_modelLib;
open bir_exp_to_wordsLib;
open bir_rel_synthLib;
open bslSyntax;
open numSyntax;
open wordsSyntax;
open wordsLib;
open stringSyntax;
open listSyntax;
<<<<<<< HEAD
open bir_embexp_driverLib;
open bir_symb_execLib;
open bir_symb_masterLib;
open bir_typing_expTheory;
open scamv_configLib;
open bir_conc_execLib;
=======
open experimentsLib;
open persistenceLib;
open bir_symb_execLib;
open bir_symb_masterLib;
open bir_typing_expTheory;
open bir_programSyntax;
open scamv_configLib;
open scamv_symb_exec_interfaceLib;
open bir_conc_execLib;
open scamv_path_structLib;
open visited_statesLib;
open bir_utilLib;
open scamv_trainingLib;

  (* error handling *)
  val libname  = "bir_scamv_driverLib"
  val ERR      = Feedback.mk_HOL_ERR libname
  val wrap_exn = Feedback.wrap_exn libname 

fun print_exn_location_option printfun (lo: PolyML.location option) =
  case lo of
     NONE => printfun "NO EXCEPTION LOCATION\n\n"
   | SOME (l:{file: string, startLine: int, endLine: int, startPosition: int, endPosition: int}) => (
       let val s1 =
         "EXCEPTION LOCATION:\n" ^
         " - file:      " ^ (#file l) ^ "\n" ^
         " - lines:     " ^ (Int.toString (#startLine l))     ^ "-" ^ (Int.toString (#endLine l))     ^ "\n" ^
         " - positions: " ^ (Int.toString (#startPosition l)) ^ "-" ^ (Int.toString (#endPosition l)) ^ "\n" ^
         "\n";
       in printfun s1 end);

fun handle_locinfo printfun f =
  let
    val r =
      PolyML.Exception.traceException (f, (fn (l,e) => (
        printfun ("\nTRACE\n==================\nEXCEPTION: " ^ (PolyML.makestring e) ^ "\n");
        print "EXCEPTION TRACE:\n";
        List.map print l ;
        PolyML.Exception.reraise e)))
      (* PolyML.Exception.exception_trace f *)
      handle e => (
        printfun ("\nEXCEPTION: " ^ (PolyML.makestring e) ^ "\n");
        print_exn_location_option printfun (PolyML.Exception.exceptionLocation e);
        PolyML.Exception.reraise e);
  in r end;
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

(*
 workflow:
 - (a) program generation
 - lifting
 - (b) obs model augmentation
 - symbolic execution
 - conversion to symbolic observation paths (n paths)
 - relation synthesis
 - (c) relation partitioning (m partitions)
 - somewhere around here: constraining memory accesses (and probably some registers or flags) for test setup
 - state generation using SMT solver
 - test execution
 - driver decision (jump to a, b or c)
 *)

<<<<<<< HEAD

fun symb_exec_phase prog =
    let
        (* leaf list *)
        val maxdepth = 5 * length (fst (dest_list (dest_BirProgram prog))) (* (~1); *)
        val precond = ``bir_exp_true``
        val leafs = symb_exec_process_to_leafs_nosmt maxdepth precond prog;

        (* retrieval of path condition and observation expressions *)
	fun extract_cond_obs s =
	  let
	    val (_,_,cond,_,obs) = dest_bir_symb_state s;
	    val obss = ((List.map dest_bir_symb_obs) o fst o dest_list) obs;

	    (* determine whether this is an error state *)
	    val isErrorState = not (symb_is_BST_Halted s);

	    (* this converts BIR consts to HOL4 variables *)
	    val obs_list = List.map (fn (ec,eo, obsf) =>
		   (bir_exp_hvar_to_bvar ec, bir_exp_hvar_to_bvar eo, obsf)) obss;

	    (* we require singleton lists for the observations at the moment *)
	    (* check that we have HD as observation function, and apply it *)
	    val obs_list' = List.map (fn (ec,eo,obsf) =>
		     let
		       val (otl,_) = dest_list eo;
		       val _ = (if listSyntax.is_hd ``^obsf x`` then () else raise ERR "" "")
			       handle _ =>
				 raise ERR "extract_cond_obs" ("currently we only support HD as observation function, not \"" ^ (term_to_string obsf) ^ "\"");
		     in
		       if length otl <> 1 then
			 raise ERR "extract_cond_obs" "currently we support only singleton observations"
		       else
			 (ec, hd otl)
		     end
		   ) obs_list;
	  in
	    (bir_exp_hvar_to_bvar cond, if isErrorState then NONE else SOME obs_list')
	  end;

        val paths = List.map extract_cond_obs leafs;

        (* we also need all generated expressions to collect the variables *)
        val path_conds = List.map fst paths;
        val obs_exps = flatten (List.map (fn (x,y) => [x,y])
                          (flatten (List.map ((fn x =>
                             case x of NONE => [] 
                                     | SOME y => y) o snd) paths)));
        val all_exps = (path_conds @ obs_exps);
    in
        (paths, all_exps)
    end

fun bir_free_vars exp =
    if is_comb exp then
        let val (con,args) = strip_comb exp
        in if identical con ``BExp_Den`` then
               let val v = case strip_comb (hd args) of
                               (_,v::_) => v
                             | _ => raise ERR "bir_free_vars" "not expected"
               in [v]
               end
           else
               List.concat (map bir_free_vars args)
        end
    else [];

exception NoObsInPath;

(*
val exps = all_exps;
*)
fun make_word_relation relation exps =
    let
        fun primed_subst exp =
            map (fn v =>
                    let val vp = lift_string string_ty (fromHOLstring v ^ "'")
                    in ``BVar ^v`` |-> ``BVar ^vp`` end)
                (bir_free_vars exp);

        fun primed_vars exp = map (#residue) (primed_subst exp);
        fun nub_with eq [] = []
          | nub_with eq (x::xs) = x::nub_with eq (List.filter (fn y => not (eq(y,x))) xs);
        val primed = sort (curry String.<=)
                     (map (fromHOLstring o snd o dest_comb)
                         (nub_with (fn (x,y) => identical x y) (flatten (map primed_vars exps))));
        val unprimed = sort (curry String.<=)
                            (nub_with (op=) (map fromHOLstring
                                      (flatten (map bir_free_vars exps))));
        val pairs = zip unprimed primed;
        fun mk_distinct (a,b) =
            let val va = mk_var (a,``:word64``);
                val vb = mk_var (b,``:word64``);
            in
``(^va <> ^vb)``
            end;
        val distinct = if null pairs then raise NoObsInPath else list_mk_disj (map mk_distinct pairs);
    in
       ``^(bir2bool relation) /\ ^distinct``
    end

=======
exception NoObsInPath;

>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
(* Prints a model, one variable per line. *)
fun print_model model =
    List.foldl
        (fn ((name, tm), _) =>
            (print (" - " ^ name ^ ": "); Hol_pp.print_term tm))
        () (rev model);

<<<<<<< HEAD
fun to_sml_Arbnums model =
    List.map (fn (name, tm) => (name, dest_word_literal tm)) model;

val hw_obs_model_id = ref "";
val do_enum = ref false;

val (current_prog_id : string ref) = ref "";
val (current_prog : term option ref) = ref NONE;
val (current_prog_w_obs : term option ref) = ref NONE;
val (current_obs_model_id : string ref) = ref "";
val (current_pathstruct :
     path_struct ref) = ref [];
val (current_word_rel : term option ref) = ref NONE;

fun reset () =
    (current_prog_id := "";
     current_prog := NONE;
     current_prog_w_obs := NONE;
     current_pathstruct := [];
=======

val hw_obs_model_id = ref "";
val do_enum = ref false;
val do_training = ref false;

val (current_prog_id : embexp_logsLib.prog_handle option ref) = ref NONE;
val (current_prog : term option ref) = ref NONE;
val (current_prog_w_obs : term option ref) = ref NONE;
val (current_prog_w_refined_obs : term option ref) = ref NONE;
val (current_obs_model_id : string ref) = ref "";
val (current_refined_obs_model_id : string option ref) = ref NONE;
val (current_obs_projection : int ref) = ref 1;
val (current_pathstruct :
     path_struct option ref) = ref NONE;
val (current_full_specs : path_spec list ref) = ref [];
val (current_visited_map : visited_map ref) = ref (init_visited ());
val (current_word_rel : term option ref) = ref NONE;
(*val (next_iter_rel    : (path_spec * term) option ref) = ref NONE; *)

fun reset () =
    (current_prog_id := NONE;
     current_prog := NONE;
     current_prog_w_obs := NONE;
     current_prog_w_refined_obs := NONE;
     current_pathstruct := NONE;
     current_visited_map := init_visited ();
     current_full_specs := [];
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
     current_word_rel := NONE);

fun printv n str =
    if (#verbosity (scamv_getopt_config ()) >= n)
    then print str
    else ();

fun min_verb n f =
    if (#verbosity (scamv_getopt_config ()) >= n)
    then f ()
    else ();

fun observe_line e =
    brshift (band (e, blshift (bconst64 0x7f, bconst64 6)), bconst64 6);

fun collect_observations observe_fun pathstruct =
    let fun collect_from_leaf NONE = []
          | collect_from_leaf (SOME leaf) =
            List.map (observe_fun o snd) leaf;

        val leaves = List.map snd pathstruct;
    in
        List.concat (List.map collect_from_leaf leaves)
    end

(* fun collect_targets observe_fun path pathstruct = *)
(*     let fun collect_from_leaf NONE = [] *)
(*           | collect_from_leaf (SOME leaf) = *)
(*             List.map (observe_fun o snd) leaf; *)

(*         val leaf = List.find (fn entry => fst entry = path) pathstruct; *)
(*     in *)
(*         case leaf of *)
(*             NONE => raise ERR "collect_targets" "wrong path given" *)
(*          | SOME l => *)
(*            List.concat (List.map collect_from_leaf leaves) *)
(*     end *)

<<<<<<< HEAD
fun extract_obs_variables ps =
    List.concat (
        List.map (fn (_,obs_list) =>
                     case obs_list of
                         NONE => []
                       | SOME list => 
                         List.concat (List.map
                                          (fn (_,term) =>
                                              bir_free_vars term) list))
                ps);

fun enumerate_line_single_input path_struct =
    let val vars = extract_obs_variables path_struct;
=======
fun enumerate_line_single_input path_struct =
    let val vars = extract_obs_variables path_struct
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
    in
        case vars of
            [] => []
          | (v::vs) => [(observe_line (bden (bvarimm64 (fromHOLstring v))),
                         bir_rel_synthLib.enum_range (0,60))]
    end;

fun default_enumeration_targets paths =
    if !do_enum
    then enumerate_line_single_input paths
    else [];

<<<<<<< HEAD
fun start_interactive prog =
    let
        val _ = reset ();

        val (prog_id, lifted_prog) = prog;
        val _ = current_prog_id := prog_id;
        val _ = current_prog := SOME lifted_prog;
        val _ = min_verb 2 (fn () => print_term lifted_prog);

        val add_obs = #add_obs (get_obs_model (!current_obs_model_id))

        val lifted_prog_w_obs = add_obs lifted_prog;
        val _ = current_prog_w_obs := SOME lifted_prog_w_obs;
        val _ = min_verb 3 (fn () => print_term lifted_prog_w_obs);
        val (paths, all_exps) = symb_exec_phase lifted_prog_w_obs;
(*        val _ = List.map (Option.map (List.map (print_term o fst)) o snd) paths;*)
        
        fun has_observations (SOME []) = false
          | has_observations NONE = false
          | has_observations _ = true
        val _ =
            if exists (has_observations o snd) paths
            then () (* fine, there is at least one observation
                       in the paths list *)
            else raise ERR "start_interactive" "no observations";

        val enum_env = default_enumeration_targets paths;
        val (path_struct, validity, next_relation) =
            rel_synth_init paths enum_env; (* TODO consider validity *)
        val _ = current_pathstruct := path_struct;
        val _ = min_verb 4 (fn () => print_path_struct path_struct);
    in (path_struct, all_exps, next_relation) end;

=======
fun scamv_set_prog_state prog =
    let val (prog_id, lifted_prog) = prog;
        val _ = current_prog_id := SOME prog_id;
        val _ = current_prog := SOME lifted_prog;
        val _ = min_verb 2 (fn () => print_term lifted_prog);
    in
      (prog_id, lifted_prog)
    end;

fun scamv_phase_add_obs () =
let 
  val _ = printv 1 "Adding obs\n";
  val add_obs = #add_obs (get_obs_model (!current_obs_model_id));
  val mem_bounds =
      let
        val (mem_base, mem_len) = embexp_params_memory;
        val mem_end = (Arbnum.- (Arbnum.+ (mem_base, mem_len), Arbnum.fromInt 128));
      in
        pairSyntax.mk_pair
            (mk_wordi (embexp_params_cacheable mem_base, 64),
             mk_wordi (embexp_params_cacheable mem_end, 64))
      end;
  val lifted_prog_w_obs = add_obs mem_bounds (valOf (!current_prog));
  val _ = printv 1 "Obs added\n";
  val _ = current_prog_w_obs := SOME lifted_prog_w_obs;
  val _ = min_verb 3 (fn () => print_term lifted_prog_w_obs);
in
  lifted_prog_w_obs
end;

fun scamv_phase_symb_exec () =
    let
      val (paths, all_exps) = scamv_run_symb_exec (valOf (!current_prog_w_obs));
	    val _ = List.map (Option.map (List.map (fn (a,b,c) => print_term b)) o snd) paths;
      val ps = initialise paths;
      val _ = current_pathstruct := SOME ps;
      val _ = min_verb 4 (fn () => (print_path_struct ps; print (PolyML.makestring ps)));
    in
      ps
    end;

fun scamv_phase_rel_synth_init () =
    let
      val paths = valOf (!current_pathstruct);
      val enum_env = default_enumeration_targets paths;
      val relation_enumeration =
          rel_synth_init paths (!current_obs_projection) enum_env; (* TODO consider validity *)
    in
      relation_enumeration
    end;

fun scamv_per_program_init prog =
    let
        val _ = reset ();

        val _ = scamv_set_prog_state prog;
        val _ = scamv_phase_add_obs ();
        val _ = scamv_phase_symb_exec ();

        val result = scamv_phase_rel_synth_init ();
    in result end;
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

fun all_obs_not_present { a_run = (_,a_obs), b_run = (_,b_obs) } =
    let fun check xs = all (fn (b,_) => b = false) xs;
    in check a_obs andalso check b_obs
    end;

<<<<<<< HEAD
fun next_experiment all_exps next_relation  =
    let
        open bir_expLib;
        
        (* ADHOC this constrains paths to only those where
           none of the observations appear *)
=======
(* This is used to build the next relation for path enumeration *)
fun mem_constraint [] = ``T``
  | mem_constraint mls =
    let fun is_addr_numeral tm = tm |> pairSyntax.dest_pair |> fst |> (fn x => (rhs o concl o EVAL) ``w2n ^x``) |> is_numeral
	fun adjust_prime s =
            if String.isSuffix "_" s
            then String.map (fn c => if c = #"_" then #"'" else c) s
            else s
	fun mk_cnst vname vls =
	    let
		val toIntls = (snd o finite_mapSyntax.strip_fupdate) vls
		val mem = mk_var (adjust_prime vname ,Type`:word64 |-> word8`)
		val memconstraint = map (fn p => let val (t1,t2) = pairSyntax.dest_pair p
						 in
						     ``^mem ' (^t1) = ^t2``
						 end) toIntls;
		val mc_conj = foldl (fn (a,b) => mk_conj (a,b)) (hd memconstraint) (tl memconstraint);
	    in
		(``~(^mc_conj)``, toIntls)
	    end

	val (hc, hv)::(tc, tv)::[] = (map (fn (vn, vl) =>  mk_cnst vn vl ) mls)
	val mc_conj = mk_conj ((if is_addr_numeral (hd hv) then hc else ``T``), (if is_addr_numeral (hd tv) then tc else ``T``))
    in
	mc_conj
    end

fun next_experiment all_exps next_relation  =
    let
        open bir_expLib;

	(* measuring time*)
	val timer = (Time.now());

        (* ADHOC this constrains paths to only those where *)
	(* none of the observations appear *)
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
        val guard_path_spec =
            if !do_enum
            then all_obs_not_present
            else (fn _ => true);

        val (path_spec, rel) =
<<<<<<< HEAD
            valOf (next_relation guard_path_spec)
            handle Option =>
                   raise ERR "next_experiment" "next_relation returned a NONE";
        
=======
	  (*   case !next_iter_rel of *)
		(* NONE        => valOf (next_relation guard_path_spec)  *)
	  (*     | SOME (p, r) => let val _ = next_iter_rel := NONE in (p, r) end *)
            valOf (next_relation guard_path_spec)
		        handle Option =>
                       raise ERR "next_experiment" "next_relation returned a NONE";
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
        val _ = min_verb 1 (fn () =>
                               (print "Selected path: ";
                                print (PolyML.makestring path_spec);
                                print "\n"));

        val _ = min_verb 3 (fn () =>
                               bir_exp_pretty_print rel);
        val _ = printv 4 ("Word relation\n");
<<<<<<< HEAD
        val new_word_relation = make_word_relation rel all_exps;
        val _ = min_verb 4 (fn () =>
                               (print_term new_word_relation;
                                print "\n"));
        val word_relation =
            case !current_word_rel of
                NONE => new_word_relation
              | SOME r => mk_conj (new_word_relation, r);

        val _ = printv 2 ("Calling Z3\n");
        val model = Z3_SAT_modelLib.Z3_GET_SAT_MODEL word_relation;
        val _ = min_verb 1 (fn () => (print "SAT model:\n"; print_model model(*; print "\n"*)));

        val sml_model = to_sml_Arbnums model;
        fun isPrimedRun s = String.isSuffix "_" s;
        val (s2,s1) = List.partition (isPrimedRun o fst) sml_model;
        val prog_id = !current_prog_id;
=======
        val new_word_relation = make_word_relation rel true;
        val _ = min_verb 4 (fn () =>
                               (print_term new_word_relation;
                                print "\n"));
(*        val word_relation =
            case !current_word_rel of
                NONE => new_word_relation
	      (* r is a constraint used to build the next relation for path enumeration *)
              | SOME r => mk_conj (new_word_relation, r); *)
        val word_relation = mk_conj(new_word_relation, lookup_visited (!current_visited_map) path_spec)
                            handle NotFound => new_word_relation;

        val _ = printv 2 ("Calling Z3\n");
        val model = Z3_SAT_modelLib.Z3_GET_SAT_MODEL word_relation;
        val _ = min_verb 1 (fn () => (print "SAT model:\n"; print_model model; print "\nSAT model finished.\n"));

	val (ml, regs) = List.partition (fn el =>  (String.isSubstring (#1 el) "MEM_")) model
	val (primed, nprimed) = List.partition (isPrimedRun o fst) model
        (* clean up s2 *)
	val primed_rm = List.map (fn (r,v) => (remove_prime r,v)) primed
        val s1 = to_sml_Arbnums nprimed;
	val s2 = to_sml_Arbnums primed_rm;
        val prog_id =
          case !current_prog_id of
             NONE => raise ERR "next_experiment" "currently no prog_id loaded"
           | SOME x => x;
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

        fun mk_var_mapping s =
            let fun mk_eq (a,b) =
                    let fun adjust_prime s =
                            if String.isSuffix "_" s
                            then String.map (fn c => if c = #"_" then #"'" else c) s
                            else s;
                        val va = mk_var (adjust_prime a,``:word64``);
                    in ``^va = ^b``
<<<<<<< HEAD
                    end; 
            in list_mk_conj (map mk_eq s) end;
        val new_constraint = ``~^(mk_var_mapping model)``;
        val _ =
            current_word_rel :=
            (case !current_word_rel of
                 NONE => SOME new_constraint
               | SOME cumulative =>
                 SOME ``^cumulative /\ ^new_constraint``);

(*        val _ = print_term (valOf (!current_word_rel)); *)

        (* clean up s2 *)
        fun remove_prime str =
          if String.isSuffix "_" str then
            (String.extract(str, 0, SOME((String.size str) - 1)))
          else
            raise ERR "remove_prime" "there was no prime where there should be one";
        val s2 = List.map (fn (r,v) => (remove_prime r,v)) s2;

        (* check with concrete-symbolic execution whether the observations are actually equivalent *)
        val lifted_prog_w_obs = case !current_prog_w_obs of
                             SOME x => x
                           | NONE => raise ERR "next_test" "no program found";

        val _ = if conc_exec_obs_compare lifted_prog_w_obs (s1, s2) then () else
                  raise ERR "next_experiment" "Experiment does not yield equal observations, won't generate an experiment.";

        (* create experiment files *)
        val exp_id  = bir_embexp_sates2_create ("arm8", !hw_obs_model_id, !current_obs_model_id) prog_id (s1, s2);
        val exp_gen_message = "Generated experiment: " ^ exp_id;
        val _ = bir_embexp_log_prog exp_gen_message;

        val _ =  (if (#only_gen (scamv_getopt_config ())) then
                    printv 1 exp_gen_message
                    (* no need to do anything else *)
                  else (
                    let val test_result = bir_embexp_run exp_id false;
                    in case test_result of
                          (NONE, msg) => printv 1 ("result = NO RESULT (" ^ msg ^ ")")
                        | (SOME r, msg) => printv 1 ("result = " ^ (if r then "ok!" else "failed") ^ " (" ^ msg ^ ")")
                    end);
                 printv 1 "\n\n");
    in ()
    end;

fun mk_round_robin n =
    let val counter = ref 0;
    in fn (ys : term list) =>
          let val c = !counter;
          in
              (if c = n
               then counter := 0
               else counter := c + 1) ;
              List.nth (ys, c)
          end
    end

fun mk_round_robin_every s n =
    let val counter = ref n;
        val step = ref 0;
    in fn (ys : term list) =>
          let val c = !counter;
          in
              (if c = n
               then (counter := 0; step := 0)
               else (if (!step = s)
                     then (counter := c + 1;
                           step := 0)
                     else (step := !step + 1));
               printv 1 ("Path counter: " ^ PolyML.makestring (!counter) ^ "\n");
               List.nth (ys, c))
          end
    end

fun scamv_test_main tests prog =
    let
        val _ = reset();
        val (path_structure, all_exps, next_relation) = start_interactive prog;
        fun do_tests 0 = ()
          | do_tests n =
            let val _ = next_experiment all_exps next_relation
                        handle e => (
                               let
                                 val message = "Skipping test case due to exception in pipleline:\n" ^ PolyML.makestring e ^ "\n***\n";
                               in
                                 bir_embexp_log_prog message;
                                 print message
                               end
                        )
            in do_tests (n-1) end
    in do_tests tests
    end


fun scamv_test_gen_run tests (prog_id, lifted_prog) =
    (raise ERR "scamv_test_gen_run" "function DEPRECATED and will be removed soon - use scamv_run with from_file generator instead"; (NONE, "DEPRECATED"));


=======
                    end;
            in list_mk_conj (map mk_eq s) end;

        val reg_constraint = ``~^(mk_var_mapping (regs))``;
	val mem_constraint = mem_constraint ml;
	val new_constraint = mk_conj (reg_constraint, mem_constraint);

        val _ =
            current_visited_map := add_visited (!current_visited_map) path_spec new_constraint;
        val _ =
            current_word_rel := SOME (lookup_visited_all_paths (!current_visited_map));
(*                        current_word_rel :=
            (case !current_word_rel of
                 NONE => SOME new_constraint
               | SOME cumulative =>
                 SOME ``^cumulative /\ ^new_constraint``); *)

	(* ------------------------- training start ------------------------- *)
        val paths = valOf (!current_pathstruct);
        val st_o =
            if !do_training
            then
              SOME (
              compute_training_state (!current_full_specs)
                                     (!current_obs_projection)
                                     (lookup_visited (!current_visited_map) path_spec)
                                     (fst (#a_run path_spec))
                                     paths)
            else
              NONE;
	(* ------------------------- training end ------------------------- *)
	(* val _ = print_term (valOf (!current_word_rel)); *)

        (* check with concrete-symbolic execution whether the observations are actually equivalent *)
        val lifted_prog_w_obs = case !current_prog_w_obs of
				    SOME x => x
				  | NONE => raise ERR "next_test" "no program found";

	val ce_obs_comp = conc_exec_obs_compare (!current_obs_projection) lifted_prog_w_obs (s1, s2)
        val _ = if ce_obs_comp then () else
                raise ERR "next_experiment" "Experiment does not yield equal observations, won't generate an experiment.";

	(* show time *)
	val d_s = Time.- (Time.now(), timer) |> Time.toString;
	val _ = print ("Time to generate the experiment : "^d_s^"\n");

        (* create experiment files *)
        val exp_id  =
          run_create_exp
            prog_id
            ExperimentTypeStdTwo
            (!hw_obs_model_id)
            ([("1", s1), ("2", s2)]@(Portable.the_list (Option.map (fn st => ("train", st)) st_o)))
            [("state_gen_id", !current_obs_model_id), ("time", d_s)];
        val exp_gen_message = "Generated experiment: " ^ (embexp_logsLib.exp_handle_toString exp_id);
        val _ = run_log_prog exp_gen_message;

    in ()
    end;

fun scamv_test_main tests prog =
    let
        val _ = reset();
        val (full_specs, validity, next_relation) = scamv_per_program_init prog;
        val _ = current_full_specs := full_specs;
        val exit_threshold = tests;
        fun init_tests () = (current_word_rel := NONE; current_full_specs := []; current_visited_map := init_visited ());
        fun do_tests _ 0 = init_tests ()
          | do_tests 0 _ = (init_tests (); raise ERR "scamv_test_main" ("couldn't generate new test cases for " ^ (Int.toString exit_threshold) ^ " times"))
          | do_tests r n =
            let val success =
              (handle_locinfo print (fn () => next_experiment [] next_relation); true)
              handle e as Thread.Interrupt => (
                  run_log_prog "Keyboard interrupt!\n";
                  PolyML.Exception.reraise e)
                  |  e => (
                    let
                      val message = "Skipping test case due to exception in pipleline:\n" ^ PolyML.makestring e ^ "\n***\n";
                    in
                      run_log_prog message;
                      print message;
                      false
                    end
              )
            in
              if success then
                do_tests exit_threshold (n-1)
              else
                do_tests (r-1) n
            end
    in do_tests exit_threshold tests
    end

>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
fun scamv_test_single_file filename =
    let val prog = prog_gen_store_fromfile filename ();
    in scamv_test_main 1 prog
    end;

fun show_error_no_free_vars (id,_) =
    print ("Program " ^ id ^ " skipped because it has no free variables.\n");

<<<<<<< HEAD
fun scamv_run { max_iter = m, prog_size = sz, max_tests = tests, enumerate = enumerate
              , generator = gen, generator_param = generator_param
              , obs_model = obs_model, hw_obs_model = hw_obs_model
              , verbosity = verb, only_gen = og, seed_rand = seed_rand } =
    let

        val _ = bir_scamv_helpersLib.rand_isfresh_set seed_rand;

        val _ = do_enum := enumerate;

        val prog_store_fun =
           case gen of
                gen_rand => (case generator_param of
                                 SOME x => prog_gen_store_rand x  sz
                               | NONE   => prog_gen_store_rand "" sz)
              | qc => (case generator_param of
                                 SOME x => prog_gen_store_a_la_qc x sz
                               | NONE   => raise ERR "scamv_run::qc" "qc type needs to be specified as generator_param")
              | slice => prog_gen_store_rand_slice sz
              | from_file => (case generator_param of
                                 SOME x => prog_gen_store_fromfile x
                               | NONE   => raise ERR "scamv_run::from_file" "file needs to be specified as generator_param")
              | prefetch_strides => prog_gen_store_prefetch_stride sz
              | _ => raise ERR "scamv_run" ("unknown generator type " ^ PolyML.makestring gen)

        val _ =
           case obs_model of
                cache_tag_index  =>
                      current_obs_model_id := "cache_tag_index"
              | cache_tag_only =>
                      current_obs_model_id := "cache_tag_only"
              | cache_index_only =>
                      current_obs_model_id := "cache_index_only"
              | cache_tag_index_part =>
                      current_obs_model_id := "cache_tag_index_part"
              | cache_tag_index_part_page =>
                      current_obs_model_id := "cache_tag_index_part_page"
              | _ => raise ERR "scamv_run" ("unknown obs_model " ^ PolyML.makestring obs_model);

        val _ =
           case hw_obs_model of
                hw_cache_tag_index  =>
                      hw_obs_model_id := "cache_multiw"
              | hw_cache_index_numvalid =>
                      hw_obs_model_id := "cache_multiw_numinset"
              | hw_cache_tag_index_part =>
                      hw_obs_model_id := "cache_multiw_subset"
              | hw_cache_tag_index_part_page =>
                      hw_obs_model_id := "cache_multiw_subset_page_boundary"
              | _ => raise ERR "scamv_run" ("unknown hw_obs_model " ^ PolyML.makestring hw_obs_model);
=======
fun match_prog_gen gen sz generator_param =
    case gen of
        gen_rand => (
          case generator_param of
              SOME x => prog_gen_store_rand x  sz
            | NONE   => prog_gen_store_rand "" sz)
      | qc => (case generator_param of
              SOME x => prog_gen_store_a_la_qc x sz
            | NONE   => raise ERR "match_prog_gen::qc" "qc type needs to be specified as generator_param")
      | slice => prog_gen_store_rand_slice sz
      | from_file => (case generator_param of
              SOME x => prog_gen_store_fromfile x
            | NONE   => raise ERR "match_prog_gen::from_file" "file needs to be specified as generator_param")
      | from_list    => (case generator_param of
              SOME x => prog_gen_store_list x
            | NONE   => raise ERR "match_prog_gen::from_list" "list needs to be specified as generator_param")
      | prefetch_strides => prog_gen_store_prefetch_stride sz
      | _ => raise ERR "match_prog_gen" ("unknown generator type: " ^ (PolyML.makestring gen));

fun match_obs_model obs_model =
    case obs_model of
        mem_address_pc =>
        "mem_address_pc"
      | cache_tag_index  =>
        "cache_tag_index"
      | cache_tag_only =>
        "cache_tag_only"
      | cache_index_only =>
        "cache_index_only"
      | cache_tag_index_part =>
        "cache_tag_index_part"
      | cache_speculation =>
        "cache_speculation"
      | cache_speculation_first =>
        "cache_speculation_first"
      | cache_tag_index_part_page =>
        "cache_tag_index_part_page"
      | _ => raise ERR "match_obs_model" ("unknown obs_model " ^ PolyML.makestring obs_model);

fun match_hw_obs_model hw_obs_model =
    case hw_obs_model of
        hw_cache_tag_index  =>
        "cache_multiw"
      | hw_cache_index_numvalid =>
        "cache_multiw_numinset"
      | hw_cache_tag_index_part =>
        "cache_multiw_subset"
      | hw_cache_tag_index_part_page =>
        "cache_multiw_subset_page_boundary"
      | _ => raise ERR "match_hw_obs_model" ("unknown hw_obs_model: " ^ (PolyML.makestring hw_obs_model));

fun scamv_run { max_iter = m, prog_size = sz, max_tests = tests, enumerate = enumerate
              , generator = gen, generator_param = generator_param
              , obs_model = obs_model, hw_obs_model = hw_obs_model
              , refined_obs_model = refined_obs_model, obs_projection = proj
              , verbosity = verb, seed_rand = seed_rand, do_training = train
              , run_description = descr_o } =
    let

        val _ = bir_randLib.rand_isfresh_set seed_rand;

        val _ = run_init descr_o;

        val _ = do_enum := enumerate;
        val _ = do_training := train;
        val _ = current_obs_projection := proj;
        
        val prog_store_fun =
            match_prog_gen gen sz generator_param;

        val _ =
            current_obs_model_id := match_obs_model obs_model;

        val _ =
            current_refined_obs_model_id := Option.map match_obs_model refined_obs_model;

        val _ =
            hw_obs_model_id := match_hw_obs_model hw_obs_model;
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

        val config_str =
          "Scam-V set to the following test params:\n" ^
          ("Program generator    : " ^ PolyML.makestring gen ^ "\n") ^
          ("Prog gen params      : " ^ PolyML.makestring generator_param ^ "\n") ^
          ("Observation model    : " ^ !current_obs_model_id ^ "\n") ^
<<<<<<< HEAD
          ("HW observation model : " ^ !hw_obs_model_id ^ "\n") ^
          ("Enumerate            : " ^ PolyML.makestring (!do_enum) ^ "\n");

        val _ = bir_embexp_log config_str;
=======
          ("Refined observation model: " ^ PolyML.makestring (!current_refined_obs_model_id) ^ "\n") ^
          ("Projection model: " ^ PolyML.makestring proj ^ "\n") ^
          ("HW observation model : " ^ !hw_obs_model_id ^ "\n") ^
          ("Enumerate            : " ^ PolyML.makestring (!do_enum) ^ "\n") ^
          ("Train branch pred.   : " ^ PolyML.makestring (!do_training) ^ "\n") ^
          ("Run description text : " ^ PolyML.makestring descr_o ^ "\n") ;

        val _ = run_log config_str;
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
        val _ = min_verb 1 (fn () => print config_str);

        fun skipProgExText e = "Skipping program due to exception in pipleline:\n" ^ PolyML.makestring e ^ "\n***\n";
        
        fun main_loop 0 = ()
         |  main_loop n =
            (printv 1 ("Iteration: " ^ PolyML.makestring (m - n) ^ "\n");
<<<<<<< HEAD
             (let val prog = prog_store_fun ()
              in
                scamv_test_main tests prog
                handle e => (bir_embexp_log_prog (skipProgExText e); raise e)
              end
              handle e => print (skipProgExText e));
             main_loop (n-1))
    in
        (main_loop m
         handle _ => ()); bir_embexp_finalize ()
=======
             ((handle_locinfo print (fn () =>
              let val prog = prog_store_fun ()
              in
                scamv_test_main tests prog
                handle e => (run_log_prog (skipProgExText e); PolyML.Exception.reraise e)
              end))
              handle e as Thread.Interrupt => (
                        run_log "Keyboard interrupt!\n";
                        PolyML.Exception.reraise e)
                   | e => print (skipProgExText e));
             main_loop (n-1))
    in
        ((handle_locinfo print (fn () => main_loop m))
         handle _ => ()); run_finalize ()
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
    end;

fun scamv_run_with_opts () =
    let val cfg = scamv_getopt_config ();
    in
        scamv_run cfg
    end;

end;
