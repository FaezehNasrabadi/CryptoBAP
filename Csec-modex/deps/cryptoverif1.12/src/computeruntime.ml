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

(* Compute the runtime of the context *)

let rec make_length_term g t =
  match t.t_desc with
    FunApp(f,l) -> 
      Length(f, make_length g l)
  | Var(b,l) ->
      Maxlength(g, Terms.term_from_binder b)
  | TestE _ | LetE _ | FindE _ | ResE _ | EventE _ ->
      Parsing_helper.internal_error "If/let/find/new/event not allowed in make_length_term"

and make_length g = function
    [] -> []
  | (t::l) ->
      let l' = make_length g l in
      if t.t_type.toptions land Settings.tyopt_BOUNDED != 0 then
	l'
      else
	(make_length_term g t)::l'   (*Maxlength(g, t)::l'*)

(* (!Settings.ignore_small_times)>0 when many details should be ignored.*)

let empty_game = { proc = Terms.nil_proc; game_number = -1 }
let get_time_map = ref ((fun t -> raise Not_found) : term -> term list * int * int * binder list * (binder list * term list) list)
let whole_game = ref empty_game
let names_to_discharge = ref []

let rec time_list f = function
    [] -> Polynom.zero
  | (a::l) -> Polynom.sum (f a) (time_list f l)
	
let rec time_for_term_in_context t (args, il, ik, repl_lhs, indices_exp) =
  let targs = time_list time_term args in
  if (!Settings.ignore_small_times)>0 then
    targs
  else
    let eqindexty = List.map (fun brepl -> Settings.t_interv(*brepl.btype*)) repl_lhs in
    let tupleargs = 
      Terms.build_term_type Settings.t_bitstring (FunApp(Settings.get_tuple_fun (List.map (fun t -> t.t_type) args), args))
    in
    let t_context = 
      if (!Settings.front_end) == Settings.Oracles then
	Add(Add(Add(Mul (Cst (float_of_int (ik*il)), ActTime(AFunApp(Settings.f_plus), [])),
		    Mul (Cst (float_of_int (ik*il)), ActTime(AFunApp(Settings.f_mul), []))),
		Mul(Cst (float_of_int (4*ik+5+2*List.length args)), ActTime(AArrayAccess ik, []))),
	    Add(Mul(Cst (float_of_int (2*ik*(ik+1))), ActTime(AReplIndex, [])),
		Mul(Cst 2.0, ActTime(AArrayAccess il, []))))
      else
	Add(Add(Add(ActTime(AOut(eqindexty, t.t_type), make_length (!whole_game) [t]),
		    Add(Mul (Cst (float_of_int (ik*il)), ActTime(AFunApp(Settings.f_plus), [])),
			Mul (Cst (float_of_int (ik*il)), ActTime(AFunApp(Settings.f_mul), [])))),
		Add(Mul(Cst (float_of_int (3*ik)), ActTime(AOut(eqindexty, Settings.t_unit), [])),
		    Mul(Cst 2.0, ActTime(AOut(eqindexty, Settings.t_bitstring), make_length (!whole_game) [tupleargs])))),
	    Add(Add(Mul(Cst (float_of_int (3*ik+3)), ActTime(AIn ik, [])),
		    Mul(Cst (float_of_int (2*ik*(ik+1))), ActTime(AReplIndex, []))),
		Add(ActTime(AArrayAccess il, []), ActTime(AArrayAccess ik, []))))
    in
    let t_indexes = time_list (fun (_,tl) -> time_list time_term tl) indices_exp in
    Polynom.sum targs (Polynom.sum t_indexes (Polynom.probaf_to_polynom t_context))

