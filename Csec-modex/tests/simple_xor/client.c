// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "net.h"
#include "lib.h"

#include <string.h>
#include <stdio.h>

#include <openssl/rand.h>

#ifdef CSEC_VERIFY
  #include "common.h"
#endif

#define PAYLOAD_LEN 20

/**
 *  Assumes that payload has length PAYLOAD_LEN.
 */
void client(unsigned char * payload)
{
  ulong msg_len = PAYLOAD_LEN + 1;
  unsigned char * msg = malloc(msg_len);

  * msg = 0x01;                               // add the tag
  memcpy(msg + 1, payload, PAYLOAD_LEN);      // add the payload

  unsigned char * pad = otp(msg_len);         // apply the one-time pad
  xor(msg, pad, msg_len);

  BIO * b = socket_connect();
  send(b, msg, msg_len);

#ifndef CSEC_VERIFY
  printf("sent\n");
  print_buffer(payload, PAYLOAD_LEN);
#endif
}

int main(int argc, char ** argv)
{
  unsigned char * payload = malloc(PAYLOAD_LEN);
  RAND_bytes(payload, PAYLOAD_LEN);

  client(payload);

  return 0;
}
