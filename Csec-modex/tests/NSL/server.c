// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "keys.h"
#include "net.h"
#include "lib.h"

#ifdef CSEC_VERIFY
  #include "common.h"
#endif

#include <string.h>
#include <stdio.h>

void event2(const char * s, const unsigned char * buf1, size_t len1, const unsigned char * buf2, size_t len2)
{

}

void typehint(const unsigned char * buf, size_t len, const char * type)
{

}
int main(int argc, char ** argv)
{
  // our identity and the identity of the other partner
  unsigned char * host, * xhost;
  size_t host_len, xhost_len;

  unsigned char * pkey, * skey, * xkey;
  size_t pkey_len, skey_len, xkey_len;

  unsigned char * m1, * m1_e;
  unsigned char * xNa, * xNb;
  size_t m1_len, m1_e_len;
  size_t m1_l;

  unsigned char * m2, * m2_e;
  unsigned char * Nb;
  size_t m2_len, m2_e_len;

  unsigned char * m3, * m3_e;
  size_t m3_len, m3_e_len;

  unsigned char * p;

  // for dropping encryption tags
  unsigned char * dummy = malloc(4);

  BIO * bio = socket_listen();

  host = get_host(&host_len, 'B');

  pkey = get_pkey(&pkey_len, 'B');
  skey = get_skey(&skey_len, 'B');

#ifdef VERBOSE
  printf("B pkey = ");
  print_buffer(pkey, pkey_len);
  printf("\n");

  printf("B skey = ");
  print_buffer(skey, skey_len);
  printf("\n");
#endif


  /* Receive message 1 */

  recv(bio, (unsigned char*) &m1_e_len, sizeof(m1_e_len));

  if(m1_e_len > MAX_SIZE_CIPHER)
    fail("Server: cipher in message 1 too long");

  m1_e = malloc(m1_e_len);
  recv(bio, m1_e, m1_e_len);

  m1_len = decrypt_len(skey, skey_len, m1_e, m1_e_len);
  m1 = malloc(m1_len);
  m1_len = decrypt(skey, skey_len, m1_e, m1_e_len, m1);

  if(sizeof(size_t) + SIZE_NONCE + 4 > m1_len)
  {
    fprintf(stderr, "m1 has wrong length\n");
    exit(1);
  }

  if(memcmp(m1, "msg1", 4))
  {
    fprintf(stderr, "B: m1 not properly tagged, aborting\n");
    exit(1);
  }

  m1_l = * (size_t *) (m1 + 4);

  if(m1_l !=  SIZE_NONCE)
  {
    fprintf(stderr, "A: m1 contains wrong length for xNa\n");
    exit(1);
  }

  xhost_len = m1_len - (4 + sizeof(size_t) + m1_l);
  xhost = m1 + 4 + sizeof(size_t) + m1_l;

  if(xhost_len > MAX_SIZE_HOST)
    fail("B: host size in m1 too long");

#ifdef VERBOSE
  printf("B xhost = ");
  print_buffer(xhost, xhost_len);
  printf("\n");
#endif

  xkey = lookup_xkey(&xkey_len, xhost, xhost_len, 'B');

#ifdef VERBOSE
  printf("B xkey = ");
  print_buffer(xkey, xkey_len);
  printf("\n");
#endif

  /*
  if(memcmp(m1 + sizeof(size_t) + m1_l + 4, xkey,  xkey_len))
  {
    fprintf(stderr, "x_xkey in m1 doesn't match xkey\n");
    exit(1);
  }
  */

  xNa = m1 + 4 + sizeof(size_t);
  typehint(xNa, m1_l, "fixed_20_nonce");

#ifdef VERBOSE
    fprintf(stderr, "B: m1 received and checked");
    fprintf(stderr, "\n");
    fflush(stderr);
#endif

#ifdef CSEC_VERIFY
#ifdef USE_EVENT_PARAMS
  event2("server_begin", xhost, xhost_len, host, host_len);
#else
  event0("server_begin");
#endif
#endif

  /* Send message 2 */

  m2_len = 2 * SIZE_NONCE + 2 * sizeof(size_t) + 4 + host_len;
  p = m2 = malloc(m2_len);

  memcpy(p, "msg2", 4);
  p += 4;
  * (size_t *) p = m1_l;
  p += sizeof(size_t);
  * (size_t *) p = SIZE_NONCE;
  p += sizeof(size_t);
  memcpy(p, xNa, m1_l);
  p += m1_l;
  Nb = p;
  nonce(Nb);
  p += SIZE_NONCE;
  memcpy(p, host, host_len);

  m2_e_len = encrypt_len(xkey, xkey_len, m2, m2_len);

  if(m2_e_len > MAX_SIZE_CIPHER)
    fail("Server: cipher in message 2 too long");

  m2_e = malloc(m2_e_len);
  m2_e_len = encrypt(xkey, xkey_len, m2, m2_len, m2_e);

  send(bio, &m2_e_len, sizeof(m2_e_len));
  send(bio, m2_e, m2_e_len);

#ifdef VERBOSE
  printf("B: m2_e sent, m2_e = ");
  print_buffer(m2_e, m2_e_len);
  printf("\n");
  fflush(stdout);
#endif

  /* Receive message 3 */

  recv(bio, (unsigned char*) &m3_e_len, sizeof(m3_e_len));

  if(m3_e_len > MAX_SIZE_CIPHER)
    fail("Server: cipher in message 3 too long");

  m3_e = malloc(m3_e_len);
  recv(bio, m3_e, m3_e_len);

  m3_len = decrypt_len(skey, skey_len, m3_e, m3_e_len);
  m3 = malloc(m3_len);
  m3_len = decrypt(skey, skey_len, m3_e, m3_e_len, m3);

  if(memcmp(m3, "msg3", 4))
  {
    fprintf(stderr, "B: m3 not properly tagged, aborting\n");
    exit(1);
  }

  if(m3_len != SIZE_NONCE + 4)
  {
    fprintf(stderr, "B: m3 has wrong length\n");
    exit(1);
  }

  xNb = m3 + 4;
  typehint(xNb, SIZE_NONCE, "fixed_20_nonce");

  if(memcmp(xNb, Nb, SIZE_NONCE))
  {
    fprintf(stderr, "xNb in m3 doesn't match Nb\n");
    exit(1);
  }

#ifdef VERBOSE
    printf("B: Na = ");
    print_buffer(xNa, SIZE_NONCE);
    printf("\n");
    printf("B: Nb = ");
    print_buffer(Nb, SIZE_NONCE);
    printf("\n");
    fflush(stdout);
#endif

#ifdef CSEC_VERIFY
#ifdef USE_EVENT_PARAMS
  event2("server_end", xhost, xhost_len, host, host_len);
#else
  event0("server_end");
#endif
#endif

  // wait for the client to close, to avoid "Address already in use" errors
  wait_close(bio);

  return 0;
}

