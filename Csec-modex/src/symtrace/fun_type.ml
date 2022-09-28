(*
  Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
  This file is distributed as part of csec-tools under a BSD license.
  See LICENSE file for copyright notice.
*)

open Common
open Printf

type ('a, 'b) t = 'a Type.t list * 'b Type.t

type any = Any : (bitstring, 'b) t -> any

let to_string (ts, t) =
  let ts = List.map ~f:Type.to_string ts in
  let t = Type.to_string t in
  sprintf "%s -> %s" (String.concat ~sep:" * " ts) t

let of_string s : any =
  if not (Str.string_match (Str.regexp "\\(.*\\) -> \\(.*\\)") s 0)
  then begin
    let Type.Any t = Type.of_string s in
    Any ([], t)
  end
  else try begin
      (* Call matched_group before calling split (which is also called in
         Type.of_string). *)
    let t = Str.matched_group 2 s in
    let ts =
      Str.matched_group 1 s
      |> Str.split (Str.regexp "\\*")
      |> List.map ~f:Type.of_string_bitstring
    in
    let Type.Any t = Type.of_string t in
    Any (ts, t)
  end with
    e -> fail "Op_type.of_string: %s: %s" s (Printexc.to_string e)

let arity (ts, _) = List.length ts

let kind (_, t) = Type.kind t
