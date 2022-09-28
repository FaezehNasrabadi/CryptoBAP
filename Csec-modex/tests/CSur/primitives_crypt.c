#include <openssl/bn.h>
#include <stdlib.h>
#include <string.h>

#include "needham_type.h"
#include "primitives_crypt.h"

/* Une fonction de g�n�ration de cl�s pub/priv */

// FIXME: Misha: seems rather computational for me
//int key_gen(struct nskey_s *nskey, unsigned long pub_key)
//{
//  /*
//  ** p et q premier (256 bits)
//  ** p,q = BN_generate_prime(res, 256, NULL, NULL, NULL, NULL)
//  ** n = BN_mul(p, q); (512 bits)
//  ** BN_clear_bit(p, 0);
//  ** BN_clear_bit(q, 0);
//  ** phi_n = BN_mul(p, q) // phi_b = (p - 1)(q - 1)
//  ** BN_set_word(pub_exp, 65537)
//  ** BN_CTX ctx = BN_CTX_new();
//  ** priv_exp = BN_mod_inverse(NULL, pub_exp, phi_n, ctx);
//  */
//  BIGNUM *p,*q;
//  BIGNUM *res;
//  BIGNUM *n, *phi_n;
//  BN_CTX *ctx;
//
//  nskey -> pub_exp  = BN_new();
//  nskey -> pub_mod  = BN_new();
//  nskey -> priv_exp = BN_new();
//
//  ctx = BN_CTX_new();
//
//  p     = BN_new();
//  q     = BN_new();
//  res   = BN_new();
//  n     = BN_new();
//  phi_n = BN_new();
//
//  /* BIGNUM *BN_generate_prime(BIGNUM *ret, int num, int safe, BIGNUM *add,
//     BIGNUM *rem, void ( * callback )(int, int, void * ), void *cb_arg); */
//
//  BN_generate_prime(p, 256, 0, NULL, NULL, NULL, NULL) ;
//  BN_generate_prime(q, 256, 0, NULL, NULL, NULL, NULL) ;
//
//  /* */
//  printf("\nGenerator \n p=%s \n q=%s\n", BN_bn2hex(p), BN_bn2hex(q));
//  /* */
//
//  BN_mul(n, p, q, ctx);     /* n = (p*q) */
//  BN_clear_bit(p, 0);       /* p = (p-1) */
//  BN_clear_bit(q, 0);       /* q = (q-1) */
//  BN_CTX_init(ctx);
//  BN_mul(phi_n,p, q, ctx) ; /* phi_n = (p-1)(q-1) */
//
//  nskey-> pub_mod = n; /* n */
//
//  /* int     BN_set_word(BIGNUM *a, BN_ULONG w); */
//  BN_set_word(nskey->pub_exp,  pub_key);
//
//  /* BIGNUM *BN_mod_inverse(BIGNUM *r, BIGNUM *a, const BIGNUM *n, BN_CTX *ctx); */
//  /* ((a*r)%n==1). */
//  BN_CTX_init(ctx);
//  nskey -> priv_exp = BN_mod_inverse(NULL, nskey->pub_exp, phi_n, ctx);
//
//  if (nskey -> priv_exp == NULL)
//    {
//      exit(1);
//    };
//
//  return(0);
//}


int printf_keys(struct nskey_s * nskey)
{
  printf("\nprintkey : ");
  printf("\npub  = ");
  BN_print_fp(stdout,nskey -> pub_exp);
  printf("\nmod  = ");
  BN_print_fp(stdout,nskey -> pub_mod);
  printf("\npriv = ");
  BN_print_fp(stdout,nskey -> priv_exp);
  printf("\n");
  /*
     printf("\n %s %s %s\n", BN_bn2hex(nskey -> pub_exp) , BN_bn2hex(nskey -> pub_mod) , BN_bn2hex(nskey -> priv_exp));
  */
  return(0);
}


int key_of_string (char *kpub, char *kpriv, char *kmod, struct nskey_s *nskey)
{

  nskey -> pub_exp  = BN_new();
  nskey -> pub_mod  = BN_new();
  nskey -> priv_exp = BN_new();

  BN_hex2bn(&(nskey -> pub_exp), kpub);
  BN_hex2bn(&(nskey -> priv_exp), kpriv);
  BN_hex2bn(&(nskey -> pub_mod) , kmod);

  return(0);

}