and time_term t =
  try
    (* The term is transformed; compute the time of the context,
       not the time of t itself *)
    time_for_term_in_context t ((!get_time_map) t)
  with Not_found -> 
    (* The term is not transformed; simply compute the time of t *)
  match t.t_desc with
    Var(b,[]) when Terms.is_repl b ->
      if (!Settings.ignore_small_times)>0 then
	Polynom.zero
      else
	Polynom.probaf_to_polynom (ActTime(AReplIndex, []))
  | Var(b,l) ->
      let tl = time_list time_term l in
      if (!Settings.ignore_small_times)>0 then
	tl
      else
	Polynom.sum tl (Polynom.probaf_to_polynom (ActTime(AArrayAccess (List.length l), [])))
  | FunApp(f,l) ->
      let tl = time_list time_term l in
      if (!Settings.ignore_small_times)>1 && 
	((f==Settings.f_and) || (f==Settings.f_or) || (f==Settings.f_not) ||
	 (f==Settings.get_tuple_fun []) || 
	 ((l == []) && (Terms.equal_terms t (Terms.cst_for_type (snd f.f_type)))))
      then
	(* Ignore &&, ||, not, (), cst_ty 
	   when (!Settings.ignore_small_times)>1 *)
	tl
      else if (!Settings.ignore_small_times)>2  && 
	(match f.f_cat with
	  Equal | Diff -> true 
	| _ -> false) && 
	((List.hd l).t_type.toptions land Settings.tyopt_BOUNDED != 0)
      then
	(* Ignore the time for equality tests 
	   when (!Settings.ignore_small_times)>2 *)
	tl
      else if (!Settings.ignore_small_times)>2  && (l == []) 
      then
	tl
      else
	Polynom.sum tl (Polynom.probaf_to_polynom (ActTime(AFunApp f, make_length (!whole_game) l)))
  | ResE(b,t) ->
      let tt = time_term t in
      if (!Settings.ignore_small_times)>0 then
	tt
      else
	begin
	  (* When b is in names_to_discharge, "new b" is replaced with
	     "let b = cst" in the context *)
	  if List.memq b (!names_to_discharge) then
	    Polynom.sum tt (Polynom.sum 
	      (Polynom.probaf_to_polynom (ActTime(AArrayAccess (List.length b.args_at_creation), [])))
              (time_term (Terms.cst_for_type b.btype)))
	  else
	    Polynom.sum tt (Polynom.probaf_to_polynom 
	      (Add(ActTime(AArrayAccess (List.length b.args_at_creation), []), ActTime(ANew b.btype, []))))
	end
  | EventE(t) ->
      Parsing_helper.internal_error "event should have been expanded"
  | TestE(t,t1,t2) ->
      let tp = Polynom.sum (time_term t) (Polynom.max (time_term t1) (time_term t2)) in
      if (!Settings.ignore_small_times)>0 then
	tp
      else
	Polynom.sum tp (Polynom.probaf_to_polynom (ActTime(AIf, [])))
  | FindE(l0,t3, _) ->
      let rec t_proc = function
	  [] -> time_term t3
	| (_,_,_,t2)::l -> Polynom.max (time_term t2) (t_proc l)
      in
      let tp = t_proc l0 in
      let rec prod_count r = function
	  [] -> r
	| (b::bl) -> Polynom.product (Polynom.probaf_to_polynom (Count (Terms.param_from_type b.btype))) (prod_count r bl)
      in
      let max_blen = ref 0 in
      let args_at_creation = ref 0 in
      let rec t_test = function
	  [] -> tp
	| (bl, def_list, t, _)::l ->
	    let t_test1 = 
	      Polynom.sum (time_list time_binderref def_list)
	     (Polynom.sum (time_term t) 
	     (if (!Settings.ignore_small_times)>0 then 
	       Polynom.zero
	     else
	       Polynom.probaf_to_polynom (
	       match bl with
		 [] -> ActTime(AFind 0, [])
	       | (b::_) ->
		   let blen = List.length bl in
		   let argslen = List.length b.args_at_creation in
		   if blen > !max_blen then
		     begin
		       max_blen := blen;
		       args_at_creation := argslen
		     end;
		   Add(ActTime(AFind blen, []), Mul (Cst(float_of_int blen), ActTime(AArrayAccess argslen, [])))
		     )))
	    in
	    Polynom.sum (t_test l) (prod_count t_test1 bl)
      in
      let tt = t_test l0 in
      if (!Settings.ignore_small_times)>0 then 
	tt
      else
	Polynom.sum tt (Polynom.probaf_to_polynom (Mul (Cst(float_of_int (!max_blen)), ActTime(AArrayAccess (!args_at_creation), []))))
  | LetE(pat, t, t1, topt) ->
      Polynom.sum (time_pat pat) (Polynom.sum (time_term t) 
	(Polynom.max (time_term t1) 
	   (match topt with
	     None -> Polynom.zero 
	   | Some t2 -> time_term t2)))

