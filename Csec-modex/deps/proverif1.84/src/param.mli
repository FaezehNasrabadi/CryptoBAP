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
val lib_name : string ref

val def_var_name : string

(* Use the following constants to set bits of the p_prop field 
   of predicates. For the predicate p,

   pred_ANY means that there exists x1,...,xn such that p:x1,...,xn and 
   if all inequalities involving x1...xn are satisfiable, then they are 
   satisfied for this x1...xn.

   pred_ANY_STRICT means that there exists x such that p:x,...,x

   pred_TUPLE means that p:(x_1, ..., x_n) iff p:x_1 and ... and p:x_n
   pred_TUPLE_SELECT means further that facts p:x may be selected by the
   selection function

   pred_BLOCKING means that the predicate must never be selected by
   the selection function.

   pred_ELEM means that 
     att(x) /\ elem(M_1, x) /\ ... /\ elem(M_n, x)
   becomes
     att(x) /\ att(M_1) /\ ... /\ att(M_n)
   when elem is a predicate pred_ELEM and att is a predicate pred_TUPLE
   This simplification is always done when x does not occur elsewhere.
   When x occurs elsewhere, the simplification can be done when the
   clause has no selected fact. It leads to a loss of precision in
   this case.

   pred_ATTACKER means that the predicate is one of the attacker, attacker_pi
   predicates for the different phases.

   pred_ELIMVAR means that p(y,x) /\ p(y',x) /\ y <> y' -> bad
   and p(x,y) /\ p(x,y') /\ y <> y' -> bad are present

   pred_SIMPEQ means that one should use the equational theory
   to simplify the arguments of this predicate.
*)
val pred_ANY : int
val pred_ANY_STRICT : int
val pred_TUPLE : int
val pred_TUPLE_SELECT : int
val pred_BLOCKING : int
val pred_ELEM : int
val pred_ATTACKER : int
val pred_ELIMVAR : int
val pred_SIMPEQ : int
val pred_REFTRANS : int

val fun_TYPECONVERTER : int

val max_depth : int ref
val max_hyp : int ref
val ansi_color : bool ref
val active_attacker : bool ref
val key_compromise : int ref
val non_interference : bool ref

val typed_frontend : bool ref
val ignore_types : bool ref
val untyped_attacker : bool ref

val verbose_rules : bool ref
type explain_clauses = NoClauses | Clauses | ExplainedClauses
val verbose_explain_clauses : explain_clauses ref
val verbose_redundant : bool ref
val verbose_completed : bool ref
val verbose_eq : bool ref
val verbose_term : bool ref

val reconstruct_derivation : bool ref
val simplify_derivation : bool ref
type simplification_level_t = AttackerOnly | AttackerSameTree | AllFacts
val simplify_derivation_level : simplification_level_t ref
val unify_derivation : bool ref
val display_derivation : bool ref
val abbreviate_derivation : bool ref
val explain_derivation : bool ref
val reconstruct_trace : bool ref
val trace_backtracking : bool ref

type sel_type = NounifsetMaxsize | Nounifset | Term | TermMaxsize
val select_fun : sel_type ref

val should_stop_term : bool ref

type red_type = NoRed | SimpleRed | BestRed
val redundancy_test : red_type ref

val move_new : bool ref

val redundant_hyp_elim : bool ref
val redundant_hyp_elim_begin_only : bool ref
val check_pred_calls : bool ref
val eq_in_names : bool ref

val simpeq_remove : bool ref

type eqtreatment = ConvLin | NonProved
val eqtreatment : eqtreatment ref

type trace_display = NoDisplay | ShortDisplay | LongDisplay
val trace_display : trace_display ref

val tulafale : int ref

val boolean_param : bool ref -> string -> Parsing_helper.extent -> Ptree.pval -> unit
val common_parameters : string -> Parsing_helper.extent -> Ptree.pval -> unit

(* types *)

val any_type : Types.typet
val bitstring_type : Types.typet
val channel_type : Types.typet
val sid_type : Types.typet
val event_type : Types.typet
val bool_type : Types.typet
val table_type : Types.typet

(* Special type to record that the type is not defined yet *)
val tmp_type : Types.typet list

val get_type_suffix : Types.typet -> string

(* predicates *)

val end_pred : Types.predicate
val end_pred_inj : Types.predicate
val testunif_pred : Types.predicate
val bad_pred : Types.predicate

(* Special variables *)

val secret_vars : Types.funsymb list ref
val secret_vars_with_sets : (Types.funsymb * Types.term list option) list ref

(* [memo f] is the memoizing version of function f:
   when f is called several times with the same argument, it returns
   the same result without recomputing f *)

val memo : ('a -> 'b) -> 'a -> 'b

(* Phases *)

val get_pred : Types.info -> Types.predicate

(* Weak secrets *)

val weaksecret : Types.funsymb option ref
val weaksecret_mode : bool ref

(* Choice *)

val choice_fun : Types.typet -> Types.funsymb
val has_choice : bool ref

(* Values computed from the input file *)

val all_types : Types.typet list ref
val fun_decls : (string,Types.funsymb) Hashtbl.t
val pred_env : (string,Types.predicate) Hashtbl.t
val freenames : Types.funsymb list ref
val max_used_phase : int ref
val session1 : Types.funsymb
val red_rules : (Types.fact list * Types.fact * Types.constraints list list * Types.label) list ref
val elim_true : Types.fact list ref

