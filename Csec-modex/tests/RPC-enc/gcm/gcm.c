#include "gcm.h"
#include <string.h>
#ifndef WIN32
#include <arpa/inet.h>
#endif

static void mul_alpha(uint32 *z) {
  int carry = z[3] & 1;

  z[3] >>= 1;
  z[3] |= ((z[2] & 1) << 31);
  z[2] >>= 1;
  z[2] |= ((z[1] & 1) << 31);
  z[1] >>= 1;
  z[1] |= ((z[0] & 1) << 31);
  z[0] >>= 1;

  if (carry) 
    z[0] ^= GHASH_ALPHA;
}

static void build_hash_table_64k(gcm_ctx_64k *c, uint32 hkey[4]) {
  uint32 a[4];
  int    i, j, k, t;

  a[0] = htonl(hkey[0]);
  a[1] = htonl(hkey[1]);
  a[2] = htonl(hkey[2]);
  a[3] = htonl(hkey[3]);

  for (t=0;t<16;t++) {
    c->table[t][0][0] = c->table[t][0][1] = c->table[t][0][2] = 
      c->table[t][0][3] = 0;
    i = 128, j = 256;
    while (i) {
      c->table[t][i][0] = htonl(a[0]);
      c->table[t][i][1] = htonl(a[1]);
      c->table[t][i][2] = htonl(a[2]);
      c->table[t][i][3] = htonl(a[3]);
      mul_alpha(a);
      i >>= 1;
      j >>= 1;
    }
  }
  
  for (i=1;i<256;i<<=1) {
    for (j=1;j<i;j++) {
      k = i + j;
      for (t=0;t<16;t++) {
	c->table[t][k][0] = c->table[t][i][0] ^ c->table[t][j][0];
	c->table[t][k][1] = c->table[t][i][1] ^ c->table[t][j][1];
	c->table[t][k][2] = c->table[t][i][2] ^ c->table[t][j][2];
	c->table[t][k][3] = c->table[t][i][3] ^ c->table[t][j][3];
      }
    }
  }
}

#if BYTE_ORDER == BIG_ENDIAN
#define GMULWI64K(e,t,i,s) \
  e = (uint32 *)t[i][s>>24]; t0 = e[0]; t1 = e[1]; t2 = e[2]; t3 = e[3];\
  e = (uint32 *)t[i+1][(s>>16)&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+2][(s>>8)&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+3][s&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3]

#define GMULW64K(e,t,i,s) \
  e = (uint32 *)t[i][s>>24]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+1][(s>>16)&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+2][(s>>8)&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+3][s&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3]
#else
#define GMULWI64K(e,t,i,s) \
  e = (uint32 *)t[i][s&0xff]; t0 = e[0]; t1 = e[1]; t2 = e[2]; t3 = e[3];\
  e = (uint32 *)t[i+1][(s>>8)&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+2][(s>>16)&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+3][s>>24]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3]

#define GMULW64K(e,t,i,s) \
  e = (uint32 *)t[i][s&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+1][(s>>8)&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+2][(s>>16)&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  e = (uint32 *)t[i+3][s>>24]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3]
#endif

#define GHB64K(t, b) \
  s0 ^= ((uint32 *)b)[0];		\
  s1 ^= ((uint32 *)b)[1];		\
  s2 ^= ((uint32 *)b)[2];		\
  s3 ^= ((uint32 *)b)[3];		\
  GMULWI64K(entry, t, 0, s0);\
  GMULW64K(entry, t, 4, s1);\
  GMULW64K(entry, t, 8, s2);\
  GMULW64K(entry, t, 12, s3);\
  s0 = t0; \
  s1 = t1; \
  s2 = t2; \
  s3 = t3;

MODIFIERS void gcm_init_64k(gcm_ctx_64k *c, uchar key[], size_t keylen) {
  uint32 hkgen[4] = {0,};
  uint32 hkey[4];

  if (keylen != 128 && keylen != 192 && keylen != 256) {
    return;
  }
  ENCRYPT_INIT(&(c->ck), key, keylen);
  c->keylen = keylen;
  DO_ENCRYPT(&(c->ck), (uchar *)hkgen, (uchar *)hkey, keylen);
  build_hash_table_64k(c, hkey);
}

MODIFIERS void /*inline*/ gcm_encrypt_64k(gcm_ctx_64k *c, uchar *nonce, size_t nlen, 
				      uchar *data, size_t dlen, uchar *adata, 
				      size_t alen, uchar *out, uchar *tag) {
  uint32 tmp[8] = {0, 0, 0, 0, 0, htonl(alen << 3), 0, htonl(dlen << 3)};
  uint32 ctr[4];
  size_t b, l, i;
  register uint32 t0, t1, t2, t3;
  register uint32 *entry;
  register uint32 s0 = 0, s1 = 0, s2 = 0, s3 = 0;

  /* Process the nonce first. */
  if (nlen != 12) {
    b = nlen >> 4;
    l = nlen & 15;
    while (b--) {
      GHB64K(c->table, nonce);
      nonce += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = nonce[l];
      GHB64K(c->table, tmp);
    }
    tmp[0] = tmp[1] = 0;
    tmp[2] = htonl(nlen >> 29);
    tmp[3] = htonl(nlen << 3);
    GHB64K(c->table, tmp);
    ctr[0] = s0;
    ctr[1] = s1;
    ctr[2] = s2;
    ctr[3] = htonl(s3);
    tmp[0] = tmp[1] = tmp[2] = tmp[3] = s0 = s1 = s2 = s3 = 0;
  } else {
    ctr[0] = ((uint32 *)nonce)[0];
    ctr[1] = ((uint32 *)nonce)[1];
    ctr[2] = ((uint32 *)nonce)[2];
    ctr[3] = 1;
  }
  CTR_INIT(&(c->ck), ctr, ctr + 3, tag, c->keylen);

  /* Hash associated data. */
  if (alen) {
    b = alen >> 4;
    l = alen & 15;

    for (i=0;i<b;i++) {
      GHB64K(c->table, adata);
      adata += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = adata[l];
      GHB64K(c->table, tmp);
      tmp[0] = tmp[1] = tmp[2] = tmp[3] = 0;
    }
  }

  /* Hash ciphertext. */
  b = dlen >> 4;
  l = dlen & 15;

  for (i=0;i<b;i++) {
    CTR_ENCRYPT(&(c->ck), (&ctr[3]), out, c->keylen);
    ((uint32 *)out)[0] ^= ((uint32 *)data)[0];
    ((uint32 *)out)[1] ^= ((uint32 *)data)[1];
    ((uint32 *)out)[2] ^= ((uint32 *)data)[2];
    ((uint32 *)out)[3] ^= ((uint32 *)data)[3];
    GHB64K(c->table, out);
    data += GHASH_BLK_SZ;
    out += GHASH_BLK_SZ;
  }

  if (l) {
    CTR_ENCRYPT(&(c->ck), &ctr[3], ctr, c->keylen);
    for (i=0;i<l;i++)
      out[i] = ((uchar *)ctr)[i] ^ data[i];
    memcpy(tmp, out, l);
    GHB64K(c->table, tmp);
  }

  GHB64K(c->table, (tmp + 4));
  
  ((uint32 *)tag)[0] ^= s0;
  ((uint32 *)tag)[1] ^= s1;
  ((uint32 *)tag)[2] ^= s2;
  ((uint32 *)tag)[3] ^= s3;
}

