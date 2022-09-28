// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "lib.h"
#include "net.h"

#include <proxies/common.h>
#include <proxies/interface.h>

unsigned char * get_key_proxy(size_t * len)
{
  mute();
  unsigned char * ret = get_key(len);
  unmute();

  // CR: use getenv
  stack_ptr("get_key");
  StoreBuf(&ret);

  readenv(ret, len, "key");
  return ret;
}

unsigned char * get_payload_proxy(size_t * len)
{
  mute();
  unsigned char * ret = get_payload(len);
  unmute();

  // CR: use getenv
  stack_ptr("get_payload");
  StoreBuf(&ret);

  readenv(ret, len, "payload");
  return ret;
}
