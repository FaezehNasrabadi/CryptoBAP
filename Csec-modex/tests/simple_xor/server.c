// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include <openssl/hmac.h>

#include "net.h"

#include <string.h>

#include "lib.h"

#ifdef CSEC_VERIFY
  #include "common.h"
#endif

#define PAYLOAD_LEN 20

/**
 * Writes the received payload into payload argument and returns the tag of the message
 */
unsigned char server(unsigned char * payload)
{
  ulong msg_len = PAYLOAD_LEN + 1;
  unsigned char* msg = malloc(msg_len);

  // receive the message
  BIO * b = socket_listen();
  recv(b, msg, msg_len);
  // wait for the client to close, to avoid "Address already in use" errors
  wait_close(b);

  unsigned char * pad = otp(msg_len);         // apply the one-time pad
  xor(msg, pad, msg_len);

  // get the payload
  memcpy(payload, msg + 1, PAYLOAD_LEN);

  // return the tag
  return *msg;
}

void consume(unsigned char tag, unsigned char * payload)
{
#ifndef CSEC_VERIFY
  printf("received\n");
  print_buffer(payload, PAYLOAD_LEN);
#endif
}

int main(int argc, char ** argv)
{
  unsigned char * payload = malloc(PAYLOAD_LEN);

  unsigned char tag = server(payload);

  // Now consume the tag and the payload.
  // This is not part of the model and in fact would violate secrecy if observable.
  consume(tag, payload);

  return 0;
}
 
