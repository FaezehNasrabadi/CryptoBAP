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
open Parsing_helper

let compatible_empty = Binderset.empty

(* Returns a list containing n times element x *)

let rec repeat n x =
  if n = 0 then [] else x :: (repeat (n-1) x)

(* Returns l without its n first elements *)

let rec skip n l = 
  try
    if n = 0 then l else skip (n-1) (List.tl l)
  with Failure "tl" ->
    failwith "Terms.skip"

(* Split l into two lists, first its n first elements, second
   the remaining of l *)

let rec split n l = 
  if n = 0 then ([],l) else
  match l with
    [] -> Parsing_helper.internal_error "split"
  | (a::l') -> let l1,l2 = split (n-1) l' in (a::l1,l2)


(* Find x in list l and return its position *)

let rec find_in_list x = function
    [] -> raise Not_found
  | (a::l) -> if x == a then 0 else 1 + find_in_list x l

(* Take a suffix of length n *)

let lsuffix n l =
  try
    skip (List.length l - n) l
  with Failure "Terms.skip" ->
    failwith "Terms.lsuffix"

(* Remove a suffix of length n *)

let remove_suffix n l =
  let (res, _) = split (List.length l - n) l in
  res

let equal_lists eq l1 l2 =
  (List.length l1 == List.length l2) && 
  (List.for_all2 eq l1 l2)

(* [map_concat f l] applied f to each element of l,
   and concatenates the result. Duplicate elements in the result
   are removed. *)

let equal_mset mset1 mset2 =
  match (mset1, mset2) with
    (MOneBinder b1, MOneBinder b2) -> b1 == b2
  | x, y -> x == y

let equal_rset rset1 rset2 =
  match (rset1, rset2) with
    (All, All) | (Minimal, Minimal) -> true
  | (OneBinder b1, OneBinder b2) -> b1 == b2
  | (SubstOneBinder (b1,occ1), SubstOneBinder (b2, occ2)) -> (b1 == b2) && (occ1 == occ2)
  | _ -> false

let equal_merge_mode m1 m2 =
  match (m1,m2) with
    (MNoBranchVar, MNoBranchVar) | (MCreateBranchVar, MCreateBranchVar) -> true
  | (MCreateBranchVarAtProc (pl1, cur_array1), MCreateBranchVarAtProc (pl2, cur_array2)) ->
      (equal_lists (==) pl1 pl2) && (equal_lists (==) cur_array1 cur_array2)
  | (MCreateBranchVarAtTerm (tl1, cur_array1), MCreateBranchVarAtTerm (tl2, cur_array2)) ->
      (equal_lists (==) tl1 tl2) && (equal_lists (==) cur_array1 cur_array2)
  | _ -> false

let equal_query q1 q2 =
  match (q1,q2) with
    (QSecret b1, QSecret b2) -> b1 == b2
  | (QSecret1 b1, QSecret1 b2) -> b1 == b2
  | _ -> false

let equal_instruct i1 i2 =
  match i1,i2 with
    (ExpandIfFind, ExpandIfFind) -> true
  | (Simplify l1, Simplify l2) -> equal_lists (=) l1 l2
  | (RemoveAssign rset1, RemoveAssign rset2) -> equal_rset rset1 rset2
  | (SArenaming b1, SArenaming b2) -> b1 == b2
  | (MoveNewLet mset1, MoveNewLet mset2) -> equal_mset mset1 mset2
  | (CryptoTransf (eq1, bl1), CryptoTransf (eq2, bl2)) -> 
      (eq1 == eq2) && (equal_lists (==) bl1 bl2)
  | (InsertEvent(s1,n1), InsertEvent(s2,n2)) ->
      (s1 = s2) && (n1 == n2)
  | (InsertInstruct(s1,_,n1,_), InsertInstruct(s2,_,n2,_)) ->
      (s1 = s2) && (n1 == n2)
  | (ReplaceTerm(s1,_,n1,_), ReplaceTerm(s2,_,n2,_)) ->
      (s1 = s2) && (n1 == n2)
  | (MergeArrays(bl1,m1), MergeArrays(bl2,m2)) ->
      (equal_lists (equal_lists (fun (b1,ext1) (b2, ext2) -> (b1 == b2) && (ext1 = ext2))) bl1 bl2) &&
      (equal_merge_mode m1 m2)
  | (MergeBranches, MergeBranches) -> true
  | (Proof ql1, Proof ql2) ->
      equal_lists (fun ((q1,n1),p1) ((q2,n2),p2) -> (equal_query q1 q2) && (n1 = n2) && (p1 = p2)) ql1 ql2
  | _ -> false

let add_eq a l =
  if List.exists (equal_instruct a) l then l else a::l

let rec union_eq l1 = function
    [] -> l1
  | (a::l) ->
      if List.exists (equal_instruct a) l1 then union_eq l1 l else
      a::(union_eq l1 l)

let rec map_concat f = function
    [] -> []
  | (a::l) -> union_eq (f a) (map_concat f l)
      
(* Union of sets of excluded traces *)

let eq_set a b =
  match a,b with
    SetProba r, SetProba r' -> r == r'
  | SetEvent(f,g), SetEvent(f',g') -> (f == f') && (g == g')
  | _ -> false

(* union1 l1 l2 = l1 union l2 *)

let rec union1 l1 = function
    [] -> l1
  | (a::l) -> 
      if List.exists (eq_set a) l1 then
	union1 l1 l
      else
	a::(union1 l1 l)
	  
(* union_setf l = union of all elements of l *)

let rec union_setf = function
    [] -> []
  | (l1::l) -> union1 (union_setf l) l1

(* Create an interval type from a parameter *)

let type_for_param_table = Hashtbl.create 7

let type_for_param p =
  try 
    Hashtbl.find type_for_param_table p 
  with Not_found ->
    let t = { tname = "[1," ^ p.pname ^"]";
	      tcat = Interv p;
	      toptions = Settings.tyopt_BOUNDED;
	      tsize = 0 }
    in
    Hashtbl.add type_for_param_table p t;
    t

(* Get a parameter from an interval type *)

let param_from_type t =
  match t.tcat with
    Interv p -> p
  | _ -> internal_error "Interval type expected"

(* New occurrence *)

let occ = ref 0

let new_occ() =
  incr occ;
  !occ

(* Binder from term *)

let binder_from_term t =
  match t.t_desc with
    Var(b,_) -> b
  | _ -> internal_error "Binder term expected"

let build_term t desc =
  { t_desc = desc;
    t_type = t.t_type;
    t_occ = new_occ(); 
    t_loc = Parsing_helper.dummy_ext;
    t_facts = None }

let build_term2 t desc =
  { t_desc = desc;
    t_type = t.t_type;
    t_occ = t.t_occ;
    t_loc = t.t_loc;
    t_facts = t.t_facts }

let build_term_type ty desc =
  { t_desc = desc;
    t_type = ty;
    t_occ = new_occ();
    t_loc = Parsing_helper.dummy_ext;
    t_facts = None }

let term_from_binder b =
  build_term_type b.btype (Var(b, b.args_at_creation))

let term_from_binderref (b,l) =
  build_term_type b.btype (Var(b, l))

(* Process from desc *)

let iproc_from_desc d = { i_desc = d; i_occ = new_occ(); i_facts = None }

let oproc_from_desc d = { p_desc = d; p_occ = new_occ(); p_facts = None }

let iproc_from_desc2 p d = { i_desc = d; i_occ = p.i_occ; i_facts = p.i_facts }

let oproc_from_desc2 p d = { p_desc = d; p_occ = p.p_occ; p_facts = p.p_facts }

let nil_proc = iproc_from_desc Nil
let yield_proc = oproc_from_desc Yield

(* Constant for each type *)

let cst_for_type_table = Hashtbl.create 7

let cst_for_type ty =
  try
    Hashtbl.find cst_for_type_table ty
  with Not_found ->
    let r = build_term_type ty 
	(FunApp({ f_name = "cst_" ^ ty.tname;
		  f_type = [],ty;
		  f_cat = Std;
		  f_options = 0 },[]))
    in
    Hashtbl.add cst_for_type_table ty r;
    r

(* Is a variable defined by a restriction ? *)

let is_restr b =
  List.for_all (function 
      { definition = DProcess { p_desc = Restr _} } -> true
    | { definition = DTerm ({ t_desc = ResE _}) } -> true
    | { definition = DFunRestr } -> true
    | _ -> false) b.def

let is_repl b =
  List.for_all (function 
      { definition = DInputProcess { i_desc = Repl _} } -> true
    | { definition = DFunRepl } -> true
    | _ -> false) b.def

let is_assign b =
  List.for_all (function 
      { definition = DProcess { p_desc = Let _} } -> true
    | { definition = DTerm { t_desc = LetE _ }} -> true
    | _ -> false) b.def

(* Links *)

let current_bound_vars = ref []

let link v l =
  current_bound_vars := v :: (!current_bound_vars);
  v.link <- l

let cleanup () =
  List.iter (fun v -> v.link <- NoLink) (!current_bound_vars);
  current_bound_vars := []

let auto_cleanup f =
  let tmp_bound_vars = !current_bound_vars in
  current_bound_vars := [];
  try
    let r = f () in
    List.iter (fun v -> v.link <- NoLink) (!current_bound_vars);
    current_bound_vars := tmp_bound_vars;
    r
  with x ->
    List.iter (fun v -> v.link <- NoLink) (!current_bound_vars);
    current_bound_vars := tmp_bound_vars;
    raise x

(* Equality *)

let rec equal_terms t1 t2 = 
  match (t1.t_desc, t2.t_desc) with
    Var(b1,l1),Var(b2,l2) ->
      (b1 == b2) && (List.for_all2 equal_terms l1 l2)
  | FunApp(f1,[t1;t1']),FunApp(f2,[t2;t2']) when f1 == f2 && f1.f_options land Settings.fopt_COMMUT != 0 ->
      (* Commutative function symbols *)
      ((equal_terms t1 t2) && (equal_terms t1' t2')) ||
      ((equal_terms t1 t2') && (equal_terms t1' t2))
  | FunApp(f1,l1),FunApp(f2,l2) ->
      (f1 == f2) && (List.for_all2 equal_terms l1 l2)
  | TestE(t1,t2,t3), TestE(t1',t2',t3') ->
      (equal_terms t1 t1') && (equal_terms t2 t2') && (equal_terms t3 t3')
  | FindE(l,t3,_),FindE(l',t3',_) ->
      (* Could do modulo renaming of bl and bl'! *)
      (equal_lists (fun (bl,def_list,t1,t2) (bl',def_list',t1',t2') ->
	(equal_lists (==) bl bl') && 
	(equal_def_lists def_list def_list') && 
	(equal_terms t1 t1') && (equal_terms t2 t2')) l l') && 
      (equal_terms t3 t3')
  | LetE(pat, t1, t2, topt), LetE(pat', t1', t2', topt') ->
      (equal_pats pat pat') &&
      (equal_terms t1 t1') &&
      (equal_terms t2 t2') &&
      (match topt, topt' with
	None, None -> true
      |	Some t3, Some t3' -> equal_terms t3 t3'
      |	_ -> false)
  | ResE(b,t), ResE(b',t') ->
      (b == b') && (equal_terms t t')
  | EventE(t), EventE(t') -> 
      equal_terms t t'
  | _ -> false

and equal_def_lists def_list def_list' =
  equal_lists equal_binderref def_list def_list'

and equal_binderref (b,l) (b',l') =
  (b == b') && (List.for_all2 equal_terms l l')

and equal_pats p1 p2 =
  match p1,p2 with
    PatVar b, PatVar b' -> b == b'
  | PatTuple (f,l), PatTuple (f',l') -> (f == f') && (List.for_all2 equal_pats l l')
  | PatEqual t, PatEqual t' -> equal_terms t t'
  | _ -> false

let equal_term_lists l1 l2 =
  equal_lists equal_terms l1 l2

let equal_action a1 a2 =
  match a1, a2 with
    AFunApp f, AFunApp f' -> f == f'
  | APatFunApp f, APatFunApp f' -> f == f'
  | AReplIndex, AReplIndex -> true
  | AArrayAccess n, AArrayAccess n' -> n == n'
  | ANew t, ANew t' -> t == t'
  | ANewChannel, ANewChannel -> true
  | AIf, AIf -> true
  | AFind n, AFind n' -> n == n'
  | AOut(tl,t), AOut(tl',t') -> (t == t') && (equal_lists (==) tl tl')
  | AIn n, AIn n' -> n == n'
  | _ -> false
  
let rec equal_probaf p1 p2 =
  match p1, p2 with
    Proba(p, l), Proba(p',l') -> (p == p') && (equal_lists equal_probaf l l')
  | Count p, Count p' -> p == p'
  | OCount c, OCount c' -> c == c'
  | Cst f, Cst f' -> f = f'
  | Zero, Zero -> true
  | Card t, Card t' -> t == t'
  | AttTime, AttTime -> true
  | Time (n,p), Time (n',p') -> (n == n') && (equal_probaf p p')
  | ActTime(a,l), ActTime(a',l') -> (equal_action a a') && (equal_lists equal_probaf l l')
  | Add(p1,p2), Add(p1',p2') -> (equal_probaf p1 p1') && (equal_probaf p2 p2')
  | Mul(p1,p2), Mul(p1',p2') -> (equal_probaf p1 p1') && (equal_probaf p2 p2')
  | Sub(p1,p2), Sub(p1',p2') -> (equal_probaf p1 p1') && (equal_probaf p2 p2')
  | Div(p1,p2), Div(p1',p2') -> (equal_probaf p1 p1') && (equal_probaf p2 p2')
  | Max l, Max l' -> equal_lists equal_probaf l l'
  | Maxlength(n,t),Maxlength(n',t') -> (n == n') && (equal_terms t t')
  | TypeMaxlength(t),TypeMaxlength(t') -> t == t'
  | Length(f,l), Length(f',l') -> (f == f') && (equal_lists equal_probaf l l')
  | _ -> false

(* Compute the length of the longest common prefix *)

let rec len_common_prefix l1 l2 =
  match (l1, l2) with
    [], _ | _, [] -> 0
  | (a1::l1,a2::l2) ->
      if equal_terms a1 a2 then 1 + len_common_prefix l1 l2 else 0

(* Compute the length of the longest common suffix *)

let len_common_suffix l1 l2 =
  len_common_prefix (List.rev l1) (List.rev l2)

(* Term from pattern *)

let rec term_from_pat = function
    PatVar b -> term_from_binder b
  | PatTuple (f,l) -> 
      build_term_type (snd f.f_type) (FunApp(f, List.map term_from_pat l))
  | PatEqual t -> t

(* Type of a pattern *)

let get_type_for_pattern = function
    PatVar b -> b.btype
  | PatTuple(f,_) -> snd f.f_type
  | PatEqual t -> t.t_type

(* New variable name *)

let vcounter = ref 0

let new_vname() =
  incr vcounter;
  !vcounter

let new_binder b0 =
  { sname = b0.sname;
    vname = new_vname();
    btype = b0.btype;
    args_at_creation = b0.args_at_creation;
    def = b0.def;
    compatible = compatible_empty;
    link = NoLink;
    count_def = 0;
    root_def_array_ref = false;
    root_def_std_ref = false;
    array_ref = false;
    std_ref = false;
    count_array_ref = 0;
    count_exclude_array_ref = 0;
    priority = 0 }

let create_binder s n t a =
  { sname = s;
    vname = n;
    btype = t;
    args_at_creation = a;
    def = [];
    compatible = compatible_empty;
    link = NoLink;
    count_def = 0;
    root_def_array_ref = false;
    root_def_std_ref = false;
    array_ref = false;
    std_ref = false;
    count_array_ref = 0;
    count_exclude_array_ref = 0;
    priority = 0 }

(* Find out whether a term is a conjunction of "defined(...)" conditions *)

let rec mem_binderref br = function
    [] -> false
  | (a::l) -> (equal_binderref br a) || (mem_binderref br l)

let add_binderref a accu =
  if mem_binderref a (!accu) then () else accu := a :: (!accu)

let setminus_binderref s1 s2 =
  List.filter (fun br -> not (mem_binderref br s2)) s1

let inter_binderref s1 s2 =
  List.filter (fun br -> mem_binderref br s2) s1

(* get def_list subterms *)

let rec get_deflist_subterms accu t =
  match t.t_desc with
    Var(b,l) -> add_binderref (b,l) accu
  | FunApp(f,l) -> List.iter (get_deflist_subterms accu) l
  | TestE(t1,t2,t3) -> 
      get_deflist_subterms accu t1;
      get_deflist_subterms accu t2;
      get_deflist_subterms accu t3
  | FindE(l0,t3, find_info) ->
      List.iter (fun (bl, def_list, t, t1) ->
	get_deflist_subterms accu t;
	get_deflist_subterms accu t1
	) l0;
      get_deflist_subterms accu t3
  | LetE(pat,t1,t2,topt) ->
      get_def_list_pat accu pat;
      get_deflist_subterms accu t1;
      get_deflist_subterms accu t2;
      begin
	match topt with
	  None -> ()
	| Some t3 -> get_deflist_subterms accu t3
      end
  | ResE(b,t) -> get_deflist_subterms accu t
  | EventE(t) -> get_deflist_subterms accu t

and get_def_list_pat accu = function
    PatVar _ -> ()
  | PatTuple(f,l) -> List.iter (get_def_list_pat accu) l
  | PatEqual t -> get_deflist_subterms accu t

let rec get_deflist_process accu p = 
  match p.i_desc with
    Nil -> ()
  | Par(p1,p2) -> get_deflist_process accu p1;
      get_deflist_process accu p2
  | Repl(b,p) -> get_deflist_process accu p
  | Input((c,tl),pat,p) ->
      List.iter (get_deflist_subterms accu) tl;
      get_def_list_pat accu pat;
      get_deflist_oprocess accu p

and get_deflist_oprocess accu p =
  match p.p_desc with
    Yield -> ()
  | Restr(b,p) -> get_deflist_oprocess accu p
  | Test(t,p1,p2) -> 
      get_deflist_subterms accu t;
      get_deflist_oprocess accu p1;
      get_deflist_oprocess accu p2
  | Find(l0,p2, find_info) ->
      List.iter (fun (bl, def_list, t, p1) ->
	get_deflist_subterms accu t;
	get_deflist_oprocess accu p1
	) l0;
      get_deflist_oprocess accu p2
  | Let(pat,t,p1,p2) ->
      get_def_list_pat accu pat;
      get_deflist_subterms accu t;
      get_deflist_oprocess accu p1;
      get_deflist_oprocess accu p2
  | Output((c,tl),t2,p) ->
       List.iter (get_deflist_subterms accu) tl;
      get_deflist_subterms accu t2;
      get_deflist_process accu p
  | EventP(t,p) ->
      get_deflist_subterms accu t;
      get_deflist_oprocess accu p
      

(* Copy term, following one level of links *)

let rec copy_term t = 
  match t.t_desc with
    Var(b,l) ->
      begin
	match b.link with
	  NoLink -> build_term t (Var(b,List.map copy_term l))
	| TLink t -> t
      end
  | FunApp(f,l) ->
      build_term t (FunApp(f, List.map copy_term l))
  | _ -> Parsing_helper.internal_error "Only Var/FunApp expected in copy_term"

(* Compute term { l / cur_array } *)

let subst cur_array l term =
  auto_cleanup (fun () ->
    List.iter2 (fun b t -> link b (TLink t)) cur_array l;
    copy_term term)


(* Substitution of v[v.args_at_creation] only *)

let rec copy_term3 t = 
  match t.t_desc with
    Var(b,l) ->
      begin
	match b.link with
	  TLink t when List.for_all2 equal_terms l b.args_at_creation ->
	    t
	| _ -> 
	    build_term t (Var(b,List.map copy_term3 l))
      end
  | FunApp(f,l) ->
      build_term t (FunApp(f, List.map copy_term3 l))
  | TestE(t1,t2,t3) ->
      build_term t (TestE(copy_term3 t1, copy_term3 t2, copy_term3 t3))
  | LetE(pat, t1, t2, topt) ->
      let topt' = match topt with
	None -> None
      |	Some t3 -> Some (copy_term3 t3)
      in
      build_term t (LetE(copy_pat3 pat, copy_term3 t1, copy_term3 t2, topt'))
  | FindE(l, t3, find_info) -> 
      let l' = List.map (fun (bl, def_list, t1, t2) ->
	let def_list' = copy_def_list3 def_list in
	(bl, def_list', copy_term3 t1, copy_term3 t2)) l
      in
      build_term t (FindE(l', copy_term3 t3, find_info))
  | ResE(b,t') ->
      build_term t (ResE(b, copy_term3 t'))
  | EventE(t') ->
      build_term t (EventE(copy_term3 t'))
	
and copy_pat3 = function
  PatVar b -> PatVar b
| PatTuple (f,l) -> PatTuple(f,List.map copy_pat3 l)
| PatEqual t -> PatEqual(copy_term3 t)

and copy_def_list3 = function
    [] -> []
  | (b, l)::r ->
      let r' = copy_def_list3 r in
      match b.link with
	TLink t when List.for_all2 equal_terms l b.args_at_creation ->
	  let accu = ref r' in
	  get_deflist_subterms accu t;
	  !accu
      |	_ ->
	  (b, List.map copy_term3 l) :: r'

let rec copy_process3 p = 
  iproc_from_desc (
      match p.i_desc with
	Nil -> Nil
      | Par(p1,p2) -> Par(copy_process3 p1, copy_process3 p2)
      | Repl(b,p) -> Repl(b, copy_process3 p)
      | Input((c,tl),pat,p) ->
	  Input((c, List.map copy_term3 tl), copy_pat3 pat, 
		copy_oprocess3 p))

and copy_oprocess3 p = 
  oproc_from_desc (
      match p.p_desc with
	Yield -> Yield
      | Restr(b,p) -> Restr(b, copy_oprocess3 p)
      | Test(t,p1,p2) -> 
	  Test(copy_term3 t, copy_oprocess3 p1, copy_oprocess3 p2)
      | Find(l,p2, find_info) ->
	  let l' = List.map (fun (bl, def_list, t, p1) ->
	    (bl, copy_def_list3 def_list, 
	     copy_term3 t, copy_oprocess3 p1)
	      ) l in
	  Find(l',copy_oprocess3 p2, find_info)
      | Output((c,tl),t,p) ->
	  Output((c, List.map copy_term3 tl), copy_term3 t, copy_process3 p)
      | Let(pat, t, p1, p2) ->
	  Let(copy_pat3 pat, copy_term3 t, copy_oprocess3 p1, copy_oprocess3 p2)
      | EventP(t,p) -> EventP(copy_term3 t, copy_oprocess3 p))

let subst3 subst t =
  auto_cleanup (fun () ->
    List.iter (fun (b,t') -> link b (TLink t')) subst;
    copy_term3 t)

let subst_def_list3 subst def_list =
  auto_cleanup (fun () ->
    List.iter (fun (b,t') -> link b (TLink t')) subst;
    copy_def_list3 def_list)
  
let subst_oprocess3 subst p =
  auto_cleanup (fun () ->
    List.iter (fun (b,t') -> link b (TLink t')) subst;
    copy_oprocess3 p)
 
(* Check whether a term t refers to a binder b0 *)

let no_def = ref false

let rec refers_to b0 t = 
  match t.t_desc with
    Var (b,l) -> 
      (b == b0) || (List.exists (refers_to b0) l) ||
      (match b.link with
	 TLink t -> refers_to b0 t
       | _ -> false)
  | FunApp(f,l) -> List.exists (refers_to b0) l
  | TestE(t1,t2,t3) -> (refers_to b0 t1) || (refers_to b0 t2) || (refers_to b0 t3)
  | ResE(b,t) -> refers_to b0 t
  | EventE(t) -> refers_to b0 t
  | FindE(l0,t3, find_info) -> 
      (List.exists (fun (bl,def_list,t1,t2) ->
	(List.exists (refers_to_br b0) def_list) ||
	(refers_to b0 t1) || (refers_to b0 t2)) l0) || 
      (refers_to b0 t3)
  | LetE(pat, t1, t2, topt) ->
      (refers_to_pat b0 pat) ||
      (refers_to b0 t1) || (refers_to b0 t2) ||
      (match topt with
	None -> false
      |	Some t3 -> refers_to b0 t3)

and refers_to_br b0 (b,l) =
  ((not (!no_def)) && (b == b0)) || List.exists (refers_to b0) l

and refers_to_pat b0 = function
    PatVar b -> false
  | PatTuple (f,l) -> List.exists (refers_to_pat b0) l
  | PatEqual t -> refers_to b0 t 

let rec refers_to_process b0 p = 
  match p.i_desc with
    Nil -> false
  | Par(p1,p2) -> (refers_to_process b0 p1) || (refers_to_process b0 p2)
  | Repl(b,p) -> refers_to_process b0 p
  | Input((c,tl),pat,p) -> 
      (List.exists (refers_to b0) tl) || (refers_to_pat b0 pat) || (refers_to_oprocess b0 p)

and refers_to_oprocess b0 p =
  match p.p_desc with
    Yield -> false
  | Restr(b,p) -> refers_to_oprocess b0 p
  | Test(t,p1,p2) -> (refers_to b0 t) || (refers_to_oprocess b0 p1) ||
    (refers_to_oprocess b0 p2)
  | Find(l0,p2, find_info) ->
      (List.exists (fun (bl,def_list,t,p1) ->
	(List.exists (refers_to_br b0) def_list) ||
        (refers_to b0 t) || (refers_to_oprocess b0 p1)) l0) || 
      (refers_to_oprocess b0 p2)
  | Output((c,tl),t2,p) ->
      (List.exists (refers_to b0) tl) || (refers_to b0 t2) || (refers_to_process b0 p)
  | EventP(t,p) ->
      (refers_to b0 t) || (refers_to_oprocess b0 p)
  | Let(pat,t,p1,p2) ->
      (refers_to b0 t) || (refers_to_pat b0 pat) || 
      (refers_to_oprocess b0 p1) ||(refers_to_oprocess b0 p2)

let rec refers_to_fungroup b = function
    ReplRestr(_,_,funlist) ->
      List.exists (refers_to_fungroup b) funlist
  | Fun(_,_,res,_) -> refers_to b res

let refers_to_nodef b0 t =
  no_def := true;
  let res = refers_to b0 t in
  no_def := false;
  res

let refers_to_process_nodef b0 p =
  no_def := true;
  let res = refers_to_oprocess b0 p in
  no_def := false;
  res

(* Extract defined variables from a pattern *)

let rec vars_from_pat accu = function
    PatVar b -> b::accu
  | PatEqual t -> accu
  | PatTuple (f,l) -> vars_from_pat_list accu l

and vars_from_pat_list accu = function
    [] -> accu
  | (a::l) -> vars_from_pat_list (vars_from_pat accu a) l


(* Test if a variable occurs in a pattern *)

let rec occurs_in_pat b = function
    PatVar b' -> b' == b
  | PatTuple (f,l) -> List.exists (occurs_in_pat b) l
  | PatEqual t -> false

(* Testing boolean values *)

let is_true t =
  match t.t_desc with
    FunApp(f,[]) when f == Settings.c_true -> true
  | _ -> false

let is_false t =
  match t.t_desc with
    FunApp(f,[]) when f == Settings.c_false -> true
  | _ -> false

(* Applying boolean functions *)

let make_true () =
  build_term_type Settings.t_bool (FunApp(Settings.c_true, []))
  
let make_false () =
  build_term_type Settings.t_bool (FunApp(Settings.c_false, []))

let make_and_ext ext t t' =
  if (is_false t) || (is_false t') then make_false() else
  if is_true t then t' else
  if is_true t' then t else
  { t_desc = FunApp(Settings.f_and, [t;t']);
    t_type = Settings.t_bool;
    t_occ = new_occ();
    t_loc = ext;
    t_facts = None }

let make_and t t' =  make_and_ext Parsing_helper.dummy_ext t t'

let make_or_ext ext t t' =
  if (is_true t) || (is_true t') then make_true() else
  if is_false t then t' else
  if is_false t' then t else
  { t_desc = FunApp(Settings.f_or, [t;t']);
    t_type = Settings.t_bool;
    t_occ = new_occ();
    t_loc = ext;
    t_facts = None }

let make_or t t' =  make_or_ext Parsing_helper.dummy_ext t t'

let rec make_and_list = function
    [] -> make_true()
  | [a] -> a
  | (a::l) -> make_and a (make_and_list l)

let rec make_or_list = function
    [] -> make_false()
  | [a] -> a
  | (a::l) -> make_or a (make_or_list l)

let make_not t =
  build_term_type Settings.t_bool (FunApp(Settings.f_not, [t]))
  
let make_equal_ext ext t t' =
  { t_desc = FunApp(Settings.f_comp Equal t.t_type t'.t_type, [t;t']);
    t_type = Settings.t_bool;
    t_occ = new_occ();
    t_loc = ext;
    t_facts = None }

let make_equal t t' = make_equal_ext Parsing_helper.dummy_ext t t'

let make_let_equal t t' =
  build_term_type Settings.t_bool (FunApp(Settings.f_comp LetEqual t.t_type t'.t_type, [t;t']))

let make_diff_ext ext t t' =
  { t_desc = FunApp(Settings.f_comp Diff t.t_type t'.t_type, [t;t']);
    t_type = Settings.t_bool;
    t_occ = new_occ();
    t_loc = ext;
    t_facts = None }

let make_diff t t' = make_diff_ext Parsing_helper.dummy_ext t t'

(* Put a term in the form or (and (...)) *)

let rec get_or t =
  match t.t_desc with
    FunApp(f, [t1;t2]) when f == Settings.f_or ->
      (get_or t1) @ (get_or t2)
  | _ -> [t]

let rec make_and1 a = function
    [] -> Parsing_helper.internal_error "make_and1 empty"
  | [b] -> make_and b a
  | (b::l2) -> make_or (make_and a b) (make_and1 a l2)

let rec make_and2 l1 = function
    [] -> Parsing_helper.internal_error "make_and2 empty"
  | [a] -> make_and1 a l1
  | (a::l2) -> make_or (make_and1 a l1) (make_and2 l1 l2)

let make_and_distr t1 t2 =
  if (is_false t1) || (is_false t2) then make_false() else
  if is_true t1 then t2 else
  if is_true t2 then t1 else
  (* If t1 or t2 is "or", distribute *)
  make_and2 (get_or t1) (get_or t2)

let rec or_and_form t =
  match t.t_desc with
    FunApp(f, [t1;t2]) when f == Settings.f_and ->
      make_and_distr (or_and_form t1) (or_and_form t2)
  | FunApp(f, [t1;t2]) when f == Settings.f_or ->
      make_or (or_and_form t1) (or_and_form t2)
  | _ -> t

(* Test for tuples *)

let is_tuple t =
  match t.t_desc with
    FunApp(f, _) when (f.f_options land Settings.fopt_COMPOS) != 0 -> true
  | _ -> false

let is_pat_tuple = function
    PatTuple (f,_) -> true
  | _ -> false

(* Compute intersections *)

let rec intersect eqtest l = function
    [] -> []
  | (a'::l') -> 
      let l'' = intersect eqtest l l' in
      if List.exists (eqtest a') l then 
	a'::l'' 
      else
	l''

let rec intersect_list eqtest = function
    [] -> Parsing_helper.internal_error "Intersection of nothing"
  | [a] -> a
  | (a::l) -> intersect eqtest a (intersect_list eqtest l)

(* Building lets *)

let rec put_lets l1 l2 p1 p2 = 
  match (l1,l2) with
    [],[] -> p1
  | (a1::l1),(a2::l2) ->
      oproc_from_desc (Let(a1, a2, put_lets l1 l2 p1 p2, p2))
  | _ -> Parsing_helper.internal_error "Different lengths in put_lets"

let rec put_lets_term l1 l2 p1 p2 = 
  match (l1,l2) with
    [],[] -> p1
  | (a1::l1),(a2::l2) ->
      build_term_type p1.t_type (LetE(a1, a2, put_lets_term l1 l2 p1 p2, p2))
  | _ -> Parsing_helper.internal_error "Different lengths in put_lets"

exception Impossible

let rec split_term f0 t = 
  match t.t_desc with
    Var(_,_) -> 
      (* TO DO when the variable is created by a restriction,
         it is different from a tuple with high probability *)
      raise Not_found
  | FunApp(f,l) when f == f0 -> l
  | FunApp(f,l) -> 
      if f0.f_cat == Tuple && (f.f_cat == Tuple || (f.f_cat == Std && l == [] && (!Settings.constants_not_tuple))) then
	raise Impossible
      else
	raise Not_found
  | TestE _ | FindE _ | LetE _ | ResE _ | EventE _ ->
      Parsing_helper.internal_error "If, find, let, new, and event should have been expanded (Simplify)"


  
(* Change the occurrences and make sure nodes associated with Find
   are distinct for different occurrences of Find *)

let rec move_occ_term t = 
  build_term t 
      (match t.t_desc with
	Var(b,l) -> Var(b, List.map move_occ_term l)
      |	FunApp(f,l) -> FunApp(f, List.map move_occ_term l)
      |	TestE(t1,t2,t3) -> TestE(move_occ_term t1, 
				 move_occ_term t2, 
				 move_occ_term t3)
      |	FindE(l0,t3, find_info) -> 
	  FindE(List.map (fun (bl,def_list,t1,t2) ->
	          (bl, 
		   List.map move_occ_br def_list,
		   move_occ_term t1,
		   move_occ_term t2)) l0,
		move_occ_term t3, find_info)
      |	LetE(pat, t1, t2, topt) ->
	  LetE(move_occ_pat pat, move_occ_term t1, 
	       move_occ_term t2, 
	       match topt with
		 None -> None
	       | Some t3 -> Some (move_occ_term t3))
      |	ResE(b,t) ->
	  ResE(b, move_occ_term t)
      |	EventE(t) ->
	  EventE(move_occ_term t))

and move_occ_pat = function
    PatVar b -> PatVar b
  | PatTuple (f,l) -> PatTuple(f,List.map move_occ_pat l)
  | PatEqual t -> PatEqual(move_occ_term t)

and move_occ_br (b,l) = (b, List.map move_occ_term l)

let rec move_occ_process p = 
  iproc_from_desc (
      match p.i_desc with
	Nil -> Nil
      | Par(p1,p2) -> Par(move_occ_process p1, move_occ_process p2)
      | Repl(b,p) -> Repl(b, move_occ_process p)
      | Input((c,tl),pat,p) ->
	  Input((c, List.map move_occ_term tl), move_occ_pat pat, move_occ_oprocess p))

and move_occ_oprocess p =
  oproc_from_desc (
      match p.p_desc with
	Yield -> Yield
      | Restr(b,p) -> Restr(b, move_occ_oprocess p)
      | Test(t,p1,p2) -> Test(move_occ_term t, move_occ_oprocess p1,
			      move_occ_oprocess p2)
      | Find(l0, p2, find_info) -> 
	  Find(List.map (fun (bl, def_list, t, p1) -> 
	    (bl, 
	     List.map move_occ_br def_list,
	     move_occ_term t,
	     move_occ_oprocess p1)) l0,
               move_occ_oprocess p2, find_info)
      | Let(pat,t,p1,p2) ->
	  Let(move_occ_pat pat, move_occ_term t,
	      move_occ_oprocess p1,
	      move_occ_oprocess p2)
      | Output((c,tl),t2,p) ->
	  Output((c, List.map move_occ_term tl), move_occ_term t2, move_occ_process p)
      | EventP(t,p) ->
	  EventP(move_occ_term t, move_occ_oprocess p))

let move_occ_process p =
  occ := 0;
  move_occ_process p

(* Empty tree of definition dependances 
   The treatment of TestE/FindE/LetE/ResE is necessary: build_def_process
   is called in check.ml.
*)


let rec empty_def_term t =
  t.t_facts <- None;
  match t.t_desc with
    Var(b,l) ->
      b.def <- [];
      empty_def_term_list l
  | FunApp(_,l) ->
      empty_def_term_list l
  | TestE(t1,t2,t3) ->
      empty_def_term t2;
      empty_def_term t3;
      empty_def_term t1
  | FindE(l0,t3,_) ->
      List.iter (fun (bl,def_list,t1,t2) ->
	List.iter (fun b -> b.def <- []) bl;
	empty_def_term_def_list def_list;
	empty_def_term t1;
	empty_def_term t2) l0;
      empty_def_term t3;
  | LetE(pat, t1, t2, topt) ->
      empty_def_pattern pat;
      empty_def_term t1;
      empty_def_term t2;
      begin
	match topt with
	  None -> ()
	| Some t3 -> empty_def_term t3
      end
  | ResE(b,t) -> b.def <- []; empty_def_term t
  | EventE(t) -> empty_def_term t

and empty_def_term_list l = List.iter empty_def_term l

and empty_def_br (b,l) = b.def <- []; empty_def_term_list l

and empty_def_term_def_list def_list = 
  List.iter empty_def_br def_list

and empty_def_pattern = function
    PatVar b -> b.def <- []
  | PatTuple (f,l) -> List.iter empty_def_pattern l
  | PatEqual t -> empty_def_term t

let rec empty_def_process p = 
  p.i_facts <- None;
  match p.i_desc with
    Nil -> ()
  | Par(p1,p2) -> 
      empty_def_process p1;
      empty_def_process p2
  | Repl(b,p) ->
      b.def <- [];
      empty_def_process p
  | Input((c,tl),pat,p) ->
      List.iter empty_def_term tl;
      empty_def_pattern pat;
      empty_def_oprocess p

and empty_def_oprocess p = 
  p.p_facts <- None;
  match p.p_desc with
    Yield -> ()
  | Restr(b,p) ->
      b.def <- [];
      empty_def_oprocess p
  | Test(t,p1,p2) ->
      empty_def_term t;
      empty_def_oprocess p1;
      empty_def_oprocess p2
  | Find(l0,p2,_) ->
      List.iter (fun (bl,def_list,t,p1) ->
	List.iter (fun b -> b.def <- []) bl;
	empty_def_term_def_list def_list;
	empty_def_term t;
	empty_def_oprocess p1) l0;
      empty_def_oprocess p2
  | Output((c,tl),t',p) ->
      List.iter empty_def_term tl;
      empty_def_term t';
      empty_def_process p
  | Let(pat,t,p1,p2) ->
      empty_def_term t;
      empty_def_pattern pat;
      empty_def_oprocess p1;
      empty_def_oprocess p2
  | EventP(t,p) ->
      empty_def_term t;
      empty_def_oprocess p

(* Functions used for filtering elsefind facts *)

(* [not_deflist b elsefind] returns true when [b] does not occur
   in the "defined" conditions of [elsefind] *)

let not_deflist b (_, def_list, _) =
  not (List.exists (refers_to_br b) def_list)

(* [not_deflist_l bl elsefind] returns true when no variable in [bl] occurs
   in the "defined" conditions of [elsefind] *)

let not_deflist_l bl elsefind =
  List.for_all (fun b -> not_deflist b elsefind) bl

(* Build tree of definition dependences
   The treatment of TestE/FindE/LetE/ResE is necessary: build_def_process
   is called in check.ml.

   The value of elsefind_facts is correct only if the game has been expanded:
   the complex terms may appear only in conditions of find, and the
   variables defined there have no array accesses, so the variables defined
   in terms never have defined conditions in elsefind facts, so there is no need
   to discard elsefind facts when analyzing a term.
   Because the variables defined in terms never have array accesses,
   I won't use their elsefind facts computed here: the goal here is to know
   the elsefind facts at definition points of variables for use when
   they have array accesses, so we compute them only for processes.
   One MUST NOT use the value of elsefind_facts in check.ml.
   *)

let rec close_def_subterm accu (b,l) =
  add_binderref (b,l) accu;
  List.iter (close_def_term accu) l

and close_def_term accu t =
  match t.t_desc with
    Var(b,l) -> close_def_subterm accu (b,l)
  | FunApp(f,l) -> List.iter (close_def_term accu) l
  | _ -> Parsing_helper.input_error "if/find/let forbidden in defined conditions of find" t.t_loc

let rec def_term above_node true_facts def_vars t =
  t.t_facts <- Some (true_facts, def_vars, above_node);
  match t.t_desc with
    Var(b,l) ->
      def_term_list above_node true_facts def_vars l
  | FunApp(_,l) ->
      def_term_list above_node true_facts def_vars l
  | TestE(t1,t2,t3) ->
      let true_facts' = t1 :: true_facts in
      let true_facts'' = (make_not t1) :: true_facts in
      ignore(def_term above_node true_facts' def_vars t2);
      ignore(def_term above_node true_facts'' def_vars t3);
      def_term above_node true_facts def_vars t1
  | FindE(l0,t3,_) ->
      List.iter (fun (bl,def_list,t1,t2) ->
	let true_facts' =  t1 :: true_facts in
	let accu = ref def_vars in
	List.iter (close_def_subterm accu) def_list;
	let def_vars' = !accu in
	let above_node' = { above_node = above_node; binders = bl; 
			    true_facts_at_def = true_facts; 
			    def_vars_at_def = def_vars;
			    elsefind_facts_at_def = [];
			    future_binders = []; future_true_facts = [];
			    future_def_vars = [];
			    definition = DTerm t } 
	in
	List.iter (fun b -> b.def <- above_node' :: b.def) bl;
	let above_node'' = def_term (def_term_def_list above_node' true_facts def_vars def_list) true_facts def_vars' t1 in
	ignore(def_term above_node'' true_facts' def_vars' t2)) l0;
      ignore(def_term above_node true_facts def_vars t3);
      above_node
  | LetE(pat, t1, t2, topt) ->
      let above_node' = def_term above_node true_facts def_vars t1 in
      let accu = ref [] in
      let above_node'' = def_pattern accu above_node' true_facts def_vars pat in
      let true_facts' = ((match pat with PatVar _ -> make_let_equal | _ -> make_equal) (term_from_pat pat) t1) :: true_facts in
      let above_node''' = { above_node = above_node''; binders = !accu; 
			    true_facts_at_def = true_facts'; 
			    def_vars_at_def = def_vars;
			    elsefind_facts_at_def = [];
			    future_binders = []; future_true_facts = [];
			    future_def_vars = [];
			    definition = DTerm t } 
      in
      List.iter (fun b -> b.def <- above_node''' :: b.def) (!accu);
      ignore (def_term above_node''' true_facts' def_vars t2);
      begin
	match topt with
	  None -> ()
	| Some t3 -> ignore(def_term above_node' true_facts def_vars t3)
      end;
      above_node'
  | ResE(b, t') ->
      let above_node' = { above_node = above_node; binders = [b]; 
			  true_facts_at_def = true_facts; 
			  def_vars_at_def = def_vars;
			  elsefind_facts_at_def = [];
			  future_binders = []; future_true_facts = [];
			  future_def_vars = [];
			  definition = DTerm t } 
      in
      b.def <- above_node' :: b.def;
      def_term above_node' true_facts def_vars t'
  | EventE(t') ->
      def_term above_node true_facts def_vars t'
      

and def_term_list above_node true_facts def_vars = function
    [] -> above_node
  | (a::l) -> def_term_list (def_term above_node true_facts def_vars a) true_facts def_vars l

and def_term_def_list above_node true_facts def_vars = function
    [] -> above_node
  | (b,l)::l' -> def_term_def_list (def_term_list above_node true_facts def_vars l) true_facts def_vars l'

and def_pattern accu above_node true_facts def_vars = function
    PatVar b -> accu := b :: (!accu); above_node
  | PatTuple (f,l) -> def_pattern_list accu above_node true_facts def_vars l
  | PatEqual t -> def_term above_node true_facts def_vars t

and def_pattern_list accu above_node true_facts def_vars = function
    [] -> above_node 
  | (a::l) -> def_pattern_list accu (def_pattern accu above_node true_facts def_vars a) true_facts def_vars l

let rec def_process event_accu above_node true_facts def_vars p' =
  p'.i_facts <- Some (true_facts, def_vars, above_node);
  match p'.i_desc with
    Nil -> ()
  | Par(p1,p2) -> 
      def_process event_accu above_node true_facts def_vars p1;
      def_process event_accu above_node true_facts def_vars p2
  | Repl(b,p) ->
      let above_node' = { above_node = above_node; binders = [b]; 
			  true_facts_at_def = true_facts;
			  def_vars_at_def = def_vars;
			  elsefind_facts_at_def = [];
			  future_binders = []; future_true_facts = [];
			  future_def_vars = [];
			  definition = DInputProcess p' } 
      in
      b.def <- above_node' :: b.def;
      def_process event_accu above_node' true_facts def_vars p
  | Input((c,tl),pat,p) ->
      let above_node' = def_term_list above_node true_facts def_vars tl in
      let accu = ref [] in
      let above_node'' = def_pattern accu above_node' true_facts def_vars pat in
      (* is_find_unique uses this node to test whether two variables are defined
	 in the same input/output block, so it's important to generate this
	 node even if the pattern pat defines no variable. *)
      let above_node''' = { above_node = above_node''; binders = !accu; 
			    true_facts_at_def = true_facts; 
			    def_vars_at_def = def_vars;
			    elsefind_facts_at_def = [];
			    future_binders = []; future_true_facts = [];
			    future_def_vars = [];
			    definition = DInputProcess p' } 
      in
      List.iter (fun b -> b.def <- above_node''' :: b.def) (!accu);
      let (fut_binders, fut_true_facts, fut_def_vars) = 
	def_oprocess event_accu above_node''' true_facts def_vars [] p
      in
      above_node'''.future_binders <- fut_binders;
      above_node'''.future_true_facts <- fut_true_facts;
      above_node'''.future_def_vars <- fut_def_vars

and def_oprocess event_accu above_node true_facts def_vars elsefind_facts p' =
  p'.p_facts <- Some (true_facts, def_vars, above_node);
  match p'.p_desc with
    Yield -> 
      ([],[],[])
  | Restr(b,p) ->
      let elsefind_facts' = List.filter (not_deflist b) elsefind_facts in
      let above_node' = { above_node = above_node; binders = [b]; 
			  true_facts_at_def = true_facts; 
			  def_vars_at_def = def_vars;
			  elsefind_facts_at_def = elsefind_facts;
			  future_binders = []; future_true_facts = [];
			  future_def_vars = [];
			  definition = DProcess p' } 
      in
      b.def <- above_node' :: b.def;
      let (fut_binders, fut_true_facts, fut_def_vars) = 
	def_oprocess event_accu above_node' true_facts def_vars elsefind_facts' p
      in
      above_node'.future_binders <- fut_binders;
      above_node'.future_true_facts <- fut_true_facts;
      above_node'.future_def_vars <- fut_def_vars;
      (b::fut_binders, fut_true_facts, fut_def_vars)
  | Test(t,p1,p2) ->
      let above_node' = def_term above_node true_facts def_vars t in
      let true_facts' = t :: true_facts in
      let true_facts'' = (make_not t) :: true_facts in
      let (fut_binders1, fut_true_facts1, fut_def_vars1) = 
	def_oprocess event_accu above_node' true_facts' def_vars elsefind_facts p1
      in
      let (fut_binders2, fut_true_facts2, fut_def_vars2) = 
	def_oprocess event_accu above_node' true_facts'' def_vars elsefind_facts p2
      in
      (intersect (==) fut_binders1 fut_binders2, 
       intersect equal_terms fut_true_facts1 fut_true_facts2,
       intersect equal_binderref fut_def_vars1 fut_def_vars2)
  | Find(l0,p2,_) ->
      let l0_conds = List.map (fun (bl,def_list,t1,_) -> (bl,def_list,t1)) l0 in
      let l0_elsefind = List.filter (function (_,_,{ t_desc = Var _ | FunApp _}) -> true | _ -> false) l0_conds in 
      let elsefind_facts' = l0_elsefind @ elsefind_facts in
      let (fut_binders2, fut_true_facts2, fut_def_vars2) = 
	def_oprocess event_accu above_node true_facts def_vars elsefind_facts' p2
      in
      let rec find_l = function
	  [] -> (fut_binders2, fut_true_facts2, fut_def_vars2)
	| (bl,def_list,t,p1)::l ->
	    let (fut_bindersl, fut_true_factsl, fut_def_varsl) = find_l l in
	    let elsefind_facts'' = List.filter (not_deflist_l bl) elsefind_facts in
	    let true_facts' = t :: true_facts in
	    let accu = ref [] in
	    List.iter (close_def_subterm accu) def_list;
	    let def_vars' = (!accu) @ def_vars in
	    let above_node' = { above_node = above_node; binders = bl; 
				true_facts_at_def = true_facts; 
				def_vars_at_def = def_vars;
				elsefind_facts_at_def = elsefind_facts;
				future_binders = []; future_true_facts = [];
				future_def_vars = [];
				definition = DProcess p' } 
	    in
	    List.iter (fun b -> b.def <- above_node' :: b.def) bl;
	    let above_node'' = def_term (def_term_def_list above_node' true_facts def_vars def_list) true_facts def_vars' t in
	    let (fut_binders1, fut_true_facts1, fut_def_vars1) = 
	      def_oprocess event_accu above_node'' true_facts' def_vars' elsefind_facts'' p1
	    in
	    above_node'.future_binders <- fut_binders1;
	    above_node'.future_true_facts <- t :: fut_true_facts1;
	    above_node'.future_def_vars <- (!accu) @ fut_def_vars1;
	    (intersect (==) (bl @ fut_binders1) fut_bindersl,
	     intersect equal_terms (t::fut_true_facts1) fut_true_factsl,
	     intersect equal_binderref ((!accu) @ fut_def_vars1) fut_def_varsl)
      in
      find_l l0
  | Output((c,tl),t',p) ->
      let above_node' = def_term_list above_node true_facts def_vars  tl in
      let above_node'' = def_term above_node' true_facts def_vars t' in
      def_process event_accu above_node'' true_facts def_vars p;
      ([],[],[])
  | Let(pat,t,p1,p2) ->
      let above_node' = def_term above_node true_facts def_vars t in
      let accu = ref [] in
      let above_node'' = def_pattern accu above_node' true_facts def_vars pat in
      let new_fact = (match pat with PatVar _ -> make_let_equal | _ -> make_equal) (term_from_pat pat) t in
      let true_facts' = new_fact :: true_facts in
      let elsefind_facts' = List.filter (not_deflist_l (!accu)) elsefind_facts in
      let above_node''' = { above_node = above_node''; binders = !accu; 
			    true_facts_at_def = true_facts'; 
			    def_vars_at_def = def_vars;
			    elsefind_facts_at_def = elsefind_facts;
			    future_binders = []; future_true_facts = [];
			    future_def_vars = [];
			    definition = DProcess p' } 
      in
      List.iter (fun b -> b.def <- above_node''' :: b.def) (!accu);
      let (fut_binders1, fut_true_facts1, fut_def_vars1) = 
	def_oprocess event_accu above_node''' true_facts' def_vars elsefind_facts' p1
      in
      above_node'''.future_binders <- fut_binders1;
      above_node'''.future_true_facts <- fut_true_facts1;
      above_node'''.future_def_vars <- fut_def_vars1;
      begin
	match pat, p2.p_desc with
	  PatVar _, Yield -> 
	    ((!accu) @ fut_binders1, new_fact :: fut_true_facts1, fut_def_vars1)
	| _ -> 
	    let (fut_binders2, fut_true_facts2, fut_def_vars2) = 
	      def_oprocess event_accu above_node' true_facts def_vars elsefind_facts p2
	    in
	    (intersect (==) ((!accu) @ fut_binders1) fut_binders2,
	     intersect equal_terms (new_fact :: fut_true_facts1) fut_true_facts2,
	     intersect equal_binderref fut_def_vars1 fut_def_vars2)
      end
  | EventP(t,p) ->
      begin
	match event_accu with
	  None -> ()
	| Some accu -> accu := (t, Some (true_facts, def_vars, above_node)) :: (!accu)
      end;
      let above_node' = def_term above_node true_facts def_vars t in
      let (fut_binders, fut_true_facts, fut_def_vars) = 
	def_oprocess event_accu above_node' (t :: true_facts) def_vars elsefind_facts p
      in
      (fut_binders, t::fut_true_facts, fut_def_vars)

let build_def_process event_accu p =
  empty_def_process p;
  let rec st_node = { above_node = st_node; 
		      binders = []; 
		      true_facts_at_def = []; 
		      def_vars_at_def = []; 
		      elsefind_facts_at_def = [];
		      future_binders = []; future_true_facts = [];
		      future_def_vars = [];
		      definition = DNone } 
  in
  def_process event_accu st_node [] [] p

(* Add to [accu] the variables defined above the node [n] *)

let rec add_def_vars_node accu n =
  let accu' = n.binders @ accu in
  if n.above_node != n then
    add_def_vars_node accu' n.above_node
  else
    accu'


(* array_ref_* stores in the binders the kind of accesses made to the binder:
    - b.count_def: number of definitions of the binder b
    - b.std_ref: true when b has standard references (references to b 
      in its scope with the array indices at its definition)
    - b.array_ref: true when b has array references (references to b
      outside its scope or with explicit array indices that use the value of b)
    - b.root_def_std_ref: true when b is referenced at the root of a "defined"
      condition, in its scope with the array indices at its definition.
    - b.root_def_array_ref: true when b is referenced at the root of a "defined"
      condition, in an array reference. 
      If references at the root of defined conditions are the only ones, 
      the definition point of b is important, but not its value.

   It also stores the binders in all_vars, so that cleanup_array_ref
   can cleanup the binders; cleanup_array_ref should be called when
   the reference information is no longer needed.

   The treatment of TestE/FindE/LetE/ResE is necessary: array_ref_eqside
   is called in check.ml.
*)

let all_vars = ref []

let add b =
  if not (List.memq b (!all_vars)) then
    all_vars := b :: (!all_vars)

let rec array_ref_term in_scope t = 
  match t.t_desc with
    Var(b, l) -> 
      if List.for_all2 equal_terms l b.args_at_creation &&
	List.memq b in_scope then
	b.std_ref <- true
      else
	begin
	  b.array_ref <- true;
      	  b.count_array_ref <- b.count_array_ref + 1
	end;
      add b;
      List.iter (array_ref_term in_scope) l
  | FunApp(_,l) ->
      List.iter (array_ref_term in_scope)  l
  | TestE(t1,t2,t3) ->
      array_ref_term in_scope t1;
      array_ref_term in_scope t2;
      array_ref_term in_scope t3
  | LetE(pat, t1, t2, topt) ->
      array_ref_pattern in_scope pat;
      array_ref_term in_scope t1;
      array_ref_term (vars_from_pat in_scope pat) t2;
      begin
	match topt with
	  None -> ()
	| Some t3 -> array_ref_term in_scope t3
      end
  | FindE(l0,t3,_) ->
      List.iter (fun (bl,def_list, t1,t2) ->
	List.iter (fun b -> b.count_def <- b.count_def + 1) bl;
	let in_scope' = bl @ in_scope in
	array_ref_def_list in_scope' def_list;
	array_ref_term in_scope' t1;
	array_ref_term in_scope' t2) l0;
      array_ref_term in_scope t3
  | ResE(b,t) ->
      b.count_def <- b.count_def + 1;
      array_ref_term (b::in_scope) t
  | EventE(t) ->
      array_ref_term in_scope t

and array_ref_pattern in_scope = function
    PatVar b -> b.count_def <- b.count_def + 1
  | PatTuple (f,l) -> List.iter (array_ref_pattern in_scope) l
  | PatEqual t -> array_ref_term in_scope t

and array_ref_def_list in_scope' def_list =
  List.iter (fun (b,l) -> 
    List.iter (array_ref_term in_scope') l;
    if List.for_all2 equal_terms l b.args_at_creation &&
      List.memq b in_scope' then
      b.root_def_std_ref <- true
    else
      begin
	b.root_def_array_ref <- true;
	b.count_array_ref <- b.count_array_ref + 1
      end;
    add b) def_list

let rec array_ref_process in_scope p =
  match p.i_desc with
    Nil -> ()
  | Par(p1,p2) -> 
      array_ref_process in_scope p1;
      array_ref_process in_scope p2
  | Repl(b,p) ->
      b.count_def <- b.count_def + 1;
      array_ref_process (b::in_scope) p
  | Input((_,tl),pat,p) ->
      List.iter (array_ref_term in_scope) tl;      
      array_ref_pattern in_scope pat;
      array_ref_oprocess (vars_from_pat in_scope pat) p

and array_ref_oprocess in_scope p = 
  match p.p_desc with
    Yield -> ()
  | Restr(b,p) ->
      b.count_def <- b.count_def + 1;
      array_ref_oprocess (b::in_scope) p
  | Test(t,p1,p2) ->
      array_ref_term in_scope t;      
      array_ref_oprocess in_scope p1;
      array_ref_oprocess in_scope p2
  | Find(l0,p2,_) ->
      List.iter (fun (bl,def_list,t,p1) ->
	List.iter (fun b -> b.count_def <- b.count_def + 1) bl;
	let in_scope' = bl @ in_scope in
	array_ref_def_list in_scope' def_list;
	array_ref_term in_scope' t;      
	array_ref_oprocess in_scope' p1) l0;
      array_ref_oprocess in_scope p2
  | Output((_,tl),t2,p) ->
      List.iter (array_ref_term in_scope) tl;      
      array_ref_term in_scope t2;
      array_ref_process in_scope p
  | Let(pat, t, p1, p2) ->
      array_ref_pattern in_scope pat;
      array_ref_term in_scope t;      
      array_ref_oprocess (vars_from_pat in_scope pat) p1;
      array_ref_oprocess in_scope p2
  | EventP(t,p) ->
      array_ref_term in_scope t;      
      array_ref_oprocess in_scope p

let rec array_ref_fungroup in_scope = function
    ReplRestr(repl, restr, funlist) ->
      List.iter (array_ref_fungroup (repl :: ((List.map fst restr) @ in_scope))) funlist
  | Fun(ch, args, res, priority) ->
      array_ref_term (args @ in_scope) res
      
let cleanup_array_ref() =
  List.iter (fun b ->
    b.count_def <- 0;
    b.root_def_array_ref <- false;
    b.root_def_std_ref <- false;
    b.array_ref <- false;
    b.std_ref <- false;
    b.count_array_ref <- 0;
    b.count_exclude_array_ref <- 0) (!all_vars);
  all_vars := []

let array_ref_process p =
  cleanup_array_ref();
  array_ref_process [] p

let array_ref_eqside rm =
  cleanup_array_ref();
  List.iter (fun (fg, _) -> array_ref_fungroup [] fg) rm

let has_array_ref b =
  b.root_def_array_ref || b.array_ref

(* Functions that compute count_exclude_array_ref.
   The goal is to be able to easily determine if a variable has array
   references in the game outside a certain expression.
   One first computes array references in the full game, then
   one calls exclude_array_ref_term/exclude_array_ref_def_list on the
   part to exclude. 
   b has an array reference in the remaining part iff
   b.count_array_ref > b.count_exclude_array_ref *)

let all_vars_exclude = ref []

let add_exclude b =
  if not (List.memq b (!all_vars_exclude)) then
    all_vars_exclude := b :: (!all_vars_exclude)

let rec exclude_array_ref_term in_scope t = 
  match t.t_desc with
    Var(b, l) -> 
      if not (List.for_all2 equal_terms l b.args_at_creation &&
	List.memq b in_scope) then
	begin
      	  b.count_exclude_array_ref <- b.count_exclude_array_ref + 1;
	  add_exclude b
	end;
      List.iter (exclude_array_ref_term in_scope) l
  | FunApp(_,l) ->
      List.iter (exclude_array_ref_term in_scope)  l
  | TestE(t1,t2,t3) ->
      exclude_array_ref_term in_scope t1;
      exclude_array_ref_term in_scope t2;
      exclude_array_ref_term in_scope t3
  | LetE(pat, t1, t2, topt) ->
      exclude_array_ref_pattern in_scope pat;
      exclude_array_ref_term in_scope t1;
      exclude_array_ref_term (vars_from_pat in_scope pat) t2;
      begin
	match topt with
	  None -> ()
	| Some t3 -> exclude_array_ref_term in_scope t3
      end
  | FindE(l0,t3,_) ->
      List.iter (fun (bl,def_list,t1,t2) ->
	let in_scope' = bl @ in_scope in
	exclude_array_ref_def_list in_scope' def_list;
	exclude_array_ref_term in_scope' t1;
	exclude_array_ref_term in_scope' t2) l0;
      exclude_array_ref_term in_scope t3
  | ResE(b,t) ->
      exclude_array_ref_term (b::in_scope) t
  | EventE(t) ->
      exclude_array_ref_term in_scope t

and exclude_array_ref_pattern in_scope = function
    PatVar b -> ()
  | PatTuple (f,l) -> List.iter (exclude_array_ref_pattern in_scope) l
  | PatEqual t -> exclude_array_ref_term in_scope t

and exclude_array_ref_def_list in_scope' def_list = 
  List.iter (fun (b,l) -> 
    List.iter (exclude_array_ref_term in_scope') l;
    if not (List.for_all2 equal_terms l b.args_at_creation &&
	    List.memq b in_scope') then
      begin
	b.count_exclude_array_ref <- b.count_exclude_array_ref + 1;
        add_exclude b
      end) def_list

let cleanup_exclude_array_ref() =
  List.iter (fun b ->
    b.count_exclude_array_ref <- 0) (!all_vars_exclude);
  all_vars_exclude := []

let has_array_ref_non_exclude b =
  b.count_array_ref > b.count_exclude_array_ref

(* Build list of compatible binder definitions
   i.e. pairs of binders that can be simultaneously defined with
   the same array indexes 
   Assumes that LetE/FindE/ResE/TestE occur only in conditions of find
   (which is guaranteed after expansion).
*)

(* Empty the "compatible" field of all variables. *)

let rec empty_comp_pattern = function
    PatVar b -> b.compatible <- compatible_empty
  | PatTuple (f,l) -> List.iter empty_comp_pattern l
  | PatEqual t -> ()

let rec empty_comp_term t =
  match t.t_desc with
    Var _ -> ()
  | FunApp _ -> ()
  | TestE(_,t2,t3) -> 
      empty_comp_term t2;
      empty_comp_term t3
  | FindE(l0,t3,_) ->
      List.iter (fun (bl,def_list,t1,t2) ->
	List.iter (fun b -> b.compatible <- compatible_empty) bl;
	empty_comp_term t1;
	empty_comp_term t2) l0;
      empty_comp_term t3
  | LetE(pat,t1,t2,topt) ->
      empty_comp_pattern pat;
      empty_comp_term t2;
      begin
	match topt with
	  None -> ()
	| Some t3 -> empty_comp_term t3
      end
  | ResE(b,p) ->
      b.compatible <- compatible_empty;
      empty_comp_term p
  | EventE(t) ->
      empty_comp_term t

let rec empty_comp_process p = 
  match p.i_desc with
    Nil -> ()
  | Par(p1,p2) -> 
      empty_comp_process p1;
      empty_comp_process p2
  | Repl(b,p) ->
      b.compatible <- compatible_empty;
      empty_comp_process p
  | Input((c,tl),pat,p) ->
      empty_comp_pattern pat;
      empty_comp_oprocess p

and empty_comp_oprocess p =
  match p.p_desc with
    Yield -> ()
  | Restr(b,p) ->
      b.compatible <- compatible_empty;
      empty_comp_oprocess p
  | Test(t,p1,p2) ->
      empty_comp_oprocess p1;
      empty_comp_oprocess p2
  | Find(l0,p2,_) ->
      List.iter (fun (bl,def_list,t,p1) ->
	List.iter (fun b -> b.compatible <- compatible_empty) bl;
	empty_comp_term t;
	empty_comp_oprocess p1) l0;
      empty_comp_oprocess p2
  | Output((c,tl),t',p) ->
      empty_comp_process p
  | Let(pat,t,p1,p2) ->
      empty_comp_pattern pat;
      empty_comp_oprocess p1;
      empty_comp_oprocess p2
  | EventP(t,p) ->
      empty_comp_oprocess p


let rec union l1 = function
    [] -> l1
  | (a::l) -> 
      if List.memq a l1 then union l1 l else
      a::(union l1 l)

let add_compatible l1 l2 =
  List.iter (fun a ->
    List.iter (fun b ->
      if a == b then
	Parsing_helper.internal_error "Same binder may be defined several times";
      a.compatible <- Binderset.add a.compatible b) l2) l1

let rec add_self_compatible = function
    [] -> ()
  | (a::l) -> add_compatible [a] l; add_self_compatible l

let rec compatible_def_term t = 
  match t.t_desc with
    Var(b,l) -> []
  | FunApp(f,l) -> []
  | TestE(t1,t2,t3) -> 
      let def2 = compatible_def_term t2 in
      let def3 = compatible_def_term t3 in
      union def2 def3
  | FindE(l0, t3, _) ->
      let def3 = compatible_def_term t3 in
      let accu = ref def3 in
      List.iter (fun (bl, def_list, t1, t2) ->
	(*Nothing to for def_list: it contains only
          Var and Fun*)
	let def1 = compatible_def_term t1 in
	let def2 = compatible_def_term t2 in
	add_self_compatible bl;
	add_compatible bl def1;
	add_compatible bl def2;
	add_compatible def1 def2;
	accu := union bl (union def1 (union def2 (!accu)))) l0;
      !accu
  | LetE(pat, t1, t2, topt) ->
      let accu = vars_from_pat [] pat in
      let def3 = compatible_def_term t2 in
      let def4 = match topt with
	None -> []
      |	Some t3 -> compatible_def_term t3 
      in
      add_self_compatible accu;
      add_compatible accu def3;
      union accu (union def3 def4)
  | ResE(b,t) ->
      let def = compatible_def_term t in
      add_compatible def [b];
      union def [b]
  | EventE(t) ->
      compatible_def_term t

let rec compatible_def_process p =
  match p.i_desc with
    Nil -> []
  | Par(p1,p2) ->
      let def1 = compatible_def_process p1 in
      let def2 = compatible_def_process p2 in
      add_compatible def1 def2;
      union def1 def2
  | Repl(b,p) ->
      let def = compatible_def_process p in
      add_compatible def [b];
      union def [b]
  | Input((c,tl),pat,p) ->
      let accu = vars_from_pat [] pat in
      let def3 = compatible_def_oprocess p in
      add_self_compatible accu;
      add_compatible accu def3;
      union accu def3

and compatible_def_oprocess p =
  match p.p_desc with
    Yield -> []
  | Restr(b, p) ->
      let def = compatible_def_oprocess p in
      add_compatible def [b];
      union def [b]
  | Test(t,p1,p2) ->
      let def2 = compatible_def_oprocess p1 in
      let def3 = compatible_def_oprocess p2 in
      union def2 def3
  | Find(l0, p2, _) ->
      let def3 = compatible_def_oprocess p2 in
      let accu = ref def3 in
      List.iter (fun (bl, def_list, t, p1) ->
	(*Nothing to do for def_list: it contains only
          Var and Fun*)
	let def1 = compatible_def_term t in
	let def2 = compatible_def_oprocess p1 in
	add_self_compatible bl;
	add_compatible bl def1;
	add_compatible bl def2;
	accu := union bl (union def1 (union def2 (!accu)))) l0;
      !accu
  | Output((c,tl),t2,p) ->
      compatible_def_process p
  | Let(pat,t,p1,p2) ->
      let accu = vars_from_pat [] pat in
      let def3 = compatible_def_oprocess p1 in
      let def4 = compatible_def_oprocess p2 in
      add_self_compatible accu;
      add_compatible accu def3;
      union accu (union def3 def4)
  | EventP(t,p) ->
      compatible_def_oprocess p 

let build_compatible_defs p = 
  empty_comp_process p;
  ignore (compatible_def_process p)

let is_compatible (b,args) (b',args') =
  (b == b') || 
  (
  let l = List.length args in
  let l' = List.length args' in
  let min = if l > l' then l' else l in
  let args_skip = skip (l-min) args in
  let args_skip' = skip (l'-min) args' in
  (not (List.for_all2 equal_terms args_skip args_skip')) ||
  (Binderset.mem b'.compatible b) || 
  (Binderset.mem b.compatible b')
      )

