// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include <openssl/bio.h>
#include <openssl/err.h>

extern BIO *socket_listen(void);

extern BIO *socket_connect(void);

extern void send(BIO *c, unsigned char * msg, ulong len);

extern int recv(BIO *c, unsigned char * buf, ulong len);

extern void wait_close(BIO *c);
