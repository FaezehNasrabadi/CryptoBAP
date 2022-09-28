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
open Terms

type query_res = True | False | DontKnow

let display_res = function
    True -> print_string " is true."
  | False -> print_string " is false."
  | DontKnow -> print_string " cannot be proved."
    
let supplemental_info = ref None

(* Display a clause and possibly a corresponding trace
   When inj_mode = Some q, try to reconstruct a trace that falsifies injectivity
   When inj_mode = None, just try to reconstruct a trace corresponding 
   to the derivation of the clause cl.
   Returns true when a trace has definitely been found.
 *)

let display_clause_trace detail recheck inj_mode cl =
  print_string "goal reachable: ";
  Display.display_rule cl;
  (* TulaFale expects a derivation after "goal reachable" *)
  if (detail || (!Param.tulafale = 1)) then
    begin
      let new_tree = History.build_history cl in
      Display.newline();
      if (!Param.reconstruct_trace) && (!Param.reconstruct_derivation) &&
	(!Param.key_compromise == 0)
      then 
	begin
	  Reduction.do_reduction recheck inj_mode new_tree
	end
      else 
	begin
	  cleanup();
	  false
	end
    end
  else
    false

(* Display a query *)

let display_query = Display.display_corresp_query

(* Link variables of a fact to new constants, of type "SpecVar" *)

let rec put_constants = function
    Var v ->
      begin
	match v.link with
	  TLink t -> ()
	| NoLink -> 
	    v.link <- TLink (FunApp({ f_name = Display.varname v;
				      f_type = [], v.btype;
				      f_cat = SpecVar v;
				      f_initial_cat = SpecVar v;
				      f_private = false;
				      f_options = 0 }, []));
	    current_bound_vars := v :: (!current_bound_vars)
	| _ -> internal_error "unexpected link in put_constants"
      end
  | FunApp(f,l) -> List.iter put_constants l

