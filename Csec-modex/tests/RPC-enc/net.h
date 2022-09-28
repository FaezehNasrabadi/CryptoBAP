// Copyright (c) Mihhail Aizatulin (avatar@hot.ee), Francois Dupressoir (fdupress@gmail.com).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#define DEFAULTHOST      "localhost"
#define DEFAULTHOST_LEN  9
#define DEFAULTPORT      4433

#include <stdlib.h>
#include <stdint.h>
#include <polarssl/net.h>

int socket_listen(int *bind_fd, int *client_fd, const unsigned char *bind_ip, uint32_t bind_ip_len, int port, void *client_ip);

int socket_connect(int *fd, const char *host, uint32_t host_len, int port);

void send(int *ch, unsigned char * msg, unsigned long len);

int recv(int *ch, unsigned char * buf, unsigned long len);

void wait_close(int *c);