MODIFIERS int gcm_decrypt_64k(gcm_ctx_64k *c, uchar *nonce, size_t nlen, uchar *ct,
			      size_t ctlen, uchar *tag, size_t taglen, uchar *adata,
			      size_t alen, uchar *pt) {
  uint32 tmp[8] = {0, 0, 0, 0, htonl(alen >> 29), htonl(alen << 3), htonl(ctlen >> 29), htonl(ctlen << 3)};
  uint32 ctr[4];
  uchar  chksm[16];
  register char *p;
  size_t b, l, i;
  register uint32 t0, t1, t2, t3;
  register uint32 *entry;
  register uint32 s0 = 0, s1 = 0, s2 = 0, s3 = 0;

  if (taglen > 16) taglen = 16;
  if (nlen != 12) {
    b = nlen >> 4;
    l = nlen & 15;
    while (b--) {
      GHB64K(c->table, nonce);
      nonce += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = nonce[l];
      GHB64K(c->table, tmp);
    }
    tmp[0] = tmp[1] = 0;
    tmp[2] = htonl(nlen >> 29);
    tmp[3] = htonl(nlen << 3);
    GHB64K(c->table, tmp);
    ctr[0] = s0;
    ctr[1] = s1;
    ctr[2] = s2;
    ctr[3] = htonl(s3);
    tmp[0] = tmp[1] = tmp[2] = tmp[3] = s0 = s1 = s2 = s3 = 0;
  } else {
    ctr[0] = ((uint32 *)nonce)[0];
    ctr[1] = ((uint32 *)nonce)[1];
    ctr[2] = ((uint32 *)nonce)[2];
    ctr[3] = 1;
  }
  CTR_INIT(&(c->ck), ctr, ctr + 3, chksm, c->keylen);
  for (i=0;i<taglen;i++) 
    chksm[i] ^= tag[i];

  if (alen) {
    b = alen >> 4;
    l = alen & 15;

    for (i=0;i<b;i++) {
      GHB64K(c->table, adata);
      adata += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = adata[l];
      GHB64K(c->table, tmp);
      tmp[0] = tmp[1] = tmp[2] = tmp[3] = 0;
    }
  }

  b = ctlen >> 4;
  l = ctlen & 15;
  p = ct;
  
  for (i=0;i<b;i++) {
    GHB64K(c->table, p);
    p += GHASH_BLK_SZ;
  }
  if (l) {
    while (l--)
      ((uchar *)tmp)[l] = p[l];
    GHB64K(c->table, tmp);
  }
  l = ctlen & 15;
  GHB64K(c->table, (tmp + 4));
  
  ((uint32 *)chksm)[0] ^= s0;
  ((uint32 *)chksm)[1] ^= s1;
  ((uint32 *)chksm)[2] ^= s2;
  ((uint32 *)chksm)[3] ^= s3;

  for (i=taglen;i<16;i++)
      chksm[i] = 0;

  if (((uint32 *)chksm)[0] || ((uint32 *)chksm)[1] || ((uint32 *)chksm)[2] ||
      ((uint32 *)chksm)[3]) return 0;

  for (i=0;i<b;i++) {
    CTR_ENCRYPT(&(c->ck), (&ctr[3]), pt, c->keylen);
    ((uint32 *)pt)[0] ^= ((uint32 *)ct)[0];
    ((uint32 *)pt)[1] ^= ((uint32 *)ct)[1];
    ((uint32 *)pt)[2] ^= ((uint32 *)ct)[2];
    ((uint32 *)pt)[3] ^= ((uint32 *)ct)[3];
    ct += GHASH_BLK_SZ;
    pt += GHASH_BLK_SZ;
  }

  if (l) {
    CTR_ENCRYPT(&(c->ck), &ctr[3], ctr, c->keylen);
    for (i=0;i<l;i++)
      pt[i] = ((uchar *)ctr)[i] ^ ct[i];
  }
  return 1;
}

MODIFIERS void gcm_destroy_64k(gcm_ctx_64k *c) {
  memset(c, '0', sizeof(gcm_ctx_64k));
}

/* Beginning of 4K tables implementation. */
static uint32 rtable_4k[256] = {
  0x00000000, 0x01c20000, 0x03840000, 0x02460000, 0x07080000, 0x06ca0000,
  0x048c0000, 0x054e0000, 0x0e100000, 0x0fd20000, 0x0d940000, 0x0c560000, 
  0x09180000, 0x08da0000, 0x0a9c0000, 0x0b5e0000, 0x1c200000, 0x1de20000,
  0x1fa40000, 0x1e660000, 0x1b280000, 0x1aea0000, 0x18ac0000, 0x196e0000, 
  0x12300000, 0x13f20000, 0x11b40000, 0x10760000, 0x15380000, 0x14fa0000,
  0x16bc0000, 0x177e0000, 0x38400000, 0x39820000, 0x3bc40000, 0x3a060000, 
  0x3f480000, 0x3e8a0000, 0x3ccc0000, 0x3d0e0000, 0x36500000, 0x37920000,
  0x35d40000, 0x34160000, 0x31580000, 0x309a0000, 0x32dc0000, 0x331e0000, 
  0x24600000, 0x25a20000, 0x27e40000, 0x26260000, 0x23680000, 0x22aa0000,
  0x20ec0000, 0x212e0000, 0x2a700000, 0x2bb20000, 0x29f40000, 0x28360000, 
  0x2d780000, 0x2cba0000, 0x2efc0000, 0x2f3e0000, 0x70800000, 0x71420000, 
  0x73040000, 0x72c60000, 0x77880000, 0x764a0000, 0x740c0000, 0x75ce0000, 
  0x7e900000, 0x7f520000, 0x7d140000, 0x7cd60000, 0x79980000, 0x785a0000, 
  0x7a1c0000, 0x7bde0000, 0x6ca00000, 0x6d620000, 0x6f240000, 0x6ee60000, 
  0x6ba80000, 0x6a6a0000, 0x682c0000, 0x69ee0000, 0x62b00000, 0x63720000, 
  0x61340000, 0x60f60000, 0x65b80000, 0x647a0000, 0x663c0000, 0x67fe0000, 
  0x48c00000, 0x49020000, 0x4b440000, 0x4a860000, 0x4fc80000, 0x4e0a0000, 
  0x4c4c0000, 0x4d8e0000, 0x46d00000, 0x47120000, 0x45540000, 0x44960000, 
  0x41d80000, 0x401a0000, 0x425c0000, 0x439e0000, 0x54e00000, 0x55220000, 
  0x57640000, 0x56a60000, 0x53e80000, 0x522a0000, 0x506c0000, 0x51ae0000, 
  0x5af00000, 0x5b320000, 0x59740000, 0x58b60000, 0x5df80000, 0x5c3a0000, 
  0x5e7c0000, 0x5fbe0000, 0xe1000000, 0xe0c20000, 0xe2840000, 0xe3460000, 
  0xe6080000, 0xe7ca0000, 0xe58c0000, 0xe44e0000, 0xef100000, 0xeed20000, 
  0xec940000, 0xed560000, 0xe8180000, 0xe9da0000, 0xeb9c0000, 0xea5e0000, 
  0xfd200000, 0xfce20000, 0xfea40000, 0xff660000, 0xfa280000, 0xfbea0000, 
  0xf9ac0000, 0xf86e0000, 0xf3300000, 0xf2f20000, 0xf0b40000, 0xf1760000, 
  0xf4380000, 0xf5fa0000, 0xf7bc0000, 0xf67e0000, 0xd9400000, 0xd8820000, 
  0xdac40000, 0xdb060000, 0xde480000, 0xdf8a0000, 0xddcc0000, 0xdc0e0000, 
  0xd7500000, 0xd6920000, 0xd4d40000, 0xd5160000, 0xd0580000, 0xd19a0000, 
  0xd3dc0000, 0xd21e0000, 0xc5600000, 0xc4a20000, 0xc6e40000, 0xc7260000, 
  0xc2680000, 0xc3aa0000, 0xc1ec0000, 0xc02e0000, 0xcb700000, 0xcab20000, 
  0xc8f40000, 0xc9360000, 0xcc780000, 0xcdba0000, 0xcffc0000, 0xce3e0000, 
  0x91800000, 0x90420000, 0x92040000, 0x93c60000, 0x96880000, 0x974a0000, 
  0x950c0000, 0x94ce0000, 0x9f900000, 0x9e520000, 0x9c140000, 0x9dd60000, 
  0x98980000, 0x995a0000, 0x9b1c0000, 0x9ade0000, 0x8da00000, 0x8c620000, 
  0x8e240000, 0x8fe60000, 0x8aa80000, 0x8b6a0000, 0x892c0000, 0x88ee0000, 
  0x83b00000, 0x82720000, 0x80340000, 0x81f60000, 0x84b80000, 0x857a0000, 
  0x873c0000, 0x86fe0000, 0xa9c00000, 0xa8020000, 0xaa440000, 0xab860000, 
  0xaec80000, 0xaf0a0000, 0xad4c0000, 0xac8e0000, 0xa7d00000, 0xa6120000, 
  0xa4540000, 0xa5960000, 0xa0d80000, 0xa11a0000, 0xa35c0000, 0xa29e0000, 
  0xb5e00000, 0xb4220000, 0xb6640000, 0xb7a60000, 0xb2e80000, 0xb32a0000, 
  0xb16c0000, 0xb0ae0000, 0xbbf00000, 0xba320000, 0xb8740000, 0xb9b60000, 
  0xbcf80000, 0xbd3a0000, 0xbf7c0000, 0xbebe0000
};

