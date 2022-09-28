#include "RPC.h"

#include <stdlib.h>

dbytes_c *request(dstr_c *s)
{
  dbytes_c *res = concat(utf8(str(fromString("Request", 7))), utf8(s));
  return res;
}

dbytes_c *response(dstr_c *s, dstr_c *t)
{
  dbytes_c *res = concat(utf8(str(fromString("Response", 8))), concat(utf8(s), utf8(t)));
  return res;
}

key_c *mkKeyAB(dstr_c *a, dstr_c *b)
{
  key_c *k = hmac_keygen();
  return k;
}

dstr_c *service(dstr_c *s)
{
  return iutf8(concat(utf8(str(fromString("ACK:", 4))), utf8(s)));
}
