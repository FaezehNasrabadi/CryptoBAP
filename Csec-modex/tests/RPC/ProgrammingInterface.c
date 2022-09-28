#include <openssl/rand.h>
#include <openssl/evp.h>
#include <openssl/hmac.h>

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <limits.h>

#ifdef CSEC_VERIFY
#include "common.h"
#endif

const static unsigned char request[] = "ThisIsARequest";
const static unsigned char key[] = "ThisIsASharedKey";

unsigned char * get_request(size_t * len)
{
  *len = strlen(request);
  return request;
}

unsigned char * get_shared_key(size_t * len)
{
  *len = strlen(key);
  return key;
}



typedef struct dbytes_s
{
	unsigned char *address;
	unsigned long length;

} bytes_c;

typedef bytes_c dbytes_c;
typedef bytes_c dstr_c;
typedef bytes_c key_c;
typedef bytes_c usage_c;
typedef bytes_c string_c;

bytes_c *cpy(bytes_c *b)
{
	dstr_c *ret;

	if (b == NULL)
	{
		fprintf(stderr, "Error: Invalid argument (to cpy()).\n");
		exit(0);
	}

	ret = malloc(sizeof(*ret));
	if (ret == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in cpy()).\n");
		exit(0);
	}

	ret->address = malloc(b->length);
	if (ret->address == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in cpy()).\n");
		exit(0);
	}

	memcpy(ret->address, b->address, b->length);
	ret->length = b->length;

	return ret;
}

string_c *fromString(char *addr, unsigned long len)
{
	dstr_c *res;

	if (addr == NULL)
	{
		fprintf(stderr, "Error: Invalid argument (to fromString()).\n");
		exit(0);
	}

	res = malloc(sizeof(*res));
	if (res == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in fromString()).\n");
		exit(0);
	}

	res->address = malloc(len);
	if (res->address == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in fromString()).\n");
		exit(0);
	}

	memcpy(res->address, addr, len);
	res->length = len;

        // BUGFIX

        // We convert these lengths to integers when calling openssl functions,
        // so we check in advance that this will not overflow.
        if (res->length > INT_MAX)
        {
		fprintf(stderr, "Error: String too long (in fromString()).\n");
		exit(0);
	}


	return res;
}

dstr_c *str(string_c *str)
{
	return (dstr_c*) cpy((string_c *) str);
}

string_c *istr(dstr_c *s)
{
	return (string_c*) cpy((bytes_c *) s);
}

dstr_c *base64(dbytes_c *b)
{
	return (dstr_c*) cpy((bytes_c *) b);
}

dbytes_c *ibase64(dstr_c *s)
{
	return (dbytes_c*) cpy((bytes_c *) s);
}

dbytes_c *utf8(dstr_c *s)
{
	return (dbytes_c*) cpy((bytes_c *) s);
}

dstr_c *iutf8(dbytes_c *b)
{
	return (dstr_c*) cpy((bytes_c *) b);
}


dbytes_c *concat(dbytes_c *b1, dbytes_c *b2)
{
	dbytes_c *ret;
	unsigned long totLen;

	if (b1 == NULL || b2 == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in concat()).\n");
		exit(0);
	}

	totLen = b1->length + b2->length;
	ret = malloc(sizeof(*ret));
	if (ret == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in concat()).\n");
		exit(0);
	}

	// BUGFIX: Original mistake, preserve to verify later:
	// ret->address = malloc(totLen);
	ret->address = malloc(totLen + sizeof(b1->length) + sizeof(char));
	if (ret->address == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in concat()).\n");
		exit(0);
	}

	memcpy(ret->address, &(b1->length), sizeof(b1->length));
	memcpy(ret->address + sizeof(b1->length),  "|", sizeof(char));
	memcpy(ret->address + sizeof(b1->length) + sizeof(char), b1->address, b1->length);
	memcpy(ret->address + sizeof(b1->length) + sizeof(char) + b1->length, b2->address, b2->length);

	ret->length = totLen + sizeof(b1->length) + sizeof(char);

	return ret;
}

