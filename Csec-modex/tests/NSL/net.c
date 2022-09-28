// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "net.h"

#include <stdlib.h>
#include <stdio.h>

#define DEFAULTHOST "127.0.0.1:1234"

BIO *socket_listen(void)
{
	BIO *netBIO, *res;

	if ((netBIO = BIO_new_accept(DEFAULTHOST)) == NULL)
	{
		fprintf(stderr, "Error: Network error (in listen()).\n");
		exit(0);
	}
	if (BIO_do_accept(netBIO) <= 0)
	{
		fprintf(stderr, "Error: Network error (in listen()).\n");
		ERR_print_errors_fp(stderr);
		BIO_free(netBIO);
		exit(0);
	}
	if (BIO_do_accept(netBIO) <= 0)
	{
		fprintf(stderr, "Error: Network error (in listen()).\n");
		ERR_print_errors_fp(stderr);
		BIO_free(netBIO);
		exit(0);
	}
	res = BIO_pop(netBIO);
	BIO_free(netBIO);

	return res;
}

BIO *socket_connect(void)
{
	BIO *res;

	if ((res = BIO_new_connect(DEFAULTHOST)) == NULL)
	{
		fprintf(stderr, "Error: Network error (in connect()).\n");
		exit(0);
	}
	if (BIO_do_connect(res) <= 0)
	{
		fprintf(stderr, "Error: Network error (in connect()).\n");
		BIO_free(res);
		exit(0);
	}

	return res;
}

void send(BIO *c, unsigned char * msg, unsigned long len)
{
	int tmp;
	unsigned long sent = 0;

	sent = 0;
	while (sent < len)
	{
		if ((tmp = BIO_write(c, msg + sent, len - sent)) <= 0)
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

int recv(BIO *c, unsigned char * buf, unsigned long len)
{
	int tmp;
	unsigned long received = 0;

	while (received < len)
	{
		if ((tmp = BIO_read(c, buf + received, len - received)) <= 0)
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


void wait_close(BIO *c)
{
  char dummy;
  BIO_read(c, &dummy, 1);
}

