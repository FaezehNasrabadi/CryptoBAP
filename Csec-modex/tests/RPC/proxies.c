// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "ProgrammingInterface.h"
#include "RPC.h"

#include <proxies/common.h>
#include <proxies/interface.h>

unsigned char * get_shared_key_proxy(size_t * len)
{
  mute();
  unsigned char * ret = get_shared_key(len);
  unmute();

  stack_ptr("get_key");
  StoreBuf(&ret);

  readenv(ret, len, "keyAB");
  return ret;
}

unsigned char * get_request_proxy(size_t * len)
{
  mute();
  unsigned char * ret = get_request(len);
  unmute();

  stack_ptr("get_request");
  StoreBuf(&ret);

  readenv(ret, len, "request");
  return ret;
}

dstr_c *service_proxy(dstr_c *s)
{
  mute();
  dstr_c * ret = service(s);
  unmute();

  fresh_ptr(sizeof(*ret));
  StoreBuf(&ret);

  get_env(&(ret->address), &(ret->length), "response");

  if(ret->length > MAX_RESPONSE_LEN) {
    fprintf(stderr, "Response too long.\n");
    return 1;
  }

  return ret;
}