int my_cypher(msg_t *msg, struct nskey_s *pub_key, BIGNUM *cipher)
{
  BIGNUM *plain;
  int msg_len;
  BN_CTX *ctx;

  ctx = BN_CTX_new();
  msg_len = sizeof (msg_t);

  // FIXME: BUG:
  /*
  msg_len = sizeof(int);
  switch (msg->msg_type)
    {
    case MSG1:
      msg_len += sizeof (msg1_t);
      break;
    case MSG2:
      msg_len += sizeof (msg2_t);
      break;
    case MSG3:
      msg_len += sizeof (msg3_t);
      break;
    default:
      printf("\nErreur my_cipher");
      exit(EXIT_FAILURE);
    }
  */

  /* BIGNUM *BN_bin2bn(const unsigned char *s,int len,BIGNUM *ret); */

  plain = BN_bin2bn((unsigned char *) msg, msg_len, NULL);

  /*
     printf("\nMSG plain  = ");
     BN_print_fp(stdout,plain);
  */

  /* int     BN_mod_exp(BIGNUM *r, BIGNUM *a, const BIGNUM *p,
     const BIGNUM *m,BN_CTX *ctx); */
  /* r=a^p % m */
  BN_CTX_init(ctx);
  BN_mod_exp(cipher, plain, pub_key->pub_exp, pub_key->pub_mod, ctx);

  return (0);
}

int my_decypher(BIGNUM *cipher, struct nskey_s *priv_key, msg_t *plain)
{
  BIGNUM *bn_plain;
  unsigned char temp[1024];
  BN_CTX *ctx;
  int msg_len;

  ctx = BN_CTX_new();
  bn_plain = BN_new();

  /*
  printf("\nmy_decipher, priv_key: ");
  print_buffer((unsigned char *)priv_key, sizeof(*priv_key));

  int cipher_len = BN_bn2bin(cipher, temp);
  printf("\nmy_decipher, cipher: ");
  print_buffer(temp, cipher_len);
  */

  /* int     BN_mod_exp(BIGNUM *r, BIGNUM *a, const BIGNUM *p,
     const BIGNUM *m,BN_CTX *ctx); */
  /* r=a^p % m */
  BN_mod_exp(bn_plain, cipher, priv_key->priv_exp, priv_key->pub_mod, ctx);

  /*
    printf("\nMSG d�chiffr� = ");
    BN_print_fp(stdout,bn_plain);
  */

  if (BN_num_bytes(bn_plain) > 1024)
    return (1);

  BN_bn2bin(bn_plain, temp);

  /*
  printf("\nmy_decipher, bn_plain: ");
  print_buffer(temp, BN_num_bytes(bn_plain));
  */
  msg_len = sizeof (msg_t) ;

  // BUGFIX
  if (BN_num_bytes(bn_plain) < msg_len) {
    printf("bn_plain too short");
    exit(1);
  }
  // END BUGFIX

  /*
  switch (((msg_t) (temp)).msg_type)
    {
    case MSG1:
      msg_len += sizeof (msg1_t);
      break;
    case MSG2:
      msg_len += sizeof (msg2_t);
      break;
    case MSG3:
      msg_len += sizeof (msg3_t);
      break;
    default:
      printf("\nErreur my_cipher");
      exit(EXIT_FAILURE);
    };
  */

  memcpy(plain, temp, msg_len);

  return (0);
}


int printf_message(msg_t* msg)
{

  // printf("\n msg_type = %d",msg -> msg_type);

  switch (msg -> msg_type)
    {
    case MSG1:
      printf("\nMessage Type 1 : id=%lu, nonce=",  msg->msg.msg1.id);
      // print_buffer(msg->msg.msg1.nonce, sizeof(msg->msg.msg1.nonce));
      printf("\n");
      // printf("\nMessage Type 1 \n");
      break;
    case MSG2:
      /* printf("\nMessage Type 2 : nonce1=%s, nonce=%s", msg->msg.msg2.nonce1, msg->msg.msg2.nonce2); */
      printf("\nMessage Type 2 \n");
      break;
    case MSG3:
      /* printf("\nMessage Type 3 : nonce=%s", msg->msg.msg3.nonce); */
      printf("\nMessage Type 3 \n");
      break;
    default:
      printf("\nErreur printf_message type msg\n");
      exit(EXIT_FAILURE);
    };
  return(0);
}

int print_nonce(unsigned char nonce[16])
{
  int i;
  for (i=0;i<SIZENONCE;i++) { printf ("%d ", nonce[i]); };
  return(0);
}


/*
int main()
{
  struct nskey_s *nskey;

  msg_t my_message;
  msg_t de_my_message;

  BIGNUM *cipher;

  key_gen(nskey);
  printf_keys(nskey);

  my_message.msg_type = MSG1;
  my_message.msg.msg1.id = 1024;
  strcpy(my_message.msg.msg1.nonce,"Fabrice");

  printf_message(&my_message);

  cipher = BN_new();
  my_cypher( &my_message, nskey, cipher);

  printf("\n Le message chiffr� = %s ", BN_bn2hex(cipher));
  printf("\n");

  my_decypher(cipher, nskey, &de_my_message);


  printf("\n Le message d�chiffr�\n");
  printf_message(&de_my_message);

  return(0);
}
*/

