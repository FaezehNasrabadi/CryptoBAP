structure binariesDefsLib =
struct

open binariesBalrobDefsLib;

val symb_filter_mem = fn secname =>
  case secname of
<<<<<<< HEAD
      ".text" => (K true)
    | ".data" => (K true)
    | ".bss"  => (K true)
    | _       => (K false);
=======
      ".text" => (Lib.K true)
    | ".data" => (Lib.K true)
    | ".bss"  => (Lib.K true)
    | _       => (Lib.K false);
>>>>>>> 24a6f6f2aba3708ecd62e9f1b7ba9b6ecc72edcc
val data_filter_mem = fn secname => fn _ => secname = ".data" orelse secname = ".bss";

val (prog_id, (da_file_lift, da_file_mem, mem_file), thm_name, (mem_region_const, mem_region_data, mem_region_stack)) = List.nth(configs,0);

end (* struct *)
