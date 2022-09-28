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
open Parsing_helper
open Types
open Pitypes

(* TO DO: improve this translation algorithm by
   making the unifications as soon as they are known.
   Pb: we have to be able to undo unifications... *)

(*
val fold_left : f:('a -> 'b -> 'a) -> init:'a -> 'b list -> 'a
        (* [List.fold_left f a [b1; ...; bn]] is
           [f (... (f (f a b1) b2) ...) bn]. *)
List.fold_left (fun accu v -> accu') accu0 vlist

*)

(* For key compromise *)
let session0 = { f_name = "session0"; 
		 f_type = [], Param.sid_type;
                 f_private = false;
		 f_options = 0;
		 f_cat = Eq [];
		 f_initial_cat = Eq []
	       }
let compromised_session = FunApp(session0, [])

let session1 = Param.session1
let comp_session_var = Terms.new_var "session" Param.sid_type

(* For non-interference *)
let testunif_pred = Param.testunif_pred
let bad_pred = Param.bad_pred

(* Returns true when event f is present in the process.
   Raises an error when event f is present several times in the same
   then/else branch, so that it could be executed several times with
   the same session identifiers *)

let rec check_uniq_ev f = function
   Nil -> false
 | Par(p,q) -> 
     let present_p = check_uniq_ev f p in
     let present_q = check_uniq_ev f q in
     if present_p && present_q then
       user_error ("Error: the event " ^ f.f_name ^ " is present several times in the same branch of a test.\nInjective agreement cannot be proved.\n");
     present_p || present_q
 | Repl (p,_) -> check_uniq_ev f p
 | Restr(a,p) -> check_uniq_ev f p
 | Test(t1,t2,p,q,_) -> (check_uniq_ev f p) || (check_uniq_ev f q)
 | Input(tc,pat,p,_) -> check_uniq_ev f p
 | Output(tc,t,p,_) -> check_uniq_ev f p
 | Let(pat,t,p,p',_) -> (check_uniq_ev f p) || (check_uniq_ev f p')
 | LetFilter(_,_,p,q,_) -> (check_uniq_ev f p) || (check_uniq_ev f q)
 | Event (FunApp(f',_),p,_) -> 
     let present_p = check_uniq_ev f p in
     if f' == f then
       begin
	 if present_p then
	   user_error ("Error: the event " ^ f.f_name ^ " is present several times in the same branch of a test.\nInjective agreement cannot be proved.\n");
	 true
       end
     else
       present_p
 | Event (_,p,_) -> 
     user_error ("Events should be function applications\n")
 | Insert(_,p,_) -> check_uniq_ev f p
 | Get(_,_,p,_) -> check_uniq_ev f p
 | Phase(n,p) ->
     check_uniq_ev f p

(* Compute in accu the list of events that are injective, so that
   they must be executed at most once for each value of the session
   identifiers *)

let rec get_uniq_ev_proc accu = function
   Nil -> ()
 | Par(p,q) -> get_uniq_ev_proc accu p; get_uniq_ev_proc accu q
 | Repl (p,_) -> get_uniq_ev_proc accu p
 | Restr(a,p) -> get_uniq_ev_proc accu p
 | Test(t1,t2,p,q,_) -> get_uniq_ev_proc accu p; get_uniq_ev_proc accu q
 | Input(tc,pat,p,_) -> get_uniq_ev_proc accu p
 | Output(tc,t,p,_) -> get_uniq_ev_proc accu p
 | Let(pat,t,p,p',_) -> get_uniq_ev_proc accu p; get_uniq_ev_proc accu p'
 | LetFilter(_,_,p,q,_) -> get_uniq_ev_proc accu p; get_uniq_ev_proc accu q
 | Event (FunApp(f,_),p,_) -> 
     let fstatus = Pievent.get_event_status f in
     if fstatus.end_status = Inj || fstatus.begin_status = Inj then
       accu := f :: (!accu);
     get_uniq_ev_proc accu p
 | Event (_,p,_) -> 
     user_error ("Events should be function applications\n")
 | Insert(_,p,_) -> get_uniq_ev_proc accu p
 | Get(_,_,p,_) -> get_uniq_ev_proc accu p
 | Phase(n,p) ->
     get_uniq_ev_proc accu p

(* Check that all injective events can be executed at most once
   for each value of the session identifiers *)

let check_uniq_ev_proc p = 
  let must_uniq_ev = ref [] in
  get_uniq_ev_proc must_uniq_ev p;
  List.iter (fun f -> ignore(check_uniq_ev f p)) (!must_uniq_ev)

(* Check that predicate calls are implementable *)

let rec get_other_vars other_vars vlist = function
    Var v -> 
      if not (List.memq v vlist) then 
	other_vars := v :: (!other_vars)
  | FunApp(f,l) ->
      List.iter (get_other_vars other_vars vlist) l

let rec is_ground bound_vars t =
  match t with
    Var v -> List.memq v bound_vars
  | FunApp(f,l) -> List.for_all (is_ground bound_vars) l

let check_constra error_message bound_vars c = 
  List.iter (function Neq(t,t') -> 
    if not (is_ground (!bound_vars) t && is_ground (!bound_vars) t') then
      begin
	error_message();
	user_error "In clauses, variables in inequalities should all be bound.\n"
      end) c

let rec binds_vars error_message bound_vars = function
    FunApp(f,l) ->
      begin
	match f.f_cat with
	  Tuple -> List.iter (binds_vars error_message bound_vars) l 
	| _ ->
	    if not (List.for_all (is_ground (!bound_vars)) l) then
	      begin
		error_message();
		user_error ("Cannot bind variables under non-data constructors ("
			    ^ f.f_name ^ ").\n")
	      end
	    (* Do not bind variables under non-data constructors *)
      end
  | Var v ->
      if not (List.memq v (!bound_vars)) then
	bound_vars := v :: (!bound_vars)
	  
let rec check_fact error_message seen_pred_calls bound_vars = function
    Pred(p, l) ->
      check_pred error_message seen_pred_calls (p, List.map (is_ground (!bound_vars)) l);
      List.iter (binds_vars error_message bound_vars) l
  | Out(_,_) -> 
      internal_error "Out fact not allowed in user clauses in pi input"

and check_pred error_message seen_pred_calls (p, ground_list) = 
  try
    let ground_list_seen = List.assq p seen_pred_calls  in
    if List.exists2 (fun g_seen g -> g_seen && (not g)) ground_list_seen ground_list then
      begin
	error_message();
	user_error ("Too many unbound vars in recursive call to predicate " ^ p.p_name ^ "\n")
      end
  with Not_found ->
    let seen_pred_calls' = (p, ground_list) :: seen_pred_calls in
    List.iter (function 
	(hyp, (Pred(p', l') as concl), constra, _) -> 
	  if p == p' then
	    let error_message' () = 
	      error_message();
	      print_string "Clause ";
	      Display.display_rule (hyp, concl, Empty concl, constra)
	    in
	    let error_message'' () =
	      error_message'();
	      print_string "Conclusion ";
	      Display.display_fact concl;
	      Display.newline()
	    in
	    let bound_vars = ref [] in
	    List.iter2 (fun t g ->
	      if g then binds_vars error_message'' bound_vars t) l' ground_list;
	    List.iter (fun f ->
	      check_fact 
		(fun () -> 
		  error_message'();
		  print_string "Hypothesis ";
		  Display.display_fact f;
		  Display.newline()
		) 
		seen_pred_calls' bound_vars f) hyp;
	    List.iter (fun f ->
	      check_constra
		(fun () ->
		  error_message'();
		  print_string "Hypothesis ";
		  Display.display_constra f;
		  Display.newline()
		)
		bound_vars f) constra;
	    List.iter (fun t -> 
	      if not (is_ground (!bound_vars) t) then
		begin
		  error_message''();
		  user_error "In the conclusion of a clause, all variables should have been bound by evaluating the hypothesis\n"
		end) l'
      |	(_, Out(_,_), _, _) ->
	  internal_error "No Out fact allowed in conclusion (check_pred)"
      ) (!Param.red_rules);
    List.iter (function 
	(Pred(p', l') as concl) -> 
	  if p == p' then
	    let error_message' () = 
	      error_message();
	      print_string "Elimtrue fact ";
	      Display.display_fact concl;
	      Display.newline()
	    in
	    let bound_vars = ref [] in
	    List.iter2 (fun t g ->
	      if g then binds_vars error_message' bound_vars t) l' ground_list;
	    List.iter (fun t -> 
	      if not (is_ground (!bound_vars) t) then
		begin
		  error_message'();
		  user_error "In a fact, all variables should have been bound\n"
		end) l'
      |	Out(_,_) ->
	  internal_error "No Out fact allowed in conclusion (check_pred)"
      ) (!Param.elim_true)

let check_first_fact vlist = function
    Pred(p,l) as f ->
      let bound_vars = ref [] in
      List.iter (get_other_vars bound_vars vlist) l;
      let error_message = fun () -> 
	print_string "Error while checking implementability of \"";
	begin
	  match vlist with
	    [] ->
	      Display.display_keyword "if"
	  | (a::restv) ->
	      Display.display_keyword "let";
	      print_string (" " ^ (Display.varname a));
	      List.iter (fun v -> print_string (", " ^ (Display.varname v))) restv;
	      print_string " ";
	      Display.display_keyword "suchthat"
	end;
	print_string " ";
	Display.display_fact f;
	print_string "\"";
	Display.newline()
      in
      List.iter (fun v -> 
	if not (List.exists (Terms.occurs_var v) l) then
	  begin
	    error_message();
	    user_error ("Variable " ^ (Display.varname v) ^ " should occur in the fact.\n") 
	  end
		 ) vlist;
      check_fact error_message [] bound_vars f
  | Out(_,_) -> 
      internal_error "No Out fact in let...suchthat"

(* Rule base *)

let nrule = ref 0
let red_rules = ref ([] : reduction list)

let add_rule hyp concl constra tags =
  red_rules := (hyp, concl, 
                Rule (!nrule, tags, hyp, concl, constra), constra)
     :: (!red_rules);
  incr nrule

type name_param_info =
    Always of string * binder * term
  | IfQueryNeedsIt of string * binder * term
(* string: variable name;
   binder: variable for the fisrt component of the environment in Out facts
   term: to put as parameter of name function symbol
*)


type transl_state = 
    { hypothesis : fact list; (* Current hypotheses of the rule *)
      constra : constraints list list; (* Current constraints of the rule *)
      unif : (term * term) list; (* Current unifications to do *)
      last_step_unif : (term * term) list; 
      (* Unifications to do for the last group of destructor applications. 
         last_step_unif will be appended to unif before emitting clauses. 
	 The separation between last_step_unif and unif is useful only 
	 for non-interference. *)
      success_conditions : constraints list list ref option;
      (* List of constraints that should be false for the evaluation
	 of destructors to succeed *)
      name_params : name_param_info list; (* List of parameters of names *)
      repl_count : int;
      (* Session identifier, to include in the parameter of 
         end events for injective agreement *)
      current_session_id : binder option;  
      is_below_begin : bool; 
      cur_phase : int;
      input_pred : predicate;
      output_pred : predicate;
      hyp_tags : hypspec list
    }

let att_fact phase t =
  Pred(Param.get_pred (Attacker(phase, Terms.get_term_type t)), [t])
  
let mess_fact phase tc tm =
  Pred(Param.get_pred (Mess(phase, Terms.get_term_type tm)), [tc;tm])
  
let table_fact phase t =
  Pred(Param.get_pred (Table(phase)), [t])

let rec count_name_params = function
    [] -> 0
  | (Always _)::l -> 1+count_name_params l
  | (IfQueryNeedsIt _)::l -> count_name_params l

let rec extract_name_params_noneed = function
    [] -> []
  | (Always(s,_,t)::l) ->
      t::(extract_name_params_noneed l)
  | (IfQueryNeedsIt(s,_,t)::l) ->
      extract_name_params_noneed l

let rec extract_name_params sf need_list = function
    [] -> 
      begin
	match need_list with
	  [] -> []
	| ((s,ext)::_) ->
	    Parsing_helper.input_error ("variable " ^ s ^ " not defined at restriction " ^ sf) ext
      end
  | (Always(s,_,t)::l) ->
      t::(extract_name_params sf (List.filter (fun (s',_) -> s' <> s) need_list) l)
  | (IfQueryNeedsIt(s,_,t)::l) ->
      if List.exists (fun (s',_) -> s' = s) need_list then
	t::(extract_name_params sf (List.filter (fun (s',_) -> s' <> s) need_list) l)
      else
	extract_name_params sf need_list l

let rec extract_name_params_meaning sf need_list = function
    [] -> 
      begin
	match need_list with
	  [] -> []
	| ((s,ext)::_) ->
	    Parsing_helper.input_error ("variable " ^ s ^ " not defined at restriction " ^ sf) ext
      end
  | (Always(s,_,_)::l) ->
      s::(extract_name_params_meaning sf (List.filter (fun (s',_) -> s' <> s) need_list) l)
  | (IfQueryNeedsIt(s,_,_)::l) ->
      if List.exists (fun (s',_) -> s' = s) need_list then
	s::(extract_name_params_meaning sf (List.filter (fun (s',_) -> s' <> s) need_list) l)
      else
	extract_name_params_meaning sf need_list l

let output_rule { hypothesis = prev_input; constra = constra; unif = unif;
		  last_step_unif = lsu;  
		  hyp_tags = hyp_tags; name_params = name_params1 } out_fact =
   let name_params = extract_name_params_noneed name_params1 in
   try
     if lsu != [] then
       Parsing_helper.internal_error "last_step_unif should have been appended to unif";
     if !Terms.current_bound_vars != [] then
       Parsing_helper.internal_error "bound vars should be cleaned up (pitransl2)";
      List.iter (fun (p1,p2) -> Terms.unify p1 p2) unif;
      let hyp = List.map Terms.copy_fact2 prev_input in
      let concl = Terms.copy_fact2 out_fact in
      let constra2 = List.map Terms.copy_constra2 constra in
      let name_params2 = List.map Terms.copy_term2 name_params in
      Terms.cleanup();
      begin
	try
	  add_rule hyp concl (Rules.simplify_constra_list (concl::hyp) constra2) 
	    (ProcessRule(hyp_tags, name_params2))
	with Rules.FalseConstraint -> ()
      end;
      if !Param.key_compromise = 2 then
	begin
	  if !Terms.current_bound_vars != [] then
	    Parsing_helper.internal_error "bound vars should be cleaned up (pitransl3)";

	  (* substitutes session1 for session0, attacker_p1 for 
	     attacker_p0 and mess_p1 for mess_p0 *)
	  let rec copy_term3 = function
	      FunApp(f,l) -> 
		FunApp((if f == session0 then session1 else f), 
		       List.map copy_term3 l)
	    | Var v -> match v.link with
		NoLink -> 
		  let r = Terms.new_var v.sname v.btype in
		  Terms.link v (VLink r);
		  Var r
	      | TLink l -> copy_term3 l
	      | VLink r -> Var r
	      | _ -> internal_error "unexpected link in copy_term3"
	  in
	  let copy_term_pair3 = fun (v,t) -> (v, copy_term3 t) in
	  let copy_fact3 = function
	      Pred(chann, t) -> 
		Pred((match chann.p_info with
		  [Attacker(0,ty)] -> Param.get_pred (Attacker(1,ty))
		| [Mess(0,ty)] -> Param.get_pred(Mess(1,ty))
		| [Table(0)] -> Param.get_pred(Table(1))
		| _ -> chann), List.map copy_term3 t)
	    | Out(t,l) -> Out(copy_term3 t, List.map copy_term_pair3 l)
	  in
	  let rec copy_constra3 c = List.map (function
	      Neq(t1,t2) -> Neq(copy_term3 t1, copy_term3 t2)) c
	  in
	  List.iter (fun (p1,p2) -> Terms.unify p1 p2) unif;
	  let hyp = List.map copy_fact3 prev_input in
	  let concl = copy_fact3 out_fact in
	  let constra3 = List.map copy_constra3 constra in
	  let name_params3 = List.map copy_term3 name_params in
	  Terms.cleanup();
	  try
	    add_rule hyp concl (Rules.simplify_constra_list (concl::hyp) constra3) 
	      (ProcessRule(hyp_tags, name_params3))
	  with Rules.FalseConstraint -> ()
	end
   with Terms.Unify -> 
      Terms.cleanup()

(* For non-interference *)

let end_destructor_group next_f occ cur_state =
  next_f { cur_state with 
	   unif = cur_state.last_step_unif @ cur_state.unif;
	   last_step_unif = [];
	   success_conditions = None };
  if cur_state.last_step_unif == [] then
    match cur_state.success_conditions with
      None -> ()
    | Some r -> r:= [] :: (!r) (* false condition: the destructor always succeeds, so the else clause is never executed *)
  else
  if (!Param.non_interference) || (cur_state.success_conditions != None) then
    begin
      (* Get all vars in cur_state.hypothesis/unif/constra *)
      let var_list = ref [] in
      List.iter (Terms.get_vars_fact var_list) cur_state.hypothesis;
      List.iter (fun (t1,t2) -> Terms.get_vars var_list t1; Terms.get_vars var_list t2) cur_state.unif;
      List.iter (List.iter (Terms.get_vars_constra var_list)) cur_state.constra;
      (* Generalize all vars not in cur_state.hypothesis/unif/constra *)
      let l1 = List.map (fun (t,_) -> Terms.generalize_vars_not_in (!var_list) t) cur_state.last_step_unif in
      let l2 = List.map (fun (_,t) -> Terms.generalize_vars_not_in (!var_list) t) cur_state.last_step_unif in
      Terms.cleanup();
      if !Param.non_interference then
	begin
	  let tuple_fun = Terms.get_tuple_fun (List.map Terms.get_term_type l1) in
	  let new_hyp = Pred(testunif_pred, [FunApp(tuple_fun, l1); FunApp(tuple_fun, l2)]) in
	  output_rule { cur_state with 
			hypothesis = new_hyp :: cur_state.hypothesis;
			hyp_tags = TestUnifTag(occ) :: cur_state.hyp_tags;
			last_step_unif = [] } (Pred(bad_pred, []))
	end;
      match cur_state.success_conditions with
	None -> ()
      | Some r -> 
	  let new_constra = List.map2 (fun t1 t2 -> Neq(t1,t2)) l1 l2 in
	  r:= new_constra :: (!r)
    end

(* Functions that modify last_step_unif, and that should
   therefore be followed by a call to end_destructor_group 

   transl_term
   transl_term_list
   transl_term_incl_destructor
   transl_term_list_incl_destructor
   transl_pat
   transl_fact

*)

(* Translate term *)

(* next_f takes a state and a pattern as parameter *)
let rec transl_term next_f cur_state = function 
    Var v -> 
      begin
	match v.link with
          TLink t -> next_f cur_state t
	| _ -> internal_error "unexpected link in transl_term"
      end
  | FunApp(f,l) ->
      match f.f_cat with
	Name n ->  
	  begin
            match n.prev_inputs with
              Some t -> next_f cur_state t
            | _ -> internal_error "unexpected prev_inputs in transl_term"
	  end
      | Tuple -> 
          transl_term_list (fun cur_state1 patlist -> 
	    next_f cur_state1 (FunApp(f, patlist))) cur_state l
      | Eq red_rules ->
          transl_term_list (fun cur_state1 patlist -> 
	    next_f cur_state1 (FunApp(f, patlist));
	    List.iter (fun red_rule ->
              let (left_list, right) = Terms.copy_red red_rule in
	      next_f { cur_state1 with last_step_unif = List.fold_left2(fun accu_unif pat left ->
                (pat,left)::accu_unif) cur_state1.last_step_unif patlist left_list } right
	      ) red_rules
	      ) cur_state l
      | Red red_rules ->
          transl_term_list (fun cur_state1 patlist -> 
	    List.iter (fun red_rule ->
              let (left_list, right) = Terms.copy_red red_rule in
	      next_f { cur_state1 with last_step_unif = List.fold_left2(fun accu_unif pat left ->
                (pat,left)::accu_unif) cur_state1.last_step_unif patlist left_list } right
	      ) red_rules
	      ) cur_state l
      | _ ->
           Parsing_helper.internal_error "function symbols of these categories should not appear in input terms"


(* next_f takes a state and a list of patterns as parameter *)
and transl_term_list next_f cur_state = function
    [] -> next_f cur_state []
  | (a::l) -> 
      transl_term (fun cur_state1 p ->
	transl_term_list (fun cur_state2 patlist -> 
	  next_f cur_state2 (p::patlist)) cur_state1 l) cur_state a

let rec check_several_types = function
    Var _ -> false
  | FunApp(f,l) ->
      (List.exists check_several_types l) || 
      (if !Param.eq_in_names then
	 (* Re-allow an old setting, which was faster on some examples *)
	 match f.f_cat with
       	   Red rules -> List.length rules > 1
	 | Eq rules -> List.length rules > 0
	 | _ -> false
      else
	 match f.f_initial_cat with
       	   Red rules -> List.length rules > 1
         | _ -> false)

(* To associate a variable to a syntax element without creating
   a fresh variable everytime. Useful for the first component of
   the environment in Out facts *)
let var_cache_term = ref ([] : (term * binder) list)
let var_cache_process = ref ([] : (process * binder) list)

let get_var_for_term a s =
  try
    List.assq a (!var_cache_term)
  with Not_found ->
    let r = Terms.new_var s (Terms.get_term_type a) in
    var_cache_term := (a, r) :: (!var_cache_term);
    r

let get_var_for_process a v =
  try
    List.assq a (!var_cache_process)
  with Not_found ->
    var_cache_process := (a, v) :: (!var_cache_process);
    v

let transl_term_incl_destructor f t cur_state =
  let may_have_several_types = check_several_types t in
  transl_term (fun cur_state1 pat1 ->
    if may_have_several_types then
      f pat1 { cur_state1 with 
                 name_params = Always("", (get_var_for_term t (if !Param.tulafale != 1 then "@destrv" else "destrv")), pat1)::cur_state1.name_params }
    else
      f pat1 cur_state1
    ) cur_state t

let transl_term_list_incl_destructor f tl cur_state =
  let may_have_several_types = List.exists check_several_types tl in
  transl_term_list (fun cur_state1 patlist ->
    if may_have_several_types then
      f patlist { cur_state1 with 
                    name_params = (List.map2 (fun t pat -> Always("", get_var_for_term t (if !Param.tulafale != 1 then "@destrv" else "destrv"), pat)) tl patlist) @ cur_state1.name_params }
    else
      f patlist cur_state1
    ) cur_state tl

(* This predicate is for Out facts before their environment is set 
   It should never occur in finally generated rules. *)
let pred_begin_tmp = { p_name = "begin_tmp"; 
		       p_type = [Param.event_type]; 
		       p_prop = 0; 
		       p_info = [] }

let occ_cst = FunApp({ f_name = "@occ_cst";
		       f_type = [], Param.any_type;
		       f_cat = Tuple;
		       f_initial_cat = Tuple;
		       f_private = false;
		       f_options = 0 }, [])

let occ_var_map = Hashtbl.create 7

let get_occ_var occ =
  try
    Hashtbl.find occ_var_map occ
  with Not_found ->
    let r = Terms.new_var ("@occ" ^ (string_of_int occ)) Param.any_type in
    Hashtbl.add occ_var_map occ r;
    r

let replace_begin_out name_params tags hyp =
   let rec make_out_fun np = match np with
      [] -> []
    | Always(_,ve,Var v)::l -> (ve, Var v) :: make_out_fun l
    | _ :: l -> make_out_fun l
   in
   let make_out = make_out_fun name_params in
   let tag_ref = ref tags in
   List.map (function 
       Pred(pred_begin_x, [FunApp(f,l) as pat_begin]) when pred_begin_x == pred_begin_tmp ->
	 let fstatus = Pievent.get_event_status f in
	 let rec find_occ = function
	     [] -> Parsing_helper.internal_error "Should find BeginFact and BeginEvent tags"
	   | BeginFact :: BeginEvent(occ) :: l -> 
	       tag_ref := l;
	       occ
	   | _ :: l -> find_occ l
	 in
	 let occ = find_occ (!tag_ref) in
	 if fstatus.begin_status = Inj then
	   (* Store the occurrence of the "begin" event in the environment, 
              to be able to find it back in piauth.ml *)
	   Out(pat_begin, make_out @ [get_occ_var occ, occ_cst] )
	 else
	   Out(pat_begin, [])
     | Pred(pred_begin_x,_)  when pred_begin_x == pred_begin_tmp -> 
         user_error ("Events should be function applications\n")
     | c -> c) hyp

(* Translate pattern *)

type put_var_type =
    PutAlways | PutIfQueryNeedsIt

let rec transl_pat put_var f pat pat' cur_state =
  match pat with
    PatVar b ->
      b.link <- TLink pat';
      f (match put_var with
	   PutAlways -> 
	     { cur_state with name_params = Always(b.sname, b, pat') :: cur_state.name_params }
         | PutIfQueryNeedsIt -> 
             { cur_state with name_params = IfQueryNeedsIt(b.sname, b, pat') :: cur_state.name_params });
      b.link <- NoLink
  | PatTuple (fsymb,patlist) ->
      let patlist' = List.map Reduction_helper.new_var_pat patlist in
      let pat2 = FunApp(fsymb, patlist') in
      transl_pat_list put_var f patlist patlist' { cur_state with last_step_unif = (pat', pat2)::cur_state.last_step_unif };
  | PatEqual t ->
      transl_term_incl_destructor (fun pat cur_state ->
	f { cur_state with last_step_unif = (pat,pat')::cur_state.last_step_unif};
	    ) t cur_state

and transl_pat_list put_var f patlist patlist' cur_state =
  match (patlist, patlist') with
    ([],[]) -> f cur_state
  | (p::pl, p'::pl') ->
      (* It is important to translate the head first, like the head is
         checked first in pisyntax.ml, because variables may be bound in the
         head and used in equality tests in the tail *)
      transl_pat put_var (transl_pat_list put_var f pl pl') p p' cur_state
  | _ -> internal_error "not same length in transl_pat_list"
      

(* Translate fact *)

let transl_fact next_fun f cur_state =
  match f with
    Out(_, _) -> Parsing_helper.internal_error "Out fact not allowed in let... suchthat"
  | Pred(p,tl) ->
      transl_term_list_incl_destructor (fun patl cur_state1 ->
	next_fun (Pred(p,patl)) cur_state1) tl cur_state 

(* Translate process *)

let rec transl_process cur_state = function
   Nil -> ()
 | Par(p,q) -> transl_process cur_state p;
               transl_process cur_state q
 | (Repl (p,occ)) as p' -> 
     let cur_state = { cur_state with repl_count = cur_state.repl_count + 1 } in
     (* Always introduce session identifiers ! *)
     let cur_state = 
       if cur_state.is_below_begin then
	 { cur_state with 
	   is_below_begin = false;
	   hypothesis = replace_begin_out cur_state.name_params cur_state.hyp_tags cur_state.hypothesis
	 }
       else
	 cur_state
     in
     let v = Terms.new_var (if !Param.tulafale != 1 then "@sid" else "sid") Param.sid_type in
     let v' = get_var_for_process p' v in 
     let count_params = count_name_params cur_state.name_params in
     begin
       if !Param.non_interference then 
	 begin
	   if (!Param.key_compromise == 0) then
	     transl_process { cur_state with 
			      hypothesis = (att_fact cur_state.cur_phase (Var v)) :: cur_state.hypothesis;
			      current_session_id = Some v;
			      name_params = Always(("!" ^ (string_of_int cur_state.repl_count)), v', Var v) :: cur_state.name_params;
			      hyp_tags = (ReplTag(occ, count_params)) :: cur_state.hyp_tags
			    } p
	   else if (!Param.key_compromise == 1) then
	     transl_process { cur_state with 
			      hypothesis = (att_fact cur_state.cur_phase (Var v)) :: (att_fact cur_state.cur_phase (Var comp_session_var)) :: cur_state.hypothesis;
			      current_session_id = Some v;
			      name_params = Always("!comp", comp_session_var, Var comp_session_var) :: 
                                 Always(("!" ^ (string_of_int cur_state.repl_count)), v', Var v) :: cur_state.name_params;
			      hyp_tags = (ReplTag(occ, count_params)) :: cur_state.hyp_tags
			    } p
	   else 
	     transl_process { cur_state with 
			      hypothesis = (att_fact cur_state.cur_phase (Var v)) :: cur_state.hypothesis;
			      current_session_id = Some v;
			      name_params = Always("!comp", v', compromised_session) :: 
                                 Always(("!" ^ (string_of_int cur_state.repl_count)), v', Var v) :: cur_state.name_params;
			      hyp_tags = (ReplTag(occ, count_params)) :: cur_state.hyp_tags
			    } p
	 end
       else
	 begin 
	   if (!Param.key_compromise == 0) then
	     transl_process { cur_state with 
			      current_session_id = Some v;
			      name_params = Always(("!" ^ (string_of_int cur_state.repl_count)), v', Var v) :: cur_state.name_params;
			      hyp_tags = (ReplTag(occ, count_params)) :: cur_state.hyp_tags
			    } p
	   else if (!Param.key_compromise == 1) then
	     transl_process { cur_state with 
			      current_session_id = Some v;
			      name_params = Always("!comp", comp_session_var, Var comp_session_var) :: 
                                 Always(("!" ^ (string_of_int cur_state.repl_count)), v', Var v) :: cur_state.name_params;
			      hyp_tags = (ReplTag(occ, count_params)) :: cur_state.hyp_tags
			    } p
	   else 
	     transl_process { cur_state with 
			      current_session_id = Some v;
			      name_params = Always("!comp", v', compromised_session) :: 
                                 Always(("!" ^ (string_of_int cur_state.repl_count)), v', Var v) :: cur_state.name_params;
			      hyp_tags = (ReplTag(occ, count_params)) :: cur_state.hyp_tags
			    } p
	 end
     end;
 | Restr(n,p) -> 
     begin
       let need_list = Reduction_helper.get_need_vars n.f_name in
       let npm = extract_name_params_meaning n.f_name need_list cur_state.name_params in
       let np = extract_name_params n.f_name need_list cur_state.name_params in
     match n.f_cat with
       Name r -> 
	 let nptype = List.map Terms.get_term_type np in
	 if fst n.f_type == Param.tmp_type then 
	   begin
	     n.f_type <- nptype, snd n.f_type;
	     r.prev_inputs_meaning <- npm
	   end
	 else if not (Terms.eq_lists (fst n.f_type) nptype) then
	   internal_error ("Name " ^ n.f_name ^ " has bad type");
         r.prev_inputs <- Some (FunApp(n, np));
         transl_process cur_state p;
         r.prev_inputs <- None
     | _ -> internal_error "A restriction should have a name as parameter"
     end
 | Test(t1,t2,p,q,occ) ->
     transl_term_incl_destructor (fun pat1 cur_state1 ->
       transl_term_incl_destructor (fun pat2 cur_state2 ->
         end_destructor_group (fun cur_state3 ->
           if !Param.non_interference then
	     output_rule { cur_state3 with 
			   hypothesis = (Pred(testunif_pred, [pat1;pat2])) :: cur_state3.hypothesis;
			   hyp_tags = TestUnifTag(occ) :: cur_state3.hyp_tags 
			 } (Pred(bad_pred, []));
           transl_process { cur_state3 with 
                            unif = (pat1,pat2) :: cur_state3.unif;
                            hyp_tags = (TestTag occ) :: cur_state3.hyp_tags } p;
	   transl_process { cur_state3 with 
                            constra = [Neq(pat1, pat2)] :: cur_state3.constra;
                            hyp_tags = (TestTag occ) :: cur_state3.hyp_tags } q
         ) occ cur_state2
       ) t2 cur_state1
     ) t1 cur_state;
 | Input(tc,pat,p,occ) ->
      let v = Reduction_helper.new_var_pat pat in
      begin
        match tc with
          FunApp({ f_cat = Name _; f_private = false },_) when !Param.active_attacker ->
	    transl_pat PutAlways (end_destructor_group (fun cur_state1 -> transl_process cur_state1 p) occ)
	      pat v { cur_state with 
		      hypothesis = (att_fact cur_state.cur_phase v) :: cur_state.hypothesis;
		      hyp_tags = (InputTag(occ)) :: cur_state.hyp_tags 
		    };
            if !Param.non_interference then
	      transl_term_incl_destructor (fun pat1 cur_state1 ->
                end_destructor_group (fun cur_state2 ->
                  output_rule { cur_state2 with
                                hyp_tags = (InputPTag(occ)) :: cur_state.hyp_tags }
		    (Pred(cur_state.input_pred, [pat1]))
                ) occ cur_state1
              ) tc cur_state
        | _ -> 
	    transl_term_incl_destructor (fun pat1 cur_state1 ->
              end_destructor_group (fun cur_state2 ->
	        transl_pat PutAlways (end_destructor_group (fun cur_state3 -> 
                  transl_process cur_state3 p) occ) pat v 
		    { cur_state2 with 
		      hypothesis = (mess_fact cur_state.cur_phase pat1 v) :: cur_state2.hypothesis;
		      hyp_tags = (InputTag(occ)) :: cur_state2.hyp_tags
		    };
	        if !Param.non_interference then
                  output_rule { cur_state2 with
                                hyp_tags = (InputPTag(occ)) :: cur_state.hyp_tags }
		    (Pred(cur_state.input_pred, [pat1]))
	      ) occ cur_state1
            ) tc cur_state
      end
 | Output(tc,t,p,occ) ->
      begin
        match tc with 
          FunApp({ f_cat = Name _; f_private = false },_) when !Param.active_attacker -> 
	    if !Param.non_interference then
	    begin
	      transl_term (fun cur_state1 patc ->
                end_destructor_group (fun cur_state2 ->
 		  output_rule { cur_state2 with
                                hyp_tags = (OutputPTag occ) :: cur_state2.hyp_tags }
		    (Pred(cur_state.output_pred, [patc]))
                ) occ cur_state1
              ) cur_state tc
	    end;
	    transl_term (fun cur_state1 pat1 ->
              end_destructor_group (fun cur_state2 ->
                output_rule { cur_state2 with 
                              hypothesis = replace_begin_out cur_state2.name_params cur_state2.hyp_tags cur_state2.hypothesis;
                              hyp_tags = (OutputTag occ) :: cur_state2.hyp_tags
			    } (att_fact cur_state.cur_phase pat1)
              ) occ cur_state1
            ) cur_state t
        | _ -> transl_term (fun cur_state1 patc ->
                 transl_term (fun cur_state2 pat1 ->
                   end_destructor_group (fun cur_state3 ->
         	     if !Param.non_interference then
                       output_rule { cur_state3 with
                                     hyp_tags = (OutputPTag occ) :: cur_state3.hyp_tags }
			  (Pred(cur_state.output_pred, [patc]));
                     output_rule { cur_state3 with 
				   hypothesis = replace_begin_out cur_state3.name_params cur_state3.hyp_tags cur_state3.hypothesis;
                                   hyp_tags = (OutputTag occ) :: cur_state2.hyp_tags
			         } (mess_fact cur_state.cur_phase patc pat1)
                   ) occ cur_state2
                 ) cur_state1 t
	       ) cur_state tc
      end;
      transl_process { cur_state with
                       hyp_tags = (OutputTag occ) :: cur_state.hyp_tags } p
 | Let(pat,t,p,p',occ) ->
     if cur_state.last_step_unif != [] then
       Parsing_helper.internal_error "last_step_unif should have been appended to unif (let)";
     let success_conditions = ref [] in
     transl_term_incl_destructor (fun pat1 cur_state1 ->
       transl_pat PutIfQueryNeedsIt (end_destructor_group (fun cur_state2 -> transl_process cur_state2 p) occ)
	 pat pat1 cur_state1
     ) t { cur_state with 
           success_conditions = Some success_conditions;
           hyp_tags = (LetTag occ) :: cur_state.hyp_tags };
     transl_process { cur_state with
                      constra = (!success_conditions) @ cur_state.constra;
                      hyp_tags = (LetTag occ) :: cur_state.hyp_tags } p'
 | LetFilter(vlist,f,p,q,occ) ->
    (* TO DO Warning! LetFilter is currently not compatible with
       non-interference! We have to generate more "test" clauses. 

       For a predicate clause:
         F1 & ... & Fn -> F
       we should add the clauses:
         testF -> testF1
         testF & F1 -> testF2
         ....
         testF & F1 ... & Fn-1 -> testFn
       where, if Fi = p(M1, ..., Mn), testFi = testp(M1, ..., Mn)

       The process let v1...vn suchthat p(M1,...,Mn) generates
         h -> testp(testM1, ..., testMn)
       where testMi is obtained from Mi by existentially quantifying 
       variables v1...vn. (???)
     *)
     if !Param.non_interference then
       user_error "Predicates are currently incompatible with non-interference.\n";
     if !Param.check_pred_calls then check_first_fact vlist f;
     let vlist' = List.map (fun v ->
       let v' = Var (Terms.new_var v.sname v.btype) in
       v.link <- TLink v';
       v') vlist in
     transl_fact (fun f1 cur_state1 ->
       end_destructor_group (fun cur_state2 ->
         transl_process { cur_state2 with 
			  hypothesis = f1 :: cur_state2.hypothesis;
			  hyp_tags = LetFilterFact :: (LetFilterTag(occ)) :: cur_state2.hyp_tags
			} p
       ) occ cur_state1
     ) f { cur_state with name_params = (List.map2 (fun v v' -> Always(v.sname, v, v')) vlist vlist') @ cur_state.name_params };
     List.iter (fun v -> v.link <- NoLink) vlist;
     transl_process { cur_state with hyp_tags = LetFilterTag(occ) :: cur_state.hyp_tags } q
 | Event(FunApp(f,l) as lendbegin, p,occ) ->
     begin
       if !Param.key_compromise == 0 then
	 ()
       else 
	 match l with
	   (Var v)::l' ->
	     if !Param.key_compromise == 1 then
	       v.link <- TLink (Var comp_session_var)
	     else
	       v.link <- TLink compromised_session
	 | _ -> internal_error "Bad event format in queries"
     end;
     let fstatus = Pievent.get_event_status f in
     begin
       match fstatus.end_status with
	 No -> ()
       | Inj ->
	   if cur_state.repl_count == 0 then
	     user_error "Error: injective events should always be under a replication. (Otherwise,\nthe injective property is a trivial consequence of the non-injective one.)\n"
	   else
	     let first_param = 
	       match cur_state.current_session_id with
		 Some v -> Var v
	       | None -> FunApp(Terms.get_tuple_fun [], [])
	     in
	     transl_term (fun cur_state1 pat1 -> 
               end_destructor_group (fun cur_state2 ->
 		 output_rule { cur_state2 with 
                               hyp_tags = (BeginEvent(occ)) :: cur_state.hyp_tags;
                               hypothesis = replace_begin_out cur_state2.name_params cur_state2.hyp_tags cur_state2.hypothesis
			     } (Pred(Param.end_pred_inj, [first_param; pat1])) 
				    ) occ cur_state1
			 ) cur_state lendbegin
       | NonInj ->
	     transl_term (fun cur_state1 pat1 -> 
               end_destructor_group (fun cur_state2 ->
		 output_rule { cur_state2 with 
                               hyp_tags = (BeginEvent(occ)) :: cur_state.hyp_tags;
                               hypothesis = replace_begin_out cur_state2.name_params cur_state2.hyp_tags cur_state2.hypothesis
			     } (Pred(Param.end_pred, [pat1]))
				    ) occ cur_state1
			 ) cur_state lendbegin
	     
     end;
     begin
       match fstatus.begin_status with
	 No -> transl_process { cur_state with hyp_tags = (BeginEvent(occ)) :: cur_state.hyp_tags } p
       | Inj | NonInj ->
	   transl_term_incl_destructor 
	     (fun pat_begin cur_state0 -> end_destructor_group 
		 (fun cur_state1 ->
		   transl_process { cur_state1 with 
				    hypothesis = Pred(pred_begin_tmp, [pat_begin]) :: cur_state1.hypothesis;
				    hyp_tags = BeginFact :: (BeginEvent(occ)) :: cur_state1.hyp_tags
				  } p
		 ) occ cur_state0
	     ) lendbegin { cur_state with is_below_begin = true }
     end
 | Event(_,_,_) -> user_error ("Events should be function applications\n")
 | Insert(t,p,occ) ->
     transl_term (fun cur_state1 pat1 ->
       end_destructor_group (fun cur_state2 ->
         output_rule { cur_state2 with 
                       hypothesis = replace_begin_out cur_state2.name_params cur_state2.hyp_tags cur_state2.hypothesis;
                       hyp_tags = (InsertTag occ) :: cur_state2.hyp_tags
                     } (table_fact cur_state.cur_phase pat1)
           ) occ cur_state1
         ) cur_state t;
      transl_process { cur_state with
                       hyp_tags = (InsertTag occ) :: cur_state.hyp_tags } p
 | Get(pat,t,p,occ) ->
     let v = Reduction_helper.new_var_pat pat in
     transl_pat PutAlways (fun cur_state1 -> 
       transl_term (fun cur_state2 patt ->
	 end_destructor_group (fun cur_state3 -> transl_process cur_state3 p) occ 
	   { cur_state2 with 
             last_step_unif = (patt, FunApp(Terms.true_cst, [])) :: cur_state2.last_step_unif }
	   ) cur_state1 t
	 ) pat v { cur_state with 
		   hypothesis = (table_fact cur_state.cur_phase v) :: cur_state.hypothesis;
		   hyp_tags = (GetTag(occ)) :: cur_state.hyp_tags 
		 }
 | Phase(n,p) ->
     transl_process { cur_state with 
                      cur_phase = n;
                      input_pred = Param.get_pred (InputP(n));
                      output_pred = Param.get_pred (OutputP(n)) } p

let rules_for_red f phase red_rule =
  let res_pred = Param.get_pred (Attacker(phase, snd f.f_type)) in
  let (hyp, concl) = Terms.copy_red red_rule in
  add_rule (List.map (att_fact phase) hyp)
    (att_fact phase concl) [] (Apply(Func(f), res_pred));
  if !Param.non_interference then
    begin
      if !Terms.current_bound_vars != [] then
	Parsing_helper.internal_error "bound vars should be cleaned up (pitransl4)";
      let hyp' = List.map (Terms.generalize_vars_not_in []) hyp in
      Terms.cleanup();
  
      let thyp = List.map Terms.get_term_type hyp in
      let tuple_fun = Terms.get_tuple_fun thyp in
      let vlist = List.map Terms.new_var_def thyp in
      add_rule 
        ((Pred(testunif_pred, [FunApp(tuple_fun, vlist); FunApp(tuple_fun, hyp')]))
	 :: List.map (att_fact phase) vlist)
	(Pred(bad_pred, []))
	[]
	(TestApply(Func(f), res_pred))
    end

let rules_for_function phase _ f =
   if not f.f_private then
     let res_pred = Param.get_pred (Attacker(phase, snd f.f_type)) in
     match f.f_cat with
       Eq red_rules -> 
	 let vars = Terms.var_gen (fst f.f_type) in
	 add_rule (List.map (att_fact phase) vars)
           (att_fact phase (FunApp(f,vars))) [] (Apply(Func(f), res_pred));
	 List.iter (rules_for_red f phase) red_rules
     | Red red_rules ->
	 List.iter (rules_for_red f phase) red_rules
     | Tuple ->
	(* For tuple constructor *)
	 let vars = Terms.var_gen (fst f.f_type) in
	 add_rule (List.map (att_fact phase) vars)
	   (att_fact phase (FunApp(f, vars))) []
	   (Apply(Func(f), res_pred));

	(* For corresponding projections *)
	 for n = 0 to (List.length (fst f.f_type))-1 do
	   let vars = Terms.var_gen (fst f.f_type) in
	   let v = List.nth vars n in
	   add_rule [att_fact phase (FunApp(f, vars))]
	     (att_fact phase v) []
	     (Apply(Proj(f,n),res_pred))
	 done
     | _ -> ()

let transl_attacker phase =
   (* The attacker can apply all functions *)
  Hashtbl.iter (rules_for_function phase) Param.fun_decls;
  Hashtbl.iter (rules_for_function phase) Terms.tuple_table;

  List.iter (fun t ->
    let att_pred = Param.get_pred (Attacker(phase,t)) in
    let mess_pred = Param.get_pred (Mess(phase,t)) in

    (* The attacker has any message sent on a channel he has *)
    let v = Terms.new_var_def t in
    let vc = Terms.new_var_def Param.channel_type in
    add_rule [Pred(mess_pred, [vc; v]); att_fact phase vc]
          (Pred(att_pred, [v])) [] (Rl(att_pred,mess_pred));

    if (!Param.active_attacker) then
      begin
      (* The attacker can send any message he has on any channel he has *)
	let v = Terms.new_var_def t in
	let vc = Terms.new_var_def Param.channel_type in
	add_rule [att_fact phase vc; Pred(att_pred, [v])]
          (Pred(mess_pred, [vc; v])) [] (Rs(att_pred, mess_pred))
      end) (if !Param.ignore_types then [Param.any_type] else !Param.all_types);

  
  if (!Param.non_interference) then
    begin
      let att_pred = Param.get_pred (Attacker(phase,Param.channel_type)) in
      let input_pred = Param.get_pred (InputP(phase)) in
      let output_pred = Param.get_pred (OutputP(phase)) in
      
      (* The attacker can do communications *)
      let vc = Terms.new_var_def Param.channel_type in
      add_rule [Pred(att_pred, [vc])] (Pred(input_pred, [vc])) [] (Ri(att_pred, input_pred));
      let vc = Terms.new_var_def Param.channel_type in
      add_rule [Pred(att_pred, [vc])] (Pred(output_pred, [vc])) [] (Ro(att_pred, output_pred));

      (* Check communications do not reveal secrets *)
      let vc = Terms.new_var_def Param.channel_type in
      let vc2 = Terms.new_var_def Param.channel_type in
      add_rule [Pred(input_pred, [vc]); 
		 Pred(output_pred, [vc2]);  
		 Pred(testunif_pred, [vc;vc2])] 
	(Pred(bad_pred, [])) [] (TestComm(input_pred, output_pred))

    end


(* Weak secrets *)

let weak_memo = Param.memo (fun t -> 
  { f_name = "@weaksecretcst"; 
    f_type = [], t;
    f_private = true;
    f_options = 0;
    f_cat = Eq [];
    f_initial_cat = Eq []
  })

let weaksecretcst t = 
  weak_memo (if !Param.ignore_types then Param.any_type else t)

let att_guess_fact t1 t2 =
  Pred(Param.get_pred (AttackerGuess(Terms.get_term_type t1)), [t1;t2])

let rules_for_red_guess f red_rules =
  List.iter (fun red1 ->
    List.iter (fun red2 ->
      let (hyp1, concl1) = Terms.copy_red red1 in
      let (hyp2, concl2) = Terms.copy_red red2 in
      add_rule (List.map2 att_guess_fact hyp1 hyp2)
	(att_guess_fact concl1 concl2) []
	(Apply(Func(f), Param.get_pred (AttackerGuess(snd f.f_type))))
	) red_rules
      ) red_rules

let rules_for_function_guess _ f =
  if not f.f_private then
    let res_pred = Param.get_pred (AttackerGuess(snd f.f_type)) in
    match f.f_cat with
      Eq red_rules -> 
	let vars1 = Terms.var_gen (fst f.f_type) in
        rules_for_red_guess f ((vars1, FunApp(f, vars1)) :: red_rules)
    | Red red_rules ->
	rules_for_red_guess f red_rules;
	List.iter (fun red ->
	  let (hyp, _) = Terms.copy_red red in
	  if !Terms.current_bound_vars != [] then
	    Parsing_helper.internal_error "bound vars should be cleaned up (pitransl6)";
	  let hyp' = List.map (Terms.generalize_vars_not_in []) hyp in
	  Terms.cleanup();
  
	  let thyp = List.map Terms.get_term_type hyp in
	  let vlist = List.map Terms.new_var_def thyp in
	  add_rule 
            (List.map2 att_guess_fact hyp vlist)
	    (Pred(Param.bad_pred, []))
	    [List.map2 (fun v t -> Neq(v,t)) vlist hyp']
	    (TestApply(Func(f), res_pred))
		  ) red_rules
    | Tuple -> 
	(* For tuple constructor *)
	let vars1 = Terms.var_gen (fst f.f_type) in
	let vars2 = Terms.var_gen (fst f.f_type) in
	add_rule (List.map2 att_guess_fact vars1 vars2)
	  (att_guess_fact (FunApp(f, vars1)) (FunApp(f, vars2))) []
	  (Apply(Func(f), res_pred));

	(* For corresponding projections *)
	for n = 0 to (List.length (fst f.f_type))-1 do
	  let vars1 = Terms.var_gen (fst f.f_type) in
	  let vars2 = Terms.var_gen (fst f.f_type) in
	  let v1 = List.nth vars1 n in
	  let v2 = List.nth vars2 n in
	  add_rule [att_guess_fact (FunApp(f, vars1)) (FunApp(f, vars2))]
	    (att_guess_fact v1 v2) []
	    (Apply(Proj(f,n),res_pred))
	done;

	let vars1 = Terms.var_gen (fst f.f_type) in
	let v = Terms.new_var_def (snd f.f_type) in
	let gvars1 = List.map (fun ty -> FunApp(Terms.new_gen_var ty,[])) (fst f.f_type) in
	add_rule [att_guess_fact (FunApp(f, vars1)) v]
	  (Pred(Param.bad_pred, [])) [[Neq(v, FunApp(f, gvars1))]] (TestApply(Proj(f,0), res_pred))
	  
    | _ -> ()	


   
(* Handle key_compromise *)

let comp_output_rule prev_input out_fact =
  if !Terms.current_bound_vars != [] then
    Parsing_helper.internal_error "bound vars should be cleaned up (pitransl5)";
  add_rule (List.map Terms.copy_fact2 prev_input)
    (Terms.copy_fact2 out_fact) [] LblComp;
  Terms.cleanup()

let comp_fact t =
  Pred(Param.get_pred (Compromise(Terms.get_term_type t)), [t])

let rec comp_transl_process = function
   Nil -> ()
 | Par(p,q) -> comp_transl_process p;
               comp_transl_process q
 | Repl (p,_) -> 
     comp_transl_process p
 | Restr(n,p) ->
     begin
       match n.f_cat with
	 Name { prev_inputs_meaning = l } ->
	   let rec build_params ml tl = 
	     match (ml, tl) with
	       [],[] -> [],[]
	     | (a::l),(ty::tyl) ->
		 let (name_params, prev_input) = build_params l tyl in
		 if a = "!comp" then
		   (compromised_session :: name_params, prev_input)
		 else
		   let v = Var (Terms.new_var a ty) in
		   (v :: name_params, (comp_fact v) :: prev_input)
	     | _ -> Parsing_helper.internal_error "bad length in comp_transl_process"
	   in
	   let (name_params, prev_input) = build_params l (fst n.f_type) in
	   comp_output_rule prev_input 
	     (comp_fact (FunApp(n, name_params)));
	   if List.exists (fun x -> x == compromised_session) name_params then
	     comp_output_rule prev_input 
	       (att_fact 0 (FunApp(n, name_params)))
       | _ -> internal_error "name expected in comp_transl_process"
     end;
     comp_transl_process p
 | Test(t1,t2,p,q,_) ->
     comp_transl_process p;
     comp_transl_process q
 | Input(tc,pat,p,_) ->
     comp_transl_process p
 | Output(tc,t,p,_) ->
     comp_transl_process p
 | Let(pat,t,p,p',_) ->
     comp_transl_process p;
     comp_transl_process p'
 | LetFilter(_,_,p,q,_) ->
     comp_transl_process p;
     comp_transl_process q
 | Event (l,p,_) -> 
     comp_transl_process p (* TO DO *)
 | Insert (_,p,_) -> 
     comp_transl_process p 
 | Get (_,_,p,_) -> 
     comp_transl_process p 
 | Phase(n,p) ->
     user_error "Phases are incompatible with key compromise.\nKey compromise is itself already a phase scenario\n"

let comp_rules_for_function _ f =
   match f.f_cat with
     Eq _ | Tuple -> 
       let vars = Terms.var_gen (fst f.f_type) in
       add_rule (List.map comp_fact vars)
         (comp_fact (FunApp(f,vars))) []
         (Apply(Func(f), Param.get_pred (Compromise(snd f.f_type))))
   | _ -> ()

(* Global translation *)

let record_eqs () =
  if TermsEq.hasEquationsToRecord() then
    begin
      TermsEq.record_eqs();
      if !Param.verbose_eq then 
	begin
          print_string "Completed destructors:";
	  Display.newline()
	end;
      Hashtbl.iter (fun _ f ->
	match f.f_cat with
	  Red red_rules -> 
	    let red_rules' = TermsEq.close_destr_eq f red_rules in
	    if !Param.verbose_eq then
	      Display.display_red f red_rules';
	    f.f_cat <- Red red_rules'
	|	_ -> ()
	      ) Param.fun_decls
    end

(* Generate data clauses for user-defined predicates
   Only for the front-end without types; for the front-end
   with types, it does not make sense since all data functions
   cannot be applied under all data predicates due to types. *)

let gen_data_clauses () =
  let output_rule_hist h =
    match History.get_rule_hist h with
      (Rule(_, t, hyp, concl, constra)) ->
	add_rule hyp concl constra t
    | _ -> Parsing_helper.internal_error "unexpected result in output_rule_hist"
  in

  let gen_fun pred f =
    output_rule_hist (Apply(Func(f), pred));
    for n = 0 to (List.length (fst f.f_type))-1 do
      output_rule_hist (Apply(Proj(f,n), pred))
    done
  in

  let tuples_rules p =
    Hashtbl.iter (fun _ f ->
      match f.f_cat with
	Tuple -> gen_fun p f
      | _ -> ()) Param.fun_decls;
    Hashtbl.iter (fun _ f -> gen_fun p f) Terms.tuple_table
  in
  
  Hashtbl.iter (fun _ p ->
    if (p.p_prop land Param.pred_TUPLE != 0) then
      begin
	if (not (!Param.typed_frontend)) || 
	   (match p.p_info with
	     [PolymPred (_,_,tl)] -> List.for_all (fun t -> t == Param.any_type) tl
	   | _ -> false)
	then 
	  tuples_rules p
	else
	  Parsing_helper.internal_error "In the typed front-end, only polymorphic predicates can be declated data"
      end
	       ) Param.pred_env

let transl p = 
  Rules.reset ();
  Reduction_helper.main_process := p;
  nrule := 0;
  red_rules := [];
  List.iter (fun (hyp1, concl1, constra1, tag1) -> 
    TermsEq.close_rule_destr_eq (fun (hyp, concl, constra) ->
      add_rule hyp concl constra tag1) (hyp1, concl1, constra1))
    (!Param.red_rules);
  List.iter (fun fact -> 
    TermsEq.close_rule_destr_eq (fun (hyp, concl, constra) ->
      Rules.add_elimtrue (!nrule, concl);
      add_rule hyp concl constra LblClause) ([], fact, []))
    (!Param.elim_true);
  (* Initialize the selection function.
     In particular, when there is a predicate
       member:x,y -> member:x,cons(z,y)
     we would like nounif member:*x,y
     It is important to initialize this very early, so that
     the simplification of the initial rules is performed with
     the good selection function. *)
  List.iter (fun r -> ignore(Selfun.selection_fun r)) (!red_rules);

  (* Check that injective events occur only once *)
  check_uniq_ev_proc p;

  for i = 0 to !Param.max_used_phase do
    transl_attacker i;
    List.iter (fun t -> 
      let att_i = Param.get_pred (Attacker(i,t)) in
      let v = Terms.new_var Param.def_var_name t in
      Selfun.add_no_unif (att_i, [FVar v]) Selfun.never_select_weight;
      if i > 0 then
	let w = Terms.new_var_def t in
	let att_im1 = Param.get_pred (Attacker(i-1,t)) in
	add_rule [Pred(att_im1, [w])] (Pred(att_i, [w])) [] PhaseChange
	  ) (if !Param.ignore_types || !Param.untyped_attacker then [Param.any_type] else !Param.all_types);
    if i > 0 then
      let tbl_i = Param.get_pred (Table(i)) in
      let tbl_im1 = Param.get_pred (Table(i-1)) in
      let w = Terms.new_var_def Param.table_type in
      add_rule [Pred(tbl_im1, [w])] (Pred(tbl_i, [w])) [] TblPhaseChange
  done;

   (* Knowing the free names and creating new names is necessary only in phase 0.
      The subsequent phases will get them by attacker_i(x) -> attacker_{i+1}(x) *)  

   (* The attacker has the public free names.
      The non-interference queries have their private flag set. *)
   List.iter (fun ch ->
      if not ch.f_private then
        add_rule [] (att_fact 0 (FunApp(ch, []))) [] Init) (!Param.freenames);

  List.iter (fun t ->
    (* Clauses for equality *)
    let v = Terms.new_var_def t in
    add_rule [] (Pred(Param.get_pred (Equal(t)), [v;v])) [] LblEq
      ) (if !Param.ignore_types then [Param.any_type] else !Param.all_types);

  List.iter (fun t ->
    (* The attacker can create new names *)
    let v = Terms.new_var_def Param.sid_type in
    let new_name_fun = Terms.new_name_fun t in
    if !Param.non_interference then
      add_rule [att_fact 0 v] (att_fact 0 (FunApp(new_name_fun, [v])))
	[] (Rn (Param.get_pred (Attacker(0, t))))
    else
      add_rule [] (att_fact 0 (FunApp(new_name_fun, [v])))
	[] (Rn (Param.get_pred (Attacker(0, t))));

    if (!Param.non_interference) then
      begin
      (* Rules that derive bad from attacker are necessary only in the last phase.
         Previous phases will get them by attacker_i(x) -> attacker_{i+1}(x) *)

	let att_pred = Param.get_pred (Attacker(!Param.max_used_phase, t)) in
	
      (* The attacker can do all equality tests on data he has *)
	let v = Terms.new_var_def t in
	let vc = Terms.new_var_def t in
	add_rule [Pred(att_pred, [vc]); Pred(att_pred, [v]); Pred(testunif_pred, [vc;v])]
          (Pred(bad_pred, [])) [] (TestEq(att_pred));

      end
	) (if !Param.ignore_types || !Param.untyped_attacker then [Param.any_type] else !Param.all_types);

  (* Weak secrets *)
  begin
    match !Param.weaksecret with
      None -> ()
    | Some w ->
	add_rule [] (att_guess_fact (FunApp(w, [])) (FunApp(weaksecretcst (snd w.f_type), []))) [] WeakSecr;

	(* rules_for_function_guess for each function, including tuples *)
	Hashtbl.iter rules_for_function_guess Param.fun_decls;
	Hashtbl.iter rules_for_function_guess Terms.tuple_table;

	Weaksecr.attrulenum :=
	   List.map (fun t -> 
	     let v = Terms.new_var_def t in
	     let att_guess = Param.get_pred (AttackerGuess(t)) in
	     let hyp = [att_fact (!Param.max_used_phase) v] in
	     let concl = Pred(att_guess, [v; v]) in
	     let r = (t, Rule(!nrule, PhaseChange, hyp, concl, [])) in
	     add_rule hyp concl [] PhaseChange;

	     let v1 = Terms.new_var_def t in
	     let v2 = Terms.new_var_def t in
	     let v3 = Terms.new_var_def t in
	     add_rule [Pred(att_guess, [v1; v2]); Pred(att_guess, [v1; v3])]
	       (Pred(Param.bad_pred, [])) [[Neq(v2,v3)]] (TestEq(att_guess));

	     let v1 = Terms.new_var_def t in
	     let v2 = Terms.new_var_def t in
	     let v3 = Terms.new_var_def t in
	     add_rule [Pred(att_guess, [v2; v1]); Pred(att_guess, [v3; v1])]
	       (Pred(Param.bad_pred, [])) [[Neq(v2,v3)]] (TestEq(att_guess));

 	     (* adjust the selection function *)
	     let v1 = Terms.new_var Param.def_var_name t in
	     let v2 = Terms.new_var Param.def_var_name t in
	(* Selfun.add_no_unif (att_guess, [FAny v1; FVar v2])
	  (Selfun.never_select_weight+30);
	Selfun.add_no_unif (att_guess, [FVar v1; FAny v2])
	  (Selfun.never_select_weight+20); *)
	     Selfun.add_no_unif (att_guess, [FVar v1; FVar v2])
	       (Selfun.never_select_weight+10);

	     r) (if !Param.ignore_types || !Param.untyped_attacker then [Param.any_type] else !Param.all_types)

  end;
  
   List.iter (fun ch -> match ch.f_cat with
                          Name r -> r.prev_inputs <- Some (FunApp(ch, []))
                        | _ -> internal_error "should be a name 1")
	(!Param.freenames);
   transl_process 
     { hypothesis = []; constra = []; unif = []; last_step_unif = [];
       success_conditions = None; name_params = []; 
       repl_count = 0; current_session_id = None;
       is_below_begin = false; cur_phase = 0; 
       input_pred = Param.get_pred (InputP(0));
       output_pred = Param.get_pred (OutputP(0));
       hyp_tags = []; 
     } p;
   List.iter (fun ch -> match ch.f_cat with
                          Name r -> r.prev_inputs <- None
                        | _ -> internal_error "should be a name 2")
        (!Param.freenames);

   if !Param.key_compromise > 0 then
     begin
       List.iter (fun t -> 
	 let v = Terms.new_var Param.def_var_name t in
	 Selfun.add_no_unif (Param.get_pred (Compromise(t)), [FVar v]) Selfun.never_select_weight
	   ) (if !Param.ignore_types || !Param.untyped_attacker then [Param.any_type] else !Param.all_types);
       comp_transl_process p;
       List.iter (fun ch ->
	 if not ch.f_private then
           add_rule [] (comp_fact (FunApp(ch, []))) [] Init) (!Param.freenames);
       Hashtbl.iter comp_rules_for_function Param.fun_decls;
       Hashtbl.iter comp_rules_for_function Terms.tuple_table
     end;

  List.iter (function 
      QFact(p,l) ->
	(* For attacker: not declarations, the not declaration is also
	   valid in previous phases, because of the implication
	   attacker_p(i):x => attacker_p(i+1):x *)
	begin
	  match p.p_info with
	    [Attacker(i,t)] ->
	      for j = 0 to i-1 do
		let att_j = Param.get_pred (Attacker(j,t)) in
		Rules.add_not(Pred(att_j,l))
	      done
	  | _ -> ()
	end;
	Rules.add_not(Pred(p,l))
    | _ -> Parsing_helper.user_error "The only allowed facts in \"not\" declarations are attacker:, mess:, and user-defined predicates."
	  ) (if !Param.typed_frontend then Pitsyntax.get_not() else Pisyntax.get_not());
  
  List.iter (function (f,n) ->
    Selfun.add_no_unif f n) (if !Param.typed_frontend then Pitsyntax.get_nounif() else Pisyntax.get_nounif());

  List.rev (!red_rules)

(* Move restrictions under inputs to make the analysis more precise *)

let rec occurs_term f = function
    Var x -> false
  | FunApp(f2,l) -> (f2 == f) || (List.exists (occurs_term f) l)

let rec occurs_pat f = function
    PatVar v -> false
  | PatTuple (_,l) -> List.exists (occurs_pat f) l
  | PatEqual t -> occurs_term f t

let occurs_fact f = function
    Pred(_,l) -> List.exists (occurs_term f) l
  | Out(t, l) -> 
      (occurs_term f t) || 
      (List.exists(fun (_,t) -> occurs_term f t) l)

let rec list_split f = function
    [] -> ([],[])
  | (a::l) ->
      let (l1,l2) = list_split f l in
      if f a then 
	(a::l1,l2)
      else
	(l1,a::l2)

let rec put_new l p = 
  match l with
    [] -> p
  | (a::l') -> Restr(a,put_new l' p)

let rec move_new accu = function
    Nil -> Nil
  | Par(p1,p2) -> put_new accu (Par(move_new [] p1, move_new [] p2))
  | Repl(p,occ) ->  put_new accu (Repl (move_new [] p,occ))
  | Restr(f, p) -> move_new (f::accu) p
  | Test(t1,t2,p1,p2,occ) -> 
      if p2 <> Nil then
	put_new accu (Test(t1, t2, move_new [] p1, move_new [] p2,occ))
      else
	let (l1,l2) = list_split (fun f -> occurs_term f t1 || occurs_term f t2) accu in
        put_new l1 (Test(t1,t2,move_new l2 p1,Nil,occ))
  | Input(t,pat,p,occ) ->
      let (l1,l2) = list_split (fun f -> occurs_term f t || occurs_pat f pat) accu in
      put_new l1 (Input(t,pat, move_new l2 p,occ))
  | Output(t1,t2,p,occ) ->
      let (l1,l2) = list_split (fun f -> occurs_term f t1 || occurs_term f t2) accu in
      put_new l1 (Output(t1,t2,move_new l2 p,occ))
  | Let(pat,t,p,p',occ) ->
      if p' <> Nil then
        put_new accu (Let(pat, t, move_new [] p, move_new [] p',occ))
      else
        let (l1,l2) = list_split (fun f -> occurs_term f t || occurs_pat f pat) accu in
        put_new l1 (Let(pat, t, move_new l2 p, Nil,occ))
  | LetFilter(vl,fact,p,q,occ) ->
      if q <> Nil then
	put_new accu (LetFilter(vl,fact,move_new [] p, move_new [] q,occ))
      else
	let (l1,l2) = list_split (fun f -> occurs_fact f fact) accu in
	put_new l1 (LetFilter(vl, fact, move_new l2 p,Nil,occ))
  | Event(t1,p,occ) ->
      let (l1,l2) = list_split (fun f -> occurs_term f t1) accu in
      put_new l1 (Event(t1, move_new l2 p, occ))
  | Insert(t1,p,occ) ->
      let (l1,l2) = list_split (fun f -> occurs_term f t1) accu in
      put_new l1 (Insert(t1, move_new l2 p, occ))
  | Get(pat,t1,p,occ) ->
      let (l1,l2) = list_split (fun f -> occurs_term f t1 || occurs_pat f pat) accu in
      put_new l1 (Get(pat, t1, move_new l2 p, occ))
  | Phase(n,p) ->
      Phase(n, move_new accu p)
      
let move_new p = move_new [] p
