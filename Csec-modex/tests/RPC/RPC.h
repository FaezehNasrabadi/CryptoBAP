#include "ProgrammingInterface.h"

typedef int channel_c;

// Network functions (would be somewhere else)
channel_c *socket_listen(void);
channel_c *socket_connect(void);
void wait_close(channel_c *);

void send(channel_c *c, dbytes_c *b);

dbytes_c *recv(channel_c *c);

// Programming interface
dbytes_c *request(dstr_c *s);

dbytes_c *response(dstr_c *s, dstr_c *t);

dstr_c *service(dstr_c *s);

key_c *mkKeyAB(dstr_c *a, dstr_c *b);

void client(dstr_c *a, dstr_c *b, key_c *k, dstr_c *s);

void server(dstr_c *a, dstr_c *b, key_c *k);
