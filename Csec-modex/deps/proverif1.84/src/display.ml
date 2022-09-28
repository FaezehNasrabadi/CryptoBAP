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

let color_black = 30
let color_red = 31
let color_green = 32
let color_yellow = 33
let color_blue = 34
let color_magenta = 35
let color_cyan = 36
let color_white = 37

let bold = 1

let color_stack = ref []

let emit_color n = 
  print_string "\027[";
  print_int n;
  print_string "m"

let start_color n =
  if !Param.ansi_color then
    begin
      emit_color n;
      color_stack := n :: (!color_stack)
    end
  
let reset_color() = 
  if !Param.ansi_color then
    begin  
      match !color_stack with
	[] -> Parsing_helper.internal_error "Popping more colors than pushed"
      |	[n] -> emit_color 0; color_stack := []
      |	_::n::r -> emit_color n; color_stack := n::r
    end

let display_occ n =
  start_color color_green;
  print_string ("{" ^ (string_of_int n) ^ "}");
  reset_color()

let display_keyword s =
  start_color color_blue;
  print_string s;
  reset_color()

let display_connective s =
  print_string " ";
  start_color bold;
  print_string s;
  reset_color();
  print_string " "

let newline() =
  print_newline()

let varname v = v.sname ^ "_" ^ (string_of_int v.vname)

let rec display_list f sep = function
   [] -> ()
 | [a] -> f a
 | (a::l) -> f a;
             print_string sep;
             display_list f sep l

let rec display_list_connective f sep = function
   [] -> ()
 | [a] -> f a
 | (a::l) -> f a;
             display_connective sep;
             display_list_connective f sep l

let display_phase p =
  match p.p_info with
    [Attacker (n,_)] | [AttackerBin (n,_)] | [Mess (n,_)] | [MessBin (n,_)] 
  | [InputP n] | [InputPBin n] | [OutputP n] | [OutputPBin n] | [Table n] 
  | [TableBin n] -> 
      if n > 0 then 
	print_string (" in phase " ^ (string_of_int n))
  | [AttackerGuess _] -> print_string " in off-line phase"
  | _ -> ()

let display_function_name f =
  match f.f_cat with
    Tuple when f.f_name = "" -> 
      let arity = List.length (fst f.f_type) in
      if (arity = 0) || (!Param.ignore_types) then
	print_string ((string_of_int arity) ^ "-tuple")
      else
	print_string ((Terms.tl_to_string "-" (fst f.f_type)) ^ "-tuple")
  | _ -> print_string f.f_name


module DisplayFun =
  functor (Link : sig
    val follow : bool
  end) ->
    struct

      let rec term = function
	  FunApp(f,l) -> 
	    begin
	      match f.f_name with
		"=" | "&&" | "||" | "<>" ->
		  (* Infix functions *)
		  begin
		    match l with
		      [t1;t2] ->
			print_string "(";
			term t1;
			print_string " ";
			print_string f.f_name;
			print_string " ";
			term t2;
			print_string ")"
		    | _ -> Parsing_helper.internal_error "infix operators should have 2 arguments"
		  end
	      |	_ ->
	      print_string f.f_name;
              match f.f_cat with
                Name { prev_inputs_meaning = sl } ->
		  print_string "[";
		  if (sl = []) || (!Param.tulafale = 1) then term_list l else name_list l sl;
                  print_string "]"
	      | Choice -> 
                  print_string "[";
                  term_list l;
                  print_string "]"
	      | General_var -> ()
              | _ ->
                  print_string "(";
                  term_list l;
                  print_string ")"
            end
	| Var v -> 
	    if Link.follow then
	      match v.link with
		TLink t -> term t
	      | VLink b -> print_string (varname b)
	      | NoLink -> print_string (varname v)
	      | _ -> Parsing_helper.internal_error "unexpected link in display_term_with_links"
	    else
	      print_string (varname v)
