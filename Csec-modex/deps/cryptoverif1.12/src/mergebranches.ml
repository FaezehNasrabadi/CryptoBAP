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
open Parsing_helper

let cur_branch_var_list = ref []
    (* List of pairs (variable in current branch, variable in else branch)
       for variables with array references, a single definition, and
       a different name in different branches *)

let all_branches_var_list = ref []
    (* All lists cur_branch_var_list for the various branches *)

let var_no_array_ref = ref []
    (* Variables that must not have array references in the final game *)

let has_array_ref b =
  Terms.has_array_ref_non_exclude b || Transform.occurs_in_queries b

let merge_var next_f map b b' =
  if b == b' then
    next_f map
  else if (b.btype != b'.btype) || (Transform.occurs_in_queries b) || (Transform.occurs_in_queries b') then
    false
  else 
    let ar_b = Terms.has_array_ref_non_exclude b in
    let ar_b' = Terms.has_array_ref_non_exclude b' in
    if (not ar_b) && (not ar_b') then
      next_f ((b,b')::map)
    else if (!Settings.merge_arrays) then
      begin
	if ar_b then var_no_array_ref := b :: (!var_no_array_ref);
	if ar_b' then var_no_array_ref := b' :: (!var_no_array_ref);
	if ar_b && ar_b' && (b.count_def == 1) && (b'.count_def == 1) then
          (* When there are variables with different names in the various
             branches and they have array references, we advise MergeArrays. *)
	  cur_branch_var_list := (b,b') :: (!cur_branch_var_list);
	next_f ((b,b')::map)
      end
    else 
      false

let rec merge_var_list next_f map bl bl' =
  match bl,bl' with
    [], [] -> next_f map
  | [], _ | _, [] -> false
  | (b::bl, b'::bl') ->
      merge_var (fun map' -> merge_var_list next_f map' bl bl') map b b'
      

let eq_oblig = ref []

let equal_terms_ren map t t' = 
  if t.t_type != t'.t_type then false else
  let mapped_t = Terms.subst3 (List.map (fun (b,b') -> (b, Terms.term_from_binder b')) map) t in
  (* We test the equality of processes by first testing that
     they have the same structure, and collecting all needed 
     equalities of terms in eq_oblig. When the processes have
     the same structure, we will later verify that the terms are
     indeed equal. This is because testing equality of terms
     is more costly. *)
  eq_oblig := (mapped_t, t') :: (!eq_oblig);
  true


let eq_binderref map br br' = 
  equal_terms_ren map (Terms.term_from_binderref br) (Terms.term_from_binderref br')
  
let eq_deflist map dl dl' = 
  Terms.equal_lists (eq_binderref map) dl dl'
(* TO DO because equalities are collected and tested later, "List.exists"
does not play its role and always takes the first element of the list, which
is not what we want. For now, I use a stronger test that requires the elements
of dl and dl' to be in the same order.
  (List.for_all (fun br' -> List.exists (fun br -> eq_binderref map br br') dl) dl') &&
  (List.for_all (fun br -> List.exists (fun br' -> eq_binderref map br br') dl') dl) 
*)

let rec equal_pat_ren map map_ref pat pat' =
  match pat, pat' with
    PatVar b, PatVar b' ->
      merge_var (fun map' -> map_ref := map'; true) (!map_ref) b b'
  | PatTuple(f,l), PatTuple(f',l') ->
      (f == f') && (List.for_all2 (equal_pat_ren map map_ref) l l')
  | PatEqual t, PatEqual t' -> 
      equal_terms_ren map t t' 
  | _ -> false

let rec equal_find_cond map t t' =
  match t.t_desc, t'.t_desc with
    (Var _ | FunApp _), (Var _ | FunApp _) -> equal_terms_ren map t t'
  | TestE(t1,t2,t3), TestE(t1',t2',t3') ->
      (equal_terms_ren map t1 t1') &&
      (equal_find_cond map t2 t2') &&
      (equal_find_cond map t3 t3')
  | FindE(l0,t3,find_info), FindE(l0',t3',find_info') ->
      (equal_find_cond map t3 t3') && (List.length l0 == List.length l0') &&
      (find_info = find_info') (* TO DO change this test if find_info structure becomes richer *) &&
      (List.for_all2 (fun (bl, def_list, t, t1)
	  (bl', def_list', t', t1') ->
	    merge_var_list (fun map' -> 
	      (eq_deflist map' def_list def_list') &&
	      (equal_find_cond map' t t') &&
	      (equal_find_cond map' t1 t1')) map bl bl'
	      ) l0 l0')
  | LetE(pat,t1,t2,topt),LetE(pat',t1',t2',topt') ->
      (equal_terms_ren map t1 t1') &&
      (match topt, topt' with
	None, None -> true
      |	Some t3, Some t3' -> equal_find_cond map t3 t3'
      |	_ -> false) &&
      (let map_ref = ref map in
      let eq_pat = equal_pat_ren map map_ref pat pat' in
      eq_pat && (equal_find_cond (!map_ref) t2 t2'))
  | ResE(b,t), ResE(b',t') ->
      merge_var (fun map' -> equal_find_cond map' t t') map b b'
  | EventE _, EventE _ ->
      Parsing_helper.internal_error "Event should have been expanded"
  | _ -> false

let rec equal_process map p p' =
  match p.i_desc, p'.i_desc with
    Nil, Nil -> true
  | Par(p1,p2), Par(p1',p2') -> 
      (equal_process map p1 p1') && (equal_process map p2 p2')
  | Repl(b,p), Repl(b',p') -> 
      if b == b' then
	equal_process map p p'
      else
	(b.btype == b'.btype) && (equal_process ((b,b')::map) p p')
  | Input((c,tl), pat, p), Input((c',tl'), pat', p') ->
      (c == c') && 
      (Terms.equal_lists (equal_terms_ren map) tl tl') &&
      (let map_ref = ref map in
      let eq_pat = equal_pat_ren map map_ref pat pat' in
      eq_pat && (equal_oprocess (!map_ref) p p'))
  | _ -> false

and equal_oprocess map p p' =
  match p.p_desc, p'.p_desc with
    Yield, Yield -> true
  | Restr(b,p), Restr(b',p') ->
      merge_var (fun map' -> equal_oprocess map' p p') map b b'
  | Test(t,p1,p2), Test(t',p1',p2') ->
      (equal_terms_ren map t t') &&
      (equal_oprocess map p1 p1') &&
      (equal_oprocess map p2 p2')
  | Let(pat, t, p1, p2), Let(pat', t', p1', p2') ->
      (equal_terms_ren map t t') &&
      (equal_oprocess map p2 p2') &&
      (let map_ref = ref map in
      let eq_pat = equal_pat_ren map map_ref pat pat' in
       eq_pat && (equal_oprocess (!map_ref) p1 p1'))
  | Output((c,tl),t2,p), Output((c',tl'),t2',p') ->
      (c == c') && 
      (Terms.equal_lists (equal_terms_ren map) tl tl') &&
      (equal_terms_ren map t2 t2') &&
      (equal_process map p p')
  | EventP(t,p), EventP(t',p') ->
      (equal_terms_ren map t t') &&
      (equal_oprocess map p p')
  | Find(l,p, find_info), Find(l',p', find_info') ->
      (equal_oprocess map p p') && (List.length l == List.length l') &&
      (find_info = find_info') (* TO DO change this test if find_info structure becomes richer *) &&
      (List.for_all2 (fun 
	(bl, def_list, t, p1)
	  (bl', def_list', t', p1') ->
	    merge_var_list (fun map' -> 
	      (eq_deflist map' def_list def_list') &&
	      (equal_find_cond map' t t') &&
	      (equal_oprocess map' p1 p1')) map bl bl'
	      ) l l')
  | _ -> false


(* For simplification of terms *)

(* Applying a substitution *)

let reduced_subst = ref false

let rec apply_subst1 t tsubst =
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
             | FunApp(f,l) when f.f_cat != LetEqual ->
	         Terms.build_term2 t (FunApp(f, List.map (fun t' -> apply_subst1 t' tsubst) l))
             | _ -> t
         end
     | _ -> Parsing_helper.internal_error "substitutions should be Equal or LetEqual terms"

let rec apply_all_subst t = function
    [] -> t
  | (a::l) ->
      let t' = apply_subst1 t a in
      if !reduced_subst then t' else apply_all_subst t l

let rec reduce ((subst2, _, _) as simp_facts) t =
  reduced_subst := false;
  let t' = apply_all_subst t subst2 in
  if !reduced_subst then 
    reduce simp_facts t' 
  else
    t

(* simp_equal_terms tests equality between t and t', modulo rewrite rules in 
   simp_facts. Returns true when equal, false otherwise.  *)

let simp_equal_terms simp_facts t t' =
  let t = reduce simp_facts t in
  let t' = reduce simp_facts t' in
  Terms.equal_terms t t'

(* Apply reduction rules defined by statements to term t *)

let rec match_term next_f restr t t' = 
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
	    if not (Terms.equal_terms t t') then raise NoMatch
      end;
      next_f()
  | FunApp(f,[t1;t2]) when f.f_options land Settings.fopt_COMMUT != 0 ->
      (* Commutative function symbols *)
      begin
	match t'.t_desc with
	  FunApp(f',[t1';t2']) when f == f' ->
            begin
              try
                Terms.auto_cleanup (fun () ->
	          match_term (fun () -> match_term next_f restr t2 t2') restr t1 t1')
              with NoMatch ->
                match_term (fun () -> match_term next_f restr t2 t1') restr t1 t2'
            end
	| _ -> raise NoMatch
      end
  | FunApp(f,l) ->
      begin
	match t'.t_desc with
	  FunApp(f',l') when f == f' ->
	    match_term_list next_f restr l l'
	| _ -> raise NoMatch
      end
  | Var _ | TestE _ | FindE _ | LetE _ | ResE _ | EventE _ ->
      Parsing_helper.internal_error "Var with arguments, if, find, let, and new should not occur in match_term"

and match_term_list next_f restr l l' = 
  match l,l' with
    [],[] -> next_f()
  | a::l,a'::l' ->
      match_term (fun () -> match_term_list next_f restr l l') 
	restr a a'
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

let rec apply_not_red t =
  match t.t_desc with
    FunApp(fnot, [t']) when fnot == Settings.f_not ->
      begin
      match t'.t_desc with
	FunApp(feq, [t1;t2]) when feq.f_cat == Equal ->
	  reduced := true;
	  Terms.make_diff t1 t2
      |	FunApp(fdiff, [t1;t2]) when fdiff.f_cat == Diff ->
	  reduced := true;
	  Terms.make_equal t1 t2
      |	_ -> Terms.make_not (apply_not_red t')
      end
  | FunApp(f,[t1;t2]) when f.f_cat == Equal && (Terms.equal_terms t1 t2) ->
      reduced := true;
      Terms.make_true()
  | FunApp(f,[t1;t2]) when f.f_cat == Diff && (Terms.equal_terms t1 t2) ->
      reduced := true;
      Terms.make_false()
  | FunApp(f,[t1;t2]) when f == Settings.f_and ->
      Terms.make_and (apply_not_red t1) (apply_not_red t2)
  | FunApp(f,[t1;t2]) when f == Settings.f_or ->
      Terms.make_or (apply_not_red t1) (apply_not_red t2)
  | FunApp(f,l) ->
      Terms.build_term2 t (FunApp(f, List.map apply_not_red l))
  | _ -> t

let rec apply_red t (restr,proba,redl,redr) =
  match t.t_desc with
    FunApp(f,l) ->
      begin
	try
	  match_term (fun () -> 
	    let t' = Terms.copy_term redr in
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
	    t'
	      ) restr redl t
	with NoMatch ->
	  Terms.cleanup();
	  Terms.build_term2 t (FunApp(f, List.map (fun t' -> apply_red t' (restr, proba, redl, redr)) l))
      end
  | _ -> t

let apply_statement t (vl,t_state) =
  match t_state.t_desc with
    FunApp(f, [t1;t2]) when f.f_cat == Equal ->
      apply_red t ([],Zero,t1,t2)
  | FunApp(f, [t1;t2]) when f.f_cat == Diff ->
      apply_red (apply_red t 
	([],Zero,t_state, Terms.make_true())) 
	([],Zero,Terms.make_equal t1 t2, Terms.make_false())
  | _ -> apply_red t ([],Zero,t_state, Terms.make_true())

let rec apply_all_red t = function
    [] -> 
      let t' = apply_not_red t in
      if !reduced then t' else t
  | (a::l) ->
      let t' = apply_statement t a in
      if !reduced then t' else apply_all_red t l

let apply_collision t (restr, forall, t1, proba, t2) =
  apply_red t (restr,proba,t1,t2)

let rec apply_all_coll t = function
    [] -> t
  | (a::l) ->
      let t' = apply_collision t a in
      if !reduced then t' else apply_all_coll t l

let apply_statements_and_collisions t =
  let t' = apply_all_red t (!Transform.statements) in
  if !reduced then t' else
  apply_all_coll t (!Transform.collisions) 

let rec apply_reds simp_facts t =
  let t = reduce simp_facts t in
  reduced := false;
  let t' = apply_statements_and_collisions t in
  if !reduced then 
    apply_reds simp_facts t' 
  else
    t

let rec orient t1 t2 = 
  match t1.t_desc, t2.t_desc with
    (Var(b,l), _) when
    (not (match t2.t_desc with
            FunApp(f,_) when (f.f_options land Settings.fopt_DECOMPOS) != 0 -> true
          | _ -> Terms.refers_to b t2)) && 
    (not (Terms.is_restr b)) -> true
  | (Var(b1,l1), Var(b2,l2)) when
    (b1 == b2) && (List.for_all2 orient l1 l2) -> true
  | (FunApp(f1,l1), FunApp(f2,l2)) when
    (f1 == f2) && (List.for_all2 orient l1 l2) -> true
  | _ -> false
    
let rec add_fact ((subst2, facts, elsefind) as simp_facts) fact =
  (* print_string "Adding "; Display.display_term [] fact; print_newline(); *)
  match fact.t_desc with
    FunApp(f,[t1;t2]) when f.f_cat == LetEqual ->
      begin
	match t1.t_desc with
	  Var(b,l) -> 
	    let t1' = Terms.build_term2 t1 (Var(b, List.map (reduce simp_facts) l))
	    in
	    let t2' = reduce simp_facts t2 in
	    let rec try_red_t1 = function
		[] -> (* Could not reduce t1' *)
		  subst_simplify2 simp_facts (Terms.make_let_equal t1' t2')
	      | { t_desc = FunApp(f'',[t1'';t2''])}::l when f''.f_cat == LetEqual ->
		  if Terms.equal_terms t1'' t1' then 
		    simplif_add simp_facts (Terms.make_equal t2' t2'')
		  else
		    try_red_t1 l
	      | _::l -> try_red_t1 l
	    in
	    try_red_t1 subst2
	| _ -> 
	    Parsing_helper.internal_error "LetEqual terms should have a variable in the left-hand side"
      end
  | FunApp(f,[t1;t2]) when f.f_cat == Equal ->
      begin
      match (t1.t_desc, t2.t_desc) with
        (FunApp(f1,l1), FunApp(f2,l2)) when
	f1.f_cat == Tuple && f2.f_cat == Tuple && f1 != f2 -> 
	  raise Contradiction
      | (FunApp(f1,l1), FunApp(f2,l2)) when
	(f1.f_options land Settings.fopt_COMPOS) != 0 && f1 == f2 -> 
	  simplif_add_list simp_facts (List.map2 Terms.make_equal l1 l2)
      | (Var(b1,l1), Var(b2,l2)) when
	(Terms.is_restr b1) &&
	(Proba.is_large_term t1 || Proba.is_large_term t2) && (b1 == b2) &&
	(Proba.add_elim_collisions b1 b1) ->
          (* add_proba (Div(Cst 1, Card b1.btype)); * number applications *)
	  simplif_add_list simp_facts (List.map2 Terms.make_equal l1 l2)
      | (Var(b1,l1), Var(b2,l2)) when
	(Terms.is_restr b1) && (Terms.is_restr b2) &&
	(Proba.is_large_term t1 || Proba.is_large_term t2) &&
	(b1 != b2) && (Proba.add_elim_collisions b1 b2) ->
	  raise Contradiction
(*      | (_,_) when simp_facts t1 t2 ->
	  raise Contradiction*)
      | (FunApp(f1,[]), FunApp(f2,[]) ) when
	f1 != f2 && (!Settings.diff_constants) ->
	  raise Contradiction
	  (* Different constants are different *)
      | (_, _) when orient t1 t2 ->
	  subst_simplify2 simp_facts (Terms.make_equal t1 t2)
      | (_, _) when orient t2 t1 -> 
	  subst_simplify2 simp_facts (Terms.make_equal t2 t1)
      | _ -> (subst2, fact::facts, elsefind)
      end
  | FunApp(f,[t1;t2]) when f == Settings.f_and ->
      simplif_add (add_fact simp_facts t1) t2
  | _ -> 
      if Terms.is_false fact then raise Contradiction else
      if Terms.is_true fact then simp_facts else
      (subst2, fact::facts, elsefind)

and subst_simplify2 (subst2, facts, elsefind) link =
  let subst2'' = ref [] in
  let not_subst2_facts = ref [] in
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
	      let t1' = apply_statements_and_collisions (reduce (link :: (!subst2''), facts, elsefind) t') in
	      (t1, t1', red || (!reduced) || (!reduced_subst))
	  | _ -> Parsing_helper.internal_error "If/let/find/new not allowed in subst_simplify2"
	in
	if reduced then
	  not_subst2_facts := Terms.build_term_type Settings.t_bool (FunApp(f,[t1; t1']))
	     :: (!not_subst2_facts)
	else
	  subst2'' := t0 :: (!subst2'')
    | _ -> Parsing_helper.internal_error "substitutions should be Equal or LetEqual terms"
    ) subst2;
  simplif_add_list (link :: (!subst2''),[], elsefind) ((!not_subst2_facts) @ facts)

and simplif_add ((subst2, facts, elsefind) as simp_facts) fact =
(*  print_string "simplif_add "; Display.display_term [] fact; 
  print_string " knowing\n"; display_facts simp_facts; print_newline();*)
  let fact' = apply_reds simp_facts fact in
  add_fact simp_facts fact'

and simplif_add_list simp_facts = function
    [] -> simp_facts
  | (a::l) -> simplif_add_list (simplif_add simp_facts a) l


      

(* f is a function that compares processes; if in different branches 
   of these processes with have two variables (b,b') with arrays accesses,
   it stores (b,b') in diff_var_list.
   If f returns false, the comparison failed. 
   If diff_var_list is not empty, the comparison also failed, but we advise
   merging of arrays so that diff_var_list becomes empty on the next try.
*)

let rec form_advise all_branches =
  let first_branch = List.hd all_branches in
  List.iter (fun bl ->
    if List.length bl != List.length first_branch then
      Parsing_helper.internal_error "All branches should have the same number of variables to merge") all_branches;
  match first_branch with
    [] -> []
  | (_,b0)::_ ->
      let first_vars = List.map List.hd all_branches in
      List.iter (fun (_,b0') ->
	if b0 != b0' then
	  Parsing_helper.internal_error "The variables should be in the same order in all branches") first_vars;
      let first_elem = (b0, Parsing_helper.dummy_ext) :: 
	(List.map (fun (b,_) -> (b, Parsing_helper.dummy_ext)) first_vars) 
      in
      first_elem :: (form_advise (List.map List.tl all_branches))
  

let store_arrays_to_normal f =
  cur_branch_var_list := [];
  all_branches_var_list := [];
  var_no_array_ref := [];
  let r = f() in
  if not r then
    begin
      var_no_array_ref := [];
      all_branches_var_list := [];
      Terms.cleanup_exclude_array_ref();
      false
    end
  else if List.for_all (fun bl -> bl == []) (!all_branches_var_list) then
    begin
      let r' = not (List.exists has_array_ref (!var_no_array_ref)) in
      var_no_array_ref := [];
      all_branches_var_list := [];
      Terms.cleanup_exclude_array_ref();
      r'
    end 
  else 
    begin
      (* Note: I cannot advise MergeArrays with mode MCreateBranchVarAtTerm/AtProc here,
	 because this function is called from simplification, and simplification can
	 modify the process afterwards, so that the term/process references might no longer
	 be correct. I should use mode MCreateBranchVarAtTerm/AtProc in the specialized
	 MergeBranches transformation. *)
      Transform.advise := Terms.add_eq (MergeArrays(List.rev (form_advise (!all_branches_var_list)), MCreateBranchVar)) (!Transform.advise);
      var_no_array_ref := [];
      all_branches_var_list := [];
      Terms.cleanup_exclude_array_ref();
      false
    end
  

let equal_oprocess_store_arrays true_facts p p' =
  eq_oblig := [];
  let r = equal_oprocess [] p p' in
  if not r then
    begin
      cur_branch_var_list := [];
      eq_oblig := [];
      false
    end
  else
    begin
      try 
	let (subst, facts, elsefind) = true_facts in
	let true_facts' = simplif_add_list (subst, [], []) facts in
	let r = List.for_all (fun (t,t') -> simp_equal_terms true_facts' t t') (!eq_oblig) in
	all_branches_var_list := (!cur_branch_var_list) :: (!all_branches_var_list);
	cur_branch_var_list := [];
	eq_oblig := [];
	r
      with Contradiction ->
	(* A contradiction is discovered when adding the facts in true_facts.
	   This means that the current program point is in fact not reachable.
           This may happen because the addition procedure is not exactly the same
           as that used in the rest of simplification, so it may discover some
           new information, but it should be extremely rare. For simplicity, 
	   we ignore the information that the current program point is unreachable. *)
	cur_branch_var_list := [];
	eq_oblig := [];
	false
    end

let equal_oprocess true_facts p p' =
  store_arrays_to_normal (fun () -> 
    equal_oprocess_store_arrays true_facts p p')
      
let equal_term_with_find_store_arrays true_facts t t' =
  eq_oblig := [];
  let r = equal_find_cond [] t t' in
  if not r then
    begin
      cur_branch_var_list := [];
      eq_oblig := [];
      false
    end
  else
    begin
      try 
	let (subst, facts, elsefind) = true_facts in
	let true_facts' = simplif_add_list (subst, [], []) facts in
	let r = List.for_all (fun (t,t') -> simp_equal_terms true_facts' t t') (!eq_oblig) in
	eq_oblig := [];
	all_branches_var_list := (!cur_branch_var_list) :: (!all_branches_var_list);
	cur_branch_var_list := [];
	r
      with Contradiction ->
	(* A contradiction is discovered when adding the facts in true_facts.
	   This means that the current program point is in fact not reachable.
           This may happen because the addition procedure is not exactly the same
           as that used in the rest of simplification, so it may discover some
           new information, but it should be extremely rare. For simplicity, 
	   we ignore the information that the current program point is unreachable. *)
	cur_branch_var_list := [];
	eq_oblig := [];
	false
    end

let equal_term_with_find true_facts t t' =
  store_arrays_to_normal (fun () -> 
    equal_term_with_find_store_arrays true_facts t t')

let needed_vars vars = List.exists has_array_ref vars

let get_in_scope fact_info =
  match fact_info with
    Some(_,_,n) -> Terms.add_def_vars_node [] n
  | None -> Parsing_helper.internal_error "facts should have been set"

let can_merge_all_branches_findE_store_arrays above_t true_facts l0 t3 =
  let in_scope = get_in_scope above_t.t_facts in
  List.iter (fun (bl, def_list, t1, t2) ->
    var_no_array_ref := bl @ (!var_no_array_ref);
    Terms.exclude_array_ref_def_list (bl @ in_scope) def_list;
    Terms.exclude_array_ref_term (bl @ in_scope) t1) l0;
  List.for_all (fun (bl, def_list, t1, t2) ->
    equal_term_with_find_store_arrays true_facts t2 t3
      ) l0

let can_merge_all_branches_findE above_t true_facts l0 t3 =
  store_arrays_to_normal (fun () ->
    can_merge_all_branches_findE_store_arrays above_t true_facts l0 t3)

let can_merge_one_branch_findE_store_arrays above_t true_facts (bl, def_list, t1, t2) t3 =
  let in_scope = get_in_scope above_t.t_facts in
  Terms.exclude_array_ref_def_list (bl @ in_scope) def_list;
  Terms.exclude_array_ref_term (bl @ in_scope) t1;
  var_no_array_ref := bl @ (!var_no_array_ref);
  equal_term_with_find_store_arrays true_facts t2 t3

let can_merge_one_branch_findE above_t true_facts br t3 =
  store_arrays_to_normal (fun () ->
    can_merge_one_branch_findE_store_arrays above_t true_facts br t3)

let can_merge_all_branches_find_store_arrays above_p true_facts l0 p3 =
  let in_scope = get_in_scope above_p.p_facts in
  List.iter (fun (bl, def_list, t1, p2) ->
    var_no_array_ref := bl @ (!var_no_array_ref);
    Terms.exclude_array_ref_def_list (bl @ in_scope) def_list;
    Terms.exclude_array_ref_term (bl @ in_scope) t1) l0;
  List.for_all (fun (bl, def_list, t1, p2) ->
    equal_oprocess_store_arrays true_facts p2 p3) l0

let can_merge_all_branches_find above_p true_facts l0 p3 =
  store_arrays_to_normal (fun () ->
    can_merge_all_branches_find_store_arrays above_p true_facts l0 p3)

let can_merge_one_branch_find_store_arrays above_p true_facts (bl, def_list, t1, p2) p3 =
  let in_scope = get_in_scope above_p.p_facts in
  Terms.exclude_array_ref_def_list (bl @ in_scope) def_list;
  Terms.exclude_array_ref_term (bl @ in_scope) t1;
  var_no_array_ref := bl @ (!var_no_array_ref);
  equal_oprocess_store_arrays true_facts p2 p3

let can_merge_one_branch_find above_p true_facts br p3 =
  store_arrays_to_normal (fun () ->
    can_merge_one_branch_find_store_arrays above_p true_facts br p3)


(* Transformation MergeArrays with merging of array references *)

exception Failed

let has_done_merge = ref false

(* We may use variables to distinguish the branches, and still merge
the arrays even if in some cases we need to know from which branch
they come *)

type new_branch_var_t =
    NoBranchVar
  | CreateBranchVar of binder list
  | CreateBranchVarAtProc of process list * binder list
  | CreateBranchVarAtTerm of term list * binder list

let rename_var (source_to_target_list, _) b =
  let rec ren = function
      [] -> b
    | (source_vars, target_var)::r ->
	if List.memq b source_vars then 
	  target_var
	else
	  ren r
  in
  ren source_to_target_list

let rec swap_rows_columns l =
  if List.hd l == [] then
    []
  else
    (List.map List.hd l)::(swap_rows_columns (List.map List.tl l))

let rec assq2 l1 l2 b =
  match (l1,l2) with
    [],[] -> raise Not_found
  | (b1::r1,b2::r2) ->
      if b1 == b then
	b2
      else
	assq2 r1 r2 b
  | _ -> Parsing_helper.internal_error "Lists should have same length in assq2"

let rec assq2l source_to_target_list l2 b =
  match source_to_target_list with
    [] -> raise Not_found 
  | (source_vars,_)::r ->
      try
	assq2 source_vars l2 b
      with Not_found ->
	assq2l r l2 b

let rec apply_list f target_new_def target_sv_brl sv_brl v =
  match target_new_def with
    [] -> v
  | (target_b, target_l)::r ->
      let v' = apply_list f r target_sv_brl sv_brl v in
      f target_l target_b (assq2 target_sv_brl sv_brl target_b) v'

let add_def_var_find_cond rename_instr t b =
  match rename_instr with
    ((source_vars, target_var)::_), CreateBranchVar brl ->
      begin
	try
	  let b2 = assq2 source_vars brl b in
	  Terms.build_term t (LetE(PatVar b2, Terms.cst_for_type b2.btype, t, None))
	with Not_found -> 
	  t
      end
  | _ -> t

let add_def_var_proc rename_instr p b =
  match rename_instr with
    ((source_vars, target_var)::_), CreateBranchVar brl ->
      begin
	try
	  let b2 = assq2 source_vars brl b in
	  Terms.oproc_from_desc (Let(PatVar b2, Terms.cst_for_type b2.btype, p, Terms.yield_proc))
	with Not_found -> 
	  p
      end
  | _ -> p

let rec merge_term rename_instr t =
  match t.t_desc with
    Var(b,l) ->
      Terms.build_term2 t (Var(rename_var rename_instr b,
			       List.map (merge_term rename_instr) l))
  | FunApp(f,l) ->
      Terms.build_term2 t (FunApp(f, List.map (merge_term rename_instr) l))
  | ResE _ | EventE _ | TestE _ | LetE _ | FindE _ ->
      Parsing_helper.internal_error "new/event/if/let/find unexpected in terms"

let merge_find_branches proc_display proc_subst proc_rename proc_equal proc_merge proc_add_def_var merge_find_cond curr_facts 
    rename_instr l0 p3 =
  let (source_to_target_list, br_vars) = rename_instr in
  let already_defined = 
    match curr_facts with
      Some (_, def_vars, def_node) ->
        def_vars @ def_node.def_vars_at_def @ 
	(List.map (fun b -> (b, b.args_at_creation)) (Terms.add_def_vars_node [] def_node))
    | None -> Parsing_helper.internal_error "p_facts should have been defined"
  in
  let branches_to_merge = ref [] in
  let branches_to_leave_unchanged = ref [] in
  List.iter (function ((bl, def_list, t, p) as branch) ->
    let accu = ref [] in
    List.iter (Terms.close_def_subterm accu) def_list;
    let new_def_conditions = Terms.setminus_binderref (!accu) 
	((List.map (fun b -> (b, b.args_at_creation)) bl) @ already_defined) 
    in
    let new_def_conditions_to_rename = List.filter (fun (b,l) -> 
      List.exists (fun (source_vars, _) -> 
	List.memq b source_vars) source_to_target_list) new_def_conditions 
    in
    match new_def_conditions_to_rename with
      [] -> 
	(* The branch should be left as it is *)
	branches_to_leave_unchanged := branch :: (!branches_to_leave_unchanged)
    | x ->
        (* The branch should be merged with other branches of that find *)
	branches_to_merge := (x, branch) :: (!branches_to_merge)
					      ) l0;
  let l0 = 
    if (!branches_to_merge) == [] then 
      (* Ok, done, just rename as below *)
      l0
    else
      begin
	(*
	print_string "Branches to merge:\n";
	List.iter (function new_def,(bl, def_list, t, p) ->
	  print_string "new_def: ";
	  Display.display_list (fun (b,l) -> Display.display_var [] b l) new_def;
	  print_string " find ";
	  Display.display_list Display.display_binder bl;
	  print_string " suchthat defined(";
	  Display.display_list (fun (b,tl) -> Display.display_var [] b tl) def_list;
	  print_string ") && ";
	  Display.display_term [] t;
	  print_string " then\n";
	  proc_display p
	    ) (!branches_to_merge);
	*)
	try
	  let branches_to_merge = !branches_to_merge in
	  
	  (* choose one of branches_to_merge as target branch (the one that 
	     uses target_var as new_def_conditions_to_rename, if any; otherwise
	     just take one branch as random) *)
	  let (target_new_def, ((target_bl, target_def_list, target_t, target_p) as target_branch)) =
	    try
	      List.find (fun (new_def,_) -> 
		List.exists (fun (b,_) -> 
		  List.exists (fun (_, target_var) -> b == target_var) source_to_target_list
		    ) new_def) branches_to_merge
	    with Not_found ->
              List.hd branches_to_merge
          in
          (*
	    The candidate branches are obtained by renaming target_b[target_l] to
	    b[target_l] for each b in source_vars. We should check that the branches
	    of branches_to_merge are equivalent to those. If this is true, we
	    can replace them with target_branch after renaming all elements of
	    source_vars to target_var. 
	    
	    - Check that the new_def_conditions_to_rename of these
	    branches consist of (b,l) for b that belong to the same
	    "source_vars" branch in the same branch and to distinct
	    "source_vars" branches in distinct branches.  *)
	  let source_vars_by_branches = 
	    swap_rows_columns (List.map fst source_to_target_list)
	  in
	  let (target_b0, target_l) = List.hd target_new_def in
	  let target_sv_brl =
	    List.find (fun bl -> List.memq target_b0 bl) source_vars_by_branches
	  in
	  let remaining_source_vars_by_branches = ref source_vars_by_branches in
	  let branches_to_merge =
	    List.map (fun (new_def, branch) ->
	      let (b0,_) = List.hd new_def in
	      let rec find_b0 seen = function
		  [] -> 
                    (* b0 not found: b0 belongs to a branch that was already found before,
		       so two branches use a variable that belongs to the same "source_vars" branch *) 
		    raise Failed
		| (sv_brl::r) ->
		    if List.memq b0 sv_brl then
		      begin
		        (* b0 found in sv_brl -> all other vars of new_def should also be
			   in sv_brl *)
			List.iter (fun (b,_) -> if not (List.memq b sv_brl) then raise Failed) new_def;
			remaining_source_vars_by_branches := List.rev_append seen r;
			sv_brl
		      end
		    else
		      find_b0 (sv_brl::seen) r
	      in
	      (find_b0 [] (!remaining_source_vars_by_branches), new_def, branch)
		) branches_to_merge
	  in
	  
          (*
	    - Rename all bl of these branches to the bl of the target branch.
	    *)
	  let branches_to_merge_remain = 
	    List.filter (function _,new_def,_ -> new_def != target_new_def) branches_to_merge 
	  in
          let branches_to_merge_remain' = List.map (function sv_brl,new_def,(bl, def_list, t, p) ->
	    if needed_vars bl then 
	      raise Failed;
	    if List.length bl != List.length target_bl then
	      raise Failed;
	    (* TO DO Instead of failing when the variables do not have
	       corresponding types, we could try to reorder them so that
	       they have matching types, or even to satisfy the
	       constraint that l = target_l below. However, it seems
	       difficult to guarantee that the right order will always be
	       found if there is one, since these criteria do not provide 
	       a unique order. *)
	    let subst = List.map2 (fun b b' -> 
	      if b.btype != b'.btype then raise Failed;
	      (b, Terms.term_from_binder b')) bl target_bl in
	    sv_brl, List.map (fun (b,l) -> (b, List.map (Terms.subst3 subst) l)) new_def,
	    (target_bl, Terms.subst_def_list3 subst def_list, 
	     Terms.subst3 subst t, proc_subst subst p)
	      ) branches_to_merge_remain
	  in
          (*
	    - Check that the new_def_conditions_to_rename of these branches
	    consist of (b,l) for the same l (modulo known equalities)
	    *)
	  let true_facts = Facts.get_facts_at curr_facts in
	  let simp_facts = simplif_add_list ([],[],[]) true_facts in
	  List.iter (fun (b,l) ->
	    if not (Terms.equal_lists (equal_term_with_find simp_facts) l target_l) then
	      raise Failed
		) (List.tl target_new_def);
	  List.iter (function _,new_def,_ -> 
	    List.iter (fun (b,l) ->
	      if not (Terms.equal_lists (equal_term_with_find simp_facts) l target_l) then
		raise Failed
		  ) new_def
	      ) branches_to_merge_remain';
          (*
	    - If not all branches of source_vars appear as new_def_conditions_to_rename,
	    check that the remaining branches are not needed, i.e.
	    check that 
	         let def_list' be obtained by renaming target_b[target_l] to b[target_l] 
                 in the "def_list" of target_branch (use Transform.rename_binder)
	         b[target_l] cannot be defined when def_list' is defined
	    where target_b[target_l] is an element of target_new_def and b is the variable
	    corresponding to target_b in the missing branch (i.e. b = assq2 target_sv_brl sv_brl target_b).
	    *)
          List.iter (fun sv_brl ->
            (* sv_brl is a missing branch *)
	    let def_list' = List.map (apply_list Transform.rename_binder target_new_def target_sv_brl sv_brl) target_def_list in
	    let accu = ref [] in
	    List.iter (Terms.close_def_subterm accu) def_list';
	    if List.for_all (fun br -> 
	      List.for_all (fun (target_b,target_l) -> 
		let b = assq2 target_sv_brl sv_brl target_b in 
		Terms.is_compatible br (b,target_l)
		  ) target_new_def
		) (!accu) then
	      try
		let facts = Facts.facts_from_defined None target_bl def_list' in
		let simp_facts' = simplif_add_list simp_facts facts in
		let t' = apply_list Transform.rename_term target_new_def target_sv_brl sv_brl target_t in
		let _ = simplif_add simp_facts' t' in
		(* The condition deflist' & t' does not imply a contradiction, I would need
		   a branch "deflist' & t' then ..." to be present in order to be able to 
		   merge the branches, so I raise Failed. *)
		raise Failed
	      with Contradiction -> ()
		  ) (!remaining_source_vars_by_branches);

         (*
	     - Check that all branches_to_merge are "equal" modulo known equalities, i.e.
	       for each element of branches_to_merge except the target branch, 
	       rename target_b[target_l] to b[target_l] in target_branch 
               (use Transform.rename_term/binder/oprocess)
	       where target_b[target_l] is an element of target_new_def and b is the variable
	       corresponding to target_b in the current branch (i.e. b = assq2 target_sv_brl sv_brl target_b). 
	       Check that, for the obtained branch,
	         def_list of branch is defined iff def_list of renamed_target_branch is defined;
	         when they are defined, the condition and process are equal (modulo known equalities)
	   *)
          List.iter (function sv_brl,_,(bl, def_list, t, p) ->
	    (* new_bl = target_bl = bl by the previous renaming *)
	    let new_def_list = List.map (apply_list Transform.rename_binder target_new_def target_sv_brl sv_brl) target_def_list in
	    let new_t = apply_list Transform.rename_term target_new_def target_sv_brl sv_brl target_t in
	    let new_p = apply_list proc_rename target_new_def target_sv_brl sv_brl target_p in
	    
	    begin
	      try
		let new_def_list_implied = Facts.def_vars_from_defined None bl new_def_list in
		if not (List.for_all (fun br -> Terms.mem_binderref br new_def_list_implied) def_list) then
		  raise Failed
	      with Contradiction -> ()
	    end;
	    begin
	      try
		let def_list_implied = Facts.def_vars_from_defined None bl def_list in
		if not (List.for_all (fun br -> Terms.mem_binderref br def_list_implied) new_def_list) then
		  raise Failed
	      with Contradiction -> ()
	    end;
	    begin
	      try
		let facts = Facts.facts_from_defined None bl def_list in
		let simp_facts' = simplif_add_list simp_facts facts in
		if not (equal_term_with_find simp_facts' t new_t) then
		  raise Failed;
		let simp_facts'' = simplif_add simp_facts' t in
		if not (proc_equal simp_facts'' p new_p) then
		  raise Failed
	      with Contradiction -> ()
	    end
	      ) branches_to_merge_remain';
	  
	  has_done_merge := true;
	  target_branch :: (!branches_to_leave_unchanged)
	with Failed ->
	  match br_vars with
	    NoBranchVar -> raise Failed
	  | CreateBranchVar brl | CreateBranchVarAtProc(_,brl) | CreateBranchVarAtTerm(_,brl) ->
	      (* When the merging fails, we can still succeed by keeping each branch, 
		 adding a test defined(bi[l]) for each (b,l) in new_def_conditions_to_rename 
		 where bi is the variable of br_vars that corresponds to the element b of source_vars.
		 Then we rename the branch as other branches (bi will remain) *)
	      (List.map (fun (new_def, (bl, def_list, t, p)) ->
		(bl, (List.map (fun (b,l) -> 
		  let b' = assq2l source_to_target_list brl b in 
		  (b', Terms.lsuffix (List.length b'.args_at_creation) l)) new_def) @ def_list, t, p)
		  ) (!branches_to_merge)) @ (!branches_to_leave_unchanged)
      end
  in
  let p3' = proc_merge rename_instr p3 in
  let l0' = List.map (fun (bl, def_list, t, p) ->
    let bl' = List.map (rename_var rename_instr) bl in
    let def_list' = List.map (fun (b,l) -> (rename_var rename_instr b, 
					    List.map (merge_term rename_instr) l)) def_list in
    let p' = proc_merge rename_instr p in
    let t' = merge_find_cond rename_instr t in
    (bl', def_list', t', List.fold_left (proc_add_def_var rename_instr) p' bl)
	  (* TO DO is there a problem if I refer to variables added by 
	     "List.fold_left (add_def_var_find_cond rename_instr) __ bl"
	     inside def_list' or t'? 
	     Related to the question of whether bl is considered defined inside def_list/t
	     i.e. when I test defined(b[j]) for b in bl can be true for j = the current repl index?
	     It should not I think (but I should check the semantics) and in this case,
	     I think there is no problem: the variables added by
	     "List.fold_left (add_def_var_find_cond rename_instr) __ bl"
	     are defined exactly when bl is defined.
	     I checked the semantics and there is indeed something strange in the semantics:
	     in find u <= N suchthat defined(...) & M then ...
	     u[curr. repl. index] is considered defined in M (to the value currently under inspection), 
	     which may cause unexpected behaviors if we use u[M'] for some other M'.
	     *) 
      ) l0 
  in
  (l0',p3')
    
let rec merge_find_cond rename_instr t =
  let t' = 
  match t.t_desc with
    ResE(b,p) ->
      Terms.build_term2 t (ResE(rename_var rename_instr b, 
				add_def_var_find_cond rename_instr (merge_find_cond rename_instr p) b))
  | EventE _ ->
      Parsing_helper.internal_error "event should not occur as term"
  | TestE(t1,t2,t3) ->
      let t1' = merge_term rename_instr t1 in
      let t2' = merge_find_cond rename_instr t2 in
      let t3' = merge_find_cond rename_instr t3 in
      Terms.build_term2 t (TestE(t1',t2',t3'))
  | LetE(pat,t1,t2,topt) ->
      let pat' = merge_pat rename_instr pat in
      let t1' = merge_term rename_instr t1 in      
      let t2' = merge_find_cond rename_instr t2 in
      let topt' = 
	match topt with
	  None -> None
	| Some t3 -> Some (merge_find_cond rename_instr t3)
      in
      let pat_vars = Terms.vars_from_pat [] pat in
      Terms.build_term2 t (LetE(pat',t1', List.fold_left (add_def_var_find_cond rename_instr) t2' pat_vars,topt'))
  | FindE(l0,t3, find_info) ->
      begin
	try
	  let (l0', t3') = merge_find_branches (Display.display_term []) 
	      Terms.subst3 Transform.rename_term equal_term_with_find 
	      merge_find_cond add_def_var_find_cond merge_find_cond t.t_facts rename_instr l0 t3
	  in
	  Terms.build_term2 t (FindE(l0',t3',find_info))
	with Contradiction ->
	  (* When there is a contradiction here, the Find is in fact unreachable *)
	  t3
      end
  | Var _ | FunApp _ -> 
      merge_term rename_instr t 
  in
  let (_, br_vars) = rename_instr in
  match br_vars with
    CreateBranchVarAtTerm(tl,bl) ->
      begin
	try
	  let b = assq2 tl bl t in
	  Terms.build_term t (LetE(PatVar b, Terms.cst_for_type b.btype, t', None))
	with Not_found ->
	  t'
      end
  | _ -> t'


and merge_pat rename_instr = function
    PatVar b -> PatVar (rename_var rename_instr b)
  | PatTuple(f,l) -> PatTuple(f, List.map (merge_pat rename_instr) l)
  | PatEqual t -> PatEqual (merge_term rename_instr t)

let rec merge_i rename_instr p =
  let p_desc' =
  match p.i_desc with
    Nil -> Nil
  | Par(p1,p2) ->
      Par(merge_i rename_instr p1,
	  merge_i rename_instr p2)
  | Repl(b,p) ->
      Repl(b, merge_i rename_instr p)
  | Input((c,tl),pat, p) ->
      let tl' = List.map (merge_term rename_instr) tl in 
      let pat' = merge_pat rename_instr pat in
      let p' = merge_o rename_instr p in
      let pat_vars = Terms.vars_from_pat [] pat in
      let p'' = List.fold_left (add_def_var_proc rename_instr) p' pat_vars in
      Input((c,tl'),pat',p'')
  in
  Terms.iproc_from_desc2 p p_desc'

and merge_o rename_instr p =
  let p_desc' =
    match p.p_desc with
      Yield -> Yield
    | Restr(b,p) ->
	Restr(rename_var rename_instr b, 
	      add_def_var_proc rename_instr (merge_o rename_instr p) b)
    | Test(t,p1,p2) ->
	let t' = merge_term rename_instr t in
	let p1' = merge_o rename_instr p1 in
	let p2' = merge_o rename_instr p2 in
	Test(t',p1',p2')
    | EventP(t,p) ->
	let t' = merge_term rename_instr t in
	let p' = merge_o rename_instr p in
	EventP(t',p')
    | Let(pat,t,p1,p2) ->
	let pat' = merge_pat rename_instr pat in
	let t' = merge_term rename_instr t in      
	let p1' = merge_o rename_instr p1 in
	let p2' = merge_o rename_instr p2 in
	let pat_vars = Terms.vars_from_pat [] pat in
	Let(pat',t', List.fold_left (add_def_var_proc rename_instr) p1' pat_vars,p2')
    | Find(l0,p3,find_info) ->
	begin
	  try
	    let (l0', p3') = merge_find_branches (Display.display_oprocess [] "  ") 
		Terms.subst_oprocess3 Transform.rename_oprocess equal_oprocess 
		merge_o add_def_var_proc merge_find_cond p.p_facts rename_instr l0 p3
	    in
	    Find(l0',p3',find_info)
	  with Contradiction ->
	    (* When there is a contradiction here, the Find is in fact unreachable *)
	    Yield
	end
    | Output((c,tl),t,p) ->
	let tl' = List.map (merge_term rename_instr) tl in 
	let t' = merge_term rename_instr t in
	let p' = merge_i rename_instr p in
	Output((c,tl'),t',p')
  in
  let p' = Terms.oproc_from_desc2 p p_desc' in
  let (_, br_vars) = rename_instr in
  match br_vars with
    CreateBranchVarAtProc(pl,bl) ->
      begin
	try
	  let b = assq2 pl bl p in
	  Terms.oproc_from_desc (Let(PatVar b, Terms.cst_for_type b.btype, p', Terms.yield_proc))
	with Not_found ->
	  p'
      end
  | _ -> p'

let is_def_before (b1,_) (b,_) =
  match b.def with
    [n] -> List.memq b1 (Terms.add_def_vars_node [] n)
  | _ -> Parsing_helper.internal_error "Variable should have exactly one definition in Mergebranches.is_def_before"

let check_distinct_branch (b,ext) (b', ext') =
  if (Binderset.mem b'.compatible b) || 
     (Binderset.mem b.compatible b') then
    raise(Error("For merging arrays, variable " ^
		(Display.binder_to_string b) ^ 
		" should not be defined for the same indices as " ^ 
		(Display.binder_to_string b'), ext))

(*
merge_arrays merges arrays contained in bll. bll is a list of list of variables, say
bll = [[b11, ..., b1n],[b21, ..., b2n], ..., [bk1, ..., bkn]]
(Each list must contain the same number of variables; this MUST be checked before
calling merge_arrays.)

- each list [bi1,...,bin] corresponds to variables to merge together, they
are merged to bi1. Heuristic: the chances of success are probably higher if
bi1 comes from the "else" branch; indeed, the code of the various branches
is merged towards the code of the branch that contains bi1, and the code of 
the "else" branch is more generic because other branches can take advantage
of the tested conditions to use a different code.

- the variables bij for all i at the same position j in the various lists 
are expected to belong to the same branch. bij for i > 1 should preferably
be defined under the definition of b1j; this allows the algorithm to introduce
a new variable b'j defined when b1j is defined, and to use defined(b'j) to test
whether one is in branch j.

merge_arrays has several modes of operation, selected by the argument "mode":
- one in which br_vars are never introduced (MNoBranchVar)
- one in which br_vars may be introduced by the transformation at the point where
the first variable of each branch b1j is defined, if bij for i > 1 is 
defined under b1j (MCreateBranchVar)
- one in which br_vars are introduced at a program point specified in argument
(MCreateBranchVarAtProc / MCreateBranchVarAtTerm). The caller MUST make sure
bij for all i is defined under the j-th program point pj, and that these
program points cannot be executed for the same value of the replication indices.
So this mode can be used in advised instructions, but not for instructions
given by the user.

Note: if merge_arrays introduces new variables b'j to distinguish branches, and
later we could merge the branches that were still distinguished, we can
do that by calling merge_arrays again with argument the b'j.  
*)

let merge_arrays simplify_internal_info bll mode g =
  Terms.array_ref_process g.proc;
  Terms.build_def_process None g.proc;
  Terms.build_compatible_defs g.proc;
  Proba.reset [] simplify_internal_info g;
  has_done_merge := false;
  List.iter (fun bl ->
    match bl with
      [] -> Parsing_helper.internal_error "List of binder to merge should not be empty"
    | ((b1,ext1)::br) ->
	List.iter (fun (b,ext) -> 
	  if b.btype != b1.btype then
	    raise(Error("For merging arrays, variable " ^
			(Display.binder_to_string b) ^ 
			" should have the same type as " ^
			(Display.binder_to_string b1), ext));
	  if not (Terms.equal_term_lists b.args_at_creation b1.args_at_creation) then
	    raise(Error("For merging arrays, variable " ^
			(Display.binder_to_string b) ^ 
			" should have the same indices as " ^
			(Display.binder_to_string b1), ext))
	      ) br;
	List.iter (fun (b, ext) -> 
	  if Transform.occurs_in_queries b then
	    raise(Error("For merging arrays, variable " ^
			(Display.binder_to_string b) ^ 
			" should not occur in queries", ext));
	  if b.count_def > 1 then
	    raise(Error("For merging arrays, variable " ^
			(Display.binder_to_string b) ^ 
			" should have a single definition", ext));
	  if b.count_def = 0 then
	    raise(Error("Variable " ^ (Display.binder_to_string b) ^ 
			" should be defined", ext))
	      ) bl;
	) bll;
  let bll_br = swap_rows_columns bll in
  let rec check_pairwise_distinct_branches = function
      [] -> ()
    | bl::r ->
	check_pairwise_distinct_branches r;
	List.iter (fun b -> 
	  List.iter (List.iter (check_distinct_branch b)) r
	    ) bl
  in
  check_pairwise_distinct_branches bll_br;
  match bll with
    [] -> Parsing_helper.internal_error "List of list of binders to merge should not be empty"
  | bl1::blr ->
      let branch_vars =
	match mode with
	  MNoBranchVar -> NoBranchVar
	| MCreateBranchVar ->
	    if List.for_all (fun bl -> 
	      List.for_all2 is_def_before bl1 bl
		) blr then
	      CreateBranchVar (List.map (fun (b,_) -> Terms.new_binder b) bl1)
	    else
	      NoBranchVar
	| MCreateBranchVarAtProc(pl, cur_array) ->
	    CreateBranchVarAtProc(pl, List.map (fun (b,_) -> 
	      Terms.create_binder "@br" (Terms.new_vname()) b.btype (List.map Terms.term_from_binder cur_array)) bl1)
	| MCreateBranchVarAtTerm(tl, cur_array) ->
	    CreateBranchVarAtTerm(tl, List.map (fun (b,_) -> 
	      Terms.create_binder "@br" (Terms.new_vname()) b.btype (List.map Terms.term_from_binder cur_array)) bl1)
      in
      try
	let bll_no_ext = List.map (List.map fst) bll in
	let p' = merge_i (List.map (fun bl -> bl, List.hd bl) bll_no_ext, branch_vars) g.proc in
	(* If the variables have array references only at defined conditions,
	   and no real merge has been done, the transformation is useless: 
	   I would just use different variables to distinguish the branches. 
	   So in this case, I cancel the transformation. *)
	if (!has_done_merge) || (List.exists (fun bl ->
	  List.exists (fun (b,_) -> b.array_ref) bl
	    ) bll) then
	  begin
	    Transform.changed := true;
	    Terms.empty_comp_process g.proc;
	    (* Display.display_process p'; *)
	    let proba = Proba.final_add_proba [] in
	    ({ proc = p'; game_number = -1 }, proba, Proba.final_internal_info(), None)
	  end
	else
	  begin
	    Terms.empty_comp_process g.proc;
	    (g, [], simplify_internal_info, None)
	  end
      with 
	Failed ->
	  Terms.empty_comp_process g.proc;
	  (g, [], simplify_internal_info, None)
      | Error(mess,ext) ->
	  Terms.empty_comp_process g.proc;
	  raise (Error(mess,ext))
  
(* Merge as many branches of if/let/find as possible.
   Simplify already does a bit of this, but this function is more powerful
1st step: store the merges that may be done if array accesses are removed
2nd step: iterate, removing merges that cannot be done because the desired
array accesses cannot be removed
3rd step: 
   if some merges can be done, do them
   if some merges can be done and some have been excluded, iterate
   if no merges can be done, advise MergeBranches for the excluded merges.
 *)

(*
A merge is stored as
- the main process/term to merge (if/let/find)
- the list of branches to merge
  (these branches must be in the same order as the one output by
  form_advise, that is, else branch first, then the other branches in
  the same order as they appear in the process)
- the value of cur_array at that point
- the value of all_branches_var_list
- the list of variables that must have no array accesses for the 
  merge to be possible (!var_no_array_ref)
- a list of pairs (variables, number of array accesses to that 
  variable that can be removed by the merge)
*)

type merge_t =
    MergeFindCond of term * term list
  | MergeProcess of process * process list

type merge_tt = merge_t * binder list * (binder * binder) list list * binder list * (binder * int) list
    
let merges_to_do = ref ([] : merge_tt list)

let merges_cannot_be_done = ref ([] : merge_tt list)

let add_advice (merge_type, cur_array, all_branches_var_list, _, _) = 
  (* If I want to give an explicit location for variable creations, 
     I can give only one "MergeArrays" instruction, because after the first one,
     the location will no longer be up-to-date, and I should run it directly
     without giving it as advice, because if I give it as advice, I am not
     sure that it will be immediately executed, so the location may not be
     up-to-date when I execute it.

  let var_loc = 
    match merge_type with
      MergeFindCond(_, tl) -> MCreateBranchVarAtTerm(tl, cur_array)
    | MergeProcess(_,pl) -> MCreateBranchVarAtProc(pl, cur_array)
  in

     Furthermore, the advice is not always good! (r_362,r_404 in EKE)
     (when I advise MergeArrays in mode MCreateBranchVar).

     To avoid the risk of giving bad advice, I choose to advise
     MergeArrays in mode "MNoBranchVar", so that MergeArrays succeeds perhaps
     less often, but when MergeArrays succeeds, it has really simplified the game.
  *)
  if not (List.for_all (fun l -> l == []) all_branches_var_list) then
    Transform.advise := Terms.add_eq (MergeArrays(List.rev (form_advise all_branches_var_list), MNoBranchVar)) (!Transform.advise)


(* First step *) 

let rec collect_merges_find_cond find_indices cur_array t =
  match t.t_desc with
    Var _ | FunApp _ -> ()
  | EventE _ -> Parsing_helper.internal_error "EventE should have been expanded"
  | ResE(_,t) -> collect_merges_find_cond find_indices cur_array t
  | TestE(t1,t2,t3) ->
      begin
	try
	  all_branches_var_list := [];
	  cur_branch_var_list := [];
	  var_no_array_ref := [];
	  let true_facts = Facts.get_facts_at t.t_facts in
	  let simp_facts = Facts.simplif_add_list Facts.no_dependency_anal ([],[],[]) true_facts in
	  if equal_term_with_find_store_arrays simp_facts t2 t3 then
	    begin
	      merges_to_do := (MergeFindCond(t, [t3;t2]), cur_array, !all_branches_var_list, !var_no_array_ref, []) :: (!merges_to_do);
	      var_no_array_ref := [];
	      all_branches_var_list := []
	    end;
	with Contradiction ->
	  (* The current program point is unreachable. I could in fact
	     perform the merge, but the most natural thing to do is to
	     use simplication to remove unreachable code.
	     No need to clean-up, because the contradiction occurs when computing
	     true_facts/simp_facts before storing anything in 
	     all_branches_var_list/cur_branch_var_list/var_no_array_ref.
	     Other contradictions are caught in 
	     equal_oprocess_store_arrays/equal_term_with_find_store_arrays *)
	  ()
      end;
      collect_merges_find_cond find_indices cur_array t2;
      collect_merges_find_cond find_indices cur_array t3
  | LetE(pat,t1,t2,topt) ->
      begin
	match topt with
	  None -> collect_merges_find_cond find_indices cur_array t2
	| Some t3 ->
	    begin
	      try 
		all_branches_var_list := [];
		cur_branch_var_list := [];
		var_no_array_ref := [];
		let true_facts = Facts.get_facts_at t.t_facts in
		let simp_facts = Facts.simplif_add_list Facts.no_dependency_anal ([],[],[]) true_facts in
		if equal_term_with_find_store_arrays simp_facts t2 t3 then
		  begin
		    merges_to_do := (MergeFindCond(t, [t3;t2]), cur_array, !all_branches_var_list, Terms.vars_from_pat (!var_no_array_ref) pat, []) :: (!merges_to_do);
		    var_no_array_ref := [];
		    all_branches_var_list := []
		  end;
	      with Contradiction ->
		()
	    end;
	    collect_merges_find_cond find_indices cur_array t2;
	    collect_merges_find_cond find_indices cur_array t3
      end
  | FindE(l0,t3,find_info) -> 
      collect_merges_find_cond find_indices cur_array t3;
      let true_facts = Facts.get_facts_at t.t_facts in
      let simp_facts = Facts.simplif_add_list Facts.no_dependency_anal ([],[],[]) true_facts in
      if Simplify1.is_find_unique (find_indices @ cur_array) t.t_facts simp_facts l0 then
	begin
	  try
	    List.iter (fun ((bl, def_list, t1, t2) as br) ->
	      all_branches_var_list := [];
	      cur_branch_var_list := [];
	      var_no_array_ref := [];
	      let r = can_merge_one_branch_findE_store_arrays t simp_facts br t3 in
	      if r then
		merges_to_do := (MergeFindCond(t, [t3;t2]), 
				 cur_array, !all_branches_var_list, !var_no_array_ref, 
				 List.map (fun b -> (b, b.count_exclude_array_ref)) (!Terms.all_vars_exclude))
		   :: (!merges_to_do);
	      var_no_array_ref := [];
	      all_branches_var_list := [];
	      Terms.cleanup_exclude_array_ref();
	      collect_merges_find_cond find_indices cur_array t2;
	      if not r then
		collect_merges_find_cond (bl @ find_indices) cur_array t1
		  ) l0
	  with Contradiction ->
	    ()
	end
      else
	begin
	  try
	    all_branches_var_list := [];
	    cur_branch_var_list := [];
	    var_no_array_ref := [];
	    let r = can_merge_all_branches_findE_store_arrays t simp_facts l0 t3 in
	    if r then
	      merges_to_do := (MergeFindCond(t, t3 :: List.map (fun (_,_,_,t2) -> t2) l0), 
			       cur_array, !all_branches_var_list, !var_no_array_ref, 
			       List.map (fun b -> (b, b.count_exclude_array_ref)) (!Terms.all_vars_exclude))
		 :: (!merges_to_do);
	    var_no_array_ref := [];
	    all_branches_var_list := [];
	    Terms.cleanup_exclude_array_ref();
	    List.iter (fun (_,_,_,t2) -> collect_merges_find_cond find_indices cur_array t2) l0;
	    if not r then
	      List.iter (fun (bl,_,t1,_) -> collect_merges_find_cond (bl @ find_indices) cur_array t1) l0
	  with Contradiction ->
	    ()
	end
	    
let rec collect_merges_i cur_array p =
  match p.i_desc with
    Nil -> ()
  | Par(p1,p2) ->
      collect_merges_i cur_array p1;
      collect_merges_i cur_array p2
  | Repl(b,p) ->
      collect_merges_i (b::cur_array) p
  | Input(_,_, p) ->
      collect_merges_o cur_array p
    
and collect_merges_o cur_array p =
  match p.p_desc with
    Yield -> ()
  | Restr(b,p) ->
      collect_merges_o cur_array p
  | EventP(t,p) ->
      collect_merges_o cur_array p
  | Test(t,p1,p2) ->
      begin
	try
	  all_branches_var_list := [];
	  cur_branch_var_list := [];
	  var_no_array_ref := [];
	  let true_facts = Facts.get_facts_at p.p_facts in
	  let simp_facts = Facts.simplif_add_list Facts.no_dependency_anal ([],[],[]) true_facts in
	  if equal_oprocess_store_arrays simp_facts p1 p2 then
	    begin
	      merges_to_do := (MergeProcess(p, [p2;p1]), cur_array, !all_branches_var_list, !var_no_array_ref, []) :: (!merges_to_do);
	      var_no_array_ref := [];
	      all_branches_var_list := []
	    end;
	with Contradiction ->
	  ()
      end;
      collect_merges_o cur_array p1;
      collect_merges_o cur_array p2
  | Let(pat,t,p1,p2) ->
      begin
	try
	  all_branches_var_list := [];
	  cur_branch_var_list := [];
	  var_no_array_ref := [];
	  let true_facts = Facts.get_facts_at p.p_facts in
	  let simp_facts = Facts.simplif_add_list Facts.no_dependency_anal ([],[],[]) true_facts in
	  if equal_oprocess_store_arrays simp_facts p1 p2 then
	    begin
	      merges_to_do := (MergeProcess(p, [p2;p1]), cur_array, !all_branches_var_list, Terms.vars_from_pat (!var_no_array_ref) pat, []) :: (!merges_to_do);
	      var_no_array_ref := [];
	      all_branches_var_list := []
	    end;
	with Contradiction ->
	  ()
      end;
      collect_merges_o cur_array p1;
      collect_merges_o cur_array p2
  | Find(l0,p3,find_info) ->
      collect_merges_o cur_array p3;
      let true_facts = Facts.get_facts_at p.p_facts in
      let simp_facts = Facts.simplif_add_list Facts.no_dependency_anal ([],[],[]) true_facts in
      let is_unique = Simplify1.is_find_unique cur_array p.p_facts simp_facts l0 in
      if is_unique then
	begin
	  try
	    List.iter (fun ((bl, def_list, t1, p2) as br) ->
	      all_branches_var_list := [];
	      cur_branch_var_list := [];
	      var_no_array_ref := [];
	      let r = can_merge_one_branch_find_store_arrays p simp_facts br p3 in
	      if r then
	      merges_to_do := (MergeProcess(p, [p3;p2]), 
			       cur_array, !all_branches_var_list, !var_no_array_ref, 
			       List.map (fun b -> (b, b.count_exclude_array_ref)) (!Terms.all_vars_exclude))
		 :: (!merges_to_do);
	      var_no_array_ref := [];
	      all_branches_var_list := [];
	      Terms.cleanup_exclude_array_ref();
	      collect_merges_o cur_array p2;
	      if not r then
		collect_merges_find_cond bl cur_array t1
		  ) l0
	  with Contradiction -> 
	    ()
	end
      else
	begin
	  try 
	    all_branches_var_list := [];
	    cur_branch_var_list := [];
	    var_no_array_ref := [];
	    let r = can_merge_all_branches_find_store_arrays p simp_facts l0 p3 in
	    if r then
	      merges_to_do := (MergeProcess(p, p3 :: List.map (fun (_,_,_,p2) -> p2) l0), 
			       cur_array, !all_branches_var_list, !var_no_array_ref, 
			       List.map (fun b -> (b, b.count_exclude_array_ref)) (!Terms.all_vars_exclude))
		 :: (!merges_to_do);
	    var_no_array_ref := [];
	    all_branches_var_list := [];
	    Terms.cleanup_exclude_array_ref();
	    List.iter (fun (_,_,_,p2) -> collect_merges_o cur_array p2) l0;
	    if not r then
	      List.iter (fun (bl,_,t1,_) -> collect_merges_find_cond bl cur_array t1) l0
	  with Contradiction ->
	    ()
	end
  | Output(_,_,p) ->
      collect_merges_i cur_array p

(* Second step *)

let rec remove_impossible_merges() =
  Terms.all_vars_exclude := [];
  List.iter (fun (_,_,_,_,l) ->
    List.iter (fun (b,n) -> 
      b.count_exclude_array_ref <- b.count_exclude_array_ref + n;
      Terms.all_vars_exclude := b :: (!Terms.all_vars_exclude)
				       ) l
      ) (!merges_to_do);
  let need_to_iterate = ref false in
  merges_to_do := List.filter (fun ((_,_,_,l,_) as merge) ->
    let r = List.exists has_array_ref l in
    if r then
      begin
	need_to_iterate := true;
	merges_cannot_be_done := merge :: (!merges_cannot_be_done)
      end;
    not r) (!merges_to_do);
  Terms.cleanup_exclude_array_ref();
  if !need_to_iterate then
    remove_impossible_merges()



(* Third step *)

let rec do_merges_find_cond t =
  match t.t_desc with
    Var _ | FunApp _ -> t
  | EventE _ -> Parsing_helper.internal_error "EventE should have been expanded"
  | ResE(b,t1) ->
      let t1' = do_merges_find_cond t1 in
      Terms.build_term2 t (ResE(b,t1'))
  | TestE(t1,t2,t3) ->
      if List.exists (function
	  (MergeFindCond(t',_),_,_,_,_) -> t' == t
	| _ -> false) (!merges_to_do)
      then
	(* Merge the test *)
	do_merges_find_cond t3
      else
	let t2' = do_merges_find_cond t2 in
	let t3' = do_merges_find_cond t3 in
	Terms.build_term2 t (TestE(t1,t2',t3'))
  | LetE(pat,t1,t2,topt) ->
      begin
	match topt with
	  None ->
	    let t2' = do_merges_find_cond t2 in
	    Terms.build_term2 t (LetE(pat,t1,t2',None))
	| Some t3 ->
	    if List.exists (function
		(MergeFindCond(t',_),_,_,_,_) -> t' == t
	      | _ -> false) (!merges_to_do)
	    then
	      (* Merge the let *)
	      do_merges_find_cond t3
	    else
	      let t2' = do_merges_find_cond t2 in
	      let t3' = do_merges_find_cond t3 in
	      Terms.build_term2 t (LetE(pat,t1,t2',Some t3'))
      end
  | FindE(l0,t3, find_info) ->
      let t3' = do_merges_find_cond t3 in
      if List.exists (function
	  (MergeFindCond(t',l),_,_,_,_) -> (t' == t) && (List.length l0 + 1 = List.length l)
	| _ -> false) (!merges_to_do)
      then
	(* Merge all branches of the find *)
	t3'
      else
	(* May merge some branches of the find
	   l0' = list with the merged branches removed *)
	let l0' = List.filter (fun (_,_,_,t2) ->
	  not (List.exists (function
	      (MergeFindCond(t',[t3';t2']),_,_,_,_) -> (t' == t) && (t3' == t3) && (t2' == t2)
	    | _ -> false) (!merges_to_do))) l0
	in
	if l0' == [] then
	  t3'
	else
	  let l0'' = List.map (fun (bl, def_list, t1, t2) ->
	    (bl, def_list, do_merges_find_cond t1, do_merges_find_cond t2)) l0' in
	  Terms.build_term2 t (FindE(l0'',t3',find_info))

let rec do_merges_i p =
  let p_desc' =
  match p.i_desc with
    Nil -> Nil
  | Par(p1,p2) ->
      Par(do_merges_i p1,
	  do_merges_i p2)
  | Repl(b,p) ->
      Repl(b, do_merges_i p)
  | Input(ch,pat, p) ->
      Input(ch,pat,do_merges_o p)
  in
  Terms.iproc_from_desc2 p p_desc'

and do_merges_o p =
  match p.p_desc with
    Yield -> p
  | Restr(b,p1) ->    
      Terms.oproc_from_desc2 p (Restr(b, do_merges_o p1))
  | EventP(t,p1) ->
      Terms.oproc_from_desc2 p (EventP(t, do_merges_o p1))
  | Test(t,p1,p2) ->
      if List.exists (function
	  (MergeProcess(p',_),_,_,_,_) -> p' == p
	| _ -> false) (!merges_to_do)
      then
	(* Merge the test *)
	do_merges_o p2
      else
	let p1' = do_merges_o p1 in
	let p2' = do_merges_o p2 in
	Terms.oproc_from_desc2 p (Test(t,p1',p2'))
  | Let(pat,t,p1,p2) ->
      if List.exists (function
	  (MergeProcess(p',_),_,_,_,_) -> p' == p
	| _ -> false) (!merges_to_do)
      then
	(* Merge the let *)
	do_merges_o p2
      else
	let p1' = do_merges_o p1 in
	let p2' = do_merges_o p2 in
	Terms.oproc_from_desc2 p (Let(pat, t,p1',p2'))
  | Find(l0,p3,find_info) ->
      let p3' = do_merges_o p3 in
      if List.exists (function
	  (MergeProcess(p',l),_,_,_,_) -> (p' == p) && (List.length l0 + 1 = List.length l)
	| _ -> false) (!merges_to_do)
      then
	(* Merge all branches of the find *)
	p3'
      else
	(* May merge some branches of the find
	   l0' = list with the merged branches removed *)
	let l0' = List.filter (fun (_,_,_,p2) ->
	  not (List.exists (function
	      (MergeProcess(p',[p3';p2']),_,_,_,_) -> (p' == p) && (p3' == p3) && (p2' == p2)
	    | _ -> false) (!merges_to_do))) l0
	in
	if l0' == [] then
	  p3'
	else
	  let l0'' = List.map (fun (bl, def_list, t1, p2) ->
	    (bl, def_list, do_merges_find_cond t1, do_merges_o p2)) l0' in
	  Terms.oproc_from_desc2 p (Find(l0'',p3',find_info))
  | Output(ch,t,p1) ->
      Terms.oproc_from_desc2 p (Output(ch, t, do_merges_i p1))

let display_merge = function
    (MergeProcess(p,l),_,_,_,_) ->
      print_string "Merging ";
      Display.display_oprocess [] "" p;
      print_string "Branches ";
      Display.display_list (fun p -> Display.display_oprocess [] "" p) l;
      print_newline()
  | (MergeFindCond(t,l),_,_,_,_) ->
      print_string "Merging ";
      Display.display_term [] t;
      print_string "Branches ";
      Display.display_list (fun t -> Display.display_term [] t) l;
      print_newline()
      

let merge_branches simplify_internal_info g =
  Terms.array_ref_process g.proc;
  Terms.build_def_process None g.proc;
  Proba.reset [] simplify_internal_info g;
  Simplify1.term_collisions := [];
  let old_merge_arrays = !Settings.merge_arrays in
  Settings.merge_arrays := true;
  merges_to_do := [];
  merges_cannot_be_done := [];
  collect_merges_i [] g.proc;
  if (!merges_to_do) == [] then
    begin
      (* No merge can be done *)
      Settings.merge_arrays := old_merge_arrays;
      (g, [], simplify_internal_info, None)
    end
  else
    begin
      (* See which merges can be done, if we remove enough array references *)
      remove_impossible_merges();
      (* List.iter display_merge (!merges_to_do); *)
      if (!merges_to_do) != [] then
        (* Perform the possible merges *)
	let p' = do_merges_i g.proc in
	Transform.changed := true;
        (* TO DO if (!merges_cannot_be_done) != [], I should iterate to get up-to-date advice *)
	Settings.merge_arrays := old_merge_arrays;
	merges_to_do := [];
	merges_cannot_be_done := [];
	let proba = Simplify1.final_add_proba () in
	Simplify1.term_collisions := [];
	({ proc = p'; game_number = -1 }, proba, Proba.final_internal_info(), None)
      else
	begin
	  (* No change, but may advise MergeArrays *)
	  List.iter add_advice (!merges_cannot_be_done);
	  Settings.merge_arrays := old_merge_arrays;
	  merges_to_do := [];
	  merges_cannot_be_done := [];
	  (g, [], simplify_internal_info, None)
	end
    end
