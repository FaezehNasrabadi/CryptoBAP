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
open Types
open Terms
open Parsing_helper
open Display

let equationsToRecord = ref false

let equations_list = ref []
let register_equation eq =
  equationsToRecord := true;
  equations_list := eq :: (!equations_list)

let hasEquations() =
  !equations_list != []

let hasEquationsToRecord() =
  !equationsToRecord

let rec close_term_eq restwork = function
    Var x ->
      begin
	match x.link with
	  TLink t -> 
	    (* TO DO should I always recursively close links modulo equations? *)
	    close_term_eq restwork t
	| NoLink -> restwork (Var x)
	| _ -> internal_error "unexpected link in close_term_eq"
      end
  | FunApp(f,l) ->
      close_term_list_eq (fun l' -> 
	restwork (FunApp(f,l'));
	match f.f_cat with
	  Eq eqlist ->
	    List.iter (fun red ->
	      let curr_bound_vars = !current_bound_vars in
	      current_bound_vars := [];
	      let (leq', req') = copy_red red in
	      begin
		try
		  List.iter2 unify l' leq';
		  restwork req'
		with Unify -> ()
	      end;
	      cleanup();
	      current_bound_vars := curr_bound_vars
		   ) eqlist
	| _ -> ()
			 ) l

and close_term_list_eq restwork = function
    [] -> restwork []
  | (a::l) ->
      close_term_eq (fun a' ->
	close_term_list_eq (fun l' ->
	  restwork (a'::l')) l) a

let close_fact_eq restwork = function
    Pred(p,l) ->
      close_term_list_eq (fun l' -> restwork (Pred(p,l'))) l
  | Out(t,l) ->
      restwork (Out(t,l))
      (* TO DO apply equations to the "fact" part of Out facts;
	 the environment part is left unchanged 
      close_term_eq (fun t' ->
	  restwork (Out(t',l))) t *)


let rec close_fact_list_eq restwork = function
    [] -> restwork []
  | (a::l) ->
      close_fact_eq (fun a' ->
	close_fact_list_eq (fun l' ->
	  restwork (a'::l')) l) a

let close_rule_eq restwork (hyp,concl,hist,constra) =
  close_fact_list_eq (fun hyp' ->
    close_fact_eq (fun concl' ->
      let tmp_bound = !current_bound_vars in
      current_bound_vars := [];
      let hyp'' = List.map copy_fact2 hyp' in
      let concl'' = copy_fact2 concl' in
      let histref = ref hist in
      let rank = ref 0 in
      List.iter2 (fun hyp1 hyp1' ->
	if not (equal_facts hyp1 hyp1') then
	  histref := HEquation(!rank, copy_fact2 hyp1, copy_fact2 hyp1', !histref);
	incr rank) hyp hyp'; 
      let r = (hyp'', concl'', 
	       (if equal_facts concl concl' then 
		 (!histref)
	       else
		 HEquation(-1, concl'', copy_fact2 concl, !histref)), 
	       List.map copy_constra2 constra) in
      cleanup();
      restwork r;
      current_bound_vars := tmp_bound
		  ) concl) hyp


let close_term_eq restwork t =
  if hasEquations() then close_term_eq restwork t else restwork t

let close_term_list_eq restwork t =
  if hasEquations() then close_term_list_eq restwork t else restwork t

let close_fact_eq restwork t =
  if hasEquations() then close_fact_eq restwork t else restwork t

let close_fact_list_eq restwork t =
  if hasEquations() then close_fact_list_eq restwork t else restwork t

let close_rule_eq restwork t =
  if hasEquations() then close_rule_eq restwork t else restwork t


let rec close_term_destr_eq restwork = function
    Var x ->
      begin
	match x.link with
	  TLink t -> 
	    (* TO DO should I always recursively close links modulo equations? *)
	    close_term_eq restwork t
	| NoLink -> restwork (Var x)
	| _ -> internal_error "unexpected link in close_term_destr_eq"
      end
  | FunApp(f,l) ->
      close_term_destr_list_eq (fun l' -> 
	match f.f_cat with
	  Eq eqlist ->
	    restwork (FunApp(f,l'));
	    List.iter (fun red ->
	      let curr_bound_vars = !current_bound_vars in
	      current_bound_vars := [];
	      let (leq', req') = copy_red red in
	      begin
		try
		  List.iter2 unify l' leq';
		  restwork req'
		with Unify -> ()
	      end;
	      cleanup();
	      current_bound_vars := curr_bound_vars
		   ) eqlist
	| Red eqlist ->
	    List.iter (fun red ->
	      let curr_bound_vars = !current_bound_vars in
	      current_bound_vars := [];
	      let (leq', req') = copy_red red in
	      begin
		try
		  List.iter2 unify l' leq';
		  restwork req'
		with Unify -> ()
	      end;
	      cleanup();
	      current_bound_vars := curr_bound_vars
		   ) eqlist
	| _ -> 
	    restwork (FunApp(f,l'))
			 ) l

and close_term_destr_list_eq restwork = function
    [] -> restwork []
  | (a::l) ->
      close_term_destr_eq (fun a' ->
	close_term_destr_list_eq (fun l' ->
	  restwork (a'::l')) l) a

let close_fact_destr_eq restwork = function
    Pred(p,l) ->
      close_term_destr_list_eq (fun l' -> restwork (Pred(p,l'))) l
  | Out(t,l) ->
      restwork (Out(t,l))
      (* TO DO apply equations to the "fact" part of Out facts;
	 the environment part is left unchanged 
      close_term_eq (fun t' ->
	  restwork (Out(t',l))) t *)


let rec close_fact_destr_list_eq restwork = function
    [] -> restwork []
  | (a::l) ->
      close_fact_destr_eq (fun a' ->
	close_fact_destr_list_eq (fun l' ->
	  restwork (a'::l')) l) a

let close_constra1_destr_eq restwork = function
    Neq(t1,t2) ->
      close_term_destr_eq (fun t1' ->
	close_term_destr_eq (fun t2' ->
	  restwork (Neq(t1',t2'))
			    ) t2) t1

let rec close_constra_destr_eq restwork = function
    [] -> restwork []
  | (a::l) ->
      close_constra1_destr_eq (fun a' ->
	close_constra_destr_eq (fun l' ->
	  restwork (a'::l')
	    ) l) a

let rec close_constra_destr_list_eq restwork = function
    [] -> restwork []
  | (a::l) ->
      close_constra_destr_eq (fun a' ->
	close_constra_destr_list_eq (fun l' ->
	  restwork (a'::l')
	    ) l) a

let close_rule_destr_eq restwork (hyp,concl,constra) =
  close_fact_destr_list_eq (fun hyp' ->
    close_fact_destr_eq (fun concl' ->
      close_constra_destr_list_eq (fun constra' ->
	let tmp_bound = !current_bound_vars in
	current_bound_vars := [];
	let r = (List.map copy_fact2 hyp', copy_fact2 concl',
		 List.map copy_constra2 constra') in
	cleanup();
	restwork r;
	current_bound_vars := tmp_bound
				  ) constra) concl) hyp


(* Copy an equation *)

let copy_eq (leq, req) = 
  if !current_bound_vars != [] then
    Parsing_helper.internal_error "bound vars should be cleaned up (eq4)";
  let eq' = (copy_term2 leq, copy_term2 req) in
  cleanup();
  eq'

(* Swap sides of an equation *)

let swap_eq (leq, req) = (req, leq)

(* Complete the equations, to obtain all terms equal to one term 
   Store the result in the information associated with each constructor *)

let rewrite_system = ref []
let order = ref []

let rec normal_form = function
    Var v -> Var v
  | FunApp(f,l) -> 
      let t' = FunApp(f, List.map normal_form l) in
      let rec find_red = function
        [] -> t'
      | ((leq,req)::redl) ->
         try
           Terms.match_terms2 leq t';
           let r = copy_term3 req in
           Terms.cleanup();
           normal_form r
         with NoMatch ->
           Terms.cleanup();
           find_red redl
      in
      find_red (!rewrite_system)

let rec joignable_critical_pairs build_context (leq1, req1) (leq2, req2) =
  match leq2 with
    Var v -> true
  | FunApp(f,l) -> 
      (
       try
	 Terms.unify leq1 leq2;
	 let req1' = copy_term2 (build_context req1) in
	 let req2' = copy_term2 req2 in
	 Terms.cleanup();
	 let r = Terms.equal_terms (normal_form req1') (normal_form req2') in
	 (*if not r then
	   begin
	     print_string "Non-joignable critical pair:";
	     display_eq (leq1,req1);
	     print_string " and ";
	     display_eq (leq2,req2);
	     print_string ". We should have ";
	     display_eq (req1',req2');
	     print_string "\n"
	   end;*)
	 r
       with Unify ->
	 Terms.cleanup();
	 true
      )
	&&
      (
       let seen = ref [] in
       let to_see = ref l in
       List.for_all (fun x -> 
	 to_see := List.tl (!to_see);
	 let cur_seen = !seen in 
	 let cur_to_see = !to_see in
	 let r = joignable_critical_pairs (fun y -> build_context (
	   FunApp(f, List.rev_append cur_seen (y :: cur_to_see)))) 
	     (leq1, req1) (x, req2) in
	 seen := x :: (!seen);
	 r) l
      )


let rec check_confluent new_rule = function
  [] -> true
| (a::l) -> 
    (joignable_critical_pairs (fun x -> x) a new_rule) &&
    (joignable_critical_pairs (fun x -> x) new_rule a) &&
    (check_confluent new_rule l)
  

let eq_queue = Queue.new_queue()
let eq_base = ref []
let eq_count = ref 0

let rec build_rules_eq leq req f get_rule = function
   FunApp(f2,l) as t ->
      if f2 == f then
      begin
	if !current_bound_vars != [] then
	  Parsing_helper.internal_error "bound vars should be cleaned up (r2)";
        try
          unify t leq;
          get_rule req
        with Unify ->
          cleanup()
      end;
      build_rules_eq_list leq req f (fun concl_list -> get_rule (FunApp(f2,concl_list))) l
  | Var _ -> ()

and build_rules_eq_list leq req f get_rule = function
    [] -> ()
  | (a::l) -> 
      build_rules_eq leq req f (fun concl -> get_rule (concl::l)) a;
      build_rules_eq_list leq req f (fun concl_list -> get_rule (a::concl_list)) l

let rec implies_eq (leq1, req1) (leq2, req2) =
  if !current_bound_vars != [] then
    Parsing_helper.internal_error "bound vars should be cleaned up (r3)";
  try
    match_terms2 leq1 leq2;
    match_terms2 req1 req2;
    cleanup();
    true
  with NoMatch -> 
    cleanup();
    (* Try to match the equation inside a context *)
    match leq2, req2 with
      (FunApp(fl, ll), FunApp(fr, lr)) when fl == fr ->
	List.exists2 (fun leq2 req2 ->
	  implies_eq (leq1, req1) (leq2, req2)) ll lr
    | _ -> false

let add_eq (leq, req) =
  (* reduce to normal form *)
  let leq = 
    match leq with
      FunApp(f,l) -> FunApp(f, List.map normal_form l)
    | _ -> leq in
  let req = normal_form req in
  let new_eq = (leq, req) in
  (* check not a trivial equation *)
  if equal_terms leq req then () else
  (* check not x = y *)
  match (leq, req) with
    Var x, Var y when x != y -> 
      user_error "Error: The equational theory equates all terms.\nThis trivial case is not supported by the verifier.\n"
  | _ ->
  (* check not subsumed *)
  let test_impl = fun eq -> implies_eq eq new_eq in
  if (List.exists test_impl (!eq_base)) ||
     (Queue.exists eq_queue test_impl) then () else
  begin
    let test_impl = fun eq -> not(implies_eq new_eq eq) in
    eq_base := List.filter test_impl (!eq_base);
    Queue.filter eq_queue test_impl;
    Queue.add eq_queue new_eq
  end

(* Combine leq2 -> req2 followed by leq1 -> req1
   when req2 unifies with C[leq1] *)

let combine_eq_eq1 (leq1, req1) (leq2, req2) =
  match leq1 with
    Var _ -> ()
  | FunApp(f,_) -> 
      build_rules_eq leq1 req1 f (fun new_term ->
        let eq3 = (copy_term2 leq2, copy_term2 new_term) in
        cleanup();
        add_eq eq3) req2

(* Combine leq2 -> req2 followed by leq1 -> req1
   when leq1 unifies with C[req2] *)

let combine_eq_eq2 (leq1, req1) (leq2, req2) =
  match req2 with
    Var _ -> ()
  | FunApp(f,_) -> 
      build_rules_eq req2 leq2 f (fun new_term ->
        let eq3 = (copy_term2 new_term, copy_term2 req1) in
        cleanup();
        add_eq eq3) leq1

(* Close the equational theory *)

let rec complete_eq bothdir =
  match Queue.get eq_queue with
    None -> !eq_base
  | Some eq ->
      eq_base := eq :: (!eq_base);
      let eq' = copy_eq eq in
      List.iter (fun eq2 -> 
	combine_eq_eq1 eq' eq2;
	combine_eq_eq1 eq2 eq';
	if bothdir then
	  begin
	    combine_eq_eq2 eq' eq2;
	    combine_eq_eq2 eq2 eq';
	    if (!rewrite_system) != [] then (* Useful only for non-proved algo. *)
	      begin
		let eqs' = swap_eq eq' in
		let eqs2 = swap_eq eq2 in
		(* Swap eq' *)
		combine_eq_eq1 eqs' eq2;
		combine_eq_eq1 eq2 eqs';
		combine_eq_eq2 eqs' eq2;
		combine_eq_eq2 eq2 eqs';
		(* Swap eq2 *)
		combine_eq_eq1 eq' eqs2;
		combine_eq_eq1 eqs2 eq';
		combine_eq_eq2 eq' eqs2;
		combine_eq_eq2 eqs2 eq';
		(* Swap eq' and eq2 *)
		combine_eq_eq1 eqs' eqs2;
		combine_eq_eq1 eqs2 eqs';
		combine_eq_eq2 eqs' eqs2;
		combine_eq_eq2 eqs2 eqs';
	      end (* End useful only for non-proved algo. *)
	  end) (!eq_base);
      if !Param.verbose_rules then
        display_eq eq
      else
         begin
           incr eq_count;
	   if (!eq_count) mod 200 = 0 then
	     begin
	       print_string ((string_of_int (!eq_count)) ^ 
			     " equations inserted. The rule base contains " ^
			     (string_of_int (List.length (!eq_base))) ^
			     " equations. " ^
			     (string_of_int (Queue.length eq_queue)) ^
			     " equations in the queue.");
	       Display.newline()
	     end
	 end;
       complete_eq bothdir

(* Check subterm *)

let rec check_subterm t1 t2 =
  (equal_terms t1 t2) || (check_strict_subterm t1 t2)

and check_strict_subterm t1 t2 =
  match t1 with
    FunApp(_,l) -> List.exists (fun t -> check_subterm t t2) l
  | _ -> false

(* Find the rewrite system S *)

let add_rewrite ((leq, req) as r) =
  (* check that all variables on the right-hand side also occur in the
     left-hand side *)
  let var_right = ref [] in
  Terms.get_vars var_right req;
  if List.for_all (fun v -> Terms.occurs_var v leq) (!var_right) then
    begin
      (* check that the resulting system is confluent *)
      rewrite_system := r :: (!rewrite_system);
      if not (check_confluent r (!rewrite_system)) then
	begin
	  rewrite_system := List.tl (!rewrite_system);
	  false
	end
      else
	true
    end
  else
    false

let rec check_no_path f f' = 
  (f != f') && 
  (List.for_all (fun (f2,f2') -> 
    if f == f2 then check_no_path f2' f' else true) (!order))


let find_rewrite_system eq =
  let (leq, req) = copy_eq eq in
  if check_strict_subterm req leq then
    ignore (add_rewrite (leq, req))
  else
    match leq with
      FunApp(f,l) ->
	let rec find_fun_symb accu = function
	    Var _ -> accu
	  | FunApp(f2,l2) -> 
	      let accu' = if List.memq f2 accu then accu else f2::accu in
	      List.fold_left find_fun_symb accu' l2
	in
	let new_symbols = find_fun_symb [] req in
	if List.for_all (fun f2 -> check_no_path f2 f) new_symbols then 
	  if add_rewrite (leq, req) then
	    order := (List.map (fun f2 -> (f,f2)) new_symbols) @ (!order)
    | Var _ -> ()


(* Lexicographic path ordering *)

let rec add_order = function
    (FunApp(f1,l1), (FunApp(f2,l2) as t2)) when f1 == f2 ->
      List.iter (fun t1 -> add_order (t1,t2)) l1;
      List.iter2 (fun t1 t2 -> add_order  (t1,t2)) l1 l2
  | (FunApp(f1,l1), t2) when occurs_f f1 t2 ->
      (* 
      Useful for finding a good ordering for Delaune-ex3.prv, but then
      the generation of the rewrite rules corresponding to the equations
      does not terminate anyway, so it's not that useful.
      begin
	match t2 with
	  FunApp(f2,_) ->
	    if check_no_path f2 f1 then
	      order := (f1,f2) :: (!order)
	| _ -> ()
      end; *)
      List.iter (fun t1 -> add_order (t1,t2)) l1
  | (FunApp(f1,l1), t2) ->
      let rec find_fun_symb accu = function
	  Var _ -> accu
	| FunApp(f2,l2) -> 
	    let accu' = if List.memq f2 accu then accu else f2::accu in
	    List.fold_left find_fun_symb accu' l2
      in
      let new_symbols = find_fun_symb [] t2 in
      if List.for_all (fun f2 -> check_no_path f2 f1) new_symbols then 
	order := (List.map (fun f2 -> (f1,f2)) new_symbols) @ (!order)
  | _ -> ()

let rec greater_lpo t1 t2 = match (t1,t2) with
  (Var v1, _) -> false
| (t1, Var v2) -> occurs_var v2 t1
| (FunApp(f1,l1), FunApp(f2,l2)) ->
    (List.exists (fun t1' -> greater_lpo t1' t2) l1) ||
    ((f1 != f2) && (not (check_no_path f1 f2)) && 
     (List.for_all (greater_lpo t1) l2)) ||
    ((f1 == f2) && (List.for_all (greater_lpo t1) l2) &&
     (greater_lpo_lex l1 l2))

and greater_lpo_lex l1 l2 = match (l1,l2) with
  ([], []) -> false
| (t1::l1',t2::l2') ->
    (greater_lpo t1 t2) ||
    ((equal_terms t1 t2) && (greater_lpo_lex l1' l2'))
| _ -> Parsing_helper.internal_error "Different length in greater_lpo_lex"

(* Build block of equations disjoint from others *)

let rec get_fun_symb flist = function
    Var v -> ()
  | FunApp(f,l) -> 
      if not (List.mem f (!flist)) then flist := f :: (!flist);
      List.iter (get_fun_symb flist) l

let rec unionlist l1 = function
    [] -> l1
  | (a::l) -> 
      if List.memq a l1 then 
	unionlist l1 l
      else
	a::(unionlist l1 l)

let buildblocks eqlist =
  let blocks = ref [] in
  List.iter (fun eq ->
    let flist = ref [] in
    get_fun_symb flist (fst eq);
    get_fun_symb flist (snd eq);
    let tmpblocks = !blocks in
    let cur_block = ref ((!flist),[eq]) in
    blocks := [];
    List.iter (fun (bfunsymb, beq) ->
      if List.exists (fun f1 -> List.memq f1 (!flist)) bfunsymb then
	(* Block has common function symbol with cur_block
           -> merge them *)
	cur_block := (unionlist bfunsymb (fst (!cur_block)), 
		      beq @ (snd (!cur_block)))
      else
	(* Block has no common function symbol with cur_block
           -> leave it as it is *)
	blocks := (bfunsymb, beq) :: (!blocks)
      ) tmpblocks;
    blocks := (!cur_block) :: (!blocks);
    ) eqlist;
  List.map snd (!blocks)

(* Check block convergent *)

exception Nontermination of equation
exception Nonconfluent of equation * equation

let check_convergent block = 
  (* Check termination *) 
  List.iter (fun ((leq, req) as eq) -> if not (greater_lpo leq req) then 
    raise (Nontermination eq)) block;
  (* Check confluence *)
  rewrite_system := block;
  List.iter (fun r1 ->
    let r1 = copy_eq r1 in
    List.iter (fun r2 ->
      if not (joignable_critical_pairs (fun x -> x) r1 r2) then
	begin
	  rewrite_system := [];
	  raise (Nonconfluent(r1,r2))
	end) block
	) block;
  rewrite_system := []

(* Check block linear *)

let rec is_linear_term vlist = function
    Var v -> 
      if List.memq v (!vlist) then false else 
      begin
	vlist := v :: (!vlist); 
	true
      end
  | FunApp(_,l) ->
      List.for_all (is_linear_term vlist) l

let is_linear block =
  List.for_all (fun (leq, req) ->
    (is_linear_term (ref []) leq) && (is_linear_term (ref []) req)) block


(* Transforms equations into "equational destructors" *)

let record_eqs () =
  if hasEquationsToRecord() then
  begin
   equationsToRecord := false;

   if !Param.eqtreatment = Param.ConvLin then
   begin
    (*print_string "Building order...";
    Display.newline();*)
    List.iter add_order (!equations_list);
    (*print_string "Building blocks...";
    Display.newline();*)
    let blocks = buildblocks (!equations_list) in
    (*print_string "Separating convergent/linear...";
    Display.newline();*)
    let convergent_part = ref [] in
    let linear_part = ref [] in
    List.iter (fun block ->
      try 
	check_convergent block;
        convergent_part := block @ (!convergent_part)
      with
	(Nontermination _ | Nonconfluent _) as e ->
	  if is_linear block then
            linear_part := block @ (!linear_part)
	  else
            begin
              print_string "Error: Cannot handle the following equations:\n";
              List.iter display_eq block;
	      print_string "This block of equations is not linear and could not be proved convergent.\n";
	      begin
		match e with
		  Nontermination eq -> 
		    print_string "(I could not prove that\n";
		    display_eq eq;
		    print_string "is decreasing in a lexicographic path ordering.)\n"
		| Nonconfluent(eq1,eq2) ->
		    print_string "(The system is not confluent because of a critical pair between\n";
		    display_eq eq1;
		    print_string "and\n";
		    display_eq eq2;
		    print_string ".)\n"
		| _ -> Parsing_helper.internal_error "TermsEq: added to avoid warning for non-exhaustive pattern-matching"
	      end;
              Parsing_helper.user_error "These equations cannot be handled.\n"
        end
       ) blocks;

    if !Param.verbose_eq then
      begin
        print_string "Linear part:";
	Display.newline();
        List.iter display_eq (!linear_part)
      end;
    List.iter (fun eq -> 
       add_eq eq; 
       add_eq (swap_eq eq)) (!linear_part);
    print_string "Completing equations...";
    Display.newline();
    let resulting_equations_linear = complete_eq true in
    eq_base := [];
    if !Param.verbose_eq then
      begin
        print_string "Completed equations:\n";
        List.iter display_eq resulting_equations_linear
      end;

    if !Param.verbose_eq then
      begin
        print_string "Convergent part:";
	Display.newline();
       List.iter display_eq (!convergent_part)
      end;
    rewrite_system := !convergent_part;
    List.iter add_eq (!convergent_part);
    print_string "Completing equations...";
    Display.newline();
    let resulting_equations_convergent = complete_eq false in
    if !Param.verbose_eq then
      begin
        print_string "Completed equations:\n";
        List.iter display_eq resulting_equations_convergent
      end;
    
    let resulting_equations = resulting_equations_linear @ resulting_equations_convergent in
    (* record the equations in each constructor *)
    List.iter (function
      (FunApp(f, l), req) -> 
        begin
          match f.f_cat with
            Eq leq -> f.f_cat <- Eq ((l, req) :: leq)
          | _ -> user_error "Does not support equations on non-constructors\n"
        end
    | _ -> ()) resulting_equations

   end
   else
   begin
    (* Old, non-proved treatment of equations.
       Kept just in case it is useful... *)
    List.iter find_rewrite_system (!equations_list);
    if !Param.verbose_eq then
      begin
        print_string "Rewriting system:";
	Display.newline();
        List.iter display_eq (!rewrite_system)
      end;

    List.iter (fun eq -> add_eq eq;
                         add_eq (swap_eq eq)) (!equations_list);
    print_string "Completing equations...";
    Display.newline();
    let resulting_equations = complete_eq true in
    (* record the equations in each constructor *)
    if !Param.verbose_eq then
      print_string "Completed equations:\n";
    List.iter (function
      (FunApp(f, l), req) as eq -> 
        begin
          if !Param.verbose_eq then display_eq eq;
          match f.f_cat with
            Eq leq -> f.f_cat <- Eq ((l, req) :: leq)
          | _ -> user_error "Does not support equations on non-constructors\n"
        end
    | _ -> ()) resulting_equations

   end
  end


(* Close destructor reductions under equations *)

let close_destr_eq f l =
  let results = ref [] in
  List.iter (fun (leq, req) ->
    close_term_list_eq (function
	[] -> internal_error "should not be empty"
      | (req'::leq') ->
	  let curr_bound_vars = !current_bound_vars in
	  current_bound_vars := [];
	  let (leq1,req1) = (List.map copy_term2 leq', copy_term2 req') in
	  cleanup();
	  if (List.exists (fun (leq2,req2) -> 
	    implies_eq (FunApp(f, leq2), req2) (FunApp(f, leq1), req1)) (!results)) then () else
	  results := (leq1,req1) :: List.filter (fun (leq2,req2) -> 
	    not(implies_eq (FunApp(f, leq1), req1) (FunApp(f, leq2), req2))) (!results);
	  current_bound_vars := curr_bound_vars) (req::leq)
  ) l;
  !results

(* Closure of terms modulo the equational theory.
   First calls restwork with one possible equal term.
   When restwork raises Unify, calls it again with another possible
   equal term, and so on. *)

let rec close_term_eq_exc restwork = function
    Var x ->
      begin
        match x.link with
          TLink t -> close_term_eq_exc restwork t
        | NoLink -> restwork (Var x)
        | _ -> internal_error "unexpected link in close_term_eq_exc"
      end
  | FunApp(f,l) ->
      close_term_list_eq_exc (fun l' -> 
	let curr_bound_vars = !current_bound_vars in
	current_bound_vars := [];
	try
          restwork (FunApp(f,l'));
	  cleanup();
	  current_bound_vars := curr_bound_vars
	with Unify ->
	  cleanup();
	  current_bound_vars := curr_bound_vars;
          match f.f_cat with
            Eq eqlist ->
	      let rec reweqlist = function
		  (leq, req) :: lrew ->
		    let curr_bound_vars = !current_bound_vars in
		    current_bound_vars := [];
		    let leq' = List.map copy_term leq in
		    let req' = copy_term req in
		    cleanup();
		    begin
                      try
			List.iter2 unify l' leq';
			restwork req';
			cleanup();
			current_bound_vars := curr_bound_vars
                      with Unify -> 
			(* Try another rewriting when Unify is raised *)
			cleanup();
			current_bound_vars := curr_bound_vars;
			reweqlist lrew
		    end
		| [] -> raise Unify
	      in
              reweqlist eqlist
          | _ -> raise Unify
                ) l

and close_term_list_eq_exc restwork = function
    [] -> restwork []
  | (a::l) ->
      close_term_eq_exc (fun a' ->
        close_term_list_eq_exc (fun l' ->
          restwork (a'::l')) l) a


(*

let unify_modulo restwork t1 t2 =
  close_term_eq_exc (fun t1' ->
    close_term_eq_exc (fun t2' ->
      Terms.unify t1' t2';
      restwork ()) t2) t1

let rec unify_modulo_list restwork l1 l2 = 
  match (l1, l2) with
    [], [] -> restwork ()
  | (a1::l1'), (a2::l2') ->
      unify_modulo (fun () -> unify_modulo_list restwork l1' l2') a1 a2
  | _ -> internal_error "Lists should have same length in unify_modulo_list"

let remove_syntactic = copy_term2
let remove_syntactic_fact f = f
let remove_syntactic_constra c = c

*)

(* Unification modulo the equational theory *)

(* Equivalent of copy_term, but replaces function symbols with
   syntactic ones *)

let syntactic_table = Hashtbl.create 7

let get_syntactic f =
  try
    Hashtbl.find syntactic_table f
  with Not_found ->
    let f' = { f_name = f.f_name;
               f_type = f.f_type;
               f_cat = Syntactic f;
               f_initial_cat = Syntactic f;
               f_private = f.f_private;
	       f_options = f.f_options } in
    Hashtbl.add syntactic_table f f';
    f'

let rec put_syntactic = function
 | FunApp(f,l) -> FunApp(get_syntactic f, List.map put_syntactic l)
 | Var v -> match v.link with
      NoLink -> 
        let r = { vname = v.vname;
		  sname = v.sname;
		  btype = v.btype;
                  link = NoLink } in
        link v (VLink r);
        Var r
   | VLink l -> Var l
   | _ -> internal_error "Unexpected link in put_syntactic"


(* Equivalent of copy_term2, but replaces syntactic function symbols
   with their non-syntactic equivalents *)

let non_syntactic f = 
  match f.f_cat  with 
    Syntactic f' -> f'
  | _ -> f

let rec copy_remove_syntactic = function
 | FunApp(f,l) -> FunApp(non_syntactic f, List.map copy_remove_syntactic l)
 | Var v -> match v.link with
      NoLink -> 
        let r = new_var v.sname v.btype in
        link v (VLink r);
        Var r
   | TLink l -> copy_remove_syntactic l
   | VLink r -> Var r
   | _ -> internal_error "unexpected link in copy_remove_syntactic"

let copy_remove_syntactic_pair = fun (v,t) -> (v, copy_remove_syntactic t)

let copy_remove_syntactic_fact = function
    Pred(chann, t) -> Pred(chann, List.map copy_remove_syntactic t)
  | Out(t,l) -> Out(copy_remove_syntactic t, List.map copy_remove_syntactic_pair l)

let rec copy_remove_syntactic_constra c = List.map (function
    Neq(t1,t2) -> Neq(copy_remove_syntactic t1, copy_remove_syntactic t2)) c

(* Remove syntactic function symbols without copying *)

let rec remove_syntactic_term = function
 | FunApp(f,l) -> FunApp(non_syntactic f, List.map remove_syntactic_term l)
 | Var v -> match v.link with
      NoLink -> Var v
    | TLink l -> remove_syntactic_term l
    | _ -> internal_error "unexpected link in remove_syntactic_term"

let remove_syntactic_pair = fun (v,t) -> (v, remove_syntactic_term t)

let remove_syntactic_fact = function
    Pred(chann, t) -> Pred(chann, List.map remove_syntactic_term t)
  | Out(t,l) -> Out(remove_syntactic_term t, List.map remove_syntactic_pair l)

let rec remove_syntactic_constra c = List.map (function
    Neq(t1,t2) -> Neq(remove_syntactic_term t1, remove_syntactic_term t2)) c


(* Unification modulo itself *)

let rec close_term_eq_synt restwork = function
    Var x ->
      begin
        match x.link with
          TLink t -> close_term_eq_synt restwork t
        | NoLink -> restwork (Var x)
        | _ -> internal_error "unexpected link in close_term_eq_synt"
      end
  | FunApp(f,l) ->
      let curr_bound_vars = !current_bound_vars in
      current_bound_vars := [];
      try
        let res = restwork (FunApp(f,l)) in
        cleanup();
        current_bound_vars := curr_bound_vars;
	res
      with 
	Unify ->
          cleanup();
          current_bound_vars := curr_bound_vars;
          close_term_list_eq_synt (fun l' -> 
          match f.f_cat with
            Eq eqlist ->
	      let rec reweqlist = function
		  (leq, req) :: lrew ->
		    let curr_bound_vars = !current_bound_vars in
		    current_bound_vars := [];
		    let leq' = List.map put_syntactic leq in
		    let req' = put_syntactic req in
		    cleanup();
		    begin
                      try
			let res = unify_modulo_list (fun () -> restwork req')  l' leq' in
			cleanup();
			current_bound_vars := curr_bound_vars;
			res
                      with 
			Unify -> 
			  (* Try another rewriting when Unify is raised *)
			  cleanup();
			  current_bound_vars := curr_bound_vars;
			  reweqlist lrew
		      | x ->
			  cleanup();
			  current_bound_vars := curr_bound_vars;
			  raise x
		    end
		| [] -> raise Unify
	      in
              reweqlist eqlist
          | _ -> raise Unify
                ) l
      | x ->
          cleanup();
          current_bound_vars := curr_bound_vars;
	  raise x

and close_term_list_eq_synt restwork = function
    [] -> restwork []
  | (a::l) ->
      close_term_eq_synt (fun a' ->
        close_term_list_eq_synt (fun l' ->
          restwork (a'::l')) l) a

and unify_modulo restwork t1 t2 =
  close_term_eq_synt (fun t1 ->
    close_term_eq_synt (fun t2 ->
     match (t1,t2) with
       (Var v, Var v') when v == v' -> restwork ()
     | (Var v, _) -> 
       begin
          match v.link with
             NoLink ->
	       begin
		 match t2 with
		   Var {link = TLink t2'} -> unify_modulo restwork t1 t2'
		 | _ ->
		     occur_check v t2;
		     link v (TLink t2);
                     restwork ()
	       end
           | TLink t1' -> unify_modulo restwork t1' t2
           | _ -> internal_error "Unexpected link in unify 1"
       end
     | (_, Var v) ->
       begin
          match v.link with
             NoLink -> 
	       occur_check v t1;
	       link v (TLink t1);
               restwork ()
           | TLink t2' -> unify_modulo restwork t1 t2'
           | _ -> internal_error "Unexpected link in unify 2"
       end
     | (FunApp(f1, l1), FunApp(f2,l2)) ->
        if (non_syntactic f1) != (non_syntactic f2) then raise Unify;
        unify_modulo_list restwork l1 l2) t2) t1

and unify_modulo_list restwork l1 l2 = 
  match (l1, l2) with
    [], [] -> restwork ()
  | (a1::l1'), (a2::l2') ->
      unify_modulo (fun () -> unify_modulo_list restwork l1' l2') a1 a2
  | _ -> internal_error "Lists should have same length in unify_modulo_list"

let rec get_list l1 l2 = match (l1,l2) with
  [],[] -> []
| ((v1,t1)::l1'),((v2,t2)::l2') ->
    let l' = get_list l1' l2' in
    (* Unification of environments ignores variables that do not match.
       When needed, the result of the unification should be an
       environment that contains only the common variables *)
    if v1 == v2 then t1 :: l' else l'
| _ -> internal_error "Lists should have same length in get_list"

let unify_modulo_env restwork l1 l2 =
    let len1 = List.length l1 in
    let len2 = List.length l2 in
    if len2 < len1 then 
      begin
	let l1 = Terms.skip (len1-len2) l1 in
        unify_modulo_list restwork (get_list l1 l2) (get_list l2 l1) 
      end
    else
      begin
	let l2 = Terms.skip (len2-len1) l2 in
        unify_modulo_list restwork (get_list l1 l2) (get_list l2 l1) 
      end

(* Simplifies a term using the equations *)

exception Reduces

let simp_eq t =
  if not (!Param.simpeq_remove) then
    normal_form t
  else
    let rec find_red_term = function
	Var v -> ()
      | (FunApp(f,l)) as t -> 
	  List.iter find_red_term l;
	  let rec find_red = function
              [] -> ()
	    | ((leq,req)::redl) ->
		try
		  Terms.match_terms2 leq t;
		  (*let r = copy_term3 req in*)
		  Terms.cleanup();
		  raise Reduces
		with NoMatch ->
		  Terms.cleanup();
		  find_red redl
	  in
	  find_red (!rewrite_system)
    in
    find_red_term t;
    t

(*
let simp_eq t =
  print_string "Simplifying ";
  Display.display_term t;
  print_string " into ";
  let r = simp_eq t in
  Display.display_term r;
  Display.newline();
  r
*)  
