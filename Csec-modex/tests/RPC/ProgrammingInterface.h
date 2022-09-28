
#include <stddef.h>

#define MAX_REQUEST_LEN 2000
#define MAX_RESPONSE_LEN 2000

// Concrete types
typedef struct dbytes_s
{
	char *address;
	unsigned long length;
} bytes_c;

typedef bytes_c dbytes_c;
typedef bytes_c dstr_c;
typedef bytes_c key_c;
typedef bytes_c usage_c;
typedef bytes_c string_c;

extern unsigned char * get_shared_key(size_t * len);
extern unsigned char * get_request(size_t * len);

// Strings, Unicode and Base64
string_c *fromString(char *addr, unsigned long len);

dstr_c *str(string_c *str);

string_c *istr(dstr_c *s);

dstr_c *base64(dbytes_c *b);

dbytes_c *ibase64(dstr_c *s);

dbytes_c *utf8(dstr_c *s);

dstr_c *iutf8(dbytes_c *b);

// Concatenation
dbytes_c *concat(dbytes_c *b1, dbytes_c *b2);

void iconcat(dbytes_c *ab, dbytes_c *a, dbytes_c *b);

// Nonces and fresh bytestrings
dbytes_c *mkNonce(void);

dbytes_c *mkNonce256(void);

dbytes_c *freshbytes(usage_c *u, string_c *s);

// Message Authentication Codes
key_c *hmac_keygen(void);

dbytes_c *hmacsha1(key_c *k, dbytes_c *b);

void hmacsha1Verify(key_c *k, dbytes_c *b, dbytes_c *h);

dbytes_c *hmac_keyseed(void);

key_c *psha1(dbytes_c *b1, dbytes_c *b2);
