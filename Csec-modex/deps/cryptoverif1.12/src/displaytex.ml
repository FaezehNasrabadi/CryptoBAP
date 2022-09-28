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

let nice_tex = ref true

let display_occurrences = ref false

let display_arrays = ref false

let times_to_display = ref []

let file = ref stdout

let print_string s =
  output_string (!file) s

let display_string s =
  for i = 0 to String.length s - 1 do
    match s.[i] with
      '\\' -> print_string "{\\textbackslash}"
    | '&' -> print_string "\\ensuremath{\\&}"
    | '{' -> print_string "\\ensuremath{\\{}"
    | '}' -> print_string "\\ensuremath{\\}}"
    | '_' -> print_string "{\\_}"
    | '^' -> print_string "{\\string^}"
    | '#' -> print_string "\\#"
    | '$' -> print_string "\\$"
    | '%' -> print_string "\\%"
    | '@' -> print_string "{\\string@}"
    | '~' -> print_string "{\\string~}"
    | '>' -> print_string "\\ensuremath{>}"
    | '<' -> print_string "\\ensuremath{<}"
    | c -> output_char (!file) c
  done  

let print_id prefix s suffix =
  print_string prefix;
  display_string s;
  print_string suffix

let rec display_list f = function
    [] -> ()
  | [a] -> f a
  | (a::l) -> f a; print_string ", ";
      display_list f l

let rec remove_common_prefix l1 l2 = match (l1,l2) with
  (a1::l1',a2::l2') when Terms.binder_from_term a1 == Terms.binder_from_term a2 -> 
    remove_common_prefix l1' l2'
| _ -> l1

let remove_common_suffix l1 l2 =
  List.rev (remove_common_prefix (List.rev l1) (List.rev l2))

let display_type t =
  print_id "\\kwt{" t.tname "}"

let display_binder b =
  print_id "\\var{" b.sname "}";
  if (b.vname != 0) || (Display.ends_with_underscore_number b.sname) then 
    begin
      if !nice_tex then
	print_string ("_{" ^ (string_of_int b.vname) ^ "}")
      else
	print_string ("\\_" ^ (string_of_int b.vname))
    end

let rec display_var cur_array b tl =
      let tl = 
	if !display_arrays then tl else 
	remove_common_suffix tl cur_array
      in
      display_binder b;
      if tl != [] then
	begin
	  print_string "[";
	  display_list (display_term cur_array) tl;
	  print_string "]"
	end

and display_binder_with_array b =
  display_binder b;
  if (!display_arrays) && (b.args_at_creation != []) then
    begin
      print_string "[";
      display_list (display_term []) b.args_at_creation;      
      print_string "]"
    end
  
and display_binder_with_type b =
  display_binder_with_array b;
  match b.btype.tcat with
    Interv n -> 
      print_id " \\leq \\kwp{" n.pname "}"
  | _ -> 
      print_id ": \\kwt{" b.btype.tname "}"

and display_findcond cur_array (def_list, t1) =
  let cond_printed = ref false in
  if def_list != [] then
    begin
      print_string "\\kw{defined}(";
      display_list (fun (b,tl) -> display_var cur_array b tl) def_list;
      print_string ")";
      cond_printed := true
    end;
  if !cond_printed then
    begin
      if not (Terms.is_true t1) then
	begin
	  print_string (if !nice_tex then "\\wedge " else "\\ \\&\\&\\ ");
	  display_term cur_array t1
	end
    end
  else
    display_term cur_array t1

