(*************************************************************
 *                                                           *
 *       Cryptographic protocol verifier                     *
 *                                                           *
 *       Bruno Blanchet                                      *
 *                                                           *
 *       Copyright (C) ENS, CNRS, INRIA, 2005-2011           *
 *                                                           *
 *************************************************************)

(*

    Copyright ENS, CNRS, INRIA 
    contributor: Bruno Blanchet, Bruno.Blanchet@ens.fr
    
This software is a computer program whose purpose is to verify 
cryptographic protocols in the computational model.

This software is governed by the CeCILL-B license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the CeCILL-B
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the CeCILL-B license and that you accept its terms.

*)
open Types

let rec check_no_ifletfindres t =
  match t.t_desc with
    Var(_,l) | FunApp(_,l) ->
      List.for_all check_no_ifletfindres l
  | TestE _ | FindE _ | LetE _ | ResE _ | EventE _ ->
      false

let filter_ifletfindres l =
  List.filter check_no_ifletfindres l

(* Display facts; for debugging *)

let display_facts (subst2, facts, elsefind) =
  print_string "Substitutions:\n";
  List.iter (fun t -> Display.display_term [] t; print_newline()) subst2;
  print_string "Facts:\n";
  List.iter (fun t -> Display.display_term [] t; print_newline()) facts;
  print_string "Elsefind:\n";
  List.iter (fun (bl, def_list, t) ->
    print_string "for all ";
    Display.display_list Display.display_binder bl;
    print_string "; not(defined(";
    Display.display_list (fun (b,l) -> Display.display_var [] b l) def_list;
    print_string ") && ";
    Display.display_term [] t;
    print_string ")";
    print_newline()
    ) elsefind

