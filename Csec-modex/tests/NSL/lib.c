// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "lib.h"

#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <ctype.h>

#include <openssl/rand.h>

/*
  These functions are now stubs, real ones will be using something along the lines of

  #include <openssl/evp.h>
  EVP_PKEY_CTX *EVP_PKEY_CTX_new(EVP_PKEY *pkey, ENGINE *e);
  EVP_PKEY *EVP_PKEY_new(void);
  int EVP_PKEY_set1_RSA(EVP_PKEY *pkey,RSA *key);

  For now it doesn't really matter what's in here because the verification doesn't look into these functions.
*/

extern void nonce(unsigned char * N)
{
  memcpy(N, "nonce", 5);
  RAND_bytes(N + 5, SIZE_NONCE - 5);
}

extern size_t encrypt_len(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen)
{
  return ENCRYPTION_OVERHEAD + inlen;
}

extern size_t encrypt(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen, unsigned char * out)
{
  if(memcmp(key, "pk", 2))
  {
    fprintf(stderr, "encrypt: wrong key type\n");
    exit(1);
  }

  memcpy(out, "encrypt", 7);
  memcpy(out + 7, in, inlen);

  return encrypt_len(key, keylen, in, inlen);
}

extern size_t decrypt_len(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen)
{
  if(inlen < ENCRYPTION_OVERHEAD)
    fail("decrypt_len: ciphertext too short");

  return inlen - ENCRYPTION_OVERHEAD;
}

extern size_t decrypt(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen, unsigned char * out)
{
  size_t outlen = decrypt_len(key, keylen, in, inlen);

  memcpy(out, in + 7, outlen);

  return outlen;
}

unsigned char * get_sigkey(size_t *  len)
{
  *len = 3;
  return (unsigned char *) "pkS";
}

unsigned char * get_pkey(size_t * len, char side)
{
  *len = 3;

  char * ret;

  if(side == 'A') ret = "pkA";
  if(side == 'B') ret = "pkB";

  return (unsigned char *) ret;
}

unsigned char * get_skey(size_t * len, char side)
{
  *len = 3;

  char * ret;

  if(side == 'A') ret = "skA";
  if(side == 'B') ret = "skB";

  return (unsigned char *) ret;
}

unsigned char * get_xkey(size_t * len, const unsigned char * xhost, size_t xhost_len)
{
  *len = 3;

  char * ret;

  if(xhost[4] == 'A') ret = "pkA";
  if(xhost[4] == 'B') ret = "pkB";

  return (unsigned char *) ret;
}

unsigned char * get_host(size_t * len, char side)
{
  *len = 5;

  char * ret;

  if(side == 'A') ret = "hostA";
  if(side == 'B') ret = "hostB";

  return (unsigned char *) ret;
}

unsigned char * get_xhost(size_t * len, char side)
{
  *len = 5;

  char * ret;

  if(side == 'A') ret = "hostB";
  if(side == 'B') ret = "hostA";

  return (unsigned char *) ret;
}


unsigned char * get_xsig(size_t * len, const unsigned char * xhost, size_t xhost_len)
{
  *len = 4;

  char * ret;

  if(xhost[4] == 'A') ret = "sigA";
  if(xhost[4] == 'B') ret = "sigB";

  return (unsigned char *) ret;
}

bool check_key(const unsigned char * host, size_t host_len,
               const unsigned char * key, size_t key_len,
               const unsigned char * sig, size_t sig_len,
               const unsigned char * sigkey, size_t sigkey_len)
{
  // TODO: implement cryptographically
  return ((host[4] == key[2]) && (key[2] == sig[3]));
}

void fail(const char * fmt, ...)
{
  va_list argp;
  va_start(argp, fmt);
  vfprintf(stderr, fmt, argp);
  va_end(argp);
  printf("\n");

  // if(c != NULL) wait_close(c);

  exit(1);
}


void print_buffer(const unsigned char * buf, int len)
{
  if(!buf)
  {
    printf("NULL");
    return;
  }

  int i;
  for(i = 0; i < len; i++)
    if(isprint(buf[i]))
      putchar(buf[i]);
    else
      printf("\\%.2x", buf[i]);

  printf("\n");
}
