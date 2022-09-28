// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "lib.h"

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>

unsigned char * otp(size_t len)
{
  unsigned char * buf = malloc(len);

  /*
   * WARNING: right now otp.in contains text data, and we read it as binary,
   * so not to be taken seriously.
   */
  FILE * f;
  if((f = fopen("otp.in", "r")) == NULL)
    fail("cannot read one-time pad file");

  if(fread(buf, 1, len, f) < len)
    fail("cannot read one-time pad file");

  fclose(f);

  return buf;
}

extern void xor(unsigned char * buf, unsigned char * pad, size_t len)
{
  int i;
  for(i = 0; i < len; i++)
    buf[i] ^= pad[i];
}

void print_buffer(const unsigned char * buf, int len)
{
  if(!buf)
  {
    printf("NULL");
    return;
  }

  int i;
  for(i = 0; i < len; i++)
    if(isprint(buf[i]))
      putchar(buf[i]);
    else
      printf("\\%.2x", buf[i]);

  printf("\n");
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
