(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common
open Printf

module Kind = struct
  type 'a t =
  | Bool : bool t
  | Int : int t
  | Bitstring : bitstring t

  let equal (type a) (type b) (t1 : a t) (t2 : b t) : (a, b) Type_equal.t option =
    let open Type_equal in
    match t1, t2 with
    | Bitstring, Bitstring -> Some Equal
    | Bool, Bool           -> Some Equal
    | Int, Int             -> Some Equal
    | _                    -> None

  let to_string (type a) (t : a t) =
    match t with
    | Bool -> "Bool"
    | Int -> "Int"
    | Bitstring -> "Bitstring"
end

module Int_type = struct
  module Signedness = struct
    type t = [ `Signed | `Unsigned ]

    let to_string = function
      | `Signed -> "s"
      | `Unsigned -> "u"
  end
  type signedness = Signedness.t
  type width = int

  type t = signedness * width

  let to_string (sd, w) =
    match sd with
    | `Signed -> sprintf "[s,%d]" w
    | `Unsigned -> sprintf "[u,%d]" w

  let of_string s =
    let s = String.trim s in
    let toks = Str.split (Str.regexp "[][,]") s in
    match toks with
    | ["u"; w] ->  (`Unsigned, int_of_string w)
    | ["s"; w] ->  (`Signed,   int_of_string w)
    | _ -> fail "Int_type.of_string: %s" s

  let latex ?(y = false) (s, w) =
    if y
    then match s with
    | `Signed   -> sprintf "\\mkitypey{S}{%d}" w
    | `Unsigned -> sprintf "\\mkitypey{U}{%d}" w
    else match s with
    | `Signed   -> sprintf "\\mkitype{S}{%d}" w
    | `Unsigned -> sprintf "\\mkitype{U}{%d}" w

  let invariant (_, w) =
    if w = 0
    then fail "Int_type: width cannot be 0"

  let () = Cil.initCIL ()

  let int =
    match Cil.intType with
    | Cil.TInt (ikind, _) -> (`Signed, Cil.bytesSizeOfInt ikind)
    | _ -> assert false

  let size_t =
    (* TODO: check that this is the right type *)
    match !Cil.typeOfSizeOf with
    | Cil.TInt (ikind, _) -> (`Unsigned, Cil.bytesSizeOfInt ikind)
    | _ -> assert false

  let ptr =
    let bit_size = Cil.bitsSizeOf Cil.voidPtrType in
    if bit_size mod 8 <> 0 then assert false;
    (`Unsigned, bit_size / 8)

  let signedness (s, _) = s
  let width (_, w) = w
  let create s w =
    let t = (s, w) in
    invariant t;
    t
end

type 'a t =
| Bitstringbot : bitstring t               (** All strings and bottom. *)
| Bitstring : bitstring t                  (** All machine-representable strings *)
| Fixed : int -> bitstring t               (** All strings of a given length *)
| Bounded : int -> bitstring t             (** All strings up to a given length *)
| Ptr : bitstring t
| Bs_int : Int_type.t -> bitstring t
  (* A named type with an optional type definition. Named (_, None) may not contain
     bottom. *)
| Named : string * bitstring t option -> bitstring t
| Bool : bool t
| Int : int t

type 'a imltype = 'a t

let kind (type a) (t : a t) : a Kind.t =
  match t with
  | Bitstringbot      -> Kind.Bitstring
  | Bitstring         -> Kind.Bitstring
  | Fixed _           -> Kind.Bitstring
  | Bounded _         -> Kind.Bitstring
  | Ptr               -> Kind.Bitstring
  | Bs_int _          -> Kind.Bitstring
  | Named _           -> Kind.Bitstring
  | Bool              -> Kind.Bool
  | Int               -> Kind.Int

type any = Any : 'a t -> any

let of_string_bitstring s =
  try Bs_int (Int_type.of_string s)
  with _ ->
    match List.map ~f:String.trim (Str.bounded_split (Str.regexp "_") s 3) with
    | ["bitstringbot"]     -> Bitstringbot
    | ["bitstring"]        -> Bitstring
    | ["bitstring"; name]  -> Named (name, Some Bitstring)
    | ["fixed"; n]         -> Fixed (int_of_string n)
    | ["fixed"; n; name]   -> Named (name, Some (Fixed (int_of_string n)))
    | ["bounded"; n]       -> Bounded (int_of_string n)
    | ["bounded"; n; name] -> Named (name, Some (Bounded (int_of_string n)))
    | ["ptr"]              -> Ptr
    | ["bool"]             -> fail "Unexpected in Type.of_string_bitstring: bool"
    | _                    -> Named (s, None)

let of_string = function
  | "bool" -> Any Bool
  | s -> Any (of_string_bitstring s)

let rec to_string : type a. a t -> string = function
  | Bitstringbot         -> "bitstring"
  | Bitstring            -> "bitstring"
  | Fixed n              -> "fixed_" ^ string_of_int n
  | Bounded n            -> "bounded_" ^ string_of_int n
  | Bool                 -> "bool"
  | Int                  -> "int"
  | Ptr                  -> "ptr"
  | Bs_int itype         -> Int_type.to_string itype
  | Named (name, Some t) -> to_string t ^ "_" ^ name
  | Named (name, None)   -> name

let latex : type a. a t -> string = function
  | Bitstringbot         -> "\\bitstring"
  | Bitstring            -> "\\bitstringbot"
  | Fixed n              -> sprintf "\\fixed{%d}" n
  | Bounded n            -> sprintf "\\bounded{%d}" n
  | Bool                 -> "\\bool"
  | Int                  -> assert false
  | Ptr                  -> assert false
  | Bs_int itype         -> Int_type.latex itype
  | Named _              -> assert false

let rec strip_name : type a. a t -> a t = function
  | Named (_, Some t) -> strip_name t
  | t -> t

let subtype (type a) (t : a t) (t' : a t) =
  match strip_name t, strip_name t' with
  | Int, Int -> true
  | Bool, Bool -> true
  | _, Bitstringbot -> true
  | Bitstringbot, _ -> false
  | _, Bitstring    -> true
  | Bitstring, _    -> false
  | Bounded i, Bounded i' -> i <= i'
  | Fixed i, Bounded i'   -> i <= i'
  | Fixed i, Fixed i'     -> i = i'
  | Bs_int itype, Ptr     -> itype = Int_type.ptr
  | Ptr, Bs_int itype     -> itype = Int_type.ptr
  | t, t' -> t = t'

let intersection t t' =
  if subtype t t' then t
  else if subtype t' t then t'
  else fail "cannot compute intersection of types %s and %s" (to_string t) (to_string t')

let union t t' =
  if subtype t t' then t'
  else if subtype t' t then t
  else fail "cannot compute union of types %s and %s" (to_string t) (to_string t')

(* Could return true for more types, but this is enough for now. *)
let has_fixed_length t =
  match strip_name t with
  | Fixed _ -> true
  | _ -> false

let is_bounded t =
  match strip_name t with
  | Fixed _ | Bounded _ -> true
  | _ -> false

let is_defined t =
  match strip_name t with
  | Bitstringbot -> false
  | _ -> true

let equal (type a) (type b) (t : a t) (t' : b t) =
  match Kind.equal (kind t) (kind t') with
  | None -> false
  | Some Type_equal.Equal ->
    subtype t t' && subtype t' t

