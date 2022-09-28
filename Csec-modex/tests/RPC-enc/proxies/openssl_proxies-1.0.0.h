
// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.



#ifndef OPENSSL_PROXIES_H
#define OPENSSL_PROXIES_H

#include <openssl/ssl.h>
#include <openssl/evp.h>
#include <openssl/x509v3.h>
#include <openssl/engine.h>
#include <openssl/hmac.h>
#include <openssl/pem.h>
#include <openssl/des.h>
#include <openssl/aes.h>

 
/*
   i2d_X509() encodes the structure pointed to by x into DER format.
   If out is not NULL is writes the DER encoded data to the buffer at *out,
   and increments it to point after the data just written.
   If the return value is negative an error occurred,
   otherwise it returns the length of the encoded data.
   For OpenSSL 0.9.7 and later if *out is NULL memory will be allocated
   for a buffer and the encoded data written to it.
   In this case *out is not incremented and it points to the start of the data just written.
*/
extern int i2d_X509_proxy(X509 *a , unsigned char **out ) ;
#pragma cilnoremove("i2d_X509_proxy")

/*
 * d2i_X509() attempts to decode len bytes at *in.
 * If successful a pointer to the X509 structure is returned.
 * If an error occurred then NULL is returned.
 * If px is not NULL then the returned structure is written to *px.
 * If *px is not NULL then it is assumed that *px contains a valid X509 structure
 * and an attempt is made to reuse it.
 * If the call is successful *in is incremented to the byte following the parsed data.
 */
extern X509 *d2i_X509_proxy(X509 **a , unsigned char const   **in , long len ) ;
#pragma cilnoremove("d2i_X509_proxy")

// done
extern int EVP_DigestInit_ex_proxy(EVP_MD_CTX *ctx , EVP_MD const   *type , ENGINE *impl ) ;
#pragma cilnoremove("EVP_DigestInit_ex_proxy")

// done
extern int EVP_DigestUpdate_proxy(EVP_MD_CTX *ctx , void const   *d , size_t cnt ) ;
#pragma cilnoremove("EVP_DigestUpdate_proxy")

// undocumented
extern EVP_PKEY *X509_get_pubkey_proxy(X509 *x ) ;
#pragma cilnoremove("X509_get_pubkey_proxy")

// done
extern int EVP_VerifyFinal_proxy(EVP_MD_CTX *ctx , unsigned char const   *sigbuf ,
                                 unsigned int siglen , EVP_PKEY *pkey ) ;
#pragma cilnoremove("EVP_VerifyFinal_proxy")


// done
extern int EVP_SignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ,
                               EVP_PKEY *pkey ) ;
#pragma cilnoremove("EVP_SignFinal_proxy")

/*
 * EVP_md2(), EVP_md5(), EVP_sha(), EVP_sha1(), EVP_mdc2() and EVP_ripemd160()
 * return EVP_MD structures for the MD2, MD5, SHA, SHA1, MDC2 and RIPEMD160
 * digest algorithms respectively. The associated signature algorithm is RSA in each case.
 */
extern EVP_MD const   *EVP_md5_proxy(void) ;
#pragma cilnoremove("EVP_md5_proxy")
extern EVP_MD const   *EVP_sha1_proxy(void) ;
#pragma cilnoremove("EVP_sha1_proxy")

// done
extern int EVP_DigestFinal_ex_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ) ;
#pragma cilnoremove("EVP_DigestFinal_ex_proxy")


/*
 * EVP_EncryptInit_ex() sets up cipher context ctx for encryption with cipher type from ENGINE impl.
 * ctx must be initialized before calling this function.
 * type is normally supplied by a function such as EVP_des_cbc().
 * If impl is NULL then the default implementation is used.
 * key is the symmetric key to use and iv is the IV to use (if necessary),
 * the actual number of bytes used for the key and IV depends on the cipher.
 * It is possible to set all parameters to NULL except type in an initial call
 * and supply the remaining parameters in subsequent calls, all of which have type set to NULL.
 * This is done when the default cipher parameters are not appropriate.
 */