and display_term cur_array t = 
  if !display_occurrences then
    begin
      print_string "\\{";
      print_string (string_of_int t.t_occ);
      print_string "\\}"
    end;
  match t.t_desc with
    Var(b,tl) -> display_var cur_array b tl
  | FunApp(f,l) ->
      begin
	match f.f_cat with
	  Std | Tuple | Event -> 
	    print_id "\\kwf{" f.f_name "}";
	    (* Event functions have replication indexes added at first argument
               Do not display it *)
	    let l = if f.f_cat == Event then List.tl l else l in
	    if (l != []) || (f.f_cat == Tuple) then
	      begin
		print_string "(";
		display_list (display_term cur_array) l;
		print_string ")"
	      end
	| LetEqual | Equal | Diff | Or | And ->
	    match l with
	      [t1;t2] -> 
		print_string "(";
		display_term cur_array t1;
		print_string (" " ^ (match f.f_name with
		  "&&" -> if !nice_tex then "\\wedge " else "\\ \\&\\&\\ "
		| "||" -> if !nice_tex then "\\vee " else "\\ \\|\\|\\ "
		| "=" -> " = "
		| "<>" -> " \neq "
		| _ -> f.f_name) ^ " ");
		display_term cur_array t2;
		print_string ")"
	    | _ -> Parsing_helper.internal_error "Infix operators need two arguments (display)"
      end
  | TestE(t1,t2,t3) ->
      print_string "\\kw{if}\\ ";
      display_term cur_array t1;
      print_string "\\ \\kw{then}\\ ";
      display_term cur_array t2;
      print_string "\\ \\kw{else}\\ ";
      display_term cur_array t3
  | FindE([([],def_list,t1,t2)],t3, find_info) ->
      print_string "\\kw{if}\\ ";
      display_findcond cur_array (def_list, t1);
      print_string "\\ \\kw{then}\\ ";
      display_term cur_array t2;
      print_string "\\ \\kw{else}\\ ";
      display_term cur_array t3
  | FindE(l0, t3, find_info) ->
      let first = ref true in
      print_string "\\kw{find}\\ ";
      List.iter (fun (bl, def_list, t1, t2) ->
	if !first then
	  first := false
	else if !nice_tex then
	  print_string "\\ \\oplus\\ "
	else
	  print_string "\\ \\kw{orfind}\\ ";
	display_list display_binder_with_type bl;
	print_string "\\ \\kw{suchthat}\\ ";
	display_findcond cur_array (def_list, t1);
	print_string "\\ \\kw{then}\\ ";
	display_term cur_array t2;
	print_string "$\\\\\n$"  (* Should align somehow... *)) l0;
      print_string "\\ \\kw{else}\\ ";
      display_term cur_array t3      
  | LetE(pat, t1, t2, topt) ->
      begin
	match pat with
	  PatVar b when (!Settings.front_end) == Settings.Oracles ->
	    display_binder_with_type b;
	    print_string " \\store ";
	    display_term cur_array t1;
	    print_string "; ";	    
	| _ ->
	    print_string "\\kw{let}\\ ";
	    display_pattern cur_array pat;
	    print_string " = ";
	    display_term cur_array t1;
	    print_string "\\ \\kw{in}\\ "
      end;
      display_term cur_array t2;
      begin
	match topt with
	  None -> ()
	| Some t3 ->
	    print_string "\\ \\kw{else}\\ ";
	    display_term cur_array t3      
      end
  | ResE(b,t) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  display_binder_with_array b;
	  print_id " \\getR \\kwt{" b.btype.tname "}"
	end
      else
	begin
	  print_string "\\kw{new}\\ ";
	  display_binder_with_type b
	end;
      print_string ";\\ ";
      display_term cur_array t
  | EventE(t) ->
      print_string "\\kw{event}\\ ";
      display_term cur_array t
      

(* Patterns *)

and display_pattern cur_array = function
    PatVar b ->
      display_binder_with_type b
  | PatTuple (f,l) ->
      print_id "\\kwf{" f.f_name "}";
      print_string "(";
      display_list (display_pattern cur_array) l;
      print_string ")"
  | PatEqual t ->
      print_string "=";
      display_term cur_array t

(* Statements *)

let display_statement (bl, t) =
  print_string "$\\kw{forall}\\ ";
  display_list display_binder_with_type bl;
  print_string "; ";
  display_term [] t;
  print_string "$\\\\\n"

(* Equivalences *)

let display_action = function
    AFunApp f -> 
      begin
	match f.f_cat with
	  Tuple -> 
	    print_string "(";
	    display_list display_type (fst f.f_type);
	    print_string ")"	    
	| LetEqual | Equal | Diff ->
	    print_string (if f.f_cat = Diff then " \\neq " else ("\\kwf{" ^ f.f_name ^ "}"));
	    print_id " \\kwt{" (List.hd (fst f.f_type)).tname "}"
	| And -> print_string (if !nice_tex then "\\wedge " else "\\ \\&\\&\\ ")
	| Or -> print_string (if !nice_tex then "\\vee " else "\\ \\|\\|\\ ")
	| _ -> print_id "\\kwf{" f.f_name "}"
      end
  | APatFunApp f -> 
      begin
	match f.f_cat with
	  Tuple -> 
	    print_string "\\kw{let}\\ (";
	    display_list display_type (fst f.f_type);
	    print_string ")"
	| _ ->
	    print_id "\\kw{let}\\ \\kwf{" f.f_name "}"
      end
  | AReplIndex -> 
      if (!Settings.front_end) == Settings.Oracles then
	print_string "\\kw{foreach}"
      else
	print_string "!"
  | AArrayAccess n -> print_string ("[" ^ (string_of_int n) ^ "]")
  | ANew t -> 
      if (!Settings.front_end) == Settings.Oracles then
	print_string "\\getR "
      else
	print_string "\\kw{new}\\ ";
      display_type t
  | ANewChannel -> 
      if (!Settings.front_end) == Settings.Oracles then
	print_string "\\kw{newOracle}"
      else
	print_string "\\kw{newChannel}"
  | AIf -> print_string "\\kw{if}"
  | AFind n -> print_string ("\\kw{find}\\ " ^ (string_of_int n))
  | AOut (tl,t) -> 
      if (!Settings.front_end) == Settings.Oracles then
	Parsing_helper.internal_error "out action should not occur in oracles front-end";
      print_string "\\kw{out}\\ ";
      if tl != [] then
	begin
	  print_string "[";
	  display_list display_type tl;
	  print_string "]\\ "
	end;
      display_type t
  | AIn n -> 
      if (!Settings.front_end) == Settings.Oracles then
	Parsing_helper.internal_error "in action should not occur in oracles front-end";
      print_string ("\\kw{in}\\ " ^ (string_of_int n))

