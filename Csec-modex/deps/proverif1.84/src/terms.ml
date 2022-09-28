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

let tuple_table = Hashtbl.create 1

let get_tuple_fun tl =
  let tl = 
    if !Param.ignore_types then
      List.map (fun _ -> Param.any_type) tl
    else
      tl
  in 
  try
    Hashtbl.find tuple_table tl
  with Not_found ->
    let r = { f_name = "";
              f_type = tl, Param.bitstring_type;
              f_cat = Tuple;
              f_initial_cat = Tuple;
              f_private = false;
	      f_options = 0 }
    in
    Hashtbl.add tuple_table tl r;
    r

let get_term_type = function
    Var b -> b.btype
  | FunApp(f,_) -> snd f.f_type

let get_format_type = function
    FVar b -> b.btype
  | FAny b -> b.btype
  | FFunApp(f,_) -> snd f.f_type

let rec copy_n n v =
  if n <= 0 then [] else v :: (copy_n (n-1) v)

let rec tl_to_string sep = function
    [] -> ""
  | [a] -> a.tname
  | (a::l) -> a.tname ^ sep ^ (tl_to_string sep l)

let eq_lists l1 l2 =
  (List.length l1 == List.length l2) && (List.for_all2 (==) l1 l2)

let var_idx = ref 0

let new_var_name() =
   incr var_idx;
   (!var_idx)

let new_var s t =
  { sname = s; vname = new_var_name(); btype = t; link = NoLink }

let new_var_def t =
  Var (new_var Param.def_var_name t)

let var_gen tl = List.map new_var_def tl

(* [occurs_var v t] determines whether the variable [v] occurs in the term [t] *)

let rec occurs_var v = function
    Var v' -> v == v'
  | FunApp(f,l) -> List.exists (occurs_var v) l

let occurs_var_fact v = function
    Pred(_,l) -> List.exists (occurs_var v) l
  | Out _ -> internal_error "Unexpected Out fact in occurs_var_fact"

(* [occurs_f f t] determines whether the function symbol [f] occurs in the term [t] *)