extern int EVP_EncryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const   *cipher ,
                                    ENGINE *impl , unsigned char const   *key , unsigned char const   *iv ) ;
#pragma cilnoremove("EVP_EncryptInit_ex_proxy")

/*
 * EVP_DecryptInit_ex(), EVP_DecryptUpdate() and EVP_DecryptFinal_ex()
 * are the corresponding decryption operations.
 */
extern int EVP_DecryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const   *cipher ,
                                    ENGINE *impl , unsigned char const   *key , unsigned char const   *iv ) ;
#pragma cilnoremove("EVP_DecryptInit_ex_proxy")

// done
extern int EVP_Cipher_proxy(EVP_CIPHER_CTX *c , unsigned char *out , unsigned char const   *in ,
                            unsigned int inl ) ;
#pragma cilnoremove("EVP_Cipher_proxy")

// done
extern int EVP_MD_CTX_copy_proxy(EVP_MD_CTX *out , EVP_MD_CTX const   *in ) ;
#pragma cilnoremove("EVP_MD_CTX_copy_proxy")

// done
extern EVP_MD const   *EVP_MD_CTX_md_proxy(EVP_MD_CTX const   *ctx ) ;
#pragma cilnoremove("EVP_MD_CTX_md_proxy")

// done
extern int BIO_read_proxy(BIO *b , void *data , int len ) ;
#pragma cilnoremove("BIO_read_proxy")

// done
extern int BIO_write_proxy(BIO *b , void const   *data , int len ) ;
#pragma cilnoremove("BIO_write_proxy")

extern long BIO_ctrl_proxy(BIO *bp , int cmd , long larg , void *parg );
#pragma cilnoremove("BIO_ctrl_proxy")

/*
 * EVP_dss() and EVP_dss1() return EVP_MD structures for
 * SHA and SHA1 digest algorithms but using DSS (DSA) for the signature algorithm.
 */
extern EVP_MD const   *EVP_dss1_proxy(void) ;
#pragma cilnoremove("EVP_dss1_proxy")

// undocumented
extern EVP_MD const   *EVP_ecdsa_proxy(void) ;
#pragma cilnoremove("EVP_ecdsa_proxy")



// undocumented
extern int X509_certificate_type_proxy(X509 *x , EVP_PKEY *pubkey ) ;
#pragma cilnoremove("X509_certificate_type_proxy")


// undocumented
extern EVP_CIPHER const   *EVP_aes_128_cbc_proxy(void) ;
#pragma cilnoremove("EVP_aes_128_cbc_proxy")

// almost undocumented
extern EVP_MD const   *EVP_sha256_proxy(void) ;
#pragma cilnoremove("EVP_sha256_proxy")

/*
 * HMAC_Init_ex() initializes or reuses a HMAC_CTX structure to use the function evp_md and key key.
 * Either can be NULL, in which case the existing one will be reused.
 * HMAC_CTX_init() must have been called before the first use of an HMAC_CTX in this function.
 * N.B. HMAC_Init() had this undocumented behaviour in previous versions of OpenSSL -
 * failure to switch to HMAC_Init_ex() in programs that expect it will cause them to stop working.
 */
extern int HMAC_Init_ex_proxy(HMAC_CTX *ctx , void const   *key , int len , EVP_MD const   *md ,
                              ENGINE *impl ) ;
#pragma cilnoremove("HMAC_Init_ex_proxy")

extern int HMAC_Update_proxy(HMAC_CTX *ctx , unsigned char const   *data , size_t len ) ;
#pragma cilnoremove("HMAC_Update_proxy")

extern int HMAC_Final_proxy(HMAC_CTX *ctx , unsigned char *md , unsigned int *len ) ;
#pragma cilnoremove("HMAC_Final_proxy")

