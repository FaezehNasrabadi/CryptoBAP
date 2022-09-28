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


(* Check that array references are suitably defined *)

(* - First pass: build tree of definition dependances. See terms.ml *)

(* - Second pass: check array references 
     The verification routine takes as argument the references that 
     are surely defined at the current point. *)

let rec check_def_term defined_refs t =
  match t.t_desc with
    Var(b,l) ->
      if not (List.exists (Terms.equal_binderref (b,l)) defined_refs) then
	begin
	  print_string "Subterm ";
	  Display.display_term [] t;
	  print_newline();
	  Parsing_helper.input_error "Variable reference not defined" t.t_loc
	end;
      List.iter (check_def_term defined_refs) l
  | FunApp(f,l) ->
      List.iter (check_def_term defined_refs) l
  | TestE(t1,t2,t3) ->
      check_def_term defined_refs t1;
      check_def_term defined_refs t2;
      check_def_term defined_refs t3
  | LetE(pat, t1, t2, topt) ->
      check_def_term defined_refs t1;
      let accu = ref defined_refs in
      check_def_pat accu defined_refs pat;
      check_def_term (!accu) t2;
      begin
	match topt with
	  None -> ()
	| Some t3 -> check_def_term defined_refs t3
      end
  | FindE(l0,t3,_) ->
      List.iter (fun (bl,def_list,t1,t2) ->
	let accu = ref ((List.map (fun b -> (b, b.args_at_creation)) bl) @ defined_refs) in
	List.iter (Terms.close_def_subterm accu) def_list;
	let defined_refs' = !accu in
	check_def_term defined_refs' t1;
	check_def_term defined_refs' t2) l0;
      check_def_term defined_refs t3
  | ResE(b,t) ->
      check_def_term ((b,b.args_at_creation)::defined_refs) t
  | EventE(t) ->
      check_def_term defined_refs t

and check_def_pat accu defined_refs = function
    PatVar b -> accu := (b, b.args_at_creation) :: (!accu)
  | PatTuple (f,l) ->
      List.iter (check_def_pat accu defined_refs) l
  | PatEqual t -> check_def_term defined_refs t

let rec check_def_process defined_refs p =
  match p.i_desc with
    Nil -> ()
  | Par(p1,p2) -> 
      check_def_process defined_refs p1;
      check_def_process defined_refs p2
  | Repl(b,p) ->
      check_def_process ((b,b.args_at_creation)::defined_refs) p
  | Input((c,tl),pat,p) ->
      List.iter (check_def_term defined_refs) tl;
      let accu = ref defined_refs in
      check_def_pat accu defined_refs pat;
      check_def_oprocess (!accu) p

and check_def_oprocess defined_refs p = 
  match p.p_desc with
    Yield -> ()
  | Restr(b,p) ->
      check_def_oprocess ((b,b.args_at_creation)::defined_refs) p
  | Test(t,p1,p2) ->
      check_def_term defined_refs t;
      check_def_oprocess defined_refs p1;
      check_def_oprocess defined_refs p2
  | Find(l0,p2,_) ->
      List.iter (fun (bl,def_list,t,p1) ->
	let accu' = ref ((List.map (fun b -> (b, b.args_at_creation)) bl) @ defined_refs) in
	List.iter (Terms.close_def_subterm accu') def_list;
	let defined_refs' = !accu' in
	check_def_term defined_refs' t;
	check_def_oprocess defined_refs' p1) l0;
      check_def_oprocess defined_refs p2
  | Output((c,tl),t2,p) ->
      List.iter (check_def_term defined_refs) tl;
      check_def_term defined_refs t2;
      check_def_process defined_refs p
  | Let(pat,t,p1,p2) ->
      check_def_term defined_refs t;
      let accu = ref defined_refs in
      check_def_pat accu defined_refs pat;
      check_def_oprocess (!accu) p1;
      check_def_oprocess defined_refs p2
  | EventP(t,p) ->
      check_def_term defined_refs t;
      check_def_oprocess defined_refs p

(* - Main checking function for processes *)

let check_def_process_main p =
  Terms.build_def_process None p;
  check_def_process [] p

(* - Main checking function for equivalence statements *)

let rec build_def_fungroup above_node = function
    ReplRestr(repl, restr, funlist) ->
      let above_node1 = { above_node = above_node; binders = [repl]; 
			  true_facts_at_def = []; def_vars_at_def = [];
			  elsefind_facts_at_def = [];
			  future_binders = []; future_true_facts = [];
			  future_def_vars = [];
			  definition = DFunRepl } 
      in
      repl.def <- above_node1 :: repl.def;
      let above_node2 = { above_node = above_node1; 
			  binders = List.map fst restr; 
			  true_facts_at_def = []; def_vars_at_def = [];
			  elsefind_facts_at_def = [];
			  future_binders = []; future_true_facts = [];
			  future_def_vars = [];
			  definition = DFunRestr } 
      in
      List.iter (fun (b,_) -> b.def <- above_node2 :: b.def) restr;
      List.iter (build_def_fungroup above_node2) funlist
  | Fun(ch, args, res, priority) ->
    let above_node1 = { above_node = above_node; binders = args; 
			true_facts_at_def = []; def_vars_at_def = [];
			elsefind_facts_at_def = [];
			future_binders = []; future_true_facts = [];
			future_def_vars = [];
			definition = DFunArgs } 
    in
    List.iter (fun b -> b.def <- above_node1 :: b.def) args;
    ignore(Terms.def_term above_node1 [] [] res)

let array_index_args args =
  List.filter (fun b -> match b.btype.tcat with
    Interv _ -> true
  | BitString -> false) args


(* Check that, when there is a common index, all following indices 
   are common too. Note that, since each replication has a different
   bound, typing guarantees that, if there is a common index, then
   this common index is at the same position. *)
let check_common_index (b,l) (b',l') =
  let lenl = List.length l in
  let lenl' = List.length l' in
  let minl = min lenl lenl' in
  let sufl = Terms.skip (lenl-minl) l in
  let sufl' = Terms.skip (lenl'-minl) l' in
  let rec check_common l1 l2 = 
    match l1,l2 with
      [],[] -> ()
    | a1::r1,a2::r2 -> 
	if Terms.equal_terms a1 a2 then 
	  begin
	    Parsing_helper.input_error "This array index is used in another array reference and this is not supported yet" a1.t_loc
	    (* TO DO The line above could be replaced by the next code, which
	       is more permissive. However, cryptotransf.ml does not support yet
	       array references that share arguments.
	       See TO DO in cryptotransf.ml, function check_lhs_array_ref.
	    if not (List.for_all2 Terms.equal_terms r1 r2) then
	      Parsing_helper.input_error "This array index is used elsewhere and the following indices are not the same in all usages" a1.t_loc
		*)
	  end
	else
	  check_common r1 r2
    | _ -> Parsing_helper.internal_error "check_common_index: I should have extracted suffixes of the same length" 
  in
  check_common sufl sufl'

let rec get_arg_array_ref index_args accu t = 
  match t.t_desc with
    Var(b,l) ->
      if List.exists 
	  (function { t_desc = Var(b',l') } when List.memq b' index_args -> true
	    | _ -> false) l then
	(* This is an array reference with an argument as index.
           Check that it is correct *)
	if List.exists (Terms.equal_binderref (b,l)) (!accu) then
	  (* Already found before and was ok, so it's ok *)
	  ()
	else
	  let rec check_ok l args_at_creation =
	    match l, args_at_creation with
	      [],[] -> ()
	    | (l1::lr, c1::cr) ->
		begin
		  if Terms.equal_terms l1 c1 then
		    begin
		      Parsing_helper.input_error "Incorrect array reference: contains an argument of the function, but also implicitly refers to some current replication indices, and this is not supported yet" t.t_loc
		      (* TO DO The line above could be replaced by the next code, which
			 is more permissive. However, cryptotransf.ml does not support yet
			 array references with a part that consists of replication indices
			 and another part consisting of arguments of the function.
			 See TO DO in cryptotransf.ml, function check_lhs_array_ref.
		      if not (List.for_all2 Terms.equal_terms l args_at_creation) then
			Parsing_helper.input_error "Incorrect array reference" t.t_loc
			  *)
		    end
		  else
		    match l1.t_desc with
		      Var(b',l') ->
			if not (List.memq b' index_args) then
			  Parsing_helper.input_error "Incorrect array reference: argument of the function expected as index" t.t_loc;
			if not (List.for_all2 Terms.equal_terms l' b'.args_at_creation) then
			  Parsing_helper.input_error "Incorrect array reference: argument index should have no indices" l1.t_loc;
			if not (Terms.is_restr b) then
			  Parsing_helper.input_error "Only restrictions are allowed to take arguments as indices" t.t_loc;
			check_ok lr cr
		    | _ ->  Parsing_helper.input_error "Variable expected as index in array reference" t.t_loc
		end
	    | _ -> Parsing_helper.input_error "Bad number of indices in array reference" t.t_loc
	  in
	  check_ok l b.args_at_creation;
	  List.iter (check_common_index (b,l)) (!accu);
	  accu := (b,l) :: (!accu)
      else
	List.iter (get_arg_array_ref index_args accu) l
  | FunApp(f,l) -> 
      List.iter (get_arg_array_ref index_args accu) l
  | TestE(t1,t2,t3) ->
      get_arg_array_ref index_args accu t1;
      get_arg_array_ref index_args accu t2;
      get_arg_array_ref index_args accu t3
  | LetE(pat, t1, t2, topt) ->
      get_arg_array_ref index_args accu t1;
      get_arg_array_ref_pat index_args accu pat;
      get_arg_array_ref index_args accu t2;
      begin
	match topt with
	  None -> ()
	| Some t3 -> get_arg_array_ref index_args accu t3
      end
  | FindE(l0,t3,_) ->
      List.iter (fun (bl,def_list,t1,t2) ->
	List.iter (fun (_,l) -> List.iter (get_arg_array_ref index_args accu) l) def_list;
	get_arg_array_ref index_args accu t1;
	get_arg_array_ref index_args accu t2) l0;
      get_arg_array_ref index_args accu t3
  | ResE(b,t) ->
      get_arg_array_ref index_args accu t
  | EventE(t) ->
      get_arg_array_ref index_args accu t

and get_arg_array_ref_pat index_args accu = function
    PatVar b -> ()
  | PatTuple (f,l) ->
      List.iter (get_arg_array_ref_pat index_args accu) l
  | PatEqual t -> get_arg_array_ref index_args accu t
    

let rec check_def_fungroup def_refs = function
    ReplRestr(repl, restr, funlist) ->
      List.iter (check_def_fungroup ((repl, repl.args_at_creation) :: (List.map (fun (b,_) -> (b, b.args_at_creation)) restr) @ def_refs)) funlist
  | Fun(ch, args, res, priority) ->
      let index_args = array_index_args args in
      let array_ref_args = ref [] in
      get_arg_array_ref index_args array_ref_args res;
      check_def_term ((List.map (fun b -> (b, b.args_at_creation)) args) @ (!array_ref_args) @ def_refs) res

let check_def_member l =
  let rec st_node = { above_node = st_node; binders = []; 
		      true_facts_at_def = []; def_vars_at_def = [];
		      elsefind_facts_at_def = [];
		      future_binders = []; future_true_facts = [];
		      future_def_vars = [];
		      definition = DNone } 
  in
  List.iter (fun (fg, mode) -> build_def_fungroup st_node fg) l;
  List.iter (fun (fg, mode) -> check_def_fungroup [] fg) l

let check_def_eqstatement (lm,rm,_,_,_) =
  check_def_member lm;
  check_def_member rm


(* Check and simplify the left member of equivalence statements *)

let rec check_lm_term t = 
  match t.t_desc with
    Var(b, l) -> 
      (* Now, array references are allowed, with indices given as argument to the oracle
      if not (List.for_all2 Terms.equal_terms l b.args_at_creation) then
	Parsing_helper.input_error "Array references forbidden in left member of equivalences" t.t_loc;
      *)
      begin
      match b.link with
	TLink t -> check_lm_term t
      |	NoLink -> t
      end 
  | FunApp(f,l) ->
      Terms.build_term2 t (FunApp(f, List.map check_lm_term l))
  | LetE(PatVar b,t,t1,_) ->
      if Terms.refers_to b t then
	Parsing_helper.input_error "Cyclic assignment in left member of equivalence" t.t_loc;
      Terms.link b (TLink t);
      check_lm_term t1
  | LetE _ ->
      Parsing_helper.input_error "let with non-variable patterns forbidden in left member of equivalences" t.t_loc
  | (TestE _ | FindE _ | ResE _ | EventE _) ->
      Parsing_helper.input_error "if, find, new and event forbidden in left member of equivalences" t.t_loc

let rec check_lm_fungroup = function
    ReplRestr(repl, restr, funlist) ->
      let funlist' = List.map check_lm_fungroup funlist in
      ReplRestr(repl, restr, funlist')
  | Fun(ch, args, res, priority) ->
      let res' = check_lm_term res in
      Terms.cleanup();
      Fun(ch, args, res', priority)


(* Check and simplify the right member of equivalences 
   NOTE: It is important that is called after check_def_eqstatement 
   on this equivalence, so that the definition nodes of variables
   have been computed. *)

let rec close_node accu n l =
  List.iter (fun b' ->
    let l' = Terms.skip ((List.length l) - (List.length b'.args_at_creation)) l in
    accu := ((b',l'))::(!accu)
      ) n.binders;
  if n.above_node != n then
    close_node accu n.above_node l

let close_def accu (b,l) =
  match b.def with
    [n] -> close_node accu n l
  | _ -> Parsing_helper.internal_error "close_def: binder has several definitions"

(*
let same_binders l1 l2 =
  List.for_all2 (fun b t ->
    match t.t_desc with
      Var(b'',l') when b'' == b -> true
    | _ -> false) l1 l2
*)

let rec check_rm_term allowed_index_seq t =
  match t.t_desc with
    Var(b,l) ->
      Terms.build_term2 t (Var(b, List.map (check_rm_term allowed_index_seq) l))
  | FunApp(f,l) ->
      Terms.build_term2 t (FunApp(f, List.map (check_rm_term allowed_index_seq) l))
  | LetE(pat,t1,t2,topt) ->
      Terms.build_term2 t (LetE(check_rm_pat allowed_index_seq pat,
		      check_rm_term allowed_index_seq t1,
		      check_rm_term allowed_index_seq t2,
		      begin
			match topt with
			  None -> None
			| Some t3 -> Some(check_rm_term allowed_index_seq t3)
		      end))
  | ResE(b,t') ->
      Terms.build_term2 t (ResE(b, check_rm_term allowed_index_seq t'))
  | TestE(t1,t2,t3) ->
      Terms.build_term2 t (TestE(check_rm_term allowed_index_seq t1,
		       check_rm_term allowed_index_seq t2,
		       check_rm_term allowed_index_seq t3))
  | FindE(l0, t3, find_info) ->
      Terms.build_term2 t (FindE(
	List.map (function 
	   (* ([], _, _, _, _) -> Parsing_helper.user_error "Find in right member of equivalences should bind at least one index\n"
	  | *) (lindex, def_list, t1, t2) ->
	    (* Variables in def_list should have a particular form of indexes: 
	         a suffix of lindex + the same suffix of a sequence in allowed_index_seq
	       At least one of these variables should use the full lindex.
	       Furthermore, a single reference in def_list should imply that all other
	       references are defined. This implies that the same find cannot reference
	       variables defined in different functions under the same replication
	       (which simplifies the code of cryptotransf.ml).
	       *)
	      let max_sequence = ref [] in
	      List.iter (fun ((_,l) as def) ->
		let def_closure = ref [] in
		close_def def_closure def;
		if List.for_all (fun def' -> List.exists (Terms.equal_binderref def') (!def_closure)) def_list then
		  max_sequence := l
			 ) def_list;
	      if !max_sequence == [] then
		Parsing_helper.input_error "In equivalences, in find, one \"defined\" variable reference should imply all others" t.t_loc;
	      
	      let l1 = !max_sequence in
	      let l1_binders = List.map (function
		  { t_desc = Var(b,_) } -> b
		| _ -> Parsing_helper.input_error "In equivalences, find ... suchthat defined(x[l],...): terms in l should be variables." t.t_loc) l1
	      in
	      let l_index = List.length lindex in
	      let l_other_seq_suffix = List.length l1 - l_index in
	      if List.length l1_binders < l_index then
		Parsing_helper.input_error "Variables in right member of equivalences should have as indexes the indexes defined by find" t.t_loc;
	      let (lindex_maxseq, other_seq_suffix) = Terms.split l_index l1_binders in
	      if not (List.for_all2 (==) lindex lindex_maxseq) then
		Parsing_helper.input_error "Variables in right member of equivalences should have as indexes the indexes defined by find" t.t_loc;
	      if not (List.exists (fun seq ->
		let suffix = Terms.skip (List.length seq - l_other_seq_suffix) seq in
		List.for_all2 (==) suffix other_seq_suffix) allowed_index_seq) then
		Parsing_helper.input_error "Variables in right member of equivalences should have as indexes the indexes defined by find" t.t_loc;
	      let allowed_index_seq' = (*Commented out to simplify the indexes: allowed_index_seq is now only [cur_array]. 
					 This makes the transformation simpler, but a bit less powerful.
					   l1_binders :: *)allowed_index_seq in
	      List.iter (fun (b',l) ->
		if List.length l < l_other_seq_suffix then
		  Parsing_helper.input_error "Variables in right member of equivalences should have as indexes the indexes defined by find" t.t_loc
		    ) def_list;
	      let t1' = check_rm_term allowed_index_seq' t1 in
	      let t2' = check_rm_term allowed_index_seq' t2 in
	      (lindex, def_list, t1', t2')
		) l0,
	check_rm_term allowed_index_seq t3, find_info))
  | EventE(t') ->
      Terms.build_term2 t (EventE(check_rm_term allowed_index_seq t'))

and check_rm_pat allowed_index_seq = function
    PatVar b -> PatVar b
  | PatTuple (f,l) -> PatTuple (f,List.map (check_rm_pat allowed_index_seq) l)
  | PatEqual t -> PatEqual (check_rm_term allowed_index_seq t)

let rec check_rm_fungroup cur_array = function
    ReplRestr(repl, restr, funlist) ->
      ReplRestr(repl, restr, List.map (check_rm_fungroup (repl::cur_array)) funlist)
  | Fun(ch, args, res, priority) ->
      let res = check_rm_term [cur_array] res in
      let rec make_lets body = function
	  [] -> ([], body)
	| (b::l) -> 
	    let (b_inputs', body') = make_lets body l in
	    if Terms.has_array_ref b then
	      let b' = Terms.new_binder b in
	      (b'::b_inputs', 
	       Terms.build_term_type body'.t_type (LetE(PatVar b, 
			       Terms.term_from_binderref (b',List.map Terms.term_from_binder cur_array),
			       body', None)))
	    else
	      (b::b_inputs', body')
      in
      let (args', res') = make_lets res args in
      Fun(ch, args', res', priority)

(* When there is a name just above a function in the left-hand side,
   the corresponding function in the right-hand side must not contain
   new names (in the term), for the crypto transformation to be correct
   as it is implemented. So we move the names in the sequence of names
   just above the function in the right-hand side. *)

let rec move_names_term add_names corresp_list t =
  match t.t_desc with
    Var(b,l) ->
      Terms.build_term2 t (Var(b, List.map (move_names_term add_names corresp_list) l))
  | FunApp(f,l) ->
      Terms.build_term2 t (FunApp(f, List.map (move_names_term add_names corresp_list) l))
  | ResE(b,t1) ->
      let t' = move_names_term add_names corresp_list t1 in
      add_names := b::(!add_names);
      if b.root_def_std_ref || b.root_def_array_ref then
	let b' = Terms.new_binder b in
	corresp_list := (b,b')::(!corresp_list);
	Terms.build_term2 t (LetE(PatVar b', Terms.cst_for_type b.btype  , t', None))
      else
	t'
  | LetE(pat, t1, t2, topt) ->
      Terms.build_term2 t (LetE(move_names_pat add_names corresp_list pat,
		      move_names_term add_names corresp_list t1,
		      move_names_term add_names corresp_list t2,
		      match topt with
			None -> None
		      |	Some t3 -> Some (move_names_term add_names corresp_list t3)))
  | FindE(l0, t3, find_info) ->
      let move_br (b,l) = (b, List.map (move_names_term add_names corresp_list) l) in
      Terms.build_term2 t (FindE(List.map (fun (bl, def_list, t1, t2) ->
	(bl, 
	 List.map move_br def_list, 
	 move_names_term add_names corresp_list t1, 
	 move_names_term add_names corresp_list t2)) l0, 
		       move_names_term add_names corresp_list t3, find_info))
  | TestE(t1,t2,t3) ->
      Terms.build_term2 t (TestE(move_names_term add_names corresp_list t1,
		       move_names_term add_names corresp_list t2,
		       move_names_term add_names corresp_list t3))
  | EventE(t1) ->
      Terms.build_term2 t (EventE(move_names_term add_names corresp_list t1))

and move_names_pat add_names corresp_list = function
    PatVar b -> PatVar b
  | PatTuple(f,l) -> PatTuple(f, List.map (move_names_pat add_names corresp_list) l)
  | PatEqual t -> PatEqual (move_names_term add_names corresp_list t)

let rec move_names corresp_list lm_name_above lm_fungroup rm_fungroup =
  match (lm_fungroup, rm_fungroup) with
    (ReplRestr(_, restr, funlist), ReplRestr(repl', restr', funlist')) ->
      let (add_names, funlist'') = move_names_list corresp_list (restr != []) funlist funlist' in
      ([], ReplRestr(repl', (List.map (fun b -> (b, NoOpt)) add_names) @ restr', funlist''))
  | (Fun(_,_,_,_), Fun(ch',args', res', priority')) ->
      if lm_name_above then
	let add_names = ref [] in
	let res'' = move_names_term add_names corresp_list res' in
	(!add_names, Fun(ch', args', res'', priority'))
      else
	([], rm_fungroup)
  | _ -> Parsing_helper.internal_error "Structures of left- and right-hand sides of an equivalence must be the same"

and move_names_list corresp_list lm_name_above lm rm =
  match (lm,rm) with
    [],[] -> ([], [])
  | (lm1::lmr),(rm1::rmr) -> 
      let (add_names1, rm1') = move_names corresp_list lm_name_above lm1 rm1 in
      let (add_namesr, rmr') = move_names_list corresp_list lm_name_above lmr rmr in
      (add_names1 @ add_namesr, rm1'::rmr')
  | _ -> Parsing_helper.internal_error "Structures of left- and right-hand sides of an equivalence must be the same"

let rec update_def_list_term corresp_list t =
  Terms.build_term2 t 
     (match t.t_desc with
	Var(b,l) ->
	  Var(b, List.map (update_def_list_term corresp_list) l)
      | FunApp(f,l) ->
	  FunApp(f, List.map (update_def_list_term corresp_list) l)
      | ResE(b,t) ->
	  ResE(b, update_def_list_term corresp_list t)
      | LetE(pat, t1, t2, topt) ->
	  LetE(update_def_list_pat corresp_list pat,
	       update_def_list_term corresp_list t1,
	       update_def_list_term corresp_list t2,
	       match topt with
		 None -> None
	       | Some t3 -> Some (update_def_list_term corresp_list t3))
      | FindE(l0, t3, find_info) ->
	  FindE(List.map (fun (bl, def_list, t1, t2) ->
	    let def_list_subterms = ref [] in
	    List.iter (fun (b,l) -> 
	      Terms.add_binderref (b,l) def_list_subterms;
	      List.iter (Terms.get_deflist_subterms def_list_subterms) l) def_list;
	    let add_def_list = ref def_list in
	    List.iter (fun (b,l) ->
	      try
		add_def_list := (List.assq b corresp_list, l) :: (!add_def_list)
	      with Not_found -> ()) (!def_list_subterms);
	    (bl, 
	     (!add_def_list), 
	     update_def_list_term corresp_list t1, 
	     update_def_list_term corresp_list t2)) l0, 
		update_def_list_term corresp_list t3, find_info)
      | TestE(t1,t2,t3) ->
	  TestE(update_def_list_term corresp_list t1,
		update_def_list_term corresp_list t2,
		update_def_list_term corresp_list t3)
      |	EventE(t1) ->
	  EventE(update_def_list_term corresp_list t1))

and update_def_list_pat corresp_list = function
    PatVar b -> PatVar b
  | PatTuple(f,l) -> PatTuple(f, List.map (update_def_list_pat corresp_list) l)
  | PatEqual t -> PatEqual (update_def_list_term corresp_list t)
    

let rec update_def_list corresp_list = function
    ReplRestr(repl, restr, fungroup) ->
      ReplRestr(repl, restr, List.map (update_def_list corresp_list) fungroup)
  | Fun(ch, args, res, priority) ->
      Fun(ch, args, update_def_list_term corresp_list res, priority)
	
let move_names_all lmg rmg =
  let corresp_list = ref [] in
  let rmg' = 
    List.map2 (fun (lm,_) (rm, mode) ->
      let (_, rm') = move_names corresp_list false lm rm in
      (rm', mode)) lmg rmg
  in
  List.map (fun (rm, mode) -> (update_def_list (!corresp_list) rm, mode)) rmg'


(* Define a mapping between restrictions in the right-hand side and 
   restrictions in the left-hand side, such that, if a name is used in
   a certain function in the right-hand side, then the corresponding
   name is also used in the corresponding function in the left-hand side. *)

(* uses b0 t is true when the term t uses the variable b0 *)

let rec uses b0 t = 
  match t.t_desc with
    Var (b,l) -> 
      ((b == b0) && (List.for_all2 Terms.equal_terms l b.args_at_creation)) || 
      (List.exists (uses b0) l)
  | FunApp(f,l) -> List.exists (uses b0) l
  | TestE(t1,t2,t3) -> (uses b0 t1) || (uses b0 t2) || (uses b0 t3)
  | ResE(b,t) -> uses b0 t
  | FindE(l0,t3, _) -> 
      (List.exists (fun (bl,def_list,t1,t2) ->
	(uses b0 t1) || (uses b0 t2)) l0) || 
      (uses b0 t3)
  | LetE(pat, t1, t2, topt) ->
      (uses_pat b0 pat) ||
      (uses b0 t1) || (uses b0 t2) ||
      (match topt with
	None -> false
      |	Some t3 -> uses b0 t3)
  | EventE(t) -> uses b0 t

and uses_pat b0 = function
    PatVar b -> false
  | PatTuple (f,l) -> List.exists (uses_pat b0) l
  | PatEqual t -> uses b0 t 


exception NotCorresp

let rec check_corresp_uses b b' accu funlist funlist' =
  match funlist, funlist' with
    (ReplRestr(_, _, funlist), ReplRestr(_, _, funlist')) ->
       List.fold_left2 (check_corresp_uses b b') accu funlist funlist'
  | (Fun (_,args,res,_), Fun (_,args',res',_)) -> 
      (* For references to b/b' without explicit indices *)
      let accu' = 
	if uses b' res' then 
	  if uses b res then accu else res::accu
	else accu
      in
      (* For references to b/b' with indices taken in arguments *)
      let index_args = array_index_args args in
      let array_ref_args = ref [] in
      get_arg_array_ref index_args array_ref_args res;
      let index_args' = array_index_args args' in
      let array_ref_args' = ref [] in
      get_arg_array_ref index_args' array_ref_args' res';
      let args_map = List.combine args' args in
      List.iter (fun (b'',l') -> 
	if b'' == b' then
	  (* b'[l'] used in res' *)
	  let l = List.map (function
	      { t_desc = Var(i,_) } -> 
		Terms.term_from_binder (List.assq i args_map)
	    | _ -> 
		Parsing_helper.internal_error "Variable expected as index") l'
	  in
	  (* Check if b[l] is used in res *)
	  if not (List.exists (Terms.equal_binderref (b,l)) (!array_ref_args)) then
	    (* I do not allow array accesses in the RHS that do not correspond to array accesses
	       in the LHS. If I wanted to allow that, I should complete the correspondence between
	       names also for array accesses, by extending complete_env in cryptotransf.ml *)
	    raise NotCorresp
	      ) (!array_ref_args');
      accu'

  | _ -> Parsing_helper.internal_error "Structures of left- and right-hand sides of an equivalence must be the same"

let find_assoc restr funlist b' bopt' funlist' =
  try
    let (b,_) = List.find (fun (b,_) ->
      (b.sname = b'.sname) &&
      (b.vname == b'.vname) &&
      (b.btype == b'.btype) &&
      bopt' == Unchanged) restr 
    in
    (* b' is marked "unchanged"; a restriction with the same name 
       exists in the left-hand side.
       Try to associate it with b'; check that all functions that
       use b' in the right-hand side also use b' in the left-hand side.
       If this is not the case, we add some elements in "def_check"
       (the second element of the pair, result of find_assoc,
       which will end up as third element of the name mapping) *)
    try
      let def_check = List.fold_left2 (check_corresp_uses b b') [] funlist funlist' in
      (b, def_check)
    with NotCorresp ->
      Parsing_helper.user_error (b.sname ^ " in the left-hand side does not correspond to " ^ b'.sname ^ " in the right-hand side, because there is an array access in the right-hand side that does not match the one in the left-hand side")
  with Not_found -> 
    let rec find_min_def_check = function
	[] -> Parsing_helper.internal_error "should have at least one restriction in Check.find_assoc"
      |	[(b,_)] ->
	  begin
	    try 
	      (b, List.fold_left2 (check_corresp_uses b b') [] funlist funlist')
	    with NotCorresp ->
	      Parsing_helper.user_error (b'.sname ^ " in the right-hand side corresponds to no variable in the left-hand side, because there is an array access in the right-hand side that does not match one in the left-hand side")
	  end
      |	((b,_)::l) ->
	  try
	    let defcheck_cur = List.fold_left2 (check_corresp_uses b b') [] funlist funlist' in
	    if defcheck_cur == [] then (b, defcheck_cur) else
	    let (btmp, defchecktmp) = find_min_def_check l in
	    if List.length defcheck_cur <= List.length defchecktmp then
	      (b, defcheck_cur)
	    else
	      (btmp, defchecktmp)
	  with NotCorresp -> 
	    find_min_def_check l
    in
    find_min_def_check restr
      

let rec build_restr_mapping_fungroup restr_mapping lm rm =
  match lm, rm with
    (ReplRestr(_, restr, funlist), ReplRestr(_, restr', funlist')) ->
      List.iter2 (build_restr_mapping_fungroup restr_mapping) funlist funlist';
      if restr = [] then
	()
      else
	List.iter (fun (b',bopt') ->
	  let (b, def_check) = find_assoc restr funlist b' bopt' funlist' in
	  (* print_string ("Mapping " ^ b'.sname ^ " to " ^ b.sname ^ "\n");
	  List.iter (fun (l,res) ->
	      print_string "check that ";
	      Display.display_var [] b l;
              print_string " is defined at occurrences of ";
              Display.display_term [] res;
              print_newline()) def_check; *)
	  restr_mapping := (b', b, def_check):: (!restr_mapping)) restr'
  | (Fun _, Fun _) -> ()
  | _ -> Parsing_helper.internal_error "Structures of left- and right-hand sides of an equivalence must be the same"

let build_restr_mapping restr_mapping lmg rmg =
  List.iter2 (fun (lm,_) (rm,_) -> 
    build_restr_mapping_fungroup restr_mapping lm rm) lmg rmg

let check_equiv (lm,rm,p,opt,opt2) =
  let lm' = List.map (fun (fg, mode) -> (check_lm_fungroup fg, mode)) lm in
  (* Require that each function has a different number of repetitions.
     Then the typing guarantees that when several variables are referenced
     with the same array indexes, then these variables come from the same function. *)
  Terms.array_ref_eqside rm;
  let rm' = List.map (fun (fg, mode) ->
    (check_rm_fungroup [] fg, mode)) rm
  in
  let rm'' = move_names_all lm' rm' in
  Terms.cleanup_array_ref();
  let restr_mapping = ref [] in
  build_restr_mapping restr_mapping lm' rm'';
  ((lm', rm'', p, opt,opt2), !restr_mapping)

