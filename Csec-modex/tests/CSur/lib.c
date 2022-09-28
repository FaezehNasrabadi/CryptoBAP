// Copyright (c) Mihhail Aizatulin (avatar@hot.ee), Francois Dupressoir (fdupress@gmail.com).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "lib.h"

#include <stdio.h>

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