extern unsigned char *HMAC_proxy(EVP_MD const   *evp_md , void const   *key ,
                                 int key_len , unsigned char const   *d ,
                                 size_t n , unsigned char *md ,
                                 unsigned int *md_len ) ;
#pragma cilnoremove("HMAC_proxy")

/*
 * EVP_EncryptUpdate() encrypts inl bytes from the buffer in and writes the encrypted version to out.
 * This function can be called multiple times to encrypt successive blocks of data.
 * The amount of data written depends on the block alignment of the encrypted data:
 * as a result the amount of data written may be anything from zero bytes to (inl + cipher_block_size - 1)
 * so outl should contain sufficient room. The actual number of bytes written is placed in outl.
 */
extern int EVP_EncryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const   *in , int inl ) ;
#pragma cilnoremove("EVP_EncryptUpdate_proxy")

/*
 * If padding is enabled (the default) then EVP_EncryptFinal_ex() encrypts the "final" data,
 * that is any data that remains in a partial block. It uses standard block padding (aka PKCS padding).
 * The encrypted final data is written to out which should have sufficient space for one cipher block.
 * The number of bytes written is placed in outl.
 * After this function is called the encryption operation is finished and no further calls to
 * EVP_EncryptUpdate() should be made.
 */
extern int EVP_EncryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ) ;
#pragma cilnoremove("EVP_EncryptFinal_proxy")

// done
extern int EVP_DigestInit_proxy(EVP_MD_CTX *ctx , EVP_MD const   *type ) ;
#pragma cilnoremove("EVP_DigestInit_proxy")

/*
 * EVP_CipherInit_ex(), EVP_CipherUpdate() and EVP_CipherFinal_ex() are functions that can be used
 * for decryption or encryption. The operation performed depends on the value of the enc parameter.
 * It should be set to 1 for encryption, 0 for decryption and -1 to leave the value unchanged
 * (the actual value of 'enc' being supplied in a previous call).
 */
extern int EVP_CipherInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const   *cipher ,
                                   ENGINE *impl , unsigned char const   *key , unsigned char const   *iv ,
                                   int enc ) ;
#pragma cilnoremove("EVP_CipherInit_ex_proxy")

// done
extern int EVP_MD_CTX_copy_ex_proxy(EVP_MD_CTX *out , EVP_MD_CTX const   *in ) ;
#pragma cilnoremove("EVP_MD_CTX_copy_ex_proxy")



/*
 * EVP_DecryptInit_ex(), EVP_DecryptUpdate() and EVP_DecryptFinal_ex()
 * are the corresponding decryption operations.
 */
extern int EVP_DecryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const   *in , int inl ) ;
#pragma cilnoremove("EVP_DecryptUpdate_proxy")
extern int EVP_DecryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *outm , int *outl ) ;
#pragma cilnoremove("EVP_DecryptFinal_proxy")

// undocumented
extern EVP_PKEY *EVP_PKEY_new_mac_key_proxy(int type , ENGINE *e , unsigned char *key ,
                                            int keylen ) ;
#pragma cilnoremove("EVP_PKEY_new_mac_key_proxy")

// done
extern int EVP_DigestSignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *sigret , size_t *siglen ) ;
#pragma cilnoremove("EVP_DigestSignFinal_proxy")

// Read a certificate in PEM format from a BIO:
extern X509 *PEM_read_bio_X509_proxy(BIO *bp , X509 **x , pem_password_cb *cb , void *u ) ;
#pragma cilnoremove("PEM_read_bio_X509_proxy")

extern EVP_CIPHER const   *EVP_get_cipherbyname_proxy(char const   *name ) ;
#pragma cilnoremove("EVP_get_cipherbyname_proxy")


extern EVP_CIPHER const   *EVP_enc_null_proxy(void) ;
#pragma cilnoremove("EVP_enc_null_proxy")

