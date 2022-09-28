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
open Ptree

let lib_name = ref ""

let def_var_name = "v"

(* constants for predicate properties *)

let pred_ANY = 1
let pred_TUPLE = 2
let pred_BLOCKING = 4
let pred_ANY_STRICT = 8
let pred_ELEM = 16
let pred_ATTACKER = 32
let pred_ELIMVAR = 64
let pred_SIMPEQ = 128
let pred_TUPLE_SELECT = 256
let pred_REFTRANS = 512

(* constants for function properties *)

let fun_TYPECONVERTER = 2

(* various parameters that can be set by the user *)

let max_depth = ref (-1)
let max_hyp = ref (-1)

let ansi_color = ref false

let active_attacker = ref true

let key_compromise = ref 0

let typed_frontend = ref false
let ignore_types = ref true
let untyped_attacker = ref true

let verbose_rules = ref false
type explain_clauses = NoClauses | Clauses | ExplainedClauses
let verbose_explain_clauses = ref NoClauses
let verbose_redundant = ref false
let verbose_completed = ref false
let verbose_eq = ref true
let verbose_term = ref true

let reconstruct_derivation = ref true
let simplify_derivation = ref true
type simplification_level_t = AttackerOnly | AttackerSameTree | AllFacts
let simplify_derivation_level = ref AttackerSameTree
let unify_derivation = ref true

let display_derivation = ref true
let abbreviate_derivation = ref true
let explain_derivation = ref true
let reconstruct_trace = ref true
let trace_backtracking = ref true

let non_interference = ref false
(* let testeq = ref (None : (Types.predicate * Types.funsymb list) option) *)

type sel_type = NounifsetMaxsize | Nounifset | Term | TermMaxsize
let select_fun = ref TermMaxsize

let should_stop_term = ref true

type red_type = NoRed | SimpleRed | BestRed
let redundancy_test = ref SimpleRed

let move_new = ref false

let redundant_hyp_elim = ref false
let redundant_hyp_elim_begin_only = ref true

let check_pred_calls = ref true

let eq_in_names = ref false

let simpeq_remove = ref true

type eqtreatment = ConvLin | NonProved
let eqtreatment = ref ConvLin

type trace_display = NoDisplay | ShortDisplay | LongDisplay
let trace_display = ref ShortDisplay

let tulafale = ref 0

let boolean_param flag p ext v =
  match v with
    S ("no",_) | S ("false",_) -> flag := false
  | S ("yes",_) | S ("true",_) -> flag := true
  | _ -> Parsing_helper.input_error ("Unexpected value for parameter " ^ p ^ "=" ^ 
		       (match v with S (s,_) -> s | I n -> string_of_int n)) ext

let common_parameters p ext v =
  match (p,v) with
    "verboseRules", _ -> boolean_param verbose_rules p ext v
  | "verboseRedundant", _ -> boolean_param verbose_redundant p ext v
  | "verboseCompleted", _ -> boolean_param verbose_completed p ext v
  | "verboseEq", _ -> boolean_param verbose_eq p ext v
  | "verboseTerm", _ -> boolean_param verbose_term p ext v
  | "maxDepth", S ("none",_) -> max_depth := -1
  | "maxDepth", I s -> max_depth := s
  | "maxHyp", I s -> max_hyp := s
  | "maxHyp", S ("none",_) -> max_hyp := -1
  | "selFun", S ("Nounifset",_) -> select_fun := Nounifset
  | "selFun", S ("NounifsetMaxsize",_) -> select_fun := NounifsetMaxsize
  | "selFun", S ("Term",_) -> select_fun := Term
  | "selFun", S ("TermMaxsize",_) -> select_fun := TermMaxsize
  | "stopTerm", _ -> boolean_param should_stop_term p ext v
  | "redundancyElim", S("no",_) -> redundancy_test := NoRed
  | "redundancyElim", S("simple",_) -> redundancy_test := SimpleRed
  | "redundancyElim", S("best",_) -> redundancy_test := BestRed
  | "redundantHypElim", S("beginOnly",_) -> 
      redundant_hyp_elim := true; 
      redundant_hyp_elim_begin_only := true
  | "redundantHypElim", S (("true"|"yes"),_) -> 
      redundant_hyp_elim := true; 
      redundant_hyp_elim_begin_only := false
  | "redundantHypElim", S (("false"|"no"),_) -> redundant_hyp_elim := false
  | "simpEq", S ("remove",_) -> simpeq_remove := true
  | "simpEq", S ("reduce",_) -> simpeq_remove := false
  | "eqTreatment", S ("convLin",_) -> eqtreatment := ConvLin
  | "eqTreatment", S ("nonProved",_) -> eqtreatment := NonProved (* Undocumented! *)
  | "reconstructDerivation", _ -> boolean_param reconstruct_derivation p ext v
  | "simplifyDerivation", _ -> boolean_param simplify_derivation p ext v
  | "displayDerivation", _ -> boolean_param display_derivation p ext v
  | "abbreviateDerivation", _ -> boolean_param abbreviate_derivation p ext v
  | _, _ -> Parsing_helper.input_error ("Bad parameter " ^ p ^ "=" ^ 
			 (match v with S (s,_) -> s | I n -> string_of_int n)) ext