static void build_hash_table_4k(gcm_ctx_4k *c, uint32 hkey[4]) {
  register int i = 64, j, k;
  register uint32 w, x, y, z,  carry;

  c->table[0][0] = c->table[0][1] = c->table[0][2] = c->table[0][3] = 0;
  w = htonl(hkey[0]);
  x = htonl(hkey[1]);
  y = htonl(hkey[2]);
  z = htonl(hkey[3]);

  c->table[0x80][0] = w;
  c->table[0x80][1] = x;
  c->table[0x80][2] = y;
  c->table[0x80][3] = z;

  while (i) {
    carry = z & 1;
    z >>= 1;
    z |= (y & 1) << 31;
    y >>= 1;
    y |= (x & 1) << 31;
    x >>= 1;
    x |= (w & 1) << 31;
    w >>= 1;
    if (carry)
      w ^= GHASH_ALPHA;

    c->table[i][0] = w;
    c->table[i][1] = x;
    c->table[i][2] = y;
    c->table[i][3] = z;

    i >>= 1;
  }
  for (i=1;i<256;i<<=1) {
    for (j=1;j<i;j++) {
      k = i + j;
      c->table[k][0] = c->table[i][0] ^ c->table[j][0];
      c->table[k][1] = c->table[i][1] ^ c->table[j][1];
      c->table[k][2] = c->table[i][2] ^ c->table[j][2];
      c->table[k][3] = c->table[i][3] ^ c->table[j][3];
    }
  }
}

#define SHIFT4K() \
 tt = t3 & 0xff; t3 >>= 8; t3 |= (t2 << 24); t2 >>= 8; t2 |= (t1 << 24);\
 t1 >>= 8; t1 |= (t0 << 24); t0 >>=8; t0 ^= rtable_4k[tt]
#define GMULWI4K(e,t,s) \
  e = (uint32 *)t[s&0xff]; t0 = e[0]; t1 = e[1]; t2 = e[2]; t3 = e[3];\
  SHIFT4K();\
  e = (uint32 *)t[(s>>8)&0xff];t0 ^= e[0];t1 ^= e[1];t2 ^= e[2];t3 ^= e[3];\
  SHIFT4K();\
  e = (uint32 *)t[(s>>16)&0xff];t0 ^= e[0];t1 ^= e[1];t2 ^= e[2];t3 ^= e[3];\
  SHIFT4K();\
  e = (uint32 *)t[s>>24];t0 ^= e[0];t1 ^= e[1];t2 ^= e[2];t3 ^= e[3]

#define GMULW4K(e,t,s) \
  SHIFT4K();\
  e = (uint32 *)t[s&0xff]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  SHIFT4K();\
  e = (uint32 *)t[(s>>8)&0xff];t0 ^= e[0];t1 ^= e[1];t2 ^= e[2];t3 ^= e[3];\
  SHIFT4K();\
  e = (uint32 *)t[(s>>16)&0xff];t0 ^= e[0];t1 ^= e[1];t2 ^= e[2];t3 ^= e[3];\
  SHIFT4K();\
  e = (uint32 *)t[s>>24];t0 ^= e[0];t1 ^= e[1];t2 ^= e[2];t3 ^= e[3];

#define GHB4K(t,b)\
  s0 ^= htonl(((uint32 *)b)[0]); \
  s1 ^= htonl(((uint32 *)b)[1]); \
  s2 ^= htonl(((uint32 *)b)[2]); \
  s3 ^= htonl(((uint32 *)b)[3]); \
  GMULWI4K(entry, t, s3); \
  GMULW4K(entry, t, s2);\
  GMULW4K(entry, t, s1);\
  GMULW4K(entry, t, s0);\
  s0 = t0; \
  s1 = t1; \
  s2 = t2; \
  s3 = t3;

MODIFIERS void gcm_init_4k(gcm_ctx_4k *c, uchar key[16], size_t keylen) {
  uint32 hkgen[4] = {0,};
  uint32 hkey[4];

  c->keylen = keylen;
  ENCRYPT_INIT(&(c->ck), key, keylen);
  DO_ENCRYPT(&(c->ck), (uchar *)hkgen, (uchar *)hkey, keylen);
  build_hash_table_4k(c, hkey);
}