(* to see links  
     ;
     match v.link with
       NoLink -> print_string "nl"
     | TLink t -> print_string "tl"
     | VLink v -> print_string "vl"
     | PGLink t -> print_string "pgl"
*)

      and term_list l = display_list term "," l

      and name_list l sl = match (l,sl) with
	[],[] -> ()
      | [a],[sa] -> 
	  if sa <> "" then
	    begin
	      print_string sa; print_string " = "
	    end;
	  term a
      | (a::l),(sa::sl) -> 
	  if sa <> "" then
	    begin
	      print_string sa; print_string " = "
	    end;
	  term a;
          print_string ",";
          name_list l sl
      |	_ -> Parsing_helper.internal_error "prev_inputs_meaning should have the same length as the arguments of the name"

let fact = function
    Pred(chann,t) ->
      print_string chann.p_name;
      if !Param.typed_frontend then print_string "(" else print_string ":";
      term_list t;
      if !Param.typed_frontend then print_string ")"
  | Out(t,l) ->
      if !Param.typed_frontend then print_string "begin(" else print_string "begin:";
      term t;
      List.iter (fun (v,t) ->
	print_string (", " ^ (varname v) ^ " = ");
	term t) l;
      if !Param.typed_frontend then print_string ")"

let simple_constra = function
    Neq(t1,t2) ->
      term t1;
      print_string " <> ";
      term t2

let rec constra_rec = function
    [] -> print_string "F"
  | [a] -> simple_constra a
  | (a::l) -> 
      simple_constra a;
      print_string " | ";
      constra_rec l

(* Collect general variables in a term, in order to display it *)

let rec collect_gen_vars accu = function
    FunApp(f, []) when f.f_cat == General_var -> 
      if not (List.memq f (!accu)) then
	accu := f :: (!accu)
  | FunApp(f,l) -> List.iter (collect_gen_vars accu) l
  | Var _ -> ()

let collect_gen_vars_constra accu constra =
  List.iter (function Neq(t1,t2) -> 
    collect_gen_vars accu t1; 
    collect_gen_vars accu t2) constra

let constra a =
  let gen_vars = ref [] in
  collect_gen_vars_constra gen_vars a;
  if (!gen_vars <> []) then
    begin
      print_string "(forall ";
      display_list (fun f -> print_string f.f_name) "," (!gen_vars);
      print_string ", "
    end;
  if List.length a > 1 then
    begin
      print_string "(";
      constra_rec a;
      print_string ")"
    end
  else
    constra_rec a;
   if (!gen_vars <> []) then
     print_string ")"

