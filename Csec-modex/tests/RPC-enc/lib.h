// Copyright (c) Mihhail Aizatulin (avatar@hot.ee), Francois Dupressoir (fdupress@gmail.com).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#ifndef LIB_H_
#define LIB_H_

#ifdef VERIFY
#include <vcc.h>
#include "table.h"
#else
#define _(...)
#endif

#include <stdlib.h>
#include <stdint.h>

extern _(pure) uint32_t encrypt_len(unsigned char * key, uint32_t keylen, unsigned char * in, uint32_t inlen);

/**
 * Returns actual outbuflen.
 *
 * The key must be 16 bytes long. We follow the PolarSSL library in accepting the keylen field,
 * but it is actually not necessary.
 *
*/
extern uint32_t encrypt(unsigned char * key, uint32_t keylen, unsigned char * in, uint32_t inlen, unsigned char * outbuf);

extern _(pure) uint32_t decrypt_len(unsigned char * key, uint32_t keylen, unsigned char * in, uint32_t inlen);

/**
 * Returns actual outbuflen.
 *
 * The key must be 16 bytes long. We follow the PolarSSL library in accepting the keylen field,
 * but it is actually not necessary.
 *
*/
extern uint32_t decrypt(unsigned char * key, uint32_t keylen, unsigned char * in, uint32_t inlen, unsigned char * outbuf);

unsigned char * get_shared_key(unsigned char* client, uint32_t client_len, unsigned char* server, uint32_t server_len, uint32_t * len);

unsigned char * mk_session_key(uint32_t * len);

/*
 * Pads the request up to MIN_REQUEST_LEN
 */
unsigned char * get_request(uint32_t * len, const char * request);
unsigned char * get_response(uint32_t * len);

extern void print_buffer(const unsigned char * buf, int len);

extern void print_text_buffer(const unsigned char * buf, int len);

extern void fail(const char * fmt, ...);

#endif /* LIB_H_ */
