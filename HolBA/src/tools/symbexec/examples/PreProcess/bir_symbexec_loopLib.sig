signature bir_symbexec_loopLib =
sig
    include Abbrev Arbnum
    
    val detect_loop:
	bir_cfgLib.cfg_graph -> 'a -> term -> term list -> term list
    val find_loop:
	(term, bir_cfgLib.cfg_node) Redblackmap.dict ->
        'a -> term list -> string list -> term
    val get_range: (string * 'a) list * string list -> int option
    val is_call_node:
	('a, 'b) Redblackmap.dict -> 'a list -> 'a list -> 'a list
    val mk_key_from_address64: int -> num -> term
    val next_pc: term -> term
    val print_list: term list -> unit list
end
