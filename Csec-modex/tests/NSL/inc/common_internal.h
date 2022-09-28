
// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.


/**
 * These are utility functions used internally by the proxy (interface) functions.
 */

#ifndef PROXY_COMMON_INTERNAL
#define PROXY_COMMON_INTERNAL

#include "common.h"

#ifdef __cplusplus
  #include <string>

  using namespace std;

  extern string buffer2string(const unsigned char * buf, int len);
#endif

#endif /* PROXY_COMMON_INTERNAL */
