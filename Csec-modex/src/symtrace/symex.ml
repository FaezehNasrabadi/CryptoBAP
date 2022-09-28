(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)

open Common

(* CR: turn undefined functions into compile errors. *)

open Type
open Sym
open Exp
open Iml
open Stmt

module E = Exp
module S = Solver

module Base_map = E.Base_map

module L = struct
  let get_len e = Simplify.full_simplify (E.Len e)
end

type mem = bterm Base_map.t

type sym = string
type nargs = int

type cvm =
    (* loading *)
  | Load_int of intval
  | Load_string of char list
  | Load_c_string of char list
  | Load_char of char
  | Load_stack_ptr of string (** name of variable; step init to 0 (invalid value) *)
  | Malloc (** stack: buffer length; step init to 0 *)
  | Load_buf (** stack: ptr, len *)
  | Load_mem (** stack: ptr; use ptr step as len. *)
  | Load_all (** stack: ptr; load the whole buffer *)
    (* Load_attr attr // stack: ptr; consumed *)
  | In  (** stack: len *)
  | New (**
            stack: constant int length N, type alias T. Creates value of type Fixed (N, T).
            Special case: N = -1. Creates value of type (Named T).
         *)
  | Env of string

    (* offsetts *)
  | Field_offset of string (** stack: ptr; step init to 0 *)
  | Ctx_offset of string (** pointer step set to 0,
                            a context pointer should never be used with Load_mem (implement a check in update) *)
  | Index_offset of Int_type.t (** stack: ptr, offset; step init to 0 *)

    (* operations *)
  | Apply of sym
  | Dup
  | Len
  | Truth
  | BS of Int_type.t
  | Val of Int_type.t
  | In_type of string

  | Apply_nondet (** For a symbol application on top of stack indicate that the application is not deterministic.
                    For a stack pointer assigns it a fresh id. *)

  (* | Concrete_result of intval *)
  | Append (** stack: first, second; second consumed *)
  | Event of sym * nargs
  | Branch of bool
  | Assume
  | Hint of string
  | Type_hint of string
  | Set_ptr_step (** The size of the underlying type,
                   stack: ptr, step; step consumed
                   Overwrites existing pointer step.
                   Is necessary as a separate thing because of casts and the trick with flat char arrays. *)
  | Done (** signals that we are done creating and customising a new value *)

    (* storing *)
  | Store_buf (** stack: exp, ptr; both consumed; use exp len *)
  | Store_mem (** stack: exp, ptr; both consumed; use pointer step *)
  | Store_all (** stack: exp, ptr; both consumed; replace whatever the pointer points to, don't look at exp len
                 Currently used in two cases:
                 - To replace contents of E.zero-terminated expressions
                 - To store cryptographic attributes *)
    (* Store_attr attr // stack: exp, ptr; both consumed *)
  | Clear (** No warnings *)
  | Copy_ctx (** stack: to, from; both consumed *)
  | Out

  (* misc *)
  | Call of string * nargs
  | Return
  | Comment

(*************************************************)
(** {1 Debug} *)
(*************************************************)

let fail_mode = ref false

let fail_buf = ref ""

let output a =
  let output s =
    if !fail_mode
    then fail_buf := !fail_buf ^ ("\n  " ^ s)
    else if debug_enabled ()
    then prerr_endline (decorate_debug s)
  in
  Printf.ksprintf output a

module Loc = struct
  type t =
    { fname : string
    ; mutable line  : string
    ; call_id : int
    }

  let to_string t =
    Printf.sprintf "%s[%d, %s]" t.fname t.call_id t.line

  (** The ids for the calls on the call stack *)
  let call_id : int ref = ref 0

  (** Current call stack, used for debug purposes only *)
  let stack : t Stack.t = Stack.create ()

  let set_line l =
    let top = Stack.top stack in
    top.line <- l

  let call f =
    Stack.push
      { fname = f
      ; line = Printf.sprintf "<top of %s>" f
      ; call_id = next call_id}
      stack

  let return () =
    let result = to_string (Stack.pop stack) in
    if Stack.is_empty stack
    then fail "Returned from main";
    result

  let reset () =
    Stack.clear stack;
    call_id := 0;
    call "main"

  let () = reset ()

  let current () =
    to_string (Stack.top stack)

  let call_stack () =
    Stack.to_list stack
    |> List.map ~f:to_string
    |> String.concat ~sep:"\n"

  let dump_stack () =
    Stack.iter (fun loc ->
      output "#  %s" (to_string loc)) stack
end


(*************************************************)
(** {1 State} *)
(*************************************************)

(** The symbolic memory *)
let mem : mem ref = ref Base_map.empty

(** Symbolic execution stack *)
let stack: Exp.any Stack.t = Stack.create ()

(** IML generated so far *)
let iml: iml ref = ref []

(** All the functions called so far, for debug purposes only *)
let called_functions: string list ref = ref []

let cur_stack_ptr_id : int ref = ref 0
let cur_heap_ptr_id : int ref = ref 0

let previous_malloc_lens = ref []

(** The number of instructions executed so far *)
let done_instr : int ref = ref 0

let reset_state : unit -> unit = fun () ->
  (* don't reset the Exp state *)
  mem := Base_map.empty;
  Stack.clear stack;
  iml := [];
  previous_malloc_lens := [];
  Loc.reset ();
  S.reset_facts ()

(*************************************************)
(** {1 Helpers} *)
(*************************************************)

let ptr_len = Sym (Ptr_len, [])

let fresh_heap_ptr l =
  if not (E.is_constant l)
  then previous_malloc_lens := !previous_malloc_lens @ [l];
  Ptr (Heap (increment cur_heap_ptr_id, !previous_malloc_lens, l),
       [Flat E.zero, Int 1L])

(* TODO: move as much as possible into invariant *)
let check_well_formed (type a) (e : a exp) =

  let rec check_decreasing : pos -> unit = function
    | [_; (Attr _, _)] -> ()
    | (_, step1) :: ((_, step2) as os2) :: pos' ->
      if not (S.greater_equal_len step1 step2) then
        fail "check_well_formed: offset step sequence not monotonous: %s" (E.dump e);
      check_decreasing (os2 :: pos')

    | _ -> ()
  in

  (*
  (* check that all flat offsets have step 1 *)
  let rec check_flat_offset: offset -> unit = function
    | (Flat _, step) ->
      if not (S.equal_len step one) then
        fail ("check_well_formed: a flat offset with step greater 1: " ^ E.dump e)
   | _ -> ()
  in
  *)

  (*
  (*
    One thing that prevents this from being enforced is that a step of an attribute offset
    isn't known, so an attribute offset doesn't bubble up past the trailing flat or index offset.

    I think this can be fixed by updating bubble_up so that attributes always bubble up past
    flat offsets.
  *)
  let rec check_order : bool -> bool -> pos -> unit = fun seen_index prev_flat -> function
    | ((Field _ | Attr _), _) :: pos' ->
      if not seen_index then
        fail "check_pos: first field or attribute not preceded by index: %s" (E.dump e);
      if prev_flat then
        fail "check_pos: field or attribute preceded by flat: %s" (E.dump e);
      check_order seen_index false pos'

    | (Index _, _) :: pos' ->
      if prev_flat then
        fail "check_pos: index preceded by flat: %s" (E.dump e);
      check_order true false pos';

     | (Flat _, _) :: pos' -> check_order seen_index true pos';

     | [] -> ()
  in
  *)
  E.invariant e;
  match e with
  | Ptr (_, pos) ->
    (* check_order false false pos; *)
    check_decreasing pos;
  (* See notes about flat offset steps *)
  (* iter check_flat_offset pos *)
  | _ -> () (* L.get_len e <> Unknown *) (* see notes *)

(*
  FIXME: merge when merging with CIL.
*)
let is_interface_fun : string -> bool = fun s ->
  List.mem s
        ~set:["event0"; "event1"; "event2"; "event3"; "event4"; "readenv"; "readenvE"; "readenvL";
              "make_str_sym"; "make_sym"; "mute"; "unmute"; "fail";
              (* Internal interface functions: *)
              "load_buf"; "load_all"; "load_ctx"; "load_int"; "load_str";
              "symL"; "symN"; "symNE"; "input"; "newTL"; "newT";
              "varsym"; "var"; "varWithBufInit"; "varL"; "output";
              "store_buf"; "store_all"; "store_ctx"; "event";
              "add_to_attr"; "set_attr_str"; "set_attr_buf"; "set_attr_int";
              "get_attr_int"; "copy_ctx"; "copy_attr_ex"; "copy_attr";
              "clear_attr"; "concrete_val"; "fresh_ptr"; "test_intype"; "assume_intype";
              "len"; "assume"; "assume_len"; "assume_len_at_most";
              "clear"; "duplicate"; "store_len"]

let interesting (type a) (e : a exp) =
  match e with
  | Ptr (Stack "SAX_meter.i:method[4777]", _) -> true
  (* | Ptr (Heap (17, _), _) -> true *)
  | _ -> false


(*************************************************)
(** {1 Fail} *)
(*************************************************)

(** Non-destructive. *)
let dump_stack () =
  Stack.iter (fun (Any e) -> output "# %s" (E.dump e)) stack

let _dump_memory () =
  let dump_cell (b : base) (e : bterm) =
    output "%s => %s" (E.base_to_string b) (E.dump e)
  in
  Base_map.iter dump_cell !mem

let dump_called_funs: unit -> unit = fun () ->
  (* output called functions *)
  let f = open_out_bin "called.out" in
  List.iter ~f:(fun s -> output_string f (s ^ "\n")) !called_functions

let failfun () =
  fail_mode := true;
  output "Instructions Executed: %d" !done_instr;
  output "Location: %s" (Loc.current ());
  output ("Call stack:");
  Loc.dump_stack ();
  (* E.clip_enabled := false; *)
  output ("Execution stack:");
  dump_stack ();
  (*
  output ("symbolic memory:");
  dump_memory ();
  debug ("generated iml:");
  iter prerr_endline (map E.dump (filter interesting_event !iml));
  *)
  (*
  (* FIXME: this should be done only once, given that we use catch now. *)
  dump_called_funs ();
  *)

  output "process = ";
  output "%s" (Iml.to_string !iml);
  fail_mode := false;
  let result = !fail_buf in
  fail_buf := "";
  result

let _ = fail_funs := !fail_funs @ [failfun]

(*************************************************)
(** {1 Symbolic Buffer Manipulation} *)
(*************************************************)

let flatten_array : bterm Int_map.t -> bterm = fun cells ->
  let rec check = fun len -> function
    | [] -> ()
    | [j, _] -> if j = len - 1 then () else fail "flatten: sparse arrays not supported yet"
    | _ :: xs -> check len xs
  in
  let clist = fold2list Int_map.fold (fun i e -> (i, e)) cells in
  check (List.length clist) clist;
  Simplify.simplify (Concat (List.map ~f:snd clist))

let flatten_index : pos -> pos = function
  | (Index i, step) :: pos -> (Flat (E.prod [step; (E.int i)]), step) :: pos
  | _ -> fail "flatten_index"

(**
    Flatten until the next field or attribute offset.
*)
let rec flatten_index_deep : pos -> pos = function
  | (Index i, step) :: pos -> (Flat (E.prod [step; (E.int i)]), step) :: flatten_index_deep pos
  | (Flat e, step) :: pos -> (Flat e, step) :: flatten_index_deep pos
  | pos -> pos


(**
    We assume that length is correct, in particular we don't check length when doing member extraction.

    If we need to apply a member offset to a encoderenation, we try with the first element.

    None in length position means extract everything until the end of the storage unit.
    FIXME: this will be simplified.
*)
let rec extract (pos: pos) (l : iterm option) (e : bterm) : bterm =
  DEBUG "extract, e_host: %s" (E.dump e);
  DEBUG "extract, pos: %s" (String.concat ~sep:", " (List.map ~f:E.offset_to_string pos));
  DEBUG "extract, len: %s" (Option.to_string E.dump l);
  match (pos, l, e) with
    | ((Field s, _) :: os', _, Struct (fields, _, _, e_old)) ->
      begin
	      try let e' = Str_map.find s fields in extract os' l e'
	      with Not_found -> extract pos l e_old
      end

    | ((Attr s, _) :: os', _, Struct (_, attrs, _, _)) ->
      let e' = try Str_map.find s attrs
               with Not_found -> fail "extract: attribute not initialised: %s" s in
      extract os' l e'

    | ((Index i, step) :: pos', l, Array (cells, len, elt_size)) ->
      (* trying to catch a situation where pointer to the start of array is used to
         extract a big piece of array *)
      (* TODO: simplify the control here *)
      let inside_cell = match l with
        | Some l -> S.greater_equal_len_answer elt_size l = S.Yes
        | None -> false
      in
      let take_until_end =
        match l with
        | Some l -> S.equal_int l len
        | None -> true
      in
      if not inside_cell
      then begin
        (* If we want the whole array, don't flatten it. *)
        if i = 0 && take_until_end then e
        else extract pos l (flatten_array cells)
      end
      else begin
	if S.equal_int step elt_size then
	  let e' = try Int_map.find i cells
	    with Not_found -> fail "extract: array index not initialised: %s" (string_of_int i) in
	  extract pos' l e'
	else if i = 0 && S.equal_int step len then
	  extract pos' l e
	else if S.greater_equal_len elt_size step then
	  let e' = try Int_map.find 0 cells
	    with Not_found -> fail "extract: cannot descend into first cell" in
	  extract pos l e'
	else
          extract pos l (flatten_array cells)
      end

    | ((Index _, _) :: _, l, e) ->
      extract (flatten_index pos) l e

    | (pos, l, Array (cells, _, l')) ->
      let take_until_end =
        match l with
        | None -> true
        | Some l -> S.equal_int l l'
      in
      if pos = [] && take_until_end then e
      else extract pos l (flatten_array cells)

    | ((Flat oe, _) :: os', l, e) ->
      let e' = Simplify.full_simplify (Range (e, oe, E.minus (L.get_len e) oe)) in
      extract os' l e'

    | ([], None, e) -> e
    | ([], Some l, e) -> Simplify.full_simplify (Range (e, E.zero, l))

      (* FIXME *)
    | (os, l, Concat (e' :: _)) -> extract os l e'

    | ((Field s, _) :: os', Some l, e) ->
      (* We already pre-trim to length l, otherwise the length of the result is harder to
         compute. *)
      let e' = Simplify.full_simplify (Range (e, Sym (Sym.Field_offset s, []), l)) in
      extract os' (Some l) e'

    | _ -> fail "extract: cannot read through pointer"

let extract pos l e =
  push_debug "extract_pos";
  let result = extract pos l e in
  pop_debug "extract_pos";
  result

(** Creates structures and members along the way if they don't exist.

    [l_val] is the length of the part of [e_host] that needs to be replaced with [e_val].
    In case [l_val = None] the effect is to replace all data from [pos] until the end of
    the segment that [pos] points to.

    [step] gives the length for newly created structures and arrays.

    [e_host] is the rest of the current segment. This is important if [l_val = Infty].

    It is however not a requirement and sometimes the call can return expressions of other
    lengths.
*)
let rec update
    (pos : pos)
    (step : iterm)
    (l_val : iterm option)
    (e_host : bterm)
    (e_val : bterm) =
  DEBUG "update, e_host: %s" (E.dump e_host);
  DEBUG "update, e_val: %s"  (E.dump e_val);
  DEBUG "update, pos: %s" (String.concat ~sep:", " (List.map ~f:E.offset_to_string pos));
  DEBUG "update, step: %s" (E.dump step);
  DEBUG "update, l_val: %s" (Option.to_string E.dump l_val);
  if not (S.is_true (E.is_defined e_val))
  then fail "Cannot prove %s when storing to memory." (E.to_string (E.is_defined e_val));
  match (pos, l_val, e_host) with
  | ((Index _, _) :: _, None, Array (cells, _, _)) ->
    update pos step None (flatten_array cells) e_val

  | ((Index i, step') :: pos', Some l_val, Array (cells, len, elt_size)) ->
    begin
      match S.greater_equal_len_answer elt_size l_val with
      | (S.No | S.Maybe) -> update pos step (Some l_val) (flatten_array cells) e_val
      | _ ->
	if S.equal_int step' elt_size then
	  let e_elem = try Int_map.find i cells
	    with Not_found -> Concat [] in
	  let e' = update pos' step' (Some l_val) e_elem e_val in
	  Array (Int_map.add i e' cells, len, elt_size)

	else if i = 0 && S.equal_int step' len then
	  update pos' step' (Some l_val) e_host e_val

	(* else if S.greater_equal_len elt_size step then
	   let e_elem = try Int_map.find 0 cells
	   with Not_found -> Concat [] in
	   let e' = update pos elt_size l_val e_elem e_val in
	   Array (Int_map.add 0 e' cells, len, elt_size) *)

        else update pos step (Some l_val) (flatten_array cells) e_val

    (* else fail "update: index step incompatible with array element size" *)
    end

  | ((Index _, _) :: _, None, Concat []) ->
    update (flatten_index pos) step None e_host e_val

  | ((Index _, step') :: _, Some l_val, Concat []) ->
    if S.greater_equal_len step' l_val then
      let e_new = Array (Int_map.empty, step, step') in
      update pos step (Some l_val) e_new e_val
    else
      update (flatten_index pos) step (Some l_val) e_host e_val

  (* TODO: give it one more chance in case Concat [Array _]? *)
  | ((Index _, _) :: _, l_val, e_host) ->
    (* deep flattening here is slightly cosmetical - otherwise you get stuff like
       [payload_len|<{0 -> <{0 -> 7c}>}>] *)
    (* let e_new = update (flatten_index_deep pos') step' l_val (Concat []) e_val in
       update (flatten_index [Index i, step']) step (L.get_len e_new) e_host e_new *)
    update (flatten_index_deep pos) step l_val e_host e_val

  | ((Field s, step') :: pos', l_val, Struct (fields, attrs, len, e_old)) ->
    let e_field =
      try Str_map.find s fields
      with Not_found -> Concat []
    in
    let e' = update pos' step' l_val e_field e_val in
    Struct (Str_map.add s e' fields, attrs, len, e_old)

  | ((Attr s, step') :: pos', l_val, Struct (fields, attrs, len, e_old)) ->
    let e_attr = try Str_map.find s attrs
      with Not_found -> Concat [] in
    let e' = update pos' step' l_val e_attr e_val in
    Struct (fields, Str_map.add s e' attrs, len, e_old)

  (* FIXME: we might need to descend if position is E.zero *)
  | ((Flat _, _) :: _, l_val, Array (cells, _, _)) ->
    update pos step l_val (flatten_array cells) e_val

  (* We follow the assumption that a flat offset has step 1.  If we want to create a
     structure below this offset, we better inherit the structure size (pointer step) from
     above.  *)
  | ((Flat oe, _) :: pos', l_val, e) ->
    (* FIXME: you might want to flatten_index_deep pos' in case oe > 0 *)
    let e1 = Simplify.full_simplify (Range (e, E.zero, oe)) in
    let e2 = Simplify.full_simplify (Range (e, oe, E.minus (L.get_len e) oe)) in
    Simplify.full_simplify (Concat [e1; update pos' step l_val e2 e_val])

  | ([], None, _) -> e_val

  | ([], Some l_val, e) ->
    let e_len = Simplify.full_simplify (L.get_len e) in
    begin match S.greater_equal_len_answer e_len l_val with
    | S.Yes ->
      let e' = Simplify.full_simplify (Range (e, l_val, E.minus e_len l_val)) in
      Simplify.full_simplify (Concat ([e_val; e']))
    (* here we essentially replace e by undef which is sound *)
    | S.No -> e_val
    (* Sound here too, we shall not allow access otuside e_val. The reason this is a
       warning and not a fail is that variables do not get cleared when entering a
       function a second time, so if you have a local variable that contains data of
       symbolic length (like temp variable in CSur my_decrypt function, you might get into
       trouble. *)
    | S.Maybe ->
      warn "update: cannot decide which is greater: %s or %s, erasing current cell contents"
        (E.to_string e_len) (E.to_string l_val);
      e_val
    end

  | (pos, l_val, Concat (e :: es)) when S.greater_equal_len (L.get_len e) step ->
    (* At this point [pos] starts with something that definitely goes into a deeper
       segment.  Thus it is safe to pass only the first element down - the right thing
       happens even if [l_val = Infty].  *)
    let e' = update pos step l_val e e_val in
    Simplify.full_simplify (Concat (e' :: es))

  | (((Field _ | Attr _), step') :: _, l_val, e) ->
    let e_old = Simplify.full_simplify (Range (e, E.zero, step)) in
    let e_new = Struct (Str_map.empty, Str_map.empty, step, e_old) in
    update pos step' l_val e_new e_val

(* Last resort: try to overwrite the value completely *)
(* | (((Field _, _) | (Attr _, _)) :: _, _) -> update pos step l_val (Concat []) e_val *)

(* | _ -> fail "update: cannot write through pointer" *)

let update pos step l_val e_host e_val =
  push_debug "update";
  let result = update pos step l_val e_host e_val in
  pop_debug "update";
  result

(*************************************************)
(** {1 Execution Functions} *)
(*************************************************)

(* Simplifications are done on a case-by-case basis. It is important not to do them too
   early, in order to let things like Hint and Set_len be applied to whatever they are
   meant for. *)

let take_stack_any () =
  try Stack.pop stack
  with
  | Stack.Empty -> fail "take_stack: not enough elements on stack"

let take_stack_with_kind (type a) (kind : a Kind.t) : a exp =
  let Any e = take_stack_any () in
  match E.coerce kind e with
  | Some e ->
    DEBUG "taking %s" (E.dump e);
    e
  | None ->
    fail "Take stack: wrong kind of %s, expected %s, got %s"
      (E.to_string e) (Kind.to_string kind) (Kind.to_string (E.kind e))

let take_stack () = take_stack_with_kind Kind.Bitstring
let take_stack_int () = take_stack_with_kind Kind.Int
let take_stack_bool () = take_stack_with_kind Kind.Bool

let take_n_stack n =
  List.map (1 -- n) ~f:(fun _ -> take_stack ()) |> List.rev

let take_n_stack_any n =
  List.map (1 -- n) ~f:(fun _ -> take_stack_any ()) |> List.rev

let to_stack e =
  DEBUG "pushing %s" (E.dump e);
  Stack.push (Any e) stack

let to_mem b e =
  check_well_formed e;
  DEBUG "storing %s" (E.dump e);
  mem := Base_map.add b e !mem

let add_stmts s ~with_loc =
  if with_loc
  then iml := !iml @ [Stmt.Comment (Loc.current ())] @ s
  else iml := !iml @ s
(*
  None means take all that's in the buffer.
*)
let load (l : iterm option) (p : bterm) =
  if interesting p then mark_enabled := true;
  DEBUG "load, p: %s" (E.dump p);
  match p with
    | Ptr (b, pos) ->
      begin match Option.try_with (fun () -> Base_map.find b !mem) with
      | None -> fail "load_mem: reading uninitialised memory"
      | Some e ->
      (* extract already does the simplification *)
        let e'= extract pos l e in
        to_stack e';
        mark_enabled := false
      end

    | _ -> fail "load: ptr expected"

let get_step : offset list -> iterm = comp snd List.last

let load_p : bool -> unit = fun use_step ->
  match take_stack () with
  | Ptr (_, pos) as p -> load (if use_step then Some (get_step pos) else None) p
  | _ -> fail "load_mem: ptr expected"

let store : cvm -> unit = fun flag ->
  let get_length e =
    let l = L.get_len e in
    if l = Unknown Kind.Int then fail "store: cannot determine expression length"
    else l
  in
  let p = take_stack () in
  let e = take_stack () in

  if interesting p then mark_enabled := true;

  DEBUG "store, p: %s" (E.dump p);
  DEBUG "store, e: %s" (E.dump e);
  match p with
  | Ptr (b, pos) ->
    let e_host = try Base_map.find b !mem with Not_found -> Concat [] in
    let l_val =
      match flag with
      | Store_buf -> Some (get_length e)
      | Store_mem -> Some (get_step pos)
      | Store_all -> None
      | _ -> fail "store: impossible"
    in
    (* CR: step? *)
    let step =
      match b with
      | Heap (_, _, len) -> len
      | _ -> snd (List.hd pos)
    in
    (* update performs simplification already *)
    let e = (update pos step l_val e_host e) in
    Option.iter (E.ptr_size b) ~f:(fun ptr_size ->
      if not (S.greater_equal ptr_size (Len e))
      then fail ("Writing outside allocated area: "
                 ^^ "cannot prove that %s is smaller than %s")
        (E.to_string (Len e)) (E.to_string ptr_size));
    to_mem b e;
    mark_enabled := false

  | _ -> fail "store: pointer expected"

let value ~expected_type e =
  match e with
  | E.BS (_, itype) ->
    (* begin match expected_sign with *)
    if itype <> expected_type
    then fail "Expected type %s in expression %s, got %s"
      (Int_type.to_string expected_type)
      (E.to_string e)
      (Int_type.to_string itype)
    else E.Val (e, itype) |> Simplify.simplify
  | _ ->
    E.Val (e, expected_type)

let rec execute = function

  | Load_buf ->
    begin try
      let l = take_stack () in
      let p = take_stack () in
      (* The expected type is the type of the argument of Load_buf in C. *)
      load (Some (value ~expected_type:Int_type.size_t l)) p
    with
      | Not_found   -> fail "load_buf: reading uninitialised memory"
      | Stack.Empty -> fail "load_buf: not enough elements on stack"
    end

  | Load_mem -> load_p true
  | Load_all -> load_p false

  | Load_int ival ->
    to_stack (Int ival)

  | Load_string s ->
    to_stack (String s)

  | Load_c_string s ->
    let s = s @ [Char.chr 0] in
    let l = List.length s in
    let p = fresh_heap_ptr (Int (Int64.of_int l)) in
    to_stack (String s);
    to_stack p;
    execute Store_mem;
    to_stack p

  | Load_char c ->
    (* Character literals in C have type int *)
    to_stack (E.BS (Char c, Int_type.int))

  | Load_stack_ptr name ->
    (* CR: disambiguate across function calls. How do we deal with static
       variables and static functions? *)
    to_stack (Ptr (Stack name, [Index 0, Unknown Kind.Int]))

  | Malloc ->
    let l = take_stack_int () in
    to_stack (fresh_heap_ptr l)

  | In ->
    let vname = Var.fresh "" in
    let v = Var (vname, Kind.Bitstring) in
    (* Inputs are defined in IML. *)
    S.assume [E.is_defined v];
    push_debug "In";
    DEBUG "Call stack on input:\n%s" (Loc.call_stack ());
    pop_debug "In";
    (* CR: be careful with inserting IML statements since this may bypass
       well-definedness checks and simplifications. *)
    add_stmts [Stmt.In [vname]; Stmt.Assume (E.is_defined v)] ~with_loc:false;
    to_stack v

  | New ->
    let vname = Var.fresh "" in
    let t = take_stack () in
    let l = take_stack_int () in
    let l, t =
      match l, t with
      | Int i, String s when i = -1L -> None, Named (String.implode s, None)
      | Int i, String []             -> Some (Int i), Fixed (Int64.to_int i)
      | Int i, String s              -> Some (Int i), Named (String.implode s, Some (Fixed (Int64.to_int i)))
      | l, _ ->
        fail "New: length followed by typename expected on stack, instead found %s, %s"
          (E.dump l) (E.dump l)
    in
    let v = Var (vname, Type.kind t) in
    add_stmts [Stmt.New (vname, t)] ~with_loc:false;
    S.assume [E.is_defined v];
    begin match l with
    | None -> ()
    | Some l -> S.assume [E.eq_int [E.len v; l]]
    end;
    to_stack v

  | Env v ->
    to_stack (Exp.var_s v)

  | Field_offset s ->
    begin match take_stack () with
      | Ptr (b, pos) -> to_stack (Ptr (b, pos @ [(Field s, Unknown Kind.Int)]))
      | _ ->  fail "field_offset: pointer expected"
    end

  | Ctx_offset s ->
    begin match take_stack () with
        | Ptr (b, pos) -> to_stack (Ptr (b, pos @ [(Attr s, Unknown Kind.Int)]))
        | _ ->  fail "ctx_offset: pointer expected"
    end

  | Index_offset itype ->
    begin
      let e = take_stack () in
      (* FIXME: loss of precision because of Int64 conversion *)
      (* This seems to be what 6.5.6 of the standard implies. *)
      match take_stack (), S.eval (value ~expected_type:itype e) with
        | (Ptr (b, pos), Some i) -> to_stack (Ptr (b, pos @ [(Index i, Unknown Kind.Int)]))
        | (Ptr _, _)             -> fail "index_offset: only concrete indices supported for now"
        | _ ->  fail "index_offset: pointer expected"
     end

  | Apply s ->
    let (Sym.Any sym) = Sym.of_string s in
    let args = take_n_stack_any (Sym.arity sym) in
    let e' = E.apply sym args in
    begin match sym with
    | Op (Op.Minus_PP, _) ->
      let e' = Simplify.full_simplify e' in
      to_stack (E.is_defined e');
      execute Assume
    | _ -> ()
    end;
    to_stack e'

  | Truth ->
    let e = take_stack () in
    to_stack (E.truth e)

  | Dup ->
    let e = take_stack () in
    to_stack e; to_stack e

  | Len ->
    let e = take_stack() in
    to_stack (E.Len e)

  | BS itype ->
    let e = take_stack_int() in
    to_stack (E.BS (e, itype))

  | Val itype ->
    let e = take_stack () in
    to_stack (Simplify.simplify (E.Val (e, itype)))

  | In_type tname ->
    let t = Type.of_string_bitstring tname in
    let e = take_stack() in
    to_stack (E.in_type e t)

  | Apply_nondet ->
    begin match take_stack () with
    | Sym (Fun (f, (arity, kind)), args) ->
      let v = Var.fresh "nondet" in
      let t_nondet = Type.Named ("nondet", None) in
      add_stmts [Stmt.New (v, t_nondet)] ~with_loc:true;
      to_stack (Sym (Fun (f, (arity + 1, kind)),
                     args @ [Var (v, Kind.Bitstring)]))
    | Ptr (Stack name, pos)  ->
      to_stack (Ptr (Stack (name ^ "[" ^ (string_of_int (increment cur_stack_ptr_id)) ^ "]"), pos))
    | e -> fail "Nondet: unexpected value on stack: %s" (E.to_string e)
    end

  | Append ->
    let args = take_n_stack 2 in
    to_stack (Simplify.simplify (Concat args))

  | Event (name, nargs) ->
    let args = take_n_stack nargs |> List.map ~f:Simplify.full_simplify in
    add_stmts [Stmt.Event (name, args)] ~with_loc:false
  (* [Sym (("event", Prefix), [e], Unknown, Det)] *)

  | Out ->
    let e = take_stack () |> Simplify.full_simplify in
    add_stmts [Stmt.Out [e]] ~with_loc:false

  | Branch dir ->
    (* CR: make sure to check explicitly that e is defined, as per thesis. *)
    let e = take_stack_bool () |> Simplify.full_simplify in
    DEBUG "branch: %s" (E.dump e);
    if not (E.is_constant e)
    then begin
      DEBUG "branch is not concrete";
      let e = if dir then e else E.negation e in
      if not (S.is_true e)
      then begin
        DEBUG "branch has non-constant condition, adding test statement";
        add_stmts [Stmt.make_test e] ~with_loc:true;
        S.assume [e]
      end
    end

  | Assume ->
    let e = take_stack_bool () in
    (* This is a bit stupid: we often cannot simplify an expression before
       assuming it, because parts of it may be undefined. *)
    (* CR-someday: this is also stupid because you simplify, say,
       [x = ztp)safe(x)] to [x = x].
    *)
    S.assume [e];
    DEBUG "add fact: %s" (E.dump e);
    let e = Simplify.full_simplify e in
    DEBUG "add assume statement: %s" (E.dump e);
    add_stmts [Stmt.Assume e] ~with_loc:true

  | Hint h ->
    let e = take_stack () |> Simplify.full_simplify in
    begin match e with
    | E.BS _ ->
      warn "Applying a hint to %s will prevent further simplifications" (E.to_string e);
    | _ -> ()
    end;
    let vname = Var.fresh h in
    let v = Var (vname, Kind.Bitstring) in
    S.assume [E.eq_bitstring [v; e]];
    if S.is_true (E.is_defined e)
    then S.assume [E.is_defined v];
    add_stmts [Let (Pat.VPat vname, Annotation(Name vname, e))] ~with_loc:false;
    to_stack v;
    DEBUG "attaching hint %s to %s" h (E.dump e)

  | Type_hint t ->
    let e = take_stack () in
    DEBUG "attaching type hint %s to %s" t (E.dump e);
    to_stack (Annotation (E.Type_hint (Type.of_string_bitstring t), e))

  | Set_ptr_step ->

    let flatten : offset -> offset_val = function
      | (Flat e,  _) -> Flat e
      | (Index i, step) -> Flat (E.prod [step; (E.int i)])
        (* The logic here is that Field is already flat in the sense that the offset value is independet of step *)
      | (Field f, _) -> Field f
        (* fail "set_ptr_step: trying to flatten a field offset" *)
      | (Attr _, _) -> fail "set_ptr_step: trying to flatten an attribute"
    in

    let rec bubble_up : offset -> pos -> pos = fun (ov, l) -> function
      | (ov', l') :: pos' as pos ->
        if S.greater_equal_len l l' then

          if E.is_zero_offset_val ov' then
            bubble_up (ov, l) pos'

          else if E.is_zero_offset_val ov then
            if S.equal_int l l' then
              pos
            else
              bubble_up (flatten (ov', l'), l) pos'

          else
            if S.equal_int l l' && (E.is_field_offset_val ov) && (E.is_field_offset_val ov') then
              (ov, l) :: pos
            else fail "set_ptr_step: trying to merge two nonzero offsets"

          (*
          else if S.equal_len l l' then
            if is_zero_offset_val ov then
              pos
            else if is_field_offset_val ov then
              (ov, l) :: pos
            else
              fail "set_ptr_step: trying to delete a non-E.zero offset (1)"
          else
            fail "set_ptr_step: trying to delete a non-E.zero offset"
          *)

        else
          (ov, l) :: pos

      | [] -> [(ov, l)]
    in

    let set_step : iterm -> pos -> pos = fun l -> function
      | (ov, _) :: pos' -> bubble_up (ov, l) pos'
      | [] -> fail "set_ptr_step: empty offset list"
        (* This unfortunately does not work, because of pointer-to-pointer casts *)
        (* | _ ->  fail "set_ptr_step: step already present" *)
    in

    let l = take_stack_int () in
    (*
        Simplification needed because we want to remove casts from pointers.
    *)
    let e = match Simplify.simplify (take_stack ()) with
      | Ptr (b, pos) -> Ptr (b, List.rev (set_step l (List.rev pos)))
      | _ -> fail "set_ptr_step: pointer expected"
    in
    to_stack e

  | Done ->
    let Any e = take_stack_any () in
    (*
    let l = fresh_len e in
    S.assume (E.ge l E.zero);
    let e = L.set_len e l in
    *)
    let e = Simplify.full_simplify e in
    DEBUG "Done, simplified: %s" (E.dump e);
    (* debug ("do_done, with new len: " ^ E.dump e); *)
    check_well_formed e;
    to_stack e

  | Store_buf -> store Store_buf
  | Store_mem -> store Store_mem
  | Store_all -> store Store_all

  | Clear ->
    ignore (take_stack ())

  | Copy_ctx ->
      execute Load_mem;
      let e_from = take_stack () in
      let p_to   = take_stack () in
      execute Load_mem;
      let e_to   = take_stack () in
      begin match (e_from, e_to) with
        | (Struct (_, attrs, _, _), Struct (fields, _, len, e_old)) ->
          (* FIXME: no need for simplification *)
          to_stack (Struct (fields, attrs, len, e_old));
          to_stack p_to;
          execute Store_mem;

        | _ -> fail "copy_ctx: two structure pointers expected"
      end

  | Call (fname, nargs) ->
    called_functions := !called_functions @ [fname];

    increase_indent ();

    Loc.call fname;
    DEBUG "# Entering %s, new call stack:" fname;
    Loc.dump_stack ();
    DEBUG "# execution stack:";
    dump_stack ();
    if not (is_interface_fun fname) && Stack.length stack != nargs then
      warn "Wrong number of elements on stack when entering %s" fname

  | Return ->
    let fname = Loc.return () in
    DEBUG "returning from %s" fname;
    decrease_indent ()

  | Comment -> ()


(*************************************************)
(** {1 Init} *)
(*************************************************)

let make_assumptions () =
  (* FIXME: remove this later when all symbolic sizes are being used properly *)
  let w = Int_type.width Int_type.ptr in
  S.assume [ E.eq_int [E.int w; ptr_len] ]

let init_argv n =
  let load_var_ptr name =
    let v = Var (name, Kind.Bitstring) in
    let e = Concat [v; E.zero_byte] in
    to_stack (E.eq_bitstring [v; Sym (Ztp_safe, [v])]);
    execute Assume;
    to_stack (E.is_defined (BS (Len e, Int_type.size_t)));
    execute Assume;
    to_stack e;
    let p = fresh_heap_ptr (Len e) in
    to_stack p;
    execute Store_buf;
    to_stack p
  in
  load_var_ptr (Var.of_string "argv0");
  for i = 1 to n - 1 do
    load_var_ptr (Var.of_string (Printf.sprintf "argv%d" i));
    execute Append;
  done;
  let argv = Ptr (Stack "argv", [Index 0, Sym (Ptr_len, [])]) in
  to_stack argv;
  execute Store_buf;
  let argc = E.BS (Int (Int64.of_int n), Int_type.int) in
  to_stack argc;
  to_stack argv

(*************************************************)
(** {1 Execution Loop} *)
(*************************************************)

let execute_file (file : in_channel) : iml =

  let rec execute' () =
    let line = input_line file in
    let toks = String.words line in
    if List.length toks = 0 then fail "empty instruction: %s" line;
    let bool_of_int_string = function
      | "0" -> false
      | "1" -> true
      | s -> fail "bool_of_int_string: unexpected: %s" s
    in
    let cmd =
      try match List.hd toks with
          | "//"             ->
            Loc.set_line line;
            warning_location := Loc.call_stack ();
            Comment
          | "LoadBuf"        -> Load_buf
          | "LoadMem"        -> Load_mem
          | "LoadAll"        -> Load_all
          | "LoadInt"        -> Load_int (Int64.of_string (List.nth toks 1))
            (* TODO: write full int types in crestify? *)
          | "BS_signed"      -> BS (Int_type.create `Signed (int_of_string (List.nth toks 1)))
          | "BS_unsigned"    -> BS (Int_type.create `Unsigned (int_of_string (List.nth toks 1)))
          | "Val_signed"     -> Val (Int_type.create `Signed (int_of_string (List.nth toks 1)))
          | "Val_unsigned"   -> Val (Int_type.create `Unsigned  (int_of_string (List.nth toks 1)))
          | "LoadStr"        -> Load_string (String.unescape (input_line file))
          | "LoadCStr"       -> Load_c_string (String.unescape (input_line file))
          | "LoadChar"       -> Load_char (List.nth toks 1).[0]
          | "LoadStackPtr"   -> Load_stack_ptr (List.nth toks 1) (* (int_of_string (List.nth toks 2)) *)
          | "Malloc"         -> Malloc
          | "In"             -> In
          | "New"            -> New
          | "Env"            -> Env (List.nth toks 1)
          | "FieldOffset"    -> Field_offset (List.nth toks 1)
          | "CtxOffset"      -> Ctx_offset (List.nth toks 1)
          | "IndexOffset"    -> Index_offset (Int_type.of_string (input_line file))
          (* | "Apply_all"       -> Apply_all (List.nth toks 1) *)
          | "Apply"          -> Apply (input_line file)
          | "Dup"            -> Dup
          | "Len"            -> Len
          | "Truth"          -> Truth
          | "InType"         -> In_type (List.nth toks 1)
          | "Nondet"         -> Apply_nondet
          (* | "Concrete_result" -> Concrete_result (Int64.of_string (List.nth toks 1)) *)
          | "Append"         -> Append
          | "Event"          -> Event (List.nth toks 1, int_of_string (List.nth toks 2))
          | "Branch"         -> Branch (bool_of_int_string (List.nth toks 1))
          | "Assume"         -> Assume
          | "Hint"           -> Hint (List.nth toks 1)
          | "TypeHint"       -> Type_hint (List.nth toks 1)
          | "SetPtrStep"     -> Set_ptr_step
          | "Done"           -> Done
          | "StoreBuf"       -> Store_buf
          | "StoreMem"       -> Store_mem
          | "StoreAll"       -> Store_all
          | "Out"            -> Out
          | "Clear"          -> Clear
          | "CopyCtx"        -> Copy_ctx
          | "Call"           -> Call (List.nth toks 1, int_of_string (List.nth toks 2))
          | "Return"         -> Return
                                (* Using failwith as this will be caught outside and fail invoked then *)
          | _                -> failwith (Printf.sprintf "execute: unknown instruction: %s" line)
      with
        | _ -> fail "wrong number of arguments or unknown instruction: %s" line
    in
    begin match cmd with
      | Call _ | Return -> ()
      | Apply s -> DEBUG "Apply %s" s
      | Load_string s -> DEBUG "LoadStr %s" (String.escaped (String.implode s))
      | _ -> DEBUG "%s" line
    end;
    DEBUG "stack depth = %s" (string_of_int (Stack.length stack));
    DEBUG "instruction %d" !done_instr;
    execute cmd;
    (* if (line <> "Indent") && (line <> "Dedent") then *)
    done_instr := !done_instr + 1;
    execute' ()
  in

  make_assumptions ();
  init_argv 5;
  try with_debug "execute" execute' () with End_of_file -> ();

  if Stack.length stack <> 1 then
    fail "Expecting a single element on stack (return of main)";

  (* return (); *)
  let iml = !iml in (* List.map deep_simplify  *)
  reset_state ();
  iml

(*************************************************)
(** {2 Execution Loop} *)
(*************************************************)
(*fun x -> Exp.truth (List.map x ~f:Exp.string)*)

let exe_file (file : in_channel) : iml =
  let iml_in: iml ref = ref [] in	
  let rec execute'' () =
    let line = input_line file in
    let toks = String.words line in
    if List.length toks = 0 then fail "empty instruction: %s" line;
    let bool_of_int_string = function
      | "0" -> false
      | "1" -> true
      | s -> fail "bool_of_int_string: unexpected: %s" s
    in
    let cmd =
      try match List.hd toks with
          | "//"             ->
            Loc.set_line line;
            warning_location := Loc.call_stack ();
	Iml.Stmt.Comment (List.nth toks 1)	
          | "in"      -> Iml.Stmt.In [Var.of_string (List.nth toks 2)]
          | "new"     -> Iml.Stmt.New (Var.of_string (List.nth toks 1), Type.of_string_bitstring (List.nth toks 2))
          | "out"     -> Iml.Stmt.Out (List.map (List.tl (List.tl toks)) ~f:Exp.var_s)
	  | "if"      -> Iml.Stmt.Test (Exp.eq_bitstring [(Exp.string (List.nth toks 1))])		
          (*| "if"      -> Iml.Stmt.Eq_test ((Exp.var_s (List.nth toks 1)), (Exp.var_s (List.nth toks 3)))*)
	  | "else"    -> Iml.Stmt.Comment (List.nth toks 0)
          | "event"   -> Iml.Stmt.Event (List.nth toks 1, (List.map (List.tl (List.tl toks)) ~f:Exp.var_s))
	  | "let"   -> Iml.Stmt.Let (Pat.vpat (List.nth toks 1), (Exp.var_s (List.nth toks 3)))		
          | _         -> failwith (Printf.sprintf "execute: unknown instruction: %s" line)
      with
        | _ -> fail "wrong number of arguments or unknown instruction: %s" line
    in
	begin 
	iml_in := !iml_in @ [cmd]
    	end;
    execute'' ()
  in

  try with_debug "execute" execute'' () with End_of_file -> ();
  
  let iml = !iml_in in
  iml


(*************************************************)
(** {1 Marshalling} *)
(*************************************************)

let raw_out : out_channel -> iml -> iml -> unit = fun c client server ->
  output_value c client;
  output_value c server;
  E.serialize_state c;
  Var.serialize_state c;
  output_value c !cur_stack_ptr_id;
  output_value c !cur_heap_ptr_id

let raw_in (c : in_channel) : iml * iml =
  let (client : iml) = input_value c in
  let (server : iml) = input_value c in
  E.deserialize_state c;
  Var.deserialize_state c;
  cur_stack_ptr_id := input_value c;
  cur_heap_ptr_id := input_value c;
  (client, server)
(*
let raw_t_out : out_channel -> string list -> iml * iml  = fun c all ->
  output_value c all;
  E.serialize_state c;
  Var.serialize_state c;
  output_value c !cur_stack_ptr_id;
  output_value c !cur_heap_ptr_id
*)
let raw_t_out : out_channel -> iml -> unit = fun c all ->
  output_value c all;
  E.serialize_state c;
  Var.serialize_state c;
  output_value c !cur_stack_ptr_id;
  output_value c !cur_heap_ptr_id

let raw_t_in (c : in_channel) : iml =
  let (all : iml) = input_value c in
  E.deserialize_state c;
  Var.deserialize_state c;
  cur_stack_ptr_id := input_value c;
  cur_heap_ptr_id := input_value c;
  (all)

(* 980 lines *)