let rec occurs_f f = function
    Var _ -> false
  | FunApp(f',l) ->
      (f == f') || (List.exists (occurs_f f) l)

(* Equality tests *)

let rec equal_terms t1 t2 =
   match (t1,t2) with
   | (FunApp(f1,l1), FunApp(f2,l2)) ->
        (f1 == f2) && (List.for_all2 equal_terms l1 l2)
   | (Var v1, Var v2) -> v1 == v2
   | (_,_) -> false

let equals_term_pair (v, t) (v', t') = (v == v') && (equal_terms t t')

let equal_facts f1 f2 = 
  match (f1,f2) with
    Pred(chann1, t1),Pred(chann2, t2) ->
      (chann1 == chann2) && (List.for_all2 equal_terms t1 t2)
  | Out(t1,l1),Out(t2,l2) ->
      (equal_terms t1 t2) && (List.length l1 = List.length l2) 
	&& (List.for_all2 equals_term_pair l1 l2)
  | _ -> false

let equals_simple_constraint c1 c2 = 
  match (c1,c2) with
    (Neq(t1, t2), Neq(t1', t2')) ->
      (equal_terms t1 t1') && (equal_terms t2 t2') 

(* Copy and cleanup *)

let current_bound_vars = ref []

let link v l =
  current_bound_vars := v :: (!current_bound_vars);
  v.link <- l

let cleanup () = 
  List.iter (fun v -> v.link <- NoLink) (!current_bound_vars);
  current_bound_vars := []

let auto_cleanup f =
  let tmp_bound_vars = !current_bound_vars in
  current_bound_vars := [];
  try
    let r = f () in
    List.iter (fun v -> v.link <- NoLink) (!current_bound_vars);
    current_bound_vars := tmp_bound_vars;
    r
  with x ->
    List.iter (fun v -> v.link <- NoLink) (!current_bound_vars);
    current_bound_vars := tmp_bound_vars;
    raise x

(* We could also define the following functions instead of cleanup:

let in_auto_cleanup = ref false

let link v l =
  if not (!in_auto_cleanup) then
    Parsing_helper.internal_error "should be in auto_cleanup to use link";
  current_bound_vars := v :: (!current_bound_vars);
  v.link <- l

let auto_cleanup f =
  let tmp_in_auto_cleanup = !in_auto_cleanup in
  in_auto_cleanup := true;
  let tmp_bound_vars = !current_bound_vars in
  current_bound_vars := [];
  try
    let r = f () in
    List.iter (fun v -> v.link <- NoLink) (!current_bound_vars);
    current_bound_vars := tmp_bound_vars;
    in_auto_cleanup := tmp_in_auto_cleanup;
    r
  with x ->
    List.iter (fun v -> v.link <- NoLink) (!current_bound_vars);
    current_bound_vars := tmp_bound_vars;
    in_auto_cleanup := tmp_in_auto_cleanup;
    raise x

Use 
   auto_cleanup (fun () -> ...) 
instead of
   let tmp_bound_vars = !current_bound_vars in
   current_bound_vars := [];
   ...
   cleanup();
   current_bound_vars := tmp_bound_vars
and of
   if !current_bound_vars != [] then
      Parsing_helper.internal_error "...";
   ...
   cleanup()
This would be a better programming style, but this conflicts 
with the way the function Rules.build_rules_eq is written...
and would probably also slow down a bit the system.

*)

let rec copy_term = function
    FunApp(f,l) -> FunApp(f, List.map copy_term l)
  | Var v -> 
      match v.link with
	NoLink -> 
          let r = new_var v.sname v.btype in
	  link v (VLink r);
          Var r
      | VLink l -> Var l
      | _ -> internal_error "Unexpected link in copy_term"

let copy_term_pair = fun (v,t) -> (v, copy_term t)

let copy_fact = function
    Pred(chann, t) -> Pred(chann, List.map copy_term t)
  | Out(t, l) -> Out(copy_term t, List.map copy_term_pair l)

let copy_constra c = List.map (function
    Neq(t1,t2) -> Neq(copy_term t1, copy_term t2)) c

let rec copy_rule (hyp,concl,hist,constra) =
  let tmp_bound = !current_bound_vars in
  current_bound_vars := [];
  let r = (List.map copy_fact hyp, copy_fact concl, hist, List.map copy_constra constra) in
  cleanup();
  current_bound_vars := tmp_bound;
  r

let copy_red (left_list, right) =
  if !current_bound_vars != [] then
    Parsing_helper.internal_error "bound vars should be cleaned up (terms1)";
  let left_list' = List.map copy_term left_list in
  let right' = copy_term right in
  cleanup();
  (left_list', right')


(* Unification *)

exception Unify

let rec occur_check v t =
   match t with
     Var v' -> 
           begin
               if v == v' then raise Unify;
               match v'.link with
                 NoLink -> ()
               | TLink t' -> occur_check v t'
               | _ -> internal_error "unexpected link in occur_check"
           end
   | (FunApp(_,l)) -> List.iter (occur_check v) l

let rec unify t1 t2 =
   match (t1,t2) with
     (Var v, Var v') when v == v' -> ()
   | (Var v, _) -> 
       begin
          match v.link with
             NoLink ->
	       begin
		 match t2 with
		   Var {link = TLink t2'} -> unify t1 t2'
		 | _ ->
		     occur_check v t2;
		     link v (TLink t2)
	       end
           | TLink t1' -> unify t1' t2
           | _ -> internal_error "Unexpected link in unify 1"
       end
   | (_, Var v) ->
       begin
          match v.link with
             NoLink -> 
	       occur_check v t1;
	       link v (TLink t1)
           | TLink t2' -> unify t1 t2'
           | _ -> internal_error "Unexpected link in unify 2"
       end
   | (FunApp(f1, l1), FunApp(f2,l2)) ->
        if f1 != f2 then raise Unify;
        List.iter2 unify l1 l2

let rec skip n l =
  if n = 0 then l else
  match l with
    (a::l) -> skip (n-1) l
  | [] -> internal_error "skip error"

let unify_facts f1 f2 = 
  match (f1,f2) with
    Pred(chann1, t1),Pred(chann2,t2) ->
      if chann1 != chann2 then raise Unify;
      List.iter2 unify t1 t2
  | Out(t1,l1),Out(t2,l2) ->
      unify t1 t2;
      (* Warning: this might be a bit insecure? 
	 if List.length l1 != List.length l2 then raise Unify; *)
      let len1 = List.length l1 in
      let len2 = List.length l2 in
      if len2 < len1 then 
	begin
	  let l1 = skip (len1-len2) l1 in
	  List.iter2 (fun (v1,t1) (v2,t2) ->
	    if v1 != v2 then raise Unify;
	    unify t1 t2) l1 l2
	end
      else
	begin
	  let l2 = skip (len2-len1) l2 in
	  List.iter2 (fun (v1,t1) (v2,t2) ->
	    if v1 != v2 then raise Unify;
	    unify t1 t2) l1 l2
	end
  | _ -> raise Unify
    

let rec copy_term2 = function
    FunApp(f,l) -> FunApp(f, List.map copy_term2 l)
  | Var v -> 
      match v.link with
	NoLink -> 
          let r = new_var v.sname v.btype in
	  link v (VLink r);
          Var r
      | TLink l -> copy_term2 l
      | VLink r -> Var r
      | _ -> internal_error "unexpected link in copy_term2"

let copy_term2_pair = fun (v,t) -> (v, copy_term2 t)

let copy_fact2 = function
    Pred(chann, t) -> Pred(chann, List.map copy_term2 t)
  | Out(t,l) -> Out(copy_term2 t, List.map copy_term2_pair l)

let rec copy_constra2 c = List.map (function
    Neq(t1,t2) -> Neq(copy_term2 t1, copy_term2 t2)) c

(* Matching *)

exception NoMatch

let rec match_terms2 t1 t2 =
   match (t1,t2) with
     (Var v), t -> 
       begin
	 match v.link with
           NoLink -> 
	     link v (TLink t)
         | TLink t' -> if not (equal_terms t t') then raise NoMatch
	 | _ -> internal_error "Bad link in match_terms2"
       end
   | (FunApp (f1,l1')), (FunApp (f2,l2')) ->
       if f1 != f2 then raise NoMatch;
       List.iter2 match_terms2 l1' l2'
   | _,_ -> raise NoMatch

let match_facts2 f1 f2 = 
  match (f1,f2) with
    Pred(chann1, t1),Pred(chann2, t2) ->
      if chann1 != chann2 then raise NoMatch;
      List.iter2 match_terms2 t1 t2
  | Out(t1,l1),Out(t2,l2) ->
      match_terms2 t1 t2;
      let len1 = List.length l1 in
      let len2 = List.length l2 in
      if len1 != len2 then raise NoMatch;
      List.iter2 (fun (v1,t1) (v2,t2) ->
	if v1 != v2 then raise NoMatch;
	match_terms2 t1 t2) l1 l2
  | _ -> raise NoMatch

let matchafact finst fgen =
  if !current_bound_vars != [] then
    Parsing_helper.internal_error "bound vars should be cleaned up (terms)";
  try
    match_facts2 fgen finst;
    cleanup();
    true
  with NoMatch ->
    cleanup();
    false

let matchafactstrict finst fgen =
  if !current_bound_vars != [] then
    Parsing_helper.internal_error "bound vars should be cleaned up (terms2)";
  try
    match_facts2 fgen finst;
    if List.exists (fun v -> match v.link with
      TLink (Var _) -> false
    | TLink t -> true
    | _ -> false) (!current_bound_vars) then
      begin
	cleanup();
	true
      end
    else
      begin
	cleanup();
	false
      end
  with NoMatch ->
    cleanup();
    false


(* Size *)

let rec term_size = function 
    Var _ -> 0
  | FunApp(f, l) -> 1 + term_list_size l

and term_list_size = function
    [] -> 0
  | a::l -> term_size a + term_list_size l

let rec term_pair_list_size = function
    [] -> 0
  | (v,t)::l -> 1 + term_size t + term_pair_list_size l

let fact_size = function
    Pred(_, tl) -> 1 + term_list_size tl
  | Out(t,l) -> term_size t + term_pair_list_size l

(* For Neq and testunif *)

let gen_var_counter = ref 0

let new_gen_var t =
  incr gen_var_counter;
  { f_name = (if !Param.tulafale != 1 then "@gen" else "gen") ^ (string_of_int (!gen_var_counter));
    f_type = [], t;
    f_cat = General_var;
    f_initial_cat = General_var;
    f_private = true;
    f_options = 0 }

let rec generalize_vars_not_in vlist = function
    Var v -> 
      begin
	if List.memq v vlist then Var v else
	match v.link with
	  NoLink -> 
	    let v' = FunApp(new_gen_var v.btype, []) in
	    link v (TLink v');
	    v'
	| TLink l -> l
	| _ -> internal_error "Unexpected link in generalize_vars"
      end
  | FunApp(f, l) ->
      FunApp(f, List.map (generalize_vars_not_in vlist) l)

(* [replace_f_var vl t] replaces names in t according to
   the association list vl. That is, vl is a reference to a list of pairs
   (f_i, v_i) where f_i is a (nullary) function symbol and
   v_i is a variable. Each f_i is replaced with v_i in t.
   If an f_i in general_vars occurs in t, a new entry is added
   to the association list vl, and f_i is replaced accordingly. *)

let rec replace_f_var vl = function
    Var v2 -> Var v2
  | FunApp(f2,[]) -> 
      begin
	try
	  Var (List.assq f2 (!vl))
	with Not_found ->
	  if f2.f_cat = General_var then
	    begin
	      let v = new_var f2.f_name (snd f2.f_type) in
	      vl := (f2, v) :: (!vl);
	      Var v
	    end
	  else
	    FunApp(f2,[])
      end
  | FunApp(f2,l) -> FunApp(f2, List.map (replace_f_var vl) l)

(* [rev_assoc v2 vl] looks for v2 in the association list vl.
   That is, vl is a list of pairs (f_i, v_i) where f_i is a 
   (nullary) function symbol and v_i is a variable.
   If v2 is a v_i, then it returns f_i[],
   otherwise it returns v2 unchanged. *)

let rec rev_assoc v2 = function
    [] -> Var v2
  | ((f,v)::l) -> if v2 == v then FunApp(f,[]) else rev_assoc v2 l

(* [follow_link var_case t] follows links stored in variables in t
   and returns the resulting term. Variables are translated
   by the function [var_case] *)

let rec follow_link var_case = function
    Var v -> 
      begin
	match v.link with
	  TLink t -> follow_link var_case t
	| NoLink -> var_case v
	| _ -> Parsing_helper.internal_error "unexpected link in follow_link"
      end
  | FunApp(f,l) -> FunApp(f, List.map (follow_link var_case) l)

(* [replace name f t t'] replaces all occurrences of the name f (ie f[]) with t
   in t' *)

let rec replace_name f t = function
    Var v -> Var v
  | FunApp(f',[]) -> if f' == f then t else FunApp(f',[])
  | FunApp(f',l') -> FunApp(f', List.map (replace_name f t) l')

(* List of variables *)

let rec get_vars vlist = function
    Var v -> if not (List.memq v (!vlist)) then vlist := v :: (!vlist)
  | FunApp(_,l) -> 
      List.iter (get_vars vlist) l

let get_vars_constra vlist (Neq(t1,t2)) =
  get_vars vlist t1;
  get_vars vlist t2

let get_vars_fact vlist = function
    Pred(_,l) -> List.iter (get_vars vlist) l
  | Out(t,l) ->
      get_vars vlist t;
      List.iter(fun (_,t') -> get_vars vlist t') l

(* Copy of terms and constraints after matching *)

let rec copy_term3 = function
 | FunApp(f,l) -> FunApp(f, List.map copy_term3 l)
 | Var v -> match v.link with
     NoLink -> Var v
   | TLink l -> l
   | _ -> internal_error "unexpected link in copy_term3"

let copy_fact3 = function
    Pred(p,l) -> Pred(p, List.map copy_term3 l)
  | Out(t,l) -> Out(copy_term3 t, List.map (fun (x,t') -> (x, copy_term3 t')) l)

let rec copy_constra3 c = List.map (function
    Neq(t1,t2) -> Neq(copy_term3 t1, copy_term3 t2))c

(* Do not select Out facts, blocking facts, or pred_TUPLE(vars) *)

let is_var = function
    Var _ -> true
  | _ -> false

let unsel_set = ref ([] : fact list)
let add_unsel f =
  unsel_set := f :: (!unsel_set)

let is_unselectable = function
    Pred(p,pl) as f ->
      (p.p_prop land Param.pred_BLOCKING != 0) ||
      (p.p_prop land Param.pred_TUPLE != 0 && 
       p.p_prop land Param.pred_TUPLE_SELECT = 0 &&
       List.for_all is_var pl) ||
      (List.exists (function f' ->
	try 
	  auto_cleanup (fun () ->
	    unify_facts f f');
	  true
	with Unify ->
	  false
	    ) (!unsel_set))
  | Out _ -> true

(* Helper functions for decomposition of tuples *)
      
let rec reorganize_list l =
  let rec get_first = function
      [] -> ([], [])
    | (a ::l)::l' -> 
	let (firstl, rest) = get_first l' in
	(a :: firstl, l :: rest)
    | [] :: _ -> internal_error "unexpected case in reorganize_list"
  in
  match l with
    [] :: _ -> []
  | _ ->
      let (firstl, rest) = get_first l in
      firstl :: (reorganize_list rest)

let fun_app f = function 
    FunApp(f',l) when f == f' -> l
  | _ -> raise Not_found

let reorganize_fun_app f l0 =
  reorganize_list (List.map (fun_app f) l0)

(* Constants *)

let true_cst =
  { f_name = "true";
    f_type = [], Param.bool_type;
    f_cat = Tuple;
    f_initial_cat = Tuple;
    f_private = false;
    f_options = 0 }

let false_cst =
  { f_name = "false";
    f_type = [], Param.bool_type;
    f_cat = Tuple;
    f_initial_cat = Tuple;
    f_private = false;
    f_options = 0 }

(* Functions *)

let true_term = FunApp(true_cst, [])
let false_term = FunApp(false_cst, [])

let equal_memo = Param.memo (fun t -> 
  let v = new_var_def t in
  let equal_cat = Red [[v;v], true_term] in
  { f_name = "=";
    f_type = [t;t], Param.bool_type;
    f_cat = equal_cat;
    f_initial_cat = equal_cat;
    f_private = false;
    f_options = 0 })

let equal_fun t =
  equal_memo (if !Param.ignore_types then Param.any_type else t)

let and_fun =
  let and_cat = Red [[true_term; true_term], true_term] in
  { f_name = "&&";
    f_type = [Param.bool_type; Param.bool_type], Param.bool_type;
    f_cat = and_cat;
    f_initial_cat = and_cat;
    f_private = false;
    f_options = 0 }

let not_cat = 
  Red [[true_term], false_term; (* not(true) = false *)
       [false_term], true_term] (* not(false) = true *)

let not_fun =
  { f_name = "not";
    f_type = [Param.bool_type], Param.bool_type;
    f_cat = not_cat;
    f_initial_cat = not_cat;
    f_private = false;
    f_options = 0 }

let new_name_memo = Param.memo (fun t ->
  let cat = Name { prev_inputs = None; prev_inputs_meaning = ["!att"] } in
  { f_name = "new_name" ^ (Param.get_type_suffix t);
    f_type = [Param.sid_type], t;
    f_cat = cat;
    f_initial_cat = cat;
    f_private = false;
    f_options = 0 })

let new_name_fun t =
  new_name_memo (if !Param.ignore_types then Param.any_type else t)
