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
type 'a queue = { mutable next : 'a queue option;
                  elem : 'a }

type 'a q = { mutable qstart : 'a queue option;
              mutable qend : 'a queue option }

let new_queue() = { qstart = None; qend = None }

(* qstart and qend are None at the same time, 
   and this means that the queue is empty *)

let add queue r =
  match queue.qend with
    None -> let qelem = { next = None; elem = r } in
            queue.qstart <- Some qelem; queue.qend <- Some qelem
  | Some q -> q.next <- Some { next = None; elem = r };
              queue.qend <- q.next

let get queue =
  match queue.qstart with
    None -> None
  | Some q -> if q.next == None then queue.qend <- None;
              queue.qstart <- q.next;
              Some q.elem

let length queue =
  let rec lengthq q =
    match q with
      None -> 0
    | Some q' -> 1 + lengthq (q'.next)
  in
  lengthq queue.qstart

let exists queue f = 
  let rec existsrec q =
    match q with
      None -> false
    | Some q' -> (f q'.elem) || (existsrec q'.next)
  in
  existsrec queue.qstart

let filter queue f =
  let rec filterrec q =
    match q with
      None -> None
    | Some q' -> 
	let rnext = filterrec q'.next in
	if f q'.elem then
	  let r = Some { next = rnext; elem = q'.elem } in
	  if rnext == None then queue.qend <- r;
	  r
	else
	  rnext
  in
  queue.qstart <- filterrec queue.qstart;
  if queue.qstart == None then queue.qend <- None

let iter queue f =
  let rec iterrec q =
    match q with
      None -> ()
    | Some q' -> 
	f q'.elem; 
	iterrec q'.next
  in
  iterrec queue.qstart
 
