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

let display_occurrences = ref false

let display_arrays = ref false

let max_game_number = ref 1

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

(* Verifying that a variable name does not end with _nnn is necessary
to make sure that there cannot be confusions between b.sname = XXX_nnn,
b.vname = 0 and b.sname = XXX, b.vname = nnn. 
With this test, when the displayed name is XXX_nnn, then 
b.vname = nnn, b.sname = XXX (XXX must be non-empty).
Otherwise, b.vname = 0, b.sname = the displayed name. *)

let ends_with_underscore_number s =
  let l = String.length s in
  '0' <= s.[l-1] && s.[l-1] <= '9' &&
  (let rec underscore_number n = (n > 0) &&
    ((s.[n] = '_') || ('0' <= s.[n] && s.[n] <= '9' && underscore_number (n-1)))
  in
  underscore_number (l-2))

let binder_to_string b =
  if (b.vname != 0) || (ends_with_underscore_number b.sname) then 
    b.sname ^ "_" ^ (string_of_int b.vname)
  else
    b.sname

let display_binder b =
  print_string (binder_to_string b)
  
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
      print_string " <= ";
      print_string n.pname
  | _ -> 
      print_string ": ";
      print_string b.btype.tname

and display_findcond cur_array (def_list, t1) =
  let cond_printed = ref false in
  if def_list != [] then
    begin
      print_string "defined(";
      display_list (fun (b,tl) -> display_var cur_array b tl) def_list;
      print_string ")";
      cond_printed := true
    end;
  if !cond_printed then
    begin
      if not (Terms.is_true t1) then
	begin
	  print_string " && ";
	  display_term cur_array t1
	end
    end
  else
    display_term cur_array t1

and display_term cur_array t = 
  if !display_occurrences then
    begin
      print_string "{";
      print_int t.t_occ;
      print_string "}"
    end;
  match t.t_desc with
    Var(b,tl) -> display_var cur_array b tl
  | FunApp(f,l) ->
      begin
	match f.f_cat with
	  Std | Tuple | Event -> 
	    print_string f.f_name;
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
		print_string (" " ^ f.f_name ^ " ");
		display_term cur_array t2;
		print_string ")"
	    | _ -> Parsing_helper.internal_error "Infix operators need two arguments (display)"
      end
  | TestE(t1,t2,t3) ->
      print_string "if ";
      display_term cur_array t1;
      print_string " then ";
      display_term cur_array t2;
      print_string " else ";
      display_term cur_array t3
  | FindE([([],def_list,t1,t2)],t3,find_info) ->
      print_string "if ";
      display_findcond cur_array (def_list,t1);
      print_string " then ";
      display_term cur_array t2;
      print_string " else ";
      display_term cur_array t3
  | FindE(l0, t3, find_info) ->
      let first = ref true in
      print_string "find ";
      List.iter (fun (bl, def_list, t1, t2) ->
	if !first then
	  first := false
	else
	  print_string " orfind ";
	display_list display_binder_with_type bl;
	print_string " suchthat ";
	display_findcond cur_array (def_list, t1);
	print_string " then ";
	display_term cur_array t2) l0;
      print_string " else ";
      display_term cur_array t3      
  | LetE(pat, t1, t2, topt) ->
      begin
	match pat with
	  PatVar b when (!Settings.front_end) == Settings.Oracles ->
	    display_binder_with_type b;
	    print_string " <- ";
	    display_term cur_array t1;
	    print_string "; ";	    
	| _ ->
	    print_string "let ";
	    display_pattern cur_array pat;
	    print_string " = ";
	    display_term cur_array t1;
	    print_string " in "
      end;
      begin
	display_term cur_array t2;
	match topt with
	  None -> ()
	| Some t3 ->
	    print_string " else ";
	    display_term cur_array t3      
      end
  | ResE(b,t) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  display_binder_with_array b;
	  print_string " <-R ";
	  print_string b.btype.tname
	end
      else
	begin
	  print_string "new ";
	  display_binder_with_type b
	end;
      print_string "; ";
      display_term cur_array t
  | EventE(t) ->
      print_string "event ";
      display_term cur_array t
      
(* Patterns *)

and display_pattern cur_array = function
    PatVar b ->
      display_binder_with_type b
  | PatTuple (f,l) ->
      print_string f.f_name;
      print_string "(";
      display_list (display_pattern cur_array) l;
      print_string ")"
  | PatEqual t ->
      print_string "=";
      display_term cur_array t

(* Statements *)

let display_statement (bl, t) =
  print_string "forall ";
  display_list display_binder_with_type bl;
  print_string "; ";
  display_term [] t;
  print_newline()