// d2i_X509_bio() is similar to d2i_X509() except it attempts to parse data from BIO bp.
extern X509 *d2i_X509_bio_proxy(BIO *bp , X509 **x509 ) ;
#pragma cilnoremove("d2i_X509_bio_proxy")


// undocumented
extern int EVP_PKEY_assign_proxy(EVP_PKEY *pkey , int type , void *key ) ;
#pragma cilnoremove("EVP_PKEY_assign_proxy")

// The main purpose of the functions EVP_PKEY_missing_parameters() and EVP_PKEY_copy_parameters()
// is to handle public keys in certificates where the parameters are sometimes omitted from a public key
// if they are inherited from the CA that signed it.
extern int EVP_PKEY_copy_parameters_proxy(EVP_PKEY *to , EVP_PKEY const   *from ) ;
#pragma cilnoremove("EVP_PKEY_copy_parameters_proxy")


extern EVP_PKEY *PEM_read_bio_PrivateKey_proxy(BIO *bp , EVP_PKEY **x , pem_password_cb *cb ,
                                               void *u ) ;
#pragma cilnoremove("PEM_read_bio_PrivateKey_proxy")

// undocumented
extern EVP_PKEY *d2i_PrivateKey_bio_proxy(BIO *bp , EVP_PKEY **a ) ;
#pragma cilnoremove("d2i_PrivateKey_bio_proxy")

// undocumented
extern EVP_PKEY *d2i_PrivateKey_proxy(int type , EVP_PKEY **a , unsigned char const   **pp ,
                                      long length ) ;
#pragma cilnoremove("d2i_PrivateKey_proxy")


extern EVP_CIPHER const   *EVP_des_cbc_proxy(void) ;
#pragma cilnoremove("EVP_des_cbc_proxy")
extern EVP_CIPHER const   *EVP_des_ede3_cbc_proxy(void) ;
#pragma cilnoremove("EVP_des_ede3_cbc_proxy")
// extern EVP_CIPHER const   *EVP_idea_cbc_proxy(void) ;
// #pragma cilnoremove("EVP_idea_cbc_proxy")
extern EVP_CIPHER const   *EVP_rc4_proxy(void) ;
#pragma cilnoremove("EVP_rc4_proxy")
extern EVP_CIPHER const   *EVP_rc2_cbc_proxy(void) ;
#pragma cilnoremove("EVP_rc2_cbc_proxy")
extern EVP_CIPHER const   *EVP_aes_192_cbc_proxy(void) ;
#pragma cilnoremove("EVP_aes_192_cbc_proxy")
extern EVP_CIPHER const   *EVP_aes_256_cbc_proxy(void) ;
#pragma cilnoremove("EVP_aes_256_cbc_proxy")
extern EVP_CIPHER const   *EVP_camellia_128_cbc_proxy(void) ;
#pragma cilnoremove("EVP_camellia_128_cbc_proxy")
extern EVP_CIPHER const   *EVP_camellia_256_cbc_proxy(void) ;
#pragma cilnoremove("EVP_camellia_256_cbc_proxy")
extern EVP_CIPHER const   *EVP_seed_cbc_proxy(void) ;
#pragma cilnoremove("EVP_seed_cbc_proxy")

extern int RAND_bytes_proxy(unsigned char *buf , int num ) ;
#pragma cilnoremove("RAND_bytes_proxy")

extern int RAND_pseudo_bytes_proxy(unsigned char *buf , int num ) ;
#pragma cilnoremove("RAND_pseudo_bytes_proxy")


extern RSA *d2i_RSAPrivateKey_bio_proxy(BIO *bp , RSA **rsa ) ;
#pragma cilnoremove("d2i_RSAPrivateKey_bio_proxy")

extern RSA *PEM_read_bio_RSAPrivateKey_proxy(BIO *bp , RSA **x , pem_password_cb *cb ,
                                             void *u ) ;
#pragma cilnoremove("PEM_read_bio_RSAPrivateKey_proxy")

