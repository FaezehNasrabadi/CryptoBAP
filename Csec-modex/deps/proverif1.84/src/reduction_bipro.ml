(*************************************************************
 *                                                           *
 *       Cryptographic protocol verifier                     *
 *                                                           *
 *       Bruno Blanchet and Xavier Allamigeon                *
 *                                                           *
 *       Copyright (C) INRIA, LIENS, MPII 2000-2009          *
 *                                                           *
 *************************************************************)

(*

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details (in file LICENSE).

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*)
(* Trace reconstruction by Xavier Allamigeon and Bruno Blanchet
   This version of the trace reconstruction does not exploit the
   order of nodes in the derivation tree. It is the main
   algorithm presented in [CSFW'05].
 *)
(* TO DO Test phases
   Should I use evaluated terms in the "comment" field?
 *)

open Types
open Pitypes
open Terms
open Reduction_helper

let made_forward_step = ref false
let failed_traces = ref 0

let debug_find_io_rule = ref false
let debug_backtracking = ref false
let debug_print s = ()
     (* print_string s; Display.newline() *)

type bi_term = term * term

type name_param_info = 
    Always of string * bi_term

let extract_name_params_noneed l = List.split (List.map (function Always(s,t) -> t) l)

type info = 
    InputInfo of bi_term list * bi_term list * bi_term * name_param_info list * hypspec list * (bi_term * (bi_term list * bi_term list) option) list
	(* Channel name after decomposition of tuples,
	   Public set of values at last test,
	   Channel name,
	   name_params, occs,
	   list of possible messages, possibly with their public status: the message after decomposition of tuples and the public set of values at last test.

	   Assume InputInfo(tc_list, oldpub, tc, name_params, occs, mess_list).
	   If tc_list != [], the first element of l is not in oldpub
	   we check whether the first element of
	   tc_list in is the part of public before oldpub. 
	   - If no, tc_list' = tc_list 
	   - If yes, we remove from the tail of l the first elements that 
	   are in public, yielding tc_list'. 
	   We replace the cache with InputInfo(tc_list',public,...)
	   If tc_list' is not empty, the channel is not public, 
	   try to perform (Res I/O). 
	   If tc_list' is empty, the channel is public, 
	   try to perform (Res In).
      	*)
  | OutputInfo of bi_term list * bi_term list
	(* the channel name after decomposition of tuples
	   the public set of values at last test.

	   Invariant: if we have OutputInfo(l,oldpub),
           the first element of l is not oldpub. 

	   When testing this output, we check whether the first element of
	   l in is the part of public before oldpub. 
	   - If no, we replace the cache with OutputInfo(l,public).
	   - If yes, we remove from the tail of l the first elements that 
	   are in public, yielding l'. If l' is not empty, we replace 
	   the cache with OutputInfo(l',public). If l' is empty,
	   we can execute the output: the channel is public.
	   *)
  | GetInfo of bi_term list * bi_term list
	(* the old contents of tables 
	   the list of possible entries *)	
  | Nothing

type sub_proc =
    process * (name_param_info list) * (hypspec list) * (fact list) * info 
      (* process (always closed -- only bound variables can occur; no variable with link *)
      (* list of name_params (terms received as input + session ids), always closed -- no variables *)
      (* list of occurrences of inputs and replications already seen in the reduction *)
      (* list of facts corresponding to already seen inputs -- no variables *)
      (* cached info for inputs *)

(* Types of locations (attacker or process) for steps in trace reconstruction *)

type loc_info = 
    LocAttacker
  | LocProcess of int * sub_proc

type goal_t =
    ProcessTest of (int * sub_proc) option ref(*location where test found*)
  | ApplyTest of funsymb * bi_term list
  | CommTest of bi_term(*input channel*) * bi_term(*output channel*) * 
	(loc_info(*location where input found*) * loc_info(*location where output found*)) option ref
  | EqTest of bi_term * bi_term

type reduc_state = 
    { 
      goal : goal_t; (* goal to reach *)
      subprocess : sub_proc list; (* process list *)
      public : bi_term list; (* attacker knowledge *)
      tables : bi_term list; (* contents of tables *)

      prepared_attacker_rule : (predicate * bi_term list * bi_term list) list; (* attacker rules *)
                               (* predicate, hypothesis, conclusion *)
      io_rule : (int * fact list * hypspec list * term list * term list * fact) list; (* process rules *)
                (* rule number, hypotheses, occurrence labels, name params left, name params right, conclusion *)

      previous_state : reduc_state option; (* previous semantic state *)
   
      hyp_not_matched : fact list;
      current_phase : int;
      comment : reduc_type  (* type of the reduction *)
    }

exception No_result
(* We use the exception Unify for local failure *)

exception FailOneSideOnly

let make_choice t1 t2 =
  FunApp(Param.choice_fun (Terms.get_term_type t1), [t1;t2])

let make_bi_choice (t1, t2) =
  FunApp(Param.choice_fun (Terms.get_term_type t1), [t1;t2])

let get_choice = function
    FunApp({ f_cat = Choice }, [t1;t2]) -> (t1,t2)
  | _ -> Parsing_helper.internal_error "Choice term expected"

let display_bi_term (t1,t2) =
  if Terms.equal_terms t1 t2 then 
    Display.display_term2 t1
  else
    begin
      print_string "choice[";
      Display.display_term2 t1;
      print_string ", ";
      Display.display_term2 t2;
      print_string "]"
    end

let equal_bi_terms_modulo (t1,t2) (t1',t2') =
  (equal_terms_modulo t1 t1') && (equal_terms_modulo t2 t2')

let equal_bi_terms_modulo_test (t1,t2) (t1',t2') = 
  let r1 = equal_terms_modulo t1 t1' in
  let r2 = equal_terms_modulo t2 t2' in
  if r1 && r2 then true else
  if (not r1) && (not r2) then false else
  raise FailOneSideOnly

(* Executes action for both sides, and applies next_f to the
   obtained pair of values. 
   next_f can raise No_result when it fails; next_f must not raise Unify.
   action raises Unify when it fails.
   Raises FailOneSideOnly when one side of the action fails. 
   Raises No_result when next_f has raised No_result for all possible cases. 
   Raises Unify when the action fails on both sides. *)

let bi_action action next_f =
  try
    action 1 (fun t1 ->
      try 
	action 2 (fun t2 ->
	  next_f (t1,t2)) 
      with Unify ->
	(* Left side succeeded, right side failed *)
	raise FailOneSideOnly) 
  with Unify ->
    (* Left side failed *)
    action 2 (fun t2 -> (* Left side failed, right side succeeded *) raise FailOneSideOnly) 

let rev_name_subst_bi = function
    [t] -> let r = rev_name_subst t in (r,r)
  | [t1;t2] -> (rev_name_subst t1, rev_name_subst t2)
  | _ -> Parsing_helper.internal_error "Unexpected number of arguments for this predicate"

let build_mess_fact phase (tc1,tc2) (t1,t2) =
  if phase < !Reduction_helper.min_choice_phase then
    Pred(Param.get_pred(Mess(phase, Terms.get_term_type t1)), [tc1;t1])
  else
    Pred(Param.get_pred(MessBin(phase, Terms.get_term_type t1)), [tc1;t1;tc2;t2])

let build_table_fact phase (t1,t2) =
  if phase < !Reduction_helper.min_choice_phase then
    Pred(Param.get_pred(Table(phase)), [t1])
  else
    Pred(Param.get_pred(TableBin(phase)), [t1;t2])

(* Display clauses *)

let display_rule (n, sons, hsl, nl1, nl2, concl) = 
  print_string ("Rule " ^ (string_of_int n) ^ ": ");
  display_tag hsl (List.map2 make_choice nl1 nl2);
  print_string "  ";
  Display.display_rule (List.map (fun t -> copy_fact2 t) sons, copy_fact2 concl, Empty concl, []);
  Display.newline()

(* Display the trace *)

let display_init_state = ref true

let rec display_reduc_state display_state state =
  if (not (!display_init_state)) && (state.previous_state = None) then
    (* Do not display the initial state; used when the 
       beginning of the trace has already been displayed *)
    List.length state.public
  else
  let display_next_state =
    match state.comment with
    | RInput _ | RIO _ | RIO2 _ | RPhase _ -> true
    | _ -> false
  in
  let display_cur_state = display_state ||
    match state.comment with
    | RIO _ | RIO2 _ | RPhase _ -> true
    | _ -> state.previous_state = None
  in
  let old_size_public = 
    match state.previous_state with
      Some s -> display_reduc_state display_next_state s
    | None -> 0
  in
  display_step state.comment;
  Display.newline ();
  Display.newline ();
  let size_public = List.length state.public in
  if size_public > old_size_public then
    begin
      print_string "Additional knowledge of the attacker:";
      Display.newline(); 
      itern (fun x -> 
	print_string "      ";
	display_bi_term x;
	Display.newline()) (size_public - old_size_public) state.public;
      Display.newline();
      print_string "--------------------------------------------------------------";
      Display.newline()
    end;
  if display_cur_state then
    begin
      print_string "New processes:";
      Display.newline();
      let n = ref 0 in
      if List.length state.subprocess > 1 then
	begin
	  print_string "(";
	  Display.newline()
	end;
      List.iter (fun (proc, _,_,_,_) -> 
	if !n > 0 then 
	  begin
	    print_string ") | (";
	    Display.newline()
	  end;
	Display.display_process "      " proc;
	incr n) state.subprocess;
      if List.length state.subprocess > 1 then
	begin
	  print_string ")";
	  Display.newline()
	end;
      Display.newline ();
      print_string "--------------------------------------------------------------";
      Display.newline ()
    end;
  size_public

let display_process_loc p =
  match p with
    (Test(_,_,_,_,occ) | Let(_,_,_,_,occ) | Input(_,_,_,occ) | Output(_,_,_,occ) |
    LetFilter(_,_,_,_,occ) | Event(_,_,occ) | Insert(_,_,occ) | Get(_,_,_,occ)), name_params, _, _, _ ->
      print_string " at ";
      Display.display_occ occ;
      let first = ref true in
      List.iter (function 
	  Always("!", sid) -> 
	    if !first then print_string " in copy " else print_string ", ";
	    first := false;
	    Display.display_term2 (fst sid)
	| _ -> ()
	      ) (List.rev name_params)
  | _ -> Parsing_helper.internal_error "Unexpected process"
  
let display_loc = function
    LocAttacker -> 
      print_string " by the attacker"
  | LocProcess(n,p) -> 
      match !Param.trace_display with
	Param.NoDisplay | Param.ShortDisplay ->  
	  display_process_loc p
      | Param.LongDisplay -> 
	  print_string (" in the " ^ (order_of_int n) ^ " process")
    
let rec display_labeled_trace state =
  if (!display_init_state) || (state.previous_state != None) then
    (* Do not display the initial state when the 
       beginning of the trace has already been displayed *)
    begin
      begin
	match state.previous_state with
	  Some s -> display_labeled_trace s
	| None -> ()
      end;
      let display_loc n =
	match state.previous_state with
	  None -> Parsing_helper.internal_error "Previous state should exist"
	| Some s ->
	    display_process_loc (List.nth s.subprocess n);
	    Display.newline();
	    Display.newline()
      in
      begin
	match state.comment with
	  RInput(n, tc, pat, mess_term) ->
	    Display.display_keyword "in";
	    print_string "(";
	    Display.display_term2 tc;
	    print_string ", ";
	    Display.display_term2 mess_term;
	    print_string ")";
	    display_loc n
	| ROutput1(n, tc, t) ->
	    Display.display_keyword "out";
	    print_string "(";
	    Display.display_term2 tc;
	    print_string ", ";
	    Display.display_term2 t;
	    print_string ")";
	    display_loc n
	| RBegin1(n, t) | REnd(n,t) ->
	    Display.display_keyword "event";
	    print_string "(";
	    Display.display_term2 t;
	    print_string ")";
	    display_loc n
	| _ -> ()
      end
    end

let display_goal = function
    ProcessTest(loc) ->
      begin
	match !loc with
	  None -> Parsing_helper.internal_error "Location should have been filled"
	| Some(n,p) ->
	    match !Param.trace_display with
	      Param.NoDisplay | Param.ShortDisplay -> 
		print_string "A test that may give the attacker some information on the secret is performed";
		display_process_loc p;
		print_string "."
	    | Param.LongDisplay -> 
		print_string ("The " ^ (order_of_int n) ^ " process performs a test that may give the attacker some information on the secret.");
      end;
      Display.newline()
  | ApplyTest(f,tl) ->
      print_string "The attacker tries to apply ";
      Display.display_function_name f;
      print_string " to the messages ";
      Display.display_list display_bi_term ", " tl;
      print_string " that he has.";
      Display.newline();
      print_string "The application succeeds on one side and not on the other.";
      Display.newline()
  | CommTest(t1,t2,loc) ->
      print_string "An input on channel ";
      display_bi_term t1;
      print_string " and an output on channel ";
      display_bi_term t2;
      print_string " are present simultaneously.";
      Display.newline();
      begin
	match !loc with
	  None -> Parsing_helper.internal_error "Location should have been filled"
	| Some(iloc,oloc) ->
	    print_string "(The input is performed";
	    display_loc iloc;
	    print_string ";";
	    Display.newline();
	    print_string "The output is performed";
	    display_loc oloc;
	    print_string ".)";
	    Display.newline()
      end;
      print_string "The communication succeeds on one side and not on the other.";
      Display.newline()
  | EqTest(t1,t2) ->
      print_string "The attacker tests whether ";
      display_bi_term t1;
      print_string " = ";
      display_bi_term t2;
      print_string ".";
      Display.newline();
      print_string "The result in the left-hand side is different from the result in the right-hand side.";
      Display.newline()

let display_trace final_state =
  match !Param.trace_display with
    Param.NoDisplay -> ()
  | Param.ShortDisplay ->   
      if !display_init_state then
	begin
	  print_string "A more detailed output of the traces is available with\n";
	  if !Param.typed_frontend then
	    print_string "  set traceDisplay = long.\n"
          else
	    print_string "  param traceDisplay = long.\n";
	  Display.newline()
	end;
      display_labeled_trace final_state
  | Param.LongDisplay -> 
      ignore (display_reduc_state true final_state)

(* Find a clause *)

let find_io_rule next_f hypspeclist hyplist name_params var_list io_rules =
  let (name_params1, name_params2) = extract_name_params_noneed name_params in
  let l = List.length hypspeclist in
  let lnp = List.length name_params1 in
  let lh = List.length hyplist in
  (* Useful for debugging *)
  if !debug_find_io_rule then
    begin
      auto_cleanup (fun () ->
	print_string "Looking for ";
	display_tag hypspeclist (List.map2 make_choice name_params1 name_params2);
	print_string "  ";
	Display.display_list Display.WithLinks.fact " & " hyplist;
	Display.newline())
    end;
  let found_terms = ref [] in
  let rec find_io_rule_aux = function
    [] -> raise Unify
  | ((n, sons, hypspeclist2, name_params1', name_params2',_)::io_rules) ->
      let l2 = List.length hypspeclist2 in
      let lnp2 = List.length name_params1' in
      let lh2 = List.length sons in
      if (l2 < l) || (lnp2 < lnp) || (lh2 < lh)
        || (not (hypspeclist = skip (l2-l) hypspeclist2)) then
	find_io_rule_aux io_rules
      else
        begin
	  let sons3 = skip (lh2-lh) sons in
	  try 
	    auto_cleanup (fun () ->
	      match_modulo_list (fun () ->
		match_modulo_list (fun () ->
	          match_equiv_list (fun () -> 
                    let new_found = List.map copy_closed_remove_syntactic var_list in
	            if List.exists (fun old_found ->
	              List.for_all2 equal_terms_modulo old_found new_found) (!found_terms) then
	              raise Unify;
	            found_terms := new_found :: (!found_terms);
		    if !debug_find_io_rule then
		      begin
			auto_cleanup (fun () ->
			  print_string "Found ";
			  Display.display_list Display.WithLinks.term ", " new_found;
			  Display.newline())
		      end;
	            next_f new_found) sons3 hyplist 
                    ) name_params2 (skip (lnp2-lnp) name_params2')
                  ) name_params1 (skip (lnp2-lnp) name_params1')
		)
          with Unify -> find_io_rule_aux io_rules
        end
  in 
  find_io_rule_aux io_rules

(* Evaluate a term possibly containing destructors
   Raises Unify when the term evaluation fails.
   The function next_f may raise No_result when it finds no result.
   In this case, term_evaluation also raises No_result *)

let rec term_evaluation t side next_f = 
  match t with
    Var v -> 
      begin
        match v.link with
          TLink t -> term_evaluation t side next_f
        | _ -> Parsing_helper.internal_error "Error: term should be closed in attack reconstruction";
      end
  | FunApp(f,l) ->
      (* for speed, use the initial definition of destructors, not the one enriched with the equational theory *)
      match f.f_initial_cat with
	Eq _ | Tuple -> term_evaluation_list l side (fun l' -> next_f (FunApp(f,l')))
      | Name _ -> next_f (FunApp(f,[]))
      |	Choice ->
	  begin
	    match l with 
	      [t1;t2] -> if side = 1 then term_evaluation t1 side next_f else term_evaluation t2 side next_f 
	    | _ -> Parsing_helper.internal_error "Choice should have two arguments"
	  end
      | Red redl -> term_evaluation_list l side (fun l' ->
	  let evaluation_succeeds = ref false in
	  let rec try_red_list = function
	      [] -> 
		if !evaluation_succeeds then
		  raise No_result
		else
		  raise Unify
	    | (red1::redl) ->
		let (left, right) = auto_cleanup (fun () -> Terms.copy_red red1) in
		try 
		  auto_cleanup (fun () ->
		  match_modulo_list (fun () -> 
		    try
		      (* TO DO (for speed) should I remove_syntactic, or keep it,
			 but take it into account elsewhere (when doing
			 function symbol comparisons, accept functions that
			 differ by their syntactic status) *)
 		      next_f (let t = TermsEq.remove_syntactic_term right in
		              close_term t; 
		              t)
		    with No_result ->
			evaluation_succeeds := true;
			raise Unify
				    ) left l')
		with Unify -> try_red_list redl
	  in
	  try_red_list redl
	  ) 
      | _ -> Parsing_helper.internal_error "unexpected function symbol in term_evaluation"

and term_evaluation_list l side next_f = 
  match l with
    [] -> next_f []
  | (a::l) -> 
      term_evaluation_list l side (fun l' -> 
	term_evaluation a side (fun a' ->
	  next_f (a'::l')
	) 
      ) 

(* Evaluates t1 and tests if it is equal to t2. *)
 
let equal_terms_modulo_eval t1 t2 =
  try
    auto_cleanup (fun () ->
      bi_action (term_evaluation t1) (fun t1' ->
	if equal_bi_terms_modulo t1' t2 then true else raise No_result
	  ))
  with No_result | Unify | FailOneSideOnly ->
    false


(*
Note: it is important that nothing is added in name_params for constructors 
with an equational theory. Indeed, these constructors are substituted during the
evaluation of the process, so the result of check_several_types would not be
the same in pitransl and in reduction, leading to different values of name_params,
so errors
*)

let rec check_several_types = function
    Var { link = TLink t } -> check_several_types t
  | Var _ -> false
  | FunApp(f,l) ->
      (List.exists check_several_types l) || 
      (match f.f_initial_cat with
       	 Red rules -> List.length rules > 1
       | Eq rules -> 
	   if !Param.eq_in_names then
	     Parsing_helper.internal_error "Setting eqInNames should have disabled trace reconstruction";
	   false
       | _ -> false)

let term_evaluation_name_params next_f t hypspeclist hyplist name_params io_rules =
  let may_have_several_types = check_several_types t in
  bi_action (term_evaluation t) (fun t' ->
    if may_have_several_types then
      (* We check that a clause in io_rule justifies our choice when adding 
         elements to name_params -> This makes it possible to detect wrong 
         choices very quickly and avoid losing too much time in backtracking. *)
      find_io_rule (fun _ ->
        next_f t' (Always("",t') :: name_params)) hypspeclist hyplist (Always("",t')::name_params) [] io_rules
    else
      next_f t' name_params
    ) 

let term_evaluation_name_params2 next_f t1 t2 hypspeclist hyplist name_params io_rules =
  let may_have_several_types1 = check_several_types t1 in
  let may_have_several_types2 = check_several_types t2 in
  bi_action (term_evaluation_list [t1;t2]) (function 
      ([t1';t2'],[t1'';t2'']) ->
	let name_params1 = 
	  if may_have_several_types1 then 
	    (Always("",(t1',t1'')) :: name_params)
	  else
	    name_params
	in
	let name_params2 = 
	  if may_have_several_types2 then 
	    (Always("",(t2',t2'')) :: name_params1)
	  else
	    name_params1
	in
	if name_params2 != name_params then
      (* We check that a clause in io_rule justifies our choice when adding 
         elements to name_params -> This makes it possible to detect wrong 
         choices very quickly and avoid losing too much time in backtracking. *)
	  find_io_rule (fun _ ->
            next_f (t1',t1'') (t2',t2'') name_params2) hypspeclist hyplist name_params2 [] io_rules
	else
	  next_f (t1',t1'') (t2',t2'') name_params      
    | _ -> Parsing_helper.internal_error "reduction_bipro.ml: Expecting two terms (1)"
    )

(* Match a pattern
   Raises Unify when the matching fails *)

let rec match_pattern p side next_f t = 
  match p with
    PatVar b -> 
      begin
	if side = 1 then
	  Terms.link b (TLink (make_choice t t))
	else
	  match b.link with
	    TLink (FunApp({ f_cat = Choice }, [t1;t2])) ->
	      Terms.link b (TLink (make_choice t1 t))
	  | _ ->
	      (* When the evaluation or pattern matching failed on the left side,
		 some variables may be unbounded when we try the pattern matching
		 on the right side *)
	      Terms.link b (TLink (make_choice t t))
      end; 
      next_f ()
  | PatTuple(f,l) ->
      let vl = Terms.var_gen (fst f.f_type) in
      match_modulo (fun () ->
	let tl = List.map copy_closed_remove_syntactic vl in
	match_pattern_list l side next_f tl
	  ) (FunApp(f, vl)) t
  | PatEqual t' ->
      term_evaluation t' side (fun t'' ->
	match_modulo (fun () -> ()) t'' t;
	);
      next_f ()

and match_pattern_list pl side next_f tl = 
  match (pl, tl) with
    [],[] -> next_f ()
  | (p1::pl,t1::tl) ->
      match_pattern p1 side (fun () ->
        match_pattern_list pl side next_f tl) t1
  | _ -> Parsing_helper.internal_error "Different length in match_pattern_list"

let bi_match_pattern p (t1,t2) side next_f =
  if side = 1 then 
    match_pattern p side next_f t1
  else
    match_pattern p side next_f t2

let term_evaluation_name_params_and_match next_f pat t hypspeclist hyplist name_params io_rules =
  let may_have_several_types = check_several_types t in
  bi_action (fun side next_f ->
    term_evaluation t side (fun t' -> match_pattern pat side (fun () -> next_f t') t'))
    (fun t' ->
      if may_have_several_types then
      (* We check that a clause in io_rule justifies our choice when adding 
         elements to name_params -> This makes it possible to detect wrong 
         choices very quickly and avoid losing too much time in backtracking. *)
	find_io_rule (fun _ ->
          next_f (Always("",t') :: name_params)) hypspeclist hyplist (Always("",t')::name_params) [] io_rules
      else
	next_f name_params
	  )


let rec update_name_params name_params = function
  PatVar b -> 
    let t = copy_closed_remove_syntactic (Var b) in
    Always(b.sname, get_choice t)::name_params
| PatTuple(f,l) -> update_name_params_list name_params l
| PatEqual _ -> name_params

and update_name_params_list name_params = function
  [] -> name_params
| (a::l) -> update_name_params_list (update_name_params name_params a) l


(* Decompose tuples *)

let rec decompose_term = function
    (FunApp(f,l), FunApp(f',l')) when f.f_cat == Tuple && f == f' -> decompose_list (List.combine l l')
  | t -> [t]

and decompose_list = function
    [] -> []
  | (a::l) -> (decompose_term a) @ (decompose_list l)

(* Test if a term is public *)

let rec is_in_public public = function
    (FunApp({ f_cat = Tuple } as f, l), FunApp(f',l')) when f == f' -> List.for_all (is_in_public public) (List.combine l l')
  | t -> List.exists (equal_bi_terms_modulo t) public

let rec remove_first_in_public public = function
    [] -> []
  | ((a::l) as l') ->
      if List.exists (equal_bi_terms_modulo a) public then
	remove_first_in_public public l
      else
	l'

let update_term_list oldpub public tc_list =
  match tc_list with
    [] -> []
  | (t0::l0) ->
      let rec is_in_until = function
	  [] -> false
	| ((a::l) as public) -> 
	    if public == oldpub then false else
	    if equal_bi_terms_modulo a t0 then true else
	    is_in_until l
      in
      if is_in_until public then
	remove_first_in_public public l0 
      else
	tc_list


let rec add_public_and_close state t =
  let queue = ref [t] in
  let rec remove_from_att_rules public t = function
      [] -> []
    | (p, hyp_terms,concl_terms)::attacker_rules ->
	let attacker_rules' = remove_from_att_rules public t attacker_rules in
	if getphase p < state.current_phase then attacker_rules' else
	let hyp_terms' = match hyp_terms with
	  [] -> []
	| (t0::l0) -> 
	    if equal_bi_terms_modulo t0 t then
	      remove_first_in_public public l0
	    else
	      hyp_terms
	in
	if (hyp_terms' = []) && (getphase p = state.current_phase) then
	  begin
	    queue := concl_terms @ (!queue);
	    attacker_rules'
	  end
	else
	  (* Keep the rule, removing hypotheses that are already in public *)
	  (p, hyp_terms', concl_terms) :: attacker_rules'
  in
  let rec do_close state =
    match !queue with
      [] -> state
    | (t::l) -> 
	queue := l;
	if List.exists (equal_bi_terms_modulo t) state.public then 
	  do_close state
	else
	  let public' = t :: state.public in
	  do_close { state with
                     public = public';
                     prepared_attacker_rule = remove_from_att_rules public' t state.prepared_attacker_rule }
  in
  do_close state

let rec add_public state = function
    (FunApp({ f_cat = Tuple } as f, l), FunApp(f',l')) when f == f' -> add_public_list state (List.combine l l')
  | t -> add_public_and_close state t

and add_public_list state = function
    [] -> state
  | (a::l) -> add_public_list (add_public state a) l

(* Do reductions that do not involve interactions *)
(* f takes as input
      - a boolean indicating whether the attacker knowledge has changed
      - the new state 
*)
(* When the goal is reached, returns the final state.
   Otherwise, raises an exception No_result. *)

let rec do_red_nointeract f prev_state n =
  let (proc, name_params, occs, facts, cache_info) =
	 List.nth prev_state.subprocess n in
  match proc with
    Nil -> debug_print "Doing Nil";
      made_forward_step := true;
      f false { prev_state with 
	             subprocess = remove_at n prev_state.subprocess;
                     comment = RNil(n);
                     previous_state = Some prev_state }
  | Par(p,q) -> 
      debug_print "Doing Par";
      made_forward_step := true;
      do_red_nointeract (fun new_att_know cur_state2 ->
        do_red_nointeract (fun new_att_know2 cur_state3 ->
             f (new_att_know || new_att_know2) cur_state3)
          cur_state2 n
        ) { prev_state with
	    subprocess = add_at n (p, name_params, occs, facts, Nothing)
	                (replace_at n (q, name_params, occs, facts, Nothing) 
                         prev_state.subprocess);
            comment = RPar(n);
            previous_state = Some prev_state } (n+1)
  | Restr(na,p) ->
      debug_print "Doing Restr";
      made_forward_step := true;
      let (l1,l2) = extract_name_params_noneed name_params in
      let n1' = add_name_for_pat (FunApp(na, l1)) in
      let n2' = add_name_for_pat (FunApp(na, l2)) in
      let n' = if n1' == n2' then FunApp(n1',[]) else make_choice (FunApp(n1',[])) (FunApp(n2',[])) in
      let p' = process_subst p na n' in
      begin
	do_red_nointeract f { prev_state with
	    subprocess = replace_at n (p', name_params, occs, facts, Nothing) prev_state.subprocess;
            comment = RRestr(n, na, n');
            previous_state = Some prev_state } n
      end
  | Let(pat,t,p,q,occ) ->
      debug_print "Doing Let";
      made_forward_step := true;
      let new_occs = (LetTag occ) :: occs in
      begin
      try 
        auto_cleanup (fun () -> 
        term_evaluation_name_params_and_match (fun name_params' ->
          let p' = copy_process p in
          do_red_nointeract f { prev_state with
	    subprocess = replace_at n (p', name_params', new_occs, facts, Nothing) prev_state.subprocess;
            comment = RLet1(n, pat, t);
            previous_state = Some prev_state } n
           ) pat t new_occs facts name_params prev_state.io_rule)
      with Unify ->
        do_red_nointeract f { prev_state with
	  subprocess = replace_at n (q, name_params, new_occs, facts, Nothing) prev_state.subprocess;
          comment = RLet2(n, pat, t);
          previous_state = Some prev_state } n
      | FailOneSideOnly ->
	  (* SUCCESS *)
	  { prev_state with
            goal = ProcessTest(ref (Some(n, List.nth prev_state.subprocess n))) }
      end
  | Test(t1,t2,p,q,occ) ->
      debug_print "Doing Test";
      made_forward_step := true;
      begin
	try
          auto_cleanup (fun () ->
	    let new_occs = (TestTag occ) :: occs in
            term_evaluation_name_params2 (fun t1' t2' name_params' ->
              if equal_bi_terms_modulo_test t1' t2' then
	        do_red_nointeract f 
		    { prev_state with
	              subprocess = replace_at n (p, name_params', new_occs, facts, Nothing) prev_state.subprocess;
                      comment = RTest1(n, t1, t2);
                      previous_state = Some prev_state } n
              else
                do_red_nointeract f 
		    { prev_state with
	              subprocess = replace_at n (q, name_params', new_occs, facts, Nothing) prev_state.subprocess;
                      comment = RTest2(n, t1, t2);
                      previous_state = Some prev_state } n
		  ) t1 t2 new_occs facts name_params prev_state.io_rule
	      )
        with Unify ->
	  f false { prev_state with
	      subprocess = remove_at n prev_state.subprocess;
              comment = RTest3(n, t1, t2);
              previous_state = Some prev_state } 
        | FailOneSideOnly ->
	  (* SUCCESS *)
	  { prev_state with
            goal = ProcessTest(ref (Some(n, List.nth prev_state.subprocess n))) }
      end
  | Output(tc,t,p,occ) ->
      let success = 
	if cache_info != Nothing then 
	  false (* Was already tested and failed before; will still fail if tested again *) 
	else
	  match prev_state.goal with
	    CommTest(tin,tout,loc) ->
	      if equal_terms_modulo_eval tc tout then 
		begin
		  if is_in_public prev_state.public tin then 
		    begin
		      loc := Some (LocAttacker, LocProcess(n, List.nth prev_state.subprocess n));
		      true
		    end
		  else (* find a process that does some input on tin *)
		    try
		      let (n',p') = 
			findi (function 
			    (Input(tc,_,_,_),_,_,_,_) -> equal_terms_modulo_eval tc tin
			  | _ -> false
				) prev_state.subprocess
		      in
		      loc := Some (LocProcess(n',p'), LocProcess(n, List.nth prev_state.subprocess n));
		      true
		    with Not_found ->
		      false
		end
	      else false
	  | _ -> false
      in
      if success then prev_state else 
      begin
	debug_print "Doing Output";
        (* For passive attackers, do red I/O only, 
	   but still evaluate the arguments of the output *)
	if not (!Param.active_attacker) then 
	  match cache_info with
	    InputInfo _ | GetInfo _ -> Parsing_helper.internal_error "Should not have input/get info for an output!"
	  | OutputInfo _ -> f false prev_state (* Arguments already evaluated *)
	  | Nothing ->
	      try
		auto_cleanup (fun () ->
		  bi_action (term_evaluation_list [tc;t]) (function
		      ([tc1;t1],[tc2;t2]) ->
			let tc' = (tc1, tc2) in
			let t' = (t1, t2) in
			let tclist = decompose_term tc' in
			f false { prev_state with 
                                  subprocess = replace_at n (Output(make_bi_choice tc', make_bi_choice t',p,occ), name_params, occs, facts, 
					   (OutputInfo(tclist, prev_state.public))) 
                                     prev_state.subprocess }
		    | _ -> Parsing_helper.internal_error "reduction_bipro.ml: Expecting two terms (2)"
			  )
		    )
              with Unify ->
	        f false { prev_state with
                      subprocess = remove_at n prev_state.subprocess;
                      comment = ROutput3(n, tc, t);
                      previous_state = Some prev_state } 
              | FailOneSideOnly ->
	          (* SUCCESS *)
		  { prev_state with
                    goal = ProcessTest(ref (Some(n, List.nth prev_state.subprocess n))) }

	else
        (* For active attackers, one can output on public channels *)
	begin
	  let new_occs = (OutputTag occ) :: occs in
	  match cache_info with
	    InputInfo _ | GetInfo _ -> Parsing_helper.internal_error "Should not have input/get info for an output!"
	  | OutputInfo(tclist, oldpub) ->
	      let tclist' = update_term_list oldpub prev_state.public tclist in
	      if tclist' = [] then
		begin
		  made_forward_step := true;
		  let prev_state' = add_public prev_state (get_choice t) in
		  do_red_nointeract (if prev_state.public == prev_state'.public then f else 
		  (fun mod_public cur_state -> f true cur_state))
		    { prev_state' with
                      subprocess = replace_at n (p, name_params, new_occs, facts, Nothing) prev_state.subprocess;
                      comment = ROutput1(n, tc, t);
		      previous_state = Some prev_state } n
		end
	      else
		f false { prev_state with
                          subprocess = replace_at n (proc, name_params, occs, facts, 
						     (OutputInfo(tclist', prev_state.public))) 
                                         prev_state.subprocess }
	  | Nothing ->
	      try
		auto_cleanup (fun () ->
		  bi_action (term_evaluation_list [tc;t]) (function
		      ([tc1;t1],[tc2;t2]) ->
			let tc' = (tc1, tc2) in
			let t' = (t1, t2) in
			let tclist = decompose_term tc' in
			let tclist' = remove_first_in_public prev_state.public tclist in
			if tclist' = [] then
			  begin
			    made_forward_step := true;
			    let prev_state' = add_public prev_state t' in
			    do_red_nointeract (if prev_state.public == prev_state'.public then f else 
			    (fun mod_public cur_state -> f true cur_state))
			      { prev_state' with
                                  subprocess = replace_at n (p, name_params, new_occs, facts, Nothing) prev_state.subprocess;
			          comment = ROutput1(n, tc, t);
			          previous_state = Some prev_state } n
			  end
			else
		      (* When one side is a channel and the other side is not,
                         we keep the Output process; the failure of the equivalence
                         will be detected (or has already been detected) by CommTest *)
			  f false { prev_state with 
                                    subprocess = replace_at n (Output(make_bi_choice tc', make_bi_choice t',p,occ), name_params, occs, facts, 
							   (OutputInfo(tclist', prev_state.public))) 
                                               prev_state.subprocess }
		    | _ -> Parsing_helper.internal_error "reduction_bipro.ml: Expecting two terms (3)"
			)
		    )
              with Unify ->
	        f false { prev_state with
                      subprocess = remove_at n prev_state.subprocess;
                      comment = ROutput3(n, tc, t);
                      previous_state = Some prev_state } 
              | FailOneSideOnly ->
	          (* SUCCESS *)
		  { prev_state with
                    goal = ProcessTest(ref (Some(n, List.nth prev_state.subprocess n))) }
	end
      end
  | Event(FunApp(fs,l) as t,p,occ) ->
      debug_print "Doing Event";
      made_forward_step := true;
      begin
	 (* Check that the argument of the event can be evaluated but otherwise ignore it *)
	try
	  auto_cleanup (fun () ->
	    bi_action (term_evaluation t) (fun t' -> ()));
	  do_red_nointeract f { prev_state with
	                        subprocess = replace_at n (p, name_params, occs, facts, Nothing) prev_state.subprocess;
	                        comment = RBegin1(n, t);
	                        previous_state = Some prev_state } n
        with Unify ->
	  f false { prev_state with 
                    subprocess = remove_at n prev_state.subprocess;
		    comment = RBegin2(n, t);
		    previous_state = Some prev_state }
        | FailOneSideOnly ->
	  (* SUCCESS *)
	  { prev_state with
            goal = ProcessTest(ref (Some(n, List.nth prev_state.subprocess n))) }
      end
  | LetFilter(bl, Pred(pr,l), p, q, occ) ->
      Parsing_helper.user_error "Predicates are currently incompatible with non-interference.\n"
  | Repl(p,occ) ->
      debug_print "Doing Repl";
      made_forward_step := true;
      let sid = Terms.new_var "sid" Param.sid_type in
      let new_occs = (ReplTag (occ,List.length name_params))::occs in
      let copy_number = ref 0 in
      let new_state = ref { prev_state with
	                    subprocess = remove_at n prev_state.subprocess;
                            comment = RRepl(n,0);
                            previous_state = Some prev_state } 
      in
      begin
      try
        auto_cleanup (fun () ->
          find_io_rule (function 
             [sid_pat] ->
                    let p' = auto_cleanup (fun () -> copy_process p) in
                    incr copy_number;
                    new_state := { !new_state with
                            subprocess = add_at n (p', Always("!",(sid_pat, sid_pat))::name_params, new_occs, facts, Nothing) !new_state.subprocess
                          };
                    raise Unify
           | _ -> Parsing_helper.internal_error "Repl case, reduction.ml"
	     ) new_occs facts (Always("!",(Var sid, Var sid))::name_params) [Var sid] prev_state.io_rule
           )
      with Unify ->
	debug_print ("Repl: " ^ (string_of_int (!copy_number)) ^ " copies");
        let rec do_red_copies b ncopies state =
          if ncopies < 0 then 
            f b state
          else
            do_red_nointeract (fun b' s -> do_red_copies (b||b') (ncopies-1) s) state (n+ncopies)
	in
	do_red_copies false ((!copy_number)-1) 
          { !new_state with
            comment = RRepl(n,!copy_number)
          }
     end
  | Input(tc,_,_,_) ->
      begin
	match prev_state.goal with
	  CommTest(tin,tout,loc) ->
	    if equal_terms_modulo_eval tc tin then 
	      begin
		if is_in_public prev_state.public tout then 
		  begin
		    loc := Some (LocProcess(n, List.nth prev_state.subprocess n), LocAttacker);
		    prev_state
		  end
		else (* find a process that does some output on tout *)
		  try
		    let (n',p') = 
		      findi (function 
			  (Output(tc,_,_,_),_,_,_,_) -> equal_terms_modulo_eval tc tout
			| _ -> false
			      ) prev_state.subprocess
		    in
		    loc := Some (LocProcess(n, List.nth prev_state.subprocess n), LocProcess(n',p'));
		    prev_state
		  with Not_found ->
		    f false prev_state
	      end
	    else f false prev_state
	| _ -> f false prev_state

      end
  | Insert(t,p,occ) ->
      debug_print "Doing Insert";
      begin
	let new_occs = (InsertTag occ) :: occs in
	try
	  auto_cleanup (fun () ->
	    bi_action (term_evaluation t) (fun t' ->
	      made_forward_step := true;
	      do_red_nointeract f
		  { prev_state with
                    subprocess = replace_at n (p, name_params, new_occs, facts, Nothing) prev_state.subprocess;
	            tables = if List.exists (equal_bi_terms_modulo t') prev_state.tables then prev_state.tables else t'::prev_state.tables;
		    comment = RInsert1(n, t);
	            previous_state = Some prev_state } n
		)
	      )
        with Unify ->
	  f false { prev_state with
                    subprocess = remove_at n prev_state.subprocess;
                    comment = RInsert2(n, t);
                    previous_state = Some prev_state } 
        | FailOneSideOnly ->
	    (* SUCCESS *)
	    { prev_state with
              goal = ProcessTest(ref (Some(n, List.nth prev_state.subprocess n))) }
      end
  | _ -> f false prev_state


(* Test success when the knowledge of the attacker has changed *)

let test_success cur_state' =
  try
    match cur_state'.goal with
      EqTest(t1,t2) ->
	(is_in_public cur_state'.public t1) &&
	(is_in_public cur_state'.public t2)
    | ApplyTest(_, l) ->
	List.for_all (is_in_public cur_state'.public) l
    | CommTest(tin,tout,loc) ->
	let rin = 
	  if is_in_public cur_state'.public tin then 
	    Some LocAttacker
	  else (* find a process that does some input on tin *)
	    try
	      let (n,p) = 
		findi (function 
		    (Input(tc,_,_,_),_,_,_,_) -> equal_terms_modulo_eval tc tin
		  | _ -> false
			) cur_state'.subprocess
	      in
	      Some (LocProcess(n,p))
	    with Not_found ->
	      None
	in
	let rout = 
	  if is_in_public cur_state'.public tout then 
	    Some LocAttacker
	  else (* find a process that does some output on tout *)
	    try
	      let (n,p) = 
		findi (function 
		    (Output(tc,_,_,_),_,_,_,_) -> equal_terms_modulo_eval tc tout
		  | _ -> false
			) cur_state'.subprocess
	      in
	      Some (LocProcess(n,p)) 
	    with Not_found ->
	      None
	in
	begin
	  match rin,rout with
	    Some lin, Some lout -> loc := Some(lin,lout); true
	  | _ -> false
	end
    | _ -> false
  with Unify ->
    false

(* let test_success = Profile.f1 "test_success" test_success *)
	    
let end_if_success next_f cur_state =
  if test_success cur_state then cur_state else next_f cur_state

(* Normalize the state after a reduction *)

let rec find_possible_outputs f cur_state n seen_list = function
    [] -> f cur_state
  | (Output(tc,t,p,out_occ) as proc, name_params, occs, facts, cache_info)::rest_subprocess when (!Param.active_attacker) ->
      let tclist' = 
	match cache_info with
	  InputInfo _ | GetInfo _ -> Parsing_helper.internal_error "Should not have input/get info for an output!"
	| OutputInfo(tclist, oldpub) ->
	    update_term_list oldpub cur_state.public tclist 
	| Nothing ->
	    let tclist = decompose_term (get_choice tc) in
	    remove_first_in_public cur_state.public tclist 
      in
      let seen_list' = (proc, name_params, occs, facts, OutputInfo(tclist', cur_state.public)) :: seen_list in
      if tclist' = [] then
        do_red_nointeract (fun change_pub cur_state2 ->
          if change_pub then
            end_if_success (find_possible_outputs_rec f) cur_state2 
          else 
            find_possible_outputs f cur_state2 0 [] cur_state2.subprocess
	      ) { cur_state with subprocess = List.rev_append seen_list' rest_subprocess } n
      else
	find_possible_outputs f cur_state (n+1) seen_list' rest_subprocess
  | sub_proc::rest_subprocess -> find_possible_outputs f cur_state (n+1) (sub_proc::seen_list) rest_subprocess

and find_possible_outputs_rec f cur_state3 =
	 find_possible_outputs f cur_state3 0 [] cur_state3.subprocess

(*      When the process number n has been changed *)

let normal_state f change_pub cur_state n =
  do_red_nointeract (fun change_pub2 cur_state2 ->
    if change_pub || change_pub2 then
      end_if_success (find_possible_outputs_rec f) cur_state2 
    else f cur_state2
	            ) cur_state n

(*      When two processes have been changed, numbers n1 and n2 *)

let normal_state2 f change_pub cur_state n1 n2 =
  let n1',n2' = if n1 < n2 then n1,n2 else n2,n1 in
  do_red_nointeract (fun change_pub2 cur_state2 ->
    do_red_nointeract (fun change_pub3 cur_state3 ->
      if change_pub || change_pub2 || change_pub3 then
        end_if_success (find_possible_outputs_rec f) cur_state3
      else f cur_state3
	              ) cur_state2 n1'
	            ) cur_state n2'

(*      When all processes have been changed *)

let normal_state_all f change_pub cur_state =
  let rec do_red_all change_pub2 cur_state2 n =
    if n < 0 then
      if change_pub2 then
	end_if_success (find_possible_outputs_rec f) cur_state2
      else
	f cur_state2
    else
      do_red_nointeract (fun change_pub3 cur_state3 ->
	do_red_all (change_pub2 || change_pub3) cur_state3 (n-1)
			) cur_state2 n
  in
  do_red_all change_pub cur_state (List.length cur_state.subprocess - 1)

(* Initial attacker knowledge *)

let rec public_build l =
  match l with
  | [] -> []
  | h::t ->
      if not h.f_private then
	(FunApp(h,[]))::(public_build t)
      else
	public_build t

(* Initialize the rule lists *)

let rec init_rule state tree =
  match tree.desc with
    FHAny | FEmpty -> 
      begin
	match tree.thefact with
	  Out(_,_) -> state
	| Pred(p, [t]) when p.p_prop land Param.pred_ATTACKER != 0 ->
	    begin
	      let t' = rev_name_subst t in
	      match t' with
		FunApp({ f_cat = Name _; f_private = false },[]) ->
		  { state with public = (t',t') :: state.public }
	      |	_ -> 
                  (* Public contains terms, not patterns
	             -> translate the pattern into a term.
	             If the translation fails because a name is not in the table, we have to stop. *)
		  if is_in_public state.public (t',t') then 
		    state
		  else
                    { state with 
                      public = (t',t') :: state.public;
	              hyp_not_matched = (Pred(p,[t']))::state.hyp_not_matched }
            end
	| Pred(p, [t1;t2]) when p.p_prop land Param.pred_ATTACKER != 0 ->
	    begin
	      let t1' = rev_name_subst t1 in
	      let t2' = rev_name_subst t2 in
	      match t1', t2' with
		(FunApp({ f_cat = Name _; f_private = false },[]),
		 FunApp({ f_cat = Name _; f_private = false },[])) when
		equal_terms_modulo t1' t2' ->
		  { state with public = (t1', t2') :: state.public }
	      |	_ -> 
                  (* Public contains terms, not patterns
	             -> translate the pattern into a term.
	             If the translation fails because a name is not in the table, we have to stop. *)
		  if is_in_public state.public (t1',t2') then 
		    state
		  else
                    { state with 
                      public = (t1',t2') :: state.public;
	              hyp_not_matched = (Pred(p,[t1';t2']))::state.hyp_not_matched }
            end
        | _ -> 
	     { state with
	       hyp_not_matched = (rev_name_subst_fact tree.thefact)::state.hyp_not_matched }
      end
  | FRemovedWithProof _ -> state
  | FRule (n, tags, constra, sons) ->
      let rec init_sons_rule state1 = function
	| [] -> 
	    begin
	      match tags with
	        ProcessRule2 (hsl,nl1,nl2) -> 
                  {state1 with io_rule = (n, List.map (fun t -> rev_name_subst_fact t.thefact) sons,
					  hsl, rev_name_subst_list nl1, rev_name_subst_list nl2, 
					  rev_name_subst_fact tree.thefact)::state1.io_rule}
	      | Apply (Func(f),_) when f.f_cat != Tuple -> 
		  begin
		    let (p,c) = 
		      match tree.thefact with
			Pred(p,l) -> (p,rev_name_subst_bi l)
		      | _ -> Parsing_helper.internal_error "unexpected Apply clause"
		    in
		    let h = List.map (function 
			{ thefact = Pred(_,l) } -> rev_name_subst_bi l
		      |	_ -> Parsing_helper.internal_error "unexpected Apply clause") sons
		    in
	            {state1 with prepared_attacker_rule = (p, decompose_list h, decompose_term c)::state1.prepared_attacker_rule}
		  end
              | Rn _ ->
                  begin
	            match tree.thefact with
                      Pred(p, l) ->
                        { state1 with prepared_attacker_rule = (p, [], [rev_name_subst_bi l])::state1.prepared_attacker_rule }
                    | _ -> Parsing_helper.internal_error "Rule Rn should conclude p(name)"
	          end
	      | _ -> state1
	    end
	| h::t ->
	    let state1' = init_rule state1 h in
	    init_sons_rule state1' t
      in 
      init_sons_rule state sons
  | FEquation son -> init_rule state son

(* Handle reductions i/o and in *)

(* Perform an input on a public channel (Res In) *)

let do_res_in cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' mess_term public_status next_f    =
  (* The real list of processes is (List.rev_append seen_list (InputProcess :: rest_subprocess)) *)
  let (mess_list, oldpub) = 
    match public_status with
      Some (m,o) -> (m,o)
    | None -> (decompose_term mess_term, [])
  in
  (* Remove the elements of mess_list' that are already in cur_state.public *)
  let mess_list' = update_term_list oldpub cur_state.public mess_list in
  (* When mess_list' is not empty, its first element is not in cur_state.public
     Remember that point to avoid testing again that part of public *)
  current_cache_list := (mess_term, Some (mess_list', cur_state.public)) :: (!current_cache_list);
  if mess_list' != [] then raise Unify; (* The message is not public *)
  try
    made_forward_step := true;
    auto_cleanup (fun () ->
      bi_action (bi_match_pattern pat mess_term) (fun _ -> 
	let name_params'' = update_name_params name_params' pat in
	let p' = auto_cleanup (fun () -> copy_process p) in
	let fact' = build_mess_fact cur_state.current_phase tc' mess_term in
	normal_state next_f false 
	  { cur_state with
            subprocess = List.rev_append seen_list ((p', name_params'', new_occs, fact' :: facts, Nothing) :: rest_subprocess);
            comment = RInput(n, tc, pat, make_bi_choice mess_term);
            previous_state = Some cur_state } n
	  ) 
	)
  with No_result ->
    (* Inputting the message mess_term on this input will always fail,
       even in the following of the trace *)
    current_cache_list := List.tl (!current_cache_list);
    raise Unify
  | FailOneSideOnly ->
    (* SUCCESS the pattern matching fails on one side only *)
      { cur_state with
        goal = ProcessTest(ref (Some(n, List.nth cur_state.subprocess n))) }
   
(* Perform a (Red I/O) reduction between an input and an asynchronous output *)

let do_async_res_io cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' mess_term public_channel next_f  =
  (* The real list of processes is (List.rev_append seen_list (InputProcess :: rest_subprocess)) 
     It differs from cur_state.subprocess only by the cache of input processes, so when
     looking for an output process, we can use cur_state.subprocess instead. *)
  current_cache_list := (mess_term, None) :: (!current_cache_list);
  (* Find the corresponding asynchronous output *)
  let rec find_asynchronous_output noutput = function
      [] -> raise Unify (* not found *)
    | ((Output(tc2, t2, Nil,out_occ), name_params2,occs2, facts2, cache_info2)::_) when
      (equal_bi_terms_modulo (get_choice tc2) tc') && (equal_bi_terms_modulo (get_choice t2) mess_term) ->
	noutput
    | _::rest_subprocess2 -> find_asynchronous_output (noutput+1) rest_subprocess2
  in
  let noutput = find_asynchronous_output 0 cur_state.subprocess in
  begin
    try
      made_forward_step := true;
      try
	auto_cleanup (fun () ->
	  bi_action (bi_match_pattern pat mess_term) (fun _ -> 
	    let name_params'' = update_name_params name_params' pat in
	    let p' = auto_cleanup (fun () -> copy_process p) in
	    let fact' = build_mess_fact cur_state.current_phase tc' mess_term in
	    let cur_state' = 
	      { (if public_channel then
		add_public cur_state mess_term else cur_state)
                with
	        subprocess = remove_at noutput
	          (List.rev_append seen_list ((p', name_params'', new_occs, fact' :: facts, Nothing) :: rest_subprocess));
	        comment = RIO(n, tc, pat, noutput, tc, make_bi_choice mess_term);
	        previous_state = Some cur_state }
	    in
	    let ninput = if n > noutput then n-1 else n in
	    normal_state next_f false cur_state' ninput
                  ) 
	    )
      with Unify ->
	(* The pattern does not match *)
	let noutput' = if n>noutput then noutput else noutput-1 in
	let cur_state' = 
	  { (if public_channel then
	    add_public cur_state mess_term else cur_state)
            with
	    subprocess = remove_at noutput' (List.rev_append seen_list rest_subprocess);
	    comment = RIO(n, tc, pat, noutput, tc, make_bi_choice mess_term);
	    previous_state = Some cur_state }
	in
	next_f cur_state' 
      | FailOneSideOnly ->
	  (* SUCCESS the pattern matching fails on one side only *)
	  { cur_state with
            goal = ProcessTest(ref (Some(n, List.nth cur_state.subprocess n))) }
    with No_result -> 
      current_cache_list := List.tl (!current_cache_list);
      raise Unify
  end


(* Perform a (Res I/O) reduction with a synchronous output *)

let do_sync_res_io cur_state seen_list rest_subprocess n name_params' new_occs facts tc pat p tc' public_channel next_f   =
  (* The real list of processes is (List.rev_append seen_list (InputProcess :: rest_subprocess)) 
     It differs from cur_state.subprocess only by the cache of input processes, so when
     looking for an output process, we can use cur_state.subprocess instead. *)
  let rec find_synchronous_output noutput = function
      [] -> raise No_result (* Not found *)
    | ((Output(tc2,t2,p2,out_occ),name_params2,occs2, facts2, cache_info2)::rest_subprocess2) when p2 != Nil ->
	begin
	  try
	    let tc2' = get_choice tc2 in
	    let t2' = get_choice t2 in
	    if equal_bi_terms_modulo tc2' tc' then
	      begin
		made_forward_step := true;
		(* The i/o reduction is possible, compute the reduced state *)
		let fact = build_mess_fact cur_state.current_phase tc' t2' in
		try
		  auto_cleanup (fun () ->
		    bi_action (bi_match_pattern pat t2') (fun _ -> 
		      let name_params'' = update_name_params name_params' pat in
		      let p' = auto_cleanup (fun () -> copy_process p) in
		      let cur_state' = 
			{ (if public_channel then
			  add_public cur_state t2' else cur_state)
		          with
			  subprocess = replace_at noutput (p2, name_params2, (OutputTag out_occ)::occs2, facts2, Nothing) 
			    (List.rev_append seen_list ((p', name_params'', new_occs, fact :: facts, Nothing) :: rest_subprocess));
			  comment = RIO(n, make_bi_choice tc', pat, noutput, tc2, t2);
			  previous_state = Some cur_state }
		      in
		      normal_state2 next_f false cur_state' noutput n
			    )
		      )
	        with Unify -> (* The pattern does not match *)
		  let noutput' = if n > noutput then noutput else noutput-1 in
		  let cur_state' = 
		    { (if public_channel then
		      add_public cur_state t2' else cur_state)
                      with
                      subprocess = replace_at noutput' (p2, name_params2, occs2, facts2, Nothing) 
			(List.rev_append seen_list rest_subprocess);
		      comment = RIO2(n, make_bi_choice tc', pat, noutput, tc2, t2);
                      previous_state = Some cur_state }
		  in
		  normal_state next_f false cur_state' noutput'
	        | FailOneSideOnly ->
	            (* SUCCESS the pattern matching fails on one side only *)
		    { cur_state with
                      goal = ProcessTest(ref (Some(n, List.nth cur_state.subprocess n))) }
	      end
	    else raise Unify
          with Unify | No_result ->
	    find_synchronous_output (noutput+1) rest_subprocess2
	end
    | _::rest_subprocess2 -> find_synchronous_output (noutput+1) rest_subprocess2
  in
  find_synchronous_output 0 cur_state.subprocess

(* Perform a get (Res Get) *)

let rec find_term stop_l t l = 
  if l == stop_l then false else
  match l with
    [] -> false
  | (a::r) ->
      if equal_bi_terms_modulo t a then true else find_term stop_l t r

let do_res_get cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts pat t p mess_term old_tables next_f    =
  (* The real list of processes is (List.rev_append seen_list (InputProcess :: rest_subprocess)) *)
  current_cache_list := mess_term :: (!current_cache_list);
  debug_print "Get";
  if not (find_term old_tables mess_term cur_state.tables) then raise Unify; (* The entry is not found *)
  debug_print "Ok, the entry is present";
  try
    made_forward_step := true;
    auto_cleanup (fun () ->
      bi_action (bi_match_pattern pat mess_term) (fun _ -> 
	let name_params'' = update_name_params name_params' pat in
	term_evaluation_name_params (fun t' name_params''' ->
	  match t' with
	    (FunApp(f,[]), FunApp(f',[])) when f == Terms.true_cst && f' == Terms.true_cst ->
	      (* we check that t evaluates to true *)	    
	      let p' = auto_cleanup (fun () -> copy_process p) in
	      let fact' = build_table_fact cur_state.current_phase mess_term in
	      normal_state next_f false 
		{ cur_state with
                  subprocess = List.rev_append seen_list ((p', name_params''', new_occs, fact' :: facts, Nothing) :: rest_subprocess);
                  comment = RGet(n, pat, t, make_bi_choice mess_term);
                  previous_state = Some cur_state } n
	  | (FunApp(f,[]),_) when f == Terms.true_cst -> 
	      raise FailOneSideOnly
	  | (_,FunApp(f,[])) when f == Terms.true_cst -> 
	      raise FailOneSideOnly
	  | _ -> raise Unify
		) t new_occs facts name_params'' cur_state.io_rule
	  ) 
	)
  with No_result ->
    (* Using the entry mess_term on this input will always fail,
       even in the following of the trace *)
    current_cache_list := List.tl (!current_cache_list);
    raise Unify
  | FailOneSideOnly ->
    (* SUCCESS the pattern matching fails on one side only *)
      { cur_state with
        goal = ProcessTest(ref (Some(n, List.nth cur_state.subprocess n))) }
   
(* Dispatch between (Res In), asynchronous (Res I/O), and synchronous (Res I/O), and (Res Get) *)

let rec find_in_out next_f cur_state n seen_list = function
    [] -> raise No_result
  | ((Input(tc,pat,p,occ) as proc ,name_params,occs, facts, cache_info)::rest_subprocess) ->
      debug_print ("Trying Input on process " ^ (string_of_int n));
      begin
	match cache_info with
	  OutputInfo _ | GetInfo _ -> Parsing_helper.internal_error "Should not have output/get info for an input!"
	| InputInfo(tc_list, oldpub, tc', name_params', new_occs, l) -> 
	    let tc_list' = update_term_list oldpub cur_state.public tc_list in
	    if (!Param.active_attacker) && (tc_list' = []) then
	      begin
	        (* The channel is public and the attacker is active, try (Res In) *)
		let current_cache_list = ref [] in
		let rec do_l = function
		    [] -> 
		      let seen_list' = (proc ,name_params,occs, facts, 
					InputInfo(tc_list', cur_state.public, tc', name_params', new_occs, !current_cache_list)) :: seen_list in
		      find_in_out next_f cur_state (n+1) seen_list' rest_subprocess
		  | (mess_term, public_status)::l -> 
		      try
			do_res_in cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' mess_term public_status next_f
		      with Unify ->
		      do_l l 
		in
		do_l l
	      end
	    else
	      begin
	        (* The channel is private or the attacker is passive, try (Res I/O) *)
		let current_cache_list = ref [] in
		let public_channel = (not (!Param.active_attacker)) && (tc_list' = []) in
		let rec do_l = function
		    [] -> 
		      let seen_list' = (proc ,name_params,occs, facts, 
					InputInfo(tc_list', cur_state.public, tc', name_params', new_occs, !current_cache_list)) :: seen_list in
		      begin
			try 
			  do_sync_res_io cur_state seen_list rest_subprocess n name_params' new_occs facts tc pat p tc' public_channel next_f
			with Unify | No_result ->
			  find_in_out next_f cur_state (n+1) seen_list' rest_subprocess
		      end
		  | (mess_term,_)::l -> 
		      try
			do_async_res_io cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' mess_term public_channel next_f
		      with Unify ->
			do_l l 
		in
		do_l l
	      end
	| Nothing ->
	    let seen_list' = ref ((proc, name_params, occs, facts, cache_info) :: seen_list) in
	    try
              auto_cleanup (fun () ->
		term_evaluation_name_params (fun tc' name_params' ->
		  let m = 
		    if cur_state.current_phase < !Reduction_helper.min_choice_phase then
		      let v = Reduction_helper.new_var_pat pat in
		      (v,v)
		    else
		      (Reduction_helper.new_var_pat pat, Reduction_helper.new_var_pat pat)
		  in
		  let new_occs = (InputTag occ) :: occs in
		  let fact = build_mess_fact cur_state.current_phase tc' m in
		  let tc_list = decompose_term tc' in
		  let tc_list' = remove_first_in_public cur_state.public tc_list in
		  if (!Param.active_attacker) && (tc_list' = []) then
		    begin
		      (* Input on a public channel, and the attacker is active: apply (Res In)  *)
		      let current_cache_list = ref [] in
		      try
			find_io_rule (function
			    [mess_term1;mess_term2] ->
			      do_res_in cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' (mess_term1,mess_term2) None next_f
			  | _ -> Parsing_helper.internal_error "input case; reduction_bipro.ml"
				) new_occs (fact :: facts) name_params' [fst m; snd m] cur_state.io_rule
		      with Unify ->
			seen_list' := (proc, name_params, occs, facts, 
				       InputInfo([], [], tc', name_params', new_occs, !current_cache_list)) :: seen_list;
			raise No_result
		    end
		  else
		    begin
		      (* Input on a private channel or the attacker is passive: apply (Res I/O)
			 First try an asynchronous output, with a corresponding clause in the tree *)
		      let current_cache_list = ref [] in
		      let public_channel = (not (!Param.active_attacker)) && (tc_list' = []) in
		      try
			find_io_rule (function
			    [mess_term1;mess_term2] ->
			      do_async_res_io cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' (mess_term1,mess_term2) public_channel next_f
			  | _ -> Parsing_helper.internal_error "input case; reduction_bipro.ml"
				) new_occs (fact :: facts) name_params' [fst m; snd m] cur_state.io_rule
                      with Unify ->
			seen_list' := (proc, name_params,occs, facts, 
				       InputInfo(tc_list', cur_state.public, tc', name_params', new_occs, !current_cache_list)) :: seen_list;
		        (* Try a synchronous output *)
			do_sync_res_io cur_state seen_list rest_subprocess n name_params' new_occs facts tc pat p tc' public_channel next_f
		    end
                      ) tc occs facts name_params cur_state.io_rule
		  )
	    with Unify | No_result ->
	      find_in_out next_f cur_state (n+1) (!seen_list') rest_subprocess
	  | FailOneSideOnly ->
	      (* SUCCESS the evaluation of the channel name fails on one side only *)
	      { cur_state with
                goal = ProcessTest(ref (Some(n, List.nth cur_state.subprocess n))) }
      end
  | ((Get(pat,t,p,occ) as proc ,name_params,occs, facts, cache_info)::rest_subprocess) ->
      debug_print ("Trying Get on process " ^ (string_of_int n));
      begin
	match cache_info with
	  OutputInfo _ | InputInfo _ -> Parsing_helper.internal_error "Should not have input/output info for a get!"
	| GetInfo(old_tables, l) -> 
	    let new_occs = (GetTag occ) :: occs in
	    let current_cache_list = ref [] in
	    let rec do_l = function
		[] -> 
		  let seen_list' = (proc ,name_params,occs, facts, 
				    GetInfo(cur_state.tables, !current_cache_list)) :: seen_list in
		  find_in_out next_f cur_state (n+1) seen_list' rest_subprocess
	      | mess_term::l -> 
		  try
		    do_res_get cur_state seen_list rest_subprocess n current_cache_list name_params new_occs facts pat t p mess_term old_tables next_f
		  with Unify ->
		    do_l l 
	    in
	    do_l l
	| Nothing ->
	    let seen_list' = ref ((proc, name_params, occs, facts, cache_info) :: seen_list) in
	    try
              auto_cleanup (fun () ->
		let m = 
		  if cur_state.current_phase < !Reduction_helper.min_choice_phase then
		    let v = Reduction_helper.new_var_pat pat in
		    (v,v)
		  else
		    (Reduction_helper.new_var_pat pat, Reduction_helper.new_var_pat pat)
		in
		let new_occs = (GetTag occ) :: occs in
		let fact = build_table_fact cur_state.current_phase m in
		begin
		  let current_cache_list = ref [] in
		  try
		    find_io_rule (function
			[mess_term1;mess_term2] ->
			  do_res_get cur_state seen_list rest_subprocess n current_cache_list name_params new_occs facts pat t p (mess_term1,mess_term2) [] next_f
		      | _ -> Parsing_helper.internal_error "get case; reduction_bipro.ml"
                            ) new_occs (fact :: facts) name_params [fst m; snd m] cur_state.io_rule
		  with Unify ->
		    seen_list' := (proc, name_params, occs, facts, 
				   GetInfo(cur_state.tables, !current_cache_list)) :: seen_list;
		    raise No_result
		end
		  )
	    with Unify | No_result ->
	      find_in_out next_f cur_state (n+1) (!seen_list') rest_subprocess
	  | FailOneSideOnly ->
	      (* SUCCESS the evaluation of the channel name fails on one side only *)
	      { cur_state with
                goal = ProcessTest(ref (Some(n, List.nth cur_state.subprocess n))) }
      end
  | sub_proc::rest_subprocess -> 
      find_in_out next_f cur_state (n+1) (sub_proc :: seen_list) rest_subprocess

(* Handle phases *)

let rec extract_phase n = function
    [] -> []
  | (Phase(n',p),name_params,occs, facts, cache_info)::r -> 
      let r' = extract_phase n r in
      if n = n' then (p,name_params,occs, facts, Nothing)::r' else 
      if n<n' then (Phase(n',p),name_params,occs, facts, Nothing)::r' else r'
  | _::r -> extract_phase n r

let rec find_phase next_f cur_state n = function
    [] -> 
      if !made_forward_step then
	begin
          incr failed_traces;
          made_forward_step := false
	end;
      (* Useful for debugging *)
      if !debug_backtracking then
	begin
	  ignore (display_reduc_state true cur_state);
	  print_string "Blocked. Backtracking...\n"
	end
      else
	debug_print "Backtracking";
      raise No_result
  | (Phase(n,p),name_params,occs, facts, cache_info)::rest_subprocess -> 
      debug_print "Doing Phase";
      if n <= cur_state.current_phase then
	Parsing_helper.user_error "Phases should be in increasing order";
      made_forward_step := true;
      begin
	try 
	  (* Do transition to phase n *)
	  let cur_state' = 
	    { cur_state with
	      subprocess = extract_phase n cur_state.subprocess;
	      previous_state = Some cur_state;
	      current_phase = n;
	      comment = RPhase(n) }
	  in
	  (* Reclose public, since new function symbols may become applicable *)
	  let cur_state'' = add_public_list { cur_state' with public = [] } cur_state'.public in
	  normal_state_all next_f false cur_state''
        with No_result ->
	  find_phase next_f cur_state (n+1) rest_subprocess
      end
  | _::rest_subprocess -> find_phase next_f cur_state (n+1) rest_subprocess

(* Put all reductions together *)

let rec reduction_backtrack state = 
  try
    find_in_out reduction_backtrack state 0 [] state.subprocess
  with No_result ->
    find_phase reduction_backtrack state 0 state.subprocess


(* This exception is local to reduction_nobacktrack *)
exception Reduced of reduc_state

let rec reduction_nobacktrack state =
  try
    try
      find_in_out (fun state -> raise (Reduced state)) state 0 [] state.subprocess
    with No_result ->
      find_phase (fun state -> raise (Reduced state)) state 0 state.subprocess
  with Reduced one_red_state ->
    display_trace one_red_state;
    display_init_state := false;
    reduction_nobacktrack { one_red_state with previous_state = None }

let reduction state =
  if !Param.trace_backtracking then
    reduction_backtrack state
  else
    reduction_nobacktrack state

(* Build the goal *)

let analyze_tree tree =
  match tree.desc with
    FRule(_, lbl, _, hyp) ->
      begin
	match lbl, hyp with
	  ProcessRule2(hyp_tags, name_params1, name_params2), hyp ->
	    ProcessTest(ref None)
	| TestApply(f, p), hyp ->
	    ApplyTest(funsymb_from_funspec f, List.map (function 
		{ thefact = Pred(_, l) } -> rev_name_subst_bi l
	      |	_ -> Parsing_helper.internal_error "Unexpected derivation for choice") hyp)
	| TestComm(pi,po), [{thefact = Pred(_,lin)}; {thefact = Pred(_,lout)}] ->
	    CommTest(rev_name_subst_bi lin, rev_name_subst_bi lout, ref None)
	| TestEq(p), [{thefact = Pred(_,l1)};{thefact = Pred(_,l2)}] ->
	    EqTest(rev_name_subst_bi l1, rev_name_subst_bi l2)
	| _ -> Parsing_helper.internal_error "Unexpected clause concluding the derivation for choice"
      end
  | _ -> Parsing_helper.internal_error "Unexpected derivation for choice"


(* Main trace reconstruction function *)

let do_reduction tree =
(*  Profile.start();  *)
  made_forward_step := true;
  failed_traces := 0;
  let public_init = public_build !Param.freenames in
  public_free := public_init;
  display_init_state := true;
  init_name_mapping (!Param.freenames);
  close_tree tree;
  let init_state = 
    { goal = analyze_tree tree;
      subprocess = [(!(main_process), [],[],[],Nothing)];
      public = List.map (fun t -> (t,t)) public_init;
      tables = [];
      io_rule = [];
      prepared_attacker_rule = [];
      previous_state = None;
      hyp_not_matched = [];
      current_phase = 0;
      comment = RInit } 
  in
  let res = 
    begin
      try
	let state = init_rule init_state tree in
        (* Close initially the set public *)
	let state = add_public_list { state with public = [] } state.public in
	if !debug_find_io_rule then
	  begin
	    auto_cleanup (fun () ->
	      print_string "Available rules:";
	      Display.newline();
	      List.iter display_rule state.io_rule)
	  end;
	let final_state = normal_state reduction true state 0 in
	if final_state.hyp_not_matched = [] then 
	  begin
	    display_trace final_state; 
	    display_goal final_state.goal;
	    print_string "A trace has been found.";
	    Display.newline();
	    true
	  end
	else
	  begin
	    display_trace final_state; 
	    display_goal final_state.goal;
	    print_string "A trace has been found, assuming the following hypothesis :";
	    Display.newline();
	    List.iter (fun x ->
	      print_string "    * ";
	      Display.WithLinks.fact x;
	      Display.newline ()) final_state.hyp_not_matched;
	    Display.newline ();
	    false
	  end
      with No_result ->
	if not (!Param.trace_backtracking) then
	  begin
	    print_string "Blocked!";
	    Display.newline()
	  end;
	print_string "Could not find a trace corresponding to this derivation.";
	Display.newline();
	false
    end
  in
(*  print_endline ("Failed " ^ (string_of_int (!failed_traces)) ^ " traces."); *)
  Terms.cleanup ();
(*  Profile.stop(); *)
  res

(* Heuristic to find traces more often, especially with complex protocols:
   we unify rules of the derivation tree when possible
   Note that success is not guaranteed; however, when the heuristic fails,
   the derivation does not correspond to a trace. 

This heuristic can break inequality constraints.
We recheck them after modifying the derivation tree. *)

(* First, revise_tree is the function that checks that inequality constraints still hold *)

exception Loop


let rec find_fact f t =
  if 
    (match t.desc with 
      FHAny | FEmpty | FRemovedWithProof _ -> false
    | _ -> true) && (equal_facts_modulo f t.thefact) then t else
  match t.desc with
    FEquation son -> find_fact f son
  | FRule(_,_,_,sons) -> find_fact_list f sons
  | _ -> raise Not_found

and find_fact_list f = function
    [] -> raise Not_found
  | a::l -> 
      try
	find_fact f a 
      with Not_found ->
	find_fact_list f l
      

let revise_tree tree =
  let rec revise_tree_rec no_loop t =
    if List.memq t no_loop then
      raise Loop
    else
      { desc =
	begin
	  match t.desc with
	    FHAny | FEmpty -> 
	      begin
		match t.thefact with
                  Pred(p, [t']) when 
		  (match follow_link t' with Var v -> true | _ -> false) -> t.desc
		| Pred(p, [t';t'']) when 
		  (match follow_link t' with Var v -> true | _ -> false) &&
		  (match follow_link t'' with Var v -> true | _ -> false) -> t.desc
		| Out _ -> t.desc (* Out facts cannot be proved anyway *)
		| _ -> 
		    (* When unification has lead to instantiating a fact that need not be proved before, try to find a proof for it. *)
	            try
                      let t' = revise_tree_rec (t::no_loop) (find_fact t.thefact tree) in
		      t'.desc 
                    with Not_found | Loop -> 
		      FEmpty
              end
	  | FRule(n, tags, constra, sons) -> 
	      if constra != [] then
		begin
		  try 
		    let constra' = Terms.auto_cleanup (fun () ->
		      List.map Terms.copy_constra2 constra) in
		    Terms.auto_cleanup(fun () ->
		      ignore (Rules.simplify_constra_list [] constra'))
		  with Rules.FalseConstraint ->
		    print_string "Unification made an inequality become false.\nTrying with the initial derivation tree instead.\n";
		    raise Rules.FalseConstraint
		end;
	      FRule(n, tags, constra, List.map (revise_tree_rec no_loop) sons)
	  | FRemovedWithProof t ->  FRemovedWithProof t
	  | FEquation son -> FEquation(revise_tree_rec no_loop son)
	end;
	thefact = t.thefact }
  in
  revise_tree_rec [] tree


(* simplify_tree unifies facts with same session identifier *)

(* "first" is true when this is the first call to simplify_tree. 
   In this case, if we find no unification to do, we do not need to call
   revise_tree, since the derivation has not been modified at all *)

let f_has_no_eq f =
  match f.f_cat with
    Eq [] -> true
  | Eq _ -> false
  | _ -> true

module HashFactId =
  struct

    type factIdElem =
	HypSpec of hypspec
      |	Term of term

    type t = 
	{ hash : int;
	  factId : factIdElem list }

    let equalFactIdElem a b =
      match (a,b) with
	HypSpec h, HypSpec h' -> h = h'
      |	Term t, Term t' -> Termslinks.equal_terms_with_links t t'
      |	_ -> false

    let equal a b = 
      (List.length a.factId == List.length b.factId) &&
      (List.for_all2 equalFactIdElem a.factId b.factId)

    type skel_term =
	SVar of int
      |	SFun of string * skel_term list

    type skel_factIdElem =
	SHypSpec of hypspec
      |	STerm of skel_term

    let rec skeleton_term = function
	Var b -> 
	  begin
	    match b.link with
	      TLink t -> skeleton_term t
	    | NoLink -> SVar(b.vname)
	    | _ -> Parsing_helper.internal_error "unexpected link in skeleton_term"
	  end
      |	FunApp(f,l) -> 
	  match f.f_cat with
	    Name _ -> SFun(f.f_name,[])
	  | _ -> SFun(f.f_name, List.map skeleton_term l)

    let skeleton_factIdElem = function
	HypSpec x -> SHypSpec x
      |	Term t -> STerm(skeleton_term t)

    let hash a = a.hash

    (* build a HashFactId.t from a fact id *)

    let build fid = { hash = Hashtbl.hash(List.map skeleton_factIdElem fid);
		      factId = fid }

  end

module FactHashtbl = Hashtbl.Make(HashFactId)

let rec simplify_tree first next_f tree =
  let unif_to_do_left = ref [] in
  let unif_to_do_right = ref [] in
  let fact_hashtbl = FactHashtbl.create 7 in
  let done_unif = ref false in

  let rec add_unif_term t1 t2 =
    match t1, t2 with
      FunApp(f1, l1), FunApp(f2,l2) when f_has_no_eq f1 && f_has_no_eq f2 ->
	if f1 == f2 then List.iter2 add_unif_term l1 l2
	(* When f1 != f2, unification fails; I display no message. *)
    | Var v, Var v' when v == v' -> ()
    | Var v, _ -> 
	begin
	  match v.link with
	    NoLink ->
	      begin
		match t2 with
		  Var {link = TLink t2'} -> add_unif_term t1 t2'
		| _ ->
		    try
		      print_string "Trying unification ";
		      Display.WithLinks.term t1;
		      print_string " with ";
		      Display.WithLinks.term t2;
		      Terms.occur_check v t2;
		      Terms.link v (TLink t2);
		      print_string " succeeded.";
		      print_newline();
		      done_unif := true
		    with Unify -> 
                      (* Unification failed *)
		      print_string " failed.";
		      print_newline()
	      end
	  | TLink t1' -> add_unif_term t1' t2
	  | _ -> Parsing_helper.internal_error "Unexpected link in add_unif_term 1"
	end
    | _, Var v ->
	begin
          match v.link with
             NoLink -> 
	       begin
		 try
		   print_string "Trying unification ";
		   Display.WithLinks.term t1;
		   print_string " with ";
		   Display.WithLinks.term t2;
		   Terms.occur_check v t1;
		   Terms.link v (TLink t1);
		   print_string " succeeded.";
		   print_newline();
		   done_unif := true
		 with Unify -> 
                   (* Unification failed *)
		   print_string " failed.";
		   print_newline()
	       end
           | TLink t2' -> add_unif_term t1 t2'
           | _ -> Parsing_helper.internal_error "Unexpected link in add_unif_term 2"
	end
    | _ ->
        (* It is important to check equality *modulo the equational
	   theory* here. Otherwise, unify_modulo may make the two terms equal
	   modulo the theory but still syntactically different, which would 
	   result in an endless iteration of unifyDerivation. *)
	if not (equal_open_terms_modulo t1 t2) then
	  begin
	    unif_to_do_left := t1 :: (!unif_to_do_left);
	    unif_to_do_right := t2 :: (!unif_to_do_right)
	  end
  in
  
  let add_unif_fact f1 f2 =
    if (f1 != f2) then
      match f1, f2 with
	Pred(p1,l1), Pred(p2,l2) when p1 == p2 ->
	  List.iter2 add_unif_term l1 l2
      | Out(t1,_),Out(t2,_) -> 
	  add_unif_term t1 t2
      | _ -> 
	  print_string "Trying to unify incompatible facts in unifyDerivation; skipping this impossible unification.\n"

  in

  let rec check_coherent factId (concl, hyp_spec, name_params1, name_params2, sons) =
    match hyp_spec with
      [] -> ()
    | h1::l1 -> 
	let factId' = (HashFactId.HypSpec h1) :: factId in
	match h1 with
          ReplTag (occ,count_params) -> 
	    (* the session identifiers are part of the fact id *)
	    check_coherent ((HashFactId.Term (List.nth name_params1 count_params)) ::
			    (HashFactId.Term (List.nth name_params2 count_params)) :: factId')
	      (concl, l1, name_params1, name_params2, sons) 
	| OutputTag occ | InsertTag occ | InputPTag occ | OutputPTag occ ->
	    if l1 == [] then
	      (* I'm reaching the conclusion *)
	      let fact_id = HashFactId.build factId' in
	      try
		let concl' = FactHashtbl.find fact_hashtbl fact_id in
		add_unif_fact concl concl'
	      with Not_found ->
		FactHashtbl.add fact_hashtbl fact_id concl
	    else
	      check_coherent factId' (concl, l1, name_params1, name_params2, sons)
	| LetTag occ | TestTag occ | TestUnifTag2 occ ->
	    check_coherent factId' (concl, l1, name_params1, name_params2, sons)
	| InputTag _ | GetTag _ -> 
	    let f = (List.hd sons).thefact in
	    let fact_id = HashFactId.build factId' in
	    begin
	      try
		let f' = FactHashtbl.find fact_hashtbl fact_id in
		add_unif_fact f f'
	      with Not_found -> 
		FactHashtbl.add fact_hashtbl fact_id f
	    end;
            check_coherent factId' (concl, l1, name_params1, name_params2, List.tl sons)
	| TestUnifTag _ | BeginEvent _ | LetFilterTag _ | BeginFact | LetFilterFact -> Parsing_helper.internal_error "TestUnifTag, BeginEvent, LetFilterTag, BeginFact, LetFilterFact should not be generated for biprocesses"
  in

  let rec simplify_tree1 t =
    match t.desc with
      FRule(_, ProcessRule2(hyp_spec, name_params1, name_params2), constra, sons) -> 
	check_coherent [] (t.thefact, List.rev hyp_spec, List.rev name_params1, List.rev name_params2, List.rev sons);
	List.iter simplify_tree1 sons
    | FRule(_,_,_,sons) ->
        List.iter simplify_tree1 sons
    | FEquation son -> simplify_tree1 son
    | FHAny -> 
	begin
	match t.thefact with
	  Pred({p_info = [AttackerBin _]}, [t1;t2]) ->
	    if t1 != t2 then add_unif_term t1 t2
	| _ -> ()
	end
    | _ -> ()
  in

  simplify_tree1 tree;
  if (!unif_to_do_left) == [] then
    if !done_unif then
      begin
	print_string "Iterating unifyDerivation.";
	print_newline();
        simplify_tree false next_f tree
      end
    else if first then
      begin
	(* print_string "Nothing to unify.\n"; *)
	next_f tree
      end
    else
      begin
	print_string "Fixpoint reached: nothing more to unify.";
	print_newline();
	next_f (revise_tree tree)
      end
  else
    begin
      print_string "Trying unification ";
      Display.WithLinks.term_list (!unif_to_do_left);
      print_string " with ";
      Display.WithLinks.term_list (!unif_to_do_right);
      try
	auto_cleanup (fun () ->
	  TermsEq.unify_modulo_list (fun () -> 
	    print_string " succeeded.\n";
	    print_string "Iterating unifyDerivation.\n";
	    simplify_tree false next_f tree
	       ) (!unif_to_do_left) (!unif_to_do_right)
	    )
      with Unify ->
        print_string " failed.\n";
	next_f (revise_tree tree)
    end

let do_reduction tree =
  let r = 
    if !Param.unify_derivation then
      begin
	(* print_string "Starting unifyDerivation.\n"; *)
	try
	  auto_cleanup (fun () -> simplify_tree true do_reduction tree)
	with Rules.FalseConstraint ->
	  do_reduction tree
      end
    else
      do_reduction tree
  in
  Terms.cleanup();
  r


