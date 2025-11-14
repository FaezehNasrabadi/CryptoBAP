open HolKernel Parse boolLib bossLib;
open sumTheory;
open pred_setTheory;
open sigma_algebraTheory;
open listTheory;
open tautLib;
open interleavingdeductionTheory;
open parallelcompositiondeductionTheory;
open derived_rules_deductionTheory;

val _ = new_theory "derived_rules_DYlib";

(*DY library with same function signature *)

val _ = Datatype `term =
Name 'symb
| FAPP  (string # int) (term list)
        `;

val _ = Datatype `pred =
Equal ('symb term) ('symb term)
      `;

val same_function_signature_thm = store_thm(
  "same_function_signature_thm",
  ``!Sym Sym' P P' S1 S1' S2 S2' (MTrn:(('event + 'eventS), ('symb pred), 'state, 'symb) mtrel) (Ded:('symb pred) tded).
     (comptraces (MTrn,Ded) (MTrn,Ded) (Sym,P,S1,S2) (Sym',P',S1',S2'))                           
  = (binterleave_ts (traces (MTrn,Ded) (Sym,(IMAGE OUTL P),S1) (Sym',(IMAGE OUTL P'),S1')) (traces (MTrn,Ded) (Sym,(IMAGE OUTR P),S2) (Sym',(IMAGE OUTR P'),S2')))
    ``,
  rewrite_tac[binterleave_ts,traces_def,comptraces_def,EXTENSION] >>
  rw[] >>
  rewrite_tac[binterleave_trace_deduction]
  ); 



(*DY library with distinct function signature *)

(* DY Lib One *)     
val _ = Datatype `termOne =
NameOne 'symb
| FAPPOne  (string # int) (termOne list)
           `;

val _ = Datatype `predOne =
EqualOne ('symb termOne) ('symb termOne)
         `;

(* DY Lib Two *) 
val _ = Datatype `termTwo =
NameTwo 'symb
| FAPPTwo  (string # int) (termTwo list)
           `;

val _ = Datatype `predTwo =
EqualTwo ('symb termTwo) ('symb termTwo)
         `;


val distinct_function_signatures_thm = store_thm(
  "distinct_function_signatures_thm",
  ``∀Sym P S1 S2 Sym' P' S1' S2' (MTrn1:('event1 + 'eventS, ('symb predOne), 'state1, 'symb) mtrel) (MTrn2:('event2 + 'eventS, ('symb predTwo), 'state2, 'symb) mtrel) (Ded1:('symb predOne) tded) (Ded2:('symb predTwo) tded).
         (comptraces (MTrn1,Ded1) (MTrn2,Ded2) (Sym,P,S1,S2) (Sym',P',S1',S2'))                           
     = (binterleave_ts (traces (MTrn1,Ded1) (Sym,(IMAGE OUTL P),S1) (Sym',(IMAGE OUTL P'),S1')) (traces (MTrn2,Ded2) (Sym,(IMAGE OUTR P),S2) (Sym',(IMAGE OUTR P'),S2')))
       ``,
     rewrite_tac[binterleave_ts,traces_def,comptraces_def,EXTENSION] >>
     rw[] >>
     rewrite_tac[binterleave_trace_deduction]   
  ); 




val _ = export_theory();
