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
(* Verify that the invariants are maintained by game transformations *)

open Types


(* Invariant 1: single definition; two definitions of the same variable
are in different branches of if/let/find.
Variables have as args_at_creation the current indices.
Returns the list of defined variables *)

let check_noninter d1 d2 =
  List.iter (fun b1 ->
    if List.memq b1 d2 then
      Parsing_helper.internal_error ("Same variable " ^ (Display.binder_to_string b1) ^ " defined twice\n")
	) d1

let ok_cur_array cur_array b =
  if not (Terms.equal_term_lists b.args_at_creation (List.map Terms.term_from_binder cur_array)) then 
    Parsing_helper.internal_error ("Bad args_at_creation for " ^ (Display.binder_to_string b))

let rec inv1fc cur_array t =
  match t.t_desc with
    Var _ | FunApp _ -> []
  | TestE(_,p1,p2) ->
      let def1 = inv1fc cur_array p1 in
      let def2 = inv1fc cur_array p2 in
      Terms.union def1 def2
  | ResE(b,p) ->
      Parsing_helper.internal_error "new should not appear as term"
(*
      let def = inv1fc cur_array p in
      check_noninter def [b];
      ok_cur_array cur_array b;
      b :: def
*)
  | EventE(t) ->
      Parsing_helper.internal_error "event should not appear as term"
  | LetE(pat,t,p1,topt) ->
      let def1 = inv1fc cur_array p1 in
      let def2 = Terms.vars_from_pat [] pat in
      List.iter (ok_cur_array cur_array) def2;
      check_noninter def1 def2;
      let def3 = 
	match topt with
	  Some p2 -> inv1fc cur_array p2
	| None -> []
      in
      Terms.union (def2 @ def1) def3
  | FindE(l0,p3,_) ->
      let def3 = inv1fc cur_array p3 in
      let accu = ref def3 in
      List.iter (fun (bl,def_list,t,p) ->
	List.iter (ok_cur_array cur_array) bl;
	let deft = inv1fc cur_array t in
	let defp = inv1fc cur_array p in
	check_noninter deft defp;
	check_noninter deft bl;
	check_noninter defp bl;
	accu := Terms.union (bl @ deft @ defp) (!accu)
	) l0;
      !accu
      

let rec inv1 cur_array p = 
  match p.i_desc with
    Nil -> []
  | Par(p1,p2) ->
      let def1 = inv1 cur_array p1 in
      let def2 = inv1 cur_array p2 in
      check_noninter def1 def2;
      def1 @ def2
  | Repl(b,p) ->
      let def = inv1 (b::cur_array) p in
      if b.args_at_creation != [] then
	Parsing_helper.internal_error "Replication indices should have empty args_at_creation";
      def
  | Input((c,tl),pat, p) ->
      let def1 = inv1o cur_array p in
      let def2 = Terms.vars_from_pat [] pat in
      List.iter (ok_cur_array cur_array) def2;
      check_noninter def1 def2;
      def1 @ def2

and inv1o cur_array p =
  match p.p_desc with
    Yield -> []
  | Restr(b,p) ->
      let def = inv1o cur_array p in
      check_noninter def [b];
      ok_cur_array cur_array b;
      b :: def
  | Test(t,p1,p2) ->
      let def1 = inv1o cur_array p1 in
      let def2 = inv1o cur_array p2 in
      Terms.union def1 def2
  | EventP(t,p) -> 
      inv1o cur_array p
  | Let(pat,t,p1,p2) ->
      let def1 = inv1o cur_array p1 in
      let def2 = Terms.vars_from_pat [] pat in
      List.iter (ok_cur_array cur_array) def2;
      check_noninter def1 def2;
      let def3 = inv1o cur_array p2 in
      Terms.union (def2 @ def1) def3
  | Find(l0,p3,_) ->
      let def3 = inv1o cur_array p3 in
      let accu = ref def3 in
      List.iter (fun (bl,def_list,t,p) ->
	List.iter (ok_cur_array cur_array) bl;
	let deft = inv1fc cur_array t in
	let defp = inv1o cur_array p in
	check_noninter deft defp;
	check_noninter deft bl;
	check_noninter defp bl;
	accu := Terms.union (bl @ deft @ defp) (!accu)
	) l0;
      !accu
  | Output((c,tl),t,p) ->
      inv1 cur_array p



