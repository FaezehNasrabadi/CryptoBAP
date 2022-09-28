#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <openssl/ssl.h>

#include "RPC.h"

#ifdef CSEC_VERIFY
  #include "common.h"
#endif

// #define VERBOSE
void SSL_load_error_strings(){};
void event1(const char * s, const unsigned char * buf, size_t len){};
void event2(const char * s, const unsigned char * buf1, size_t len1,
                            const unsigned char * buf2, size_t len2){};
void event3(const char * s, const unsigned char * buf1, size_t len1,
                            const unsigned char * buf2, size_t len2,
                            const unsigned char * buf3, size_t len3){};
void client(dstr_c *a, dstr_c *b, key_c *k, dstr_c *s)
{
	channel_c *c;
	dbytes_c *mac, pload2, mac2;
	dstr_c *t;
#ifdef VERBOSE
	unsigned long i;
#endif

#ifdef CSEC_VERIFY
	event1("client_begin", s->address, s->length);
#endif

	c = socket_connect();

	mac = hmacsha1(k, request(s));
	send(c, concat(utf8(s), mac));
#ifdef VERBOSE
	printf("Sent request\n");
	for(i = 0; i < s->length; i++)
		printf("%02x", s->address[i]);
	printf("\nwith MAC\n");
	for (i = 0; i < 20; i++)
		printf("%02x", (unsigned char) mac->address[i]);
	printf("\n");
#endif

	iconcat(recv(c), &pload2, &mac2);
	t = iutf8(&pload2);
        // BUGFIX
        if(t->length > MAX_RESPONSE_LEN)
        {
          fprintf(stderr, "Response too long.\n");
          exit(1);
        }
	hmacsha1Verify(k, response(s, t), &mac2);
#ifdef VERBOSE
	printf("Received and authenticated response\n");
	for(i = 0; i < t->length; i++)
		printf("%02x", t->address[i]);
	printf("\nwith MAC\n");
	for (i = 0; i < 20; i++)
		printf("%02x", (unsigned char) mac2.address[i]);
	printf("\n");
#endif

#ifdef CSEC_VERIFY
	event2("client_accept", s->address, s->length, t->address, t->length);
#endif
}

void server(dstr_c *a, dstr_c *b, key_c *k)
{
	channel_c *c;
	dbytes_c pload, mac, *mac2;
	dstr_c *s, *t;
#ifdef VERBOSE
	unsigned long i;
#endif

	c = socket_listen();

	iconcat(recv(c), &pload, &mac);
	s = iutf8(&pload);
        // BUGFIX
        if(s->length > MAX_REQUEST_LEN)
        {
          fprintf(stderr, "Request too long.\n");
          exit(1);
        }
	hmacsha1Verify(k, request(s), &mac);
#ifdef VERBOSE
	printf("Received and authenticated request\n");
	for(i = 0; i < s->length; i++)
		printf("%02x", s->address[i]);
	printf("\nwith MAC\n");
	for (i = 0; i < 20; i++)
		printf("%02x", (unsigned char) mac.address[i]);
	printf("\n");
#endif

	t = service(s);

#ifdef CSEC_VERIFY
	event3("server_reply", s->address, s->length, t->address, t->length, t->address, t->length);
#endif

	mac2 = hmacsha1(k, response(s, t));
	send(c, concat(utf8(t), mac2));
#ifdef VERBOSE
	printf("Sent response\n");
	for(i = 0; i < t->length; i++)
		printf("%02x", t->address[i]);
	printf("\nwith MAC\n");
	for (i = 0; i < 20; i++)
		printf("%02x", (unsigned char) mac2->address[i]);
	printf("\n");
#endif

	// wait for the client to close, to avoid "Address already in use" errors
	wait_close(c);
}

int main(int argc, char *argv[])
{
  unsigned char * key_buf;
  size_t key_len;
  unsigned char * request_buf;
  size_t request_len;
  key_c *k;
  dstr_c *alice, *bob, *s;

  if (argc < 2)
    {
      fprintf(stderr, "Wrong command-line arguments.\n");
      return 1;
    }

  SSL_load_error_strings();

  alice = str(fromString("Alice", 5));
  bob = str(fromString("Bob", 3));

  key_buf = get_shared_key(&key_len);
  k = fromString(key_buf, key_len);

  request_buf = get_request(&request_len);
  s = str(fromString(request_buf, request_len));

  // BUGFIX
  if(s->length > MAX_REQUEST_LEN)
    {
      fprintf(stderr, "Request too long.\n");
      return 1;
    }

  // FIXME: do it properly
  int isClient = 0;

  isClient = !strncmp(argv[1], "client", 6);

  if (isClient)
    {
      client(alice, bob, k, s);
    }
  else // if (!strncmp(argv[1], "server", 6))
    {
      server(alice ,bob, k);
    }
  /* else
     {
     fprintf(stderr, "Wrong command-line arguments.\n");
     return 1;
     } */

  return 0;
}