(* Equivalences *)

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
  | AReplIndex -> 
      if (!Settings.front_end) == Settings.Oracles then
	print_string "foreach"
      else
	print_string "!"
  | AArrayAccess n -> print_string ("[" ^ (string_of_int n) ^ "]")
  | ANew t -> 
      if (!Settings.front_end) == Settings.Oracles then
	print_string ("<-R " ^ t.tname)
      else
	print_string ("new " ^ t.tname)
  | ANewChannel -> 
      if (!Settings.front_end) == Settings.Oracles then
	print_string "newOracle"
      else
	print_string "newChannel"
  | AIf -> print_string "if"
  | AFind n -> print_string ("find " ^ (string_of_int n))
  | AOut (tl,t) -> 
      if (!Settings.front_end) == Settings.Oracles then
	Parsing_helper.internal_error "out action should not occur in oracles front-end";
      print_string "out ";
      if tl != [] then
	begin
	  print_string "[";
	  display_list (fun t -> print_string t.tname) tl;
	  print_string "] "
	end;
      print_string t.tname
  | AIn n -> 
      if (!Settings.front_end) == Settings.Oracles then
	Parsing_helper.internal_error "in action should not occur in oracles front-end";
      print_string ("in " ^ (string_of_int n))

let times_to_display = ref []

let rec display_proba level = function
    Proba(p,l) -> 
      print_string p.prname;
      if l != [] then
	begin
	  print_string "(";
	  display_list (display_proba 0) l;
	  print_string ")"
	end
  | Count p -> print_string p.pname
  | OCount c -> print_string "#"; print_string c.cname
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
      print_string "max(";
      display_list (display_proba 0) l;
      print_string ")"
  | Mul(x,y) ->
      if level > 3 then print_string "(";
      display_proba 3 x;
      print_string " * ";
      display_proba 3 y;
      if level > 3 then print_string ")"
  | Zero -> print_string "0"      
  | Cst n -> print_float n
  | Div(x,y) ->
      if level > 3 then print_string "(";
      display_proba 3 x;
      print_string " / ";
      display_proba 4 y;
      if level > 3 then print_string ")"
  | Card t ->
      print_string "|";
      print_string t.tname;
      print_string "|"
  | AttTime ->
	print_string "time"
  | Time(g,t)->
	begin
	  print_string "time(context for game ";
	  print_int g.game_number;
	  print_string ")";
	  try
	    ignore (List.assq g (!times_to_display))
	  with Not_found -> 
	    times_to_display := (g,t)::(!times_to_display)
	end
  | ActTime(act, pl) ->
      print_string "time(";
      display_action act;
      if pl != [] then
	begin
	  print_string ", ";
	  display_list (display_proba 0) pl
	end;
      print_string ")"
  | Maxlength(g,t) ->
      print_string "maxlength(";
      if g.game_number>=0 then
	begin
	  print_string "game ";
	  print_int g.game_number;
	  print_string ": "
	end;
      display_term [] t;
      print_string ")"
  | TypeMaxlength(ty) ->
      print_string "maxlength(";
      print_string ty.tname;
      print_string ")"
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
	  display_list (display_proba 0) pl
	end;
      print_string ")"

let display_one_set = function
    SetProba r ->
      display_proba 0 r.proba;
  | SetEvent(f, g) ->
      print_string "Pr[event ";
      print_string f.f_name;
      print_string " in game ";
      print_int g.game_number;
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
      print_string "{";
      print_int t.t_occ;
      print_string "}"
    end;
  match t.t_desc with
    Var _ | FunApp _ ->
      print_string "return(";
      display_term cur_array t;
      print_string ")"
  | TestE(t1,t2,t3) ->
      print_string "if ";
      display_term cur_array t1;
      print_string " then ";
      display_procasterm cur_array t2;
      print_string " else ";
      display_procasterm cur_array t3
  | FindE([([],def_list,t1,t2)],t3,find_info) ->
      print_string "if ";
      display_findcond cur_array (def_list,t1);
      print_string " then ";
      display_procasterm cur_array t2;
      print_string " else ";
      display_procasterm cur_array t3
  | FindE(l0, t3, find_info) ->
      let first = ref true in
      print_string "find ";
      List.iter (fun (bl, def_list, t1, t2) ->
	if !first then
	  first := false
	else
	  print_string " orfind ";
	display_list display_binder_with_type bl;
	print_string " suchthat ";
	display_findcond cur_array (def_list, t1);
	print_string " then ";
	display_procasterm cur_array t2) l0;
      print_string " else ";
      display_procasterm cur_array t3      
  | LetE(pat, t1, t2, topt) ->
      begin
	match pat with
	  PatVar b when (!Settings.front_end) == Settings.Oracles ->
	    display_binder_with_type b;
	    print_string " <- ";
	    display_term cur_array t1;
	    print_string "; ";	    
	| _ ->
	    print_string "let ";
	    display_pattern cur_array pat;
	    print_string " = ";
	    display_term cur_array t1;
	    print_string " in "
      end;
      begin
	display_procasterm cur_array t2;
	match topt with
	  None -> ()
	| Some t3 ->
	    print_string " else ";
	    display_procasterm cur_array t3      
      end
  | ResE(b,t) ->
      display_binder_with_array b;
      print_string " <-R ";
      print_string b.btype.tname;
      print_string "; ";
      display_procasterm cur_array t
  | EventE(t) ->
      print_string "event ";
      display_term cur_array t
       

