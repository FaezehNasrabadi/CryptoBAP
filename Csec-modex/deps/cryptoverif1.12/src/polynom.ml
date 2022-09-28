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

(* 1. Operations on polynoms *)

type monomial =
    (probaf * int) list

type polynom =
    (float * monomial) list

let zero = []

let rec display_list f = function
    [] -> ()
  | [a] -> f a
  | (a::l) -> f a; print_string ", ";
      display_list f l

let display_action = function
    AFunApp f -> 
      begin
	match f.f_cat with
	  Tuple -> 
	    print_string "(";
	    display_list (fun t -> print_string t.tname) (fst f.f_type);
	    print_string ")"
	| LetEqual | Equal | Diff ->
	    print_string f.f_name;
	    print_string " ";
	    print_string (List.hd (fst f.f_type)).tname
	| _ -> print_string f.f_name
      end
  | APatFunApp f -> 
      begin
	match f.f_cat with
	  Tuple -> 
	    print_string "let (";
	    display_list (fun t -> print_string t.tname) (fst f.f_type);
	    print_string ")"	      
	| _ -> print_string ("let " ^ f.f_name)
      end
  | AReplIndex -> print_string "!"
  | AArrayAccess n -> print_string ("[" ^ (string_of_int n) ^ "]")
  | ANew t -> print_string ("new " ^ t.tname)
  | ANewChannel -> print_string "newChannel"
  | AIf -> print_string "if"
  | AFind n -> print_string ("find " ^ (string_of_int n))
  | AOut (tl,t) -> 
      print_string "out ";
      if tl != [] then
	begin
	  print_string "[";
	  display_list (fun t -> print_string t.tname) tl;
	  print_string "] "
	end;
      print_string t.tname
  | AIn n -> print_string ("in " ^ (string_of_int n))

let rec display_proba = function
    Proba(p,l) -> 
      print_string p.prname;
      if l != [] then
	  print_string "(...)"
  | Count p -> print_string p.pname
  | OCount c -> print_string "#"; print_string c.cname
  | Add(x,y) -> 
      print_string "(";
      display_proba x;
      print_string " + ";
      display_proba y;
      print_string ")"
  | Sub(x,y) -> 
      print_string "(";
      display_proba x;
      print_string " - ";
      display_proba y;
      print_string ")"
  | Max(l) -> 
      print_string "max(";
      display_list display_proba l;
      print_string ")"
  | Mul(x,y) ->
      print_string "(";
      display_proba x;
      print_string " * ";
      display_proba y;
      print_string ")"
  | Zero -> print_string "0"      
  | Cst n -> print_float n
  | Div(x,y) ->
      print_string "(";
      display_proba x;
      print_string " / ";
      display_proba y;
      print_string ")"
  | Card t ->
      print_string "|";
      print_string t.tname;
      print_string "|"
  | AttTime ->
      print_string "time"
  | Time(g,t) ->
      begin
	print_string "time(game ";
	print_int g.game_number;
	print_string ")"
      end
  | ActTime(act, pl) ->
      print_string "time(";
      display_action act;
      if pl != [] then
	begin
	  print_string ", ";
	  display_list display_proba pl
	end;
      print_string ")"
  | Maxlength(n,t) ->
      print_string "maxlength(...)"
  | TypeMaxlength(ty) ->
      print_string ("maxlength(" ^ ty.tname ^ ")")
  | Length(f,pl) ->
      print_string "length(";
      begin
	match f.f_cat with
	  Tuple -> 
	    print_string "(";
	    display_list (fun t -> print_string t.tname) (fst f.f_type);
	    print_string ")"	      
	| _ -> print_string f.f_name
      end;
      if pl != [] then
	begin
	  print_string ", ";
	  display_list display_proba pl
	end;
      print_string ")"

let rec display_monomial = function
    (coef, []) -> print_float coef
  | (coef, (elem, n)::l) -> display_monomial (coef, l);
      print_string " * "; display_proba elem; print_string " ^ "; print_int n

let rec display_polynom = function
    [] -> print_string "0"
  | [a] -> display_monomial a
  | (a::l) -> display_monomial a; print_string " + "; display_polynom l

let equal_factor (p,n) (p',n') = (n==n') && (Terms.equal_probaf p p')

let rec remove_factor f = function
    [] -> raise Not_found
  | (a::l) -> if equal_factor f a then l else a::(remove_factor f l)

let same_monomial m1 m2 =
  let m2ref = ref m2 in
  try 
    List.iter (fun f -> m2ref := remove_factor f (!m2ref)) m1;
    (!m2ref) = []
  with Not_found -> false

let rec find_monomial m = function
    [] -> raise Not_found
  | (((coef,a) as x)::l) -> 
      if same_monomial a m then (coef,l) else 
      let (coef',l') = find_monomial m l in
      (coef',x::l')

let rec sum p1 = function
    [] -> p1
  | ((coef,a)::l) ->
      try
	let (coef',l') = find_monomial a p1 in
	(coef+.coef',a)::(sum l' l)
      with Not_found ->
	(coef,a)::(sum p1 l)

let max_float a b =
  if a > b then a else b

let rec max p1 = function
    [] -> p1
  | ((coef,a)::l) ->
      try
	let (coef',l') = find_monomial a p1 in
	(max_float coef coef',a)::(max l' l)
      with Not_found ->
	(coef,a)::(max p1 l)

let rec sub p1 = function
    [] -> p1
  | ((coef,a)::l) ->
      try
	let (coef',l') = find_monomial a p1 in
	(coef'-.coef,a)::(sub l' l)
      with Not_found ->
	(0.-.coef,a)::(sub p1 l)

