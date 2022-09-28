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
// #define LOWE_ATTACK

int main(int argc, char ** argv)
{
  // our identity, the identity of the intended partner, and the identity received from partner
  unsigned char * client_name, * server_name, * x_server_name;
  size_t client_name_len, server_name_len;

  unsigned char * pkey, * skey, * xkey;
  size_t pkey_len, skey_len, xkey_len;

  unsigned char * m1, * m1_e;
  unsigned char * Na;
  size_t m1_len, m1_e_len;

  unsigned char * m2, * m2_e;
  unsigned char * xNb, * xNa;
  size_t m2_len, m2_e_len;
  size_t m2_l1, m2_l2;

  unsigned char * m3, * m3_e;
  size_t m3_len, m3_e_len;

  unsigned char * p;

  // for encryption tags
  unsigned char * etag = malloc(4);

  BIO * bio = socket_connect();

  client_name = get_host(&client_name_len, 'A');
  server_name = get_xhost(&server_name_len, 'A');

  pkey = get_pkey(&pkey_len, 'A');
  skey = get_skey(&skey_len, 'A');

#ifdef VERBOSE
  printf("A pkey = ");
  print_buffer(pkey, pkey_len);
  printf("\n");

  printf("A skey = ");
  print_buffer(skey, skey_len);
  printf("\n");

  printf("A server_name = ");
  print_buffer(server_name, server_name_len);
  printf("\n");
#endif

  xkey = lookup_xkey(&xkey_len, server_name, server_name_len, 'A');

#ifdef VERBOSE
  printf("A xkey = ");
  print_buffer(xkey, xkey_len);
  printf("\n");
#endif

#ifdef CSEC_VERIFY
#ifdef USE_EVENT_PARAMS
  event2("client_begin", client_name, client_name_len, server_name, server_name_len);
#else
  event0("client_begin");
#endif
#endif

  /* Send message 1 */

  m1_len = SIZE_NONCE + 4 + client_name_len
      + sizeof(size_t);
  p = m1 = malloc(m1_len);

  memcpy(p, "msg1", 4);
  p += 4;
  * (size_t *) p = SIZE_NONCE;
  p += sizeof(size_t);
  Na = p;
  nonce(Na);
  p += SIZE_NONCE;
  memcpy(p, client_name, client_name_len);

  m1_e_len = encrypt_len(xkey, xkey_len,
                         m1, m1_len);

  if(m1_e_len > MAX_SIZE_CIPHER)
    fail("Client: cipher in message 1 too long");

  m1_e = malloc(m1_e_len);
  m1_e_len =
    encrypt(xkey, xkey_len, m1,
            m1_len,
            m1_e);

  send(bio, &m1_e_len, sizeof(m1_e_len));
  send(bio, m1_e, m1_e_len);

#ifdef VERBOSE
    printf("A: m1_e sent, m1_e = ");
    print_buffer(m1_e, m1_e_len);
    printf("\n");
    fflush(stdout);
#endif

  /* Receive message 2 */

  recv(bio, (unsigned char*) &m2_e_len,
       sizeof(m2_e_len));

  if(m2_e_len > MAX_SIZE_CIPHER)
    fail("Client: cipher in message 2 too long");

  m2_e = malloc(m2_e_len);
  recv(bio, m2_e, m2_e_len);

  m2_len = decrypt_len(skey, skey_len,
                       m2_e, m2_e_len);
  m2 = malloc(m2_len);
  m2_len =
      decrypt(skey, skey_len,
              m2_e, m2_e_len, m2);

  if(server_name_len + 2 * SIZE_NONCE
      + 2 * sizeof(size_t) + 4 != m2_len)
  {
    printf("A: m2 has wrong length\n");
    exit(1);
  }

  if(memcmp(m2, "msg2", 4))
  {
    printf("A: m2 not properly tagged\n");
    exit(1);
  }

  m2_l1 = *(size_t *) (m2 + 4);
  m2_l2 = *(size_t *) (m2 + 4 + sizeof(size_t));

  if(m2_l1 != SIZE_NONCE)
  {
    printf("A: m2 has wrong length for xNa\n");
    exit(1);
  }

  if(m2_l2 != SIZE_NONCE)
  {
    printf("A: m2 has wrong length for xNb\n");
    exit(1);
  }

  xNa = m2 + 4 + 2 * sizeof(size_t);
  typehint(xNa, SIZE_NONCE, "fixed_20_nonce");

  if(memcmp(xNa, Na, m2_l1))
  {
    printf("A: xNa in m2 doesn't match Na\n");
    exit(1);
  }

  x_server_name =
    m2 + m2_l1 + m2_l2
    + 2 * sizeof(size_t) + 4;
  typehint(x_server_name, server_name_len, "bounded_40_host");

#ifndef LOWE_ATTACK
  if(memcmp(x_server_name, server_name,  server_name_len))
  {
    printf("A: x_xkey in m2 doesn't match xkey\n");
    exit(1);
  }
#endif

  xNb = m2 + m2_l1 + 2 * sizeof(size_t) + 4;
  typehint(xNb, m2_l2, "fixed_20_nonce");

#ifdef VERBOSE
    printf("A: m2 received and checked");
    printf("\n");
    fflush(stdout);
#endif

  /* Send message 3 */

  m3_len = 4 + m2_l2;
  p = m3 = malloc(m3_len);

  memcpy(p, "msg3", 4);
  p += 4;

  memcpy(p, xNb, m2_l2);

  m3_e_len = encrypt_len(xkey, xkey_len,
                         m3, m3_len);

  if(m3_e_len > MAX_SIZE_CIPHER)
    fail("Client: cipher in message 3 too long");

  m3_e = malloc(m3_e_len);
  m3_e_len =
    encrypt(xkey, xkey_len, m3,
            m3_len, m3_e);

  send(bio, &m3_e_len, sizeof(m3_e_len));
  send(bio, m3_e, m3_e_len);

#ifdef VERBOSE
    printf("A: m3 sent");
    printf("\n");
    fflush(stdout);
#endif

#ifdef VERBOSE
    printf("A: Na = ");
    print_buffer(Na, SIZE_NONCE);
    printf("\n");
    printf("A: Nb = ");
    print_buffer(xNb, SIZE_NONCE);
    printf("\n");
    fflush(stdout);
#endif

#ifdef CSEC_VERIFY
#ifdef USE_EVENT_PARAMS
  event2("client_end", client_name, client_name_len, server_name, server_name_len);
#else
  event0("client_end");
#endif
#endif


  return 0;
}
