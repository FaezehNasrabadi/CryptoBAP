// Copyright (c) Mihhail Aizatulin (avatar@hot.ee), Francois Dupressoir (fdupress@gmail.com).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include <stdio.h>
#include <stdint.h>

#include "lib.h"
#include "net.h"
#include "rpc-enc.h"

#ifdef CSEC_VERIFY
  #include "common.h"
  #include "interface.h"
#endif

#include <string.h>
void event4(const char * s, const unsigned char * buf1, size_t len1,
                            const unsigned char * buf2, size_t len2,
                            const unsigned char * buf3, size_t len3,
                            const unsigned char * buf4, size_t len4)
{};
void readenvL(const unsigned char * buf, size_t len, const char * s){};
void assume_string(const unsigned char * name){};
void mute(){};
void unmute(){};
int recv_request(RPCstate * ctx)
{
  unsigned char * m1_e, * m1, * p;
  uint32_t m1_e_len, m1_len;

  recv(&(ctx->conn_fd), (unsigned char*) &m1_e_len, sizeof(m1_e_len));
  if (m1_e_len < MIN_MSG1_LENGTH || m1_e_len > MAX_MSG1_LENGTH)
    fail("server: message has wrong length");

  p = m1_e = malloc(m1_e_len);
  if (m1_e == NULL)
    fail("Allocation failure, m1_e");

  recv(&(ctx->conn_fd), m1_e, m1_e_len);

  if (memcmp("p", p, 1))
  {
#ifndef VERIFY
    fprintf(stderr, "Server: Message not properly tagged as a pair, aborting.\n");
#endif
    exit(-1);
  }
  p += 1;

  ctx->other_len = *((uint32_t *) p);
  if (ctx->other_len > MAX_PRINCIPAL_LENGTH)
    fail("ctx->other_len is too long: %d", ctx->other_len);

  if (m1_e_len <= 1 + sizeof(uint32_t) + ctx->other_len)
  {
#ifndef VERIFY
    fprintf(stderr, "Server: Message has wrong length.\n");
#endif
    exit(-1);
  }
  p += sizeof(uint32_t);

  ctx->other = malloc(ctx->other_len);
  if (ctx->other == NULL)
    fail("Allocation failure: ctx->other");
  memcpy(ctx->other,p,ctx->other_len);
  p += ctx->other_len;

  m1_e_len -= (1 + sizeof(ctx->other_len) + ctx->other_len);

  // This is strictly speaking not necessary since the condition (m1_len >
  // MAX_PLAINTEXT_LENGTH) below is equivalent (however, it will not be once we
  // get back to encrypt_len).. However, this is checked too late, so that the
  // extraction of the client part does not pass the parsing safety check. This
  // is fine, the program would still verify, but the model is less neat.
  if(m1_e_len > MAX_CIPHER_LENGTH)
    {
#ifndef VERIFY
      fprintf(stderr, "Server: Message has wrong length %d.\n", m1_e_len);
#endif
      exit(-1);
    }

#ifdef VERBOSE
#ifndef VERIFY
  printf("Server: Received message: %.1s | %u | ", m1_e, *((uint32_t*) (m1_e + 1)));
  print_text_buffer(m1_e + 1 + sizeof(uint32_t),ctx->other_len);
  printf(" | ");
  print_buffer(p, m1_e_len);
  fflush(stdout);
#endif
#endif

  ctx->k_ab = get_shared_key(ctx->other, ctx->other_len, ctx->self, ctx->self_len, &(ctx->k_ab_len));

  m1_len = decrypt_len(ctx->k_ab, ctx->k_ab_len, p, m1_e_len);
  if (m1_len > MAX_PLAINTEXT_LENGTH)
    fail("m1_len too big");

  m1 = malloc(m1_len);
  if (m1 == NULL)
  {
    free(m1_e);
    return -1;
  }
  m1_len = decrypt(ctx->k_ab, ctx->k_ab_len, p, m1_e_len, m1);

  if(m1_len < 1 + sizeof(ctx->request_len))
  {
#ifndef VERIFY
    fprintf(stderr, "Server: Plaintext has wrong length.\n");
#endif
    exit(1);
  }

  ctx->request_len = *((uint32_t *) (m1 + 1));

  if(ctx->request_len > MAX_PAYLOAD_LENGTH ||
     ctx->request_len < MIN_PAYLOAD_LENGTH ||
     m1_len <= 1 + sizeof(ctx->request_len) + ctx->request_len)
  {
#ifndef VERIFY
    fprintf(stderr, "Server: Plaintext has wrong length.\n");
#endif
    exit(1);
  }

  if(memcmp("p", m1, 1))
  {
#ifndef VERIFY
    fprintf(stderr, "Server: Plaintext not properly tagged as a pair, aborting\n");
#endif
    exit(1);
  }

  ctx->request = malloc(ctx->request_len);
  if (ctx->request == NULL)
  {
    free(m1_e);
    free(m1);
    return -1;
  }
  memcpy(ctx->request, m1 + 1 + sizeof(ctx->request_len), ctx->request_len);

  ctx->k_len = m1_len - (1 + sizeof(ctx->request_len) + ctx->request_len);

  // This has been moved here from send_response since this is required to prove
  // parsing safety for the request. It is probably possible to verify the model
  // without, but this seems like a good change anyway.
  if(ctx->k_len != 16)
  {
#ifndef VERIFY
    fprintf(stderr, "Server: session key must be 16 bytes long.\n");
#endif
    exit(1);
  }

  ctx->k = malloc(ctx->k_len);
  if (ctx->k == NULL)
  {
    free(m1_e);
    free(m1);
    return -1;
  }
  memcpy(ctx->k, m1 + 1 + sizeof(ctx->request_len) + ctx->request_len, ctx->k_len);

#ifdef VERBOSE
#ifndef VERIFY
  printf("Server: Authenticated request: ");
  print_text_buffer(ctx->request,ctx->request_len);
  printf("\nServer: Authenticated session key: ");
  print_buffer(ctx->k,ctx->k_len);
  fflush(stdout);
#endif
#endif

  free(m1_e);
  free(m1);
  return 0;
}

