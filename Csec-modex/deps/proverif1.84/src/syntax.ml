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
        Parser.all Lexer.token lexbuf
      with Parsing.Parse_error ->
        input_error "Syntax error" (extent lexbuf)
    in
    close_in ic;
    ptree
  with Sys_error s ->
    user_error ("File error: " ^ s ^ "\n")

(* Functions *)

let fun_decls = Param.fun_decls

let get_fun (s,ext) arity =
  try
    let r = Hashtbl.find fun_decls s in
    let r_arity = List.length (fst r.f_type) in
    if r_arity != arity then
      input_error ("arity of function " ^ s ^ " should be " ^ 
                   (string_of_int r_arity)) ext;
    r
  with Not_found ->
    input_error ("function " ^ s ^ " not defined") ext

let get_var env s =
  try 
    Hashtbl.find env s
  with Not_found -> 
    let r = Terms.new_var s Param.any_type in
    Hashtbl.add env s r;
    r

let get_ident_any env (s,ext) =
   try
     let r = Hashtbl.find fun_decls s in
     let r_arity = List.length (fst r.f_type) in
     if (r_arity != 0) then
        input_error ("function " ^ s ^ " is used without argument. It expects " ^
                 (string_of_int r_arity) ^ " arguments") ext;
     FunApp (r, [])
   with Not_found ->
     Var (get_var env s)

let check_fun_decl is_tuple (name,ext) arity =
    try
      ignore(Hashtbl.find fun_decls name);
      input_error ("function " ^ name ^ " already defined") ext
    with Not_found ->
      let cat = if is_tuple then Tuple else Eq [] in
      Hashtbl.add fun_decls name { f_name = name;
				   f_type = (Terms.copy_n arity Param.any_type), Param.any_type;
				   f_private = false;
				   f_options = 0;
				   f_cat = cat;
				   f_initial_cat = cat }

(* Equations *)

let rec check_eq_term varenv = function
  (PIdent i) -> 
    get_ident_any varenv i
| (PFunApp (f, tlist)) ->
    FunApp(get_fun f (List.length tlist),
	   List.map (check_eq_term varenv) tlist)
| (PName ((_,ext),_)) -> input_error "No names in equations" ext
| (PTuple l) -> FunApp(Terms.get_tuple_fun (List.map (fun _ -> Param.any_type) l), 
                       List.map (check_eq_term varenv) l)

let check_equation (t1, t2) =
   let var_env = Hashtbl.create 7 in
   let t1' = check_eq_term var_env t1 in
   let t2' = check_eq_term var_env t2 in
   TermsEq.register_equation (t1',t2')


let rule_counter = ref 0
let rules = ref []

(* Predicates *)

let pred_env = Param.pred_env

let add_new_name p =
  incr rule_counter;
  let v1 = Terms.new_var_def Param.any_type in
  let new_name = FunApp(Terms.new_name_fun Param.any_type, [v1]) in
  let f = Pred(p, List.map (fun _ -> new_name) p.p_type) in
  rules := ([], f, Rule(!rule_counter, Rn p, [], f, []), []) :: (!rules)

let rec interpret_info arity r = function
      ("memberOptim", ext) -> 
	if arity != 2 then
	  input_error "memberOptim makes sense only for predicates of arity 2" ext;
	r.p_prop <- r.p_prop lor Param.pred_ELEM
    | ("refTransAtt", ext) ->
	if arity != 2 then
	  input_error "refTransAtt makes sense only for predicates of arity 2" ext;
	r.p_prop <- r.p_prop lor Param.pred_REFTRANS
    | ("elimVar", ext) -> 
	if arity == 0 then
	  input_error "elimVar does not make sense for predicates without arguments" ext;
	add_new_name r;
	r.p_prop <- r.p_prop lor Param.pred_ANY
    | ("elimVarStrict", ext) -> 
	if arity == 0 then
	  input_error "elimVarStrict does not make sense for predicates without arguments" ext;
	add_new_name r;
	r.p_prop <- r.p_prop lor Param.pred_ANY_STRICT
    | ("decompData",_) -> r.p_prop <- r.p_prop lor Param.pred_TUPLE
    | ("decompDataSelect",_) -> r.p_prop <- r.p_prop lor Param.pred_TUPLE lor Param.pred_TUPLE_SELECT
    | ("block",_) -> r.p_prop <- r.p_prop lor Param.pred_BLOCKING
    | (s,ext) -> input_error ("unknown predicate qualifier " ^ s) ext

let check_pred (c,ext) arity info =
  if Hashtbl.mem pred_env c then
    input_error ("predicate " ^ c ^ " already declared") ext
  else
    let r = { p_name = c; 
	      p_type = Terms.copy_n arity Param.any_type; 
	      p_prop = 0; 
	      p_info = [] } 
    in
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
    let r = { p_name = c; 
	      p_type = Terms.copy_n arity Param.any_type; 
	      p_prop = 0; 
	      p_info = [] } 
    in
    Hashtbl.add pred_env c r;
    r

(* Names *)

let name_env = Hashtbl.create 7