MODIFIERS void gcm_encrypt_4k(gcm_ctx_4k *c, uchar *nonce, size_t nlen, uchar *data, 
			      size_t dlen, uchar *adata, size_t alen, uchar *out, 
			      uchar *tag) {
  uint32 tmp[8] = {0, 0, 0, 0, 0, htonl(alen << 3), 0, htonl(dlen << 3)};
  uint32 ctr[4];
  size_t b, l, i;
  register uint32 t0, t1, t2, t3, tt;
  register uint32 *entry;
  register uint32 s0 = 0, s1 = 0, s2 = 0, s3 = 0;

  if (nlen != 12) {
    b = nlen >> 4;
    l = nlen & 15;
    while (b--) {
      GHB4K(c->table, nonce);
      nonce += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = nonce[l];
      GHB4K(c->table, tmp);
    }
    tmp[0] = tmp[1] = 0;
    tmp[2] = htonl(nlen >> 29);
    tmp[3] = htonl(nlen << 3);
    GHB4K(c->table, tmp);
    ctr[0] = htonl(s0);
    ctr[1] = htonl(s1);
    ctr[2] = htonl(s2);
    ctr[3] = s3;
    tmp[0] = tmp[1] = tmp[2] = tmp[3] = s0 = s1 = s2 = s3 = 0;
  } else {
    ctr[0] = ((uint32 *)nonce)[0];
    ctr[1] = ((uint32 *)nonce)[1];
    ctr[2] = ((uint32 *)nonce)[2];
    ctr[3] = 1;

  }
  CTR_INIT(&(c->ck), ctr, ctr+3, tag, c->keylen);

  if (alen) {
    b = alen >> 4;
    l = alen & 15;

    for (i=0;i<b;i++) {
      GHB4K(c->table, adata);
      adata += 16;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = adata[l];
      GHB4K(c->table, tmp);
      tmp[0] = tmp[1] = tmp[2] = tmp[3] = 0;
    }
  }

  b = dlen >> 4;
  l = dlen & 15;

  for (i=0;i<b;i++) {
    CTR_ENCRYPT(&(c->ck), &ctr[3], out, c->keylen);
    ((uint32 *)out)[0] ^= ((uint32 *)data)[0];
    ((uint32 *)out)[1] ^= ((uint32 *)data)[1];
    ((uint32 *)out)[2] ^= ((uint32 *)data)[2];
    ((uint32 *)out)[3] ^= ((uint32 *)data)[3];
    GHB4K(c->table, out);
    data += GHASH_BLK_SZ;
    out += GHASH_BLK_SZ;
  }

  if (l) {
    CTR_ENCRYPT(&(c->ck), &ctr[3], ctr, c->keylen);
    for (i=0;i<l;i++) {
      out[i] = ((uchar *)ctr)[i] ^ data[i];
    }
    memcpy(tmp, out, l);
    GHB4K(c->table, tmp);
  }
  GHB4K(c->table, (tmp + 4));
  ((uint32 *)tag)[0] ^= htonl(s0);
  ((uint32 *)tag)[1] ^= htonl(s1);
  ((uint32 *)tag)[2] ^= htonl(s2);
  ((uint32 *)tag)[3] ^= htonl(s3);
}


MODIFIERS int gcm_decrypt_4k(gcm_ctx_4k *c, uchar *nonce, size_t nlen, uchar *ct, 
			     size_t dlen, uchar *stag, size_t taglen, uchar *adata,
			     size_t alen, uchar *out) {
  uint32 tmp[8] = {0, 0, 0, 0, 0, htonl(alen << 3), 0, htonl(dlen << 3)};
  uint32 ctr[4];
  uchar  tag[16], *p = ct;
  size_t b, l, i;
  register uint32 t0, t1, t2, t3, tt;
  register uint32 *entry;
  register uint32 s0 = 0, s1 = 0, s2 = 0, s3 = 0;

  if (taglen > 16) taglen = 16;
  if (nlen != 12) {
    b = nlen >> 4;
    l = nlen & 15;
    while (b--) {
      GHB4K(c->table, nonce);
      nonce += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = nonce[l];
      GHB4K(c->table, tmp);
    }
    tmp[0] = tmp[1] = 0;
    tmp[2] = htonl(nlen >> 29);
    tmp[3] = htonl(nlen << 3);
    GHB4K(c->table, tmp);
    ctr[0] = htonl(s0);
    ctr[1] = htonl(s1);
    ctr[2] = htonl(s2);
    ctr[3] = s3;
    tmp[0] = tmp[1] = tmp[2] = tmp[3] = s0 = s1 = s2 = s3 = 0;
  } else {
    ctr[0] = ((uint32 *)nonce)[0];
    ctr[1] = ((uint32 *)nonce)[1];
    ctr[2] = ((uint32 *)nonce)[2];
    ctr[3] = 1;

  }
  CTR_INIT(&(c->ck), ctr, ctr+3, tag, c->keylen);
  for (i=0;i<taglen;i++)
    tag[i] ^= stag[i];

  if (alen) {
    b = alen >> 4;
    l = alen & 15;

    for (i=0;i<b;i++) {
      GHB4K(c->table, adata);
      adata += 16;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = adata[l];
      GHB4K(c->table, tmp);
      tmp[0] = tmp[1] = tmp[2] = tmp[3] = 0;
    }
  }

  b = dlen >> 4;
  l = dlen & 15;

  for (i=0;i<b;i++) {
    GHB4K(c->table, p);
    p += GHASH_BLK_SZ;
  }

  if (l) {
    memcpy(tmp, p, l);
    GHB4K(c->table, tmp);
  }
  GHB4K(c->table, (tmp + 4));
  ((uint32 *)tag)[0] ^= htonl(s0);
  ((uint32 *)tag)[1] ^= htonl(s1);
  ((uint32 *)tag)[2] ^= htonl(s2);
  ((uint32 *)tag)[3] ^= htonl(s3);

  for (i=taglen;i<16;i++) {
    tag[i] = 0;
  }

  if (((uint32 *)tag)[0] || ((uint32 *)tag)[1] || 
      ((uint32 *)tag)[2] || ((uint32 *)tag)[3]) 
    return 0;
  
  for (i=0;i<b;i++) {
    CTR_ENCRYPT(&(c->ck), &ctr[3], out, c->keylen);
    ((uint32 *)out)[0] ^= ((uint32 *)ct)[0];
    ((uint32 *)out)[1] ^= ((uint32 *)ct)[1];
    ((uint32 *)out)[2] ^= ((uint32 *)ct)[2];
    ((uint32 *)out)[3] ^= ((uint32 *)ct)[3];
    ct  += GHASH_BLK_SZ;
    out += GHASH_BLK_SZ;
  }

  if (l) {
    CTR_ENCRYPT(&(c->ck), &ctr[3], ctr, c->keylen);
    for (i=0;i<l;i++) {
      out[i] = ((uchar *)ctr)[i] ^ ct[i];
    }
  }
  return 1;
}

MODIFIERS void gcm_destroy_4k(gcm_ctx_4k *c) {
  memset(c, '0', sizeof(gcm_ctx_4k));
}

/* Beginning of 256B implementation */

static uint32 rtable_256b[16] = {
  0x00000000, 0x1c200000, 0x38400000, 0x24600000, 0x70800000, 0x6ca00000,
  0x48c00000, 0x54e00000, 0xe1000000, 0xfd200000, 0xd9400000, 0xc5600000,
  0x91800000, 0x8da00000, 0xa9c00000, 0xb5e00000
};

