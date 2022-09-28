// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include <openssl/hmac.h>

#include "net.h"
#include "lib.h"

#include <string.h>
#include <stdio.h>

#ifdef CSEC_VERIFY
  #include <proxies/common.h>
#endif


void client(unsigned char * payload, ulong payload_len, unsigned char * key, ulong key_len)
{
  if(payload_len > MAX_PAYLOAD_LEN) fail("Client: payload too long.");
  if(key_len > MAX_KEY_LEN) fail("Client: key too long.");

  ulong body_len = sizeof(payload_len) + 1 + payload_len;
  ulong msg_len = body_len + SHA1_LEN;
  unsigned char * msg = malloc(msg_len);

  unsigned char * p = msg;
  * (ulong *)p = payload_len;                               // add length
  p += sizeof(payload_len);
  unsigned char * tag = p;
  *(p++) = 1;                                               // add the tag
  memcpy(p, payload, payload_len);                          // add the payload

  p += payload_len;

  unsigned int md_len;
  *tag = 2;
  HMAC(EVP_sha1(), key, key_len, msg, body_len, p, &md_len); // add hash
  *tag = 1;

  BIO * b = socket_connect();
  send(b, (unsigned char *) &msg_len, sizeof(msg_len));
  send(b, msg, msg_len);
}

int main(int argc, char ** argv)
{
  char * msg;
  ulong msg_len;
  char * key;
  ulong key_len;

  msg = get_payload(&msg_len);
  key = get_key(&key_len);

#ifdef CSEC_VERIFY
  event1("client_send", msg, msg_len);
#endif


  client((unsigned char*) msg, msg_len, (unsigned char *) key, key_len);

  return 0;
}
