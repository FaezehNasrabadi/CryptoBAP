// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "lib.h"

#include <proxies/common.h>
#include <proxies/interface.h>
#include <proxies/system_proxies.h>

#include <string.h>

unsigned char * otp_proxy(size_t len)
{
  mute();
  char * ret = otp(len);
  unmute();

  fresh_ptr(len);
  store_buf(&ret);
  readenvL(ret, len, "pad");

  return ret;
}

extern void xor_proxy(unsigned char * buf, unsigned char * pad, size_t len)
{
  mute();
  xor(buf, pad, len);
  unmute();

  load_buf(buf, len, NULL);
  load_buf(pad, len, NULL);
  SymN("XOR", 2);
  Hint("xor");
  assume_len(&len, false, sizeof(len));
  store_buf(buf);
}
