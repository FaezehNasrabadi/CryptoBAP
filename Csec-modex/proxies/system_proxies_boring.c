// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "crest.h"
#include "interface.h"

#include <stdio.h>

int fflush_proxy(FILE *stream)
{
  mute();
  int ret = fflush(stream);
  unmute();

  fresh_var("fflush_ret");
  assume_intype("bitstring");
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));
  store_buf(&ret);

  return ret;
}

void free_proxy(void *ptr )
{
  mute();
  free(ptr);
  unmute();
}

