 
#include "needham_type.h"
#include "common.h"
#include "primitives_crypt.h"

#include <proxies/common.h>

#include <string.h>
#include <openssl/rand.h>

int main()
{
  msg_t msg1, msg2;
  BIGNUM *cipher1, *cipher2;
  char* cipher_hex;
  unsigned char nonceA[16];

  struct nskey_s *alice_key;
  struct nskey_s *bob_key;

  alice_key = (struct nskey_s *) malloc (sizeof(struct nskey_s));
  bob_key   = (struct nskey_s *) malloc (sizeof(struct nskey_s));

  key_of_string( alice_pub_key, alice_priv_key, alice_mod_key, alice_key);
  key_of_string( bob_pub_key, bob_priv_key, bob_mod_key, bob_key);

  RAND_bytes(nonceA, 16);

  printf("nonceA = ");
  print_buffer(nonceA, 16);

  msg1.msg_type = MSG1;
  msg1.msg.msg1.id = 10;
  memcpy(msg1.msg.msg1.nonce, nonceA, sizeof(nonceA));

  printf("\n Message 1: ");
     printf_message(&msg1);

  cipher1 = BN_new();
  my_cypher( &msg1, bob_key, cipher1);

  cipher_hex = BN_bn2hex(cipher1);

  printf("Ciphertext in hex [1] = %s \n", cipher_hex);

  cipher2 = BN_new();
  BN_hex2bn(&cipher2, cipher_hex);

  // cipher2 = cipher1;

  my_decypher(cipher2, bob_key, &msg2);

  printf("message type: %d\n", msg2.msg_type);
  printf("message id: %lu\n", msg2.msg.msg1.id);
  printf("message nonce: ");
  print_buffer(msg2.msg.msg1.nonce, 16);
  printf("\n");

  return 0;
}

