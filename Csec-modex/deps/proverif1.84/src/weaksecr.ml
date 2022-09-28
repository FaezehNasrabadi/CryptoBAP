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

let detect_atteq = function
    ([Pred(p1, [Var v1; Var v2]); Pred(p2, [Var v3; Var v4])],
     (Pred(p4, [])), _, [[Neq(Var v5, Var v6)]]) 
      when p1.p_prop land Param.pred_ELIMVAR != 0
      && p2.p_prop land Param.pred_ELIMVAR != 0
      && p4 == Param.bad_pred
      && v1 == v3
      && ((v2 == v5 && v4 == v6) || (v2 == v6 && v4 == v5)) -> true
  | _ -> false

let detect_atteq2 = function
    ([Pred(p1, [Var v1; Var v2]); Pred(p2, [Var v3; Var v4])],
     (Pred(p4, [])), _, [[Neq(Var v5, Var v6)]]) 
      when p1.p_prop land Param.pred_ELIMVAR != 0
      && p2.p_prop land Param.pred_ELIMVAR != 0
      && p4 == Param.bad_pred
      && v2 == v4
      && ((v1 == v5 && v3 == v6) || (v1 == v6 && v3 == v5)) -> true
  | _ -> false

let detect_atteq3 = function
    ([Pred(p1, [Var v1]); Pred(p2, [Var v3; Var v4])],
     (Pred(p4, [])), _, [[Neq(Var v5, Var v6)]]) 
      when p1.p_prop land Param.pred_ATTACKER != 0
      && p2.p_prop land Param.pred_ELIMVAR != 0
      && p4 == Param.bad_pred
      && v1 == v3
      && ((v3 == v5 && v4 == v6) || (v3 == v6 && v4 == v5)) -> true
  | _ -> false

let detect_atteq4 = function
    ([Pred(p1, [Var v1]); Pred(p2, [Var v3; Var v4])],
     (Pred(p4, [])), _, [[Neq(Var v5, Var v6)]]) 
      when p1.p_prop land Param.pred_ATTACKER != 0
      && p2.p_prop land Param.pred_ELIMVAR != 0
      && p4 == Param.bad_pred
      && v1 == v4
      && ((v3 == v5 && v4 == v6) || (v3 == v6 && v4 == v5)) -> true
  | _ -> false

let is_bad = function
    Pred(p, []) -> p==Param.bad_pred
  | _ -> false

let attrulenum = ref []

let elim_att_guess_xx next_stage repeat_next_stage (hyp, concl, hist, constra) =
  let redo_all_optim = ref false in
  let hist' = ref hist in
  let rec f n = function
      [] -> []
    | (Pred({ p_info = [AttackerGuess _]}, [Var v1; Var v2])) :: l when v1 == v2 ->
	redo_all_optim := true;
	hist' := Resolution(List.assq (if !Param.ignore_types || !Param.untyped_attacker then Param.any_type else v1.btype) (!attrulenum), n, !hist'); 
	(Pred(Param.get_pred (Attacker(!Param.max_used_phase, v1.btype)), [Var v1])) :: (f (n+1) l)
    | fact :: l -> fact :: (f (n+1) l)
  in
  let r' = (f 0 hyp, concl, !hist', constra) in
  if !redo_all_optim then
    repeat_next_stage r'
  else
    next_stage r'

let rec follow_link v = 
  match v.link with
    TLink (Var v') -> follow_link v'
  | NoLink -> v
  | _ -> Parsing_helper.internal_error "unexpected link in follow_link (weaksecr)"

let simplify next_stage repeat_next_stage ((hyp, concl, hist, constra) as r) = 
  if (not (!Param.weaksecret_mode)) || (detect_atteq r) || (detect_atteq2 r) ||
     (detect_atteq3 r) || (detect_atteq4 r) (* || (not (is_bad concl)) *)
  then
    next_stage r
  else
    let redo_all_optim = ref false in
    let rec find_att x = function
	[] -> false
      |	(Pred(p', [Var v])) :: _ when p'.p_prop land Param.pred_ATTACKER != 0
				 && v == x -> true
      |	_ :: l -> find_att x l
    in
    let rec find_right x y = function
	[] -> None
      |	(Pred(p', [Var v1; Var v2])) :: _ 
	when p'.p_prop land Param.pred_ELIMVAR != 0 && v1 == x && v2 != y ->
	  Some v2
      |	_ :: l -> find_right x y l
    in
    let rec find_left x y = function
	[] -> None
      |	(Pred(p', [Var v1; Var v2])) :: _ 
	when p'.p_prop land Param.pred_ELIMVAR != 0 && v2 == x && v2 != y ->
	  Some v1
      |	_ :: l -> find_left x y l
    in
    let link v1 v2 =
      let v1 = follow_link v1 in
      let v2 = follow_link v2 in
      if v1 != v2 then
	begin
	  Terms.link v2 (TLink (Var v1));
	  redo_all_optim := true
	end
    in
    let rec inst = function
	[] -> ()
      |	(h::r) ->
	  begin
	  match h with
	    Pred(p, [Var v1; Var v2]) when p.p_prop land Param.pred_ELIMVAR != 0 -> 
	      begin
		if find_att v1 hyp then
		  link v1 v2
		else if find_att v2 hyp then
		  link v2 v1
		else
		  match find_right v1 v2 r with
		    Some v2' -> link v2' v2
		  | None -> 
		      match find_left v2 v1 r with
		        Some v1' -> link v1' v1
		      | None -> ()
	      end
	  | _ -> ()
	  end;
	  inst r
    in
    inst hyp;
    if (!redo_all_optim) then
      begin
	let hyp' = List.map Terms.copy_fact2 hyp in
	let concl' = Terms.copy_fact2 concl in
	let constra' = List.map Terms.copy_constra2 constra in
	Terms.cleanup();
	repeat_next_stage (hyp', concl', hist, constra')
      end
    else
      elim_att_guess_xx next_stage repeat_next_stage r

(* Selection function: called when the standard selection function says 
   to select the conclusion *)  
   
let selfun ((hyp, concl, hist, constra) as r) = 
  if not ((!Param.weaksecret_mode) && (is_bad concl) && (hyp != [])) then -1 
  else
  if (detect_atteq r) || (detect_atteq2 r) then 0 else
  begin
    print_string "Warning: selection not found in Weaksecr.selfun in rule\n";
    Display.display_rule r;
    -1
  end