and time_pat = function
    PatVar b -> 
      if (!Settings.ignore_small_times)>0 then
	Polynom.zero
      else
	Polynom.probaf_to_polynom (ActTime(AArrayAccess (List.length b.args_at_creation), []))
  | PatTuple(f,l) ->
      let tl = time_list time_pat l in
      if (!Settings.ignore_small_times)>1 && 
	(f == Settings.get_tuple_fun []) then
	(* Ignore let () when (!Settings.ignore_small_times)>1 *)
	tl
      else
	Polynom.sum tl (Polynom.probaf_to_polynom (ActTime(APatFunApp f, make_length (!whole_game) (List.map Terms.term_from_pat l))))
  | PatEqual t ->
      if (!Settings.ignore_small_times)>2 &&
	(t.t_type.toptions land Settings.tyopt_BOUNDED != 0)
      then
	time_term t 
      else
	Polynom.sum (time_term t) (Polynom.probaf_to_polynom (ActTime(AFunApp (Settings.f_comp Equal t.t_type t.t_type), make_length (!whole_game) [t])))

and time_binderref (b,l) = 
  let tl = time_list time_term l in
  if (!Settings.ignore_small_times)>0 then
    tl
  else
    Polynom.sum tl (Polynom.probaf_to_polynom (ActTime(AArrayAccess (List.length l), [])))

let rec time_term_ignore_tuple t =
  match t.t_desc with
    FunApp(f,l) when f.f_cat == Tuple ->
      time_list time_term_ignore_tuple l
  | _ -> time_term t

let time_term_ignore_top_tuple t =
  match t.t_desc with
    FunApp(f,l) when f.f_cat == Tuple ->
      time_list time_term l
  | _ -> time_term t

let rec time_pat_ignore_tuple = function
    PatTuple(f,l) when f.f_cat == Tuple ->
      time_list time_pat_ignore_tuple l
  | pat -> time_pat pat

let time_pat_ignore_top_tuple = function
    PatTuple(f,l) when f.f_cat == Tuple ->
      time_list time_pat l
  | pat -> time_pat pat

let rec time_process p =
  match p.i_desc with
    Nil -> Polynom.zero
  | Par(p1,p2) -> Polynom.sum (time_process p1) (time_process p2)
  | Repl(b,p) -> Polynom.product (time_process p) (Polynom.probaf_to_polynom (Count (Terms.param_from_type b.btype)))
  | Input((c,tl),pat,p) ->
      let ttl = Polynom.sum (Polynom.sum (time_list time_term tl) 
	 ((if (!Settings.ignore_small_times)>1 then time_pat_ignore_tuple else 
	   if (!Settings.front_end) == Settings.Oracles then time_pat_ignore_top_tuple else time_pat) pat)) (time_oprocess p) in
      if ((!Settings.ignore_small_times)>0) || 
         ((!Settings.front_end) == Settings.Oracles) then
	ttl
      else
	Polynom.sum ttl (Polynom.probaf_to_polynom (ActTime(AIn(List.length tl), [])))
      