let concl upper concl tag =
  match tag with
    OutputTag occ :: _ ->
      print_string (if upper then "The message " else "the message ");
      begin
	match concl with
	  Pred({p_info = [Attacker(n,_)]} as p, [v]) ->
	    term v;
	    print_string " may be sent to the attacker";
	    display_phase p
	| Pred({p_info = [Mess(n,_)]} as p, [vc;v]) ->
	    term v;
	    print_string " may be sent on channel ";
	    term vc;
	    display_phase p
	| Pred({p_info = [AttackerBin(n,_)]} as p, [v;v']) ->
	    term v;
	    print_string " (resp. ";
	    term v';
	    print_string ") may be sent to the attacker";
	    display_phase p
	| Pred({p_info = [MessBin(n,_)]} as p, [vc;v;vc';v']) ->
	    term v;
	    print_string " may be sent on channel ";
	    term vc;
            print_string " (resp. message ";
	    term v';
	    print_string " on channel ";
	    term vc';
 	    print_string ")";
	    display_phase p
	| _ -> Parsing_helper.internal_error "Unexpected conclusion for OutputTag"
      end;
      print_string " at output ";
      display_occ occ
  | TestUnifTag occ :: _ | TestUnifTag2 occ :: _ ->
      begin
	print_string (if upper then "The attacker can make a distinguishing test at " else "the attacker can make a distinguishing test at ");
	display_occ occ
      end
  | BeginEvent(occ) :: _ ->
      print_string (if upper then "Event " else "event ");
      begin
	match concl with
	  Pred(_, [e]) ->
	    term e;
	    print_string " may be executed at ";
	    display_occ occ
	| Pred(_, [e';e]) ->
	    term e;
	    print_string " may be executed at ";
	    display_occ occ;
	    print_string " in session ";
	    term e'
	| _ -> Parsing_helper.internal_error "Unexpected conclusion for BeginEvent"
      end
  | InputPTag(occ) :: _ ->
      print_string (if upper then "An input on channel " else "an input on channel ");
      begin
	match concl with
	  Pred({p_info = [InputP(n)]} as p, [e]) ->
	    term e;
	    print_string " may be triggered at ";
	    display_occ occ;
	    display_phase p
	| Pred({p_info = [InputPBin(n)]} as p, [e;e']) ->
	    term e;
	    print_string " (resp. ";
	    term e';
	    print_string ") may be triggered at ";
	    display_occ occ;
	    display_phase p
	| _ -> Parsing_helper.internal_error "Unexpected conclusion"
      end
  | OutputPTag(occ) :: _ ->
      print_string (if upper then "An output on channel " else "an output on channel ");
      begin
	match concl with
	| Pred({p_info = [OutputP(n)]} as p, [e]) ->
	    term e;
	    print_string " may be triggered at ";
	    display_occ occ;
	    display_phase p
	|  Pred({p_info = [OutputPBin(n)]} as p, [e;e']) ->
	    term e;
	    print_string " (resp. ";
	    term e';
	    print_string ") may be triggered at ";
	    display_occ occ;
	    display_phase p
	| _ -> Parsing_helper.internal_error "Unexpected conclusion"
      end
  | InsertTag occ :: _ ->
      print_string (if upper then "The entry " else "the entry ");
      begin
	match concl with
	  Pred({p_info = [Table(n)]} as p, [v]) ->
	    term v;
	    print_string " may be inserted in a table";
	    display_phase p
	| Pred({p_info = [TableBin(n)]} as p, [v;v']) ->
	    term v;
	    print_string " (resp. ";
	    term v';
	    print_string ") may be inserted in a table";
	    display_phase p
	| _ -> Parsing_helper.internal_error "Unexpected conclusion for InsertTag"
      end;
      print_string " at output ";
      display_occ occ
  | _ -> Parsing_helper.internal_error "There should be at least one tag"

end
    

module Std = DisplayFun(struct
  let follow = false
end)

module WithLinks = DisplayFun(struct
  let follow = true
end)

let display_term = Std.term
let display_term_list = Std.term_list
let display_fact = Std.fact
let display_constra = Std.constra

let rec display_format = function
   FFunApp(f,l) -> 
     print_string f.f_name;
     begin
       match f.f_cat with
         Name { prev_inputs_meaning = sl } ->
           print_string "[";
           if (sl = []) || (!Param.tulafale = 1) then display_format_list l else display_name_list l sl;
           print_string "]"
       | _ ->
           print_string "(";
           display_format_list l;
           print_string ")"
     end
 | FVar v -> print_string (varname v)
 | FAny v -> print_string ("*" ^ (varname v))

and display_format_list l = display_list display_format "," l

and display_name_list l sl = match (l,sl) with
	[],[] -> ()
      | [a],[sa] -> 
	  if sa <> "" then
	    begin
	      print_string sa; print_string " = "
	    end;
	  display_format a
      | (a::l),(sa::sl) -> 
	  if sa <> "" then
	    begin
	      print_string sa; print_string " = "
	    end;
	  display_format a;
          print_string ",";
          display_name_list l sl
      |	_ -> Parsing_helper.internal_error "prev_inputs_meaning should have the same length as the arguments of the name (format)"


let display_fact_format (chann,t) =
  print_string chann.p_name;
  if !Param.typed_frontend then print_string "(" else print_string ":";
  display_format_list t;
  if !Param.typed_frontend then print_string ")"

let display_hyp = display_list_connective display_fact (if !Param.typed_frontend then "&&" else "&")

let display_constra_list = display_list_connective display_constra (if !Param.typed_frontend then "&&" else "&")

let display_rule (hyp, concl, hist, constra) =
  display_constra_list constra;
  if (constra != []) && (hyp != []) then
    display_connective (if !Param.typed_frontend then "&&" else "&");
  display_hyp hyp;
  if (constra != []) || (hyp != []) then
    display_connective "->";
  display_fact concl;
  newline()

(* 
   TestUnifTag(occ): given only as first tag for clauses H /\ testunif(...) -> bad (for non_interference)
   TestUnifTag2(occ): given only as first tag for clauses H /\ M<>M' -> bad (for pitranslweak)
   TestTag(occ): test, associated to no hypothesis
   InputTag(occ): input, associated with one hypothesis mess:... or attacker:...
   ReplTag(occ,_): replication, associated with one hypothesis if non_interference and with two if
                   non_interference and key_compromise == 1
   OutputTag(occ): output, used as first tag for clauses H -> mess:... or H -> attacker:...
   LetFilterFact: let suchthat, associated with one hypothesis [always followed by LetFilterTag(occ)]
   LetFilterTag(occ): let suchthat, associated with no hypothesis
   BeginEvent(occ): event, first tag for clauses H -> end:...
                    tag associated with no hypothesis
   BeginFact: event, associated with one hypothesis begin:... [always followed by BeginEvent(occ)]
   LetTag(occ): let, associated with no hypothesis

clauses H -> input:... and H -> output:... for non_interference currently 
have no tag for describing their conclusion
*)

let rec display_hyp hyp tag =
  match (hyp, tag) with
    (_::h, TestUnifTag _ :: t) | (h, TestUnifTag2 _ :: t) | (h, TestTag _ :: t) 
  | (h, LetTag _ :: t) | (h, InputPTag _ :: t) | (h, OutputPTag _ :: t) 
  | (h, OutputTag _ :: t) | (h, InsertTag _ :: t) | (h, LetFilterTag _ :: t)
  | (h, BeginEvent _ :: t) ->
      display_hyp h t
  | (h, ReplTag _ :: t) ->
      if !Param.non_interference then
	if !Param.key_compromise == 1 then
	  match h with
	    _::_::h' -> display_hyp h' t
	  | _ -> Parsing_helper.internal_error "2 hypotheses should be added for a replication for non_interference, key_compromise = 1"
	else
	  match h with
	    _::h' -> display_hyp h' t
	  | _ -> Parsing_helper.internal_error "At least one hypothesis should be added for a replication for non_interference"
      else
	display_hyp h t
  | (m::h,InputTag occ :: t) ->
      display_hyp h t;
      begin
	match m with
	  Pred({p_info = [Attacker(n,_)]} as p, [v]) ->
	    print_string "the message ";
	    display_term v;
	    print_string " is received from the attacker";
	    display_phase p;
	    print_string " at input ";
	    display_occ occ
	| Pred({p_info = [Mess(n,_)]} as p, [vc;v]) ->
	    print_string "the message ";
	    display_term v;
	    print_string " is received on channel ";
	    display_term vc;
	    display_phase p;
	    print_string " at input ";
	    display_occ occ
	| Pred({p_info = [AttackerBin(n,_)]} as p, [v;v']) ->
	    print_string "the message ";
	    display_term v;
	    print_string " (resp. ";
	    display_term v';
	    print_string ") is received from the attacker";
	    display_phase p;
	    print_string " at input ";
	    display_occ occ
	| Pred({p_info = [MessBin(n,_)]} as p, [vc;v;vc';v']) ->
	    print_string "the message ";
	    display_term v;
	    print_string " is received on channel ";
	    display_term vc;
            print_string " (resp. message ";
	    display_term v';
	    print_string " on channel ";
	    display_term vc';
 	    print_string ")";
	    display_phase p;
	    print_string " at input ";
	    display_occ occ
	| _ -> Parsing_helper.internal_error "Unexpected hypothesis for InputTag"
      end;
      print_string ",";
      newline()
  | (m::h, LetFilterFact :: LetFilterTag(occ) :: t) ->
      display_hyp h t;
      display_fact m;
      print_string " is true at ";
      display_occ occ;
      print_string ",";
      newline()
  | (Out(e,_) ::h, BeginFact :: BeginEvent(occ) :: t) ->
      display_hyp h t;
      print_string "event ";
      display_term e;
      print_string " is executed at ";
      display_occ occ;
      print_string ",";
      newline()
  | (m::h,GetTag occ :: t) ->
      display_hyp h t;
      begin
	match m with
	  Pred({p_info = [Table(n)]} as p, [v]) ->
	    print_string "the entry ";
	    display_term v;
	    print_string " is in a table";
	    display_phase p;
	    print_string " at get ";
	    display_occ occ
	| Pred({p_info = [TableBin(n)]} as p, [v;v']) ->
	    print_string "the entry ";
	    display_term v;
	    print_string " (resp. ";
	    display_term v';
	    print_string ") is in a table";
	    display_phase p;
	    print_string " at get ";
	    display_occ occ
	| _ -> Parsing_helper.internal_error "Unexpected hypothesis for GetTag"
      end;
      print_string ",";
      newline()
  | ([],[]) -> ()
  | _ -> Parsing_helper.internal_error "Unexpected hypothesis"

let rec empty_hyp hyp tags =
  match hyp, tags with
    (_::h, TestUnifTag _ :: t) | (h, TestUnifTag2 _ :: t) | (h, TestTag _ :: t) 
  | (h, LetTag _ :: t) | (h, InputPTag _ :: t) | (h, OutputPTag _ :: t) 
  | (h, OutputTag _ :: t) | (h, LetFilterTag _ :: t) | (h, InsertTag _ :: t) 
  | (h, BeginEvent _ :: t) -> empty_hyp h t
  | (h, ReplTag _ :: t) ->
      if !Param.non_interference then
	if !Param.key_compromise == 1 then
	  match h with
	    _::_::h' -> empty_hyp h' t
	  | _ -> Parsing_helper.internal_error "2 hypotheses should be added for a replication for non_interference, key_compromise = 1"
	else
	  match h with
	    _::h' -> empty_hyp h' t
	  | _ -> Parsing_helper.internal_error "At least one hypothesis should be added for a replication for non_interference"
      else
	empty_hyp h t
  | [], _ -> true
  | _ -> false

let display_rule_num ((hyp,concl,hist,constra) as rule) =
  match hist with
    Rule (n,lbl,_,_,_) -> 
      print_string ("Rule " ^ (string_of_int n) ^ ": ");
      display_rule rule;
      if !Param.verbose_explain_clauses = Param.ExplainedClauses then
	begin
	  start_color color_magenta;
	  begin
	  match lbl with
	    Rn _ -> print_string "(The attacker can create new names.)"
	  | Init -> print_string "(Initial knowledge of the attacker.)"
	  | PhaseChange -> print_string "(Knowledge is communicated from one phase to the next.)"
	  | TblPhaseChange -> print_string "(Tables are communicated from one phase to the next.)"
	  | Apply(Func(f),p) ->
	      print_string "(The attacker applies function ";
	      display_function_name f;
	      display_phase p;
	      print_string ".)"
	  | Apply(Proj(f,n),p) ->
	      print_string ("(The attacker applies the " ^ (string_of_int n) ^ "th inverse of function ");
	      display_function_name f;
	      display_phase p;
	      print_string ".)"
	  | TestApply(Func(f),p) ->
	      print_string "(The attacker tests whether ";
	      display_function_name f;
	      print_string " is applicable";
	      display_phase p;
	      print_string ".)"
	  | TestApply(Proj(f,n),p) ->
	      print_string "(The attacker tests whether an inverse of function ";
	      display_function_name f;
	      print_string " is applicable";
	      display_phase p;
	      print_string ".)"
	  | TestEq(p) ->
	      print_string "(The attacker tests equality";
	      display_phase p;
	      print_string ".)"
	  | Rl(p,p') ->
	      print_string "(The attacker can listen on all channels it has";
	      display_phase p;
	      print_string ".)"
	  | Rs(p,p') ->
	      print_string "(The attacker can send messages it has on all channels it has";
	      display_phase p;
	      print_string ".)"
	  | Ri(p,p') ->
	      print_string "(The attacker can input on all channels it has";
	      display_phase p;
	      print_string ".)"
	  | Ro(p,p') ->
	      print_string "(The attacker can output on all channels it has";
	      display_phase p;
	      print_string ".)"
	  | TestComm(p,p') ->
	      print_string "(If an input and an output are done";
	      display_phase p;
	      print_string ", then the attacker may know whether the communication succeeds.)"
	  | InputSecr p ->
	      print_string "(If an input on the secret is done";
	      display_phase p;
	      print_string ", then the attacker may know whether the secret is a name.)"
	  | OutputSecr p ->
	      print_string "(If an output on the secret is done";
	      display_phase p;
	      print_string ", then the attacker may know whether the secret is a name.)"
	  | WeakSecr ->
	      print_string "(The attacker has the weak secret in the first component, a guess in the second.)"
	  | Elem(pl,p) -> ()
	  | TestUnif ->
	      print_string "(The attacker can test whether these terms unify.)"
	  | ProcessRule(tags, _) | ProcessRule2(tags, _, _) -> 
	      if empty_hyp hyp tags && constra == [] then
		begin
		  print_string "(";
		  Std.concl true concl tags;
		  print_string ".)"
		end
	      else
		begin
		  print_string "(If ";
		  display_hyp hyp tags;
		  if constra != [] then
		    begin
		      display_constra_list constra;
		      newline()
		    end;
		  print_string "then ";
		  Std.concl false concl tags;
		  print_string ".)";
		end
	  | LblEquiv ->
	      print_string "(This clause comes from a <-> or <=> declaration in the input file.)"
	  | LblClause ->
	      print_string "(This clause is given in the input file.)"
	  | LblEq ->
	      print_string "(Definition of equal.)"
	  | LblComp -> 
	      print_string "(The attacker has all names created in the compromised sessions.)"
	  | LblNone -> ()
	  end;
	  reset_color();
	  newline();
	  newline()
	end
  | _ -> display_rule rule

let display_eq (leq, req) =
   display_term leq;
   print_string " = ";
   display_term req;
   newline()

let display_red f l =
  List.iter (fun (leq, req) ->
    display_term (FunApp(f,leq));
    print_string " => ";
    display_term req;
    newline()) l

(* Display functions by Xavier Allamigeon and Bruno Blanchet *)

let rec display_term2 = function
    FunApp(f,l) -> 
      begin
	match f.f_cat with
          Name _ -> print_string f.f_name
	| Choice -> 
	    begin
	      match l with
		[t1;t2] ->
		  if Terms.equal_terms t1 t2 then 
		    display_term2 t1
		  else
		    begin
		      print_string "choice[";
		      display_term_list2 l;
		      print_string "]"
		    end
	      | _ -> Parsing_helper.internal_error "Choice expects 2 arguments"
	    end
	| _ ->
	    match f.f_name with
	      "=" | "&&" | "||" | "<>" ->
		(* Infix functions *)
		begin
		  match l with
		    [t1;t2] ->
		      print_string "(";
		      display_term2 t1;
		      print_string " ";
		      print_string f.f_name;
		      print_string " ";
		      display_term2 t2;
		      print_string ")"
		  | _ -> Parsing_helper.internal_error "infix operators should have 2 arguments"
		end
	    | _ ->
		print_string f.f_name;
		print_string "(";
		display_term_list2 l;
		print_string ")"
      end
  | Var v -> print_string (varname v)

and display_term_list2 l = display_list display_term2 "," l


let rec display_pattern = function
  | PatVar b -> 
      print_string (varname b);
      if !Param.typed_frontend then
	print_string (": " ^ b.btype.tname)
  | PatTuple (f,l) -> 
      print_string f.f_name;
      print_string "(";
      display_pattern_list l;
      print_string ")";
  | PatEqual t ->
      print_string "=";
      display_term2 t

and display_pattern_list = function
  | [] -> ()
  | [h] -> display_pattern h
  | h::t -> 
      display_pattern h;
      print_string ",";
      display_pattern_list t
	
let display_fact2 = function
    Pred(chann,t) ->
      print_string chann.p_name;
      if !Param.typed_frontend then print_string "(" else print_string ":";
      display_term_list2 t;
      if !Param.typed_frontend then print_string ")"
  | Out(t,l) ->
      if !Param.typed_frontend then print_string "begin(" else print_string "begin:";
      display_term2 t;
      List.iter (fun (v,t) -> 
	print_string (", " ^ (varname v) ^ " = ");
	display_term2 t
	  ) l;
      if !Param.typed_frontend then print_string ")"

let display_proc show_occ align proc =
  let display_occ occ =
    if show_occ then display_occ occ
  in
  let rec display_process align proc = 
    match proc with
    | Nil -> 
	print_string align;
	display_keyword "0";
	newline()
    | Par _ -> 
	let rec dec_par = function
	    Par(p,p') -> (dec_par p) @ (dec_par p')
	  | p -> [p]
	in
	let l = dec_par proc in
	print_string (align^"(");
	newline();
	let rec display_par_list = function
	    [] -> Parsing_helper.internal_error "empty list of parallel processes"
	  | [p] ->
	      display_process (align^"    ") p;
	      print_string (align^")");
	      newline()
	  | p::l ->
	      display_process (align^"    ") p;
	      print_string (align^") | (");
	      newline();
	      display_par_list l
	in
	display_par_list l
    | Repl (p,occ) -> 
	print_string align;
	display_occ occ;
	display_keyword "!";
	newline();
	display_process align p
    | Restr (f, p) ->
	print_string align;
	display_keyword "new";
	print_string (" "^f.f_name);
	if !Param.typed_frontend then
	  print_string (": " ^ (snd f.f_type).tname);
	print_string ";";
	newline();
	display_process align p
    | Test (t, t', p, p',occ) ->
	print_string align;
	display_occ occ;
	display_keyword "if";
	print_string " ";
	display_term2 t;
	print_string " = ";
	display_term2 t';
	print_string " ";
        display_keyword "then";
	newline();
	if (p' != Nil) then 
	  begin
	    print_string align;
	    print_string "(";
	    newline();
	    display_process (align^"    ") p;
	    print_string align;
	    print_string ")";
	    newline();
	    print_string align;
	    display_keyword "else";
	    newline();
	    print_string align;
	    print_string "(";
	    newline();
	    display_process (align^"    ") p';
	    print_string align;
	    print_string ")";
	    newline()
	  end
	else
	  display_process align p;
    | Input (t, pat, p,occ) ->
	print_string align;
	display_occ occ;
	display_keyword "in";
	print_string "(";
	display_term2 t;
	print_string ", ";
	display_pattern pat;
	print_string ");";
	newline();
	display_process align p
    | Output (t, t', p, occ) ->
	print_string align;
	display_occ occ;
	display_keyword "out";
	print_string "(";
	display_term2 t;
	print_string ", ";
	display_term2 t';
	print_string ");";
	newline();
	display_process align p
    | Let (pat, t, p, p', occ) ->
	print_string align;
	display_occ occ;
	display_keyword "let";
	print_string " ";
	display_pattern pat;
	print_string " = ";
	display_term2 t;
	print_string " ";
	display_keyword "in";
	newline();
	if (p' = Nil) then
	  display_process align p
	else 
	  begin
	    print_string align;
	    print_string "(";
	    newline();
	    display_process (align^"    ") p;
	    print_string align;
	    print_string ")";
	    newline();
	    print_string align;
	    display_keyword "else";
	    newline();
	    print_string align;
	    print_string "(";
	    newline();
	    display_process (align^"    ") p';
	    print_string align;
	    print_string ")";
	    newline()
	  end
    | Event (f,p,occ) ->
	print_string align;
	display_occ occ;
	display_keyword "event";
	print_string " ";
	display_term2 f;
	print_string ";";
	newline();
	display_process align p
    | Insert (f,p,occ) ->
	print_string align;
	display_occ occ;
	display_keyword "insert";
	print_string " ";
	display_term2 f;
	print_string ";";
	newline();
	display_process align p
    | Get(pat,t,p,occ) ->
	print_string align;
	display_occ occ;
	display_keyword "get";
	print_string " ";
	display_pattern pat;
	begin
	  match t with
	    FunApp(f,[]) when f == Terms.true_cst -> ()
	  | _ ->
	      print_string " suchthat ";
	      display_term2 t;
	end;
	print_string " ";
	display_keyword "in";
	newline();
	display_process align p
    | Phase(n,p) ->
	print_string align;
	display_keyword "phase";
	print_string (" " ^ (string_of_int n) ^ ";");
	newline();
	display_process align p
    | LetFilter(lb,f,p,q,occ) ->
	print_string align;
	display_occ occ;
	display_keyword "let";
	print_string " ";
	let first = ref true in
	List.iter (fun b -> 
	  if !first then 
	    first := false
	  else
	    print_string ", ";
	  print_string (varname b);
	  if !Param.typed_frontend then
	    print_string (": " ^ b.btype.tname)
	      ) lb;
	print_string " ";
	display_keyword "suchthat";
	print_string " ";
	display_fact2 f;
	print_string " ";
	display_keyword "in";
	newline();
	if (q <> Nil) then
	  begin
	    print_string align;
	    print_string "(";
	    newline();
	    display_process (align^"    ") p;
	    print_string align;
	    print_string ")";
	    newline();
	    print_string align;
	    display_keyword "else";
	    newline();
	    print_string align;
	    print_string "(";
	    newline();
	    display_process (align^"    ") q;
	    print_string align;
	    print_string ")";
	    newline()
	  end
	else
	  display_process align p
  in
  display_process align proc

let display_process align proc =
  display_proc false align proc

let display_process_occ align proc =
  display_proc true align proc

(* Display a query *)

let display_event = function
    QSEvent(b, t) ->
      if !Param.typed_frontend then 
	print_string (if b then "inj-event(" else "event(")
      else
	print_string (if b then "evinj:" else "ev:");
      display_term t;
      if !Param.typed_frontend then print_string ")"
  | QFact(p, tl) ->
      print_string p.p_name;
      if !Param.typed_frontend then print_string "(" else print_string ":";
      display_term_list tl;
      if !Param.typed_frontend then print_string ")"
  | QNeq(t1,t2) ->
      display_term t1;
      print_string " <> ";
      display_term t2
  | QEq(t1,t2) ->
      display_term t1;
      print_string " = ";
      display_term t2

let rec display_corresp_query = function
    Before(e, []) -> 
      print_string "not ";
      display_event e
  | Before(e, a::l) -> 
      display_event e;
      print_string " ==> ";
      display_hyp_and a;
      List.iter (fun b ->
	print_string " | ";
	display_hyp_and b) l

and display_hyp_and = function
    [] -> ()
  | (a::l) ->
	  if l != [] then print_string "(";
	  display_hyp_elem a;
	  List.iter (fun b ->
	    print_string " & ";
	    display_hyp_elem b) l;
	  if l != [] then print_string ")"
      
and display_hyp_elem = function
    QEvent e -> display_event e
  | NestedQuery q -> print_string "("; display_corresp_query q; print_string ")"

let display_corresp_putbegin_query = function
    PutBegin(b, l) ->
      print_string "putbegin ";
      if !Param.typed_frontend then 
	print_string (if b then "inj-event:" else "event:")
      else
	print_string (if b then "evinj:" else "ev:");
      display_list (fun f -> print_string f.f_name) "," l
  | RealQuery q -> display_corresp_query q


let display_eq_query = function
    ChoiceQuery -> print_string "Observational equivalence"
  | NonInterfQuery l ->
      print_string "Non-interference ";
      display_list (fun (f, tset) ->
	print_string f.f_name;
	match tset with
	  None -> ()
	| Some s -> 
	    print_string " among ("; 
	    display_list display_term ", " s;
	    print_string ")"
	      ) ", " l
  | WeakSecret f -> 
      print_string ("Weak secret " ^ f.f_name)
