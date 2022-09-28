// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "lib.h"

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

const unsigned char payload[] = "Hello world";
const unsigned char key[] = "Secret key";

unsigned char * get_payload(size_t * len)
{
  *len = strlen(payload);
  return payload;
}

unsigned char * get_key(size_t * len)
{
  *len = strlen(key);
  return key;
}

void fail(const char * fmt, ...)
{
  va_list argp;
  va_start(argp, fmt);
  vfprintf(stderr, fmt, argp);
  va_end(argp);
  fprintf(stderr, "\n");

  // if(c != NULL) wait_close(c);

  exit(1);
}