let rec display_fungroup indent cur_array = function
    ReplRestr(repl, restr, funlist) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string "foreach ";
	  display_binder_with_type repl;
	  print_string " do ";
	  List.iter (fun (b,opt) -> 
	    display_binder_with_array b;
	    print_string " <-R ";
	    print_string b.btype.tname;
	    if opt == Unchanged then
	      print_string " [unchanged]";
	    print_string "; ") restr
	end
      else
	begin
	  print_string "! ";
	  display_binder_with_type repl;
	  print_string " ";
	  List.iter (fun (b,opt) -> 
	    print_string "new ";
	    display_binder_with_type b;
	    if opt == Unchanged then
	      print_string " [unchanged]";
	    print_string "; ") restr
	end;
      begin
	match funlist with 
	  [f] -> 
	    display_fungroup indent ((Terms.term_from_binder repl) :: cur_array) f
	| _ -> 
	    print_string ("(\n" ^ indent);
	    let first = ref true in
	    List.iter (fun f ->
	      if !first then
		first := false
	      else
		(if (!Settings.front_end) == Settings.Oracles then
		  print_string (" |\n" ^ indent)
		else
		  print_string (",\n" ^ indent));
	      display_fungroup (indent ^ "  ") ((Terms.term_from_binder repl) :: cur_array) f;
	      ) funlist;
	    print_string ")"
      end
  | Fun(ch, args, res, (priority, options)) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string ch.cname;
	  print_string "(";
	  display_list display_binder_with_type args;
	  print_string ")";
	  if priority != 0 then
	    begin
	      print_string " [";
	      print_int priority;
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
	      print_int priority;
	      print_string "]"
	    end;
	  print_string " -> ";
	  display_term cur_array res
	end
      else
	begin
	  print_string ch.cname;
	  print_string "(";
	  display_list display_binder_with_type args;
	  print_string ")";
	  if priority != 0 then
	    begin
	      print_string " [";
	      print_int priority;
	      print_string "]"
	    end;
	  print_string " := ";
	  display_term cur_array res
	end

let display_eqmember l =
  display_list (fun (fg, mode) ->
    display_fungroup "  " [] fg;
    if mode = AllEquiv then print_string " [all]") l

let display_equiv ((m1,m2,set,opt,opt2),_) =
  print_string "equiv ";
  display_eqmember m1;
  print_newline();
  print_string "<=(";
  display_set set;
  print_string ")=>";
  begin
    match opt,opt2 with
      StdEqopt, Decisional -> ()
    | PrioEqopt n, Decisional -> print_string (" [" ^ (string_of_int n) ^ "]")
    | ManualEqopt, Decisional -> print_string " [manual]"
    | StdEqopt, Computational -> print_string " [computational]"
    | PrioEqopt n, Computational -> print_string (" [" ^ (string_of_int n) ^ "] [computational]")
    | ManualEqopt, Computational -> print_string " [manual, computational]"
  end;
  print_string "\n      ";
  display_eqmember m2;
  print_newline()

(* Processes *)

let display_channel cur_array c tl =
  print_string c.cname;
  if tl != [] then
    begin
      print_string "[";
      display_list (display_term cur_array) tl;
      print_string "]"
    end


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
      print_string "{";
      print_int p.i_occ;
      print_string "}"
    end;
  match p.i_desc with
    Nil -> 
      print_string (indent ^ "0\n")
  | Par _ -> 
      let rec dec_par p0 = 
	match p0.i_desc with
	  Par(p,p') -> (dec_par p) @ (dec_par p')
	| p -> [p0]
      in
      let l = dec_par p in
      print_string (indent^"(\n");
      let rec display_par_list = function
	  [] -> Parsing_helper.internal_error "empty list of parallel processes"
	| [p] ->
	    display_process cur_array (indent^"  ") p;
	    print_string (indent^")\n");
	| p::l ->
	    display_process cur_array (indent^"  ") p;
	    print_string (indent^") | (\n");
	    display_par_list l
      in
      display_par_list l
  | Repl(b,p) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string (indent ^ "foreach ");
	  display_binder_with_type b;
	  print_string " do"
	end
      else
	begin
	  print_string (indent ^ "! ");
	  display_binder_with_type b
	end;
      print_newline();
      display_process ((Terms.term_from_binder b)::cur_array) indent p
  | Input((c,tl),pat,p) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string (indent ^ c.cname);
	  if (!display_arrays) && (tl != []) then
	    begin
	      print_string "[";
	      display_list (display_term cur_array) tl;
	      print_string "]"
	    end;
	  display_pattern cur_array pat;
	  print_string " :=\n";
	  display_oprocess cur_array indent p
	end
      else
	begin
	  print_string (indent ^ "in(");
	  display_channel cur_array c tl;
	  print_string ", ";
	  display_pattern cur_array pat;
	  print_string ")";
	  display_optoprocess cur_array indent p
	end