(* Invariant 2: variables accessed are defined 
   Invariant 3: the process is well-typed
   plus
- if a variable access refers to a replication index, all the 
rest of the indices must be the indices at creation
- terms never contain new/if/let/find except in conditions of find
(but not in defined)
- new does not occur in find conditions.
- variables defined in conditions of find have no array references and a single
definition
- restrictions are done only on "fixed" types
- in terms, else branch of let can be omitted only when the pattern is a variable.
*)

let no_array_ref b =
  if Transform.has_array_ref b then
    Parsing_helper.internal_error ("Variable " ^ (Display.binder_to_string b) ^ " is defined in a condition of find; it should have no array reference.");
  match b.def with
    [] -> Parsing_helper.internal_error ("No definition for " ^ (Display.binder_to_string b))
  | [_] -> ()
  | _::_::_ -> Parsing_helper.internal_error ("Variable " ^ (Display.binder_to_string b) ^ " is defined in a condition of find; it should have a single definition.")

let is_repl_index t =
  match t.t_desc with
    Var(b,[]) ->
      List.exists (function
	  { definition = DInputProcess({ i_desc = Repl _}) } -> true
	| _ -> false) b.def
  | _ -> false

let rec check_indices args l =
  match args,l with
    [],[] -> ()
  | _::rargs, i::rl -> 
      if is_repl_index i then
	List.iter2 (fun arg i -> 
	  if not (Terms.equal_terms arg i) then
	    Parsing_helper.internal_error "If a variable access refers to a replication index, all the rest of the indices must be the indices at creation") args l
      else
	check_indices rargs rl
  | _ -> Parsing_helper.internal_error "Variable indices have length different from args_at_creation"

let rec invt defined_refs t =
  match t.t_desc with
    Var(b,l) ->
      if not (Terms.mem_binderref (b,l) defined_refs) then
	begin
	  print_string "Variable access "; 
	  Display.display_var [] b l; 
	  print_newline();
	  Parsing_helper.internal_error "Variable accessed but definition not guaranteed"
	end;
      check_indices b.args_at_creation l;
      List.iter2 (fun arg p ->
	if arg.t_type != p.t_type then
	  Parsing_helper.internal_error "Type error") b.args_at_creation l;
      if t.t_type != b.btype then
	Parsing_helper.internal_error "Type error";
      List.iter (invt defined_refs) l
  | FunApp(f,l) ->
      List.iter2 (fun t p ->
	if t != p.t_type then
	  Parsing_helper.internal_error "Type error") (fst f.f_type) l;
      if t.t_type != snd f.f_type then
	Parsing_helper.internal_error "Type error";
      List.iter (invt defined_refs) l
  | ResE _ | FindE _ | TestE _ | LetE _ | EventE _ ->
      Parsing_helper.internal_error "If/let/new/find should have been expanded"

let rec invpat defined_refs = function
    PatVar b -> b.btype
  | PatTuple(f,l) ->
      let tl = List.map (invpat defined_refs) l in
      List.iter2 (fun t t' ->
	if t != t' then
	  Parsing_helper.internal_error "Type error: function argument in pattern") (fst f.f_type) tl;
      snd f.f_type
  | PatEqual t ->
      invt defined_refs t;
      t.t_type
      
let rec invfc defined_refs t =
  match t.t_desc with
    Var _ | FunApp _ -> invt defined_refs t
  | ResE(b,t) ->
      Parsing_helper.internal_error "new should not appear as term"
