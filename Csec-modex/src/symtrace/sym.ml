(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common
open Printf
open Type

module Stats = Stats_local

module Cmp = struct
  type t = Lt | Gt | Le | Ge | Eq | Ne
end

module Arith = struct
  type t = Plus of int | Minus | Mult of int | Div | Neg

  let is_infix = function
    | Neg -> false
    | Plus _ | Minus | Mult _ | Div -> true

  let arity = function
    | Plus n | Mult n -> n
    | Minus | Div -> 2
    | Neg -> 1
end

module Logical = struct
  type t = And of int | Or of int | Not | Implies | True | Eq

  let is_infix = function
    | And _ | Or _ | Implies | Eq -> true
    | Not | True -> false

  let arity = function
    | And n | Or n -> n
    | Implies | Eq -> 2
    | Not -> 1
    | True -> 0
end

module Op = struct
  open Cmp
  open Arith

  type t =
    BNot                                (** Bitwise complement (~) *)
  | LNot                                (** Logical Not (!) *)

  | Op_arith of Arith.t                 (** arithmetic + *)
  | Op_cmp of Cmp.t                     (** <  (arithmetic comparison) *)

  | Plus_PI                              (** pointer + int *)

  | Minus_PI                             (** pointer - int *)
  | Minus_PP                             (** pointer - pointer *)
  | Mod                                  (** % *)

  | Shiftlt                              (** shift left *)
  | Shiftrt                              (** shift right *)

  | BAnd                                (** bitwise and *)
  | BXor                                (** exclusive-or *)
  | BOr                                 (** inclusive-or *)

  | LAnd                                (** logical and. Unlike other
                                         * expressions this one does not
                                         * always evaluate both operands. If
                                         * you want to use these, you must
                                         * set {!Cil.use_logical_operators}. *)
  | LOr                                 (** logical or. Unlike other
                                         * expressions this one does not
                                         * always evaluate both operands.  If
                                         * you want to use these, you must
                                         * set {!Cil.use_logical_operators}. *)

  | Cast_to_int
  | Cast_to_ptr
  | Cast_to_other

  let to_string = function
    | BNot -> "~"  |  LNot -> "!"

    | Mod     -> "%"   | BAnd    ->  "&"   | BOr   -> "BOR"  | BXor  -> "XOR"
    | Shiftlt -> "<<"  | Shiftrt ->  ">>"  | LAnd  -> "&&"   | LOr   -> "LOR"

    | Op_arith arith ->
      begin match arith with
      | Neg -> "neg"
      | Plus _  -> "+"
      | Minus ->  "-"
      | Mult _ -> "*"
      | Div -> "/"
      end

    | Op_cmp cmp ->
      begin match cmp with
      | Eq -> "=="
      | Ne ->  "!="
      | Gt -> ">"
      | Le -> "<="
      | Lt -> "<"
      | Ge ->  ">="
      end

    | Plus_PI  -> "PlusPI"
    | Minus_PI -> "MinusPI"
    | Minus_PP -> "MinusPP"

    | Cast_to_int -> "CastToInt"
    | Cast_to_ptr -> "CastToPtr"
    | Cast_to_other -> "CastToOther"

  let of_string = function
    | "+" -> Op_arith (Plus 2)
    | "-" -> Op_arith Minus
    | "*" -> Op_arith (Mult 2)
    | "/" -> Op_arith Div
    | "neg" -> Op_arith Neg
    | "%" -> Mod
    | "~" -> BNot     | "!" -> LNot
    | "&" -> BAnd     | "BOR" -> BOr  | "XOR" -> BXor
    | "<<" -> Shiftlt | ">>" -> Shiftrt | "&&" -> LAnd  | "LOR" -> LOr
    | "==" -> Op_cmp Eq
    | "!=" -> Op_cmp Ne
    | ">" -> Op_cmp Gt
    | "<=" -> Op_cmp Le
    | "<" -> Op_cmp Lt
    | ">=" -> Op_cmp Ge

    | "PlusPI" -> Plus_PI
    | "MinusPP" -> Minus_PP
    | "CastToInt" -> Cast_to_int
    | "CastToPtr" -> Cast_to_ptr
    | "CastToOther" -> Cast_to_other

    | s -> fail "Op.to_string: %s" s

  let latex (ts, t) = function
    | BNot -> assert false
    | LNot -> "\\lnot"

    | Mod | BAnd | BOr | BXor | Shiftlt | Shiftrt  -> assert false
    | LAnd  -> "\\&\\&"
    | LOr   -> "\\|\\|"

    | Op_arith arith ->
      let t = Type.latex t in
      begin match arith with
      | Neg -> sprintf "\\bminus{%s}" t
      | Plus _  -> sprintf "\\bplus{%s}" t
      | Minus ->  sprintf "\\bminus{%s}" t
      | Mult _ -> sprintf "\\bmult{%s}" t
      | Div -> sprintf "\\bdiv{%s}" t
      end

    | Op_cmp cmp ->
      let t = Type.latex t in
      begin match cmp with
      | Eq -> sprintf "\\bineq_{%s}" t
      | Ne -> sprintf "\\binneq_{%s}" t
      | Gt -> sprintf ">_{%s}" t
      | Le -> sprintf "\\leq_{%s}" t
      | Lt -> sprintf "<_{%s}" t
      | Ge -> sprintf "\\geq_{%s}" t
      end

    | Plus_PI
    | Minus_PI
    | Minus_PP -> assert false

    | Cast_to_int ->
      begin match ts with
      | [t'] ->
        sprintf "\\cast_{%s \\to %s}" (Type.latex t') (Type.latex t)
      | _ -> assert false
      end

    | Cast_to_ptr
    | Cast_to_other -> assert false


  let is_unary = function
    | Op_arith Neg
    | Cast_to_int
    | Cast_to_ptr
    | Cast_to_other
    | BNot
    | LNot -> true
    | _ -> false
end

type name = string
type arity = int
type invocation_id = int

type ('a, 'b) t =
  (* TODO: should take Int_type.t *)
| Op : Op.t * (bitstring, bitstring) Fun_type.t -> (bitstring, bitstring) t

| Bs_eq : (bitstring, bool) t
  (** Bitstring comparison, works on bottoms too. *)
| Cmp : (bitstring, bitstring) t
  (** Bitstring comparison returning bitstring result.  Bs_eq(x, y) = Truth(Cmp(x, y)) *)

| Int_op : Arith.t -> (int, int) t
| Int_cmp : Cmp.t -> (int, bool) t

| Logical : Logical.t -> (bool, bool) t

| Ptr_len : (_, int) t

| Malloc : int -> (int, int) t

| Cast : bitstring Type.t * bitstring Type.t -> (bitstring, bitstring) t

| Ztp : (bitstring, bitstring) t
  (**
     Zero-terminated prefix - up to but not including the first 0.
     Bottom if the bitstring does not contain zero.
  *)

| Ztp_safe : (bitstring, bitstring) t
  (**
     Same as Ztp, but returns the argument unchanged instead of bottom.
  *)

| Replicate : (bitstring, bitstring) t
  (** Field_offset is only there for CSur, in which network data is treated as a
      structure directly. We don't try to prove safety of this. *)
| Field_offset : string -> (_, int) t
| Opaque : ('a, 'a) t
  (** Used only in Solver *)
| Defined : ('a, bool) t
| In_type : 'a Type.t -> ('a, bool) t
  (** Defined is the same as (In_type Bitstring) *)

| Truth_of_bs : (bitstring, bool) t
| BS_of_truth : Int_type.width -> (bool, bitstring) t

  (* The yices versions of len and val, see thesis. *)
| Len_y : (bitstring, int) t
| Val_y : Int_type.t -> (bitstring, int) t

  (* FIXME: unify with unknown? *)
| Undef : invocation_id -> (_, bitstring) t
  (** With a tag to distinguish different undefs.
      FIXME: Do not create explicitly, use Expr.undef. *)

  (* We assume that a boolean function cannot generate a bottom from non-bottom
     arguments. *)
| Fun : name * (arity * 'b Kind.t) -> (bitstring, 'b) t

type ('a, 'b) sym = ('a, 'b) t

type bfun = (bitstring, bitstring) t

type any = Any : ('a, 'b) t -> any
type any_bitstring = Any_bitstring : (bitstring, 'b) t -> any_bitstring

let any s = Any s

let is_infix (type a) (type b) (t : (a, b) t) =
  match t with
  | Op (op, _) -> not (Op.is_unary op)

  | Int_op arith -> Arith.is_infix arith

  | Int_cmp _ -> true

  | Logical op -> Logical.is_infix op

  | Bs_eq -> true

  | _ -> false

let to_string_hum (type a) (type b) ?(show_types = true) (t: (a, b) t) =
  match t with
  | Op (op, t) ->
    if show_types
    then sprintf "(%s : %s)" (Op.to_string op) (Fun_type.to_string t)
    else sprintf "%s" (Op.to_string op)

  | Int_cmp cmp ->
    let open Cmp in
    begin match cmp with
    | Eq -> "="
    | Ne -> "<>"
    | Ge -> ">="
    | Gt -> ">"
    | Le -> "<="
    | Lt -> "<"
    end

  | Int_op op ->
    let open Arith in
    begin match op with
    | Plus _ -> "+"
    | Minus -> "-"
    | Mult _ -> "*"
    | Neg -> "-"
    | Div -> "/"
    end

  | Logical op ->
    let open Logical in
    begin match op with
    | Implies -> "=>"
    | And _ -> "/\\"
    | Or _ -> "\\/"
    | Not -> "¬"
    | True -> "True"
    | Eq -> "="
    end

  | Bs_eq -> "="
  | Ptr_len -> "ptrLen"

  | Malloc _ -> "Malloc"

  | Cast (t, t') -> "cast_" ^ Type.to_string t ^ "_" ^ Type.to_string t'

  | Ztp -> "Ztp"
  | Ztp_safe -> "ZtpSafe"

  | Truth_of_bs -> "Truth_of_bs"
  | BS_of_truth width -> sprintf "Bs_of_truth[%d]" width

  | Len_y -> "Len_y"
  | Val_y t -> sprintf "Val_y%s" (Int_type.to_string t)

  | Cmp -> "Cmp"

  | Replicate -> "Replicate"
  | Field_offset s -> sprintf "Field_offset[%s]" s
  | Opaque -> "Opaque"
  | Defined -> "Defined"
  | In_type t -> sprintf "InType[%s]" (Type.to_string t)
  | Undef i -> Printf.sprintf "Undef[%d]" i
  | Fun (s, _) ->
      (* CR-someday: enforce this *)
      (*

        let c = String.get s 0 in
        if Char.lowercase c <> c
        then fail "function names must start with lowercase letters: %s" s;
      *)
    sprintf "%s" s

let to_string t =
  to_string_hum t

(*
let to_string t =
  String.mask_digits (to_string_hum t)
*)

let latex (type a) (type b) ?(show_types = true) (t : (a, b) t) =
  match t with
  | Op (op, t) ->
    if show_types
    then assert false (* sprintf "(%s : %s)" (Op.latex op) (Fun_type.latex t) *)
    else Op.latex t op
  | Int_cmp cmp ->
    let open Cmp in
    begin match cmp with
    | Eq -> "="
    | Ne -> "\\ne"
    | Ge -> "\\geq"
    | Gt -> ">"
    | Le -> "\\leq"
    | Lt -> "<"
    end
  | Int_op op ->
    let open Arith in
    begin match op with
    | Plus _ -> "+"
    | Minus -> "-"
    | Mult _ -> "*"
    | Neg -> "-"
    | Div -> "/"
    end
  | Logical op ->
    let open Logical in
    begin match op with
    | Implies -> "\\implies"
    | And _ -> "\\wedge"
    | Or _ -> "\\vee"
    | Not -> "\\neg"
    | True -> "\\true"
    | Eq -> "\\Leftrightarrow"
    end
  | Bs_eq -> "="
  | Ptr_len -> assert false
  | Malloc _ -> assert false
  | Cast (t, t') ->
    sprintf "\\tcast_{%s \\to %s}" (Type.latex t) (Type.latex t')
  | Ztp -> assert false
  | Ztp_safe -> assert false
  | Truth_of_bs -> "\\truth"
  | BS_of_truth _width -> assert false
  | Len_y -> "\\leny"
  | Val_y _ -> assert false
  | Cmp -> assert false
  | Replicate -> assert false
  | Field_offset _ -> assert false
  | Opaque -> "\\opaque"
  | Defined -> "\\defined"
  | In_type t -> sprintf "InType[%s]" (Type.latex t)
  | Undef _ -> assert false
  | Fun (s, _) -> sprintf "\\var{%s}" s

let cv_declaration f (ts, t) =
  sprintf "%s(%s): %s"
    (to_string f)
    (String.concat ~sep:", " (List.map ~f:Type.to_string ts))
    (Type.to_string t)

let of_string s =
  if Str.string_match (Str.regexp "(\\(.+\\) *: \\(.+\\))") s 0
  then begin
    let sym = String.trim (Str.matched_group 1 s) in
    let t = Str.matched_group 2 s in
    let Fun_type.Any t = Fun_type.of_string t in
    let kind = Fun_type.kind t in
    match Option.try_with (fun () -> Op.of_string sym) with
    | None ->
        (* CR-someday: enforce this *)
        (*
          let c = String.get sym 0 in
          if Char.lowercase c <> c
          then fail "function names must start with lowercase letters: %s" sym;
        *)
        (* CR: we are discarding the types of the arguments! *)
      Any (Fun (sym, (Fun_type.arity t, kind)))
    | Some op ->
      match kind with
      | Kind.Bitstring -> Any (Op (op, t))
      | _ -> fail "Sym.of_string: %s" s
  end
  else if (Str.string_match (Str.regexp "\\(.+\\)/\\([0-9]+\\)") s 0)
  then begin
    let sym = String.trim (Str.matched_group 1 s) in
    let n = int_of_string (Str.matched_group 2 s) in
    match sym with
    | "=" -> Any Bs_eq
    | "EqInt" -> Any (Int_cmp Cmp.Eq)
    | "LeInt" -> Any (Int_cmp Cmp.Le)
    | "ptrLen" -> Any Ptr_len
    | "ztp" -> Any Ztp
    | "ztpSafe" -> Any Ztp_safe
    | "cmp" -> Any Cmp
    | "truth_of_bs" -> Any Truth_of_bs
    | s when Str.string_match (Str.regexp "bs_of_truth\\[\\(.+\\)\\]") s 0 ->
      let width = int_of_string (Str.matched_group 1 s) in
      Any (BS_of_truth width)
    | s ->
      Any (Fun (s, (n, Kind.Bitstring)))
  end
  else fail "Sym.of_string: %s" s

let of_string_bitstring s =
  let Any sym = of_string s in
  match sym with
  | Fun (_, (_, Kind.Bitstring)) as f -> f
  | sym -> fail "Sym.of_string_bitstring: %s" (to_string sym)

let may_fail (type a) (type b) (t : (a, b) t) =
  match t with
  | Ztp -> true

  | Op _ -> true
  | Val_y _ -> true

  | Field_offset _ -> false

  | Int_cmp _ -> false

  | Int_op _ -> false

  | Logical _ -> false

  | Bs_eq -> false
  | Ptr_len -> false

  | Malloc _ -> false

  | Cast _ -> false

  | Ztp_safe -> false

  | Truth_of_bs -> false
  | BS_of_truth _ -> false
  | Cmp -> false

  | Len_y -> false

  | Replicate -> false
  | Defined -> false
  | In_type _ -> false
  | Undef _ -> false
  | Opaque -> false

  | Fun (_, (_, kind)) ->
    begin match kind with
    | Kind.Bool -> false
    | _ -> true
    end

let never_fails (type a) (type b) (t : (a, b) t) =
  match t with
  | Bs_eq -> true
  | In_type _ -> true

  | Logical _ -> true

  | Defined -> true

  | Field_offset _ -> true

  | Op _ -> false
  | Ztp -> false

  | Fun _ -> false

  | Int_cmp _ -> false
  | Int_op _ -> false

  | Ptr_len -> false

  | Malloc _ -> false

  | Cast _ -> false

  | Ztp_safe -> false

  | Truth_of_bs -> false
  | BS_of_truth _ -> false
  | Cmp -> false

  | Len_y -> false
  | Val_y _ -> false

  | Replicate -> false
  | Undef _ -> false
  | Opaque -> false

let result_itype (type a) (type b) (t : (a, b) t) : Int_type.t option =
  match t with
  | BS_of_truth width -> Some (Int_type.create `Unsigned width)
  | Cast (_, Bs_int t) -> Some t
  | Op (_, (_, Bs_int t)) -> Some t
  | _ -> None

let arity  (type a) (type b) (t : (a, b) t) =
  match t with
  | Int_cmp _ -> 2

  | Int_op op -> Arith.arity op

  | Logical op -> Logical.arity op

  | BS_of_truth _ -> 1

  | Undef _ -> 0
  | Ptr_len -> 0

  | Malloc n -> n

  | Truth_of_bs -> 1
  | Ztp -> 1
  | Ztp_safe -> 1
  | Field_offset _ -> 0
  | Opaque -> 1
  | In_type _ -> 1
  | Len_y -> 1
  | Defined -> 1

  | Cmp -> 2
  | Bs_eq -> 2

  | Replicate -> 2

  | Cast _ -> 1

  | Val_y _ -> 1

  | Fun (_, (arity, _)) -> arity

  | Op (_, (ts, _)) -> List.length ts

let prime = function
  | Fun (s, n) -> Fun (s ^ "_prime", n)
  | sym -> fail "auxiliary_facts: impossible auxiliary symbol: %s" (to_string sym)

let unprime = function
  | Fun (s, meta) ->
    Option.map (String.chop_suffix s ~suffix:"_prime") ~f:(fun s -> Fun (s, meta))
  | _ -> None

(*************************************************)
(** {1 Helpers} *)
(*************************************************)

let encoder_id = ref 0
let parser_id = ref 0
let arith_id = ref 0
let auxiliary_id = ref 0

let make sym ~arity =
  Fun (sym, (arity, Kind.Bitstring))

let make_bool sym ~arity =
  Fun (sym, (arity, Kind.Bool))

let make_const sym =
  make sym ~arity:0

let new_encoder ~arity =
  make (sprintf "conc%d" (increment encoder_id)) ~arity

let new_parser () =
  make (sprintf "parse%d" (increment parser_id)) ~arity:1

let new_auxiliary ~arity =
  make_bool (sprintf "cond%d" (increment auxiliary_id)) ~arity

let new_arith ~arity =
  make (sprintf "arithmetic%d" (increment arith_id)) ~arity

(*************************************************)
(** {1 Maps} *)
(*************************************************)

let kind (type a) (type b) (sym : (a, b) sym) : b Kind.t =
  match sym with
  | Fun (_, (_, kind)) -> kind
    (* Can be added if necessary. *)
  | sym -> fail "No kind for %s" (to_string sym)

module Key = struct
  type 'a t = (bitstring, 'a) sym
  module Kind = Kind

  let kind = kind
  let to_string = to_string
end

module Map_any = Common.Map_any (Kind) (Key)

module Map (Value : GADT) = struct
  type 'a sym = (bitstring, 'a) t
  module type Map = sig
    type kind
    module Ops : Custom_map with type key = kind sym
    val value : kind Value.t Ops.t
  end
  type 'a t = (module Map with type kind = 'a)

  let mem (type a) sym t =
    let module M = (val t : Map with type kind = a) in
    M.Ops.mem sym M.value

  let add (type a) sym value t : a t =
    let module M = (val t : Map with type kind = a) in
    (module struct
      type kind = a
      module Ops = M.Ops
      let value = Ops.add sym value M.value
    end)

  let maybe_find (type a) sym t =
    let module M = (val t : Map with type kind = a) in
    M.Ops.maybe_find sym M.value

  let find (type a) sym t =
    let module M = (val t : Map with type kind = a) in
    M.Ops.find sym M.value

  let find sym t =
    Stats.call "Sym.Map.find" (fun () -> find sym t)

  let of_list (type a) xs : a t =
    (module struct
      type kind = a
      module Key = struct
        type t = kind sym
        let compare = Pervasives.compare
        let to_string = to_string
      end
      module Ops = Custom_map(Key)
      let value = Ops.of_list xs
    end)

  let to_list (type a) t =
    let module M = (val t : Map with type kind = a) in
    M.Ops.to_list M.value

  let keys t =
    to_list t |> List.map ~f:fst

  let values t =
    to_list t |> List.map ~f:snd

  (* Looks like with this implementation empty needs to take unit. *)
  let empty () = of_list []

  let is_empty (type a) t =
    let module M = (val t : Map with type kind = a) in
    M.Ops.is_empty M.value

  let singleton key value =
    add key value (empty ())

  (* The downside of this implementation is that we can't prove that Ops in two
     maps are the same, so we need to rebuild the map from scratch. That's where
     Core would be good *)
  let disjoint_union (type a) ts : a t =
    match ts with
    | [] -> empty ()
    | t :: _ as ts ->
      let module M = (val t : Map with type kind = a) in
      let bindings = List.map ts ~f:to_list |> List.concat in
      (module struct
        type kind = a
        module Ops = M.Ops
        let value =
          List.fold_left bindings ~init:Ops.empty ~f:(fun map (sym, value) ->
            if Ops.mem sym map
            then fail "Map.disjoint_union: maps are not disjoint, both contain %s"
              (to_string sym)
            else Ops.add sym value map)
      end)

  let compatible_union (type a) ts : a t =
    match ts with
    | [] -> empty ()
    | t :: _ as ts ->
      let module M = (val t : Map with type kind = a) in
      let bindings = List.map ts ~f:to_list |> List.concat in
      (module struct
        type kind = a
        module Ops = M.Ops
        let value =
          List.fold_left bindings ~init:Ops.empty ~f:(fun map (sym, value) ->
            match Ops.maybe_find sym map with
            | None -> Ops.add sym value map
            | Some value' ->
              if value = value' then Ops.add sym value map
              else fail "Map.compatible_union: key %s contains incompatible values"
                (to_string sym))
      end)

  let iter (type a) ~f t =
    let module M = (val t : Map with type kind = a) in
    M.Ops.iter f M.value

  let filter (type a) ~f t : a t =
    let module M = (val t : Map with type kind = a) in
    (module struct
      type kind = a
      module Ops = M.Ops
      let value = Ops.filter f M.value
    end)
end