static void build_hash_table_256b(gcm_ctx_256b *c, uint32 hkey[4]) {
  c->table[0][0] = c->table[0][1] = c->table[0][2] = c->table[0][3] = 0;
  c->table[0x8][0] = htonl(hkey[0]);
  c->table[0x8][1] = htonl(hkey[1]);
  c->table[0x8][2] = htonl(hkey[2]);
  c->table[0x8][3] = htonl(hkey[3]);

  c->table[0x4][0] = c->table[0x8][0];
  c->table[0x4][1] = c->table[0x8][1];
  c->table[0x4][2] = c->table[0x8][2];
  c->table[0x4][3] = c->table[0x8][3];

  mul_alpha(c->table[0x4]);

  c->table[0x2][0] = c->table[0x4][0];
  c->table[0x2][1] = c->table[0x4][1];
  c->table[0x2][2] = c->table[0x4][2];
  c->table[0x2][3] = c->table[0x4][3];

  mul_alpha(c->table[0x2]);

  c->table[0x1][0] = c->table[0x2][0];
  c->table[0x1][1] = c->table[0x2][1];
  c->table[0x1][2] = c->table[0x2][2];
  c->table[0x1][3] = c->table[0x2][3];

  mul_alpha(c->table[0x1]);

  c->table[0x3][0] = c->table[0x1][0] ^ c->table[0x2][0];
  c->table[0x3][1] = c->table[0x1][1] ^ c->table[0x2][1];
  c->table[0x3][2] = c->table[0x1][2] ^ c->table[0x2][2];
  c->table[0x3][3] = c->table[0x1][3] ^ c->table[0x2][3];
  
  c->table[0x5][0] = c->table[0x1][0] ^ c->table[0x4][0];
  c->table[0x5][1] = c->table[0x1][1] ^ c->table[0x4][1];
  c->table[0x5][2] = c->table[0x1][2] ^ c->table[0x4][2];
  c->table[0x5][3] = c->table[0x1][3] ^ c->table[0x4][3];
  
  c->table[0x6][0] = c->table[0x4][0] ^ c->table[0x2][0];
  c->table[0x6][1] = c->table[0x4][1] ^ c->table[0x2][1];
  c->table[0x6][2] = c->table[0x4][2] ^ c->table[0x2][2];
  c->table[0x6][3] = c->table[0x4][3] ^ c->table[0x2][3];
  
  c->table[0x7][0] = c->table[0x4][0] ^ c->table[0x3][0];
  c->table[0x7][1] = c->table[0x4][1] ^ c->table[0x3][1];
  c->table[0x7][2] = c->table[0x4][2] ^ c->table[0x3][2];
  c->table[0x7][3] = c->table[0x4][3] ^ c->table[0x3][3];
  
  c->table[0x9][0] = c->table[0x1][0] ^ c->table[0x8][0];
  c->table[0x9][1] = c->table[0x1][1] ^ c->table[0x8][1];
  c->table[0x9][2] = c->table[0x1][2] ^ c->table[0x8][2];
  c->table[0x9][3] = c->table[0x1][3] ^ c->table[0x8][3];
  
  c->table[0xa][0] = c->table[0x2][0] ^ c->table[0x8][0];
  c->table[0xa][1] = c->table[0x2][1] ^ c->table[0x8][1];
  c->table[0xa][2] = c->table[0x2][2] ^ c->table[0x8][2];
  c->table[0xa][3] = c->table[0x2][3] ^ c->table[0x8][3];
  
  c->table[0xb][0] = c->table[0x3][0] ^ c->table[0x8][0];
  c->table[0xb][1] = c->table[0x3][1] ^ c->table[0x8][1];
  c->table[0xb][2] = c->table[0x3][2] ^ c->table[0x8][2];
  c->table[0xb][3] = c->table[0x3][3] ^ c->table[0x8][3];
  
  c->table[0xc][0] = c->table[0x4][0] ^ c->table[0x8][0];
  c->table[0xc][1] = c->table[0x4][1] ^ c->table[0x8][1];
  c->table[0xc][2] = c->table[0x4][2] ^ c->table[0x8][2];
  c->table[0xc][3] = c->table[0x4][3] ^ c->table[0x8][3];
  
  c->table[0xd][0] = c->table[0x5][0] ^ c->table[0x8][0];
  c->table[0xd][1] = c->table[0x5][1] ^ c->table[0x8][1];
  c->table[0xd][2] = c->table[0x5][2] ^ c->table[0x8][2];
  c->table[0xd][3] = c->table[0x5][3] ^ c->table[0x8][3];
  
  c->table[0xe][0] = c->table[0x6][0] ^ c->table[0x8][0];
  c->table[0xe][1] = c->table[0x6][1] ^ c->table[0x8][1];
  c->table[0xe][2] = c->table[0x6][2] ^ c->table[0x8][2];
  c->table[0xe][3] = c->table[0x6][3] ^ c->table[0x8][3];
  
  c->table[0xf][0] = c->table[0x7][0] ^ c->table[0x8][0];
  c->table[0xf][1] = c->table[0x7][1] ^ c->table[0x8][1];
  c->table[0xf][2] = c->table[0x7][2] ^ c->table[0x8][2];
  c->table[0xf][3] = c->table[0x7][3] ^ c->table[0x8][3];
}

#define SHIFT256B() \
  tt = t3 & 0xf; t3 >>= 4; t3 |= (t2 << 28); t2 >>= 4; t2 |= (t1 << 28);\
  t1 >>= 4; t1 |= (t0 << 28); t0 >>=4; t0 ^= rtable_256b[tt]

