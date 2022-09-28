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

let anal_file s =
  try
    let (statements, collisions, equivs, move_new_eq, queries, proof, p) = Syntax.read_file s in
    List.iter Check.check_def_eqstatement equivs;
    List.iter (fun (_,eq) -> Check.check_def_eqstatement eq) move_new_eq;
    Check.check_def_process_main p;
    let equivs = List.map Check.check_equiv equivs in
    let new_new_eq = List.map (fun (ty, eq) -> (ty, Check.check_equiv eq)) move_new_eq in
    let g = { proc = p; game_number = 1 } in
    Transform.queries := 
       if queries == [] then 
	 [AbsentQuery,g]
       else
	 List.map (fun q -> (q,g)) queries;
    Transform.statements := statements;
    Transform.collisions := collisions;
    Transform.equivs := equivs;
    Transform.move_new_eq := new_new_eq;
    Transform.collect_public_vars();

    (*
    List.iter Display.display_statement statements;
    print_newline();
    List.iter Display.display_equiv equivs;
    print_newline();
    Display.display_process p;
    *)
    let _ = Instruct.execute_any_crypto proof 
	{ game = g; 
	  simplify_internal_info = ([],[]);
	  prev_state = None } in
    () 
  with End_of_file ->
    print_string "End of file.\n"
  | e ->
    Parsing_helper.internal_error (Printexc.to_string e)


let _ =
  Arg.parse
    [ "-lib", Arg.String (fun s -> Settings.lib_name := s),
      "<filename> \tchoose library file";
      "-tex", Arg.String (fun s -> Settings.tex_output := s),
      "<filename> \tchoose TeX output file";
      "-in", Arg.String (function 
	  "channels" -> Settings.front_end := Settings.Channels
	| "oracles" -> Settings.front_end := Settings.Oracles
	| _ -> Parsing_helper.user_error "Command-line option -in expects argument either \"channels\" or \"oracles\".\n"),
      "channels / -in oracles \t choose the front-end"
    ]
    anal_file "Cryptoverif. Cryptographic protocol verifier, by Bruno Blanchet\nCopyright ENS-CNRS, distributed under the CeCILL-B license"