(* types *)

let any_type = { tname = "any" }
let bitstring_type = { tname = "bitstring" }
let channel_type = { tname = "channel" }
let sid_type = { tname = "sid" } (* session ids *)
let event_type = { tname = "event" }
let bool_type = { tname = "bool" }
let table_type = { tname = "table" }

let tmp_type = [{ tname = "temporary_type_should_be_removed" }]

(* predicates *)

let get_suffix i =
  if i = 0 then "" else "_p" ^ (string_of_int i)

let get_type_suffix t =
  if t == any_type then "" else "_" ^ t.tname

let rec tl_to_string sep = function
    [] -> ""
  | [a] -> a.tname
  | (a::l) -> a.tname ^ sep ^ (tl_to_string sep l)

let build_pred = function
    Attacker(i,t) -> 
      { p_name = "attacker" ^ (get_type_suffix t) ^ (get_suffix i); 
	p_type = [t];
	p_prop = pred_ANY + pred_TUPLE + pred_ATTACKER;
	p_info = [Attacker(i,t)] }
  | Mess(i,t) ->
      { p_name = "mess" ^ (get_type_suffix t) ^ (get_suffix i); 
	p_type = [channel_type; t];
	p_prop = 0;
	p_info = [Mess(i,t)] }
  | InputP(i) ->
      { p_name = "input" ^ (get_suffix i); 
	p_type = [channel_type]; 
	p_prop = 0;
	p_info = [InputP(i)] }
  | OutputP(i) ->
      { p_name = "output" ^ (get_suffix i); 
	p_type = [channel_type]; 
	p_prop = 0;
	p_info = [OutputP(i)] }
  | AttackerBin(i,t) ->
      { p_name = "attacker2" ^ (get_type_suffix t) ^ (get_suffix i); 
	p_type = [t;t];
	p_prop = pred_TUPLE + pred_TUPLE_SELECT + pred_ELIMVAR + pred_SIMPEQ + pred_ANY + pred_ATTACKER;
	p_info = [AttackerBin(i,t)] }
  | MessBin(i,t) ->
      { p_name = "mess2" ^ (get_type_suffix t) ^ (get_suffix i); 
	p_type = [channel_type; t; channel_type; t];
	p_prop = 0;
	p_info = [MessBin(i,t)] }
  | InputPBin(i) ->
      { p_name = "input2" ^ (get_suffix i); 
	p_type = [channel_type; channel_type]; 
	p_prop = 0;
	p_info = [InputPBin(i)] }
  | OutputPBin(i) ->
      { p_name = "output2" ^ (get_suffix i); 
	p_type = [channel_type; channel_type]; 
	p_prop = 0;
	p_info = [OutputPBin(i)] }
  | AttackerGuess(t) ->
      { p_name = "attacker_guess" ^ (get_type_suffix t); 
	p_type = [t;t]; 
	p_prop = pred_TUPLE + pred_TUPLE_SELECT + pred_ELIMVAR + pred_SIMPEQ + pred_ANY + pred_ATTACKER;
	p_info = [AttackerGuess(t)] }
  | Compromise(t) ->
      { p_name = "comp" ^ (get_type_suffix t); 
	p_type = [t]; 
	p_prop = pred_TUPLE + pred_ANY;
	p_info = [Compromise(t)] }
  | Equal(t) ->
      { p_name = "equal" ^ (get_type_suffix t); 
	p_type = [t;t]; 
	p_prop = 0;
	p_info = [Equal(t)] }
  | Table(i) ->
      { p_name = "table" ^ (get_suffix i); 
	p_type = [table_type];
	p_prop = 0;
	p_info = [Table(i)] }
  | TableBin(i) ->
      { p_name = "table2" ^ (get_suffix i); 
	p_type = [table_type;table_type];
	p_prop = 0;
	p_info = [TableBin(i)] }
  | PolymPred(s,i,tl) ->
      { p_name = s ^ (if List.for_all (fun x -> x == any_type) tl then "" else
                      if List.for_all (fun x -> x == List.hd tl) tl then "_" ^ (List.hd tl).tname else
		      "_" ^ (tl_to_string "_" tl)); 
	p_type = tl;
	p_prop = i;
	p_info = [PolymPred(s,i,tl)] }

