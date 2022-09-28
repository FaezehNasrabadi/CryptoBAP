/*
Ce fichier d�crit le protocole du point de vue de "Alice"
*/

#include <openssl/bn.h>
#include <openssl/rand.h>

#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <string.h>

#include "needham_type.h"
#include "common.h"
#include "lib.h"
#include "primitives_crypt.h"

#ifdef CSEC_VERIFY
#include <proxies/common.h>
#include "proxies.h"
#endif

/*
 A -> B : {Na, A}_pub(B).
 B -> A : {Na, Nb}_pub(A).
 A -> B : { Nb }_Pub(B).
*/

/* Dolev Yao Rules. */

/* % knows(nil).                                                       % */
/* % knows(pair (X,Y))      <= knows(X), knows(Y).                     % */
/* % knows(X)               <= knows(pair(X,Y)).                       % */
/* % knows(Y)               <= knows(pair(X,Y)).                       % */
/* % knows(crypt(X,Y))      <= knows(X), knows(Y).                     % */
/* % knows(M)               <= knows(crypt(M,pub(Y))), knows(prv(Y)).  % */

/* Initial knowledge of intruder. */

/* % knows(pub(A)) <= agent(A).                                        % */
/* % agent(alice).                                                     % */
/* % agent(bob).                                                       % */
/* % agent(intrus).                                                    % */
/* % knows(prv(intrus)).                                               % */

/* Rule from Bob. */

/* knows(crypt([Na;nOnceB([Xa;Xb])], pub(Xa)))
                                  <= knows(crypt([Na; Xa] , pub(Xb))). */

