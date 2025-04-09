#include <stdint.h>

static void send(int b) {}

static int senc(char *m, int k) {}

static int new_key(void) {}

void main() {

  	int k = new_key();

	char *m = "message";	
	
	int cipher = senc(m,k);

	int b = k ^ 123456;	

	send(b);

return;
}
