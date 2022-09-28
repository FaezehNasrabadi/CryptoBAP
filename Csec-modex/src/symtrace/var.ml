open Common

module Stats = Stats_local

type t = string
type var = t

(*
let to_string ?(dont_mask = false) t =
  if dont_mask then t else String.mask_digits t

let of_string s =
  String.fail_if_masked s
*)

let to_string ?dont_mask:_ t = t

let of_string s = s

let used = Hashtbl.create 100

let serialize_state c =
  output_value c used

let deserialize_state c =
  let new_used = input_value c in
  Hashtbl.clear used;
  Hashtbl.iter new_used ~f:(fun stem value ->
    Hashtbl.add used stem value)

let reset_fresh () =
  Hashtbl.clear used

let fresh_id stem =
  let stem = if stem = "" then "var" else stem in
  let n = Option.try_with_default (fun () -> Hashtbl.find used stem) ~default:1 in
  Hashtbl.replace used stem (n + 1);
  n

let fresh stem =
  let stem = if stem = "" then "var" else stem in
  Printf.sprintf "%s%d" stem (fresh_id stem)

let fresh name =
  Stats.call "Var.fresh" (fun () -> fresh name)

module Key = struct
  type t = string
  let compare = Pervasives.compare
  let to_string t = t
end

module Map = Custom_map(Key)
