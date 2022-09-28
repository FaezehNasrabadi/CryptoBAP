// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include <openssl/bio.h>
#include <openssl/err.h>

BIO *socket_listen(void);

BIO *socket_connect(void);

void send(BIO *c, unsigned char * msg, ulong len);

int recv(BIO *c, unsigned char * buf, ulong len);

void wait_close(BIO *c);
