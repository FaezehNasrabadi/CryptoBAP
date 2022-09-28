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

let whole_game = ref { proc = Terms.nil_proc; game_number = -1 }

let rec check_usage_term seen_accu b t =
  match t.t_desc with
    Var(b',l) ->
      if b' == b then raise Not_found;
      List.iter (check_usage_term seen_accu b) l
  | FunApp(f,l) ->
      List.iter (check_usage_term seen_accu b) l
  | TestE(t1,t2,t3) ->
      check_usage_term seen_accu b t1;
      check_usage_term seen_accu b t2;
      check_usage_term seen_accu b t3
  | FindE(l0,t3,_) ->
      List.iter (fun (bl,def_list,t1,t2) ->
	List.iter (fun (_,l) -> List.iter (check_usage_term seen_accu b) l) def_list;
	check_usage_term seen_accu b t1;
	check_usage_term seen_accu b t2) l0;
      check_usage_term seen_accu b t3
  | LetE(PatVar b', { t_desc = Var(b'',l) }, t2, _) when b'' == b ->
      if not (List.memq b' (!seen_accu)) then
	begin
	  seen_accu := b' :: (!seen_accu);
	  try
	    check_usage_process seen_accu b' (!whole_game).proc
	  with Not_found ->
	    if List.length b'.def > 1 then
	      Transform.advise := Terms.add_eq (SArenaming b') (!Transform.advise);
	    raise Not_found
	end;
      List.iter (check_usage_term seen_accu b) l;
      check_usage_term seen_accu b t2
  | LetE(pat, t1, t2, topt) ->
      begin
	check_usage_pat seen_accu b pat;
	check_usage_term seen_accu b t1;
	check_usage_term seen_accu b t2;
	match topt with
	  None -> ()
	| Some t3 -> check_usage_term seen_accu b t3
      end
  | ResE(b,t) ->
      check_usage_term seen_accu b t
  | EventE _ ->
      Parsing_helper.internal_error "Event should have been expanded"
      
and check_usage_pat seen_accu b = function
    PatVar _ -> ()
  | PatTuple (f,l) -> List.iter (check_usage_pat seen_accu b) l
  | PatEqual t -> check_usage_term seen_accu b t

and check_usage_process seen_accu b p =
  match p.i_desc with
    Nil -> ()
  | Par(p1,p2) -> 
      check_usage_process seen_accu b p1;
      check_usage_process seen_accu b p2
  | Repl(_,p) ->
      check_usage_process seen_accu b p
  | Input((c, tl), pat, p) ->
      List.iter (check_usage_term seen_accu b) tl;
      check_usage_pat seen_accu b pat;
      check_usage_oprocess seen_accu b p

and check_usage_oprocess seen_accu b p =
  match p.p_desc with
    Yield -> ()
  | Restr(_,p) ->
      check_usage_oprocess seen_accu b p
  | Test(t,p1,p2) ->
      check_usage_term seen_accu b t;
      check_usage_oprocess seen_accu b p1;
      check_usage_oprocess seen_accu b p2
  | Find(l0,p2,_) ->
      List.iter (fun (bl,def_list, t, p1) ->
	List.iter (fun (_,l) -> List.iter (check_usage_term seen_accu b) l) def_list;
	check_usage_term seen_accu b t;
	check_usage_oprocess seen_accu b p1) l0;
      check_usage_oprocess seen_accu b p2
  | Let(PatVar b', { t_desc = Var(b'',l) }, p1, _) when b'' == b ->
      if not (List.memq b' (!seen_accu)) then
	begin
	  seen_accu := b' :: (!seen_accu);
	  try
	    check_usage_process seen_accu b' (!whole_game).proc
	  with Not_found ->
	    if List.length b'.def > 1 then
	      Transform.advise := Terms.add_eq (SArenaming b') (!Transform.advise);
	    raise Not_found
	end;
      List.iter (check_usage_term seen_accu b) l;
      check_usage_oprocess seen_accu b p1
  | Let(pat,t,p1,p2) ->
      check_usage_pat seen_accu b pat;
      check_usage_term seen_accu b t;
      check_usage_oprocess seen_accu b p1;
      check_usage_oprocess seen_accu b p2
  | Output((c, tl),t2,p) ->
      List.iter (check_usage_term seen_accu b) tl;
      check_usage_term seen_accu b t2;
      check_usage_process seen_accu b p
  | EventP(t,p) ->
      (* Events are ignored when checking secrecy
	 This assumes that LetE/FindE have been expanded, so that
	 they do not occur in t *)
      check_usage_oprocess seen_accu b p

let has_assign b =
  List.exists (fun def ->
    match def.definition with
      DProcess { p_desc = Let _ } | DTerm { t_desc = LetE _} -> true
    | _ -> false) b.def



let check_secrecy b =
  let ty = ref None in
  let r = 
    List.for_all (fun d -> 
      match d.definition with
	DProcess { p_desc = Let(PatVar _,{ t_desc = Var(b',_) },_,_) }
      |	DTerm { t_desc = LetE(PatVar _, { t_desc = Var(b',_) },_,_) } ->
	  if has_assign b' then
	    begin
	      Transform.advise := Terms.add_eq (RemoveAssign (OneBinder b')) (!Transform.advise);
	      false
	    end
	  else if Terms.is_restr b' then
	    begin
	      (match !ty with
		None -> ty := Some b'.btype; true
	      |	Some ty' -> ty' == b'.btype) && (
	      try
		check_usage_process (ref [b']) b' (!whole_game).proc;
		true
	      with Not_found ->
		if List.length b'.def > 1 then
		  Transform.advise := Terms.add_eq (SArenaming b') (!Transform.advise);
		false)
	    end
	  else
	    false
      |	DProcess { p_desc = Restr _ } ->
	  (match !ty with
	    None -> ty := Some b.btype; true
	  | Some ty' -> ty' == b.btype) && 
	  begin
	    try
	      check_usage_process (ref [b]) b (!whole_game).proc;
	      true
	    with Not_found ->
	      false
	  end
      |	_ ->
	  false) b.def
  in
  if r then
    begin
      print_string "Proved one-session secrecy of ";
      Display.display_binder b;
      print_newline()
    end;
  r

let check_query simplify_internal_info = function
    (QSecret1 b,_) -> (check_secrecy b, [])
  | (QSecret b,_) -> 
      let r1 = check_secrecy b in
      if r1 then
	let (r2, proba) = Facts.check_distinct b simplify_internal_info (!whole_game) in
	if r2 then
	  begin
	    print_string "Proved secrecy of ";
	    Display.display_binder b;
	    if proba != [] then
	      begin
		print_string " Probability: ";
		Display.display_set proba
	      end;
	    print_newline();
	    (true, proba)
	  end
	else (false, [])
      else (false, [])
  | (QEventQ(t1,t2),gn) ->
      let (r, proba) = Facts.check_corresp (t1,t2) simplify_internal_info (!whole_game) in
      if r then
	begin
	  print_string "Proved query ";
	  Display.display_query (QEventQ(t1,t2),gn);
	  if proba != [] then
	    begin
	      print_string " Probability: ";
	      Display.display_set proba
	    end;
	  print_newline();
	  (true, proba)
	end
      else (false, [])
  | (AbsentQuery,_) -> (false, [])	

let rec check_query_list simplify_internal_info = function
    [] -> ([],[])
  | (a::l) ->
      let (l',l'') = check_query_list simplify_internal_info l in
      let (res, proba) = check_query simplify_internal_info a in
      if res then ((a,proba)::l', l'') else (l', a::l'')

let is_success simplify_internal_info g = 
  whole_game := g;
  Terms.build_def_process None g.proc;
  let (proved_queries, rem_queries) =
    check_query_list simplify_internal_info (!Transform.queries)
  in
  Transform.queries := rem_queries; (* Queries still to prove *)
  proved_queries, (rem_queries == [])


      

	  
