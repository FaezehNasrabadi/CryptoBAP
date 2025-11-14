open HolKernel Parse
open PPBackEnd;
open boolLib pairLib;
open bir_inst_liftingLib;
open bir_inst_liftingHelpersLib;
open gcc_supportLib;

val _ = Parse.current_backend := PPBackEnd.vt100_terminal;
val _ = set_trace "bir_inst_lifting.DEBUG_LEVEL" 2;

val _ = new_theory "Alice";

val arch_str         = "arm8";

val dafilename = "alice.da";

val prog_range       =  ((Arbnum.fromInt 0x0), (Arbnum.fromInt 0x2D1));

val _ = print_with_style_ [Bold, Underline] ("Lifting " ^ dafilename ^ " (" ^ arch_str ^ ")\n");

val (region_map, sections) = read_disassembly_file_regions  dafilename;
                            
val (thm, errors) = bmil_arm8.bir_lift_prog_gen prog_range sections;

val _ = save_thm ("Alice_thm", thm);


val _ = export_theory();



