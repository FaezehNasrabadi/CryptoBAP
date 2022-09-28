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
open Pitptree
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
        Pitparser.all Pitlexer.token lexbuf
      with Parsing.Parse_error ->
        input_error "Syntax error" (extent lexbuf)
    in
    close_in ic;
    ptree
  with Sys_error s ->
    user_error ("File error: " ^ s ^ "\n")

let parse_lib filename =
  let filename = filename ^ ".pvl" in
  try
    let ic = open_in filename in
    let lexbuf = Lexing.from_channel ic in
    lexbuf.Lexing.lex_curr_p <- { lexbuf.Lexing.lex_curr_p with 
                                  Lexing.pos_fname = filename };    
    let ptree =
      try
        Pitparser.lib Pitlexer.token lexbuf
      with Parsing.Parse_error ->
        input_error "Syntax error" (extent lexbuf)
    in
    close_in ic;
    ptree
  with Sys_error s ->
    user_error ("File error: " ^ s ^ "\n")

let parse_with_lib filename =
  let l1 = 
    if (!Param.lib_name) <> "" then
      parse_lib (!Param.lib_name) 
    else
      []
  in
  let (l,p) = parse filename in
  (l1 @ l, p)


(* Global table of identifiers, including names, functions, variables,
   predicates, and types.
   Is a map from strings to the description of the ident *)

let global_env = ref (StringMap.empty : envElement StringMap.t)

(** Types **)

let get_type_polym polym (s, ext) =
  if s = "any_type" then
    if polym then
      Param.any_type
    else
      input_error "polymorphic type not allowed here" ext
  else
  try
    List.find (fun t -> t.tname = s) (!Param.all_types)
  with Not_found -> 
    input_error ("type " ^ s ^ " not declared") ext

let get_type (s, ext) = get_type_polym false (s,ext)

let check_type_decl (s, ext) =
  if s = "any_type" then
    input_error "type any_type reserved for polymorphism" ext;
  if StringMap.mem s (!global_env) then
    input_error ("identifier " ^ s ^ " already defined (as a free name, a function, a predicate, or a type)") ext;
  let r = { tname = s } in 
  Param.all_types := r :: (!Param.all_types);
  global_env := StringMap.add s (EType r) (!global_env)

(* Table of bound names of the process *)

let glob_table = Hashtbl.create 7

let check_single ext s =
  let vals = Hashtbl.find_all glob_table s in
  match vals with
    _::_::_ -> input_error (s ^ " cannot be used in queries. Its definition is ambiguous. (For example, several restrictions might define " ^ s ^ ".)") ext
  | _ -> ()
  


(* Functions *)
    
let fun_decls = Param.fun_decls

let true_cst = Terms.true_cst
let false_cst = Terms.false_cst

let init_fun_decl () =
  Hashtbl.add fun_decls "true" true_cst;
  global_env := StringMap.add "true" (EFun true_cst) (!global_env);
  Hashtbl.add fun_decls "false" false_cst;
  global_env := StringMap.add "false" (EFun false_cst) (!global_env);
  Hashtbl.add fun_decls "not" Terms.not_fun;
  global_env := StringMap.add "not" (EFun Terms.not_fun) (!global_env);
  List.iter (fun t -> global_env := StringMap.add t.tname (EType t) (!global_env)) (!Param.all_types)

let special_functions = ["choice"; "||"; "&&"; "="; "<>"]

let get_fun env (s,ext) tl =
  if List.mem s special_functions then
    input_error (s ^ " not allowed here") ext;
  try
    match StringMap.find s env with
      EFun r -> 
	if not (Terms.eq_lists (fst r.f_type) tl) then
	  input_error ("function " ^ s ^ " expects arguments of type " ^ 
		       (Terms.tl_to_string ", " (fst r.f_type)) ^
		       " but is given arguments of type " ^
		       (Terms.tl_to_string ", " tl)) ext;
	r
    | _ ->
	input_error (s ^ " should be a function") ext
  with Not_found ->
    input_error ("function " ^ s ^ " not defined") ext

let check_fun_decl (name, ext) argtypes restype options =
  let tyarg = List.map get_type argtypes in
  let tyres = get_type restype in
  if StringMap.mem name (!global_env) then
    input_error ("identifier " ^ name ^ " already defined (as a free name, a function, a predicate, or a type)") ext;
  let is_tuple = ref false in
  let is_private = ref false in
  let opt = ref 0 in
  List.iter (function 
	("data",_) -> is_tuple := true
      |	("private",_) -> is_private := true
      |	("typeConverter",_) -> 
	  if List.length tyarg != 1 then
	    input_error "only unary functions can be declared \"typeConverter\"" ext;
	  opt := (!opt) lor Param.fun_TYPECONVERTER
      |	(_,ext) ->
	input_error "for functions, the only allowed options are data, private, and typeConverter" ext) options;
  let cat = if !is_tuple (* || ((arity == 0) && (not is_private)) *) then Tuple else Eq [] in
  let r = { f_name = name;
	    f_type = tyarg, tyres;
	    f_cat = cat;
	    f_initial_cat = cat;
	    f_private = !is_private;
	    f_options = !opt }
  in
  Hashtbl.add fun_decls name r;
  global_env := StringMap.add name (EFun r) (!global_env)

let get_var env (s,ext) =
  try 
    match StringMap.find s env with
      EVar v -> v
    | _ -> input_error (s ^ " should be a variable") ext
  with Not_found -> 
    input_error ("variable " ^ s ^ " not declared") ext

let add_env env l =
  let env_ref = ref env in
  List.iter (fun ((s,ext),ty) ->
      let t = get_type ty in
      begin
	try
	  match StringMap.find s (!env_ref) with
	    EVar _ -> input_error ("variable " ^ s ^ " already defined") ext
	  | _ -> input_warning ("identifier " ^ s ^ " rebound") ext
	with Not_found -> ()
      end;
      let v = Terms.new_var s t in
      env_ref := StringMap.add s (EVar v) (!env_ref)
    ) l;
  !env_ref

let create_env l = 
  add_env (!global_env) l

let f_eq_tuple f ext =
  match f.f_cat with
    Eq _ | Tuple -> ()
  | _ -> input_error ("function " ^ f.f_name ^ " has been defined by reduction. It should not appear in equations or clauses") ext

let f_any f ext = ()