let rec display_proba level = function
    Proba (p,l) -> 
      print_id "\\var{" p.prname "}";
      if l != [] then
	begin
	  print_string "(";
	  display_list (display_proba 0) l;
	  print_string ")"
	end
  | Count p -> print_id "\\kwp{" p.pname "}"
  | OCount c -> print_id "\\#\\kwc{" c.cname "}"
  | Add(x,y) -> 
      if level > 1 then print_string "(";
      display_proba 1 x;
      print_string " + ";
      display_proba 1 y;
      if level > 1 then print_string ")"
  | Sub(x,y) -> 
      if level > 1 then print_string "(";
      display_proba 1 x;
      print_string " - ";
      display_proba 2 y;
      if level > 1 then print_string ")"
  | Max(l) -> 
      print_string "\\kw{max}(";
      display_list (display_proba 0) l;
      print_string ")"
  | Mul(x,y) ->
      if level > 3 then print_string "(";
      display_proba 3 x;
      print_string " \\times ";
      display_proba 3 y;
      if level > 3 then print_string ")"
  | Zero -> print_string "0"      
  | Cst n -> print_string (string_of_float n)
  | Div(x,y) ->
      if level > 3 then print_string "(";
      display_proba 3 x;
      print_string " / ";
      display_proba 4 y;
      if level > 3 then print_string ")"
  | Card t ->
      print_id "|\\kwt{" t.tname "}|"
  | AttTime ->
      print_string "\\kw{time}"
  | Time(g,t) ->
      print_string ("\\kw{time}(\\mathit{context\\ for\\ game}\\ " ^ (string_of_int g.game_number) ^ ")");
      begin
	try
	  ignore (List.assq g (!times_to_display))
	with Not_found -> 
	  times_to_display := (g,t)::(!times_to_display)
      end
  | ActTime(act, pl) ->
      print_string "\\kw{time}(";
      display_action act;
      if pl != [] then
	begin
	  print_string ", ";
	  display_list (display_proba 0) pl
	end;
      print_string ")"
  | Maxlength(g,t) ->
      print_string "\\kw{maxlength}(";
      if g.game_number>=0 then
	print_string ("\\mathit{game}\\ " ^ (string_of_int g.game_number) ^ ": ");
      display_term [] t;
      print_string ")"
  | TypeMaxlength(ty) ->
      print_id "\\kw{maxlength}(\\kwt{" ty.tname "})"
  | Length(f,pl) ->
      print_string "\\kw{length}(";
      begin
	match f.f_cat with
	  Tuple -> 
	    print_string "(";
	    display_list display_type (fst f.f_type);
	    print_string ")"	      
	| _ -> print_id "\\kwf{" f.f_name "}"
      end;
      if pl != [] then
	begin
	  print_string ", ";
	  display_list (display_proba 0) pl
	end;
      print_string ")"

let display_one_set = function
    SetProba r ->
      display_proba 0 r.proba
  | SetEvent(f, g) ->
      print_id "\\Pr[\\kw{event}\\ \\kwf{" f.f_name "}\\textrm{ in game }";
      print_string (string_of_int g.game_number);
      print_string "]"

let rec display_set = function
    [] -> print_string "0"
  | [a] -> display_one_set a
  | a::l -> 
      display_one_set a;
      print_string " + ";
      display_set l
  

(* Only for the oracles front-end *)

let rec display_procasterm cur_array t = 
  if !display_occurrences then
    begin
      print_string "\\{";
      print_string (string_of_int t.t_occ);
      print_string "\\}"
    end;
  match t.t_desc with
    Var _ | FunApp _ ->
      print_string "\\kw{return}(";
      display_term cur_array t;
      print_string ")"
  | TestE(t1,t2,t3) ->
      print_string "\\kw{if}\\ ";
      display_term cur_array t1;
      print_string "\\ \\kw{then}\\ ";
      display_procasterm cur_array t2;
      print_string "\\ \\kw{else}\\ ";
      display_procasterm cur_array t3
  | FindE([([],def_list,t1,t2)],t3,find_info) ->
      print_string "\\kw{if}\\ ";
      display_findcond cur_array (def_list, t1);
      print_string "\\ \\kw{then}\\ ";
      display_procasterm cur_array t2;
      print_string "\\ \\kw{else}\\ ";
      display_procasterm cur_array t3
  | FindE(l0, t3, find_info) ->
      let first = ref true in
      print_string "\\kw{find}\\ ";
      List.iter (fun (bl, def_list, t1, t2) ->
	if !first then
	  first := false
	else if !nice_tex then
	  print_string "\\ \\oplus\\ "
	else
	  print_string "\\ \\kw{orfind}\\ ";
	display_list display_binder_with_type bl;
	print_string "\\ \\kw{suchthat}\\ ";
	display_findcond cur_array (def_list, t1);
	print_string "\\ \\kw{then}\\ ";
	display_procasterm cur_array t2;
	print_string "$\\\\\n$"  (* Should align somehow... *)) l0;
      print_string "\\ \\kw{else}\\ ";
      display_procasterm cur_array t3      
  | LetE(pat, t1, t2, topt) ->
      begin
	match pat with
	  PatVar b when (!Settings.front_end) == Settings.Oracles ->
	    display_binder_with_type b;
	    print_string " \\store ";
	    display_term cur_array t1;
	    print_string "; ";	    
	| _ ->
	    print_string "\\kw{let}\\ ";
	    display_pattern cur_array pat;
	    print_string " = ";
	    display_term cur_array t1;
	    print_string "\\ \\kw{in}\\ "
      end;
      display_procasterm cur_array t2;
      begin
	match topt with
	  None -> ()
	| Some t3 ->
	    print_string "\\ \\kw{else}\\ ";
	    display_procasterm cur_array t3      
      end
  | ResE(b,t) ->
      display_binder_with_array b;
      print_id " \\getR \\kwt{" b.btype.tname "};\\ ";
      display_procasterm cur_array t
  | EventE(t) -> 
      print_string "\\kw{event}\\ ";
      display_term cur_array t
      

