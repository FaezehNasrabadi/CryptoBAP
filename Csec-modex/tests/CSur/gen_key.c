#include <openssl/bn.h>
#include <stdlib.h>

#include "primitives_crypt.h"



int main(int argc, char **argv) 
{
  struct nskey_s *nskey;
  unsigned long pub_key;

  pub_key = 65537;

  if (argc == 2)
    {
      pub_key = atoi(argv[1]);
    }
  ;

  printf("\nLa clés publique = %lu \n", pub_key);

  key_gen(nskey, pub_key);
  printf_keys(nskey);
}
