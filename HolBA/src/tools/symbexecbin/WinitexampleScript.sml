open HolKernel Parse
open PPBackEnd;

open bir_inst_liftingLib;
open bir_inst_liftingHelpersLib;
open gcc_supportLib;

val _ = Parse.current_backend := PPBackEnd.vt100_terminal;
val _ = set_trace "bir_inst_lifting.DEBUG_LEVEL" 2;

val _ = new_theory "Winitexample";

val arch_str         = "arm8";

val dafilename = "wireguard.da";

val symbs_sec_text = [
    "wait_for_random_bytes",
    "down_read",
    "down_write",
    "mix_hash",
    "curve25519_generate_secret",
    "curve25519_generate_public",
    "up_write",
    "up_read",
    "message_ephemeral",
    "mix_dh",
    "chacha20poly1305_encrypt",
    "__crypto_memneq",
    "kdf.constprop.0",
    "ktime_get_real_ts64",
    "wg_index_hashtable_insert",
    "init_module",
    "handshake_init",
    "message_encrypt",
    "mix_precomputed_dh",
    "mix_psk",
    "wg_noise_handshake_create_initiation",
    "wg_noise_handshake_consume_response"
];
  
val prog_range       = ((Arbnum.fromInt 0x00000000), (Arbnum.fromInt 0xffffffff));                           

val _ = print_with_style_ [Bold, Underline] ("Lifting " ^ dafilename ^ " (" ^ arch_str ^ ")\n");

val symb_filter_lift = fn secname =>
  case secname of
    ".text" => (fn symbname => List.exists (fn x => x = symbname) symbs_sec_text)
  | _       => (K false);

val (region_map, sections) = read_disassembly_file_regions_filter symb_filter_lift  dafilename;


                            
val (thm, errors) = bmil_arm8.bir_lift_prog_gen prog_range sections;

val _ = save_thm ("Winitexample_thm", thm);



val _ = export_theory();