let rec display_fungroup indent cur_array = function
    ReplRestr(repl, restr, funlist) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string "\\kw{foreach}\\ ";
	  display_binder_with_type repl;
	  print_string "\\ \\kw{do}\\ ";
	  List.iter (fun (b,opt) -> 
	    display_binder_with_array b;
	    print_id " \\getR \\kwt{" b.btype.tname "}"; 
	    if opt = Unchanged then
	      print_string "\\ [unchanged]"; 
	    print_string ";\\ ") restr
	end
      else if !nice_tex then
	begin
	  match repl.btype.tcat with
	    Interv n -> 
	      print_id "!^{\\kwp{" n.pname "}}\\ ";
	      List.iter (fun (b,opt) -> 
		print_string "\\kw{new}\\ ";
		display_binder_with_type b;
		if opt = Unchanged then
		  print_string "\\ [unchanged]"; 
		print_string ";\\ ") restr
	  | _ -> Parsing_helper.internal_error "Interval type expected"
	end
      else
	begin
	  print_string "!\\ ";
	  display_binder_with_type repl;
	  print_string "\\ ";
	  List.iter (fun (b,opt) -> 
	    print_string "\\kw{new}\\ ";
	    display_binder_with_type b;
	    if opt = Unchanged then
	      print_string "\\ [unchanged]"; 
	    print_string ";\\ ") restr
	end;
      begin
	match funlist with 
	  [f] -> 
	    display_fungroup indent ((Terms.term_from_binder repl) :: cur_array) f
	| _ -> 
	    print_string ("($\\\\\n$" ^ indent);
	    let first = ref true in
	    List.iter (fun f ->
	      if !first then
		first := false
	      else
		(if (!Settings.front_end) == Settings.Oracles then
		  print_string ("\\ |$\\\\\n$" ^ indent)
		else
		  print_string (",$\\\\\n$" ^ indent));
	      display_fungroup (indent ^ "\\quad ") ((Terms.term_from_binder repl) :: cur_array) f;
	      ) funlist;
	    print_string ")"
      end
  | Fun(ch, args, res, (priority, options)) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_id "\\kwc{" ch.cname "}(";
	  display_list display_binder_with_type args;
	  print_string ")";
	  if priority != 0 then
	    begin
	      print_string " [";
	      print_string (string_of_int priority);
	      print_string "]"
	    end;
	  begin
	    match options with
	      StdOpt -> ()
	    | RequiredOpt -> print_string " [required]"
	  end;
	  print_string " := ";
	  display_procasterm cur_array res
	end
      else if ch.cname = "@dummy_channel" then
	begin
	  print_string "(";
	  display_list display_binder_with_type args;
	  print_string ")";
	  if priority != 0 then
	    begin
	      print_string " [";
	      print_string (string_of_int priority);
	      print_string "]"
	    end;
	  print_string "\\ \\rightarrow\\ ";
	  display_term cur_array res
	end
      else
	begin
	  print_id "\\kwc{" ch.cname "}(";
	  display_list display_binder_with_type args;
	  print_string ")";
	  if priority != 0 then
	    begin
	      print_string " [";
	      print_string (string_of_int priority);
	      print_string "]"
	    end;
	  print_string " := ";
	  display_term cur_array res
	end

let display_eqmember l =
  display_list (fun (fg, mode) ->
    display_fungroup "\\quad  " [] fg;
    if mode = AllEquiv then print_string " [all]") l

