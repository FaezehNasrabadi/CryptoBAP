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
open Stringmap

let event_status_table = Hashtbl.create 7

let init_event_status_table event_fun_table =
  Hashtbl.clear event_status_table;
  Hashtbl.iter (fun _ d ->
    Hashtbl.add event_status_table d { end_status = No; begin_status = No })
    event_fun_table

let get_event_status f =
  try 
    Hashtbl.find event_status_table f
  with Not_found ->
    Parsing_helper.internal_error "event not found"

let set_event_status_e set_end set_begin = function
    QSEvent(b, FunApp(f,_)) ->
	let fstatus = get_event_status f in
	if set_end then begin
	  if b then fstatus.end_status <- Inj else
	  if fstatus.end_status = No then fstatus.end_status <- NonInj
	end;
	if set_begin then begin
	  if b then fstatus.begin_status <- Inj else
	  if fstatus.begin_status = No then fstatus.begin_status <- NonInj
	end
  | _ -> ()

let rec set_event_status_r set_begin = function
    Before(e, ll) ->
      set_event_status_e true set_begin e;
      List.iter (List.iter (function
	  QEvent e -> set_event_status_e false true e
	| NestedQuery q -> set_event_status_r true q)) ll

let set_event_status = function
    PutBegin(i, l) ->
      List.iter (fun f ->
	let fstatus = get_event_status f in
	if i then fstatus.begin_status <- Inj else
	if fstatus.begin_status = No then fstatus.begin_status <- NonInj) l
  | RealQuery q ->
      set_event_status_r false q

