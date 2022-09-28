
// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

/**
 * These are utility functions used by the (annotated) protocol code.
 */

#ifndef PROXY_COMMON
#define PROXY_COMMON

// This should be included by all files that call crest functions explicitly
// #include <crest.h>

#include <stdlib.h>
#include <stdint.h>

#include <openssl/bn.h>

#ifdef __cplusplus
	#define EXTERN extern "C"
#else
	#define EXTERN extern
#endif

EXTERN void proxy_fail(const char * fmt, ...);

extern void get_envE(unsigned char ** buf,
                     const unsigned char * len,
                     size_t lenlen,
                     const char * name);

extern void get_env(unsigned char ** buf, size_t * len, const char * name);

void readenv(const unsigned char * buf, const size_t * len, const char * s);
/**
 * A version that does not assume a particular length size.
 * lenlen should be an appropriate value even if len is NULL.
 */
void readenvE(const unsigned char * buf, const unsigned char * len, size_t lenlen, const char * s);

void readenvL(const unsigned char * buf, size_t len, const char * s);
// shouldn't use this at all?
void make_sym(const unsigned char * buf, size_t len, const char * s);
void event0(const char * s);
void event1(const char * s, const unsigned char * buf, size_t len);
void event2(const char * s, const unsigned char * buf1, size_t len1,
                            const unsigned char * buf2, size_t len2);
void event3(const char * s, const unsigned char * buf1, size_t len1,
                            const unsigned char * buf2, size_t len2,
                            const unsigned char * buf3, size_t len3);
void event4(const char * s, const unsigned char * buf1, size_t len1,
                            const unsigned char * buf2, size_t len2,
                            const unsigned char * buf3, size_t len3,
                            const unsigned char * buf4, size_t len4);

void typehint(const unsigned char * buf, size_t len, const char * type);
void hint(const unsigned char * buf, size_t len, const char * name);

void append_zero(const unsigned char * buf);

/**
 * Adds an assumption that buf does not contain zero and appends zero to buf.
 */
void assume_string(const unsigned char * name);

#endif /* PROXY_COMMON */