extern RSA *d2i_RSAPrivateKey_proxy(RSA **a , unsigned char const   **in , long len ) ;
#pragma cilnoremove("d2i_RSAPrivateKey_proxy")

extern void tls1_PRF(long digest_mask,
		     const void *seed1, int seed1_len,
		     const void *seed2, int seed2_len,
		     const void *seed3, int seed3_len,
		     const void *seed4, int seed4_len,
		     const void *seed5, int seed5_len,
		     const unsigned char *sec, int slen,
		     unsigned char *out1,
		     unsigned char *out2, int olen);

extern void tls1_PRF_proxy(long digest_mask,
		     const void *seed1, int seed1_len,
		     const void *seed2, int seed2_len,
		     const void *seed3, int seed3_len,
		     const void *seed4, int seed4_len,
		     const void *seed5, int seed5_len,
		     const unsigned char *sec, int slen,
		     unsigned char *out1,
		     unsigned char *out2, int olen);
#pragma cilnoremove("tls1_PRF_proxy")

extern void tls1_P_hash(const EVP_MD *md, const unsigned char *sec,
			int sec_len,
			const void *seed1, int seed1_len,
			const void *seed2, int seed2_len,
			const void *seed3, int seed3_len,
			const void *seed4, int seed4_len,
			const void *seed5, int seed5_len,
			unsigned char *out, int olen);

extern void tls1_P_hash_proxy(const EVP_MD *md, const unsigned char *sec,
			int sec_len,
			const void *seed1, int seed1_len,
			const void *seed2, int seed2_len,
			const void *seed3, int seed3_len,
			const void *seed4, int seed4_len,
			const void *seed5, int seed5_len,
			unsigned char *out, int olen);
#pragma cilnoremove("tls1_P_hash_proxy")

extern int tls1_generate_master_secret(SSL *s, unsigned char *out, unsigned char *p,
	     int len);
extern int tls1_generate_master_secret_proxy(SSL *s, unsigned char *out, unsigned char *p,
	     int len);
#pragma cilnoremove("tls1_generate_master_secret_proxy")

// extern int BUF_MEM_grow_clean_proxy(BUF_MEM *str , size_t len ) ;
// #pragma cilnoremove("BUF_MEM_grow_clean_proxy")

// undocumented
extern int ENGINE_load_ssl_client_cert_proxy(ENGINE *e , SSL *s , struct stack_st_X509_NAME *ca_dn ,
                                             X509 **pcert , EVP_PKEY **ppkey , struct stack_st_X509 **pother ,
                                             UI_METHOD *ui_method , void *callback_data ) ;
#pragma cilnoremove("ENGINE_load_ssl_client_cert_proxy")

////////////////////////////////////////////
// EVP_PKEY_CTX was only introduced in 1.0.0
////////////////////////////////////////////

// The EVP_PKEY_derive_set_peer() function sets the peer key: this will normally be a public key.
extern int EVP_PKEY_derive_set_peer_proxy(EVP_PKEY_CTX *ctx , EVP_PKEY *peer ) ;
#pragma cilnoremove("EVP_PKEY_derive_set_peer_proxy")

/*
 * The EVP_PKEY_decrypt() function performs a public key decryption operation using ctx.
 * The data to be decrypted is specified using the in and inlen parameters.
 * If out is NULL then the maximum size of the output buffer is written to the outlen parameter.
 * If out is not NULL then before the call the outlen parameter should contain the length of the out buffer,
 * if the call is successful the decrypted data is written to out and the amount of data written to outlen.
 */
extern int EVP_PKEY_decrypt_proxy(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                                  unsigned char const   *in , size_t inlen ) ;
#pragma cilnoremove("EVP_PKEY_decrypt_proxy")

// TODO
extern int EVP_PKEY_CTX_ctrl_proxy(EVP_PKEY_CTX *ctx , int keytype , int optype ,
                                   int cmd , int p1 , void *p2 ) ;
