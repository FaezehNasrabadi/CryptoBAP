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

(* Create fresh replication indices *)

let repl_index_counter = ref 0
(* mapping from terms to fresh repl indexes *)
let repl_index_list = ref []

let new_repl_index_term t =
  let rec find_repl_index = function
      [] ->
	incr repl_index_counter;
	let b' = Terms.create_binder "!2" (!repl_index_counter) t.t_type [] in
	let rec node = { above_node = node;
			 binders = [b'];
			 true_facts_at_def = [];
			 def_vars_at_def = [];
			 elsefind_facts_at_def = [];
			 future_binders = []; future_true_facts = [];
			 future_def_vars = [];
			 definition = DFunRepl }
	in
	b'.def <- [node];
	repl_index_list := (t,b') :: (!repl_index_list);
	b'
    | ((a,b')::l) ->
	if Terms.equal_terms a t then b' else
	find_repl_index l
  in
  find_repl_index (!repl_index_list)

let new_repl_index b = new_repl_index_term (Terms.term_from_binder b)

let rec map_find_indices = function
    [] -> []
  | (b::l) ->
      let l' = map_find_indices l in
      if Terms.is_repl b then 
	l' 
      else
	(b, Terms.term_from_binder (new_repl_index b)) :: l'

let get_binder t =
  match t.t_desc with
    Var(b,_) -> b
  | _ -> Parsing_helper.internal_error "Unexpected repl index in get_binder"

let true_facts_from_simp_facts (facts, subst, else_find) =
  subst @ facts

(* An element (t1, t2, b, lopt, T) in term_collisions means that
the equality t1 = t2 was considered impossible; it has
negligible probability because t1 depends on b[lopt] by decompos followed
by compos functions, the types T are the types obtained after applying
the decompos functions (they are large types), and t2 does not depend 
on b *)

let term_collisions = ref []

let any_term_name = "?"
let any_term_binder t = 
  let b' = Terms.create_binder any_term_name 0 t [] in
  let rec node = { above_node = node;
		   binders = [b'];
		   true_facts_at_def = [];
		   def_vars_at_def = [];
		   elsefind_facts_at_def = [];
		   future_binders = []; future_true_facts = [];
		   future_def_vars = [];
		   definition = DNone }
  in
  b'.def <- [node];
  b'

let any_term t = Terms.term_from_binder (any_term_binder t.t_type)

let any_term_pat pat = 
  Terms.term_from_binder (any_term_binder (Terms.get_type_for_pattern pat))

let rec match_term3 next_f t t' = 
  match t.t_desc, t'.t_desc with
    Var (v,[]), _ when v.sname==any_term_name -> next_f()
  | Var (v,[]), _ when Terms.is_repl v -> 
    (* Check that types match *)
      if t'.t_type != v.btype then
	raise NoMatch;
      begin
	match v.link with
	  NoLink -> Terms.link v (TLink t')
	| TLink t -> if not (Terms.equal_terms t t') then raise NoMatch;
      end;
      next_f()
  | Var(b,l), Var(b',l') when b == b' -> 
      match_term_list3 next_f l l'
  | FunApp(f,[t1;t2]), FunApp(f',[t1';t2']) when f.f_options land Settings.fopt_COMMUT != 0 && f == f' ->
      (* Commutative function symbols *)
      begin
        try
          Terms.auto_cleanup (fun () ->
	    match_term3 (fun () -> match_term3 next_f t2 t2') t1 t1')
        with NoMatch ->
          match_term3 (fun () -> match_term3 next_f t2 t1') t1 t2'
      end
  | FunApp(f,l), FunApp(f',l') when f == f' ->
      match_term_list3 next_f l l'
  | _ -> raise NoMatch

and match_term_list3 next_f l l' = 
  match l,l' with
    [],[] -> next_f()
  | a::l,a'::l' ->
      match_term3 (fun () -> match_term_list3 next_f l l') a a'
  | _ -> Parsing_helper.internal_error "Different lengths in match_term_list"

let matches_pair t1 t2 t1' t2' =
  try
    Terms.auto_cleanup (fun () ->
      match_term3 (fun () -> match_term3 (fun () -> ()) t2 t2') t1 t1');
    true
  with NoMatch -> false

let rec cleanup_until l l' = 
  if l' == l then () else
  match l' with
    [] -> Parsing_helper.internal_error "cleanup_until"
  | (v::r) -> 
      v.link <- NoLink;
      cleanup_until l r

let eq_terms3 t1 t2 =
  let cur_bound_vars = !Terms.current_bound_vars in
  try
    match_term3 (fun () -> ()) t1 t2;
    true
  with NoMatch ->
    cleanup_until cur_bound_vars (!Terms.current_bound_vars);
    Terms.current_bound_vars := cur_bound_vars;
    false

let get_index_size b =
  match b.btype.tcat with
    Interv p -> p.psize
  | BitString -> Parsing_helper.internal_error "I would expect indices to have interval type in get_index_size"

(* Filter out the indices that are unique knowing other indices 
   (useful for reducing the probabilities of collision) 

   true_facts must not contain if/let/find/new. 
   if the initial indices contain "noninteractive" indices, we try
   to eliminate them, even by adding "interactive" indices, as follows: 
   we start from a list (initial_indices) of indices that consists of
   (1) the "noninteractive" indices in the initial useful indices
   (2) the "interactive" indices that occur in all_indices but not in the 
      initial useful indices
   (3) the "interactive" indices that occur in the initial indices
   and try to eliminate the indices in order. At each step, we check that all
   indices in the initial useful indices (used_indices) are uniquely 
   determined. 
   *)


let filter_indices_coll true_facts used_indices initial_indices =
  (* Filter the indices *)
  let useful_indices = ref [] in
  let useless_indices = ref [] in
  let used_indices_term = List.map Terms.term_from_binder used_indices in
  let rec filter_indices_rec = function
      [] -> ()
    | first_index::rest_indices ->
	List.iter (fun b -> 
	  let b' = new_repl_index b in
	  Terms.link b (TLink (Terms.term_from_binder b')))
	  (first_index::(!useless_indices));
	let true_facts' = List.map Terms.copy_term3 true_facts in
	let used_indices_term' = List.map Terms.copy_term3 used_indices_term in 
	Terms.cleanup();
	let diff_fact = Terms.make_or_list (List.map2 Terms.make_diff used_indices_term used_indices_term') in
	let facts = diff_fact :: (true_facts' @ true_facts) in
	try
	  ignore (Terms.auto_cleanup (fun () -> Facts.simplif_add_list Facts.no_dependency_anal ([],[],[]) facts));
	  (* The index cannot be removed *)
	  useful_indices := (!useful_indices) @ [first_index];
	  filter_indices_rec rest_indices
	with Contradiction ->
	  (* The index can be removed *)
	  useless_indices := first_index :: (!useless_indices);
	  filter_indices_rec rest_indices
  in
  filter_indices_rec initial_indices;
  if (!useless_indices) == [] then
    (* Removed no index, return the initial list physically, to facilitate
       testing that the list of index was unchanged *)
    initial_indices
  else    
    (!useful_indices)

(* Collision t1 = t2 means: for all indices in t1, t2 such that true_facts holds, eliminate collision t1 = t2.
   Collision t1' = t2' means: for all indices in t1', t2' such that true_facts' holds, eliminate collision t1' = t2'.
There is a substitution sigma such that
 * t1' = sigma t1', t2' = sigma t2
 * There is a subset common_facts of true_facts suchthat
   true_facts' contains at least sigma common_facts 
 * The same indices can be removed using common_facts as
   using true_facts, so that the used indices at t1 = t2 with common_facts
   are still really_used_indices.
Then we replace both calls with
  for all indices in t1, t2 and common_facts such that common_facts holds, 
  eliminate collision t1 = t2
This is more general than the two collisions and yields the same cardinal 
as t1 = t2. *)

let matches 
    (true_facts, used_indices, initial_indices, really_used_indices, t1, t2, b, lopt, tl)
    (true_facts', used_indices', initial_indices', really_used_indices', t1', t2', b', lopt', tl') =
  Terms.auto_cleanup(fun () ->
    if matches_pair t1 t2 t1' t2' then
      let common_facts = List.filter (fun f -> List.exists (fun f' -> eq_terms3 f f') true_facts') true_facts in
      Terms.cleanup();
      (* Check that we can remove the same indices using common_facts as with all facts *)
      if initial_indices == really_used_indices then
	(* If we removed no index, this is certainly true *)
	Some(common_facts, used_indices, initial_indices, really_used_indices, t1, t2, b, lopt, tl)
      else
      let really_used_indices'' = filter_indices_coll common_facts used_indices initial_indices in
      if Terms.equal_lists (==) really_used_indices really_used_indices'' then
	begin
	  (*
	  print_string "Simplify.matches ";
	  Display.display_term [] t1;
	  print_string " with ";
	  Display.display_term [] t2;
	  print_string " succeeds\n";
	  print_string "Common facts:\n";
	  List.iter (fun t ->
	    Display.display_term [] t; print_newline()) common_facts; *)
	  Some(common_facts,  used_indices, initial_indices, really_used_indices, t1, t2, b, lopt, tl)
	end
      else
	begin
	  (*
	  print_string "Simplify.matches ";
	  Display.display_term [] t1;
	  print_string " with ";
	  Display.display_term [] t2;
	  print_string " fails\n";
	  print_string "True facts:\n";
	  List.iter (fun t ->
	    Display.display_term [] t; print_newline()) true_facts;
	  print_string "True facts':\n";
	  List.iter (fun t ->
	    Display.display_term [] t; print_newline()) true_facts';
	  print_string "Common facts:\n";
	  List.iter (fun t ->
	    Display.display_term [] t; print_newline()) common_facts;
	  print_string "used_indices\n";
	  Display.display_list Display.display_binder used_indices;
	  print_newline();
	  print_string "initial_indices\n";
	  Display.display_list Display.display_binder initial_indices;
	  print_newline();
	  print_string "really_used_indices\n";
	  Display.display_list Display.display_binder really_used_indices;
	  print_newline();
	  print_string "really_used_indices''\n";
	  Display.display_list Display.display_binder really_used_indices'';
	  print_newline();*)
	  None
	end
    else
      None)

let add_term_collisions (all_indices, map_find_indices, true_facts) t1 t2 b lopt tl =
  (* Map everything with map_find_indices, to replace indices of find with fresh
     replication indices.
     For some calls, some parts have already been mapped by map_find_indices,
     but not all (in particular the true_facts) *)
  let t1 = Terms.subst3 map_find_indices t1 in
  let t2 = Terms.subst3 map_find_indices t2 in
  let lopt = match lopt with
    None -> None
  | Some l -> Some (List.map (Terms.subst3 map_find_indices) l) 
  in
  let all_indices_ref = ref (List.map (fun b ->
    try
      get_binder (List.assq b map_find_indices)
    with Not_found ->
      b) all_indices)
  in
  (* Add the indices of t1,t2 to all_indices; some of them may be missing
     initially because array indices in t1,t2 that depend on "bad" variables
     are replaced with fresh indices, and these indices are not included in
     all_indices initially (all_indices contains the replication and find
     indices above the considered terms) *)
  Proba.collect_array_indexes all_indices_ref t1;
  Proba.collect_array_indexes all_indices_ref t2;
  let all_indices = !all_indices_ref in
  (* Compute the used indices *)
  let used_indices_ref = ref [] in
  Proba.collect_array_indexes used_indices_ref t1;
  Proba.collect_array_indexes used_indices_ref t2;
  let used_indices = !used_indices_ref in
  try
  let collision_info = 
    (* If the probability used_indices/t for t in tl is small enough to eliminate collisions, return that probability.
       Otherwise, try to optimize to reduce the factor used_indices *)
    if List.for_all (fun t -> 
      Proba.is_small_enough_coll_elim (List.map (fun array_idx -> Proba.card array_idx.btype) used_indices, Proba.card t)
	) tl then 
      ([], used_indices, used_indices, used_indices, t1, t2, b, lopt, tl)
    else
      let true_facts = List.map (Terms.subst3 map_find_indices) true_facts in
      (* Try to reduce the list of used indices. 
	 Compute the initial list of indices to start with.
	 - if all indices in used_indices_ref are not greater 
	   than the default size, then we start from used_indices_ref
         - otherwise, we add some indices from all_indices;
	   the goal is to try to remove large indices
	   of used_indices_ref, perhaps at the cost of adding more
           smaller indices of all_indices *)
      let initial_indices =
	if not (List.exists (fun b -> get_index_size b > Settings.psize_DEFAULT) used_indices) then
	  used_indices
	else
	  (* Sort used_indices and all_indices in decreasing size *)
	  let greater_size b1 b2 = compare (get_index_size b2) (get_index_size b1) in
	  let used_indices_sort = List.sort greater_size used_indices in
	  let all_indices_sort = List.sort greater_size all_indices in
	  (* Remove elements of all_indices that are >= the maximum of used_indices *)
	  let used_indices_maxsize = get_index_size (List.hd used_indices_sort) in
	  let all_indices_sort' = List.filter (fun b -> get_index_size b < used_indices_maxsize) all_indices_sort in
	  (* Build a list by merging indices from all_indices and used_indices.
	     When indices are of the same size, we put elements of all_indices first,
	     so that they will be eliminated, except if they are now necessary
	     because they replace some larger index eliminated before. *)
	  List.merge greater_size all_indices_sort' used_indices_sort 
      in
      let really_used_indices = filter_indices_coll true_facts used_indices initial_indices in
      (* OLD: I can forget the facts without losing precision when I removed no index
	 (initial_indices == really_used_indices);
	 Now, if I removed no index, the probability will be too large to eliminate collisions. *)
      if List.for_all (fun t -> 
	Proba.is_small_enough_coll_elim (List.map (fun array_idx -> Proba.card array_idx.btype) really_used_indices, Proba.card t)
	  ) tl then 
	(true_facts, used_indices, initial_indices, really_used_indices, t1, t2, b, lopt, tl) 
      else
	(* Raises NoMatch when the probability is too large to be accepted *)
	raise NoMatch
  in
    (* I remove an entry when another entry is an instance of it,
       obtained by substituting terms for replication indexes *)
  let rec find_more_general_coll = function
      [] -> raise Not_found
    | (collision_info' :: rest) ->
	match matches collision_info' collision_info with
	  Some collision_info'' -> collision_info'' :: rest
	| None -> collision_info' :: (find_more_general_coll rest)
  in
  begin
    try
      term_collisions := find_more_general_coll (!term_collisions)
    with Not_found ->
      let new_coll = ref collision_info in
      let term_collisions' = List.filter (fun collision_info' -> 
	match matches (!new_coll) collision_info' with
	  None -> true
	| Some collision_info'' -> new_coll := collision_info''; false) (!term_collisions)
      in
      term_collisions := (!new_coll) :: term_collisions'
  end;
  true
  with NoMatch -> 
    false

let proba_for_term_collision (_, _, _, really_used_indices, t1, t2, b, lopt, tl) =
  print_string "Eliminated collisions between ";
  Display.display_term [] t1;
  print_string " and ";
  Display.display_term [] t2;
  print_string " Probability: ";  
  let nindex = Polynom.p_prod (List.map (fun array_idx -> Proba.card array_idx.btype) really_used_indices) in
  let p = 
    match tl with
      [t] -> Div(nindex, Proba.card t)
    | _ -> Polynom.p_sum (List.map (fun t -> Div(nindex, Proba.card t)) tl)
  in
  Display.display_proba 0 p;
  print_newline();
  print_string "(";
  Display.display_term [] t1;
  print_string " characterizes a part of ";
  begin
  match lopt with
    None ->   Display.display_binder b; print_string "[...]"
  | Some l -> Display.display_var [] b l 
  end;
  print_string " of type(s) ";
  Display.display_list (fun t -> print_string t.tname) tl;
  print_string ";\n ";
  Display.display_term [] t2;
  print_string " does not depend on ";
  begin
  match lopt with
    None ->   Display.display_binder b; print_string "[...]"
  | Some l -> Display.display_var [] b l 
  end;
  print_string ")\n";
  p
  

(* Final addition of probabilities *)

let final_add_proba() =
  Proba.final_add_proba (List.map proba_for_term_collision (!term_collisions))

(* Dependency analysis
   When M1 characterizes a part of x of a large type T
   and M2 does not depend on x, then M1 = M2 fails up to
   negligible probability.
   The module FindCompos defines "characterize"
   The modules DepAnal1 and DepAnal2 perform dependency analyses
   Function dependency_collision concludes *)

module FindCompos : sig

type status = Compos | Decompos | Any

type charac_type =
    CharacType of typet
  | CharacTypeOfVar of binder

type 'a depinfo =
   (binder * (status * 'a)) list option * term list
      (* The dependency information has two components (dep, nodep):
	 If dep = Some l where l is a list of (variable, ...), such that it 
	 is guaranteed only variables in this list depend on the considered 
	 variable x[l].
	 If dep = None, we have no information of this kind; any variable 
	 may depend on x.
	 nodep is a list of terms that are guaranteed not to depend on x[l].
	 *)

val init_elem : 'a depinfo

val depends : (binder * 'a depinfo) -> term -> bool

  (* is_indep (b, depinfo) t returns a term independent of b
     in which some array indexes in t may have been replaced with
     fresh replication indexes. When t depends on b by variables
     that are not array indexes, raise Not_found *)
val is_indep : (binder * 'a depinfo) -> term -> term

val remove_dep_array_index : (binder * 'a depinfo) -> term -> term
val remove_array_index : term -> term

val find_compos : ((binder * (status * 'a)) -> term list -> (status * charac_type) option) -> 'a depinfo -> (binder * (status * 'a)) -> term -> (status * charac_type * term) option

val find_compos_list : ((binder * (status * 'a)) -> term list -> (status * charac_type) option) -> 'a depinfo -> (binder * (status * 'a)) list -> term -> (status * charac_type * term * binder * 'a) option

end
=
struct

let init_elem = (None, [])

let rec depends ((b, (dep,nodep)) as bdepinfo) t = 
  match t.t_desc with
    FunApp(f,l) -> List.exists (depends bdepinfo) l
  | Var(b',[]) when Terms.is_repl b' -> false
  | Var(b',l) ->
      (not (List.exists (Terms.equal_terms t) nodep)) && 
      ((
       ((b == b') || (not (Terms.is_restr b'))) &&
       (match dep with
	 None -> true
       | Some dl -> List.exists (fun (b'',_) -> b'' == b') dl
	  )) || (List.exists (depends bdepinfo) l))
  | _ -> true (*Rough overapproximation of the dependency analysis when
       if/let/find/new occur.
       Parsing_helper.internal_error "If/let/find/new unexpected in DepAnal1.depends"*)

let rec is_indep ((b0, (dep,nodep)) as bdepinfo) t =
  Terms.build_term2 t
     (match t.t_desc with
	FunApp(f,l) -> FunApp(f, List.map (is_indep bdepinfo) l)
      | Var(b,[]) when Terms.is_repl b -> t.t_desc
      |	Var(b,l) ->
	  if (List.exists (Terms.equal_terms t) nodep) then
	    t.t_desc 
	  else if (b != b0 && Terms.is_restr b) || (match dep with
	      None -> false
	    | Some dl -> not (List.exists (fun (b',_) -> b' == b) dl))
	  then
	    Var(b, List.map (fun t' ->
	      try
		is_indep bdepinfo t'
	      with Not_found ->
		Terms.term_from_binder (new_repl_index_term t')) l)
	  else
	    raise Not_found
      | _ -> Parsing_helper.internal_error "If/let/find/new unexpected in is_indep")

let rec remove_dep_array_index ((b0, (dep,nodep)) as bdepinfo) t =
  Terms.build_term2 t 
     (match t.t_desc with
	FunApp(f,l) -> FunApp(f, List.map (remove_dep_array_index bdepinfo) l)
      | Var(b,[]) when Terms.is_repl b -> t.t_desc
      |	Var(b,l) ->
	  if (List.exists (Terms.equal_terms t) nodep) then
	    t.t_desc 
	  else 
	    Var(b, List.map (fun t' -> 
	      if depends bdepinfo t' then
		Terms.term_from_binder (new_repl_index_term t')
	      else
		t') l)
      | _ -> Parsing_helper.internal_error "If/let/find/new unexpected in remove_dep_array_index")

let rec remove_array_index t =
  Terms.build_term2 t 
     (match t.t_desc with
	FunApp(f,l) -> FunApp(f, List.map remove_array_index l)
      | Var(b,[]) when Terms.is_repl b -> t.t_desc
      |	Var(b,l) ->
	  Var(b, List.map (fun t' ->
	    match t'.t_desc with
	      Var(b',[]) when Terms.is_repl b' -> t'
	    | _ -> Terms.term_from_binder (new_repl_index_term t')
		  ) l)
      | _ -> Parsing_helper.internal_error "If/let/find/new unexpected in remove_dep_array_index")

let reduced = ref false

(* Same as apply_reds but do not apply collisions, and apply statements
   only at the root of the term *)
let apply_statement2 t t_state =
  match t_state.t_desc, t.t_desc with
    FunApp(f1, [redl;redr]), FunApp(f,l) when f1.f_cat == Equal ->
      begin
	try
	  Facts.match_term (fun () -> 
	    let t' = Terms.copy_term redr in
	    Terms.cleanup();
	    reduced := true;
	    t'
	      ) ([],[],[]) [] redl t
	with NoMatch ->
	  Terms.cleanup();
	  t
      end
  | _ -> t

let rec apply_all_red2 t = function
    [] -> t
  | ((_,t_state)::l) ->
      let t' = apply_statement2 t t_state in
      if !reduced then t' else apply_all_red2 t l

let rec apply_statements t =
  reduced := false;
  let t' = apply_all_red2 t (!Transform.statements) in
  if !reduced then 
    apply_statements t' 
  else
    t


(* find_compos b t returns true when t characterizes b: only one
value of b can yield a certain value of t *)

type status = Compos | Decompos | Any

type charac_type =
    CharacType of typet
  | CharacTypeOfVar of binder

type 'a depinfo =
  (binder * (status * 'a)) list option * term list

let rec find_decompos_bin check ((b,_) as b_st) b' t t' =
  (Proba.is_large_term t || Proba.is_large_term t') && (t'.t_type == t.t_type) &&
  (match t.t_desc, t'.t_desc with
    Var(b1,l), Var(b1',l') when 
    (b == b1 && b' == b1') || (b == b1' && b' == b1) -> 
      (check b_st l != None) && (check b_st l' != None)
  | FunApp(f,l), FunApp(f',l') when 
      (f.f_options land Settings.fopt_UNIFORM) != 0  && (f == f') ->
      List.exists2 (find_decompos_bin check b_st b') l l'
  | _ -> false)
  
let rec find_compos_bin check ((b,(st,_)) as b_st) b' fact =
  match fact.t_desc with
   FunApp(f,[t1;t2]) when f.f_cat == Equal ->
      begin
      match (t1.t_desc, t2.t_desc) with
      	Var(b1,l1), Var(b2,l2) when (b1 == b && b2 == b') ->
	  if check b_st l2 != None then check b_st l1 else None
      |	Var(b1,l1), Var(b2,l2) when (b1 == b' && b2 == b) -> 
	  if check b_st l1 != None then check b_st l2 else None
      |	(FunApp(f1,l1), FunApp(f2,l2)) when
	(f1.f_options land Settings.fopt_COMPOS) != 0 && f1 == f2 -> 
	  find_compos_bin_l check b_st b' l1 l2
      |	(FunApp(f1,l1), FunApp(f2,l2)) when
	(f1.f_options land Settings.fopt_UNIFORM) != 0  && f1 == f2 ->
	  if (Proba.is_large_term t1 || Proba.is_large_term t2) && (st = Decompos) && 
	    (List.exists2 (find_decompos_bin check b_st b') l1 l2)
	  then Some (Decompos, CharacType t1.t_type)  else None
      |	_ -> None
      end
  | FunApp(f,[t1;t2]) when f == Settings.f_and ->
      begin
	match find_compos_bin check b_st b' t1 with
	  None -> find_compos_bin check b_st b' t2
	| x -> x
      end
  | _ -> None
    
and find_compos_bin_l check b_st b' l1 l2 =
  match (l1,l2) with
    [],[] -> None
  | (a1::l1,a2::l2) ->
      begin
      match find_compos_bin check b_st b' (apply_statements (Terms.make_equal a1 a2)) with
	None -> find_compos_bin_l check b_st b' l1 l2
      |	Some(_, charac_type) -> Some(Compos,charac_type)
      end
  | _ -> Parsing_helper.internal_error "Lists of different lengths in find_compos_bin_l"
      
let rec subst depinfo assql t =
  Terms.build_term2 t 
     (match t.t_desc with
	Var(b,l) -> Var(
	  (try List.assq b (!assql) with Not_found ->
            (* Do not rename variables that do not depend on the
	       variable argument of find_compos *)
	    if (Terms.is_restr b) || (Terms.is_repl b) ||
	       (match depinfo with
	         (Some dl,tl) ->
		   (not (List.exists (fun (b',_) -> b' == b) dl)) ||
		   (List.exists (Terms.equal_terms t) tl)
	       | (None, tl) -> List.exists (Terms.equal_terms t) tl)
	    then b else 
	    let r = Terms.new_binder b in
	    assql := (b,r)::(!assql);
	    r), List.map (subst depinfo assql) l)
      | FunApp(f,l) -> FunApp(f, List.map (subst depinfo assql) l)
      |	_ -> Parsing_helper.internal_error "If, find, let, and new should not occur in subst")

let rec find_decompos check ((b, _) as b_st) t =
  (Proba.is_large_term t) && 
  (match t.t_desc with
    Var(b',l) when b == b' -> 
      check b_st l != None
  | FunApp(f,l) when (f.f_options land Settings.fopt_UNIFORM) != 0 ->
      List.exists (find_decompos check b_st) l
  | _ -> false)

let rec find_compos check depinfo ((b,(st,_)) as b_st) t =
  if st = Any then None else
  match t.t_desc with
    Var(b',l) when b == b' -> 
      begin
	match check b_st l with
	  None -> None
	| Some(st, ch_ty) -> Some(st, ch_ty, t)
      end
  | FunApp(f,l) when (f.f_options land Settings.fopt_COMPOS) != 0 ->
      begin
	match find_compos_l check depinfo b_st l with
	  None -> None
	| Some(st, ch_ty, l') -> 
	    Some(st, ch_ty, Terms.build_term2 t (FunApp(f,l')))
      end
  | FunApp(f,l) when (f.f_options land Settings.fopt_UNIFORM) != 0 ->
      if (Proba.is_large_term t) && (st = Decompos) && 
	(List.exists (find_decompos check b_st) l)
      then Some (Decompos, CharacType t.t_type, t)  else None
  | Var _ -> None
  | _ -> 
      (* In a simpler version, we would remove 
	 find_compos_bin, find_compos_bin_l, find_decompos_bin, subst,
	 apply_statement2, apply_all_red2, apply_statements
	 and replace this case with None
	 *)
      let vcounter = !Terms.vcounter in
      let b' = Terms.new_binder b in
      let t' = subst depinfo (ref [(b, b')]) t in
      let f1 = apply_statements (Terms.make_equal t t') in
      let r = 
	match find_compos_bin check b_st b' f1 with
	  None -> None
	| Some(st,ch_ty) -> Some(st, ch_ty, t)
      in
      Terms.vcounter := vcounter; (* Forget created variables *)
      r

and find_compos_l check depinfo b_st = function
    [] -> None
  | (a::l) ->
      match find_compos check depinfo b_st a with
	None -> 
	  begin
	    match find_compos_l check depinfo b_st l with
	      None -> None
	    | Some(st, charac_type, l') -> Some(st, charac_type, (any_term a)::l')
	  end
      |	Some(_, charac_type, a') -> Some(Compos,charac_type, a'::List.map any_term l)

let find_compos_list check depinfo seen_list t =
  let rec test_l = function
    [] -> None
  | (((b, (st, x)) as b_st)::l) -> 
      match find_compos check depinfo b_st t with
	None -> test_l l
      |	Some(st,charac_type,t') -> Some(st,charac_type,t',b,x)
  in
  test_l seen_list

end


(* Facts.facts_from_defined def_list: 
       for each (b,l) in def_list,
       look for definitions n of binders b,
       substitute l for b.args_at_creation in n.true_facts_at_def and
       add these facts to the returned list 
       substitute l for b.args_at_creation in n.def_vars_at_def and
       continue recursively with these definitions 
       If there are several definitions of b, take the intersection
       of lists of facts/defined vars. ("or" would be more precise
       but difficult to implement) 
       Do not reconsider an already seen pair (b,l), to avoid loops.*)


let rec filter_def_list bl accu = function
    [] -> accu
  | (br::l) ->
      let implied_br = Facts.def_vars_from_defined None bl [br] in
      let accu' = Terms.setminus_binderref accu implied_br in
      let l' = Terms.setminus_binderref l implied_br in
      filter_def_list bl (br::accu') l'

let rec remove_subterms accu = function
    [] -> accu
  | (br::l) ->
      let subterms = ref [] in
      Terms.close_def_subterm subterms br;
      let accu' = Terms.setminus_binderref accu (!subterms) in
      let l' = Terms.setminus_binderref l (!subterms) in
      remove_subterms (br::accu') l' 


let rec match_term2 next_f simp_facts bl t t' =
  match t.t_desc with
    Var(v,l) when (List.memq v bl) && (List.for_all2 Terms.equal_terms l v.args_at_creation) ->
      begin
	if t'.t_type != v.btype then
	  raise NoMatch;
	match v.link with
	  NoLink -> Terms.link v (TLink t')
	| TLink t -> ignore (Facts.unify_terms simp_facts t t')
      end;
      next_f ()
  | Var(v,l) ->
      begin
	match t'.t_desc with
	  Var(v',l') when v == v' ->
	    match_term_list2 next_f simp_facts bl l l'
	| _ -> raise NoMatch
      end
  | FunApp(f,[t1;t2]) when f.f_options land Settings.fopt_COMMUT != 0 ->
      (* Commutative function symbols *)
      begin
	match t'.t_desc with
	  FunApp(f',[t1';t2']) when f == f' ->
	    begin
	      try
		Terms.auto_cleanup (fun () ->
		  match_term2 (fun () -> match_term2 next_f simp_facts bl t2 t2') simp_facts bl t1 t1')
	      with NoMatch ->
		match_term2 (fun () -> match_term2 next_f simp_facts bl t2 t1') simp_facts bl t1 t2'
	    end
	| _ -> raise NoMatch
      end
  | FunApp(f,l) ->
      begin
	match t'.t_desc with
	  FunApp(f',l') when f == f' ->
	    match_term_list2 next_f simp_facts bl l l'
	| _ -> raise NoMatch
      end
  | _ -> Parsing_helper.internal_error "If, find, let, and new should not occur in match_term2"

and match_term_list2 next_f simp_facts bl l l' = 
  match l,l' with
    [],[] -> next_f()
  | a::l,a'::l' ->
      match_term2 (fun () -> match_term_list2 next_f simp_facts bl l l') 
	simp_facts bl a a'
  | _ -> Parsing_helper.internal_error "Different lengths in match_term_list2"


let match_binderref2 next_f simp_facts bl (b,l) (b',l') =
  if b != b' then raise NoMatch;
  match_term_list2 next_f simp_facts bl l l'

let rec match_among next_match simp_facts bl br = function
    [] -> raise NoMatch
  | (br1::brl) ->
      try 
	Terms.auto_cleanup (fun () ->
	  match_binderref2 next_match simp_facts bl br br1)
      with NoMatch ->
	match_among next_match simp_facts bl br brl

let rec match_among_list next_match simp_facts bl def_vars = function
    [] -> next_match()
  | (br1::brl) ->
      match_among (fun () -> 
	match_among_list next_match simp_facts bl def_vars brl) 
	simp_facts bl br1 def_vars
  

let final_next dep_info bl true_facts t () =
  let t' = Terms.copy_term3 t in
  (* Cleanup links, with possibility to restore *)
  let tmp_list = List.map (fun b -> b.link) bl in
  List.iter (fun b -> b.link <- NoLink) bl;
  (* Raise Contradiction when t implied *)
  Terms.auto_cleanup (fun () -> 
    (* TO DO It would be possible to improve this when t' is the conjunction
       of terms in tl:
       replace true_facts := Facts.simplif_add (!true_facts) (Terms.make_not t') with
       if List.for_all (fun t -> 
         try
           ignore(Facts.simplif_add true_facts (Terms.make_not t));
           false
         with Contradiction -> true) tl then raise Contradiction *)
    (* print_string "Adding ";
    Display.display_term [] (Terms.make_not t');
    print_newline();*)
    true_facts := Facts.simplif_add dep_info (!true_facts) (Terms.make_not t'));
  (* Restore links *)
  List.iter2 (fun b l -> b.link <- l) bl tmp_list;
  (* Backtrack *)
  raise NoMatch

let always_true_def_list_t dep_info bl simp_facts t def_vars def_list =
  try
    match_among_list (final_next dep_info bl simp_facts t) (!simp_facts) bl def_vars def_list
  with NoMatch -> ()

(* Test if a branch of find always succeeds *)

exception SuccessBranch of (binder * term) list * binder list

let final_next2 dep_info bl true_facts t1 () =
  let t1' = Terms.copy_term3 t1 in
  (* Cleanup links, with possibility to restore *)
  let tmp_list = List.map (fun b -> b.link) bl in
  List.iter (fun b -> b.link <- NoLink) bl;
  (* Raise Contradiction when t1 implied *)
  begin
    try 
      Terms.auto_cleanup (fun () -> 
	ignore (Facts.simplif_add dep_info true_facts (Terms.make_not t1')))
    with Contradiction ->
      (* For the value of bl computed in the links, t1 is true;
	 furthermore match_among_list has checked that all variables
	 in def_list are defined, so this branch of find succeeds *)
      (* print_string "Proved ";
         Display.display_term [] t1';
         print_newline();*)
      let subst = ref [] in
      let keep_bl = ref [] in
      List.iter2 (fun b l -> 
	match l with
	  TLink b_im -> subst := (b,b_im) :: (!subst)
	| NoLink -> keep_bl := b :: (!keep_bl)) bl tmp_list;
      raise (SuccessBranch(!subst, !keep_bl))
  end;
  (* Restore links *)
  List.iter2 (fun b l -> b.link <- l) bl tmp_list;
  (* Backtrack *)
  raise NoMatch

(* Raises SuccessBranch when the branch is proved to succeed for some
   value of the indices. These values are stored in the argument of SuccessBranch *)

let branch_succeeds (bl, def_list, t1, _) dep_info true_facts def_vars =
  try
    match_among_list (final_next2 dep_info bl true_facts t1) true_facts bl def_vars def_list
  with NoMatch -> ()

(* Treatment of elsefind facts *)

let rec add_elsefind dep_info def_vars ((subst, facts, elsefind) as simp_facts) = function
    [] -> simp_facts
  | ((bl, def_list, t1,_)::l) -> 
      (* When the condition t1 contains if/let/find/new, we simply ignore it when adding elsefind facts. *)
      let simp_facts' = 
	match (bl, def_list, t1.t_desc) with
	  [],[],(Var _ | FunApp _) -> Facts.simplif_add dep_info simp_facts (Terms.make_not t1)
	| _,[],_ -> simp_facts
	| _,_,(Var _ | FunApp _) -> 
	    let simp_facts_ref = ref (subst, facts, (bl, def_list, t1)::elsefind) in
	    always_true_def_list_t dep_info bl simp_facts_ref t1 def_vars def_list;
	    !simp_facts_ref
	| _ -> simp_facts
      in
      add_elsefind dep_info def_vars simp_facts' l

let filter_elsefind f (subst, facts, elsefind) =
  (subst, facts, List.filter f elsefind)

let convert_elsefind dep_info def_vars ((subst, facts, elsefind) as simp_facts) =
  let simp_facts_ref = ref simp_facts in
  List.iter (fun (bl, def_list, t1) ->
    always_true_def_list_t dep_info bl simp_facts_ref t1 def_vars def_list
      ) elsefind;
  !simp_facts_ref

(* Prove unicity of find branches. 
   This code applies both to find and findE because it just deals with 
   the find conditions *)

let debug_find_unique = ref false

(* [is_in_bl bl t] returns true when the term [t] is equal to some
   variable in the list [bl] *)

let is_in_bl bl t =
  match t.t_desc with
    Var(b,l) ->
      (List.memq b bl) && (List.for_all2 Terms.equal_terms b.args_at_creation l)
  | _ -> false

(* Dependency analysis that takes into account assumption on the
   definition order

   dep_info = (array ref defined later; list of array ref defined before)
 *)

let rec remove_dep_array_index all_indices ((b0, (dep,nodep)) as bdepinfo) t =
  Terms.build_term2 t 
     (match t.t_desc with
	FunApp(f,l) -> FunApp(f, List.map (remove_dep_array_index all_indices bdepinfo) l)
      | Var(b,l) ->
	  if (is_in_bl all_indices t) || (List.exists (Terms.equal_terms t) nodep) then
	    t.t_desc 
	  else 
	    Var(b, List.map (fun t' -> 
	      if is_in_bl all_indices t' then
		t'
	      else if FindCompos.depends bdepinfo t' then
		Terms.term_from_binder (new_repl_index_term t')
	      else
		t') l)
      | _ -> Parsing_helper.internal_error "If/let/find/new unexpected in remove_dep_array_index")

let rec dependency_collision_rec2bis all_indices map_find_indices true_facts (((b_after, l_after), defl_before) as dep_info) t1 t2 t =
  match t.t_desc with
    Var(b,l) when (Terms.is_restr b) && (b == b_after) && (List.for_all2 Terms.equal_terms l l_after) && (Proba.is_large_term t) ->
      begin
	let t1' = remove_dep_array_index all_indices (b,(None, defl_before)) t1 in
	let check (b, (st, _)) l =
	  if List.for_all2 Terms.equal_terms l l_after then
	    Some (st, FindCompos.CharacType b.btype)
	  else
	    None
	in
	match FindCompos.find_compos check (None, defl_before) (b,(FindCompos.Decompos, b.btype)) t1' with
	  Some(_, FindCompos.CharacType charac_type, t1'') -> 
	    begin
	    try 
	      let t2' = FindCompos.is_indep (b, (None, defl_before)) t2 in
	      (* add probability, if small enough. returns true if proba small enough, false otherwise *)
	      add_term_collisions (all_indices, map_find_indices, true_facts) t1'' t2' b (Some l_after) [charac_type]
	    with Not_found -> false
	    end
	| Some _ -> Parsing_helper.internal_error "CharacTypeOfVar should not be used in DepAnal2"
	| None -> false
      end 
  | FunApp(f,l) ->
      List.exists (dependency_collision_rec2bis all_indices map_find_indices true_facts dep_info t1 t2) l
  | _ -> false

let rec try_no_var_rec simp_facts t =
  let t' = Facts.try_no_var simp_facts t in(* Risk of non-termination? *)
  match t'.t_desc with
    FunApp(f,l) -> 
      Terms.build_term2 t' (FunApp(f, List.map (try_no_var_rec simp_facts) l))
  | _ -> t'

let dependency_collision_order_hyp all_indices dep_info simp_facts t1 t2 = 
  let t1' = try_no_var_rec simp_facts t1 in
  let t2' = try_no_var_rec simp_facts t2 in
  let map_find_indices = map_find_indices all_indices in
  let true_facts = true_facts_from_simp_facts simp_facts in
  (dependency_collision_rec2bis all_indices map_find_indices true_facts dep_info t1' t2' t1') ||
  (dependency_collision_rec2bis all_indices map_find_indices true_facts dep_info t2' t1' t2')

(* [same_input_node br defl] returns true when [br] is defined in the
same input...output block as variables in [defl]. When [defl] contains
several elements, they are already supposed to be defined in the same
input...output block, so that we need only compare with the
first element of [defl]. *) 

let rec above_input_node n =
  if n.above_node == n then
    Parsing_helper.internal_error "reached beginning of program without seeing an input";
  match n.definition with
    DInputProcess _ -> n
  | _ -> above_input_node n.above_node
    
let same_input_node (b,_) defl =
  let (b',_) = List.hd defl in
  match b.def with
    n::r -> 
      let input_node = above_input_node n in
      (List.for_all (fun n' -> input_node == above_input_node n') r) &&
      (List.for_all (fun n' -> input_node == above_input_node n') b'.def)
  | _ -> false

(* analyzed contains a list of pairs (list of indices used, list of
   variable references in defined condition that use those indices and
   are in the same input...output block).
   This input...output block is chosen to be as late as possible. *)

let rec add_in_analyzed ((b,l) as br) = function
    [] -> [(List.map Terms.binder_from_term l, [br])]
  | (bl, defl)::rest ->
      let l' = List.map Terms.binder_from_term l in
      if List.exists (fun b' -> List.memq b' bl) l' then
	let lenl' = List.length l' in
	let lenbl = List.length bl in
	if lenl' > lenbl then 
	  (l',[br])::rest
	else if lenl' < lenbl then
	  (bl, defl)::rest
	else (* lenl' == lenbl *) 
	  if (List.for_all2 (==) l' bl) && (same_input_node br defl) then
	    (* Most frequent case *)
	    (bl, br::defl)::rest
	  else if List.for_all (fun (b',_) ->
	    List.for_all (fun n -> List.exists (fun n' -> Facts.is_reachable n' n) b'.def) b.def) defl then
	    (* b defined after b', b is better *)
	    (l', [br])::rest
	  else
	    (bl, defl)::rest
      else
	(bl, defl)::(add_in_analyzed br rest)

let rec analyze_def_br analyzed bl ((b,l) as br) =
  if List.for_all (is_in_bl bl) l then
    analyzed := add_in_analyzed br (!analyzed)
  else
    List.iter (analyze_def_term analyzed bl) l

and analyze_def_term analyzed bl t =
  match t.t_desc with
    Var(b,l) -> analyze_def_br analyzed bl (b,l)
  | FunApp(f,l) -> List.iter (analyze_def_term analyzed bl) l
  | _ -> Parsing_helper.internal_error "If/Let/Find/Res/Event not allowed in def list"

(* Rename an elsefind fact according to renaming subst *)

let rec rename_term_except bl subst t =
  match t.t_desc with
    Var(b,l) -> 
      let (b',l') = rename_br_except bl subst (b,l) in
      Terms.build_term2 t (Var(b',l'))
  | FunApp(f,l) ->
       Terms.build_term2 t (FunApp(f, List.map (rename_term_except bl subst) l))
  | _ -> Parsing_helper.internal_error "If/Let/Find/Res/Event not allowed in elsefind facts"

and rename_br_except bl subst (b,l) =
  if List.for_all2 Terms.equal_terms b.args_at_creation l then
    if List.memq b bl  then
      (b,l)
    else
      try
	let b' = Terms.binder_from_term (List.assq b subst) in
	(b', b'.args_at_creation)
      with Not_found ->
	(b, List.map (rename_term_except bl subst) l)
  else
    (b, List.map (rename_term_except bl subst) l)

let rename_elsefind subst (bl, def_list, t) =
  (bl, List.map (rename_br_except bl subst) def_list, 
   rename_term_except bl subst t)


(* branch_unique proves that the given branch can succeed only for one 
   choice of indices in bl 
cur_array = all indices above the current find (replication indices, and 
  find indices if the current find occurs in a find condition)
the_facts = p.p_facts for processes, t.t_facts for terms
true_facts0 = the facts that are true at the find.
*)

let branch_unique cur_array the_facts true_facts0 (bl, def_list, t, _) =
  let bl1 = List.map Terms.new_binder bl in
  let bl2 = List.map Terms.new_binder bl in
  let subst1 = List.map2 (fun b b' -> (b, Terms.term_from_binder b')) bl bl1 in
  let subst2 = List.map2 (fun b b' -> (b, Terms.term_from_binder b')) bl bl2 in
  let def_list1 = Terms.subst_def_list3 subst1 def_list in
  let t1 = Terms.subst3 subst1 t in
  let def_list2 = Terms.subst_def_list3 subst2 def_list in
  let t2 = Terms.subst3 subst2 t in
  try
    let this_branch_node = Facts.get_node_for_find_branch the_facts bl in 
    let facts_def_list1 = Facts.facts_from_defined this_branch_node bl1 def_list1 in
    let true_facts1 = Facts.simplif_add_list Facts.no_dependency_anal true_facts0 facts_def_list1 in
    let true_facts2 = Facts.simplif_add_find_cond Facts.no_dependency_anal true_facts1 t1 in
    let facts_def_list2 = Facts.facts_from_defined this_branch_node bl2 def_list2 in
    let true_facts3 = Facts.simplif_add_list Facts.no_dependency_anal true_facts2 facts_def_list2 in
    let true_facts4 = Facts.simplif_add_find_cond Facts.no_dependency_anal true_facts3 t2 in
    let diff_fact = Terms.make_or_list (List.map2 (fun (_,b1) (_,b2) -> Terms.make_diff b1 b2) subst1 subst2) in
    let true_facts5 = Facts.simplif_add Facts.no_dependency_anal true_facts4 diff_fact in

    let analyzed = ref [] in
    List.iter (analyze_def_br analyzed bl) def_list;
    (* Check that all elements of bl are in some sub-bl list of analyzed.
       Otherwise, we cannot apply the case distinction. *)
    (List.for_all (fun b -> List.exists (fun (sub_bl,_) -> List.memq b sub_bl) (!analyzed)) bl) &&
    ((* Since all elements of bl are in some sub_bl list, and bl1 <> bl2,
	there exists some sub_bl list such that sub_bl1 <> sub_bl2 *)
    List.for_all (fun (sub_bl, defl) ->
      if !debug_find_unique then
	begin
	  print_string "Discriminating variables: "; Display.display_list (fun (bx,_) -> Display.display_binder bx) defl; print_newline()
	end;
      try
	let diff_fact2 = Terms.make_or_list 
	    (List.map (fun b -> Terms.make_diff (List.assq b subst1) (List.assq b subst2)) sub_bl) 
	in
	let true_facts6 = Facts.simplif_add Facts.no_dependency_anal true_facts5 diff_fact2 in
	(* Distinguish cases depending on whether the variable bx has 
	   been defined first with indices sub_bl1 or sub_bl2.
	   Suppose sub_bl1 comes first. (The other case is symmetric.)
	   Then bx[sub_bl2] defined afterwards, and we can exploit some
	   "elsefind" facts at definition of bx[sub_bl2]

	   When bx[sub_bl2] is defined, I know that bx[sub_bl1] is defined.
	   Infer other defined variables by Facts.def_vars_from_defined
	   *)
	let sub_bl1 = List.map (fun b -> List.assq b subst1) sub_bl in
	let def_vars = Facts.def_vars_from_defined None bl (List.map (fun (bx, _) -> (bx, sub_bl1)) defl) in
	let (subst6, facts6, _) = true_facts6 in 
	(* TO DO Would it be better to collect elsefind_facts for each
	   node n, take the intersection, then take the union on all
	   variables bx, and look for a contradiction from the
	   obtained facts? *) 
	List.exists (fun (bx, _) -> List.for_all
	   (fun n -> try
	    (* convert indices of bx to sub_bl2 *)
	      let renaming = List.map2 (fun t b -> (Terms.binder_from_term t, List.assq b subst2)) bx.args_at_creation sub_bl in
	      let elsefind_facts = List.map (rename_elsefind renaming) n.elsefind_facts_at_def in
	      if !debug_find_unique then Facts.display_facts (subst6,facts6, elsefind_facts);
	      let _ = convert_elsefind Facts.no_dependency_anal def_vars (subst6,facts6, elsefind_facts) in
	      if !debug_find_unique then print_string "Could not get a contradiction\n";
	      false
	    with Contradiction ->
	      true) bx.def
	    ) defl
      with Contradiction ->
	true
	  ) (!analyzed)
      )
  with Contradiction -> 
    true

(* incompatible branches proves that the two branches cannot 
   simultaneously succeed *)

let incompatible_branches cur_array the_facts true_facts0 (bl1, def_list1, t1, _) (bl2, def_list2, t2, _) =
  let bl1' = List.map Terms.new_binder bl1 in
  let bl2' = List.map Terms.new_binder bl2 in
  let all_indices = bl1' @ bl2' @ cur_array in
  let subst1 = List.map2 (fun b b' -> (b, Terms.term_from_binder b')) bl1 bl1' in
  let subst2 = List.map2 (fun b b' -> (b, Terms.term_from_binder b')) bl2 bl2' in
  let def_list1' = Terms.subst_def_list3 subst1 def_list1 in
  let t1' = Terms.subst3 subst1 t1 in
  let def_list2' = Terms.subst_def_list3 subst2 def_list2 in
  let t2' = Terms.subst3 subst2 t2 in
  try
    let this_branch_node1 = Facts.get_node_for_find_branch the_facts bl1 in 
    let facts_def_list1 = Facts.facts_from_defined this_branch_node1 bl1' def_list1' in
    let true_facts1 = Facts.simplif_add_list Facts.no_dependency_anal true_facts0 facts_def_list1 in
    let true_facts2 = Facts.simplif_add_find_cond Facts.no_dependency_anal true_facts1 t1' in
    let this_branch_node2 = Facts.get_node_for_find_branch the_facts bl2 in 
    let facts_def_list2 = Facts.facts_from_defined this_branch_node2 bl2' def_list2' in
    let true_facts3 = Facts.simplif_add_list Facts.no_dependency_anal true_facts2 facts_def_list2 in
    let true_facts4 = Facts.simplif_add_find_cond Facts.no_dependency_anal true_facts3 t2' in
    let (subst4, facts4, _) = true_facts4 in 

    let analyzed1 = ref [] in
    List.iter (analyze_def_br analyzed1 bl1) def_list1;
    let analyzed2 = ref [] in
    List.iter (analyze_def_br analyzed2 bl2) def_list2;

    (* TO DO When the variables in defl1 are defined in a different
       input...output block than the variables of defl2, I could make the
       stronger assumption that either all variables of defl1 are defined
       before all variables of defl2, or all variables of defl2 are
       defined before all variables of defl1 *)

    List.exists (fun (sub_bl1, defl1) ->
      List.exists (fun (bx1, _) ->
	List.exists (fun (sub_bl2, defl2) ->
	  List.exists (fun (bx2, _) ->
	(List.for_all (fun n -> not (List.memq n bx2.def)) bx1.def) &&
	(* bx1 and bx2 are defined in different nodes (checked on the above line), so 
	   bx1[sub_bl1'] and bx2[sub_bl2'] are not defined simultaneously, 
	   one is defined before the other.
	   First case: bx1[sub_bl1'] is defined before bx2[sub_bl2']  *)
	(
	if !debug_find_unique then 
	  begin
	    print_string "Discriminating variables: "; Display.display_binder bx1; print_string " before "; Display.display_binder bx2; print_newline()
	  end;
	try
	  let def_vars = Facts.def_vars_from_defined None bl1 [(bx1, List.map (fun b -> List.assq b subst1) sub_bl1)] in
	  if !debug_find_unique then
	    begin
	      print_string "Def vars = "; Display.display_list (fun (b,l) -> Display.display_var [] b l) def_vars; print_newline()
	    end;
	  let dep_info =
	    ((bx2, List.map (fun b -> List.assq b subst2) sub_bl2),
	     List.map Terms.term_from_binderref def_vars)
	  in
	  List.for_all (fun n ->   
	    try
	    (* convert indices of bx2 to sub_bl2' *)
	      let renaming = List.map2 (fun t b -> (Terms.binder_from_term t, List.assq b subst2)) bx2.args_at_creation sub_bl2 in
	      let elsefind_facts = List.map (rename_elsefind renaming) n.elsefind_facts_at_def in
	      if !debug_find_unique then Facts.display_facts (subst4,facts4, elsefind_facts);
	      let (subst4, facts4, _) = Facts.simplif_add_list (dependency_collision_order_hyp all_indices dep_info) ([],[],[]) (subst4 @ facts4) in
	      let _ = convert_elsefind (dependency_collision_order_hyp all_indices dep_info) def_vars (subst4,facts4, elsefind_facts) in
	      if !debug_find_unique then print_string "Could not get a contradiction\n";
	      false
	    with Contradiction ->
	      true) bx2.def
	with Contradiction ->
	  true
	) && 
	(* Second case:  bx2[sub_bl2'] is defined before bx1[sub_bl1'] *)
	(
	if !debug_find_unique then
	  begin
	    print_string "Discriminating variables: "; Display.display_binder bx1; print_string " after "; Display.display_binder bx2; print_newline()
	  end;
	try
	  let def_vars = Facts.def_vars_from_defined None bl2 [(bx2, List.map (fun b -> List.assq b subst2) sub_bl2)] in
	  if !debug_find_unique then 
	    begin
	      print_string "Def vars = "; Display.display_list (fun (b,l) -> Display.display_var [] b l) def_vars; print_newline()
	    end;
	  let dep_info =
	    ((bx1, List.map (fun b -> List.assq b subst1) sub_bl1),
	     List.map Terms.term_from_binderref def_vars)
	  in
	  List.for_all (fun n ->   
	    try
	    (* convert indices of bx2 to sub_bl2' *)
	      let renaming = List.map2 (fun t b -> (Terms.binder_from_term t, List.assq b subst1)) bx1.args_at_creation sub_bl1 in
	      let elsefind_facts = List.map (rename_elsefind renaming) n.elsefind_facts_at_def in
	      if !debug_find_unique then Facts.display_facts (subst4,facts4, elsefind_facts);
	      let (subst4, facts4, _) = Facts.simplif_add_list (dependency_collision_order_hyp all_indices dep_info) ([],[],[]) (subst4 @ facts4) in
	      let _ = convert_elsefind (dependency_collision_order_hyp all_indices dep_info) def_vars (subst4,facts4, elsefind_facts) in
	      if !debug_find_unique then print_string "Could not get a contradiction\n";
	      false
	    with Contradiction ->
	      true) bx1.def
	with Contradiction -> 
	  true
	)
	      ) defl2
	    ) (!analyzed2)
	  ) defl1
	) (!analyzed1)
  with Contradiction -> 
    true

(* prove unicity of find *)

let is_find_unique cur_array the_facts simp_facts find_branches =
  (List.for_all (branch_unique cur_array the_facts simp_facts) find_branches) &&
  (let rec incomp_branches = function
      [] -> true
    | (br::rest_br) -> 
	(List.for_all (incompatible_branches cur_array the_facts simp_facts br) rest_br) &&
	(incomp_branches rest_br)
  in
  incomp_branches find_branches)