let display_equiv ((m1,m2,set,opt,opt2),_) =
  if !nice_tex then print_string "$" else print_string "$\\kw{equiv}\\ ";
  display_eqmember m1;
  print_string "$\\\\\n$";
  if !nice_tex then
    begin
      print_string "\\approx_{";
      display_set set;
      print_string "}"
    end
  else
    begin
      print_string "\\Leftarrow(";
      display_set set;
      print_string ")\\Rightarrow"
    end;
  begin
    match opt, opt2 with
      StdEqopt, Decisional -> ()
    | PrioEqopt n, Decisional -> print_string ("\\ [" ^ (string_of_int n) ^ "]")
    | ManualEqopt, Decisional -> print_string "\\ [manual]"
    | StdEqopt, Computational -> print_string "\\ [computational]"
    | PrioEqopt n, Computational -> print_string ("\\ [" ^ (string_of_int n) ^ "]\\ [computational]")
    | ManualEqopt, Computational -> print_string "\\ [manual, computational]"
  end;
  print_string "$\\\\\n$";
  if not (!nice_tex) then print_string "\\phantom{\\kw{equiv}}\\ ";
  display_eqmember m2;
  print_string "$\\\\\n"

(* Processes *)

let display_channel cur_array c tl =
  print_id "\\kwc{" c.cname "}";
  if tl != [] then
    begin
      print_string "[";
      display_list (display_term cur_array) tl;
      print_string "]"
    end
  
let rec split_par p = 
  match p.i_desc with
    Par(p1,p2) -> (split_par p1) @ (split_par p2)
  | _ -> [p]

let rec may_have_elseo p = 
  match p.p_desc with
    Yield -> false
  | Test _ | Find _ | Let _ -> true
  | Restr(_,p) | EventP(_,p) -> may_have_elseo p
  | Output(_,_,p) -> may_have_else p

and may_have_else p = 
  match p.i_desc with
    Nil | Par _ -> false (* Par always introduces parentheses; whatever
	there is inside will be surrounded by these parentheses so does not
	need further parentheses *)
  | Repl(_,p) -> may_have_else p
  | Input(_,_,p) -> may_have_elseo p

let rec display_process cur_array indent p = 
  if !display_occurrences then
    begin
      print_string "\\{";
      print_string (string_of_int p.i_occ);
      print_string "\\}"
    end;
  match p.i_desc with
    Nil -> 
      print_string (indent ^ "0$\\\\\n$")
  | Par _ ->
      let pl = split_par p in
      print_string (indent ^ "($\\\\\n$");
      let first = ref true in
      List.iter (fun pi ->
	if !first then first := false else print_string (indent ^ ") \\mid ($\\\\\n$");
	display_process cur_array (indent ^ "\\quad ") pi) pl;
      print_string (indent ^ ")$\\\\\n$")	  
  | Repl(b,p) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string (indent ^ "\\kw{foreach}\\ ");
	  display_binder_with_type b;
	  print_string "\\ \\kw{do}$\\\\\n$"
	end
      else if !nice_tex then
	begin
	  print_string (indent ^ "!^{");
	  display_binder_with_type b;
	  print_string "}$\\\\\n$"
	end
      else
	begin
	  print_string (indent ^ "!\\ ");
	  display_binder_with_type b;
	  print_string "$\\\\\n$"
	end;
      display_process ((Terms.term_from_binder b)::cur_array) indent p
  | Input((c,tl),pat,p) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_id (indent ^ "\\kwc{") c.cname "}";
	  if (!display_arrays) && (tl != []) then
	    begin
	      print_string "[";
	      display_list (display_term cur_array) tl;
	      print_string "]"
	    end;
	  display_pattern cur_array pat;
	  print_string " :=$\\\\\n$";
	  display_oprocess cur_array indent p
	end
      else if !nice_tex then
	begin
	  print_string (indent ^ "\\cinput{");
	  display_channel cur_array c tl;
	  print_string "}{";
	  begin
	    match pat with
	      PatTuple(f,l) when f.f_cat == Tuple ->
		display_list (display_pattern cur_array) l
	    | _ -> display_pattern cur_array pat
	  end;
	  print_string "}";
	  display_optoprocess cur_array indent p
	end
      else
	begin
	  print_string (indent ^ "\\kw{in}(");
	  display_channel cur_array c tl;
	  print_string ", ";
	  display_pattern cur_array pat;
	  print_string ")";
	  display_optoprocess cur_array indent p
	end