int send_response(RPCstate * ctx)
{
  unsigned char * m2_e;
  uint32_t m2_e_len;

#ifdef VERBOSE
#ifndef VERIFY
  printf("Server: Preparing response: ");
  print_text_buffer(ctx->response,ctx->response_len);
  printf("\n");
  fflush(stdout);
#endif
#endif

  m2_e_len = encrypt_len(ctx->k, ctx->k_len, ctx->response, ctx->response_len);

  m2_e = malloc(m2_e_len);
  if (m2_e == NULL)
  {
    return -1;
  }
  m2_e_len = encrypt(ctx->k, ctx->k_len, ctx->response, ctx->response_len, m2_e);
  if (m2_e_len == 0)
  {
    return -1;
  }

#ifdef VERBOSE
#ifndef VERIFY
  printf("Server: Sending encrypted message of length %d: ", m2_e_len);
  print_buffer(m2_e, m2_e_len);
  fflush(stdout);
#endif
#endif

  send(&(ctx->conn_fd), (unsigned char*) &m2_e_len, sizeof(m2_e_len));
  send(&(ctx->conn_fd), m2_e, m2_e_len);

  free(m2_e);
  return 0;
}

int parseargs(int argc, char ** argv, RPCstate * ctx)
{
  size_t port_len, pwr = 1;

  if (argc != 2 && argc != 3)
    return -1;

  // Initialize the whole structure to 0
  ctx->self = NULL;
  ctx->other = NULL;
  ctx->k = NULL;
  ctx->k_ab = NULL;
  ctx->request = NULL;
  ctx->response = NULL;
  ctx->port = 0;

  // Get the principal name from the first command-line parameter
  size_t self_len = strlen(argv[1] );

  // Check length before truncating
  if(self_len > MAX_PRINCIPAL_LENGTH){
    printf("Server: server ID too long\n");
    exit(-1);
  }

  ctx->self_len = self_len;
  if (ctx->self_len >= 256)
    return -1;
  if (ctx->self_len == 0)
  {
    ctx->self_len = DEFAULTHOST_LEN;
    ctx->self = malloc(ctx->self_len);
    if (ctx->self == NULL)
      return -1;

    memcpy(ctx->self,DEFAULTHOST,ctx->self_len);
  }
  else
  {
    ctx->self = malloc(ctx->self_len);
    if (ctx->self == NULL)
      return -1;

    memcpy(ctx->self,argv[1],ctx->self_len);
  }

#ifdef CSEC_VERIFY
  // The following chunk verifies, but adds a lot of noise from the if statements, so we replace
  // the computed value by an environment variable "port".
  mute();
#endif

  ctx->port = 0;
  if (argc == 3)
  {
    port_len = strlen(argv[2]);
    if (port_len > 5)
      return -1;

    while (port_len > 0)
    {
      if (argv[2][port_len - 1] < '0' || argv[2][port_len - 1] > '9')
        return -1;
      ctx->port += (int) (((uint32_t) argv[2][port_len - 1] - 48) * pwr);
      pwr *= 10;
      port_len--;
    }
  }
  if (ctx->port <= 0 || ctx->port >= 65535)
  {
    ctx->port = DEFAULTPORT;
  }

#ifdef CSEC_VERIFY
  unmute();
  readenvL(&(ctx->port), sizeof(ctx->port), "port");
#endif

  return 0;
}

int main(int argc, char ** argv)
{
#ifdef CSEC_VERIFY
  assume_string("serverID");
  assume_string("port_ascii");

  readenvL(argv[1], strlen(argv[1]), "serverID");
  readenvL(argv[2], strlen(argv[2]), "port_ascii");
#endif

  RPCstate seState;
  if (parseargs(argc,argv, &seState))
  {
#ifndef VERIFY
    fprintf(stdout, "Usage: server serverAddress [port]\n");
#endif
    exit(-1);
  }

#ifdef VERBOSE
#ifndef VERIFY
  printf("Server: Now listening on ");
  print_text_buffer(seState.self, seState.self_len);
  printf(", port %d.\n", seState.port);
#endif
#endif

  if (socket_listen(&(seState.bind_fd),&(seState.conn_fd), seState.self, seState.self_len, seState.port,NULL))
    return -1;

#ifdef VERBOSE
#ifndef VERIFY
  printf("Server: Accepted client connection.\n");
#endif
#endif

  /* Receive request */
  if (recv_request(&seState) != 0)
  {
    return -1;
  }

  /* Send response */
  seState.response = get_response(&(seState.response_len));

#ifdef CSEC_VERIFY
  event4("server_reply", seState.other, seState.other_len, seState.self, seState.self_len,
                         seState.request, seState.request_len, seState.response, seState.response_len);
#endif

  if (send_response(&seState) != 0)
  {
    return -1;
  }

  // wait for the client to close, to avoid "Address already in use" errors
  wait_close(&(seState.conn_fd));

  return 0;
}
