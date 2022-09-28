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
open Ptree
open Piptree
open Types
open Pitypes
open Stringmap

let occ_count = ref 0

let new_occurrence () =
  incr occ_count;
  !occ_count

(* Parse a file *)

let parse filename = 
  try
    let ic = open_in filename in
    let lexbuf = Lexing.from_channel ic in
    lexbuf.Lexing.lex_curr_p <- { lexbuf.Lexing.lex_curr_p with 
                                  Lexing.pos_fname = filename };    
    let ptree =
      try
        Piparser.all Pilexer.token lexbuf
      with Parsing.Parse_error ->
        input_error "Syntax error" (extent lexbuf)
    in
    close_in ic;
    ptree
  with Sys_error s ->
    user_error ("File error: " ^ s ^ "\n")

let fun_decls = Param.fun_decls

let create_name s arity is_free =
  let cat = Name { prev_inputs = None; prev_inputs_meaning = [] } in
   { f_name = s; 
     f_type = 
       if arity = -1 then
	 Param.tmp_type, Param.any_type
       else
	 (Terms.copy_n arity Param.any_type), Param.any_type;
     f_cat = cat;
     f_initial_cat = cat;
     f_private = not is_free;
     f_options = 0 }

let create_name_uniq s arity is_free =
  let cat = Name { prev_inputs = None; prev_inputs_meaning = [] } in
   { f_name = s ^ "_" ^ (string_of_int (Terms.new_var_name())); 
     f_type =  
       if arity = -1 then
	 Param.tmp_type, Param.any_type
       else
	 (Terms.copy_n arity Param.any_type), Param.any_type;
     f_cat = cat;
     f_initial_cat = cat;
     f_private = not is_free;
     f_options = 0 }


let check_fun_decl is_tuple (name,ext) arity is_private =
  if Hashtbl.mem fun_decls name then
    input_error ("function " ^ name ^ " already defined") ext;
  let cat = if is_tuple (* || ((arity == 0) && (not is_private)) *) then Tuple else Eq [] in
  Hashtbl.add fun_decls name 
    { f_name = name;
      f_type = (Terms.copy_n arity Param.any_type), Param.any_type;
      f_cat = cat;
      f_initial_cat = cat;
      f_private = is_private;
      f_options = 0 }

let get_var env s =
  try 
    Hashtbl.find env s
  with Not_found -> 
    let r = Terms.new_var s Param.any_type in
    Hashtbl.add env s r;
    r

let get_fun (s,ext) arity =
  try
    if s = "choice specident" then
      input_error "choice not allowed here" ext;
    let r = Hashtbl.find fun_decls s in
    let r_arity = List.length (fst r.f_type) in
    if r_arity != arity then
      input_error ("function " ^ s ^ " has arity " ^
		   (string_of_int r_arity) ^
		   " but is used with " ^
		   (string_of_int arity) ^
		   " parameters") ext;
    r
  with Not_found ->
    input_error ("function " ^ s ^ " not defined") ext

let f_eq_tuple f ext =
  match f.f_cat with
    Eq _ | Tuple -> ()
  | _ -> input_error ("function " ^ f.f_name ^ " has been defined by reduction. It should not appear in equations or clauses") ext

let f_any f ext = ()

let rec check_eq_term f_allowed varenv (term,ext) = 
  match term with
    (PIdent (s,ext)) -> 
      begin
	try
	  let f = Hashtbl.find fun_decls s in
	  let f_arity = List.length (fst f.f_type) in
	  if f_arity <> 0 then 
	    input_error ("function " ^ s ^ " has arity " ^ 
			 (string_of_int f_arity) ^
			 " but is used without parameters") ext;
	  f_allowed f ext;
	  FunApp(f, [])
	with
	  Not_found -> Var (get_var varenv s)
      end
  | (PFunApp (fi, tlist)) ->
      let f = get_fun fi (List.length tlist) in
      f_allowed f ext;
      FunApp(f, List.map (check_eq_term f_allowed varenv) tlist)
  | (PTuple tlist) ->
      FunApp (Terms.get_tuple_fun (List.map (fun _ -> Param.any_type) tlist), 
              List.map (check_eq_term f_allowed varenv) tlist)

let check_equation (t1, t2) =
   let var_env = Hashtbl.create 7 in
   let t1' = check_eq_term f_eq_tuple var_env t1 in
   let t2' = check_eq_term f_eq_tuple var_env t2 in
   TermsEq.register_equation (t1',t2')