and display_oprocess cur_array indent p = 
  if !display_occurrences then
    begin
      print_string "\\{";
      print_string (string_of_int p.p_occ);
      print_string "\\}"
    end;
  match p.p_desc with
    Yield -> 
      if (!Settings.front_end) == Settings.Oracles then
	print_string (indent ^ "\\kw{end}$\\\\\n$")
      else if !nice_tex then
	print_string (indent ^ "\\overline{0}$\\\\\n$")
      else
	print_string (indent ^ "\\kw{yield}$\\\\\n$")
  | Restr(b,p) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string indent;
	  display_binder_with_array b;
	  print_id " \\getR \\kwt{" b.btype.tname "}"
	end
      else
	begin
	  print_string (indent ^ "\\kw{new}\\ ");
	  display_binder_with_type b
	end;
      display_optoprocess cur_array indent p
  | Test(t,p1,p2) ->
      print_string (indent ^ "\\kw{if}\\ ");
      display_term cur_array t;
      print_string "\\ \\kw{then}$\\\\\n$";
      if p2.p_desc = Yield then
	display_oprocess cur_array indent p1
      else
	begin
	  display_oprocess_paren cur_array indent p1;
	  print_string (indent ^ "\\kw{else}$\\\\\n$");
	  display_oprocess cur_array (indent ^ "\\quad ") p2
	end
  | Find([([],def_list,t,p1)],p2,find_info) ->
      print_string (indent ^ "\\kw{if}\\ ");
      display_findcond cur_array (def_list,t);
      print_string "\\ \\kw{then}$\\\\\n$";
      if p2.p_desc = Yield then
	display_oprocess cur_array indent p1
      else
	begin
	  display_oprocess_paren cur_array indent p1;
	  print_string (indent ^ "\\kw{else}$\\\\\n$");
	  display_oprocess cur_array (indent ^ "\\quad ") p2
	end
  | Find(l0,p2,find_info) ->
      let first = ref true in
      let single_branch = (p2.p_desc = Yield) && (List.length l0 = 1) in
      print_string (indent ^ "\\kw{find}\\ ");
      List.iter (fun (bl,def_list,t,p1) ->
	if !first then
	  first := false
	else if !nice_tex then
	  print_string (indent ^ "\\oplus\\ ")
	else
	  print_string (indent ^ "\\kw{orfind}\\ ");
	display_list display_binder_with_type bl;
	print_string "\\ \\kw{suchthat}\\ ";
	display_findcond cur_array (def_list,t);
	print_string "\\ \\kw{then}$\\\\\n$";
	if single_branch then
	  display_oprocess cur_array indent p1
	else
	  display_oprocess_paren cur_array indent p1
	  ) l0;
      if p2.p_desc != Yield then
	begin
	  print_string (indent ^ "\\kw{else}$\\\\\n$");
	  display_oprocess cur_array (indent ^ "\\quad ") p2
	end
  | Output((c,tl),t2,p) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string (indent ^ "\\kw{return}");
	  display_term cur_array t2
	end
      else if !nice_tex then
	begin
	  print_string (indent ^ "\\coutput{");
	  display_channel cur_array c tl;
	  print_string "}{";
	  begin
	    match t2.t_desc with
	      FunApp(f, l) when f.f_cat == Tuple ->
		display_list (display_term cur_array) l
	    | _ -> display_term cur_array t2
	  end;
	  print_string "}"
	end
      else
	begin
	  print_string (indent ^ "\\kw{out}(");
	  display_channel cur_array c tl;
	  print_string ", ";
	  display_term cur_array t2;
	  print_string ")"
	end;
      display_optprocess cur_array indent p
  | Let(pat,t,p1,p2) ->
      begin
	match pat with
	  PatVar b when (!Settings.front_end) == Settings.Oracles ->
	    print_string indent;
	    display_binder_with_type b;
	    print_string " \\store ";
	    display_term cur_array t;
	    display_optoprocess cur_array indent p1
	| _ ->
	    print_string (indent ^ "\\kw{let}\\ ");
	    display_pattern cur_array pat;
	    print_string " = ";
	    display_term cur_array t;
	    if (p1.p_desc = Yield) && (p2.p_desc = Yield) then
	      print_string "$\\\\\n$"
	    else
	      begin
		print_string "\\ \\kw{in}$\\\\\n$";
		if p2.p_desc = Yield then
		  display_oprocess cur_array indent p1
		else
		  begin
		    display_oprocess_paren cur_array indent p1;
		    print_string (indent ^ "\\kw{else}$\\\\\n$");
		    display_oprocess cur_array (indent ^ "\\quad ") p2
		  end
	      end
      end
  | EventP(t,p) ->
      print_string (indent ^ "\\kw{event}\\ ");
      display_term cur_array t;
      display_optoprocess cur_array indent p

and display_optprocess cur_array indent p =
  if p.i_desc = Nil then 
    print_string "$\\\\\n$"
  else
    begin
      print_string ";$\\\\\n$";
      display_process cur_array indent p
    end
      
and display_optoprocess cur_array indent p =
  if p.p_desc = Yield then 
    print_string "$\\\\\n$"
  else
    begin
      print_string ";$\\\\\n$";
      display_oprocess cur_array indent p
    end

and display_oprocess_paren cur_array indent p =
  if may_have_elseo p then
    begin
      print_string (indent ^ "($\\\\\n$");
      display_oprocess cur_array (indent ^ "\\quad ") p;
      print_string (indent ^ ")$\\\\\n$")
    end
  else
    display_oprocess cur_array (indent ^ "\\quad ") p

let display_process p =
  print_string "$";
  display_process [] "" p;
  print_string " $\\\\\n"
	
(* Instructions *)