#pragma cilnoremove("EVP_PKEY_CTX_ctrl_proxy")

/*
 * The EVP_PKEY_verify() function performs a public key verification operation using ctx.
 * The signature is specified using the sig and siglen parameters.
 * The verified data (i.e. the data believed originally signed) is specified
 * using the tbs and tbslen parameters.
 */
extern int EVP_PKEY_verify_proxy(EVP_PKEY_CTX *ctx , unsigned char const   *sig ,
                                 size_t siglen , unsigned char const   *tbs , size_t tbslen ) ;
#pragma cilnoremove("EVP_PKEY_verify_proxy")

/*
 * The EVP_PKEY_encrypt() function performs a public key encryption operation using ctx.
 * The data to be encrypted is specified using the in and inlen parameters.
 * If out is NULL then the maximum size of the output buffer is written to the outlen parameter.
 * If out is not NULL then before the call the outlen parameter should contain the length of the out buffer,
 * if the call is successful the encrypted data is written to out and the amount of data written to outlen.
 */
extern int EVP_PKEY_encrypt_proxy(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                                  unsigned char const   *in , size_t inlen ) ;
#pragma cilnoremove("EVP_PKEY_encrypt_proxy")

/*
 * The EVP_PKEY_sign() function performs a public key signing operation using ctx.
 * The data to be signed is specified using the tbs and tbslen parameters.
 * If sig is NULL then the maximum size of the output buffer is written to the siglen parameter.
 * If sig is not NULL then before the call the siglen parameter should contain the length of the sig buffer,
 * if the call is successful the signature is written to sig and the amount of data written to siglen.
 *
 */
extern int EVP_PKEY_sign_proxy(EVP_PKEY_CTX *ctx , unsigned char *sig , size_t *siglen ,
                               unsigned char const   *tbs , size_t tbslen ) ;
#pragma cilnoremove("EVP_PKEY_sign_proxy")

// done
extern int EVP_DigestSignInit_proxy(EVP_MD_CTX *ctx , EVP_PKEY_CTX **pctx , EVP_MD const   *type ,
                                    ENGINE *e , EVP_PKEY *pkey ) ;
#pragma cilnoremove("EVP_DigestSignInit_proxy")

/*
 * The EVP_PKEY_CTX_new() function allocates public key algorithm context
 * using the algorithm specified in pkey and ENGINE e.
 */
extern EVP_PKEY_CTX *EVP_PKEY_CTX_new_proxy(EVP_PKEY *pkey , ENGINE *e ) ;
#pragma cilnoremove("EVP_PKEY_CTX_new_proxy")

extern int SHA256_Init_proxy(SHA256_CTX *c ) ;

extern int SHA256_Update_proxy(SHA256_CTX *c , void const   *data , size_t len ) ;

extern int SHA256_Final_proxy(unsigned char *md , SHA256_CTX *c ) ;

extern DSA_SIG *dsa_do_sign(unsigned char const   *dgst , int dlen , DSA *dsa ) ;

extern DSA_SIG *dsa_do_sign_proxy(unsigned char const   *dgst , int dlen , DSA *dsa ) ;

extern int dsa_do_verify(unsigned char const   *dgst , int dgst_len , DSA_SIG *sig ,
                               DSA *dsa ) ;

extern int dsa_do_verify_proxy(unsigned char const   *dgst , int dgst_len , DSA_SIG *sig ,
                               DSA *dsa ) ;

extern int DSA_generate_key_proxy(DSA *dsa ) ;

extern int BN_set_word_proxy(BIGNUM *a, unsigned long w);

extern int BN_mod_exp2_mont_proxy(BIGNUM *rr , BIGNUM const   *a1 ,
                                  BIGNUM const   *p1 , BIGNUM const   *a2 ,
                                  BIGNUM const   *p2 , BIGNUM const   *m ,
                                  BN_CTX *ctx , BN_MONT_CTX *in_mont ) ;

