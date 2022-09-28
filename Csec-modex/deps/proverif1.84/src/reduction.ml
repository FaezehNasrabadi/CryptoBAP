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
   Should I localize the processes (or the attacker) that sends the message or 
   executes an event when the goal is mess:... or event:...? In fact, the current
   display already gives the information in most cases.
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
  (*  print_string s; Display.newline() *)

type name_param_info = 
    Always of string * term
  | IfQueryNeedsIt of string * term

let rec count_name_params = function
    [] -> 0
  | (Always _)::l -> 1+count_name_params l
  | (IfQueryNeedsIt _)::l -> count_name_params l

let rec extract_name_params_noneed = function
    [] -> []
  | (Always(s,t)::l) ->
      t::(extract_name_params_noneed l)
  | (IfQueryNeedsIt(s,t)::l) ->
      extract_name_params_noneed l

let rec extract_name_params sf need_list = function
    [] -> 
      begin
	match need_list with
	  [] -> []
	| ((s,ext)::_) ->
	    Parsing_helper.input_error ("variable " ^ s ^ " not defined at restriction " ^ sf) ext
      end
  | (Always(s,t)::l) ->
      t::(extract_name_params sf (List.filter (fun (s',_) -> s' <> s) need_list) l)
  | (IfQueryNeedsIt(s,t)::l) ->
      if List.exists (fun (s',_) -> s' = s) need_list then
	t::(extract_name_params sf (List.filter (fun (s',_) -> s' <> s) need_list) l)
      else
	extract_name_params sf need_list l

type info = 
    InputInfo of term list * term list * term * name_param_info list * hypspec list * (term * (term list * term list) option) list
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
  | OutputInfo of term list * term list
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
  | GetInfo of term list * term list
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

type weak_test =
    DestrTest of term
  | EqTest of term * term

type noninterf_test =
    ProcessTest of hypspec list * term list * (int * sub_proc) option ref(*location where test found*)
  | ApplyTest of funsymb * term list
  | CommTest of term(*input channel*) * term(*output channel*) * 
	(loc_info(*location where input found*) * loc_info(*location where output found*)) option ref
  | InputTest of term(*input channel*) * loc_info option ref(*location where input found*)
  | OutputTest of term(*output channel*) * loc_info option ref(*location where output found*)
  | NIEqTest of term * term

type goal_t =
    Fact of fact
  | WeakSecrGoal of (term * binder) list * weak_test * term * term
	(*
	  list of terms that the attacker has to know, with arbitrary variables
	  to store them,
	  the term that the attacker computes to test its guess,
	  the weak secret that the attacker wants to guess,
	  the symbol that represents the guess
	*)
  | NonInterfGoal of noninterf_test
  | InjGoal of fact * term * int 
        (* The end event to execute, the second session in which it should
	   be executed, and the number of times it has already been met *)

type reduc_state = 
    { 
      goal : goal_t; (* goal to reach *)
      subprocess : sub_proc list; (* process list *)
      public : term list; (* attacker knowledge *)
      tables : term list; (* contents of tables *)

      prepared_attacker_rule : (predicate * term list * term list) list; (* attacker rules *)
                               (* predicate, hypothesis, conclusion *)
      io_rule : (int * fact list * hypspec list * term list * fact) list; (* process rules *)
                (* rule number, hypotheses, occurrence labels, name params, conclusion *)

      previous_state : reduc_state option; (* previous semantic state *)
   
      hyp_not_matched : fact list;
      current_phase : int;
      comment : reduc_type  (* type of the reduction *)
    }

exception No_result
(* We use the exception Unify for local failure *)

let equal_io_rule (n1, h1, hs1, np1, f1) (n2, h2, hs2, np2, f2) =
  (n1 == n2) &&
  (List.length h1 == List.length h2) &&
  (List.for_all2 Termslinks.equal_facts_with_links h1 h2) &&
  (List.length hs1 == List.length hs2) &&
  (List.for_all2 (=) hs1 hs2) &&
  (List.length np1 == List.length np2) &&
  (List.for_all2 Termslinks.equal_terms_with_links np1 np2) &&
  (Termslinks.equal_facts_with_links f1 f2)

(* Display clauses *)

let display_rule (n, sons, hsl, nl, concl) = 
  print_string ("Rule " ^ (string_of_int n) ^ ": ");
  display_tag hsl nl;
  print_string "  ";
  Display.display_rule (List.map (fun t -> copy_fact2 t) sons, copy_fact2 concl, Empty concl, []);
  Display.newline()

(* Display the trace *)

let display_init_state = ref true

(* TO DO display the additional entries in tables ?
   Perhaps not necessary, since this is clear from the executed "insert" instructions. *)

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
	Display.display_term2 x;
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
    LetFilter(_,_,_,_,occ) | Event(_,_,occ) | Insert(_,_,occ) | Get(_,_,_,occ)), 
    name_params, _, _, _ ->
      print_string " at ";
      Display.display_occ occ;
      let first = ref true in
      List.iter (function 
	  Always("!", sid) -> 
	    if !first then print_string " in copy " else print_string ", ";
	    first := false;
	    Display.display_term2 sid
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

let display_explained_fact = function
    Pred({p_info = [Attacker(n,_)]} as p, [v]) ->
      print_string "The attacker has the message ";
      Display.display_term2 v;
      Display.display_phase p
  | Pred({p_info = [Mess(n,_)]} as p, [vc;v]) ->
      print_string "The message ";
      Display.display_term2 v;
      print_string " is sent on channel ";
      Display.display_term2 vc;
      Display.display_phase p
  | Pred({p_info = [AttackerBin(n,_)]} as p, [v;v']) ->
      print_string "The attacker has the message ";      
      Display.display_term2 v;
      print_string " (resp. ";
      Display.display_term2 v';
      print_string ")";
      Display.display_phase p
  | Pred({p_info = [MessBin(n,_)]} as p, [vc;v;vc';v']) ->
      print_string "The message ";
      Display.display_term2 v;
      print_string " is sent on channel ";
      Display.display_term2 vc;
      print_string " (resp. message ";
      Display.display_term2 v';
      print_string " on channel ";
      Display.display_term2 vc';
      print_string ")";
      Display.display_phase p
  | Pred(p, [e]) when p == Param.end_pred ->
      print_string "The event ";
      Display.display_term2 e;
      print_string " is executed"
  | Pred(p, [e';e]) when p == Param.end_pred_inj ->
      print_string "The event ";
      Display.display_term2 e;
      print_string " is executed in session ";
      Display.display_term2 e'
  | Pred({p_info = [InputP(n)]} as p, [e]) ->
      print_string "An input is executed on channel ";
      Display.display_term2 e;
      Display.display_phase p
  | Pred({p_info = [InputPBin(n)]} as p, [e;e']) ->
      print_string "An input is executed on channel ";
      Display.display_term2 e;
      print_string " (resp. ";
      Display.display_term2 e';
      print_string ")";
      Display.display_phase p
  | Pred({p_info = [OutputP(n)]} as p, [e]) ->
      print_string "An output is executed on channel ";
      Display.display_term2 e;
      Display.display_phase p
  | Pred({p_info = [OutputPBin(n)]} as p, [e;e']) ->
      print_string "An output is executed on channel ";
      Display.display_term2 e;
      print_string " (resp. ";
      Display.display_term2 e';
      print_string ")";
      Display.display_phase p
  | _ -> Parsing_helper.internal_error "Unexpected goal"


let display_goal = function
    Fact f -> 
      (* Display.WithLinks.fact f; *)
      display_explained_fact f;
      print_string ".";
      Display.newline()
  | InjGoal(f,sid',n) ->
      begin
	match f with
	  Pred(p, [e';e]) when p == Param.end_pred_inj ->
	    print_string "The event ";
	    Display.display_term2 e;
	    print_string " is executed in session ";
	    Display.display_term2 e';
	    print_string " and in session ";
	    Display.display_term2 sid';
	    print_string ".";
	    Display.newline()
	| _ -> Parsing_helper.internal_error "InjGoal should have an injective event as argument"
      end
  | WeakSecrGoal(l, t, w1, w2) ->
      print_string "The attacker tests whether ";
      begin
	match t with
	  DestrTest t' ->
	    Display.display_term2 t';
	    print_string " succeeds knowing "
	| EqTest(t1,t2) ->
	    Display.display_term2 t1;
	    print_string " = ";
	    Display.display_term2 t2;
	    print_string " knowing "
      end;
      Display.display_list (fun (t,b) -> 
	print_string ((Display.varname b) ^ " = ");
	Display.display_term2 t) ", " l;
      print_string ".";
      Display.newline();
      print_string "This allows the attacker to know whether ";
      Display.display_term2 w2;
      print_string " = ";
      Display.display_term2 w1;
      print_string ".";
      Display.newline()
  | NonInterfGoal t ->
      match t with
	ProcessTest(hypspec,tl,loc) ->
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
      |	ApplyTest(f,tl) ->
	  print_string "The attacker tries to apply ";
	  Display.display_function_name f;
	  print_string " to the messages ";
	  Display.display_list Display.display_term2 ", " tl;
	  print_string " that he has.";
	  Display.newline();
	  print_string "This gives the attacker some information on the secret.";
	  Display.newline()
      |	CommTest(t1,t2,loc) ->
	  print_string "An input on channel ";
	  Display.display_term2 t1;
	  print_string " and an output on channel ";
	  Display.display_term2 t2;
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
	  print_string "The success or failure of the communication may give the attacker some information on the secret.";
	  Display.newline()
      |	InputTest (t,loc) ->
	  print_string "An input on channel ";
	  Display.display_term2 t;
	  print_string " is performed";
	  begin
	    match !loc with
	      None -> Parsing_helper.internal_error "Location should have been filled"
	    | Some iloc -> display_loc iloc
	  end;
	  print_string ".";
	  Display.newline();
	  print_string "The success or failure of the input may give the attacker some information on the secret.";
	  Display.newline()
      |	OutputTest (t, loc) ->
	  print_string "An output on channel ";
	  Display.display_term2 t;
	  print_string " is performed";
	  begin
	    match !loc with
	      None -> Parsing_helper.internal_error "Location should have been filled"
	    | Some oloc -> display_loc oloc
	  end;
	  print_string ".";
	  Display.newline();
	  print_string "The success or failure of the output may give the attacker some information on the secret.";
	  Display.newline()
      |	NIEqTest(t1,t2) ->
	  print_string "The attacker tests whether ";
	  Display.display_term2 t1;
	  print_string " = ";
	  Display.display_term2 t2;
	  print_string ".";
	  Display.newline();
	  print_string "This gives the attacker some information on the secret.";
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

let find_io_rule next_f hypspeclist hyplist name_params1 var_list io_rules =
  let name_params = extract_name_params_noneed name_params1 in
  let l = List.length hypspeclist in
  let lnp = List.length name_params in
  let lh = List.length hyplist in
  (* Useful for debugging *)
  if !debug_find_io_rule then
    begin
      auto_cleanup (fun () ->
	print_string "Looking for ";
	display_tag hypspeclist name_params;
	print_string "  ";
	Display.display_list Display.WithLinks.fact " & " hyplist;
	Display.newline())
    end;
  let found_terms = ref [] in
  let rec find_io_rule_aux = function
    [] -> raise Unify
  | ((n, sons, hypspeclist2, name_params2, _)::io_rules) ->
      let l2 = List.length hypspeclist2 in
      let lnp2 = List.length name_params2 in
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
                  ) name_params (skip (lnp2-lnp) name_params2)
		)
          with Unify -> find_io_rule_aux io_rules
        end
  in 
  find_io_rule_aux io_rules

(* Evaluate a term possibly containing destructors
   Raises Unify when the term evaluation fails.
   The function next_f may raise No_result when it finds no result.
   In this case, term_evaluation also raises No_result *)

let rec term_evaluation next_f = function
    Var v -> 
      begin
        match v.link with
          TLink t -> term_evaluation next_f t
        | _ -> Parsing_helper.internal_error "Error: term should be closed in attack reconstruction";
      end
  | FunApp(f,l) ->
      (* for speed, use the initial definition of destructors, not the one enriched with the equational theory *)
      match f.f_initial_cat with
	Eq _ | Tuple -> term_evaluation_list (fun l' -> next_f (FunApp(f,l'))) l
      | Name _ -> next_f (FunApp(f,[]))
      | Red redl -> term_evaluation_list (fun l' ->
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
	  ) l
      | _ -> Parsing_helper.internal_error "unexpected function symbol in term_evaluation"

and term_evaluation_list next_f = function
    [] -> next_f []
  | (a::l) -> 
      term_evaluation_list (fun l' -> 
	term_evaluation (fun a' ->
	  next_f (a'::l')
	) a
      ) l

(* Evaluates t1 and tests if it is equal to t2. *)
 
let equal_terms_modulo_eval t1 t2 =
  try
    auto_cleanup (fun () ->
      term_evaluation (fun t1' ->
	if equal_terms_modulo t1' t2 then true else raise No_result
	  ) t1)
  with No_result | Unify ->
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
  term_evaluation (fun t' ->
    if may_have_several_types then
      (* We check that a clause in io_rule justifies our choice when adding 
         elements to name_params -> This makes it possible to detect wrong 
         choices very quickly and avoid losing too much time in backtracking. *)
      find_io_rule (fun _ ->
        next_f t' (Always("",t') :: name_params)) hypspeclist hyplist (Always("",t')::name_params) [] io_rules
    else
      next_f t' name_params
    ) t

let rec term_evaluation_letfilter next_f = function
    Var { link = TLink t } -> term_evaluation_letfilter next_f t
  | Var v ->  next_f (Var v)
  | FunApp(f,l) ->
      match f.f_cat with
	Eq _ | Tuple -> term_evaluation_list_letfilter (fun l' -> next_f (FunApp(f,l'))) l
      | Name _ -> next_f (FunApp(f,[]))
      | Red redl -> term_evaluation next_f (FunApp(f,l))
      | _ -> Parsing_helper.internal_error "unexpected function symbol in term_evaluation_letfilter"

and term_evaluation_list_letfilter next_f = function
    [] -> next_f []
  | (a::l) -> 
      term_evaluation_list_letfilter (fun l' -> 
	term_evaluation_letfilter (fun a' -> next_f (a'::l')) a
      ) l

let term_evaluation_letfilter next_f l name_params =
  let may_have_several_types = List.exists check_several_types l in
  term_evaluation_list_letfilter (fun l' ->
    if may_have_several_types then
      (* The fact that the newly added name_params are justified by a clause
	 in the derivation tree will be checked in next_f, when looking
         for the result of letfilter *)
      next_f l' ((List.map (fun t -> Always("",t)) l') @ name_params)
    else
      next_f l' name_params
    ) l

(* Match a pattern
   Raises Unify when the matching fails *)

let rec match_pattern next_f p t = 
  match p with
    PatVar b -> Terms.link b (TLink t); next_f ()
  | PatTuple(f,l) ->
      let vl = Terms.var_gen (fst f.f_type) in
      match_modulo (fun () ->
	let tl = List.map copy_closed_remove_syntactic vl in
        match_pattern_list next_f l tl
	  ) (FunApp(f, vl)) t
  | PatEqual t' ->
      term_evaluation (fun t'' ->
	match_modulo (fun () -> ()) t'' t
	  ) t';
      next_f ()
	
and match_pattern_list next_f pl tl = 
  match (pl, tl) with
    [],[] -> next_f ()
  | (p1::pl,t1::tl) ->
      match_pattern (fun () ->
        match_pattern_list next_f pl tl) p1 t1
  | _ -> Parsing_helper.internal_error "Different length in match_pattern_list"

type put_var_type =
    PutAlways | PutIfQueryNeedsIt

let rec update_name_params put_var name_params = function
    PatVar b -> 
      begin
	match put_var with
	  PutAlways -> Always(b.sname, copy_closed_remove_syntactic (Var b))::name_params
	| PutIfQueryNeedsIt -> IfQueryNeedsIt(b.sname, copy_closed_remove_syntactic (Var b))::name_params
      end
  | PatTuple(f,l) -> update_name_params_list put_var name_params l
  | PatEqual _ -> name_params

and update_name_params_list put_var name_params = function
    [] -> name_params
  | (a::l) -> update_name_params_list put_var (update_name_params put_var name_params a) l


(* Decompose tuples *)

let rec decompose_term = function
    FunApp(f,l) when f.f_cat == Tuple -> decompose_list l
  | t -> [t]

and decompose_list = function
    [] -> []
  | (a::l) -> (decompose_term a) @ (decompose_list l)

(* Test if a term is public *)

let rec is_in_public public = function
    FunApp({ f_cat = Tuple }, l) -> List.for_all (is_in_public public) l
  | t -> List.exists (equal_terms_modulo t) public

let rec remove_first_in_public public = function
    [] -> []
  | ((a::l) as l') ->
      if List.exists (equal_terms_modulo a) public then
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
	    if equal_terms_modulo a t0 then true else
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
	let hyp_terms' = 
	  match hyp_terms with
	    [] -> []
	  | (t0::l0) -> 
	      if equal_terms_modulo t0 t then
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
	if List.exists (equal_terms_modulo t) state.public then 
	  do_close state
	else
	  let public' = t :: state.public in
	  do_close { state with
                     public = public';
                     prepared_attacker_rule = remove_from_att_rules public' t state.prepared_attacker_rule }
  in
  do_close state

let rec add_public state = function
    FunApp({ f_cat = Tuple }, l) -> add_public_list state l
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
  let success =
    match prev_state.goal with
      NonInterfGoal(ProcessTest((TestUnifTag occ_goal)::occs_goal, name_params_goal, loc)) ->
	(* Note: when a clause concludes bad_pred and is a ProcessRule, then its first tag
           is TestUnifTag *)
	begin
	  match proc with
	    Test(_,_,_,_,occ) | Let(_,_,_,_,occ) | Input(_,_,_,occ) | Output(_,_,_,occ) 
	  | LetFilter(_,_,_,_,occ) | Event(_,_,occ) | Insert(_,_,occ) | Get(_,_,_,occ) ->
	      let l = List.length name_params in
	      let lg = List.length name_params_goal in
	      if (occ == occ_goal) && 
		(occs = occs_goal) &&
		(l <= lg) &&
		(List.for_all2 equal_terms_modulo (extract_name_params_noneed name_params) (skip (lg-l) name_params_goal)) then
		begin
		  loc := Some (n, List.nth prev_state.subprocess n);
		  true
		end
	      else false
	  | _ -> false
	end
    | _ -> false
  in
  if success then prev_state else
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
      let need_list = get_need_vars na.f_name in
      let nt = FunApp(na, extract_name_params na.f_name need_list name_params) in
      let n' = FunApp(add_name_for_pat nt,[]) in
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
        term_evaluation_name_params (fun t' name_params' ->
          match_pattern (fun () -> 
            let p' = copy_process p in
            let name_params'' = update_name_params PutIfQueryNeedsIt name_params' pat in 
          do_red_nointeract f { prev_state with
	    subprocess = replace_at n (p', name_params'', new_occs, facts, Nothing) prev_state.subprocess;
            comment = RLet1(n, pat, t);
            previous_state = Some prev_state } n
	      ) pat t'
           ) t new_occs facts name_params prev_state.io_rule)
      with Unify ->
        do_red_nointeract f { prev_state with
	  subprocess = replace_at n (q, name_params, new_occs, facts, Nothing) prev_state.subprocess;
          comment = RLet2(n, pat, t);
          previous_state = Some prev_state } n
      end
  | Test(t1,t2,p,q,occ) ->
      debug_print "Doing Test";
      made_forward_step := true;
      begin
	try
          auto_cleanup (fun () ->
	    let new_occs = (TestTag occ) :: occs in
            term_evaluation_name_params (fun t1' name_params' ->
	      term_evaluation_name_params (fun t2' name_params'' ->
                if equal_terms_modulo t1' t2' then
	          do_red_nointeract f 
		    { prev_state with
	              subprocess = replace_at n (p, name_params'', new_occs, facts, Nothing) prev_state.subprocess;
                      comment = RTest1(n, t1, t2);
                      previous_state = Some prev_state } n
                else
                  do_red_nointeract f 
		    { prev_state with
	              subprocess = replace_at n (q, name_params'', new_occs, facts, Nothing) prev_state.subprocess;
                      comment = RTest2(n, t1, t2);
                      previous_state = Some prev_state } n
	      ) t2 new_occs facts name_params' prev_state.io_rule
            ) t1 new_occs facts name_params prev_state.io_rule
	  )
        with Unify ->
	  f false { prev_state with
	      subprocess = remove_at n prev_state.subprocess;
              comment = RTest3(n, t1, t2);
              previous_state = Some prev_state } 
      end
  | Output(tc,t,p,occ) ->
      let success = 
	if cache_info != Nothing then 
	  false (* Was already tested and failed before; will still fail if tested again *) 
	else
	  match prev_state.goal with
	    NonInterfGoal(OutputTest(tout,loc)) ->
	      if equal_terms_modulo_eval tc tout then 
		begin
		    (* Success when output on channel tout *)
		  loc := Some (LocProcess(n, List.nth prev_state.subprocess n));
		  true
		end
	      else false
	  | NonInterfGoal(CommTest(tin,tout,loc)) ->
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
		  term_evaluation (fun tc' ->
		    let tclist = decompose_term tc' in
		    term_evaluation (fun t' ->
		      f false { prev_state with 
                                subprocess = replace_at n (Output(tc',t',p,occ), name_params, occs, facts, 
							   (OutputInfo(tclist, prev_state.public))) 
                                               prev_state.subprocess }
			) t
		      ) tc
		    )
              with Unify ->
	        f false { prev_state with
                      subprocess = remove_at n prev_state.subprocess;
                      comment = ROutput3(n, tc, t);
                      previous_state = Some prev_state } 
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
		  let prev_state' = add_public prev_state t in
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
		  term_evaluation (fun tc' ->
		    let tclist = decompose_term tc' in
		    let tclist' = remove_first_in_public prev_state.public tclist in
		    term_evaluation (fun t' ->
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
			f false { prev_state with 
                                  subprocess = replace_at n (Output(tc',t',p,occ), name_params, occs, facts, 
							   (OutputInfo(tclist', prev_state.public))) 
                                               prev_state.subprocess }
			  ) t
		      ) tc
		    )
              with Unify ->
	        f false { prev_state with
                      subprocess = remove_at n prev_state.subprocess;
                      comment = ROutput3(n, tc, t);
                      previous_state = Some prev_state } 
	end
      end
  | Event(FunApp(fs,l) as t,p,occ) ->
      debug_print "Doing Event";
      made_forward_step := true;
      let fstatus = Pievent.get_event_status fs in
      let do_begin prev_state =
	match fstatus.begin_status with
	  No ->
	    begin
	      (* Check that the argument of the event can be evaluated but otherwise ignore it *)
	      try
		auto_cleanup (fun () ->
		  term_evaluation (fun t' -> ()) t);
	     	let new_occs = (BeginEvent (occ)) :: occs in
		do_red_nointeract f { prev_state with
	                              subprocess = replace_at n (p, name_params, new_occs, facts, Nothing) prev_state.subprocess;
				      comment = RBegin1(n, t);
				      previous_state = Some prev_state } n
              with Unify ->
		f false { prev_state with 
	                subprocess = remove_at n prev_state.subprocess;
			comment = RBegin2(n, t);
			previous_state = Some prev_state }
	    end
	| NonInj | Inj ->
	    try
	    auto_cleanup (fun () ->
	      term_evaluation_name_params (fun t' name_params' ->
		  let new_occs = BeginFact :: (BeginEvent (occ)) :: occs in
		  let new_facts = (Out(t', [])) :: facts in
		  auto_cleanup (fun () ->
		    find_io_rule (fun _ ->
			do_red_nointeract f { prev_state with
	                                      subprocess = replace_at n (p, name_params', new_occs, new_facts, Nothing) prev_state.subprocess;
                                              comment = RBegin1(n, t);
				              previous_state = Some prev_state } n
				 ) new_occs new_facts name_params' [] prev_state.io_rule
			       )
					  ) t occs facts name_params prev_state.io_rule)
            with Unify ->
	      f false { prev_state with 
	                subprocess = remove_at n prev_state.subprocess;
			comment = RBegin2(n, t);
			previous_state = Some prev_state }
      in
      let do_test t' = 
	if equal_terms_modulo_eval t t' then
		  (* SUCCESS! *)
	  { prev_state with
            subprocess = replace_at n (p, name_params, occs, facts, Nothing) prev_state.subprocess;
	    comment = REnd(n,t);
	    previous_state = Some prev_state }
	else
	  do_begin prev_state
      in
      begin
	match (fstatus.end_status, prev_state.goal) with
	  (NonInj, Fact(Pred(pr,[t']))) when pr == Param.end_pred -> do_test t'
	| (Inj, Fact(Pred(pr,[_;t']))) when pr == Param.end_pred_inj -> do_test t'
	| (Inj, InjGoal(Pred(pr,[_;t']) as f,sid',nexecuted)) when pr == Param.end_pred_inj -> 
	    if equal_terms_modulo_eval t t' then
	      (* Event met once more *)
	      if nexecuted+1 = 2 then
                (* Event met twice -> SUCCESS 
		   This condition is not really sufficient: before saying that the 
		   query is false, I will also check that the matching begin events 
		   have not been executed twice *) 
	        { prev_state with
                  goal = InjGoal(f,sid',nexecuted+1);
                  subprocess = replace_at n (p, name_params, occs, facts, Nothing) prev_state.subprocess;
                  comment = REnd(n,t);
	          previous_state = Some prev_state }
	      else 
                (* Event met once, continue *)
		do_begin { prev_state with goal = InjGoal(f,sid',nexecuted+1) }
	    else
	      do_begin prev_state
	    
	| _ -> do_begin prev_state
      end
  | LetFilter(bl, Pred(pr,l), p, q, occ) ->
      debug_print "Doing LetFilter";
      made_forward_step := true;
      let letfilter_succeeds = ref false in
      begin
	try
	  let new_occs = (LetFilterTag occ) :: occs in
	  let vars_bl = List.map (fun b -> Var b) bl in
	  auto_cleanup (fun () ->
	    term_evaluation_letfilter (fun l' name_params' ->
	      let fact' = Pred(pr,l') in
	      try
 	        find_io_rule (fun terms_bl ->
		    let new_facts' = (TermsEq.copy_remove_syntactic_fact fact') :: facts in
		    List.iter2 (fun b term_b ->
		      Terms.link b (TLink term_b)) bl terms_bl;
	            let name_params'' = List.map 
			(function Always(s,t) -> Always(s,copy_closed_remove_syntactic t)
			  | IfQueryNeedsIt(s,t) -> IfQueryNeedsIt(s,copy_closed_remove_syntactic t)) name_params' in
                    let p' = auto_cleanup (fun () -> copy_process p) in
	            letfilter_succeeds := true;
	            (* Allow choosing a different result for letfilter when search fails *)
                    try 
                    do_red_nointeract f { prev_state with
	                                  subprocess = replace_at n (p', name_params'', LetFilterFact :: new_occs, new_facts', Nothing) prev_state.subprocess;
                                          comment = RLetFilter1(n, bl, Pred(pr,l));
				          previous_state = Some prev_state } n
                    with No_result -> raise Unify     
                              ) new_occs (fact' :: facts) name_params' vars_bl prev_state.io_rule
              with Unify ->
	        if !letfilter_succeeds then raise No_result else
		(* it should be ok to query the fact with names instead of patterns? *)
	        let letfilterclauses = auto_cleanup (fun () -> Rules.query_goal_std fact') in
                if letfilterclauses != [] (* fact' may be derivable from the clauses => 
                     LetFilter may succeed but not allowed by the derivation tree =>
                     consider that LetFilter blocks *) then
                  raise Unify
	        else
	          do_red_nointeract f { prev_state with 
	                    subprocess = replace_at n (q, name_params, new_occs, facts, Nothing) prev_state.subprocess;
		            comment = RLetFilter3(n, bl, Pred(pr,l));
		            previous_state = Some prev_state } n
	                                     ) l ((List.map2 (fun v v' -> Always(v.sname, v')) bl vars_bl) @ name_params)
	               )
	with Unify ->
	  f false { prev_state with 
	            subprocess = remove_at n prev_state.subprocess;
      	            comment = RLetFilter2(n, bl, Pred(pr,l));
	            previous_state = Some prev_state }
      end
  | Repl(p,occ) ->
      debug_print "Doing Repl";
      made_forward_step := true;
      let sid = Terms.new_var "sid" Param.sid_type in
      let new_occs = (ReplTag (occ,count_name_params name_params))::occs in
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
	            (* TO DO this assumes no key compromise
	               (which is coherent with the current usage of this module)
	               With key compromise, we may need two session ids. *)
                    let p' = auto_cleanup (fun () -> copy_process p) in
                    incr copy_number;
                    new_state := { !new_state with
                            subprocess = 
	                      if !Param.non_interference then
				(* With non-interference, we need to add the session id in facts *)
				add_at n (p', Always("!",sid_pat)::name_params, new_occs, (Pred(Param.get_pred (Attacker(!new_state.current_phase, Param.sid_type)), [sid_pat]))::facts, Nothing) !new_state.subprocess
			      else
				add_at n (p', Always("!",sid_pat)::name_params, new_occs, facts, Nothing) !new_state.subprocess;
                          };
                    raise Unify
           | _ -> Parsing_helper.internal_error "Repl case, reduction.ml"
	     ) new_occs facts (Always("!",Var sid)::name_params) [Var sid] prev_state.io_rule
           )
      with Unify ->
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
	  NonInterfGoal(InputTest(tin,loc)) ->
	    if equal_terms_modulo_eval tc tin then 
	      begin
		(* Success when input on channel tin *)
		loc := Some (LocProcess(n, List.nth prev_state.subprocess n));
		prev_state
	      end
	    else f false prev_state
	| NonInterfGoal(CommTest(tin,tout,loc)) ->
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
      let new_occs = (InsertTag occ) :: occs in
      begin
	try
	  auto_cleanup (fun () ->
	    term_evaluation (fun t' ->
	      made_forward_step := true;
	      do_red_nointeract f
		{ prev_state with
                  subprocess = replace_at n (p, name_params, new_occs, facts, Nothing) prev_state.subprocess;
	          tables = if List.exists (equal_terms_modulo t') prev_state.tables then 
				    prev_state.tables else t' :: prev_state.tables;
		  comment = RInsert1(n, t);
		  previous_state = Some prev_state } n
		) t
	      )
        with Unify ->
	  f false { prev_state with
                    subprocess = remove_at n prev_state.subprocess;
                    comment = RInsert2(n, t);
                    previous_state = Some prev_state } 
      end
  | _ -> f false prev_state


(* Test success when the knowledge of the attacker has changed *)

let test_success cur_state' =
  try
    match cur_state'.goal, cur_state'.current_phase with
          Fact(Pred({p_info = [Attacker(i,_)]},[t])), i' ->
	    (* Current phase is i'; if t is known by the attacker 
               in phase i', it will still be known in phase i *)
            (i' <= i) && (is_in_public cur_state'.public t)
        | Fact(Pred({p_info = [Mess(i,_)]},[tc;t])), i'  ->
	    (* Current phase is i'; if tc and t are known by the attacker 
               in phase i, they will still be known in phase i,
               so the attacker will be able to send t on tc in phase i *)
	    (i' <= i &&
	     is_in_public cur_state'.public t &&
	     is_in_public cur_state'.public tc)
	| WeakSecrGoal(l,_,_,_), _ ->
	    List.for_all (fun (t,_) ->
	      is_in_public cur_state'.public t) l
	| NonInterfGoal(NIEqTest(t1,t2)), _ ->
	    (is_in_public cur_state'.public t1) &&
	    (is_in_public cur_state'.public t2)
	| NonInterfGoal(ApplyTest(_, l)), _ ->
	    List.for_all (is_in_public cur_state'.public) l
	| NonInterfGoal(InputTest(t,loc) | OutputTest(t,loc)), _ ->
	    let r = is_in_public cur_state'.public t in
	    if r then loc := Some LocAttacker;
	    r
	| NonInterfGoal(CommTest(tin,tout,loc)), _ ->
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
	      |	_ -> false
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
	    let tclist = decompose_term tc in
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
	    (* Note that the predicate "comp" is not pred_ATTACKER and could be handled
	       similarly, but anyway it does not appear here since key compromise
	       is incompatible with attacker reconstruction. *)
	    begin
	      let t' = rev_name_subst t in
	      match t' with
		FunApp({ f_cat = Name _; f_private = false },[]) ->
		  { state with public = t' :: state.public }
	      |	_ -> 
                  (* Public contains terms, not patterns
	             -> translate the pattern into a term.
	             If the translation fails because a name is not in the table, we have to stop. *)
		  if is_in_public state.public t' then 
		    state
		  else
                    { state with 
                      public = t' :: state.public;
	              hyp_not_matched = (Pred(p,[t']))::state.hyp_not_matched }
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
	        ProcessRule (hsl,nl) -> 
		  let new_io_rule = (n, List.map (fun t -> rev_name_subst_fact t.thefact) sons,
					  hsl, rev_name_subst_list nl, rev_name_subst_fact tree.thefact)
		  in
		  { state1 with io_rule = new_io_rule::state1.io_rule }
		  (*
		  if not (List.exists (equal_io_rule new_io_rule) state1.io_rule) then
                    { state1 with io_rule = new_io_rule::state1.io_rule }
		  else
		    state1
		    *)
	      |	Apply (Func(f), {p_info = [AttackerGuess(_)]}) ->
		  (* Clauses attacker_guess_pred will be handled when looking for the goal *)
		  state1
	      | Apply (Func(f),_) when f.f_cat != Tuple -> 
		  begin
		    let (p,c) = 
		      match tree.thefact with
			Pred(p,[t]) -> (p,rev_name_subst t)
		      | _ -> Parsing_helper.internal_error "unexpected Apply clause"
		    in
		    let h = List.map (function 
			{ thefact = Pred(_,[t]) } -> rev_name_subst t
		      |	_ -> Parsing_helper.internal_error "unexpected Apply clause") sons
		    in
	            {state1 with prepared_attacker_rule = (p, decompose_list h, decompose_term c)::state1.prepared_attacker_rule}
		  end
              | Rn _ ->
                  begin
	            match tree.thefact with
                      Pred(p, [t]) ->
                        { state1 with prepared_attacker_rule = (p, [], [rev_name_subst t])::state1.prepared_attacker_rule }
                    | _ -> 
			Parsing_helper.internal_error "Rule Rn should conclude p(name)"
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

let do_res_in cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' mess_term public_status next_f =
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
  debug_print "Input on public channel (message found)";
  if mess_list' != [] then raise Unify; (* The message is not public *)
  debug_print "Ok, the message is public";
  try
    made_forward_step := true;
    auto_cleanup (fun () ->
      match_pattern (fun () -> 
	let name_params'' = update_name_params PutAlways name_params' pat in
	let p' = auto_cleanup (fun () -> copy_process p) in
	let fact' = Pred(Param.get_pred(Mess(cur_state.current_phase, Terms.get_term_type mess_term)), [tc'; mess_term]) in
	normal_state next_f false 
	  { cur_state with
            subprocess = List.rev_append seen_list ((p', name_params'', new_occs, fact' :: facts, Nothing) :: rest_subprocess);
            comment = RInput(n, tc, pat, mess_term);
            previous_state = Some cur_state } n
	  ) pat mess_term
	)
  with No_result ->
    (* Inputting the message mess_term on this input will always fail,
       even in the following of the trace *)
    current_cache_list := List.tl (!current_cache_list);
    raise Unify
   
(* Perform a (Red I/O) reduction between an input and an asynchronous output *)

let do_async_res_io cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' mess_term public_channel next_f =
  (* The real list of processes is (List.rev_append seen_list (InputProcess :: rest_subprocess)) 
     It differs from cur_state.subprocess only by the cache of input processes, so when
     looking for an output process, we can use cur_state.subprocess instead. *)
  current_cache_list := (mess_term, None) :: (!current_cache_list);
  (* Find the corresponding asynchronous output *)
  let rec find_asynchronous_output noutput = function
      [] -> raise Unify (* not found *)
    | ((Output(tc2, t2, Nil,out_occ), name_params2,occs2, facts2, cache_info2)::_) when
      (equal_terms_modulo tc2 tc') && (equal_terms_modulo t2 mess_term) ->
	noutput
    | _::rest_subprocess2 -> find_asynchronous_output (noutput+1) rest_subprocess2
  in
  let noutput = find_asynchronous_output 0 cur_state.subprocess in
  begin
    try
      made_forward_step := true;
      try
	auto_cleanup (fun () ->
	  match_pattern (fun () -> 
	    let name_params'' = update_name_params PutAlways name_params' pat in
	    let p' = auto_cleanup (fun () -> copy_process p) in
	    let fact' = Pred(Param.get_pred(Mess(cur_state.current_phase, Terms.get_term_type mess_term)), [tc'; mess_term]) in
	    let cur_state' = 
	      { (if public_channel then
		add_public cur_state mess_term else cur_state)
                with
	        subprocess = remove_at noutput
	          (List.rev_append seen_list ((p', name_params'', new_occs, fact' :: facts, Nothing) :: rest_subprocess));
	        comment = RIO(n, tc, pat, noutput, tc, mess_term);
	        previous_state = Some cur_state }
	    in
	    let ninput = if n > noutput then n-1 else n in
	    match cur_state.goal with
	      Fact(Pred({p_info = [Mess(n,_)]},[tcg;tg])) when (n == cur_state.current_phase) &&
	      (equal_terms_modulo tg mess_term) && (equal_terms_modulo tcg tc') ->
		(* SUCCESS! *)
		cur_state'
	    | _ -> normal_state next_f false cur_state' ninput
                  ) pat mess_term
	    )
      with Unify ->
	(* The pattern does not match *)
	let noutput' = if n>noutput then noutput else noutput-1 in
	let cur_state' = 
	  { (if public_channel then
	    add_public cur_state mess_term else cur_state)
            with
	    subprocess = remove_at noutput' (List.rev_append seen_list rest_subprocess);
	    comment = RIO(n, tc, pat, noutput, tc, mess_term);
	    previous_state = Some cur_state }
	in
	match cur_state.goal with
	  Fact(Pred({p_info = [Mess(n,_)]},[tcg;tg])) when (n == cur_state.current_phase) &&
	  (equal_terms_modulo tg mess_term) && (equal_terms_modulo tcg tc') ->
	    (* SUCCESS! *)
	    cur_state'
	| _ -> next_f cur_state' 
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
      [] -> raise Unify (* Not found *)
    | ((Output(tc2,t2,p2,out_occ),name_params2,occs2, facts2, cache_info2)::rest_subprocess2) when p2 != Nil ->
	begin
	  try
	    if equal_terms_modulo tc2 tc' then
	      begin
		made_forward_step := true;
		(* The i/o reduction is possible, compute the reduced state *)
		let fact = Pred(Param.get_pred(Mess(cur_state.current_phase, Terms.get_term_type t2)), [tc'; t2]) in
		try
		  auto_cleanup (fun () ->
		    match_pattern (fun () -> 
		      let name_params'' = update_name_params PutAlways name_params' pat in
		      let p' = auto_cleanup (fun () -> copy_process p) in
		      let cur_state' = 
			{ (if public_channel then
			  add_public cur_state t2 else cur_state)
		          with
			  subprocess = replace_at noutput (p2, name_params2, (OutputTag out_occ)::occs2, facts2, Nothing) 
			    (List.rev_append seen_list ((p', name_params'', new_occs, fact :: facts, Nothing) :: rest_subprocess));
			  comment = RIO(n, tc', pat, noutput, tc2, t2);
			  previous_state = Some cur_state }
		      in
		      match cur_state.goal with
			Fact(Pred({p_info = [Mess(n,_)]},[tcg;tg])) when (n == cur_state.current_phase) &&
			(equal_terms_modulo tg t2) && (equal_terms_modulo tcg tc') ->
			  (* SUCCESS! *)
			  cur_state'
		      | _ -> normal_state2 next_f false cur_state' noutput n
			    ) pat t2
		      )
	        with Unify -> (* The pattern does not match *)
		  let noutput' = if n > noutput then noutput else noutput-1 in
		  let cur_state' = 
		    { (if public_channel then
		      add_public cur_state t2 else cur_state)
                      with
                      subprocess = replace_at noutput' (p2, name_params2, occs2, facts2, Nothing) 
			(List.rev_append seen_list rest_subprocess);
		      comment = RIO2(n, tc', pat, noutput, tc2, t2);
                      previous_state = Some cur_state }
		  in
		  match cur_state.goal with
		    Fact(Pred({ p_info = [Mess(n,_)] },[tcg;tg])) when (n == cur_state.current_phase) &&
		    (equal_terms_modulo tg t2) && (equal_terms_modulo tcg tc') ->
		      (* SUCCESS! *)
		      cur_state'
		  | _ -> normal_state next_f false cur_state' noutput'
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
      if equal_terms_modulo t a then true else find_term stop_l t r

let do_res_get cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts pat t p mess_term old_tables next_f =
  (* The real list of processes is (List.rev_append seen_list (GetProcess :: rest_subprocess)) *)
  current_cache_list := mess_term :: (!current_cache_list);
  debug_print "Get";
  if not (find_term old_tables mess_term cur_state.tables) then raise Unify; (* The entry is not found *)
  debug_print "Ok, the entry is present";
  try
    made_forward_step := true;
    auto_cleanup (fun () ->
      match_pattern (fun () -> 
	let name_params'' = update_name_params PutAlways name_params' pat in
	term_evaluation_name_params (fun t' name_params''' ->
	  match t' with 
	    FunApp(f,[]) when f == Terms.true_cst ->
	      (* we check that t evaluates to true *)
	      let p' = auto_cleanup (fun () -> copy_process p) in
	      let fact' = Pred(Param.get_pred(Table(cur_state.current_phase)), [mess_term]) in
	      normal_state next_f false 
		{ cur_state with
                  subprocess = List.rev_append seen_list ((p', name_params''', new_occs, fact' :: facts, Nothing) :: rest_subprocess);
                  comment = RGet(n, pat, t, mess_term);
                  previous_state = Some cur_state } n
	  | _ -> raise Unify
		) t new_occs facts name_params'' cur_state.io_rule
	  ) pat mess_term
	)
  with No_result ->
    (* Using the entry mess_term on this input will always fail,
       even in the following of the trace *)
    current_cache_list := List.tl (!current_cache_list);
    raise Unify
   
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
		debug_print "Input on public channel (cached)";
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
		debug_print "Input on private channel (cached); trying asynchronous output";
		let current_cache_list = ref [] in
		let public_channel = (not (!Param.active_attacker)) && (tc_list' = []) in
		let rec do_l = function
		    [] -> 
		      let seen_list' = (proc ,name_params,occs, facts, 
					InputInfo(tc_list', cur_state.public, tc', name_params', new_occs, !current_cache_list)) :: seen_list in
		      begin
			debug_print "Input on private channel (cached); trying synchronous output";
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
		  let m = Reduction_helper.new_var_pat1 pat in
		  let new_occs = (InputTag occ) :: occs in
		  let fact = Pred(Param.get_pred(Mess(cur_state.current_phase, m.btype)), [tc'; Var m]) in
		  let tc_list = decompose_term tc' in
		  let tc_list' = remove_first_in_public cur_state.public tc_list in
		  if (!Param.active_attacker) && (tc_list' = []) then
		    begin
		      (* Input on a public channel, and the attacker is active: apply (Res In)  *)
		      debug_print "Input on public channel";
		      let current_cache_list = ref [] in
		      try
			find_io_rule (function
			    [mess_term] ->
			      do_res_in cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' mess_term None next_f
			  | _ -> Parsing_helper.internal_error "input case; reduction.ml"
				) new_occs (fact :: facts) name_params' [Var m] cur_state.io_rule
		      with Unify ->
			seen_list' := (proc, name_params, occs, facts, 
				       InputInfo([], [], tc', name_params', new_occs, !current_cache_list)) :: seen_list;
			raise Unify
		    end
		  else
		    begin
		      (* Input on a private channel or the attacker is passive: apply (Res I/O)
			 First try an asynchronous output, with a corresponding clause in the tree *)
		      debug_print "Input on private channel; trying asynchronous output";
		      let current_cache_list = ref [] in
		      let public_channel = (not (!Param.active_attacker)) && (tc_list' = []) in
		      try
			find_io_rule (function
			    [mess_term] ->
			      do_async_res_io cur_state seen_list rest_subprocess n current_cache_list name_params' new_occs facts tc pat p tc' mess_term public_channel next_f
			  | _ -> Parsing_helper.internal_error "input case; reduction.ml"
				) new_occs (fact :: facts) name_params' [Var m] cur_state.io_rule
                      with Unify ->
			seen_list' := (proc, name_params,occs, facts, 
				       InputInfo(tc_list', cur_state.public, tc', name_params', new_occs, !current_cache_list)) :: seen_list;
		        (* Try a synchronous output *)
			debug_print "Input on private channel; trying synchronous output";
			do_sync_res_io cur_state seen_list rest_subprocess n name_params' new_occs facts tc pat p tc' public_channel next_f
		    end
                      ) tc occs facts name_params cur_state.io_rule
		  )
	    with Unify | No_result ->
	      find_in_out next_f cur_state (n+1) (!seen_list') rest_subprocess
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
		let m = Reduction_helper.new_var_pat1 pat in
		let new_occs = (GetTag occ) :: occs in
		let fact = Pred(Param.get_pred(Table(cur_state.current_phase)), [Var m]) in
		let current_cache_list = ref [] in
		try
		  find_io_rule (function
		      [mess_term] ->
			do_res_get cur_state seen_list rest_subprocess n current_cache_list name_params new_occs facts pat t p mess_term [] next_f
		    | _ -> Parsing_helper.internal_error "get case; reduction.ml"
			) new_occs (fact :: facts) name_params [Var m] cur_state.io_rule
		with Unify ->
		  seen_list' := (proc, name_params, occs, facts, 
				 GetInfo(cur_state.tables, !current_cache_list)) :: seen_list;
		  raise Unify
		    )
	    with Unify | No_result ->
	      find_in_out next_f cur_state (n+1) (!seen_list') rest_subprocess
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

(* Build the goal for weak secrets *)

let rec analyze_weak_secr_tree_rec accu weaksecrets tree =
  match tree.desc with
    FRule(_, lbl, _, hyp) ->
      begin
	match lbl with
	  Apply(f,{ p_info = [AttackerGuess _]}) ->
	    FunApp(funsymb_from_funspec f, 
		   List.map (analyze_weak_secr_tree_rec accu weaksecrets) hyp)
	| WeakSecr ->
	    begin
	      match tree.thefact with
		Pred({ p_info = [AttackerGuess _]}, [t1;t2]) -> 
		  weaksecrets := Some (rev_name_subst t1,rev_name_subst t2);
		  rev_name_subst t2
	      |	_ -> Parsing_helper.internal_error "Unexpected WeakSecr clause in the derivation for weaksecret"
	    end
	| PhaseChange ->
	    begin
	      match tree.thefact with
		Pred({ p_info = [AttackerGuess _] }, [t1;t2]) -> 
		  let v = Terms.new_var "v" (Terms.get_term_type t1) in
		  let t1' = rev_name_subst t1 in
		  accu := (t1', v) :: (!accu);
		  Var v
	      |	_ -> Parsing_helper.internal_error "Unexpected WeakSecr clause in the derivation for weaksecret"
	    end
	| _ -> Parsing_helper.internal_error "Unexpected clause in derivation for weaksecret"
      end
  | FEquation t -> analyze_weak_secr_tree_rec accu weaksecrets t
  | FRemovedWithProof t -> analyze_weak_secr_tree_rec accu weaksecrets t
  | FHAny | FEmpty -> Parsing_helper.internal_error "Unexpected derivation for weaksecret"


let analyze_weak_secret_tree accu weaksecrets tree =
  match tree.desc with
    FRule(_, lbl, _, hyp) ->
      begin
	let l = List.map (analyze_weak_secr_tree_rec accu weaksecrets) hyp in
	match lbl, l with
	  TestApply(f, { p_info = [AttackerGuess _] }), _ ->
	    DestrTest(FunApp(funsymb_from_funspec f, l))
	| TestEq({ p_info = [AttackerGuess _] } ), [t1;t2] -> 
	    EqTest(t1,t2)
	| _ -> Parsing_helper.internal_error "Unexpected clause concluding the derivation for weaksecret"
      end
  | _ -> Parsing_helper.internal_error "Unexpected derivation for weaksecret"
	    

(* Build the goal for non-interference *)

let analyze_non_interf_tree tree =
  match tree.desc with
    FRule(_, lbl, _, hyp) ->
      begin
	match lbl, hyp with
	  ProcessRule(hyp_tags, name_params), hyp ->
	    ProcessTest(hyp_tags, rev_name_subst_list name_params, ref None)
	| TestApply(f, p), _(*testunif fact*)::hyp ->
	    ApplyTest(funsymb_from_funspec f, List.map (function 
		{ thefact = Pred(_, [t]) } -> rev_name_subst t
	      |	_ -> Parsing_helper.internal_error "Unexpected derivation for noninterf") hyp)
	| TestComm(pi,po), [{thefact = Pred(_,[tin])}; {thefact = Pred(_,[tout])}; _(* testunif fact *)] ->
	    CommTest(rev_name_subst tin, rev_name_subst tout, ref None)
	| InputSecr(p), [{thefact = Pred(_,[t])}] ->
	    InputTest(rev_name_subst t, ref None)
	| OutputSecr(p), [{thefact = Pred(_,[t])}] ->
	    OutputTest(rev_name_subst t, ref None)
	| TestEq(p), [{thefact = Pred(_,[t1])};{thefact = Pred(_,[t2])};_(* testunif fact *)] ->
	    NIEqTest(rev_name_subst t1, rev_name_subst t2)
	| _ -> Parsing_helper.internal_error "Unexpected clause concluding the derivation for noninterf"
      end
  | _ -> Parsing_helper.internal_error "Unexpected derivation for noninterf"

(* For injectivity *)


(* Copy the history 

let rec copy_tree { desc = d; thefact = f} =
   { desc = copy_tree_desc d; thefact = copy_fact2 f } 
   
and copy_tree_desc = function
   FHAny -> FHAny
 | FEmpty -> FEmpty
 | FRemovedWithProof t -> FRemovedWithProof t
 | FRule(n, descr, constra, l) -> FRule(n, copy_descr descr, List.map copy_constra2 constra, List.map copy_tree l)
 | FEquation(t) -> FEquation(copy_tree t)

and copy_descr = function
    ProcessRule(hypspec,name_params) -> 
      ProcessRule(hypspec, List.map copy_term2 name_params)
  | ProcessRule2(hypspec,name_params1,name_params2) ->
      ProcessRule2(hypspec, List.map copy_term2 name_params1, List.map copy_term2 name_params2)
  | x -> x
*)

let new_sid() =
  let cat = Name { prev_inputs = None; prev_inputs_meaning = [] } in
  { f_name = "sid_" ^ (string_of_int (Terms.new_var_name()));
    f_type = [], Param.sid_type;
    f_cat = cat;
    f_initial_cat = cat;
    f_private = false;
    f_options = 0
  }

let add_sid (v,f) l = 
  if not (List.exists (fun (v',f') -> f == f') (!l)) then l := (v,f) :: (!l)

let rec get_sid = function
    Var ({ link = TLink (FunApp(sid,[])) } as v) ->
      (v, sid)
  | Var { link = TLink t } -> get_sid t
  | t -> 
      Display.display_term t; 
      begin
      match t with
	Var v -> 
	  begin
	  print_string " Var ";
	  match v.link with
	    NoLink -> print_string " NoLink "
	  | TLink _ -> print_string " TLink "
	  | VLink _ -> print_string " VLink "
	  | TLink2 _ -> print_string " TLink2 "
	  | _ -> print_string " other link "
	  end
      |	FunApp _ -> print_string " FunApp "
      end; 
      Parsing_helper.internal_error "Constant session ids should be function applications with no arguments stored as links of variables"

let rec has_sid_term sid = function
    Var { link = TLink t } -> has_sid_term sid t
  | Var _ -> false
  | FunApp(f,l) ->
      (f == sid) || (List.exists (has_sid_term sid) l)

let find_sid_fact end_sid no_dup_begin_sids = function
    Pred(_,l) -> ()
  | Out(t,l) -> 
      if not (List.exists (fun (_,t') -> has_sid_term end_sid t') l) then
	List.iter (fun (v,t') -> 
	  if v.sname = "@sid" then add_sid (get_sid t') no_dup_begin_sids) l

let rec find_sid_tree end_sid all_sids no_dup_begin_sids t =
  find_sid_fact end_sid no_dup_begin_sids t.thefact;
  match t.desc with
    FHAny | FEmpty -> ()
  | FRemovedWithProof _ -> ()
  | FEquation t -> find_sid_tree end_sid all_sids no_dup_begin_sids t
  | FRule(_,tags,constra,tl) -> 
      List.iter (find_sid_tree end_sid all_sids no_dup_begin_sids) tl;
      match tags with
	ProcessRule (hsl,nl) -> 
	  (* find session ids in nl by looking for corresponding elements of hsl:
	     if hsl contains ReplTag(_,count_params), then the count_params-th element of nlrev is a session id. *)
	  let nlrev = List.rev nl in
	  List.iter (function
	      ReplTag(_,count_params) -> add_sid (get_sid (List.nth nlrev count_params)) all_sids
	    | _ -> ()) hsl
      |	ProcessRule2 _ -> Parsing_helper.internal_error "ProcessRule2 should not occur with injective queries"
      |	_ -> ()
	


let build_inj_state state tree =
  let (v_end_sid,end_sid) = 
    match tree.thefact with
      Pred(pr,[sid;t']) when pr == Param.end_pred_inj -> get_sid sid
    | _ -> Parsing_helper.internal_error "In inj_mode, the fact should be an injective end event"
  in
  (* Collects session ids. 
     all_sids will contain all session ids
     no_dup_begin_sids will contain the session ids of begin facts that must not be duplicated,
     that is, those whose environment does not contain the session id of the end event.
     *)
  let all_sids = ref [(v_end_sid,end_sid)] in
  let no_dup_begin_sids = ref [] in
  find_sid_tree end_sid all_sids no_dup_begin_sids tree;
(*
  print_string "Session ids: ";  Display.display_list (fun (v,f) -> Display.display_function_name f) ", " (!all_sids); print_newline();
  print_string "No dup begin session ids: "; Display.display_list (fun (v,f) -> Display.display_function_name f) ", " (!no_dup_begin_sids); print_newline();
*)
  (* We rename the session ids that are in all_sids but not in no_dup_begin_sids *)
  let no_dup_begin_sids = List.map snd (!no_dup_begin_sids) in
  let sids_to_rename = List.filter (fun (v,f) -> not (List.memq f no_dup_begin_sids)) (!all_sids) in
  List.iter (fun (v,_) -> v.link <- TLink (FunApp(new_sid(),[]))) sids_to_rename;
  (* Add the rules generated from the renamed derivation tree *)
  let state' = init_rule state tree in
  { state' with
    goal = InjGoal (rev_name_subst_fact tree.thefact, FunApp(end_sid,[]), 0) }

(* For injectivity: check that a trace really falsifies a query q 
   Currently, this test is sound but very basic: it just checks 
   that some injective "begin" event is executed once (while the "end" event 
   has been executed twice by the success condition of the trace).
   The events are counted by the root function symbol, without checking
   their arguments.
   TO DO there may be room for improvement here.
   *)

let rec count_events event_table state =
  begin
    match state.comment with
      RBegin1(_,t) | RBegin2(_,t) | REnd(_,t) ->
	begin
	  match t with
	    FunApp(f, _) -> 
	      begin
		try
		  let count = List.assq f (!event_table) in
		  incr count
		with Not_found ->
		  event_table := (f, ref 1) :: (!event_table)
	      end
	  | _ -> Parsing_helper.internal_error "Events should start with a function symbol"
	end
    | _ -> ()
  end;
  match state.previous_state with
    None -> ()
  | Some prev_state -> count_events event_table prev_state

let get_count event_table f =
  try
    !(List.assq f (!event_table))
  with Not_found ->
    0

let check_query_falsified q final_state =
  let event_table = ref [] in
  count_events event_table final_state;
  match q with
    Before(QSEvent(inj,FunApp(fend,_)),hyp) when inj == true ->
      (* Check that the "end" event is executed at least twice;
	 this should always be true by the success condition of the trace *)
      if get_count event_table fend < 2 then 
	Parsing_helper.internal_error "End event executed at most once in injective trace!";
      (* Check that in each "or" branch of the hypothesis, at least one 
         injective event is executed at most once. 
         Then the query is false *)
      List.for_all (List.exists (function 
	  QEvent(QSEvent(inj, FunApp(fbegin,_))) when inj == true -> 
	    get_count event_table fbegin < 2
	| _ -> false)) hyp
  | _ -> 
      Parsing_helper.internal_error "Unexpected injective query"

(* Main trace reconstruction function *)

let build_trace state = 
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
      (final_state, true)
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
      (final_state, false)
    end


let do_reduction inj_mode tree =
(*  Profile.start();  *)
  made_forward_step := true;
  failed_traces := 0;
  let public_init = public_build !Param.freenames in
  public_free := public_init;
  display_init_state := true;
  init_name_mapping (!Param.freenames);
  let links = ref [] in
  if inj_mode == None then
    close_tree tree
  else
    close_tree_collect_links links tree;
    (* The variable links is used to restore the links destroyed by
       rev_name_subst, only when inj_mode = Some _, so we avoid computing
       it when inj_mode = None *)
  let goal = 
    if !Param.weaksecret != None then
      let accu = ref [] in
      let weaksecrets = ref None in
      let compute_term = analyze_weak_secret_tree accu weaksecrets tree in
      match !weaksecrets with
	None -> Parsing_helper.internal_error "weak secret clause should appear"
      |	Some (w1,w2) ->
	  WeakSecrGoal(!accu, compute_term, w1, w2)
    else if !Param.non_interference then
      NonInterfGoal(analyze_non_interf_tree tree)
    else
      Fact(rev_name_subst_fact tree.thefact)
  in
  let init_state = 
    { goal = goal;
      subprocess = [(!(main_process), [],[],[],Nothing)];
      public = public_init;
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
        (* print_string ((string_of_int (List.length state.io_rule)) ^ " io rules");
           print_newline(); *)
	begin
	  match inj_mode with
	    None -> snd (build_trace state)
	  | Some q ->
	      ignore (build_trace state);
	      print_string "I am now trying to reconstruct a trace that falsifies injectivity.";
	      Display.newline();
	      (* Restore the links destroyed by rev_name_subst *)
	      List.iter (fun (v,l) -> v.link <- l) (!links);
	      let state_inj = build_inj_state state tree in
	      let (final_state, r) = build_trace state_inj in
	      (* When the trace is found, and it really falsifies the query q, return true. *)
	      if r then check_query_falsified q final_state else false
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
We recheck them after modifying the derivation tree.
I also recheck that the derivation still contradicts the security property after unification ! 
For non-interference or weak secrets, that's ok: we still have a 
derivation of "bad".
For correspondences, that may be wrong, because unification may
make arguments of some events equal, for instance. *)

(* First, get_clause_from_derivation rebuilds a Horn clause from a derivation *)

let get_clause_from_derivation tree =
  let concl = tree.thefact in
  let hyp = ref [] in
  let constra = ref [] in

  let rec rebuild_hyp tree =
    match tree.desc with
      FEmpty ->
        if not (List.exists (Termslinks.equal_facts_with_links tree.thefact) (!hyp)) then
          hyp := tree.thefact :: (!hyp)
    | FHAny | FRemovedWithProof _ -> ()
    | FEquation son -> rebuild_hyp son
    | FRule(_, _, rconstra, sons) ->
        List.iter rebuild_hyp sons;
        constra := rconstra @ (!constra)
  in
  rebuild_hyp tree;

  let (hyp', concl', constra') = 
    Terms.auto_cleanup (fun () ->
      (List.map Terms.copy_fact2 (!hyp),
       Terms.copy_fact2 concl,
       List.map Terms.copy_constra2 (!constra)))
  in
  let constra'' = 
    try 
      Terms.auto_cleanup(fun () ->
	 Rules.simplify_constra_list (concl'::hyp') constra')
    with Rules.FalseConstraint ->
      Parsing_helper.internal_error "False constraints should have been excluded by revise_tree"
  in
  let hist = Rule(-1, LblNone, hyp', concl', constra'') in
  (hyp', concl', hist, constra'')

(* Second, revise_tree is the function that checks that inequality constraints still hold and that the obtained derivation still contradicts the query *)

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
      

let revise_tree recheck tree =
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
                  Pred(p, [t']) when (match follow_link t' with Var v -> true | _ -> false) -> t.desc
		| Out _ -> t.desc (* Out facts cannot be proved anyway *)
		| _ -> 
		    (* When unification has lead to instantiating a fact that need not be proved before, try to find a proof for it. *)
	            try
                      (revise_tree_rec (t::no_loop) (find_fact t.thefact tree)).desc
                    with Not_found | Loop -> FEmpty
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
  let tree' = revise_tree_rec [] tree in
  match recheck with
    None -> tree'
  | Some recheck_fun ->
      let cl' = get_clause_from_derivation tree' in
      print_string "The clause after unifyDerivation is ";
      Display.display_rule cl';
      if Terms.auto_cleanup (fun () -> recheck_fun cl') then
	begin
          (* cl' no longer contradicts the query *)
          print_string "This clause does not correspond to an attack against the query; using the derivation before unifyDerivation.\n";
	  raise Rules.FalseConstraint
        end
      else
        begin
          print_string "This clause still contradicts the query.\n";
          tree'
        end

(* simplify_tree unifies facts with same session identifier *)

(* "first" is true when this is the first call to simplify_tree. 
   In this case, if we find no unification to do, we do not need to call
   revise_tree, since the derivation has not been modified at all

   "recheck" is either None, or Some recheck_fun, where recheck_fun is
   a function that takes a clause as argument and returns false when
   the clause contradicts the current query, true when it does not
   contradict it. When recheck_fun returns true, we should use the old
   derivation rather than the one obtained after unifyDerivation,
   because the new one does not corresponds to an attack against the
   query.
 *)

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

let rec simplify_tree first recheck next_f tree =
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

  let rec check_coherent factId (concl, hyp_spec, name_params, sons) =
    match hyp_spec with
      [] -> ()
    | h1::l1 -> 
	let factId' = (HashFactId.HypSpec h1) :: factId in
	match h1 with
          ReplTag (occ,count_params) -> 
	    (* the session identifier is part of the fact id *)
	    check_coherent ((HashFactId.Term (List.nth name_params count_params)) :: factId') 
	      (concl, l1, name_params, sons) 
	| OutputTag occ | InsertTag occ | InputPTag occ | OutputPTag occ | BeginEvent occ ->
	    if l1 == [] then
	      (* I'm reaching the conclusion *)
	      let fact_id = HashFactId.build factId' in
	      try
		let concl' = FactHashtbl.find fact_hashtbl fact_id in
		add_unif_fact concl concl'
	      with Not_found ->
		FactHashtbl.add fact_hashtbl fact_id concl
	    else
	      check_coherent factId' (concl, l1, name_params, sons)
	| LetTag occ | TestTag occ | LetFilterTag occ | TestUnifTag2 occ ->
	    check_coherent factId' (concl, l1, name_params, sons)
	| InputTag _ | GetTag _ | BeginFact | LetFilterFact -> 
	    let f = (List.hd sons).thefact in
	    let fact_id = HashFactId.build factId' in
	    begin
	      try
		let f' = FactHashtbl.find fact_hashtbl fact_id in
		add_unif_fact f f'
	      with Not_found -> 
		FactHashtbl.add fact_hashtbl fact_id f
	    end;
            check_coherent factId' (concl, l1, name_params, List.tl sons)
	| TestUnifTag _ -> 
	    check_coherent factId' (concl, l1, name_params, List.tl sons) 
  in

  let rec simplify_tree1 t =
    match t.desc with
      FRule(_, ProcessRule(hyp_spec, name_params), constra, sons) -> 
	check_coherent [] (t.thefact, List.rev hyp_spec, List.rev name_params, List.rev sons);
	List.iter simplify_tree1 sons
    | FRule(_,_,_,sons) ->
        List.iter simplify_tree1 sons
    | FEquation son -> simplify_tree1 son
    | FHAny -> 
	begin
	match t.thefact with
	  Pred({p_info = [AttackerGuess _]}, [t1;t2]) ->
	    if t1 != t2 then add_unif_term t1 t2
	| _ -> ()
	end
    | _ -> ()
  in

  simplify_tree1 tree;
(*
  let n = List.length (!coh_tuples) in
  let nf = float_of_int n in
  let bf = float_of_int (!Param.unify_derivation_bound) in
  let n_to_do = ref
      (if !Param.unify_derivation_bound == 0 then -1 else
       if nf *. (nf -. 1.) /. 2. > bf then 
	 let n_to_do = int_of_float (nf -. sqrt(nf *. nf -. 2. *. bf) +. 1.)  in
	 print_string ((string_of_int n) ^ " tuples to unify, so " ^ (string_of_float (nf *. (nf -. 1.) /. 2.)) ^ " calls to check_coherent!\n");
	 print_string ("Considering only the first " ^ (string_of_int n_to_do) ^ " tuples for speed.");
	 print_newline();
	 n_to_do
       else -1)
  in
  if (!n_to_do == -1) && (n > 1000) then
    begin
      print_string ((string_of_int n) ^ " tuples to unify, so " ^ (string_of_float (nf *. (nf -. 1.) /. 2.)) ^ " calls to check_coherent!");
      print_newline()
    end;
  let rec check_coherent_list = function
      [] -> ()
    | (tup1::rest) ->
	decr n_to_do;
	if (!n_to_do) = 0 then () else
	begin
	  List.iter (check_coherent tup1) rest;
	  check_coherent_list rest
	end
  in
  check_coherent_list (!coh_tuples);
*)
  if (!unif_to_do_left) == [] then
    if !done_unif then
      begin
	print_string "Iterating unifyDerivation.";
	print_newline();
        simplify_tree false recheck next_f tree
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
	next_f (revise_tree recheck tree)
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
	    simplify_tree false recheck next_f tree
	       ) (!unif_to_do_left) (!unif_to_do_right)
	    )
      with Unify ->
        print_string " failed.\n";
	next_f (revise_tree recheck tree)
    end

let do_reduction recheck inj_mode tree =
  let r = 
    if !Param.unify_derivation then
      begin
	(* print_string "Starting unifyDerivation.\n"; *)
	try
	  auto_cleanup (fun () -> simplify_tree true recheck (do_reduction inj_mode) tree)
	with Rules.FalseConstraint ->
	  do_reduction inj_mode tree
      end
    else
      do_reduction inj_mode tree
  in
  Terms.cleanup();
  r