#define GMULWI256B(e,t,s) \
  e = (uint32 *)t[s&0xf]; t0 = e[0]; t1 = e[1]; t2 = e[2]; t3 = e[3];\
  SHIFT256B();\
  e = (uint32 *)t[(s>>4)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  SHIFT256B();\
  e = (uint32 *)t[(s>>8)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  SHIFT256B();\
  e = (uint32 *)t[(s>>12)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
\
  SHIFT256B();\
  e = (uint32 *)t[(s>>16)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
\
  SHIFT256B();\
  e = (uint32 *)t[(s>>20)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
\
  SHIFT256B();\
  e = (uint32 *)t[(s>>24)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
\
  SHIFT256B();\
  e = (uint32 *)t[s>>28]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3]

#define GMULW256B(e,t,s) \
  SHIFT256B();\
  e = (uint32 *)t[s&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  SHIFT256B();\
  e = (uint32 *)t[(s>>4)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  SHIFT256B();\
  e = (uint32 *)t[(s>>8)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
  SHIFT256B();\
  e = (uint32 *)t[(s>>12)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
\
  SHIFT256B();\
  e = (uint32 *)t[(s>>16)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
\
  SHIFT256B();\
  e = (uint32 *)t[(s>>20)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
\
  SHIFT256B();\
  e = (uint32 *)t[(s>>24)&0xf]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3];\
\
  SHIFT256B();\
  e = (uint32 *)t[s>>28]; t0 ^= e[0]; t1 ^= e[1]; t2 ^= e[2]; t3 ^= e[3]

#define GHB256B(t,b)\
  s0 ^= htonl(((uint32 *)b)[0]); \
  s1 ^= htonl(((uint32 *)b)[1]); \
  s2 ^= htonl(((uint32 *)b)[2]); \
  s3 ^= htonl(((uint32 *)b)[3]); \
  GMULWI256B(entry, t, s3); \
  GMULW256B(entry, t, s2);\
  GMULW256B(entry, t, s1);\
  GMULW256B(entry, t, s0);\
  s0 = t0; \
  s1 = t1; \
  s2 = t2; \
  s3 = t3;

void gcm_init_256b(gcm_ctx_256b *c, uchar key[16], size_t keylen) {
  uint32 hkgen[4] = {0,};
  uint32 hkey[4];

  c->keylen = keylen;
  ENCRYPT_INIT(&(c->ck), key, keylen);
  DO_ENCRYPT(&(c->ck), (uchar *)hkgen, (uchar *)hkey, keylen);
  build_hash_table_256b(c, hkey);
}

MODIFIERS void /*inline*/ gcm_encrypt_256b(gcm_ctx_256b *c, uchar *nonce, size_t nlen, 
				       uchar *data, size_t dlen, uchar *adata, 
				       size_t alen, uchar *out, uchar *tag) {
  uint32 tmp[8] = {0, 0, 0, 0, 0, htonl(alen << 3), 0, htonl(dlen << 3)};
  uint32 ctr[4];
  size_t b, l, i;
  register uint32 t0, t1, t2, t3, tt;
  register uint32 *entry;
  register uint32 s0 = 0, s1 = 0, s2 = 0, s3 = 0;

  /* Process the nonce first. */
  if (nlen != 12) {
    b = nlen >> 4;
    l = nlen & 15;
    while (b--) {
      GHB256B(c->table, nonce);
      nonce += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = nonce[l];
      GHB256B(c->table, tmp);
    }
    tmp[0] = tmp[1] = 0;
    tmp[2] = htonl(nlen >> 29);
    tmp[3] = htonl(nlen << 3);
    GHB256B(c->table, tmp);
    ctr[0] = htonl(s0);
    ctr[1] = htonl(s1);
    ctr[2] = htonl(s2);
    ctr[3] = s3;
    tmp[0] = tmp[1] = tmp[2] = tmp[3] = s0 = s1 = s2 = s3 = 0;
  } else {
    ctr[0] = ((uint32 *)nonce)[0];
    ctr[1] = ((uint32 *)nonce)[1];
    ctr[2] = ((uint32 *)nonce)[2];
    ctr[3] = 1;
  }
  CTR_INIT(&(c->ck), ctr, ctr + 3, tag, c->keylen);

  /* Hash associated data. */
  if (alen) {
    b = alen >> 4;
    l = alen & 15;

    for (i=0;i<b;i++) {
      GHB256B(c->table, adata);
      adata += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = adata[l];
      GHB256B(c->table, tmp);
      tmp[0] = tmp[1] = tmp[2] = tmp[3] = 0;
    }
  }

  /* Hash ciphertext. */
  b = dlen >> 4;
  l = dlen & 15;

  for (i=0;i<b;i++) {
    CTR_ENCRYPT(&(c->ck), (&ctr[3]), out, c->keylen);
    ((uint32 *)out)[0] ^= ((uint32 *)data)[0];
    ((uint32 *)out)[1] ^= ((uint32 *)data)[1];
    ((uint32 *)out)[2] ^= ((uint32 *)data)[2];
    ((uint32 *)out)[3] ^= ((uint32 *)data)[3];
    GHB256B(c->table, out);
    data += GHASH_BLK_SZ;
    out += GHASH_BLK_SZ;
  }

  if (l) {
    CTR_ENCRYPT(&(c->ck), &ctr[3], ctr, c->keylen);
    for (i=0;i<l;i++)
      out[i] = ((uchar *)ctr)[i] ^ data[i];
    memcpy(tmp, out, l);
    GHB256B(c->table, tmp);
  }

  GHB256B(c->table, (tmp + 4));
  
  ((uint32 *)tag)[0] ^= htonl(s0);
  ((uint32 *)tag)[1] ^= htonl(s1);
  ((uint32 *)tag)[2] ^= htonl(s2);
  ((uint32 *)tag)[3] ^= htonl(s3);
}

MODIFIERS int gcm_decrypt_256b(gcm_ctx_256b *c, uchar *nonce, size_t nlen, uchar *ct,
			       size_t ctlen, uchar *tag, size_t taglen, uchar *adata,
			       size_t alen, uchar *pt) {
  uint32 tmp[8] = {0, 0, 0, 0, htonl(alen >> 29), htonl(alen << 3), htonl(ctlen >> 29), htonl(ctlen << 3)};
  uint32 ctr[4];
  uchar  chksm[16];
  register char *p;
  size_t b, l, i;
  register uint32 t0, t1, t2, t3, tt;
  register uint32 *entry;
  register uint32 s0 = 0, s1 = 0, s2 = 0, s3 = 0;

  if (taglen > 16) taglen = 16;
  if (nlen != 12) {
    b = nlen >> 4;
    l = nlen & 15;
    while (b--) {
      GHB256B(c->table, nonce);
      nonce += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = nonce[l];
      GHB256B(c->table, tmp);
    }
    tmp[0] = tmp[1] = 0;
    tmp[2] = htonl(nlen >> 29);
    tmp[3] = htonl(nlen << 3);
    GHB256B(c->table, tmp);
    ctr[0] = htonl(s0);
    ctr[1] = htonl(s1);
    ctr[2] = htonl(s2);
    ctr[3] = s3;
    tmp[0] = tmp[1] = tmp[2] = tmp[3] = s0 = s1 = s2 = s3 = 0;
  } else {
    ctr[0] = ((uint32 *)nonce)[0];
    ctr[1] = ((uint32 *)nonce)[1];
    ctr[2] = ((uint32 *)nonce)[2];
    ctr[3] = 1;
  }
  CTR_INIT(&(c->ck), ctr, ctr + 3, chksm, c->keylen);
  for (i=0;i<taglen;i++) 
    chksm[i] ^= tag[i];

  if (alen) {
    b = alen >> 4;
    l = alen & 15;

    for (i=0;i<b;i++) {
      GHB256B(c->table, adata);
      adata += GHASH_BLK_SZ;
    }
    if (l) {
      while (l--)
	((uchar *)tmp)[l] = adata[l];
      GHB256B(c->table, tmp);
      tmp[0] = tmp[1] = tmp[2] = tmp[3] = 0;
    }
  }

  b = ctlen >> 4;
  l = ctlen & 15;
  p = ct;
  
  for (i=0;i<b;i++) {
    GHB256B(c->table, p);
    p += GHASH_BLK_SZ;
  }
  if (l) {
    while (l--)
      ((uchar *)tmp)[l] = p[l];
    GHB256B(c->table, tmp);
  }
  l = ctlen & 15;
  GHB256B(c->table, (tmp + 4));
  
  ((uint32 *)chksm)[0] ^= htonl(s0);
  ((uint32 *)chksm)[1] ^= htonl(s1);
  ((uint32 *)chksm)[2] ^= htonl(s2);
  ((uint32 *)chksm)[3] ^= htonl(s3);

  for (i=taglen;i<16;i++)
      chksm[i] = 0;

  if (((uint32 *)chksm)[0] || ((uint32 *)chksm)[1] || ((uint32 *)chksm)[2] ||
      ((uint32 *)chksm)[3]) return 0;

  for (i=0;i<b;i++) {
    CTR_ENCRYPT(&(c->ck), (&ctr[3]), pt, c->keylen);
    ((uint32 *)pt)[0] ^= ((uint32 *)ct)[0];
    ((uint32 *)pt)[1] ^= ((uint32 *)ct)[1];
    ((uint32 *)pt)[2] ^= ((uint32 *)ct)[2];
    ((uint32 *)pt)[3] ^= ((uint32 *)ct)[3];
    ct += GHASH_BLK_SZ;
    pt += GHASH_BLK_SZ;
  }

  if (l) {
    CTR_ENCRYPT(&(c->ck), &ctr[3], ctr, c->keylen);
    for (i=0;i<l;i++)
      pt[i] = ((uchar *)ctr)[i] ^ ct[i];
  }
  return 1;
}

MODIFIERS void gcm_destroy_256b(gcm_ctx_256b *c) {
  memset(c, '0', sizeof(gcm_ctx_256b));
}

#ifdef PYTHON_BINDINGS

typedef struct {
  PyObject_HEAD
  gcm_ctx_64k  ctx;
} GCM64Kobject;

typedef struct {
  PyObject_HEAD
  gcm_ctx_4k   ctx;
} GCM4Kobject;

typedef struct {
  PyObject_HEAD
  gcm_ctx_256b ctx;
} GCM256Bobject;

typedef struct {
  PyObject_HEAD
  KEY_SCHED    ctx;
  int          keylen;
} PRPobject;

staticforward PyTypeObject GCM64Ktype;
staticforward PyTypeObject GCM4Ktype;
staticforward PyTypeObject GCM256Btype;

static char *initkwlist[] = {"key", 0};
static char *ekwlist[]    = {"plaintext", "nonce", "aad", 0};
static char *dkwlist[]    = {"ciphertext", "nonce", "aad", 0};

static PyObject *GCMalloc(PyTypeObject *subtype, PyObject *args, PyObject *kw) {
  return subtype->tp_alloc(subtype, 1);
}

static void GCM64Kdealloc(PyObject *ptr) {
  GCM64Kobject *p = (GCM64Kobject *)ptr;

  gcm_destroy_64k(&(p->ctx));
  ptr->ob_type->tp_free(ptr);
}

static void GCM4Kdealloc(PyObject *ptr) {
  GCM4Kobject *p = (GCM4Kobject *)ptr;
  
  gcm_destroy_4k(&(p->ctx));
  ptr->ob_type->tp_free(ptr);
}

static void GCM256Bdealloc(PyObject *ptr) {
  GCM256Bobject *p = (GCM256Bobject *)ptr;

  gcm_destroy_256b(&(p->ctx));
  ptr->ob_type->tp_free(ptr);
}

static void PRPdealloc(PyObject *ptr) {
  PRPobject *p = (PRPobject *)ptr;

  memset(&(p->ctx), 0, sizeof(KEY_SCHED));
  p->keylen = 0;
  ptr->ob_type->tp_free(ptr);
}

static int GCM64Kinit(PyObject *self, PyObject *args, PyObject *kw) {
  unsigned char *key;
  int            keylen;
  GCM64Kobject  *p = (GCM64Kobject *)self;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "s#", initkwlist, &key, &keylen))
    return -1;
  if (keylen != 16 && keylen != 24 && keylen != 32) {
    PyErr_SetString(PyExc_ValueError, "GCM key must be 128, 192 or 256 bits.");
    return -1;
  }
  gcm_init_64k(&(p->ctx), key, keylen*8);
  return 0;
}

static int GCM4Kinit(PyObject *self, PyObject *args, PyObject *kw) {
  unsigned char *key;
  int            keylen;
  GCM4Kobject  *p = (GCM4Kobject *)self;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "s#", initkwlist, &key, &keylen))
    return -1;
  if (keylen != 16 && keylen != 24 && keylen != 32) {
    PyErr_SetString(PyExc_ValueError, "GCM key must be 128, 192 or 256 bits.");
    return -1;
  }
  gcm_init_4k(&(p->ctx), key, keylen*8);
  return 0;
}

static int GCM256Binit(PyObject *self, PyObject *args, PyObject *kw) {
  unsigned char *key;
  int            keylen;
  GCM256Bobject *p = (GCM256Bobject *)self;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "s#", initkwlist, &key, &keylen))
    return -1;
  if (keylen != 16 && keylen != 24 && keylen != 32) {
    PyErr_SetString(PyExc_ValueError, "GCM key must be 128, 192 or 256 bits.");
    return -1;
  }
  gcm_init_256b(&(p->ctx), key, keylen*8);
  return 0;
}

static int PRPinit(PyObject *self, PyObject *args, PyObject *kw) {
  unsigned char *key;
  int            keylen;
  PRPobject     *p = (PRPobject *)self;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "s#", initkwlist, &key, &keylen))
    return -1;
  if (keylen != 16 && keylen != 24 && keylen != 32) {
    PyErr_SetString(PyExc_ValueError, "The PRP takes an AES key.");
    return -1;
  }
  p->keylen = keylen*8;
  aes_enc_setup((uint32 *)&(p->ctx), key, p->keylen);
  return 0;
}

static PyObject *GCM64K_Encrypt(GCM64Kobject *self, PyObject *args, PyObject *kw) {
  char     *pt = 0, *ct, *nonce = 0, *aad = 0;
  PyObject *ret;
  int       ptlen = 0, nlen = 0, alen = 0;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "|z#z#z#", ekwlist, &pt, &ptlen,
				   &nonce, &nlen, &aad, &alen))
    return NULL;
  if (ptlen + 16 < 16 || !(ct = (char *)malloc(ptlen + 16))) {
    PyErr_SetString(PyExc_MemoryError, "No memory available to encrypt");
    return NULL;
  }
  gcm_encrypt_64k(&(self->ctx), nonce, nlen, pt, ptlen, aad, alen, ct,
		  ct + ptlen);
  ret = PyString_FromStringAndSize(ct, ptlen+16);
  free(ct);
  return ret;
}

