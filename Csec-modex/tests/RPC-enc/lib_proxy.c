// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "lib.h"

#include <proxies/common.h>
#include <proxies/interface.h>
#include <proxies/system_proxies.h>

#include <string.h>

#include "rpc-enc.h"

/*
extern uint32_t encrypt_len_proxy(unsigned char * key, uint32_t keylen, unsigned char * in, uint32_t inlen)
{
  uint32_t ret = encrypt_len(key, keylen, in, inlen);

  // Don't use "len"
  symL("encrypt_len", "len", sizeof(ret), false);
  store_buf(&ret);

  if(ret < 0) exit(1);

  return ret;
}
*/

extern uint32_t encrypt_proxy(unsigned char * key, uint32_t keylen, unsigned char * in, uint32_t inlen, unsigned char * out)
{
  mute();
  uint32_t ret = encrypt(key, keylen, in, inlen, out);
  unmute();

  load_buf(in, inlen, "msg");
  load_buf(key, keylen, "key");
  // FIXME: is the seed really 16 bytes?
  newTL(16, "seed", "nonce");

  SymN("E", 3);
  Hint("cipher");
  store_len(&ret, sizeof(ret), false);

  if(ret > encrypt_len(key, keylen, in, inlen))
    fail("encrypt_proxy: bad length");

  store_buf(out);

  return ret;
}

/*
extern uint32_t decrypt_len_proxy(unsigned char * key, uint32_t keylen, unsigned char * in, uint32_t inlen)
{
  uint32_t ret = decrypt_len(key, keylen, in, inlen);

  symL("decrypt_len", "len", sizeof(ret), false);
  store_buf(&ret);

  if(ret < 0) exit(1);

  return ret;
}
*/

extern uint32_t decrypt_proxy(unsigned char * key, uint32_t keylen, unsigned char * in, uint32_t inlen, unsigned char * out)
{
  mute();
  uint32_t ret = decrypt(key, keylen, in, inlen, out);
  unmute();

  load_buf(in, inlen, "cipher");
  load_buf(key, keylen, "key");

  SymN("D", 2);
  SymN("inverse_injbot", 1);
  Hint("msg");
  store_len(&ret, sizeof(ret), false);

  if(ret > decrypt_len(key, keylen, in, inlen))
    fail("decrypt_proxy: bad length");

  store_buf(out);

  return ret;
}

unsigned char * get_shared_key_proxy(unsigned char* client, uint32_t client_len, unsigned char* server, uint32_t server_len, uint32_t * len)
{
  mute();
  unsigned char * ret = get_shared_key(client, client_len, server, server_len, len);
  unmute();

  stack_ptr("shared_key_ptr");
  StoreBuf(&ret);

  // We only provide the service for one identity of attacker's choice
  // (xClient).  This can be improved with multipath, because then we can just
  // inline the case split bad client / good client.
  uint32_t xclient_len;
  unsigned char * xclient;

  // This could go into a separate function get_xclient, but it is used only here.
  mute();
  xclient_len = client_len;
  xclient = malloc(xclient_len);
  memcpy(xclient, client, xclient_len);
  unmute();

  size_t lenlen = sizeof(xclient_len);
  get_envE(&xclient, &xclient_len, lenlen, "xClient");

  if((client_len != xclient_len) || memcmp_proxy(client, xclient, xclient_len))
    fail("trying to look up key for unknown host");

  load_buf(client, client_len, "client");
  load_buf(server, server_len, "server");
  varsym("db");

  SymN("lookup", 3);
  assume_intype("bitstring");
  Hint("kAB");
  store_len(len, sizeof(*len), false);

  store_buf(ret);
  //readenv(ret, len, "kAB");

  return ret;
}

unsigned char * mk_session_key_proxy(uint32_t * len)
{
  mute();
  unsigned char * ret = mk_session_key(len);
  unmute();

  stack_ptr("session_key_ptr");
  StoreBuf(&ret);

  newTL(16, "keyseed", "kS_seed");

  SymN("kgen", 1);
  Hint("kS");
  store_len(len, sizeof(*len), false);

  store_buf(ret);

  if(*len != 16)
    fail("The session key is wrong (impossible)");

  return ret;
}

/*
unsigned char * get_request_proxy(uint32_t * len)
{
  unsigned char * ret = get_request(len);

  symNE("nonce", "request", len, sizeof(*len), false);
  store_buf(ret);

  return ret;
}
*/


unsigned char * get_request_proxy(uint32_t * len, const char * request)
{
  mute();
  unsigned char * ret = get_request(len, request);
  unmute();

  stack_ptr("request_ptr");
  StoreBuf(&ret);

  readenvE(ret, (unsigned char *) len, sizeof(*len), "request");

  if(*len > MAX_PAYLOAD_LENGTH || *len < MIN_PAYLOAD_LENGTH)
    fail("Server: reuqest of wrong  size");

  return ret;
}


unsigned char * get_response_proxy(uint32_t * len)
{
  mute();
  unsigned char * ret = get_response(len);
  unmute();

  stack_ptr("response_ptr");
  StoreBuf(&ret);

  readenvE(ret, (unsigned char *) len, sizeof(*len), "response");

  if(*len > MAX_PAYLOAD_LENGTH || *len < MIN_PAYLOAD_LENGTH)
    fail("Server: response of wrong  size");

  return ret;
}

void print_buffer_proxy(const unsigned char * buf, int len)
{
  mute();
  print_buffer(buf, len);
  unmute();
}

void print_text_buffer_proxy(const unsigned char * buf, int len)
{
  mute();
  print_text_buffer(buf, len);
  unmute();
}
