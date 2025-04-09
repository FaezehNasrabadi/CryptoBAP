open HolKernel Parse
open PPBackEnd;

open bir_inst_liftingLib;
open bir_inst_liftingHelpersLib;
open gcc_supportLib;

val _ = Parse.current_backend := PPBackEnd.vt100_terminal;
val _ = set_trace "bir_inst_lifting.DEBUG_LEVEL" 2;

val _ = new_theory "TinySSHexample";

val arch_str         = "arm8";

val dafilename = "tinysshd.da";

val symbs_sec_text = [
    "main_tinysshd",
    "Server_decrypt",
    "Server_accept",
    "Client_accept",
    "Server_pk",
    "poll@plt",
    "packet_kexdh",
    "packet_auth",
    "packet_channel_request@plt",
    "packet_channel_send_data@plt",
    "channel_getfd0@plt",
    "packet_putisready@plt",
    "global_die@plt",
    "geteuid@plt",
    "packet_unimplemented@plt",
    "packet_channel_send_close@plt",
    "channel_readisready@plt",
    "packet_send@plt",
    "open_cwd@plt",
    "buf_purge_@plt",
    "packet_channel_recv_data@plt",
    "channel_getfd2@plt",
    "packet_recvisready@plt",
    "channel_subsystem_log@plt",
    "close@plt",
    "packet_channel_send_eof@plt",
    "__errno_location@plt",
    "buf_put_@plt",
    "log_init",
    "log_init@plt",
    "packet_sendisready@plt",
    "packet_kex_send@plt",
    "signal@plt",
    "blocking_disable@plt",
    "load@plt",
    "packet_kexdh@plt",
    "packet_auth@plt",
    "packet_hello_send@plt",
    "packet_hello_receive@plt",
    "packet_channel_open@plt",
    "channel_writeisready@plt",
    "channel_getfd1@plt",
    "connectioninfo@plt",
    "connectioninfo",
    "str_equaln@plt",
    "str_equaln",
    "fchdir@plt",
    "packet_channel_recv_extendeddata@plt",
    "channel_iseof@plt",
    "alarm@plt",
    "channel_getfd0@plt",
    "packet_get@plt",
    "global_init@plt",
    "packet_channel_recv_close@plt",
    "die_fatal_",
    "blocking_disable@plt",
    "channel_waitnohang@plt",
    "channel_write@plt",
    "packet_recv@plt",
    "die_fatal_@plt",
    "packet_channel_send_extendeddata@plt",
    "str_len@plt",
    "channel_subsystem_add@plt",
    "channel_extendedreadisready@plt",
    "packet_channel_recv_eof@plt",
    "die_usage@plt",
    "die_usage",
    "open_pipe@plt",
    "__stack_chk_fail@plt",
    "packet_getall",
    "buf_purge_",
    "packetparser_uint8_",
    "__errno_location@plt",
    "log_9_",
    "global_die",
    "packetparser_skip_",
    "str_equaln",
    "packetparser_end_",
    "packet_put",
    "packet_sendall",
    "packetparser_uint8_",
    "log_9_",
    "packetparser_uint32_",
    "packetparser_copy_",
    "str_equaln",
    "cleanup_",
    "buf_put_",
    "buf_putstringlen_",
    "buf_putnum8_",
    "buf_putstring_",
    "uint32_unpack_big",
    "numtostr",
    "byte_copy",
    "poll@plt",
    "packet_recv",
    "log_string",
    "writeall",
    "getln",
    "str_len",
    "byte_isequal",
    "buf_putrandombytes_",
    "sshcrypto_kex_put",
    "sshcrypto_key_put",
    "sshcrypto_cipher_put",
    "sshcrypto_cipher_macput",
    "sshcrypto_kex_select",
    "sshcrypto_key_select",
    "sshcrypto_cipher_select",
    "sshcrypto_cipher_macselect",
    "packetparser_copy_",
    "buf_putstringlen_",
    "subprocess_sign",
    "receive_new_key",
    "read@plt"
];

val prog_range       = ((Arbnum.fromInt 0x00000000), (Arbnum.fromInt 0xffffffff));                           

val _ = print_with_style_ [Bold, Underline] ("Lifting " ^ dafilename ^ " (" ^ arch_str ^ ")\n");

val symb_filter_lift = fn secname =>
			  case secname of
			      ".text"  => (fn symbname => true)
			    | ".init"  => (fn symbname => true)
			    | ".plt"   => (fn symbname => true)
			    | ".fini"  => (fn symbname => true)
			    | ".page1" => (fn symbname => List.exists (fn x => x = symbname) symbs_sec_text)
			    | ".page2" => (fn symbname => List.exists (fn x => x = symbname) symbs_sec_text)
			    | ".page3" => (fn symbname => List.exists (fn x => x = symbname) symbs_sec_text)
			    | _        => (K false);

val (region_map, sections) = read_disassembly_file_regions dafilename;


                            
val (thm, errors) = bmil_arm8.bir_lift_prog_gen prog_range sections;

val _ = save_thm ("TinySSHexample_thm", thm);



val _ = export_theory();