static PyObject *GCM4K_Encrypt(GCM4Kobject *self, PyObject *args, PyObject *kw) {
  char     *pt = 0, *ct, *nonce = 0, *aad = 0;
  PyObject *ret;
  int       ptlen = 0, nlen = 0, alen = 0;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "|z#z#z#", ekwlist, &pt, &ptlen,
				   &nonce, &nlen, &aad, &alen))
    return NULL;
  if (ptlen + 16 < 16 || !(ct = (char *)malloc(ptlen + 16))) {
    PyErr_SetString(PyExc_MemoryError, "No memory available to encrypt");
    return NULL;
  }
  gcm_encrypt_4k(&(self->ctx), nonce, nlen, pt, ptlen, aad, alen, ct,
		  ct + ptlen);
  ret = PyString_FromStringAndSize(ct, ptlen+16);
  free(ct);
  return ret;
}

static PyObject *GCM256B_Encrypt(GCM256Bobject *self, PyObject *args, PyObject *kw) {
  char     *pt = 0, *ct, *nonce = 0, *aad = 0;
  PyObject *ret;
  int       ptlen = 0, nlen = 0, alen = 0;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "|z#z#z#", ekwlist, &pt, &ptlen,
				   &nonce, &nlen, &aad, &alen))
    return NULL;
  if (ptlen + 16 < 16 || !(ct = (char *)malloc(ptlen + 16))) {
    PyErr_SetString(PyExc_MemoryError, "No memory available to encrypt");
    return NULL;
  }
  gcm_encrypt_256b(&(self->ctx), nonce, nlen, pt, ptlen, aad, alen, ct,
		  ct + ptlen);
  ret = PyString_FromStringAndSize(ct, ptlen+16);
  free(ct);
  return ret;
}

static PyObject *PRP_Permute(PRPobject *self, PyObject *args) {
  PyObject *ret;
  char *in, out[16];
  int   inlen;

  if (!PyArg_ParseTuple(args, "s#", &in, &inlen))
    return NULL;
  if (inlen != 16) {
    PyErr_SetString(PyExc_ValueError, "Can only permute 16 byte values.");
    return NULL;
  }
  aes_enc((uint32 *)&(self->ctx), in, out, self->keylen);
  ret = PyString_FromStringAndSize(out, 16);
  memset(out, 0, 16);
  return ret;
}

static PyObject *GCM64K_Decrypt(GCM64Kobject *self, PyObject *args, PyObject *kw) {
  PyObject *ret;
  char *pt = 0, *ct, *nonce = 0, *aad = 0;
  int   ctlen, nlen = 0, alen = 0;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "s#|z#z#", dkwlist, &ct, &ctlen,
				   &nonce, &nlen, &aad, &alen))
    return NULL;
  if (ctlen < 16) {
    PyErr_SetString(PyExc_ValueError, "Ciphertext is invalid.");
    return NULL;
  }
  if (ctlen > 16) {
    pt = (char *)malloc(ctlen - 16);
    if (!pt) {
      PyErr_SetString(PyExc_MemoryError, "No memory available for decrypt");
      return NULL;
    }
  }
  if (!gcm_decrypt_64k(&(self->ctx), nonce, nlen, ct, ctlen - 16, ct + ctlen - 16, 
		       16, aad, alen, pt)) {
    PyErr_SetString(PyExc_ValueError, "Ciphertext is invalid.");
    free(pt);
    return NULL;
  }
  ret = PyString_FromStringAndSize(pt, ctlen - 16);
  free(pt);
  return ret;
}