let display_rem_set = function
    All -> print_string "all\\ binders"
  | OneBinder b -> 
      print_string "binder $";
      display_binder b;
      print_string "$"
  | SubstOneBinder(b,o) -> 
      print_string "binder $";
      display_binder b;
      print_string "$ at "; print_string (string_of_int o)
  | Minimal -> 
      print_string "useless"

let display_move_set = function
    MAll -> print_string "all\\ binders"
  | MNoArrayRef -> print_string "binders\\ without\\ array\\ references"
  | MNew -> print_string "all\\ new's"
  | MNewNoArrayRef -> print_string "new's\\ without\\ array\\ references"
  | MLet -> print_string "all\\ let's"
  | MOneBinder b -> 
      print_string "binder $";
      display_binder b;
      print_string "$"

let display_bl_assoc bl_assoc =
  display_list display_binder bl_assoc

let rec display_query1 = function
    [] -> Parsing_helper.internal_error "List should not be empty"
  | [b,t] -> 
      if b then print_string "\\kw{inj}:";
      display_term [] t
  | (b,t)::l ->
      if b then print_string "\\kw{inj}:";
      display_term [] t;
      print_string (if !nice_tex then " \\wedge " else "\\ \\&\\&\\ ");
      display_query1 l

let rec display_query2 = function
    QEvent(b,t) ->
      if b then print_string "\\kw{inj}:";
      display_term [] t
  | QTerm t ->
      display_term [] t
  | QOr(t1,t2) ->
      print_string "(";
      display_query2 t1;
      print_string (if !nice_tex then " \\vee " else "\\ \\|\\|\\ ");
      display_query2 t2;
      print_string ")"
  | QAnd(t1,t2) ->
      print_string "(";
      display_query2 t1;
      print_string (if !nice_tex then " \\wedge " else "\\ \\&\\&\\ ");
      display_query2 t2;
      print_string ")"

let display_query (q,g) = 
  match q with 
    AbsentQuery -> 
      if g.game_number <> 1 then
	print_string ("indistinguishability from game " ^ (string_of_int g.game_number))  
      else
	print_string "indistinguishability from the initial game"
  | _ ->
  begin
  match q with 
    QSecret1 b -> 
      print_string "one-session secrecy of $"; 
      display_binder b; 
      print_string "$"
  | QSecret b -> 
      print_string "secrecy of $"; 
      display_binder b; 
      print_string "$"
  | QEventQ(t1,t2) ->
      print_string "event $";
      display_query1 t1;
      print_string " \\Longrightarrow ";
      display_query2 t2;
      print_string "$"
  | AbsentQuery ->
      Parsing_helper.internal_error "AbsentQuery should have been handled"
  end;
  if g.game_number <> 1 then
    print_string (" in game " ^ (string_of_int g.game_number))  

let display_instruct = function
    ExpandIfFind -> print_string "expand if, let, find"
  | Simplify [] -> print_string "simplify"
  | Simplify l -> 
      print_string "simplify with collision elimination at ";
      display_list display_string l
  | MoveNewLet s -> print_string "move\\ "; display_move_set s
  | RemoveAssign r -> print_string "remove assignments of "; display_rem_set r
  | SArenaming b -> 
      print_string "SA rename $";
      display_binder b;
      print_string "$"
  | CryptoTransf(e, bl_assoc) -> 
      print_string "equivalence\\\\\n";
      display_equiv e;
      if bl_assoc != [] then 
	begin
	  print_string "with $";
	  display_bl_assoc bl_assoc;
	  print_string "$"
	end
  | InsertEvent(s,occ) ->
      print_id "insert event $\\kwf{" s "}$";
      print_string (" at occurrence " ^ (string_of_int occ))
  | InsertInstruct(s,ext_s,occ,ext_o) ->
      print_string "insert instruction ";
      display_string s; 
      print_string (" at occurrence " ^ (string_of_int occ))
  | ReplaceTerm(s,ext_s,occ,ext_o) ->
      print_string ("replace term at occurrence " ^ (string_of_int occ) ^ " with ");
      display_string s
  | MergeArrays(bll, m) ->
      print_string "merge variables $";
      display_list (fun bl -> 
	print_string "("; 
	display_list (fun (b,_) -> display_binder b) bl;
	print_string ")") bll;
      print_string "$";
      begin
	match m with
	  MNoBranchVar -> print_string " (no branch variables)"
	| MCreateBranchVar -> ()
	| MCreateBranchVarAtProc _ -> print_string " (branch variables created at given processes)"
	| MCreateBranchVarAtTerm _ -> print_string " (branch variables created at given terms)"
      end
  | MergeBranches ->
      print_string "merge branches"
  | Proof ql -> 
      print_string "proof of ";
      display_list (fun (q, set) -> 
	display_query q; 
	if set != [] then
	  begin
	    print_string " up to probability $";
	    display_set set;
	    print_string "$"
	  end) ql

