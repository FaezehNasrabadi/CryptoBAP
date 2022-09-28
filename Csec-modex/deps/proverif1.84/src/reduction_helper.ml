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
open Pitypes
open Terms

let main_process = ref Nil
let min_choice_phase = ref 0

(* Functions that handle processes *)

(* Get the type of a pattern *)

let get_pat_type = function
    PatVar b -> b.btype
  | PatTuple (f,l) -> snd f.f_type
  | PatEqual t -> get_term_type t
    

(* Generate a variable from a pattern, reusing variable names as much
   as possible *)

let new_var_pat1 = function
    PatVar b -> new_var b.sname b.btype
  | PatEqual (Var b) -> new_var b.sname b.btype
  | PatTuple (f,l) -> new_var Param.def_var_name (snd f.f_type)
  | PatEqual t -> new_var Param.def_var_name (get_term_type t)

let new_var_pat pat = Var (new_var_pat1 pat)

(* Get the variables that are defined in a pattern *)

let rec get_pat_vars accu = function
    PatVar b -> b :: accu
  | PatTuple(_,l) -> List.fold_left get_pat_vars accu l
  | PatEqual _ -> accu

let get_pat_vars pat = get_pat_vars [] pat

(* Test whether a variable occurs in a pattern/process *)

let rec occurs_var_pat v = function
    PatVar _ -> false
  | PatTuple(f,l) -> List.exists (occurs_var_pat v) l
  | PatEqual t -> Terms.occurs_var v t

let rec occurs_var_proc v = function
    Nil -> false
  | Par(p1,p2) -> (occurs_var_proc v p1) || (occurs_var_proc v p2)
  | Repl(p,_) -> occurs_var_proc v p
  | Restr(_,p) -> occurs_var_proc v p
  | Test(t1,t2,p1,p2,_) -> 
      (Terms.occurs_var v t1) || (Terms.occurs_var v t2) ||
      (occurs_var_proc v p1) || (occurs_var_proc v p2)
  | Input(t,pat,p,_) ->
      (Terms.occurs_var v t) || (occurs_var_pat v pat) ||
      (occurs_var_proc v p)
  | Output(t1,t2,p,_) -> 
      (Terms.occurs_var v t1) || (Terms.occurs_var v t2) ||
      (occurs_var_proc v p)
  | Let(pat, t, p1, p2, _) ->
      (Terms.occurs_var v t) || (occurs_var_pat v pat) ||
      (occurs_var_proc v p1) || (occurs_var_proc v p2)
  | LetFilter(_,f,p1,p2,_) ->
      (Terms.occurs_var_fact v f) ||
      (occurs_var_proc v p1) || (occurs_var_proc v p2)
  | Event(t,p,_) ->
      (Terms.occurs_var v t) || (occurs_var_proc v p)
  | Insert(t,p,_) ->
      (Terms.occurs_var v t) || (occurs_var_proc v p)
  | Get(pat,t,p,_) ->
      (occurs_var_pat v pat) || (Terms.occurs_var v t) || 
      (occurs_var_proc v p)
  | Phase(_,p) -> occurs_var_proc v p

(* Determine which variables should be included as arguments of names,
   so that queries can be answered *)

let need_vars_in_names = ref ([] : (string * string * Parsing_helper.extent) list)

(* If we have a query in which NI occurs several 
   times and NI corresponds to a restriction in the process, then
   NI designates any name created at that restriction, possibly 
   different names at different occurrences in the query. To say
   that several occurrences of NI correspond to the same name, we
   define a binding "let v = NI[...]" and use several times the variable
   v.

*)

let get_need_vars s =
  let rec get_need_list_rec = function
      [] -> []
    | (s1,s2,e)::l ->
	if s = s1 then
	  (s2,e) :: (get_need_list_rec l)
	else
	  get_need_list_rec l
  in 
  get_need_list_rec (!need_vars_in_names)

(*====================================================================*)
(* Functions to help trace reconstruction algorithms
   by Xavier Allamigeon and Bruno Blanchet *)

(* Find an element of the list x such that f x is true and
   return (index of x in the list, x). The first element of the list
   has index 0. Raise [Not_found] when not found *)