void iconcat(dbytes_c *ab, dbytes_c *a, dbytes_c *b)
{
	unsigned long totLen, aLen, bLen;

	if (ab == NULL || a == NULL || b == NULL)
	{
		fprintf(stderr, "Error: Invalid argument (to iconcat).\n");
		exit(0);
	}

        // BUGFIX:
        if (ab->length < sizeof(aLen) + sizeof(char))
	{
          fprintf(stderr, "Error: This byte array is not a valid concatenation.\n");
          exit(0);
	}

	totLen = ab->length - sizeof(aLen) - sizeof(char);

	memcpy(&aLen, ab->address, sizeof(aLen));

	// CR: restore when you can prove that (int) 7c = i127
	// if (aLen > totLen || ab->address[sizeof(aLen)] != '|')
	if (aLen > totLen || memcmp(ab->address + sizeof(aLen), "|", 1))
	{
		fprintf(stderr, "Error: This byte array is not a valid concatenation.\n");
		exit(0);
	}
	bLen = totLen - aLen;

	a->address = malloc(aLen);
	b->address = malloc(bLen);
	if (a->address == NULL || b->address == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in iconcat()).\n");
		exit(0);
	}

	memcpy(a->address, (ab->address + sizeof(aLen) + sizeof(char)), aLen);
	memcpy(b->address, (ab->address + sizeof(aLen) + sizeof(char) + aLen), bLen);

	a->length = aLen;
	b->length = bLen;

	return;
}

dbytes_c *mkNonce(void)
{
	dbytes_c *ret = malloc(sizeof(*ret));
	if (ret == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in mkNonce()).\n");
		exit(0);
	}

	ret->address = malloc(sizeof(unsigned long));
	if (ret->address == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in mkNonce()).\n");
		exit(0);
	}

	RAND_bytes(ret->address, sizeof(unsigned long));
	ret->length = sizeof(unsigned long);

	return ret;
}

dbytes_c *mkNonce256(void)
{
	dbytes_c *ret = malloc(sizeof(*ret));
	if (ret == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in mkNonce()).\n");
		exit(0);
	}

	ret->address = malloc(32);
	if (ret->address == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in mkNonce()).\n");
		exit(0);
	}

	RAND_bytes(ret->address, 32);
	ret->length = 32;

	return ret;
}

dbytes_c *freshbytes(usage_c *u, string_c *s);

key_c *hmac_keygen(void)
{
	return (key_c *) mkNonce256();
}

dbytes_c *hmacsha1(key_c *k, dbytes_c *b)
{
	dbytes_c *ret;
	unsigned int length;

	if (k == NULL || b == NULL)
	{
		fprintf(stderr, "Error: Invalid arguments (in hmacsha1()).\n");
		exit(0);
	}

	ret = malloc(sizeof(*ret));
	if (ret == NULL)
	{
		fprintf(stderr, "Error: Out of Memory (in hmacsha1()).\n");
		exit(0);
	}

	ret->address = HMAC(EVP_sha1(), k->address, k->length, b->address, b->length, NULL, &length);
	ret->length = length;

	return ret;
}

void hmacsha1Verify(key_c *k, dbytes_c *b, dbytes_c *h)
{
	dbytes_c *tmp;

	if (k == NULL || b == NULL || h == NULL)
	{
		fprintf(stderr, "Error: Invalid arguments (in hmacsha1Verify()).\n");
		exit(0);
	}

	tmp = hmacsha1(k, b);

	if (h->length == tmp->length)
		if (!memcmp(h->address, tmp->address, h->length))
			return;

	fprintf(stderr, "Failure: Invalid MAC.\n");
	exit(0);
}

dbytes_c *hmac_keyseed(void);
key_c *psha1(dbytes_c *b1, dbytes_c *b2);
