/*
** BN_bin2bn(3) BN_bn2bin(3)
**
*/

#ifndef _NS_H_
#define _NS_H_

#include <openssl/bn.h>

#define ALICE_ID 0
#define BOB_ID 1

#define MSG1 1
#define MSG2 2
#define MSG3 3


#define SIZENONCE 16

typedef struct key_s nskey_t;
struct nskey_s
{
  BIGNUM *pub_exp;
  BIGNUM *pub_mod;
  BIGNUM *priv_exp;
};

typedef struct msg1_s msg1_t;
struct msg1_s
{
  /* uid utilisateur (alice=0 bob=1 etc...) */
  unsigned long id;

  /* donnee aleatoire read(/dev/urandom)
  ** RAND_bytes(3) d'openssl */
  unsigned char nonce[SIZENONCE];
};

typedef struct msg2_s msg2_t;
struct msg2_s
{
  unsigned char nonce1[SIZENONCE];
  unsigned char nonce2[SIZENONCE];
};

typedef struct msg3_s msg3_t;
struct msg3_s
{
  unsigned char nonce[SIZENONCE];
};

union msg_generic_u
{
  msg1_t msg1;
  msg2_t msg2;
  msg3_t msg3;
};

typedef union msg_generic_u msg_generic_t;

typedef struct msg_s msg_t;
struct msg_s
{
  int msg_type;
  msg_generic_t msg;
};

#endif