let check_red tlist is_private =
  match tlist with 
    ((PFunApp((f,ext),l),_),_)::_ ->
      begin 
	if f = "choice specident" then
	  input_error "choice not allowed here" ext;	
        if Hashtbl.mem fun_decls f then
          input_error ("function " ^ f ^ " already defined") ext;
	let red_list = List.map 
              (function ((PFunApp((f',ext'),l1),_), t2) -> 
                if f <> f' then 
                  input_error ("In reductions, all rules should begin with the same function " ^ f) ext';
                let var_env = Hashtbl.create 7 in
                let ((lhs, rhs) as red) = (List.map (check_eq_term f_eq_tuple var_env) l1, 
					   check_eq_term f_eq_tuple var_env t2)
		in
		let var_list_rhs = ref [] in
		Terms.get_vars var_list_rhs rhs;
		if not (List.for_all (fun v -> List.exists (Terms.occurs_var v) lhs) (!var_list_rhs)) then
		  Parsing_helper.input_error "All variables of the right-hand side of a \"reduc\" definition\nshould also occur in the left-hand side." ext';
		red
                | (_, ext1), _ -> input_error ("In reductions, all rules should begin with function application") ext1) tlist
	in
	begin
	  match red_list with
	    [] -> internal_error "reduction with empty list"
	  | (lhs,_)::r ->
	      let arity = List.length lhs in
	      List.iter (fun (lhs',_) ->
		if List.length lhs' != arity then
		  input_error ("the function " ^ f ^ " does not have the same number of arguments in all rewrite rules") ext) r
	end;
	let cat = Red red_list in
        let fsymb = { f_name = f;
                      f_type = (List.map (fun _ -> Param.any_type) l), Param.any_type;
                      f_private = is_private;
		      f_options = 0;
                      f_cat = cat;
		      f_initial_cat = cat
		    }
        in
        Hashtbl.add fun_decls f fsymb
      end
  | ((_, ext1), _) :: l -> input_error ("In reductions, all rules should begin with function application") ext1
  | [] -> internal_error "reduction with empty list"

(* Check clauses *)
	
let pred_env = Param.pred_env

let rec interpret_info arity r = function
      ("memberOptim", ext) -> 
	if arity != 2 then
	  input_error "memberOptim makes sense only for predicates of arity 2" ext;
	r.p_prop <- r.p_prop lor Param.pred_ELEM
    | ("refTransAtt", ext) ->
	if arity != 2 then
	  input_error "refTransAtt makes sense only for predicates of arity 2" ext;
	r.p_prop <- r.p_prop lor Param.pred_REFTRANS
    | ("decompData",ext) -> r.p_prop <- r.p_prop lor Param.pred_TUPLE
    | ("decompDataSelect",_) -> r.p_prop <- r.p_prop lor Param.pred_TUPLE lor Param.pred_TUPLE_SELECT
    | ("block",_) -> r.p_prop <- r.p_prop lor Param.pred_BLOCKING
	  (* add other qualifiers here *)
    | (s,ext) -> input_error ("unknown predicate qualifier " ^ s) ext

let check_pred (c,ext) arity info =
  if c = "attacker" || c = "mess" || c = "ev" || c = "evinj" then
    input_error ("predicate name " ^ c ^ " is reserved. You cannot declare it") ext;
  if Hashtbl.mem pred_env c then
    input_error ("predicate " ^ c ^ " already declared") ext;
  let r = { p_name = c; 
	    p_type = Terms.copy_n arity Param.any_type; 
	    p_prop = 0; 
	    p_info = [] } in
  List.iter (interpret_info arity r) info;
  Hashtbl.add pred_env c r

let get_pred (c,ext) arity =
  try
    let r =  Hashtbl.find pred_env c in
    let r_arity = List.length r.p_type in
    if arity != r_arity then
      input_error ("arity of predicate " ^ c ^ 
		   " should be " ^ (string_of_int r_arity)) ext;
    r
  with Not_found ->
    input_error ("undeclared predicate " ^ c ) ext


let add_rule hyp concl constra tag =
  Param.red_rules := (hyp, concl, constra, tag) :: (!Param.red_rules)


let equal_pred = Param.get_pred (Equal(Param.any_type))

let check_cterm env (p,t) =
   (get_pred p (List.length t), List.map (check_eq_term f_any env) t)

let rec check_one_hyp (hyp_accu,constra_accu) env (fact, ext) = 
  match fact with
  | PSNeq(t1,t2) -> (hyp_accu, [Neq(check_eq_term f_any env t1, check_eq_term f_any env t2)] ::
		     constra_accu)
  | PSEqual(t1,t2) -> (Pred(equal_pred, [check_eq_term f_any env t1; check_eq_term f_any env t2])::hyp_accu, constra_accu)
  | PSimpleFact(p,l) ->
      let (p',l') = check_cterm env (p,l) in
      (Pred(p',l')::hyp_accu, constra_accu)

let check_simple_fact env (fact, ext) = 
  match fact with
  | PSNeq(t1,t2) -> input_error "<> fact not allowed here" ext
  | PSEqual(t1,t2) -> input_error "= fact not allowed here" ext
  | PSimpleFact(p,l) ->
      let (p',l') = check_cterm env (p,l) in
      Pred(p',l')

let check_clause = function
    PClause(i,c) ->
      begin
      try 
	let env = Hashtbl.create 7 in
	let (hyp, constra) = List.fold_right (fun onehyp accu -> check_one_hyp accu env onehyp) i ([],[]) in
	let concl = check_simple_fact env c in
	add_rule hyp concl
	  (Rules.simplify_constra_list (concl :: hyp) constra) LblClause
      with Rules.FalseConstraint -> ()
      end
  | PEquiv(i,c,select) ->
      let env = Hashtbl.create 7 in
      let (hyp, constra) = List.fold_right (fun onehyp accu -> check_one_hyp accu env onehyp) i ([],[]) in
      if constra != [] then 
	Parsing_helper.user_error "Inequality constraints not allowed in equivalences";
      let concl = check_simple_fact env c in
      add_rule hyp concl [] LblEquiv;
      List.iter (fun h -> add_rule [concl] h [] LblEquiv) hyp;
      Rules.add_equiv (hyp, concl, -1); (* TO DO should give a real rule number, but that's not easy... *)
      if not select then Terms.add_unsel concl

      

(* Environment of a process.
   May contain function symbols, names and variables.
   Is a map from strings to the description of the ident *)

type envElement = EFun of funsymb
                | EVar of binder
                | EName of funsymb

let glob_table = Hashtbl.create 7

let init_env () =
   let m = ref StringMap.empty in
   Hashtbl.iter (fun s f -> 
     m := StringMap.add s (EFun f) (!m);
     Hashtbl.add glob_table s (EFun f)) fun_decls;
   !m 

let clear_var_env () =
  let list_var = ref [] in
  Hashtbl.iter (fun s v ->
    match v with
      EVar b -> list_var := s :: (!list_var)
    | _ -> ()) glob_table;
  List.iter (fun s -> Hashtbl.remove glob_table s) (!list_var)

let check_single ext s =
  let vals = Hashtbl.find_all glob_table s in
  match vals with
    _::_::_ -> input_error (s ^ " cannot be used in queries. Its definition is ambiguous. (For example, several restrictions might define " ^ s ^ ".)") ext
  | _ -> ()
  

(* List of the free names of the process *)

let freenames = Param.freenames

let add_free_name is_pub s =
  let r = create_name s 0 is_pub in 
  Hashtbl.add glob_table s (EName r);
  freenames := r :: !freenames;
  r

let get_non_interf_name (s,ext) =
   try
     match Hashtbl.find glob_table s  with
       | EName r -> 
	   check_single ext s;
	   if not r.f_private then
	     input_error ("Non-interference is certainly false on public values, such as " ^ s) ext
	   else
	     r
       | _ ->
	   input_error ("Non-interference can only be tested on private free names") ext
   with Not_found ->
     input_error ("Name " ^ s ^ " is not declared") ext


(* Look for a name in the list of free names.
   If not found, add it *)

let free_name s ext =
   try
     List.find (fun r -> r.f_name = s) (!freenames)
   with Not_found ->
     input_warning ("Free name " ^ s ^ " not declared") ext;
     add_free_name true s

(* Check non-interference terms *)

let rec check_ni_term varenv (term,ext) = 
  match term with
    (PIdent (s,ext)) -> 
      begin
	try
	  let f = Hashtbl.find fun_decls s in
	  let f_arity = List.length (fst f.f_type) in
	  if f_arity <> 0 then 
	    input_error ("function " ^ s ^ " has arity " ^ 
			 (string_of_int f_arity) ^
			 " but is used without parameters") ext;
	  (match f.f_cat with
            Eq _ | Tuple -> ()
	  | _ -> input_error ("function " ^ s ^ " has been defined by reduction. It should not appear in non-interference queries") ext);
	  FunApp(f, [])
	with Not_found ->
	  try
	    match Hashtbl.find glob_table s  with
              EName r -> 
		check_single ext s;
		if fst r.f_type == Param.tmp_type then
		  internal_error "Arity of a name uninitialized"
		else
		  FunApp (r, Terms.var_gen (fst r.f_type))
	    | EFun _ | EVar _ -> internal_error "should not find var/fun here"
	  with Not_found ->
	    Var (get_var varenv s)
      end
| (PFunApp ((s,ext) as fi, tlist)) ->
    let f = get_fun fi (List.length tlist) in
    (match f.f_cat with
      Eq _ | Tuple -> ()
    | _ -> input_error ("function " ^ s ^ " has been defined by reduction. It should not appear in non-interference queries") ext);
    FunApp(f, List.map (check_ni_term varenv) tlist)
| (PTuple tlist) ->
    FunApp (Terms.get_tuple_fun (List.map (fun _ -> Param.any_type) tlist), 
            List.map (check_ni_term varenv) tlist)

(* Get an ident when anything is allowed *)

let get_ident_any s env ext =
   try
     match StringMap.find s env with
         EVar b -> Var b
       | EName r -> FunApp (r,[])
       | EFun f -> 
	   let f_arity = List.length (fst f.f_type) in
	   if f_arity = 0 then
	     FunApp(f,[])
	   else
	     input_error ("function " ^ s ^ " has arity " ^ 
			  (string_of_int f_arity) ^
			  " but is used without parameters") ext
   with Not_found ->
     FunApp(free_name s ext, [])

let get_fun (s,ext) arity env =
  try
    match StringMap.find s env with
      EFun f -> 
	let f_arity = List.length (fst f.f_type) in
	if f_arity = arity then
	  f
	else
	  input_error ("function " ^ s ^ 
		       " should be applied to " ^ 
		       (string_of_int f_arity) ^ " arguments")
	    ext
    | _ ->
	input_error ("only functions can be applied, not " ^ s) ext
  with Not_found ->
    input_error ("function " ^ s ^ " not defined") ext


let rec check_term env (term, _) =
  match term with 
    (PIdent (s,ext)) -> get_ident_any s env ext
  | (PFunApp((s,ext) as fi,l)) -> 
      let f = 
	if s = "choice specident" then 
	  Param.choice_fun Param.any_type 
	else
	  get_fun fi (List.length l) env  
      in
      FunApp(f, List.map (check_term env) l)
  | (PTuple l) -> FunApp(Terms.get_tuple_fun (List.map (fun _ -> Param.any_type)l),
                         List.map (check_term env) l)

let check_fl_term env (p,t) =
   (get_pred p (List.length t), List.map (check_term env) t)

let pdeftbl = (Hashtbl.create 7 : (string, Piptree.process) Hashtbl.t)

let rec check_pat env = function
  PPatVar (s,e) -> 
    if (StringMap.mem s env) && (!Param.tulafale != 1) then
      input_warning ("identifier " ^ s ^ " rebound") e;
    let v = Terms.new_var s Param.any_type in
    (PatVar v, StringMap.add s (EVar v) env)
| PPatTuple l ->
    let (l',env') = check_pat_list env l in
    (PatTuple(Terms.get_tuple_fun (List.map (fun _ -> Param.any_type) l), l'), env')
| PPatFunApp((s,ext) as fi,l) ->
    let (l',env') = check_pat_list env l in
    let f = get_fun fi (List.length l) env  in
    if f.f_cat <> Tuple then
      input_error ("only data functions are allowed in patterns, not " ^ s) ext;
    (PatTuple(f, l'), env')
| PPatEqual t ->
    (PatEqual(check_term env t), env)

and check_pat_list env = function
  [] -> ([], env)
| (a::l) -> 
    let (a',env') = check_pat env a in
    let (l',env'') = check_pat_list env' l in
    (a'::l', env'')
	

let event_fun_table = Hashtbl.create 7

let get_event_fun s arity ext =
  try
    let p = Hashtbl.find event_fun_table s in
    let p_arity = List.length (fst p.f_type) in
    if p_arity != arity then
      input_error ("function " ^ s ^ " has arity " ^ 
		   (string_of_int p_arity) ^
		   " but is used with arity " ^ (string_of_int arity)) ext;
    p
  with Not_found ->
    let p = { f_name = s; 
	      f_type = (Terms.copy_n arity Param.any_type), Param.any_type; 
	      f_cat = Eq[]; 
	      f_initial_cat = Eq[]; 
	      f_private = true;
              f_options = 0 } in
    Hashtbl.add event_fun_table s p;
    p

let rec check_process env = function 
    PNil -> Nil
  | PPar (p1,p2) -> 
      Par(check_process env p1, check_process env p2)
  | PRepl p -> 
      Repl(check_process env p, new_occurrence())
  | PTest((f,_),p1,p2) -> 
      begin
	match f with
	  PSimpleFact(pred,l) ->
	    let (pred',l') = check_fl_term env (pred,l) in
	    LetFilter([], Pred(pred',l'), check_process env p1, check_process env p2, new_occurrence())
	| PSEqual(t1,t2) ->
	    Test(check_term env t1, check_term env t2,
		 check_process env p1, check_process env p2, new_occurrence())
	| PSNeq(t1,t2) ->
	    Test(check_term env t1, check_term env t2,
		 check_process env p2, check_process env p1, new_occurrence())
      end
  | PLetDef (s,ext) ->
      begin
	try
          check_process env (Hashtbl.find pdeftbl s)
        with Not_found ->
          input_error ("process " ^ s ^ " not defined") ext
      end
  | PRestr((s,ext),p) -> 
      let r = create_name_uniq s (-1) false in
      Hashtbl.add glob_table s (EName r);
      if (StringMap.mem s env) && (!Param.tulafale != 1) then
	input_warning ("identifier " ^ s ^ " rebound") ext;
      Restr(r, check_process (StringMap.add s (EName r) env) p)
  | PInput(tc,pat,p) ->
      let (pat',env') = check_pat env pat in
      Input(check_term env tc, pat',
	    check_process env' p, new_occurrence())
  | POutput(tc,t,p) ->
      Output(check_term env tc,
	     check_term env t,
	     check_process env p, new_occurrence())
  | PLet(pat,t,p,p') ->
      let (pat', env') = check_pat env pat in
      Let(pat',check_term env t,check_process env' p,check_process env p', new_occurrence())
  | PLetFilter(identlist,(f,ext),p,q) ->
      let (env', vlist) = List.fold_left (fun (env, vlist) (s,e) ->
	if (StringMap.mem s env) && (!Param.tulafale != 1) then
	  input_warning ("identifier " ^ s ^ " rebound") e;
	let v = Terms.new_var s Param.any_type in
	(StringMap.add s (EVar v) env, v:: vlist)) (env,[]) identlist in
      let vlist = List.rev vlist in
      let f' = match f with
	PSEqual(t1,t2) -> 
	  Pred(equal_pred, [check_term env' t1; check_term env' t2])
      |	PSNeq(t1,t2) -> 
	  input_error "<> fact not allowed here" ext
      |	PSimpleFact(pred, l) -> 
	  let (pred',l') = check_fl_term env' (pred,l) in
	  Pred(pred',l')
      in
      LetFilter(vlist, f', check_process env' p, check_process env q, new_occurrence())
  | PEvent((i,ext),l,p) ->
      if !Param.key_compromise == 0 then
	let f = get_event_fun i (List.length l) ext in
	Event(FunApp(f, List.map (check_term env) l), check_process env p, new_occurrence())
      else
	let f = get_event_fun i (1+List.length l) ext in
	Event(FunApp(f, (Terms.new_var_def Param.any_type) :: (List.map (check_term env) l)), check_process env p, new_occurrence())
  | PPhase(n, p) ->
      Phase(n, check_process env p)

let get_non_interf (id, lopt) =
  (get_non_interf_name id, 
   match lopt with
     None -> None
   | Some l -> Some (List.map (check_ni_term (Hashtbl.create 7)) l))

let query_list = ref ([] : Piptree.query list list)
let need_vars_in_names = Reduction_helper.need_vars_in_names
let noninterf_list = ref ([] : (funsymb * term list option) list list)
let not_list = ref ([] : ((Piptree.gfact_e * int) * (Piptree.ident * Piptree.gterm_e) list) list)
let nounif_list = ref ([] : (Piptree.gfact_format * int * (Piptree.ident * Piptree.gformat_e) list) list)
let weaksecret_list = ref ([] : funsymb list)

(* Compute need_vars_in_names: the list of pairs (restriction, variable name)
   such that the variable "variable name" must occur as argument in the
   pattern that models names created by "restriction", because the
   structure "restriction[... variable name = ... ]" is used in the input 
   file. *)

let rec nvn_t (term, ext0) =
  match term with
    PGIdent (s,ext) -> ()
  | PGFunApp((s,ext),l) -> List.iter nvn_t l
  | PGTuple l -> List.iter nvn_t l
  | PGName ((s,ext),bl) ->
      List.iter (fun ((s',ext'),t) -> 
	(* The replication indices do not need to be added in 
	   need_vars_in_names, because they are always included as
	   arguments of names, whether or not they occur in 
	   the input file. 
	   They must not be added to need_vars_in_names, because 
	   they are not correctly computed by trace reconstruction,
	   so adding them would cause bugs in trace reconstruction. *)
	if (s' <> "") && (s'.[0] != '!') then
	  begin
	    try 
	      match Hashtbl.find glob_table s with
		EName r ->
	          (* print_string ("Need " ^ s' ^ " in " ^ r.f_name ^ "\n");  *)
		  need_vars_in_names := (r.f_name, s',ext') :: (!need_vars_in_names)
	      |	_ -> ()
	    with Not_found ->
	      ()
	  end;
	  need_vars_in_names := (s, s',ext') :: (!need_vars_in_names);
	nvn_t t
						) bl

let nvn_b ((i,e),t) =
  nvn_t t

let nvn_e ((f,e),n) =
  match f with
    PGNeq(t1,t2) -> nvn_t t1; nvn_t t2
  | PGEqual(t1,t2) -> nvn_t t1; nvn_t t2
  | PGSimpleFact(_, tl) ->
      List.iter nvn_t tl

let rec nvn_rq  = function
    PBefore(ev, hyp) ->
      nvn_e ev;
      nvn_he hyp

and nvn_he = function
    PQEvent(ev) -> nvn_e ev
  | PNestedQuery(q) -> nvn_rq q
  | POr(he1,he2) -> nvn_he he1; nvn_he he2
  | PAnd(he1,he2) -> nvn_he he1; nvn_he he2
  | PFalse -> ()

let nvn_q  = function
    PRealQuery q -> nvn_rq q
  | PPutBegin(i, l) -> ()
  | PBinding(i,t) -> nvn_t t

let rec nvn_f (f,ext0) = 
  match f with
    PFGIdent (s,ext) -> ()
  | PFGFunApp((s,ext),l) -> List.iter nvn_f l
  | PFGTuple l -> List.iter nvn_f l
  | PFGName ((s,ext),bl) ->
      List.iter (fun ((s',ext'),t) -> 
	(* The replication indices do not need to be added in 
	   need_vars_in_names, because they are always included as
	   arguments of names, whether or not they occur in 
	   the input file. 
	   They must not be added to need_vars_in_names, because 
	   they are not correctly computed by trace reconstruction,
	   so adding them would cause bugs in trace reconstruction. *)
	if (s' <> "") && (s'.[0] != '!') then
	  begin
	    try 
	      match Hashtbl.find glob_table s with
		EName r ->
	          (* print_string ("Need " ^ s' ^ " in " ^ r.f_name ^ "\n");  *)
		  need_vars_in_names := (r.f_name, s',ext') :: (!need_vars_in_names)
	      |	_ -> ()
	    with Not_found ->
	      ()
	  end;
	nvn_f t
						) bl
  | PFGAny (s,ext) -> ()

let nvn_ff (id,fl,n) =
  List.iter nvn_f fl

(* Handle all declarations *)

let rec check_all = function
    (FunDecl (f,i,is_private))::l -> 
      check_fun_decl false f i is_private;
      check_all l
  | (DataFunDecl (f,i))::l -> 
      check_fun_decl true f i false;
      check_all l
  | (Equation eq)::l ->
      check_equation eq;
      check_all l
  | (Reduc (r,is_private))::l -> 
      check_red r is_private; 
      check_all l
  | (PredDecl (p, arity, info)) :: l ->
      check_pred p arity info;
      check_all l
  | (PDef ((s,ext),p)) :: l -> 
      Hashtbl.add pdeftbl s p; 
      check_all l
  | (Query q) :: l -> 
      query_list := q :: (!query_list); 
      check_all l
  | (Noninterf lnoninterf) :: l -> 
      noninterf_list := (List.map get_non_interf lnoninterf) :: (!noninterf_list); 
      check_all l
  | (Weaksecret i) :: l ->
      weaksecret_list := (get_non_interf_name i) ::(!weaksecret_list);
      check_all l
  | (NoUnif (fact,n,bl)) :: l ->
      nounif_list := (fact, n, bl) :: (!nounif_list);
      check_all l
  | (Elimtrue fact) :: l ->
      let env = Hashtbl.create 7 in
      Param.elim_true := (check_simple_fact env fact) :: (!Param.elim_true);
      check_all l
  | (Not (((_,e) as f,n),b)) :: l -> 
      not_list := ((f,n),b) :: (!not_list); 
      check_all l
  | (Free (il,b)) :: l -> 
      List.iter (fun (i,ext) -> 
	if (List.exists (fun r -> r.f_name = i) (!freenames)) && (!Param.tulafale != 1) then
	  input_error ("free name " ^ i ^ " already declared") ext;
	ignore(add_free_name (not b) i)) il;
      check_all l
  | (Clauses c) :: l ->
      List.iter check_clause c;
      check_all l
  | (Param((p,ext),v)) :: l -> 
      begin
	match (p,v) with
	  "attacker", S ("passive",_) -> Param.active_attacker := false
	| "attacker", S ("active",_) -> Param.active_attacker := true
	| "keyCompromise", S ("strict",_) -> Param.key_compromise := 2
	| "keyCompromise", S ("approx",_) -> Param.key_compromise := 1
	| "keyCompromise", S ("none",_) -> Param.key_compromise := 0
	| "movenew", _ -> Param.boolean_param Param.move_new p ext v
	| "verboseClauses", S ("explained",_) -> Param.verbose_explain_clauses := Param.ExplainedClauses
	| "verboseClauses", S ("short",_) -> Param.verbose_explain_clauses := Param.Clauses
	| "verboseClauses", S ("none",_) -> Param.verbose_explain_clauses := Param.NoClauses
	| "explainDerivation", _ -> Param.boolean_param Param.explain_derivation p ext v
	| "predicatesImplementable", S("check",_) -> Param.check_pred_calls := true
	| "predicatesImplementable", S("nocheck",_) -> Param.check_pred_calls := false
	| "eqInNames", _ ->
	    Param.boolean_param Param.eq_in_names p ext v;
	    if !Param.eq_in_names then Param.reconstruct_trace := false
	| "reconstructTrace", _ -> Param.boolean_param Param.reconstruct_trace p ext v
	| "traceBacktracking", _ -> Param.boolean_param Param.trace_backtracking p ext v
	| "unifyDerivation", _ -> Param.boolean_param Param.unify_derivation p ext v
	| "traceDisplay", S ("none",_) -> Param.trace_display := Param.NoDisplay
	| "traceDisplay", S ("short",_) -> Param.trace_display := Param.ShortDisplay
	| "traceDisplay", S ("long",_) -> Param.trace_display := Param.LongDisplay
	| _, _ -> Param.common_parameters p ext v
      end;
      check_all l
  | [Process p] -> 
      let r = check_process (init_env()) p in
      List.iter (List.iter nvn_q) (!query_list);
      List.iter (fun (fact,_,bl) ->
	nvn_ff fact;
	List.iter (fun (_,t) -> nvn_f t) bl) (!nounif_list);
      List.iter (fun (f,b) ->
	nvn_e f;
	List.iter (fun (_,t) -> nvn_t t) b) (!not_list);
      r
  | _ -> internal_error "The first process part is not the last element of the file"

(* Get the maximum phase number *)

let rec set_max_used_phase = function
    Nil -> ()
  | Par(p1,p2) -> set_max_used_phase p1; set_max_used_phase p2
  | Repl (p,_) ->  set_max_used_phase p
  | Restr(n,p) -> set_max_used_phase p
  | Test(_,_,p1,p2,_) -> set_max_used_phase p1; set_max_used_phase p2
  | Input(_,_, p,_) -> set_max_used_phase p
  | Output(_,_,p,_) -> set_max_used_phase p
  | Let(_,_,p1, p2,_) -> set_max_used_phase p1; set_max_used_phase p2
  | LetFilter(_,_,p,q,_) -> set_max_used_phase p; set_max_used_phase q
  | Event(_,p,_) -> set_max_used_phase p
  | Get _ | Insert _ -> Parsing_helper.internal_error "get/insert only in typed front-end"
  | Phase(n,p) ->
      if n > !Param.max_used_phase then
	Param.max_used_phase := n;
      set_max_used_phase p

let parse_file s = 
  let p = check_all (parse s) in
  if !Param.key_compromise = 2 then
    Param.max_used_phase := 1
  else
    set_max_used_phase p;
  p

let display () =
   print_string "Functions ";
   Hashtbl.iter (fun _ fsymb -> 
     print_string (fsymb.f_name ^ "/" ^ (string_of_int (List.length (fst fsymb.f_type))) ^ ". ")
       ) fun_decls;
   print_string "\n"

(* queries *)

let non_compromised_session = FunApp(Param.session1, [])


(* Note: when check_query, get_queries are applied before the
   translation of the process into Horn clauses has been done, 
   the arity of names may not be correctly initialized. In this case,
   update_arity_names should be called after the translation of the
   process to update it.  *)

let get_ident_any s ext =
   try
     match Hashtbl.find glob_table s  with
         EVar b -> 
	   begin
	     match b.link with
	       TLink t -> t
	     | NoLink -> Var b
	     | _ -> internal_error "unexpected link in get_ident_any"
	   end
       | EName r -> 
	   check_single ext s;
	   if fst r.f_type == Param.tmp_type then 
	     let v = Terms.new_var Param.def_var_name Param.any_type in
	     v.link <- PGLink (PGIdent(s, ext),ext);
	     Var v
	   else
	     begin
	       match r.f_cat with 
		 Name { prev_inputs_meaning = sl } ->
		   let p = List.map (fun s'' ->
		     if s'' = "!comp" then 
		       non_compromised_session 
		     else
		       Terms.new_var_def Param.any_type) sl in
		   let r_arity = List.length (fst r.f_type) in
		   if List.length p != r_arity then
		     internal_error ("name " ^ s ^ " expects " ^ (string_of_int r_arity) ^ " arguments, but has " ^ (string_of_int (List.length p)) ^ " elements in prev_inputs_meaning");
		   FunApp(r, p)
	       | _ -> internal_error "name expected here"
	     end
       | EFun f -> 
	   let f_arity = List.length (fst f.f_type) in
	   if f_arity = 0 then 
	     FunApp(f,[]) 
	   else
	     input_error ("function " ^ s ^ " has arity " ^ 
			  (string_of_int f_arity) ^
			  " but is used without parameters") ext
   with Not_found ->
     let b = Terms.new_var s Param.any_type in
     Hashtbl.add glob_table s (EVar b);
     Var b

let rec check_query_term (term, ext0) =
  match term with
    PGIdent (s,ext) -> get_ident_any s ext  
  | PGFunApp((s,ext),l) -> 
      begin
        try
          match Hashtbl.find glob_table s with
            EFun f -> 
              (match f.f_cat with
                 Eq _ | Tuple -> ()
               | _ ->  input_error ("function " ^ s ^ " is defined by reduction. Such a function should not be used in a query") ext);
	      let f_arity = List.length (fst f.f_type) in
	      if f_arity = List.length l then 
		FunApp(f, List.map check_query_term l)
	      else
		input_error ("function " ^ s ^ " has arity " ^ 
			     (string_of_int f_arity) ^
			     " but is used with " ^ 
			     (string_of_int (List.length l)) ^
			     " parameters") ext
          | _ -> input_error("only functions can be applied, not " ^ s) ext
        with Not_found ->
          input_error ("function " ^ s ^ " not defined") ext
      end
  | PGTuple l -> FunApp(Terms.get_tuple_fun (List.map (fun _ -> Param.any_type) l),
                        List.map check_query_term l)
  | PGName ((s,ext),bl) -> 
     try
       match Hashtbl.find glob_table s  with
	 EName r ->
	   check_single ext s;
	   if fst r.f_type == Param.tmp_type then
	     begin
	       let v = Terms.new_var Param.def_var_name Param.any_type in
	       v.link <- PGLink (term,ext0);
	       Var v
	     end
           else
	     begin
	       match r.f_cat with 
		 Name { prev_inputs_meaning = sl } ->
		   List.iter (fun ((s',ext'),_) -> 
		     if not (List.mem s' sl) then
		       input_error ("variable " ^ s' ^ " not defined at restriction " ^ s) ext') bl;
		   let p = List.map (fun s'' ->
		     if s'' = "!comp" then non_compromised_session else
		     binding_find s'' bl) sl in
		   let r_arity = List.length (fst r.f_type) in
		   if List.length p != r_arity then
		     internal_error ("name " ^ s ^ " expects " ^ (string_of_int r_arity) ^ " arguments, but has " ^ (string_of_int (List.length p)) ^ " elements in prev_inputs_meaning");
		   FunApp(r, p)
	       | _ -> internal_error "name expected here"
	     end
     | _ -> input_error (s ^ " should be a name") ext
     with Not_found ->
       input_error (s ^ " should be a name") ext

and binding_find s = function
    [] -> Terms.new_var_def Param.any_type
  | ((s',_),t)::l ->
      if s' = s then
	check_query_term t
      else
	binding_find s l

let add_binding ((i,e),t) =
  if Hashtbl.mem glob_table i then
    input_error ("Variable " ^ i ^ " defined after used.") e
  else
    let v = Terms.new_var i Param.any_type in
    v.link <- TLink (check_query_term t);
    Hashtbl.add glob_table i (EVar v)

let find_event_arity s e'' arity =
  try
    let f = Hashtbl.find event_fun_table s in
    let f_arity = List.length (fst f.f_type) in
    if f_arity != arity then
      input_error ("event " ^ s ^ " has arity " ^ 
		   (string_of_int f_arity) ^
		   " but is used with " ^ 
		   (string_of_int arity) ^
		   " parameters") e''
    else
      f
  with Not_found ->
    input_error ("unknown event " ^s) e''

let check_event ((f,e),n) =
  match f with
    PGNeq(t1,t2) ->
      if n = -1 then QNeq(check_query_term t1,check_query_term t2) else
      input_error "inequalities do not depend on phases, so no phase should be specified in inequality facts in queries" e
  | PGEqual(t1,t2) ->
      if n = -1 then QEq(check_query_term t1,check_query_term t2) else
      input_error "equalities do not depend on phases, so no phase should be specified in equality facts in queries" e
  | PGSimpleFact(("ev",e'),tl0) ->
      begin
	match tl0 with
	  [PGFunApp((s,e''), tl),_] ->
	    if n = -1 then 
	      if !Param.key_compromise == 0 then
		QSEvent(false, FunApp((find_event_arity s e'' (List.length tl)),
				      List.map check_query_term tl))
	      else
		QSEvent(false, FunApp((find_event_arity s e'' (1+List.length tl)),
				      (Terms.new_var_def Param.any_type)::(List.map check_query_term tl)))
	    else
	      input_error "events have no phases, so no phase should be specified in events in queries" e
	| _ -> input_error "predicate ev should have one argument, which is a function application" e'
      end
  | PGSimpleFact(("evinj",e'),tl0) ->
      begin
	match tl0 with
	  [PGFunApp((s,e''), tl),_] ->
	    if n = -1 then 
	      if !Param.key_compromise == 0 then
		QSEvent(true, FunApp((find_event_arity s e'' (List.length tl)), 
				     List.map check_query_term tl))
	      else
		QSEvent(true, FunApp((find_event_arity s e'' (1+List.length tl)), 
				     (Terms.new_var_def Param.any_type)::(List.map check_query_term tl)))
	    else
	      input_error "events have no phases, so no phase should be specified in events in queries" e
	| _ -> input_error "predicate evinj should have one argument, which is a function application" e'
      end
  | PGSimpleFact(("attacker",_), tl) ->
      if List.length tl != 1 then
	input_error "arity of predicate attacker should be 1" e;
      if n > !Param.max_used_phase then
	begin
	  input_warning "phase greater than the maximum phase used in the process.\nIs that really what you want?" e;
	  Param.max_used_phase := n;
	end;
      let att_n = Param.get_pred (Attacker((if n = -1 then (!Param.max_used_phase) else n), Param.any_type)) in
      QFact(att_n, List.map check_query_term tl)
  | PGSimpleFact(("mess",_), tl) ->
      if List.length tl != 2 then
	input_error "arity of predicate mess should be 2" e;
      if n > !Param.max_used_phase then
	begin
	  input_warning "phase greater than the maximum phase used in the process.\nIs that really what you want?" e;
	  Param.max_used_phase := n;
	end;
      let mess_n = Param.get_pred (Mess((if n = -1 then (!Param.max_used_phase) else n), Param.any_type)) in
      QFact(mess_n, List.map check_query_term tl)
  | PGSimpleFact(p, tl) ->
      if n != -1 then
	input_error "declared predicates do not depend on phases, so no phase should be specified in such facts in queries" e;
      let p = get_pred p (List.length tl) in
      QFact(p, List.map check_query_term tl)

let rec check_real_query = function
    PBefore(ev, hypll) ->
      let ev' = check_event ev in
      (
       match ev' with
	 QNeq _ | QEq _ -> user_error "Inequalities or equalities cannot occur before ==> in queries\n"
       | _ -> ()
      );
      let hypll' = check_hyp hypll in
      Before(ev', hypll')

and check_hyp = function
    PQEvent(ev) -> [[QEvent(check_event ev)]]
  | PNestedQuery(q) -> [[NestedQuery(check_real_query q)]]
  | PFalse -> []
  | POr(he1,he2) -> 
      (check_hyp he1) @ (check_hyp he2)
  | PAnd(he1,he2) ->
      let he1' = check_hyp he1 in
      let he2' = check_hyp he2 in
      List.concat (List.map (fun e1 -> List.map (fun e2 -> e1 @ e2) he2') he1')

let check_real_query_top = function
    PBefore(ev, hypll) ->
      let ev' = check_event ev in
      let ev'' = 
	match ev' with
	  QNeq _ | QEq _ -> user_error "Inequalities or equalities cannot occur before ==> in queries\n"
	| QFact _ -> ev'
	| QSEvent _ when !Param.key_compromise == 0 -> ev'
	| QSEvent(inj, FunApp(f, sid::l)) ->
	    QSEvent(inj, FunApp(f, non_compromised_session::l))
	| QSEvent(_,_) ->
	    internal_error "Bad format for events in queries"
      in
      let hypll' = check_hyp hypll in
      Before(ev'', hypll')

let check_query = function
    PRealQuery q -> RealQuery(check_real_query_top q)
  | PPutBegin(i, l) ->
      let i' = match i with
	("ev",_) -> false
      | ("evinj",_) -> true
      | (s,e) -> input_error ("ev or evinj expected instead of " ^ s) e
      in
      let l' = List.map (fun (s,e) ->
	try
	  Hashtbl.find event_fun_table s
	with Not_found ->
	  input_error ("unknown event " ^s) e) l
      in
      PutBegin(i',l') 
  | PBinding(i,t) ->
      add_binding (i,t);
      PutBegin(false,[])


let rec has_inj = function
    Before(_,ll) ->
      List.exists (List.exists (function
	  NestedQuery q -> has_inj q
	| QEvent (QSEvent (i,_)) -> i
	| QEvent (_) -> false)) ll

let rec check_inj_coherent_r q = 
  if has_inj q then
    match q with 
      Before(e,ll) ->
	let e' = 
	match e with
	  QFact _ | QNeq _ | QEq _ -> user_error "In a query e ==> h, if h contains an injective event, then e must be an event ev or better evinj\n"
	| QSEvent(_,t) -> QSEvent(true, t) (* set the event injective *)
	in
	Before(e', List.map (List.map (function 
	    QEvent e -> QEvent e
	  | NestedQuery q' -> NestedQuery (check_inj_coherent_r q'))) ll)
  else q

let check_inj_coherent = function
    (PutBegin(_,_) as q) -> q
  | RealQuery q -> RealQuery (check_inj_coherent_r q)


(*
let present_inj_in_query = Hashtbl.create 7

let check_inj_uniq_e = function
    QSEvent(true, FunApp(f,ll)) ->
      begin
	if Hashtbl.mem present_inj_in_query f then
	  user_error "Injective events should be unique in one query\n"
	else
	  Hashtbl.add present_inj_in_query f ()
      end
  | _ -> ()

let rec check_inj_uniq_r = function
    Before(e,ll) ->
      check_inj_uniq_e e;
      List.iter (List.iter (function
	  QEvent e -> check_inj_uniq_e e
	| NestedQuery q -> check_inj_uniq_r q)) ll
      

let check_inj_uniq = function
    PutBegin(_,_) -> ()
  | RealQuery q -> check_inj_uniq_r q
*)

let transl_query q =
  clear_var_env();
  let q' = List.map check_query q in
  let q'' = List.map check_inj_coherent q' in
  Pievent.init_event_status_table event_fun_table;
(*
  List.iter (fun q ->
    Hashtbl.clear present_inj_in_query;
    check_inj_uniq q) q'';
*)
  List.iter Pievent.set_event_status q'';
  q''

(* Give the fact to query from the detailed query
   This is used only to create a resembling specification for SPASS
 *)

let query_to_facts q =
  let facts = ref [] in
  List.iter (function
      PutBegin(_) -> ()
    | RealQuery(Before(e,_)) -> match e with
	QSEvent(_,(FunApp(f,l) as param)) -> 
	  facts := 
	    (if (Pievent.get_event_status f).end_status = Inj then
	      Pred(Param.end_pred_inj, [Var(Terms.new_var "endsid" Param.sid_type);param])
	    else
	      Pred(Param.end_pred, [param])) :: (!facts)
      | QSEvent(_, _) ->
	  user_error ("Events should be function applications\n")
      | QFact(p,l) ->
	  facts := (Pred(p,l)) :: (!facts)
      | QNeq _ | QEq _ -> internal_error "no Neq/Eq queries"
	    ) q;
  !facts

(* After its translation, the names in the query are considered of arity 0.
   The exact arity of each name function symbol is computed during the translation
   of the process. The following functions scan the query to update the names
   with their real arity. *)

let rec update_arity_names_t = function
    Var v ->
      begin
	match v.link with
	  PGLink t -> 
	    let t' = check_query_term t in
	    v.link <- TLink t';
	    t'
	| TLink t -> t
	| NoLink -> Var v
	| _ -> internal_error "unexpected link in update_arity_names_t"
      end
  | FunApp(f,l) -> FunApp(f, List.map update_arity_names_t l)
      

let update_arity_names_e = function
    QSEvent(b,t) -> QSEvent(b, update_arity_names_t t)
  | QFact(p,tl) -> QFact(p, List.map update_arity_names_t tl)
  | QNeq(t1,t2) -> QNeq(update_arity_names_t t1, update_arity_names_t t2)
  | QEq(t1,t2) -> QEq(update_arity_names_t t1, update_arity_names_t t2)

let rec update_arity_names_r = function
    Before(ev,hypll) -> Before(update_arity_names_e ev, List.map (List.map update_arity_names_h) hypll)

and update_arity_names_h = function
    QEvent(ev) -> QEvent(update_arity_names_e ev)
  | NestedQuery(q) -> NestedQuery(update_arity_names_r q)

let update_arity_names = function
    PutBegin(b,l) -> PutBegin(b,l)
  | RealQuery q -> RealQuery(update_arity_names_r q)

let get_noninterf_queries () =
  !noninterf_list

let get_weaksecret_queries () =
  !weaksecret_list

let get_not() =
  List.map (fun (ev,b) -> 
    clear_var_env();
    List.iter add_binding b;
    check_event ev) (!not_list)

(* For Nounif. Very similar to queries, except that *v is allowed
   and events are not allowed *)

let fget_ident_any s ext =
   try
     match Hashtbl.find glob_table s  with
         EVar b -> 
	   begin
	     match b.link with
	       FLink t -> t
	     | NoLink -> FVar b
	     | _ -> internal_error "unexpected link in fget_ident_any"
	   end
       | EName r -> 
	   check_single ext s;
	   if fst r.f_type == Param.tmp_type then 
	     Parsing_helper.internal_error "Names should have their arity at this point"
	   else
	     begin
	       match r.f_cat with 
		 Name { prev_inputs_meaning = sl } ->
		   let p = List.map (fun s'' ->
		     FAny (Terms.new_var Param.def_var_name Param.any_type)) sl in
		   let r_arity = List.length (fst r.f_type) in
		   if List.length p != r_arity then
		     internal_error ("name " ^ s ^ " expects " ^ (string_of_int r_arity) ^ " arguments, but has " ^ (string_of_int (List.length p)) ^ " elements in prev_inputs_meaning");
		   FFunApp(r, p)
	       | _ -> internal_error "name expected here"
	     end
       | EFun f -> 
	   let f_arity = List.length (fst f.f_type) in
	   if f_arity = 0 then 
	     FFunApp(f,[]) 
	   else
	     input_error ("function " ^ s ^ " has arity " ^ 
			  (string_of_int f_arity) ^
			  " but is used without parameters") ext
   with Not_found ->
     let b = Terms.new_var s Param.any_type in
     Hashtbl.add glob_table s (EVar b);
     FVar b


let rec check_gformat (term, ext0) =
  match term with
    PFGIdent (s,ext) -> fget_ident_any s ext  
  | PFGFunApp((s,ext),l) -> 
      begin
        try
          match Hashtbl.find glob_table s with
            EFun f -> 
              (match f.f_cat with
                 Eq _ | Tuple -> ()
               | _ ->  input_error ("function " ^ s ^ " is defined by reduction. Such a function should not be used in a \"nounif\" declaration") ext);
	      let f_arity = List.length (fst f.f_type) in
	      if f_arity = List.length l then 
		FFunApp(f, List.map check_gformat l)
	      else
		input_error ("function " ^ s ^ " has arity " ^ 
			     (string_of_int f_arity) ^
			     " but is used with " ^ 
			     (string_of_int (List.length l)) ^
			     " parameters") ext
          | _ -> input_error("only functions can be applied, not " ^ s) ext
        with Not_found ->
          input_error ("function " ^ s ^ " not defined") ext
      end
  | PFGTuple l -> FFunApp(Terms.get_tuple_fun (List.map (fun _ -> Param.any_type) l),
                          List.map check_gformat l)
  | PFGAny (s,ext) -> 
      begin
	try
	  match Hashtbl.find glob_table s  with
            EVar b -> 
	      begin
		match b.link with
		  NoLink -> FAny b
		| FLink _ -> input_error "variables preceded by * must not be defined by a binding" ext
		| _ -> internal_error "unexpected link in check_gformat"
	      end
	  | _ -> input_error (s ^ " should be a variable") ext
	with Not_found ->
	  let b = Terms.new_var s Param.any_type in
	  Hashtbl.add glob_table s (EVar b);
	  FAny b
      end
  | PFGName ((s,ext),bl) -> 
     try
       match Hashtbl.find glob_table s  with
	 EName r ->
	   check_single ext s;
	   if fst r.f_type == Param.tmp_type then
	     Parsing_helper.internal_error "Names should have their arity at this point"
           else
	     begin
	       match r.f_cat with 
		 Name { prev_inputs_meaning = sl } ->
		   List.iter (fun ((s',ext'),_) -> 
		     if not (List.mem s' sl) then
		       input_error ("variable " ^ s' ^ " not defined at restriction " ^ s) ext') bl;
		   let p = List.map (fun s'' ->
		     fbinding_find s'' bl) sl in
		   let r_arity = List.length (fst r.f_type) in
		   if List.length p != r_arity then
		     internal_error ("name " ^ s ^ " expects " ^ (string_of_int r_arity) ^ " arguments, but has " ^ (string_of_int (List.length p)) ^ " elements in prev_inputs_meaning");
		   FFunApp(r, p)
	       | _ -> internal_error "name expected here"
	     end
     | _ -> input_error (s ^ " should be a name") ext
     with Not_found ->
       input_error (s ^ " should be a name") ext

and fbinding_find s = function
    [] -> FAny (Terms.new_var Param.def_var_name Param.any_type)
  | ((s',_),t)::l ->
      if s' = s then
	check_gformat t
      else
	fbinding_find s l

let add_fbinding ((i,e),t) =
  if Hashtbl.mem glob_table i then
    input_error ("Variable " ^ i ^ " defined after used.") e
  else
    let v = Terms.new_var i Param.any_type in
    v.link <- FLink (check_gformat t);
    Hashtbl.add glob_table i (EVar v)

let check_gfact_format ((s, ext), tl, n) =
  match s with
    "ev" | "evinj" -> 
      input_error "predicates ev and evinj not allowed in nounif" ext
  | "attacker" ->
      if List.length tl != 1 then
	input_error "arity of predicate attacker should be 1" ext;
      if n > !Param.max_used_phase then
	input_warning "nounif declaration for a phase greater than used" ext;
      let att_n = Param.get_pred (Attacker((if n = -1 then (!Param.max_used_phase) else n), Param.any_type)) in
      (att_n, List.map check_gformat tl)
  | "mess" ->
      if List.length tl != 2 then
	input_error "arity of predicate mess should be 2" ext;
      if n > !Param.max_used_phase then
	input_warning "nounif declaration for a phase greater than used" ext;
      let mess_n = Param.get_pred (Mess((if n = -1 then (!Param.max_used_phase) else n), Param.any_type)) in
      (mess_n, List.map check_gformat tl)
  | s ->
      if n != -1 then
	input_error "declared predicates do not depend on phases, so no phase should be specified in such facts in queries" ext;
      let p = get_pred (s,ext) (List.length tl) in
      (p, List.map check_gformat tl)


let get_nounif() =
  List.map (fun (fact,n,b) ->
    clear_var_env();
    List.iter add_fbinding b;
    (check_gfact_format fact, -n)
      ) (!nounif_list)
  

