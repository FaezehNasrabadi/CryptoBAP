(*
    Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
    This file is distributed as part of csec-tools under a BSD license.
    See LICENSE file for copyright notice.
*)

open Str
open Filename
open List
open Sys

open Cil

(*************************************************)
(** {1 General Purpose} *)
(*************************************************)

val fail : string -> 'a

val trim : string -> string

val snd3 : 'a * 'b * 'c -> 'b

val flip : ('a -> 'b -> 'c) -> 'b -> 'a -> 'c

val readFile : string -> string list

val (|>) : 'a -> ('a -> 'b) -> 'b

module Option : sig
  type 'a t = 'a option

  val value : default:'a -> 'a t -> 'a
end

(*************************************************)
(** {2 Lists} *)
(*************************************************)

val filter_out : ('a -> bool) -> 'a list -> 'a list

val remove : 'a -> 'a list -> 'a list

(** Set difference *)
val diff : 'a list -> 'a list -> 'a list

val intersect: 'a list -> 'a list -> 'a list

val nub: 'a list -> 'a list

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

module StrMap : Map.S with type key = string

(**
  The keys are unique names that can be computed using [mkUniqueName]. The reason that we can't just
  take a name of the glob to be the key is that two different static globals can share the same name.
*)
val globs : glob StrMap.t ref

(**
  The path of the current source file relative to [compilationRoot], including the file name itself.
  We use the name of the .c file even when we are called with .i file as argument.
*)
val srcPath : string ref

(*************************************************)
(** {1 Misc} *)
(*************************************************)

val isInterfaceFun : string -> bool

(*************************************************)
(** {1 Configuration} *)
(*************************************************)

val setRootPath : string -> unit

val setSrcPath : file -> unit

(*************************************************)
(** {1 Information Gathering} *)
(*************************************************)

(*
  This is also called from crestInstrument to give names to stack locations.
*)
val mkUniqueName : varinfo -> string

val addGlob : varinfo -> glob

val addChild : global -> varinfo -> unit

val markNeedsProxy : varinfo -> unit

val markIsProxy : varinfo -> unit

val markProxied : varinfo -> unit

val markOpaque : varinfo -> unit

val markCrestified : varinfo -> unit

val addRef : varinfo -> unit

val addDef : varinfo -> location -> unit

(*************************************************)
(** {1 Information Query} *)
(*************************************************)

(**
    Can throw [Not_found].
*)
val getGlob : varinfo -> glob

val get_callgraph : unit -> glob graph

val isOpaque : varinfo -> bool

val needsProxy : varinfo -> bool

val isProxied : varinfo -> bool

(* This should do the job for now *)
val isProxy: varinfo -> bool

val proxy_name : string -> string

(*************************************************)
(** {1 Information Input and Output} *)
(*************************************************)

val writeInfo : file -> unit

val readInfo : graph_file:string -> glob_file:string -> unit