and display_oprocess cur_array indent p =
  if !display_occurrences then
    begin
      print_string "{";
      print_int p.p_occ;
      print_string "}"
    end;
  match p.p_desc with
    Yield -> 
      if (!Settings.front_end) == Settings.Oracles then
	print_string (indent ^ "end\n")
      else
	print_string (indent ^ "yield\n")
  | Restr(b,p) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string indent;
	  display_binder_with_array b;
	  print_string " <-R ";
	  print_string b.btype.tname
	end
      else
	begin
	  print_string (indent ^ "new ");
	  display_binder_with_type b
	end;
      display_optoprocess cur_array indent p
  | Test(t,p1,p2) ->
      print_string (indent ^ "if ");
      display_term cur_array t;
      print_string " then\n";
      if p2.p_desc = Yield then
	display_oprocess cur_array indent p1
      else
	begin
	  display_oprocess_paren cur_array indent p1;
	  print_string (indent ^ "else\n");
	  display_oprocess cur_array (indent ^ "  ") p2
	end
  | Find([([],def_list,t,p1)],p2, find_info) ->
      print_string (indent ^ "if ");
      display_findcond cur_array (def_list,t);
      print_string " then\n";
      if p2.p_desc = Yield then
	display_oprocess cur_array indent p1
      else
	begin
	  display_oprocess_paren cur_array indent p1;
	  print_string (indent ^ "else\n");
	  display_oprocess cur_array (indent ^ "  ") p2
	end
  | Find(l0,p2, find_info) ->
      let first = ref true in
      let single_branch = (p2.p_desc = Yield) && (List.length l0 = 1) in
      print_string (indent ^ "find ");
      List.iter (fun (bl,def_list,t,p1) ->
	if !first then
	  first := false
	else
	  print_string (indent ^ "orfind ");
	display_list display_binder_with_type bl;
	print_string " suchthat ";
	display_findcond cur_array (def_list,t);
	print_string " then\n";
	if single_branch then
	  display_oprocess cur_array indent p1
	else
	  display_oprocess_paren cur_array indent p1
	  ) l0;
      if p2.p_desc != Yield then
	begin
	  print_string (indent ^ "else\n");
	  display_oprocess cur_array (indent ^ "  ") p2
	end
  | Output((c,tl),t2,p) ->
      if (!Settings.front_end) == Settings.Oracles then
	begin
	  print_string (indent ^ "return");
	  display_term cur_array t2
	end
      else
	begin
	  print_string (indent ^ "out(");
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
	    print_string " <- ";
	    display_term cur_array t;
	    display_optoprocess cur_array indent p1
	| _ ->
	    print_string (indent ^ "let ");
	    display_pattern cur_array pat;
	    print_string " = ";
	    display_term cur_array t;
	    if (p1.p_desc = Yield) && (p2.p_desc = Yield) then
	      print_string "\n"
	    else
	      begin
		print_string " in\n";
		if p2.p_desc = Yield then
		  display_oprocess cur_array indent p1
		else
		  begin
		    display_oprocess_paren cur_array indent p1;
		    print_string (indent ^ "else\n");
		    display_oprocess cur_array (indent ^ "  ") p2
		  end
	      end
      end
  | EventP(t,p) ->
      print_string (indent ^ "event ");
      display_term cur_array t;
      display_optoprocess cur_array indent p

and display_optprocess cur_array indent p =
  if p.i_desc = Nil then 
    print_string "\n"
  else
    begin
      print_string ";\n";
      display_process cur_array indent p
    end
      
and display_optoprocess cur_array indent p =
  if p.p_desc = Yield then 
    print_string "\n"
  else
    begin
      print_string ";\n";
      display_oprocess cur_array indent p
    end

and display_oprocess_paren cur_array indent p =
  if may_have_elseo p then
    begin
      print_string (indent ^ "(\n");
      display_oprocess cur_array (indent ^ "  ") p;
      print_string (indent ^ ")\n")
    end
  else
    display_oprocess cur_array (indent ^ "  ") p


let display_process p =
  display_process [] "" p;
  print_newline()
	
(* Instructions *)

let display_rem_set = function
    All -> print_string "all binders"
  | OneBinder b -> 
      print_string "binder ";
      display_binder b
  | SubstOneBinder(b,o) -> 
      print_string "binder ";
      display_binder b;
      print_string " at "; print_int o
  | Minimal -> 
      print_string "useless"

