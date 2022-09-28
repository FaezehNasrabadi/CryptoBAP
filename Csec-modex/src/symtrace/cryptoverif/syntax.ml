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
open Ptree
open Parsing_helper
open Types
open Terms

(* Parse a file *)

let parse filename =
  try
    let ic = open_in filename in
    let lexbuf = Lexing.from_channel ic in
    lexbuf.Lexing.lex_curr_p <- { lexbuf.Lexing.lex_curr_p with 
                                  Lexing.pos_fname = filename };    
    let ptree =
      try
	if (!Settings.front_end) == Settings.Channels then
          Parser.all Lexer.token lexbuf
	else
	  Oparser.all Olexer.token lexbuf
      with 
	Parsing.Parse_error ->
          input_error "Syntax error" (extent lexbuf)
      |	IllegalCharacter ->
	  input_error "Illegal character" (extent lexbuf)
    in
    close_in ic;
    ptree
  with Sys_error s ->
    user_error ("File error: " ^ s ^ "\n")

let parse_lib filename =
  let filename = filename ^ (if (!Settings.front_end) == Settings.Channels then ".cvl" else ".ocvl") in
  try
    let ic = open_in filename in
    let lexbuf = Lexing.from_channel ic in
    lexbuf.Lexing.lex_curr_p <- { lexbuf.Lexing.lex_curr_p with 
                                  Lexing.pos_fname = filename };    
    let ptree =
      try
	if (!Settings.front_end) == Settings.Channels then
          Parser.lib Lexer.token lexbuf
	else
	  Oparser.lib Olexer.token lexbuf
      with Parsing.Parse_error ->
        input_error "Syntax error" (extent lexbuf)
    in
    close_in ic;
    ptree
  with Sys_error s ->
    user_error ("File error: " ^ s ^ "\n")

let parse_with_lib filename =
  let l1 = parse_lib (!Settings.lib_name) in
  let (l,p) = parse filename in
  (l1 @ l, p)

(* Environment.
   May contain function symbols, variables, ...
   Is a map from strings to the description of the ident *)

open Stringmap

let init_env () =
   let m = StringMap.empty in
   let m1 = StringMap.add "true" (EFunc Settings.c_true)
       (StringMap.add "false" (EFunc Settings.c_false)
	  (StringMap.add "not" (EFunc Settings.f_not) m)) in
   StringMap.add "bitstring" (EType Settings.t_bitstring)
     (StringMap.add "bitstringbot" (EType Settings.t_bitstringbot)
	(StringMap.add "bool" (EType Settings.t_bool) m1))

type location_type =
    InProcess
  | InEquivalence

let current_location = ref InProcess

(* Declarations *)

let macrotable = ref StringMap.empty
let statements = ref ([]: statement list)
let collisions = ref ([]: collision list)
let equivalences = ref ([]: equiv list)
let move_new_eq = ref ([]: (typet * equiv) list)
let queries_parse = ref ([]: Ptree.query list)
let proof = ref (None : Ptree.ident list list option)

type binder_env_content = 
    Uniq of binder
  | UniqNoType
  | Ambiguous
  | FindCond
let binder_env = (Hashtbl.create 7: (string, binder_env_content) Hashtbl.t)
(* binder_env_content = Uniq b means that the only declaration of this
binder is b and its type is known; 
binder_env_content = UniqNoType means that there is a unique declaration of this
binder, and it has no explicit type; 
binder_env_content = Ambiguous means that there are 
several declarations of this binder.
binder_env_content = FindCond means that this binder is defined in
a find condition, so array references to this binder are forbidden. *)

let repl_binders = (Hashtbl.create 7: (int, term) Hashtbl.t)

(* Check types *)

let check_type ext e t =
  if (e.t_type != t) && (e.t_type != Settings.t_any) && (t != Settings.t_any) then
    input_error ("This expression has type " ^ e.t_type.tname ^ " but expects type " ^ t.tname) ext

let check_bit_string_type ext t =
  match t.tcat with
    BitString -> ()
  | _ -> input_error "Some bitstring type expected" ext

let rec check_type_list ext pel el tl =
  match (pel, el, tl) with
    [],[],[] -> ()
  | (pe::pel, e::el, t::tl) ->
      check_type (snd pe) e t;
      check_type_list ext pel el tl
  | _ ->
      input_error ("Unexpected number of arguments") ext

let rec check_array_type_list ext pel el cur_array creation_array =
  match (pel, el, creation_array) with
    [],[],[] -> []
  | [],[],_ -> 
      (* Allow incomplete array arguments. They are automatically
         completed with cur_array *)
      let n = (List.length cur_array) - (List.length creation_array) in
      if n < 0 then 
	input_error "Unexpected number of array specifiers" ext;
      let cur_array_rest = skip n cur_array in
      if List.for_all2 (==) cur_array_rest creation_array then
	cur_array_rest
      else
	input_error "Unexpected number of array specifiers" ext
  | (pe::pel, e::el, t::tl) ->
      check_type (snd pe) e t.t_type;
      e::(check_array_type_list ext pel el cur_array tl)
  | _ ->
      input_error ("Unexpected number of array specifiers") ext

(**** First pass: build binder_env ****)

(* Add a binder in the environment *)

let add_in_env1 s t cur_array =
  if Hashtbl.mem binder_env s then
    Hashtbl.replace binder_env s Ambiguous
  else
    let b = Terms.create_binder s 0 t cur_array in
    Hashtbl.add binder_env s (Uniq b)

let add_in_env1notype s =
  if Hashtbl.mem binder_env s then
    Hashtbl.replace binder_env s Ambiguous
  else
    Hashtbl.add binder_env s UniqNoType

let add_in_env1findcond s =
  if Hashtbl.mem binder_env s then
    Hashtbl.replace binder_env s Ambiguous
  else
    Hashtbl.add binder_env s FindCond

(* Check terms *)

(* Should the indexes bound by find be added in the environment
   for future array references? Yes for normal terms,
   no in terms of equivalences. *)
let add_find = ref true

let rec check_term1 in_find_cond cur_array = function
    PIdent (s, ext), ext2 -> ()
  | (PArray(_, tl) | PFunApp(_, tl) | PTuple(tl)), ext -> 
      List.iter (check_term1 in_find_cond cur_array) tl
  | PTestE(t1, t2, t3), ext ->
      check_term1 in_find_cond cur_array t1;
      check_term1 in_find_cond cur_array t2;
      check_term1 in_find_cond cur_array t3
  | PFindE(l0,t3,_), ext ->
      List.iter (fun (bl,def_list,t1,t2) ->
	List.iter (fun ((s1,ext1),(s2,ext2)) ->
	  let p = get_param (!env) s2 ext2 in
	  if in_find_cond then
	    add_in_env1findcond s1
	  else if !add_find then
	    add_in_env1 s1 (type_for_param p) cur_array
	  else 
	    add_in_env1notype s1) bl;
	List.iter (check_br1 cur_array) def_list;
	check_term1 true cur_array t1;
	check_term1 in_find_cond cur_array t2) l0;
      check_term1 in_find_cond cur_array t3
  | PLetE(pat, t1, t2, topt), ext ->
      check_pattern1 in_find_cond cur_array false pat;
      check_term1 in_find_cond cur_array t1;
      check_term1 in_find_cond cur_array t2;
      begin
	match topt with
	  None -> ()
	| Some t3 -> check_term1 in_find_cond cur_array t3
      end
  | PResE((s1,ext1),(s2,ext2),t), ext ->
      let ty' = get_type (!env) s2 ext2 in
      if in_find_cond then
	add_in_env1findcond s1
      else
	add_in_env1 s1 ty' cur_array;
      check_term1 in_find_cond cur_array t
  | PEventE(id), ext -> ()
  | (PEqual(t1,t2) | PDiff(t1,t2) | PAnd(t1,t2) | POr(t1,t2)), ext ->
      check_term1 in_find_cond cur_array t1;
      check_term1 in_find_cond cur_array t2
  | PInjEvent _,ext -> 
      Parsing_helper.input_error "inj: allowed only in queries" ext

and check_br1 cur_array (_,tl) = 
  List.iter (check_term1 true cur_array) tl

(* Check pattern *)

and check_pattern1 in_find_cond cur_array needtype = function
    PPatVar ((s1,ext1), tyopt), _ ->
      begin
	match tyopt with
	  None -> 
	    if needtype then
	      input_error "type needed for this variable" ext1
	    else if in_find_cond then
	      add_in_env1findcond s1
	    else
	      add_in_env1notype s1
	| Some (s2,ext2) ->
	    let ty' = get_type (!env) s2 ext2 in
	    if in_find_cond then
	      add_in_env1findcond s1
	    else
	      add_in_env1 s1 ty' cur_array
      end
  | PPatTuple l, _ ->
      List.iter (check_pattern1 in_find_cond cur_array true) l
  | PPatFunApp(f,l), _ ->
      List.iter (check_pattern1 in_find_cond cur_array false) l
  | PPatEqual t, _ ->
      check_term1 in_find_cond cur_array t

(* Check equivalence statements *)

let check_binder1 cur_array ((s1,ext1),(s2,ext2),opt) = 
  let t = get_type (!env) s2 ext2 in
  add_in_env1 s1 t cur_array

let check_binderi1 cur_array ((s1,ext1),ty) = 
  let t = 
  match ty with
    Tid (s2, ext2) -> get_type (!env) s2 ext2 
  | TBound (s2, ext2) -> 
      let p = get_param (!env) s2 ext2 in
      type_for_param p
  in
  add_in_env1 s1 t cur_array

