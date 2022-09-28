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
(* Representation of sets of binders by a hash table, using chaining.
   I would have liked to use the standard Caml hash table module,
   but I could not because of a recursivity in types: the type binder
   contains sets of binders. So I had to reimplement it *)

open Types

let hash b =
  if b.vname == 0 then Hashtbl.hash b.sname else b.vname

let empty = 
  { nelem = 0; table = Array.make 1 [] }

let add s elem =
  let s = 
    if s == empty then
      { nelem = 0; table = Array.make 7 [] }
    else
      s
  in
  begin
    let nslot = Array.length s.table in
    let index = (hash elem) mod nslot in
    if not (List.memq elem s.table.(index)) then
      begin
	s.nelem <- s.nelem+1;
	s.table.(index) <- elem :: s.table.(index);
	(* filling factor at most 3 *)
	if s.nelem > 3 * nslot then
	  let new_nslot = 3 * nslot in
	  let new_table = Array.make new_nslot [] in
	  for i = 0 to nslot - 1 do
	    List.iter (fun elem ->
	      let new_index = (hash elem) mod new_nslot in
	      new_table.(new_index) <- elem :: new_table.(new_index)) s.table.(i)
	  done;
	  s.table <- new_table
      end
  end;
  s
    
let mem s elem =
  List.memq elem s.table.((hash elem) mod (Array.length s.table))
