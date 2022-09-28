/**
 * prp.h
 *
 * Optimised ANSI C AES code modified from reference code.  Decrypt
 * routine is removed, and the code is optimized for GCM's awesome
 * brand of counter mode, where only the lower 32 bits change.  This
 * means we can skip nearly a whole round per block cipher invocation.
 */
#ifndef __PRP_H
#define __PRP_H

#define MAXKC	(256/32)
#define MAXKB	(256/8)
#define MAXNR	14

/*  This implementation operates on fixed-size types.  We assume that
 *  one has a 64-bit int type.  While few machines still provide such
 *  a type natively, most compilers will automatically emulate a
 *  64-bit type when there isn't a native one available.
 */

#ifdef WIN32
#include <windows.h>
typedef unsigned __int64   uint64;
typedef DWORD              uint32;
typedef unsigned short     uint16;
#else
typedef unsigned long long uint64;
typedef unsigned int       uint32;
typedef unsigned short     uint16;
#endif

typedef unsigned char      uchar;

typedef uint32 AES_CTR_CTX[64];

int aes_enc_setup(uint32 rk[], const uchar cipherKey[], int keyBits);
void aes_ctr_first(uint32 rk[64], uchar nonce[12], uint32 *ctr, 
		   uchar ct[16], int keyBits);
void aes_enc(const uint32 rk[], const uchar pt[16], uchar ct[16], int keyBits);
void aes_ctr(uint32 rk[64], uint32 ctr[1], uchar ct[16], int keyBits);

#define KEY_SCHED  AES_CTR_CTX
#define ENCRYPT_INIT(sched, key, keylen) aes_enc_setup((uint32 *)(sched), key, keylen)
#define CTR_INIT(sched, nonce, ctr, out, keylen) aes_ctr_first((uint32 *)(sched), (uchar *)(nonce), (uint32 *)(ctr), (uchar *)(out), keylen)
#define CTR_ENCRYPT(sched, ctr, out, keylen) aes_ctr((uint32 *)(sched), (uint32 *)(ctr), (uchar *)(out), keylen)
#define DO_ENCRYPT(sched, in, out, keylen) aes_enc((uint32 *)(sched), (uchar *)(in), (uchar *)(out), keylen)

#endif /* __PRP_H */
