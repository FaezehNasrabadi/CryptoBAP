// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "keys.h"
#include "lib.h"

#include <string.h>

unsigned char * lookup_xkey(size_t * key_len, const unsigned char * xhost, size_t xhost_len, char side)
{
  unsigned char * sig, * key, * sigkey;
  size_t sig_len, sigkey_len;

  key = get_xkey(key_len, xhost, xhost_len);
  sig = get_xsig(&sig_len, xhost, xhost_len);
  sigkey = get_sigkey(&sigkey_len);

  // check that sig binds host to key
  if(!check_key(xhost, xhost_len, key, *key_len, sig, sig_len, sigkey, sigkey_len))
    fail("could not check that key belongs to host");

  return key;
}
