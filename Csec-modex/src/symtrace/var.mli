open Common

type t
type var = t

val to_string : ?dont_mask:bool -> t -> string

val of_string : string -> t

val fresh : string -> t
val fresh_id : string -> int

val reset_fresh : unit -> unit

module Map : Custom_map with type key = t

val serialize_state : out_channel -> unit
val deserialize_state : in_channel -> unit
