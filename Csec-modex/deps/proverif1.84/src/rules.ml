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
open Display
open Terms
open TermsEq
open Selfun

(* let resol_step = ref 0 *)

let sound_mode = ref false

let not_set = ref ([]: fact list)
let add_not f =
  not_set := f :: (!not_set)

let elimtrue_set = ref ([]: (int * fact) list)
let add_elimtrue f =
  elimtrue_set := f :: (!elimtrue_set)

(* Check that two facts are smaller for all instances *)

let rec get_vars_rep vlist = function
    Var v -> vlist := v :: (!vlist)
  | FunApp(_,l) -> 
      List.iter (get_vars_rep vlist) l

let get_vars_rep_fact vlist = function
    Pred(p,l) -> List.iter (get_vars_rep vlist) l
  | Out(t,l) -> get_vars_rep vlist t;
      List.iter (fun (_,t') -> get_vars_rep vlist t') l

let is_in_list vlist v =
  let rec remove_first v = function
      [] -> raise Not_found
    | (v'::l) -> if v' == v then l else v' :: (remove_first v l)
  in
  try
    vlist := remove_first v (!vlist);
    true
  with Not_found -> false

let is_smaller f1 f2 =
  (Terms.fact_size f1 < Terms.fact_size f2) && 
  (let v1 = ref [] in
  let v2 = ref [] in
  get_vars_rep_fact v1 f1;
  get_vars_rep_fact v2 f2;
  List.for_all (is_in_list v2) (!v1))

let equiv_set = ref ([]: (fact list * fact * int) list)
let add_equiv ((hyp, concl, n) as r) =
  (* Check that \sigma h smaller than \sigma concl for all \sigma, for all h in hyp.
     This implies termination of the replacement process *)
  if not (List.for_all (fun h -> is_smaller h concl) hyp) then
    Parsing_helper.user_error "For equivalences, the conclusion must be larger than the hypotheses\nand this must be true for all instances of these facts.";
  (* Check that only ONE replacement rule applies to a given fact.
     This implies confluence of the replacement process *)
  List.iter (fun (_, concl',_) ->
    try
      Terms.auto_cleanup (fun () -> Terms.unify_facts concl concl');
      Parsing_helper.user_error "Conflict between equivalences: two of them apply to the same fact";
    with Unify -> ()
	) (!equiv_set);
  begin
    match concl with
      Pred(p,((FunApp(f,_) :: _) as l)) when 
        p.p_prop land Param.pred_TUPLE != 0 &&
        f.f_cat = Tuple -> 
	begin
	try 
	  let _ = reorganize_fun_app f l in
	  Parsing_helper.user_error "Conflict between an equivalence and the decomposition of data constructors:\nan equivalence applies to a fact which is also decomposable by data constructors"
	with Not_found -> ()
	end
    | _ -> ()
  end;
  (* Store the replacement rule *)
  equiv_set := r :: (!equiv_set)

(* Limiting the depth of terms and number of hypotheses to
   enforce termination. Disabled in sound mode. *)

let rec limit_depth n t =
   if n = 0 then 
      Terms.new_var_def (Terms.get_term_type t)
   else
      match t with
      | Var v -> t
      | FunApp(f,l) -> FunApp(f, List.map (limit_depth (n-1)) l)

let limit_depth_fact n = function
    Pred(chann,t) -> Pred(chann, List.map (limit_depth n) t)
  | Out(t,l) -> Out(limit_depth n t, List.map (fun (v,t) -> (v, limit_depth n t)) l)

let rec limit_depth_constra n c = List.map (function
    Neq(t1,t2) -> Neq(limit_depth n t1, limit_depth n t2)) c

let rec max_length n = function
    [] -> []
  | (a::l) -> if n = 0 then [] else a::(max_length (n-1) l)

let rec cancel_history n maxn h =
  if maxn <= n then h else 
  cancel_history n (maxn-1) (Any(n,h))

let limit_depth_rule r =
  if !sound_mode then r else
  let r =
    let max_hyp = !Param.max_hyp in
    if max_hyp < 0 then r else
    let (hyp, concl, hist,constra) = r in
    (* remove some hypotheses/constraints if they are too numerous
       Adjust the history hist accordingly *) 
    (max_length max_hyp hyp, concl,
     cancel_history max_hyp (List.length hyp) hist,
     List.map (max_length max_hyp) (max_length max_hyp constra))
  in 
   let max_depth = ! Param.max_depth in
   if max_depth < 0 then r else
   let (hyp, concl, hist,constra) = r in
   (List.map (limit_depth_fact max_depth) hyp, 
    limit_depth_fact max_depth concl, hist, 
    List.map (limit_depth_constra max_depth) constra)

(* Decompose tuples and data constructors in hypotheses of rules.
   It is important for the correctness of this optimization that
   p:x is never selected when p is a predicate on which we
   perform the decomposition of data constructors, except
   when there are only such facts in the clause.

   Also eliminates duplicate hypotheses.
 *)

let rec pos_in_list init f = function
    [] -> -1 
  | (a::l) -> if f a then init else pos_in_list (init+1) f l

let is_exempt_from_dectuple (_,_,h,_) =
  match h with
    Rule (_,Apply(Func(f),p),_,_,_) -> f.f_cat = Tuple
  | Rule (_,Apply(Proj(_,_),p),_,_,_) -> true
  | Rule (_,LblEquiv,_,_,_) -> true
  | _ -> false

let rec find_f_dectuple l0 lbool = 
  match (l0,lbool) with
  | (_::l1,false::lbool1) -> find_f_dectuple l1 lbool1
  | (FunApp(f,_)::_, true::_) when f.f_cat = Tuple -> f
  | (_::_,true::_) -> raise Not_found
  | _ -> Parsing_helper.internal_error "dec_partial.find_f"

let rec decompose_hyp_rec accu hypl = 
  List.fold_right (fun hyp1 (hypl,nl,histl) ->
    let default() = 
      let count = pos_in_list (nl+1) (equal_facts hyp1) hypl in
      if count >= 0 then
        (hypl, nl-1, Removed(nl, count, histl))
      else
        (hyp1::hypl, nl-1, histl)
    in
    match hyp1 with
      Pred(chann,l0) ->
	let rec try_equiv_set = function
	    [] ->
	      if chann.p_prop land Param.pred_TUPLE != 0 then
		try
		  match l0 with
		    (FunApp(f,_) :: _) when f.f_cat = Tuple ->
		      let l = reorganize_fun_app f l0 in
		      let (Rule(_, _, hyp, _, _)) as hist_dec = History.get_rule_hist (Apply(Func(f),chann)) in
		      decompose_hyp_rec (hypl, nl+(List.length l)-1, (Resolution(hist_dec, nl, histl))) 
			(List.map2 (fun (Pred(p', _)) x -> Pred(p', x)) hyp l)
		  | _ -> default()
		with Not_found -> default()
	      else default()
	  | (hypeq, concleq, neq)::l ->
	      try
		let hypeq' = 
		  Terms.auto_cleanup (fun () ->
		    match_facts2 concleq hyp1;
		    List.map copy_fact3 hypeq)
		in
		let hist_dec = Rule(neq, LblEquiv, hypeq, concleq, []) in
		decompose_hyp_rec (hypl, nl+(List.length hypeq')-1, (Resolution(hist_dec, nl, histl))) hypeq'
	      with NoMatch ->
		try_equiv_set l
	in
	try_equiv_set (!equiv_set)
    | _ -> default()
      ) hypl accu

let decompose_hyp_tuples ((hypl, concl, hist, constra) as rule) =
  if is_exempt_from_dectuple rule then
    rule
  else
   let (hypl', nl', histl') =  
     decompose_hyp_rec ([], (List.length hypl)-1, hist) hypl
   in
   (hypl', concl, histl',constra)

(* Counts occurrences of a variable in a list of facts
    occur_count v l
   returns the number of occurrences of v in the list of facts l
 *)

let rec list_add f = function
    [] -> 0
  | (a::l) -> (f a) + (list_add f l)

let rec term_occur_count v = function
    Var v' -> if v == v' then 1 else 0
  | FunApp(f,l) -> list_add (term_occur_count v) l

let fact_occur_count v = function
    Pred(chann, l) -> list_add (term_occur_count v) l
  | Out(t,l) ->
      term_occur_count v t + list_add (fun (_,t2) -> term_occur_count v t2) l

let occur_count v l = list_add (fact_occur_count v) l

let constra_occur_count v = function
    Neq(t1,t2) -> term_occur_count v t1 + term_occur_count v t2

let occur_count_constra v l =
  list_add (list_add (constra_occur_count v)) l

(* Eliminate hypotheses p(x1...xn) where p has been declared "elimVar"
   or "elimVarStrict" and x1...xn do not occur elsewhere.
   Such a declaration means that p(x...x) is true for some value of x. 
   This is correct in particular when p = attacker. When p is declared
   elimVar and we are not in sound_mode, x1...xn are allowed to occur
   in inequalities.

   In sound_mode, we always require that x1...xn do not occur in 
   inequalities.
 *)

let elim_any_x ((hypl', concl, histl', constra) as r) =
   let (hypl'', _, histl'') = List.fold_right (fun hyp1 (hypl, nl, histl) ->
     match hyp1 with
       Pred(chann, l) ->
	 begin
	   try 
	     let (n, ff) = List.find (fun (_, ff) ->
	       let hyp1vlist = ref [] in
	       Terms.get_vars_fact hyp1vlist hyp1;
	       try
		 Terms.auto_cleanup (fun () -> 
		   Terms.unify_facts ff hyp1;
	       (* check that all modified variables of hyp1 do not 
		  occur in the rest of R including inequalities *)
		   List.iter (fun v ->
		     let vt = Terms.follow_link (fun x -> Var x) (Var v) in
		     match vt with
		       Var v' when v' == v -> ()
		     | _ -> 
			 if (occur_count v (concl :: hypl') > fact_occur_count v hyp1)
                       || (occur_count_constra v constra > 0) then raise Unify
			     ) (!hyp1vlist);
	       (* all checks successful *)
		   true
		     )
	       with Unify -> 
		 false 
		   ) (!elimtrue_set)
             in
	     (hypl, nl-1, (Resolution(Rule(n, LblClause, [], ff, []), nl, histl)))
	   with Not_found ->
	     if
	       (chann.p_prop land Param.pred_ANY != 0 && 
		List.for_all (function
		    Var v -> (occur_count v (concl :: hypl') == fact_occur_count v hyp1)
			&& ((not (!sound_mode)) || (occur_count_constra v constra == 0))
		  | _ -> false) l)
             ||
	       (chann.p_prop land Param.pred_ANY_STRICT != 0 &&
		List.for_all (function
		    Var v -> (occur_count v (concl :: hypl') == fact_occur_count v hyp1)
			&& (occur_count_constra v constra == 0)
		  | _ -> false) l)
	     then
	       (hypl, nl-1, (Any(nl, histl)))
	     else
	       (hyp1 :: hypl, nl-1, histl)
	 end
     | _ -> (hyp1 :: hypl, nl-1, histl)
	   ) hypl' ([], (List.length hypl')-1, histl')
   in
   (hypl'', concl, histl'',constra)


(* Implication between constraints. Use this after simplification
   to get the best possible precision. *)

let links = ref []

let rec match_terms_genvar f lt1 lt2 =
   match (lt1,lt2) with
     [], [] -> f ()
   | ((FunApp(f1,[]))::l1, t2::l2) when f1.f_cat = General_var -> 
        begin
	  try 
	    let t = List.assq f1 (!links) in
	    if not (equal_terms t t2) then raise NoMatch;
	    match_terms_genvar f l1 l2
	  with Not_found ->
	    links := (f1, t2) :: (!links);
            try
              let r = match_terms_genvar f l1 l2 in
	      links := List.tl (!links);
	      r
            with NoMatch ->
	      links := List.tl (!links);
              raise NoMatch
	end
   | ((Var v1)::l1), ((Var v2)::l2) when v1 == v2 ->
       match_terms_genvar f l1 l2
   | ((FunApp (f1,l1'))::l1, (FunApp (f2,l2'))::l2) ->
          if f1 != f2 then raise NoMatch;
          match_terms_genvar f (l1' @ l1) (l2' @ l2)
   | _,_ -> raise NoMatch

let match_constra f (Neq(t1,t1')) (Neq(t2, t2')) =
   match_terms_genvar f [t1;t1'] [t2;t2']

let rec match_constra1 f h1 = function
    [] -> raise NoMatch
  | (h2::hl2) -> 
        try
          match_constra f h1 h2
        with NoMatch ->
          match_constra1 f h1 hl2 

let rec match_constra_list hyp1 hyp2 () =
   match hyp1 with
     [] -> ()
   | (h1 :: hl1) -> match_constra1 (match_constra_list hl1 hyp2) h1 hyp2

let implies_simple_constraint = equals_simple_constraint

let implies_constra c1 c2 = 
  try 
    match_constra_list c1 c2 ();
    true
  with NoMatch ->
    false

(*
let implies_simple_constraint = equals_simple_constraint

let implies_constra c1 c2 = 
  List.for_all (fun c1elem -> 
    List.exists (fun c2elem ->
      implies_simple_constraint c1elem c2elem) c2
      ) c1
*)

(* Simplification of constraints *)

(* Remark: for the way the subsumption test is implemented,
   it is important that all variables that occur in constraints
   also occur in the rest of the rule.
   Indeed, only the variables that occur in the rest of the rule
   are bound during the subsumption test. Other variables
   are always considered to be different, yielding the non-detection
   of subsumption 

   When there is no universally quantified variable and no equational
   theory, we can simply remove all inequalities that contain variables
   not in the rest of the rule.
   However, "for all x, x <> y" is wrong even when y does not 
   occur elsewhere. Similarly, "x <> decrypt(encrypt(x,y),y)" is wrong
   with the equation "decrypt(encrypt(x,y),y) = x".
   In this case, we can replace these variables with _new_
   constants.
   In the long run, the best solution might be to consider
   inequalities as an ordinary blocking predicate (and to remove
   constraints completely).
 *)

exception TrueConstraint
exception FalseConstraint

let any_val_counter = ref 0

let elim_var_if_possible has_gen_var rule v =
   if occur_count v rule == 0 then
   begin
     if (not has_gen_var) && (not (TermsEq.hasEquations())) then
       raise TrueConstraint
     else
       begin
         match v.link with
           NoLink ->
	     incr any_val_counter;
             v.link <- TLink (FunApp(
			      { f_name = "any_val" ^ (string_of_int (!any_val_counter)); 
				f_type = [], v.btype; 
				f_cat = Eq []; (* Should not be a name to avoid bad interaction with any_name_fsymb *)
				f_initial_cat = Eq []; (* Should not be a name to avoid bad interaction with any_name_fsymb *)
				f_private = true;
			        f_options = 0 }, []));
             Terms.current_bound_vars := v :: (!Terms.current_bound_vars)
         | TLink _ -> ()
         | _ -> Parsing_helper.internal_error "unexpected link in elim_var_if_possible"
       end
   end
 

let rec check_vars_occurs has_gen_var rule = function
  | FunApp(_,l) -> List.iter (check_vars_occurs has_gen_var rule) l
  | Var v -> elim_var_if_possible has_gen_var rule v

let rec has_gen_var = function
    Var v -> false
  | FunApp(f,[]) when f.f_cat = General_var -> true
  | FunApp(_,l) -> List.exists has_gen_var l

let elim_var_notelsewhere has_gen_var rule = function
  | (Neq(Var v1, Var v2)) ->
      if v1 == v2 then
        Parsing_helper.internal_error "unexpected constraint in simplify_simple_constraint: v <> v";
      elim_var_if_possible has_gen_var rule v1;
      elim_var_if_possible has_gen_var rule v2
(* constraints Neq(x,t), where x does not appear in the rule and t is not a variable, are true
   Note that, if t was a universally quantified variable, it would have been removed by swap.
 *)
  | (Neq(Var v, t)) -> 
      elim_var_if_possible false rule v;
      check_vars_occurs has_gen_var rule t
  | _ ->
      Parsing_helper.internal_error "unexpected constraint in simplify_simple_constraint: t <> t', t not variable"

let rec swap ldone = function
    [] -> 
      (List.rev ldone)
  | (Neq(Var v as a1, FunApp(f,[])) :: l)
	when f.f_cat = General_var -> 
	  let rep = fun (Neq(x, t)) -> Neq(x, replace_name f a1 t) in
	  let ldone' = List.map rep ldone in
	  let l' = List.map rep l in
	  swap ldone' l'
  | (Neq(FunApp(f1,[]),a2) :: l)
	when f1.f_cat = General_var ->
	  swap ldone l
  | (a::l) ->
      swap (a::ldone) l

let feed_new_constra rule accu constra = 
(* TO DO do not keep "syntactic" terms after unification modulo?  
   let constra = TermsEq.remove_syntactic_constra constra in *)
  try
    let constra' = swap [] constra in
    let constra_has_gen_var = List.exists (fun (Neq(x,t)) ->
      has_gen_var t) constra' in
    List.iter (elim_var_notelsewhere constra_has_gen_var rule) constra';
    let constrasimp = copy_constra3 constra' in
    Terms.cleanup();
    if constrasimp = [] then
      raise FalseConstraint
    else if List.exists (fun a'' -> implies_constra a'' constrasimp) (!accu) then 
      ()
    else
      accu := constrasimp :: (List.filter (fun a'' -> not (implies_constra constrasimp a'')) (!accu))
  with TrueConstraint ->
    Terms.cleanup()

let rec close_constra_eq restwork = function
    [] -> restwork ()
  | (Neq(t1,t2) :: l) ->
      try
	unify_modulo (fun () ->
	  close_constra_eq restwork l;
	  raise Unify) t1 t2
	(* In fact, always terminates by raising Unify; never returns
	   ; cleanup() *)
      with Unify ->
	cleanup()

(* rev_assoc2 
   replaces all variables not in keep_vars with general_vars *)

let rev_assoc2 keep_vars vl v =
  match rev_assoc v (!vl) with
    Var _ ->
      if List.mem v keep_vars then
	Var v
      else
	let v' = new_gen_var v.btype in
	vl := (v', v) :: (!vl);
	FunApp(v', [])
  | x -> x


let rec make_constra vl keep_vars = function
    [] -> []
  | (v::l) ->
      let l' = make_constra vl keep_vars l in
      match v.link with
	NoLink -> l'
      | TLink _ -> 
	  (Neq(rev_assoc2 keep_vars vl v, follow_link (rev_assoc2 keep_vars vl) (Var v))) :: l'
      | _ -> internal_error "unexpected link in make_constra"

let simplify_constra accu constra = 
  let vl = ref [] in
  if !Terms.current_bound_vars != [] then
      Parsing_helper.internal_error "bound vars should be cleaned up (simplify_constra)";
  let constra' = List.map (fun (Neq(t1,t2)) -> 
      Neq(replace_f_var vl t1, replace_f_var vl t2)) constra in
  let vlist = ref [] in
  List.iter (get_vars_constra vlist) constra';
  close_constra_eq (fun () ->
    accu := (make_constra vl (!vlist) (!vlist)) :: (!accu)
		   ) constra';
  if !Terms.current_bound_vars != [] then
    Parsing_helper.internal_error "bound vars should be cleaned up (simplify_constra2)"

    
let simplify_constra_list rule constralist = 
  let accu = ref [] in
  List.iter (simplify_constra accu) constralist;
  let accu' = ref [] in
  List.iter (feed_new_constra rule accu') (!accu);
  !accu'

(* subsumption test between rules:
   H -> F (C) => H' -> F' (C') iff exists \sigma,
   \sigma H \subseteq H', \sigma F = F', C' => sigma C *)


(* 1. implication between constraints 

1/ copy the constraints to instantiate variables according to
   the substitution computed by matching conclusion and hypotheses.
   This uses copy_constra3

2/ simplify the obtained constraint, by simplify_constra_list

3/ test the implication, by implies_constra
   raise NoMatch if it fails 

*)

let implies_constra_list rule c1 c2 () =
  try 
    let c2' = simplify_constra_list rule (List.map copy_constra3 c2) in
    if not 
	(List.for_all (fun c2elem -> 
	  List.exists (fun c1elem -> implies_constra c1elem c2elem) c1
	    ) c2') then raise NoMatch
  with FalseConstraint ->
    raise NoMatch

(* 2. matching between terms and facts *)

let rec match_terms f lt1 lt2 =
   match (lt1,lt2) with
     [], [] -> f ()
   | ((Var v)::l1, t2::l2) -> 
        begin
          match v.link with
            NoLink -> 
              begin
		v.link <- TLink t2;
                try
                  let r = match_terms f l1 l2 in
		  v.link <- NoLink;
		  r
                with NoMatch ->
                  v.link <- NoLink;
                  raise NoMatch
	      end
	  | TLink t -> 
	      if not (equal_terms t t2) then raise NoMatch;
	      match_terms f l1 l2
	  | _ -> internal_error "unexpected link in match_terms"
	end
   | ((FunApp (f1,l1'))::l1, (FunApp (f2,l2'))::l2) ->
          if f1 != f2 then raise NoMatch;
          match_terms f (l1' @ l1) (l2' @ l2)
   | _,_ -> raise NoMatch

let match_facts f f1 f2 = match (f1,f2) with
  Pred(chann1, t1),Pred(chann2, t2) ->
   if chann1 != chann2 then raise NoMatch;
   match_terms f t1 t2
| Out(t1,l1),Out(t2,l2) ->
    (* Is it the right direction ? *)
    let len1 = List.length l1 in
    let len2 = List.length l2 in
    if len2 < len1 then raise NoMatch;
    let l2 = skip (len2-len1) l2 in
     List.iter2 (fun (v1,t1) (v2,t2) ->
      if v1 != v2 then raise NoMatch) l1 l2;
    let l1' = List.map snd l1 in
    let l2' = List.map snd l2 in
    match_terms f (t1::l1') (t2::l2')
| _ -> raise NoMatch

(* 3. matching between hypotheses. Try all possible orderings
      of the hypotheses *)
(*
let rec match_hyp1 f h1 = function
    [] -> raise NoMatch
  | (h2::hl2) -> 
        try
          match_facts f h1 h2
        with NoMatch ->
          match_hyp1 f h1 hl2 

let rec match_hyp f hyp1 hyp2 () =
   match hyp1 with
     [] -> f ()
   | (h1 :: hl1) -> match_hyp1 (match_hyp f hl1 hyp2) h1 hyp2

 Test \sigma H \subseteq H' for multiset inclusion
   (whereas the version above is for set inclusion)
*)

let rec match_hyp1 f h1 hyp2 passed_hyp =
   match hyp2 with
     [] -> raise NoMatch
   | (h2::hl2) -> 
        try
          match_facts (f (passed_hyp @ hl2)) h1 h2
        with NoMatch ->
          match_hyp1 f h1 hl2 (h2 :: passed_hyp)

let rec match_hyp f hyp1 hyp2 () =
   match hyp1 with
     [] -> f ()
   | (h1 :: hl1) -> match_hyp1 (match_hyp f hl1) h1 hyp2 []

(* 4. Try to reorder hypotheses to speed up the subsumption test.
      Put first constant hypotheses (no unbound variable. They
      can contain variables already bound by matching the conclusion.)
      Then put other hypotheses in decreasing size order. *)

let rec has_unbound_var = function
    Var v ->
      begin
	match v.link with
	  NoLink -> true
	| TLink _ -> false
	| _ -> internal_error "unexpected link in has_unbound_var"
      end
  | FunApp(_,l) -> List.exists has_unbound_var l

let fact_has_unbound_var = function
    Pred(_, tl) -> List.exists has_unbound_var tl
  | Out(t,l) -> (has_unbound_var t) || (List.exists 
      (fun (v,t) -> has_unbound_var t) l)

let rank f =
  if fact_has_unbound_var f then
    fact_size f
  else
    1000000 (* Something probably bigger than all sizes of terms *)

let rank_compare (_,r1) (_,r2) = r2 - r1

let reorder hyp = 
  if List.length hyp > 4 then
    let hyp_rank = List.map (fun f -> (f, rank f)) hyp in
    let hyp_sorted = List.sort rank_compare hyp_rank in
    List.map (fun (f,_) -> f) hyp_sorted
  else
    hyp

(* 5. The final function for subsumption test *)

let implies ((hyp1, concl1, _, constr1) as r1) ((hyp2, concl2, _, constr2) as r2) =
  if List.length hyp1 > List.length hyp2 then false else
  (* let t0 = Unix.times() in *)
   try 
     match_facts (fun () ->
       match_hyp (implies_constra_list (concl2 :: hyp2) constr2 constr1)
	 (reorder hyp1) hyp2 ()) concl1 concl2;
     (* let t1 = Unix.times() in
     if t1.Unix.tms_utime -. t0.Unix.tms_utime > 1.0 then
       begin
	 print_string "testing implication ";
	 display_rule r1;
	 print_string "=> ";
	 display_rule r2;
	 print_string "implication true, took ";
	 print_float (t1.Unix.tms_utime -. t0.Unix.tms_utime);
	 print_string " seconds.";
	 Display.newline()
       end; *)
     true
   with NoMatch -> 
     (* let t1 = Unix.times() in
     if t1.Unix.tms_utime -. t0.Unix.tms_utime > 1.0 then
       begin
	 print_string "testing implication ";
	 display_rule r1;
	 print_string "=> ";
	 display_rule r2;
	 print_string "implication false, took ";
	 print_float (t1.Unix.tms_utime -. t0.Unix.tms_utime);
	 print_string " seconds.";
	 Display.newline()
       end; *)
      false
(* let implies = Profile.f2 "implies" implies *)

(* The rule base. We distinguish rules that have no selected hypothesis
   [rule_base_ns] and rules that have a selected hypothesis [rule_base_sel].
   The number of the selected hypothesis is stored with the rule
   in the second case. *)

let rule_queue = Queue.new_queue()

let rule_count = ref 0

let rule_base_ns = ref ([] : reduction list)
let rule_base_sel = ref ([] : (reduction * int) list)

(* [add_rule] adds the rule in the rule base.
   It also eliminates subsumed rules. *)

let add_rule rule = 
  (* Check that the rule is not already in the rule base or in the queue *)
  let test_impl = fun r -> implies r rule in
  if (List.exists test_impl (!rule_base_ns)) ||
     (List.exists (function (r,_) -> implies r rule) (!rule_base_sel)) ||
     (Queue.exists rule_queue test_impl) then () else
    begin
      (* eliminates from the rule_base the rules implied by rule *)
      let test_impl = fun r -> not(implies rule r) in
      rule_base_ns := List.filter test_impl (!rule_base_ns);
      rule_base_sel := List.filter
	   (function (r,_) -> not (implies rule r)) (!rule_base_sel);
      Queue.filter rule_queue test_impl;
      Queue.add rule_queue rule
    end


(* Several simplification functions for rules *)

(* 1. Simplify the constraints *)

let simplify_rule_constra next_stage (hyp, concl, hist,constra) =
  try 
    let constra' = simplify_constra_list (concl::hyp) constra in
    next_stage (hyp, concl, hist, constra')
  with FalseConstraint ->
    ()

(* 2. eliminate rules that have in hypothesis a "not" fact
      (secrecy assumption) *)

let elim_not next_stage ((hyp', _, _,_) as r) =
  if (List.exists (fun h -> List.exists (matchafact h) (!not_set)) hyp') then
    ()
  else
    next_stage r

(* 3. eliminate tautologies (rules that conclude a fact already in their
      hypothesis) *)

let elim_taut next_stage ((hyp', concl, _,_) as r) =
  if List.exists (equal_facts concl) hyp' then
    ()
  else
    next_stage r

(* 4. eliminate hypotheses p(x1...xn) where p has been declared "elimVar"
   or "elimVarStrict" and x1...xn do not occur elsewhere.
   Such a declaration means that p(x...x) is true for some value of x. 
   This is correct in particular when p = attacker. When p is declared
   elimVar and we are not in sound_mode, x1...xn are allowed to occur
   in inequalities.

   In sound_mode, we always require that x1...xn do not occur in 
   inequalities. *)

let elim_any_x2 next_stage r =
  next_stage (elim_any_x r)

(* 5. decompose tuples and data constructors in hypotheses
   It is important for the correctness of this optimization that
   p:x is never selected when p is a predicate on which we
   perform the decomposition of data constructors, except
   when there are only such facts in the clause.

   Also eliminates duplicate hypotheses.
 *)

let decompose_hyp_tuples2 next_stage r =
  next_stage (decompose_hyp_tuples r)

(* 6. decompose tuples and data constructors in conclusion
   It is important for the correctness of this optimization that
   p:x is never selected when p is a predicate on which we
   perform the decomposition of data constructors. *)

let list_iter_i f l =
  let rec list_iter_i n = function
      [] -> ()
    | (a::l) -> list_iter_i (n+1) l; f n a
  in
  list_iter_i 0 l

let decompose_concl_tuples next_stage ((hyp', concl, hist', constra) as r) =
  if is_exempt_from_dectuple r then
    next_stage r
  else
    let put_clause first_fact hist =
      if !current_bound_vars != [] then
	Parsing_helper.internal_error "bound vars should be cleaned up (r1)";
      let r = (List.map copy_fact hyp', copy_fact first_fact, hist, List.map copy_constra constra) in
      cleanup();
      next_stage r
    in
    let rec tuple_dec hist concl =
      match concl with
	Pred(chann, l0) ->
	  let rec try_equiv_set = function
	      [] ->
		if chann.p_prop land Param.pred_TUPLE != 0 then
		  match l0 with
		    FunApp(f,_) :: _ when f.f_cat = Tuple ->
		      let l = reorganize_fun_app f l0 in	    
		      list_iter_i (fun n first ->
			let (Rule(_,_,_,Pred(p',_), _)) as hist_dec = History.get_rule_hist (Apply(Proj(f, n), chann)) in
			let concl' = Pred(p', first) in
			let hist'' = Resolution(hist, 0, hist_dec) in
			try 
			  tuple_dec hist'' concl'
			with Not_found -> put_clause concl' hist'') l
		  | _ -> raise Not_found
		else
		  raise Not_found
	    | (hypeq, concleq, neq)::l ->
		try
		  let hypeq' = 
		    Terms.auto_cleanup (fun () ->
		      match_facts2 concleq concl;
		      List.map copy_fact3 hypeq)
		  in
		  list_iter_i (fun n concl' ->
		    let hist_dec = Rule(neq + n + 1, LblEquiv, [concleq], List.nth hypeq n, []) in
		    let hist'' = Resolution(hist, 0, hist_dec) in
		    try 
		      tuple_dec hist'' concl'
		    with Not_found -> put_clause concl' hist''
			) hypeq'
		with NoMatch ->
		  try_equiv_set l
	  in
	  try_equiv_set (!equiv_set)
      | _ -> raise Not_found
    in
    begin
      try
	tuple_dec hist' concl
      with Not_found ->
	next_stage r
    end


(*
let decompose_concl_tuples next_stage ((hyp', concl, hist', constra) as r) =
  if is_exempt_from_dectuple r then
    next_stage r
  else
  match concl with
    Pred(chann, ((FunApp(f,_) :: _) as l0)) when 
      (f.f_cat = Tuple) &&
      (chann.p_prop land Param.pred_TUPLE != 0) ->
        let rec tuple_make hist' f n = function
            [] -> ()
          | (first::rest) -> 
              tuple_make hist' f (n+1) rest;
	      let hist_dec = History.get_rule_hist (Apply(Proj(f, n), chann)) in
              let hist'' = Resolution(hist', 0, hist_dec) in
              match first with 
                FunApp(f,_) :: _ when f.f_cat = Tuple -> 
		  begin
		    try
		      let l = reorganize_fun_app f first in
		      tuple_make hist'' f 0 l
		    with Not_found ->
		      if !current_bound_vars != [] then
			Parsing_helper.internal_error "bound vars should be cleaned up (r1)";
                      let first_fact = Pred(chann,first) in
                      let r = (List.map copy_fact hyp', copy_fact first_fact, hist'', List.map copy_constra constra) in
		      cleanup();
                      next_stage r
		  end
              | _ -> 
		  if !current_bound_vars != [] then
		    Parsing_helper.internal_error "bound vars should be cleaned up (r1)";
                  let first_fact = Pred(chann,first) in
                  let r = (List.map copy_fact hyp', copy_fact first_fact, hist'', List.map copy_constra constra) in
		  cleanup();
                  next_stage r
	in
	begin
	  try
	    let l = reorganize_fun_app f l0 in
            tuple_make hist' f 0 l
	  with Not_found ->
	    next_stage r
	end
  | _ -> next_stage r
*)

(* Simplification for reflexive and transitive predicates
   whose arguments are known by the attacker, 
   by Avik Chaudhuri and Bruno Blanchet *)

let no_occurrence_except_attacker v = function 
    Pred(c,[Var x]) when c.p_prop land Param.pred_ATTACKER != 0 && x == v -> 
      true
  | Pred(c,ts) -> not (List.exists (occurs_var v) ts)
  | Out(t,bts) -> 
           (not (occurs_var v t)) 
	&& (not (List.exists (fun (_,t) -> occurs_var v t) bts))  

let elim_attacker v n f = function
    Pred(c,[Var x]) when c.p_prop land Param.pred_ATTACKER != 0 && x == v -> 
      Some (fun hist -> Any(n,f hist))
  | _ -> None

(* [check_hypR c y z hypR] checks that [hypR] contains a fact
   Pred(c, [x; Var y]), y occurs in hypR only in that fact and 
   in attacker(y) facts. Pred(c, [x; Var y]) is then replaced with
   Pred(c, [x; z]). *)

let rec check_hypR c y z = function
    [] -> raise Not_found 
  | (Pred(c', [x;Var y']))::l 
    when c' == c
      && y' == y 
      && (not (occurs_var y x))
      && List.for_all (no_occurrence_except_attacker y) l ->
	(Pred(c', [x;z]))::l
  | a::l ->
      if no_occurrence_except_attacker y a then
	a::(check_hypR c y z l)
      else
	raise Not_found

let rec candidate constra concl hypL = function
   [] -> None
 | (_::[]) -> None
 | ((Pred(c,[Var y;z])) as a::hypR) 
        when c.p_prop land Param.pred_REFTRANS !=0
          && (not (occurs_var y z))
          && List.for_all (no_occurrence_except_attacker y) hypL
          && fact_occur_count y concl == 0
          && occur_count_constra y constra == 0 -> 
	    begin
	      try 
		let hypR' = check_hypR c y z hypR in
		let (hypL',_,f) = List.fold_right
                    (fun hyp (hs,n,f) ->
                      match elim_attacker y n f hyp with
			None -> ((hyp::hs),n+1,f)
                      | Some f -> (hs,n,f)
			    )
                    hypL ([],0,fun hist -> hist) in
		let (hypRcL',_,f') = List.fold_left
                    (fun (hs,n,f') hyp ->
                      match elim_attacker y n f' hyp with
			None -> ((hyp::hs),n+1,f')
                      | Some f' -> (hs,n,f')
			    )
                    (hypL',(List.length hypL')+1,f) hypR' in
		Some(List.rev hypRcL',
		     fun hist -> Resolution(Rule(-1,LblNone,[],Pred(c,[Var y;Var y]),[]),List.length hypL',f' hist))
	      with Not_found -> 
		candidate constra concl (a::hypL) hypR
	    end
 | (a::l) -> candidate constra concl (a::hypL) l


let rec simp_transitive next_stage ((hyp',concl,hist',constra) as r) = 
  match candidate constra concl [] hyp' with
    None -> next_stage r
  | Some(simp_hyp',f) -> simp_transitive next_stage (simp_hyp',concl,f hist',constra)
  
(* End of simplification of reflexive and transitive predicates by
   Avik Chaudhuri and Bruno Blanchet *)

(* 7. Element simplification 
     att(x) /\ elem(M_1, x) /\ ... /\ elem(M_n, x)
   becomes
     att(M_1) /\ ... /\ att(M_n)
   when x does not occur elsewhere in the clause.
   When x occurs elsewhere, the simplification can be done when the
   clause has no selected fact. It leads to a loss of precision in
   this case. (So the latter case is disabled in sound mode.)

   "att" can be any predicate declared with data decomposition (pred_TUPLE).
   The predicate "elem" must be declared pred_ELEM.
   *)

let rec collect_preds v = function
    [] -> []
  | (f::l) -> 
      match f with
	Pred(p, [Var v']) when p.p_prop land Param.pred_TUPLE != 0 
	    && v' == v ->
	      p :: (collect_preds v l)
      | _ -> collect_preds v l


let rec transform_hyp preds v hist n = function
    [] -> ([], hist)
  | (f::l) ->
      match f with
	Pred(p, [t1; Var v']) when p.p_prop land Param.pred_ELEM != 0 
	      && v == v' ->
		let (Rule(_, _, hyp, _, _)) as hist_dec = History.get_rule_hist (Elem(preds, p)) in
		let hist' = Resolution(hist_dec, n,  hist) in
		let (l', hist'') = transform_hyp preds v hist' (n + List.length preds) l in
		((List.map (function 
		    (Pred(p',_)) -> Pred(p', [t1])
		  | Out _ -> Parsing_helper.internal_error "rules.ml: Pred expected") hyp) @ l', hist'')
      | _ -> 
	  let (l', hist') = transform_hyp preds v hist (n+1) l in
	  (f :: l', hist')

let transform_rule v (hyp, concl, hist, constra) =
  let preds = collect_preds v hyp in
  let (hyp', hist') = transform_hyp preds v hist 0 hyp in
  (hyp', concl, hist', constra)

let check_occurs_fact p0 v = function
    Pred(p, [Var v']) when p.p_prop land Param.pred_TUPLE != 0 
	      && v == v' -> false
  | Pred(p, [t1; Var v']) when p.p_prop land Param.pred_ELEM != 0 && p == p0
	      && v == v' -> occurs_var v t1
  | Pred(p, tl) -> List.exists (occurs_var v) tl
  | Out(t, env) -> (occurs_var v t) || (List.exists (fun (_, t) -> occurs_var v t) env)

let check_occurs_concl v = function
  | Pred(p, tl) -> List.exists (occurs_var v) tl
  | Out(t, env) -> internal_error "Out fact should not occur in conclusion"

let check_occurs_constra v c = List.exists 
    (function Neq(t1,t2) -> occurs_var v t1 || occurs_var v t2) c

let check_occurs_rule p0 v (hyp, concl, hist, constra) =
  List.exists (check_occurs_fact p0 v) hyp ||
  (check_occurs_concl v concl) ||
  List.exists (check_occurs_constra v) constra

(* 8.1 Apply the simplification only when x does not occur
   in bad positions. No loss of precision in this case *)

let rec elem_simplif next_stage repeat_next_stage ((hyp, concl, hist, constra) as r) =
  let rec find_optim seen_vars = function
      [] -> next_stage r
    | (f::l) ->
	match f with
	  Pred(p,[t1;Var v]) when p.p_prop land Param.pred_ELEM != 0 
	      && not (List.memq v seen_vars) ->
		if check_occurs_rule p v r then
		  find_optim (v::seen_vars) l
		else
		  repeat_next_stage (transform_rule v r)
	| _ -> find_optim seen_vars l
  in
  find_optim [] hyp

(* 8.2 When the conclusion is selected, apply the simplification
   event at the cost of a loss of precision
   Disabled in sound mode. *)

let rec elem_simplif2 next_stage repeat_next_stage ((hyp, concl, hist, constra) as r) =
  let rec find_optim = function
      [] -> next_stage r
    | (f::l) ->
	match f with
	  Pred(p,[t1;Var v]) when (p.p_prop land Param.pred_ELEM != 0)
	    && (collect_preds v hyp <> []) ->
	    if Selfun.selection_fun r = -1 then
              let r' = transform_rule v r in
              print_string "Warning: simplifying ";
              Display.display_rule r;
              print_string "into ";
              Display.display_rule r';
              print_string "with loss of precision.\n";
	      repeat_next_stage r'
	    else
	      next_stage r
	| _ -> find_optim l
  in
  if !sound_mode then
    next_stage r 
  else
    find_optim hyp

(* 9. Eliminate redundant hypotheses 
   When R = H /\ H' -> C, and there exists \sigma such that
   \sigma H \subseteq H' and \sigma does not modify variables
   of H' and C, then R can be replaced with R' = H' -> C.
   This is a generalization of elimination of duplicate hypotheses.
   (In the history, code them as duplicate hypotheses.)

   Redundant hypotheses appear in particular when there are 
   begin facts. They can slow down the subsumption test
   considerably.

*)

let rec match_hyp1 f h1 = function
    [] -> raise NoMatch
  | (h2::hl2) -> 
        try
          (h1, h2)::(match_facts f h1 h2)
        with NoMatch ->
          match_hyp1 f h1 hl2 

let rec match_hyp f hyp1 hyp2 () =
   match hyp1 with
     [] -> f ()
   | (h1 :: hl1) -> match_hyp1 (match_hyp f hl1 hyp2) h1 hyp2

let implies2 (hyp1, concl1, _, constr1) (hyp2, concl2, _, constr2) =
  match_facts (fun () ->
    match_hyp (fun () -> implies_constra_list (concl2 :: hyp2) constr2 constr1 (); [])
      (reorder hyp1) hyp2 ()) concl1 concl2

(*** Just a sanity check

let rec match_hyp3 f hyp1 hyp2 () =
   match (hyp1,hyp2) with
     [],[] -> f ()
   | (h1 :: hl1),(h2::hl2) -> match_facts (match_hyp3 f hl1 hl2) h1 h2

let implies3 ((hyp1, concl1, _, constr1) as r1) ((hyp2, concl2, _, constr2) as r2) =
  try
  match_facts (fun () ->
    match_hyp3 (implies_constra_list (concl2 :: hyp2) constr2 constr1)
      hyp1 hyp2 ()) concl1 concl2
  with NoMatch -> Parsing_helper.internal_error "elim_redundant_hyp"

    End sanity check ***)

(* Find useless hyp can be very slow! *)
let rec find_useless_hyp next_stage repeat_next_stage r concl hist constra seenhyp = function
    [] -> (* print_string "find_useless_hyp done"; Display.newline(); *) next_stage r
  | (Pred(_,_) as a)::l when !Param.redundant_hyp_elim_begin_only ->
      find_useless_hyp next_stage repeat_next_stage r concl hist constra (a::seenhyp) l 
  | a::l -> 
      let hyp' = List.rev_append seenhyp l in
      try 
	let match_list = implies2 r (hyp', concl, hist, constra) in
	let (hyp,_,_,_) = r in
	let hyp'' = List.map (fun f -> List.assq f match_list) hyp in
	(* implies3 r (hyp'', concl, hist, constra); *)
	(* print_string "find_useless_hyp done 2"; Display.newline(); *)
	repeat_next_stage (hyp'', concl, hist, constra)
      with NoMatch ->
	find_useless_hyp next_stage repeat_next_stage r concl hist constra (a::seenhyp) l 

let elim_redundant_hyp next_stage repeat_next_stage r =
  if !Param.redundant_hyp_elim then
    let (hyp, concl, hist, constra) = copy_rule r in
    (* print_string "find_useless_hyp starts for";  
    display_rule r; *)
    find_useless_hyp next_stage repeat_next_stage r concl hist constra [] hyp
  else
    next_stage r

(* 10. Simplification using the equational theory *)

let simp_eq_rule next_stage repeat_next_stage ((hyp, concl, hist, constra) as rule) =
  if TermsEq.hasEquations() then
    try
      let redo_all_optim = ref false in
      let simp_eq_fact = function
	  Pred(p,l) when p.p_prop land Param.pred_SIMPEQ != 0 ->
	    Pred(p, List.map (fun t ->
	      let t' = TermsEq.simp_eq t in
	      if not (Terms.equal_terms t t') then redo_all_optim := true;
	      t') l)
	| f -> f
      in
      let rule' = (List.map simp_eq_fact hyp, simp_eq_fact concl, hist, constra) in
      if !redo_all_optim then
	repeat_next_stage rule'
      else
	next_stage rule'
    with TermsEq.Reduces ->
      () (* Remove the clause when Param.simpeq_remove is true and an argument
            of attacker2 reduces. *)
  else
    next_stage rule

(* Combines the previous simplication functions, then add the
   simplified rule to the rule base *)

let simplify_rule_constra_normal next_stage r =
  if !Terms.current_bound_vars != [] then
      Parsing_helper.internal_error "bound vars should be cleaned up (simplify_rule_constra - normal)";
  simplify_rule_constra next_stage r

let rec normal_rule r = 
  if !Terms.current_bound_vars != [] then
      Parsing_helper.internal_error "bound vars should be cleaned up (normal)";
  decompose_hyp_tuples2 (simp_eq_rule 
    (elim_redundant_hyp (elim_not (Weaksecr.simplify (Noninterf.simplify 
    (decompose_concl_tuples (elim_taut (elim_any_x2 
    (simplify_rule_constra_normal (simp_transitive (elem_simplif (elem_simplif2
    (fun r -> add_rule (limit_depth_rule r)) normal_rule) normal_rule) )))))
       normal_rule) normal_rule)) normal_rule) normal_rule) r

(* Equations *)

(* Close rules under equations *)

let rec complete_rules_eq () =
   match Queue.get rule_queue with
     None -> !rule_base_ns
   | Some rule -> 
       rule_base_ns := rule :: (!rule_base_ns);
       close_rule_eq normal_rule (copy_rule rule);
       if !Param.verbose_rules then
         display_rule rule
       else
         begin
           incr rule_count;
	   if (!rule_count) mod 200 = 0 then
	     begin
	       print_string ((string_of_int (!rule_count)) ^ 
			     " rules inserted. The rule base contains " ^
			     (string_of_int (List.length (!rule_base_ns))) ^
			     " rules. " ^
			     (string_of_int (Queue.length rule_queue)) ^
			     " rules in the queue.");
	       Display.newline()
	     end
	 end;
       complete_rules_eq()

(* Close fact under equations *)

let combine_fact_eq fact =
   let accu = ref [] in
   close_fact_eq (fun fact' ->
     let tmp_bound = !current_bound_vars in
     current_bound_vars := [];
     accu := (copy_fact2 fact') :: (!accu);
     cleanup();
     current_bound_vars := tmp_bound) fact;
   !accu

(* End equations *)

(* [compos] unifies [concl1] with the selected hypothesis of [hyp2]
   and builds the resulting rule 
   There must be no selected fact in [rule1], and a selected fact in [rule2]

   R = F1 & ... & Fn -> F0
   R' = F'1 & ... & F'n' -> F'0
can be composed into
      s F1 & ... & s Fn & s F'2 & ... & s F'n -> s F'0
where s is the most general unifier of F0 and F'1
if 
    F'1 selected 
and for all Fi, Fi not selected

*)

let rec replace_nth_list l1 n = function
    [] -> internal_error "replace_nth_list error"
  | (a::l) -> if n = 0 then l1 @ l else a::(replace_nth_list l1 (n-1) l)

let compos next_stage (hyp1, concl1, hist1,constra1) ((hyp2, concl2, hist2,constra2), sel_index) =
  let a = List.nth hyp2 sel_index in
  (* compose with the selected fact *)
  if !current_bound_vars != [] then
    Parsing_helper.internal_error "bound vars should be cleaned up (r4)";
  try
    unify_facts concl1 a;
    let hyp' = List.map copy_fact2 (replace_nth_list hyp1 sel_index hyp2) in
    (* Careful ! The order of hypotheses is important for the history *)
    let concl' = copy_fact2 concl2 in
    let hist' = Resolution(hist1, sel_index, hist2) in
    let constra' = ((List.map copy_constra2 constra1) @ (List.map copy_constra2 constra2)) in
    cleanup();
  (*  incr resol_step; *)
    next_stage (hyp', concl', hist', constra')
  with Unify -> 
    cleanup()

(* Redundancy test 
   [rulelist] and [firstrulelist] must be lists of rules with empty selection
   [initrule] must be a rule with empty selection
   The test returns true if and only if the rule [initrule] can be derived 
   with a derivation containing a rule in [firstrulelist] as top rule 
   and other rules in [rulelist].
*)

let dummy_channel = { p_name = "dummy"; p_type = []; p_prop = 0; p_info = [] }
let dummy_fact = Pred(dummy_channel, [])

exception Redundant

let redundant rulelist firstrulelist ((_,initconcl,_,_) as initrule) =
  let rec redundant_rec firstrulelist ((hyp, concl, hist, constra) as rule) seen_list =
    if matchafact initconcl concl then
      let sel_index = selection_fun (hyp, dummy_fact, hist, constra) in
      if sel_index != -1 then
	if not (List.exists (fun r -> implies r rule) seen_list) then 
	  let seen_list = rule :: seen_list in
	  List.iter (fun ((hyp1, _, _, _) as rule1) ->
	    if List.for_all is_unselectable hyp1 then
	    compos (simplify_rule_constra (fun r -> 
	      let r' = elim_any_x (decompose_hyp_tuples r) in
              if implies r' initrule then
		raise Redundant
	      else
		redundant_rec rulelist r' seen_list)) 
	      rule1 (rule,sel_index)
		    ) firstrulelist
  in
  try
    redundant_rec firstrulelist ([initconcl], initconcl, Empty(initconcl), []) [];
    false
  with Redundant ->
    if !Param.verbose_redundant then
      begin
	print_string "Redundant rule eliminated:\n";
	display_rule initrule
      end;
    true

let redundant_glob initrule =
  match !Param.redundancy_test with
    Param.NoRed -> false
  | Param.SimpleRed -> 
      redundant (!rule_base_ns) (!rule_base_ns) initrule 
  | Param.BestRed -> 
      if redundant (!rule_base_ns) (!rule_base_ns) initrule then true else
      let rec all_redundant accu = function
	  [] -> accu
	| (a::l) -> 
	    let rlist = initrule :: (accu @ l) in
	    if redundant rlist rlist a then 
	      all_redundant accu l
	    else
	      all_redundant (a::accu) l
      in
      rule_base_ns := List.rev (all_redundant [] (!rule_base_ns));
      false 


let redundant_res res_list =
  let rec all_redundant accu = function
      [] -> accu
    | (a::l) ->
	if redundant (!rule_base_ns) (accu @ l) a then
	  all_redundant accu l
	else
	  all_redundant (a::accu) l
  in
  all_redundant [] res_list

(* Saturates the rule base, by repeatedly applying the composition [compos] *)

let rec complete_rules () =
   match Queue.get rule_queue with
     None -> !rule_base_ns
   | Some rule -> 
       let sel_index = selection_fun rule in
       if sel_index == -1 then
	 begin
	   if not (redundant_glob rule) then
	     begin
	       rule_base_ns := rule :: (!rule_base_ns);
	       List.iter (compos normal_rule rule) (!rule_base_sel)
	     end
	 end
       else
	 begin
	   let rule_sel = (rule, sel_index) in
	   rule_base_sel := rule_sel :: (!rule_base_sel);
	   List.iter (fun rule2 -> compos normal_rule rule2 rule_sel) (!rule_base_ns)
	 end;

       (* display the rule *)
       if !Param.verbose_rules then
         display_rule rule
       else
	 begin
	   incr rule_count;
	   if (!rule_count) mod 200 = 0 then
	     begin
	       print_string ((string_of_int (!rule_count)) ^ 
			     " rules inserted. The rule base contains " ^
			     (string_of_int ((List.length (!rule_base_ns))
					   + (List.length (!rule_base_sel)))) ^
			     " rules. " ^
			     (string_of_int (Queue.length rule_queue)) ^
			     " rules in the queue.");
	       Display.newline()
	     end
	 end;
       
       complete_rules()


(* Search algo *)

let query_goal_std g =
  let success_accu = ref [] in
  let rec goal_reachable_rec ((subgoals, orig_fact, hist_done, constra) as rule) 
    seen_list =
    if not (List.exists (fun old_rule -> implies old_rule rule) (!success_accu))
    then
      (* if already found a way to generate a more general pattern,
	 stop here; otherwise, continue search *)
      let sel_index = selection_fun (subgoals, dummy_fact, hist_done, constra) in
      if sel_index == -1 then
	success_accu := rule :: (!success_accu)
      else
	begin
	  if not (List.exists (fun r -> implies r rule) seen_list) then 
	  let seen_list = rule :: seen_list in
	  List.iter (fun rule1 ->
	    compos (simplify_rule_constra (fun r -> 
	      goal_reachable_rec (elim_any_x (decompose_hyp_tuples r)) seen_list)) 
	      rule1 (rule,sel_index)
		    ) (!rule_base_ns)
	end
  in
  let do_query a =
    goal_reachable_rec (elim_any_x (decompose_hyp_tuples ([a], a, Empty(a),[]))) []
  in
  List.iter do_query (combine_fact_eq g);
  redundant_res (!success_accu)
(*
  let r = redundant_res (!success_accu) in
  print_int (!resol_step);
  print_string " resolution steps since the beginning\n";
  r
*)

let query_goal g = 
  match query_goal_std g with
    [] -> print_string "RESULT goal unreachable: ";
      display_fact g;
      Display.newline()
  | l -> 
      List.iter (fun rule ->
	print_string "goal reachable: ";
	display_rule rule;
	ignore (History.build_history rule);
	cleanup();
	Display.newline();
		) l;
      print_string "RESULT goal reachable: ";
      display_fact g;
      Display.newline()

let query_goal_not g = 
  match query_goal_std g with
    [] -> print_string "ok, secrecy assumption verified: fact unreachable ";
      display_fact g;
      Display.newline()
  | l -> 
      List.iter (fun rule ->
	print_string "goal reachable: ";
	display_rule rule;
	ignore (History.build_history rule);
	cleanup();
	Display.newline();
		) l;
      Parsing_helper.user_error "Error: you have given a secrecy assumption that I could not verify.\n"

let completion rulelist =
  (* Enter the rules given in "rulelist" in the rule base *)
  if (!Param.verbose_explain_clauses != Param.NoClauses) || 
     (!Param.explain_derivation = false) then
    begin
      print_string "Starting rules:\n";
      List.iter display_rule_num rulelist
    end;

  (* Reinit the rule base *)
  rule_base_ns := [];
  rule_base_sel := [];
  rule_count := 0;

  (* Complete the rule base *)
  List.iter normal_rule rulelist;
  Selfun.guess_no_unif rule_queue;

  if hasEquationsToRecord() then
  begin
    record_eqs();
    print_string "Completing with equations...\n";
    let rulelisteq = complete_rules_eq() in
    if !Param.verbose_completed then
      begin
	print_string "Completed rules:\n";
	List.iter display_rule rulelisteq
      end;
    rule_base_ns := [];
    List.iter normal_rule rulelisteq
  end;

  print_string "Completing...\n";
  let completed_rules = complete_rules() in
  if !Param.verbose_completed then
    begin
      print_string "Completed rules:\n";
      List.iter display_rule completed_rules
    end;
      
  (* Query the goals *)
  List.iter query_goal_not (!not_set)



let main_analysis rulelist goal_set =
  completion rulelist;
  List.iter query_goal goal_set

let reset () =
  Selfun.reset_no_unif_set();
  not_set := []

(* Test whether bad is derivable from rulelist; 
   this function does not alter rule_base_ns, so that it can be called
   even if I am calling query_goal_std afterwards to test whether some fact
   is derivable from other completed clauses.
   It is guaranteed to say that bad is not derivable only if it is
   actually not derivable. *)

let bad_derivable rulelist =
  let old_rule_base_ns = !rule_base_ns in
  completion rulelist;
  let saturated_rules = !rule_base_ns in
  rule_base_ns := old_rule_base_ns;
  rule_base_sel := [];
  List.filter (function
      (_, Pred(p, []), _, _) when p == Param.bad_pred -> 
	true
    | _ -> false) saturated_rules

(* Test whether bad is derivable from rulelist; 
   this function does not alter rule_base_ns, so that it can be called
   even if I am calling query_goal_std afterwards to test whether some fact
   is derivable from other completed clauses.
   Furthermore, it is guaranteed to say that that bad is derivable only
   if it is actually derivable *)

let sound_bad_derivable rulelist =
  let old_sound_mode = !sound_mode in
  sound_mode := true;
  let r = bad_derivable rulelist in
  sound_mode := old_sound_mode;
  r
