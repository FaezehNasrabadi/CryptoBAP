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

(* 1. Is a type large? (i.e. the inverse of its cardinal is negligible) *)

let is_large t =
  (t.tsize >= !Settings.tysize_MIN_Auto_Coll_Elim)

let is_passwd t =
  (t.tsize >= !Settings.tysize_MIN_Manual_Coll_Elim)

let elim_collisions_on_password_occ = ref []

let is_large_term t =
  (is_large t.t_type) || 
  ((is_passwd t.t_type) && 
   (List.exists (fun s ->
     try
       int_of_string s = t.t_occ
     with Failure _ ->
       (s = t.t_type.tname) || 
       (match t.t_desc with
	 Var(b,l) -> s = Display.binder_to_string b (* if ... then begin print_string "occ "; print_int t.t_occ; print_newline(); true end else false *)
       | _ -> false)
	 ) (!elim_collisions_on_password_occ)))

(* 2. Cardinality functions *)

let card t =
match t.tcat with
  Interv p -> Count(p)
| _ -> Card(t)

let card_index b =
  Polynom.p_prod (List.map (fun t -> card t.t_type) b.args_at_creation)

(* 3. Computation of probabilities of collisions *)

(* Tests if proba_l/proba is considered small enough to eliminate collisions *)

let is_smaller proba_l factor_bound  =
  (* Sort the factor_bound and proba_l by decreasing sizes *)
  let factor_bound_sort = List.sort (fun (b1size, b1exp) (b2size, b2exp) -> compare b2size b1size) factor_bound in
  let proba_l = List.map (function 
      Count p -> p 
    | _ -> Parsing_helper.internal_error "Expecting value of a parameter in is_small_enough_coll_elim") proba_l in
  let proba_l_sort = List.sort (fun p1 p2 -> compare p2.psize p1.psize) proba_l in
  (* Check that factor_bound >= proba_l *)
  let rec ok_bound factor_bound proba_l =
    match (factor_bound, proba_l) with
      _, [] -> true
    | [], _ -> false
    | ((bsize, bexp):: rest), p::prest ->
	if p.psize <= bsize then
	  if bexp > 1 then ok_bound ((bsize, bexp-1)::rest) prest
	  else ok_bound rest prest
	else
	  false
  in
  ok_bound factor_bound_sort proba_l_sort

let is_small_enough_coll_elim (proba_l, proba) = 
  List.exists (fun (factor_bound, type_bound) ->
    match proba with
      Card t -> 
	(t.tsize >= type_bound) && 
	(is_smaller proba_l factor_bound)
    | _ -> Parsing_helper.internal_error "Expecting cardinal of a type in is_small_enough_coll_elim"
      ) (!Settings.allowed_collisions)

let is_small_enough_collision proba_l =
  List.exists (is_smaller proba_l) (!Settings.allowed_collisions_collision)
  

let whole_game = ref { proc = Terms.nil_proc; game_number = -1 }

(* An element (b1,b2) in eliminated_collisions or 
already_counted_eliminated_collisions means that we have used the fact
that collisions between b1 and b2 have negligible probability.
It is in already_counted_eliminated_collisions when the probability of
collision between b1 and b2 has been counted in a previous simplification,
so does not need to be counted again. *)

let already_counted_eliminated_collisions = ref []
let eliminated_collisions = ref [] 

let add_elim_collisions b1 b2 =
  let equal (b1',b2') =
           ((b1 == b1') && (b2 == b2')) ||
           ((b1 == b2') && (b2 == b1'))
  in
  if not ((List.exists equal (!eliminated_collisions)) ||
          (List.exists equal (!already_counted_eliminated_collisions))) then
    begin
      if is_small_enough_coll_elim (List.map (fun t -> card t.t_type) (b1.args_at_creation @ b2.args_at_creation), card b1.btype) then
	begin
	  eliminated_collisions := (b1, b2) :: (!eliminated_collisions);
	  true
	end
      else
	false
    end
  else
    true

let proba_for_collision b1 b2 =
  print_string "Eliminated collisions between ";
  Display.display_binder b1;
  print_string " and ";
  Display.display_binder b2;
  print_string " Probability: ";
  let p = 
    if b1 == b2 then
      Polynom.p_mul(Cst 0.5,Div(Polynom.p_mul(card_index b1, card_index b1), card b1.btype))
    else
      begin
        if b1.btype != b2.btype then
          Parsing_helper.internal_error "Collision between different types";
        Div(Polynom.p_mul(card_index b1, card_index b2), card(b1.btype))
      end
  in
  Display.display_proba 0 p;
  print_newline();
  p