let rec check_fungroup1 cur_array = function
    PReplRestr((occ, idopt, (rep,ext)), restrlist, funlist) ->
      let pn = get_param (!env) rep ext in
      let t = type_for_param pn in 
      let b = Terms.create_binder
	  (match idopt with 
	    None -> "!" 
	  | Some(id,ext) -> id) (Terms.new_vname()) t []
      in
      let cur_array1 = Terms.term_from_binder b in
      Hashtbl.add repl_binders occ cur_array1;
      let cur_array' = cur_array1 :: cur_array in
      List.iter (check_binder1 cur_array') restrlist;
      List.iter (check_fungroup1 cur_array') funlist
  | PFun(_, arglist, tres, _) ->
      List.iter (check_binderi1 cur_array) arglist;
      add_find := false;
      check_term1 false cur_array tres;
      add_find := true

(* Check process *)

let rec check_process1 cur_array = function
    PNil, _ | PYield, _ -> ()
  | PPar(p1,p2), _ -> 
      check_process1 cur_array p1;
      check_process1 cur_array p2
  | PRepl(occ,idopt,(s2,ext2),p), _ ->
      let pn = get_param (!env) s2 ext2 in
      let t = type_for_param pn in 
      let b = Terms.create_binder 
	  (match idopt with 
	      None -> "!" 
	    | Some(id,ext) -> id) (Terms.new_vname()) t []
      in
      let cur_array1 = Terms.term_from_binder b in
      Hashtbl.add repl_binders occ cur_array1;
      check_process1 (cur_array1::cur_array) p
  | PRestr((s1,ext1),(s2,ext2),p), _ ->
      let t = get_type (!env) s2 ext2 in
      add_in_env1 s1 t cur_array;
      check_process1 cur_array p
  | PLetDef(s,ext), _ ->
      check_process1 cur_array (get_process (!env) s ext)
  | PTest(t,p1,p2), _ ->
      check_term1 false cur_array t;
      check_process1 cur_array p1;
      check_process1 cur_array p2
  | PFind(l0,p2,_), _ ->
      List.iter (fun (bl,def_list,t,p1) ->
	List.iter (fun ((s1,ext1),(s2,ext2)) ->
	  let p = get_param (!env) s2 ext2 in
	  add_in_env1 s1 (type_for_param p) cur_array) bl;
	List.iter (check_br1 cur_array) def_list;
	check_term1 true cur_array t;
	check_process1 cur_array p1) l0;
      check_process1 cur_array p2
  | PInput(t, pat, p), _ ->
      if (!Settings.front_end) == Settings.Channels then
	check_term1 false cur_array t;
      check_pattern1 false cur_array true pat;
      check_process1 cur_array p 
  | POutput(t1,t2,p), _ ->
      if (!Settings.front_end) == Settings.Channels then
	check_term1 false cur_array t1;
      check_term1 false cur_array t2;
      check_process1 cur_array p
  | PLet(pat, t, p1, p2), _ ->
      check_term1 false cur_array t;
      check_pattern1 false cur_array false pat;
      check_process1 cur_array p1;
      check_process1 cur_array p2 
  | PEvent(t,p), _ ->
      check_term1 false cur_array t;
      check_process1 cur_array p
      

(**** Second pass: type check everything ****)

(* Add a binder in the environment *)

let add_in_env env s ext t cur_array =
  try
    match Hashtbl.find binder_env s with
      Uniq b -> 
	(StringMap.add s (EVar b) env, b)
    | UniqNoType | FindCond ->
	let b = Terms.create_binder s 0 t cur_array in
	(StringMap.add s (EVar b) env, b)	
    | Ambiguous ->
	let b = Terms.create_binder s (Terms.new_vname()) t cur_array in
	(StringMap.add s (EVar b) env, b)
  with Not_found ->
    internal_error ("Binder " ^ s ^ " should be in binder_env")

(* Check that t does not contain if/find/let/new/event *)

let rec check_no_iffindletnewevent (t,ext) =
  match t with
    PIdent _ -> () 
  | PArray (_,l) | PFunApp(_,l) | PTuple l ->
      List.iter check_no_iffindletnewevent l
  | PEqual(t1,t2) | PDiff(t1,t2) | POr(t1,t2) | PAnd(t1,t2) ->
      check_no_iffindletnewevent t1;
      check_no_iffindletnewevent t2      
  | PTestE _ | PLetE _ | PFindE _ ->
      if (!Settings.front_end) == Settings.Channels then
	Parsing_helper.input_error "if, let, find should not occur in defined conditions,\nor in input channels" ext
      else
	Parsing_helper.input_error "if, let, find should not occur in defined conditions" ext
  | PResE _ -> 
      Parsing_helper.input_error "new should not occur as term" ext
  | PEventE _ -> 
      Parsing_helper.input_error "event should not occur as term" ext
  | PInjEvent _ -> 
      Parsing_helper.input_error "inj: allowed only in queries" ext

(* Check that t does not contain new *)

let rec check_no_new (t,ext) =
  match t with
    PIdent _ -> () 
  | PArray (_,l) | PFunApp(_,l) | PTuple l ->
      List.iter check_no_new l
  | PEqual(t1,t2) | PDiff(t1,t2) | POr(t1,t2) | PAnd(t1,t2) ->
      check_no_new t1;
      check_no_new t2
  | PTestE(t1,t2,t3) ->
      check_no_new t1;
      check_no_new t2;
      check_no_new t3
  | PLetE(pat,t1,t2,topt) ->
      check_no_new_pat pat;
      check_no_new t1;
      check_no_new t2;
      begin
	match topt with
	  None -> ()
	| Some t3 -> check_no_new t3
      end
  | PFindE(l0,t3,_) ->
      List.iter (fun (_,def_list,t1,t2) ->
	(* def_list will be checked by check_no_iffindletnew
	   when translating this find *)
	check_no_new t1;
	check_no_new t2) l0;
      check_no_new t3
  | PResE _ -> 
      Parsing_helper.input_error "new should not occur as term" ext
  | PEventE _ -> 
      Parsing_helper.input_error "event should not occur as term" ext
  | PInjEvent _ -> 
      Parsing_helper.input_error "inj: allowed only in queries" ext

and check_no_new_pat (pat,_) = 
  match pat with
    PPatVar _ -> ()
  | PPatTuple l | PPatFunApp(_,l) -> List.iter check_no_new_pat l
  | PPatEqual t -> check_no_new t

(* Check terms *)

let rec check_term cur_array env = function
    PIdent (s, ext), ext2 ->
      begin
      try 
	match StringMap.find s env with
	  EVar(b) -> { t_desc = Var(b,b.args_at_creation); t_type = b.btype; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| EFunc(f) -> 
	    if fst (f.f_type) = [] then
	      { t_desc = FunApp(f, []); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	    else
	      input_error (s ^ " has no arguments but expects some") ext
	| _ -> input_error (s ^ " should be a variable or a function") ext
      with Not_found -> try
	match Hashtbl.find binder_env s with
	  Uniq b -> 
	    let tl'' = check_array_type_list ext2 [] [] cur_array b.args_at_creation in 
	    { t_desc = Var(b,tl''); t_type = b.btype; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| Ambiguous | UniqNoType | FindCond ->
	    input_error (s ^ " is referenced outside its scope and is either\ndefined without type, defined several times, defined in a condition of find, or defined in find in an equivalence") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PArray((s, ext), tl), ext2 ->
      let tl' = List.map (check_term cur_array env) tl in
      begin
      try
	match Hashtbl.find binder_env s with
	  Uniq b -> 
	    let tl'' = check_array_type_list ext2 tl tl' cur_array b.args_at_creation in 
	    { t_desc = Var(b,tl''); t_type = b.btype; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| Ambiguous | UniqNoType | FindCond ->
	    input_error (s ^ " is referenced in an array reference and is either\ndefined without type, defined several times, defined in a condition of find, or defined in find in an equivalence") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PFunApp((s,ext), tl),ext2 ->
      let tl' = List.map (check_term cur_array env) tl in
      begin
      try 
	match StringMap.find s env with
	  EFunc(f) ->
	    check_type_list ext2 tl tl' (fst f.f_type);
	    { t_desc = FunApp(f, tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| _ -> input_error (s ^ " should be a function") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PTuple(tl), ext2 ->
      let tl' = List.map (check_term cur_array env) tl in
      let f = Settings.get_tuple_fun (List.map (fun t -> t.t_type) tl') in
      check_type_list ext2 tl tl' (fst f.f_type);
      { t_desc = FunApp(f, tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
  | PTestE(t1, t2, t3), ext ->
      let t1' = check_term cur_array env t1 in
      let t2' = check_term cur_array env t2 in
      let t3' = check_term cur_array env t3 in
      check_type (snd t1) t1' Settings.t_bool;
      if (t2'.t_type != t3'.t_type) && (t2'.t_type != Settings.t_any) && (t3'.t_type != Settings.t_any) then
	Parsing_helper.input_error "Both branches of a test should yield the same type" ext;
      { t_desc = TestE(t1', t2', t3'); t_type = t2'.t_type; t_occ = new_occ(); t_loc = ext; t_facts = None }
  | PLetE(pat, t1, t2, topt), ext ->
      let t1' = check_term cur_array env t1 in
      let (env', pat') = check_pattern cur_array env (Some t1'.t_type) pat in
      let t2' = check_term cur_array env' t2 in
      let topt' = 
	match topt, pat with
	  Some t3, _ -> Some (check_term cur_array env t3)
	| None, (PPatVar _, _) -> None
	| None, _ -> Parsing_helper.input_error "When a let in an expression has no else part, it must be of the form let x = M in M'" ext
      in
      begin
	match topt' with
	  None -> ()
	| Some t3' -> if (t2'.t_type != t3'.t_type)  && (t2'.t_type != Settings.t_any) && (t3'.t_type != Settings.t_any) then
	    input_error "Both branches of a let should return the same type" ext
      end;
      { t_desc = LetE(pat', t1', t2', topt'); t_type = t2'.t_type; t_occ = new_occ(); t_loc = ext; t_facts = None }
  | PResE((s1,ext1),(s2,ext2),t), ext ->
      let ty = get_type env s2 ext2 in
      if ty.toptions land Settings.tyopt_CHOOSABLE == 0 then
	input_error ("Cannot choose randomly a bitstring from " ^ ty.tname ^ " with uniform distribution") ext2;
      let (env',b) = add_in_env env s1 ext1 ty cur_array in
      let t' = check_term cur_array env' t in
      { t_desc = ResE(b, t');
	t_type = t'.t_type;
	t_occ = new_occ();
	t_loc = ext; 
	t_facts = None }
  | PFindE(l0,t3,opt), ext ->
      List.iter (fun (s,ext_s) ->
	if s <> "unique" then
	  Parsing_helper.input_error "The only option allowed for find is unique (and it is ignored)" ext_s
	) opt;
      let rec add env = function
	  [] -> (env,[])
	| ((s1,ext1),(s2,ext2))::bl ->
	    let p = get_param env s2 ext2 in
	    let (env',b) = add_in_env env s1 ext1 (type_for_param p) cur_array in
	    let (env'',bl') = add env' bl in
	    (env'',b::bl')
      in
      let t3' = check_term cur_array env t3 in
      let l0' = List.map (fun (bl,def_list,t1,t2) ->
	let (env', bl') = add env bl in
	let t1' = check_term cur_array env' t1 in
	check_no_new t1;
	let t2' = check_term cur_array env' t2 in
	check_type (snd t1) t1' Settings.t_bool;
	if (t2'.t_type != t3'.t_type)  && (t2'.t_type != Settings.t_any) && (t3'.t_type != Settings.t_any) then
	  Parsing_helper.input_error "All branches of a if or find should return the same type" ext;
	let def_list' = List.map (check_br cur_array env') def_list in
	(bl', def_list', t1', t2')) l0 
      in
      { t_desc = FindE(l0', t3', Nothing); t_type = t3'.t_type; t_occ = new_occ(); t_loc = ext; t_facts = None }
  | PEventE(s,ext2), ext ->
      let t = 
      begin
      try 
	match StringMap.find s env with
	  EEvent(f) ->
	    check_type_list ext2 [] [] (List.tl (fst f.f_type));
	    let idx = Terms.build_term_type Settings.t_bitstring (FunApp(Settings.get_tuple_fun [], [])) in
	    { t_desc = FunApp(f, [idx]); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| _ -> input_error (s ^ " should be an event") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
      in
      { t_desc = EventE(t); t_type = Settings.t_any; t_occ = new_occ(); t_loc = ext; t_facts = None }
  | PEqual(t1,t2), ext ->
      let t1' = check_term cur_array env t1 in
      let t2' = check_term cur_array env t2 in
      if t1'.t_type != t2'.t_type then
	Parsing_helper.input_error "= expects expressions of the same type" ext;
      Terms.make_equal_ext ext t1' t2'
  | PDiff(t1,t2), ext ->
      let t1' = check_term cur_array env t1 in
      let t2' = check_term cur_array env t2 in
      if t1'.t_type != t2'.t_type then
	Parsing_helper.input_error "<> expects expressions of the same type" ext;
      Terms.make_diff_ext ext t1' t2'
  | PAnd(t1,t2), ext ->
      let t1' = check_term cur_array env t1 in
      let t2' = check_term cur_array env t2 in
      check_type (snd t1) t1' Settings.t_bool;
      check_type (snd t2) t2' Settings.t_bool;
      Terms.make_and_ext ext t1' t2'
  | POr(t1,t2), ext ->
      let t1' = check_term cur_array env t1 in
      let t2' = check_term cur_array env t2 in
      check_type (snd t1) t1' Settings.t_bool;
      check_type (snd t2) t2' Settings.t_bool;
      Terms.make_or_ext ext t1' t2'
  | PInjEvent _,ext -> 
      Parsing_helper.input_error "inj: allowed only in queries" ext

and check_br cur_array env ((s,ext), tl) =
  List.iter check_no_iffindletnewevent tl;
  let tl' = List.map (check_term cur_array env) tl in
  begin
    try
      match Hashtbl.find binder_env s with
	Uniq b -> 
	  let tl'' = check_array_type_list ext tl tl' cur_array b.args_at_creation in
	  (b,tl'')
      | Ambiguous | UniqNoType | FindCond ->
	  input_error (s ^ " is referenced in an array reference and is either\ndefined without type, defined several times, defined in a condition of find, or defined in find in an equivalence") ext
    with Not_found ->
      input_error (s ^ " not defined") ext
  end

(* Check pattern *)

and check_pattern cur_array env tyoptres = function
    PPatVar ((s1,ext1), tyopt), _ ->
      begin
	match tyopt, tyoptres with
	  None, None ->
	    input_error "type needed for this variable" ext1
	| None, Some ty -> 
	    let (env',b) = add_in_env env s1 ext1 ty cur_array in
	    (env', PatVar b)
	| Some (s2, ext2), None -> 
	    let ty' = get_type env s2 ext2 in
	    begin
	      match ty'.tcat with
		Interv _ -> input_error "Cannot input a term of interval type" ext2
	        (* This condition simplifies greatly the theory:
	           otherwise, one needs to compute which channels the adversary
	           knows... *)
	      |	_ -> ()
	    end;
	    let (env',b) = add_in_env env s1 ext1 ty' cur_array in
	    (env', PatVar b)	    
	| Some (s2,ext2), Some ty ->
	    let ty' = get_type env s2 ext2 in
	    if ty != ty' then
	      input_error ("Pattern is declared of type " ^ ty'.tname ^ " and should be of type " ^ ty.tname) ext2;
	    let (env',b) = add_in_env env s1 ext1 ty' cur_array in
	    (env', PatVar b)
      end
  | PPatTuple l, ext ->
      begin
	match tyoptres with
	  None -> ()
	| Some ty ->
	    if ty != Settings.t_bitstring then
	      input_error ("A tuple pattern has type bitstring but is here used with type " ^ ty.tname) ext
      end;
      let tl = List.map (fun _ -> None) l in
      let (env', l') = check_pattern_list cur_array env tl l in
      let tl' = List.map get_type_for_pattern l' in
      (env', PatTuple(Settings.get_tuple_fun tl', l'))
  | PPatFunApp((s,ext),l), ext2 -> 
      begin
      try 
	match StringMap.find s env with
	  EFunc(f) ->
	    if (f.f_options land Settings.fopt_COMPOS) == 0 then
	      input_error "Only [compos] functions are allowed in patterns" ext;
	    begin
	      match tyoptres with
		None -> ()
	      |	Some ty ->
		  if ty != snd f.f_type then
		    input_error ("Pattern returns type " ^ (snd f.f_type).tname ^ " and should be of type " ^ ty.tname) ext2
	    end;
	    if List.length (fst f.f_type) != List.length l then
	      input_error ("Function " ^ f.f_name ^ " expects " ^ 
			   (string_of_int (List.length (fst f.f_type))) ^ 
			   " arguments but is here applied to " ^  
			   (string_of_int (List.length l)) ^ "arguments") ext;
	    let (env', l') = check_pattern_list cur_array env (List.map (fun t -> Some t) (fst f.f_type)) l in
	    (env', PatTuple(f, l'))
	| _ -> input_error (s ^ " should be a function") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PPatEqual t, ext ->
      let t' = check_term cur_array env t in
      begin
	match tyoptres with
	  None -> ()
	| Some ty ->
	    if (t'.t_type != ty)  && (t'.t_type != Settings.t_any) && (ty != Settings.t_any) then
	      input_error ("Pattern has type " ^ (t'.t_type).tname ^ " and should be of type " ^ ty.tname) ext
      end;
      (env, PatEqual t')

and check_pattern_list cur_array env lty l = 
  match lty, l with
    [], [] -> (env,[])
  | (ty::lty),(a::l) ->
      let env', l' = check_pattern_list cur_array env lty l in
      let env'', a' = check_pattern cur_array env' ty a in
      (env'', a'::l')
  | _ -> Parsing_helper.internal_error "Lists have different length in check_pattern_list"

(* Check channels *)

let channel_env = (Hashtbl.create 7: (string, channel) Hashtbl.t)

let check_channel_id (s,ext) =
  try
    Hashtbl.find channel_env s 
  with Not_found -> 
    let c = { cname = s } in
    Hashtbl.add channel_env s c;
    c

let check_process_channel cur_array env c = 
  if (!Settings.front_end) == Settings.Channels then
    match c with
      PIdent (s, ext), ext2 ->
	begin
	  try 
	    match StringMap.find s env with
	      EChannel(b) -> (b,cur_array)
	    | _ -> input_error (s ^ " should be a channel") ext
	  with Not_found -> 
	    input_error (s ^ " not defined") ext
	end
    | PArray((s, ext), tl), ext2 ->
	let tl' = List.map (check_term cur_array env) tl in
	begin
	  try 
	    match StringMap.find s env with
	      EChannel(b) -> (b,tl')
	    | _ -> input_error (s ^ " should be a channel") ext
	  with Not_found -> 
	    input_error (s ^ " not defined") ext
	end
    | _, ext -> 
	input_error "A channel should be an identifier or an array access" ext
  else
    match c with
      PIdent id, ext2 -> (check_channel_id id, cur_array)
    | _, ext -> 
	internal_error "An oracle name should be an identifier" 

(* Check statement *)

let add_in_env_nobe env s ext t =
    let b = Terms.create_binder s 0 t [] in
    (StringMap.add s (EVar b) env, b)

let rec check_binder_list env = function
    [] -> (env,[])
  | ((s1,ext1),(s2,ext2))::l ->
      let t = get_type env s2 ext2 in
      let (env',b) = add_in_env_nobe env s1 ext1 t in
      let (env'',l') = check_binder_list env' l in
      (env'', b::l')


let rec check_term_nobe env = function
    PIdent (s, ext), ext2 ->
      begin
      try 
	match StringMap.find s env with
	  EVar(b) -> { t_desc = Var(b,b.args_at_creation); t_type = b.btype; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| EFunc(f) -> 
	    if fst (f.f_type) = [] then
	      { t_desc = FunApp(f, []); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	    else
	      input_error (s ^ " has no arguments but expects some") ext
	| _ -> input_error (s ^ " should be a variable or a function") ext
      with Not_found -> input_error (s ^ " not defined") ext
      end
  | PFunApp((s,ext), tl),ext2 ->
      let tl' = List.map (check_term_nobe env) tl in
      begin
      try 
	match StringMap.find s env with
	  EFunc(f) ->
	    check_type_list ext2 tl tl' (fst f.f_type);
	    { t_desc = FunApp(f, tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| _ -> input_error (s ^ " should be a function") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PTuple(tl), ext2 ->
      let tl' = List.map (check_term_nobe env) tl in
      let f = Settings.get_tuple_fun (List.map (fun t -> t.t_type) tl') in
      check_type_list ext2 tl tl' (fst f.f_type);
      { t_desc = FunApp(f, tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
  | PEqual(t1,t2), ext ->
      let t1' = check_term_nobe env t1 in
      let t2' = check_term_nobe env t2 in
      if (t1'.t_type != t2'.t_type) && (t1'.t_type != Settings.t_any) && (t2'.t_type != Settings.t_any) then
	Parsing_helper.input_error "= expects expressions of the same type" ext;
      Terms.make_equal_ext ext t1' t2'
  | PDiff(t1,t2), ext ->
      let t1' = check_term_nobe env t1 in
      let t2' = check_term_nobe env t2 in
      if (t1'.t_type != t2'.t_type) && (t1'.t_type != Settings.t_any) && (t2'.t_type != Settings.t_any) then
	Parsing_helper.input_error "<> expects expressions of the same type" ext;
      Terms.make_diff_ext ext t1' t2'
  | PAnd(t1,t2), ext ->
      let t1' = check_term_nobe env t1 in
      let t2' = check_term_nobe env t2 in
      check_type (snd t1) t1' Settings.t_bool;
      check_type (snd t2) t2' Settings.t_bool;
      Terms.make_and_ext ext t1' t2'
  | POr(t1,t2), ext ->
      let t1' = check_term_nobe env t1 in
      let t2' = check_term_nobe env t2 in
      check_type (snd t1) t1' Settings.t_bool;
      check_type (snd t2) t2' Settings.t_bool;
      Terms.make_or_ext ext t1' t2'
  | (PArray _ | PTestE _ | PFindE _ | PLetE _ | PResE _ | PEventE _), ext ->
      input_error "If, find, let, new, event, and array references forbidden in forall statements" ext
  | PInjEvent _,ext -> 
      Parsing_helper.input_error "inj: allowed only in queries" ext

let check_statement env (l,t) =
  let (env',l') = check_binder_list env l in
  let t' = check_term_nobe env' t in
  begin
    match t'.t_desc with
      FunApp(f, [t1;t2]) when f.f_cat == Equal ->
	if not (List.for_all (fun b -> Terms.refers_to b t1) l') then
	  input_error "In equality statements, all bound variables should occur in the left-hand side" (snd t)
    | _ -> ()
  end;
  check_type (snd t) t' Settings.t_bool;
  statements := (l',t') :: (!statements)

(* Check equivalence statements *)

let rec check_term_proba env = function
    PIdent (s, ext), ext2 ->
      begin
      try 
	match StringMap.find s env with
	  EVar(b) -> { t_desc = Var(b,b.args_at_creation); t_type = b.btype; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| EFunc(f) -> 
	    if fst (f.f_type) = [] then
	      { t_desc = FunApp(f, []); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	    else
	      input_error (s ^ " has no arguments but expects some") ext
	| _ -> input_error (s ^ " should be a variable or a function") ext
      with Not_found -> try
	match Hashtbl.find binder_env s with
	  Uniq b -> 
	    let tl'' = check_array_type_list ext2 [] [] b.args_at_creation b.args_at_creation in 
	    { t_desc = Var(b,tl''); t_type = b.btype; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| Ambiguous | UniqNoType | FindCond ->
	    input_error (s ^ " is referenced outside its scope and is either\ndefined without type, defined several times, defined in a condition of find, or defined in find in an equivalence") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PFunApp((s,ext), tl),ext2 ->
      let tl' = List.map (check_term_proba env) tl in
      begin
      try 
	match StringMap.find s env with
	  EFunc(f) ->
	    check_type_list ext2 tl tl' (fst f.f_type);
	    { t_desc = FunApp(f, tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
	| _ -> input_error (s ^ " should be a function") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PTuple(tl), ext2 ->
      let tl' = List.map (check_term_proba env) tl in
      let f = Settings.get_tuple_fun (List.map (fun t -> t.t_type) tl') in
      check_type_list ext2 tl tl' (fst f.f_type);
      { t_desc = FunApp(f, tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }
  | (PArray _ | PTestE _ | PLetE _ | PResE _ | PFindE _ | PEventE _), ext ->
      Parsing_helper.input_error "Array accesses/if/let/find/new/event not allowed in terms in probability formulas" ext
  | PEqual(t1,t2), ext ->
      let t1' = check_term_proba env t1 in
      let t2' = check_term_proba env t2 in
      if (t1'.t_type != t2'.t_type) && (t1'.t_type != Settings.t_any) && (t2'.t_type != Settings.t_any) then
	Parsing_helper.input_error "= expects expressions of the same type" ext;
      Terms.make_equal_ext ext t1' t2'
  | PDiff(t1,t2), ext ->
      let t1' = check_term_proba env t1 in
      let t2' = check_term_proba env t2 in
      if (t1'.t_type != t2'.t_type) && (t1'.t_type != Settings.t_any) && (t2'.t_type != Settings.t_any) then
	Parsing_helper.input_error "<> expects expressions of the same type" ext;
      Terms.make_diff_ext ext t1' t2'
  | PAnd(t1,t2), ext ->
      let t1' = check_term_proba env t1 in
      let t2' = check_term_proba env t2 in
      check_type (snd t1) t1' Settings.t_bool;
      check_type (snd t2) t2' Settings.t_bool;
      Terms.make_and_ext ext t1' t2'
  | POr(t1,t2), ext ->
      let t1' = check_term_proba env t1 in
      let t2' = check_term_proba env t2 in
      check_type (snd t1) t1' Settings.t_bool;
      check_type (snd t2) t2' Settings.t_bool;
      Terms.make_or_ext ext t1' t2'
  | PInjEvent _,ext -> 
      Parsing_helper.input_error "inj: allowed only in queries" ext


(* TO DO we should output an error message when a term in a probability
  formula depends on variables occurring in several different expressions
  of the left-hand side of the equivalence. (In such a case, no expression
  can instantiate all variables, so it will always have result 0, which
  is not the desired behaviour!) *)
      
(* returns the checked formula and its dimension as a power of probability
   and a power of time *)
let get_compatible ext d1 d2 =
  match (d1,d2) with
    None, _ -> d2
  | _, None -> d1
  | Some(dp1,dt1,dl1),Some(dp2,dt2,dl2) -> 
      if (dp1 != dp2) || (dt1 != dt2) || (dl1 != dl2) then
	input_error "values of incompatible dimensions" ext
      else
	d1

let compose_dim f d1 d2 =
  match (d1,d2) with
    None, _ -> None
  | _, None -> None
  | Some(dp1,dt1,dl1),Some(dp2,dt2,dl2) -> 
      Some (f dp1 dp2, f dt1 dt2, f dl1 dl2)

let rec check_types ext pl0 pl tl = 
  match (pl0, pl, tl) with
    [],[],[] -> []
  | _::pl0', (TypeMaxlength(ty'))::pl', ty::tl' when ty.toptions land Settings.tyopt_BOUNDED != 0 && ty == ty' -> 
      (* print_string ("Type max length " ^ ty.tname ^ "\n"); *)
      check_types ext pl0' pl' tl'
  | _, _, ty::tl' when ty.toptions land Settings.tyopt_BOUNDED != 0 -> 
      (* print_string ("Bounded type " ^ ty.tname ^ "\n"); *)
      check_types ext pl0 pl tl'
  | (_, ext)::pl0', pt::pl', ty::tl' ->
      let rec check_pt ty = function
	  Maxlength(_,t) ->
	    if t.t_type != ty then
	      input_error ("In a probability formula, time/length should be of form time/length(f, p1, ..., pn)\n" ^
			   "where p1...pn are probabilities pi ::= maxlength(ti) | length(fi, ...) | max(pi,pi)\n" ^
			   "for terms ti or result of fi of types the non-bounded arguments of f.\n" ^ 
			   "Type " ^ ty.tname ^ " expected, got " ^ t.t_type.tname ^ ".") ext
	| TypeMaxlength(t) ->
	    input_error ("In a probability formula, time/length should be of form time/length(f, p1, ..., pn)\n" ^
			 "where p1...pn are probabilities pi ::= maxlength(ti) | length(fi, ...) | max(pi,pi)\n" ^
			 "for terms ti or result of fi of types the non-bounded arguments of f.\n" ^ 
			 "Unbounded type " ^ ty.tname ^ " expected, got bounded type " ^ t.tname ^ ".") ext
	| Max(l) ->
	    List.iter (check_pt ty) l
	| Length(f,l) ->
	    if snd f.f_type != ty then
	      input_error ("In a probability formula, time/length should be of form time/length(f, p1, ..., pn)\n" ^
			   "where p1...pn are probabilities pi ::= maxlength(ti) | length(fi, ...) | max(pi,pi)\n" ^
			   "for terms ti or result of fi of types the non-bounded arguments of f.\n" ^ 
			   "Type " ^ ty.tname ^ " expected, got " ^ (snd f.f_type).tname ^ ".") ext
	    
	| _ ->
	    input_error ("In a probability formula, time/length should be of form time/length(f, p1, ..., pn)\n" ^
			 "where p1...pn are probabilities pi ::= maxlength(ti) | length(fi, ...) | max(pi,pi)\n" ^
			 "for terms ti or result of fi of types the non-bounded arguments of f.\n" ^ 
			 "maxlength or max expected.") ext
      in
      check_pt ty pt;
      pt :: (check_types ext pl0' pl' tl')
  | _ -> 
      input_error ("In a probability formula, time/length should be of form time/length(f, p1, ..., pn)\n" ^
		   "where p1...pn are probabilities pi ::= maxlength(ti) | length(fi, ...) | max(pi,pi)\n" ^
		   "for terms ti or result of fi of types the non-bounded arguments of f.\n" ^ 
		   "Unexpected number of arguments.") ext


let dummy_game = { proc = Terms.nil_proc; game_number = -1 }

let rec check_probability_formula seen_ch seen_repl env = function
    PPIdent(s,ext), ext2 ->
      begin
	try 
	  match StringMap.find s env with
	    EParam p -> 
	      if not (List.exists (fun b -> p == Terms.param_from_type b) (!seen_repl)) then
		input_error ("The parameter " ^s^ " should occur in each member of the equivalence") ext;
	      Count p, Some(0, 0, 0)
	  | EProba p -> Proba(p,[]), Some(1, 0, 0)
	  | _ -> input_error (s ^ " should be a probability or a parameter") ext
	with Not_found ->
	  input_error (s ^ " is not defined") ext
      end
  | PCount(s,ext), ext2 ->
      begin
	try
	  OCount(List.find (fun ch -> ch.cname = s) seen_ch), Some(0, 0, 0)
	with Not_found -> 
	  input_error ("The oracle name " ^ s ^ " is not defined") ext
      end
  | PPFun((s,ext), l), ext2 ->
      let l' = List.map (fun p -> fst (check_probability_formula seen_ch seen_repl env p )) l in
      (* Remove "TypeMaxlength" arguments for simplicity; they are constants.
	 TO DO This removing is perhaps questionable *)
      let l' = List.filter (function 
	  TypeMaxlength _ -> false
	| _ -> true) l' in
      begin
	try 
	  match StringMap.find s env with
	  | EProba p -> Proba(p,l'), Some(1, 0, 0)
	  | _ -> input_error (s ^ " should be a probability") ext
	with Not_found ->
	  input_error (s ^ " is not defined") ext
      end
  | PAdd(p1,p2), ext ->
      let (p1', d1) = check_probability_formula seen_ch seen_repl env p1 in
      let (p2', d2) = check_probability_formula seen_ch seen_repl env p2 in
      (Add(p1',p2'), get_compatible ext d1 d2)
  | PSub(p1,p2), ext ->
      let (p1', d1) = check_probability_formula seen_ch seen_repl env p1 in
      let (p2', d2) = check_probability_formula seen_ch seen_repl env p2 in
      (Sub(p1',p2'), get_compatible ext d1 d2)
  | PMax(pl), ext ->
      let rec check_comp = function
	  [] -> ([], None)
	| (p::l) -> 
	    let (p', d) = check_probability_formula seen_ch seen_repl env p in
	    let (l', dl) = check_comp l in
	    if List.exists (Terms.equal_probaf p') l' then
	      (* remove duplicate elements for simplifying *)
	      (l',dl)
	    else
	      (p'::l', get_compatible ext d dl)
      in
      let (pl', d) = check_comp pl in
      begin
	(* The "max" is removed when the list contains a single element *)
	match pl' with
	  [p] -> (p, d)
	| _ -> (Max(pl'), d)
      end
  | PTime, ext ->
      (AttTime, Some(0, 1, 0))
  | PActTime(action, pl), ext ->
      begin
	let pl' = List.map (fun p -> fst (check_probability_formula seen_ch seen_repl env p)) pl in
	match action with
	  PAFunApp(s,ext') ->
	    begin
	    try 
	      match StringMap.find s env with
	      | EFunc f -> 
		  let pl' = check_types ext pl pl' (fst f.f_type) in
		  (ActTime(AFunApp f, pl'), Some(0, 1, 0))
	      | _ -> input_error (s ^ " should be a function symbol") ext'
	    with Not_found ->
	      input_error (s ^ " is not defined") ext'
	    end
	| PAPatFunApp(s,ext') ->
	    begin
	    try 
	      match StringMap.find s env with
	      | EFunc f -> 
		  let pl' = check_types ext pl pl' (fst f.f_type) in
		  (ActTime(APatFunApp f, pl'), Some(0, 1, 0))
	      | _ -> input_error (s ^ " should be a function symbol") ext'
	    with Not_found ->
	      input_error (s ^ " is not defined") ext'
	    end
	| PACompare(s,ext') ->
	    let t = get_type_or_param env s ext' in
	    let pl' = check_types ext pl pl' [t] in
	    (ActTime(AFunApp(Settings.f_comp Equal t t), pl'), Some(0, 1, 0))
	| PANew(s,ext') ->
	    let t = get_type env s ext' in
	    if pl != [] then 
	      internal_error "No length arguments for time(new)";
	    (ActTime(ANew t, pl'), Some(0, 1, 0))
	| PAAppTuple(tl) ->
	    let tl' = List.map (fun (s,ext') -> get_type env s ext') tl in
	    let f = Settings.get_tuple_fun tl' in
	    let pl' = check_types ext pl pl' (fst f.f_type) in
	    (ActTime(AFunApp f, pl'), Some(0, 1, 0))
	| PAPatTuple(tl) ->
	    let tl' = List.map (fun (s,ext') -> get_type env s ext') tl in
	    let f = Settings.get_tuple_fun tl' in
	    let pl' = check_types ext pl pl' (fst f.f_type) in
	    (ActTime(APatFunApp f, pl'), Some(0, 1, 0))
	| PAOut(l1,(s,ext')) ->
	    if (!Settings.front_end) == Settings.Channels then
	      begin
		let l1' = List.map (fun (s,ext') -> get_type_or_param env s ext') l1 in
		let t = get_type env s ext' in
		let pl' = check_types ext pl pl' (l1' @ [t]) in
		(ActTime(AOut(l1',t), pl'), Some(0, 1, 0))
	      end
	    else
	      internal_error "out action not allowed in oracles front-end"
	| _ ->
	    begin
	      if pl != [] then 
		internal_error "No length arguments for this action";
	      let action' = match action with
		PAReplIndex -> AReplIndex
	      |	PAArrayAccess n -> AArrayAccess n
	      |	PAAnd -> AFunApp(Settings.f_and)
	      |	PAOr -> AFunApp(Settings.f_or)
	      |	PAIf -> AIf
	      |	PANewChannel -> ANewChannel
	      |	PAFind n -> AFind n
	      |	PAIn n -> 
		  if (!Settings.front_end) == Settings.Channels then
		    AIn n
		  else
		    internal_error "in action not allowed in oracles front-end"
	      |	_ -> internal_error "Unexpected action (syntax.ml)"
	      in
	      (ActTime(action', pl'), Some(0, 1, 0))
	    end
      end
  | PMaxlength(t), ext ->
      let t' = check_term_proba env t in
      if t'.t_type.toptions land Settings.tyopt_BOUNDED != 0 then
	(TypeMaxlength(t'.t_type), Some (0,0,1))
      else
	(Maxlength(dummy_game, t'), Some (0,0,1))
  | PLength((s,ext'), pl), ext ->
      begin
	let pl' = List.map (fun p -> fst (check_probability_formula seen_ch seen_repl env p)) pl in
	try 
	  match StringMap.find s env with
	  | EFunc f -> 
	      let pl' = check_types ext pl pl' (fst f.f_type) in
	      if (snd f.f_type).toptions land Settings.tyopt_BOUNDED != 0 then
		(TypeMaxlength (snd f.f_type), Some(0,0,1))
	      else
		(Length(f, pl'), Some(0,0,1))
	  | _ -> input_error (s ^ " should be a function symbol") ext'
	with Not_found ->
	  input_error (s ^ " is not defined") ext'
      end
  | PLengthTuple(tl,pl), ext ->
      let pl' = List.map (fun p -> fst (check_probability_formula seen_ch seen_repl env p)) pl in
      let tl' = List.map (fun (s,ext') -> get_type env s ext') tl in
      let f = Settings.get_tuple_fun tl' in
      let pl' = check_types ext pl pl' (fst f.f_type) in
      (Length(f, pl'), Some(0,0,1))
  | PProd(p1,p2), ext ->
      let (p1', d1) = check_probability_formula seen_ch seen_repl env p1 in
      let (p2', d2) = check_probability_formula seen_ch seen_repl env p2 in
      (Mul(p1',p2'), compose_dim (+) d1 d2)
  | PDiv(p1,p2), ext ->
      let (p1', d1) = check_probability_formula seen_ch seen_repl env p1 in
      let (p2', d2) = check_probability_formula seen_ch seen_repl env p2 in
      (Div(p1',p2'), compose_dim (-) d1 d2)
  | PPZero, ext -> Zero, None
  | PCard (s,ext'), ext -> 
      begin
	try 
	  match StringMap.find s env with
	  | EType t -> Card t, Some(-1, 0, 0)
	  | _ -> input_error (s ^ " should be a type") ext'
	with Not_found ->
	  input_error (s ^ " is not defined") ext'
      end
  | PCst i, ext ->
      Cst (float_of_int i), Some(0, 0, 0)
  | PFloatCst f, ext ->
      Cst f, Some(0, 0, 0)

let check_probability_formula2 seen_ch seen_repl env p =
  let (p', d) = check_probability_formula seen_ch seen_repl env p in
  begin
    match d with
      None -> ()
    | Some(dp,dt,dl) ->
	if (dp != 1) || (dt != 0) || (dl != 0) then 
	  input_error "The result of this formula is not a probability" (snd p)
  end;
  p'

let rec check_binder_list2 cur_array env = function
    [] -> (env,[])
  | ((s1,ext1),ty)::l ->
      let t = 
	match ty with
	  Tid (s2,ext2) -> get_type env s2 ext2 
	| TBound (s2,ext2) -> 
	    let p = get_param env s2 ext2 in
	    type_for_param p
      in
      (* Interval types now allowed in arguments of oracles
	 check_bit_string_type ext2 t; *)
      let (env',b) = add_in_env env s1 ext1 t cur_array in
      let (env'',l') = check_binder_list2 cur_array env' l in
      (env'', b::l')

let rec check_lm_restrlist cur_array env = function
    [] -> (env, [])
  | ((s1,ext1),(s2,ext2),opt)::l ->
      let t = get_type env s2 ext2 in
      if t.toptions land Settings.tyopt_CHOOSABLE == 0 then
	input_error ("Cannot choose randomly a bitstring from " ^ t.tname ^ " with uniform distribution") ext2;
      begin
	match opt with
	  [] -> ()
	| (_,ext3)::_ ->
	    input_error ("Restrictions should have no options in the left-hand side of an equivalence") ext3
      end;
      let (env',b) = add_in_env env s1 ext1 t cur_array in
      let (env'',bl) = check_lm_restrlist cur_array env' l in
      (env'', (b, NoOpt)::bl)

let rec check_lm_fungroup2 cur_array cur_restr env seen_ch seen_repl = function
    PReplRestr((occ, _, (rep,ext)), restrlist, funlist) ->
      let cur_array1 = Hashtbl.find repl_binders occ in
      let repl_count' = binder_from_term cur_array1 in
      let cur_array' = cur_array1 :: cur_array in
      let (env',restrlist') = check_lm_restrlist cur_array' env restrlist in
      if List.memq repl_count'.btype (!seen_repl) then
	Parsing_helper.input_error "In an equivalence, different functions must have a different number of repetitions" ext;
      seen_repl := repl_count'.btype :: (!seen_repl);
      let funlist' = List.map (check_lm_fungroup2 cur_array' (restrlist'::cur_restr) env' seen_ch seen_repl) funlist in
      (* Remove useless new *)
      let restrlist'' = List.filter (fun (b,_) -> List.exists (Terms.refers_to_fungroup b) funlist') restrlist' in
      if restrlist'' == [] then
	begin
	  match funlist' with
	    [Fun _] -> ()
	  | _ -> Parsing_helper.input_error "In equivalences, under a replication without new, there should be a single function" ext
	end;
      ReplRestr(repl_count', restrlist'', funlist')
  | PFun(((s, ext) as ch), arglist, tres, (priority, options)) ->
      let ch' = check_channel_id ch in
      if (s <> "@dummy_channel") && (List.memq ch' (!seen_ch)) then
	input_error ("Oracle name " ^ s ^ " already used in this equivalence") ext;
      seen_ch := ch' :: (!seen_ch);
      let (env', arglist') = check_binder_list2 cur_array env arglist in
      let tres' = check_term cur_array env' tres in
      (* Note: restriction. Could be lifted, but simplifies cryptotransf.ml greatly 
	 Restriction partly lifted, by completing sequences of names with names already in the map.
      if not (List.for_all (List.for_all (fun b -> Terms.refers_to b tres')) cur_restr) then
	Parsing_helper.input_error ("In equivalences, each expression should use all names defined by\n" ^
				    "restrictions above it. This is a simplifying restriction.") (snd tres);
      *)
      check_bit_string_type (snd tres) tres'.t_type;
      List.iter2 (fun ((argname,ext),_) arg' ->
	if not (Terms.refers_to arg' tres') then
	  if (!Settings.front_end) == Settings.Channels then
            Parsing_helper.input_error ("Variable " ^ argname ^ " is not used in the result of the function") ext
	  else
	    Parsing_helper.input_error ("Variable " ^ argname ^ " is not used in the result of the oracle") ext
	      ) arglist arglist';
      let options' = ref StdOpt in
      List.iter (fun (s,ext) ->
	if s = "required" then options' := RequiredOpt else
	Parsing_helper.input_error ("Unrecognized option " ^ s ^ ". Only \"required\" is allowed.") ext) options;
      Fun(ch', arglist', tres', (priority, !options'))


let rec check_rm_restrlist options2 cur_array env restrlist0 = function
    [] -> (env, [])
  | ((s1,ext1),(s2,ext2),opt)::l ->
      let t = get_type env s2 ext2 in
      if t.toptions land Settings.tyopt_CHOOSABLE == 0 then
	input_error ("Cannot choose randomly a bitstring from " ^ t.tname ^ " with uniform distribution") ext2;
      let (env',b) = add_in_env env s1 ext1 t cur_array in
      let opt' = ref NoOpt in
      List.iter (fun (s,ext) ->
	if s = "unchanged" then 
	  if options2 = Computational then
	    if List.exists (fun (b',_) -> 
	      (b.sname = b'.sname) &&
	      (b.vname == b'.vname) &&
	      (b.btype == b'.btype)
	      ) restrlist0 then
	      opt' := Unchanged 
	    else
	      input_error "When a restriction is marked [unchanged] in the right-hand side,\nthere should exist a corresponding restriction of the same name in the\nleft-hand side" ext
	  else
	    input_error "The option [unchanged] is allowed only for computational equivalences" ext
	else
	  input_error "The only allowed option for restrictions is [unchanged]" ext
	  ) opt;
      let (env'',bl) = check_rm_restrlist options2 cur_array env' restrlist0 l in
      (env'', (b, !opt')::bl)

let rec check_rm_fungroup2 options2 cur_array env fg0 fg = 
  match (fg0, fg) with
    ReplRestr(repl_count0, restrlist0, funlist0),
    PReplRestr((occ, _, (rep,ext)), restrlist, funlist) ->
      let cur_array1 = Hashtbl.find repl_binders occ in
      let repl_count' = binder_from_term cur_array1 in
      let cur_array' = cur_array1 :: cur_array in
      let (env',restrlist') = check_rm_restrlist options2 cur_array' env restrlist0 restrlist in
      if List.length funlist != List.length funlist0 then
	input_error "Different number of functions in left and right sides of equivalence" ext;
      if repl_count'.btype != repl_count0.btype then
	input_error "Different number of repetitions in left and right members of equivalence" ext;
      ReplRestr(repl_count', restrlist', List.map2 (check_rm_fungroup2 options2 cur_array' env') funlist0 funlist)
  | Fun(ch0, arglist0, tres0, priority0), PFun((ch, ext), arglist, tres, _) ->
      let (env', arglist') = check_binder_list2 cur_array env arglist in
      if List.length arglist' != List.length arglist0 then
	input_error "Argument lists have different lengths in left and right members of equivalence" (snd tres);
      List.iter2 (fun b b' ->
	if b.btype != b'.btype then
	  input_error "Incompatible types of arguments between left and right members of equivalence" (snd tres)
	    ) arglist' arglist0;
      let tres' = check_term cur_array env' tres in
      (* Check that the type of the right member is the same as
	 the type of the corresponding left member. This is required
	 so that after transformation, the process remains well-typed. *)
      check_type (snd tres) tres' tres0.t_type;
      if ch <> ch0.cname then
	input_error "Oracle names should be the same in the left and right members of the equivalence" ext;
      (* The priority is ignored in the right-hand side; one takes
         the priority of the left-hand side *)
      Fun(ch0, arglist', tres', priority0)
  | _, PReplRestr((_, _, (_,ext)), _,_) ->
      input_error "Left member is a function, right member is a replication" ext
  | _, PFun(ch, arglist, tres, _) ->
      input_error "Left member is a replication, right member is a function" (snd tres)

let check_mode right = function
    Some (modes, ext) -> 
      if right then
	Parsing_helper.input_error "Modes can be specified only in the left-hand side of an equivalence" ext;
      if modes = "all" then AllEquiv else 
      if modes = "exist" then ExistEquiv else
      Parsing_helper.input_error "Only modes all and exist can be specified" ext
  | None -> ExistEquiv

let check_eqstatement ((mem1, ext1), (mem2, ext2), proba, (priority, options)) =
  let options' = ref StdEqopt in
  let options2' = ref Decisional in
  if priority != 0 then options' := PrioEqopt priority;
  List.iter (fun (s,ext) ->
    if s = "manual" then
      if !options' == StdEqopt then 
	options' := ManualEqopt 
      else
	Parsing_helper.input_error ("Conflicting options : you cannot specify both a priority and \"manual\"") ext 
    else if s = "computational" then 
      options2' := Computational 
    else
      Parsing_helper.input_error ("Unrecognized option " ^ s ^ ". Only \"manual\" is allowed.") ext
      ) options;
  let seen_repl = ref [] in
  let seen_ch = ref [] in
  Hashtbl.clear binder_env;
  List.iter (fun (fg, _, _) -> check_fungroup1 [] fg) mem1; (* Builds binder_env *)
  let count_exist = ref 0 in
  let mem1' = List.map (fun (fg, mode, ext) ->
    let res = (check_lm_fungroup2 [] [] (!env) seen_ch seen_repl fg,
	       check_mode false mode)
    in
    match res with
      (ReplRestr(_,[],_), ExistEquiv) ->
	input_error "In equivalences, a function without any name should always be in mode [all]" ext
    | (_,ExistEquiv) -> incr count_exist; res
    | _ -> res
    ) mem1
  in
  (* The probability formula must be checked in the binder_env for the
     left-hand side of the equivalence. Arguments of Maxlength may use
     variables of the left-hand side of the equivalence. *)
  let proba' = check_probability_formula2 (!seen_ch) seen_repl (!env) proba in
  (*if !count_exist > 1 then
    input_error "In equivalences, there should be at most one function group without mode [all]" ext1;*)
  Hashtbl.clear binder_env;
  List.iter (fun (fg, _, _) -> check_fungroup1 [] fg) mem2; (* Builds binder_env *)
  let mem2' = List.map2 (fun (fg0, _) (fg, mode, _) -> 
    check_rm_fungroup2 (!options2') [] (!env) fg0 fg, check_mode true mode) mem1' mem2 
  in
  equivalences := (mem1',mem2', (if proba' = Zero then [] else [SetProba { set_name = ""; proba = proba' }]), !options', !options2') :: (!equivalences)

(* Check collision statement *)

let check_collision env (restr, forall, t1, proba, t2) =
  Hashtbl.clear binder_env;
  let (env',restr') = check_binder_list env restr in
  List.iter2 (fun b (_,(_,ext)) ->
    if b.btype.toptions land Settings.tyopt_CHOOSABLE == 0 then
      input_error ("Cannot choose randomly a bitstring from " ^ b.btype.tname ^ " with uniform distribution") ext
      ) restr' restr;
  let (env'',forall') = check_binder_list env' forall in
  let proba' = check_probability_formula2 [] (ref []) env'' proba in
  let t1' = check_term_nobe env'' t1 in
  if not (List.for_all (fun b -> Terms.refers_to b t1') (restr' @ forall')) then
    input_error "In collision statements, all bound variables should occur in the left-hand side" (snd t1);
  let t2' = check_term_nobe env'' t2 in
  check_bit_string_type (snd t1) t1'.t_type;
  if t1'.t_type != t2'.t_type then 
    input_error "Both sides of a collision statement should have the same type" (snd t2);
  collisions := (restr', forall', t1', proba', t2') :: (!collisions)


(* Check process
   check_process returns the process, as well as a list of oracles with their
   types (oracle name, list of index types, list of args types, list of result types)
   check_oprocess returns the process, as well as a list of oracles with their
   types and the list of result types returned by this process
 *)

let eqtypes tl1 tl2 = 
  (List.length tl1 == List.length tl2) &&
  (List.for_all2 (fun t1 t2 -> (t1 == t2) || (t1 != Settings.t_any) || (t2 != Settings.t_any)) tl1 tl2)

exception IncompatibleTypes

let mergetypesopt topt1 topt2 = 
  match topt1,topt2 with
    None,_ -> topt2
  | _,None -> topt1
  | Some tl1,Some tl2 -> 
      if not (eqtypes tl1 tl2) then 
	raise IncompatibleTypes
      else
	topt1

let mergeres ext topt1 topt2 =
  try
    mergetypesopt topt1 topt2
  with IncompatibleTypes ->
    input_error "Several branches of a process have incompatible return types" ext

let rec check_distinct ext l1 = function
    [] -> ()
  | (ch,_,_,_)::l -> 
      if List.exists (fun (ch',_,_,_) -> ch == ch') l1 then
	input_error ("Duplicate definitions of oracle " ^ ch.cname) ext
      else
	check_distinct ext l1 l

let rec check_compatible ext l1 = function
    [] -> l1
  | (ch,tindex,targs,tres)::l ->
      let l1' = check_compatible ext l1 l in
      begin
      try
	let (ch',tindex',targs',tres') = List.find (fun (ch',_,_,_) -> ch == ch') l1 in
	if not (eqtypes tindex tindex') then
	  input_error ("Definitions of oracle " ^ ch.cname ^ " with different replication indexes types") ext;
	if not (eqtypes targs targs') then
	  input_error ("Definitions of oracle " ^ ch.cname ^ " with different argument types") ext;
	try
	  let tres'' = mergetypesopt tres tres' in
	  (ch,tindex,targs,tres'') :: (List.filter (fun (ch',_,_,_) -> ch != ch') l1')
	with IncompatibleTypes ->
	  input_error ("Definitions of oracle " ^ ch.cname ^ " with different result types") ext
      with Not_found -> 
	(ch,tindex,targs,tres)::l1'
      end

let event_type_list = ref []

let dummy_channel = { cname = "dummy_channel" }

let rec check_process cur_array env = function
    PNil, _ -> (iproc_from_desc Nil, [])
  | PPar(p1,p2), ext -> 
      let (p1',oracle1) = check_process cur_array env p1 in
      let (p2',oracle2) = check_process cur_array env p2 in
      check_distinct ext oracle1 oracle2;
      (iproc_from_desc (Par(p1',p2')), oracle1 @ oracle2)
  | PRepl(occ,_,(s2,ext2),p), _ ->
      let cur_array1 = Hashtbl.find repl_binders occ in
      let (p',oracle) = check_process (cur_array1::cur_array) env p in
      (iproc_from_desc (Repl(binder_from_term cur_array1, p')), oracle)
  | PInput(t, pat, p), _ ->
      check_no_iffindletnewevent t;
      let ((c, _) as t') = check_process_channel cur_array env t in
      let (env', pat') = check_pattern cur_array env None pat in
      let (p', tres, oracle) = check_oprocess cur_array env' p in
      if (!Settings.front_end) == Settings.Channels then
	(iproc_from_desc (Input(t', pat', p')), oracle)
      else
	begin
	  match pat' with
	    PatTuple(_,patl) ->
	      (iproc_from_desc (Input(t', pat', p')), 
	       (c, List.map (fun t -> t.t_type) cur_array, 
		List.map get_type_for_pattern patl, tres)::oracle)
	  | _ -> internal_error "One can only have a tuple as argument"
	end
  | PLetDef(s,ext), _ ->
      check_process cur_array env (get_process env s ext)
  | _, ext ->
      input_error "input process expected" ext

and check_oprocess cur_array env = function
    PYield, _ -> (oproc_from_desc Yield, None, [])
  | PRestr((s1,ext1),(s2,ext2),p), _ ->
      let t = get_type env s2 ext2 in
      if t.toptions land Settings.tyopt_CHOOSABLE == 0 then
	input_error ("Cannot choose randomly a bitstring from " ^ t.tname ^ " with uniform distribution") ext2;
      let (env',b) = add_in_env env s1 ext1 t cur_array in
      let (p', tres, oracle) = check_oprocess cur_array env' p in
      (oproc_from_desc (Restr(b, p')), tres, oracle)
  | PLetDef(s,ext), _ ->
      check_oprocess cur_array env (get_process env s ext)
  | PTest(t,p1,p2), ext ->
      let t' = check_term cur_array env t in
      check_type (snd t) t' Settings.t_bool;
      let (p1',tres1,oracle1) = check_oprocess cur_array env p1 in
      let (p2',tres2,oracle2) = check_oprocess cur_array env p2 in
      (oproc_from_desc (Test(t', p1', p2')),
       mergeres ext tres1 tres2, check_compatible ext oracle1 oracle2)
  | PFind(l0,p2,opt), ext ->
      List.iter (fun (s,ext_s) ->
	if s <> "unique" then
	  Parsing_helper.input_error "The only option allowed for find is unique (and it is ignored)" ext_s
	) opt;
      let rec add env = function
	  [] -> (env,[])
	| ((s1,ext1),(s2,ext2))::bl ->
	    let p = get_param env s2 ext2 in
	    let (env',b) = add_in_env env s1 ext1 (type_for_param p) cur_array in
	    let (env'',bl') = add env' bl in
	    (env'',b::bl')
      in
      let (p2', tres2, oracle2) = check_oprocess cur_array env p2 in
      let trescur = ref tres2 in
      let oraclecur = ref oracle2 in
      let l0' = List.map (fun (bl,def_list,t,p1) ->
	let (env', bl') = add env bl in
	let t' = check_term cur_array env' t in
	check_no_new t;
	check_type (snd t) t' Settings.t_bool;
	let def_list' = List.map (check_br cur_array env') def_list in
	let (p1', tres1, oracle1) = check_oprocess cur_array env' p1 in
	trescur := mergeres ext tres1 (!trescur);
	oraclecur := check_compatible ext oracle1 (!oraclecur);
	(bl', def_list', t', p1')) l0
      in
      (oproc_from_desc (Find(l0', p2',Nothing)), (!trescur), (!oraclecur))
  | POutput(t1,t2,p), _ ->
      let t2' = check_term cur_array env t2 in
      begin
      match t2'.t_type.tcat with
	Interv _ -> input_error "Cannot output a term of interval type" (snd t2)
      |	_ -> ()
      end;
      let (p', oracle) = check_process cur_array env p in
      if (!Settings.front_end) == Settings.Channels then
	let t1' = check_process_channel cur_array env t1 in
	(oproc_from_desc (Output(t1', t2', p')), None, oracle)
      else
	begin
	  match t2'.t_desc with
	    FunApp(_,tl) ->
	      (oproc_from_desc (Output((dummy_channel, []), t2', p')), 
	       Some (List.map (fun t -> t.t_type) tl), oracle)
	  | _ -> 
	      internal_error "One can only return a tuple"
	end
  | PLet(pat, t, p1, p2), ext ->
      let t' = check_term cur_array env t in
      let (env', pat') = check_pattern cur_array env (Some t'.t_type) pat in
      let (p1',tres1,oracle1) = check_oprocess cur_array env' p1 in
      let (p2',tres2,oracle2) = check_oprocess cur_array env p2 in
      (oproc_from_desc (Let(pat', t', p1', p2')), 
       mergeres ext tres1 tres2, check_compatible ext oracle1 oracle2)
  | PEvent((PFunApp((s,ext0),tl), ext), p), ext2 ->
      begin
      try 
	match StringMap.find s env with
	  EEvent(f) ->
	    let tl' = List.map (check_term cur_array env) tl in
	    check_type_list ext tl tl' (List.tl (fst f.f_type));
	    let tupf = Settings.get_tuple_fun (List.map (fun t -> t.t_type) cur_array) in
	    event_type_list := (f, tupf) :: (!event_type_list);
	    let tcur_array = { t_desc = FunApp(tupf, cur_array);
			       t_type = Settings.t_bitstring;
			       t_occ = Terms.new_occ();
			       t_loc = ext2; 
			       t_facts = None }
	    in
	    let (p', tres, oracle) = check_oprocess cur_array env p in
	    (oproc_from_desc 
	      (EventP({ t_desc = FunApp(f, tcur_array::tl');
			t_type = Settings.t_bool;
			t_occ = Terms.new_occ();
			t_loc = ext2; 
			t_facts = None }, p')), tres, oracle)
	| _ -> input_error (s ^ " should be an event") ext0
      with Not_found ->
	input_error (s ^ " not defined") ext0
      end
  | _, ext -> 
      input_error "non-input process expected" ext

(* Macro expansion *)

let rename_table = ref StringMap.empty

let expansion_number = ref 0

let rename_ident i = 
  try
    StringMap.find i (!rename_table)
  with Not_found ->
    let r = "@" ^ (string_of_int (!expansion_number)) ^ "_" ^ i in
    rename_table := StringMap.add i r (!rename_table);
    r

let rename_ie (i,ext) = (rename_ident i, ext)

let rename_ie_dummy_channel (i,ext) = 
  if i = "@dummy_channel" then (i,ext) else (rename_ident i, ext)

let rec rename_term (t,ext) = 
  let t' = match t with
    PIdent i -> PIdent (rename_ie i)
  | PArray(i,l) -> PArray(rename_ie i, List.map rename_term l)
  | PFunApp(f,l) -> PFunApp(rename_ie f, List.map rename_term l)
  | PInjEvent(i,l) -> PInjEvent(rename_ie i, List.map rename_term l)
  | PTuple(l) -> PTuple(List.map rename_term l)
  | PTestE(t1,t2,t3) -> PTestE(rename_term t1, rename_term t2, rename_term t3)
  | PFindE(l,t,opt) -> PFindE(List.map (fun (bl, def_list, c,t) ->
      (List.map (fun (x,t) -> (rename_ie x, rename_ie t)) bl,
       List.map rename_br def_list,
       rename_term c,
       rename_term t)) l, rename_term t, opt)
  | PLetE(pat, t1, t2, topt) ->
      PLetE(rename_pat pat, rename_term t1, rename_term t2, match topt with
	None -> None
      |	Some t -> Some (rename_term t))
  | PResE(i,ty,t) -> PResE(rename_ie i, rename_ie ty, rename_term t)
  | PEventE(i) -> PEventE(rename_ie i)
  | PEqual(t1,t2) -> PEqual(rename_term t1, rename_term t2)
  | PDiff(t1,t2) -> PDiff(rename_term t1, rename_term t2)
  | POr(t1,t2) -> POr(rename_term t1, rename_term t2)
  | PAnd(t1,t2) -> PAnd(rename_term t1, rename_term t2)
  in
  (t',ext)

and rename_pat = function
    PPatVar(i,topt), ext -> PPatVar(rename_ie i, match topt with
      None -> None
    | Some t -> Some (rename_ie t)), ext
  | PPatTuple(l), ext -> PPatTuple(List.map rename_pat l), ext
  | PPatFunApp(f,l), ext -> PPatFunApp(rename_ie f, List.map rename_pat l), ext
  | PPatEqual t, ext -> PPatEqual(rename_term t), ext

and rename_br (b, tl) = (rename_ie b, List.map rename_term tl)

let rec rename_proc (p, ext) = 
  let p' = match p with
    PNil -> PNil
  | PYield -> PYield
  | PPar(p1,p2) -> PPar(rename_proc p1, rename_proc p2)
  | PRepl(i, idopt, id, p) -> PRepl(new_occ(), (match idopt with
      None -> None
    | Some id -> Some (rename_ie id)), rename_ie id, rename_proc p)
  | PRestr(id,t,p) -> PRestr(rename_ie id, rename_ie t, rename_proc p)
  | PLetDef x -> PLetDef(rename_ie x)
  | PTest(t,p1,p2) -> PTest(rename_term t, rename_proc p1, rename_proc p2)
  | PFind(l,p,opt) -> PFind(List.map (fun (bl, def_list, c,p1) ->
      (List.map (fun (x,t) -> (rename_ie x, rename_ie t)) bl,
       List.map rename_br def_list,
       rename_term c,
       rename_proc p1)) l, rename_proc p, opt)
  | PEvent(t,p) -> PEvent(rename_term t, rename_proc p)
  | PInput(t,tpat,p) -> PInput(rename_term t, rename_pat tpat, rename_proc p)
  | POutput(t1,t2,p) -> POutput(rename_term t1, rename_term t2, rename_proc p)
  | PLet(pat, t, p1, p2) -> PLet(rename_pat pat, rename_term t, rename_proc p1, rename_proc p2)
  in
  (p', ext)

let rename_act = function
    PAFunApp i -> PAFunApp (rename_ie i)
  | PAPatFunApp i -> PAPatFunApp (rename_ie i)
  | (PAReplIndex | PAArrayAccess _ | PACompare _ |
     PAAnd | PAOr | PANewChannel | PAIf | PAFind _ | PAIn _) as x -> x
  | PAAppTuple l -> PAAppTuple (List.map rename_ie l)
  | PAPatTuple l -> PAPatTuple (List.map rename_ie l)
  | PANew i -> PANew  (rename_ie i)
  | PAOut (l, t) -> PAOut(List.map rename_ie l, rename_ie t)

let rec rename_probaf (p,ext) =
  let p' = match p with
    PAdd(p1,p2) -> PAdd(rename_probaf p1, rename_probaf p2)
  | PSub(p1,p2) -> PSub(rename_probaf p1, rename_probaf p2)
  | PProd(p1,p2) -> PProd(rename_probaf p1, rename_probaf p2)
  | PDiv(p1,p2) -> PDiv(rename_probaf p1, rename_probaf p2)
  | PMax l -> PMax (List.map rename_probaf l)
  | PPIdent i -> PPIdent (rename_ie i)
  | PCount i -> PCount (rename_ie i)
  | PPFun(i,l) -> PPFun(rename_ie i, List.map rename_probaf l)
  | (PPZero | PCst _ | PFloatCst _ | PTime) as x -> x
  | PCard i -> PCard (rename_ie i)
  | PActTime(act, l) -> PActTime(rename_act act, List.map rename_probaf l)
  | PMaxlength t -> PMaxlength (rename_term t)
  | PLength(i,l) -> PLength(rename_ie i, List.map rename_probaf l)
  | PLengthTuple(il,l) -> PLengthTuple(List.map rename_ie il, 
				       List.map rename_probaf l)
  in
  (p', ext)

let rec rename_fungroup = function
    PReplRestr((n, iopt, i), lres, lfg) ->
      PReplRestr((new_occ(), 
		  (match iopt with
		    None -> None
		  | Some i1 -> Some (rename_ie i1)), rename_ie i),
		 List.map (fun (x,t,opt) -> (rename_ie x, rename_ie t,opt)) lres,
		 List.map rename_fungroup lfg)
  | PFun(i, larg, r, n) ->
      PFun(rename_ie_dummy_channel i, List.map (fun (x,t) -> (rename_ie x, match t with
	Tid i -> Tid (rename_ie i)
      |	TBound n -> TBound (rename_ie n))) larg,
	   rename_term r, n)

let rename_eqmember (l,ext1) =
  (List.map (fun (fg, mode, ext) -> (rename_fungroup fg, mode, ext)) l, ext1) (* Do not rename the mode! *)

let rename_query = function
    PQSecret i -> PQSecret (rename_ie i)
  | PQSecret1 i -> PQSecret1 (rename_ie i)
  | PQEvent(decl,t1,t2) -> 
      PQEvent(List.map (fun (x,t) -> (rename_ie x, rename_ie t)) decl, 
	      rename_term t1, rename_term t2)

let rename_decl = function
    ParamDecl((s,ext), options) ->
      ParamDecl((rename_ident s, ext), options)
  | ProbabilityDecl(s,ext) ->
      ProbabilityDecl(rename_ident s, ext)
  | TypeDecl(s,options) ->
      TypeDecl(rename_ie s, options)
  | ConstDecl(s1,s2) ->
      ConstDecl(rename_ie s1, rename_ie s2)
  | ChannelDecl(s1,ext1) ->
      ChannelDecl(rename_ident s1, ext1)
  | Setting((p,ext),v) -> Setting((p,ext),v)
  | FunDecl(s1,l,sr,f_options) ->
      FunDecl(rename_ie s1,
	      List.map rename_ie l,
	      rename_ie sr,f_options)
  | EventDecl(s1, l) ->
      EventDecl(rename_ie s1, List.map rename_ie l)
  | Statement(l, t) ->
      Statement(List.map (fun (i,t) -> (rename_ie i, rename_ie t)) l,
		rename_term t)
  | EqStatement(l,r,p,options) ->
      EqStatement(rename_eqmember l, rename_eqmember r, rename_probaf p, options)
  | Collision(restr, forall,  t1, p, t2) ->
      Collision(List.map (fun (x,t) -> (rename_ie x, rename_ie t)) restr,
		List.map (fun (x,t) -> (rename_ie x, rename_ie t)) forall,
		rename_term t1,
		rename_probaf p,
		rename_term t2)
  | Query l ->
      Query(List.map rename_query l)
  | PDef(s,p) ->
      PDef(rename_ie s, rename_proc p)
  | Proofinfo(pr) ->
      begin
	match pr with
	  ((_, ext)::_)::_ ->
	    input_error "Proof indications not allowed in macros" ext
	| _ -> internal_error "empty proof"
      end
  | Define((s1,ext1),argl,def) ->
      input_error "macro definitions are not allowed inside macro definitions" ext1
  | Expand((s1,ext1),argl) ->
      internal_error "macro-expansion inside a macro should have been expanded at macro definition point" 
	

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


(* Check declarations *)

let add_not_found s ext v =
  if StringMap.mem s (!env) then
    input_error (s ^ " already defined.") ext
  else
    env := StringMap.add s v (!env)

let rec check_one = function
    ParamDecl((s,ext), options) ->
      let size =
	match options with
	  [] -> Settings.psize_DEFAULT
	| ["noninteractive",_] -> Settings.psize_NONINTERACTIVE
	| ["passive",_] -> Settings.psize_PASSIVE
	| [sopt,extopt] -> (* option "size<n>" where <n> is an integer *)
	    begin
	      try
		if (String.sub sopt 0 4) <> "size" then raise Not_found;
		int_of_string (String.sub sopt 4 (String.length sopt - 4))
	      with _ ->
		Parsing_helper.input_error ("Unknown parameter option " ^ sopt) extopt
	    end
	| _::_::_ -> Parsing_helper.input_error "Parameters accept a single size option" ext
      in
      add_not_found s ext (EParam{ pname = s; psize = size })
  | ProbabilityDecl(s,ext) ->
      add_not_found s ext (EProba{ prname = s })
  | TypeDecl((s1,ext1),options) ->
	let opt = ref 0 in
	let size = ref Settings.tysize_SMALL in
	List.iter (fun (sopt, extopt) ->
	  match sopt with
	    "large" -> 
	      if (!size) <> Settings.tysize_SMALL then
		Parsing_helper.input_error ("Types options large, password, and size<n> are incompatible") ext1;
	      size := Settings.tysize_LARGE
	  | "password" -> 
	      if (!size) <> Settings.tysize_SMALL then
		Parsing_helper.input_error ("Types options large, password, and size<n> are incompatible") ext1;
	      size := Settings.tysize_PASSWORD
	  | "fixed" -> opt := (!opt) lor Settings.tyopt_CHOOSABLE lor Settings.tyopt_BOUNDED
	  | "bounded" -> opt := (!opt) lor Settings.tyopt_BOUNDED
	  | _ -> (* option size<n> *)
	      try
		if (String.sub sopt 0 4) <> "size" then raise Not_found;
		if (!size) <> Settings.tysize_SMALL then
		  Parsing_helper.input_error ("Types options large, password, and size<n> are incompatible") ext1;
		size := int_of_string (String.sub sopt 4 (String.length sopt - 4))
	      with _ ->
		Parsing_helper.input_error ("Unknown type option " ^ sopt) extopt
	      ) options;
	let ty = { tname = s1;
		   tcat = BitString;
		   toptions = !opt;
		   tsize = !size }
	in
	add_not_found s1 ext1 (EType ty);
	(* register the "move array" transformation for that type *)
	if ((!size) >= !Settings.tysize_MIN_Auto_Coll_Elim) &&
	  ((!opt) land Settings.tyopt_CHOOSABLE != 0) then
	  begin
	    try
	      let (paraml, def, already_def) = StringMap.find "move_array_internal_macro" (!macrotable) in
	      if List.length paraml != 1 then
		input_error ("Macro move_array_internal_macro should expect one argument but expects " ^ (string_of_int (List.length paraml)) ^ " arguments.") ext1;
	      let old_equivalences = !equivalences in
	      List.iter check_one (apply [(s1,ext1)] paraml already_def def);
	      match !equivalences with
		[] -> input_error ("Macro move_array_internal_macro should define an equivalence.") ext1
	      |	(eq::rest) ->
		  if rest != old_equivalences then
		    input_error ("Macro move_array_internal_macro should define exactly one equivalence.") ext1;
		  equivalences := old_equivalences;
		  move_new_eq := (ty, eq) :: (!move_new_eq)
	    with Not_found -> 
	      (* Macro move_array_internal_macro not defined *)
	      ()
	  end
  | ConstDecl((s1,ext1),(s2,ext2)) ->
      let s2' = get_type (!env) s2 ext2 in
      add_not_found s1 ext1 (EFunc{ f_name = s1;
				    f_type = [], s2';
				    f_cat = Std;
				    f_options = 0 })
  | ChannelDecl(s1,ext1) ->
      if (!Settings.front_end) == Settings.Channels then
	add_not_found s1 ext1 (EChannel{ cname = s1 })
      else
	internal_error "ChannelDecl not allowed in oracles front-end"
  | Setting((p,ext),v) ->
      begin
	try 
	  Settings.do_set p v 
	with Not_found -> 
	  input_error  ("Bad setting " ^ p ^ "=" ^
                        (match v with S (s,_) -> s | I n -> string_of_int n)) ext
      end
  | FunDecl((s1,ext1),l,(sr,extr),f_options) ->
      let sr' = get_type (!env) sr extr in
      let l' = List.map (fun (s,ext) ->
	get_type (!env) s ext) l 
      in
      let opt = ref 0 in
      List.iter (fun (sopt, extopt) ->
	  if sopt = "decompos" then 
	    begin
	      opt := (!opt) lor Settings.fopt_DECOMPOS;
	      if List.length l' != 1 then
		Parsing_helper.input_error "A decompos function should be unary" extopt
	    end
	  else if sopt = "uniform" then
	    begin
	      opt := (!opt) lor Settings.fopt_UNIFORM;
	      if List.length l' != 1 then
		Parsing_helper.input_error "A uniform function should be unary" extopt
	    end
	  else if sopt = "compos" then 
	    opt := (!opt) lor Settings.fopt_COMPOS
	  else if sopt = "commut" then
	    begin
	      opt := (!opt) lor Settings.fopt_COMMUT;
	      match l' with
		[t1;t2] when t1 == t2 -> ()
	      |	_ -> Parsing_helper.input_error "A commutative function should have two arguments of the same type" extopt
	    end
	  else
	    Parsing_helper.input_error ("Unknown function option " ^ sopt) extopt
	      ) f_options;
      add_not_found s1 ext1 (EFunc{ f_name = s1;
				   f_type = l',sr';
				   f_cat = Std;
				   f_options = !opt })
  | EventDecl((s1,ext1), l) ->
      let l' = List.map (fun (s,ext) ->
	get_type (!env) s ext) l 
      in
      add_not_found s1 ext1 (EEvent{ f_name = s1;
				     (* Add a bitstring argument to store the current indexes *)
				   f_type = (Settings.t_bitstring :: l'),Settings.t_bool;
				   f_cat = Event;
				   f_options = 0 })
  | Statement s ->
      check_statement (!env) s
  | EqStatement s ->
      current_location := InEquivalence;
      check_eqstatement s
  | Collision s ->
      check_collision (!env) s
  | Query l ->
      queries_parse := l @ (!queries_parse)
  | PDef((s1,ext1),p) ->
      add_not_found s1 ext1 (EProcess p)
  | Proofinfo(pr) ->
      if !proof != None then
	match pr with
	  ((_, ext)::_)::_ ->
	    input_error "Proof indications already given before" ext
	| _ -> internal_error "empty proof"
      else
	proof := Some pr
  | Define((s1,ext1),argl,def) ->
      if StringMap.mem s1 (!macrotable) then
	input_error ("Macro " ^ s1 ^ " already defined.") ext1
      else
	(* Expand macro calls inside macro definitions
	   Because this is done at macro definition point, this requires that
	   the macros used inside the definition be defined before, which
	   is a safe requirement. (It prevents recursive macros, in particular.) *)
	let rec expand_inside_macro = function 
	    Define((s,ext),_,_)::l -> 
	      input_error "macro definitions are not allowed inside macro definitions" ext
	  | Expand((s2,ext2), argl2)::l ->
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
	StringMap.iter (fun s _ -> already_def := s :: (!already_def)) (!env);
	macrotable := StringMap.add s1 (argl, def, !already_def) (!macrotable)
  | Expand((s1,ext1),argl) ->
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
      
let rec check_all (l,p) = 
  List.iter check_one l;
  current_location := InProcess;
  Hashtbl.clear binder_env;
  check_process1 [] p; (* Builds binder_env *)
  check_process [] (!env) p

let get_qbinder (i,ext) = 
  try
    match Hashtbl.find binder_env i with
      Uniq b -> b
    | Ambiguous | UniqNoType | FindCond -> 
	input_error (i ^ " is either defined without type, defined several times, or defined in a condition of find") ext
  with Not_found ->
    input_error (i ^ " not bound") ext

let new_bitstring_binder() = 
  let b = Terms.create_binder "!l" (Terms.new_vname()) Settings.t_bitstring []
  in
  Terms.term_from_binder b

(* Check that when injective events occur several times, they
   occur in different branches of if/find. *)

let several_occ_events = ref []

let rec sym_diff l1 = function
    [] -> l1
  | (a::l) ->
      if List.memq a l1 then
	begin
	  several_occ_events := a :: (!several_occ_events);
          sym_diff (List.filter (fun x -> x != a) l1) l
	end
      else
	a::(sym_diff l1 l)

let rec count_occ_events p = 
  match p.i_desc with
    Nil -> []
  | Par(p1,p2) -> sym_diff (count_occ_events p1) (count_occ_events p2)
  | Repl(_,p) -> count_occ_events p
  | Input(_,_,p) -> count_occ_eventso p

and count_occ_eventso p = 
  match p.p_desc with
    Yield -> []
  | Restr(_,p) -> count_occ_eventso p
  | Test(_,p1,p2) -> Terms.union (count_occ_eventso p1) (count_occ_eventso p2)
  | Find(l0,p2,_) ->
      let l = ref (count_occ_eventso p2) in
      List.iter (fun (_,_,_,p1) -> l := Terms.union (!l) (count_occ_eventso p1)) l0;
      (!l)
  | Output(_,_,p) -> count_occ_events p
  | Let(_,_,p1,p2) -> Terms.union (count_occ_eventso p1) (count_occ_eventso p2)
  | EventP(t,p) -> 
      let l = count_occ_eventso p in
      match t.t_desc with
	FunApp(f,_) ->
	  if List.memq f l then
	    begin
	      several_occ_events := f :: (!several_occ_events);
	      l
	    end
	  else
	    f :: l 
      |	_ -> Parsing_helper.internal_error "Events must be function applications"

let diff_types f =
  let t = List.assq f (!event_type_list) in
  not (List.for_all (fun (f',t') -> (f' != f) || (t == t')) (!event_type_list))

let rec check_term_query1 env = function
    PIdent (s, ext), ext2 ->
      begin
      try 
	match StringMap.find s env with
	  EEvent(f) -> 
	    if List.tl (fst f.f_type) = [] then
	      [false, { t_desc = FunApp(f, [new_bitstring_binder()]); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }]
	    else
	      input_error (s ^ " has no arguments but expects some") ext
	| _ -> input_error (s ^ " should be an event") ext
      with Not_found -> 
	input_error (s ^ " not defined") ext
      end
  | PFunApp((s,ext), tl),ext2 ->
      let tl' = List.map (check_term_nobe env) tl in
      begin
      try 
	match StringMap.find s env with
	  EEvent(f) ->
	    check_type_list ext2 tl tl' (List.tl (fst f.f_type));
	    [false, { t_desc = FunApp(f, (new_bitstring_binder()) :: tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }]
	| _ -> input_error (s ^ " should be an event") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PInjEvent((s,ext), tl),ext2 ->
      let tl' = List.map (check_term_nobe env) tl in
      begin
      try 
	match StringMap.find s env with
	  EEvent(f) ->
	    if List.memq f (!several_occ_events) then
	      input_error "Injective events should occur at most once in each branch of if/find/let" ext2;
	    if diff_types f then
	      input_error "Injective events should be under replications of the same type" ext2;
	    check_type_list ext2 tl tl' (List.tl (fst f.f_type));
	    [true, { t_desc = FunApp(f, (new_bitstring_binder()) :: tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None }]
	| _ -> input_error (s ^ " should be an event") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end      
  | PAnd(t1,t2), ext ->
      (check_term_query1 env t1) @ (check_term_query1 env t2)
  | _,ext2 -> input_error "the left-hand side of a correspondence query should be an event or a conjunction of events" ext2

let rec check_term_query2 env = function
    (PIdent (s, ext), ext2) as x ->
      begin
      try 
	match StringMap.find s env with
	  EVar(b) -> 
	    let x' = { t_desc = Var(b,b.args_at_creation); t_type = b.btype; t_occ = new_occ(); t_loc = ext2; t_facts = None } in
	    check_type (snd x) x' Settings.t_bool;	    
	    QTerm x'
	| EFunc(f) ->
	    if fst (f.f_type) = [] then
	      let x' = { t_desc = FunApp(f, []); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None } in
	      check_type (snd x) x' Settings.t_bool;
	      QTerm x'
	    else
	      input_error (s ^ " has no arguments but expects some") ext

	| EEvent(f) -> 
	    if List.tl (fst f.f_type) = [] then
	      QEvent (false, { t_desc = FunApp(f, [new_bitstring_binder()]); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None })
	    else
	      input_error (s ^ " has no arguments but expects some") ext
	| _ -> input_error (s ^ " should be a variable, a function, or an event") ext
      with Not_found -> 
	input_error (s ^ " not defined") ext
      end
  | (PFunApp((s,ext), tl),ext2) as x ->
      let tl' = List.map (check_term_nobe env) tl in
      begin
      try 
	match StringMap.find s env with
	  EFunc(f) ->
	    check_type_list ext2 tl tl' (fst f.f_type);
	    let x' = { t_desc = FunApp(f, tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None } in
	    check_type (snd x) x' Settings.t_bool;
	    QTerm x'
	| EEvent(f) ->
	    check_type_list ext2 tl tl' (List.tl (fst f.f_type));
	    QEvent (false, { t_desc = FunApp(f, (new_bitstring_binder()) :: tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None })
	| _ -> input_error (s ^ " should be a function or an event") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PInjEvent((s,ext), tl),ext2 ->
      let tl' = List.map (check_term_nobe env) tl in
      begin
      try 
	match StringMap.find s env with
	  EEvent(f) ->
	    if List.memq f (!several_occ_events) then
	      input_error "Injective events should occur once in the process" ext2;
	    check_type_list ext2 tl tl' (List.tl (fst f.f_type));
	    QEvent (true, { t_desc = FunApp(f, (new_bitstring_binder()) :: tl'); t_type = snd f.f_type; t_occ = new_occ(); t_loc = ext2; t_facts = None })
	| _ -> input_error (s ^ " should be a an event") ext
      with Not_found ->
	input_error (s ^ " not defined") ext
      end
  | PAnd(t1,t2), ext ->
      QAnd(check_term_query2 env t1, check_term_query2 env t2)
  | POr(t1,t2), ext ->
      QOr(check_term_query2 env t1, check_term_query2 env t2)
  | x -> 
      let x' = check_term_nobe env x in
      check_type (snd x) x' Settings.t_bool;
      QTerm x'

let rec find_inj = function
    QAnd(t1,t2) | QOr(t1,t2) -> find_inj t1 || find_inj t2
  | QEvent(b,t) -> b
  | QTerm t -> false

let check_query = function
    PQSecret i -> QSecret (get_qbinder i)
  | PQSecret1 i -> QSecret1 (get_qbinder i)
  | PQEvent(vl,t1,t2) -> 
      let (env',l') = check_binder_list (!env) vl in
      let t1' = check_term_query1 env' t1 in
      let t2' = check_term_query2 env' t2 in
      let has_inj_before_impl = List.exists (fun (b,_) -> b) t1' in
      let has_inj_after_impl = find_inj t2' in
      if has_inj_before_impl && not has_inj_after_impl then
	input_error "In this query, inj: is present before ==> but not after ==>.\ninj: should be present either both before and after ==> or not at all." (snd t1);
      if (not has_inj_before_impl) && has_inj_after_impl then
	input_error "In this query, inj: is present after ==> but not before ==>.\ninj: should be present either both before and after ==> or not at all." (snd t2);
      QEventQ(t1',t2')

let read_file f =
  let p = parse_with_lib f in
  env := init_env();
  let (p',_) = check_all p in
  let _ = count_occ_events p' in
  (!statements, !collisions, !equivalences, !move_new_eq, List.map check_query (!queries_parse), !proof, p')
