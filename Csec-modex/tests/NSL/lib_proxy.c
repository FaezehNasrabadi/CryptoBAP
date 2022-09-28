// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "lib.h"
#include "net.h"

#include "common.h"
#include "interface.h"
// Temporary
#include "crest.h"

extern void nonce_proxy(unsigned char * N)
{
  mute();
  nonce(N);
  unmute();

  newTL(SIZE_NONCE, "nonce", "nonce");
  store_buf(N);
}

extern size_t encrypt_proxy(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen, unsigned char * out)
{
  mute();
  size_t ret = encrypt(key, keylen, in, inlen, out);
  unmute();

  load_buf(in, inlen, "msg");
  load_buf(key, keylen, "key");
  // hm, it would be sensible to set length to keylen here, but right now I don't allow len() inside lens
  SymN("isek", 1);
  Hint("key");
  // FIXME: what's the actual seed length?
  newTL(256, "seed_T", "nonce");
  SymN("E", 3);
  Hint("cipher");

  store_len(&ret, sizeof(ret), false);

  assume(ret <= encrypt_len(key, keylen, in, inlen));
  assume(ret >= inlen);

  store_buf(out);

  return ret;
}

extern size_t decrypt_proxy(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen, unsigned char * out)
{
  mute();
  size_t ret = decrypt(key, keylen, in, inlen, out);
  unmute();

  load_buf(in, inlen, "cipher");
  load_buf(key, keylen, "key");
  SymN("D", 2);
  SymN("inverse_injbot", 1);
  Hint("msg");

  store_len(&ret, sizeof(ret), false);

  // There is actually no point assuming this since this is checked in
  // decrypt_len
  assume(ret <= decrypt_len(key, keylen, in, inlen));

  store_buf(out);

  return ret;
}

unsigned char * get_sigkey_proxy(size_t * len)
{
  mute();
  unsigned char * ret = get_sigkey(len);
  unmute();

  stack_ptr("get_sigkey_ret");
  StoreBuf(&ret);

  readenv(ret, len, "pkS");
  return ret;
}

unsigned char * get_pkey_proxy(size_t * len, char side)
{
  mute();
  unsigned char * ret = get_pkey(len, side);
  unmute();

  stack_ptr("get_pkey_ret");
  StoreBuf(&ret);

  char name[] = "pkX";
  name[2] = side;

  readenv(ret, len, name);

  if(*len > 100)
    fail("pkey too long");

//  make_sym(len, sizeof(*len), "user_len");
//  make_sym(ret, *len, name);

  return ret;
}


unsigned char * get_skey_proxy(size_t * len, char side)
{
  mute();
  unsigned char * ret = get_skey(len, side);
  unmute();

  stack_ptr("get_skey_ret");
  StoreBuf(&ret);

  char name[] = "skX";
  name[2] = side;

  readenv(ret, len, name);

  if(*len > 100)
    fail("pkey too long");

//  make_sym(len, sizeof(*len), "user_len");
//  make_sym(ret, *len, name);

  return ret;
}

unsigned char * get_xkey_proxy(size_t * len, const unsigned char * host, size_t host_len)
{
  mute();
  unsigned char * ret = get_xkey(len, host, host_len);
  unmute();

  stack_ptr("get_xkey_ret");
  StoreBuf(&ret);

  char name[] = "pkX";

  readenv(ret, len, name);

  if(*len > 100)
    fail("pkey too long");

//  make_sym(len, sizeof(*len), "user_len");
//  make_sym(ret, *len, name);

  return ret;
}

unsigned char * get_xsig_proxy(size_t * len, const unsigned char * host, size_t host_len)
{
  mute();
  unsigned char * ret = get_xsig(len, host, host_len);
  unmute();

  stack_ptr("get_xsig_ret");
  StoreBuf(&ret);

  char name[] = "sigX";
  readenv(ret, len, name);
  return ret;
}

unsigned char * get_host_proxy(size_t * len, char side)
{
  mute();
  unsigned char * ret = get_host(len, side);
  unmute();

  stack_ptr("get_host_ret");
  StoreBuf(&ret);

  char name[] = "hostX";
  name[4] = side;
  readenv(ret, len, name);

  if(*len > 40)
    fail("host name too long");

  return ret;
}

unsigned char * get_xhost_proxy(size_t * len, char side)
{
  mute();
  unsigned char * ret = get_xhost(len, side);
  unmute();

  stack_ptr("get_xhost_ret");
  StoreBuf(&ret);

  char name[] = "hostX";
  readenv(ret, len, name);

  if(*len > 40)
    fail("host name too long");

  return ret;
}

bool check_key_proxy(const unsigned char * host, size_t host_len,
                     const unsigned char * key, size_t key_len,
                     const unsigned char * sig, size_t sig_len,
                     const unsigned char * sigkey, size_t sigkey_len)
{
  mute();
  bool ret = check_key(host, host_len, key, key_len, sig, sig_len, sigkey, sigkey_len);
  unmute();

  load_buf(host, host_len, "host");
  load_buf(key, key_len, "key");
  load_buf(sig, sig_len, "sig");
  load_buf(sigkey, sigkey_len, "sigkey");

  SymT("(check_key : bitstring * bitstring * bitstring * bitstring -> bool)");
  SymN("bs_of_truth[1]", 1);
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));

  store_buf(&ret);

  return ret;
}

void print_buffer_proxy(const unsigned char * buf, int len)
{
  mute();
  print_buffer(buf, len);
  unmute();
}

extern void wait_close_proxy(BIO *c )
{
  mute();
  wait_close(c);
  unmute();
}