let get_name s arity ext =
  try
    let r = Hashtbl.find name_env s in
    let r_arity = List.length (fst r.f_type) in
    if r_arity != arity then
      input_error ("arity of name " ^ s ^ " should be " ^
                   (string_of_int r_arity)) ext;
    r
  with Not_found ->
    let cat = Name { prev_inputs = None; prev_inputs_meaning = [] } in
    let r = { f_name = s; 
	      f_type = (Terms.copy_n arity Param.any_type), Param.any_type; 
              f_cat = cat;
	      f_initial_cat = cat;
              f_private = true;
	      f_options = 0 } 
    in
    Hashtbl.add name_env s r;
    r

(* Clauses *)

let rec check_term env = function
    (PIdent i) -> get_ident_any env i 
  | (PFunApp(f,l)) -> 
      FunApp (get_fun f (List.length l), 
	      List.map (check_term env) l)
  | (PTuple l) -> FunApp(Terms.get_tuple_fun (List.map (fun _ -> Param.any_type) l), 
                         List.map (check_term env) l)
  | (PName((s,ext),l)) -> 
      FunApp(get_name s (List.length l) ext, 
	     List.map (check_term env) l)

let check_cterm env (p,t) =
   (get_pred p (List.length t), List.map (check_term env) t)

let format_get_ident_any env (s,ext) =
   try
     let r = Hashtbl.find fun_decls s in
     let r_arity = List.length (fst r.f_type) in
     if (r_arity != 0) then
        input_error ("function " ^ s ^ " is used without argument. It expects " ^
                 (string_of_int r_arity) ^ " arguments") ext;
     FFunApp (r, [])
   with Not_found ->
     FVar (get_var env s)

let rec check_format env = function
    (PFIdent i) -> format_get_ident_any env i
  | (PFFunApp(f,l)) -> 
      FFunApp (get_fun f (List.length l),
	       List.map (check_format env) l)
  | (PFTuple l) -> FFunApp(Terms.get_tuple_fun (List.map (fun _ -> Param.any_type) l), 
                           List.map (check_format env) l)
  | (PFName((s,ext),l)) -> 
      FFunApp(get_name s (List.length l) ext,
	      List.map (check_format env) l)
  | PFAny (s,ext) -> 
      FAny (get_var env s)


let check_cformat_fact env (p,t) =
   (get_pred p (List.length t), List.map (check_format env) t)

let rec check_one_hyp (hyp_accu,constra_accu) env (fact, ext) = 
  match fact with
  | PSNeq(t1,t2) -> (hyp_accu, [Neq(check_term env t1, check_term env t2)] ::
		     constra_accu)
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
  | (Clause(i,c)::l) -> 
      begin
      check_red l;
      try 
	let env = Hashtbl.create 7 in
	incr rule_counter;
	let (hyp, constra) = List.fold_right (fun onehyp accu -> check_one_hyp accu env onehyp) i ([],[]) in
	let concl = check_simple_fact env c in
	let constra = Rules.simplify_constra_list (concl :: hyp) constra in
	rules := (hyp, concl, 
	 Rule(!rule_counter, LblNone, hyp, concl, constra), constra) :: (!rules)

      with Rules.FalseConstraint -> ()
      end
  | (Equiv(i,c,select)::l) -> 
      check_red l;
      let env = Hashtbl.create 7 in
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
      rules := 
      (List.map (fun h -> 
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
	Tuple -> gen_fun p f
      | _ -> ()) fun_decls;
    Hashtbl.iter (fun _ f -> gen_fun p f) Terms.tuple_table
  in
  
  Hashtbl.iter (fun _ p ->
    if (p.p_prop land Param.pred_TUPLE != 0) then
      tuples_rules p;
	       ) pred_env


let query_facts = ref ([] : fact list)

let rec check_all = function
    (FunDecl (f,i))::l -> check_fun_decl false f i; check_all l
  | (DataFunDecl(f,i))::l -> check_fun_decl true f i; check_all l
  | (Equation(t1,t2))::l -> check_equation (t1,t2); check_all l
  | (Query fact) :: l -> 
      let env = Hashtbl.create 7 in
      query_facts := (check_simple_fact env fact) :: (!query_facts);
      check_all l
  | (NoUnif (fact,n)) :: l ->
      let env = Hashtbl.create 7 in
      Selfun.add_no_unif (check_cformat_fact env fact) (-n);
      check_all l
  | (Not fact) :: l ->
      let env = Hashtbl.create 7 in
      Rules.add_not (check_simple_fact env fact);
      check_all l
  | (Elimtrue fact) :: l ->
      let env = Hashtbl.create 7 in
      let f = check_simple_fact env fact in
      incr rule_counter;
      rules := ([], f, Rule(!rule_counter, LblNone, [], f, []), []) :: (!rules);
      Rules.add_elimtrue (!rule_counter, f);
      check_all l
  | (PredDecl (p, arity, info)) :: l ->
      check_pred p arity info;
      check_all l
  | (Param((p,ext),v)) :: l -> 
      Param.common_parameters p ext v;
      check_all l
  | [Reduc r] -> 
      check_red r;
      gen_data_clauses();
      !rules
  | _ -> internal_error "The first reduc part is not the last element of the file"

let parse_file s = check_all (parse s)

