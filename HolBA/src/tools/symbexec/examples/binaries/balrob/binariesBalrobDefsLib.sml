structure binariesBalrobDefsLib =
struct

(*

(* client_hmac *)
 val symbs_sec_text = [
     "_IO_puts",
     "strlen",
     "__lll_lock_wait_private",
     "__overflow",
     "_Unwind_Resume",
     "BIO_new_connect",
     "BIO_new_accept",
     "malloc",
     "HMAC",
     "my_load_buf",
     "my_LoadBuf",
     "my_store_buf",
     "my_StoreBuf",
     "load_buf",
     "BIO_free",
     "EVP_sha1",
     "BIO_ctrl",
     "fprintf",
     "BIO_write",
     "ERR_print_errors_f",
     "BIO_pop",
     "client",
     "BIO_read",
     "socket_connect",
     "store_buf",
     "exit",
     "strlen",
     "get_key",
     "vfprintf",
     "my_memcpy_proxy",
     "client",
     "main",
     "get_payload",
     "get_key",
     "fail",
     "socket_listen",
     "socket_connect",
     "send",
     "recv",
     "wait_close"
 ];

(* server_hmac *)
 val symbs_sec_text = [
     "server",
     "fail",
     "socket_listen",
     "__stack_chk_fail",
     "__libc_malloc",
     "EVP_sha1",
     "HMAC",
     "memcpy",
     "memcmp",
     "get_key",
     "main"
 ];




(* server_xor *)
 val symbs_sec_text = [
     "__libc_malloc",
     "memcpy",
     "otp",
     "xor",
     "socket_listen",
     "consume",
     "wait_close",
     "server",
     "main"
 ];
*)

(* client_xor *)
 val symbs_sec_text = [
     "__libc_malloc",
     "memcpy",
     "otp",
     "xor",
     "socket_connect",
     "send",
     "RAND_bytes",
     "client",
     "main"
 ];

(*
(* RPC_enc_client *)
 val symbs_sec_text = [
     "__globinit_client",
     "__CrestCall",
     "__CrestLoadStackPtr",
     "__CrestApply",
     "__CrestSetPtrStep",
     "__CrestStore",
     "__CrestLocation",
     "__CrestLoadInt",
     "__CrestBS",
     "parseargs",
     "recv_response",
     "send_request",
     "event4",
     "event3",
     "__CrestDone",
     "malloc_proxy",
     "__CrestLoadMem",
     "__CrestLoadChar",
     "get_host_proxy",
     "get_xhost_proxy",
     "get_pkey_proxy",
     "get_skey_proxy",
     "lookup_xkey",
     "__CrestLoadCString",
     "event2",
     "memcpy_proxy",
     "__CrestClear",
     "nonce_proxy",
     "encrypt_len",
     "__CrestTruth",
     "__CrestBranch",
     "__CrestMute",
     "fail",
     "__CrestUnmute",
     "encrypt_proxy",
     "recv",
     "decrypt_len",
     "decrypt_proxy",
     "socket_connect",
     "exit_proxy",
     "_IO_puts",
     "__CrestNondet",
     "send",
     "typehint",
     "__CrestReturn",
     "__stack_chk_fail",
     "main"
 ];

(* RPC_enc_server *)
 val symbs_sec_text = [
     "parseargs",
     "send_response",
     "recv_request",
     "event4",
     "event3",
     "__globinit_server",
     "__CrestCall",
     "__CrestLoadStackPtr",
     "__CrestApply",
     "__CrestSetPtrStep",
     "__CrestStore",
     "__CrestLocation",
     "__CrestLoadInt",
     "__CrestBS",
     "__CrestDone",
     "malloc_proxy",
     "__CrestLoadMem",
     "__CrestLoadChar",
     "get_host_proxy",
     "get_xhost_proxy",
     "get_pkey_proxy",
     "get_skey_proxy",
     "lookup_xkey",
     "__CrestLoadCString",
     "event2",
     "memcpy_proxy",
     "__CrestClear",
     "nonce_proxy",
     "encrypt_len",
     "__CrestTruth",
     "__CrestBranch",
     "__CrestMute",
     "fail",
     "__CrestUnmute",
     "encrypt_proxy",
     "recv",
     "decrypt_len",
     "decrypt_proxy",
     "socket_listen",
     "exit_proxy",
     "_IO_fwrite",
     "__CrestNondet",
     "send",
     "typehint",
     "__CrestReturn",
     "__stack_chk_fail",
     "memcmp_proxy",
     "main"
 ];

(* RPC *)
 val symbs_sec_text = [
     "main",
     "client",
     "server"
 ];


(* CSur *)
 val symbs_sec_text = [
     "main"
 ];


(* WireGuard-Initiator *)
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


(* WireGuard-Respondor *)
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
     "wg_noise_handshake_consume_initiation",
     "wg_noise_handshake_create_response"
 ];
 *)
