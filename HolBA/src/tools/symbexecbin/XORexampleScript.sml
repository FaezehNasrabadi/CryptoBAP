open HolKernel Parse
open PPBackEnd;

open bir_inst_liftingLib;
open bir_inst_liftingHelpersLib;
open gcc_supportLib;

val _ = Parse.current_backend := PPBackEnd.vt100_terminal;
val _ = set_trace "bir_inst_lifting.DEBUG_LEVEL" 2;

val _ = new_theory "XORexample";

val arch_str         = "arm8";

val dafilename = "xor.da";

 val symbs_sec_text = [
     "new_key",
     "senc",
     "send",
     "main"
  ];
  
val prog_range       = ((Arbnum.fromInt 0x00000000), (Arbnum.fromInt 0xffffffff));                           

val _ = print_with_style_ [Bold, Underline] ("Lifting " ^ dafilename ^ " (" ^ arch_str ^ ")\n");

val symb_filter_lift = fn secname =>
  case secname of
    ".text" => (fn symbname => List.exists (fn x => x = symbname) symbs_sec_text)
  | _       => (K false);

val (region_map, sections) = read_disassembly_file_regions_filter symb_filter_lift  dafilename;


                            
val (thm, errors) = bmil_arm8.bir_lift_prog_gen prog_range sections;

val _ = save_thm ("XORexample_thm", thm);



val _ = export_theory();
