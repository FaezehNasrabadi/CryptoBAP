signature bir_rel_synthLib =
sig
<<<<<<< HEAD
    type exp;
    type cobs;
    type cobs_repr;
    type path_repr;
    type path_spec;
    type path_struct;
=======
    include Abbrev;

    type exp;
    type cobs;

>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
    datatype enum_strategy = enum_extensional of int list
                           | enum_range of int * int;
    type enum_env;

<<<<<<< HEAD
    val path_cond_of : path_repr -> exp
    val path_obs_of : path_repr -> cobs_repr list
    val cobs_id_of : cobs_repr -> int
    val path_domain : path_struct -> int list
    val obs_domain_path : cobs_repr list -> int list
    val obs_domain : path_struct -> int list
    val lookup_path : int -> path_repr list -> path_repr option
    val lookup_obs : int -> cobs_repr list -> cobs_repr option

    val print_path_struct : path_struct -> unit;

    val rel_synth_jit :
        path_spec -> path_repr list -> exp

    val rel_synth_init :
        (exp * cobs list option) list ->
        enum_env ->
        path_struct * exp * ((path_spec -> bool) -> (path_spec * term) option)
=======
    val split_obs_list :
        ''a ->
        (''a * 'b) list -> 'b list * 'b list

    val rel_synth_jit :
        scamv_path_structLib.path_spec ->
        int -> scamv_path_structLib.path_struct -> exp

    val rel_synth_init :
        scamv_path_structLib.path_struct ->
        int ->
        enum_env ->
        scamv_path_structLib.path_spec list *
            exp * ((scamv_path_structLib.path_spec -> bool) ->
                   (scamv_path_structLib.path_spec * term) option)
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc

end;
