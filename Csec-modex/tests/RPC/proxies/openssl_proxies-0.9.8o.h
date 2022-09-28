
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

extern int RAND_pseudo_bytes_proxy(unsigned char *buf , int num ) ;

extern int i2d_X509_proxy(X509 *a , unsigned char **out ) ;

extern X509 *d2i_X509_proxy(X509 **a , unsigned char const   **in , long len ) ;

extern int EVP_DigestInit_ex_proxy(EVP_MD_CTX *ctx , EVP_MD const   *type , ENGINE *impl ) ;

extern int EVP_DigestUpdate_proxy(EVP_MD_CTX *ctx , void const   *d , size_t cnt ) ;

extern EVP_PKEY *X509_get_pubkey_proxy(X509 *x ) ;

extern int EVP_VerifyFinal_proxy(EVP_MD_CTX *ctx , unsigned char const   *sigbuf ,
                                 unsigned int siglen , EVP_PKEY *pkey ) ;

extern int RSA_private_decrypt_proxy(int flen , unsigned char const   *from , unsigned char *to ,
                                     RSA *rsa , int padding ) ;

extern int RAND_bytes_proxy(unsigned char *buf , int num ) ;

extern int EVP_SignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ,
                               EVP_PKEY *pkey ) ;

extern int RSA_public_encrypt_proxy(int flen , unsigned char const   *from , unsigned char *to ,
                                    RSA *rsa , int padding ) ;

extern EVP_MD const   *EVP_md5_proxy(void) ;

extern int EVP_DigestFinal_ex_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ) ;

extern int EVP_EncryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const   *cipher ,
                                    ENGINE *impl , unsigned char const   *key , unsigned char const   *iv ) ;

extern int EVP_DecryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const   *cipher ,
                                    ENGINE *impl , unsigned char const   *key , unsigned char const   *iv ) ;

extern int EVP_Cipher_proxy(EVP_CIPHER_CTX *c , unsigned char *out , unsigned char const   *in ,
                            unsigned int inl ) ;

extern int BIO_read_proxy(BIO *b , void *data , int len ) ;

extern int BIO_write_proxy(BIO *b , void const   *data , int len ) ;

extern void EVP_MD_CTX_set_flags_proxy(EVP_MD_CTX *ctx , int flags ) ;

extern int RSA_sign_proxy(int type , unsigned char const   *m , unsigned int m_length ,
                          unsigned char *sigret , unsigned int *siglen , RSA *rsa ) ;

extern EVP_MD const   *EVP_dss1_proxy(void) ;

extern EVP_MD const   *EVP_ecdsa_proxy(void) ;

extern int X509_certificate_type_proxy(X509 *x , EVP_PKEY *pubkey ) ;

extern int RSA_verify_proxy(int type , unsigned char const   *m , unsigned int m_length ,
                            unsigned char *sigbuf , unsigned int siglen , RSA *rsa ) ;

extern EVP_CIPHER const   *EVP_aes_128_cbc_proxy(void) ;

extern EVP_MD const   *EVP_sha256_proxy(void) ;

extern void HMAC_Init_ex_proxy(HMAC_CTX *ctx , void const   *key , int len , EVP_MD const   *md ,
                               ENGINE *impl ) ;

extern int EVP_EncryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const   *in , int inl ) ;

extern int EVP_EncryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ) ;

extern void HMAC_Update_proxy(HMAC_CTX *ctx , unsigned char const   *data , size_t len ) ;

extern void HMAC_Final_proxy(HMAC_CTX *ctx , unsigned char *md , unsigned int *len ) ;

extern int check_srvr_ecc_cert_and_alg_proxy(X509 *x , SSL_CIPHER *cs ) ;

extern int ENGINE_load_ssl_client_cert_proxy(ENGINE *e , SSL *s , STACK *ca_dn , X509 **pcert ,
                                             EVP_PKEY **ppkey , STACK **pother , UI_METHOD *ui_method ,
                                             void *callback_data ) ;

extern int ssl3_final_finish_mac_proxy(SSL *s , EVP_MD_CTX *ctx1 , EVP_MD_CTX *ctx2 ,
                                       char const   *sender , int slen , unsigned char *p ) ;

extern int ssl3_cert_verify_mac_proxy(SSL *s , EVP_MD_CTX *in , unsigned char *p ) ;

extern RSA *RSAPrivateKey_dup_proxy(RSA *rsa ) ;

extern EVP_MD const   *EVP_sha1_proxy(void) ;

extern int EVP_CipherInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const   *cipher ,
                                   ENGINE *impl , unsigned char const   *key , unsigned char const   *iv ,
                                   int enc ) ;

extern int ssl3_handshake_mac_proxy(SSL *s , EVP_MD_CTX *in_ctx , char const   *sender ,
                                    int len , unsigned char *p ) ;