static PyObject *GCM4K_Decrypt(GCM4Kobject *self, PyObject *args, PyObject *kw) {
  PyObject *ret;
  char *pt = 0, *ct, *nonce = 0, *aad = 0;
  int   ctlen, nlen = 0, alen = 0;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "s#|z#z#", dkwlist, &ct, &ctlen,
				   &nonce, &nlen, &aad, &alen))
    return NULL;
  if (ctlen < 16) {
    PyErr_SetString(PyExc_ValueError, "Ciphertext is invalid.");
    return NULL;
  }
  if (ctlen > 16) {
    pt = (char *)malloc(ctlen - 16);
    if (!pt) {
      PyErr_SetString(PyExc_MemoryError, "No memory available for decrypt");
      return NULL;
    }
  }
  if (!gcm_decrypt_4k(&(self->ctx), nonce, nlen, ct, ctlen - 16, ct + ctlen - 16, 
		      16, aad, alen, pt)) {
    PyErr_SetString(PyExc_ValueError, "Ciphertext is invalid.");
    free(pt);
    return NULL;
  }
  ret = PyString_FromStringAndSize(pt, ctlen - 16);
  free(pt);
  return ret;
}

static PyObject *GCM256B_Decrypt(GCM256Bobject *self, PyObject *args, PyObject *kw) {
  PyObject *ret;
  char *pt = 0, *ct, *nonce = 0, *aad = 0;
  int   ctlen, nlen = 0, alen = 0;

  if (!PyArg_ParseTupleAndKeywords(args, kw, "s#|z#z#", dkwlist, &ct, &ctlen,
				   &nonce, &nlen, &aad, &alen))
    return NULL;
  if (ctlen < 16) {
    PyErr_SetString(PyExc_ValueError, "Ciphertext is invalid.");
    return NULL;
  }
  if (ctlen > 16) {
    pt = (char *)malloc(ctlen - 16);
    if (!pt) {
      PyErr_SetString(PyExc_MemoryError, "No memory available for decrypt");
      return NULL;
    }
  }
  if (!gcm_decrypt_256b(&(self->ctx), nonce, nlen, ct, ctlen - 16, ct + ctlen - 16, 
			16, aad, alen, pt)) {
    PyErr_SetString(PyExc_ValueError, "Ciphertext is invalid.");
    free(pt);
    return NULL;
  }
  ret = PyString_FromStringAndSize(pt, ctlen - 16);
  free(pt);
  return ret;
}

static struct PyMethodDef GCM64K_classmethods[] = {
  {"encrypt", (PyCFunction) GCM64K_Encrypt, METH_VARARGS|METH_KEYWORDS, 0},
  {"decrypt", (PyCFunction) GCM64K_Decrypt, METH_VARARGS|METH_KEYWORDS, 0},
  {0, 0}
};

static struct PyMethodDef GCM4K_classmethods[] = {
  {"encrypt", (PyCFunction) GCM4K_Encrypt, METH_VARARGS|METH_KEYWORDS, 0},
  {"decrypt", (PyCFunction) GCM4K_Decrypt, METH_VARARGS|METH_KEYWORDS, 0},
  {0, 0}
};

static struct PyMethodDef GCM256B_classmethods[] = {
  {"encrypt", (PyCFunction) GCM256B_Encrypt, METH_VARARGS|METH_KEYWORDS, 0},
  {"decrypt", (PyCFunction) GCM256B_Decrypt, METH_VARARGS|METH_KEYWORDS, 0},
  {0, 0}
};

static struct PyMethodDef PRP_classmethods[] = {
  {"permute", (PyCFunction) PRP_Permute, METH_VARARGS, 0},
  {0, 0}
};

static PyTypeObject GCM64Ktype = {
  PyObject_HEAD_INIT(NULL)
  0,
  "_GCM.GCM64K",
  sizeof(GCM64Kobject),
  0,
  GCM64Kdealloc,
  0, /* print */
  0, /* getattr */
  0, /* setattr */
  0, /* compare */
  0, /* repr */
  0, /* as_number */
  0, /* as_sequence */
  0, /* as_mapping */
  0,  /* hash */
  0,  /* call */
  0,  /* str */
  0,
  0,
  0,
  Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
  0, /* tp_doc */
  0,
  0,
  0,
  0,
  0,
  0,
  GCM64K_classmethods,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  GCM64Kinit,
  0,
  GCMalloc,
  0,
};

static PyTypeObject GCM4Ktype = {
  PyObject_HEAD_INIT(NULL)
  0,
  "_GCM.GCM4K",
  sizeof(GCM4Kobject),
  0,
  GCM4Kdealloc,
  0, /* print */
  0, /* getattr */
  0, /* setattr */
  0, /* compare */
  0, /* repr */
  0, /* as_number */
  0, /* as_sequence */
  0, /* as_mapping */
  0,  /* hash */
  0,  /* call */
  0,  /* str */
  0,
  0,
  0,
  Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
  0, /* tp_doc */
  0,
  0,
  0,
  0,
  0,
  0,
  GCM4K_classmethods,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  GCM4Kinit,
  0,
  GCMalloc,
  0,
};

static PyTypeObject GCM256Btype = {
  PyObject_HEAD_INIT(NULL)
  0,
  "_GCM.GCM256B",
  sizeof(GCM256Bobject),
  0,
  GCM256Bdealloc,
  0, /* print */
  0, /* getattr */
  0, /* setattr */
  0, /* compare */
  0, /* repr */
  0, /* as_number */
  0, /* as_sequence */
  0, /* as_mapping */
  0,  /* hash */
  0,  /* call */
  0,  /* str */
  0,
  0,
  0,
  Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
  0, /* tp_doc */
  0,
  0,
  0,
  0,
  0,
  0,
  GCM256B_classmethods,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  GCM256Binit,
  0,
  GCMalloc,
  0,
};

static PyTypeObject PRPtype = {
  PyObject_HEAD_INIT(NULL)
  0,
  "_GCM.PRP",
  sizeof(PRPobject),
  0,
  PRPdealloc,
  0, /* print */
  0, /* getattr */
  0, /* setattr */
  0, /* compare */
  0, /* repr */
  0, /* as_number */
  0, /* as_sequence */
  0, /* as_mapping */
  0,  /* hash */
  0,  /* call */
  0,  /* str */
  0,
  0,
  0,
  Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
  0, /* tp_doc */
  0,
  0,
  0,
  0,
  0,
  0,
  PRP_classmethods,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  PRPinit,
  0,
  GCMalloc,
  0,
};

PyMODINIT_FUNC init_GCM() {
  PyObject *m;
  PyType_Ready(&GCM64Ktype);
  PyType_Ready(&GCM4Ktype);
  PyType_Ready(&GCM256Btype);
  PyType_Ready(&PRPtype);
  Py_INCREF(&GCM64Ktype);
  Py_INCREF(&GCM4Ktype);
  Py_INCREF(&GCM256Btype);
  Py_INCREF(&PRPtype);
  m = Py_InitModule("SC._GCM", NULL);
  if (PyErr_Occurred())
    Py_FatalError("can't initialize module SC._GCM");
  PyModule_AddObject(m, "GCM64K", (PyObject *)&GCM64Ktype);
  PyModule_AddObject(m, "GCM4K", (PyObject *)&GCM4Ktype);
  PyModule_AddObject(m, "GCM256B", (PyObject *)&GCM256Btype);
  PyModule_AddObject(m, "PRP", (PyObject *)&PRPtype);
}
#endif
