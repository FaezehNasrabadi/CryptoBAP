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

(* Environment.
   May contain function symbols, variables, ...
   Is a map from strings to the description of the ident *)

module String = struct
   type t = string
   let compare = compare
end

module StringMap = Map.Make(String)

let env = ref (StringMap.empty : env_entry StringMap.t)

(* Read environment *)

let get_param env s ext =
  try
  match StringMap.find s env with
    EParam p -> p
  | _ -> input_error (s ^ " should be a parameter.") ext
  with Not_found -> input_error (s ^ " not defined.") ext

let get_type env s ext =
  try
  match StringMap.find s env with
    EType t -> t
  | _ -> input_error (s ^ " should be a type.") ext
  with Not_found -> input_error (s ^ " not defined.") ext

let get_type_or_param env s ext =
  try
  match StringMap.find s env with
    EType t -> t
  | EParam p -> Terms.type_for_param p
  | _ -> input_error (s ^ " should be a type or a parameter.") ext
  with Not_found -> input_error (s ^ " not defined.") ext

let get_process env s ext =
  try
  match StringMap.find s env with
    EProcess p -> p
  | _ -> input_error (s ^ " should be a process.") ext
  with Not_found -> input_error (s ^ " not defined.") ext