let rec display_state s =
  match s.prev_state with
    None -> 
      print_string "Initial state\\\\\n";
      print_string ("Game " ^ (string_of_int s.game.game_number) ^ " is\\\\\n");
      display_process s.game.proc
  | Some (Proof ql, p, s') ->
      display_state s';
      print_string "\\\\\n";
      List.iter (fun ((_,g) as q, _) -> 
	let (p, s') = List.assq q (!Display.proba_table) in
	let p' = (Display.proba_since g s') @ p in
	if p' != [] then
	  let has_event = List.exists (function SetEvent _ -> true | SetProba _ -> false) p' in
	  if has_event then
	    begin
	      print_string "RESULT The probability of distinguishing the initial game from a game that\\\\\nsatisfies ";
	      display_query q;
	      print_string " is $";
	      display_set p';
	      print_string "$\\\\\n";
	      try
		let p'' = Display.compute_proba q p s' in
		print_string "RESULT Proved ";
		display_query q;
		print_string " up to probability $";
		display_proba 0 (Display.proba_from_set p'');
		print_string "$\\\\\n"
	      with Display.NotBoundEvent(f,g) ->
		print_string "RESULT However, I could not bound the probability $";
		display_one_set (SetEvent(f,g));
		print_string "$\\\\\n"
	    end
	  else
	    begin
	      print_string "RESULT Proved ";
	      display_query q;
	      print_string " up to probability $";
	      display_proba 0 (Display.proba_from_set_may_double q p');
	      print_string "$\\\\\n"
	    end
	else
	  begin
	    print_string "RESULT Proved ";
	    display_query q;
	    print_string "\\\\\n"
	  end
	) ql;
      if p != [] then
	Parsing_helper.internal_error "Proof step should have empty set of excluded traces"
  | Some (i,p,s') ->
      display_state s';
      print_string "\\\\\nApplying ";
      display_instruct i;
      if p != [] then
	begin
	  print_string " {}[probability $";
	  display_set p;
	  print_string "${}]{}"
	end;
      print_string " yields\\\\\n\\\\\n";
      print_string ("Game " ^ (string_of_int s.game.game_number) ^ " is\\\\\n");
      display_process s.game.proc


let display_state s =
  times_to_display := [];
  display_state s;  
  List.iter (fun (g,t) ->
    print_string ("RESULT $\\kw{time}(\\mathit{context\\ for\\ game}\\ " ^ (string_of_int g.game_number) ^ ") = ");
    display_proba 0 t;
    print_string "$\\\\\n"
    ) (List.rev (!times_to_display));
  times_to_display := []

let preamble = "
\\documentclass{article}
\\usepackage[hmargin=1in,vmargin=1in]{geometry}
\\newcommand{\\kw}[1]{\\mathbf{#1}}
\\newcommand{\\kwf}[1]{\\mathsf{#1}}
\\newcommand{\\var}[1]{\\mathit{#1}}
\\newcommand{\\kwt}[1]{\\mathit{#1}}
\\newcommand{\\kwp}[1]{\\mathit{#1}}
\\newcommand{\\kwc}[1]{\\mathit{#1}}
\\begin{document}
\\begin{tabbing}
"

let nice_tex_preamble = "
\\documentclass{article}
\\usepackage[hmargin=1in,vmargin=1in]{geometry}
\\newcommand{\\cinput}[2]{{#1}({#2})}
\\newcommand{\\coutput}[2]{\\overline{#1}\\langle{#2}\\rangle}
\\newcommand{\\kw}[1]{\\mathbf{#1}}
\\newcommand{\\kwf}[1]{\\mathsf{#1}}
\\newcommand{\\var}[1]{\\mathit{#1}}
\\newcommand{\\kwt}[1]{\\mathit{#1}}
\\newcommand{\\kwp}[1]{\\mathit{#1}}
\\newcommand{\\kwc}[1]{\\mathit{#1}}
\\begin{document}
\\begin{tabbing}
"

let oracles_preamble = "
\\documentclass{article}
\\usepackage[hmargin=1in,vmargin=1in]{geometry}
\\newcommand{\\store}{\\leftarrow}
\\newcommand{\\getR}{\\stackrel{R}{\\store}}
\\newcommand{\\kw}[1]{\\mathbf{#1}}
\\newcommand{\\kwf}[1]{\\mathsf{#1}}
\\newcommand{\\var}[1]{\\mathit{#1}}
\\newcommand{\\kwt}[1]{\\mathit{#1}}
\\newcommand{\\kwp}[1]{\\mathit{#1}}
\\newcommand{\\kwc}[1]{\\mathit{#1}}
\\begin{document}
\\begin{tabbing}
"

let postamble = "
\\end{tabbing}
\\end{document}
"

let start() = 
  begin
    try
      file := open_out (!Settings.tex_output)
    with Sys_error s ->
      Parsing_helper.user_error ("File error: " ^ s ^ "\n")
  end;
  if (!Settings.front_end) == Settings.Oracles then
    print_string oracles_preamble
  else if !nice_tex then
    print_string nice_tex_preamble
  else
    print_string preamble

let stop() =
  print_string postamble;
  close_out (!file)