let memo f =
  let table = Hashtbl.create 7 in
  fun x -> 
    try
      Hashtbl.find table x
    with Not_found ->
    let r = f x in
    Hashtbl.add table x r;
    r

let build_pred_memo = memo build_pred

let get_pred info =
  let info = 
    if !ignore_types then
      match info with
	Attacker(i,t) -> Attacker(i,any_type)
      |	Mess(i,t) -> Mess(i,any_type)
      |	AttackerBin(i,t) -> AttackerBin(i,any_type)
      |	MessBin(i,t) -> MessBin(i,any_type)
      |	AttackerGuess(t) -> AttackerGuess(any_type)
      |	Compromise(t) -> Compromise(any_type)
      |	Equal(t) -> Equal(any_type)
      |	PolymPred(s,i,tl) -> PolymPred(s,i, List.map (fun _ -> any_type) tl)
      |	x -> x
    else if !untyped_attacker then
      match info with
	Attacker(i,t) -> Attacker(i,any_type)
      |	AttackerBin(i,t) -> AttackerBin(i,any_type)
      |	AttackerGuess(t) -> AttackerGuess(any_type)
      |	Compromise(t) -> Compromise(any_type)
      |	x -> x
    else
      info
  in
  build_pred_memo info

(* For authenticity *)
let end_pred = { p_name = "end"; p_type = [event_type]; p_prop = 0;
		 p_info = [] }
let end_pred_inj = { p_name = "end"; p_type = [sid_type; event_type] ; p_prop = 0;
		     p_info = [] }

(* For non-interference *)
let testunif_pred = { p_name = "testunif"; p_type = [any_type; any_type]; 
		      p_prop = pred_BLOCKING;
		      p_info = [] }
let bad_pred = { p_name = "bad"; p_type = []; p_prop = pred_BLOCKING;
		 p_info = [] }

(* Special variables *)

let secret_vars = ref []
let secret_vars_with_sets = ref []

(* For weak secrets *)
let weaksecret = ref None
let weaksecret_mode = ref false

(* For choice *)

let choice_fun_memo = memo (fun t -> 
  { f_name = "choice";
    f_type = [t;t],t;
    f_cat = Choice;
    f_initial_cat = Choice;
    f_private = true;
    f_options = 0 })

let choice_fun t = 
  choice_fun_memo (if !ignore_types then any_type else t)

let has_choice = ref false

(* Values computed from the input file *)

let all_types = ref [channel_type; bitstring_type; bool_type]
let fun_decls = ((Hashtbl.create 49) : (string, funsymb) Hashtbl.t)
let pred_env = Hashtbl.create 7
let freenames = ref ([] : funsymb list)
let max_used_phase = ref 0
let session1 = { f_name = "session1"; 
		 f_type = [], sid_type;
                 f_private = false;
		 f_options = 0;
		 f_cat = Eq [];
	         f_initial_cat = Eq [] }
let red_rules = ref []
let elim_true = ref []
