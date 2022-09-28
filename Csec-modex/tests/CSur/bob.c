/* Ce fichier d�crit le protocole de Needman schroder pour Bob. */

/*
   A --> B : { A , Na }_{pub(B)}
   B --> A : { Na, Nb }_{pub(A)}
   A --> B : { Nb }_{pub(b)}
*/

/* B doit d'abord initialiser une socket pour recevoir des
   informations de "A". */
#include <openssl/bn.h>
#include <openssl/rand.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>

#include "needham_type.h"
#include "common.h"
#include "lib.h"
#include "primitives_crypt.h"

#ifdef CSEC_VERIFY
#include <proxies/common.h>
#include "proxies.h"
#endif

/* */

int main(int argc, char **argv) {

  int conn_fd;    /* */
  int listen_fd;  /* */

  char bob[30];
  int  bob_port;
  int nb;

  unsigned char nonceB[16];
  char temp[1024];

  /* Les messages. */
  msg_t bob_mess_1;
  BIGNUM *cipher_1;

  /* Le message de type 2. */
  msg_t bob_mess_2;
  BIGNUM *cipher_2;

  /* Le message de type 3. */
  msg_t bob_mess_3;
  BIGNUM *cipher_3;

  /* Les cl�s. */
  struct nskey_s *alice_key;
  struct nskey_s *bob_key;

#ifdef CSEC_VERIFY
  // teach csec something it needs to know about field offsets
  struct_properties();
#endif

  /* Defines parameters for protocols analysis. */
  /* A : defines agent "Alice" of the protocol. */
  /* B : defines agent "Bob" of the protocol.   */
  /* % Parameters = A,B. % */

  alice_key = (struct nskey_s *) malloc (sizeof(struct nskey_s));
  bob_key   = (struct nskey_s *) malloc (sizeof(struct nskey_s));

  char * alice_pub = alice_pub_key;
  char * alice_priv = alice_priv_key;
  char * alice_mod = alice_mod_key;

  char * bob_pub = bob_pub_key;
  char * bob_priv = bob_priv_key;
  char * bob_mod = bob_mod_key;

#ifdef CSEC_VERIFY
  readenv(alice_pub, NULL, "alice_pub_key");
  readenv(alice_priv, NULL, "alice_priv_key");
  readenv(alice_mod, NULL, "alice_mod_key");

  readenv(bob_pub, NULL, "bob_pub_key");
  readenv(bob_priv, NULL, "bob_priv_key");
  readenv(bob_mod, NULL, "bob_mod_key");
#endif

  key_of_string( alice_pub, alice_priv, alice_mod, alice_key);
  key_of_string( bob_pub, bob_priv, bob_mod, bob_key);

  /* Defines public and private keys. */
  /* %    *alice_key -> pub_exp rec pub(A)
      and *alice_key -> priv_exp rec prv(A). % */

  /* %    *bob_key -> pub_exp rec pub(B)
      and *bob_key -> priv_exp rec prv(B). % */

  /* printf("\nAlice's key = ");
     printf_keys(alice_key);
     printf("\nBob's key = ");
     printf_keys(bob_key); */
  /* Initialisation. */

  bob_port = PORT_BOB;
  strcpy(bob,"127.0.0.1");

  if (argc == 3)
    {
      strcpy(bob,argv[1]);
      bob_port = atoi(argv[2]);
    }
  else if (argc > 3)
    exit(1);

  /* Cr�ation d'une socket pour la reception. */
  listen_fd = create_bind_socket(bob_port);
#ifdef VERBOSE
  printf("Waiting for Alice's connection on (%s) port %d...\n",bob,bob_port);
#endif

  /* Reception de A (A --> B). */
  /* C'est un message 1 */
  conn_fd = accept(listen_fd, NULL, NULL);

  cipher_1 = BN_new();
  nb = read(conn_fd,  temp, 128);
  // BUG: this line wasn't there
  temp[128] = 0;
#ifdef VERBOSE
  printf("\nBob: ciphertext received [1]= %s", temp);
#endif
  BN_hex2bn(&cipher_1, temp);

  /* printf ("\n Bytes received %d", nb); */
  /* printf("\nBob phase [1-2]"); */
  /* printf("\nBob: reading ciphertext from Alice ");
     print_message(cipher); */
  my_decypher(cipher_1, bob_key, &bob_mess_1);

  // printf("\nBob : bob_mess_1.msg.msg1.nonce = ");
  // print_buffer(bob_mess_1.msg.msg1.nonce, SIZENONCE);

  // printf("\n A -> B : \n Bob's message 1 (from Alice)");
  //   printf_message(&bob_mess_1);

  /* Envoie vers A (B --> A). */
  /* printf("\nBob phase [2-3] "); */

  RAND_bytes(nonceB, 16);
  /* % nonceB rec nOnceB(X) | context rec X. % */

  // printf("\nBob : nonceB = ");
  // print_buffer(nonceB, 16);

  bob_mess_2.msg_type = MSG2;
  memcpy(bob_mess_2.msg.msg2.nonce1,
         bob_mess_1.msg.msg1.nonce,
         sizeof(bob_mess_1.msg.msg1.nonce));
  memcpy(bob_mess_2.msg.msg2.nonce2, nonceB, sizeof(nonceB));

  /* % bob_mess_2 rec [Na; Nb] | bob_mess_1 rec [Na;A], nonceB rec Nb. % */

  /* printf("\n B -> A : ");
     printf_message(&bob_mess_2); */

  /* On chiffre le message. */
  cipher_2  = BN_new();
  my_cypher( &bob_mess_2, alice_key, cipher_2);
  /* printf("\n Bob's ciphertext ");
     print_message(cipher); */

#ifdef VERBOSE
  printf("\nBob: ciphertext sent [2] = %s", BN_bn2hex(cipher_2));
#endif
  write(conn_fd, BN_bn2hex(cipher_2), 128);

  /* Reception de A (A --> B). */
  cipher_3  = BN_new();
  read(conn_fd, temp, 128);
  // BUG: this line wasn't there
  temp[128] = 0;
#ifdef VERBOSE
  printf("\nBob: ciphertext received [3]= %s", temp);
#endif

  BN_hex2bn(&cipher_3, temp);

  /* printf("\nBob phase [2-3] "); */
  /* printf("\n A -> B  "); print_message(cipher); */
  my_decypher(cipher_3, bob_key, &bob_mess_3);

  /* printf("\n A -> B (mess 3): ");
     printf_message(&bob_mess_3); */

  /* On v�rifie que c'est bien le bon nonceB. */

  // printf("\nBob : bob_mess_3.msg.msg3.nonce = ");
  // print_buffer(bob_mess_3.msg.msg3.nonce, sizeof(nonceB));

  if ((strncmp((char *) bob_mess_3.msg.msg3.nonce, (char *) nonceB , sizeof(nonceB)))==0)
    {
#ifdef VERBOSE
      printf("\nNonceB matches\n");
      printf("\nSession complete, ");
      printf("\n nonceA = ");
      // print_nonce(bob_mess_2.msg.msg2.nonce1);
      print_buffer(bob_mess_2.msg.msg2.nonce1, SIZENONCE);
      printf("\n nonceB = ");
      //print_nonce(nonceB);
      print_buffer(nonceB, SIZENONCE);
      printf("\n");
      fflush(stdout);
#endif
#ifdef CSEC_VERIFY
      event2("bob_accept", bob_mess_2.msg.msg2.nonce1, SIZENONCE, nonceB, SIZENONCE);
#endif

    }
  else
    {
#ifdef VERBOSE
      printf("\nNonceB does not match\n");
      fflush(stdout);
#endif
    };

  close(conn_fd);

  /* There rules come from alice. */
  /* knows rec crypt([nOnceA([alice;bob]); alice], pub(bob)). */
  /* knows rec crypt(nOnceB([alice;bob]), pub(bob)).  */
  /* context rec [alice ; bob].  */

  /* Checking first message from Alice. */
  /* conjecture knows rec crypt([nOnceA([alice;bob]); alice] , pub(bob)). */
  /* conjecture X rec crypt([nOnceA([alice;bob]); alice], pub(bob)) | *cipher_1 as X. */
  /* conjecture bob_mess_1 rec [nOnceA([alice;bob]); alice]. */
  /* conjecture nonceB rec nOnceB([alice;bob]).  */
  /* conjecture bob_mess_2 rec [nOnceA([alice;bob]);nOnceB([alice;bob])]. */
  /* conjecture X rec crypt([nOnceA([alice;bob]);nOnceB([alice;bob])],pub(alice)) | *cipher_2 as X.  */
  /* conjecture X rec crypt(nOnceB([alice;bob]), pub(bob)) | *cipher_3 as X. */
  /* conjecture bob_mess_3 rec X | nonceB rec X. */

  /* Check whether nonceB is private from Alice and Bob. */
  /* % conjecture knows rec nOnceB([alice;bob]). % */

  /* % conjecture X rec nOnceB([alice;bob]) | nonceB as X. % */

  /* Check whether nonceB is really the expected nonce,
     in particular that Bob really is not communicating with Alice,
     rather with Charlie. */
  /* % conjecture X rec nOnceB([intrus;bob]) | nonceB as X. % */
  return(0);
}
