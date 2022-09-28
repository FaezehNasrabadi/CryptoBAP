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

open Ptree
open Parsing_helper
open Types


(* Parse a file *)

let parse filename = 
  try
    let ic = open_in filename in
    let lexbuf = Lexing.from_channel ic in
    lexbuf.Lexing.lex_curr_p <- { lexbuf.Lexing.lex_curr_p with 
                                  Lexing.pos_fname = filename };
    let ptree =
      try
        Parser.tall Lexer.token lexbuf
      with Parsing.Parse_error ->
        input_error "Syntax error" (extent lexbuf)
    in
    close_in ic;
    ptree
  with Sys_error s ->
    user_error ("File error: " ^ s ^ "\n")

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
  if List.exists (fun t -> t.tname = s) (!Param.all_types) then
    input_error ("type " ^ s ^ " already declared") ext;
  Param.all_types := { tname = s } :: (!Param.all_types)
    
(** Names **)

let name_env = Hashtbl.create 7

let get_name (s,ext) tl =
  try
    let r = Hashtbl.find name_env s in
    if fst r.f_type == Param.tmp_type then
      r.f_type <- tl, snd r.f_type
    else if not (Terms.eq_lists tl (fst r.f_type)) then
      input_error ("name " ^ s ^ " expects arguments of type " ^ 
		   (Terms.tl_to_string ", " (fst r.f_type)) ^
		   " but is given arguments of type " ^
		   (Terms.tl_to_string ", " tl)) ext;
    r
  with Not_found ->
    input_error ("name " ^ s ^ " not declared") ext

let check_name_decl (s,ext) ty =
  let t = get_type ty in
  try
    ignore (Hashtbl.find name_env s);
    input_error ("name " ^ s ^ " already declared") ext
  with Not_found -> 
  try
    ignore(Hashtbl.find Param.fun_decls s);
    input_error ("name " ^ s ^ " already defined as a function") ext
  with Not_found ->
    let cat = Name { prev_inputs = None; prev_inputs_meaning = [] } in
    let r = { f_name = s; 
	      f_type = Param.tmp_type, t; 
              f_cat = cat;
	      f_initial_cat = cat;
              f_private = true;
	      f_options = 0 } 
    in
    Hashtbl.add name_env s r

(* Functions *)

let fun_decls = Param.fun_decls

let get_fun (s,ext) tl =
  try
    let r = Hashtbl.find fun_decls s in
    if not (Terms.eq_lists (fst r.f_type) tl) then
      input_error ("function " ^ s ^ " expects arguments of type " ^ 
		   (Terms.tl_to_string ", " (fst r.f_type)) ^
		   " but is given arguments of type " ^
		   (Terms.tl_to_string ", " tl)) ext;
    r
  with Not_found ->
    input_error ("function " ^ s ^ " not defined") ext

let check_fun_decl (name, ext) argtypes restype options =
  let tyarg = List.map get_type argtypes in
  let tyres = get_type restype in
  try
    ignore(Hashtbl.find fun_decls name);
    input_error ("function " ^ name ^ " already defined") ext
  with Not_found ->
  try
    ignore(Hashtbl.find name_env name);
    input_error ("function " ^ name ^ " already defined as a name") ext
  with Not_found ->
   let is_tuple = ref false in
    let opt = ref 0 in
    List.iter (function 
	("data",_) -> is_tuple := true
      |	("typeConverter",_) -> 
	  if List.length tyarg != 1 then
	    input_error "only unary functions can be declared \"typeConverter\"" ext;
	  opt := (!opt) lor Param.fun_TYPECONVERTER
      |	(_,ext) ->
	input_error "for functions, the only allowed options are data, private, and typeConverter" ext) options;
    let cat = if !is_tuple then Tuple else Eq [] in
    Hashtbl.add fun_decls name { f_name = name;
				 f_type = tyarg, tyres;
				 f_private = false;
				 f_options = !opt;
				 f_cat = cat;
				 f_initial_cat = cat }

(** Variables **)

let get_var env (s, ext) =
  try 
    Hashtbl.find env s
  with Not_found -> 
    input_error ("variable " ^ s ^ " not declared") ext

let get_ident_any env (s,ext) =
   try
     let r = Hashtbl.find fun_decls s in
     if (List.length (fst r.f_type) != 0) then
        input_error ("function " ^ s ^ " is used without argument. It expects " ^
                 (string_of_int (List.length (fst r.f_type))) ^ " arguments") ext;
     FunApp (r, [])
   with Not_found ->
     Var (get_var env (s,ext))

