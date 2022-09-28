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
open Parsing_helper
open Terms

exception HistoryUnifyError
exception InternalError of string

(* add a rule and return its history *)

let rule_hash = Hashtbl.create 7

let change_type_attacker p t =
  match p.p_info with
    [Attacker(n,_)] -> Param.get_pred (Attacker(n,t))
  | [AttackerBin(n,_)] -> Param.get_pred (AttackerBin(n,t))
  | [AttackerGuess _] -> Param.get_pred (AttackerGuess(t))
  | [Compromise _] -> Param.get_pred (Compromise(t))
  | [PolymPred(s,i,tl)] -> Param.get_pred (PolymPred(s,i,Terms.copy_n (List.length tl) t))
  | [] -> 
      if !Param.typed_frontend then
	Parsing_helper.internal_error "Non-polymorphic user-defined predicates should not be declared data in the typed front-end"
      else
	p
  | _ -> Parsing_helper.internal_error "Unexpected predicate in change_type_attacker"

let get_rule_hist descr =
  try
    Hashtbl.find rule_hash descr
  with Not_found ->
    let (hyp,concl,constra) = 
      match descr with
        Elem(preds, ({ p_type = [t1;t2] } as p)) ->
	  let v = Terms.new_var_def t1 in
	  let v' = Terms.new_var_def t2 in
	  (List.map (fun p' -> Pred(change_type_attacker p' t1, [v])) preds, 
	   Pred(p, [v;v']), 
	   [])
      | TestUnif ->
	  ([], Pred(Param.testunif_pred, [Terms.new_var_def Param.any_type; Terms.new_var_def Param.any_type]), [])
      | Apply(Func(f),p) ->
	  let rec gen_vars n =
	    if n = 0 then
	      [] 
	    else
	      (FunApp(f, Terms.var_gen (fst f.f_type))) :: (gen_vars (n-1))
	  in
	  let concl = gen_vars (List.length p.p_type) in
	  let hypl = reorganize_fun_app f concl in
	  (List.map (fun h -> Pred((change_type_attacker p (Terms.get_term_type (List.hd h))), h)) hypl, 
	   Pred((change_type_attacker p (Terms.get_term_type (List.hd concl))), concl), [])
      | Apply(Proj(f,nproj),p) ->
	  let rec gen_vars n =
	    if n = 0 then
	      [] 
	    else
	      (FunApp(f, Terms.var_gen (fst f.f_type))) :: (gen_vars (n-1))
	  in
	  let hyp = gen_vars (List.length p.p_type) in
	  let concl = List.nth (reorganize_fun_app f hyp) nproj in
	  ([Pred((change_type_attacker p (Terms.get_term_type (List.hd hyp))),hyp)], 
	   Pred((change_type_attacker p (Terms.get_term_type (List.hd concl))), concl), [])
      | _ -> 
	  internal_error "unsupported get_rule_hist"
    in
    let hist = Rule(-1, descr, hyp, concl, constra) in
    Hashtbl.add rule_hash descr hist;
    hist

let name_from_label descr =
  match descr with
    Elem(preds,p) ->
      "simplif " ^ p.p_name
  | TestUnif ->
      "testunif"
  | Apply(Func(f),p) ->
      if f.f_name = "" then
	let arity = List.length (fst f.f_type) in
	if (arity = 0) || (!Param.ignore_types) then
	  ((string_of_int arity) ^ "-tuple")
	else
	  ((Terms.tl_to_string "-" (fst f.f_type)) ^ "-tuple")
      else
	f.f_name ^ "-tuple"
  | Apply(Proj(f,n),p) ->
      (string_of_int n) ^"-th"
  | _ -> 
      internal_error "unsupported get_rule_hist"

(* History simplification *)

(* We use a hash table that associates to each fact all trees that
   derive it. To avoid recomputing hashes, we store them together with
   the considered fact. *)

module HashFact =
  struct

    type t = 
	{ hash : int;
	  fact : fact }

    let equal a b = Termslinks.equal_facts_with_links a.fact b.fact

    type skel_term =
	SVar of int
      |	SFun of string * skel_term list

    type skel_fact =
	SPred of string * skel_term list
      |	SOut of skel_term

    let rec skeleton_term = function
	Var b -> 
	  begin
	    match b.link with
	      TLink t -> skeleton_term t
	    | NoLink -> SVar(b.vname)
	    | _ -> Parsing_helper.internal_error "unexpected link in skeleton_term"
	  end
      |	FunApp(f,l) -> 
	  match f.f_cat with
	    Name _ -> SFun(f.f_name,[])
	  | _ -> SFun(f.f_name, List.map skeleton_term l)

    let skeleton_fact = function
	Pred(p,l) -> SPred(p.p_name, List.map skeleton_term l)
      |	Out(t,_) -> SOut(skeleton_term t)

    let hash a = a.hash

    (* build a HashFact.t from a fact *)

    let build f = { hash = Hashtbl.hash(skeleton_fact f);
		    fact = f }

  end

module TreeHashtbl = Hashtbl.Make(HashFact)

let tree_hashtbl = TreeHashtbl.create 7

let seen_fact hf =
  if !Param.simplify_derivation_level = Param.AllFacts then
    TreeHashtbl.find tree_hashtbl hf
  else
  match hf.HashFact.fact with
    Pred(p,_) when p.p_prop land Param.pred_ATTACKER != 0 ->
      TreeHashtbl.find tree_hashtbl hf
  | _ -> raise Not_found 
               (* Remove proofs of the same fact only for attacker facts,
                  several proofs of the same fact may be useful for attack
		  reconstruction for other facts: for mess facts, in particular
		  several outputs of the same message on the same channel
		  may be needed for private channels. *)

let rec unroll_rwp t =
  match t.desc with 
    FRemovedWithProof t' -> unroll_rwp t'
  | _ -> t

let equal_son t t' =
  unroll_rwp t == unroll_rwp t'

let seen_tree hf t =
  if !Param.simplify_derivation_level != Param.AttackerSameTree then
    begin
      TreeHashtbl.add tree_hashtbl hf t;
      t
    end
  else
    match t.thefact with
      Pred(p,_) when p.p_prop land Param.pred_ATTACKER != 0 -> 
          (* If t was already proved, it would have been removed by seen_fact when it
	     concludes an attacker fact *)
	TreeHashtbl.add tree_hashtbl hf t;
	t
    | _ ->
	try
	  let r = TreeHashtbl.find_all tree_hashtbl hf in
	  let t' =
	    List.find (fun t' ->
	      (match t.desc, t'.desc with
		FHAny, FHAny -> true
	      | FEmpty, FEmpty -> true
	      | FRule(n, tags, constra, sons), FRule(n', tags', constra', sons') ->
		  (n == n') && (Termslinks.equal_tags tags tags') && (Termslinks.equal_constra constra constra') &&
		  (List.length sons == List.length sons') && (List.for_all2 equal_son sons sons')
	      | FEquation son, FEquation son' ->
		  equal_son son son'
	      | FRemovedWithProof _, _ -> internal_error "Unexpected FRemovedWithProof"
	      | _ -> false)
		) r
	  in
	  { t with desc = FRemovedWithProof t' }
        with Not_found ->
	  TreeHashtbl.add tree_hashtbl hf t;
	  t

let rec simplify_tree t =
  let hf = HashFact.build t.thefact in
  match t.desc with
    FRemovedWithProof t' -> 
      begin
	try
	  { t with desc = FRemovedWithProof (TreeHashtbl.find tree_hashtbl hf) }
	with Not_found ->
	  simplify_tree t'
      end
  | FHAny | FEmpty ->
      begin
	try   
	  { t with desc = FRemovedWithProof (seen_fact hf) }
        with Not_found ->
	  seen_tree hf t
      end
  | FRule(n, tags, constra, sons) -> 
      begin
	try   
	  { t with desc = FRemovedWithProof (seen_fact hf) }
        with Not_found ->
	  let sons' = List.rev_map simplify_tree (List.rev sons) in
	  seen_tree hf { t with desc = FRule(n, tags, constra, sons') } 
      end
  | FEquation son -> 
      begin
	try   
	  { t with desc = FRemovedWithProof (seen_fact hf) }
        with Not_found ->
	  let son' = simplify_tree son in
	  seen_tree hf { t with desc = FEquation son' }
      end

(* History display *)

let rec display_history_tree align ftree = 
  begin
    match ftree.desc with
      FEmpty -> print_string (align ^ "hypothesis ");
    | FHAny -> print_string (align ^ "any ")
    | FRemovedWithProof _ -> print_string (align ^ "duplicate ")
    | FRule(n, descr, constra, hl) -> 
	if n = -1 then
	  print_string (align ^ (name_from_label descr) ^ " ")
	else
	  print_string (align ^ "rule " ^ (string_of_int n) ^ " ")
    | FEquation(h) -> print_string (align ^ "equation ")
  end;
  Display.WithLinks.fact ftree.thefact;
  Display.newline();
  begin
    match ftree.desc with
      FEmpty | FHAny | FRemovedWithProof _ -> ()
    | FRule(n, _, _, hl) -> List.iter (display_history_tree (align ^ "  ")) hl
    | FEquation(h) -> display_history_tree (align ^ "  ") h
  end

(* History display with explanations linking it to the process *)

let display_step n =
  if n >= 0 then
    print_string ("By " ^ (string_of_int n) ^ ", ")

let display_step_low n =
  if n >= 0 then
    print_string (" by " ^ (string_of_int n))

let display_attacker_fact = function
    Pred({p_info = [Attacker(n,_)]}, [v]) ->
      Display.WithLinks.term v;
      if n > 0 then 
	print_string (" in phase " ^ (string_of_int n))
  | Pred({p_info = [AttackerBin(n,_)]}, [v;v']) ->
      Display.WithLinks.term v;
      print_string " (resp. ";
      Display.WithLinks.term v';
      print_string ")";
      if n > 0 then 
	print_string (" in phase " ^ (string_of_int n))
  | Pred({p_info = [AttackerGuess _]}, [v;v']) ->
      Display.WithLinks.term v;
      print_string " (resp. ";
      Display.WithLinks.term v';
      print_string ") in off-line phase"
  | _ -> Parsing_helper.internal_error "Unexpected attacker fact"

let display_tbl_fact = function
    Pred({p_info = [Table(n)]}, [v]) ->
      Display.WithLinks.term v;
      if n > 0 then 
	print_string (" in phase " ^ (string_of_int n))
  | Pred({p_info = [TableBin(n)]}, [v;v']) ->
      Display.WithLinks.term v;
      print_string " (resp. ";
      Display.WithLinks.term v';
      print_string ")";
      if n > 0 then 
	print_string (" in phase " ^ (string_of_int n))
  | _ -> Parsing_helper.internal_error "Unexpected table fact"

let display_input_fact = function
    Pred({p_info = [InputP(n)]}, [v]) ->
      Display.WithLinks.term v;
      if n > 0 then 
	print_string (" in phase " ^ (string_of_int n))
  | Pred({p_info = [InputPBin(n)]}, [v;v']) ->
      Display.WithLinks.term v;
      print_string " (resp. ";
      Display.WithLinks.term v';
      print_string ")";
      if n > 0 then 
	print_string (" in phase " ^ (string_of_int n))
  | _ -> Parsing_helper.internal_error "Unexpected input fact"

let display_output_fact = function
    Pred({p_info = [OutputP(n)]}, [v]) ->
      Display.WithLinks.term v;
      if n > 0 then 
	print_string (" in phase " ^ (string_of_int n))
  | Pred({p_info = [OutputPBin(n)]}, [v;v']) ->
      Display.WithLinks.term v;
      print_string " (resp. ";
      Display.WithLinks.term v';
      print_string ")";
      if n > 0 then 
	print_string (" in phase " ^ (string_of_int n))
  | _ -> Parsing_helper.internal_error "Unexpected output fact"

let display_attacker_hyp nl hl =
  List.iter2 (fun n h ->
    match h.thefact with 
      Pred(p, [v;v']) when p == Param.testunif_pred ->
	print_string "The terms ";
	Display.WithLinks.term v;
	print_string " and ";
	Display.WithLinks.term v';
	print_string" unify for some values of the secrets and not for others.";
	Display.newline()
    | _ -> 
	display_step n;
	print_string "the attacker may know ";
	display_attacker_fact h.thefact;
	print_string ".";
	Display.newline()) nl hl

let display_tbl_hyp nl hl =
  List.iter2 (fun n h ->
    display_step n;
    print_string "a table may contain the entry ";
    display_tbl_fact h.thefact;
    print_string ".";
    Display.newline()) nl hl

let display_hyp_basic nl hl =
  List.iter2 (fun n h ->
    display_step n;
    Display.WithLinks.fact h.thefact;
    print_string ".";
    Display.newline()) nl hl

let display_hyp_spec = function
    ReplTag (o,_) -> print_string "!"; print_string (string_of_int o)
  | InputTag o -> print_string "i"; print_string (string_of_int o)
  | BeginEvent o -> print_string "b"; print_string (string_of_int o)
  | BeginFact -> print_string "bf"
  | LetFilterTag o -> print_string "s"; print_string (string_of_int o)
  | LetFilterFact -> print_string "sf"
  | OutputTag o -> print_string "o"; print_string (string_of_int o)
  | TestTag o -> print_string "t"; print_string (string_of_int o)
  | LetTag o -> print_string "l"; print_string (string_of_int o)
  | TestUnifTag o -> print_string "u"; print_string (string_of_int o)
  | TestUnifTag2 o -> print_string "ud"; print_string (string_of_int o)
  | InputPTag o -> print_string "ip"; print_string (string_of_int o)
  | OutputPTag o -> print_string "op"; print_string (string_of_int o)
  | InsertTag o ->  print_string "it"; print_string (string_of_int o)
  | GetTag o ->  print_string "gt"; print_string (string_of_int o)

let rec display_hyp hyp hl tag =
  match (hyp, hl, tag) with
    (Pred(p,[v;v'])::h, _::hl', TestUnifTag _ :: t) ->
      display_hyp h hl' t;
      print_string "The terms ";
      Display.WithLinks.term v;
      print_string " and ";
      Display.WithLinks.term v';
      print_string" unify for some values of the secrets and not for others.";
      Display.newline()
  | (h, hl, TestUnifTag2 _ :: t) | (h, hl, TestTag _ :: t) 
  | (h, hl, LetTag _ :: t) | (h, hl, InputPTag _ :: t) 
  | (h, hl, OutputPTag _ :: t) | (h, hl, BeginEvent _ :: t)
  | (h, hl, OutputTag _ :: t) | (h, hl, InsertTag _ :: t) ->
      display_hyp h hl t
  | (h, hl, ReplTag _ :: t) ->
      if !Param.non_interference then
	if !Param.key_compromise == 1 then
	  match h, hl with
	    Pred(p, [v])::Pred(p', [v'])::h', s::s'::hl' -> 
	      display_hyp h' hl' t;
	      display_step s;
	      print_string "the attacker may have the session identifier ";
	      Display.WithLinks.term v;
	      Display.display_phase p;
	      print_string ".";
	      Display.newline();
	      display_step s';
	      print_string "the attacker may have the session identifier ";
	      Display.WithLinks.term v';
	      Display.display_phase p';
	      print_string ".";
	      Display.newline()
	  | _ -> Parsing_helper.internal_error "2 hypotheses should be added for a replication for non_interference, key_compromise = 1"
	else
	  match h, hl with
	    Pred(p, [v])::h', s::hl' -> 
	      display_hyp h' hl' t;
	      display_step s;
	      print_string "the attacker may have the session identifier ";
	      Display.WithLinks.term v;
	      Display.display_phase p;
	      print_string ".";
	      Display.newline()
	  | _ -> Parsing_helper.internal_error "At least one hypothesis should be added for a replication for non_interference"
      else
	display_hyp h hl t
  | (m::h,s::hl,InputTag occ :: t) ->
      display_hyp h hl t;
      begin
	match m with
	  Pred({p_info = [Attacker(n,_)]} as p, [v]) ->
	    print_string "The message ";
	    Display.WithLinks.term v;
	    print_string " that the attacker may have";
	    Display.display_phase p;
	    display_step_low s;
	    print_string " may be received at input ";
	    Display.display_occ occ
	| Pred({p_info = [Mess(n,_)]} as p, [vc;v]) ->
	    print_string "The message ";
	    Display.WithLinks.term v;
	    print_string " that may be sent on channel ";
	    Display.WithLinks.term vc;
	    Display.display_phase p;
	    display_step_low s;
	    print_string " may be received at input ";
	    Display.display_occ occ
	| Pred({p_info = [AttackerBin(n,_)]} as p, [v;v']) ->
	    print_string "The message ";
	    Display.WithLinks.term v;
	    print_string " (resp. ";
	    Display.WithLinks.term v';
	    print_string ") that the attacker may have";
	    Display.display_phase p;
	    display_step_low s;
	    print_string " may be received at input ";
	    Display.display_occ occ
	| Pred({p_info = [MessBin(n,_)]} as p, [vc;v;vc';v']) ->
	    print_string "The message ";
	    Display.WithLinks.term v;
	    print_string " that may be sent on channel ";
	    Display.WithLinks.term vc;
            print_string " (resp. message ";
	    Display.WithLinks.term v';
	    print_string " on channel ";
	    Display.WithLinks.term vc';
 	    print_string ")";
	    Display.display_phase p;
	    display_step_low s;
	    print_string " may be received at input ";
	    Display.display_occ occ
	| _ -> Parsing_helper.internal_error "Unexpected hypothesis for InputTag"
      end;
      print_string ".";
      Display.newline()
  | (m::h, s::hl, LetFilterFact :: LetFilterTag(occ) :: t) ->
      display_hyp h hl t;
      display_step s;
      Display.WithLinks.fact m;
      print_string " is true at ";
      Display.display_occ occ;
      print_string ".";
      Display.newline()
  | (h, hl, LetFilterTag(occ) :: t) ->
      display_hyp h hl t
  | (Out(e,l) ::h, s::hl, BeginFact :: BeginEvent(occ) :: t) ->
      display_hyp h hl t;
      print_string "The event ";
      Display.WithLinks.term e;
      if l <> [] then
	begin
	  print_string " (with environment ";
	  Display.display_list (fun (v,t) ->
	    print_string ((Display.varname v) ^ " = ");
	    Display.WithLinks.term t) ", " l;
	  print_string ")"
	end;
      print_string " may be executed at ";
      Display.display_occ occ;
      print_string ".";
      Display.newline()
  | (m::h,s::hl,GetTag occ :: t) ->
      display_hyp h hl t;
      begin
	match m with
	  Pred({p_info = [Table(n)]} as p, [v]) ->
	    print_string "The entry ";
	    Display.WithLinks.term v;
	    print_string " that may be in a table";
	    Display.display_phase p;
	    display_step_low s;
	    print_string " may be read at get ";
	    Display.display_occ occ
	| Pred({p_info = [TableBin(n)]} as p, [v;v']) ->
	    print_string "The entry ";
	    Display.WithLinks.term v;
	    print_string " (resp. ";
	    Display.WithLinks.term v';
	    print_string ") that may be in a table";
	    Display.display_phase p;
	    display_step_low s;
	    print_string " may be read at get ";
	    Display.display_occ occ
	| _ -> Parsing_helper.internal_error "Unexpected hypothesis for GetTag"
      end;
      print_string ".";
      Display.newline()
  | ([],[],[]) -> ()
  | _ -> 
      Display.display_list Display.WithLinks.fact " & " hyp;
      Display.newline();
      Display.display_list (fun n -> print_string (string_of_int n)) " " hl;
      Display.newline();
      Display.display_list display_hyp_spec " " tag;
      Display.newline();
      Parsing_helper.internal_error "Unexpected hypothesis"

let display_constra_list c = 
  if c <> [] then
    begin
      print_string "We have ";
      Display.display_list Display.WithLinks.constra " & " c;
      print_string ".";
      Display.newline()
    end


let display_clause_explain n lbl hyp_num_list hl constra concl =
  match lbl with
    Rn _ -> 
      print_string "The attacker creates the new name ";
      display_attacker_fact concl;
      print_string ".";
      Display.newline()
  | Init -> 
      print_string "The attacker initially knows ";
      display_attacker_fact concl;
      print_string ".";
      Display.newline()
  | PhaseChange -> 
      display_attacker_hyp hyp_num_list hl;
      print_string "So the attacker may know ";
      display_attacker_fact concl;
      print_string ".";
      Display.newline()
  | TblPhaseChange -> 
      display_tbl_hyp hyp_num_list hl;
      print_string "So a table may contain the entry ";
      display_tbl_fact concl;
      print_string ".";
      Display.newline()
  | Apply(Func(f),p) ->
      display_attacker_hyp hyp_num_list hl;
      print_string "Using the function ";
      Display.display_function_name f;
      print_string " the attacker may obtain ";
      display_attacker_fact concl;
      print_string ".";
      Display.newline()
  | Apply(Proj(f,n),p) ->
      display_attacker_hyp hyp_num_list hl;
      print_string ("Using the " ^ (string_of_int n) ^ "th inverse of function ");
      Display.display_function_name f;
      print_string " the attacker may obtain ";
      display_attacker_fact concl;
      print_string ".";
      Display.newline()
  | TestApply(Func(f),p) ->
      display_attacker_hyp hyp_num_list hl;
      display_constra_list constra;
      print_string "The attacker tests whether ";
      Display.display_function_name f;
      print_string " is applicable, which may allow it to distinguish cases.";
      Display.newline()
  | TestApply(Proj(f,n),p) ->
      display_attacker_hyp hyp_num_list hl;
      display_constra_list constra;
      print_string "The attacker tests whether an inverse of function ";
      Display.display_function_name f;
      print_string " is applicable, which may allow it to distinguish cases.";
      Display.newline()
  | TestEq(p) ->
      display_attacker_hyp hyp_num_list hl;
      display_constra_list constra;
      print_string "The attacker tests equality between the two terms he knows, which may allow it to distinguish cases.";
      Display.newline()
  | Rl(p,p') ->
      begin
	match (hyp_num_list, hl) with
	  [n1;n2], [h1;h2] ->
	    display_step n2;
	    print_string "the attacker may have the channel ";
	    display_attacker_fact h2.thefact;
	    print_string ".";
	    Display.newline();
	    display_step n1;
	    print_string "the message ";
	    display_attacker_fact concl;
	    print_string " may be sent on this channel.";
	    Display.newline();
	    print_string "So the attacker may obtain the message ";
	    display_attacker_fact concl;
	    print_string " by listening on this channel.";
	    Display.newline()
	| _ -> Parsing_helper.internal_error "Unexpected hypothesis for Rl"
      end	      
  | Rs(p,p') ->
      begin
	match (hyp_num_list, hl) with
	  [n1;n2], [h1;h2] -> 
	    display_step n1;
	    print_string "the attacker may have the channel ";
	    display_attacker_fact h1.thefact;
	    print_string ".";
	    Display.newline();
	    display_step n2;
	    print_string "the attacker may have the message ";
	    display_attacker_fact h2.thefact;
	    print_string ".";
	    Display.newline();
	    print_string "So the attacker may send this message on this channel.";
	    Display.newline()
	| _ -> Parsing_helper.internal_error "Unexpected hypothesis for Rs"
      end
  | Ri(p,p') ->
      display_attacker_hyp hyp_num_list hl;
      print_string "So the attacker may trigger an input on this channel.";
      Display.newline()
  | Ro(p,p') ->
      display_attacker_hyp hyp_num_list hl;
      print_string "So the attacker may trigger an output on this channel.";
      Display.newline()
  | TestComm(p,p') ->
      begin
	match (hyp_num_list, hl) with
	  n1::n2::_, h1::h2::r ->
	    display_step n1;
	    print_string "an input may be triggered on channel ";
	    display_input_fact h1.thefact;
	    print_string ".";
	    Display.newline();
	    display_step n2;
	    print_string "an output may be triggered on channel ";
	    display_output_fact h2.thefact;
	    print_string ".";
	    Display.newline();
	    begin
	      match r with
		[] -> ()
	      |	[{thefact = Pred(p, [v;v'])}] when p == Param.testunif_pred ->
		  print_string "The terms ";
		  Display.WithLinks.term v;
		  print_string " and ";
		  Display.WithLinks.term v';
		  print_string" unify for some values of the secrets and not for others.";
		  Display.newline()
	      |	_ -> Parsing_helper.internal_error "Unexpected hypothesis for TestComm (2)"
	    end;
	    display_constra_list constra;
	    print_string "So the attacker may know whether the communication succeeds, which may allow it to distinguish cases.";
	    Display.newline()
	| _ -> Parsing_helper.internal_error "Unexpected hypothesis for TestComm"
      end	      
  | InputSecr p ->
      begin
	match (hyp_num_list, hl) with
	  [n],[h] ->
	    display_step n;
	    print_string "an input may be triggered on channel ";
	    display_input_fact h.thefact;
	    print_string ".";
	    Display.newline();
	    print_string "Since this channel is secret, the attacker may know whether this secret is a name.";
	    Display.newline()
	| _ -> Parsing_helper.internal_error "Unexpected hypothesis for InputSecr"
      end	      
  | OutputSecr p ->
      begin
	match (hyp_num_list, hl) with
	  [n],[h] ->
	    display_step n;
	    print_string "an output may be triggered on channel ";
	    display_output_fact h.thefact;
	    print_string ".";
	    Display.newline();
	    print_string "Since this channel is secret, the attacker may know whether this secret is a name.";
	    Display.newline()
	| _ -> Parsing_helper.internal_error "Unexpected hypothesis for InputSecr"
      end	      
  | WeakSecr ->
      begin
	match concl with
	  Pred(p, [v;v']) ->
	    print_string "The attacker has the weak secret ";
	    Display.WithLinks.term v;
	    print_string " in the first component, a guess ";
	    Display.WithLinks.term v';
	    print_string " in the second.";
	    Display.newline()
	| _ -> Parsing_helper.internal_error "Unexpected conclusion for WeakSecr"
      end
  | LblEquiv ->
      display_hyp_basic hyp_num_list hl;
      display_constra_list constra;
      print_string "Using a clause coming from a <-> or <=> declaration in the input file,";
      Display.newline()
  | LblClause ->
      display_hyp_basic hyp_num_list hl;
      display_constra_list constra;
      print_string "Using a clause given in the input file,";
      Display.newline()
  | LblEq ->
      print_string "By definition of equal,";
      Display.newline()
  | Elem _ | TestUnif | LblComp ->
      Parsing_helper.internal_error "These tags should have been handled before"
  | ProcessRule(tags, _) | ProcessRule2(tags, _, _) ->
      if hl == [] && constra == [] then
	Display.WithLinks.concl true concl tags
      else
	begin
	  display_hyp (List.map (fun t -> t.thefact) hl) hyp_num_list tags;
	  display_constra_list constra;
	  print_string "So ";
	  Display.WithLinks.concl false concl tags
        end;
      print_string ".";
      Display.newline()
  | LblNone -> 
      display_hyp_basic hyp_num_list hl;
      display_constra_list constra;
      print_string ("Using the clause number " ^ (string_of_int n) ^ ",");
      Display.newline()


let explain_history_tree tree =
  let seen_list = ref [] in
  let rec find fact = function
      [] -> 
	raise Not_found
    | ((c,f)::l) ->
	if Termslinks.equal_facts_with_links f fact then c else
	find fact l
  in
  let count = ref 0 in
  let rec display_history tree =
    match tree.desc with
      FEmpty ->
	begin
	  match tree.thefact with
	    Out _ -> 
	      seen_list := (-1, tree.thefact) :: (!seen_list);
	      -1 (* Do not display hypotheses "begin" *)
	  | _ ->
	      incr count;
	      seen_list := (!count, tree.thefact) :: (!seen_list);
	      print_string ((string_of_int (!count)) ^ ". We assume as hypothesis that");
	      Display.newline();
	      Display.WithLinks.fact tree.thefact;
	      print_string ".";
	      Display.newline();
	      Display.newline();
	      (!count)
	end
    | FHAny ->
	incr count;
	seen_list := (!count, tree.thefact) :: (!seen_list);
	print_string ((string_of_int (!count)) ^ ". The attacker has some term ");
	display_attacker_fact tree.thefact;
	print_string ".";
	Display.newline();
	Display.WithLinks.fact tree.thefact;
	print_string ".";
	Display.newline();
	Display.newline();
	(!count)
    | FRemovedWithProof t' -> 
	begin
	  try
	    find tree.thefact (!seen_list)
	  with Not_found ->
	    display_history t'	    
	end
    | FEquation(h) ->
	let hyp_num = display_history h in
	incr count;
	seen_list := (!count, tree.thefact) :: (!seen_list);
	print_string ((string_of_int (!count)) ^ ". ");
	display_step hyp_num;
	print_string "we have ";
	Display.WithLinks.fact h.thefact;
	print_string ".";
	Display.newline();
	print_string "Using an equation, we obtain";
	Display.newline();
	Display.WithLinks.fact tree.thefact;
	print_string ".";
	Display.newline();
	Display.newline();
	(!count)
    | FRule(n, descr, constra, hl) -> 
	match descr with
	  Elem _ | TestUnif -> 
	    (* Do not display clauses that conclude member, testunif *)
	    seen_list := (-1, tree.thefact) :: (!seen_list);
	    -1
	| LblComp ->
	    incr count;
	    print_string ((string_of_int (!count)) ^ ". The attacker has all names created in the compromised sessions.\n");
	    seen_list := (!count, tree.thefact) :: (!seen_list);
	    Display.WithLinks.fact tree.thefact;
	    print_string ".";
	    Display.newline();
	    Display.newline();
	    (!count)
	| _ -> 
	    let hyp_num_list = List.map display_history (List.rev hl) in
	    incr count;
	    print_string ((string_of_int (!count)) ^ ". ");
	    seen_list := (!count, tree.thefact) :: (!seen_list);
	    display_clause_explain n descr (List.rev hyp_num_list) hl constra tree.thefact;
	    Display.WithLinks.fact tree.thefact;
	    print_string ".";
	    Display.newline();
	    Display.newline();
	    (!count)
  in
  ignore (display_history tree)

(* Find hypothesis number n in the history tree *)

type res = Success of fact_tree
         | Failure of int

let rec get_desc_rec t n = 
  match t.desc with
    FEmpty -> if n = 0 then Success(t) else Failure(n-1)
  | FHAny -> Failure(n)
  | FRemovedWithProof _ -> Failure(n)
  | FRule(_,_,_,l) -> get_desc_list_rec l n
  | FEquation h -> get_desc_rec h n

and get_desc_list_rec l n = 
  match l with
    [] -> Failure(n)
  | (a::l') ->
      match get_desc_rec a n with
	Success d -> Success d
      | Failure n' -> get_desc_list_rec l' n'


let get_desc s t n =
  match get_desc_rec t n with
    Success d -> d
  | Failure n' -> 
      print_string ("Hypothesis " ^ (string_of_int n) ^ " not found (" ^ s ^ ")\n");
      display_history_tree "" t;
      internal_error ("failed to find history hypothesis (" ^ s ^ ")")

(* Rebuild the derivation tree *)

let rec build_fact_tree = function
    Empty(f) -> 
      let tmp_bound_vars = !current_bound_vars in
      current_bound_vars := [];
      let f' = copy_fact2 f in
      cleanup();
      current_bound_vars := tmp_bound_vars;
      { desc = FEmpty;
        thefact = f' }
  | Any(n, h) ->
      let t = build_fact_tree h in
      let d = get_desc "any" t n in
      begin
	try
	  match d.thefact with
	    Pred(p, a::r) when p.p_prop land Param.pred_ANY_STRICT != 0
	      && p.p_prop land Param.pred_ANY == 0 ->
	      (* The arguments of "any" facts must all be equal *)
	      List.iter (fun b -> unify a b) r
	  | _ -> ()
	with Unify -> raise HistoryUnifyError
      end;
      d.desc <- FHAny;
      t
  | Removed(rem_count, dup_count, h) -> 
      let t = build_fact_tree h in
      let d1 = get_desc "removed" t rem_count in
      let d2 = get_desc "removed" t dup_count in
      begin
      try 
        unify_facts d1.thefact d2.thefact
      with Unify -> raise HistoryUnifyError
      end;      
      d1.desc <- FRemovedWithProof d2;
      t
  | HEquation(n,leq,req,h) ->
     let t = build_fact_tree h in
     (* Copy the facts *)
     let tmp_bound_vars = !current_bound_vars in
     current_bound_vars := [];
     let leq' = copy_fact2 leq in
     let req' = copy_fact2 req in
     cleanup();
     current_bound_vars := tmp_bound_vars;
     if n = -1 then 
       begin
        begin
          try 
            unify_facts req' t.thefact
          with Unify -> raise HistoryUnifyError
        end;
        { desc = FEquation(t);
          thefact = leq' }
       end
     else
       begin
         let d = get_desc "equation" t n in
         begin
           try 
             unify_facts leq' d.thefact
           with Unify -> raise HistoryUnifyError
         end;
         d.desc <- FEquation({ desc = FEmpty;
                               thefact = req' });
         t
       end
  | Rule(n,descr,hyp,concl,constra) -> 
      let tmp_bound = !current_bound_vars in
      current_bound_vars := [];
      let rhyp = List.map copy_fact hyp in
      let rconcl = copy_fact concl in
      let rconstra = List.map copy_constra constra in
      let rdescr = 
	match descr with
	  ProcessRule(hypspec,name_params) -> 
	    ProcessRule(hypspec,List.map copy_term name_params)
	| ProcessRule2(hypspec,name_params1,name_params2) -> 
	    ProcessRule2(hypspec,List.map copy_term name_params1,List.map copy_term name_params2)
	| x -> x
      in
      cleanup();
      current_bound_vars := tmp_bound;
      { desc = FRule(n, rdescr, rconstra, List.map (fun f -> { desc = FEmpty; thefact = f }) rhyp);
	thefact = rconcl }
  | Resolution(h1, n, h2) ->
      let t1 = build_fact_tree h1 in
      let t2 = build_fact_tree h2 in
      let d = get_desc "resolution" t2 n in
      begin
	try 
          unify_facts t1.thefact d.thefact
	with Unify -> raise HistoryUnifyError
      end;
      d.desc <- t1.desc;
      t2

(* Abbreviate some terms in a derivation *)


let abbreviate_derivation tree =
  let abbrev_table = ref [] in
  let rec find_abbrev t = function
      [] -> 
	begin
	  match t with
	    FunApp(f,l) -> 
	      let f_base_name = 
		try
		  let pos = String.rindex f.f_name '_' in
		  String.sub f.f_name 0 pos
		with Not_found -> f.f_name
	      in
	      let t'' = Var (Terms.new_var f_base_name (snd f.f_type)) in
	      abbrev_table := (t'',t) :: (!abbrev_table);
	      t''
	  | _ -> Parsing_helper.internal_error "Function application expected in find_abbrev"
	end
    | (t'',t')::l ->
	if Terms.equal_terms t t' then
	  t'' 
	else
	  find_abbrev t l
  in
  let rec abbrev_term = function
      Var { link = TLink t } -> abbrev_term t
    | Var { link = VLink v } -> (Var v)
    | Var v -> Var v
    | FunApp(f,l) ->
	let l' = List.map abbrev_term l in
	match f.f_cat, l with
	  (Name _), (_::_) -> 
	    (* Abbreviate names with arguments *)
	    find_abbrev (FunApp(f,l')) (!abbrev_table)
	| _ -> FunApp(f,l')
  in
  let abbrev_fact = function
      Pred(p,l) -> Pred(p, List.map abbrev_term l)
    | Out(t,l) -> Out(abbrev_term t, List.map (fun (v,t) -> (v, abbrev_term t)) l)
  in
  let abbrev_constra = List.map (List.map (function Neq(t1,t2) -> Neq(abbrev_term t1, abbrev_term t2))) in
  let rec abbrev_tree tree = 
    { desc = 
      begin
	match tree.desc with
	  (FEmpty | FHAny | FRemovedWithProof _) as x -> x
	|	FRule(n, descr, constra, hl) -> 
	    FRule(n, descr, abbrev_constra constra, List.map abbrev_tree hl)
	|	FEquation h -> FEquation (abbrev_tree h)
      end;
      thefact = abbrev_fact tree.thefact
    } 
  in
  let tree' = abbrev_tree tree in
  (!abbrev_table, tree')

let display_abbrev_table l =
  print_string "Abbreviations:";
  Display.newline();
  List.iter (fun (t'',t') ->
    Display.display_term t'';
    print_string " = ";
    Display.display_term t';
    Display.newline()) (List.rev l);
  Display.newline()



let build_history (subgoals, orig_fact, hist_done, constra) =
  if !current_bound_vars != [] then
    Parsing_helper.internal_error "bound vars should be cleaned up (history)";
  if not (!Param.reconstruct_derivation) then 
    begin
      if !Param.typed_frontend then
	print_string "I do not reconstruct derivations.\nIf you want to reconstruct them, add\n   set reconstructDerivation = true. \nto your script."
      else
	print_string "I do not reconstruct derivations.\nIf you want to reconstruct them, add\n   param reconstructDerivation = true. \nto your script.";
      { desc = FEmpty; thefact = orig_fact }
    end
  else
  try 
    let new_tree0 = build_fact_tree hist_done in
    let new_tree1 =
      if !Param.simplify_derivation then
	begin
	  TreeHashtbl.clear tree_hashtbl;
	  let r = simplify_tree new_tree0 in
	  TreeHashtbl.clear tree_hashtbl;
	  r
	end
      else
	new_tree0
    in
    if !Param.display_derivation then
      begin
	if !Param.abbreviate_derivation then
	  let (abbrev_table, new_tree2) = abbreviate_derivation new_tree1 in
	  if abbrev_table != [] then display_abbrev_table abbrev_table;
	  if !Param.explain_derivation then
	    explain_history_tree new_tree2
	  else
	    display_history_tree "" new_tree2
	else
	  if !Param.explain_derivation then
	    explain_history_tree new_tree1
	  else
	    display_history_tree "" new_tree1
      end;
    new_tree1
  with HistoryUnifyError ->
      if ((!Param.max_hyp) >= 0) || ((!Param.max_depth) >= 0) then
      begin
        print_string "You have probably found a false attack due to the limitations\non depth of terms and/or number of hypotheses.\nI do not know if there is a real attack.\n";
        cleanup();
        { desc = FEmpty; thefact = orig_fact }
      end
      else
        internal_error "Unification failed in history rebuilding"
    | InternalError s ->
        internal_error s

