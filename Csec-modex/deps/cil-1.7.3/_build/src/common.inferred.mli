module E = Errormsg
module List = ListLabels
val trim : string -> string
val snd3 : 'a * 'b * 'c -> 'b
val flip : ('a -> 'b -> 'c) -> 'b -> 'a -> 'c
val words : string -> string list
val open_append : string -> out_channel
val fail : string -> 'a
val some : 'a option -> 'a
val readFile : string -> string list
val ( |> ) : 'a -> ('a -> 'b) -> 'b
module Option :
  sig type 'a t = 'a option val value : default:'a -> 'a option -> 'a end
val filter_out : ('a -> bool) -> 'a list -> 'a list
val remove : 'a -> 'a list -> 'a list
val diff : 'a list -> 'a list -> 'a list
val intersect : 'a list -> 'a list -> 'a list
val nub : 'a list -> 'a list
type glob = {
  mutable name : string;
  mutable opaque : bool;
  mutable is_proxy : bool;
  mutable needs_proxy : bool;
  mutable proxied : bool;
  mutable crestified : bool;
  mutable is_fun : bool;
  mutable locdef : string option;
  mutable stor : Cil.storage;
}
type 'a edge = 'a * 'a
type 'a graph = 'a edge list
module StrSet :
  sig
    type elt = String.t
    type t = Set.Make(String).t
    val empty : t
    val is_empty : t -> bool
    val mem : elt -> t -> bool
    val add : elt -> t -> t
    val singleton : elt -> t
    val remove : elt -> t -> t
    val union : t -> t -> t
    val inter : t -> t -> t
    val diff : t -> t -> t
    val compare : t -> t -> int
    val equal : t -> t -> bool
    val subset : t -> t -> bool
    val iter : (elt -> unit) -> t -> unit
    val fold : (elt -> 'a -> 'a) -> t -> 'a -> 'a
    val for_all : (elt -> bool) -> t -> bool
    val exists : (elt -> bool) -> t -> bool
    val filter : (elt -> bool) -> t -> t
    val partition : (elt -> bool) -> t -> t * t
    val cardinal : t -> int
    val elements : t -> elt list
    val min_elt : t -> elt
    val max_elt : t -> elt
    val choose : t -> elt
    val split : elt -> t -> t * bool * t
    val find : elt -> t -> elt
    val of_list : elt list -> t
  end
module StrMap :
  sig
    type key = String.t
    type 'a t = 'a Map.Make(String).t
    val empty : 'a t
    val is_empty : 'a t -> bool
    val mem : key -> 'a t -> bool
    val add : key -> 'a -> 'a t -> 'a t
    val singleton : key -> 'a -> 'a t
    val remove : key -> 'a t -> 'a t
    val merge :
      (key -> 'a option -> 'b option -> 'c option) -> 'a t -> 'b t -> 'c t
    val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
    val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val for_all : (key -> 'a -> bool) -> 'a t -> bool
    val exists : (key -> 'a -> bool) -> 'a t -> bool
    val filter : (key -> 'a -> bool) -> 'a t -> 'a t
    val partition : (key -> 'a -> bool) -> 'a t -> 'a t * 'a t
    val cardinal : 'a t -> int
    val bindings : 'a t -> (key * 'a) list
    val min_binding : 'a t -> key * 'a
    val max_binding : 'a t -> key * 'a
    val choose : 'a t -> key * 'a
    val split : key -> 'a t -> 'a t * 'a option * 'a t
    val find : key -> 'a t -> 'a
    val map : ('a -> 'b) -> 'a t -> 'b t
    val mapi : (key -> 'a -> 'b) -> 'a t -> 'b t
  end
val compilationRoot : string ref
val srcPath : string ref
val globs : glob StrMap.t ref
val callgraph : StrMap.key graph ref
val isInterfaceFun : string -> bool
val setRootPath : string -> unit
val setSrcPath : Cil.file -> unit
val mkUniqueName : Cil.varinfo -> string
val addGlob : Cil.varinfo -> glob
val addChild : Cil.global -> Cil.varinfo -> unit
val markNeedsProxy : Cil.varinfo -> unit
val markIsProxy : Cil.varinfo -> unit
val markProxied : Cil.varinfo -> unit
val markOpaque : Cil.varinfo -> unit
val markCrestified : Cil.varinfo -> unit
val addRef : Cil.varinfo -> unit
val addDef : Cil.varinfo -> Cil.location -> unit
val getGlob : Cil.varinfo -> glob
val get_callgraph : unit -> (glob * glob) list
val isOpaque : Cil.varinfo -> bool
val needsProxy : Cil.varinfo -> bool
val isProxied : Cil.varinfo -> bool
val isProxy : Cil.varinfo -> bool
val proxy_name : string -> string
val writeGraph : string graph -> string -> unit
val writeGlob : out_channel -> string -> glob -> unit
val writeGlobs : glob StrMap.t -> string -> unit
val writeInfo : Cil.file -> unit
val nextNonemptyLine : in_channel -> string
val readGraph : in_channel -> string graph
val readGlobs : in_channel -> glob StrMap.t
val readInfo : graph_file:string -> glob_file:string -> unit