val arch_str         = "arm8";
val prog_range       = ((Arbnum.fromInt 0x00000000), (Arbnum.fromInt 0xffffffff));

(*val configs              = [ ("pkcs11",
				("pkcs11_guest.da", "balrob/pkcs11_guest.elf.da.plus", "balrob/pkcs11_guest.elf.mem"),
				"pkcs11_THM",
				((Arbnum.fromInt 0xd0000000, Arbnum.fromInt 0xd0004dac),
				 (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)),
				 (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			       ) ];  
  val configs              = [ ("client",
				("client_nsl.da", "balrob/client_nsl.da.plus", "balrob/client_nsl.mem"),
				"client_THM",
				((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0xffffffff),
				 (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)),
				 (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			       ) ];    

  val configs              = [ ("server",
				("server_xor.da", "balrob/server_xor.da.plus", "balrob/server_xor.mem"),
				"server_THM",
				((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0xffffffff),
				 (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)),
				 (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			       ) ]; 
*)
  val configs              = [ ("client",
				("client_xor.da", "balrob/client_xor.da.plus", "balrob/client_xor.mem"),
				"client_THM",
				((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0xffffffff),
				 (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)),
				 (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			       ) ];
(*
  val configs              = [ ("client",
				("client_hmac.da", "balrob/client_hmac.da.plus", "balrob/client_hmac.mem"),
				"client_THM",
				((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0xffffffff),
				 (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)),
				 (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			       ) ];
    
  val configs              = [ ("server",
				("server_hmac.da", "balrob/server_hmac.da.plus", "balrob/server_hmac.mem"),
				"server_THM",
				((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0xffffffff),
				 (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)),
				 (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			       ) ]; 
  
   
  val configs              = [ ("server",
				("server_nsl.da", "balrob/server_nsl.da.plus", "balrob/server_nsl.mem"),
				"server_THM",
				((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0xffffffff),
				 (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)),
				 (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			       ) ]; 

  val configs              = [ ("RPC",
				("RPC.da", "balrob/RPC.da.plus", "balrob/RPC.mem"),
				"RPC_THM",
				((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0xffffffff),
				 (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)),
				 (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			       ) ];
      

  val configs              = [("RPC_enc_server",
                               ("RPC_enc_server.da", "balrob/RPC_enc_server.da.plus", "balrob/RPC_enc_server.mem"),
                               "RPC_enc_server_THM",
                               ((Arbnum.fromInt 0xd0000000, Arbnum.fromInt 0xd0004dac),
				(Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x310)),
				(Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			     )];
      

  val configs              = [ ("RPC_enc_client",
				("RPC_enc_client.da", "balrob/RPC_enc_client.da.plus", "balrob/RPC_enc_client.mem"),
				"RPC_enc_client_THM",
				((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0x00003564), 
				 (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)), 
				 (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			     )];
			     
val configs              = [ ("tinyssh",
                              ("tinysshd.da", "balrob/tinysshd.da.plus", "balrob/tinysshd.mem"),
                              "tinyssh_THM",
			      ((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0x00003564), 
                               (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)), 
                               (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			   )];


 val configs              = [ ("example-indjmp",
                               ("example-indirect.da", "balrob/example-indirect.da.plus", "balrob/example-indirect.mem"),
                               "exampleindjmp_THM",
			       ((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0x00003564), 
				(Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)), 
				(Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			    )];
 val configs              = [ ("example-loop",
                               ("example-loop.da", "balrob/example-loop.da.plus", "balrob/example-loop.mem"),
                               "exampleloop_THM",
			       ((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0x00003564), 
				(Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)), 
				(Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			    )];


 val configs              = [ ("CSur-alice",
                               ("CSur_alice.da", "balrob/CSur_alice.da.plus", "balrob/CSur_alice.mem"),
                               "CSuralice_THM",
			       ((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0x00003564), 
				(Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)), 
				(Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			    )];
     
 val configs              = [ ("CSur-bob",
                               ("CSur_bob.da", "balrob/CSur_bob.da.plus", "balrob/CSur_bob.mem"),
                               "CSurbob_THM",
			       ((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0x00003564), 
				(Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)), 
				(Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			    )];


  

    val configs              = [ ("wireguard",
                              ("wireguard.da", "balrob/wireguard.da.plus", "balrob/wireguard.mem"),
                              "wireguard_THM",
			      ((Arbnum.fromInt 0x00000000, Arbnum.fromInt 0x00003564), 
                               (Arbnum.fromInt 0x10000000, Arbnum.fromInt (0x00000018 + 0x30d)), 
                               (Arbnum.fromInt 0x10001000, Arbnum.fromInt 0x00000ff0))
			       )]; *)
	

    

(*
(* For TinySSH case-study *)    
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
*)

(* For other case-studies *)
val symb_filter_lift = fn secname =>
			    case secname of
				".text" => (fn symbname => List.exists (fn x => x = symbname) symbs_sec_text)
			      | _       => (K false);

end (* struct *)
