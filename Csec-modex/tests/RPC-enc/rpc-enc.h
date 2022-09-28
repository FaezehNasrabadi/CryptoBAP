// Copyright (c) Mihhail Aizatulin (avatar@hot.ee), Francois Dupressoir (fdupress@gmail.com).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include <limits.h>
#include <stdint.h>


// (OLD) This is AUTH_LENGTH + IV_LENGTH + LENGTH_LENGTH + 2
#define ENCRYPTION_OVERHEAD 32
#define MIN_PAYLOAD_LENGTH 1024
#define MAX_PAYLOAD_LENGTH 1024
// 5
#define CONCAT_OVERHEAD (sizeof(uint32_t) + 1)
#define KEY_LENGTH 16

// 1045
#define MIN_PLAINTEXT_LENGTH (MIN_PAYLOAD_LENGTH + KEY_LENGTH + CONCAT_OVERHEAD)
// 1045
#define MAX_PLAINTEXT_LENGTH (MAX_PAYLOAD_LENGTH + KEY_LENGTH + CONCAT_OVERHEAD)

#define MIN_CIPHER_LENGTH (MIN_PLAINTEXT_LENGTH + ENCRYPTION_OVERHEAD)
// 1087
#define MAX_CIPHER_LENGTH (MAX_PLAINTEXT_LENGTH + ENCRYPTION_OVERHEAD)

#define MIN_PRINCIPAL_LENGTH 0
#define MAX_PRINCIPAL_LENGTH 1024

#define MIN_MSG1_LENGTH (MIN_CIPHER_LENGTH + MIN_PRINCIPAL_LENGTH + CONCAT_OVERHEAD)
// 2112
#define MAX_MSG1_LENGTH (MAX_CIPHER_LENGTH + MAX_PRINCIPAL_LENGTH + CONCAT_OVERHEAD)

#define MIN_MSG2_LENGTH (MIN_PAYLOAD_LENGTH + ENCRYPTION_OVERHEAD)
#define MAX_MSG2_LENGTH (MAX_PAYLOAD_LENGTH + ENCRYPTION_OVERHEAD)

enum protEnd {CLIENT, SERVER};

typedef struct RPCstate_s
{
  enum protEnd end;
  int port;


  unsigned char * self;
  uint32_t self_len;

  unsigned char * other;
  uint32_t other_len;

  // Long-Term Key
  unsigned char * k_ab;
  uint32_t k_ab_len;

  // Request
  unsigned char * request;
  uint32_t request_len;
  
  // Session Key
  unsigned char * k;
  uint32_t k_len;

  // Response
  unsigned char * response;
  uint32_t response_len;

  // The listening socket of the server
  int bind_fd;
  // The connection socket between the client and the server
  int conn_fd;
} RPCstate;