let rec product_monomial m1 = function
    [] -> m1
  | (e,n)::l -> 
      try
	let n' = List.assoc e m1 in
	(e,n + n')::(product_monomial (remove_factor (e,n') m1) l)
      with Not_found ->
	(e,n)::(product_monomial m1 l)

let rec product_pol_monomial (coef,a) = function
    [] -> []
  | ((coef',a')::l) -> 
      sum [coef *. coef', product_monomial a a'] (product_pol_monomial (coef,a) l)

let rec product p1 = function
    [] -> []
  | (a::l) -> sum (product_pol_monomial a p1) (product p1 l)


(* 2. Basic operations on probabilities, with simple simplifications *) 

let p_div(x,y) =
  match x,y with
    Zero, _ | Cst 0.0, _ -> Zero
  | Cst x', Cst y' -> if y' <> 0.0 then Cst (x' /. y') else Div(x,y)
  | _, Cst 1.0 -> x
  | _ -> Div(x,y)

let p_mul(x,y) =
  match x,y with
    Zero, _ | _, Zero | Cst 0.0, _ | _, Cst 0.0 -> Zero
  | Cst 1.0, a -> a
  | a, Cst 1.0 -> a
  | _ -> Mul(x,y)

let rec p_prod = function
  [] -> Cst 1.0
| [a] -> a
| (a::l) -> p_mul(a, p_prod l)

let p_add(x,y) =
  match x,y with
    Zero, a | a, Zero | Cst 0.0, a | a, Cst 0.0 -> a
  | _ -> Add(x,y)
  
let rec p_sum = function
  [] -> Zero
| [a] -> a
| (a::l) -> p_add(a, p_sum l)

(* 3.1 Conversion probaf_to_polynom *)

let rec probaf_to_polynom = function
    Zero -> []
  | Cst n -> [n,[]]
  | Mul(f1,f2) -> product (probaf_to_polynom f1) (probaf_to_polynom f2)
  | Add(f1,f2) -> sum (probaf_to_polynom f1) (probaf_to_polynom f2)
  | Sub(f1,f2) -> sub (probaf_to_polynom f1) (probaf_to_polynom f2)
  | Div(Cst 1.0, Mul(x,y)) -> probaf_to_polynom (Mul(Div(Cst 1.0, x), Div(Cst 1.0, y)))
  | Div(Cst 1.0, _) as prob -> [1.0,[prob,1]]
  | Div(f1,f2) -> probaf_to_polynom (Mul(f1, Div(Cst 1.0, f2)))
  | prob -> [1.0,[prob,1]]


(* 3.2 Conversion polynom_to_probaf *)

let rec factor_to_probaf (a,n) =
  if n < 1 then
    Parsing_helper.internal_error "not a polynomial in factor_to_probaf" 
  else if n = 1 then
    a 
  else 
    Mul(a,factor_to_probaf (a,n-1))

let rec factor_to_list (a,n) =
  if n < 1 then
    Parsing_helper.internal_error "not a polynomial in factor_to_probaf" 
  else if n = 1 then
    [a] 
  else 
    a :: (factor_to_list (a,n-1))

type monomial_decomp =
    { small_factors : probaf;
      large_factors : probaf list;
      denominator : probaf list }

let rec split_monomial = function
    [] -> { small_factors = Cst 1.0;
	    large_factors = [];
	    denominator = [] }
  | ((a,n) as f)::r ->
      let r' = split_monomial r in
      match a with
	Count _ | OCount _  -> 
	  let l = factor_to_probaf f in
	  { r' with small_factors = p_mul (l, r'.small_factors) }
      |	Div(Cst 1.0, x) -> 
	  let l = factor_to_list (x,n) in
	  { r' with denominator = l @ r'.denominator }
      |	Add _ | Mul _ | Sub _ | Div _ | Zero | Cst _ ->
	  Parsing_helper.internal_error "Should have been removed when generating polynoms"
      |	_ ->
	  let l = factor_to_list f in
	  { r' with large_factors = l @ r'.large_factors }
	  
let split_coef_monomial (coef, a) =
  let r = split_monomial a in
  { r with small_factors = p_mul(Cst coef, r.small_factors) }

let rec remove_eq_probaf a = function
    [] -> raise Not_found
  | (b::r) ->
      if Terms.equal_probaf a b then r else b::(remove_eq_probaf a r)

let rec equal_prod l1 l2 =
  match l2 with
    [] -> l1 == []
  | (a::r) ->
      try
	let l1' = remove_eq_probaf a l1 in
	equal_prod l1' r
      with Not_found -> false

let same_large_factors r r' =
  (equal_prod r.large_factors r'.large_factors) &&
  (equal_prod r.denominator r'.denominator)

let rec add_decomp r = function
    [] -> [r]
  | (a::l) ->
      if same_large_factors r a then
	{ a with small_factors = p_add(a.small_factors, r.small_factors) }::l
      else
	a::(add_decomp r l)

let rec polynom_to_monomial_decomp = function
    [] -> []
  | coef_a::r ->
      let split_coef_a = split_coef_monomial coef_a in
      let decomp_r = polynom_to_monomial_decomp r in
      add_decomp split_coef_a decomp_r


let monomial_decomp_to_probaf l =
  p_sum (List.map (fun a -> p_div(p_mul(a.small_factors, p_prod a.large_factors), p_prod a.denominator)) l)

let polynom_to_probaf x =
  monomial_decomp_to_probaf (polynom_to_monomial_decomp x)