extern int EVP_MD_CTX_copy_ex_proxy(EVP_MD_CTX *out , EVP_MD_CTX const   *in ) ;

extern EVP_MD const   *EVP_MD_CTX_md_proxy(EVP_MD_CTX const   *ctx ) ;

extern int X509_STORE_CTX_init_proxy(X509_STORE_CTX *ctx , X509_STORE *store , X509 *x509 ,
                                     STACK *chain ) ;

extern X509_NAME *X509_get_issuer_name_proxy(X509 *a ) ;

extern int tls1_final_finish_mac_proxy(SSL *s , EVP_MD_CTX *in1_ctx , EVP_MD_CTX *in2_ctx ,
                                       char const   *str , int slen , unsigned char *p ) ;

extern int tls1_cert_verify_mac_proxy(SSL *s , EVP_MD_CTX *in , unsigned char *p ) ;

extern int EVP_DecryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const   *in , int inl ) ;

extern int EVP_DecryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *outm , int *outl ) ;

extern void HMAC_CTX_set_flags_proxy(HMAC_CTX *ctx , unsigned long flags ) ;

extern void tls1_P_hash_proxy(EVP_MD const   *md , unsigned char const   *sec , int sec_len ,
                              unsigned char *seed , int seed_len , unsigned char *out ,
                              int olen ) ;

extern void tls1_PRF_proxy(EVP_MD const   *md5 , EVP_MD const   *sha1 , unsigned char *label ,
                           int label_len , unsigned char const   *sec , int slen ,
                           unsigned char *out1 , unsigned char *out2 , int olen ) ;

extern X509 *PEM_read_bio_X509_proxy(BIO *bp , X509 **x , pem_password_cb *cb , void *u ) ;

extern EVP_CIPHER const   *EVP_get_cipherbyname_proxy(char const   *name ) ;

extern EVP_CIPHER const   *EVP_enc_null_proxy(void) ;

extern X509 *d2i_X509_bio_proxy(BIO *bp , X509 **x509 ) ;

extern int EVP_PKEY_assign_proxy(EVP_PKEY *pkey , int type , char *key ) ;

extern int EVP_PKEY_copy_parameters_proxy(EVP_PKEY *to , EVP_PKEY const   *from ) ;

extern RSA *d2i_RSAPrivateKey_bio_proxy(BIO *bp , RSA **rsa ) ;

extern RSA *PEM_read_bio_RSAPrivateKey_proxy(BIO *bp , RSA **x , pem_password_cb *cb ,
                                             void *u ) ;

extern RSA *d2i_RSAPrivateKey_proxy(RSA **a , unsigned char const   **in , long len ) ;

extern EVP_PKEY *PEM_read_bio_PrivateKey_proxy(BIO *bp , EVP_PKEY **x , pem_password_cb *cb ,
                                               void *u ) ;

extern EVP_PKEY *d2i_PrivateKey_bio_proxy(BIO *bp , EVP_PKEY **a ) ;

extern EVP_PKEY *d2i_PrivateKey_proxy(int type , EVP_PKEY **a , unsigned char const   **pp ,
                                      long length ) ;

extern EVP_CIPHER const   *EVP_des_cbc_proxy(void) ;

extern EVP_CIPHER const   *EVP_des_ede3_cbc_proxy(void) ;

extern EVP_CIPHER const   *EVP_idea_cbc_proxy(void) ;

extern EVP_CIPHER const   *EVP_rc4_proxy(void) ;

extern EVP_CIPHER const   *EVP_rc2_cbc_proxy(void) ;

extern EVP_CIPHER const   *EVP_aes_192_cbc_proxy(void) ;

extern EVP_CIPHER const   *EVP_aes_256_cbc_proxy(void) ;

extern EVP_MD const   *EVP_get_digestbyname_proxy(char const   *name ) ;

extern EVP_MD const   *EVP_md2_proxy(void) ;

extern int BN_num_bytes_proxy(BIGNUM const *a);

extern BIGNUM *BN_bin2bn_proxy(unsigned char const   *s , int len , BIGNUM *ret ) ;

extern int BN_bn2bin_proxy(BIGNUM const   *a , unsigned char *to ) ;

extern int BN_mod_exp_proxy(BIGNUM *r , BIGNUM const   *a , BIGNUM const   *p , BIGNUM const   *m ,
                            BN_CTX *ctx ) ;

extern int BN_hex2bn_proxy(BIGNUM **a , char const   *str ) ;

extern char *BN_bn2hex_proxy(BIGNUM const   *a ) ;

extern unsigned long lh_strhash_proxy(char const   *c ) ;

#endif /* OPENSSL_PROXIES_H */