let display_move_set = function
    MAll -> print_string "all binders"
  | MNoArrayRef -> print_string "binders without array references"
  | MNew -> print_string "all new's"
  | MNewNoArrayRef -> print_string "new's without array references"
  | MLet -> print_string "all let's"
  | MOneBinder b -> 
      print_string "binder ";
      display_binder b

let display_bl_assoc bl_assoc =
  display_list display_binder bl_assoc

let rec display_query1 = function
    [] -> Parsing_helper.internal_error "List should not be empty"
  | [b,t] -> 
      if b then print_string "inj:";
      display_term [] t
  | (b,t)::l ->
      if b then print_string "inj:";
      display_term [] t;
      print_string " && ";
      display_query1 l

let rec display_query2 = function
    QEvent(b,t) ->
      if b then print_string "inj:";
      display_term [] t
  | QTerm t ->
      display_term [] t
  | QOr(t1,t2) ->
      print_string "(";
      display_query2 t1;
      print_string "||";
      display_query2 t2;
      print_string ")"
  | QAnd(t1,t2) ->
      print_string "(";
      display_query2 t1;
      print_string "&&";
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
	  QSecret1 b -> print_string "one-session secrecy of "; display_binder b
	| QSecret b -> print_string "secrecy of "; display_binder b
	| AbsentQuery -> Parsing_helper.internal_error "AbsentQuery should have been handled"
	| QEventQ(t1,t2) -> 
	    print_string "event ";
	    display_query1 t1; 
	    print_string " ==> ";
	    display_query2 t2
      end;
      if g.game_number <> 1 then
	print_string (" in game " ^ (string_of_int g.game_number))  

let display_instruct = function
    ExpandIfFind -> print_string "expand if, let, find"
  | Simplify [] -> print_string "simplify"
  | Simplify l -> 
      print_string "simplify with collision elimination at ";
      display_list print_string l
  | MoveNewLet s -> print_string "move "; display_move_set s
  | RemoveAssign r -> print_string "remove assignments of "; display_rem_set r
  | SArenaming b -> 
      print_string "SA rename ";
      display_binder b
  | CryptoTransf(e, bl_assoc) -> 
      print_string "equivalence\n";
      display_equiv e;
      if bl_assoc != [] then
	begin
	  print_string "with ";
	  display_bl_assoc bl_assoc
	end
  | InsertEvent(s,occ) ->
      print_string ("insert event " ^ s ^ " at occurrence " ^ (string_of_int occ))
  | InsertInstruct(s,ext_s,occ,ext_o) ->
      print_string ("insert instruction " ^ s ^ " at occurrence " ^ (string_of_int occ))
  | ReplaceTerm(s,ext_s,occ,ext_o) ->
      print_string ("replace term at occurrence " ^ (string_of_int occ) ^ " with " ^ s)
  | MergeArrays(bll, m) ->
      print_string "merge variables ";
      display_list (fun bl -> 
	print_string "("; 
	display_list (fun (b,_) -> display_binder b) bl;
	print_string ")") bll;
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
	    print_string " up to probability ";
	    display_set set
	  end) ql
      

let proba_table = ref []

