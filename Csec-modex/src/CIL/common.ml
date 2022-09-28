(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)

open Str
open Filename
open Sys

open Cil

module E = Errormsg

module List = ListLabels

(*************************************************)
(** {1 General Purpose} *)
(*************************************************)

let trim : string -> string = function s ->
  replace_first (regexp "^[ \t\n]+") "" (replace_first (regexp "[ \t\n]+$") "" s)

let snd3 (_, a, _) = a

let flip f x y = f y x

let words : string -> string list = Str.split (Str.regexp "[ \t]+")

let open_append fname =
  open_out_gen [Open_append; Open_creat; Open_text] 0o700 fname

let fail : string -> 'a = fun s -> failwith s

let some: 'a option -> 'a = function
  | Some a -> a
  | None   -> failwith "some called with None"

let readFile : string -> string list = fun name ->
  let f = open_in name in

  let rec read : unit -> string list = fun () ->
    (* Stay tail-recursive, make sure not to create nested exception handlers at
       runtime. *)
    match
      try Some (trim (input_line f))
      with End_of_file -> None with
    | Some s -> s :: read ()
    | None   -> []
  in
  read()

let (|>) a f = f a

module Option = struct
  type 'a t = 'a option

  let value ~default = function
    | Some x -> x
    | None -> default
 end

(*************************************************)
(** {2 Lists} *)
(*************************************************)


