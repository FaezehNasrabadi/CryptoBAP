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

let debug = false

(* For backtracking *)
exception Backtrack

let rec state_without_proof state =
  match state.prev_state with
    None -> state
  | Some(Proof _,_,s) -> state_without_proof s
  | Some(i,p,s) -> { state with prev_state = Some(i,p,state_without_proof s) }

let eq_list l1 l2 =
  (List.for_all (fun x -> List.memq x l1) l2) &&
  (List.for_all (fun x -> List.memq x l2) l1)

let has_common_elem l1 l2 =
  List.exists (fun x -> List.memq x l1) l2

let sa_rename_ins_updater b bl = function
    (ExpandIfFind | Simplify _ | RemoveAssign(All) | RemoveAssign(Minimal) | 
     MoveNewLet(MAll | MNoArrayRef | MLet | MNew | MNewNoArrayRef) | 
     Proof _ | InsertEvent _ | InsertInstruct _ | ReplaceTerm _ | MergeBranches |
     MergeArrays _ (* MergeArrays does contain variable names, but it is advised only when these variables have a single definition, so they are not modified by SArename *)) as x -> [x]
  | RemoveAssign (OneBinder b') ->
      if b' == b then
	List.map (fun b'' ->  RemoveAssign (OneBinder b'')) bl
      else
	[RemoveAssign (OneBinder b')]
  | RemoveAssign (SubstOneBinder (b',occ)) ->
      if b' == b then
	List.map (fun b'' ->  RemoveAssign (SubstOneBinder (b'',occ))) bl
      else
	[RemoveAssign (SubstOneBinder (b',occ))]
  | SArenaming b' -> 
      if b' == b then
	 (* If b' == b, useless after SArenaming b *)
	[]
      else
	[SArenaming b']
  | MoveNewLet (MOneBinder b') -> 
      if b' == b then
	List.map (fun b'' -> MoveNewLet (MOneBinder b'')) bl
      else
	[MoveNewLet (MOneBinder b')]
  | CryptoTransf(eq,bl') ->
      if List.memq b bl' then
	List.map (fun b'' -> CryptoTransf(eq, List.map (fun b' -> if b' == b then b'' else b') bl')) bl
      else
	[CryptoTransf(eq,bl')]

let compos_ins_updater a b = match a, b with
  None, x -> x
| x, None -> x
| Some f1, Some f2 -> Some (fun t -> List.concat (List.map f2 (f1 t)))

let apply_ins_updater ins_up i =
  match ins_up with
    None -> [i]
  | Some f -> f i

let apply_ins_updater_list ins_up l =
  match ins_up with
    None -> l
  | Some f -> List.concat (List.map f l)

let rec compos_sa_rename = function
    [] -> None
  | ((b,bl')::l) -> compos_ins_updater (Some (sa_rename_ins_updater b bl')) (compos_sa_rename l)

let execute simplify_internal_info g = function
    ExpandIfFind -> ({ proc = Transform.expand_process g.proc; game_number = -1 }, [], simplify_internal_info, None)
  | Simplify l -> 
      let (g', proba, simplify_internal_info', sa_rename) = 
	Simplify.simplify_main l simplify_internal_info g
      in
      (g', proba, simplify_internal_info', compos_sa_rename sa_rename)
  | MoveNewLet s -> ({ proc = Transform.move_new_let s g.proc; game_number = -1 }, [], simplify_internal_info, None)
  | RemoveAssign r -> 
      let (p', sa_rename) = Transform.remove_assignments r g.proc in
      ({ proc = p'; game_number = -1 }, [], simplify_internal_info, compos_sa_rename sa_rename)
  | SArenaming b -> 
      let (p', sa_rename) = Transform.sa_rename b g.proc in
      ({ proc = p'; game_number = -1 }, [], simplify_internal_info, compos_sa_rename sa_rename)
  | InsertEvent(s,occ) ->
      let (set, g') = Transform.insert_event occ s g in
      (g', set, simplify_internal_info, None)
  | InsertInstruct(s,ext_s,occ,ext_o) ->
      let (p', sa_rename) = Insertinstruct.insert_instruct occ ext_o s ext_s g.proc in
      ({ proc = p'; game_number = -1 }, [], simplify_internal_info, compos_sa_rename sa_rename)
  | ReplaceTerm(s,ext_s,occ,ext_o) ->
      Insertinstruct.replace_term simplify_internal_info occ ext_o s ext_s g 
  | MergeArrays(bll, m) ->
      Mergebranches.merge_arrays simplify_internal_info bll m g
  | MergeBranches ->
      Mergebranches.merge_branches simplify_internal_info g
  | CryptoTransf _ | Proof _ -> 
      Parsing_helper.internal_error "CryptoTransf/Proof unexpected in execute"

let execute_state state i =
  print_string "Doing ";
  Display.display_instruct i;
  print_string "... "; flush stdout;
  let (g', proba, simplify_internal_info, ins_update) = execute state.simplify_internal_info state.game i in
  if !Transform.changed then
    begin
      print_string "Done.";
      print_newline()
    end
  else
    begin
      print_string "No change.";
      print_newline()
    end;
  if debug then
    begin
      print_string " Resulting game:\n";
      Display.display_process g'.proc
    end;
  if !Transform.changed then
    begin
      Invariants.global_inv g'.proc;
      ({ game = g';
	 simplify_internal_info = simplify_internal_info;
	 prev_state = Some (i, proba, state) }, ins_update)
    end
  else
    (state, None)

let execute_state state = function
    SArenaming b ->
      (* Adding simplification after SArenaming *)
      let tmp_changed = !Transform.changed in
      Transform.changed := false;
      let (state', ins_updater) = execute_state state (SArenaming b) in
      if !Transform.changed then 
	if !Settings.simplify_after_sarename then 
	  let (state'', ins_updater') = execute_state state' (RemoveAssign Minimal) in
	  let (state''', ins_updater'') = execute_state state'' (Simplify []) in
	  (state''', compos_ins_updater (compos_ins_updater ins_updater ins_updater') ins_updater'')
	else
	  (state', ins_updater)
      else
	begin
	  Transform.changed := tmp_changed;
	  (state', ins_updater)
	end
  | i -> execute_state state i

let rec execute_with_advise state i = 
  let tmp_changed0 = !Transform.changed in
  Transform.changed := false;
  Transform.advise := [];
  let (state', ins_update) = execute_state state i in
  if (!Transform.advise) != [] then
    (* Retry after executing the advise *)
    let tmp_changed = !Transform.changed in
    Transform.changed := false;
    if debug then
      begin
	print_string "Trying advice ";
	Display.display_list Display.display_instruct (!Transform.advise);
	print_newline()
      end;
    let (state'', ins_update') = execute_list_with_advise state' (!Transform.advise) in
    if !Transform.changed then
      let (state3, ins_update'') = execute_list_with_advise state'' (apply_ins_updater ins_update' i) in
      (state3, compos_ins_updater ins_update (compos_ins_updater ins_update' ins_update''))
    else
      begin
	Transform.changed := tmp_changed0 || tmp_changed;
	(state', ins_update)
      end
  else
    begin
      Transform.changed := tmp_changed0 || (!Transform.changed);
      (state', ins_update)
    end

and execute_list_with_advise state = function
    [] -> (state, None)
  | (a::l) -> 
      let (state1, ins_update1) = execute_with_advise state a in
      let (state2, ins_update2) = execute_list_with_advise state1 (apply_ins_updater_list ins_update1 l) in
      (state2, compos_ins_updater ins_update1 ins_update2)

let execute_with_advise_last state i = 
  (* No need to update next instructions, so we can ignore the ins_updater *)
  let (state', _) = execute_with_advise state i in
  state'


let execute_display_advise state i =
  if !Settings.auto_advice then
    execute_with_advise_last state i 
  else
    let tmp_changed0 = !Transform.changed in
    Transform.changed := false;
    Transform.advise := [];
    let (state', _) = execute_state state i in
    if (!Transform.advise) != [] then
      begin
	print_string "Advised transformations ";
	Display.display_list Display.display_instruct (!Transform.advise);
	print_newline()
      end;
    Transform.changed := tmp_changed0 || (!Transform.changed);
    state'

type trans_res =
    CSuccess of state
  | CFailure of (equiv_nm * binder list * instruct list) list

let move_new_let state =
  if !Settings.auto_move then
    execute_with_advise_last state (MoveNewLet MAll)
  else
    state

let simplify state = execute_with_advise_last (move_new_let (execute_with_advise_last state (Simplify []))) (RemoveAssign Minimal)

let expand_simplify state = simplify (execute_with_advise_last state ExpandIfFind)

let crypto_transform stop no_advice equiv bl_assoc state =
  print_string "Trying "; Display.display_instruct (CryptoTransf(equiv, bl_assoc)); print_string "... ";
  let res = Cryptotransf.crypto_transform state.simplify_internal_info stop no_advice equiv bl_assoc state.game in
  match res with
    TSuccess (proba,g'',simplify_internal_info') -> 
      if debug then
	begin
	  Display.display_process state.game.proc;
	  print_string "Applying ";
	  Display.display_equiv equiv;
	  if bl_assoc != [] then
	    begin
	      print_string "with ";
	      Display.display_bl_assoc bl_assoc
	    end;
	  print_string " succeeds. Resulting game:\n";
	  Display.display_process g''.proc
	end
      else
	print_string "Succeeded.\n"; 
      (* Always expand FindE *)
      Invariants.global_inv g''.proc;
      CSuccess (simplify { game = g''; 
			   simplify_internal_info = simplify_internal_info';
			   prev_state = Some (CryptoTransf(equiv, bl_assoc), proba, state) })
  | TFailure l ->
      if debug then
	begin
	  Display.display_process state.game.proc;
	  print_string "Applying ";
	  Display.display_equiv equiv;
	  if bl_assoc != [] then
	    begin
	      print_string "with ";
	      Display.display_bl_assoc bl_assoc
	    end;
	  print_string " failed.\n";
	  if l != [] then print_string "Suggestions: \n";
	  List.iter (fun (_, bl_assoc, to_do) ->
	    Display.display_bl_assoc bl_assoc;
	    print_string ", after executing ";
	    Display.display_list Display.display_instruct to_do;
	    print_newline()
	      ) l
	end
      else
	print_string "Failed.\n";
      CFailure l

let rec execute_crypto_list continue = function
    [] -> continue (CFailure [])
  | ((equiv, bl_assoc, to_do), state, first_try, stop)::l ->
      (* Try after executing the advice *)
      Transform.changed := false;
      if to_do == [] then
        (* When no advice is given and it's not the first time the transfo is tried, apply the crypto transformation without advice *)
	match crypto_transform stop ((not first_try) || (!Settings.no_advice_crypto)) equiv bl_assoc state with
	  CSuccess state'' -> 
	    begin
	      try
		continue (CSuccess state'')
	      with Backtrack ->
		if !Settings.backtrack_on_crypto then
	          (* Filter the choices to avoid considering too many similar choices *)
		  let l = List.filter (fun ((equiv', bl_assoc', _), _, _, _) -> 
		    equiv' != equiv || not (has_common_elem bl_assoc' bl_assoc)) l
		  in
		  (*
		  print_string "Just tried\n";
		  Display.display_instruct (CryptoTransf(equiv, bl_assoc));
		  print_string "\nContinuing with:\n";
		  List.iter (fun ((equiv, bl_assoc, _), _, _) -> Display.display_instruct (CryptoTransf(equiv, bl_assoc)); print_newline()) l;
		  print_string "End of list\n";
		  *)
		  if l = [] then raise Backtrack;
		  execute_crypto_list continue (List.map (fun (tr, st, first_try, stop) -> (tr, state_without_proof st, first_try, stop)) l)
		else
		  raise Backtrack
	    end
	| CFailure l' -> execute_crypto_list continue ((List.map (fun x -> (x, state, false, stop)) l') @ l) 
      else
	let (state', ins_updater) = execute_list_with_advise state to_do in
	if !Transform.changed then
	  let l_crypto_transf = apply_ins_updater ins_updater (CryptoTransf(equiv, bl_assoc)) in
	  execute_crypto_list continue ((List.map (function
	      CryptoTransf(equiv, bl_assoc) -> ((equiv, bl_assoc, []), state', true, stop)
	    | _ -> Parsing_helper.internal_error "The result of an ins_updater on CryptoTransf should be a list of CryptoTransf") l_crypto_transf) @ l)
	else
	  execute_crypto_list continue l
	

let rec execute_any_crypto_rec continue state = function
    [] -> continue (CFailure [])
  | (((_,_,_,opt,_),_) as equiv::equivs) ->
      match opt with
	ManualEqopt -> 
          (* This equivalence should be applied only manually, and we are in automatic mode, so skip it *) 
	  execute_any_crypto_rec continue state equivs
      |	_ ->
      match crypto_transform false (!Settings.no_advice_crypto) equiv [] state with
	CSuccess state' -> 
	  begin
	    try
	      continue (CSuccess state')
	    with Backtrack ->
	      if !Settings.backtrack_on_crypto then
		begin
		  (*
		  print_string "Just tried equivalence\n";
		  Display.display_equiv equiv;
		  print_string "\nContinuing with equivalences:\n";
		  List.iter Display.display_equiv equivs;
		  print_string "End of list\n";
		  *)
		  execute_any_crypto_rec continue (state_without_proof state) equivs
		end
	      else
		raise Backtrack
	  end
      | CFailure l -> 
	  execute_any_crypto_rec (function  
	      CSuccess state' -> continue (CSuccess state')
	    | CFailure l' -> continue (CFailure (l @ l'))) state equivs

let rec issuccess_with_advise state = 
  Transform.advise := [];
  let (proved_queries, is_done) = Success.is_success state.simplify_internal_info state.game in
  let state' = 
    if proved_queries != [] then
      { game = state.game;
	simplify_internal_info = state.simplify_internal_info; 
	prev_state = Some (Proof proved_queries, [], state) }
    else
      state
  in
  if is_done then
    (state', true)
  else 
    let (state'', is_done'') = 
      if (!Transform.advise) != [] then
        (* Retry after executing the advise *)
	let tmp_changed = !Transform.changed in
	Transform.changed := false;
	if debug then
	  begin
	    print_string "Trying advice ";
	    Display.display_list Display.display_instruct (!Transform.advise);
	    print_newline()
	  end;
	let (state'',_) = execute_list_with_advise state' (!Transform.advise) in
	if !Transform.changed then
	  issuccess_with_advise state''
	else
	  begin
	    Transform.changed := tmp_changed;
	    (state', false)
	  end
      else
	(state', false)
    in
    if (state'' == state') && (proved_queries == []) && (is_done'' == false) then
      (state, false) (* Forget useless changes *)
    else
      (state'', is_done'')

let display_state tex state = 
  let state' = 
    let eq_queries = List.filter (function (AbsentQuery, _) -> true | _ -> false) (!Transform.queries) in
    if eq_queries == [] then
      state
    else
      { game = state.game;
	simplify_internal_info = state.simplify_internal_info; 
	prev_state = Some (Proof (List.map (fun q -> (q, [])) eq_queries), [], state) }
  in
  Display.display_state state';
  if tex && ((!Settings.tex_output) <> "") then
    Displaytex.display_state state'

let final_display rest =
  let rest' = List.filter (function (AbsentQuery, _) -> false | _ -> true) rest in
  if rest = [] then 
    print_string "All queries proved.\n"
  else if rest' != [] then
    begin
      print_string "RESULT Could not prove ";
      Display.display_list Display.display_query rest;
      print_string ".\n"
    end;
  if (!Settings.tex_output) <> "" then
    begin
      if rest = [] then
	Displaytex.print_string "All queries proved.\\\\\n"
      else if rest' != [] then
	begin
	  Displaytex.print_string "Could not prove ";
	  Displaytex.display_list Displaytex.display_query rest;
	  Displaytex.print_string ".\\\\\n"
	end
    end
  

let rec display_state_until_proof state =
  match state.prev_state with
    None -> ()
  | Some(Proof _,_,_) -> 
      display_state true state
  | Some(_,_,s) -> display_state_until_proof s 

let rec display_short_state state =
  match state.prev_state with
    None -> ()
  | Some(CryptoTransf _ as i, _, s) ->
      display_short_state s;
      Display.display_instruct i;
      print_newline()
  | Some(_,_,s) ->
      display_short_state s

(* Insertion sort; used to sort the equivalences according to their priority.
   The elements of same priority are grouped in a list *)

let get_prio ((_,_,_,opt,_),_) =
  match opt with
    StdEqopt | ManualEqopt -> 0
  | PrioEqopt n -> n
    
let rec insert_elem a = function
    [] -> [[a]]
  | (l1::l) ->
      match l1 with
	[] -> Parsing_helper.internal_error "Empty list unexpected in insert_elem"
      |	first_l1::_ ->
	  let prio_l1 = get_prio first_l1 in
	  let prio_a = get_prio a in
	  if prio_l1 = prio_a then (a::l1)::l else
	  if prio_l1 < prio_a then l1 :: (insert_elem a l) else
	  [a]::l1::l
	  
let rec insert_sort sorted = function
    [] -> sorted
  | (a::l) ->
      let sorted' = insert_sort sorted l in
      (* Insert a into sorted' *)
      insert_elem a sorted'


let rec execute_any_crypto_rec1 state =
  let (state', is_done) =  issuccess_with_advise state in
  if is_done then
    begin
      print_string "===================== Proof starts =======================\n";
      display_state true state';
      final_display [];
      (CSuccess state', state)
    end
  else
    let equiv_list = insert_sort [] (!Transform.equivs) in
    let rec apply_equivs = function
	[] -> 
	  if !Settings.backtrack_on_crypto then
	    begin
	      print_string "===================== Proof starts =======================\n";
	      display_state_until_proof state';
	      print_string "====================== Proof ends ========================\n";
	      print_string "Examined sequence:\n";
	      display_short_state state';
	      print_string "Backtracking...\n";
	      raise Backtrack
	    end
	  else
	    begin
	      print_string "===================== Proof starts =======================\n";
	      display_state true state';
	      final_display (!Transform.queries);
	      (CFailure [], state')
	    end
      |	lequiv::rest_equivs ->
	  execute_any_crypto_rec (function
	      CSuccess state'' -> execute_any_crypto_rec1 state''
	    | CFailure l -> execute_crypto_list (function 
		  CFailure _ -> 
		    apply_equivs rest_equivs
		| CSuccess state''' ->
		    execute_any_crypto_rec1 state''') (List. map (fun x -> (x, state', false, false)) l)) state' lequiv
    in
    apply_equivs equiv_list

let execute_any_crypto state =
  (* Always begin with find/if/let expansion *)
  try
    let (res, state') = execute_any_crypto_rec1 (expand_simplify state) in
    res
  with Backtrack ->
    final_display (!Transform.queries);
    CFailure []
	    
(* Interactive prover *)

exception End of state

let add accu b =
  let s = Display.binder_to_string b in
  if not (Hashtbl.mem accu s) then
    Hashtbl.add accu s b

let rec find_binders_term accu t =
  match t.t_desc with
    Var(_,l) | FunApp(_,l) ->
      List.iter (find_binders_term accu) l
  | TestE(t1,t2,t3) ->
      find_binders_term accu t1;
      find_binders_term accu t2;
      find_binders_term accu t3
  | FindE(l0,t3,_) ->
      List.iter (fun (bl,def_list,t1,t2) ->
	List.iter (add accu) bl;
        List.iter (find_binders_br accu) def_list;
	find_binders_term accu t1;
	find_binders_term accu t2) l0;
      find_binders_term accu t3
  | ResE(b,t) ->
      add accu b;
      find_binders_term accu t
  | EventE(t) ->
      find_binders_term accu t
  | LetE(pat, t1, t2, topt) ->
      find_binders_pat accu pat;
      find_binders_term accu t1;
      find_binders_term accu t2;
      match topt with
	None -> ()
      |	Some t3 -> find_binders_term accu t3
      
and find_binders_pat accu = function
    PatVar b -> add accu b
  | PatTuple(_,l) -> List.iter (find_binders_pat accu) l
  | PatEqual t -> find_binders_term accu t

and find_binders_br accu (b,l) =
  List.iter (find_binders_term_def_list accu) l;
  add accu b

and find_binders_term_def_list accu t =
  match t.t_desc with
    Var(b,l) -> 
      List.iter (find_binders_term_def_list accu) l;
      add accu b
  | FunApp(_,l) ->
      List.iter (find_binders_term_def_list accu) l
  | _ -> 
      Parsing_helper.internal_error "if/let/find/new forbidden in def_list"

let rec find_binders_rec accu p =
  match p.i_desc with
    Nil -> ()
  | Par(p1,p2) -> 
      find_binders_rec accu p1;
      find_binders_rec accu p2
  | Repl(b,p) -> find_binders_rec accu p
  | Input((c, tl),pat,p) ->
      List.iter (find_binders_term accu) tl;
      find_binders_pat accu pat;
      find_binders_reco accu p

and find_binders_reco accu p =
  match p.p_desc with
    Yield -> ()
  | Restr(b,p) -> 
      add accu b;
      find_binders_reco accu p
  | Test(t,p1,p2) ->
      find_binders_term accu t;
      find_binders_reco accu p1;
      find_binders_reco accu p2
  | Find(l0,p2,_) ->
      List.iter (fun (bl,def_list,t,p1) ->
	List.iter (add accu) bl;
        List.iter (find_binders_br accu) def_list;
	find_binders_term accu t;
	find_binders_reco accu p1) l0;
      find_binders_reco accu p2
  | Output((c, tl),t2,p) ->
      List.iter (find_binders_term accu) tl;      
      find_binders_term accu t2;
      find_binders_rec accu p
  | Let(pat, t, p1, p2) ->
      find_binders_pat accu pat;
      find_binders_term accu t;
      find_binders_reco accu p1;
      find_binders_reco accu p2
  | EventP(t,p) ->
      find_binders_term accu t;
      find_binders_reco accu p

let find_binders game =
  let accu = Hashtbl.create 7 in
  find_binders_rec accu game;
  accu 

let find_binder binders s =
  Hashtbl.find binders s

let rec find_funsymb f t =
  match t.t_desc with
    Var(b,l) -> List.exists (find_funsymb f) l
  | FunApp(f',l) -> (f = f'.f_name) || (List.exists (find_funsymb f) l)
  | _ -> Parsing_helper.internal_error "If / find / let should not occur in left members of equivalences"

let rec find_funsymb_fg f = function
    ReplRestr(_,_,l) -> List.exists (find_funsymb_fg f) l
  | Fun(_,_,r,_) -> find_funsymb f r

let rec find_proba f = function
    Proba (p,_) -> f = p.prname
  | Count _ | OCount _ | Cst _ | Zero | Card _ | AttTime | Time _ | ActTime _ | Maxlength _ |  TypeMaxlength _ -> false
  | Add(x,y) | Sub(x,y) | Mul(x,y) | Div(x,y) -> (find_proba f x) || (find_proba f y)
  | Max(l) | Length(_,l) -> List.exists (find_proba f) l

let find_equiv f ((lm,_,set,_,_),_) =
  (List.exists (fun (fg, _) -> find_funsymb_fg f fg) lm) ||
  (List.exists (function 
      SetProba r -> find_proba f r.proba
    | SetEvent(e,_) -> f = e.f_name) set)

let do_equiv ext equiv lb state = 
  match lb with
    ["*", _] ->
      let rec repeat_crypto equiv state = 
	match crypto_transform false (!Settings.no_advice_crypto) equiv [] state with
	  CSuccess state' -> repeat_crypto equiv state'
	| CFailure l -> 
	    execute_crypto_list (function 
		CSuccess state'' -> repeat_crypto equiv state''
	      | CFailure _ -> print_string "Done all possible transformations with this equivalence.\n"; state) (List.map (fun x -> (x, state, false, false)) l) 
      in
      repeat_crypto equiv state
  | _ -> 
    (* When the list of binders lb ends with a ".", do not add more binders
       automatically *)
      let (lb, stop) = 
	match List.rev lb with 
	  (".",_)::rest -> (List.rev rest, true) 
	| _ -> (lb, false) 
      in
      let binders = find_binders state.game.proc in	      	  
      let lb' = List.map (fun (s,ext) -> 
	try
	  find_binder binders s 
	with Not_found -> 
	  raise (Error("Binder " ^ s ^ " not found", ext))
	  ) lb in
      match crypto_transform stop (!Settings.no_advice_crypto) equiv lb' state with
	CSuccess state' -> state'
      | CFailure l -> 
	  if !Settings.auto_advice then
	    execute_crypto_list (function 
	      CSuccess state'' -> state''
	    | CFailure _ -> raise (Error ("Cryptographic transformation failed", ext))) (List.map (fun x -> (x, state, false, stop)) l) 
	  else
	    begin
	      if l != [] then print_string "Failed. Suggestions: \n";
	      List.iter (fun (_, bl_assoc, to_do) ->
		Display.display_bl_assoc bl_assoc;
		print_string ", after executing ";
		Display.display_list Display.display_instruct to_do;
		print_newline()
		  ) l;
	      raise (Error ("Cryptographic transformation failed", ext))
	    end



let rec undo ext state n =
  if n <= 0 then state else
  match state.prev_state with
    None -> 
      raise (Error("Could not undo more steps than those already done", ext))
  | Some (ExpandIfFind,_, { prev_state = None }) ->
      raise (Error("Cannot undo the first expansion", ext))
  | Some (ExpandIfFind,_,_) ->
      Parsing_helper.internal_error "ExpandIfFind should occur only as first instruction"
  | Some (_,_,state') -> undo ext state' (n-1)

let rec concat_strings = function
    [] -> Parsing_helper.internal_error "Empty list in concat_strings"
  | [a,_] -> a
  | ((a, _)::l) -> a ^ " " ^ (concat_strings l)

let help() =
  print_string (
  "List of available commands\n" ^
  "remove_assign useless        : remove useless assignments\n" ^
  "remove_assign binder <ident> : remove assignments on variable <ident>\n" ^
  "remove_assign all            : remove all assignments (not recommended)\n" ^
 (if (!Settings.front_end) == Settings.Channels then
  "move all                     : move all \"new\" and \"let\" down in the game\n" ^
  "move noarrayref              : move \"new\" and \"let\" without array references down in the game\n" ^
  "move random                  : move all \"new\" down in the game\n" ^
  "move random_noarrayref       : move \"new\" without array references down in the game\n" ^
  "move assign                  : move all \"let\" down in the game\n" ^
  "move assign_noarrayref       : move \"let\" without array references down in the game\n" ^
  "move binder <ident>          : move \"new <ident>\" or \"let <ident>\" down in the game\n"
  else
  "move all                     : move all \"<-R\" and \"<-\" down in the game\n" ^
  "move noarrayref              : move \"<-R\" and \"<-\" without array references down in the game\n" ^
  "move random                  : move all \"<-R\" down in the game\n" ^
  "move random_noarrayref       : move \"<-R\" without array references down in the game\n" ^
  "move assign                  : move all \"<-\" down in the game\n" ^
  "move assign_noarrayref       : move \"<-\" without array references down in the game\n" ^
  "move binder <ident>          : move \"<ident> <-R\" or \"<ident> <-\" down in the game\n") ^
  "SArename <ident>    : rename several definitions of <ident> to distinct names\n" ^
  "crypto                       : apply a cryptographic transformation\n" ^
  "(can be used alone or with a specifier of the transformation; see the manual)\n" ^
  "simplify                     : simplify the game\n" ^
  "simplify coll_elim <locations> : simplify the game, allowing collision eliminination at <locations> (variables, types, occurrences)\n" ^
  "all_simplify                 : remove_assign useless, simplify, move all\n" ^
  "insert_event <ident> <occ>   : insert an event <ident> at occurrence <occ>\n" ^
  "insert <occ> <ins>           : insert instruction <ins> at occurrence <occ>\n" ^
  "replace <occ> <term>         : replace term at occurrence <occ> with <term> (when equal)\n" ^
  "merge_arrays <ident> ...     : merge all given variables\n" ^
  "success                      : check the desired properties\n" ^
  "show_game                    : show the current game\n" ^
  "show_game occ                : show the current game with occurrences\n" ^
  "show_state                   : show the sequence of games up to now\n" ^
  "auto                         : try to terminate the proof automatically\n" ^
  "set <param> = <value>        : set the value of various parameters\n" ^
  "undo                         : undo the last transformation\n" ^
  "undo <n>                     : undo the last n transformations\n" ^
  "restart                      : restart from the initial game\n" ^
  "help                         : display this help message\n" ^  "?                            : display this help message\n")

let map_param (s,ext) ext_s =
  match s with
    "noninteractive" -> Settings.psize_NONINTERACTIVE
  | "passive" -> Settings.psize_PASSIVE
  | "small" -> Settings.psize_DEFAULT
  | _ -> (* option "size<n>" where <n> is an integer *)
      try
	if (String.sub s 0 4) <> "size" then raise Not_found;
	int_of_string (String.sub s 4 (String.length s - 4))
      with _ ->
	raise (Error("Unknown parameter size " ^ s, Parsing_helper.combine_extent ext_s ext))

let map_type (s,ext) ext_s =   
  match s with
    "large" -> Settings.tysize_LARGE
  | "password" -> Settings.tysize_PASSWORD
  | "small" -> Settings.tysize_SMALL
  | _ -> (* option size<n> *)
      try
	if (String.sub s 0 4) <> "size" then raise Not_found;
	int_of_string (String.sub s 4 (String.length s - 4))
      with _ ->
	raise (Error("Unknown type size " ^ s, Parsing_helper.combine_extent ext_s ext))


let rec interpret_command interactive state = function
    ("remove_assign", ext1)::l ->
      begin
	match l with
	  [("useless", _)] -> execute_display_advise state (RemoveAssign Minimal)
	| [("all", _)] -> execute_display_advise state (RemoveAssign All)
	| [("binder",_); (s,ext2)] -> 
	    begin
	    try
	      let binders = find_binders state.game.proc in
	      execute_display_advise state (RemoveAssign (OneBinder (find_binder binders s)))
	    with Not_found ->
	      raise (Error("Binder " ^ s ^ " not found", ext2))
	    end
	| _ -> 
	    raise (Error("Allowed options for remove_assign are useless, all, binder x", ext1))
      end
  | ("move",ext1)::l ->
      begin
	match l with
	  [("all",_)] -> execute_display_advise state (MoveNewLet MAll)
	| [("noarrayref",_)] -> execute_display_advise state (MoveNewLet MNoArrayRef)
	| [("random",_)] -> execute_display_advise state (MoveNewLet MNew)
	| [("random_noarrayref",_)] -> execute_display_advise state (MoveNewLet MNewNoArrayRef)
	| [("assign",_)] -> execute_display_advise state (MoveNewLet MLet)
	| [("binder",_); (s,ext2)] ->
	    begin
	    try
	      let binders = find_binders state.game.proc in	      
	      execute_display_advise state (MoveNewLet (MOneBinder (find_binder binders s)))
	    with Not_found ->
	      raise (Error("Binder " ^ s ^ " not found", ext2))
	    end
	| [("array",_); (s,ext2)] ->
	    begin
	    try
	      let binders = find_binders state.game.proc in	      
	      let b = find_binder binders s in
	      if not (Proba.is_large b.btype) then
		raise (Error("Transformation \"move array\" is allowed only for large types", ext2));
 	      if (b.btype.toptions land Settings.tyopt_CHOOSABLE) == 0 then
		raise (Error("Transformation \"move array\" is allowed only for fixed types",ext2));
	      try
		let equiv = List.assq b.btype (!Transform.move_new_eq) in
		match crypto_transform true (!Settings.no_advice_crypto) equiv [b] state with
		  CSuccess state' -> state'
		| CFailure l -> 
		    raise (Error ("Transformation \"move array\" failed", ext1))
	      with Not_found ->
		raise (Error("Transformation for \"move array\" not found, perhaps the macro move_array_internal_macro is not defined in your library", ext2))
	    with Not_found ->
	      raise (Error("Binder " ^ s ^ " not found", ext2))
	    end
	| _ -> raise (Error("Allowed options for move are all, noarrayref, random, random_noarrayref, assign, and binder x", ext1))
      end
  | ["simplify",_] ->
      execute_display_advise state (Simplify [])
  | ("simplify", _) :: ("coll_elim", _) :: l ->
      execute_display_advise state (Simplify (List.map fst l))
  | [("insert_event",_); (s,ext1); (occ_s,ext2)] ->
      begin
	try
	  if String.length s = 0 then raise Not_found;
	  if (s.[0] < 'A' || s.[0] >'Z') && (s.[0] < 'a' || s.[0] > 'z') then raise Not_found;
	  for i = 1 to String.length s - 1 do
	    if s.[i] <> '\'' && s.[i] <> '_' && (s.[i] < 'A' || s.[i] >'Z') && (s.[i] < 'a' || s.[0] > 'z') && (s.[i] < '\192' || s.[i] > '\214') && (s.[i] < '\216' || s.[i] > '\246') && (s.[i] < '\248') && (s.[i] < '0' && s.[i] > '9') then raise Not_found;
	  done;
	  let occ = int_of_string occ_s in
	  execute_display_advise state (InsertEvent(s,occ))
	with 
	  Not_found ->
	    raise (Error(s ^ " should be a valid identifier: start with a letter, followed with letters, accented letters, digits, underscores, quotes", ext1))
	| Failure _ ->
	    raise (Error("occurrence " ^ occ_s ^ " should be an integer", ext2))
	| Error(mess,_) ->
	    (* Errors for insert_event always concern the occurrence *)
	    raise (Error(mess, ext2))
      end
  | ("insert",_) :: (occ_s,ext2) :: (((_, ext1)::_) as r) ->
      begin
	try
	  let ins_s = concat_strings r in
	  let occ = int_of_string occ_s in
	  execute_display_advise state (InsertInstruct(ins_s,ext1,occ,ext2))
	with Failure _ ->
	  raise (Error("occurrence " ^ occ_s ^ " should be an integer", ext2))	  
      end
  | ("replace",_) :: (occ_s,ext2) :: (((_, ext1)::_) as r) ->
      begin
	try
	  let ins_s = concat_strings r in
	  let occ = int_of_string occ_s in
	  execute_display_advise state (ReplaceTerm(ins_s,ext1,occ,ext2))
	with Failure _ ->
	  raise (Error("occurrence " ^ occ_s ^ " should be an integer", ext2))	  
      end
  | ("merge_arrays",ext) :: r ->
      begin
	let binders = find_binders state.game.proc in
	if List.length r < 2 then 
	  raise (Error("You should give at least two variables to merge", ext));
	let rec anal_r accu = function
	    [] -> [List.rev accu]
	  | (",", ext)::r ->
	      (List.rev accu) :: (anal_r [] r)
	  | (s, ext2)::r ->
	      let b = 
		try
		  (find_binder binders s, ext2)
		with Not_found ->
		  raise (Error("Binder " ^ s ^ " not found", ext2))
	      in
	      anal_r (b::accu) r
	in
	let bl = anal_r [] r in
	let fl = List.hd bl in
	if List.length fl < 2 then
	  raise (Error("You should give at least two variables to merge", ext));
	List.iter (fun al ->
	  if List.length al != List.length fl then
	    raise (Error("All lists of variables to merge should have the same length", ext))) bl;
	execute_display_advise state (MergeArrays(bl, MCreateBranchVar))
      end
  | ["merge_branches",_] ->
      execute_display_advise state MergeBranches
  | ["SArename",_;s,ext1] ->
      begin
	try
	  let binders = find_binders state.game.proc in	      
	  execute_display_advise state (SArenaming (find_binder binders s))
	with Not_found ->
	  raise (Error("Binder " ^ s ^ " not found", ext1))
      end
  | ["all_simplify",_] ->
      simplify state
  | ("crypto",ext1)::r ->
      begin
	let possible_equivs = 
	  match r with
	    [] -> !Transform.equivs
	  | (s, s_ext)::lb -> 
	      try 
		[List.nth (!Transform.equivs) (int_of_string s - 1)]
	      with 
		Failure "nth" | Invalid_argument "List.nth" ->
		  raise (Error("Equivalence number " ^ s ^ " does not exist", s_ext))
	      |	Failure _ -> 
		  List.filter (find_equiv s) (!Transform.equivs) 
	in
	match possible_equivs with
	  [] -> raise (Error("No equivalence corresponds to the one you mention", ext1))
	| [equiv] -> 
	    begin
	      match r with
		[] -> 
		  if interactive then
		    begin
		      print_string "Applying ";
		      Display.display_equiv equiv; print_newline();
		      print_string "Please enter binders mapped to restrictions for this equivalence: ";
		      let s = read_line() in
		      let lb = Str.split (Str.regexp "[ \t]+") s in
		      do_equiv ext1 equiv (List.map (fun s -> (s, dummy_ext)) lb) state
		    end
		  else
		    do_equiv ext1 equiv [] state
	      |	(_::lb) -> do_equiv ext1 equiv lb state
	    end
	| _ -> 
	    if interactive then
	      begin
		let n = ref 0 in
		List.iter (fun equiv -> incr n; print_int (!n); print_string ". "; Display.display_equiv equiv; print_newline()) possible_equivs;
		print_string "Please enter number of equivalence to consider: ";
		let s = read_line() in
		try
		  let equiv = List.nth possible_equivs (int_of_string s - 1) in
		  match r with
		    [] -> 
		      print_string "Please enter binders mapped to restrictions for this equivalence: ";
		      let s = read_line() in
		      let lb = Str.split (Str.regexp "[ \t]+") s in
		      do_equiv ext1 equiv (List.map (fun s -> (s, dummy_ext)) lb) state
		  | (_::lb) -> do_equiv ext1 equiv lb state
		with Failure _ -> 
		  raise (Error("Incorrect number", dummy_ext))
	      end
	    else
	      raise (Error("Several equivalences correspond to what you mention", ext1))
      end
  | ["quit",_] ->
      raise (End state)
  | ["success",_] ->
      let (state', is_done) = issuccess_with_advise state in
      if is_done then
	begin
	  print_string "===================== Proof starts =======================\n";
	  display_state true state';
	  print_string "All queries proved.\n";
	  if (!Settings.tex_output) <> "" then
	    Displaytex.print_string "All queries proved.\\\\\n";
	  raise (End state')
	end
      else
	begin
	  print_string "Sorry, some queries remain unproved.\n";
	  state'
	end
  | ["show_game",_] ->
      Display.display_process state.game.proc;
      state
  | [("show_game",_);("occ",_)] ->
      state.game.proc <- Terms.move_occ_process state.game.proc;
      Display.display_occurrences := true;
      Display.display_process state.game.proc;
      Display.display_occurrences := false;
      state
  | ["show_state",_] ->
      display_state false state;
      state
  | ["auto",_] ->
      begin
	try
	  let (res, state') = execute_any_crypto_rec1 state in
	  match res with
	    CFailure l -> state'
	  | CSuccess state' -> raise (End state')
	with Backtrack ->
	  print_string "Returned to same state after failure of proof with backtracking.\n";
	  state
      end
  | ["set",ext1; s,_; "=",_; v,ext2] ->
      begin
	try
	  let pval =
	    if (String.length v > 0) && ('0' <= v.[0]) && (v.[0] <= '9') then
	      Ptree.I (int_of_string v)
	    else
	      Ptree.S (v, Parsing_helper.dummy_ext)
	  in
	  Settings.do_set s pval
	with
	  Failure _ -> raise (Error("Value " ^ v ^ " is not an integer", ext2))
	| Not_found -> raise (Error("Unknown parameter or value", ext1))
      end;
      state
  | ("allowed_collisions", ext1) :: (((_, ext_s) :: _) as r) ->
      begin
	let coll_s = concat_strings r in
	let lexbuf = Lexing.from_string coll_s in
	try 
	  let coll = 
	    if (!Settings.front_end) == Settings.Channels then 
	      Parser.allowed_coll Lexer.token lexbuf
	    else
	      Oparser.allowed_coll Olexer.token lexbuf
	  in
	  Settings.allowed_collisions := [];
	  Settings.allowed_collisions_collision := [];
	  List.iter (fun (pl,topt) -> 
	    let pl' = List.map (fun (p,exp) -> (map_param p ext_s, exp)) pl in
	    match topt with
	      Some t -> Settings.allowed_collisions := (pl', map_type t ext_s) :: (!Settings.allowed_collisions)
	    | None -> Settings.allowed_collisions_collision :=  pl' :: (!Settings.allowed_collisions_collision)
		  ) coll
	with
	  Parsing.Parse_error -> raise (Error("Syntax error", Parsing_helper.combine_extent ext_s (extent lexbuf)))
	| Parsing_helper.IllegalCharacter -> raise (Error("Illegal character", Parsing_helper.combine_extent ext_s (extent lexbuf)))
      end;
      state
  | ["undo",ext] -> undo ext state 1
  | ["undo",_; s,ext1] ->
      begin
	try
	  let v = int_of_string s in
	  undo ext1 state v
	with
	  Failure _ -> 
	    raise (Error("Value " ^ s ^ " should be an integer", ext1))
      end
  | ["restart",_] ->
      let rec restart state =
	match state.prev_state with
	  None -> state
	| Some (_,_,state') -> restart state'
      in
      expand_simplify (restart state)
  | ["help",_] | ["?",_] when interactive -> help(); state
  | ["interactive",_] ->
      if interactive then 
	raise (Error("Command interactive not allowed when already in interactive mode", dummy_ext));
      begin
	match interactive_loop state with
	  CSuccess s -> s
	| _ -> Parsing_helper.internal_error "interactive_loop should return CSuccess _"
      end
  | (_,ext1)::l -> 
      if interactive then help();
      raise (Error("Unknown command", ext1))
  | [] -> 
      if interactive then 
	begin
	  help();
	  raise (Error("Unknown command", dummy_ext))
	end
      else
	Parsing_helper.internal_error "Empty command"

and interactive_loop state =
  print_string "Please enter a command: ";
  let s = read_line() in
  let l = Str.split (Str.regexp "[ \t]+") s in
  try 
    interactive_loop (interpret_command true state (List.map (fun s -> (s, dummy_ext)) l))
  with End s ->
    CSuccess s
  | Error(mess, extent) ->
      Parsing_helper.display_error mess extent;
      interactive_loop state

let rec execute_proofinfo proof state =
  match proof with
    [] -> CSuccess state
  | com::rest -> 
      try
	execute_proofinfo rest (interpret_command false state com)
      with End s ->
	CSuccess s
      |	Error(mess, extent) ->
	  Parsing_helper.input_error mess extent

let execute_any_crypto proof state =
  if (!Settings.tex_output) <> "" then
    Displaytex.start();
  let r = 
    match proof with
      Some pr -> execute_proofinfo pr (expand_simplify state)
    | None ->
	if !Settings.interactive_mode then
	  interactive_loop (expand_simplify state)
	else
	  execute_any_crypto state
  in
  if (!Settings.tex_output) <> "" then
    Displaytex.stop();
  r