(* On demand substitutions 

let try_no_var (subst, facts) t =
   when t is FunApp(_), return t itself.
   when t is Var(_), try applying substitutions until t becomes FunApp(_)
   if impossible, return t itself.

   It may be necessary to apply subtitutions to strict subterms of t
   in order to be able to apply another substitution to t itself.

   Apply on demand substitution when 
   - a matching for a reduction rule meets a variable when
   it expects a function symbol
   - unification called when we have an inequality meets a 
   different variable on both sides 
   - we have a variable in a boolean formula (x && ...), ...
   - equality between a variable and a variable or a tuple
   - let (...) = x[...] substitute x

Substitutions map variables x[...] to some term.

Difficulty = avoid loops; when should I stop applying substitutions
to avoid cycles? Do not reapply the same subtitution in a term
that comes from its image term, perhaps after transformation.
The difficulty is to follow what the term becomes during these
transformations.
Possible transformations are:
   - applying another substitution
   - applying a reduction rule, which does not change variables.
So keep a mapping (occ, M -> M') of forbidden substitutions,
and update it when applying a substitution. If this substitution
transforms N into N', and occ is in N then add (occ', M -> M')
for each occ' occurrence of a variable in N'.

*)

let no_dependency_anal = fun _ _ _ -> false

let rec orient t1 t2 = 
  match t1.t_desc, t2.t_desc with
    (Var(b1,l1), Var(b2,l2)) when
    (not (Terms.refers_to b1 t2)) && (not (Terms.refers_to b2 t1)) &&
    (not (Terms.is_restr b1)) && (not (Terms.is_restr b2)) ->
      (* Both orientations would be possible, try to discriminate using
         priorities *)
      b1.priority >= b2.priority
  | (Var(b,l), _) when
    (not (match t2.t_desc with
            FunApp(f,_) when (f.f_options land Settings.fopt_DECOMPOS) != 0 -> true
          | _ -> Terms.refers_to b t2)) && 
    (not (Terms.is_restr b)) -> true
  | (Var(b1,l1), Var(b2,l2)) when
    (b1 == b2) && (List.for_all2 orient l1 l2) -> true
  | _ -> false
    
(* Applying a substitution that maps x[M1,...,Mn] to M' *)

let reduced_subst = ref false

let rec apply_subst1 t tsubst =
  match t.t_desc with
    FunApp(f,l) -> t
  | _ ->
     match tsubst.t_desc with
       FunApp(f,[redl;redr]) when f.f_cat == Equal || f.f_cat == LetEqual ->
         begin
           if Terms.equal_terms t redl then 
	     begin
	       reduced_subst := true;
	       redr
	     end
           else
             match t.t_desc with
               Var(b,l) ->
	         Terms.build_term2 t (Var(b, List.map (fun t' -> apply_subst1 t' tsubst) l))
(*    
             | FunApp(f,l) ->
	         Terms.build_term2 t (FunApp(f, List.map (fun t' -> apply_subst1 t' tsubst) l))
*)
             | _ -> t
         end
     | _ -> Parsing_helper.internal_error "substitutions should be Equal or LetEqual terms"

let rec apply_all_subst t = function
    [] -> t
  | (a::l) ->
      let t' = apply_subst1 t a in
      if !reduced_subst then t' else apply_all_subst t l

let rec try_no_var ((subst2, _, _) as simp_facts) t =
  match t.t_desc with
    FunApp(f,l) -> t
  | Var(b,l) -> 
      reduced_subst := false;
      let t' = apply_all_subst t subst2 in
      if !reduced_subst then 
	try_no_var simp_facts t' 
      else
	t
  | TestE _ | FindE _ | LetE _ | ResE _ | EventE _ -> 
      Display.display_term [] t; print_newline();
      Parsing_helper.internal_error "If, find, let, and new should not occur in try_no_var"

(* [unify_terms simp_facts t t'] tests equality between [t] and [t'], 
   modulo rewrite rules in [simp_facts].
   Returns the common form when they are equal;
   raises NoMatch otherwise.  *)

let rec unify_terms simp_facts t t' =
  (* print_string "Trying to unify "; Display.display_term [] t; print_string " and "; Display.display_term [] t'; print_newline(); *)
  match t.t_desc,t'.t_desc with
    ((TestE _ | FindE _ | LetE _ | ResE _ | EventE _), _)
  | (_, (TestE _ | FindE _ | LetE _ | ResE _ | EventE _)) ->
      Display.display_term [] t; print_newline();
      Parsing_helper.internal_error "If, find, let, and new should not occur in unify_terms"
  | (Var(b,l), Var(b',l')) when Terms.equal_terms t t' -> t
  | _ ->
      let t1 = try_no_var simp_facts t in
      let t1' = try_no_var simp_facts t' in
      match (t1.t_desc, t1'.t_desc) with
	Var(b,l), Var(b',l') -> if Terms.equal_terms t1 t1' then t1 else raise NoMatch
      | FunApp(f,[t1;t2]), FunApp(f',[t1';t2']) when f == f' && f.f_options land Settings.fopt_COMMUT != 0 ->
          (* Commutative function symbols *)
          begin
          try
            Terms.build_term2 t (FunApp(f, [ unify_terms simp_facts t1 t1';
					     unify_terms simp_facts t2 t2']))
          with NoMatch ->
            Terms.build_term2 t (FunApp(f, [ unify_terms simp_facts t1 t2';
					     unify_terms simp_facts t2 t1']))
          end
      |	FunApp(f,l), FunApp(f',l') when f == f' ->
	  Terms.build_term2 t (FunApp(f, List.map2 (unify_terms simp_facts) l l'))
      |	_ -> raise NoMatch


(* simp_equal_terms tests equality between t1 and t2, modulo rewrite rules in 
   simp_facts. Returns true when equal, false otherwise.  *)

let simp_equal_terms simp_facts t1 t2 =
  try 
    ignore(unify_terms simp_facts t1 t2); 
    true 
  with NoMatch -> 
    false

(* Apply reduction rules defined by statements to term t *)

let rec match_term next_f simp_facts restr t t' = 
  match t.t_desc with
    Var (v,[]) -> 
    (* Check that types match *)
      if t'.t_type != v.btype then
	raise NoMatch;
      begin
	match v.link with
	  NoLink -> 
	    if List.memq v restr then
	      (* t' must be a variable created by a restriction *)
	      begin
		if not (t'.t_type == v.btype) then
		  raise NoMatch;
		match t'.t_desc with
		  Var(b,l) when Terms.is_restr b -> ()
		| _ -> raise NoMatch
	      end;
	    Terms.link v (TLink t')
	| TLink t -> 
	    v.link <- TLink (unify_terms simp_facts t t')
      end;
      next_f()
  | FunApp(f,[t1;t2]) when f.f_options land Settings.fopt_COMMUT != 0 ->
      (* Commutative function symbols *)
      begin
	match (try_no_var simp_facts t').t_desc with
	  FunApp(f',[t1';t2']) when f == f' ->
            begin
              try
                Terms.auto_cleanup (fun () ->
	          match_term (fun () -> match_term next_f simp_facts restr t2 t2') simp_facts restr t1 t1')
              with NoMatch ->
                match_term (fun () -> match_term next_f simp_facts restr t2 t1') simp_facts restr t1 t2'
            end
	| _ -> raise NoMatch
      end
  | FunApp(f,l) ->
      begin
	match (try_no_var simp_facts t').t_desc with
	  FunApp(f',l') when f == f' ->
	    match_term_list next_f simp_facts restr l l'
	| _ -> raise NoMatch
      end
  | Var _ | TestE _ | FindE _ | LetE _ | ResE _ | EventE _ ->
      Parsing_helper.internal_error "Var with arguments, if, find, let, new, event should not occur in match_term"

and match_term_list next_f simp_facts restr l l' = 
  match l,l' with
    [],[] -> next_f()
  | a::l,a'::l' ->
      match_term (fun () -> match_term_list next_f simp_facts restr l l') 
	simp_facts restr a a'
  | _ -> Parsing_helper.internal_error "Different lengths in match_term_list"

let reduced = ref false

(* apply_not_red implements reduction rules 
     not (x = y) -> x != y
     not (x != y) -> x = y
     x = x -> true
     x != x -> false
(These rules cannot be stored in file default, because there are several
functions for = and for !=, one for each type.)
*)

let rec apply_not_red simp_facts t =
  match t.t_desc with
    FunApp(fnot, [t']) when fnot == Settings.f_not ->
      begin
      let t' = try_no_var simp_facts t' in
      match t'.t_desc with
	FunApp(feq, [t1;t2]) when feq.f_cat == Equal ->
	  reduced := true;
	  Terms.make_diff t1 t2
      |	FunApp(fdiff, [t1;t2]) when fdiff.f_cat == Diff ->
	  reduced := true;
	  Terms.make_equal t1 t2
      |	_ -> Terms.make_not (apply_not_red simp_facts t')
      end
  | FunApp(f,[t1;t2]) when f.f_cat == Equal && (simp_equal_terms simp_facts t1 t2) ->
      reduced := true;
      Terms.make_true()
  | FunApp(f,[t1;t2]) when f.f_cat == Diff && (simp_equal_terms simp_facts t1 t2) ->
      reduced := true;
      Terms.make_false()
  | FunApp(f,[t1;t2]) when f == Settings.f_and ->
      Terms.make_and (apply_not_red simp_facts t1) (apply_not_red simp_facts t2)
  | FunApp(f,[t1;t2]) when f == Settings.f_or ->
      Terms.make_or (apply_not_red simp_facts t1) (apply_not_red simp_facts t2)
  | FunApp(f,l) ->
      Terms.build_term2 t (FunApp(f, List.map (apply_not_red simp_facts) l))
  | _ -> t

let rec check_indep v = function
    [] -> []
  | v'::l ->
      let l_indep = check_indep v l in
      match v.link, v'.link with
	TLink { t_desc = Var(b,l) }, TLink { t_desc = Var(b',l') } ->
	  if b == b' then
	    (Terms.make_and_list (List.map2 Terms.make_equal l l')):: l_indep
	  else
	    l_indep
      |	_ -> Parsing_helper.internal_error "variables should be linked in check_indep"
	  
let rec check_indep_list = function
    [] -> []
  | [v] -> []
  | (v::l) ->
      (check_indep v l) @ (check_indep_list l)

let rec apply_red simp_facts t (restr,proba,redl,redr) =
  match t.t_desc with
    FunApp(f,l) ->
      begin
	try
	  match_term (fun () -> 
	    let t' = Terms.copy_term redr in
	    let l_indep = check_indep_list restr in
	    let t'' =
	      if l_indep == [] then
		(* All restrictions are always independent, nothing to add *)
		t' 
	      else
		begin
		  if not (Terms.is_false redr) then
		    (* I can test conditions that make restrictions independent only
		       when the result "redr" is false *)
		    raise NoMatch;
		  (* When redr is false, the result "If restrictions
		     independent then redr else t" is equal to
		     "(restrictions not independent) and t" which we
		     simplify.  We keep the transformed value only
		     when t has been reduced, because otherwise we
		     might enter a loop (applying the collision to t
		     over and over again). *)
		  Terms.make_or_list 
		    (List.map (fun f ->
		      let reduced_tmp = !reduced in
		      reduced := false;
		      let t1 = Terms.auto_cleanup (fun () ->
			apply_all_red (simplif_add no_dependency_anal simp_facts f) t (!Transform.statements))
		      in
		      if not (!reduced) then 
			begin 
			  reduced := reduced_tmp; 
			  raise NoMatch 
			end;
		      reduced := reduced_tmp;
		      Terms.make_and f t1
			) l_indep)
		end
	    in
	    if proba != Zero then
	      begin
              (* Instead of storing the term t, I store the term obtained 
                 after the applications of try_no_var in match_term,
                 obtained by (Terms.copy_term redl) *)
		if not (Proba.add_proba_red (Terms.copy_term redl) t' proba (List.map (fun restr1 ->
		  match restr1.link with
		    TLink trestr -> (restr1,trestr)
		  | _ -> Parsing_helper.internal_error "unexpected link in apply_red") restr)) then
		  raise NoMatch
	      end;
	    Terms.cleanup();
	    reduced := true;
	    t''
	      ) simp_facts restr redl t
	with NoMatch ->
	  Terms.cleanup();
	  Terms.build_term2 t (FunApp(f, List.map (fun t' -> apply_red simp_facts t' (restr, proba, redl, redr)) l))
      end
  | _ -> t

and apply_statement simp_facts t (vl,t_state) =
  match t_state.t_desc with
    FunApp(f, [t1;t2]) when f.f_cat == Equal ->
      apply_red simp_facts t ([],Zero,t1,t2)
  | FunApp(f, [t1;t2]) when f.f_cat == Diff ->
      apply_red simp_facts (apply_red simp_facts t 
	([],Zero,t_state, Terms.make_true())) 
	([],Zero,Terms.make_equal t1 t2, Terms.make_false())
  | _ -> apply_red simp_facts t ([],Zero,t_state, Terms.make_true())

and apply_all_red simp_facts t = function
    [] -> 
      let t' = apply_not_red simp_facts t in
      if !reduced then t' else t
  | (a::l) ->
      let t' = apply_statement simp_facts t a in
      if !reduced then t' else apply_all_red simp_facts t l

and apply_collision simp_facts t (restr, forall, t1, proba, t2) =
  apply_red simp_facts t (restr,proba,t1,t2)

and apply_all_coll simp_facts t = function
    [] -> t
  | (a::l) ->
      let t' = apply_collision simp_facts t a in
      if !reduced then t' else apply_all_coll simp_facts t l

and apply_statements_and_collisions simp_facts t =
  let t' = apply_all_red simp_facts t (!Transform.statements) in
  if !reduced then t' else
  apply_all_coll simp_facts t (!Transform.collisions) 

(* [apply_reds simp_facts t] applies all equalities and collisions given in the 
   input file to the term [t], taking into account the equalities in 
   [simp_facts] to enable their application. *)

and apply_reds simp_facts t =
  reduced := false;
  let t' = apply_statements_and_collisions simp_facts t in
  if !reduced then 
    apply_reds simp_facts t' 
  else
    t


(* Add a fact to a set of true facts, and simplify it *)

and add_fact dep_info ((subst2, facts, elsefind) as simp_facts) fact =
  (* print_string "Adding "; Display.display_term [] fact; print_newline(); *)
  let fact' = try_no_var simp_facts fact in
  match fact'.t_desc with
    FunApp(f,[t1;t2]) when f.f_cat == LetEqual ->
      begin
	match t1.t_desc with
	  Var(b,l) -> 
	    let t1' = Terms.build_term2 t1 (Var(b, List.map (try_no_var simp_facts) l))
	    in
	    let t2' = try_no_var simp_facts t2 in
	    let rec try_red_t1 = function
		[] -> (* Could not reduce t1' *)
		  subst_simplify2 dep_info simp_facts (Terms.make_let_equal t1' t2')
	      | { t_desc = FunApp(f'',[t1'';t2''])}::l when f''.f_cat == LetEqual ->
		  if Terms.equal_terms t1'' t1' then 
		    simplif_add dep_info simp_facts (Terms.make_equal t2' t2'')
		  else
		    try_red_t1 l
	      | _::l -> try_red_t1 l
	    in
	    try_red_t1 subst2
	| _ -> 
	    Parsing_helper.internal_error "LetEqual terms should have a variable in the left-hand side"
      end
  | FunApp(f,[t1;t2]) when f.f_cat == Equal ->
      let t1' = try_no_var simp_facts t1 in
      let t2' = try_no_var simp_facts t2 in
      begin
      match (t1'.t_desc, t2'.t_desc) with
        (FunApp(f1,l1), FunApp(f2,l2)) when
	f1.f_cat == Tuple && f2.f_cat == Tuple && f1 != f2 -> 
	  raise Contradiction
      | (FunApp(f1,l1), FunApp(f2,l2)) when
	(f1.f_options land Settings.fopt_COMPOS) != 0 && f1 == f2 -> 
	  simplif_add_list dep_info simp_facts (List.map2 Terms.make_equal l1 l2)
      | (Var(b1,l1), Var(b2,l2)) when
	(Terms.is_restr b1) &&
	(Proba.is_large_term t1'  || Proba.is_large_term t2') && (b1 == b2) &&
	(Proba.add_elim_collisions b1 b1) ->
	  simplif_add_list dep_info simp_facts (List.map2 Terms.make_equal l1 l2)
      | (Var(b1,l1), Var(b2,l2)) when
	(Terms.is_restr b1) && (Terms.is_restr b2) &&
	(Proba.is_large_term t1' || Proba.is_large_term t2') &&
	(b1 != b2) && (Proba.add_elim_collisions b1 b2)->
	  raise Contradiction
      | (_,_) when dep_info simp_facts t1' t2' ->
	  raise Contradiction
      | (FunApp(f1,[]), FunApp(f2,[]) ) when
	f1 != f2 && (!Settings.diff_constants) ->
	  raise Contradiction
	  (* Different constants are different *)
      | (_, _) when orient t1' t2' ->
	  subst_simplify2 dep_info simp_facts (Terms.make_equal t1' t2')
      | (_, _) when orient t2' t1' -> 
	  subst_simplify2 dep_info simp_facts (Terms.make_equal t2' t1')
      | _ -> (subst2, fact'::facts, elsefind)
      end
  | FunApp(f,[t1;t2]) when f == Settings.f_and ->
      simplif_add dep_info (add_fact dep_info simp_facts t1) t2
  | _ -> 
      if Terms.is_false fact' then raise Contradiction else
      if Terms.is_true fact' then simp_facts else
      let facts' = if List.exists (Terms.equal_terms fact') facts then facts else fact'::facts in
      (subst2, facts', elsefind)

and subst_simplify2 dep_info (subst2, facts, elsefind) link =
  let subst2'' = ref [] in
  let not_subst2_facts = ref facts in
  List.iter (fun t0 ->
    match t0.t_desc with
      FunApp(f, [t;t']) when f.f_cat == Equal || f.f_cat == LetEqual ->
	(* When f.f_cat == LetEqual, t itself cannot be reduced by link,
	   since otherwise the left-hand side of link is t, and this
           term should have been reduced into t' by t0 before.
	   However, subterms of t may be reduced by link.
	   
	   When f.f_cat == LetEqual and we reduce only t' (not t),
	   we might directly add 
	   Terms.make_let_equal t (try_no_var simp_facts t1') to subst2''
	   However, it is not clear what "simp_facts" should really be...
         *)
	let (t1, t1', reduced) = 
	  match t'.t_desc with
	    Var _ ->
	      reduced_subst := false;
	      let t1 = apply_subst1 t link in
	      let t1' = apply_subst1 t' link in
	      (t1,t1',!reduced_subst)
	  | FunApp _ ->
	      reduced_subst := false;
	      let t1 = apply_subst1 t link in
	      let red = !reduced_subst in
	      (* Applying reductions here slows down simplification *)
	      reduced := false;
	      let t1' = apply_statements_and_collisions (link :: (!subst2''), facts, elsefind) t' in
	      (t1, t1', red || (!reduced))
	  | _ -> Parsing_helper.internal_error "If/let/find/new not allowed in subst_simplify2"
	in
	if reduced then
	  begin
	    let fact' = Terms.build_term_type Settings.t_bool (FunApp(f,[t1; t1'])) in
	    if not (List.exists (Terms.equal_terms fact') (!not_subst2_facts)) then
	      not_subst2_facts := fact' :: (!not_subst2_facts)
	  end
	else
	  subst2'' := t0 :: (!subst2'')
    | _ -> Parsing_helper.internal_error "substitutions should be Equal or LetEqual terms"
    ) subst2;
  simplif_add_list dep_info (link :: (!subst2''),[], elsefind) (!not_subst2_facts)

and simplif_add dep_info ((subst2, facts, elsefind) as simp_facts) fact =
(*  print_string "simplif_add "; Display.display_term [] fact; 
  print_string " knowing\n"; display_facts simp_facts; print_newline();*)
  let fact' = apply_reds simp_facts fact in
  add_fact dep_info simp_facts fact'

and simplif_add_list dep_info simp_facts = function
    [] -> simp_facts
  | (a::l) -> simplif_add_list dep_info (simplif_add dep_info simp_facts a) l

(*
let simplif_add dep_info s f =
  print_string "Adding "; Display.display_term [] f;
  print_string " to\n";
  display_facts s; 
  print_newline();
  try 
    let res = simplif_add dep_info s f in
    print_string "Addition done "; display_facts res;
    print_newline();
    res
  with Contradiction ->
    print_string "Contradiction\n\n";
    raise Contradiction

let simplif_add_list dep_info s fl =
  print_string "Adding "; Display.display_list (Display.display_term []) fl;
  print_string " to\n";
  display_facts s; 
  print_newline();
  try
    let res = simplif_add_list dep_info s fl in
    print_string "Addition done "; display_facts res;
    print_newline();
    res
  with Contradiction ->
    print_string "Contradiction\n\n";
    raise Contradiction
*)

let simplif_add_find_cond dep_info simp_facts fact =
  match fact.t_desc with
    Var _ | FunApp _ -> simplif_add dep_info simp_facts fact
  | _ -> simp_facts
    

(* Compute the list of variables that must be defined at a certain
point, taking into account defined conditions of find *)

let rec intersect_list eqtest = function
    [] -> raise Contradiction
  | [a] -> a
  | (a::l) -> Terms.intersect eqtest a (intersect_list eqtest l)

let rec check_non_nested seen_fsymb seen_binders t =
  match t.t_desc with
    Var(b,l) ->
      (not (List.memq b seen_binders)) &&
      (List.for_all (check_non_nested seen_fsymb (b::seen_binders)) l)
  | FunApp(f,l) ->
      (not (List.memq f seen_fsymb)) &&
      (List.for_all (check_non_nested (f::seen_fsymb) seen_binders) l)
  | _ -> 
      Display.display_term [] t; print_newline();
      Parsing_helper.internal_error "If, find, let, new should have been expanded"

(* Get the node at which the find indices of a find are defined.
   This is the node at which the definition requirements in the "defined" condition
   are checked. *)
let get_node_for_find_branch def_node_opt bl =
  match def_node_opt with
    None -> None
  | Some (_,_,n) -> 
      match bl with
	[] -> Some n
      |	(b::_) -> 
	  try
	    Some (List.find (fun n' -> n'.above_node == n) b.def)
	  with Not_found ->
	    Parsing_helper.internal_error "Could not find defining node for find index"

(* is_reachable n n' returns true when n is reachable from n' *)
let rec is_reachable n n' =
  if n == n' then true else
  if n'.above_node == n' then false else
  is_reachable n n'.above_node

let get_def_vars_above n =
  List.map (fun b -> (b, b.args_at_creation)) (Terms.add_def_vars_node [] n)

(* Take into account variables that must be defined because a block of code
   is always executed until the next output/yield before passing control to
   another block of code *)
let def_vars_from_node current_node_opt n =
  match current_node_opt with
    Some current_node ->
      if is_reachable n current_node then
	Terms.intersect Terms.equal_binderref (n.future_def_vars @ n.def_vars_at_def) current_node.def_vars_at_def
      else
	n.future_def_vars @ n.def_vars_at_def
  | None -> n.def_vars_at_def

(* Take into account variables that must be defined because a block of code
   is always executed until the next output/yield before passing control to
   another block of code *)
let get_def_vars_above2 current_node_opt n =
  let vars_above_n = Terms.add_def_vars_node [] n in
  match current_node_opt with
    Some current_node ->
      if is_reachable n current_node then
	Terms.intersect (==) 
	  (n.future_binders @ vars_above_n)
	  (Terms.add_def_vars_node [] current_node)
      else
	n.future_binders @ vars_above_n
  | None -> vars_above_n

(* Remove variables that are certainly defined from a def_list in a find.
   Variables that are defined above the find (so don't need a "defined"
   condition) are found by "get_def_vars_above def_node". 
   Variables that already have a "defined" condition above the current
   find are found by "def_node.def_vars_at_def". *)
let reduced_def_list def_node_opt def_list =
  match def_node_opt with
    Some (_, def_vars, def_node) ->
      Terms.setminus_binderref def_list (def_vars @ def_node.def_vars_at_def @ (get_def_vars_above def_node))
  | None -> def_list

(* More precise solution, but must not be used to remove elements
of def_list, just to test whether all elements of def_list are defined,
in which case for a "find ... defined(def_list) && M", if M is true,
the else branch can be removed. -- Useful to remove the "else" branches
generated by applying the security of a Diffie-Hellman key agreement,
for example. 
Removing useful elements of def_list breaks the code of SArename 

   [add_def_vars current_node def_vars_accu seen_refs br] adds in
   [def_vars_accu] the variables that are known to be defined when [br]
   is defined and [current_node] corresponds to the current program
   point. [seen_refs] stores the variables already seen to avoid loops.
*)

let rec term_to_binderrefs accu t =
  match t.t_desc with
    Var(b,l) -> Terms.add_binderref (b,l) accu
  | FunApp(f,l) -> List.iter (term_to_binderrefs accu) l
  | _ -> Parsing_helper.internal_error "if/find/let forbidden in term_to_binderrefs"


let rec add_def_vars current_node def_vars_accu seen_refs (b,l) =
  if (List.for_all (check_non_nested [] [b]) l) &&
    (not (Terms.mem_binderref (b,l) (!seen_refs))) then
    begin
      seen_refs := (b,l) :: (!seen_refs);
      let def_vars_above_def = intersect_list (==) (List.map (get_def_vars_above2 current_node) b.def) in
      let def_vars_at_def = intersect_list Terms.equal_binderref (List.map (def_vars_from_node current_node) b.def) in
      (* b.args_at_creation -> l *)
      let bindex = List.map Terms.binder_from_term b.args_at_creation in
      (* add facts *)
      Terms.add_binderref (b,l) def_vars_accu;
      List.iter (fun b ->
	let t = Terms.term_from_binder b in
	let t' = Terms.subst bindex l t in
	term_to_binderrefs def_vars_accu t') def_vars_above_def;
      (* recursive call *)
      let def_vars_at_def' = ref [] in
      List.iter (fun br ->
	let t = Terms.term_from_binderref br in
	let t' = Terms.subst bindex l t in
	term_to_binderrefs def_vars_at_def' t') def_vars_at_def;
      List.iter (add_def_vars current_node def_vars_accu seen_refs) (!def_vars_at_def')
    end

(* Take into account facts that must be true because a block of code
   is always executed until the next output/yield before passing control to
   another block of code *)
let true_facts_from_node current_node_opt n =
  match current_node_opt with
    Some current_node ->
      if is_reachable n current_node then
	Terms.intersect Terms.equal_terms (n.future_true_facts @ n.true_facts_at_def) current_node.true_facts_at_def
      else
	n.future_true_facts @ n.true_facts_at_def
  | None -> 
      n.true_facts_at_def

let rec add_facts current_node fact_accu seen_refs (b,l) =
  (* print_string "Is defined "; Display.display_var [] b l; print_newline(); *)
  if (List.for_all (check_non_nested [] [b]) l) &&
    (not (Terms.mem_binderref (b,l) (!seen_refs))) then
    begin
      seen_refs := (b,l) :: (!seen_refs);
      let true_facts_at_def = filter_ifletfindres (intersect_list Terms.equal_terms (List.map (true_facts_from_node current_node) b.def)) in
      let def_vars_at_def = intersect_list Terms.equal_binderref (List.map (def_vars_from_node current_node) b.def) in
      let bindex = List.map Terms.binder_from_term b.args_at_creation in
      (* add facts *)
      List.iter (fun f -> 
        (* b.args_at_creation -> l *)
	let f = Terms.subst bindex l f in
	(* print_string "Adding "; Display.display_term [] f; print_newline(); *)
	if not (List.memq f (!fact_accu)) then
	  fact_accu := f :: (!fact_accu)) true_facts_at_def;
      (* recursive call *)
      let def_vars_at_def' = ref [] in
      List.iter (fun br ->
        (* b.args_at_creation -> l *)
	let t = Terms.term_from_binderref br in
	let t' = Terms.subst bindex l t in
	term_to_binderrefs def_vars_at_def' t') def_vars_at_def;
      List.iter (add_facts current_node fact_accu seen_refs) (!def_vars_at_def')
    end
      
(* [def_vars_from_defined current_node bl def_list] returns the variables that
   are known to be defined when the condition of a find with indices [bl] and 
   defined condition [def_list] holds. [current_node] is the node at 
   which the indices [bl] are defined (returned by 
   [get_node_for_find_branch]). *)

let def_vars_from_defined current_node bl def_list =
  let subterms = ref [] in
  List.iter (Terms.close_def_subterm subterms) def_list;
  let def_vars_accu = ref (!subterms) in
  List.iter (fun b -> Terms.add_binderref (b, b.args_at_creation) def_vars_accu) bl;
  let seen_refs = ref [] in
  List.iter (fun (b,l) ->
    if not (List.exists (fun b' -> b == b' && List.for_all2 Terms.equal_terms l b'.args_at_creation) bl) then
      add_def_vars current_node def_vars_accu seen_refs (b,l)
				  ) (!subterms);
  !def_vars_accu


(* [facts_from_defined current_node bl def_list] returns the facts that
   are known to hold when the condition of a find with indices [bl] and 
   defined condition [def_list] holds. [current_node] is the node at 
   which the indices [bl] are defined (returned by 
   [get_node_for_find_branch]). *)

let facts_from_defined current_node bl def_list =
  let def_list_subterms = ref [] in
  List.iter (Terms.close_def_subterm def_list_subterms) def_list;
  let fact_accu = ref [] in
  let seen_refs = ref [] in
  List.iter (fun (b,l) ->
    if not (List.exists (fun b' -> b == b' && List.for_all2 Terms.equal_terms l b'.args_at_creation) bl) then
      add_facts current_node fact_accu seen_refs (b,l)
	) (!def_list_subterms);
  !fact_accu

(* [get_def_vars_at fact_info] returns the variables that are known
   to be defined given [fact_info]. *)

let get_def_vars_at = function
    Some (_,def_vars,n) ->
      let def_vars_accu = ref (get_def_vars_above n) in
      let seen_refs = ref [] in
      List.iter (add_def_vars (Some n) def_vars_accu seen_refs) (def_vars @ n.def_vars_at_def);
      !def_vars_accu
  | None -> []

(* [get_facts_at fact_info] returns the facts that are known to hold
   given [fact_info]. *)

let get_facts_at = function
    None -> []
  | Some(true_facts, def_vars, n) ->
      let fact_accu = ref (filter_ifletfindres true_facts) in
      List.iter (add_facts (Some n) fact_accu (ref [])) (def_vars @ n.def_vars_at_def);
      !fact_accu



(*****
   Show that elements of the array b at different indices are always
   different (up to negligible probability).
   This is useful for showing secrecy of a key.
 *****)


let make_indexes b =
  List.map (fun t -> 
    let v = Terms.new_binder (Terms.binder_from_term t) in
    let rec def_node = { above_node = def_node; binders = [];
			 true_facts_at_def = []; def_vars_at_def = []; 
			 elsefind_facts_at_def = [];
			 future_binders = []; future_true_facts = [];
			 future_def_vars = [];
			 definition = DNone }
    in
    let def_node2 = { above_node = def_node; binders = [v];
		      true_facts_at_def = []; def_vars_at_def = []; 
		      elsefind_facts_at_def = [];
		      future_binders = []; future_true_facts = [];
		      future_def_vars = [];
		      definition = DNone }
    in
    v.def <- [def_node2];
    Terms.term_from_binder v) b.args_at_creation

let collect_facts accu (def,bindex,index) =
  let fact_accu = ref accu in
  let seen_refs = ref [] in
  (* add facts *)
  List.iter (fun f -> 
    let f = Terms.subst bindex index f in
    if not (List.memq f (!fact_accu)) then
      fact_accu := f :: (!fact_accu)) (filter_ifletfindres def.true_facts_at_def);
  (* recursive call *)
  List.iter (fun (b',l') ->
    add_facts None fact_accu seen_refs (b', List.map (Terms.subst bindex index) l')
      ) def.def_vars_at_def;
  (* Result *)
  !fact_accu

let rec collect_facts_list bindex index1 = function
    [] -> []
  | (d::l) ->
      let l' = collect_facts_list bindex index1 l in
      try
	(d, collect_facts [] (d,bindex,index1))::l'
      with Contradiction ->
	l'

let check_distinct b internal_info g =
  Proba.reset [] internal_info g;
  Terms.build_def_process None g.proc;
  let index1 = make_indexes b in
  let index2 = make_indexes b in
  let diff_index = Terms.make_or_list (List.map2 Terms.make_diff index1 index2) in
  let bindex = List.map Terms.binder_from_term b.args_at_creation in
  let d1withfacts = collect_facts_list bindex index1 b.def in
  let d2withfacts = collect_facts_list bindex index2 b.def in
  let r = 
  List.for_all (fun (d1,d1facts) ->
    List.for_all (fun (d2,d2facts) ->
      match d1.definition, d2.definition with
	DProcess { p_desc = Restr _ }, DProcess { p_desc = Restr _} -> true
      | DProcess { p_desc = Restr _ }, 
	    (DProcess { p_desc = Let(PatVar _,{ t_desc = Var(b',l) },_,_)}
	    |DTerm { t_desc = LetE(PatVar _, { t_desc = Var(b',l) },_,_) }) ->
		if not (Terms.is_restr b') then
		  Parsing_helper.internal_error "restriction should be checked when testing secrecy";
		(b != b') || 
		(
		try
		  let eq_b = Terms.make_and_list 
		      (List.map2 Terms.make_equal index1 (List.map (Terms.subst bindex index2) l))
		  in
		  let facts1 = diff_index :: eq_b :: d1facts @ d2facts in
		  ignore (simplif_add_list no_dependency_anal ([],[],[]) facts1);
		  false
		with Contradiction -> true
		    )
      |	(DProcess { p_desc = Let(PatVar _,{ t_desc = Var(b',l) },_,_)}
        |DTerm { t_desc = LetE(PatVar _, { t_desc = Var(b',l) },_,_) }), 
		DProcess { p_desc = Restr _ } ->
	  true (* The symmetric case will be checked by the previous pattern *)
      |	(DProcess { p_desc = Let(PatVar _,{ t_desc = Var(b1',l1) },_,_)}
        |DTerm { t_desc = LetE(PatVar _, { t_desc = Var(b1',l1) },_,_) }),
	  (DProcess {p_desc = Let(PatVar _,{ t_desc = Var(b2',l2) },_,_)}
          |DTerm { t_desc = LetE(PatVar _, { t_desc = Var(b2',l2) },_,_) }) ->
		if not ((Terms.is_restr b1') && (Terms.is_restr b2')) then
		  Parsing_helper.internal_error "restriction should be checked when testing secrecy";
		(b1' != b2') || 
		(
		try
		  let eq_b = Terms.make_and_list 
		      (List.map2 Terms.make_equal 
			 (List.map (Terms.subst bindex index1) l1) 
			 (List.map (Terms.subst bindex index2) l2))
		  in
		  let facts1 = diff_index :: eq_b :: d1facts @ d2facts in
		  ignore (simplif_add_list no_dependency_anal ([],[],[]) facts1);
		  false
		with Contradiction -> true
		    )
      | _ -> 
	  Parsing_helper.internal_error "definition cases should be checked when testing secrecy"
	  ) d2withfacts
      ) d1withfacts
  in
  if r then
    (* Add probability for eliminated collisions *)
    (true, Proba.final_add_proba[])
  else
    (false, [])

        (*
        print_string "Facts for check_distinct 1:\n";
        List.iter (fun t -> Display.display_term [] t; print_newline()) facts1;

        print_string "Facts for check_distinct 2:\n";
        display_facts facts;
        *)


(***** Check correspondence assertions *****)

let rec guess_by_matching next_f simp_facts t t' = 
  match t.t_desc with
    Var (v,[]) -> 
    (* Check that types match *)
      if t'.t_type != v.btype then
	raise NoMatch;
      begin
	match v.link with
	  NoLink -> Terms.link v (TLink t')
	| TLink t -> ()
      end;
      next_f()
  | FunApp(f,[t1;t2]) when f.f_options land Settings.fopt_COMMUT != 0 ->
      (* Commutative function symbols *)
      begin
	match (try_no_var simp_facts t').t_desc with
	  FunApp(f',[t1';t2']) when f == f' ->
            begin
              try
                Terms.auto_cleanup (fun () ->
	          guess_by_matching (fun () -> guess_by_matching next_f simp_facts t2 t2') simp_facts t1 t1')
              with NoMatch ->
                guess_by_matching (fun () -> guess_by_matching next_f simp_facts t2 t1') simp_facts t1 t2'
            end
	| _ -> next_f()
      end
  | FunApp(f,l) ->
      begin
	match (try_no_var simp_facts t').t_desc with
	  FunApp(f',l') when f == f' ->
	    guess_by_matching_list next_f simp_facts l l'
	| _ -> next_f()
      end
  | Var _ | TestE _ | FindE _ | LetE _ | ResE _ | EventE _ ->
      Parsing_helper.internal_error "Var with arguments, if, find, let, and new should not occur in guess_by_matching"

and guess_by_matching_list next_f simp_facts l l' = 
  match l,l' with
    [],[] -> next_f()
  | a::l,a'::l' ->
      guess_by_matching (fun () -> guess_by_matching_list next_f simp_facts l l') 
	simp_facts a a'
  | _ -> Parsing_helper.internal_error "Different lengths in guess_by_matching_list"

let guess_by_matching_same_root next_f simp_facts t t' = 
  match t.t_desc with
    Var (v,[]) -> 
    (* Check that types match *)
      if t'.t_type != v.btype then
	raise NoMatch;
      begin
	match v.link with
	  NoLink -> Terms.link v (TLink t')
	| TLink t -> ()
      end;
      next_f()
  | FunApp(f,[t1;t2]) when f.f_options land Settings.fopt_COMMUT != 0 ->
      (* Commutative function symbols *)
      begin
	match (try_no_var simp_facts t').t_desc with
	  FunApp(f',[t1';t2']) when f == f' ->
            begin
              try
                Terms.auto_cleanup (fun () ->
	          guess_by_matching (fun () -> guess_by_matching next_f simp_facts t2 t2') simp_facts t1 t1')
              with NoMatch ->
                guess_by_matching (fun () -> guess_by_matching next_f simp_facts t2 t1') simp_facts t1 t2'
            end
	| _ -> raise NoMatch
      end
  | FunApp(f,l) ->
      begin
	match (try_no_var simp_facts t').t_desc with
	  FunApp(f',l') when f == f' ->
	    guess_by_matching_list next_f simp_facts l l'
	| _ -> raise NoMatch
      end
  | Var _ | TestE _ | FindE _ | LetE _ | ResE _ | EventE _ ->
      Parsing_helper.internal_error "Var with arguments, if, find, let, and new should not occur in guess_by_matching"

let rec collect_vars accu t =
  match t.t_desc with
    Var(b,[]) -> accu := b :: (!accu)
  | FunApp(f,l) -> List.iter (collect_vars accu) l
  | _ -> Parsing_helper.internal_error "expecting variable or function in collect_vars"

let show_fact facts fact =
  Terms.auto_cleanup (fun () ->
      try
	ignore (simplif_add no_dependency_anal facts (Terms.make_not fact));
(*	print_string "Failed to prove "; 
	Display.display_term [] fact;
	print_newline();*)
	false
      with Contradiction ->
(*	print_string "Proved "; 
	Display.display_term [] fact;
	print_newline();*)
	true)


(* Try to prove injectivity for injective correspondences 
   simp_facts = facts derivable 
   injrepidxs = list of sequences of replication indexes at the injective end events
   begin_sid = sequence of replication indexes at an injective begin event

   facts', injrepidxs', begin_sid' = same thing for another way of proving
   the concerned injective begin event, with renamed variables.

   (Variables in t1/t2 do not occur in the facts. 
   Only variables in t1/t2 have links.)

   *)

let check_inj_compat (simp_facts, injrepidxs, _, begin_sid) facts' injrepidxs' begin_sid' =
  Terms.auto_cleanup (fun () ->
    try
      let facts_with_inj1 = simplif_add_list no_dependency_anal simp_facts facts' in
      (* injrepidxs \neq injrepidxs' *)
      let diff_fact = Terms.make_or_list (List.concat (List.map2 
	(List.map2 Terms.make_diff) injrepidxs injrepidxs')) in
      let facts_with_inj2 = simplif_add no_dependency_anal facts_with_inj1 diff_fact in
      (* begin_sid = begin_sid' *)
      let eq_facts = List.map2 Terms.make_equal begin_sid begin_sid' in
      let _ = simplif_add_list no_dependency_anal facts_with_inj2 eq_facts in
      raise NoMatch
    with Contradiction ->
      ())

let add_inj simp_facts injrepidxs vars fact' fact injinfo =
  match fact'.t_desc with
    FunApp(_, { t_desc = FunApp(_, begin_sid) }::_) ->
      begin
	let (subst, facts, _) = simp_facts in
	let nsimpfacts = subst @ facts in 
	let new_vars = List.map (fun b -> Terms.term_from_binder (Terms.new_binder b)) vars in
	let new_facts = List.map (Terms.subst vars new_vars) nsimpfacts in
	let new_injrepidxs = List.map (List.map (Terms.subst vars new_vars)) injrepidxs in
	let new_begin_sid = List.map (Terms.subst vars new_vars) begin_sid in
(*
	print_string "Checking inj compatiblity\n";
	display_facts simp_facts;
	print_string "New facts\n";
	List.iter (fun f -> Display.display_term [] f; print_newline()) new_facts;
	print_string "Inj rep idxs:";
	Display.display_list (Display.display_list (Display.display_term [])) injrepidxs;
	print_string "\nNew inj rep idxs:";
	Display.display_list (Display.display_list (Display.display_term [])) new_injrepidxs;
	print_string "\nBegin sid:";
	Display.display_list (Display.display_term []) begin_sid;
	print_string "\nNew begin sid:";
	Display.display_list (Display.display_term []) new_begin_sid;
	print_string "\n\n";
*)
	check_inj_compat (simp_facts, injrepidxs, vars, begin_sid) new_facts new_injrepidxs new_begin_sid;
	try
	  let l = List.assq fact injinfo in
	  List.iter (fun lelem -> check_inj_compat lelem new_facts new_injrepidxs new_begin_sid) l;
	  (fact, (simp_facts, injrepidxs, vars, begin_sid) :: l) :: (List.filter (fun (f, _) -> f != fact) injinfo)
	with Not_found ->
	  (fact, [(simp_facts, injrepidxs, vars, begin_sid)]) ::injinfo 
      end
  | _ -> Parsing_helper.internal_error "event should have session id"

(* try to find a instance of fact in the list of facts given as
last argument *)
let rec prove_by_matching next_check simp_facts injrepidxs vars injinfo is_inj fact = function
    [] -> raise NoMatch
  | (fact'::l) ->
      let tmp_proba_state = Proba.get_current_state() in
      try
	Terms.auto_cleanup (fun () ->
          (* When I am trying to prove an event, the root symbol is
             the event symbol, and it must really be the same for
             fact and fact'. When I am trying to prove another fact,
             it is a good heuristic, since a variable can be bound
             only when at least the root symbol is the same *)
	  guess_by_matching_same_root (fun () ->
(*	    print_string "Found ";
	    Display.display_term [] fact';
	    print_string " as instance of ";
	    Display.display_term [] fact;
	    print_newline();*)
	    (* Check that all variables of fact are instantiated *)
	    let vars_fact = ref [] in
	    collect_vars vars_fact fact;
	    if not ((List.for_all (fun b -> (b.link != NoLink)) (!vars_fact)) &&
                    (* ... and that fact' is equal to fact *)
	            show_fact simp_facts (Terms.make_equal fact' (Terms.copy_term fact)))
	    then raise NoMatch;
	    if is_inj then 
	      next_check (add_inj simp_facts injrepidxs vars fact' fact injinfo)
	    else
	      next_check injinfo
	    ) simp_facts fact fact');
      with NoMatch -> 
	Proba.restore_state tmp_proba_state;
	prove_by_matching next_check simp_facts injrepidxs vars injinfo is_inj fact l

let rec check_term next_check ((_,facts2,_) as facts) injrepidxs vars injinfo = function
    QAnd(t,t') ->
      check_term (fun injinfo' -> check_term next_check facts injrepidxs vars injinfo' t')
	facts injrepidxs vars injinfo t
  | QOr(t,t') ->
      begin
	let tmp_proba_state = Proba.get_current_state() in
	try
	  Terms.auto_cleanup (fun () ->
	    check_term next_check facts injrepidxs vars injinfo t)
	with NoMatch ->
	  Proba.restore_state tmp_proba_state;
	  check_term next_check facts injrepidxs vars injinfo t'
      end
  | QTerm t2 ->
      begin
	(* Try to find an instance of t2 in simp_facts *)
	let tmp_proba_state = Proba.get_current_state() in
	try
	  prove_by_matching next_check facts injrepidxs vars injinfo false t2 facts2
	with NoMatch -> 
	  Proba.restore_state tmp_proba_state;
	  (* If failed, try to prove t2 by contradiction,
	     when t2 is fully instantiated *)
	  let vars_t2 = ref [] in
	  collect_vars vars_t2 t2;
	  if (List.for_all (fun b -> (b.link != NoLink)) (!vars_t2)) &&
	    (show_fact facts (Terms.copy_term t2))
	      then next_check injinfo else raise NoMatch
      end
  | QEvent(is_inj,t2) ->
      begin
	(* Try to find an instance of t2 in simp_facts *)
	let tmp_proba_state = Proba.get_current_state() in
	try
	  prove_by_matching next_check facts injrepidxs vars injinfo is_inj t2 facts2
	with NoMatch -> 
	  Proba.restore_state tmp_proba_state;
	  raise NoMatch
      end
      

let check_corresp (t1,t2) internal_info g =
   Terms.auto_cleanup (fun () ->
(* Dependency collision must be deactivated, because otherwise
   it may consider the equality between t1 and t1' below as an unlikely
   collision, because t1 does not depend on variables in the process.
   That's why I use "no_dependency_anal" *)

(*  print_string "Trying to prove ";
  Display.display_query (QEventQ(t1,t2));*)
  Proba.reset [] internal_info g;
  let event_accu = ref [] in
  Terms.build_def_process (Some event_accu) g.proc;
  let vars_t1 = ref [] in
  List.iter (fun (_, t) -> collect_vars vars_t1 t) t1;
  let vars_t1' = List.map (fun b ->
    let rec def_node = { above_node = def_node; binders = [];
			 true_facts_at_def = []; def_vars_at_def = []; 
			 elsefind_facts_at_def = [];
			 future_binders = []; future_true_facts = [];
			 future_def_vars = [];
			 definition = DNone }
    in
    b.def <- [def_node];
    let b' = Terms.new_binder b in
    Terms.link b (TLink (Terms.term_from_binder b'));
    b') (!vars_t1)
  in
  let collect_facts1 next_f facts injrepidxs vars (is_inj,t) =
    List.for_all (fun (t1',fact_info) ->
      match t.t_desc,t1'.t_desc with
	FunApp(f,idx::l),FunApp(f',idx'::l') ->
	  if f == f' then
	    try
	      let end_sid = 
		match idx'.t_desc with
		  FunApp(_,lsid) -> lsid
		| _ -> Parsing_helper.internal_error "Session ids should occur first in the arguments of events"
	      in
	      let bend_sid = List.map Terms.binder_from_term end_sid in
	      let new_bend_sid = List.map Terms.new_binder bend_sid in
	      let new_end_sid = List.map Terms.term_from_binder new_bend_sid in
	      let eq_facts = List.map2 Terms.make_equal (List.map Terms.copy_term l) (List.map (Terms.subst bend_sid new_end_sid) l') in
	      let new_facts = List.map (Terms.subst bend_sid new_end_sid) (get_facts_at fact_info) in
(*
              print_string "\nFound ";
              Display.display_term [] t1';
              print_string " with facts\n";
              List.iter (fun t -> Display.display_term [] t; print_newline()) (eq_facts @ new_facts);
*)
	      let facts1 = Terms.auto_cleanup (fun () -> simplif_add_list no_dependency_anal facts new_facts) in
(*            print_string "First step without contradiction\n"; *)
	      let facts' = Terms.auto_cleanup (fun () -> simplif_add_list no_dependency_anal facts1 eq_facts) in
(*            print_string "After simplification ";
              display_facts facts'; *)
	      if not is_inj then
		next_f facts' injrepidxs (new_bend_sid @ vars)
	      else
		next_f facts' (new_end_sid :: injrepidxs) (new_bend_sid @ vars)
	    with Contradiction -> 
(*            print_string "Contradiction. Proof succeeded.\n";*)
	      true
	  else 
	    true
      | _ -> Parsing_helper.internal_error "event expected in check_corresp"
	    ) (!event_accu)
  in
  let rec collect_facts_list next_f facts injrepidxs vars = function
      [] -> next_f facts injrepidxs vars
    | (a::l) -> collect_facts1 (fun facts' injrepidxs' vars' -> collect_facts_list next_f facts' injrepidxs' vars' l) facts injrepidxs vars a
  in  
  let injinfo = ref [] in
  let r =
    collect_facts_list (fun facts' injrepidxs' vars' ->
      try 
	Terms.auto_cleanup (fun () -> 
	  check_term (fun injinfo' -> injinfo := injinfo'; true) facts' injrepidxs' vars' (!injinfo) t2)
      with NoMatch -> 
	false
	  ) ([],[],[]) [] vars_t1' t1
  in
  if r then
    (* Add probability for eliminated collisions *)
    (true, Proba.final_add_proba [])
  else
    (false, []))

(***** Show that two terms are equal (up to negligible probability) *****
       Terms.build_def_process must have been called so that t.t_facts has been filled.
*)

let check_equal internal_info g t t' =
  Proba.reset [] internal_info g;
  try 
    let facts' = get_facts_at t.t_facts in
    let simp_facts = Terms.auto_cleanup (fun () -> simplif_add_list no_dependency_anal ([],[],[]) facts') in
    let r = simp_equal_terms simp_facts t t' in
    (* Add probability for eliminated collisions *)
    let proba = Proba.final_add_proba [] in
    let internal_info' = Proba.final_internal_info() in
    (r, proba, internal_info')
  with Contradiction ->
	(* May happen when the program point of t is in fact unreachable
	   I could say true anyway because the program point is unreachable. *)
    (Terms.equal_terms t t', [], internal_info)