extern int BN_mod_exp_mont_proxy(BIGNUM *rr , BIGNUM const   *a ,
                                 BIGNUM const   *p , BIGNUM const   *m ,
                                 BN_CTX *ctx , BN_MONT_CTX *in_mont ) ;


////////////////////////////////////////////
// DES
////////////////////////////////////////////

extern void DES_ecb3_encrypt_proxy(const_DES_cblock *input , DES_cblock *output ,
                                   DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                   DES_key_schedule *ks3 , int enc ) ;

extern void DES_ncbc_encrypt_proxy(unsigned char const   *input , unsigned char *output ,
                                   long length , DES_key_schedule *schedule , DES_cblock *ivec ,
                                   int enc ) ;

extern void DES_ecb_encrypt_proxy(const_DES_cblock *input , DES_cblock *output , DES_key_schedule *ks ,
                                  int enc ) ;

extern void DES_ede3_cbc_encrypt_proxy(unsigned char const   *input , unsigned char *output ,
                                       long length , DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                       DES_key_schedule *ks3 , DES_cblock *ivec ,
                                       int enc ) ;

extern void DES_set_key_unchecked_proxy(const_DES_cblock *key , DES_key_schedule *schedule ) ;


////////////////////////////////////////////
// AES
////////////////////////////////////////////

extern int AES_set_encrypt_key_proxy(unsigned char const   *userKey , int bits , AES_KEY *key ) ;

extern int AES_set_decrypt_key_proxy(unsigned char const   *userKey , int bits , AES_KEY *key ) ;

extern void AES_ecb_encrypt_proxy(unsigned char const   *in , unsigned char *out ,
                                  AES_KEY const   *key , int enc ) ;

extern void AES_cbc_encrypt_proxy(unsigned char const   *in , unsigned char *out ,
                                  size_t length , AES_KEY const   *key , unsigned char *ivec ,
                                  int enc ) ;

////////////////////////////////////////////
// RSA
////////////////////////////////////////////


#pragma cilnoremove("RSA_generate_key_proxy")
extern RSA *RSA_generate_key_proxy(int bits , unsigned long e , void (*callback)(int  ,
                                                                                 int  ,
                                                                                 void * ) ,
                                   void *cb_arg ) ;


extern RSA *RSAPrivateKey_dup_proxy(RSA *rsa ) ;
#pragma cilnoremove("RSAPrivateKey_dup_proxy")

extern int RSA_verify_proxy(int type , unsigned char const   *m , unsigned int m_length ,
                            unsigned char const   *sigbuf , unsigned int siglen ,
                            RSA *rsa ) ;
#pragma cilnoremove("RSA_verify_proxy")

extern int RSA_public_encrypt_proxy(int flen , unsigned char const   *from , unsigned char *to ,
                                    RSA *rsa , int padding ) ;
#pragma cilnoremove("RSA_public_encrypt_proxy")

extern int RSA_private_decrypt_proxy(int flen , unsigned char const   *from , unsigned char *to ,
                                     RSA *rsa , int padding ) ;
#pragma cilnoremove("RSA_private_decrypt_proxy")

extern int RSA_sign_proxy(int type , unsigned char const   *m , unsigned int m_length ,
                          unsigned char *sigret , unsigned int *siglen , RSA *rsa ) ;
#pragma cilnoremove("RSA_sign_proxy")

extern void RSA_blinding_off_proxy(RSA *rsa ) ;



////////////////////////////////////////////
// stack_st_X509 was just STACK before 1.0.0
////////////////////////////////////////////

// undocumented
extern int X509_STORE_CTX_init_proxy(X509_STORE_CTX *ctx , X509_STORE *store , X509 *x509 ,
                                     struct stack_st_X509 *chain ) ;
#pragma cilnoremove("X509_STORE_CTX_init_proxy")

#endif /* OPENSSL_PROXIES_H */
