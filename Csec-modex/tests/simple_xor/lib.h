// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include <stddef.h>

/**
 * Return a piece of the shared one-time pad of given length.
 *
 * Only to be used once. Returns low entropy (ASCII) right now, so
 * not to be taken seriously.
 */
extern unsigned char * otp(size_t len);

/**
 * Updates buf in place.
 */
extern void xor(unsigned char * buf, unsigned char * pad, size_t len);

extern void print_buffer(const unsigned char * buf, int len);

extern void fail(const char * fmt, ...);