let findi f l =
  let rec findrec n = function
      [] -> raise Not_found
    | (a::r) -> 
	if f a then (n, a) else findrec (n+1) r
  in
  findrec 0 l

(* Remove the first n elements of the list l *)

let rec skip n l = 
  if n = 0 then l else
  match l with
    [] -> Parsing_helper.internal_error "skip"
  | (_::l) -> skip (n-1) l

(* replace the n-th element of the list with a' *)

let rec replace_at n a' = function
  [] -> Parsing_helper.internal_error "replace_at"
| (a::l) -> if n = 0 then a'::l else a::(replace_at (n-1) a' l)

(* remove the n-th element of the list *)

let rec remove_at n = function
   [] -> Parsing_helper.internal_error "remove_at"
| (a::l) -> if n = 0 then l else a::(remove_at (n-1) l)

(* add a' as n-th element of the list l *)
 
let rec add_at n a' l = 
  if n = 0 then a' :: l else 
  match l with
    [] -> Parsing_helper.internal_error "add_at"
  | (a::l) -> a::(add_at (n-1) a' l)

(* Convert the integer n into a string corresponding to (n+1)-th *)

let order_of_int n = 
  (string_of_int (n+1)) ^ 
  (
  if (n>=10) && (n<14) then "th" else
  match (n+1) mod 10 with
  | 1 -> "st"
  | 2 -> "nd"
  | 3 -> "rd"
  | _ -> "th")

(* Apply f to the n first elements of a list *)

let rec itern f n = function
    [] -> ()
  | (a::l) -> 
      if n > 0 then 
	begin
	  f a;  
	  itern f (n-1) l
	end

(* Convert a function specification (function symbol or projection) 
   into a function symbol *)

let funsymb_from_funspec = function
    Func f -> f
  | Proj(f,n) ->
      let vars = var_gen (fst f.f_type) in
      let cat = Red [(vars, List.nth vars n)] in
      { f_name = (string_of_int n) ^ "-th" ^ 
	(* TO DO should I include the types in the function name *)
	(if f.f_name = "" then "" else "-" ^ f.f_name);
	f_type = [snd f.f_type], List.nth (fst f.f_type) n;
	f_cat = cat;
	f_initial_cat = cat;
        f_private = f.f_private;
	f_options = f.f_options }

(* Test equality. t1 and t2 must be closed, but they
   may contain variables linked with TLink
   Optimized code when we have no equations *)
	  
let equal_terms_modulo t1 t2 =
  if TermsEq.hasEquations() then 
    try 
      auto_cleanup (fun () ->
	TermsEq.unify_modulo (fun () -> ()) t1 t2);
      true
    with Unify ->
      false
  else
    Termslinks.equal_closed_terms t1 t2
  
(* Matching modulo the equational theory
   t2 must be closed, but may contain variables linked with TLink
   Optimize the code when we have no equations *)

let match_modulo next_f t1 t2 =
  if TermsEq.hasEquations() then
    TermsEq.unify_modulo next_f t1 t2
  else
    begin
      Termslinks.match_terms t1 t2;
      next_f ()
    end

let match_modulo_list next_f l1 l2 =
  if TermsEq.hasEquations() then
    TermsEq.unify_modulo_list next_f l1 l2
  else
    begin
      List.iter2 Termslinks.match_terms l1 l2;
      next_f ()
    end

(* Creates a new name *)

let name_counter = ref 0

let new_name p s t =
  incr name_counter;
  let cat = Name { prev_inputs = None; prev_inputs_meaning = [] } in
  { f_name = s ^ "_" ^ (string_of_int (!name_counter));
    f_type = [], t;
    f_cat = cat;
    f_initial_cat = cat;
    f_private = p;
    f_options = 0
  }

let rec get_name_charac t =
  match t with
    FunApp({f_cat = Name { prev_inputs_meaning = sl}} as f,l) ->
      let rec find_first_sid sl l =
	match (sl,l) with
	  [],[] -> [f]
	| (sid_meaning::sl',sid::l') ->
	    if (String.length sid_meaning > 0) && (sid_meaning.[0] = '!') then 
	      begin
		match sid with
		  FunApp(fsid,[]) -> [f;fsid]
		| Var {link = TLink t} -> find_first_sid [sid_meaning] [t]
		| _ -> Parsing_helper.internal_error "a session identifier should be a function symbol without argument"
	      end
	    else find_first_sid sl' l'
	| _ -> Parsing_helper.internal_error "different length in find_first_sid"
      in
      find_first_sid sl l
  | Var { link = TLink t } -> get_name_charac t
  | _ -> Parsing_helper.internal_error "unexpected term in get_name_charac"

module Rev_name_tab = Hashtbl.Make (struct 
  type t = Types.term
  let equal = equal_terms_modulo
  let hash p =  Hashtbl.hash (get_name_charac p)
end)

let name_mapping = Rev_name_tab.create 7

let init_name_mapping freenames =
  Rev_name_tab.clear name_mapping;
  List.iter (fun n -> 
    Rev_name_tab.add name_mapping (FunApp(n,[])) n) freenames

let add_name_for_pat t =
  try 
    Rev_name_tab.find name_mapping t
  with Not_found ->
    (* print_string "Could not find "; Display.WithLinks.term t; *)
    let n = new_name true (
      match t with
	FunApp(f,_) -> f.f_name
      |	_ -> "a") (Terms.get_term_type t)
    in
    Rev_name_tab.add name_mapping t n;
    n
  

let add_new_name t =
  let n = new_name false "a" t in
  Rev_name_tab.add name_mapping (FunApp(n,[])) n;
  n
  
(* Display for debugging *)

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
| InsertTag o -> print_string "it"; print_string (string_of_int o)
| GetTag o -> print_string "gt"; print_string (string_of_int o)

let display_tag hsl nl =
  print_string "Process(";
  Display.display_list display_hyp_spec "," hsl;
  print_string "; ";
  Display.WithLinks.term_list nl;
  print_string ")"

(* Display reduction step *)

let display_step = function
    RNil(n) -> print_string ((order_of_int n) ^" process: Reduction 0")
  | RPar(n) -> print_string ((order_of_int n) ^" process: Reduction |")
  | RRepl(n, cpn) -> print_string ((order_of_int n) ^" process: Reduction ! "^(string_of_int cpn)^" copy(ies)")
  | RRestr(n, na, n') -> 
      print_string ((order_of_int n) ^" process: New " ^ na.f_name ^ " creating ");
      Display.display_term2 n'
  | RLet1(n, pat, t) ->
      print_string ((order_of_int n) ^" process: Let ");
      Display.display_pattern pat;
      print_string " = ";
      Display.display_term2 t;
      print_string " succeeds"
  | RLet2(n, pat, t) -> 
      print_string ((order_of_int n) ^" process: Let ");
      Display.display_pattern pat;
      print_string " = ";
      Display.display_term2 t;
      print_string " fails"
  | RInput(n, tc, pat, mess_term) ->
      print_string ((order_of_int n) ^" process: In(");
      Display.display_term2 tc;
      print_string ", ";
      Display.display_pattern pat;
      print_string ") done with message ";
      Display.display_term2 mess_term
  | ROutput1(n, tc, t) ->
      print_string ((order_of_int n) ^" process: Out(");
      Display.display_term2 tc;
      print_string ", ";
      Display.display_term2 t;
      print_string ") done"
  | ROutput2(n, tc, t) ->
      print_string ((order_of_int n) ^" process: Out(");
      Display.display_term2 tc;
      print_string ", ";
      Display.display_term2 t;
      print_string ") ";	
      Display.display_term2 tc;
      print_string " not a channel"
  | ROutput3 (n, tc, t) ->
      print_string ((order_of_int n) ^" process: Out(");
      Display.display_term2 tc;
      print_string ", ";
      Display.display_term2 t;
      print_string ") destructor fails"
  | RTest1(n, t1, t2) ->
      print_string ((order_of_int n) ^" process: If ");
      Display.display_term2 t1;
      print_string " = ";
      Display.display_term2 t2;
      print_string " succeeds"
  | RTest2(n, t1, t2) ->
      print_string ((order_of_int n) ^" process: If ");
      Display.display_term2 t1;
      print_string " = ";
      Display.display_term2 t2;
      print_string " fails"
  | RTest3(n, t1, t2) ->
      print_string ((order_of_int n) ^" process: If ");
      Display.display_term2 t1;
      print_string " = ";
      Display.display_term2 t2;
      print_string " destructor fails"
  | RBegin1(n, t) ->
      print_string ((order_of_int n) ^" process: Event(");
      Display.display_term2 t;
      print_string ") executed"
  | RBegin2(n, t) ->
      print_string ((order_of_int n) ^" process: Event(");
      Display.display_term2 t;
      print_string ") destructor fails or event blocks"
  | REnd(n, t) ->
      print_string ((order_of_int n) ^" process: Event(");
      Display.display_term2 t;
      print_string ") is the goal"
  | RPhase(n) ->
      print_string ("Switching to phase " ^ (string_of_int n))
  | RLetFilter1(n, bl, f)  ->
      print_string ((order_of_int n) ^" process: let ");
      let first = ref true in
      List.iter (fun b -> 
	if !first then 
	  first := false
	else
	  print_string ", ";
	print_string (Display.varname b)
	  ) bl;
      print_string " suchthat ";
      Display.display_fact2 f;
      print_string " executed"
  | RLetFilter2(n, bl, f)  ->
      print_string ((order_of_int n) ^" process: let ");
      let first = ref true in
      List.iter (fun b -> 
	if !first then 
	  first := false
	else
	  print_string ", ";
	print_string (Display.varname b)
	  ) bl;
      print_string " suchthat ";
      Display.display_fact2 f;
      print_string ": destructor fails or let...suchthat blocks"
  | RLetFilter3(n, bl, f)  ->
      print_string ((order_of_int n) ^" process: let ");
      let first = ref true in
      List.iter (fun b -> 
	if !first then 
	  first := false
	else
	  print_string ", ";
	print_string (Display.varname b)
	  ) bl;
      print_string " suchthat ";
      Display.display_fact2 f;
      print_string ": let...suchthat fails"
  | RIO(ninput, tc', pat, n, tc, t) ->
      print_string ((order_of_int ninput) ^" process: In(");
      Display.display_term2 tc';
      print_string ", ";
      Display.display_pattern pat;
      print_string ") reduces with ";
      print_string ((order_of_int n) ^" process: out(");
      Display.display_term2 tc;
      print_string ", ";
      Display.display_term2 t;
      print_string ")"
  | RIO2(ninput, tc', pat, n, tc, t) ->
      print_string ((order_of_int ninput) ^" process: In(");
      Display.display_term2 tc';
      print_string ", ";
      Display.display_pattern pat;
      print_string ") reduces with ";
      print_string ((order_of_int n) ^" process: out(");
      Display.display_term2 tc;
      print_string ", ";
      Display.display_term2 t;
      print_string ") but input fails"
  | RInsert1(n, t) ->
      print_string ((order_of_int n) ^" process: Insert ");
      Display.display_term2 t;
      print_string " done"
  | RInsert2 (n, t) ->
      print_string ((order_of_int n) ^" process: Insert ");
      Display.display_term2 t;
      print_string " destructor fails"
  | RGet(n, pat, t, m) ->
      print_string ((order_of_int n) ^" process: Get ");
      Display.display_pattern pat;
      begin
	match t with
	  FunApp(f, []) when f == Terms.true_cst -> ()
	| _ -> print_string " suchthat "; Display.display_term2 t
      end;
      print_string " done with entry ";
      Display.display_term2 m
  | RInit -> print_string "Initial state"

(* Equivalence between facts *)

let public_free = ref []

let corresp_att_mess p1 p2 =
  match p1.p_info, p2.p_info with
    [Attacker(i,ta)], [Mess(j,tm)] -> i == j && (ta == tm || !Param.untyped_attacker)
  | _ -> false

let corresp_att_mess_bin p1 p2 =
  match p1.p_info, p2.p_info with
    [AttackerBin(i,ta)], [MessBin(j,tm)] -> i == j && (ta == tm || !Param.untyped_attacker)
  | _ -> false

let match_equiv next_f f1 f2 =
  match (f1,f2) with
    Out(t1,l1), Out(t2,l2) -> match_modulo next_f t2 t1 
  | Pred(p1,l1), Pred(p2,l2) when p1 == p2 -> match_modulo_list next_f l2 l1 
  | Pred(p1,[t1]), Pred(p2, [t2';t2]) 
        when (corresp_att_mess p1 p2) 
	&& (List.mem t2' (!public_free)) -> match_modulo next_f t2 t1 
  | Pred(p1,[t1;t2]), Pred(p2, [t3';t3;t4';t4]) 
        when (corresp_att_mess_bin p1 p2) 
	&& (List.mem t3' (!public_free))
        && (List.mem t4' (!public_free)) -> match_modulo_list next_f [t3;t4] [t1;t2] 
  | _ -> raise Unify

let rec match_equiv_list next_f l1 l2 =
  match (l1,l2) with
    [],[] -> next_f()
  | (a1::l1,a2::l2) -> 
      match_equiv (fun () -> match_equiv_list next_f l1 l2) a1 a2
  | _ -> Parsing_helper.internal_error "match_equiv_list"

(* Substitute a name for another name *)

let term_subst t n1 n2 =
  Terms.replace_name n1 n2 t

let fact_subst f n1 n2 = 
  match f with
    Pred(p,l) -> Pred(p, List.map (fun t -> term_subst t n1 n2) l)
  | Out(t,l) -> Out(term_subst t n1 n2, List.map(fun (b,t) -> (b, term_subst t n1 n2)) l)

let rec pat_subst p n1 n2 = 
  match p with
    PatVar b -> PatVar b
  | PatTuple (f,l) -> PatTuple(f,List.map (fun p -> pat_subst p n1 n2) l)
  | PatEqual t -> PatEqual (term_subst t n1 n2)
	
let rec process_subst p n1 n2 = 
  match p with
    Nil -> Nil
  | Par(p1,p2) -> Par(process_subst p1 n1 n2, process_subst p2 n1 n2)
  | Restr(n,p) -> Restr(n, process_subst p n1 n2)
  | Repl(p,occ) -> Repl(process_subst p n1 n2, occ)
  | Let(pat,t,p,q,occ) -> Let(pat_subst pat n1 n2, term_subst t n1 n2, process_subst p n1 n2, process_subst q n1 n2,occ)
  | Input(t, pat, p, occ) -> Input(term_subst t n1 n2, pat_subst pat n1 n2, process_subst p n1 n2, occ)
  | Output(tc, t, p, occ) -> Output(term_subst tc n1 n2, term_subst t n1 n2, process_subst p n1 n2, occ)
  | Test(t, t', p, q, occ) -> Test(term_subst t n1 n2, term_subst t' n1 n2, process_subst p n1 n2, process_subst q n1 n2, occ)
  | Event(t, p, occ) -> Event(term_subst t n1 n2, process_subst p n1 n2, occ)
  | Insert(t, p, occ) -> Insert(term_subst t n1 n2, process_subst p n1 n2, occ)
  | Get(pat, t, p, occ) -> Get(pat_subst pat n1 n2, term_subst t n1 n2, process_subst p n1 n2, occ)
  | Phase(n,p) -> Phase(n,process_subst p n1 n2)
  | LetFilter(bl, f, p, q, occ) -> LetFilter(bl, fact_subst f n1 n2, process_subst p n1 n2, process_subst q n1 n2, occ) 

(* let process_subst = Profile.f4 "process_subst" process_subst *)

(* Copy a process *)

let copy_binder b =
  let b' = Terms.new_var b.sname b.btype in
  match b.link with
    NoLink ->
      Terms.link b (VLink b');
      b'
  | _ -> Parsing_helper.internal_error "unexpected link in copy_binder"

let rec copy_pat = function
    PatVar b -> PatVar (copy_binder b)
  | PatTuple(f,l) -> PatTuple(f, List.map copy_pat l)
  | PatEqual(t) -> PatEqual (copy_term2 t)

let rec copy_process = function
    Nil -> Nil
  | Par(p1,p2) -> Par(copy_process p1, copy_process p2)
  | Restr(n,p) -> Restr(n, copy_process p)
  | Repl(p,occ) -> Repl(copy_process p, occ)
  | Let(pat, t, p, q, occ) -> let pat' = copy_pat pat in Let(pat', copy_term2 t, copy_process p, copy_process q, occ)
  | Input(t, pat, p, occ) -> let pat' = copy_pat pat in Input(copy_term2 t, pat', copy_process p, occ)
  | Output(tc,t,p, occ) -> Output(copy_term2 tc, copy_term2 t, copy_process p, occ)
  | Test(t,t',p,q,occ) -> Test(copy_term2 t, copy_term2 t', copy_process p, copy_process q,occ)
  | Event(t, p, occ) -> Event(copy_term2 t, copy_process p, occ)
  | Insert(t, p, occ) -> Insert(copy_term2 t, copy_process p, occ)
  | Get(pat, t, p, occ) -> let pat' = copy_pat pat in Get(pat', copy_term2 t, copy_process p, occ)
  | Phase(n,p) -> Phase(n, copy_process p)
  | LetFilter(bl, f, p, q, occ) -> let bl' = List.map copy_binder bl in LetFilter(bl', copy_fact2 f, copy_process p, copy_process q, occ)


(* Close all terms after term_evaluation. Indeed, new variables may
   be introduced by term evaluation, when some constructor/destructor
   rules have more variables in their right-hand side than in
   their left-hand side. This may happen when the equational
   theory itself contains linear equations with different variables
   in their left/right-hand sides.
   Also close facts of the derivation tree. *)

let rec close_term = function
    Var v -> 
      begin
	 match v.link with
	   NoLink -> 
            let name = add_new_name v.btype in   
	    let valname = FunApp(name, []) in
	    Terms.link v (TLink valname)
         | TLink t -> close_term t
         | _ -> Parsing_helper.internal_error "unexpected link in close_term"
      end
  | FunApp(f,l) -> List.iter close_term l

let close_fact = function
    Pred(p,l) -> List.iter close_term l
  | Out(t,l) -> close_term t; List.iter (fun (_,t') -> close_term t') l

let rec close_tree tree =
  close_fact tree.thefact;
  match tree.desc with
    FHAny | FEmpty | FRemovedWithProof _ -> ()
  | FEquation son -> close_tree son
  | FRule(_,tags,constra,sons) ->
      List.iter close_tree sons;
      List.iter (List.iter (fun (Neq(t1,t2)) -> close_term t1; close_term t2)) constra;
      match tags with
        ProcessRule (hsl,nl) -> List.iter close_term nl
      | ProcessRule2 (hsl,nl1,nl2) ->
          List.iter close_term nl1;
          List.iter close_term nl2
      | _ -> ()

(* Close terms for testing equality modulo of open terms
   In contrast to close_term above, it does not register the names
   in rev_name_tab since these names will be immediately forgotten
   after the equality test. *)

let rec close_term_tmp = function
    Var v -> 
      begin
	 match v.link with
	   NoLink -> 
            let name = new_name false "a" v.btype in   
	    let valname = FunApp(name, []) in
	    Terms.link v (TLink valname)
         | TLink t -> close_term_tmp t
         | _ -> Parsing_helper.internal_error "unexpected link in close_term"
      end
  | FunApp(f,l) -> List.iter close_term_tmp l

(* Equality of terms modulo the equational theory
   Works for terms that may not be closed.  *)
let equal_open_terms_modulo t1 t2 =
  if TermsEq.hasEquations() then 
    try 
      auto_cleanup (fun () ->
	close_term_tmp t1;
	close_term_tmp t2;
	TermsEq.unify_modulo (fun () -> ()) t1 t2);
      true
    with Unify ->
      false
  else
    Termslinks.equal_terms_with_links t1 t2

(* Equality of facts modulo the equational theory
   Works for facts that may not be closed. Note that the equality
   of environments for Out facts is not verified *)
let equal_facts_modulo f1 f2 =
  match f1, f2 with
    Pred(p1,l1), Pred(p2,l2) ->
      (p1 == p2) && (List.for_all2 equal_open_terms_modulo l1 l2)
  | Out(t1,_),Out(t2,_) -> 
      equal_open_terms_modulo t1 t2
  | _ -> false

(* Copy a closed term *)

let rec copy_closed = function
    FunApp(f,l) -> FunApp(f, List.map copy_closed l)
  | Var v -> match v.link with
      TLink l -> copy_closed l
    | _ -> Parsing_helper.internal_error "unexpected link in copy_closed"

let non_syntactic f = 
  match f.f_cat  with 
    Syntactic f' -> f'
  | _ -> f

let rec copy_closed_remove_syntactic = function
 | FunApp(f,l) -> FunApp(non_syntactic f, List.map copy_closed_remove_syntactic l)
 | Var v -> 
     match v.link with
       TLink l -> copy_closed_remove_syntactic l
     | _ -> Parsing_helper.internal_error "unexpected link in copy_closed"

(* Reverse-apply a name substitution
   The pattern must be closed. *)

let rec rev_name_subst = function
    Var v -> 
      begin
	match v.link with
	  TLink t -> 
	    let t' = rev_name_subst t in
	    v.link <- TLink2 t'; (* Store the image of the translated term, to avoid redoing work *)
	    t'
	| TLink2 t' -> t'
        | _ -> Parsing_helper.internal_error "unexpected link in rev_name_subst"
      end
  | FunApp(f,l) ->
      let f = non_syntactic f in
      match f.f_cat with
	Name _ -> 
	  let t' = FunApp(f, rev_name_subst_list l) in
	  FunApp(add_name_for_pat t',[])
      | _ -> (*hash_cons*) (FunApp(f, rev_name_subst_list l))

and rev_name_subst_list l = List.map rev_name_subst l

(* let rev_name_subst = Profile.f1 "rev_name_subst" rev_name_subst *)

(* let rev_name_subst_list = Profile.f1 "rev_name_subst_list" rev_name_subst_list *)

let rev_name_subst_fact = function
    Pred(p,l) -> Pred(p, rev_name_subst_list l)
  | Out(t,l) -> Out(rev_name_subst t, List.map (fun (v,t') -> (v,rev_name_subst t')) l)

(* Check if a term is an allowed channel *)

let rec follow_link = function
    Var { link = TLink t } -> follow_link t
  | Var { link = TLink2 t } -> t
  | t -> t

let rec close_term_collect_links links = function
    Var v -> 
      begin
	match v.link with
	  NoLink -> 
            let name = add_new_name v.btype in   
	    let valname = FunApp(name, []) in
	    Terms.link v (TLink valname);
	    links := (v,v.link) :: (!links);
        | TLink t -> 
	    if not (List.exists (fun (v',_) -> v == v') (!links)) then 
	       (* If v is in links, we have already done this, so no need to redo it *)
	      begin
		links := (v,v.link) :: (!links);
		close_term_collect_links links t
	      end
        | _ -> Parsing_helper.internal_error "unexpected link in close_term"
      end
  | FunApp(f,l) -> List.iter (close_term_collect_links links) l

let close_fact_collect_links links = function
    Pred(p,l) -> List.iter (close_term_collect_links links) l
  | Out(t,l) -> close_term_collect_links links t; List.iter (fun (_,t') -> close_term_collect_links links t') l

let rec close_tree_collect_links links tree =
  close_fact_collect_links links tree.thefact;
  match tree.desc with
    FHAny | FEmpty | FRemovedWithProof _ -> ()
  | FEquation son -> close_tree_collect_links links son
  | FRule(_,tags,constra,sons) -> 
      List.iter (close_tree_collect_links links) sons;
      List.iter (List.iter (fun (Neq(t1,t2)) -> close_term_collect_links links t1; close_term_collect_links links t2)) constra;
      match tags with
	ProcessRule (hsl,nl) -> List.iter (close_term_collect_links links) nl
      |	ProcessRule2 (hsl,nl1,nl2) -> 
	  List.iter (close_term_collect_links links) nl1;
	  List.iter (close_term_collect_links links) nl2
      |	_ -> ()

(* Compute the phase number of a predicate *)

let getphase p = 
  match p.p_info with
    [Attacker(n,_)] | [Mess(n,_)] | [InputP(n)] | [OutputP(n)] 
  | [AttackerBin(n,_)] | [MessBin(n,_)] | [InputPBin(n)] | [OutputPBin(n)] 
  | [Table n] | [TableBin n] ->
      n
  | _ -> Parsing_helper.internal_error "Bad predicate for getphase"