let filter_out : ('a -> bool) -> 'a list -> 'a list = fun p ->
  List.filter ~f:(fun a -> not (p a))

let remove : 'a -> 'a list -> 'a list = fun a -> filter_out (fun b -> a = b)

(** Set difference *)
let rec diff : 'a list -> 'a list -> 'a list = fun xs -> function
  | []      -> xs
  | y :: ys -> diff (remove y xs) ys

let intersect: 'a list -> 'a list -> 'a list = fun xs ys ->
  List.filter ~f:(fun y -> List.mem y xs) ys

let nub: 'a list -> 'a list = fun l ->
  let rec nub' = fun ls ->
    function
      | (x::xs) when List.mem x ls -> nub' ls xs
      | (x::xs) -> x :: nub' (x::ls) xs
      | [] -> []
  in
  nub' [] l

(*************************************************)
(** {1 Types} *)
(*************************************************)

(** Information that I collect about globals. Another options is to keep it in [varinfo]
    instead, but that is more cumbersome to parse: you need to additionally provide headers
    for all types, so it could become a mess.

    Another problem is that [varinfo] only holds the location of the declaration, whereas
    I am more interested in the definition instead.
*)
type glob =
{
  mutable name: string;
  mutable opaque: bool;
  (** Functions for which neither the return value nor the side effects are relevant, or
      globals, for which the value is not relevant and fields of which are not accessed by
      instrumented code.

      A function is marked as opaque if it is explicitly listed in the boring section in
      config file or if it needs to be proxied.  *)

  mutable is_proxy: bool;
  mutable needs_proxy: bool;
  mutable proxied: bool;
  mutable crestified: bool;
  mutable is_fun: bool;
  mutable locdef: string option;
  mutable stor: storage;
  (* mutable is_vararg : bool *)
}

type 'a edge = 'a * 'a

type 'a graph = 'a edge list

(* What you gonna do about full source file paths? Answer: give config a full root path *)

(*************************************************)
(** {1 State} *)
(*************************************************)

module StrSet = Set.Make (String)
module StrMap = Map.Make (String)

(**
    The root folder of the compilation.
    Ends with a trailing directory separator.
*)
let compilationRoot = ref ""
(*
(** The source file name *)
let srcName = ref ""
*)
(**
  The path of the current source file relative to [compilationRoot], including the file name itself.
  We use the name of the .c file even when we are called with .i file as argument.
*)
let srcPath = ref ""

(*
(** List of all instrumented functions *)
let crestifiedNames : string list ref = ref []
*)

(** Names of opaque functions for which we actually encountered a definition *)
(* let opaqueDefNames : string list ref = ref []
*)

(*
(** List of all referenced functions. Proxied and opaque functions are not included. *)
let funRefs : string list ref = ref []
(** List of all globals defined in the current source file *)
let defs: string list ref = ref []

(** Names of functions that are called, or whose address is taken, but that are not proxied *)
(* let unproxiedNames = ref [] *)
*)

(**
  The keys are unique names that can be computed using [mkUniqueName]. The reason that we can't just
  take a name of the glob to be the key is that two different static globals can share the same name.
*)
let globs : glob StrMap.t ref = ref StrMap.empty

(** Which globals are referenced from which? *)
let callgraph : string graph ref = ref []


(*************************************************)
(** {1 Misc} *)
(*************************************************)

(*
  FIXME: Have a __proxy__ attribute on interface functions.
*)
let isInterfaceFun : string -> bool = fun s ->
  List.mem s ["event0"; "event1"; "event2"; "event3"; "event4"; "readenv"; "readenvE"; "readenvL";
              "make_str_sym"; "make_sym"; "mute"; "unmute"; "fail";
              (* Internal interface functions: *)
              "load_buf"; "load_alll"; "load_ctx"; "load_int"; "load_str";
              "symL"; "symN"; "symNE"; "input"; "newTN"; "newTL"; "newL";
              "varsym"; "var"; "varWithBUfInit"; "varL"; "output";
              "store_buf"; "store_all"; "store_ctx"; "event";
              "add_to_attr"; "set_attr_str"; "set_attr_buf"; "set_attr_int";
              "get_attr_int"; "copy_ctx"; "copy_attr_ex"; "copy_attr";
              "clear_attr"; "concrete_val"; "fresh_ptr"; "append_zero"; "typehint"]


(*************************************************)
(** {1 Configuration} *)
(*************************************************)

let setRootPath: string -> unit = fun path ->
  if Filename.check_suffix "/" path then
    compilationRoot := path
  else
    compilationRoot := path ^ "/"

let setSrcPath (f : file) =
  if !compilationRoot = ""
  then fail "setSrcPath: compilation root not set";

  let cName =
    try chop_extension f.fileName ^ ".c"
    with Invalid_argument _ -> failwith "setSrcPath: source name without extension"
  in

  (* there should be a library function to compute canonical file names *)
  let cName = global_replace (regexp "^\\./") "" cName in

  let fullPath =
    if Filename.is_relative cName
    then Filename.concat (getcwd ()) cName
    else cName
  in

  srcPath := global_replace (regexp_string !compilationRoot) "" fullPath

(*************************************************)
(** {1 Information Gathering} *)
(*************************************************)

(* TODO: think of eventually making some of these functions exclusive to marking code *)

(** Generates a descriptive global (across the whole compilation) unique
    identifier for a variable. One identifer corresponds to one physical
    variable in the linked executable.

    We use a single global name for static functions. This makes it easier to
    designate them in configuration files. At the same time this makes it
    problematic to have two static functions of the same name in different
    files.

    This is addressed in {!readGlobs} by checking that no two globs have same
    names but different locdefs.
*)
(*
  This is also called from crestInstrument to give names to stack locations.
*)
let mkUniqueName : varinfo -> string = fun v ->
  if not v.vglob (* || v.vstorage = Static *) then
    !srcPath ^ ":" ^ v.vname ^ "[" ^ string_of_int v.vid ^ "]"
  else
    v.vname

let addGlob : varinfo -> glob = fun v ->
  if not v.vglob then
    fail "addGlob: trying to add a local variable";
  let key = mkUniqueName v in
  try StrMap.find key !globs
  with Not_found ->
    (* print_endline ("addGlob: adding " ^ key); *)
    let g = {
        name = v.vname;
        opaque = false;
        needs_proxy = false;
        is_proxy = false;
        proxied = false;
        crestified = false;
        is_fun = isFunctionType v.vtype;
        locdef = None;
        stor = v.vstorage;
      }
    in
    globs := StrMap.add key g !globs;
    g

let addChild : global -> varinfo -> unit = fun parentG child ->
  let parent = match parentG with
    | GFun (f, _)    -> f.svar
    | GVar (v, _, _) -> v
    | _ ->
      E.error "%t: %s, %a" d_thisloc "function variable reference in unexpected global" d_global !currentGlobal;
      fail "addChild"
  in
  callgraph := (mkUniqueName parent, mkUniqueName child) :: !callgraph

let markNeedsProxy : varinfo -> unit = fun v ->
  let g = addGlob v in
  g.needs_proxy <- true

let markIsProxy : varinfo -> unit = fun v ->
  let g = addGlob v in
  g.is_proxy <- true

let markProxied : varinfo -> unit = fun v ->
  let g = addGlob v in
  g.proxied <- true

let markOpaque : varinfo -> unit = fun v ->
  let g = addGlob v in
  g.opaque <- true

let markCrestified : varinfo -> unit = fun v ->
  let g = addGlob v in
  g.crestified <- true

let addRef : varinfo -> unit = fun v -> ignore (addGlob v)

let addDef : varinfo -> location -> unit = fun v _ ->
  let g = addGlob v in
  g.locdef <- Some !srcPath


(*************************************************)
(** {1 Information Query} *)
(*************************************************)

(**
    Can throw [Not_found].
*)
let getGlob : varinfo -> glob = fun v -> StrMap.find (mkUniqueName v) !globs

let get_callgraph () =
  List.map !callgraph ~f:(fun (v, w) ->
    let v = StrMap.find v !globs in
    let w = StrMap.find w !globs in
    v, w)

(*
let globKeyByName : string -> string = fun name ->
  fst (StrMap.choose (StrMap.filter (fun _ g -> g.name = name) !globs))
*)

let isOpaque : varinfo -> bool = fun v ->
  try let g = getGlob v in g.opaque
  with Not_found -> false

let needsProxy : varinfo -> bool = fun v ->
  try let g = getGlob v in
      g.needs_proxy
  with Not_found -> false

let isProxied : varinfo -> bool = fun v ->
  try let g = getGlob v in
      g.proxied
  with Not_found -> false

(*
let isProxy : varinfo -> bool = fun v ->
  let result =
  try let g = getGlob v in
      g.is_proxy
  with Not_found -> false in
  Printf.printf "isProxy: %s,  result: %b\n" v.vname result;
  result
*)

(* This should do the job for now *)
let isProxy: varinfo -> bool = function v ->
  string_match (regexp ".*_proxy$") v.vname 0

let proxy_name name = name ^ "_proxy"

(*************************************************)
(** {1 Information Input and Output} *)
(*************************************************)

let writeGraph : string graph -> string -> unit = fun g outname ->
  let c = open_out outname in
  List.iter g ~f:(fun (parent, child) -> output_string c (parent ^ " " ^ child ^ "\n"));
  close_out c

let writeGlob : out_channel -> string -> glob -> unit = fun c key g ->

  let writePair : string -> string -> unit = fun a b -> output_string c (a ^ " ~ " ^ b ^ "\n") in

  writePair key "name";
  output_string c (g.name ^ "\n");

  if g.opaque then writePair key "opaque";
  if g.needs_proxy then writePair key "needs_proxy";
  if g.proxied then writePair key "proxied";
  if g.is_proxy then writePair key "is_proxy";
  if g.crestified then writePair key "crestified";
  if g.is_fun then writePair key "is_fun";

  begin
  match g.locdef with
    | Some s ->
      writePair key "locdef";
      output_string c (s ^ "\n")

    | _ -> ()
  end;

  match g.stor with
    | NoStorage -> writePair key "NoStorage"
    | Static -> writePair key "Static"
    | Register -> writePair key "Register"
    | Extern -> writePair key "Extern"


let writeGlobs : glob StrMap.t -> string -> unit = fun globs outname ->
  let c = open_out outname in
  StrMap.iter (writeGlob c) globs;
  close_out c

let writeInfo : file -> unit = fun f ->
  (* output the call relation *)
  writeGraph !callgraph (f.fileName ^ ".callgraph.out");
  (* output the defined and referenced globals list *)
  writeGlobs !globs (f.fileName ^ ".globs.out")


let rec nextNonemptyLine: in_channel -> string = fun file ->
  let line = input_line file in
  if trim line = "" then nextNonemptyLine file else line


let rec readGraph : in_channel -> string graph = fun file ->
  try
    let line = nextNonemptyLine file in
    let toks = words line in
    (List.nth toks 0, List.nth toks 1) :: readGraph file
  with
    End_of_file -> []


let readGlobs : in_channel -> glob StrMap.t = fun file ->

  let globs : glob StrMap.t ref = ref (StrMap.empty) in

  let globByKey : string -> glob = fun key ->
    try StrMap.find key !globs
    with Not_found ->
    let g = {
        name = "";
        opaque = false;
        needs_proxy = false;
        is_proxy = false;
        proxied = false;
        crestified = false;
        is_fun = false;
        locdef = None;
        stor = NoStorage;
      }
    in
    globs := StrMap.add key g !globs;
    g
  in

  let rec readField : unit -> unit = fun () ->

    let line = nextNonemptyLine file in
    let toks = words line in
    let (key, field) =
      if List.nth toks 1 = "~"
      then (List.nth toks 0, List.nth toks 2)
      else fail (Printf.sprintf "readGlobField: unexpected format %s" line) in
    let g = globByKey key in
    begin match field with
      | "name" ->
        let name = input_line file in g.name <- name
      | "opaque" -> g.opaque <- true
      | "needs_proxy" -> g.needs_proxy <- true
      | "is_proxy" -> g.is_proxy <- true
      | "proxied" -> g.proxied <- true
      | "crestified" -> g.crestified <- true
      | "is_fun" -> g.is_fun <- true
      | "locdef" ->
        let locdef = input_line file in
        if g.locdef = None then
          g.locdef <- Some locdef
        else if (g.locdef <> Some locdef) && (g.stor = Static) then
          fail ("readGlobs: two different source files define two static functions of the same name, this is unsupported: "
                 ^ key ^ ", " ^ locdef ^ ", " ^ some g.locdef)
      | "NoStorage" -> g.stor <- NoStorage
      | "Static" -> g.stor <- Static
      | "Register" -> g.stor <- Register
      | "Extern" -> g.stor <- Extern
      | _ -> fail "readGlobField: unrecognized field"
    end;

  readField ()
  in

  begin try readField (); with End_of_file -> () end;
  !globs

let readInfo ~graph_file ~glob_file =
  callgraph := readGraph (open_in graph_file);
  globs := readGlobs (open_in glob_file)