let rec gen_env env = function
    [] -> env
  | ((s,ext),ty)::l ->
      let t = get_type ty in
      try
	ignore(Hashtbl.find fun_decls s);
	input_error ("variable " ^ s ^ " already defined as a function") ext
      with Not_found ->
      try
	ignore(Hashtbl.find name_env s);
	input_error ("variable " ^ s ^ " already defined as a name") ext
      with Not_found ->
      try
	ignore(Hashtbl.find env s);
	input_error ("variable " ^ s ^ " already defined") ext
      with Not_found ->
	let v = Terms.new_var s t in
	Hashtbl.add env s v;
	gen_env env l

let create_env l = gen_env (Hashtbl.create 7) l

(* Equations *)

let rec check_eq_term varenv = function
    (PIdent i) -> 
      let t = get_ident_any varenv i in
      (t, Terms.get_term_type t)
  | (PFunApp (f, tlist)) ->
      let (tl, tyl) = List.split (List.map (check_eq_term varenv) tlist) in
      let f' = get_fun f tyl in
      if (f'.f_options land Param.fun_TYPECONVERTER != 0) && (!Param.ignore_types) then
	match tl with
	  [t] -> (t, snd f'.f_type)
	| _ -> internal_error "type converter functions should always be unary"
      else
	(FunApp(f', tl), snd f'.f_type)
  | (PName ((_,ext),_)) -> input_error "No names in equations" ext
  | (PTuple l) -> 
      let (tl, tyl) = List.split (List.map (check_eq_term varenv) l) in
      (FunApp(Terms.get_tuple_fun tyl, tl), Param.bitstring_type)

let check_equation env t1 t2 =
   let var_env = create_env env in
   let (t1', ty1) = check_eq_term var_env t1 in
   let (t2', ty2) = check_eq_term var_env t2 in
   if ty1 != ty2 then
     begin
       (* TO DO locate this error message *)
       user_error "the two members of an equation should have the same type" 
     end;
   TermsEq.register_equation (t1',t2')


let rule_counter = ref 0
let rules = ref []

(* Predicates *)

let pred_env = Param.pred_env

let add_new_name p =
  incr rule_counter;
  let t = List.hd p.p_type in
  let v1 = Terms.new_var_def Param.sid_type in
  let new_name = FunApp(Terms.new_name_fun t, [v1]) in
  let f = Pred(p, List.map (fun _ -> new_name) p.p_type) in
  rules := ([], f, Rule(!rule_counter, Rn p, [], f, []), []) :: (!rules)

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
  | ("elimVar", ext) -> 
      begin
	match ty with
	  [] -> input_error "elimVar does not make sense for predicates without arguments" ext
	| (t1::tr) ->
	    if not (List.for_all (fun t -> t == t1) tr) then
	      input_error "elimVar does not make sense for predicates that have arguments of different types" ext
      end;
      add_new_name r;
      r.p_prop <- r.p_prop lor Param.pred_ANY
  | ("elimVarStrict", ext) -> 
      begin
	match ty with
	  [] -> input_error "elimVarStrict does not make sense for predicates without arguments" ext
	| (t1::tr) ->
	    if not (List.for_all (fun t -> t == t1) tr) then
	      input_error "elimVarStrict does not make sense for predicates that have arguments of different types" ext
      end;
      add_new_name r;
      r.p_prop <- r.p_prop lor Param.pred_ANY_STRICT
  | ("decompData",ext) -> 
      if List.exists (fun t -> t != Param.any_type) ty then
	input_error "decompData makes sense only for predicates that are polymorphic in all their arguments" ext;
      r.p_prop <- r.p_prop lor Param.pred_TUPLE
  | ("decompDataSelect",ext) -> 
      if List.exists (fun t -> t != Param.any_type) ty then
	input_error "decompDataSelect makes sense only for predicates that are polymorphic in all their arguments" ext;
      r.p_prop <- r.p_prop lor Param.pred_TUPLE lor Param.pred_TUPLE_SELECT
  | ("block",_) -> r.p_prop <- r.p_prop lor Param.pred_BLOCKING
  | (s,ext) -> input_error ("unknown predicate qualifier " ^ s) ext

let check_pred (c,ext) tl info =
  let tyl = List.map (get_type_polym true) tl in
  if Hashtbl.mem pred_env c then
    input_error ("predicate " ^ c ^ " already declared") ext
  else
    let r = { p_name = c; 
	      p_type = tyl; 
	      p_prop = 0; 
	      p_info = [] } in
    List.iter (interpret_info tyl r) info;
    if List.exists (fun t -> t == Param.any_type) tyl then
      r.p_info <- [PolymPred(c, r.p_prop, tyl)];
    Hashtbl.add pred_env c r

let get_pred (c,ext) tl =
  try
    let r =  Hashtbl.find pred_env c in
    if not ((List.length r.p_type == List.length tl) && (List.for_all2 (fun t1 t2 -> t1 == t2 || t1 == Param.any_type) r.p_type tl)) then
      input_error ("predicate " ^ c ^ " expects arguments of type " ^ 
		   (Terms.tl_to_string ", " r.p_type) ^
		   " but is given arguments of type " ^
		   (Terms.tl_to_string ", " tl)) ext;
    if List.exists (fun t -> t == Param.any_type) r.p_type then
      Param.get_pred (PolymPred(r.p_name, r.p_prop, tl))
    else
      r
  with Not_found ->
    input_error ("predicate " ^ c ^ " not declared") ext


let rec check_term env = function
    (PIdent i) -> 
      let t = get_ident_any env i in
      (t, Terms.get_term_type t)
  | (PFunApp(f,l)) -> 
      let (tl, tyl) = List.split (List.map (check_term env) l) in
      let f' = get_fun f tyl in
      if (f'.f_options land Param.fun_TYPECONVERTER != 0) && (!Param.ignore_types) then
	match tl with
	  [t] -> (t, snd f'.f_type)
	| _ -> internal_error "type converter functions should always be unary"
      else
	(FunApp(f', tl), snd f'.f_type)
  | (PTuple l) -> 
      let (tl, tyl) = List.split (List.map (check_term env) l) in
      (FunApp(Terms.get_tuple_fun tyl, tl), Param.bitstring_type)
  | (PName(n,l)) -> 
      let (tl, tyl) = List.split (List.map (check_term env) l) in
      let n' = get_name n tyl in
      (FunApp(n', tl), snd n'.f_type)

let check_cterm env (p,t) =
  let (tl, tyl) = List.split (List.map (check_term env) t) in
  (get_pred p tyl, tl)

let format_get_ident_any env (s,ext) =
   try
     let r = Hashtbl.find fun_decls s in
     if (List.length (fst r.f_type) != 0) then
        input_error ("function " ^ s ^ " is used without argument. It expects " ^
                 (string_of_int (List.length (fst r.f_type))) ^ " arguments") ext;
     FFunApp (r, [])
   with Not_found ->
     FVar (get_var env (s,ext))

let rec check_format env = function
    (PFIdent i) -> 
      let t = format_get_ident_any env i in
      (t, Terms.get_format_type t)      
  | (PFFunApp(f,l)) -> 
      let (tl, tyl) = List.split (List.map (check_format env) l) in
      let f' = get_fun f tyl in
      if (f'.f_options land Param.fun_TYPECONVERTER != 0) && (!Param.ignore_types) then
	match tl with
	  [t] -> (t, snd f'.f_type)
	| _ -> internal_error "type converter functions should always be unary"
      else
	(FFunApp(f', tl), snd f'.f_type)
  | (PFTuple l) -> 
      let (tl, tyl) = List.split (List.map (check_format env) l) in
      (FFunApp(Terms.get_tuple_fun tyl, tl), Param.bitstring_type)
  | (PFName(n,l)) -> 
      let (tl, tyl) = List.split (List.map (check_format env) l) in
      let n' = get_name n tyl in
      (FFunApp(n', tl), snd n'.f_type)
  | PFAny i -> 
      let v = get_var env i in
      (FAny v, v.btype)


let check_cformat_fact env (p,t) =
  let (tl, tyl) = List.split (List.map (check_format env) t) in
  (get_pred p tyl, tl)

let rec check_one_hyp (hyp_accu,constra_accu) env (fact, ext) = 
  match fact with
  | PSNeq(t1,t2) -> 
      let (t1',ty1) = check_term env t1 in
      let (t2',ty2) = check_term env t2 in
      if ty1 != ty2 then
	input_error "the two arguments of an inequality should have the same type" ext;
      (hyp_accu, [Neq(t1',t2')] :: constra_accu)
  | PSimpleFact(p,l) ->
      let (p',l') = check_cterm env (p,l) in
      (Pred(p',l')::hyp_accu, constra_accu)

let check_simple_fact env (fact, ext) = 
  match fact with
  | PSNeq(t1,t2) -> input_error "<> constraint not allowed here" ext
  | PSimpleFact(p,l) ->
      let (p',l') = check_cterm env (p,l) in
      Pred(p',l')

let rec check_red = function 
    [] -> ()
  | (env, Clause(i,c))::l -> 
      begin
      check_red l;
      try 
	let env = create_env env in
	incr rule_counter;
	let (hyp, constra) = List.fold_right (fun onehyp accu -> check_one_hyp accu env onehyp) i ([],[]) in
	let concl = check_simple_fact env c in
	let constra = Rules.simplify_constra_list (concl :: hyp) constra in
	rules := (hyp, concl, 
	 Rule(!rule_counter, LblNone, hyp, concl, constra), constra) :: (!rules)

      with Rules.FalseConstraint -> ()
      end
  | (env, Equiv(i,c,select))::l -> 
      check_red l;
      let env = create_env env in
      let (hyp, constra) = List.fold_right (fun onehyp accu -> check_one_hyp accu env onehyp) i ([],[]) in
      if constra != [] then 
	Parsing_helper.user_error "Inequality constraints not allowed in equivalences";
      let concl = check_simple_fact env c in
      let requiv = 
	incr rule_counter;
	(hyp, concl, Rule(!rule_counter, LblEquiv, hyp, concl, []), []) 
      in
      Rules.add_equiv (hyp, concl, !rule_counter);
      if not select then Terms.add_unsel concl;
      rules := (List.map (fun h -> 
	incr rule_counter;
	([concl], h, Rule(!rule_counter, LblEquiv, [concl], h, []), [])) hyp)
      @ (requiv :: (!rules))
      

let gen_data_clauses () =
  let output_rule_hist h =
    match History.get_rule_hist h with
      (Rule(_, t, hyp, concl, constra)) ->
	incr rule_counter;
	rules := (hyp, concl, Rule(!rule_counter, t, hyp, concl, constra), constra) :: (!rules)
    | _ -> Parsing_helper.internal_error "unexpected result in output_rule_hist"
  in

  let gen_fun pred f =
    output_rule_hist (Apply(Func(f), pred));
    for n = 0 to (List.length (fst f.f_type))-1 do
      output_rule_hist (Apply(Proj(f,n), pred))
    done
  in

  let tuples_rules p =
    Hashtbl.iter (fun _ f ->
      match f.f_cat with
	Tuple -> if (f.f_options land Param.fun_TYPECONVERTER == 0) ||
	            (not (!Param.ignore_types)) then gen_fun p f
      | _ -> ()) fun_decls;
    Hashtbl.iter (fun _ f -> gen_fun p f) Terms.tuple_table
  in
  
  Hashtbl.iter (fun _ p ->
    if (p.p_prop land Param.pred_TUPLE != 0) then
      begin
	if match p.p_info with
	     [PolymPred (_,_,tl)] -> List.for_all (fun t -> t == Param.any_type) tl
	   | _ -> false
	then 
	  tuples_rules p
	else
	  Parsing_helper.internal_error "In the typed front-end, only polymorphic predicates can be declated data"
      end
	       ) pred_env

let query_facts = ref ([] : fact list)

let rec check_all = function 
    (TTypeDecl(i))::l -> check_type_decl i; check_all l
  | (TNameDecl(n,t))::l -> check_name_decl n t; check_all l
  | (TFunDecl(f,argt,rest,i))::l -> check_fun_decl f argt rest i; check_all l
  | (TConstDecl(f,rest,i))::l -> check_fun_decl f [] rest i; check_all l
  | (TEquation(env,t1,t2))::l -> check_equation env t1 t2; check_all l
  | (TQuery(env,fact)) :: l -> 
      let env = create_env env in
      query_facts := (check_simple_fact env fact) :: (!query_facts);
      check_all l
  | (TNoUnif (env,fact,n)) :: l ->
      let env = create_env env in
      Selfun.add_no_unif (check_cformat_fact env fact) (-n);
      check_all l
  | (TNot (env,fact)) :: l ->
      let env = create_env env in
      Rules.add_not (check_simple_fact env fact);
      check_all l
  | (TElimtrue (env,fact)) :: l ->
      let env = create_env env in
      let f = check_simple_fact env fact in
      incr rule_counter;
      rules := ([], f, Rule(!rule_counter, LblNone, [], f, []), []) :: (!rules);
      Rules.add_elimtrue (!rule_counter, f);
      check_all l
  | (TPredDecl (p, argt, info)) :: l ->
      check_pred p argt info;
      check_all l
  | [TReduc r] -> 
      check_red r;
      gen_data_clauses();
      !rules
  | _ -> internal_error "The first reduc part is not the last element of the file"

let parse_file s = 
  let decl = parse s in
  (* ignoreTypes must be set before doing the rest of the work
     Setting all parameters beforehand does not hurt. *)
  List.iter (function
      TSet((p,ext),v) -> 
	begin
	  match (p,v) with
	    "ignoreTypes", _ -> Param.boolean_param Param.ignore_types p ext v
	  | _,_ -> Param.common_parameters p ext v
	end
    | _ -> ()) decl;
  check_all (List.filter (function 
      TSet _ -> false
    | _ -> true) decl)