(*
      let ty = b.btype in
      if ty.toptions land Settings.tyopt_CHOOSABLE == 0 then
	Parsing_helper.internal_error ("Cannot choose randomly a bitstring from " ^ ty.tname ^ " with uniform distribution\n");
      no_array_ref b;
      invfc ((b, b.args_at_creation)::defined_refs) t
*)
  | EventE(t) ->
      Parsing_helper.internal_error "event should not appear as term"
  | TestE(t1,t2,t3) ->
      invt defined_refs t1;
      invfc defined_refs t2;
      invfc defined_refs t3;
      if t2.t_type != t3.t_type then 
	Parsing_helper.internal_error "Type error: branches of if with different types";
      if t1.t_type != Settings.t_bool then
	Parsing_helper.internal_error "Type error: condition should have type bool"
  | LetE(pat, t, t2, topt) ->
      let ty = invpat defined_refs pat in
      let bpat = Terms.vars_from_pat [] pat in
      List.iter no_array_ref bpat;
      let defs = List.map (fun b -> (b, b.args_at_creation)) bpat in
      invt defined_refs t;
      invfc (defs @ defined_refs) t2;
      if ty != t.t_type then
	Parsing_helper.internal_error "Type error: assigned pattern has different type than its value";
      begin
	match topt with
	  Some t3 -> 
	    invfc defined_refs t3;
	    if t3.t_type != t2.t_type then
	      Parsing_helper.internal_error "Type error: branches of let with different types"
	| None -> 
	    match pat with
	      PatVar _ -> ()
	    | _ -> Parsing_helper.internal_error "The else branch of let can be omitted only when the pattern is a variable"
      end
  | FindE(l0,t3,_) ->
      invfc defined_refs t3;
      List.iter (fun (bl, def_list, t, t2) ->
	if t3.t_type != t2.t_type then
	  Parsing_helper.internal_error "Type error: branches of find with different types";
	if t.t_type != Settings.t_bool then
	  Parsing_helper.internal_error "Type error: condition of find should have type bool";
	List.iter no_array_ref bl;
	let accu = ref ((List.map (fun b -> (b, b.args_at_creation)) bl) @ defined_refs) in
	List.iter (Terms.close_def_subterm accu) def_list;
	let def_refs = !accu in
	List.iter (fun br -> invt def_refs (Terms.term_from_binderref br)) def_list;
	invfc def_refs t;
	invfc def_refs t2
	) l0

let rec inv defined_refs p =
  match p.i_desc with
    Nil -> ()
  | Par(p1,p2) -> 
      inv defined_refs p1;
      inv defined_refs p2
  | Repl(b,p) ->
      if not (List.for_all (function
	  { definition = DInputProcess({ i_desc = Repl _}) } -> true
	| _ -> false) b.def) then	
	Parsing_helper.internal_error "Replication index mixed with other definitions";
      inv ((b,[]) :: defined_refs) p
  | Input((c,tl),pat,p) ->
      List.iter (invt defined_refs) tl;
      let _ = invpat defined_refs pat in
      let bpat = Terms.vars_from_pat [] pat in
      let defs = List.map (fun b -> (b, b.args_at_creation)) bpat in
      invo (defs @ defined_refs) p

and invo defined_refs p =
  match p.p_desc with
    Yield -> ()
  | Restr(b,p) ->
      let ty = b.btype in
      if ty.toptions land Settings.tyopt_CHOOSABLE == 0 then
	Parsing_helper.internal_error ("Cannot choose randomly a bitstring from " ^ ty.tname ^ " with uniform distribution\n");
      invo ((b, b.args_at_creation)::defined_refs) p
  | Test(t,p1,p2) ->
      invt defined_refs t;
      invo defined_refs p1;
      invo defined_refs p2;
      if t.t_type != Settings.t_bool then
	Parsing_helper.internal_error "Type error: condition should have type bool"
  | Let(pat, t, p1, p2) ->
      let ty = invpat defined_refs pat in
      let bpat = Terms.vars_from_pat [] pat in
      let defs = List.map (fun b -> (b, b.args_at_creation)) bpat in
      invt defined_refs t;
      invo (defs @ defined_refs) p1;
      if ty != t.t_type then
	Parsing_helper.internal_error "Type error: assigned pattern has different type than its value";
      invo defined_refs p2
  | Find(l0,p2,_) ->
      invo defined_refs p2;
      List.iter (fun (bl, def_list, t, p1) ->
	if t.t_type != Settings.t_bool then
	  Parsing_helper.internal_error "Type error: condition of find should have type bool";
	let accu = ref ((List.map (fun b -> (b, b.args_at_creation)) bl) @ defined_refs) in
	List.iter (Terms.close_def_subterm accu) def_list;
	let def_refs = !accu in
	List.iter (fun br -> invt def_refs (Terms.term_from_binderref br)) def_list;
	invfc def_refs t;
	invo def_refs p1
	) l0
  | Output((c,tl),t,p) ->
      List.iter (invt defined_refs) tl;
      invt defined_refs t;
      inv defined_refs p
  | EventP(t,p) ->
      invt defined_refs t;
      invo defined_refs p

let global_inv p =
  let _ = inv1 [] p in
  Terms.array_ref_process p;
  Terms.build_def_process None p;
  inv [] p;
  Terms.cleanup_array_ref()
