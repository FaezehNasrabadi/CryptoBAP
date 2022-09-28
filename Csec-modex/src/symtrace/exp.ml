(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common
open Printf

module Core_map = Map
open Type
open Sym

module Stats = Stats_local

type var = Var.t

type 'a t =
| Int : intval -> int t

| Char : char -> int t
  (** An int with given ascii value. *)

| String : char list -> bitstring t

| Var : Var.t * 'a Kind.t -> 'a t

| Sym : ('a, 'b) Sym.t * 'a t list -> 'b t
  (** [Sym s es] is an application of a symbolic function [s(e1, e2, ...)].  *)

| Range : bitstring t * int t * int t -> bitstring t
  (** A substring of a given expression with given start position and length.  A
      position is a point between two characters or at the beginning or end of the
      string.  Given a string of length [l], the first position is [0], the last is
      [l].  *)

| Concat : bitstring t list -> bitstring t

| Len : bitstring t -> int t

| BS : int t * Int_type.t -> bitstring t

| Val : bitstring t * Int_type.t -> int t

| Struct
    :  (bitstring t Str_map.t) * (bitstring t Str_map.t) * int t * bitstring t
  -> bitstring t
  (** The first component are the real fields, the second are the crypto attributes.
      The last component is the value of underlying memory at the time the struct
      has been created.  This will get removed as soon as I transition to static
      implementation. *)

| Array : (bitstring t Int_map.t) * int t * int t -> bitstring t
  (** Contains total length and element length.

      A good alternative is to use native array, but it only makes sense if I know the
      number of elements in advance.  This can be done, but I don't see overwhelming
      advantages and I'm too lazy to change right now, thus sticking to a sparse
      representation.

      At some point might have to use [Map] here, if there is need to generalize indices
      to arbitrary expressions.  *)
  (* FIXME: find out how to use Map here *)

| Ptr : base * pos -> bitstring t
  (** Invariants (being reviewed):

      - The offset list is never empty.

      - The sequence of offset steps is decreasing, except that step may be
      [Unknown] for attribute offsets.

      - An attribute offset always comes last.

      - The first field or context offset is preceded by an index offset.

      - A field, context, or index offset is never preceded by a flat offset.
  *)

  (* FIXME: get rid of Unknown *)
| Unknown : 'a Kind.t -> 'a t
| Annotation : 'a annotation * 'a t -> 'a t

and 'a annotation =
| Type_hint of 'a imltype
| Name of var
(* The following annotations contain the definition of the corresponding
   symbol. *)
| Parser : bitstring t -> bitstring annotation
(* (def, c) is a parser that fails if the argument is not in the range of the
   encoder c. Only used in pvtrace. *)
| Pi_parser : (bitstring t * bfun) -> bitstring annotation
| Encoder : bitstring t -> bitstring annotation
| Auxiliary : bool t -> bool annotation
| Arith : bitstring t -> bitstring annotation

  (** Not the same as lhost in CIL *)
and base =
| Stack of string
(** (Old) Name and unique id of variable. Note that this way variables from
    different calls of the same function will be mapped to the same base, but not
    variables from different functions. *)
| Heap of (id * int t list * int t)
(* CR: what about the size of intval pointers? *)
| Abs of intval
  (** An absolute pointer value to deal with cases like:
      {[
        // signal.h:
  typedef void ( *__sighandler_t) (int);
          // signum.h:
          /* Fake signal functions.  */
            #define SIG_ERR ((__sighandler_t) -1)       /* Error return.  */
            #define SIG_DFL ((__sighandler_t) 0)        /* Default action.  */
            #define SIG_IGN ((__sighandler_t) 1)        /* Ignore signal.  */
      ]}
  *)

and offset_val =
| Field of string
| Attr of string
| Index of int (* Not intval, cause ocaml is really clumsy with that - you can't even subtract it easily *)
  (* For now flat offsets are true ints, unlike in the thesis *)
| Flat of int t
  (** Flat offsets always measured in bytes *)

  (** Offset value together with offset step *)
and offset = offset_val * int t

and pos = offset list

type 'a exp = 'a t

type iterm = int t
type bterm = bitstring t
type fact = bool t

type any = Any : 'a t -> any

(*************************************************)
(** {1 Show} *)
(*************************************************)

let show_types = ref false

  (**
    Does an expression need a bracket in context?

    In expressions "|" binds less tightly than any infix operator.
  *)
  let needs_bracket : type a. a t -> bool = function
    | Concat _ -> true
    | Sym (s, _) when Sym.is_infix s -> true
    | _ -> false

  let base_to_string : base -> string = function
    | Stack name       -> "stack " ^ name (* ^ "[" ^ string_of_int id ^ "]" *)
    | Heap (id, _, _)  -> "heap " ^ string_of_int id
    | Abs i            -> "abs " ^ Int64.to_string i

  let rec show_iexp_body : type a. a t -> string = fun t ->
    let show_types = !show_types in
    match t with
    | Int ival -> Int64.to_string ival
    | String bs ->
      let rep = List.map bs ~f:Char.escaped in
      "\"" ^ String.concat ~sep:"" rep ^ "\""
    | Char c -> sprintf "'%s'" (Char.escaped c)
    | Sym (s, es) when Sym.is_infix s && List.length es > 1 ->
      let bodies = List.map ~f:(show_iexp ~bracket:true) es in
      String.concat ~sep:(" " ^ Sym.to_string_hum ~show_types s ^ " ") bodies
    | Sym (s, es) ->
      let bodies = List.map ~f:show_iexp es in
      Sym.to_string_hum ~show_types s ^ "(" ^ String.concat ~sep:", " bodies ^ ")"
    | Range (e, f, l) ->
      let body = show_iexp ~bracket:true e in
      let f_body = show_len f in
      let l_body = show_len l in
      body ^ "{" ^ f_body ^ ", " ^ l_body ^ "}"
    | Concat [] -> "<empty concat>"
    | Concat [e] -> sprintf "<concat>(%s)" (show_iexp e)
    | Concat es ->
      let bodies = List.map ~f:show_iexp es in
      String.concat ~sep:"|" bodies
    | Ptr (b, pos) ->
      let pos_bodies = List.map ~f:(offset_to_string) pos in
        (* let (step_defs, step_body) = show_len step in *)
      let body = "<<" ^ base_to_string b ^ "; " ^ String.concat ~sep:", " pos_bodies ^ ">>"
      in body
    | Struct (fields, attrs, len, _) ->
      let show_field name e ~sep =
        sprintf "%s%s%s" name sep (show_iexp e)
      in
      let fields = fold2list Str_map.fold (show_field ~sep:": ") fields in
      let attrs = fold2list Str_map.fold (show_field ~sep:" ~> ") attrs in
      sprintf "<{%s}>[%s]" (String.concat ~sep:"; " (fields @ attrs)) (show_iexp len)
    | Array (cells, _len, _) ->
      let show_cell (i, e) =
        let cell_body = show_iexp e in
        string_of_int i ^ " ~> " ^ cell_body
      in
      begin
        match fold2list Int_map.fold (fun i e -> (i, e)) cells with
        | [0, e] -> sprintf "<array>(%s)" (show_iexp e)
        | cells ->
          let cell_bodies = List.map ~f:show_cell cells in
          "[|" ^ String.concat ~sep:"; " cell_bodies ^ "|]"
        (* ^ "<" ^ E.dump len ^ ">" *)
      end

    | Var (v, _) -> Var.to_string v

    | Len e -> "len(" ^ show_iexp_body e ^ ")"

    | BS (e, itype) -> sprintf "(%s)^%s" (show_iexp e) (Int_type.to_string itype)

    | Val (e, t) -> sprintf "(%s)_%s" (show_iexp e) (Int_type.to_string t)

    | Annotation (Type_hint t, e) ->
      show_iexp_body  e  ^ ":" ^ Type.to_string t

    | Annotation (Name name, e) ->
      sprintf "%s (* named %s *)" (show_iexp_body e) (Var.to_string name)

    | Annotation (_, e) ->
      show_iexp_body e

    | Unknown _ -> "?"

  and show_len = function
    | Int (ival) -> Int64.to_string ival
    | t -> show_iexp t

  and offset_to_string : offset -> string = function (os, step) ->
    let os_body = show_offset_val os in
    let step_body = show_iexp step in
    os_body ^ "(" ^ step_body ^ ")"

  and show_offset_val : offset_val -> string = function
    | Field s -> "field " ^ s
    | Attr s -> "attr " ^ s
    | Index i -> "index " ^ (string_of_int i)
    | Flat e -> show_iexp e

  and show_iexp : type a. ?bracket:bool ->  a t -> string = fun ?(bracket = false) t ->
    match t with
    | Var (s, _) -> Var.to_string s
    | t ->
      if bracket && (needs_bracket t) then "(" ^ show_iexp_body t ^ ")"
      else show_iexp_body t

  let list_to_string ?(newline = false) es =
    let sep = if newline then ";\n" else "; " in
    show_types := false;
    "[" ^ String.concat ~sep (List.map ~f:(show_iexp ~bracket:false) es) ^ "]"

  let to_string e =
    show_types := false;
    show_iexp ~bracket:false e

  let dump_list es =
    show_types := true;
    "[" ^ String.concat ~sep:"; " (List.map ~f:(show_iexp ~bracket:false) es) ^ "]"

  let dump e =
    show_types := true;
    show_iexp ~bracket:false e

  (*************************************************)
  (** {1 Latex} *)
  (*************************************************)

  module Wrap = struct
    type t =
      { wrap_after : int
      ; wrap_to    : int
      ; sep        : string
      }

    (* Measure lengths using strings, but wrap latexs *)
    let wrap t strings latexs =
      let rec wrap n strings latexs =
        match strings, latexs with
        | [], [] -> []
        | s :: strings, l :: latexs ->
          let slen = String.length s in
          let n = n - slen in
          if n > 0 then `Block l :: wrap n strings latexs
          else `Sep :: `Block l :: wrap (t.wrap_to - slen) strings latexs
        | _ -> assert false
      in
      let rec merge = function
        | `Block s :: `Sep :: xs ->
          (s ^ t.sep) :: merge xs
        | `Block s :: xs ->
          s :: merge xs
        | `Sep :: xs ->
          merge xs
        | [] -> []
      in
      let needs_wrap =
        List.sum (List.map strings ~f:String.length) > t.wrap_after
      in
      if not needs_wrap then latexs
      else merge (wrap t.wrap_to strings latexs)
  end

  let rec latex_iexp_body : type a. ?wrap:Wrap.t -> a t -> string = fun ?wrap t ->
    let show_types = !show_types in
    match t with
    | Int ival -> Int64.to_string ival
    | String bs ->
      let rep = List.map bs ~f:Char.escaped in
      sprintf "\\miml{\"%s\"}" (String.concat ~sep:"" rep)
    | Char c -> sprintf "\\miml{'%s'}" (Char.escaped c)
    | Sym (s, es) when Sym.is_infix s ->
      let bodies = List.map ~f:(latex_iexp ~bracket:true) es in
      if bodies = []
      then Sym.latex ~show_types s ^ "()"
      else begin
        let bodies =
          match wrap with
          | None -> bodies
          | Some wrap ->
            let strings = List.map ~f:(show_iexp ~bracket:true) es in
            Wrap.wrap wrap strings bodies
        in
        String.concat ~sep:(" " ^ Sym.latex ~show_types s ^ " ") bodies
      end
    | Sym (s, es) ->
      let bodies = List.map ~f:latex_iexp es |> String.concat ~sep:", "  in
      begin match s with
      | Val_y itype ->
        sprintf "\\val{%s}{%s}" bodies (Int_type.latex ~y:true itype)
      | Logical Logical.True ->
        Sym.latex s
      | s ->
        sprintf "%s(%s)" (Sym.latex ~show_types s) bodies
      end
    | Range (e, f, l) ->
      let body = latex_iexp ~bracket:true e in
      let f_body = latex_iexp f in
      let l_body = latex_iexp l in
      body ^ "\\{" ^ f_body ^ ", " ^ l_body ^ "\\}"
    | Concat [] -> "\\emptybs"
    | Concat es ->
      let bodies = List.map ~f:latex_iexp es in
      String.concat ~sep:"\\encoder" bodies
    | Ptr _ -> assert false
    | Struct _ -> assert false
    | Array _ -> assert false
    | Var (v, _) -> sprintf "\\var{%s}" (Var.to_string v)
    | Len e -> "\\len(" ^ latex_iexp_body e ^ ")"
    | BS (e, itype)  -> sprintf "\\bs{%s}{%s}"  (latex_iexp e) (Int_type.latex itype)
    | Val (e, itype) -> sprintf "\\val{%s}{%s}" (latex_iexp e) (Int_type.latex itype)
    | Annotation _ ->
      assert false
    (* latex_iexp_body  e  ^ ":" ^ Type.latex t *)
    | Unknown _ -> assert false

  and latex_iexp : type a. ?bracket:bool -> ?wrap:Wrap.t ->  a t -> string =
                     fun ?(bracket = false) ?wrap t ->
    match t with
    | Var _ -> latex_iexp_body ?wrap t
    | t ->
      if bracket && (needs_bracket t) then "(" ^ latex_iexp_body ?wrap t ^ ")"
      else latex_iexp_body ?wrap t

  let latex ?wrap e =
    show_types := false;
    latex_iexp ~bracket:false ?wrap e

  (*************************************************)
  (** {1 Traversal} *)
  (*************************************************)

  type 'b map = { f : 'a. 'a t -> 'b }
  type descend = { descend : 'a. 'a t -> 'a t }

  (**
     Does not include lengths for non-range expressions.
  *)
  let map_children (type a) { f } (t : a t) =
    match t with
    | Sym (_, es) -> List.map ~f es
    | Range (e, pos, len) -> [f e; f pos; f len]
    | Concat es -> List.map ~f es
    | Annotation(_, e) -> [f e]
    | Len e -> [f e]
    | BS (e, _) -> [f e]
    | Val (e, _) -> [f e]
    | Var _ -> []
    | Int _ -> []
    | String _ -> []
    | Char _ -> []
    | Struct _ -> []
    | Array _ -> []
    | Ptr _ -> []
    | Unknown _ -> []

  let iter_children map t =
    ignore (map_children map t)

  (**
     Not going into lengths for non-range expressions.
  *)
  let descend (type a) { descend } (t : a t) : a t =
    match t with
    | Var _ -> t
    | String _ -> t
    | Char _ -> t
    | Int _ -> t
    | Unknown _ -> t
    | Ptr _ -> t
    | Len e ->
      let e' = descend e in
      if e == e' then t
      else Len e'
    | Val (e, itype) ->
      let e' = descend e in
      if e == e' then t
      else Val (e', itype)
    | BS (e, itype) ->
      let e' = descend e in
      if e == e' then t
      else BS (e', itype)
    | Sym (sym, es) ->
      let es' = List.map ~f:descend es in
      if List.for_all2 es es' ~f:(==) then t
      else Sym (sym, es')
    | Range (e, pos, len) ->
      let e' = descend e in
      let pos' = descend pos in
      let len' = descend len in
      if e == e' && pos == pos' && len = len' then t
      else Range  (e', pos', len')
    | Concat es ->
      let es' = List.map ~f:descend es in
      if List.for_all2 es es' ~f:(==) then t
      else Concat es'
    | Struct (fields, attrs, len, e_old) ->
      Struct (Str_map.map descend fields, Str_map.map descend attrs, descend len, e_old)
    | Array (cells, len, step) ->
      Array (Int_map.map descend cells, len, step)
    | Annotation(a, e) ->
      let e' = descend e in
      if e == e' then t
      else Annotation(a, e')

  let rec vars : type a. a t -> Var.t list = function
    | Var (v, _) -> [v]
    | t ->
      map_children {f = vars} t |> List.concat |> List.dedup

  let refcount v =
    let rec refcount : type a. a t -> int = function
      | Var (v', _) when v = v' -> 1
      | t -> map_children {f = refcount} t |> List.sum
    in
    refcount

  (*************************************************)
  (** {1 Well-formedness} *)
  (*************************************************)

  let rec type_of : type a. a t -> a Type.t option = function
    | Int _ -> Some Type.Int
    | Char _ -> Some Type.Int
    | Val _ -> Some Type.Int
    | Len _ -> Some Type.Int
    | Var _ -> None
    | String _ -> Some Type.Bitstring
    | Range _ -> None
    | Concat _ -> Some Type.Bitstring
    | Struct _ -> Some Type.Bitstring
    | Array _ -> Some Type.Bitstring
    | BS (_, itype) -> Some (Type.Bs_int itype)
    | Ptr _ -> Some Type.Ptr
    | Sym (Op (_, (_, t)), _) -> Some t
    | Sym _ -> None
    | Unknown _ -> None
    | Annotation (_, e) -> type_of e

  let invariant e_top =
    let rec invariant : type a. a t -> unit = function
      | Sym (Op (_, (ts, _)), es) ->
        List.iter2 ts es ~f:(fun t e ->
          Option.iter (type_of e) ~f:(fun e_t ->
            if not (Type.subtype e_t t)
            then fail "Wrong type of %s in %s, has %s, expected %s"
             (to_string e) (to_string e_top)
             (Type.to_string e_t)  (Type.to_string t)));
        List.iter ~f:invariant es
      | e -> iter_children {f = invariant} e
    in
    invariant e_top

  let itype = function
    | Sym (sym, _) -> Sym.result_itype sym
    (* | String bs -> Some (`Unsigned, List.length bs)
    | BS (_, itype) -> Some itype *)
    | Val (_, itype) -> Some itype
    | _ -> None

  let itype_exn t =
    match itype t with
    | Some t -> t
    | None -> fail "expression itype undefined: %s" (to_string t)

  let rec kind : type a. a t -> a Kind.t = fun e ->
    let module K = Kind in
    match e with
    | Int _ -> K.Int
    | Char _ -> K.Int
    | Unknown kind -> kind
    | String _ -> K.Bitstring
    | Var (_, kind) -> kind
    | Range _ -> K.Bitstring
    | Concat _ -> K.Bitstring
    | Len _ -> K.Int
    | BS _ -> K.Bitstring
    | Val _ -> K.Int
    | Struct _ -> K.Bitstring
    | Array _ -> K.Bitstring
    | Ptr _ -> K.Bitstring
    | Annotation (_, e) -> kind e
    | Sym (sym, es) ->
      match sym with
      | Int_op _ -> K.Int
      | Ptr_len -> K.Int
      | Len_y -> K.Int
      | Val_y _ -> K.Int
      | Field_offset _ -> K.Int
      | Malloc _ -> K.Int

      | Defined -> K.Bool
      | In_type _ -> K.Bool
      | Int_cmp _ -> K.Bool
      | Logical _  -> K.Bool
      | Truth_of_bs -> K.Bool
      | Bs_eq -> K.Bool

      | BS_of_truth _ -> K.Bitstring
      | Undef _ -> K.Bitstring
      | Ztp -> K.Bitstring
      | Ztp_safe -> K.Bitstring
      | Cmp -> K.Bitstring
      | Replicate -> K.Bitstring
      | Cast _ -> K.Bitstring
      | Op _ -> K.Bitstring

      | Fun (_, (_, kind)) -> kind

      | Opaque ->
        match es with
        | [e] -> kind e
        | _ ->
          fail "E.kind: wrong number of opaque args: %s" (to_string e)

   let coerce (type a) (type b) (k : a Kind.t) (e : b t) : a t option =
     match Kind.equal (kind e) k with
     | Some Type_equal.Equal -> Some e
     | None -> None

  let equal (type a) (type b) (t1 : a t) (t2 : b t) : (a, b) Type_equal.t option =
    match Kind.equal (kind t1) (kind t2) with
    | None -> None
    | Some Type_equal.Equal ->
      if t1 = t2 then Some Type_equal.Equal else None

  let phys_equal (type a) (type b) (t1 : a t) (t2 : b t) : (a, b) Type_equal.t option =
    match Kind.equal (kind t1) (kind t2) with
    | None -> None
    | Some Type_equal.Equal ->
      if t1 == t2 then Some Type_equal.Equal else None

  (*************************************************)
  (** {1 Collections} *)
  (*************************************************)

  module Kind = Kind

  module Any = struct
    type t = any
    let compare = Pervasives.compare
    let to_string (Any e) = to_string e
  end

  module Base = struct
    type t = base
    let compare = Pervasives.compare
  end

  module Base_map = Core_map.Make (Base)

  module Fact_set = Set.Make (struct
    type t = fact
    let compare = compare
  end)

  module Set = struct
    type 'a exp = 'a t
    include Set.Make (Any)

    let add exp set = add (Any exp) set
    let mem exp set = mem (Any exp) set
  end

  module Key = struct
    type 'a t = 'a exp
    module Kind = Kind
    let kind = kind
    let to_string = to_string
  end

  module Map_any = Common.Map_any (Kind) (Key)

  (*************************************************)
  (** {1 IDs} *)
  (*************************************************)

  module Map = struct
    include Custom_map(Any)

    let add exp map value = add (Any exp) map value
    let maybe_find exp map = maybe_find (Any exp) map
  end

  let ids = ref Map.empty
  let last_id = ref 0

  let id e =
    match Map.maybe_find e !ids with
    | Some id -> id
    | None ->
      let id = increment last_id in
      ids := Map.add e id !ids;
      id

  let reset_ids () =
    ids := Map.empty;
    last_id := 0

  let serialize_state c =
    output_value c !ids;
    output_value c !last_id

  let deserialize_state c =
    ids := input_value c;
    last_id := input_value c

  (*************************************************)
  (** {1 Cryptographic Expressions} *)
  (*************************************************)

  let rec is_cryptographic = function
    | Var _ -> true
    | Range _ -> true
    | Concat _ -> true
    | Sym (Fun _, _) -> true
    | Annotation (_, e) -> is_cryptographic e
    | _ -> false


  (*************************************************)
  (** {1 Arithmetics} *)
  (*************************************************)

  let zero = Int 0L
  let one  = Int 1L

  let sum = function
    | [] -> zero
    | [e] -> e
    | es -> Sym (Sym.Int_op (Sym.Arith.Plus (List.length es)), es)

  let minus a b =
    Sym (Int_op Arith.Minus, [a; b])

  let prod = function
    | [] -> one
    | [e] -> e
    | es ->
      Sym (Sym.Int_op (Sym.Arith.Mult (List.length es)), es)

  let arith_simplify_eq eq want_fold (e : iterm) =
    let open Sym.Arith in

    let simplify_sums (e : iterm) =
      match e with
      | Sym ((Int_op (Plus _ | Minus)), es) as e ->

        let elim_zero es = List.filter_out ~f:(eq zero) es in

        (* The proper way is to make the SMT solver perform the operation *)
        let mk_op (n : int64) = function
          | (sign, Int m) -> Int64.add n (Int64.mul (Int64.of_int sign) m)
          | _             -> fail "mk_op: not an integer"
        in

        let rec signs sign (e : iterm) =
          match e with
          | Sym (Int_op (Plus _), es)  -> List.concat_map ~f:(signs sign) es
          | Sym (Int_op Minus, [a; b]) -> (signs sign a) @ (signs (-1 * sign) b)
          | e -> [(sign, e)]
        in

        let split (e : iterm) : iterm list * iterm list =
          let es = signs 1 e in
          let (e_int, e_sym) =
            if want_fold
            then List.partition ~f:(function (_, Int _) -> true | _ -> false) es
            else ([], es)
          in
          let (e_pos, e_neg) =
            List.partition ~f:(function (sign, _) -> sign = 1) e_sym
          in
          let c_int = List.fold_left ~f:mk_op ~init:0L e_int in
          ((if c_int = 0L then [] else [Int c_int])
           @ List.map ~f:snd e_pos, List.map ~f:snd e_neg)
        in

        let (e_pos, e_neg) = split e in
        begin
          match (elim_zero (List.multidiff eq e_pos e_neg),
                 elim_zero (List.multidiff eq e_neg e_pos)) with
          | (e_pos', [])    -> sum e_pos'
          | (e_pos', e_neg') -> Sym (Int_op Minus, [sum e_pos'; sum e_neg'])
        end

      | e -> e
    in

    (* TODO: deal with it like you deal with addition *)
    let elim_one = function
      | Sym (Int_op (Mult _), es) ->
        prod (List.filter_out ~f:(eq one) es)
      | e -> e
    in

    DEBUG "arith_simplify: %s" (dump e);
    e (* |> simplify_sums Plus_a Minus_a  *) |> simplify_sums |> elim_one

  (* Not using equal_int as equality, in order not to trigger extra warnings *)
  let arith_simplify = arith_simplify_eq (=) false

  let sum es = arith_simplify (sum es)
  let prod es = arith_simplify (prod es)
  let minus e1 e2 = arith_simplify (minus e1 e2)

  (*************************************************)
  (** {1 Pointers} *)
  (*************************************************)

  let ptr_size = function
    | Stack _ -> None
    | Heap (_, _, l) -> Some l
    | Abs _ -> None

  let malloc_expr es =
    Sym (Malloc (List.length es), es)

  let is_zero_offset_val : offset_val -> bool = function
    | Index 0 -> true
    | Flat z when z = zero -> true
    (* | Flat z when S.equal_int E.zero z -> true *)
    | _ -> false

  let is_zero_pos =
    List.for_all ~f:(fun (offset, _) -> is_zero_offset_val offset)

  let is_field_offset_val : offset_val -> bool = function
    | Field _ -> true
    | _ -> false

  (*************************************************)
  (** {1 Misc} *)
  (*************************************************)

  let encoder es = Concat es

  let range e f l = Range (e, f, l)

  let var_s v = Var (Var.of_string v, Kind.Bitstring)

  let var v = Var (v, Kind.Bitstring)

  let int i = Int (Int64.of_int i)

  let string s = String (String.explode s)

  let zero_byte =
    BS (Int 0L, (Int_type.create `Signed 1))

  let rec is_constant : type a. a t -> bool = function
    (* CR: think more about this. *)
    | Sym (Field_offset _, []) -> false
    | Var _ -> false
    | Ptr (Heap _, _) -> false
    | e -> map_children {f = is_constant} e |> List.all

  let is_tag = is_constant

  let rec is_constant_integer_expression (t : iterm) =
    match t with
    | Int _ -> true
    | Sym (Int_op _, es) -> List.for_all es ~f:is_constant_integer_expression
    | _ -> false

  let is_constant_integer_fact = function
    | Sym (Int_cmp _, es) -> List.for_all es ~f:is_constant_integer_expression
    | _ -> false

  let contains_sym s =
    let rec contains_sym : type c. c t -> bool = function
      | Sym (s', _) when Sym.any s' = Sym.any s -> true
      | e -> map_children {f = contains_sym} e |> List.any
    in
    contains_sym

  let subst : type a b. Var.t list -> b t list -> a t -> a t = fun vs es ->
    let rec subst : type a. a t -> a t = function
      | Var (v, k) ->
        begin match List.find_index (fun v' -> v = v') vs with
        | None -> Var (v, k)
        | Some i ->
          let e = List.nth es i in
          match Kind.equal k (kind e) with
          | Some Type_equal.Equal -> e
          | None -> fail "subst: wrong kind"
        end
      | t -> descend {descend = subst} t
    in
    subst

  let subst vs es =
    Stats.call "E.subst" (fun () -> subst vs es)

  let subst_v vs vs' e = subst vs (List.map ~f:var vs') e

  let subst_v vs vs' =
    Stats.call "E.subst_v" (fun () -> subst_v vs vs')

  let rec remove_annotations : type a. a t -> a t = function
    | Annotation(_, e) -> remove_annotations e
    | e -> descend {descend = remove_annotations} e

  let len e = Len e

  let apply (type a) (type b) (sym : (a, b) Sym.t) (es : any list) : b t =
    let list_to_string es =
      List.map es ~f:(fun (Any e) -> to_string e)
      |> String.concat ~sep:","
    in
    if List.length es <> Sym.arity sym
    then fail "Apply: arity mismatch: %s(%s)" (Sym.to_string sym) (list_to_string es);
    match es with
    | [] -> Sym (sym, [])
    | (Any e) :: _ ->
      let module K = Kind in
      let apply (sym : (a, b) Sym.t) (kind : a Kind.t) : b t =
        List.map es ~f:(fun (Any e) -> coerce kind e)
        |> Option.all
        |> function
          | None -> fail "Apply: arguments not of the same kind: %s" (list_to_string es)
          | Some es -> Sym (sym, es)
      in
      let kind = kind e in
      let apply_with_kind (sym : (a, b) Sym.t) (k : a Kind.t) : b t =
        match Kind.equal k kind with
        | Some Type_equal.Equal -> apply sym kind
        | None ->
          fail "Apply: kind mismatch: %s(%s)" (Sym.to_string sym) (list_to_string es)
      in
      match sym, kind with
      | Int_op _, K.Int -> apply sym kind
      | Ptr_len, _ -> assert false
      | Len_y, K.Bitstring -> apply sym kind
      | Val_y _, K.Bitstring -> apply sym kind
      | Field_offset _, _ -> assert false

      | Defined, _ -> Sym (Defined, [e])
      | In_type t, _ -> apply_with_kind sym (Type.kind t)
      | Int_cmp _, K.Int -> apply sym kind
      | Logical _ , K.Bool -> apply sym kind
      | Truth_of_bs, K.Bitstring -> apply sym kind
      | Bs_eq, K.Bitstring -> apply sym kind

      | BS_of_truth _, K.Bool -> apply sym kind
      | Undef _, _ -> assert false
      | Ztp, K.Bitstring -> apply sym kind
      | Ztp_safe, K.Bitstring -> apply sym kind
      | Cmp, K.Bitstring -> apply sym kind
      | Replicate, K.Bitstring -> apply sym kind
      | Cast _, K.Bitstring -> apply sym kind
      | Op _, K.Bitstring -> apply sym kind

      | Opaque, _ -> fail "Apply: Opaque not supported"

      | Fun _, _ -> apply_with_kind sym Kind.Bitstring

      | _ -> fail "Apply: kind mismatch: %s(%s)" (Sym.to_string sym) (list_to_string es)

  let rec unfold : type a. a exp -> a exp = fun e ->
    let e =
      match e with
      | Var (x, kind) -> Var (x, kind)
      | String s -> String s
      | Char c -> Char c
      | Int n -> Int n
      | e -> e
    in
    descend { descend = unfold } e

  (*************************************************)
  (** {1 Facts} *)
  (*************************************************)

  let eq_bitstring es = Sym (Bs_eq, es)
  let eq_int es = Sym (Int_cmp Cmp.Eq, es)
  let gt a b = Sym (Int_cmp Cmp.Gt, [a; b])
  let ge a b = Sym (Int_cmp Cmp.Ge, [a; b])

  let true_fact: fact = Sym (Logical Logical.True, [])

  let is_defined e = Sym (Defined, [e])

  let negation (e : fact) : fact =
    match e with
    | Sym (Logical Logical.Not, [e]) -> e
    | e -> Sym (Logical Logical.Not, [e])

  let conj es = Sym (Sym.Logical (Sym.Logical.And (List.length es)), es)
  let disj es = Sym (Sym.Logical (Sym.Logical.Or  (List.length es)), es)

  let rec flatten_conj (e : fact) =
    let open Sym.Logical in
    match e with
    | Sym (Logical And _, es) -> List.concat_map ~f:flatten_conj es
    | Sym (Logical True, []) -> []
    | e -> [e]

  let implication es1 es2 =
    Sym (Logical Logical.Implies, [conj es1; conj es2])

  let rec in_type (e : bterm) (t : bitstring Type.t) : fact =
    let module T = Type in
    match t with
    | T.Bitstringbot -> true_fact
    | T.Bitstring    -> is_defined e
    | T.Fixed n      -> eq_int [int n; Len e]
    | T.Bounded n    -> ge (int n) (Len e)
    | T.Bs_int _ | T.Ptr ->
      begin match e with
      | Sym (Op (_, (_, t')), _) when t = t' -> is_defined e
      | e -> Sym (In_type t, [e])
       (* fail "%s" (E.to_string (Sym (In_type t, [e]))) *)
      end
    | T.Named (_, Some t) -> in_type e t
    | T.Named (_, None) -> Sym (In_type t, [e])

  (* TODO: Consider making this part of Solver.rewrite *)
  let rec truth (e : bterm) : fact =
    let exp_to_string = dump in
    let open Sym in
    let open Op in
    let open Logical in
    match e with
    | Sym (BS_of_truth _, [e]) -> e
    | BS (Int i, _) ->
      if i = 0L
      then Sym (Logical Not, [Sym (Logical True, [])])
      else Sym (Logical True, [])
    | Ptr _ as p -> Sym (Truth_of_bs, [p])
    | Sym (Op (LAnd, _), es) -> conj (List.map ~f:truth es)
    | Sym (Op (LOr, _), es) -> disj (List.map ~f:truth es)
    | Sym (Op (LNot, _), [e]) -> Sym (Logical Not, [truth e])
    | Sym (Op (Op_cmp _, _), _) as e -> Sym (Truth_of_bs, [e])
    | Sym (Cmp, [e1; e2]) -> Sym (Logical Not, [Sym (Bs_eq, [e1; e2])])
    | Var _ as e -> Sym (Truth_of_bs, [e])
    | Sym (Fun _, _) as e -> Sym (Truth_of_bs, [e])
    | e -> fail "Exp.truth: unexpected: %s" (exp_to_string e)


  (*
    We don't represent integer ranges directly because they are too big for OCaml int64.
  *)
  module Range = struct
    type t = Int_type.t

    (* Don't raise to the power explicitly, to avoid overflow *)
    let pow a n =
      if n = 0 then one
      else prod (List.replicate n (int a))

    let subset itype itype' =
      (Int_type.signedness itype = Int_type.signedness itype'
      && Int_type.width itype <= Int_type.width itype')
      || (Int_type.signedness itype = `Unsigned
         && Int_type.width itype <= Int_type.width itype' - 1)

    let get_itype = itype

    let contains itype e =
      match get_itype e with
      | Some itype' when subset itype' itype -> [true_fact]
      | _ ->
        let w = Int_type.width itype in
        let a, b = match Int_type.signedness itype with
          | `Unsigned ->
            let n = pow 256 w in
            zero, Sym (Int_op Arith.Minus, [n; int 1])
          | `Signed ->
            let n = prod [int 128; pow 256 (w - 1)] in
            Sym (Int_op Arith.Neg, [n]), Sym (Int_op Arith.Minus, [n; int 1])
        in
        [Sym (Int_cmp Cmp.Ge, [e; a]); Sym (Int_cmp Cmp.Le, [e; b])]
  end

(********************************************************)
(** {1 Function Definitions} *)
(********************************************************)

let show_fun sym def =
  Sym.to_string sym ^ " := " ^ (to_string def)

module Sym_defs = struct
  include Sym.Map(Key)

  (**
     We represent a lambda expression with n arguments by an expression containing variables
     (mk_arg 0) to (mk_arg (n - 1)).
  *)
  type 'a def = 'a exp

  let to_string t =
    to_list t
    |> List.map ~f:(fun (sym, def) -> show_fun sym def)
    |> String.concat ~sep:"\n"

  let to_string_opt t =
    if is_empty t then None
    else Some (to_string t)

  let print t =
    prerr_endline "";
    prerr_endline (to_string t);
    prerr_endline ""
end

let mk_arg id = Var.of_string ("arg" ^ string_of_int id)

let mk_arg_len id =
  Len (var (mk_arg id))

let mk_formal_args n = List.map ~f:mk_arg (0 -- (n - 1))

let is_def_annotation (type a) (ann : a annotation) =
  match ann with
  | Parser _ -> true
  | Pi_parser _ -> true
  | Encoder _ -> true
  | Arith _ -> true
  | Auxiliary _ -> true
  | Type_hint _ -> false
  | Name _ -> false

let rec parsers : type a. a t -> bitstring Sym_defs.t = function
  | Annotation (Parser def, Sym (Fun _ as f, es)) ->
    Sym_defs.disjoint_union
      (Sym_defs.singleton f def :: List.map es ~f:parsers)
  | e ->
    map_children { f = parsers } e
    |> Sym_defs.disjoint_union

let rec encoders : type a. a t -> bitstring Sym_defs.t = function
  | Annotation (Encoder def, Sym (Fun _ as f, es)) ->
    Sym_defs.disjoint_union
      (Sym_defs.singleton f def :: List.map es ~f:encoders)
  | e ->
    map_children { f = encoders } e
    |> Sym_defs.disjoint_union

let rec arith : type a. a t -> bitstring Sym_defs.t = function
  | Annotation (Arith def, Sym (Fun _ as f, es)) ->
    Sym_defs.disjoint_union
      (Sym_defs.singleton f def :: List.map es ~f:arith)
  | e ->
    map_children { f = encoders } e
    |> Sym_defs.disjoint_union

let rec auxiliary : type a. a t -> bool Sym_defs.t = function
  | Annotation (Auxiliary def, Sym (Fun _ as f, es)) ->
    Sym_defs.disjoint_union
      (Sym_defs.singleton f def :: List.map es ~f:auxiliary)
  | e ->
    map_children { f = auxiliary } e
    |> Sym_defs.disjoint_union

let defs_to_string (type a) (t : a t) =
  [ Sym_defs.to_string_opt (parsers t)
  ; Sym_defs.to_string_opt (encoders t)
  ; Sym_defs.to_string_opt (auxiliary t)
  ; Sym_defs.to_string_opt (arith t)
  ]
  |> String.concat_some ~sep:"\n"

(* CR-soon: make an exhaustive annotation list. *)
let rec expand_defs : type a. a t -> a t = function
  | Annotation (Parser def, Sym (_, es)) ->
    let xs = mk_formal_args (List.length es) in
    subst xs es def
  | Annotation (Pi_parser (def, _), Sym (_, es)) ->
    let xs = mk_formal_args (List.length es) in
    subst xs es def
  | Annotation (Encoder def, Sym (_, es)) ->
    let xs = mk_formal_args (List.length es) in
    subst xs es def
  | Annotation (Arith def, Sym (_, es)) ->
    let xs = mk_formal_args (List.length es) in
    subst xs es def
  | Annotation (Auxiliary def, Sym (_, es)) ->
    let xs = mk_formal_args (List.length es) in
    subst xs es def
  | e -> descend { descend = expand_defs } e
