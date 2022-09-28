(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)


module List = struct
  include ListLabels

  let concat_map ~f xs = concat (map ~f xs)

  let rec sum = function
    | x :: xs -> x + sum xs
    | [] -> 0

  let sum_with f xs = sum (List.map f xs)

  let rec any = function
    | true :: _ -> true
    | false :: xs -> any xs
    | [] -> false

  let rec all = function
    | false :: _ -> false
    | true :: xs -> all xs
    | [] -> true

  let rec drop n xs =
    if n = 0 then xs
    else match xs with
    | [] -> failwith "drop: list too short"
    | _ :: xs -> drop (n - 1) xs

  let take n xs =
    let rec take n acc xs =
      if n = 0 then rev acc
      else match xs with
      | [] -> failwith "take: list too short"
      | x :: xs -> take (n - 1) (x :: acc) xs
    in
    take n [] xs

  let sub ~pos ~len xs =
    take len (drop pos xs)

  let filter_out : f:('a -> bool) -> 'a list -> 'a list = fun ~f -> List.filter (fun a -> not (f a))

  let rec filter_map: f:('a -> 'b option) -> 'a list -> 'b list = fun ~f -> function
    | [] -> []
    | x :: xs ->
      match f x with
        | Some y -> y :: filter_map ~f xs
        | None -> filter_map ~f xs

  let filter_some xs =
    filter_map xs ~f:(fun x -> x)

  let rec first_some: f:('a -> 'b option) -> 'a list -> 'b option = fun ~f -> function
    | [] -> None
    | x :: xs ->
      match f x with
        | Some y -> Some y
        | None -> first_some ~f xs

  let rec find_first ~f = function
    | x :: _ when f x -> Some x
    | _ :: xs -> find_first ~f xs
    | [] -> None

  let find_exn = find

  let rec find_map ~f = function
    | [] -> None
    | x :: xs ->
      match f x with
      | Some y -> Some y
      | None -> find_map xs ~f

  let remove : 'a -> 'a list -> 'a list = fun a ->
    filter_out ~f:(fun b -> a = b)

  let rec remove_first ~f = function
    | x :: xs when f x -> xs
    | x :: xs -> x :: remove_first ~f xs
    | [] -> []

  let find_and_remove ~f xs =
    match find_first ~f xs with
      | Some x -> Some (x, remove_first ~f xs)
      | None -> None

  let rec replicate: int -> 'a -> 'a list = fun i a ->
    if i = 0 then []
    else a :: replicate (i - 1) a

  let mem ?(equal = (=)) x ~set =
    let rec mem = function
      | x' :: _ when equal x x' -> true
      | _ :: xs -> mem xs
      | [] -> false
    in
    mem set

  let dedup ?equal xs =
    let rec dedup = function
      | (x::xs) when mem ?equal x ~set:xs -> dedup xs
      | (x::xs) -> x :: dedup xs
      | [] -> []
    in
    dedup xs

  let find_all_dups xs =
    let rec find seen = function
      | [] -> []
      | x :: xs ->
        if mem ~set:seen x then x :: find seen xs else find (x :: seen) xs
    in
    find [] xs

  let rec set_element: int -> 'a -> 'a list -> 'a list = fun i x' -> function
    | x :: xs -> if i > 0 then x :: set_element (i - 1) x' xs else x' :: xs
    | [] -> failwith "replace: index out of bounds"

  let find_index : ('a -> bool) -> 'a list -> int option = fun p xs ->
    let rec find i = function
      | [] -> None
      | x :: xs -> if p x then Some i else find (i + 1) xs
    in
    find 0 xs

  let find_index_exn : ('a -> bool) -> 'a list -> int = fun p xs ->
    match find_index p xs with
      | Some i -> i
      | None -> failwith "find_index: not found"

  (** Remove the first occurence *)
  let rec del : ('a -> 'a -> bool) -> 'a -> 'a list -> 'a list = fun eq y -> function
    | []                  -> []
    | x :: xs when eq x y -> xs
    | x :: xs             -> x :: del eq y xs

  (** Set difference *)
  let rec diff : 'a list -> 'a list -> 'a list = fun xs -> function
    | []      -> xs
    | y :: ys -> diff (remove y xs) ys

  let fold = fold_left

  (** Multiset difference *)
  let rec multidiff : ('a -> 'a -> bool) -> 'a list -> 'a list -> 'a list
    = fun eq xs -> function
    | []      -> xs
    | y :: ys -> multidiff eq (del eq y xs) ys

  let rec last : 'a list -> 'a = function
    | [x]     -> x
    | _ :: xs -> last xs
    | []      -> failwith "last: empty list"

  let rec distinct = function
    | x :: xs when List.mem x xs -> false
    | _ :: xs -> distinct xs
    | [] -> true

  (**
     The function gt specifies a directed graph on the elements: gt x x' if there is an
     edge x -> x'.

     Let x > x' be the partial ordering "x' is a descendant of x" (the transitive closure
     of the graph relation).  In the following "greater" and "smaller" refer to >.

     A list (x :: xs) is topologically sorted (in ascending order) if
     - x is not greater than any of the xs
     - xs is topologically sorted.

     Will hang if there is a cycle.

     Not stable.
  *)
  let rec topsort gt = function
    | [] -> []
    (* Let rank(x, xs) be the number of elements in xs that are smaller than x (the
       number of descendants of x in xs).  We shall prove that if the graph does not
       contain loops (no x is a descendant of itself) then topsort(x :: xs) is
       topologically sorted. The proof is by double induction on length(x :: xs) and
       rank(x, xs).  The induction also ensures termination.  *)
    | x :: xs ->
      (* Find all immediate children of x *)
      match List.partition (gt x) xs with
       (* If there are no children then x is not greater than any of the xs.  By
          induction (x :: sort xs) is topologically sorted.  *)
       | [], xs  -> x :: topsort gt xs
       (* The rank of any element x' of xs is strictly smaller than the rank of x,
          because all descendants of x' are also descendants of x, but x' is not a
          descendant of itself.  By induction sort(xs @ [x] @ xs') is topologically
          sorted. *)
       | xs, xs' -> topsort gt (xs @ [x] @ xs')

  let rec cross_product f xs ys =
    match xs with
      | x :: xs -> List.map (f x) ys @ cross_product f xs ys
      | [] -> []

end

(*************************************************)
(** {1 Assoc} *)
(*************************************************)

let maybe_assoc: 'a -> ('a * 'b) list -> 'b option = fun x xs ->
  if List.mem_assoc x ~map:xs then Some (List.assoc x xs) else None

let rec inverse_mem_assoc: 'b -> ('a * 'b) list -> bool = fun b -> function
  | (_, b') :: _ when b = b' -> true
  | _ :: xs -> inverse_mem_assoc b xs
  | [] -> false

let rec inverse_assoc: 'b -> ('a * 'b) list -> 'a = fun b -> function
  | (a, b') :: _ when b = b' -> a
  | _ :: xs -> inverse_assoc b xs
  | [] -> raise Not_found

let assoc_keys: ('a * 'b) list -> 'a list = fun l -> let l1, _ = List.split l in l1

(*************************************************)
(** {1 Strings} *)
(*************************************************)

module String = struct

  include StringLabels

  let words = Str.split (Str.regexp "[ \t]+")

  let lines = Str.split (Str.regexp "\n")

  let concat_some ts ~sep =
    List.filter_some ts
    |> function
      | [] -> None
      | ts -> Some (concat ~sep ts)

  let explode s =
    let rec exp i l =
      if i < 0 then l else exp (i - 1) (s.[i] :: l) in
    exp (String.length s - 1) [];;

  let implode l =
    let res = String.create (List.length l) in
    let rec imp i = function
      | [] -> res
      | c :: l -> res.[i] <- c; imp (i + 1) l in
    imp 0 l;;

  let unescape s =
    let is_digit c =
      List.mem c ~set:['0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9']
    in
    let rec unescape = function
      | [] -> []
      | '\\' :: d1 :: d2 :: d3 :: cs when is_digit d1 && is_digit d2 && is_digit d3 ->
        let d = implode [d1; d2; d3] in
        Char.chr (int_of_string d) :: unescape cs
      | '\\' :: _ as cs -> failwith (Printf.sprintf "unescape: %s" (implode cs))
      | c :: cs -> c :: unescape cs
    in
    unescape (explode s)

  (* [is_suffix s ~suff] returns [true] if the string [s] ends with the suffix
     [suff] *)
  let is_suffix s ~suffix =
    let len_suff = String.length suffix in
    let len_s = String.length s in
    len_s >= len_suff
    && (let rec loop i =
          i = len_suff || (suffix.[len_suff - 1 - i] = s.[len_s - 1 - i] && loop (i + 1))
        in
        loop 0)

  let is_prefix s ~prefix =
    let len_pref = String.length prefix in
    String.length s >= len_pref
    && (let rec loop i =
          i = len_pref || (prefix.[i] = s.[i] && loop (i + 1))
        in
        loop 0)
  ;;

  let wrap_sub_n t n ~name ~pos ~len ~on_error =
    if n < 0 then
      invalid_arg (name ^ " expecting nonnegative argument")
    else
      try
        sub t ~pos ~len
      with _ ->
        on_error

  let drop_prefix t n = wrap_sub_n ~name:"drop_prefix" t n ~pos:n ~len:(length t - n) ~on_error:""
  let drop_suffix t n = wrap_sub_n ~name:"drop_suffix" t n ~pos:0 ~len:(length t - n) ~on_error:""
  let prefix t n = wrap_sub_n ~name:"prefix" t n ~pos:0 ~len:n ~on_error:t
  let suffix t n = wrap_sub_n ~name:"suffix" t n ~pos:(length t - n) ~len:n ~on_error:t

  let chop_suffix s ~suffix =
    if is_suffix s ~suffix
    then Some (drop_suffix s (String.length suffix))
    else None

  let mask_digits s =
    let s =
      explode s
      |> List.filter_out ~f:(fun c ->
        List.mem c ~set:['0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'])
      |> implode
    in
    s ^ "_XYZ"

  let fail_if_masked s =
    if is_suffix s ~suffix:"XYZ"
    then assert false
    else s
end

(*************************************************)
(** {1 Stacks} *)
(*************************************************)

module Stack = struct
  include Stack

  let to_list t =
    let result = ref [] in
    Stack.iter (fun x ->
      result := x :: !result) t;
    List.rev !result
end

(*************************************************)
(** {1 IO} *)
(*************************************************)

(*
  Because pp_expr in Yices uses stdout, we redirect all our standard output to a copy of stdout,
  and redirect stdout to stderr.
*)
let out_channel = Unix.out_channel_of_descr (Unix.dup Unix.stdout)
;;
Unix.dup2 Unix.stderr Unix.stdout
;;
let print_string s = output_string out_channel s
let print_endline s = output_string out_channel (s ^ "\n")

(* FIXME: try ... with in recursive function bad, will exceed stack for very long files *)
let rec read_file : in_channel -> string list = fun file ->
  try
    let line = input_line file in
    line :: read_file file
  with End_of_file -> []

let prerr_title s =
  let s = Printf.sprintf "%s (%f)" s (Sys.time ()) in
  prerr_endline ("\n" ^ s);
  prerr_endline (String.make (String.length s) '=');
  prerr_endline ""

(*************************************************)
(** {1 Fail} *)
(*************************************************)

(** Routines to be called on failure *)
let fail_funs : (unit -> string) list ref = ref []

;;
Printexc.record_backtrace true;
;;

let fail a =
  let fail s =
    let s_extra = List.map ~f:(fun f -> f ()) !fail_funs in
    let s_extra = String.concat ~sep:"\n" s_extra in
    failwith ("failure: " ^ s ^ "\n" ^ s_extra)
  in
  Printf.ksprintf fail a

(*************************************************)
(** {1 Misc} *)
(*************************************************)

type bitstring = char list

type intval = int64
type ptr    = int64

type id = int

let non f x = not (f x)

let comp f g x = f (g x)

let (|>) x f = f x

let const x _ = x

let identity x = x

(** The range function *)
let (--) i j =
    let rec aux n acc =
      if n < i then acc else aux (n-1) (n :: acc)
    in aux j []

let never_returns _ = ()

let fold2list
    : (('k -> 'a -> 'b -> 'b) -> 'm -> 'b -> 'b)
    -> ('k -> 'a -> 'c)
  -> 'm
  -> 'c list =
  fun fold_f f m ->
    List.rev (fold_f (fun k a cs -> (f k a) :: cs) m [])

let increment : int ref -> int = fun id ->
  id := !id + 1;
  if !id = 0 then fail "fresh_id: overflow";
  !id

let test_result ~expect actual to_string =
  if expect <> actual
  then fail "Expected: \n%s\ngot \n%s\n" (to_string expect) (to_string actual)

module Option = struct
  let try_with f = try Some (f ()) with _ -> None

  let value_exn = function
    | Some a -> a
    | None -> fail "value_exn"

  let value ~default = function
    | Some a -> a
    | None -> default

  let try_with_default f ~default =
    try_with f
    |> value ~default

  let to_string a_to_string = function
    | Some a -> "Some " ^ a_to_string a
    | None -> "None"

  let all xs =
    let rec all acc = function
      | [] -> Some (List.rev acc)
      | None :: _ -> None
      | Some x :: xs -> all (x :: acc) xs
    in
    all [] xs

  let iter ~f = function
    | None -> ()
    | Some x -> f x

  let map ~f = function
    | None -> None
    | Some x -> Some (f x)

  let is_some = function
    | None -> false
    | Some _ -> true
end

module Result = struct
  module T = struct
    type ('ok, 'error) t =
    | Ok of 'ok
    | Error of 'error
  end

  include T

  let try_with f =
    try Ok (f ()) with
    | e -> Error e
end

include Result.T

module Fn = struct
  let id x = x
end

let next counter =
  let n = !counter in
  counter := n + 1;
  n

(*************************************************)
(** {1 Debug} *)
(*************************************************)

let debug_labels = ref []
(* A function that takes debug_labes and decides whether to allow debug. *)
let allow_debug = ref None
let extra_indent = ref 0

let set_debug f =
  allow_debug := Some f

let debug_enabled () =
  match !allow_debug with
  | None -> false
  | Some f -> f !debug_labels

let debug_indent () =
  (List.length !debug_labels + !extra_indent) * 2

let increase_indent () =
  extra_indent := !extra_indent + 1

let decrease_indent () =
  extra_indent := !extra_indent - 1

(**
    If this is on, the debug lines in the trace will have "(mark)" in front.
    This can be used to extract an interesting portion of the trace with grep.
 *)
let mark_enabled = ref false

let warning_location = ref ""

let decorate_debug s =
  let indent = debug_indent () in
  let mark = if !mark_enabled then "(mark)" else "" in
  let s =
    String.lines s
    |> List.map ~f:(fun s -> (String.make (max 0 indent) ' ') ^ s)
    |> String.concat ~sep:"\n"
  in
  Printf.sprintf "%s%s" mark s

(*
let debug a =
  let debug s =
    if not (debug_enabled ()) then ()
    else prerr_endline (decorate_debug s);
  in
  Printf.ksprintf debug a
*)

let push_debug label =
  debug_labels := label :: !debug_labels;
  DEBUG ">>> %s" label

let pop_debug label =
  DEBUG "<<< %s" label;
  match !debug_labels with
  | l :: labels when l = label ->
    debug_labels := labels
  | labels ->
    fail "Debug mismatch when trying to pop %s from [%s]"
      label (String.concat ~sep:"; " labels)

(**
  Locally increase debug view.
*)
let with_debug label f =
  push_debug label;
  let result = f () in
  pop_debug label;
  result

let msg tag a =
  let warn s =
    if !warning_location <> ""
    then prerr_endline (decorate_debug (tag ^ s ^ " (" ^ !warning_location ^ ")"))
    else prerr_endline (decorate_debug (tag ^ s));
    flush stderr
  in
  Printf.ksprintf warn a

let warn a = msg "WARNING: " a
let info a = msg "INFO: " a

let debug_bracket_tree : string -> unit = fun s ->
  let depth = ref 0 in

  let print = fun c ->
    match c with
        | '(' | '{' ->
        begin
          prerr_string ("\n" ^ (String.make (2 * !depth) ' '));
          depth := !depth + 1;
          prerr_string (String.make 1 c)
        end
        | ')' | '}' ->
        begin
          prerr_string (String.make 1 c);
          depth := !depth - 1;
          prerr_string ("\n" ^ (String.make (2 * !depth) ' '))
        end
        | _ -> prerr_string (String.make 1 c)
  in

  String.iter ~f:print s

(*************************************************)
(** {1 Maps and Sets} *)
(*************************************************)

module Set = struct
  module type OrderedType = Set.OrderedType
  module type S = sig
    include Set.S
    val of_list : elt list -> t
    val to_list : t -> elt list
  end

  module Make (Ord : OrderedType) = struct
    include Set.Make (Ord)

    let of_list = List.fold_left ~init:empty ~f:(fun t x -> add x t)
    let to_list = elements
  end
end

module type Custom_key = sig
  include Map.OrderedType

  val to_string: t -> string
end

module type Custom_map = sig
  include Map.S

  val of_list: (key * 'a) list -> 'a t
  val to_list : 'a t -> (key * 'a) list

  val maybe_find: key -> 'a t -> 'a option

  val disjoint_union:   'a t list -> 'a t
  val compatible_union: 'a t list -> 'a t

  val merge : f:(key -> 'a -> 'a -> 'a option) -> 'a t list -> 'a t

  val keys: 'a t -> key list
  val values: 'a t -> 'a list
end

module Custom_map (M : Custom_key): (Custom_map with type key = M.t) = struct
  include Map.Make(M)

  let of_list (bindings: (key * 'a) list): 'a t =
    List.fold_left ~f:(fun m (k, a) -> add k a m) ~init:empty bindings

  let to_list t =
    fold (fun key data l -> (key, data) :: l) t []

  let find k m =
    try find k m
    with Not_found ->
      push_debug "Custom_map.find";
      (* This isn't always an error, so using debug which can be silenced. *)
      DEBUG "key not found: %s" (M.to_string k);
      pop_debug "Custom_map.find";
      raise Not_found

  let maybe_find k m =
    if mem k m then Some (find k m) else None

  let disjoint_union ms =
    let f k a b =
      match a, b with
      | Some a, None -> Some a
      | None, Some b -> Some b
      | _ -> fail "Map.disjoint_union: maps are not disjoint, both contain %s" (M.to_string k)
    in
    List.fold_left ~f:(merge f) ~init:empty ms

  let merge ~f ts =
    let f k a b =
      match a, b with
      | None, None -> None
      | Some a, None
      | None, Some a -> Some a
      | Some a, Some b -> f k a b
    in
    List.fold_left ~f:(merge f) ~init:empty ts

  let compatible_union ts =
    let f k a b =
      if a = b then Some a
      else fail "Map.compatible_union: unequal values for %s" (M.to_string k)
    in
    merge ~f ts

  let keys m =
    let (keys, _) = List.split (bindings m) in
    keys

  let values m =
    let (_, values) = List.split (bindings m) in
    values
end

module Ptr = Int64
module Ptr_map = Custom_map (struct include Ptr let to_string = to_string end)
module Int_map = Custom_map (struct type t = int
                                    let compare = Pervasives.compare
                                    let to_string = string_of_int end)
module Str_map = Custom_map (struct include String let to_string s = s end)

(*************************************************)
(** {1 GADT} *)
(*************************************************)

module Type_equal = struct
  type ('a, 'b) t = Equal : ('a, 'a) t
end

module type Kind = sig
  type 'a t
  val equal : 'a t -> 'b t -> ('a, 'b) Type_equal.t option
end

module type GADT = sig
  module Kind : Kind
  type 'a t
  val kind : 'a t -> 'a Kind.t
end

module type GADT_key = sig
  include GADT
  val to_string : _ t -> string
end

module Map_any
  (Kind : Kind)
  (Key   : GADT_key with module Kind = Kind)
  (Value : GADT     with module Kind = Kind) :
sig
  type t
  type 'b consumer = { f : 'a. 'a Key.t -> 'a Value.t -> 'b }

  val empty : t
  val add : 'a Key.t -> 'a Value.t -> t -> t
  val maybe_find : 'a Key.t -> t -> 'a Value.t option
  val find : 'a Key.t -> t -> 'a Value.t
  val mem : 'a Key.t -> t -> bool
  val map_bindings : t -> 'b consumer -> 'b list
  val iter : t -> unit consumer -> unit
  val of_list : ('a Key.t * 'a Value.t) list -> t
  val disjoint_union : t list -> t
  val compatible_union : t list -> t
end = struct
  module Value_box = struct
    type t = Value : 'a Value.t -> t
  end
  module Key_box = struct
    type t = Key : 'a Key.t -> t
    let compare = Pervasives.compare
    let to_string (Key sym) = Key.to_string sym
  end
  module Map = Custom_map (Key_box)
  type 'a map = 'a Map.t
  include (Map : Custom_map with type key := Key_box.t
                            and type 'a t := 'a map)
  type t = Value_box.t map
  type 'b consumer = { f : 'a. 'a Key.t -> 'a Value.t -> 'b }

  open Value_box
  open Key_box

  let mem sym t =
    mem (Key sym) t

  let add sym value t =
    add (Key sym) (Value value) t

  let maybe_find (type a) (sym : a Key.t) t : a Value.t option =
    match maybe_find (Key sym) t with
    | None -> None
    | Some (Value value) ->
      match Kind.equal (Value.kind value) (Key.kind sym) with
      | None -> assert false
      | Some Type_equal.Equal -> Some value

  let find (type a) (sym : a Key.t) t : a Value.t =
    let (Value value) =  find (Key sym) t in
    match Kind.equal (Value.kind value) (Key.kind sym) with
    | None -> assert false
    | Some Type_equal.Equal -> value

  let map_bindings t {f} =
    to_list t
    |> List.map ~f:(fun (Key sym, Value value) ->
      match Kind.equal (Value.kind value) (Key.kind sym) with
      | None -> assert false
      | Some Type_equal.Equal -> f sym value)

  let iter t {f} =
    to_list t
    |> List.iter ~f:(fun (Key sym, Value value) ->
      match Kind.equal (Value.kind value) (Key.kind sym) with
      | None -> assert false
      | Some Type_equal.Equal -> f sym value)

  let of_list xs =
    List.map xs ~f:(fun (sym, value) -> (Key sym, Value value))
    |> of_list
end


(*

module type Any = sig
  type 'a t
  type any = Any : 'a t -> any

  val equal : 'a t -> 'b t -> ('a, 'b) Type_equal.t option
end

module Any_list (Any : Any) = struct
  open Any

  type any_list = Any_list : 'a t list -> any_list

  let any_list (xs : any list) : any_list option =
    let rec any_list
        : type a. a t -> a t list -> any list -> any_list option = fun x acc xs ->
      match xs with
      | [] -> Some (Any_list (x :: (List.rev acc)))
      | Any x' :: xs ->
        match Any.equal x x' with
        | None -> None
        | Some Type_equal.Equal -> any_list x (x' :: acc) xs
    in
    match xs with
    | [] -> Some (Any_list [])
    | Any x :: xs -> any_list x [] xs
end
*)

(*************************************************)
(** {1 Hashtables} *)
(*************************************************)

module Hashtbl = struct
  include Hashtbl

  let find_or_add t key ~default =
    try Hashtbl.find t key with
    | Not_found -> begin
      let data = default () in
      Hashtbl.replace t key data;
      data
    end

  let iter t ~f =
    iter f t
end