and time_oprocess p = 
  match p.p_desc with
    Yield -> 
      if ((!Settings.ignore_small_times)>0) || 
         ((!Settings.front_end) == Settings.Oracles) then
	Polynom.zero
      else
	Polynom.probaf_to_polynom (ActTime(AOut([], Settings.t_unit), []))
  | Restr(b,p) ->
      let tp = time_oprocess p in
      if (!Settings.ignore_small_times)>0 then
	tp
      else
	begin
	  (* When b is in names_to_discharge, "new b" is replaced with
	     "let b = cst" in the context *)
	  if List.memq b (!names_to_discharge) then
	    Polynom.sum tp (Polynom.sum 
	      (Polynom.probaf_to_polynom (ActTime(AArrayAccess (List.length b.args_at_creation), [])))
              (time_term (Terms.cst_for_type b.btype)))
	  else
	    Polynom.sum tp (Polynom.probaf_to_polynom 
	      (Add(ActTime(AArrayAccess (List.length b.args_at_creation), []), ActTime(ANew b.btype, []))))
	end
  | Test(t,p1,p2) ->
      let tp = Polynom.sum (time_term t) (Polynom.max (time_oprocess p1) (time_oprocess p2)) in
      if (!Settings.ignore_small_times)>0 then
	tp
      else
	Polynom.sum tp (Polynom.probaf_to_polynom (ActTime(AIf, [])))
  | Find(l0,p2, _) ->
      let rec t_proc = function
	  [] -> time_oprocess p2
	| (_,_,_,p1)::l -> Polynom.max (time_oprocess p1) (t_proc l)
      in
      let tp = t_proc l0 in
      let rec prod_count r = function
	  [] -> r
	| (b::bl) -> Polynom.product (Polynom.probaf_to_polynom (Count (Terms.param_from_type b.btype))) (prod_count r bl)
      in
      let max_blen = ref 0 in
      let args_at_creation = ref 0 in
      let rec t_test = function
	  [] -> tp
	| (bl, def_list, t, _)::l ->
	    let t_test1 = 
	      Polynom.sum (time_list time_binderref def_list)
	     (Polynom.sum (time_term t) 
	     (if (!Settings.ignore_small_times)>0 then 
	       Polynom.zero
	     else
	       Polynom.probaf_to_polynom (
	       match bl with
		 [] -> ActTime(AFind 0, [])
	       | (b::_) ->
		   let blen = List.length bl in
		   let argslen = List.length b.args_at_creation in
		   if blen > !max_blen then
		     begin
		       max_blen := blen;
		       args_at_creation := argslen
		     end;
		   Add(ActTime(AFind blen, []), Mul (Cst(float_of_int blen), ActTime(AArrayAccess argslen, [])))
		     )))
	    in
	    Polynom.sum (t_test l) (prod_count t_test1 bl)
      in
      let tt = t_test l0 in
      if (!Settings.ignore_small_times)>0 then 
	tt
      else
	Polynom.sum tt (Polynom.probaf_to_polynom (Mul (Cst(float_of_int (!max_blen)), ActTime(AArrayAccess (!args_at_creation), []))))
  | Output((c,tl),t2,p) ->
      let tp = Polynom.sum (time_list time_term tl) 
	  (Polynom.sum ((if (!Settings.ignore_small_times)>1 then time_term_ignore_tuple else
	                 if (!Settings.front_end) == Settings.Oracles then time_term_ignore_top_tuple else time_term) t2) (time_process p)) in
      if ((!Settings.ignore_small_times)>0) ||
         ((!Settings.front_end) == Settings.Oracles) then
	tp
      else
	Polynom.sum tp (Polynom.probaf_to_polynom (ActTime(AOut(List.map (fun t -> t.t_type) tl, t2.t_type), make_length (!whole_game) (tl @ [t2]))))
  | Let(pat, t, p1, p2) ->
      Polynom.sum (time_pat pat) (Polynom.sum (time_term t) 
	(Polynom.max (time_oprocess p1) (time_oprocess p2)))
  | EventP(t,p) ->
      (* Events can be ignored Polynom.sum (time_term t) *) (time_oprocess p)


let compute_runtime_for_context g equiv map_fun names_discharge =
  whole_game := g;
  get_time_map := map_fun;
  names_to_discharge := names_discharge;
  let tp = time_process g.proc in
  let t = 
    if (!Settings.ignore_small_times)>0 then
      tp
    else
      let ((lm, _,_,_,_),_) = equiv in
      let rec countfuns = function
	  [] -> 0
	| (a::l) -> countfuns_fg a + countfuns l
      and countfuns_fg = function
	  ReplRestr(_,_,fgl) -> 1 + countfuns fgl
	| Fun _ -> 1
      in
      let nnewchannel = 2*(countfuns (List.map fst lm)) in
      Polynom.sum tp (Polynom.probaf_to_polynom (Mul(Cst (float_of_int nnewchannel), ActTime(ANewChannel, []))))
  in
  let r = Polynom.polynom_to_probaf t in
  whole_game := empty_game;
  get_time_map := (fun t -> raise Not_found);
  names_to_discharge := [];
  r

let compute_runtime_for g = 
  whole_game := g;
  get_time_map := (fun t -> raise Not_found);
  names_to_discharge := [];
  let r = Polynom.polynom_to_probaf (time_process g.proc) in
  whole_game := empty_game;
  r