int main(int argc, char **argv) {

  int conn_fd;     /* La socket.                     */
  char alice[30];  /* Le nom de la machine d'Alice.  */
  int  alice_port; /* Le port de la machine d'Alice. */
  char bob[30];    /* Le nom de la machine de Bob.   */
  int  bob_port;   /* Le port de la machine de Bob.  */

  unsigned char nonceA[16];
  char temp[1024];

  /* Les messages. */
  msg_t alice_mess_1;
  BIGNUM *cipher_1;

  /* Le message de type 2. */
  msg_t alice_mess_2;
  BIGNUM *cipher_2;

  /* Le message de type 3. */
  msg_t alice_mess_3;
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

  /* */
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

  /* */
#ifdef VERBOSE
  printf("\nAlice's key = ");
  printf_keys(alice_key);
  printf("\nBob's key = ");
  printf_keys(bob_key);
#endif

  /* Initialisation des parametres d'Alice.       */
  /* Initialisation du port et du nom par d�faut. */
  alice_port = PORT_ALICE;
  strcpy(alice,"127.0.0.1");
  bob_port = PORT_BOB;
  strcpy(bob,"127.0.0.1");

  /* Initialisation des informations d'Alice. */
  if (argc == 3)
    {
      strcpy(bob,argv[1]);
      bob_port = atoi(argv[2]);
    }
  else if (argc > 3)
    exit(1);

#ifdef VERBOSE
  printf("\n Launching Alice with data:");
  printf("\n    Alice      = %s ", alice);
  printf("\n    Alice port = %d ", alice_port);
  printf("\n    Bob        = %s ", bob);
  printf("\n    Bob port   = %d ", bob_port);

  /* Initialisation de la connexion vers B.   */
  /* La machine de B est donn� en argument.   */
  printf("\n Connecting Bob(%s) on port %d\n", bob, bob_port);
#endif

  conn_fd = connect_socket(bob, bob_port);

#ifdef VERBOSE
  printf("Connecting Bob ok");
#endif

  /** Ici, d�but du protocole crypto. **/

  /* Cr�ation d'un nonce. */
  /* int RAND_bytes(unsigned char *buf, int num); */
  RAND_bytes(nonceA, 16);

  /* % nonceA rec nOnceA(X) | context rec X. % */

  /* Cool, on a le nonceA. */
  alice_mess_1.msg_type = MSG1;
  alice_mess_1.msg.msg1.id = ALICE_ID;
  memcpy(alice_mess_1.msg.msg1.nonce, nonceA, sizeof(nonceA));

  // printf("\nAlice : nonceA = ");
  // print_buffer(nonceA, SIZENONCE);
  // printf("\nAlice : alice_mess_1.msg.msg1.nonce = ");
  // print_buffer(alice_mess_1.msg.msg1.nonce, SIZENONCE);

  /* % alice_mess_1 rec [Na;A] | nonceA rec Na. % */

  /* crypto comments for First message. */
  /* % alice_mess_1 rec [A;noncea([A;B])]. % */

  // printf("\n A -> B : \n Bob's message 1 (from Alice)");
  //   printf_message(&alice_mess_1);

  /* Chiffrement du message. */
  cipher_1 = BN_new();
  my_cypher( &alice_mess_1, bob_key, cipher_1);

#ifdef VERBOSE
  printf("\nAlice [1] : {a , Na}_pub(b)");
  printf("\n Alice: ciphertext sent [1] = %s ", BN_bn2hex(cipher_1));
#endif

  write(conn_fd, BN_bn2hex(cipher_1), 128);

  /* Seconde partie : Lecture du message de "Bob". */
  cipher_2 = BN_new();
  read(conn_fd, temp, 128);
  // BUG: this line wasn't there
  temp[128] = 0;
#ifdef VERBOSE
  printf("\n Alice: ciphertext received [2] = %s ", temp);
#endif
  BN_hex2bn(&cipher_2, temp);
  /* On dechiffre le message. */

  my_decypher(cipher_2, alice_key, &alice_mess_2);

  /* On v�rifie que le nonce est bien celui envoy� a "Bob" */

#ifdef VERBOSE
  printf("\nAlice : alice_mess_2.msg.msg2.nonce1 = ");
  print_buffer(alice_mess_2.msg.msg2.nonce1, sizeof(nonceA));
#endif

  if ((strncmp((char *) alice_mess_2.msg.msg2.nonce1, (char *) nonceA , sizeof(nonceA)))==0)
    {
#ifdef VERBOSE
      printf("\nOk NonceA in second message matches that in first message");
      fflush(stdout);
#endif
#ifdef CSEC_VERIFY
      event2("alice_accept", nonceA, SIZENONCE, alice_mess_2.msg.msg2.nonce2, SIZENONCE);
#endif
    }
  else
    {
#ifdef VERBOSE
      printf("\nNonceA does not match\n");
      fflush(stdout);
#endif
      exit(1);
    }

  alice_mess_3.msg_type = MSG3;
  memcpy(alice_mess_3.msg.msg3.nonce,
         alice_mess_2.msg.msg2.nonce2,
         sizeof(alice_mess_2.msg.msg2.nonce2));

  /* % alice_mess_3 rec Nb | alice_mess_2 rec [Na; Nb]. % */

  /* Creation of message 3. */

  cipher_3 = BN_new();
  my_cypher( &alice_mess_3, bob_key, cipher_3);

#ifdef VERBOSE
  printf("\n Alice: ciphertext sent [3] = %s ", BN_bn2hex(cipher_3));
#endif

  /* !!! normally:
  write(conn_fd, BN_bn2hex(cipher_3), 128);
         For bug demo:
  write(conn_fd, BN_bn2hex(cipher_1), 128);
  */

  write(conn_fd, BN_bn2hex(cipher_3), 128);

#ifdef VERBOSE
  printf("\nSession complete, ");
  printf("\n nonceA = ");
  // print_nonce(nonceA); /*@@@*/
  print_buffer(nonceA, SIZENONCE);
  printf("\n nonceB = ");
  print_buffer(alice_mess_2.msg.msg2.nonce2, SIZENONCE);
  // print_nonce(alice_mess_2.msg.msg2.nonce2); /*@@@*/
  printf("\n");
  fflush(stdout);
#endif

  close(conn_fd);

  /* Protocol context.                 */
  /* context rec [alice ; bob   ]. */
  /* % context rec [alice ; intrus]. % */
  /* % context rec [bob   ; intrus]. % */
  /* % context rec [intrus ; alice]. % */
  /* % context rec [intrus ; bob  ]. % */

  /* conjecture context rec [alice;bob]. -> Ok */
  /* conjecture nonceA rec nOnceA([alice;bob]). -> Ok */
  /* conjecture alice_mess_1 rec [nOnceA([alice;bob]); alice]. -> Ok */

  /* conjecture X rec crypt([nOnceA([alice;bob]); alice] , pub(bob)) | *cipher_1 as X. */

  /* conjecture knows rec crypt([nOnceA([alice;bob]); alice] , pub(bob)). -> Ok. */
  /* conjecture knows rec crypt([nOnceA([alice;bob]);nOnceB([alice;bob])], pub(alice)). -> Ok */
  /* conjecture X rec crypt([nOnceA([alice;bob]);nOnceB([alice;bob])], pub(alice)) | *cipher_2 as X. -> Ok */
  /* conjecture alice_mess_2 rec [nOnceA([alice;bob]);nOnceB([alice;bob])]. -> Ok */
  /* conjecture alice_mess_3 rec nOnceB([alice;bob]). */
  /* conjecture X rec crypt(nOnceB([alice;bob]), pub(bob)) | *cipher_3 as X. -> Ok */
  /* conjecture knows rec crypt(nOnceB([alice;bob]), pub(bob)). */

  /* % conjecture knows rec nOnceA([alice;bob]). % */
  return(0);
}