let rec check_eq_term f_allowed env (term,ext) = 
  match term with
    (PIdent (s,ext)) -> 
      let t = 
	try 
	  match StringMap.find s env with
	    EVar v -> Var v
	  | EFun f -> 
	      if fst f.f_type <> [] then 
		input_error ("function " ^ s ^ " expects " ^ 
			     (string_of_int (List.length (fst f.f_type))) ^
			     " arguments but is used without arguments") ext;
	      f_allowed f ext;
	      FunApp(f, [])
	  | _ -> input_error ("identifier " ^ s ^ " should be a function or a variable") ext
	with Not_found -> 
	  input_error ("identifier " ^ s ^ " not defined as a function or as a variable") ext
      in
      (t, Terms.get_term_type t)
  | (PFunApp ((f,ext), tlist)) ->
      let (tl', tyl) = List.split (List.map (check_eq_term f_allowed env) tlist) in
      let f' = get_fun env (f,ext) tyl in
      f_allowed f' ext;
      if (f'.f_options land Param.fun_TYPECONVERTER != 0) && (!Param.ignore_types) then
	match tl' with
	  [t] -> (t, snd f'.f_type)
	| _ -> internal_error "type converter functions should always be unary"
      else
	(FunApp(f', tl'), snd f'.f_type)
  | (PTuple tlist) ->
      let (tl', tyl) = List.split (List.map (check_eq_term f_allowed env) tlist) in
      (FunApp (Terms.get_tuple_fun tyl, tl'), Param.bitstring_type)


(* Equations *)

let check_equation env t1 t2 =
   let var_env = create_env env in
   let (t1', ty1) = check_eq_term f_eq_tuple var_env t1 in
   let (t2', ty2) = check_eq_term f_eq_tuple var_env t2 in
   if ty1 != ty2 then
     begin
       let ext = merge_ext (snd t1) (snd t2) in
       input_error "the two members of an equation should have the same type" ext
     end;
   TermsEq.register_equation (t1',t2')

(* Definitions of destructors by rewrite rules *)

let check_red tlist options =
  match tlist with 
    (_,(PFunApp((f,ext),l),_),_)::_ ->
      begin 
	if List.mem f special_functions then
	  input_error (f ^ " not allowed here") ext;	
        if StringMap.mem f (!global_env) then
          input_error ("identifier " ^ f ^ " already defined (as a free name, a function, a predicate, or a type)") ext;
	let red_list, ty_red_list = List.split (List.map 
		 (function (env, (PFunApp((f',ext'),l1),_), t2) -> 
                    if f <> f' then 
                      input_error ("In \"reduc\", all rewrite rules should begin with the same function " ^ f) ext';
                    let var_env = create_env env in
                    let ((lhs, tylhs), (rhs, tyrhs)) = (List.split (List.map (check_eq_term f_eq_tuple var_env) l1), 
							check_eq_term f_eq_tuple var_env t2)
		    in
		    let var_list_rhs = ref [] in
		    Terms.get_vars var_list_rhs rhs;
		    if not (List.for_all (fun v -> List.exists (Terms.occurs_var v) lhs) (!var_list_rhs)) then
		      Parsing_helper.input_error "All variables of the right-hand side of a \"reduc\" definition\nshould also occur in the left-hand side." ext';
		    (lhs, rhs), (tylhs, tyrhs)
                | _, (_, ext1), _ -> input_error ("In \"reduc\", all rewrite rules should begin with function application") ext1) tlist)
	in
	match ty_red_list with
	  [] -> internal_error "reduction with empty list"
	| (tylhs,tyrhs)::r ->
	    List.iter (fun (tylhs',tyrhs') ->
	      if not (Terms.eq_lists tylhs tylhs') then
		input_error ("the arguments of function " ^ f ^ " do not have the same type in all rewrite rules") ext;
	      if not (tyrhs == tyrhs') then
		input_error ("the result of function " ^ f ^ " does not have the same type in all rewrite rules") ext
		  ) r;
	    let cat = Red red_list in
	    let is_private = ref false in
	    List.iter (function 
	      | ("private",_) -> is_private := true
	      | (_,ext) ->
		  input_error "for functions defined by rewrite rules, the only allowed option is private" ext) options;
            let fsymb = { f_name = f;
                          f_type = tylhs, tyrhs;
                          f_private = !is_private;
			  f_options = 0;
                          f_cat = cat;
			  f_initial_cat = cat
			}
            in
            Hashtbl.add fun_decls f fsymb;
	    global_env := StringMap.add f (EFun fsymb) (!global_env)
      end
  | (_,(_, ext1), _) :: l -> 
      input_error ("In \"reduc\", all rewrite rules should begin with function application") ext1
  | [] -> internal_error "reduction with empty list"

(* Check clauses *)
	
let pred_env = Param.pred_env

let rec interpret_info ty r = function
    ("memberOptim", ext) -> 
      if List.length ty != 2 then
	input_error "memberOptim makes sense only for predicates of arity 2" ext;
      r.p_prop <- r.p_prop lor Param.pred_ELEM
  | ("refTransAtt", ext) ->
      begin
	match ty with
	  [t1;t2] when t1 == t2 -> r.p_prop <- r.p_prop lor Param.pred_REFTRANS
	| _ -> input_error "refTransAtt makes sense only for predicates with 2 arguments of the same type" ext
      end
  | ("decompData",ext) -> 
      if List.exists (fun t -> t != Param.any_type) ty then
	input_error "decompData makes sense only for predicates that are polymorphic in all their arguments" ext;
      r.p_prop <- r.p_prop lor Param.pred_TUPLE
  | ("decompDataSelect",ext) -> 
      if List.exists (fun t -> t != Param.any_type) ty then
	input_error "decompDataSelect makes sense only for predicates that are polymorphic in all their arguments" ext;
      r.p_prop <- r.p_prop lor Param.pred_TUPLE lor Param.pred_TUPLE_SELECT
  | ("block",_) -> r.p_prop <- r.p_prop lor Param.pred_BLOCKING
	  (* add other qualifiers here *)
  | (s,ext) -> input_error ("unknown predicate qualifier " ^ s) ext

let check_pred (c,ext) tl info =
  if c = "attacker" || c = "mess" || c = "event" || c = "inj-event" then
    input_error ("predicate name " ^ c ^ " is reserved. You cannot declare it") ext;
  if StringMap.mem c (!global_env) then
    input_error ("identifier " ^ c ^ " already defined (as a free name, a function, a predicate, or a type)") ext;
  let tyl = List.map (get_type_polym true) tl in
  let r = { p_name = c; p_type = tyl; p_prop = 0; p_info = [] } in
  List.iter (interpret_info tyl r) info;
  if List.exists (fun t -> t == Param.any_type) tyl then
    r.p_info <- [PolymPred(c, r.p_prop, tyl)];
  Hashtbl.add pred_env c r;
  global_env := StringMap.add c (EPred r) (!global_env) 

let get_pred env (c, ext) tl =
  try
    match StringMap.find c env with
      EPred r ->
	if not ((List.length r.p_type == List.length tl) && (List.for_all2 (fun t1 t2 -> t1 == t2 || t1 == Param.any_type) r.p_type tl)) then
	  input_error ("predicate " ^ c ^ " expects arguments of type " ^ 
		       (Terms.tl_to_string ", " r.p_type) ^
		       " but is given arguments of type " ^
		       (Terms.tl_to_string ", " tl)) ext;
	if List.exists (fun t -> t == Param.any_type) r.p_type then
	  Param.get_pred (PolymPred(r.p_name, r.p_prop, tl))
	else
	  r
    | _ -> input_error (c ^ " should be a predicate") ext
  with Not_found ->
    input_error ("undeclared predicate " ^ c ) ext

type pred_or_fun =
    IsPred of predicate
  | IsFun of funsymb

let get_pred_or_fun env (c,ext) tl' =
  try
    match StringMap.find c env with
      EPred r ->
	if not ((List.length r.p_type == List.length tl') && (List.for_all2 (fun t1 t2 -> t1 == t2 || t1 == Param.any_type) r.p_type tl')) then
	  input_error ("predicate " ^ c ^ " expects arguments of type " ^ 
		       (Terms.tl_to_string ", " r.p_type) ^
		       " but is given arguments of type " ^
		       (Terms.tl_to_string ", " tl')) ext;
	let p' = 
	  if List.exists (fun t -> t == Param.any_type) r.p_type then
	    Param.get_pred (PolymPred(r.p_name, r.p_prop, tl'))
	  else
	    r
	in
	IsPred p'
    | EFun r ->
	if not (Terms.eq_lists (fst r.f_type) tl') then
	  input_error ("function " ^ c ^ " expects arguments of type " ^ 
		       (Terms.tl_to_string ", " (fst r.f_type)) ^
		       " but is given arguments of type " ^
		       (Terms.tl_to_string ", " tl')) ext;
	if (snd r.f_type) != Param.bool_type then
	  input_error ("function " ^ c ^ " returns a result of type " ^ 
		       (snd r.f_type).tname ^ " but a boolean is expected") ext;
	IsFun r
    | _ -> input_error (c ^ " should be a predicate or a boolean function") ext
  with Not_found ->
    input_error ("undeclared predicate or function " ^ c ) ext


let add_rule hyp concl constra tag =
  Param.red_rules := (hyp, concl, constra, tag) :: (!Param.red_rules)


let equal_fact t1 t2 =
  Pred(Param.get_pred (Equal(Terms.get_term_type t1)), [t1;t2])

let check_cterm env (p,t) =
  let (tl, tyl) = List.split (List.map (check_eq_term f_any env) t) in
  (get_pred env p tyl, tl)

let rec check_hyp (hyp_accu,constra_accu) env (fact, ext) = 
  match fact with
    PIdent p -> 
      let (p',l') = check_cterm env (p,[]) in
      (Pred(p',l')::hyp_accu, constra_accu)
  | PTuple _ -> input_error "tuples not allowed here" ext
  | PFunApp((f,fext) as p, l) ->
      match f,l with
	"<>", [t1;t2] ->
	  let (t1', ty1) = check_eq_term f_any env t1 in
	  let (t2', ty2) = check_eq_term f_any env t2 in
	  if ty1 != ty2 then
	    input_error "the two arguments of an inequality test should have the same type" ext;
	  (hyp_accu, [Neq(t1', t2')] :: constra_accu)
      | "=", [t1;t2] ->
	  let (t1', ty1) = check_eq_term f_any env t1 in
	  let (t2', ty2) = check_eq_term f_any env t2 in
	  if ty1 != ty2 then
	    input_error "the two arguments of an equality test should have the same type" ext;
	  ((equal_fact t1' t2')::hyp_accu, constra_accu)
      |	"&&", [h1;h2] ->
	  check_hyp (check_hyp (hyp_accu,constra_accu) env h1) env h2
      |	("<>" | "=" | "&&"), _ -> internal_error ("Bad arity for special function " ^ f)
      |	("||" | "not" | "choice"), _ -> input_error (f ^ " not allowed here") fext
      | _ ->
	  let (p',l') = check_cterm env (p,l) in
	  (Pred(p',l')::hyp_accu, constra_accu)

let check_simple_fact env (fact, ext) = 
  match fact with
    PIdent p -> 
      let (p',l') = check_cterm env (p,[]) in
      Pred(p',l')
  | PTuple _ -> input_error "tuples not allowed here" ext
  | PFunApp((f,fext) as p,l) ->
      match f with
	"=" | "<>" | "&&" | "||" | "not" | "choice" -> input_error (f ^ " not allowed here") fext
      |	_ -> 
	  let (p',l') = check_cterm env (p,l) in
	  Pred(p',l')

let check_clause = function
    (env, PFact(c)) ->
      begin
	let env = create_env env in
	let concl = check_simple_fact env c in
	add_rule [] concl [] LblClause
      end
  | (env, PClause(i,c)) ->
      begin
      try 
	let env = create_env env in
	let (hyp, constra) = check_hyp ([],[]) env i in
	let concl = check_simple_fact env c in
	add_rule hyp concl
	  (Rules.simplify_constra_list (concl :: hyp) constra) LblClause
      with Rules.FalseConstraint -> ()
      end
  | (env, PEquiv(i,c,select)) ->
      let env = create_env env in
      let (hyp, constra) = check_hyp ([],[]) env i in
      if constra != [] then 
	Parsing_helper.user_error "Inequality constraints not allowed in equivalences";
      let concl = check_simple_fact env c in
      add_rule hyp concl [] LblEquiv;
      List.iter (fun h -> add_rule [concl] h [] LblEquiv) hyp;
      Rules.add_equiv (hyp, concl, -1); (* TO DO should give a real rule number, but that's not easy... *)
      if not select then Terms.add_unsel concl

      
(* List of the free names of the process *)

let freenames = Param.freenames

let create_name s ty is_free =
  let cat = Name { prev_inputs = None; prev_inputs_meaning = [] } in
   { f_name = s; 
     f_type = ty;
     f_cat = cat;
     f_initial_cat = cat;
     f_private = not is_free;
     f_options = 0 }

let create_name_uniq s ty is_free =
  let cat = Name { prev_inputs = None; prev_inputs_meaning = [] } in
   { f_name = s ^ "_" ^ (string_of_int (Terms.new_var_name())); 
     f_type = ty;
     f_cat = cat;
     f_initial_cat = cat;
     f_private = not is_free;
     f_options = 0 }

let add_free_name (s,ext) t options =
  let is_private = ref false in
  List.iter (function 
    | ("private",_) -> is_private := true
    | (_,ext) ->
	input_error "for free names, the only allowed option is private" ext) options;
  let ty = get_type t in
  if StringMap.mem s (!global_env) then
    input_error ("identifier " ^ s ^ " already declared (as a free name, a function, a predicate, or a type)") ext;
  let r = create_name s ([],ty) (not (!is_private)) in 
  global_env := StringMap.add s (EName r) (!global_env);
  freenames := r :: !freenames


(* Check non-interference terms *)

let get_non_interf_name env (s,ext) =
   try
     match StringMap.find s env  with
       EName r -> 
	 check_single ext s;
	 if not r.f_private then
	   input_error ("Non-interference is certainly false on public values, such as " ^ s) ext
	 else
	   r
     | _ ->
	 input_error ("Non-interference can only be tested on private free names") ext
   with Not_found ->
     input_error ("Name " ^ s ^ " is not declared") ext

let rec check_ni_term env (term,ext) = 
  match term with
    (PIdent (s,ext)) -> 
      let t = 
	try
	  match StringMap.find s env with
	    EVar v -> Var v
	  | EFun f ->
	      if fst f.f_type <> [] then 
		input_error ("function " ^ s ^ " expects " ^ 
			     (string_of_int (List.length (fst f.f_type))) ^
			     " arguments but is used without arguments") ext;
	      (match f.f_cat with
		Eq _ | Tuple -> ()
	      | _ -> input_error ("function " ^ s ^ " has been defined by reduction. It should not appear in non-interference queries") ext);
	      FunApp(f, [])
	  | EName r -> 
	      FunApp (r, [])
	  | _ -> input_error ("identifier " ^ s ^ " should be a variable, a function, or a name") ext
	with Not_found ->
	  input_error ("identifier " ^ s ^ " not defined as a variable, a function, or a name") ext
      in
      (t, Terms.get_term_type t)
  | (PFunApp ((s,ext), tlist)) ->
      let (tl, tyl) = List.split (List.map (check_ni_term env) tlist) in
      let f = get_fun env (s,ext) tyl in
      (match f.f_cat with
	Eq _ | Tuple -> ()
      | _ -> input_error ("function " ^ s ^ " has been defined by reduction. It should not appear in non-interference queries") ext);
      if (f.f_options land Param.fun_TYPECONVERTER != 0) && (!Param.ignore_types) then
	match tl with
	  [t] -> (t, snd f.f_type)
	| _ -> internal_error "type converter functions should always be unary"
      else
	(FunApp(f, tl), snd f.f_type)
  | (PTuple tlist) ->
      let (l, tl) = List.split (List.map (check_ni_term env) tlist) in
      (FunApp (Terms.get_tuple_fun tl, l), Param.bitstring_type)

let get_non_interf env (id, lopt) =
  let n = get_non_interf_name (create_env env) id in
  (n, 
   match lopt with
     None -> None
   | Some l -> 
       Some (List.map (fun t -> 
	 let (t', ty) = check_ni_term (create_env env) t in
	 if ty != snd n.f_type then
	   input_error ("this term has type " ^ ty.tname ^ " but should have type " ^ (snd n.f_type).tname) (snd t);
	 t'
	     ) l))

(* Copy a process *)

let copy_binder b =
  let b' = Terms.new_var b.sname b.btype in
  match b.link with
    NoLink ->
      Terms.link b (TLink (Var b'));
      b'
  | _ -> Parsing_helper.internal_error ("unexpected link in copy_binder " ^ b.sname)

let rec copy_pat = function
    PatVar b -> PatVar (copy_binder b)
  | PatTuple(f,l) -> PatTuple(f, List.map copy_pat l)
  | PatEqual(t) -> PatEqual (Terms.copy_term3 t)

let rec copy_process add_in_glob_table = function
    Nil -> Nil
  | Par(p1,p2) -> Par(copy_process add_in_glob_table p1, copy_process add_in_glob_table p2)
  | Restr(n,p) -> 
      if add_in_glob_table then
	(* If it is the final copy, create a distinct name for each restriction and add it in the glob_table *)
	let n' = create_name_uniq n.f_name n.f_type false in
	Hashtbl.add glob_table n.f_name n';
	Restr(n', Reduction_helper.process_subst (copy_process add_in_glob_table p) n (FunApp(n',[])))
      else
	Restr(n, copy_process add_in_glob_table p)
  | Repl(p,occ) -> Repl(copy_process add_in_glob_table p, new_occurrence())
  | Let(pat, t, p, q, occ) -> 
      Terms.auto_cleanup (fun () ->
	let pat' = copy_pat pat in 
	Let(pat', Terms.copy_term3 t, copy_process add_in_glob_table p, copy_process add_in_glob_table q, new_occurrence()))
  | Input(t, pat, p, occ) -> 
      Terms.auto_cleanup (fun () ->
	let pat' = copy_pat pat in 
	Input(Terms.copy_term3 t, pat', copy_process add_in_glob_table p, new_occurrence()))
  | Output(tc,t,p, occ) -> Output(Terms.copy_term3 tc, Terms.copy_term3 t, copy_process add_in_glob_table p, new_occurrence())
  | Test(t,t',p,q,occ) -> Test(Terms.copy_term3 t, Terms.copy_term3 t', copy_process add_in_glob_table p, copy_process add_in_glob_table q,new_occurrence())
  | Event(t, p, occ) -> Event(Terms.copy_term3 t, copy_process add_in_glob_table p, new_occurrence())
  | Insert(t, p, occ) -> Insert(Terms.copy_term3 t, copy_process add_in_glob_table p, new_occurrence())
  | Get(pat, t, p, occ) -> 
      Terms.auto_cleanup (fun () ->
	let pat' = copy_pat pat in 
	Get(pat', Terms.copy_term3 t, copy_process add_in_glob_table p, new_occurrence()))
  | Phase(n,p) -> Phase(n, copy_process add_in_glob_table p)
  | LetFilter(bl, f, p, q, occ) -> 
      Terms.auto_cleanup (fun () ->
	let bl' = List.map copy_binder bl in 
	LetFilter(bl', Terms.copy_fact3 f, copy_process add_in_glob_table p, copy_process add_in_glob_table q, new_occurrence()))

(*** Translate a process from parse tree to internal representation ***)

(* Table of processes defined by "let" *)

let pdeftbl = (Hashtbl.create 7 : (string, binder list * process) Hashtbl.t)


(* Get an ident when anything is allowed *)

let get_ident_any env (s, ext) =
   try
     match StringMap.find s env with
         EVar b -> Var b
       | EName r -> FunApp (r,[])
       | EFun f -> 
	   if fst f.f_type = [] then
	     FunApp(f,[])
	   else
	     input_error ("function " ^ s ^ " expects " ^ 
			  (string_of_int (List.length (fst f.f_type))) ^
			  " arguments but is used without arguments") ext
       | _ -> input_error ("identifier " ^ s ^ " should be a variable, a function, or a name") ext
   with Not_found ->
     input_error ("Variable, function, or name " ^ s ^ " not declared") ext

let rec cross_product l1 = function
    [] -> []
  | (a::l) -> (List.map (fun l1i -> (l1i,a)) l1) @ (cross_product l1 l)

let rec split n l = 
  if n = 0 then ([],l) else
  match l with
    [] -> Parsing_helper.internal_error "split"
  | (a::l') -> let l1,l2 = split (n-1) l' in (a::l1,l2)

let rec split_every n = function
    [] -> []
  | l ->
      let (l1,l2) = split n l in
      l1 :: (split_every n l2)

let no_expand_fun = function 
    [p] -> p
  | _ -> Parsing_helper.internal_error "no_expand_fun expecting a list with a single element"

let pairing_expand (fa,la) (fl,ll) =
  if fa == no_expand_fun then
    if fl == no_expand_fun then
      (no_expand_fun, cross_product la ll)
    else
      (fl, cross_product la ll)
  else
    if fl == no_expand_fun then
      (fa, cross_product la ll)
    else
      let len = List.length la in
      ((fun l -> let l' = split_every len l in fl (List.map fa l')), 
       cross_product la ll)

let check_no_ref ext vlist (fex, tex) =
  let fNil = fex (List.map (fun _ -> Nil) tex) in
  if List.exists (fun v -> Reduction_helper.occurs_var_proc v fNil) vlist then
    input_error "Cannot expand term because a variable in the expanded part would be referenced before being defined" ext


let rec check_term env (term, ext) =
  match term with 
    PPIdent i -> 
      let t = get_ident_any env i in
      (no_expand_fun, [t], Terms.get_term_type t)
  | PPFunApp((s,ext),l) -> 
      let (fex',lex',tl') = check_term_list env l in
      if s = "choice" then 
        begin
	  match tl' with
	    [t1;t2] when t1 == t2 -> 
              let f = Param.choice_fun t1 in
              (fex', List.map (fun l' -> FunApp(f, l')) lex', t1)
	  | _ -> 
	      input_error ("function choice expects two arguments of same type but is given arguments of type " ^
			   (Terms.tl_to_string ", " tl')) ext
        end
      else
        begin
          if List.mem s special_functions then
            input_error (s ^ " not allowed here") ext;
	  try
	    match StringMap.find s env with
	      EFun f -> 
		if not (Terms.eq_lists (fst f.f_type) tl') then
		  input_error ("function " ^ s ^ " expects arguments of type " ^ 
			       (Terms.tl_to_string ", " (fst f.f_type)) ^
			       " but is given arguments of type " ^
			       (Terms.tl_to_string ", " tl')) ext;
		if (f.f_options land Param.fun_TYPECONVERTER != 0) && (!Param.ignore_types) then
		  (fex', List.map (function
		      [t] -> t
		    | _ -> internal_error "type converter functions should always be unary"
			  ) lex', snd f.f_type)
		else
		  (fex', List.map (fun l' -> FunApp(f, l')) lex', snd f.f_type)
	    | ELetFun(args, fex, tex, ty) ->
		let tyargs = List.map (fun v -> v.btype) args in
		if not (Terms.eq_lists tyargs tl') then
		  input_error ("letfun function " ^ s ^ " expects arguments of type " ^ 
			       (Terms.tl_to_string ", " tyargs) ^
			       " but is given arguments of type " ^
			       (Terms.tl_to_string ", " tl')) ext;
		(* Fix the variables that we are going to use to rename the arguments of the function *)
	        let var_map = List.map (fun v -> (v, Terms.new_var v.sname v.btype)) args in

		((fun l -> 
		  fex' (List.map (fun tl' -> 
		    let p = ref (Terms.auto_cleanup (fun () ->
		      List.iter (fun (v,v') -> Terms.link v (TLink (Var v'))) var_map;
		      copy_process false (fex l))) in
		    List.iter2 (fun (_,v') t' ->
		      p := Let(PatVar v', t', (!p), Nil, new_occurrence())) var_map tl';
		    !p
		      ) lex')), 
		 Terms.auto_cleanup (fun () ->
		   List.iter (fun (v,v') -> Terms.link v (TLink (Var v'))) var_map;
		   List.map Terms.copy_term3 tex), ty)
	    | _ ->
		input_error (s ^ " should be a function") ext
	  with Not_found ->
	    input_error ("function " ^ s ^ " not defined") ext
	end
  | PPTuple l -> 
      let (fex',lex',tl') = check_term_list env l in
      let f = Terms.get_tuple_fun tl' in
      (fex', List.map (fun l' -> FunApp(f, l')) lex', Param.bitstring_type)
  | PPRestr((s,ext),tyid,t) -> 
      let ty = get_type tyid in
      if (StringMap.mem s env) then
	input_warning ("identifier " ^ s ^ " rebound") ext;
      let r = create_name s (Param.tmp_type, ty) false in
      let env' = StringMap.add s (EName r) env in
      let (fex, tex, ty) = check_term env' t in
      ((fun l -> Restr(r, fex l)), tex, ty)
  | PPTest(c,p1,p2) -> 
      let rec interpret_cond p1 p2 = function
	  (PPIdent pred), ext -> interpret_cond p1 p2 (PPFunApp(pred,[]), ext) 
	| (PPTuple _), ext ->
	    input_error "tuples allowed in terms, but not at this level of conditions" ext
	| (PPRestr _ | PPTest _ | PPLetIn _ | PPLet _ | PPLetFilter _), ext -> input_error "new, if, let allowed in terms, but not at this position in conditions" ext
	| (PPFunApp((f,fext), l)), ext0 ->
	    match f, l with
	      "||", [c1;c2] -> 
	        (* if c1 || c2 then p1 else p2
		   is equivalent to
		   if c1 then p1 else (if c2 then p1 else p2) *)
		interpret_cond p1 (PPTest(c2,p1,p2), ext) c1
	    | "&&", [c1;c2] ->
	        (* if c1 && c2 then p1 else p2
		   is equivalent to
		   if c1 then (if c2 then p1 else p2) else p2 *)
		interpret_cond (PPTest(c2,p1,p2), ext) p2 c1
	    | "not", [c] -> 
		interpret_cond p2 p1 c
	    | "=", [t1;t2] ->
		let (fex1',tex1', ty1) = check_term env t1 in
		let (fex2',tex2', ty2) = check_term env t2 in
		if ty1 != ty2 then
		  input_error "the two arguments of an equality test should have the same type" ext0;
		let (fex,tex) = pairing_expand (fex1',tex1') (fex2',tex2') in
		let (fexthen,texthen, tythen) = check_term env p1 in
		let (fexelse,texelse, tyelse) = check_term env p2 in
		if tythen != tyelse then
		  input_error "the then and else branches should have the same type" ext;
		let lenthen = List.length texthen in
		((fun l -> 
		  let (thenpart, elsepart) = split lenthen l in
		  fex (List.map (fun (t1, t2) -> 
		    Test(t1, t2, fexthen thenpart, fexelse elsepart, 
			 new_occurrence())) tex)), texthen @ texelse, tythen)
	    | "<>", [t1;t2] ->
		let (fex1',tex1', ty1) = check_term env t1 in
		let (fex2',tex2', ty2) = check_term env t2 in
		if ty1 != ty2 then
		  input_error "the two arguments of an inequality test should have the same type" ext0;
		let (fex,tex) = pairing_expand (fex1',tex1') (fex2',tex2') in
		let (fexthen,texthen, tythen) = check_term env p2 in
		let (fexelse,texelse, tyelse) = check_term env p1 in
		if tythen != tyelse then
		  input_error "the then and else branches should have the same type" ext;
		let lenthen = List.length texthen in
		((fun l -> 
		  let (thenpart, elsepart) = split lenthen l in
		  fex (List.map (fun (t1, t2) -> 
		    Test(t1, t2, fexthen thenpart, fexelse elsepart, 
			 new_occurrence())) tex)), texthen @ texelse, tythen)
	    | ("||" | "&&" | "=" | "<>" | "not"), _ ->
		internal_error ("Bad arity for special function " ^ f)
	    | "choice", _ -> 
		input_error "choice allowed in terms, but not at this level of conditions" ext0
	    | _ -> 
		let (fex, lex', tl') = check_term_list env l in
		let (fexthen,texthen, tythen) = check_term env p1 in
		let (fexelse,texelse, tyelse) = check_term env p2 in
		if tythen != tyelse then
		  input_error "the then and else branches should have the same type" ext;
		let lenthen = List.length texthen in
		match get_pred_or_fun env (f, fext) tl' with
		  IsPred p' -> 
		    ((fun l -> 
		      let (thenpart, elsepart) = split lenthen l in
		      fex (List.map (fun testi -> 
			LetFilter([], Pred(p', testi), fexthen thenpart, fexelse elsepart, 
				  new_occurrence())) lex')), texthen @ texelse, tythen)
		| IsFun f ->
		    ((fun l -> 
		      let (thenpart, elsepart) = split lenthen l in
		      fex (List.map (fun testi -> 
			Test(FunApp(f, testi), FunApp(true_cst, []), 
			  fexthen thenpart, fexelse elsepart, 
			  new_occurrence())) lex')), texthen @ texelse, tythen)
      in
      interpret_cond p1 p2 c
  | PPLet(pat,t,p,p') ->
      let (ftex, tex', ty) = check_term env t in
      let (fpex, patex', env',_) = check_pat env [] (Some ty) pat in
      let (fex, lex) = pairing_expand (ftex,tex') (fpex, patex') in
      let (fexthen,texthen, tythen) = check_term env' p in
      let (fexelse,texelse, tyelse) = check_term env p' in
      if tythen != tyelse then
	input_error "the in and else branches should have the same type" ext;
      let lenthen = List.length texthen in
      ((fun l -> 
	let (thenpart, elsepart) = split lenthen l in
	fex (List.map (fun (t', pat') -> 
	  Let(pat', t', fexthen thenpart, fexelse elsepart, 
	      new_occurrence())) lex)), texthen @ texelse, tythen)
  | PPLetIn(pat,t,p) ->
      let (ftex, tex', ty) = check_term env t in
      let (fpex, patex', env',_) = check_pat env [] (Some ty) pat in
      let (fex, lex) = pairing_expand (ftex,tex') (fpex, patex') in
      let (fexin, texin, tyin) = check_term env' p in
      ((fun l -> 
	fex (List.map (fun (t', pat') -> 
	  Let(pat', t', fexin l, Nil, new_occurrence())) lex)), 
       texin, tyin)
  | PPLetFilter(identlist,(fact,ext),p,q) ->
      let (env', vlist) = List.fold_left (fun (env, vlist) ((s,e),t) ->
	if (StringMap.mem s env) then
	  input_warning ("identifier " ^ s ^ " rebound") e;
	let ty = get_type t in
	let v = Terms.new_var s ty in
	(StringMap.add s (EVar v) env, v:: vlist)) (env,[]) identlist in
      let vlist = List.rev vlist in
      let (ffex, fex') = check_fact env' (fact,ext) in
      (* Verify that ffex does not reference the variables of vlist *)
      check_no_ref ext vlist (ffex, fex');
      let (fexthen,texthen, tythen) = check_term env' p in
      let (fexelse,texelse, tyelse) = check_term env q in
      if tythen != tyelse then
	input_error "the in and else branches should have the same type" ext;
      let lenthen = List.length texthen in
      ((fun l -> 
	let (thenpart, elsepart) = split lenthen l in
	ffex (List.map (fun f' -> 
	  LetFilter(vlist, f', fexthen thenpart, fexelse elsepart, 
	      new_occurrence())) fex')), texthen @ texelse, tythen)

and check_term_list env = function
    [] -> (no_expand_fun, [[]], [])
  | (a::l) -> 
      let (afex, alex, ta) = check_term env a in
      let (lfex, llex, tl) = check_term_list env l in
      let (f, l') = pairing_expand (afex, alex) (lfex, llex) in
      (f, List.map (fun (a,l'') -> a::l'') l', ta::tl)

and check_fl_term env (p,l) =
  let (fex', lex', tl') = check_term_list env l in
  match get_pred_or_fun env p tl' with
    IsPred p' ->
      (fex', List.map (fun l' -> Pred(p', l')) lex')
  | IsFun r ->
      (fex', List.map (fun l' -> equal_fact (FunApp(r, l')) (FunApp(true_cst, []))) lex')

and check_fact env' (fact, ext) =
  match fact with
    PPIdent p -> 
      check_fl_term env' (p,[])
  | PPTuple _ -> input_error "tuples not allowed here" ext
  | PPRestr _ | PPTest _ | PPLetIn _ | PPLet _ | PPLetFilter _ -> 
      input_error "new, if, let allowed in terms, but not at this position in conditions" ext
  | PPFunApp((f,fext) as p,l) ->
      match f, l with
	"=", [t1;t2] ->  
	  let (fex1', tex1', ty1) = check_term env' t1 in
	  let (fex2', tex2', ty2) = check_term env' t2 in
	  if ty1 != ty2 then
	    input_error "the two arguments of an equality test should have the same type" ext;
	  let (fex, lex) = pairing_expand (fex1', tex1') (fex2', tex2') in
	  (fex, List.map (fun (t1', t2') -> equal_fact t1' t2') lex)
      | "=", _ -> internal_error ("Bad arity for special function " ^ f)
      | ("<>" | "&&" | "||" | "not" | "choice"), _ -> input_error (f ^ " not allowed here") fext
      | _ -> 
	  check_fl_term env' (p,l)


and check_pat env def_in_this_pat tyopt = function
  PPatVar ((s,e), topt) -> 
    let ty = 
      match topt, tyopt with
	None, None ->
	  input_error ("variable " ^ s ^ " should be declared with a type") e
      |	Some (t,e), None -> 
	  get_type (t,e) 
      |	None, Some ty ->
	  ty
      |	Some (t,e), Some ty ->
	  let ty' = get_type (t,e) in
	  if ty != ty' then
	    input_error ("variable " ^ s ^ " is declared of type " ^ t ^ " but should be of type " ^ ty.tname) e;
	  ty
    in
    if (StringMap.mem s env) then
      input_warning ("identifier " ^ s ^ " rebound") e;
    let v = Terms.new_var s ty in
    (no_expand_fun, [PatVar v], StringMap.add s (EVar v) env, v::def_in_this_pat)
| PPatTuple l ->
    let (fex',lex',env',def_in_this_pat') = check_pat_list dummy_ext env def_in_this_pat (List.map (fun _ -> None) l) l in
    let f = Terms.get_tuple_fun (List.map Reduction_helper.get_pat_type (List.hd lex')) in
    (fex',List.map (fun l' -> PatTuple(f, l')) lex', env', def_in_this_pat')
| PPatFunApp((s,ext),l) ->
    begin
      try
	match StringMap.find s env with
	  EFun f -> 
	    begin
	      match tyopt with
		None -> ()
	      |	Some ty -> 
		  if ty != snd f.f_type then
		    input_error ("pattern is of type " ^ (snd f.f_type).tname ^ " but should be of type " ^ ty.tname) ext;
	    end;
	    let (fex',lex',env',def_in_this_pat') = check_pat_list ext env def_in_this_pat (List.map (fun t -> Some t) (fst f.f_type)) l in
	    if f.f_cat <> Tuple then
	      input_error ("only data functions are allowed in patterns, not " ^ s) ext;
	    if (f.f_options land Param.fun_TYPECONVERTER != 0) && (!Param.ignore_types) then
	      (fex', List.map (function
		  [t] -> t
		| _ -> internal_error "type converter functions should always be unary") lex', env', def_in_this_pat')
	    else
	      (fex', List.map (fun l' -> PatTuple(f, l')) lex', env', def_in_this_pat')
	| _ ->
	    input_error ("only functions can be applied, not " ^ s) ext
      with Not_found ->
	input_error ("function " ^ s ^ " not defined") ext
    end
| PPatEqual t ->
    let (fex', tex', ty') = check_term env t in
    (* Verify that fex' does not reference the variables of def_in_this_pat,
       which are defined in this pattern, so will not be defined before fex' *)
    check_no_ref (snd t) def_in_this_pat (fex', tex');
    begin
      match tyopt with
	None -> ()
      |	Some ty -> 
	  if ty != ty' then
	    input_error ("pattern is of type " ^ ty'.tname ^ " but should be of type " ^ ty.tname) (snd t);
    end;
    (fex', List.map (fun t' -> PatEqual t') tex', env, def_in_this_pat)

and check_pat_list ext env def_in_this_pat tyl tl = 
  match (tl, tyl) with
    [],[] -> (no_expand_fun, [[]], env, def_in_this_pat)
  | (a::l),(ty::tyl)  -> 
      let (afex, alex, env', def_in_this_pat') = check_pat env def_in_this_pat ty a in
      let (lfex, llex, env'', def_in_this_pat'') = check_pat_list ext env' def_in_this_pat' tyl l in
      let (f, l') = pairing_expand (afex, alex) (lfex, llex) in
      (f, List.map (fun (a',l'') -> a'::l'') l', env'', def_in_this_pat'')
  | _ -> input_error "wrong arity for pattern" ext

(* Events *)

let event_fun_table = Hashtbl.create 7

let check_event (name, ext) argtypes =
  let tyarg = List.map get_type argtypes in
  let tyarg = if !Param.key_compromise = 0 then tyarg else Param.sid_type :: tyarg in
  if StringMap.mem name (!global_env) then
    input_error ("identifier " ^ name ^ " already defined (as a free name, a function, a predicate, or a type)") ext;
  let r = { f_name = name;
	    f_type = tyarg, Param.event_type;
	    f_cat = Eq[];
	    f_initial_cat = Eq[];
	    f_private = true;
	    f_options = 0 }
  in
  Hashtbl.add event_fun_table name r;
  global_env := StringMap.add name (EEvent r) (!global_env)


let get_event_fun env (s,ext) tl =
  try
    let r = StringMap.find s env in
    match r with
      EEvent p ->
	if not (Terms.eq_lists (fst p.f_type) tl) then
	  input_error ("function " ^ s ^ " expects arguments of type " ^ 
		       (Terms.tl_to_string ", " (fst p.f_type)) ^
		       " but is given arguments of type " ^
		       (Terms.tl_to_string ", " tl)) ext;
	p
    | _ -> input_error (s ^ " should be an event") ext
  with Not_found ->
    input_error ("event " ^ s ^ " not defined") ext

(* Tables *)

let check_table (name, ext) argtypes =
  let tyarg = List.map get_type argtypes in
  if StringMap.mem name (!global_env) then
    input_error ("identifier " ^ name ^ " already defined (as a free name, a function, a predicate, or a type)") ext;
  let r = { f_name = name;
	    f_type = tyarg, Param.table_type;
	    f_cat = Eq[];
	    f_initial_cat = Eq[];
	    f_private = true;
	    f_options = 0 }
  in
  global_env := StringMap.add name (ETable r) (!global_env)

let get_table_fun env (s,ext) tl =
  try
    let r = StringMap.find s env in
    match r with
      ETable p ->
	if not (Terms.eq_lists (fst p.f_type) tl) then
	  input_error ("table " ^ s ^ " expects arguments of type " ^ 
		       (Terms.tl_to_string ", " (fst p.f_type)) ^
		       " but is given arguments of type " ^
		       (Terms.tl_to_string ", " tl)) ext;
	p
    | _ -> input_error (s ^ " should be a table") ext
  with Not_found ->
    input_error ("event " ^ s ^ " not defined") ext



let rec has_destr = function
    Var _ -> false
  | FunApp(f,l) -> 
      (match f.f_cat with
	Eq _ | Tuple | Choice | Name _ -> false
      |	_ -> true) || (List.exists has_destr l)

let rec check_process env = function 
    PNil -> Nil
  | PPar (p1,p2) -> 
      Par(check_process env p1, check_process env p2)
  | PRepl p -> 
      Repl(check_process env p, new_occurrence())
  | PTest(c,p1,p2) -> 
      let rec interpret_cond p1 p2 = function
	  (PPIdent pred), ext -> interpret_cond p1 p2 (PPFunApp(pred,[]), ext) 
	| (PPTuple _), ext ->
	    input_error "tuples allowed in terms, but not at this level of conditions" ext
	| (PPRestr _ | PPTest _ | PPLetIn _ | PPLet _ | PPLetFilter _), ext -> input_error "new, if, let allowed in terms, but not at this position in conditions" ext
	| (PPFunApp((f,fext), l)), ext ->
	    match f, l with
	      "||", [c1;c2] -> 
	        (* if c1 || c2 then p1 else p2
		   is equivalent to
		   if c1 then p1 else (if c2 then p1 else p2) *)
		interpret_cond p1 (PTest(c2,p1,p2)) c1
	    | "&&", [c1;c2] ->
	        (* if c1 && c2 then p1 else p2
		   is equivalent to
		   if c1 then (if c2 then p1 else p2) else p2 *)
		interpret_cond (PTest(c2,p1,p2)) p2 c1
	    | "not", [c] -> 
		interpret_cond p2 p1 c
	    | "=", [t1;t2] ->
		let (fex1',tex1', ty1) = check_term env t1 in
		let (fex2',tex2', ty2) = check_term env t2 in
		if ty1 != ty2 then
		  input_error "the two arguments of an equality test should have the same type" ext;
		let (fex,tex) = pairing_expand (fex1',tex1') (fex2',tex2') in
		fex (List.map (fun (t1',t2') ->
		  Test(t1', t2',
		       check_process env p1, 
		       check_process env p2, 
		       new_occurrence())) tex)
	    | "<>", [t1;t2] ->
		let (fex1',tex1', ty1) = check_term env t1 in
		let (fex2',tex2', ty2) = check_term env t2 in
		if ty1 != ty2 then
		  input_error "the two arguments of an inequality test should have the same type" ext;
		let (fex,tex) = pairing_expand (fex1',tex1') (fex2',tex2') in
		fex (List.map (fun (t1',t2') ->
		  Test(t1', t2',
		       check_process env p2, 
		       check_process env p1, 
		       new_occurrence())) tex)
	    | ("||" | "&&" | "=" | "<>" | "not"), _ ->
		internal_error ("Bad arity for special function " ^ f)
	    | "choice", _ -> 
		input_error "choice allowed in terms, but not at this level of conditions" ext
	    | _ -> 
		let (fex, lex', tl') = check_term_list env l in
		match get_pred_or_fun env (f,fext) tl' with
		  IsPred p' ->
		    fex (List.map (fun f -> 
		      LetFilter([], Pred(p', f), 
				check_process env p1, 
				check_process env p2, 
				new_occurrence())) lex')
		| IsFun f' ->
		    fex (List.map (fun f -> 
		      Test(FunApp(f', f), FunApp(true_cst, []), 
			   check_process env p1, 
			   check_process env p2, 
			   new_occurrence())) lex')
		    
      in
      interpret_cond p1 p2 c
  | PLetDef ((s,ext), args) ->
      let (fex, tlex, tyl) = check_term_list env args in
      begin
	try
          let (param, p') = Hashtbl.find pdeftbl s in
	  let ptype = List.map (fun b -> b.btype) param in
	  if not (Terms.eq_lists ptype tyl) then
	    input_error ("process " ^ s ^ " expects arguments of type " ^ 
			 (Terms.tl_to_string ", " ptype) ^
			 " but is given arguments of type " ^
			 (Terms.tl_to_string ", " tyl)) ext;
	  fex (List.map (fun tl ->
	    if !Terms.current_bound_vars != [] then
	      Parsing_helper.internal_error "bound vars should be cleaned up (pitsyntax)";
	    let p = ref p' in
	    List.iter2 (fun t v -> 
	      if has_destr t then 
		p := Let(PatVar v, t, (!p), Nil, new_occurrence())
	      else
		Terms.link v (TLink t)) tl param;
	    let p'' = copy_process false (!p) in
	    Terms.cleanup();
	    p'') tlex)
        with Not_found ->
          input_error ("process " ^ s ^ " not defined") ext
      end
  | PRestr((s,ext),t,p) -> 
      let ty = get_type t in
      if (StringMap.mem s env) then
	input_warning ("identifier " ^ s ^ " rebound") ext;
      let r = create_name s (Param.tmp_type, ty) false in
      Restr(r, check_process (StringMap.add s (EName r) env) p)
  | PInput(tc,pat,p) ->
      let (ftexc, texc', tyc) = check_term env tc in
      if tyc != Param.channel_type then
	input_error ("this term has type " ^ tyc.tname ^ " but should have type channel") (snd tc);
      let (fpex, patex',env',_) = check_pat env [] None pat in
      let (fex, lex) = pairing_expand (ftexc,texc') (fpex, patex') in
      fex (List.map (fun (tc', pat') -> 
	Input(tc', pat', check_process env' p, 
	      new_occurrence())) lex)
  | POutput(tc,t,p) ->
      let (ftexc, texc', tyc) = check_term env tc in
      if tyc != Param.channel_type then
	input_error ("this term has type " ^ tyc.tname ^ " but should have type channel") (snd tc);
      let (ftex, tex, ty) = check_term env t in
      let (fex, lex) = pairing_expand (ftexc,texc') (ftex, tex) in
      fex (List.map (fun (tc', t) ->
	Output(tc', t, check_process env p, 
	       new_occurrence())) lex)
  | PLet(pat,t,p,p') ->
      let (ftex, tex', ty) = check_term env t in
      let (fpex, patex', env',_) = check_pat env [] (Some ty) pat in
      let (fex, lex) = pairing_expand (ftex,tex') (fpex, patex') in
      fex (List.map (fun (t', pat') ->
	Let(pat', t', check_process env' p,
	    check_process env p', 
	    new_occurrence())) lex)
  | PLetFilter(identlist,(fact,ext),p,q) ->
      let (env', vlist) = List.fold_left (fun (env, vlist) ((s,e),t) ->
	if (StringMap.mem s env) then
	  input_warning ("identifier " ^ s ^ " rebound") e;
	let ty = get_type t in
	let v = Terms.new_var s ty in
	(StringMap.add s (EVar v) env, v:: vlist)) (env,[]) identlist in
      let vlist = List.rev vlist in
      let (ffex, fex') = check_fact env' (fact,ext) in
      (* Verify that ffex does not reference the variables of vlist *)
      check_no_ref ext vlist (ffex, fex');
      ffex (List.map (fun f' -> 
	LetFilter(vlist, f', check_process env' p, 
		  check_process env q, 
		  new_occurrence())) fex')
  | PEvent((i,ext),l,p) ->
      let (fex, lex', tl) = check_term_list env l in
      if !Param.key_compromise == 0 then
	let f = get_event_fun env (i,ext) tl in
	fex (List.map (fun l' ->
	  Event(FunApp(f, l'), check_process env p, 
		new_occurrence())) lex')
      else
	let f = get_event_fun env (i,ext) (Param.sid_type :: tl) in
	fex (List.map (fun l' -> 
	  Event(FunApp(f, (Terms.new_var_def Param.sid_type) :: l'), 
		check_process env p, 
		new_occurrence())) lex')
  | PInsert((i,ext),l,p) ->
      let (fex, lex', tl) = check_term_list env l in
      let f = get_table_fun env (i,ext) tl in
      fex (List.map (fun l' ->
	Insert(FunApp(f, l'), check_process env p, 
	       new_occurrence())) lex')
  | PGet((i,ext),patl,t,p) ->
    begin
      try
	match StringMap.find i env with
	  ETable f -> 
	    (* TO DO when check_term will allow &&, ||, <>, = (thanks to destructors 
	       with inequality conditions), check_term will be enough instead of interpret_cond *)
	    let rec interpret_cond env = function
		(PPFunApp((f,fext), l)), ext0 when (f = "&&" || f = "=") ->
		  begin
		    match f, l with
		      "&&", [c1;c2] ->
			let (fex1',tex1', ty1) = interpret_cond env c1 in
			let (fex2',tex2', ty2) = interpret_cond env c2 in
			if ty1 != Param.bool_type then 
			  input_error "this argument of && should be a boolean" (snd c1);
			if ty2 != Param.bool_type then
			  input_error "this argument of && should be a boolean" (snd c2);
			let (fex',lex') = pairing_expand (fex1',tex1') (fex2',tex2') in
			(fex', List.map (function (t1,t2) -> FunApp(Terms.and_fun, [t1;t2])) lex', Param.bool_type)
		    | "=", [t1;t2] ->
			let (fex1',tex1', ty1) = check_term env t1 in
			let (fex2',tex2', ty2) = check_term env t2 in
			if ty1 != ty2 then
			  input_error "the two arguments of an equality test should have the same type" ext0;
			let (fex',lex') = pairing_expand (fex1',tex1') (fex2',tex2') in
			let feq = Terms.equal_fun ty1 in
			(fex', List.map (function (t1,t2) -> FunApp(feq, [t1;t2])) lex', Param.bool_type)
		    | _ ->
			internal_error ("Bad arity for special function " ^ f)
		  end
	      | t -> check_term env t
	    in
	    let (fex',lex',env',_) = check_pat_list ext env [] (List.map (fun t -> Some t) (fst f.f_type)) patl in
	    let (ftex, tex', ty) = interpret_cond env' t in
	    if ty != Param.bool_type then
	      input_error ("this term has type " ^ ty.tname ^ " but should have type bool") (snd t);
	    let (fex, lex) = pairing_expand (fex', lex') (ftex,tex') in
	    fex (List.map (fun (l', t') -> 
	      Get(PatTuple(f, l'), t', check_process env' p, 
	      new_occurrence())) lex)
	| _ ->
	    input_error ("only functions can be applied, not " ^ i) ext
      with Not_found ->
	input_error ("function " ^ i ^ " not defined") ext
    end
  | PPhase(n, p) ->
      Phase(n, check_process env p)

let query_list = ref ([] : (envdecl * tquery list) list)
let need_vars_in_names = Reduction_helper.need_vars_in_names
let noninterf_list = ref ([] : (funsymb * term list option) list list)
let not_list = ref ([] : (envdecl * gterm_e) list)
let nounif_list = ref ([] : (envdecl * nounif_t) list)
let weaksecret_list = ref ([] : funsymb list)

(* Compute need_vars_in_names: the list of pairs (restriction, variable name)
   such that the variable "variable name" must occur as argument in the
   pattern that models names created by "restriction", because the
   structure "restriction[... variable name = ... ]" is used in the input 
   file. *)

let rec nvn_t (term, ext0) =
  match term with
    PGIdent _ -> ()
  | PGFunApp(_,l) -> List.iter nvn_t l
  | PGPhase(_,l, _) -> List.iter nvn_t l
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
	      let r = Hashtbl.find glob_table s in
	      (* print_string ("Need " ^ s' ^ " in " ^ r.f_name ^ "\n");  *)
	      need_vars_in_names := (r.f_name, s',ext') :: (!need_vars_in_names)
	    with Not_found ->
	      ()
	  end;
	nvn_t t
						) bl
  | PGLet(_,t,t') -> nvn_t t; nvn_t t'

let nvn_q  = function
    PRealQuery q -> nvn_t q
  | PPutBegin(i, l) -> ()

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
	      let r = Hashtbl.find glob_table s in
	      (* print_string ("Need " ^ s' ^ " in " ^ r.f_name ^ "\n");  *)
	      need_vars_in_names := (r.f_name, s',ext') :: (!need_vars_in_names)
	    with Not_found ->
	      ()
	  end;
	nvn_f t
						) bl
  | PFGAny (s,ext) -> ()
  | PFGLet(_,t,t') -> nvn_f t; nvn_f t'

let rec nvn_nounif = function
    BFLet(_,t,nounif) ->  nvn_f t; nvn_nounif nounif
  | BFNoUnif((id,fl,n),_) -> List.iter nvn_f fl


(* Macro expansion *)

let macrotable = ref StringMap.empty

let rename_table = ref StringMap.empty

let expansion_number = ref 0

let rename_ident i = 
  match i with
    "=" | "<>" | "not" | "&&" | "||" | "event" | "inj-event" | "==>" | "choice" -> i
  | _ -> if i.[0] = '!' then i else
  try
    StringMap.find i (!rename_table)
  with Not_found ->
    let r = "@" ^ (string_of_int (!expansion_number)) ^ "_" ^ i in
    rename_table := StringMap.add i r (!rename_table);
    r

let rename_ie (i,ext) = (rename_ident i, ext)

let rec rename_term (t,ext) = 
  let t' = match t with
    PIdent i -> PIdent (rename_ie i)
  | PFunApp(f,l) -> PFunApp(rename_ie f, List.map rename_term l)
  | PTuple l -> PTuple(List.map rename_term l)
  in
  (t',ext)

let rec rename_format = function
    PFIdent i -> PFIdent (rename_ie i)
  | PFFunApp(f,l) -> PFFunApp(rename_ie f, List.map rename_format l)
  | PFTuple l -> PFTuple(List.map rename_format l)
  | PFName _ -> internal_error "Names not allowed in formats with -in pi"
  | PFAny i -> PFAny (rename_ie i)

let rename_format_fact (i,l) = (rename_ie i, List.map rename_format l)

let rec rename_gformat (t,ext) =
  let t' = match t with
    PFGIdent i -> PFGIdent (rename_ie i)
  | PFGFunApp(f,l) -> PFGFunApp(rename_ie f, List.map rename_gformat l)
  | PFGTuple l -> PFGTuple(List.map rename_gformat l)
  | PFGName(i,l) ->  PFGName(rename_ie i, List.map (fun (i,t) -> (rename_ie i, rename_gformat t)) l)
  | PFGAny i -> PFGAny (rename_ie i)
  | PFGLet(i,t,t') -> PFGLet(rename_ie i, rename_gformat t, rename_gformat t')
  in
  (t',ext)

let rec rename_nounif = function
    BFLet(i,f,t) -> BFLet(rename_ie i, rename_gformat f, rename_nounif t)
  | BFNoUnif((i,l,n'),n) -> BFNoUnif((rename_ie i, List.map rename_gformat l, n'), n)

let rec rename_gterm (t,ext) =
  let t' = match t with
    PGIdent i -> PGIdent (rename_ie i)
  | PGFunApp(f,l) -> PGFunApp(rename_ie f, List.map rename_gterm l)
  | PGPhase(i,l,n) -> PGPhase(rename_ie i, List.map rename_gterm l, n)
  | PGTuple l -> PGTuple(List.map rename_gterm l)
  | PGName(i,l) -> PGName(rename_ie i, List.map (fun (i,t) -> (rename_ie i, rename_gterm t)) l)
  | PGLet(i,t,t') -> PGLet(rename_ie i, rename_gterm t, rename_gterm t')
  in
  (t',ext)

let rename_query = function
    PPutBegin(b,l) -> PPutBegin(b, List.map rename_ie l)
  | PRealQuery t -> PRealQuery(rename_gterm t)

let rename_clause = function
    PClause(t,t') -> PClause(rename_term t, rename_term t')
  | PFact t -> PFact(rename_term t)
  | PEquiv(t,t',b) -> PEquiv(rename_term t, rename_term t', b)

let rec rename_pterm (t,ext) =
  let t' = match t with
    PPIdent i -> PPIdent (rename_ie i)
  | PPFunApp(f,l) -> PPFunApp(rename_ie f, List.map rename_pterm l)
  | PPTuple(l) -> PPTuple(List.map rename_pterm l)
  | PPRestr(i,ty,t) -> PPRestr(rename_ie i, rename_ie ty, rename_pterm t)
  | PPTest(t1,t2,t3) -> PPTest(rename_pterm t1, rename_pterm t2, rename_pterm t3)
  | PPLetIn(pat, t1, t2) -> PPLetIn(rename_pat pat, rename_pterm t1, rename_pterm t2)
  | PPLet(pat, t1, t2, t3) -> PPLet(rename_pat pat, rename_pterm t1, rename_pterm t2, rename_pterm t3)
  | PPLetFilter(l, t1, t2, t3) -> PPLetFilter(List.map(fun (i,ty) -> (rename_ie i, rename_ie ty)) l, rename_pterm t1, rename_pterm t2, rename_pterm t3)
  in
  (t',ext)

and rename_pat = function
    PPatVar(i,tyopt) -> PPatVar(rename_ie i, match tyopt with
      None -> None
    | Some ty -> Some (rename_ie ty))
  | PPatTuple l -> PPatTuple(List.map rename_pat l)
  | PPatFunApp(f,l) -> PPatFunApp(rename_ie f, List.map rename_pat l)
  | PPatEqual t -> PPatEqual (rename_pterm t)

let rec rename_process = function
    PNil -> PNil
  | PPar(p1,p2) -> PPar(rename_process p1, rename_process p2)
  | PRepl(p) -> PRepl(rename_process p)
  | PRestr(i,ty,p) -> PRestr(rename_ie i, rename_ie ty, rename_process p)
  | PLetDef(i,l) -> PLetDef(rename_ie i, List.map rename_pterm l)
  | PTest(t,p1,p2) -> PTest(rename_pterm t, rename_process p1, rename_process p2)
  | PInput(t,pat,p) -> PInput(rename_pterm t, rename_pat pat, rename_process p)
  | POutput(t1,t2,p) -> POutput(rename_pterm t1, rename_pterm t2, rename_process p)
  | PLet(pat, t, p1, p2) -> PLet(rename_pat pat, rename_pterm t, rename_process p1, rename_process p2)
  | PLetFilter(l, t, p1, p2) -> PLetFilter(List.map (fun (i,ty) -> (rename_ie i, rename_ie ty)) l, rename_pterm t, rename_process p1, rename_process p2)
  | PEvent(i,l,p) -> PEvent(rename_ie i ,List.map rename_pterm l, rename_process p)
  | PInsert(i,l,p) -> PInsert(rename_ie i ,List.map rename_pterm l, rename_process p)
  | PGet(i,patl,t,p) -> PGet(rename_ie i ,List.map rename_pat patl, rename_pterm t, rename_process p)
  | PPhase(n,p) -> PPhase(n, rename_process p)


let rename_env env = List.map (fun (i,ty) -> (rename_ie i, rename_ie ty)) env

let rename_decl = function
    TTypeDecl i -> TTypeDecl (rename_ie i)
  | TFunDecl(i,l,ty,opt) -> TFunDecl(rename_ie i, List.map rename_ie l, rename_ie ty, opt)
  | TEventDecl(i,l) -> TEventDecl(rename_ie i, List.map rename_ie l)
  | TTableDecl(i,l) -> TTableDecl(rename_ie i, List.map rename_ie l)
  | TConstDecl(i,ty,opt) -> TConstDecl(rename_ie i, rename_ie ty, opt)
  | TReduc(l,opt) -> TReduc(List.map (fun (env,t1,t2) -> (rename_env env, rename_term t1, rename_term t2)) l, opt)
  | TEquation(env, t1, t2) -> TEquation(rename_env env, rename_term t1, rename_term t2)
  | TPredDecl(i,l,opt) -> TPredDecl(rename_ie i, List.map rename_ie l, opt)
  | TSet ((_,ext),_) ->
      input_error "set is not allowed inside macro definitions" ext
  | TPDef(i,env,p) -> TPDef(rename_ie i, rename_env env, rename_process p)
  | TQuery(env, l) -> TQuery(rename_env env, List.map rename_query l)
  | TNoninterf(env, l) -> TNoninterf(rename_env env, List.map (fun (i,tlopt) ->
      (rename_ie i, match tlopt with
	None -> None
      |	Some tl -> Some (List.map rename_term tl))) l)
  | TWeaksecret i -> TWeaksecret (rename_ie i)
  | TNoUnif(env, nounif) -> TNoUnif(rename_env env, rename_nounif nounif)
  | TNot(env, t) -> TNot(rename_env env, rename_gterm t)
  | TElimtrue(env, f) -> TElimtrue(rename_env env, rename_term f)
  | TFree(i,ty, opt) -> TFree(rename_ie i, rename_ie ty, opt)
  | TClauses l -> TClauses (List.map (fun (env, cl) -> (rename_env env, rename_clause cl)) l)
  | TDefine((s1,ext1),argl,def) ->
      input_error "macro definitions are not allowed inside macro definitions" ext1
  | TExpand((s1,ext1),argl) ->
      internal_error "macro-expansion inside a macro should have been expanded at macro definition point" 
  | TLetFun(i,env,t) -> TLetFun(rename_ie i, rename_env env, rename_pterm t)

let apply argl paraml already_def def =
  rename_table := StringMap.empty;
  incr expansion_number;
  List.iter (fun s -> 
    rename_table := StringMap.add s s (!rename_table)) already_def;
  List.iter2 (fun (a,_) (p,_) -> 
    rename_table := StringMap.add p a (!rename_table)) argl paraml;
  let def' = List.map rename_decl def in
  rename_table := StringMap.empty;
  def'


(* Handle all declarations *)

let rec check_one = function
    TTypeDecl(i) -> check_type_decl i
  | TFunDecl(f,argt,rest,i) -> check_fun_decl f argt rest i
  | TConstDecl(f,rest,i) -> check_fun_decl f [] rest i
  | TEquation(env,t1,t2) -> check_equation env t1 t2
  | TReduc (r,i) -> check_red r i
  | TPredDecl (p, argt, info) -> check_pred p argt info
  | TEventDecl(i, args) -> check_event i args
  | TTableDecl(i, args) -> check_table i args
  | TPDef ((s,ext), args, p) -> 
      let env = ref (!global_env) in
      let arglist = List.map (fun ((s',ext'),ty) ->
	let t = get_type ty in
	begin
	  try
	    match StringMap.find s' (!env) with
	      EVar _ -> input_error ("variable " ^ s' ^ " already defined") ext'
	    | _ -> ()
	  with Not_found ->
	    ()
	end;
	let v = Terms.new_var s' t in
	env := StringMap.add s' (EVar v) (!env);
	v
	       ) args
      in
      let p' = check_process (!env) p in
      Hashtbl.add pdeftbl s (arglist, p')
  | TQuery (env,q) -> 
      query_list := (env,q) :: (!query_list)
  | TNoninterf (env, lnoninterf) -> 
      noninterf_list := (List.map (get_non_interf env) lnoninterf) :: (!noninterf_list); 
  | TWeaksecret i ->
      weaksecret_list := (get_non_interf_name (!global_env) i) ::(!weaksecret_list)
  | TNoUnif (env, nounif) ->
      nounif_list := (env, nounif) :: (!nounif_list)
  | TElimtrue(env, fact) ->
      let env = create_env env in
      Param.elim_true := (check_simple_fact env fact) :: (!Param.elim_true)
  | TNot (env, no) -> 
      not_list := (env, no) :: (!not_list)
  | TFree (name,ty,i) -> 
      add_free_name name ty i
  | TClauses c ->
      List.iter check_clause c
  | TLetFun ((s,ext), args, p) -> 
      let env = ref (!global_env) in
      let arglist = List.map (fun ((s',ext'),ty) ->
	let t = get_type ty in
	begin
	  try
	    match StringMap.find s' (!env) with
	      EVar _ -> input_error ("variable " ^ s' ^ " already defined") ext'
	    | _ -> ()
	  with Not_found ->
	    ()
	end;
	let v = Terms.new_var s' t in
	env := StringMap.add s' (EVar v) (!env);
	v
	       ) args
      in
      let (fex, tex, ty) = check_term (!env) p in
      global_env := StringMap.add s (ELetFun(arglist, fex, tex, ty)) (!global_env)
  (* TO DO handle TExpand (_, _)|TDefine (_, _, _) *)
  | TDefine((s1,ext1),argl,def) ->
      if StringMap.mem s1 (!macrotable) then
	input_error ("Macro " ^ s1 ^ " already defined.") ext1
      else
	(* Expand macro calls inside macro definitions
	   Because this is done at macro definition point, this requires that
	   the macros used inside the definition be defined before, which
	   is a safe requirement. (It prevents recursive macros, in particular.) *)
	let rec expand_inside_macro = function 
	    TDefine((s,ext),_,_)::l -> 
	      input_error "macro definitions are not allowed inside macro definitions" ext
	  | TExpand((s2,ext2), argl2)::l ->
	      begin
		try 
		  let (paraml2, def2, already_def2) = StringMap.find s2 (!macrotable) in
		  if List.length argl2 != List.length paraml2 then
		    input_error ("Macro " ^ s2 ^ " expects " ^ (string_of_int (List.length paraml2)) ^
				 " arguments, but is here given " ^ (string_of_int (List.length argl2)) ^ " arguments.") ext2;
		  (apply argl2 paraml2 already_def2 def2) @ (expand_inside_macro l)
		with Not_found ->
		  input_error ("Macro " ^ s2 ^ " not defined.") ext2
	      end
	  | a::l -> a::(expand_inside_macro l)
	  | [] -> []
	in
	let def = expand_inside_macro def in
	let already_def = ref [] in
	StringMap.iter (fun s _ -> already_def := s :: (!already_def)) (!global_env);
	macrotable := StringMap.add s1 (argl, def, !already_def) (!macrotable)
  | TExpand((s1,ext1),argl) ->
      begin
	try 
	  let (paraml, def, already_def ) = StringMap.find s1 (!macrotable) in
	  if List.length argl != List.length paraml then
	    input_error ("Macro " ^ s1 ^ " expects " ^ (string_of_int (List.length paraml)) ^
			 " arguments, but is here given " ^ (string_of_int (List.length argl)) ^ " arguments.") ext1;
	  List.iter check_one (apply argl paraml already_def def)
	with Not_found ->
	  input_error ("Macro " ^ s1 ^ " not defined.") ext1
      end 
  | TSet _ -> internal_error "set declaration should have been handled before"

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
  | Insert(_,p,_) -> set_max_used_phase p
  | Get(_,_,p,_) -> set_max_used_phase p
  | Phase(n,p) ->
      if n > !Param.max_used_phase then
	Param.max_used_phase := n;
      set_max_used_phase p

let parse_file s = 
  init_fun_decl();
  let (decl, proc) = parse_with_lib s in
  (* ignoreTypes must be set before doing the rest of the work
     Setting all parameters beforehand does not hurt. *)
  List.iter (function
      TSet((p,ext),v) -> 
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
	  | "ignoreTypes", S (("all" | "true"), _) -> Param.ignore_types := true
	  | "ignoreTypes", S ("attacker", _) -> Param.ignore_types := false; Param.untyped_attacker := true
	  | "ignoreTypes", S (("none" | "false"), _) -> Param.ignore_types := false; Param.untyped_attacker := false
	  | _,_ -> Param.common_parameters p ext v
	end
    | _ -> ()) decl;

  List.iter (function
      TSet _ -> ()
    | x -> check_one x) decl;
 
  let p = Terms.auto_cleanup (fun () ->
	(* I call copy_process to make sure that all variables are distinct.
           copy_process renames variables in patterns *) 
	copy_process true (check_process (!global_env) proc))
  in
  List.iter (fun (_, q) -> List.iter nvn_q q) (!query_list);
  List.iter (fun (_, no) -> nvn_t no) (!not_list);
  List.iter (fun (_, nounif) -> nvn_nounif nounif) (!nounif_list);
  if !Param.key_compromise = 2 then
    Param.max_used_phase := 1
  else
    set_max_used_phase p;
  p

let display () =
   print_string "Functions ";
   Hashtbl.iter (fun _ fsymb -> 
     print_string (fsymb.f_name ^ "(" ^ (Terms.tl_to_string ", " (fst fsymb.f_type)) 
		   ^ "):" ^ (snd fsymb.f_type).tname ^ ". ")
       ) fun_decls;
   print_string "\n"

(* queries *)

let non_compromised_session = FunApp(Param.session1, [])


(* Note: when check_query, get_queries are applied before the
   translation of the process into Horn clauses has been done, 
   the arity of names may not be correctly initialized. In this case,
   update_arity_names should be called after the translation of the
   process to update it.  *)

let get_ident_any env (s, ext) =
   try
     match StringMap.find s env with
         EVar b -> 
	   begin
	     match b.link with
	       TLink t -> t
	     | NoLink -> Var b
	     | _ -> internal_error "unexpected link in get_ident_any"
	   end
       | EName r -> 
	   FunApp(r, [])
       | EFun f -> 
	   if fst f.f_type == [] then 
	     FunApp(f,[]) 
	   else
	     input_error ("function " ^ s ^ " has expects " ^ 
			  (string_of_int (List.length (fst f.f_type))) ^
			  " arguments but is used without arguments") ext
       | _ -> input_error ("identifier " ^ s ^ " should be a variable, a free name, or a function") ext
   with Not_found ->
     input_error ("identifier " ^ s ^ " not defined") ext

let rec check_query_term env (term, ext0) =
  match term with
    PGIdent i -> 
      let t = get_ident_any env i in
      (t, Terms.get_term_type t)
  | PGPhase _ -> input_error ("phase unexpected in query terms") ext0
  | PGFunApp((s,ext),l) -> 
      if List.mem s ["="; "<>"; "==>"; "&&"; "||"; "event"; "inj-event"] then
	input_error (s ^ " unexpected in query terms") ext;
      begin
        try
          match StringMap.find s env with
            EFun f -> 
              (match f.f_cat with
                 Eq _ | Tuple -> ()
               | _ ->  input_error ("function " ^ s ^ " is defined by \"reduc\". Such a function should not be used in a query") ext);
	      let (l', tl') = List.split (List.map (check_query_term env) l) in
	      if Terms.eq_lists (fst f.f_type) tl' then 
		if (f.f_options land Param.fun_TYPECONVERTER != 0) && (!Param.ignore_types) then
		  match l' with
		    [t] -> (t, snd f.f_type)
		  | _ -> internal_error "type converter functions should always be unary"
		else
		  (FunApp(f, l'), snd f.f_type)
	      else
		input_error ("function " ^ s ^ " expects arguments of type " ^ 
			     (Terms.tl_to_string ", " (fst f.f_type)) ^
			     " but is given arguments of type " ^
			     (Terms.tl_to_string ", " tl')) ext
          | _ -> input_error("only functions can be applied, not " ^ s) ext
        with Not_found ->
          input_error ("function " ^ s ^ " not defined") ext
      end
  | PGTuple l -> 
      let (l', tl') = List.split (List.map (check_query_term env) l) in
      (FunApp(Terms.get_tuple_fun tl', l'), Param.bitstring_type)
  | PGName ((s,ext),bl) -> 
      begin
	try
	  let r = Hashtbl.find glob_table s in
	  check_single ext s;
	  if fst r.f_type == Param.tmp_type then
	    begin
	      let v = Terms.new_var Param.def_var_name (snd r.f_type) in
	      v.link <- PGTLink (env, (term,ext0));
	   (Var v, snd r.f_type)
	    end
	  else
	    begin
	      match r.f_cat with 
		Name { prev_inputs_meaning = sl } ->
		  List.iter (fun ((s',ext'),_) -> 
		    if not (List.mem s' sl) then
		      input_error ("variable " ^ s' ^ " not defined at restriction " ^ s) ext') bl;
		  let p = List.map2 (fun s'' ty ->
		    if s'' = "!comp" then non_compromised_session else
		    binding_find env s'' ty bl) sl (fst r.f_type)
		  in
		  (FunApp(r, p), snd r.f_type)
	      | _ -> internal_error "name expected here"
	    end
	with Not_found ->
	  input_error (s ^ " should be a name") ext
      end
  | PGLet(id,t,t') -> check_query_term (add_binding env (id,t)) t'

and binding_find env s ty = function
    [] -> Terms.new_var_def ty
  | ((s',ext),t)::l ->
      if s' = s then
	begin
	  let (t', ty') = check_query_term env t in
	  if ty' != ty then
	    input_error ("this variable is of type " ^ ty.tname ^ " but is given a value of type " ^ ty'.tname) ext;
	  t'
	end
      else
	binding_find env s ty l

and add_binding env ((i,ext),t) =
  begin
    try
      match StringMap.find i env with
	EVar _ -> input_error ("variable " ^ i ^ " already defined") ext
      | _ -> ()
    with Not_found -> ()
  end;
  let (t', ty') = check_query_term env t in
  let v = Terms.new_var i ty' in
  v.link <- TLink t';
  StringMap.add i (EVar v) env

let check_mess env e tl n =
  match tl with
    [t1;t2] ->
      if n > !Param.max_used_phase then
	begin
	  input_warning "phase greater than the maximum phase used in the process.\nIs that really what you want?" e;
	  Param.max_used_phase := n;
	end;
      let (t1', ty1) = check_query_term env t1 in
      let (t2', ty2) = check_query_term env t2 in
      if ty1 != Param.channel_type then
	input_error ("First argument of mess is of type " ^ ty1.tname ^ " and should be of type channel") e;
      let mess_n = Param.get_pred (Mess((if n = -1 then (!Param.max_used_phase) else n),
					ty2))
      in
      QFact(mess_n, [t1';t2'])
  | _ -> 
      input_error "arity of predicate mess should be 2" e

let check_attacker env e tl n =
  match tl with
    [t1] ->
      if n > !Param.max_used_phase then
	begin
	  input_warning "phase greater than the maximum phase used in the process.\nIs that really what you want?" e;
	  Param.max_used_phase := n;
	end;
      let (t1', ty1) = check_query_term env t1 in
      let att_n = Param.get_pred (Attacker((if n = -1 then (!Param.max_used_phase) else n),
	                                   ty1)) 
      in
      QFact(att_n, [t1'])
  | _ -> 
      input_error "arity of predicate attacker should be 1" e

let rec check_event env (f,e) =
  match f with
    PGFunApp(("<>", _), [t1; t2]) ->
      let (t1', ty1) = check_query_term env t1 in
      let (t2', ty2) = check_query_term env t2 in
      if ty1 != ty2 then
	input_error "the two arguments of an inequality test should have the same type" e;      
      QNeq(t1', t2')
  | PGFunApp(("=", _), [t1; t2]) ->
      let (t1', ty1) = check_query_term env t1 in
      let (t2', ty2) = check_query_term env t2 in
      if ty1 != ty2 then
	input_error "the two arguments of an equality test should have the same type" e;      
      QEq(t1', t2')
  | PGFunApp(("event",e'),tl0) ->
      begin
	match tl0 with
	  [PGFunApp((s,e''), tl),_] ->
	    let (tl', tyl') = List.split (List.map (check_query_term env) tl) in
	    if !Param.key_compromise == 0 then
	      QSEvent(false, FunApp((get_event_fun env (s, e'') tyl'), tl'))
	    else
	      QSEvent(false, FunApp((get_event_fun env (s, e'') (Param.sid_type :: tyl')),
				    (Terms.new_var_def Param.sid_type)::tl'))
	| _ -> input_error "predicate event should have one argument, which is a function application" e'
      end
  | PGFunApp(("inj-event",e'),tl0) ->
      begin
	match tl0 with
	  [PGFunApp((s,e''), tl),_] ->
	    let (tl', tyl') = List.split (List.map (check_query_term env) tl) in
	    if !Param.key_compromise == 0 then
	      QSEvent(true, FunApp((get_event_fun env (s, e'') tyl'), tl'))
	    else
	      QSEvent(true, FunApp((get_event_fun env (s, e'') (Param.sid_type :: tyl')),
				   (Terms.new_var_def Param.sid_type)::tl'))
	| _ -> input_error "predicate inj-event should have one argument, which is a function application" e'
      end
  | PGFunApp(("attacker",_), tl) ->
      check_attacker env e tl (-1)
  | PGFunApp(("mess",_), tl) ->
      check_mess env e tl (-1)
  | PGFunApp((s, ext) as p, tl) ->
      if List.mem s ["||"; "&&"; "not"; "==>"] then
	input_error (s ^ " unexpected in events") ext;
      let (tl', tyl) = List.split (List.map (check_query_term env) tl) in
      QFact(get_pred env p tyl, tl')
  | PGPhase((s, ext), tl, n) ->
      begin
	match s with
	  "mess" -> check_mess env e tl n
	| "attacker" -> check_attacker env e tl n
	| _ -> input_error "phases can be used only with attacker or mess" ext
      end
  | PGIdent p -> 
      QFact(get_pred env p [], [])
  | PGLet(id,t,t') -> check_event (add_binding env (id,t)) t'
  | _ -> input_error "an event should be a predicate application" e
      
let rec check_hyp env = function
    PGFunApp(("==>", _), [ev; hypll]), _ ->
      let ev' = check_event env ev in
      (
       match ev' with
	 QNeq _ | QEq _ -> input_error "Inequalities or equalities cannot occur before ==> in queries" (snd ev)
       | _ -> ()
      );
      let hypll' = check_hyp env hypll in
      [[NestedQuery(Before(ev', hypll'))]]
  | PGFunApp(("||", _), [he1;he2]), _ -> 
      (check_hyp env he1) @ (check_hyp env he2)
  | PGFunApp(("&&", _), [he1;he2]), _ ->
      let he1' = check_hyp env he1 in
      let he2' = check_hyp env he2 in
      List.concat (List.map (fun e1 -> List.map (fun e2 -> e1 @ e2) he2') he1')
  | PGLet(id,t,t'), _ -> check_hyp (add_binding env (id,t)) t'
  | ev -> [[QEvent(check_event env ev)]]

let rec check_real_query_top env = function
    PGFunApp(("==>", _), [ev; hypll]), _ ->
      let ev' = check_event env ev in
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
      let hypll' = check_hyp env hypll in
      Before(ev'', hypll')
  | PGLet(id,t,t'), _ -> check_real_query_top (add_binding env (id,t)) t'
  | ev ->
      let ev' = check_event env ev in
      let ev'' = 
	match ev' with
	  QNeq _ | QEq _ -> user_error "Inequalities or equalities cannot occur alone queries\n"
	| QFact _ -> ev'
	| QSEvent _ when !Param.key_compromise == 0 -> ev'
	| QSEvent(inj, FunApp(f, sid::l)) ->
	    QSEvent(inj, FunApp(f, non_compromised_session::l))
	| QSEvent(_,_) ->
	    internal_error "Bad format for events in queries"
      in
      Before(ev'', [])

let rec check_query_list env = function
    [] -> []
  | (PRealQuery q)::lq -> 
      (RealQuery(check_real_query_top env q))::(check_query_list env lq)
  | (PPutBegin(i, l))::lq ->
      let l' = List.map (fun (s,e) ->
	try
	  match StringMap.find s env with
	    EEvent r -> r
	  | _ -> input_error (s ^ " should be an event") e
	with Not_found ->
	  input_error ("unknown event " ^s) e) l
      in
      (PutBegin(i,l'))::(check_query_list env lq)

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
	  QFact _ | QNeq _ | QEq _ -> user_error "In a query e ==> h, if h contains an injective event, then e must be an event or better inj-event\n"
	| QSEvent(_,t) -> QSEvent(true, t) (* set the event injective *)
	in
	Before(e', List.map (List.map (function 
	    QEvent e -> QEvent e
	  | NestedQuery q' -> NestedQuery (check_inj_coherent_r q'))) ll)
  else q

let check_inj_coherent = function
    (PutBegin(_,_) as q) -> q
  | RealQuery q -> RealQuery (check_inj_coherent_r q)


let transl_query (env,q) =
  let q' = check_query_list (create_env env) q in
  let q'' = List.map check_inj_coherent q' in
  Pievent.init_event_status_table event_fun_table;
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

(* After its translation, the arguments of names in the query are
   given type Param.tmp_type The exact types of the arguments of each
   name function symbol is computed during the translation of the
   process. The following functions scan the query to update the names
   with their real type. *)

let rec update_type_names_t = function
    Var v ->
      begin
	match v.link with
	  PGTLink (env, t) ->
	    let (t', _) = check_query_term env t in
	    v.link <- TLink t';
	    t'
	| TLink t -> t
	| NoLink -> Var v
	| _ -> internal_error "unexpected link in update_type_names_t"
      end
  | FunApp(f,l) -> FunApp(f, List.map update_type_names_t l)
      

let update_type_names_e = function
    QSEvent(b,t) -> QSEvent(b, update_type_names_t t)
  | QFact(p,tl) -> QFact(p, List.map update_type_names_t tl)
  | QNeq(t1,t2) -> QNeq(update_type_names_t t1, update_type_names_t t2)
  | QEq(t1,t2) -> QEq(update_type_names_t t1, update_type_names_t t2)

let rec update_type_names_r = function
    Before(ev,hypll) -> Before(update_type_names_e ev, List.map (List.map update_type_names_h) hypll)

and update_type_names_h = function
    QEvent(ev) -> QEvent(update_type_names_e ev)
  | NestedQuery(q) -> NestedQuery(update_type_names_r q)

let update_type_names = function
    PutBegin(b,l) -> PutBegin(b,l)
  | RealQuery q -> RealQuery(update_type_names_r q)

(* Noninterf queries *)

let get_noninterf_queries () =
  !noninterf_list

(* Weaksecret queries *)

let get_weaksecret_queries () =
  !weaksecret_list

(* Not declarations *)

let get_not() =
  List.map (fun (env, no) -> check_event (create_env env) no) (!not_list)

(* For Nounif. Very similar to queries, except that *v is allowed
   and events are not allowed *)

let fget_ident_any env (s, ext) =
   try
     match StringMap.find s env with
         EVar b -> 
	   begin
	     match b.link with
	       FLink t -> (t, b.btype)
	     | NoLink -> (FVar b, b.btype)
	     | _ -> internal_error "unexpected link in fget_ident_any"
	   end
       | EName r -> 
	   (FFunApp(r, []), snd r.f_type)
       | EFun f -> 
	   if fst f.f_type == [] then 
	     (FFunApp(f,[]), snd f.f_type)
	   else
	     input_error ("function " ^ s ^ " expects " ^ 
			  (string_of_int (List.length (fst f.f_type))) ^
			  " arguments but is used without arguments") ext
       | _ -> 
	   input_error ("identifier " ^ s ^ " should be a variable, a function, or a name") ext
   with Not_found ->
     input_error ("identifier " ^ s ^ " not defined") ext



let rec check_gformat env (term, ext0) =
  match term with
    PFGIdent i -> fget_ident_any env i
  | PFGFunApp((s,ext),l) -> 
      begin
        try
          match StringMap.find s env with
            EFun f -> 
              (match f.f_cat with
                 Eq _ | Tuple -> ()
               | _ ->  input_error ("function " ^ s ^ " is defined by \"reduc\". Such a function should not be used in a \"nounif\" declaration") ext);
	      let (l', tl') = List.split (List.map (check_gformat env) l) in
	      if Terms.eq_lists (fst f.f_type) tl' then 
		if (f.f_options land Param.fun_TYPECONVERTER != 0) && (!Param.ignore_types) then
		  match l' with
		    [t] -> (t, snd f.f_type)
		  | _ -> internal_error "type converter functions should always be unary"
		else
		  (FFunApp(f, l'), snd f.f_type)
	      else
		input_error ("function " ^ s ^ " expects arguments of type " ^ 
			     (Terms.tl_to_string ", " (fst f.f_type)) ^
			     " but is given arguments of type " ^
			     (Terms.tl_to_string ", " tl')) ext
          | _ -> input_error("only functions can be applied, not " ^ s) ext
        with Not_found ->
          input_error ("function " ^ s ^ " not defined") ext
      end
  | PFGTuple l -> 
      let (l', tl') = List.split (List.map (check_gformat env) l) in
      (FFunApp(Terms.get_tuple_fun tl', l'), Param.bitstring_type)
  | PFGAny (s,ext) -> 
      begin
	try
	  match StringMap.find s env with
            EVar b -> 
	      begin
		match b.link with
		  NoLink -> (FAny b, b.btype)
		| FLink _ -> input_error "variables preceded by * must not be defined by a binding" ext
		| _ -> internal_error "unexpected link in check_gformat"
	      end
	  | _ -> input_error (s ^ " should be a variable") ext
	with Not_found ->
	  input_error ("variable " ^ s ^ " is not defined") ext
      end
  | PFGName ((s,ext),bl) -> 
      begin
	try
	  let r = Hashtbl.find glob_table s in
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
		  let p = List.map2 (fun s'' ty ->
		    fbinding_find env s'' ty bl) sl (fst r.f_type) 
		  in
		  (FFunApp(r, p), snd r.f_type)
	      | _ -> internal_error "name expected here"
	    end
	with Not_found ->
	  input_error (s ^ " should be a name") ext
      end
  | PFGLet(id,t,t') -> check_gformat (add_fbinding env (id,t)) t'

and fbinding_find env s ty = function
    [] -> FAny (Terms.new_var Param.def_var_name ty)
  | ((s',ext),t)::l ->
      if s' = s then
	begin
	  let (t', ty') = check_gformat env t in
	  if ty' != ty then
	    input_error ("this variable is of type " ^ ty.tname ^ " but is given a value of type " ^ ty'.tname) ext;
	  t'
	end
      else
	fbinding_find env s ty l

and add_fbinding env ((i,ext),t) =
  begin
    try
      match StringMap.find i env with
	EVar _ -> input_error ("variable " ^ i ^ " already defined") ext
      | _ -> ()
    with Not_found -> ()
  end;
  let (t', ty') = check_gformat env t in
  let v = Terms.new_var i ty' in
  v.link <- FLink t';
  StringMap.add i (EVar v) env


let check_gfact_format env ((s, ext), tl, n) =
  match s with
    "attacker" ->
      begin
	match tl with
	  [t1] ->
	    if n > !Param.max_used_phase then
	      input_warning "nounif declaration for a phase greater than used" ext;
	    let (t1', ty1) = check_gformat env t1 in
	    let att_n = Param.get_pred (Attacker((if n = -1 then (!Param.max_used_phase) else n), ty1)) 
	    in
	    (att_n, [t1'])
	| _ -> 
	    input_error "arity of predicate attacker should be 1" ext
      end
  | "mess" ->
      begin
	match tl with
	  [t1;t2] ->
	    if n > !Param.max_used_phase then
	      input_warning "nounif declaration for a phase greater than used" ext;
	    let (t1', ty1) = check_gformat env t1 in
	    let (t2', ty2) = check_gformat env t2 in
	    if ty1 != Param.channel_type then
	      input_error ("First argument of mess is of type " ^ ty1.tname ^ " and should be of type channel") ext;
	    let mess_n = Param.get_pred (Mess((if n = -1 then (!Param.max_used_phase) else n), ty2)) 
	    in
	    (mess_n, [t1';t2'])
	| _ -> 
	    input_error "arity of predicate mess should be 2" ext
      end
  | s ->
      if n != -1 then
	input_error "declared predicates do not depend on phases, so no phase should be specified in such facts in queries" ext;
      let (tl', tyl) = List.split (List.map (check_gformat env) tl) in
      (get_pred env (s,ext) tyl, tl')

let rec handle_nounif env = function
    BFLet(id,t,nounif) -> handle_nounif (add_fbinding env (id,t)) nounif
  | BFNoUnif(fact,n) -> (check_gfact_format env fact, -n)

let get_nounif() =
  List.map (fun (env, nounif) -> handle_nounif (create_env env) nounif) (!nounif_list)
  

