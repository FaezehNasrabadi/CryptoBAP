<<<<<<< HEAD
signature bir_scamv_driverLib = sig
<<<<<<< HEAD
    include scamv_configLib 
  val symb_exec_phase : term -> (term * (term * term) list option) list * term list
  val make_word_relation : term -> term list -> term
  val scamv_test_main : int -> (string * term) -> unit

  val scamv_test_single_file : string -> unit;

  val scamv_run : scamv_config -> unit
  val scamv_run_with_opts : unit -> unit

=======
    include Abbrev;

    (* include bir_rel_synthLib *)
  val make_word_relation : term -> bool -> term
  val scamv_test_main : int -> (embexp_logsLib.prog_handle * term) -> unit

  val scamv_test_single_file : string -> unit;

  val scamv_run : scamv_configLib.scamv_config -> unit
  val scamv_run_with_opts : unit -> unit
			       
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
end
||||||| empty tree
=======
signature bir_scamv_driverLib = sig
    include Abbrev;

    (* include bir_rel_synthLib *)
  val make_word_relation : term -> bool -> term
  val scamv_test_main : int -> (embexp_logsLib.prog_handle * term) -> unit

  val scamv_test_single_file : string -> unit;

  val scamv_run : scamv_configLib.scamv_config -> unit
  val scamv_run_with_opts : unit -> unit
			       
end
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