(* An element (t1,t2,proba,tl) in red_proba means that t1 has been reduced
to t2 using a probabilistic reduction rule, and that the restrictions
in this rule are mapped according to list tl

I have a small doubt here on when exactly we can avoid counting several times
the same elimination of collisions in different games. I do it when the
probability does not depend on the runtime of the game. Would that be ok
even if it depends on it? *)

let already_counted_red_proba = ref []
let red_proba = ref []

let rec instan_time = function
    AttTime -> Add(AttTime, Time (!whole_game, Computeruntime.compute_runtime_for (!whole_game)))
  | Time _ -> Parsing_helper.internal_error "unexpected time"
  | (Cst _ | Count _ | OCount _ | Zero | Card _ | TypeMaxlength _) as x -> x
  | Proba(p,l) -> Proba(p, List.map instan_time l)
  | ActTime(f,l) -> ActTime(f, List.map instan_time l)
  | Maxlength(n,t) -> Maxlength(!whole_game, Terms.copy_term t) (* When add_proba_red is called, the variables in the reduction rule are linked to their corresponding term *)
  | Length(f,l) -> Length(f, List.map instan_time l)
  | Mul(x,y) -> Mul(instan_time x, instan_time y)
  | Add(x,y) -> Add(instan_time x, instan_time y)
  | Sub(x,y) -> Sub(instan_time x, instan_time y)
  | Div(x,y) -> Div(instan_time x, instan_time y)
  | Max(l) -> Max(List.map instan_time l)

let rec collect_array_indexes accu t =
  match t.t_desc with
    Var(b,[]) when Terms.is_repl b ->
	if not (List.memq b (!accu)) then
	  accu := b:: (!accu)
  | Var(b,l) -> List.iter (collect_array_indexes accu) l
  | FunApp(f,l) -> List.iter (collect_array_indexes accu) l
  | _ -> Parsing_helper.internal_error "If/let/find/new unexpected in collect_array_indexes"

let add_proba_red t1 t2 proba tl =
  let proba = instan_time proba in
  let equal (t1',t2',proba',tl') =
     (Terms.equal_terms t1 t1') && (Terms.equal_terms t2 t2') && (Terms.equal_probaf proba proba')
  in
  if not ((List.exists equal (!red_proba)) ||
          (List.exists equal (!already_counted_red_proba))) then
    begin
      let accu = ref [] in
      List.iter (fun (_,t) -> collect_array_indexes accu t) tl;
      let p = List.map (fun array_idx -> card array_idx.btype) (!accu) in
      if is_small_enough_collision p then
	begin
	  red_proba := (t1,t2,proba,tl) :: (!red_proba);
	  true
	end
      else
	false
    end
  else
    true

let proba_for_red_proba t1 t2 proba tl =
  print_string "Reduced ";
  Display.display_term [] t1;
  print_string " to ";
  Display.display_term [] t2;
  print_string " Probability: ";  
  let accu = ref [] in
  List.iter (fun (_,t) -> collect_array_indexes accu t) tl;
  let p = Polynom.p_mul(proba, Polynom.p_prod (List.map (fun array_idx -> card array_idx.btype) (!accu))) in
  Display.display_proba 0 p;
  print_newline();
  p


(* Initialization *)

let reset coll_elim (ac_coll, ac_red_proba) g =
  whole_game := g;
  elim_collisions_on_password_occ := coll_elim;
  eliminated_collisions := [];
  already_counted_eliminated_collisions := ac_coll;
  red_proba := [];
  already_counted_red_proba := ac_red_proba

(* Final addition of probabilities *)

let final_add_proba coll_list =
  let proba = ref Zero in
  let add_proba p =
    if !proba == Zero then proba := p else proba := Polynom.p_add(!proba, p)
  in
  List.iter (fun (b1,b2) -> add_proba (proba_for_collision b1 b2))
    (!eliminated_collisions);
  List.iter (fun (t1,t2,proba,tl) -> add_proba (proba_for_red_proba t1 t2 proba tl))
    (!red_proba);
  List.iter add_proba coll_list;
  let r = Polynom.polynom_to_probaf (Polynom.probaf_to_polynom (!proba)) in
  if r == Zero then [] else [ SetProba { set_name = ""; proba = r } ]

let final_internal_info() =
  let internal_info' =
    ((!eliminated_collisions) @ (!already_counted_eliminated_collisions),
     (!red_proba) @ (!already_counted_red_proba)) 
  in
  eliminated_collisions := [];
  red_proba := [];
  elim_collisions_on_password_occ := [];
  internal_info'

let get_current_state() =
  (!eliminated_collisions, !red_proba)

let restore_state (ac_coll, ac_red_proba) =
  eliminated_collisions := ac_coll;
  red_proba := ac_red_proba
