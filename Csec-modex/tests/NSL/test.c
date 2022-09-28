// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include <lib.h>

#include <string.h>
#include <stdio.h>

#include <proxies/common.h>

int main()
{
  unsigned char * msg = (unsigned char *) "hello world";
  size_t msglen = 12;

  unsigned char * enc;
  size_t enclen;

  unsigned char * dec;
  size_t declen;

  unsigned char * pk, * sk;
  size_t pklen, sklen;

  pk = get_pkey(&pklen, 'A');
  sk = get_skey(&sklen, 'A');

  printf("pk = ");
  print_buffer(pk, pklen);
  printf("\n");

  printf("sk = ");
  print_buffer(sk, sklen);
  printf("\n");

  enclen = encrypt_len(pk, pklen, msg, msglen);
  enc = malloc(enclen);
  encrypt(pk, pklen, msg, msglen, enc);

  printf("enc = ");
  print_buffer(enc, enclen);
  printf("\n");

  declen = decrypt_len(sk, sklen, enc, enclen);
  dec = malloc(declen);
  decrypt(sk, sklen, enc, enclen, dec);

  printf((char *)dec);
  printf("\n");

  return 0;
}
