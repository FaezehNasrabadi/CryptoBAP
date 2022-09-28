// Copyright (c) Mihhail Aizatulin (avatar@hot.ee), Francois Dupressoir (fdupress@gmail.com).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "net.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int socket_listen(int *bind_fd, int *client_fd, const unsigned char *bind_ip, uint32_t bind_ip_len, int port, void *client_ip)
{
  int ret;
  char * bind_ip_nt = malloc(bind_ip_len + 1);
  if (bind_ip_nt == 0)
    return -1;

  memcpy(bind_ip_nt,bind_ip,bind_ip_len);
  bind_ip_nt[bind_ip_len] = 0;

  if ((ret = net_bind(bind_fd,bind_ip_nt,port)) != 0)
  {
    fprintf(stderr, "Error: Network error (in listen()).\n");
    return ret;
  }
  if ((ret = net_accept(*bind_fd,client_fd,client_ip)) != 0)
  {
    fprintf(stderr, "Error: Network error (in listen()).\n");
    return ret;
  }

  free(bind_ip_nt);
  return 0;
}

int socket_connect(int *fd, const char *host, uint32_t host_len, int port)
{
  int ret;

  // turn into null-terminated string:
  char * host_str = malloc(host_len + 1);
  memcpy(host_str, host, host_len);
  host_str[host_len] = 0;

  if ((ret = net_connect(fd, host_str, port)) != 0)
    fprintf(stderr, "Error: Network error (in connect()).\n");

  return ret;
}

void send(int *c, unsigned char * msg, unsigned long len)
{
	int tmp;
	unsigned long sent = 0;

	sent = 0;
	while (sent < len)
	{
		if ((tmp = net_send(c, msg + sent, len - sent)) <= 0)
		{
			fprintf(stderr, "Error: Network error (in send()).\n");
			exit(0);
		}
		sent += tmp;
	}

	if (sent == len)
		return;
	
	fprintf(stderr, "Error: Network error (in send()).\n");
	exit(0);
}

int recv(int *c, unsigned char * buf, unsigned long len)
{
	int tmp;
	unsigned long received = 0;

	while (received < len)
	{
		if ((tmp = net_recv(c, buf + received, len - received)) <= 0)
		{
			fprintf(stderr, "Error: Network error (in recv()).\n");
			exit(0);
		}
		received += tmp;
	}

	if (received == len)
		return len;

	fprintf(stderr, "Error: Network error (in recv()).\n");
	exit(0);
}


void wait_close(int *c)
{
  net_close(*c);
  //unsigned char dummy;
  //net_recv(c, &dummy, 1);
}

