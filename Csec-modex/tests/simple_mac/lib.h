// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include <stddef.h>

#define SHA1_LEN 20
#define MAX_PAYLOAD_LEN 1000
#define MAX_KEY_LEN 1000

extern void fail(const char * fmt, ...);

extern unsigned char * get_payload(size_t * len);
extern unsigned char * get_key(size_t * len);
