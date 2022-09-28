
#include <openssl/bn.h>
#include "needham_type.h"

#ifdef CSEC_VERIFY
  // redefine BN_num_bytes:
  #include <proxies/openssl_proxies.h>
#endif


int key_gen(struct nskey_s *nskey, unsigned long pub_key);

int key_of_string (char *kpub, char *kpriv, char *kmod, struct nskey_s *nskey);

int my_cypher(msg_t *msg, struct nskey_s *pub_key, BIGNUM *cipher);

int my_decypher(BIGNUM *cipher, struct nskey_s *priv_key, msg_t *plain);

int printf_keys(struct nskey_s * nskey);

int printf_message(msg_t* msg);

int print_nonce(unsigned char nonce[16]);
