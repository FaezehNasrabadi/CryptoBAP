
// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "common_internal.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <iostream>

extern "C"
{
  void proxy_fail(const char * fmt, ...)
  {
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    exit(1);
  }
}

string buffer2string(const unsigned char * buf, int len)
{
  string s = "";
  char b[5];
  for(int i = 0; i < len; i++)
  {
    if((isgraph(buf[i]) && buf[i] != '\\') || buf[i] == ' ')
      sprintf(b, "%c", buf[i]);
    else
      sprintf(b, "\\%.3u", buf[i]);
    s += string(b);
  }
  return s;
}