let put_constants_fact = function
    Pred(p,l) -> List.iter put_constants l
  | Out(t,tl) -> 
      put_constants t;
      List.iter (fun (_,t') -> put_constants t') tl

let put_constants_constra = List.iter (function
    Neq(t1,t2) -> put_constants t1; put_constants t2) 

let put_constants_rule (hyp, concl, hist, constra) =
  List.iter put_constants_fact hyp;
  put_constants_fact concl;
  List.iter put_constants_constra constra


(* Copy a query, following links inside variables *)

let copy_event = function
    QSEvent(b, t) -> QSEvent(b, TermsEq.copy_remove_syntactic t)
  | QFact(p, tl) -> QFact(p, List.map TermsEq.copy_remove_syntactic tl)
  | QNeq(t1,t2) -> QNeq(TermsEq.copy_remove_syntactic t1, TermsEq.copy_remove_syntactic t2)
  | QEq(t1,t2) -> QEq(TermsEq.copy_remove_syntactic t1, TermsEq.copy_remove_syntactic t2)

let rec copy_query = function
    Before(e, hll) -> Before(copy_event e, List.map (List.map copy_hypelem) hll)

and copy_hypelem = function
    QEvent e -> QEvent(copy_event e)
  | NestedQuery q -> NestedQuery (copy_query q)

(* Check that all elements of SpecVar that occur in the "begin" part
   of a query also occur in its "end" part *)

let occurs_event sv = function
    QSEvent(b,t) -> Terms.occurs_f sv t
  | QFact(p,tl) -> List.exists (Terms.occurs_f sv) tl
  | QNeq(t1,t2) -> (Terms.occurs_f sv t1) || (Terms.occurs_f sv t2)
  | QEq(t1,t2) -> (Terms.occurs_f sv t1) || (Terms.occurs_f sv t2)

let rec occurs_in_e e = function
    Var v -> true
  | FunApp({ f_cat = SpecVar _ } as sv, []) -> occurs_event sv e
  | FunApp(f,l) -> List.for_all (occurs_in_e e) l

let occurs_in_e_event e = function
    QSEvent(b,t) -> occurs_in_e e t
  | QFact(p,tl) -> List.for_all (occurs_in_e e) tl
  | QNeq(t1,t2) -> (occurs_in_e e t1) && (occurs_in_e e t2)
  | QEq(t1,t2) -> (occurs_in_e e t1) && (occurs_in_e e t2)

let rec occurs_in_e_query e = function
    Before(e',hll) -> (occurs_in_e_event e e') 
	&& (List.for_all (List.for_all (occurs_in_e_hypelem e)) hll)

and occurs_in_e_hypelem e = function
    QEvent e' -> occurs_in_e_event e e'
  | NestedQuery q -> occurs_in_e_query e q

let check_query_vars = function
    Before(e,hll) -> List.for_all (List.for_all (occurs_in_e_hypelem e)) hll

(* Replace constants "SpecVar" of a query with the corresponding variables *)

let rec specvar_to_var = function
    Var v -> Var v
  | FunApp({ f_cat = SpecVar v} ,[]) ->
      Var v
  | FunApp(f,l) -> FunApp(f, List.map specvar_to_var l)

let specvar_to_var_event = function
    QSEvent(b,t) -> QSEvent(b, specvar_to_var t)
  | QFact(p, tl) -> QFact(p, List.map specvar_to_var tl)
  | QNeq(t1,t2) -> QNeq(specvar_to_var t1, specvar_to_var t2)
  | QEq(t1,t2) -> QEq(specvar_to_var t1, specvar_to_var t2)

let rec specvar_to_var_query = function
    Before(e,hll) -> Before(specvar_to_var_event e, List.map (List.map specvar_to_var_hypelem) hll)

and specvar_to_var_hypelem = function
    QEvent e -> QEvent(specvar_to_var_event e)
  | NestedQuery q -> NestedQuery (specvar_to_var_query q)
    
let specvar_to_var_env = List.map (fun (v,t) -> (v, specvar_to_var t))

let specvar_to_var_fact = function
    Pred(p,l) -> Pred(p, List.map specvar_to_var l)
  | Out(t,tl) -> Out(specvar_to_var t, 
		     List.map (fun (x,t') -> (x,specvar_to_var t')) tl)

let specvar_to_var_constra = List.map (function
    Neq(t1, t2) -> Neq(specvar_to_var t1, specvar_to_var t2))

(* Test whether v occurs in query q *)

let v_occurs v = function
    QSEvent(b,t) -> Terms.occurs_var v t
  | QFact(p,tl) -> List.exists (Terms.occurs_var v) tl
  | QNeq(t1,t2) -> (Terms.occurs_var v t1) || (Terms.occurs_var v t2)
  | QEq(t1,t2) -> (Terms.occurs_var v t1) || (Terms.occurs_var v t2)

let rec v_occurs_query v = function
    Before(e',hll) -> 
      (v_occurs v e') || 
      (List.exists (List.exists (v_occurs_hypelem v)) hll)

and v_occurs_hypelem v = function
    QEvent e' -> v_occurs v e'
  | NestedQuery q -> v_occurs_query v q

(* Call f for each variable that occurs in the query *)

let rec for_all_term f = function
    Var v -> f v
  | FunApp(_,l) -> List.iter (for_all_term f) l

let for_all_event f = function
    QSEvent(b,t) -> for_all_term f t
  | QFact(p,tl) -> List.iter (for_all_term f) tl
  | QNeq(t1,t2) -> for_all_term f t1; for_all_term f t2
  | QEq(t1,t2) -> for_all_term f t1; for_all_term f t2
    
let rec for_all_query f = function
    Before(e',hll) -> 
      for_all_event f e';
      List.iter (List.iter (for_all_hypelem f)) hll

and for_all_hypelem f = function
    QEvent e' -> for_all_event f e'
  | NestedQuery q -> for_all_query f q


(* Check that the value of e in a query e ==> H determines the value 
   of e ==> H *)


(* Rename variables to fresh variables *)

let copy_event_fresh = function
    QSEvent(b,t) -> QSEvent(b, Terms.copy_term t)
  | QFact(p, tl) -> QFact(p, List.map Terms.copy_term tl)
  | QNeq(t1,t2) -> QNeq(Terms.copy_term t1, Terms.copy_term t2)
  | QEq(t1,t2) -> QEq(Terms.copy_term t1, Terms.copy_term t2)

(* Copies the query without further renaming of variables *)

let rec copy_term4 = function
    Var v ->
      begin
	match v.link with
	  VLink v' -> Var v'
	| NoLink -> Var v
	| _ -> internal_error "unexpected link in copy_term4"
      end
  | FunApp(f,l) ->
      FunApp(f, List.map copy_term4 l)

let copy_event4 = function
    QSEvent(b,t) -> QSEvent(b, copy_term4 t)
  | QFact(p, tl) -> QFact(p, List.map copy_term4 tl)
  | QNeq(t1,t2) -> QNeq(copy_term4 t1, copy_term4 t2)
  | QEq(t1,t2) -> QEq(copy_term4 t1, copy_term4 t2)

let rec copy_query4 = function
    Before(e, hll) -> Before(copy_event4 e, List.map (List.map copy_hypelem4) hll)

and copy_hypelem4 = function
    QEvent e -> QEvent(copy_event4 e)
  | NestedQuery q -> NestedQuery (copy_query4 q)


(* Unifies two events e and e' modulo the equational theory.
   Calls f for each found most general unifier *)

let unify_event f e e' = match (e,e') with
    QSEvent(b,t), QSEvent(b',t') -> 
      if b!=b' then raise Unify;
      TermsEq.unify_modulo f t t'
  | QFact(p,tl), QFact(p',tl') ->
      if p!=p' then raise Unify;
      TermsEq.unify_modulo_list f tl tl'
  | QNeq(t1,t2), QNeq(t1',t2') -> 
      TermsEq.unify_modulo (fun () ->
	TermsEq.unify_modulo f t2 t2') t1 t1'
  | QEq(t1,t2), QEq(t1',t2') ->
      TermsEq.unify_modulo (fun () ->
	TermsEq.unify_modulo f t2 t2') t1 t1'
  | _ -> raise Unify
  
(* Replaces variables with constants *)

let put_constants_event = function
    QSEvent(b,t) -> put_constants t
  | QFact(p, tl) -> List.iter put_constants tl
  | QNeq(t1,t2) -> put_constants t1; put_constants t2
  | QEq(t1,t2) -> put_constants t1; put_constants t2

let rec put_constants_query = function
    Before(e, hll) -> 
      put_constants_event e; 
      List.iter (List.iter put_constants_hypelem) hll

and put_constants_hypelem = function
    QEvent e -> put_constants_event e
  | NestedQuery q -> put_constants_query q

(* Raise Unify when the term, event, or query are not equal *)

(* Test equality. t1 and t2 must be closed, but they
   may contain variables linked with TLink *)
let equal_terms_modulo t1 t2 =
  Terms.auto_cleanup (fun () ->
    TermsEq.unify_modulo (fun () -> ()) t1 t2)

let equal_event e e' = match (e,e') with
    QSEvent(b,t), QSEvent(b',t') -> 
      if b!=b' then raise Unify;
      equal_terms_modulo t t'
  | QFact(p,tl), QFact(p',tl') ->
      if p!=p' then raise Unify;
      List.iter2 equal_terms_modulo tl tl'
  | QNeq(t1,t2), QNeq(t1',t2') -> 
      equal_terms_modulo t1 t1';
      equal_terms_modulo t2 t2'
  | QEq(t1,t2), QEq(t1',t2') ->
      equal_terms_modulo t1 t1';
      equal_terms_modulo t2 t2'
  | _ -> raise Unify
      
let rec equal_hyp_elem h h' = match (h,h') with
    QEvent e, QEvent e' -> equal_event e e'
  | NestedQuery q, NestedQuery q' -> equal_query q q'
  | _ -> raise Unify
  
and equal_query (Before(e, hll)) (Before(e', hll')) =
  equal_event e e';
  List.iter2 (List.iter2 equal_hyp_elem) hll hll'


let check_det_p q =
  (not (TermsEq.hasEquations())) ||
  (match q with
    Before(e,hll) ->
      let (e', q') =
	Terms.auto_cleanup (fun () ->
	  let e' = copy_event_fresh e in
	  (e', copy_query4 q))
      in
      try
	unify_event (fun () -> 
	  Terms.auto_cleanup (fun () ->
	    let q1 = copy_query q in
	    let q1' = copy_query q' in
	    put_constants_query q1;
	    put_constants_query q1';
	    if 
	      (try
		equal_query q1 q1';
		true
	      with Unify -> false) then raise Unify else false)
	      ) e e'
      with Unify -> 
	true)


(* Build a clause from a query *)

let inj_marker = [(Terms.new_var Param.def_var_name Param.sid_type, Terms.new_var_def Param.sid_type)]

let non_inj_marker = []

let event_to_end_fact = function
    QSEvent(_,(FunApp(f,l) as param)) -> 
      if (Pievent.get_event_status f).end_status = Inj then
	Pred(Param.end_pred_inj, [Var(Terms.new_var "endsid" Param.sid_type);param])
      else
	Pred(Param.end_pred, [param])
  | QSEvent(_, _) ->
      user_error ("Events should be function applications\n")
  | QFact(p,l) -> Pred(p,l)
  | QNeq _ | QEq _ -> internal_error "no Neq queries"


let rec events_to_hyp = function
    [] -> ([],[],[],[],[]) 
  | (a::l) ->
      let (hyp', hyp_q', constra', eq_left', eq_right') = events_to_hyp l in
      match a with
	QEvent e ->
	  begin
	    match e with
	      QSEvent(b, param) -> 
	  (* The second arg of Out is used only as a marker to know whether
             the event is injective or not *)
		((Out(param, if b then inj_marker else non_inj_marker)) :: hyp', hyp_q', constra', eq_left', eq_right')
	    | QFact(p,l) -> ((Pred(p,l)) :: hyp', hyp_q', constra', eq_left', eq_right')
	    | QNeq (t1,t2) -> (hyp', hyp_q', [Neq(t1,t2)] :: constra', eq_left', eq_right')
	    | QEq (t1,t2) -> (hyp', hyp_q', constra', t1 :: eq_left', t2 :: eq_right')
	  end
      |	NestedQuery(Before(QSEvent(b, param),_) as q) ->
	  (* The second arg of Out is used only as a marker to know whether
             the event is injective or not *)
	  ((Out(param, if b then inj_marker else non_inj_marker)) :: hyp', q :: hyp_q', constra', eq_left', eq_right')
      |	NestedQuery(Before(QFact(p,l),_) as q) ->
	  ((Pred(p,l)):: hyp', q :: hyp_q', constra', eq_left', eq_right')
      |	NestedQuery(_) ->
	  internal_error "Bad nested query"
	
(* Transforms a query into a non-injective, non-nested one, 
   the only kind of query for which the reconstruction of a trace
   guarantees that the query is false. *)

let non_inj_event = function
    QSEvent(b,t) -> QSEvent(false,t)
  | e -> e

let simplify_query (Before(e,l)) =
  Before(non_inj_event e,
	 List.map (fun l1 ->
	 let l' = List.map (function 
	     NestedQuery(Before(e,_)) -> QEvent(non_inj_event e)
	   | QEvent e -> QEvent(non_inj_event e)) l1 
	 in
	 List.filter (function QEvent(QNeq _ | QFact _) -> false
	   | _ -> true) l'
	   ) l)

let is_non_inj_neq = function
    QSEvent(true,_) -> false
  | QNeq _ -> Parsing_helper.internal_error "inequalities should not occur in left-hand side of ==> in queries"
  | _ -> true

let is_non_inj_neq_fact = function
    QSEvent(true,_) | QNeq _ | QFact _ -> false
  | _ -> true

let is_simple_query (Before(e,l)) =
  (is_non_inj_neq e) && 
  (List.for_all (List.for_all (function 
      NestedQuery(Before(e,_)) -> false
    | QEvent e -> is_non_inj_neq_fact e)) l)

(* For injective agreement *)

let session_id_cst = 
  { f_name = "session_id";
    f_type = [], Param.sid_type;
    f_private = false;
    f_options = 0;
    f_cat = Eq [];
    f_initial_cat = Eq []
  }

let session_id = FunApp(session_id_cst, [])

let session_id_cst2 = 
  { f_name = "session_id2";
    f_type = [], Param.sid_type;
    f_private = false;
    f_options = 0;
    f_cat = Eq [];
    f_initial_cat = Eq []
  }

let session_id2 = FunApp(session_id_cst2, [])



(* to call combine_lists collector[fsymb]  rho{sid2/sid} *)

let rec combine_lists l1 = function
  [] -> [] 
| ((v,rhov)::l) -> 
     let rec do_v = function
       [] -> combine_lists l1 l
     | (v', rholv)::l' ->
	  if v' == v then
            (v', rhov::rholv)::(combine_lists l1 l)
          else 
            do_v l'
     in 
     do_v l1

(* to call when collector[fsymb] not found, build_list rho{sid2/sid} *)

let build_list = List.map (fun (v,rhov) -> (v, [rhov]))

(* call combine_lists2 [result of combine_lists/collector] rho{sid1/sid}.
   If result empty, raise Unify *)

(* TO DO cleanup after unify_modulo, unify_modulo_env, and unify_modulo_list ?
   (6 occurrences) *)

let check_no_unif t1 t2 =
  let bad = ref false in
  begin
  try
    Terms.auto_cleanup (fun () ->
      TermsEq.unify_modulo (fun () -> bad := true) t1 t2)
  with Unify -> ()
  end;
  not (!bad)

let rec combine_lists2 l1 l2 = match (l1,l2) with
  ([], _) -> []
| (((v, rholv)::l), ((v', rhov')::l')) ->
    if v == v' then
      if List.for_all (fun rhov -> check_no_unif rhov rhov') rholv then
        (v, rholv)::(combine_lists2 l l')
      else
        combine_lists2 l l'
    else
      combine_lists2 l1 l'
| _ -> internal_error "second list should be at least as long as first list in combine_lists2"

module Fun = struct
   type t = funsymb * string
   let compare = compare
end

module FunMap = Map.Make(Fun)

let current_inj_collector = ref FunMap.empty

let combine collector fsymb end_session_id env =
  let rec find_last = function
      [] -> Parsing_helper.internal_error "The environment should contain at least the occurrence variable"
    | [v,t] -> [], v.sname
    | a :: r -> let r', occ_string = find_last r in (a::r', occ_string)
  in
  let (env, occ_string) = find_last env in
  let map_arg = (fsymb, occ_string) in
  end_session_id.link <- TLink session_id;
  let curr_bound_vars = !current_bound_vars in
  current_bound_vars := [];
  let env1 = List.map (fun (v,t) -> (v, copy_term2 t)) 
               (specvar_to_var_env env) in
  Terms.cleanup();
  end_session_id.link <- TLink session_id2;
  let env2 = List.map (fun (v,t) -> (v, copy_term2 t))
               (specvar_to_var_env env) in
  Terms.cleanup();
  current_bound_vars := curr_bound_vars;
  end_session_id.link <- NoLink;
  let collectorfsymb =
    try
      combine_lists (FunMap.find map_arg collector) env2
    with Not_found ->
      build_list env2
  in
  let res = combine_lists2 collectorfsymb env1 in
  if res = [] then raise Unify;
  FunMap.add map_arg res collector

let check_inj fsymb end_session_id env restwork =
  let old_inj_collector = !current_inj_collector in
  current_inj_collector := combine old_inj_collector fsymb end_session_id env;
  try 
    restwork();
    current_inj_collector := old_inj_collector
  with Unify ->
    current_inj_collector := old_inj_collector;
    raise Unify

(*
    Note: there is a small discrepancy between the following version artauth4.tex:
    In the paper, we require that for a variable x_{jk} in the environment
    env_ok(x_{jk}) and env_ok2(x_{jk}) do not unify, where the variable x_{jk} is
    the same for all environments associated with the same function symbol
    fsymb. Here, we require that the environments
    do not unify. I think the following version is sound, but this is more
    difficult to prove, so I use the previous one.


let current_inj_collector = ref []

let check_inj fsymb end_session_id env restwork =
  List.iter (fun (fsymb2, end_session_id2, env2) -> 
    if fsymb == fsymb2 then
    begin
      let bad = ref false in
      end_session_id.link <- TLink session_id;
      let curr_bound_vars = !current_bound_vars in
      current_bound_vars := [];
      let env_ok = List.map (fun (v,t) -> (v, copy_term2 t)) 
                     (specvar_to_var_env env) in
      Terms.cleanup();
      end_session_id2.link <- TLink session_id2;
      let env_ok2 = List.map (fun (v,t) -> (v, copy_term2 t))
                      (specvar_to_var_env env2) in
      Terms.cleanup();
      current_bound_vars := curr_bound_vars;
      begin
        try
          TermsEq.unify_modulo_env (fun () -> bad := true) env_ok env_ok2
        with Unify -> ()
      end;
      end_session_id.link <- NoLink;
      end_session_id2.link <- NoLink;
      if !bad then raise Unify
    end
     ) ((fsymb, end_session_id, env) :: !current_inj_collector);
  let old_inj_collector = !current_inj_collector in
  current_inj_collector := (fsymb, end_session_id, env) :: old_inj_collector;
  try 
    restwork();
    current_inj_collector := old_inj_collector
  with Unify ->
    current_inj_collector := old_inj_collector;
    raise Unify
*)

(* Reprogrammation of clause implication to handle implication modulo
   the equational theory
   I can be approximate in that the subsumption test may fail
   even when it is in fact true. So I do not retry all unifications
   when a future unification fails in match_facts_mod_eq,
   by raising Not_found instead of Unify when a future unification fails *)

let match_facts_mod_eq f f1 f2 = match (f1,f2) with
  Pred(chann1, t1),Pred(chann2, t2) ->
    begin
    if chann1 != chann2 then raise Unify;
    try
      TermsEq.unify_modulo_list (fun () -> try f() with Unify -> raise Not_found) t1 t2
    with Not_found -> raise Unify
    end
| Out(t1,l1),Out(t2,l2) ->
    (* Is it the right direction ? *)
    let len1 = List.length l1 in
    let len2 = List.length l2 in
    if len2 < len1 then raise Unify;
    let l2 = skip (len2-len1) l2 in
     List.iter2 (fun (v1,t1) (v2,t2) ->
      if v1 != v2 then raise Unify) l1 l2;
    let l1' = List.map snd l1 in
    let l2' = List.map snd l2 in
    begin
    try
      TermsEq.unify_modulo_list (fun () -> try f() with Unify -> raise Not_found) (t1::l1') (t2::l2')
    with Not_found -> raise Unify	
    end
| _ -> raise Unify

let rec match_hyp1_mod_eq f h1 = function
    [] -> raise Unify
  | (h2::hl2) -> 
        try
          match_facts_mod_eq f h1 h2
        with Unify ->
          match_hyp1_mod_eq f h1 hl2 

let rec match_hyp_mod_eq f hyp1 hyp2 () =
   match hyp1 with
     [] -> f ()
   | (h1 :: hl1) -> match_hyp1_mod_eq (match_hyp_mod_eq f hl1 hyp2) h1 hyp2 

let implies_mod_eq (hyp1, concl1, _, constr1) (hyp2, concl2, _, constr2) =
  match_facts_mod_eq (fun () ->
    match_hyp_mod_eq (fun () ->
      begin
	try 
	  Terms.auto_cleanup (fun () ->
	    Rules.implies_constra_list 
	      (List.map (fun f -> specvar_to_var_fact (TermsEq.remove_syntactic_fact f)) (concl2 :: hyp2)) 
	      (List.map (fun c -> specvar_to_var_constra (TermsEq.remove_syntactic_constra c)) constr2) 
	      (List.map (fun c -> specvar_to_var_constra (TermsEq.remove_syntactic_constra c)) constr1) ())
	with NoMatch -> raise Unify
      end;
      )
      (Rules.reorder hyp1) hyp2 ()) concl1 concl2

let implies_mod_eq r1 r2 =
  if !current_bound_vars != [] then
    internal_error "Bad bound vars in implies_mod_eq"; 
  put_constants_rule r2;
  let (hyp_cl, concl_cl, hist_cl, constra_cl) = r2 in
  let r2' = (List.map copy_fact2 hyp_cl, 
             copy_fact2 concl_cl, hist_cl, 
             List.map copy_constra2 constra_cl)
  in
  cleanup();
  try 
    Terms.auto_cleanup (fun () -> implies_mod_eq r1 r2');
    true
  with Unify -> false

let rec remove_subsumed_mod_eq = function
    [] -> []
  | (a::l) ->
      if List.exists (fun r1 -> implies_mod_eq r1 a) l then
	remove_subsumed_mod_eq l
      else
	a::(remove_subsumed_mod_eq (List.filter (fun r2 -> not (implies_mod_eq a r2)) l))


(* Reprogrammation of clause implication to handle one clause and 
   one query.  *)

let match_facts_eq f end_session_id f1 f2 = match (f1,f2) with
  Pred(chann1, t1),Pred(chann2, t2) ->
    if chann1 != chann2 then raise Unify;
    TermsEq.unify_modulo_list f t1 t2
| Out(t1,marker),Out(t2,l2) ->
    if marker == non_inj_marker then
      TermsEq.unify_modulo f t1 t2
    else
      begin
      match end_session_id with
        None -> Parsing_helper.internal_error "the end event corresponding to an injective begin event should always have a session id"
      | Some i -> 
          match t1 with
            FunApp(fsymb, _) -> 
              TermsEq.unify_modulo (fun () -> check_inj fsymb i l2 f) t1 t2
          | _ -> Parsing_helper.internal_error "arguments of events should be function applications"
      end
| _ -> raise Unify

let rec match_hyp1_eq f end_session_id h1 = function
    [] -> raise Unify
  | (h2::hl2) -> 
        try
          match_facts_eq f end_session_id h1 h2
        with Unify ->
          match_hyp1_eq f end_session_id h1 hl2 

let rec match_hyp_eq f hyp1 hyp2 end_session_id () =
   match hyp1 with
     [] -> f ()
   | (h1 :: hl1) -> match_hyp1_eq (match_hyp_eq f hl1 hyp2 end_session_id) end_session_id h1 hyp2 

(* Improved verification of predicates in clauses *)

let init_clauses = ref []

let clauses_for_preds = ref None

let get_clauses_for_preds () = 
  match ! clauses_for_preds with
    Some l -> l
  | None -> 
      let clauses = ref [] in
      List.iter (fun (hyp1, concl1, constra1, tag1) -> 
        TermsEq.close_rule_destr_eq (fun (hyp, concl, constra) ->
          clauses := (hyp, concl, Rule(-1, tag1, hyp, concl, constra), constra) :: (!clauses)
            ) (hyp1, concl1, constra1))
                (!Param.red_rules);
      List.iter (fun fact -> 
        TermsEq.close_rule_destr_eq (fun (hyp, concl, constra) ->
          clauses := (hyp, concl, Rule(-1, LblClause, hyp, concl, constra), constra) :: (!clauses)
            ) ([], fact, []))
                (!Param.elim_true);
      Terms.cleanup();
      List.iter (function (_,_,Rule(_,(Apply _ | Init), _,_,_), _) as cl -> 
                         clauses := cl :: (!clauses)
                   | _ -> ()) (!init_clauses);
      clauses_for_preds := Some (!clauses);
      !clauses

let match_hyp_eq f hyp1 hyp2 end_session_id () =
  let filt = function Out _ -> true
		    | Pred(p,_) -> p.p_prop land Param.pred_BLOCKING != 0
  in
  let (hyp1_events, hyp1_preds) = List.partition filt hyp1 in
  let (hyp2_events, hyp2_preds) = List.partition filt hyp2 in
  match_hyp_eq (fun () ->
    if hyp1_preds == [] then f() else
    (* The matching of events succeeded; now I need to prove the facts in hyp1_preds
       from the instance of the facts in hyp2_preds *)
    Terms.auto_cleanup (fun () -> 
      let bad_fact = Pred(Param.bad_pred, []) in
      let hyp2_preds' = List.map Terms.copy_fact2 hyp2_preds in
      let hyp1_preds' = List.map Terms.copy_fact2 hyp1_preds in
      Terms.cleanup();
      let clauses = 
         (hyp1_preds', bad_fact, Rule(-1, LblNone, hyp1_preds', bad_fact, []), []) ::
         (get_clauses_for_preds()) @
         (List.map (fun fact -> ([], fact, Rule(-1, LblNone, [], fact, []), [])) hyp2_preds') 
      in
      print_string "Inside query: trying to prove ";
      Display.display_list Display.display_fact ", " hyp1_preds';
      print_string " from ";
      Display.display_list Display.display_fact ", " hyp2_preds';
      Display.newline();
      (* the resolution prover must be _sound_ for this call
	 while for other calls it must be _complete_.
         The function sound_bad_derivable is sound provided the clause
	 do not contain "any_name" and contain unary attacker predicates, 
         which is the case here. *)
      let cl = Rules.sound_bad_derivable clauses in
      if List.exists (function ([], _, _, []) -> true
                             | _ -> false) cl then
        begin
          (* Success: managed to prove the facts in hyp1_preds' *)
	  print_string "Inside query: proof succeeded\n";
          f()
        end
      else
        begin
          (* Failure: could not prove some fact in hyp1_preds' *)
	  print_string "Inside query: proof failed\n";
          raise Unify
        end)) hyp1_events hyp2_events end_session_id ()



let rec implies_q restwork (hyp1, hyp1_q, concl1, constr1) (hyp2, concl2, _, constr2) =
     match_facts_eq (fun () ->
       let end_session_id =
         match concl2 with
           Pred(_, [FunApp({f_cat = SpecVar i}, []);_]) -> Some i
         | _ -> None
       in
       match_hyp_eq (fun () ->
	 begin
	   try 
	     Terms.auto_cleanup (fun () ->
	       Rules.implies_constra_list 
		 (List.map (fun f -> specvar_to_var_fact (TermsEq.remove_syntactic_fact f)) (concl2 :: hyp2)) 
		 (List.map (fun c -> specvar_to_var_constra (TermsEq.remove_syntactic_constra c)) constr2) 
		 (List.map (fun c -> specvar_to_var_constra (TermsEq.remove_syntactic_constra c)) constr1) ())
	   with NoMatch -> 
	     raise Unify
	 end;
	 (* Instantiate the nested queries with the value given by the clause *)
	 let hyp1_q' = 
	   Terms.auto_cleanup (fun () ->
	   List.map (fun q -> 
	     let q' = copy_query q in
	     if not (check_query_vars q') then
	       begin
		 print_string "Occurrence checking failed in ";
		 display_query q';
		 Display.newline();
		 print_string "For the nested query e1 ==> (e2 ==> H) & ... to be true,\nthe variables instantiated when querying e1 ==> e2 & ... and that occur in\nH must also occur in e2. This is wrong for the query above.\n";
		 raise Unify
	       end;
	     let q'' = specvar_to_var_query q' in
	     if not (check_det_p q'') then
	       begin
		 print_string "Occurrence checking failed in ";
		 display_query q'';
		 Display.newline();
		 print_string "For the nested query e1 ==> (e2 ==> H) & ... to be true,\nthe value of e2 must determine the value of e2 ==> H.\nThis is wrong for the query above (due to the equational theory).\n";
		 raise Unify
	       end;
	     q'') hyp1_q)
	 in
	 let rec check_occ_queries rest = function
	     [] -> ()
	   | (q::l) ->
	     for_all_query (fun v -> 
	       if List.exists (v_occurs_query v) (rest @ l) && 
		 not (let Before(e',_) = q in
		      v_occurs v e')
	       then
	       begin
		 print_string "Occurrence checking failed in ";
		 display_query q;
		 Display.newline();
		 print_string "For the nested query e1 ==> (e2 ==> H) & (e3 ==> H') & ... to be true,\nthe variables that occur in H and H' must also occur in e2 and e3.\nThis is wrong for the query above.\n";
		 raise Unify
	       end
		 ) q;
	     check_occ_queries (q::rest) l
	 in
	 check_occ_queries [] hyp1_q';
	 let rec list_subqueries restwork = function
	     [] -> Terms.auto_cleanup restwork
	   | (q::l) ->
	       Terms.auto_cleanup (fun () ->
		 if check_query (fun () -> 
		   list_subqueries restwork l) false q != True then
		   raise Unify)
	 in
	 list_subqueries restwork hyp1_q'
         )
	 (Rules.reorder hyp1) hyp2 end_session_id ()) None concl1 concl2



(* Check if a query is true *)


and clause_match_elem restwork e cl h =
  let concl = event_to_end_fact e in
  let (hyp, hyp_q, constra, eq_left, eq_right) = events_to_hyp h in
  (* Replace all variables in the clause with constants "SpecVar" *)
  if !current_bound_vars != [] then
    internal_error "Bad bound vars in clause_match_elem"; 
  put_constants_rule cl;
  let (hyp_cl, concl_cl, hist_cl, constra_cl) = cl in
  let cl' = (List.map copy_fact2 hyp_cl, 
             copy_fact2 concl_cl, hist_cl, 
             List.map copy_constra2 constra_cl)
  in
  cleanup();
  (* Check whether the clause matches the query *)
  try
    if eq_left != [] then
      Terms.auto_cleanup (fun () ->
	TermsEq.unify_modulo_list (fun () -> 
	  let (hyp2, hyp_q2, concl2, constra2) = 
	     Terms.auto_cleanup (fun () ->
				  (List.map TermsEq.copy_remove_syntactic_fact hyp,
				   List.map copy_query hyp_q,
				   TermsEq.copy_remove_syntactic_fact concl,
				   List.map TermsEq.copy_remove_syntactic_constra constra))
	  in
	  Terms.auto_cleanup (fun () ->
				  implies_q restwork (hyp2, hyp_q2, concl2, constra2) cl')
	       ) eq_left eq_right
	  )
    else
      implies_q restwork (hyp, hyp_q, concl, constra) cl';
    true
  with Unify ->
    false


and clauses_match restwork non_nested q clauses =
  if !current_bound_vars != [] then
    internal_error "Bad bound vars in clauses_match"; 
  let q' = copy_query q in
  cleanup();
  let simple_query = is_simple_query q' in
  (* First check a simplified, non-nested, non-injective query *)
  let Before(e,l) as q'' = simplify_query q' in
  let recheck_fun = fun cl -> List.exists (clause_match_elem (fun () -> ()) e cl) l in
  let def_res = ref DontKnow in
  let res = List.for_all (fun cl ->
    let res = List.exists (clause_match_elem (fun () -> ()) e cl) l in
	(* When res is false, the clause cl falsifies the query *)
    if (not res) && (display_clause_trace (not res) (Some recheck_fun) None cl) then def_res := False;
    res
                             ) clauses
  in
  if non_nested && not simple_query then
    supplemental_info := Some(q'', if res then True else !def_res);
  (* If the simplified query cannot be proved, then q cannot be proved either.
     If we could reconstruct a trace against the simplified query, then q is false *)
  if not res then !def_res else
  (* If q' is simple, then it is equal to its simplified query, so the result is known *)
  if simple_query then 
    begin
      List.iter (fun cl -> ignore (display_clause_trace (not res) (Some recheck_fun) None cl)) clauses;
      try restwork(); True with Unify -> DontKnow
    end
  else
  (* Otherwise, test the query q' itself *)
  match q' with
    Before((QSEvent(false, _) | QFact(_,_) as e),l) -> 
      let res = List.for_all (fun cl -> 
	let res = List.exists (clause_match_elem (fun () -> ()) e cl) l in
	let recheck_fun = fun cl -> List.exists (clause_match_elem (fun () -> ()) e cl) l in
	(* When res is false, the clause cl falsifies the query *)
	ignore (display_clause_trace (not res) (Some recheck_fun) None cl);
	res
			     ) clauses
      in
      if res then 
	try 
	  restwork(); True 
	with Unify -> DontKnow 
      else DontKnow
  | Before(e,l) -> (* e is QSEvent(true, _): injective query *)
      match clauses with
        [] -> 
	  begin
	    try 
	      restwork(); True 
	    with Unify -> DontKnow
	  end
      | (cl::cll) -> 
	  let res =
            List.exists (clause_match_elem (fun () -> 
              if not (clauses_match_inj restwork q cll) then raise Unify) e cl) l
	  in
	  (* When res is false, one of the clauses in clauses falsifies the query *)
	  if not res then 
	    begin
	      (* The query cannot be proved *)
	      if non_nested then
		begin
		  (* If the query is not nested, try to investigate in more detail why the proof failed *)
		  let reslist = 
		    if cll = [] then [false] else 
		    List.map (fun cl -> 
		      List.exists (clause_match_elem (fun () -> ()) e cl) l) clauses
		  in
		  if List.mem false reslist then
		    begin
		      (* A single clause falsifies the query; in this case, we display the derivation
			 only for the clauses that falsify the query. We try to reconstruct a trace
			 that falsifies injectivity. *)
		      let recheck_fun = fun cl -> List.exists (clause_match_elem (fun () -> ()) e cl) l in
		      let reslist_att = List.map2 (fun cl res1 -> display_clause_trace (not res1) (Some recheck_fun) (Some q') cl) clauses reslist in
		      if List.mem true reslist_att then False else DontKnow
		    end
		  else
		    begin
		      (* Several clauses simultaneously are needed to falsify the query.
			 We display all derivations. *)
		      List.iter (fun cl -> ignore (display_clause_trace true None None cl)) clauses;
		      DontKnow
		    end
		end
	      else
		begin
		  List.iter (fun cl -> ignore (display_clause_trace true None None cl)) clauses;
		  DontKnow
		end
	    end
	  else
	    begin
	      (* The query is true *)
	      List.iter (fun cl -> ignore (display_clause_trace false None None cl)) clauses;
	      True
	    end



and clauses_match_inj restwork q clauses =
  if !current_bound_vars != [] then
    internal_error "Bad bound vars in clauses_match"; 
  let Before(e,l) = copy_query q in
  cleanup();
  match clauses with
    [] -> 
      begin
	try 
	  restwork(); true 
	with Unify -> false
      end
  | (cl::cll) -> 
      List.exists (clause_match_elem (fun () -> 
        if not (clauses_match_inj restwork q cll) then raise Unify) e cl) l

and check_query restwork non_nested (Before(e, hypll) as q) =
      print_string "Starting query ";
      display_query q;
      print_string "\n";
      if !current_bound_vars != [] then
	internal_error "Bound vars should be cleaned up (check_query)"; 
      let f = event_to_end_fact e in
      let clauses = Rules.query_goal_std f in
      (* Remove clauses subsumed modulo equational theory *)
      (* print_string ((string_of_int (List.length clauses)) ^ " clauses before subsumption modulo eq.\n"); *)
      let clauses = 
	if TermsEq.hasEquations() then
	  remove_subsumed_mod_eq clauses
	else
	  clauses
      in
      (* print_string ((string_of_int (List.length clauses)) ^ " clauses after subsumption modulo eq.\n");
        List.iter (fun cl -> 
	print_string "clause after subsumption modulo eq: ";
	Display.display_rule cl) clauses;*)
      clauses_match restwork non_nested q clauses

let do_query = function
    PutBegin _ -> ()
  | RealQuery (Before(e, hypll) as q) ->
      let non_nested = 
	List.for_all (List.for_all (function NestedQuery _ -> false
	  | _ -> true)) hypll
      in
      let r = check_query (fun () -> ()) non_nested q in
      print_string "RESULT ";
      display_query q;
      display_res r;
      Display.newline();
      if (!Param.tulafale <> 1) && (r != True) then
	begin
	  match !supplemental_info with
	    None -> ()
	  | Some(q',r') ->
	      print_string "RESULT (";
	      if r' == True then print_string "but " else print_string "even ";
	      display_query q';
	      display_res r';
	      print_string ")";
	      Display.newline()
	end;
      supplemental_info := None
	
let solve_auth rules queries =
  init_clauses := rules;
  clauses_for_preds := None;
  Rules.completion rules;
  List.iter do_query queries


