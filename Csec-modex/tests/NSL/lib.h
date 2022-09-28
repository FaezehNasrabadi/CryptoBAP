// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#ifndef LIB_H_
#define LIB_H_

#include <stdlib.h>
#include <stdbool.h>

// CR: this should be 100 according to the template
#define SIZE_KEY 3

// We just add a tag saying "encrypt" in our toy crypto
#define ENCRYPTION_OVERHEAD 7

#define SIZE_NONCE 20
#define MAX_SIZE_KEY 100
#define MAX_SIZE_HOST 40
#define MAX_SIZE_CIPHER 1000

// shall we include parameters with events?
#define USE_EVENT_PARAMS

extern void nonce(unsigned char * N);

extern size_t encrypt_len(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen);

/**
 * Returns actual outlen
*/
extern size_t encrypt(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen, unsigned char * out);

extern size_t decrypt_len(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen);

/**
 * Returns actual outlen
*/
extern size_t decrypt(unsigned char * key, size_t keylen, unsigned char * in, size_t inlen, unsigned char * out);

// The signature key of the key server
unsigned char * get_sigkey(size_t * len);

// Our own public key
unsigned char * get_pkey(size_t * len, char side);

// Our own secret key
unsigned char * get_skey(size_t * len, char side);

// Our hostname
unsigned char * get_host(size_t * len, char side);

// The hostname of the other party
unsigned char * get_xhost(size_t * len, char side);

// The public key of the other party
unsigned char * get_xkey(size_t * len, const unsigned char * host, size_t host_len);

// The signature binding the hostname of the other party to its public key
unsigned char * get_xsig(size_t * len, const unsigned char * host, size_t host_len);

bool check_key(const unsigned char * host, size_t host_len,
               const unsigned char * key, size_t key_len,
               const unsigned char * sig, size_t sig_len,
               const unsigned char * sigkey, size_t sigkey_len);

extern void fail(const char * fmt, ...);

extern void print_buffer(const unsigned char * buf, int len);

#endif /* LIB_H_ */