let rec build_proba_table s =
  match s.prev_state with
    None -> ()
  | Some(Proof ql, _, s') ->
      build_proba_table s';
      List.iter (fun ((_, g) as q, p) -> 
	if not (List.exists (fun (q', _) -> q' == q) (!proba_table)) then
	  proba_table := (q, (p, s')) :: (!proba_table)
	) ql
  | Some (_,_,s') ->
      build_proba_table s' 

exception NotBoundEvent of funsymb * game

type query_specif =
    InitQuery 
  | QEvent of funsymb

let equal_qs (qs1,g1) (qs2,g2) =
  (g1 == g2) && (match qs1,qs2 with
    InitQuery, InitQuery -> true
  | QEvent f1, QEvent f2 -> f1 == f2
  | _ -> false)

(* A proof tree is a tree in which
   - nodes are games (field pt_game below) 
   - edges correspond to game transformations. These edges are labelled with
       * i: instruct, the instruction performed to obtain the son from the current game
       * p: setf list, the probability difference
       * pt_son: proof_tree, the obtained son
       * ql: (query_specif * game) list ref, the list of properties proved by going through the
         considered edge.
   We have a tree and not just a list of games, because events may be introduced by Shoup's lemma,
   and proved later to have negligible probability, so we may need to prove several properties
   at once. Moreover, these properties may be proved using different sequences of games, thus
   leading to a tree.
   The last edge (the one that proves a property) already deals with a single property.
   Other edges may be shared between the proofs of several properties. *)

type proof_tree =
    { pt_game : game;
      mutable pt_sons : (instruct * setf list * proof_tree * (query_specif * game) list ref) list }

(* For debugging *)

let rec display_proof_tree indent pt =
  print_string (indent ^ "Game " ^ (string_of_int pt.pt_game.game_number) ^"\n");
  let display_son indent_next (i, p, pt_son, ql) =
    begin
      match i with
	CryptoTransf(((_,_,_,_,Decisional),_),_) -> print_string (indent ^ "- Decisional step\n")
      |	_ -> print_string (indent ^ "- Computational step\n")
    end;
    print_string (indent ^ "- Probability: ");
    display_set p;
    print_newline();
    print_string (indent ^ "- Properties to prove: ");
    display_list (function
	(InitQuery, _) -> print_string "Initial query"
      |	(QEvent f, g) -> print_string "Event "; print_string f.f_name; 
	  print_string " in game "; print_int g.game_number) (!ql);
    print_newline();    
    display_proof_tree indent_next pt_son
  in
  match pt.pt_sons with
    [] -> print_string (indent ^ "No son\n") 
  | [s] -> 
      print_string (indent ^ "Son:\n"); 
      display_son indent s
  | _ ->
      print_string (indent ^ "Sons:\n");
      List.iter (display_son (indent ^ "  ")) pt.pt_sons

(* Build the proof tree *)

let build_proof_tree ((_,g0) as q) p s =
  let pt_init = { pt_game = g0;
		  pt_sons = [] }
  in
  let proof_tree_table = ref [(g0, pt_init)] in
  (* We need to ignore "Proof" steps because they do not change the game at all
     (the game is physically the same), which causes bugs if we don't ignore 
     this step *)
  let rec father_ignore_proof s =
    match s.prev_state with
      None -> None
    | Some(Proof _,p,s') ->
	if p != [] then Parsing_helper.internal_error "Proof steps should have 0 probability";
	father_ignore_proof s'
    | x -> x
  in
  (* Add a new query [q] in the list of proved properties, in a part of the proof tree that is
     already built *)
  let rec add_query q pt_cur s =
    if s.game == snd q then () else 
    match father_ignore_proof s with
      None -> ()
    | Some (i,p,s') ->
	try
	  let pt_father = List.assq s'.game (!proof_tree_table) in
	  let (_,_,_,queries) = List.find (fun (_,_,pt,_) -> pt == pt_cur) pt_father.pt_sons in
	  if not (List.exists (equal_qs q) (!queries)) then
	    queries := q :: (!queries);
	  add_query q pt_father s'
	with Not_found ->
	  Parsing_helper.internal_error "This game should always be found"
  in
  (* Build the proof tree for state [s], proving property [q]. [sons_to_add] is a list
     of sons (edges, in fact) to add to the proof corresponding to state [s]. 
     [sons_to_add] is either an empty list (when [s] is the last state, the one that proves [q]),
     or a list containing one element (the next step in the proof of [q]). *)
  let rec build_pt_rec sons_to_add q s =
    try
      let pt_cur = List.assq s.game (!proof_tree_table) in
      pt_cur.pt_sons <- sons_to_add @ pt_cur.pt_sons;
      (* print_string ("Found " ^ (string_of_int s.game.game_number) ^ "; adding sons ");
      display_list (fun (_,_,pt,_) -> print_int pt.pt_game.game_number) sons_to_add;
      print_newline(); *)
      add_query q pt_cur s
    with Not_found ->
      let pt_cur = { pt_game = s.game;
		     pt_sons = sons_to_add }
      in
      proof_tree_table := (s.game, pt_cur) :: (!proof_tree_table);
      (* print_string ("Added game " ^ (string_of_int s.game.game_number) ^ " with sons ");
      display_list (fun (_,_,pt,_) -> print_int pt.pt_game.game_number) sons_to_add;
      print_newline(); *)
      match father_ignore_proof s with
	None -> Parsing_helper.internal_error "Initial game should already have been entered in the proof tree"
      |	Some(i,p,s) ->
	  build_pt_rec [(i,p,pt_cur, ref [q])] q s;
	  List.iter (function 
	      SetProba _ -> ()
	    | SetEvent(f,g) ->
		let (q',(p',s')) =
		  (* Get the proof of the property "Event f is not executed in game g" *)
		  try
		    List.find (function
			((QEventQ([false, { t_desc = FunApp(f',[{ t_desc = FunApp(f_tuple, []) }]) }], QTerm t_false),g'),_) -> 
			  g == g' && f == f' && Terms.is_false t_false
		      | _ -> false ) (!proba_table)
		  with Not_found -> raise (NotBoundEvent(f,g))
		in
		let sons_to_add =
		  let pt_final_event_f_in_g = { pt_game = { proc = Terms.nil_proc; 
							    game_number = -1 } (* dummy_game *);
						pt_sons = [] }
		  in
		  [(Proof [q',p'], p', pt_final_event_f_in_g, ref[QEvent f, g])]
		in
		build_pt_rec sons_to_add (QEvent f, g) s'
		  ) p
  in
  let sons_to_add =
    let pt_final_proof = { pt_game = { proc = Terms.nil_proc; 
				       game_number = -1 } (* dummy_game *);
			   pt_sons = [] }
    in
    [(Proof [q,p], p, pt_final_proof, ref [InitQuery, g0])]
  in
  build_pt_rec sons_to_add (InitQuery,g0) s;
  pt_init

let rec evaluate_proba double ql pt =
  (* Sanity check: all elements of ql must occur in some edge in pt *)
  List.iter (fun qs -> 
    if not (List.exists (fun (_,_,_,ql_ref) -> 
      List.exists (equal_qs qs) (!ql_ref)
	) pt.pt_sons) then
      Parsing_helper.internal_error "Missing property in evaluate_proba"
	) ql;
  (* Sanity check: the ql_ref are disjoint *)
  let check_disjoint (_,_,_,ql_ref1) (_,_,_,ql_ref2) =
    if List.exists (fun qs1 -> List.exists (equal_qs qs1) (!ql_ref2)) (!ql_ref1) then
      Parsing_helper.internal_error "ql_ref not disjoint"
  in
  let rec check_disjoint_l pt1 = function
      [] -> ()
    | (pt2::r) -> check_disjoint pt1 pt2; check_disjoint_l pt1 r
  in
  let rec check_disjoint_ll = function
      [] -> ()
    | (pt1::ptl) -> check_disjoint_l pt1 ptl; check_disjoint_ll ptl
  in
  check_disjoint_ll pt.pt_sons;
  (* Check if a son immediately proves the initial secrecy query
     If yes, we never need to double probabilities: in case we prove
     secrecy, the events proved after proving the initial secrecy query,
     are independent of the secrecy event, which allows us to apply
     a factor 1/2 to them, which compensates for the later doubling. *)
  let sons_proves_initial_query =
    List.exists (fun (i,p,pt_son,ql_ref) ->
      match i with
	Proof [((QSecret _ | QSecret1 _),_),_] -> true
      |	_ -> false
	    ) pt.pt_sons
  in
  let double = if sons_proves_initial_query then false else double in
  (* Take into account tree branching (several sons): split ql according to what
     each son proves *)
  List.concat (List.map (fun (i,p,pt_son,ql_ref) ->
    let ql' = List.filter (fun qs -> List.exists (equal_qs qs) ql) (!ql_ref) in
    let rec compute_full_query_list = function
	[] -> ql'
      |	(SetProba _)::l -> compute_full_query_list l
      |	(SetEvent(f,g))::l -> (QEvent f, g) :: (compute_full_query_list l)
    in
    (* One transformation can consist of an arbitrary syntactic or cryptographic
       transformation, that follows a series of event insertions (Shoup lemma).
       In practice, the transformation is either:
       - an event insertion alone
       - or a cryptographic transformation with an event insertion (DDH).
         The event insertion is indeed done before DDH.
       - or a transformation without event insertion. *)
    let ql'' = compute_full_query_list p in
    let proba_p = List.filter (function SetProba _ -> true | SetEvent _ -> false) p in
    match i with
      Proof pl ->
	(* The desired property is proved *)
	begin
	  match pl,ql' with
	    [q,_],[q'] -> if double then proba_p @ proba_p else proba_p
	  | _ -> Parsing_helper.internal_error "unexpected Proof element in proof tree"
	end
    | _ -> 
	(* We consider the whole set of queries ql' at once, 
	   and avoid counting several times the same events. *)
	(if double then proba_p @ proba_p else proba_p) @ 
	(evaluate_proba double ql'' pt_son)
    ) pt.pt_sons)

let compute_proba ((_,g) as q) p s =
  let pt = build_proof_tree q p s in
  (* display_proof_tree "" pt; *)
  let double =
    match q with
      ((QSecret _ | QSecret1 _),_) -> true
    | _ -> false
  in
  evaluate_proba double [InitQuery, g] pt  
  
let rec proba_since g s =
  if g == s.game then
    []
  else
    match s.prev_state with
      None -> Parsing_helper.internal_error "Game not found."
    | Some (i,p,s') -> (proba_since g s') @ p
	
let rec subst l =
  List.concat (*Terms.union_setf*) (List.map (function 
      SetProba r -> [SetProba r]
    | SetEvent(f,g) -> 
	try
	  subst   
	    (let (q,(p,s')) = List.find (function
		((QEventQ([false, { t_desc = FunApp(f',[{ t_desc = FunApp(f_tuple, []) }]) }], QTerm t_false),g'),_) -> 
		  g == g' && f == f' && Terms.is_false t_false
	      | _ -> false ) (!proba_table)
	    in
	    (proba_since g s') @ p)
	with Not_found ->
	  raise (NotBoundEvent(f,g))
	    ) l)


let rec poly_from_set = function
    [] -> Polynom.zero
  | (SetProba r)::l -> Polynom.sum (Polynom.probaf_to_polynom r.proba) (poly_from_set l)
  | _ -> Parsing_helper.internal_error "SetEvent should have been evaluated"

let proba_from_set s =
  Polynom.polynom_to_probaf (poly_from_set s)

let proba_from_set_may_double (q,g) s =
  match q with
    QSecret _ | QSecret1 _ ->
      (* For secrecy, we need to double the probability *)
      let p = poly_from_set s in
      Polynom.polynom_to_probaf (Polynom.sum p p)
  | _ ->
      Polynom.polynom_to_probaf (poly_from_set s)

let rec display_state s =
  match s.prev_state with
    None -> 
      if s.game.game_number = -1 then
	begin
	  incr max_game_number;
	  s.game.game_number <- !max_game_number
	end;
      print_string "Initial state\n";
      print_string "Game "; 
      print_int s.game.game_number;
      print_string " is\n";
      display_process s.game.proc
  | Some (Proof ql, p, s') ->
      display_state s';
      print_newline();
      (* Record names of probability differences *)
      begin
	match ql with
	  [_,[SetProba r]] -> 
	    if r.set_name = "" then
	      r.set_name <- "proof " ^ (string_of_int s'.game.game_number)
	| _ -> 
	    let count = ref 0 in
	    List.iter (fun (_,p ) -> 
	      List.iter (function
		  SetProba r ->
		    incr count;
		    if r.set_name = "" then
		      r.set_name <- "proof " ^ (string_of_int s'.game.game_number) ^ "." ^ (string_of_int (!count))
		| SetEvent _ -> ()) p
		) ql
      end;
      List.iter (fun ((_,g) as q, _) -> 
	let (p,s') = List.assq q (!proba_table) in
	let p' = (proba_since g s') @ p in
	if p' != [] then
	  let has_event = List.exists (function SetEvent _ -> true | SetProba _ -> false) p' in
	  if has_event then
	    begin
	      try
		let p'' = compute_proba q p s' in
		print_string "RESULT Proved ";
		display_query q;
		print_string " up to probability ";
		display_proba 0 (proba_from_set p'');
		(* print_newline();
		print_string "Old proba = ";
		let p'' = subst p' in
		display_proba 0 (proba_from_set q p''); *)
		print_newline()		  
	      with NotBoundEvent(f,g) ->
		print_string "RESULT The probability of distinguishing the initial game from a game that\nsatisfies ";
		display_query q;
		print_string " is ";
		display_set p';
		print_newline();
		print_string "RESULT However, I could not bound the probability ";
		display_one_set (SetEvent(f,g));
		print_newline()
	    end
	  else
	    begin
	      print_string "RESULT Proved ";
	      display_query q;
	      print_string " up to probability ";
	      display_proba 0 (proba_from_set_may_double q p');
	      print_newline()
	    end
	else
	  begin
	    print_string "RESULT Proved ";
	    display_query q;
	    print_newline()
	  end
	) ql;
      if p != [] then
	Parsing_helper.internal_error "Proof step should have empty set of excluded traces"
  | Some (i,p,s') ->
      display_state s';
      print_newline();
      (* Record the game number *)
      if s.game.game_number = -1 then
	begin
	  incr max_game_number;
	  s.game.game_number <- !max_game_number
	end;
      (* Record names of probability differences *)
      begin
	match p with
	  [] -> ()
	| [SetProba r] -> 
	    if r.set_name = "" then
	      r.set_name <- "dist " ^ (string_of_int s'.game.game_number) ^ "->" ^ (string_of_int s.game.game_number)
	| l -> 
	    let count = ref 0 in
	    List.iter (function
		SetProba r ->
		  incr count;
		  if r.set_name = "" then
		    r.set_name <- "dist " ^ (string_of_int s'.game.game_number) ^ "->" ^ (string_of_int s.game.game_number) ^ "." ^ (string_of_int (!count))
	      |	SetEvent _ -> ()) p
      end;
      print_string "Applying ";
      display_instruct i;
      if p != [] then
	begin
	  print_string " [probability ";
	  display_set p;
	  print_string "]"
	end;
      print_string " yields\n\n";
      print_string "Game "; 
      print_int s.game.game_number;
      print_string " is\n";
      display_process s.game.proc

let display_state s =
  times_to_display := [];
  build_proba_table s;
  display_state s;  
  List.iter (fun (g,t) ->
    print_string "RESULT time(context for game ";
    print_int g.game_number;
    print_string ") = ";
    display_proba 0 t;
    print_newline()
    ) (List.rev (!times_to_display));
  times_to_display := []
  

