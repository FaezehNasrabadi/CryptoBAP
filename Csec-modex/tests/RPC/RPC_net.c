#include <openssl/bio.h>
#include <openssl/err.h>

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>

#include "ProgrammingInterface.h"

#define DEFAULTHOST "127.0.0.1:1234"

typedef BIO channel_c;

channel_c *socket_listen(void)
{
	channel_c *netBIO, *res;

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

channel_c *socket_connect(void)
{
	channel_c *res;

	if ((res = BIO_new_connect(DEFAULTHOST)) == NULL)
	{
		fprintf(stderr, "Error: Network error in connect() 1.\n");
                ERR_print_errors_fp(stderr);
		exit(0);
	}
	if (BIO_do_connect(res) <= 0)
	{
		fprintf(stderr, "Error: Network error in connect() 2.\n");
		ERR_print_errors_fp(stderr);
		BIO_free(res);
		return NULL;
	}

	return res;

}

void send(channel_c *c, dbytes_c *b)
{
	int tmp;
	unsigned long sent = 0;

	if (c == NULL || b == NULL)
	{
		fprintf(stderr, "Error: Invalid argument (to send()).\n");
		exit(0);
	}

        // BUGFIX: we pass this to BIO_write as int
        if(b->length > INT_MAX){
          fprintf(stderr, "Error: message length too large (in send()).\n");
          exit(0);
        }

	while (sent < sizeof(b->length))
	{
		if ((tmp = BIO_write(c, &(b->length), sizeof(b->length) - sent)) <= 0)
		{
			fprintf(stderr, "Error: Network error (in send()).\n");
			exit(0);
		}
		sent += tmp;
	}

	sent = 0;
	while (sent < b->length)
	{
		if ((tmp = BIO_write(c, b->address, b->length - sent)) <= 0)
		{
			fprintf(stderr, "Error: Network error (in send()).\n");
			exit(0);
		}
		sent += tmp;
	}

	if (sent == b->length)
		return;

	fprintf(stderr, "Error: Network error (in send()).\n");
	exit(0);
}

dbytes_c *recv(channel_c *c)
{
	dbytes_c *res;
	int tmp;
	unsigned long received = 0;

	if (c == NULL)
	{
		fprintf(stderr, "Error: Invalid argument (to recv()).\n");
		exit(0);
	}

	res = malloc(sizeof(*res));
	if (res == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in recv()).\n");
		exit(0);
	}

	while (received < sizeof(res->length))
	{
		if ((tmp = BIO_read(c, &(res->length), sizeof(res->length) - received)) <= 0)
		{
			fprintf(stderr, "Error: Network error (in recv()).\n");
			exit(0);
		}
		received += tmp;
	}

        // BUGFIX: we pass this to BIO_read as int
        if(res->length > INT_MAX){
          fprintf(stderr, "Error: received length too large (in recv()).\n");
          exit(0);
        }

	res->address = malloc(res->length);
	if (res->address == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in recv()).\n");
		exit(0);
	}

	received = 0;
	while (received < res->length)
	{
		if ((tmp = BIO_read(c, res->address, res->length - received)) <= 0)
		{
			fprintf(stderr, "Error: Network error (in recv()).\n");
			exit(0);
		}
		received += tmp;
	}

	if (received == res->length)
		return res;

	fprintf(stderr, "Error: Network error (in recv()).\n");
	exit(0);
}


void wait_close(channel_c *c)
{
  char dummy;
  BIO_read(c, &dummy, 1);
}

