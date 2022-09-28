
// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.


/*
 * Attributes:
 * =============
 *
 * EVP_CIPHER: type
 *
 * EVP_CIPHER_CTX: type, key, use (encrypt or decrypt), enc_in, enc_out, dec_in, dec_out, seed
 *
 * EVP_MD_CTX: type, msg, key, use
 *
 * EVP_MD: type
 *
 * EVP_PKEY: id, key (set in EVP_PKEY_new_mac_key)
 *
 * EVP_PKEY_CTX: key, peerkey
 *
 * HMAC_CTX: type, key, msg
 *
 * X509: id
 *
 * RSA: id
 *
 * BIO: mem
 *
 * BIGNUM: val (no length - can't keep track of it)
 *
 * SHA256_CTX: msg
 *
 * DSA: pkey, skey, keyseed
 *
 * DSA_SIG: sig
 * DSA_SIG.r: val
 * DSA_SIG.s: val
 *
 * Hints:
 * ======
 *
 * plain, enc, dec, penc, pdec, hash, key, rsa_key, sig, cert,
 * partial_plain, partial_enc
 * plus those I formerly called symbol parameters
 *
 */

#include "system_proxies.h"
#include "openssl_proxies.h"

// for undefining the BN_num_bytes
#include "common.h"
#include "interface.h"

/************************************
 * Proxy Functions
 ************************************/


int EVP_Cipher_proxy(EVP_CIPHER_CTX *ctx, unsigned char *out, const unsigned char *in, unsigned int inl)
{
  load_ctx(ctx, "type", "type");
  load_buf(in, inl, "plain");
  load_ctx(ctx, "key", "key");
  // FIXME: output the IV as well!
  SymN("EVP_Cipher", 3);
  Hint("enc");
  assume_len(&inl, false, sizeof(inl));
  Nondet();

  int ret = EVP_Cipher(ctx, out, in, inl);

  // for both stream and block ciphers the ciphertext is as long as the plaintext
  // FIXME: what about the IV? It's generated from the master secret on both sides?
  store_buf(out);

  return ret;
}

extern BIO *BIO_pop_proxy(BIO *a )
{
  mute();
  BIO * ret = BIO_pop(a);
  unmute();

  // Let the attacker decide what this function returns.
  fresh_ptr(sizeof(*ret));
  store_buf(&ret);
  input("BIO_pop_result", sizeof(*ret));
  store_buf(ret);

  return ret;
}

extern int BIO_free_proxy(BIO *a )
{
  mute();
  int ret = BIO_free(a);
  unmute();

  // Let the attacker decide decide the result
  input("BIO_free_result", sizeof(ret));
  store_buf(&ret);

  return ret;
}

int BIO_write_proxy(BIO *b, const void *in, int inl)
{
  mute();
  int ret = BIO_write(b, in, inl);
  unmute();

  int cond = 0;

  mute();
  cond = BIO_find_type(b, BIO_TYPE_MEM) != NULL;
  unmute();

  // FIXME: assuming we have written all out, not always true
  // In fact this can lead to a crash on the concrete level, so do something about it.
  ret = inl;

  // are we writing to memory?
  // FIXME: this is still very crude
  if(cond)
  {
    // FIXME: this doesn't work, because the buffer is set in some deeper BIO
    // set_attr_buf(b, "mem", in, inl);
    return ret;
  }
  else
  {
    load_buf((unsigned char*) in, inl, "msg");
    output();

    return ret;
  }
}

int BIO_read_proxy(BIO *b, void *out, int outl)
{
  mute();
  int ret = BIO_read(b, out, outl);
  unmute();

  // FIXME: should check: are we reading from memory?

  // FIXME: making the assumption that read always returns as much as requested, not true of course
  ret = outl;

  // FIXME: switch to this when going over to multiple paths:
  // symL("net_len");
  // store_buf((void*) &ret, sizeof(ret), "read_len");
  // if(ret < 0) error("BIO_read: ret is negative");
  // if(ret > outl) error("BIO_read: ret > outl");
  // if((int) *len != *len) error("make_sym: len doesn't fit into int: %s", s);

  // if(outl < 0) error("BIO_read: outl < 0");

  input("msg", ret);
  store_buf((unsigned char*) out);

  return ret;
}

extern BIO *BIO_new_connect_proxy(char *host_port )
{
  mute();
  BIO * ret = BIO_new_connect(host_port);
  unmute();

  // Let the attacker decide what this function returns.
  fresh_ptr(sizeof(*ret));
  store_buf(&ret);
  input("BIO_new_connect_result", sizeof(*ret));
  store_buf(ret);

  return ret;
}

extern BIO *BIO_new_accept_proxy(char *host_port )
{
  mute();
  BIO * ret = BIO_new_accept(host_port);
  unmute();

  // Let the attacker decide what this function returns.
  fresh_ptr(sizeof(*ret));
  store_buf(&ret);
  input("BIO_new_accept_result", sizeof(*ret));
  store_buf(ret);

  return ret;
}

extern long BIO_ctrl_proxy(BIO *bp , int cmd , long larg , void *parg )
{
  mute();
  long ret = BIO_ctrl(bp, cmd, larg, parg);
  unmute();

  // Let the attacker decide the result
  input("BIO_ctrl_result", sizeof(ret));
  store_buf(&ret);

  // Some BIO_ctrl calls may leak more information to the attacker,
  // but the API is too complex, so I can't be bothered figuring out.

  return ret;
}

//extern long BIO_ctrl_proxy(BIO *bp , int cmd , long larg , void *parg )
//{
//  long ret = BIO_ctrl(bp, cmd, larg, parg);
//
//  // FIXME: trying to recognize whether it is BIO_get_mem_data
//  if((cmd == BIO_CTRL_INFO) && (larg == 0))
//  {
//    load_ctx(bp, "mem", "");
//    store_buf(parg, ret, "");
//  }
//
//  return ret;
//}

int EVP_DigestInit_proxy(EVP_MD_CTX *ctx , EVP_MD const   *type )
{
  copy_attr(ctx, type, "type");
  set_attr_str(ctx, "msg", "");

  return EVP_DigestInit(ctx , type);
}

int EVP_DigestInit_ex_proxy(EVP_MD_CTX *ctx , EVP_MD const   *type ,
                             ENGINE *impl )
{
  copy_attr(ctx, type, "type");
  set_attr_str(ctx, "msg", "");

  return EVP_DigestInit_ex(ctx , type, impl);
}

int EVP_DigestUpdate_proxy(EVP_MD_CTX *ctx , void const   *d , size_t cnt )
{
  add_to_attr(ctx, "msg", (unsigned char *) d, cnt);

  int ret = EVP_DigestUpdate(ctx, d, cnt);

  return ret;
}

/*
 * EVP_VerifyFinal() verifies the data in ctx using the public key pkey
 * and against the siglen bytes at sigbuf.
 */
int EVP_VerifyFinal_proxy(EVP_MD_CTX *ctx , unsigned char const   *sigbuf ,
                           unsigned int siglen , EVP_PKEY *pkey )
{
  load_ctx(ctx, "msg", "msg");
  load_ctx(pkey, "id", "pkey");

  int ret = EVP_VerifyFinal(ctx, sigbuf, siglen, pkey);

  SymN("EVP_VerifyFinal", 2);
  Hint("sig");
  assume_len(&siglen, false, sizeof(siglen));

  store_buf(sigbuf);

  return ret;
}

/*
 * EVP_SignFinal() signs the data in ctx using the private key pkey and places the signature in sig.
 * The number of bytes of data written (i.e. the length of the signature) will be written to the integer at s,
 * at most EVP_PKEY_size(pkey) bytes will be written.
 */
int EVP_SignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ,
                         EVP_PKEY *pkey )
{
  load_ctx(ctx, "msg", "msg");
  load_ctx(pkey, "id", "pkey");

  int ret = EVP_SignFinal(ctx, md, s, pkey);

  // FIXME: relying on concrete value of s?
  SymN("EVP_SignFinal", 2);
  Hint("sig");
  assume_len(s, false, sizeof(*s));
  Nondet();

  store_buf(md);

  return ret;
}

int EVP_DigestFinal_ex_proxy(EVP_MD_CTX *ctx , unsigned char *md ,
                              unsigned int *s )
{
  load_ctx(ctx, "type", "type");
  load_ctx(ctx, "msg", "msg");

  int ret = EVP_DigestFinal_ex(ctx, md, s);

  // FIXME: relying on concrete value of s?
  SymN("EVP_DigestFinal_ex", 2);
  Hint(2);
  assume_len(s, false, sizeof(*s));
  Nondet();

  store_buf(md);

  return ret;
}

/*
 * EVP_MD_CTX_copy_ex() can be used to copy the message digest state from in to out.
 */
int EVP_MD_CTX_copy_proxy(EVP_MD_CTX *out , EVP_MD_CTX const   *in )
{
  copy_ctx(out, in);

  return EVP_MD_CTX_copy(out, in);
}

int EVP_MD_CTX_copy_ex_proxy(EVP_MD_CTX *out , EVP_MD_CTX const   *in )
{
  copy_ctx(out, in);

  return EVP_MD_CTX_copy_ex(out, in);
}


EVP_MD const *EVP_MD_CTX_md_proxy(EVP_MD_CTX const   *ctx )
{
  EVP_MD const * ret = EVP_MD_CTX_md(ctx);

  copy_attr(ret, ctx, "type");

  return ret;
}

#if OPENSSL_MAJOR == 0
  void EVP_MD_CTX_set_flags_proxy(EVP_MD_CTX *ctx , int flags )
  {
    EVP_MD_CTX_set_flags(ctx, flags);
  }

#endif

#if OPENSSL_MAJOR == 1
  int EVP_DigestSignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *sigret,
                                 size_t *siglen )
  {
    int ret = EVP_DigestSignFinal(ctx, sigret, siglen);

    load_ctx(ctx, "type", "type");
    load_ctx(ctx, "msg", "msg");
    load_ctx(ctx, "key", "key");
    SymN("EVP_DigestSign", 3);
    Hint("sig");
    assume_len(siglen, false, sizeof(*siglen));
    Nondet();
    store_buf(sigret);

    return ret;
  }
#endif

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
extern int i2d_X509_proxy(X509 *a , unsigned char **out )
{
  // FIXME: do as in DSA
  int notnull = (out != NULL) && (*out != NULL);

  int ret = i2d_X509(a, out);

  if(out != NULL)
  {
    load_ctx(a, "id", "cert");

    SymN("i2d_X509", 1);
    Hint("DER");
    assume_len(&ret, true, sizeof(ret));

    if(notnull)
      store_buf(*out - ret);
    else
      store_buf(*out);

  }

  return ret;
}

/*
 * d2i_X509() attempts to decode len bytes at *in.
 * If successful a pointer to the X509 structure is returned.
 * If an error occurred then NULL is returned.
 * If px is not NULL then the returned structure is written to *px.
 * If *px is not NULL then it is assumed that *px contains a valid X509 structure
 * and an attempt is made to reuse it.
 * If the call is successful *in is incremented to the byte following the parsed data.
 */
extern X509 *d2i_X509_proxy(X509 **a , unsigned char const   **in , long len )
{
  unsigned char const * oldin = *in;

  X509 * ret = d2i_X509(a, in, len);

  if(ret != NULL)
  {
    load_buf(oldin, len, "DER");

    SymN("d2i_X509", 1);
    Hint("cert");

    store_ctx(ret, "id");
  }

  return ret;
}

// undocumented
extern EVP_PKEY *X509_get_pubkey_proxy(X509 *x )
{
  EVP_PKEY * ret = X509_get_pubkey(x);

  load_ctx(x, "id", "X509");

  SymN("X509_get_pubkey", 1);
  Hint("pkey");

  store_ctx(ret, "id");

  // fight the abstraction breaking in ssl lib:
  copy_ctx(ret->pkey.ptr, ret);

  return ret;
}

#if OPENSSL_MAJOR == 0
  extern X509_NAME *X509_get_issuer_name_proxy(X509 *a )
  {
    return X509_get_issuer_name(a);
  }
#endif

/*
 * EVP_get_digestbyname(), EVP_get_digestbynid() and EVP_get_digestbyobj()
 * return an EVP_MD structure when passed a digest name,
 * a digest NID or an ASN1_OBJECT structure respectively.
 * The digest table must be initialized using, for example, OpenSSL_add_all_digests() for these functions to work.
 */
EVP_MD const   *EVP_get_digestbyname_proxy(char const   *name )
{
  EVP_MD const * ret = EVP_get_digestbyname(name);

  set_attr_str(ret, "type", name);

  return ret;
}


/*
 * EVP_md2(), EVP_md5(), EVP_sha(), EVP_sha1(), EVP_mdc2() and EVP_ripemd160()
 * return EVP_MD structures for the MD2, MD5, SHA, SHA1, MDC2 and RIPEMD160
 * digest algorithms respectively. The associated signature algorithm is RSA in each case.
 */
extern EVP_MD const   *EVP_md5_proxy(void)
{
  EVP_MD const * ret = EVP_md5();

  set_attr_str(ret, "type", "md5");

  return ret;
}

#if OPENSSL_MAJOR == 0
extern EVP_MD const   *EVP_md2_proxy(void)
{
  EVP_MD const * ret = EVP_md2();

  set_attr_str(ret, "type", "md2");

  return ret;
}
#endif

extern EVP_MD const   *EVP_sha1_proxy(void)
{
  EVP_MD const * ret;

  mute();
  ret = EVP_sha1();
  unmute();

  fresh_ptr(sizeof(*ret));
  store_buf(&ret);

  set_attr_str(ret, "type", "sha1");

  return ret;
}

/*
 * EVP_dss() and EVP_dss1() return EVP_MD structures for
 * SHA and SHA1 digest algorithms but using DSS (DSA) for the signature algorithm.
 */
extern EVP_MD const   *EVP_dss1_proxy(void)
{
  EVP_MD const * ret = EVP_dss1();

  set_attr_str(ret, "type", "dss1");

  return ret;
}

// undocumented
extern EVP_MD const   *EVP_ecdsa_proxy(void)
{
  EVP_MD const * ret = EVP_ecdsa();

  set_attr_str(ret, "type", "ecdsa");

  return ret;
}

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
                                    ENGINE *impl , unsigned char const   *key , unsigned char const   *iv )
{
  if(cipher != NULL)
    copy_attr(ctx, cipher, "type");
  if(key != NULL)
    set_attr_buf(ctx, "key", key, EVP_CIPHER_CTX_key_length(ctx));

  if(iv != NULL)
    set_attr_buf(ctx, "seed", iv, EVP_CIPHER_CTX_iv_length(ctx));
  else
    // Where is the randomness coming from if there's no IV?
    // Is it just the key that then cannot be reused twice?
    proxy_fail("Ciphers without IV not modeled yet.");
    // FIXME: how about this:
    // set_attr(ctx, "seed", key, EVP_CIPHER_CTX_key_length(ctx));

  // Set the encryption position associated with the current seed to 0
  set_attr_int(ctx, "pos", 0);
  set_attr_str(ctx, "use", "encrypt");
  return EVP_EncryptInit_ex(ctx, cipher, impl, key, iv);
}

/*
 * EVP_DecryptInit_ex(), EVP_DecryptUpdate() and EVP_DecryptFinal_ex()
 * are the corresponding decryption operations.
 */
extern int EVP_DecryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const   *cipher ,
                                    ENGINE *impl , unsigned char const   *key , unsigned char const   *iv )
{
  if(cipher != NULL)
    copy_attr(ctx, cipher, "type");
  if(key != NULL)
    set_attr_buf(ctx, "key", key, EVP_CIPHER_CTX_key_length(ctx));

  if(iv != NULL)
    set_attr_buf(ctx, "seed", iv, EVP_CIPHER_CTX_iv_length(ctx));
  else
    // FIXME: see EncryptInit
    proxy_fail("Ciphers without IV not modeled yet.");

  // Set the encryption position associated with the current seed to 0
  set_attr_int(ctx, "pos", 0);

  set_attr_str(ctx, "use", "decrypt");

  return EVP_DecryptInit_ex(ctx, cipher, impl, key, iv);
}

/*
 * EVP_CipherInit_ex(), EVP_CipherUpdate() and EVP_CipherFinal_ex() are functions that can be used
 * for decryption or encryption. The operation performed depends on the value of the enc parameter.
 * It should be set to 1 for encryption, 0 for decryption and -1 to leave the value unchanged
 * (the actual value of 'enc' being supplied in a previous call).
 */
extern int EVP_CipherInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const   *cipher ,
                                   ENGINE *impl , unsigned char const   *key , unsigned char const   *iv ,
                                   int enc )
{
  int ret = EVP_CipherInit_ex(ctx, cipher, impl, key, iv, enc);

  copy_attr(ctx, cipher, "type");

  set_attr_buf(ctx, "key", key, EVP_CIPHER_CTX_key_length(ctx));

  if(enc == 1)
    set_attr_str(ctx, "use", "enc");
  else if(enc == 0)
    set_attr_str(ctx, "use", "dec");

  return ret;
}



// TODO, undocumented
extern int X509_certificate_type_proxy(X509 *x , EVP_PKEY *pubkey )
{
  return X509_certificate_type(x, pubkey);
}


// undocumented
extern EVP_CIPHER const   *EVP_aes_128_cbc_proxy(void)
{
  EVP_CIPHER const * ret = EVP_aes_128_cbc();

  set_attr_str(ret, "type", "aes_128_cbc");

  return ret;
}

// almost undocumented
extern EVP_MD const   *EVP_sha256_proxy(void)
{
  EVP_MD const * ret = EVP_sha256();

  set_attr_str(ret, "type", "sha256");

  return ret;
}

#if OPENSSL_MAJOR == 0
  #define HMAC_RET_TYPE void
#else
  #define HMAC_RET_TYPE int
#endif

/*
 * HMAC_Init_ex() initializes or reuses a HMAC_CTX structure to use the function evp_md and key key.
 * Either can be NULL, in which case the existing one will be reused.
 * HMAC_CTX_init() must have been called before the first use of an HMAC_CTX in this function.
 *
 * N.B. HMAC_Init() had this undocumented behaviour in previous versions of OpenSSL -
 * failure to switch to HMAC_Init_ex() in programs that expect it will cause them to stop working.
 *
 * Looking at the code of tls1_P_hash it seems that this function also clears the collected
 * message.
 */
extern HMAC_RET_TYPE HMAC_Init_ex_proxy(HMAC_CTX *ctx , void const   *key , int len , EVP_MD const   *md ,
                              ENGINE *impl )
{
  if(md != NULL)
    copy_attr(ctx, md, "type");

  // TODO: questionable
  if(key != NULL)
    set_attr_buf(ctx, "key", (const unsigned char *) key, len);

  clear_attr(ctx, "msg");

  #if OPENSSL_MAJOR == 0
    HMAC_Init_ex(ctx, key, len, md, impl);
  #else
    return HMAC_Init_ex(ctx, key, len, md, impl);
  #endif
}

extern HMAC_RET_TYPE HMAC_Update_proxy(HMAC_CTX *ctx , unsigned char const   *data , size_t len )
{
  add_to_attr(ctx, "msg", data, len);

  #if OPENSSL_MAJOR == 0
    HMAC_Update(ctx, data, len);
  #else
    return HMAC_Update(ctx, data, len);
  #endif

}

extern HMAC_RET_TYPE HMAC_Final_proxy(HMAC_CTX *ctx , unsigned char *md , unsigned int *len )
{

  #if OPENSSL_MAJOR == 0
    HMAC_Final(ctx, md, len);
  #else
    int ret = HMAC_Final(ctx, md, len);
  #endif

  load_ctx(ctx, "type", "");
  load_ctx(ctx, "msg", "msg");
  load_ctx(ctx, "key", "key");

  SymN("HMAC", 3);
  Hint("hash");
  assume_len(len, false, sizeof(*len));

  store_buf(md);

  #if OPENSSL_MAJOR == 1
    return ret;
  #endif
}

/*
   HMAC() computes the message authentication code of the n bytes at d using the
   hash function evp_md and the key key which is key_len bytes long.

   It places the result in md (which must have space for the output of the hash
   function, which is no more than EVP_MAX_MD_SIZE bytes). If md is NULL, the
   digest is placed in a static array.  The size of the output is placed in
   md_len, unless it is NULL.

   HMAC() returns a pointer to the message authentication code.
 */
extern unsigned char *HMAC_proxy(EVP_MD const   *evp_md , void const   *key ,
                                 int key_len , unsigned char const   *d ,
                                 size_t n , unsigned char *md ,
                                 unsigned int *md_len )
{
  // FIXME: this thing crashes if md_len is NULL, do the right thing
  if(md_len != NULL) *md_len = 0; // just making sure it's initialized.

  mute();
  unsigned char * ret = HMAC(evp_md, key, key_len, d, n, md, md_len);
  unmute();

  if(md_len != NULL)
    *md_len = concrete_val(*md_len);

  if(md != NULL)
    ret = md;
  else {
    fresh_ptr(*md_len);
    store_buf(&ret);
  }

  load_ctx(evp_md, "type", "");
  load_buf(d, n, "msg");
  load_buf((unsigned char *) key, key_len, "key");

  SymN("HMAC", 3);
  Hint("hash");
  assume_len(md_len, false, sizeof(*md_len));

  store_buf(ret);

  return ret;
}

#if OPENSSL_MAJOR == 0
  extern void HMAC_CTX_set_flags_proxy(HMAC_CTX *ctx , unsigned long flags )
  {
    HMAC_CTX_set_flags(ctx, flags);
  }
#endif

int SHA256_Init_proxy(SHA256_CTX *c)
{
  mute();
  int ret = SHA256_Init(c);
  unmute();

  SymN("SHA256_Init", 0);
  Nondet();
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));
  store_buf(&ret);

  clear_attr(c, "msg");

  return ret;
}

int SHA256_Update_proxy(SHA256_CTX *c, const void *data, size_t len)
{
  mute();
  int ret = SHA256_Update(c, data, len);
  unmute();

  SymN("SHA256_Update", 0);
  Nondet();
  size_t ret_len = sizeof(ret);
  assume_len(&ret_len, false, sizeof(ret_len));
  store_buf(&ret);

  add_to_attr(c, "msg", data, len);

  return ret;
}

int SHA256_Final_proxy(unsigned char *md, SHA256_CTX *c)
{
  mute();
  int ret = SHA256_Final(md, c);
  unmute();

  SymN("SHA256_Final", 0);
  Nondet();
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));
  store_buf(&ret);

  varsym("SHA256_key");
  load_ctx(c, "msg", "msg");

  SymN("SHA_hash", 2);
  Hint("hash");
  size_t len = 32;
  assume_len(&len, false, sizeof(len));

  store_buf(md);

  return ret;
}

/*
 * EVP_EncryptUpdate() encrypts inl bytes from the buffer in and writes the encrypted version to out.
 * This function can be called multiple times to encrypt successive blocks of data.
 * The amount of data written depends on the block alignment of the encrypted data:
 * as a result the amount of data written may be anything from zero bytes to (inl + cipher_block_size - 1)
 * so outl should contain sufficient room. The actual number of bytes written is placed in outl.
 */
extern int EVP_EncryptUpdate_proxy(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl,
                                   unsigned char const *in, int inl)
{
  int ret = EVP_EncryptUpdate(ctx, out, outl, in, inl);

  add_to_attr(ctx, "enc_in", in, inl);

  int pos = get_attr_int(ctx, "pos");

  load_ctx(ctx, "enc_in", "partial_plain");
  load_ctx(ctx, "key", "key");
  load_ctx(ctx, "iv", "iv");
  load_int(pos, true, sizeof(pos), "pos");
  load_ctx(ctx, "type", "type");

  SymN("encPart", 5);
  Hint("partial_enc");
  assume_len(outl, true, sizeof(*outl));
  Nondet();

  store_buf(out);

  pos += *outl;
  set_attr_int(ctx, "pos", pos);
  // add_to_attr(ctx, "enc_out", out, *outl);

  return ret;
}

/*
 * If padding is enabled (the default) then EVP_EncryptFinal_ex() encrypts the "final" data,
 * that is any data that remains in a partial block. It uses standard block padding (aka PKCS padding).
 * The encrypted final data is written to out which should have sufficient space for one cipher block.
 * The number of bytes written is placed in outl.
 * After this function is called the encryption operation is finished and no further calls to
 * EVP_EncryptUpdate() should be made.
 */
extern int EVP_EncryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl )
{
  int ret = EVP_EncryptFinal(ctx, out, outl);

  // add_to_attr(ctx, "enc_out", out, *outl);

  // FIXME: outl treatment is broken

  int pos = get_attr_int(ctx, "pos");

  load_ctx(ctx, "enc_in", "partial_plain");
  load_ctx(ctx, "key", "key");
  load_ctx(ctx, "iv", "iv");
  load_int(pos, true, sizeof(pos), "pos");
  load_ctx(ctx, "type", "type");

  SymN("encFin", 5);
  Hint("partial_enc");
  assume_len(outl, true, sizeof(*outl));
  Nondet();

  store_buf(out);

  // lhs(ctx, "enc_out", "enc");

  clear_attr(ctx, "enc_in");
  clear_attr(ctx, "pos");
  clear_attr(ctx, "iv");

  return ret;
}

/*
 * EVP_DecryptInit_ex(), EVP_DecryptUpdate() and EVP_DecryptFinal_ex()
 * are the corresponding decryption operations.
 */
extern int EVP_DecryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const   *in , int inl )
{
  int ret = EVP_DecryptUpdate(ctx, out, outl, in, inl);

  add_to_attr(ctx, "dec_in", in, inl);

  int pos = get_attr_int(ctx, "pos");

  load_ctx(ctx, "dec_in", "partial_enc");
  load_ctx(ctx, "key", "key");
  load_ctx(ctx, "iv", "iv");
  load_int(pos, true, sizeof(pos), "pos");
  load_ctx(ctx, "type", "type");

  SymN("decPart", 5);
  Hint("partial_dec");
  assume_len(outl, true, sizeof(*outl));
  Nondet();

  store_buf(out);

  pos += *outl;
  set_attr_int(ctx, "pos", pos);

  return ret;
}

extern int EVP_DecryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *outm , int *outl )
{
  int ret = EVP_DecryptFinal(ctx, outm, outl);

  int pos = get_attr_int(ctx, "pos");

  load_ctx(ctx, "dec_in", "partial_enc");
  load_ctx(ctx, "key", "key");
  load_ctx(ctx, "iv", "iv");
  load_int(pos, true, sizeof(pos), "pos");
  load_ctx(ctx, "type", "type");

  SymN("decFin", 5);
  Hint("partial_dec");
  assume_len(outl, true, sizeof(*outl));
  Nondet();

  store_buf(outm);

  clear_attr(ctx, "dec_in");
  clear_attr(ctx, "pos");
  clear_attr(ctx, "iv");

  return ret;
}


// stack_st_X509 was just STACK before 1.0.0
#if OPENSSL_MAJOR == 0

  // undocumented
  extern int X509_STORE_CTX_init_proxy(X509_STORE_CTX *ctx , X509_STORE *store , X509 *x509 ,
                                       STACK *chain )
  {
    return X509_STORE_CTX_init(ctx, store, x509, chain);
  }

  extern int ENGINE_load_ssl_client_cert_proxy(ENGINE *e , SSL *s , STACK *ca_dn , X509 **pcert ,
                                               EVP_PKEY **ppkey , STACK **pother , UI_METHOD *ui_method ,
                                               void *callback_data )
  {
    return ENGINE_load_ssl_client_cert(e, s, ca_dn, pcert, ppkey, pother, ui_method, callback_data);
  }


#else

  // TODO, undocumented
  extern int X509_STORE_CTX_init_proxy(X509_STORE_CTX *ctx , X509_STORE *store , X509 *x509 ,
                                       struct stack_st_X509 *chain )
  {
    return X509_STORE_CTX_init(ctx, store, x509, chain);
  }

  // TODO, undocumented
  extern int ENGINE_load_ssl_client_cert_proxy(ENGINE *e , SSL *s , struct stack_st_X509_NAME *ca_dn ,
                                               X509 **pcert , EVP_PKEY **ppkey , struct stack_st_X509 **pother ,
                                               UI_METHOD *ui_method , void *callback_data )
  {
    return ENGINE_load_ssl_client_cert(e, s, ca_dn, pcert, ppkey, pother, ui_method, callback_data);
  }

#endif

#if OPENSSL_MAJOR == 1
  // undocumented
  extern EVP_PKEY *EVP_PKEY_new_mac_key_proxy(int type , ENGINE *e , unsigned char *key ,
                                              int keylen )
  {
    EVP_PKEY * ret = EVP_PKEY_new_mac_key(type, e, key, keylen);

    load_buf(key, keylen, "keybits");

    SymN("EVP_PKEY_new_mac_key", 1);
    Hint("key");
    Nondet();

    store_ctx(ret, "id");

    // fighting abstraction breaking in ssl lib:
    copy_ctx(ret->pkey.ptr, ret);

    return ret;
  }
#endif

// Read a certificate in PEM format from a BIO:
extern X509 *PEM_read_bio_X509_proxy(BIO *bp , X509 **x , pem_password_cb *cb , void *u )
{
  X509 * ret = PEM_read_bio_X509(bp, x, cb, u);

  SymN("PEM_read_bio_X509", 0);
  Hint("cert");
  Nondet();

  store_ctx(ret, "id");

  return ret;
}


extern EVP_CIPHER const   *EVP_get_cipherbyname_proxy(char const   *name )
{
  EVP_CIPHER const * ret = EVP_get_cipherbyname(name);

  set_attr_str(ret, "type", name);

  return ret;
}


extern EVP_CIPHER const   *EVP_enc_null_proxy(void)
{
  EVP_CIPHER const * ret = EVP_enc_null();

  set_attr_str(ret, "type", "null");

  return ret;
}

// d2i_X509_bio() is similar to d2i_X509() except it attempts to parse data from BIO bp.
extern X509 *d2i_X509_bio_proxy(BIO *bp , X509 **x509 )
{
  X509 * ret = d2i_X509_bio(bp, x509);

  SymN("d2i_X509_bio", 0);
  Hint("cert");
  Nondet();

  store_ctx(ret, "id");

  return ret;
}


// undocumented
#if OPENSSL_MAJOR == 0
  extern int EVP_PKEY_assign_proxy(EVP_PKEY *pkey , int type , char *key )
#else
  extern int EVP_PKEY_assign_proxy(EVP_PKEY *pkey , int type , void *key )
#endif
{
  // TODO
  return EVP_PKEY_assign(pkey, type, key);
}

// The main purpose of the functions EVP_PKEY_missing_parameters() and EVP_PKEY_copy_parameters()
// is to handle public keys in certificates where the parameters are sometimes omitted from a public key
// if they are inherited from the CA that signed it.
extern int EVP_PKEY_copy_parameters_proxy(EVP_PKEY *to , EVP_PKEY const   *from )
{
  // TODO: this function doesn't copy the whole contents!
  return EVP_PKEY_copy_parameters(to, from);
}


extern EVP_PKEY *PEM_read_bio_PrivateKey_proxy(BIO *bp , EVP_PKEY **x , pem_password_cb *cb ,
                                               void *u )
{
  EVP_PKEY * ret = PEM_read_bio_PrivateKey(bp, x, cb, u);

  SymN("PEM_read_bio_PrivateKey", 0);
  Hint("pkey");
  Nondet();

  store_ctx(ret, "key");

  copy_ctx(ret->pkey.ptr, ret);

  return ret;
}

// undocumented
extern EVP_PKEY *d2i_PrivateKey_bio_proxy(BIO *bp , EVP_PKEY **a )
{
  EVP_PKEY * ret = d2i_PrivateKey_bio(bp, a);

  SymN("d2i_PrivateKey_bio", 0);
  Hint("pkey");
  Nondet();

  store_ctx(ret, "id");

  copy_ctx(ret->pkey.ptr, ret);

  return ret;
}

// undocumented
extern EVP_PKEY *d2i_PrivateKey_proxy(int type , EVP_PKEY **a , unsigned char const   **pp ,
                                      long length )
{
  EVP_PKEY * ret = d2i_PrivateKey(type, a, pp, length);

  // TODO: is this right?
  load_buf(*pp, length, "keystring");

  SymN("d2i_PrivateKey", 1);
  Hint("pkey");
  Nondet();

  store_ctx(ret, "id");

  copy_ctx(ret->pkey.ptr, ret);

  return ret;
}


extern EVP_CIPHER const   *EVP_des_cbc_proxy(void)
{
  EVP_CIPHER const * ret = EVP_des_cbc();

  set_attr_str(ret, "type", "des_cbc");

  return ret;
}

extern EVP_CIPHER const   *EVP_des_ede3_cbc_proxy(void)
{
  EVP_CIPHER const * ret = EVP_des_ede3_cbc();

  set_attr_str(ret, "type", "des_ede3_cbc");

  return ret;
}

/*
extern EVP_CIPHER const   *EVP_idea_cbc_proxy(void)
{
  EVP_CIPHER const * ret = EVP_idea_cbc();

  set_attr_str(ret, "type", "idea_cbc");

  return ret;
}
*/


extern EVP_CIPHER const   *EVP_rc4_proxy(void)
{
  EVP_CIPHER const * ret = EVP_rc4();

  set_attr_str(ret, "type", "rc4");

  return ret;
}

extern EVP_CIPHER const   *EVP_rc2_cbc_proxy(void)
{
  EVP_CIPHER const * ret = EVP_rc2_cbc();

  set_attr_str(ret, "type", "rc2_cbc");

  return ret;
}

extern EVP_CIPHER const   *EVP_rc2_40_cbc_proxy(void)
{
  EVP_CIPHER const * ret = EVP_rc2_40_cbc();

  set_attr_str(ret, "type", "rc2_40_cbc");

  return ret;
}


extern EVP_CIPHER const   *EVP_aes_192_cbc_proxy(void)
{
  EVP_CIPHER const * ret = EVP_aes_192_cbc();

  set_attr_str(ret, "type", "aes_192_cbc");

  return ret;
}

extern EVP_CIPHER const   *EVP_aes_256_cbc_proxy(void)
{
  EVP_CIPHER const * ret = EVP_aes_256_cbc();

  set_attr_str(ret, "type", "aes_256_cbc");

  return ret;
}

#if OPENSSL_MAJOR == 1

  extern EVP_CIPHER const   *EVP_camellia_128_cbc_proxy(void)
  {
    EVP_CIPHER const * ret = EVP_camellia_128_cbc();

    set_attr_str(ret, "type", "camellia_128_cbc");

    return ret;
  }

  extern EVP_CIPHER const   *EVP_camellia_256_cbc_proxy(void)
  {
    EVP_CIPHER const * ret = EVP_camellia_256_cbc();

    set_attr_str(ret, "type", "camellia_256_cbc");

    return ret;
  }

  extern EVP_CIPHER const   *EVP_seed_cbc_proxy(void)
  {
    EVP_CIPHER const * ret = EVP_seed_cbc();

    set_attr_str(ret, "type", "seed_cbc");

    return ret;
  }

#endif

/*
 * RAND_bytes() puts num cryptographically strong pseudo-random bytes into buf.
 * An error occurs if the PRNG has not been seeded with enough randomness to ensure an unpredictable byte sequence.
 *
 * The contents of buf is mixed into the entropy pool before retrieving the new pseudo-random bytes
 * unless disabled at compile time (see FAQ).
 *
 * RAND_bytes() returns 1 on success, 0 otherwise. The error code can be obtained by ERR_get_error.
 */
extern int RAND_bytes_proxy(unsigned char *buf , int num )
{
  mute();
  int ret = RAND_bytes(buf, num);
  if(ret != 1)
    proxy_fail("RAND_bytes failed");
  unmute();

  newTL(num, NULL, "nonce");
  store_buf(buf);

  return 1;
}

/*
 * RAND_pseudo_bytes() puts num pseudo-random bytes into buf. Pseudo-random byte sequences generated by RAND_pseudo_bytes()
 * will be unique if they are of sufficient length, but are not necessarily unpredictable.
 * They can be used for non-cryptographic purposes and for certain purposes in cryptographic protocols,
 * but usually not for key generation etc.
 *
 * RAND_pseudo_bytes() returns 1 if the bytes generated are cryptographically strong, 0 otherwise.
 * Both functions return -1 if they are not supported by the current RAND method.
 */
extern int RAND_pseudo_bytes_proxy(unsigned char *buf , int num )
{
  int ret = RAND_pseudo_bytes(buf, num);

  SymN("RAND_pseudo_bytes", 0);
  Hint("nonce");
  assume_len(&num, true, sizeof(num));
  Nondet();

  store_buf(buf);

  return ret;
}


extern RSA *d2i_RSAPrivateKey_bio_proxy(BIO *bp , RSA **rsa )
{
  RSA * ret = d2i_RSAPrivateKey_bio(bp, rsa);

  SymN("d2i_RSAPrivateKey_bio", 0);
  Hint("rsa_key");
  Nondet();

  store_ctx(ret, "id");

  return ret;
}


extern RSA *PEM_read_bio_RSAPrivateKey_proxy(BIO *bp , RSA **x , pem_password_cb *cb ,
                                             void *u )
{
  RSA * ret = PEM_read_bio_RSAPrivateKey(bp, x, cb, u);

  SymN("PEM_read_bio_RSAPrivateKey", 0);
  Hint("rsa_key");
  Nondet();

  store_ctx(ret, "id");

  return ret;
}

extern RSA *d2i_RSAPrivateKey_proxy(RSA **a , unsigned char const   **in , long len )
{
  // FIXME: do as in DSA
  RSA * ret = d2i_RSAPrivateKey(a, in, len);

  SymN("d2i_RSAPrivateKey", 0);
  Hint("rsa_key");
  Nondet();

  store_ctx(ret, "id");

  return ret;
}

#if OPENSSL_MAJOR == 0

  extern int ssl3_handshake_mac(SSL *s , EVP_MD_CTX *in_ctx , char const   *sender ,
                                    int len , unsigned char *p ) ;

  extern int ssl3_handshake_mac_proxy(SSL *s , EVP_MD_CTX *in_ctx , char const   *sender ,
                                    int len , unsigned char *p )
  {
    // FIXME: this looks like something that should be properly modeled
    return ssl3_handshake_mac(s, in_ctx, sender, len, p);
  }

  extern int ssl3_final_finish_mac(SSL *s , EVP_MD_CTX *ctx1 , EVP_MD_CTX *ctx2 ,
                                           char const   *sender , int slen , unsigned char *p );

  extern int ssl3_final_finish_mac_proxy(SSL *s , EVP_MD_CTX *ctx1 , EVP_MD_CTX *ctx2 ,
                                         char const   *sender , int slen , unsigned char *p )
  {
    // FIXME:
    return ssl3_final_finish_mac(s, ctx1, ctx2, sender, slen, p);
  }

  extern int ssl3_cert_verify_mac(SSL *s , EVP_MD_CTX *in , unsigned char *p );

  extern int ssl3_cert_verify_mac_proxy(SSL *s , EVP_MD_CTX *in , unsigned char *p )
  {
    // FIXME:
    return ssl3_cert_verify_mac(s, in, p);
  }

  extern int tls1_final_finish_mac(SSL *s , EVP_MD_CTX *in1_ctx , EVP_MD_CTX *in2_ctx ,
                                           char const   *str , int slen , unsigned char *p );

  extern int tls1_final_finish_mac_proxy(SSL *s , EVP_MD_CTX *in1_ctx , EVP_MD_CTX *in2_ctx ,
                                         char const   *str , int slen , unsigned char *p )
  {
    return tls1_final_finish_mac(s, in1_ctx, in2_ctx, str, slen, p);
  }

  extern int tls1_cert_verify_mac(SSL *s , EVP_MD_CTX *in , unsigned char *p );

  extern int tls1_cert_verify_mac_proxy(SSL *s , EVP_MD_CTX *in , unsigned char *p )
  {
    return tls1_cert_verify_mac(s, in, p);
  }

#endif

/*

  Bring back when crestifying OpenSSL

#if OPENSSL_MAJOR == 1
int tls1_generate_master_secret_proxy(SSL *s, unsigned char *out, unsigned char *p,
	     int len)
{
  // FIXME: what's going on here?
  //load_buf(p, len, "premaster_secret");
  //symL("tls1_generate_master_secret");
  //store_buf(NULL, 0, "");
  int ret = tls1_generate_master_secret(s, out, p, len);
  return ret;
}
#endif
*/

#if OPENSSL_MAJOR == 0
  extern int check_srvr_ecc_cert_and_alg(X509 *x , SSL_CIPHER *cs );
  int check_srvr_ecc_cert_and_alg_proxy(X509 *x , SSL_CIPHER *cs )
  {
    return check_srvr_ecc_cert_and_alg(x, cs);
  }
#endif


#if OPENSSL_MAJOR == 1

  ////////////////////////////////////////////
  // EVP_PKEY_CTX was only introduced in 1.0.0
  ////////////////////////////////////////////

  /*
   * The EVP_PKEY_CTX_new() function allocates public key algorithm context
   * using the algorithm specified in pkey and ENGINE e.
   */
  extern EVP_PKEY_CTX *EVP_PKEY_CTX_new_proxy(EVP_PKEY *pkey , ENGINE *e )
  {
    EVP_PKEY_CTX * ret = EVP_PKEY_CTX_new(pkey, e);

    copy_attr_ex(ret, "key", pkey, "id");

    return ret;
  }


  // The EVP_PKEY_derive_set_peer() function sets the peer key: this will normally be a public key.
  extern int EVP_PKEY_derive_set_peer_proxy(EVP_PKEY_CTX *ctx , EVP_PKEY *peer )
  {
    int ret = EVP_PKEY_derive_set_peer(ctx, peer);

    copy_attr_ex(ctx, "peerkey", peer, "id");

    return ret;
  }

  /*
   * The EVP_PKEY_decrypt() function performs a public key decryption operation using ctx.
   * The data to be decrypted is specified using the in and inlen parameters.
   * If out is NULL then the maximum size of the output buffer is written to the outlen parameter.
   * If out is not NULL then before the call the outlen parameter should contain the length of the out buffer,
   * if the call is successful the decrypted data is written to out and the amount of data written to outlen.
   */
  extern int EVP_PKEY_decrypt_proxy(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                                    unsigned char const   *in , size_t inlen )
  {
    int ret = EVP_PKEY_decrypt(ctx, out, outlen, in, inlen);

    if(out != NULL)
    {
      load_buf(in, inlen, "enc");
      load_ctx(ctx, "key", "pkey");

      SymN("EVP_PKEY_decrypt", 2);
      Hint("dec");
      assume_len(outlen, false, sizeof(*outlen));

      store_buf(out);
    }

    return ret;
  }

  // TODO
  extern int EVP_PKEY_CTX_ctrl_proxy(EVP_PKEY_CTX *ctx , int keytype , int optype ,
                                     int cmd , int p1 , void *p2 )
  {
    return EVP_PKEY_CTX_ctrl(ctx, keytype, optype, cmd, p1, p2);
  }


  /*
   * EVP_DigestSignInit() sets up signing context ctx to use digest type from ENGINE impl and private key pkey.
   * ctx must be initialized with EVP_MD_CTX_init() before calling this function.
   * If pctx is not NULL the EVP_PKEY_CTX of the signing operation will be written to *pctx:
   * this can be used to set alternative signing options.
   */
  int EVP_DigestSignInit_proxy(EVP_MD_CTX *ctx , EVP_PKEY_CTX **pctx ,
                                EVP_MD const   *type , ENGINE *e , EVP_PKEY *pkey )
  {
    int ret = EVP_DigestSignInit(ctx, pctx, type, e, pkey);

    copy_attr_ex(ctx, "key", pkey, "id");
    copy_attr(ctx, type, "type");
    set_attr_str(ctx, "use", "DigestSign");
    set_attr_str(ctx, "msg", "");

    if(pctx != NULL)
      copy_attr_ex(*pctx, "key", pkey, "id");

    return ret;
  }

  /*
   * The EVP_PKEY_verify() function performs a public key verification operation using ctx.
   * The signature is specified using the sig and siglen parameters.
   * The verified data (i.e. the data believed originally signed) is specified
   * using the tbs and tbslen parameters.
   *
   * EVP_PKEY_verify_init() and EVP_PKEY_verify() return 1 if the verification was successful
   * and 0 if it failed.
   */
  extern int EVP_PKEY_verify_proxy(EVP_PKEY_CTX *ctx , unsigned char const   *sig ,
                                   size_t siglen , unsigned char const   *tbs , size_t tbslen )
  {
    int ret = EVP_PKEY_verify(ctx, sig, siglen, tbs, tbslen);

    // TODO: this is wrong for symbolic tracing
    // I would take the position that in binary tracing verify doesn't make
    // sense at all, so we just do the correct symbolic equation
    if(ret == 1)
    {
      load_buf(tbs, tbslen, "msg");
      load_ctx(ctx, "key", "pkey");

      SymN("EVP_PKEY_verify", 2);
      Hint("sig");
      assume_len(&siglen, false, sizeof(siglen));

      store_buf(sig);
    }

    /* rhs(tbs, tbslen, "msg");
    rhs(sig, siglen, "sig");
    rhs(ctx, "key", "pkey");
    symL("EVP_PKEY_verify"); */

    return ret;
  }

  /*
   * The EVP_PKEY_encrypt() function performs a public key encryption operation using ctx.
   * The data to be encrypted is specified using the in and inlen parameters.
   * If out is NULL then the maximum size of the output buffer is written to the outlen parameter.
   * If out is not NULL then before the call the outlen parameter should contain the length of the out buffer,
   * if the call is successful the encrypted data is written to out and the amount of data written to outlen.
   */
  extern int EVP_PKEY_encrypt_proxy(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                                    unsigned char const   *in , size_t inlen )
  {
    int ret = EVP_PKEY_encrypt(ctx, out, outlen, in, inlen);

    if(out != NULL)
    {
      SymN("lenvar", 0);
      Hint("enc_len");
      size_t len = sizeof(*outlen);
      assume_len(&len, false, sizeof(len));

      store_buf((unsigned char *) outlen);

      load_buf(in, inlen, "plain");
      load_ctx(ctx, "key", "pkey");

      SymN("EVP_PKEY_encrypt", 2);
      Hint("penc");
      Nondet();
      assume_len(outlen, false, sizeof(*outlen));

      store_buf(out);
    }

    return ret;
  }

  /*
   * The EVP_PKEY_sign() function performs a public key signing operation using ctx.
   * The data to be signed is specified using the tbs and tbslen parameters.
   * If sig is NULL then the maximum size of the output buffer is written to the siglen parameter.
   * If sig is not NULL then before the call the siglen parameter should contain the length of the sig buffer,
   * if the call is successful the signature is written to sig and the amount of data written to siglen.
   *
   */
  extern int EVP_PKEY_sign_proxy(EVP_PKEY_CTX *ctx , unsigned char *sig , size_t *siglen ,
                                 unsigned char const   *tbs , size_t tbslen )
  {
    int ret = EVP_PKEY_sign(ctx, sig, siglen, tbs, tbslen);

    if(sig != NULL)
    {
      SymN("lenvar", 0);
      Hint("sig_len");
      size_t len = sizeof(*siglen);
      assume_len(&len, false, sizeof(len));
      Nondet();

      store_buf((unsigned char *) siglen);

      load_buf(tbs, tbslen, "msg");
      load_ctx(ctx, "key", "pkey");

      SymN("EVP_PKEY_sign", 2);
      assume_len(siglen, false, sizeof(*siglen));
      Nondet();

      store_buf(sig);
    }

    return ret;
  }


#endif

void BN_free_proxy(BIGNUM *a )
{
  mute();
  BN_free(a);
  unmute();
}

BIGNUM *BN_new_proxy(void)
{
  mute();
  BIGNUM * ret = BN_new();
  unmute();

  fresh_ptr(sizeof(ret));
  store_buf((unsigned char *) &ret);

  return ret;
}

void BN_init_proxy(BIGNUM * a)
{
  mute();
  BN_init(a);
  unmute();
}

int BN_rand_range_proxy(BIGNUM *rnd , BIGNUM const   *range )
{
  mute();
  int ret = BN_rand_range(rnd, range);
  unmute();

  SymN("BN_rand_range_result", 0);
  Nondet();
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));
  store_buf(&ret);

  load_ctx(range, "val", "range");
  SymN("BN_rand_range", 1);
  Nondet();
  store_ctx(rnd, "val");

  return ret;
}

/* No documentation but seems to do with multithreading. */
BN_MONT_CTX *BN_MONT_CTX_set_locked_proxy(BN_MONT_CTX **pmont ,
                                          int lock ,
                                          BIGNUM const   *mod ,
                                          BN_CTX *ctx )
{
  mute();
  BN_MONT_CTX * ret = BN_MONT_CTX_set_locked(pmont, lock, mod, ctx);
  unmute();

  fresh_ptr(sizeof(ret));
  store_buf((unsigned char *) &ret);

  return ret;
}


BIGNUM *BN_copy_proxy(BIGNUM *a , BIGNUM const   *b )
{
  mute();
  BIGNUM * ret = BN_copy(a, b);
  unmute();

  ret = a;

  load_ctx(a, "val", "bignum");
  store_ctx(b, "val");

  return ret;
}

/*
  BN_add() adds a and b and places the result in r (r=a+b). r may be
  the same BIGNUM as a or b.
 */
int BN_add_proxy(BIGNUM *r , BIGNUM const   *a , BIGNUM const   *b )
{
  mute();
  int ret = BN_add(r, a, b);
  unmute();

  SymN("BN_add_result", 0);
  Nondet();
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));
  store_buf(&ret);

  load_ctx(a, "val", "a");
  load_ctx(b, "val", "b");
  SymN("BN_add", 2);
  store_ctx(r, "val");

  return ret;
}

/*
  BN_div() divides a by d and places the result in dv and the
  remainder in rem (dv=a/d, rem=a%d). Either of dv and rem may be
  NULL, in which case the respective value is not returned. The result
  is rounded towards zero; thus if a is negative, the remainder will
  be zero or negative. For division by powers of 2, use BN_rshift.
 */
int BN_div_proxy(BIGNUM *dv , BIGNUM *rem , BIGNUM const   *m ,
                 BIGNUM const   *d , BN_CTX *ctx )
{
  mute();
  int ret = BN_div(dv, rem, m, d, ctx);
  unmute();

  SymN("BN_div_result", 0);
  Nondet();
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));
  store_buf(&ret);

  if(dv != NULL){
    load_ctx(m, "val", "m");
    load_ctx(d, "val", "d");
    SymN("BN_div", 2);
    store_ctx(dv, "val");
  }

  if(rem != NULL){
    load_ctx(m, "val", "m");
    load_ctx(d, "val", "d");
    SymN("BN_rem", 2);
    store_ctx(rem, "val");
  }

  return ret;
}

BIGNUM *BN_mod_inverse_proxy(BIGNUM *ret , BIGNUM const   *a ,
                             BIGNUM const   *n , BN_CTX *ctx )
{
  mute();
  ret = BN_mod_inverse(ret, a, n, ctx);
  unmute();

  load_ctx(a, "val", "a");
  load_ctx(n, "val", "n");
  SymN("BN_mod_inverse", 2);
  store_ctx(ret, "val");

  return ret;
}

void BN_clear_free_proxy(BIGNUM *a )
{
  mute();
  BN_clear_free(a);
  unmute();
}

void BN_MONT_CTX_free_proxy(BN_MONT_CTX *mont )
{
  mute();
  BN_MONT_CTX_free(mont);
  unmute();
}

void ERR_put_error_proxy(int lib , int func , int reason ,
                         char const   *file , int line )
{
  mute();
  ERR_put_error(lib, func, reason, file, line);
  unmute();
}


BN_CTX *BN_CTX_new_proxy(void)
{
  mute();
  BN_CTX * ret = BN_CTX_new();
  unmute();

  fresh_ptr(sizeof(ret));
  store_buf((unsigned char *) &ret);

  return ret;
}

void BN_CTX_free_proxy(BN_CTX *c )
{
  mute();
  BN_CTX_free(c);
  unmute();
}

void BN_CTX_start_proxy(BN_CTX *ctx )
{
  mute();
  BN_CTX_start(ctx);
  unmute();
}

BIGNUM *BN_CTX_get_proxy(BN_CTX *ctx )
{
  mute();
  BIGNUM * ret = BN_CTX_get(ctx);
  unmute();

  fresh_ptr(sizeof(ret));
  store_buf((unsigned char *) &ret);

  return ret;
}

void BN_CTX_end_proxy(BN_CTX *ctx )
{
  mute();
  BN_CTX_end(ctx);
  unmute();
}

int BN_num_bits_proxy(BIGNUM const   *a )
{
  mute();
  int ret = BN_num_bits(a);
  unmute();

  load_ctx(a, "val", NULL);

  SymN("BN_num_bits", 1);
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));

  store_buf((void*) &ret);

  return ret;
}

/*
  BN_num_bytes() returns the size of a BIGNUM in bytes.

  BN_num_bits_word() returns the number of significant bits in a
  word. If we take 0x00000432 as an example, it returns 11, not 16,
  not 32. Basically, except for a zero, it returns floor(log2(w))+1.

  BN_num_bits() returns the number of significant bits in a BIGNUM,
  following the same principle as BN_num_bits_word().

  BN_num_bytes() is a macro.
 */
int BN_num_bytes_proxy(const BIGNUM *a)
{
  mute();
  int ret = (BN_num_bits_proxy(a)+7)/8;
  unmute();

  load_ctx(a, "val", NULL);

  len(true, sizeof(ret));
  assume_intype("bitstring");

  store_buf((void*) &ret);

  return ret;
}


/*
 * BN_bin2bn() converts the positive integer in big-endian form of
 * length len at s into a BIGNUM and places it in ret.  If ret is
 * NULL, a new BIGNUM is created.
 *
 * BN_bin2bn() returns the BIGNUM, NULL on error.
 */
extern BIGNUM *BN_bin2bn_proxy(unsigned char const *s , int len , BIGNUM *ret )
{
  mute();
  BIGNUM * ret2 = BN_bin2bn(s, len, ret);
  unmute();

  fresh_ptr(sizeof(*ret2));
  store_buf(&ret2);

  BIGNUM * result;
  // FIXME: nontrivial branching
  if(ret == NULL) result = ret2; else result = ret;

  load_buf(s, len, NULL);
  store_ctx(result, "val");

  return result;
}

/*
 * BN_bn2bin() converts the absolute value of a into big-endian form and stores it at to.
 * to must point to BN_num_bytes(a) bytes of memory.
 *
 * BN_bn2bin() returns the length of the big-endian number placed at to.
 */
extern int BN_bn2bin_proxy(BIGNUM const   *a , unsigned char *to )
{
  mute();
  int ret = BN_bn2bin(a, to);
  unmute();

  load_ctx(a, "val", NULL);
  len(true, sizeof(ret));
  assume_intype("bitstring");
  store_buf((void *)&ret);

  load_ctx(a, "val", NULL);
  store_buf(to);

  return ret;
}

/*
 * BN_mod_exp() computes a to the p-th power modulo m (r=a^p % m). This function uses less time and space than BN_exp().
 *
 * For all functions, 1 is returned for success, 0 on error.
 */
extern int BN_mod_exp_proxy(BIGNUM *r , BIGNUM const   *a , BIGNUM const   *p , BIGNUM const   *m , BN_CTX *ctx )
{
  mute();
  int ret = BN_mod_exp(r, a, p, m, ctx);
  if(ret != 1)
    proxy_fail("BN_mod_exp failed");
  unmute();

  load_ctx(a, "val", "bignum");
  load_ctx(p, "val", "bignum");
  load_ctx(m, "val", "bignum");

  SymN("mod_exp", 3);
  Hint("bignum");
  assume_intype("bitstring");

  store_ctx(r, "val");

  return 1;
}

/*
 * BN_hex2bn() converts the string str containing a hexadecimal number to a BIGNUM and stores it in **a.
 * If *a  is NULL, a new BIGNUM is created. If a is NULL, it only computes the number's length in hexadecimal digits.
 * If the string starts with '-', the number is negative. BN_dec2bn() is the same using the decimal system.
 *
 * BN_hex2bn() and BN_dec2bn() return the number's length in hexadecimal or decimal digits, and 0 on error.
 */
extern int BN_hex2bn_proxy(BIGNUM **a , char const   *str )
{
  BIGNUM dummy;

  int create_new = (a != NULL) && (*a == NULL);

  mute();
  int ret = BN_hex2bn(a, str);
  unmute();

  load_all(str, "hex");

  SymN("ztp", 1);
  Hint("ztp");

  SymN("BN_hex2bn", 1);
  Hint("bignum");
  test_intype("bitstring");

  store_ctx(&dummy, "val");

  load_ctx(&dummy, "val", "");

  len(true, sizeof(ret));
  assume_intype("bitstring");
  store_buf((void *) &ret);

  if(a != NULL)
  {
    if(create_new)
    {
      fresh_ptr(sizeof(**a));
      store_buf((unsigned char *) a);
    }
    // *a = fresh_ptr((void *) *a, sizeof(**a));

    load_ctx(&dummy, "val", "bignum");
    store_ctx(*a, "val");
  }

  return ret;
}

/*
 * BN_bn2hex() and BN_bn2dec() return printable strings containing the
 * hexadecimal and decimal encoding of a respectively.  For negative
 * numbers, the string is prefaced with a leading '-'.  The string
 * must be freed later using OPENSSL_free().
 *
 * BN_bn2hex() and BN_bn2dec() return a null-terminated string, or NULL on error.
 */
extern char *BN_bn2hex_proxy(BIGNUM const   *a )
{
  mute();
  char * ret = BN_bn2hex(a);
  if(ret == NULL)
    proxy_fail("BN_bn2hex failed");
  unmute();

  load_ctx(a, "val", "");

  SymN("BN_bn2hex", 1);
  Hint("hex");
  assume_intype("bitstring");

  // CR: the allocated length is not known
  fresh_ptr(sizeof(ret));
  store_buf(&ret);
  store_all(ret);

  return ret;
}

/*
 * BN_zero(), BN_one() and BN_set_word() return 1 on success, 0
 * otherwise. BN_value_one() returns the constant.
 */
int BN_set_word_proxy(BIGNUM *a, unsigned long w)
{
  mute();
  int ret = BN_set_word(a, w);
  unmute();

  SymN("BN_set_word_result", 0);
  Nondet();
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));
  store_buf(&ret);

  load_buf((unsigned char *)&w, sizeof(w), "wordval");
  store_ctx(a, "val");

  return ret;
}

/*
 * rr = a1^p1 * a2*p2 mod m
 */
// CR: What if m = 0?
int BN_mod_exp2_mont_proxy(BIGNUM *rr , BIGNUM const   *a1 ,
                           BIGNUM const   *p1 , BIGNUM const   *a2 ,
                           BIGNUM const   *p2 , BIGNUM const   *m ,
                           BN_CTX *ctx , BN_MONT_CTX *in_mont )
{
  mute();
  int ret = BN_mod_exp2_mont(rr, a1, p1, a2, p2, m, ctx, in_mont);
  unmute();

  SymN("BN_mod_exp2_mont_result", 0);
  Nondet();
  size_t ret_len = sizeof(ret);
  assume_len(&ret_len, false, sizeof(ret_len));
  store_buf(&ret);

  int m_len = BN_num_bytes_proxy(m);

  load_ctx(a1, "val", "a1");
  load_ctx(p1, "val", "p1");
  load_ctx(a2, "val", "a1");
  load_ctx(p2, "val", "p1");
  load_ctx(m, "val", "bignum");

  SymN("mod_exp2", 5);
  // Relying on the fact that anything stored to memory or context is not
  // bottom.
  assume_intype("bitstring");
  // the result will not be longer than the modulus
  assume_len_at_most(&m_len, true, sizeof(m_len));
  Hint("rr");

  store_ctx(rr, "val");

  return ret;
}

/*
 * See BN_mod_exp_proxy.
 */
int BN_mod_exp_mont_proxy(BIGNUM *rr , BIGNUM const   *a ,
                          BIGNUM const   *p , BIGNUM const   *m ,
                          BN_CTX *ctx , BN_MONT_CTX *in_mont )
{
  int ret = BN_mod_exp_mont(rr, a, p, m, ctx, in_mont);

  load_ctx(a, "val", "a");
  load_ctx(p, "val", "p");
  load_ctx(m, "val", "bignum");

  SymN("mod_exp", 3);
  // Relying on the fact that anything stored to memory or context is not
  // bottom.
  assume_intype("bitstring");
  Hint("rr");

  store_ctx(rr, "val");

  return ret;
}

void BN_CTX_init_proxy(BN_CTX *c )
{
  mute();
  BN_CTX_init(c);
  unmute();
}

int BN_print_fp_proxy(FILE *fp , BIGNUM const   *a )
{
  mute();
  int ret = BN_print_fp(fp, a);
  unmute();

  input("BN_print_fp_result", sizeof(ret));
  store_buf(&ret);

  return ret;
}

void DSA_free_proxy(DSA *r )
{
  mute();
  DSA_free(r);
  unmute();
}


DSA_SIG *DSA_SIG_new_proxy(void)
{
  mute();
  DSA_SIG * ret = DSA_SIG_new();
  unmute();

  fresh_ptr(sizeof(ret));
  store_buf((unsigned char *) &ret);

  return ret;
}

void DSA_SIG_free_proxy(DSA_SIG *a )
{
  mute();
  DSA_SIG_free(a);
  unmute();
}

/*
 * DSA_generate_key() expects a to contain DSA parameters. It generates a new key pair and stores it in a->pub_key and a->priv_key.

   The PRNG must be seeded prior to calling DSA_generate_key().
 */
int DSA_generate_key_proxy(DSA *a)
{
/*
  size_t keylen;
  symL("dsa_keylen", "keylen", sizeof(size_t), true);
  store_buf(&keylen, sizeof(keylen));
*/

  newT("DSA_keyseed", "keyseed");
  store_ctx(a, "keyseed");

  load_ctx(a, "keyseed", "keyseed");
  SymN("DSA_sk", 1);
  Hint("skey");
  store_ctx(a, "skey");

  load_ctx(a, "keyseed", "keyseed");
  SymN("DSA_pk", 1);
  Hint("pkey");
  store_ctx(a, "pkey");

  return DSA_generate_key(a);
}

DSA *DSA_new_proxy(void)
{
  mute();
  DSA * ret = DSA_new();
  unmute();

  fresh_ptr(sizeof(ret));
  store_buf((unsigned char *) &ret);

  return ret;
}


/*
 * DSA_new_method() allocates and initializes a DSA structure so that
 * engine will be used for the DSA operations. If engine is NULL, the
 * default engine for DSA operations is used, and if no default ENGINE
 * is set, the DSA_METHOD controlled by DSA_set_default_method() is
 * used.
 */
DSA *DSA_new_method_proxy(ENGINE *engine)
{
  // show symex the very first execution of DSA_get_default_method
  // that initialises the method structure
  DSA_get_default_method();

  DSA * ret = DSA_new_method(engine);
  return ret;
}

/**
 * d2i_DSA_PUBKEY() and i2d_DSA_PUBKEY() decode and encode an DSA
 * public key using a SubjectPublicKeyInfo (certificate public key)
 * structure.
 *
 * Behaves as follows, with out = pp:
 *
 * i2d_X509() encodes the structure pointed to by x into DER format.
 * If *out is not NULL is writes the DER encoded data to the buffer at
 * *out, and increments it to point after the data just written.  If
 * the return value is negative an error occurred, otherwise it
 * returns the length of the encoded data.
 */
int i2d_DSA_PUBKEY_proxy(DSA *a , unsigned char **pp )
{
  mute();
  unsigned char *old_pp = *pp;
  int ret = i2d_DSA_PUBKEY(a, pp);
  unsigned char *new_pp = *pp;
  *pp = old_pp;
  unmute();

  load_ctx(a, "pkey", "dsa_pkey");
  SymN("i2d_DSA_PUBKEY", 1);
  Hint("DER");
  store_len(&ret, sizeof(ret), true);
  // DER remains on stack ...

  void *p;
  if(*pp == NULL)
  {
    fresh_ptr(ret);
    store_buf(pp);
    p = *pp;
  }
  else {
    p = *pp;
    *pp = *pp + ret;
  }

  // DER is stored here
  store_buf(p);

  mute();
  *pp = new_pp;
  unmute();

  return ret;
}

/**
 * This behaves in the similar fashion with a = px, pp = in
 *
 * d2i_X509() attempts to decode len bytes at *in. If successful a pointer to the X509 structure is returned.
 * If an error occurred then NULL is returned. If px is not NULL then the returned structure is written to *px.
 * If *px is not NULL then it is assumed that *px contains a valid X509 structure and an attempt is made to reuse it.
 * If the call is successful *in is incremented to the byte following the parsed data.
 */
DSA *d2i_DSA_PUBKEY_proxy(DSA **a , unsigned char const   **pp , long length )
{
  unsigned char *p = *pp;

  DSA * ret = d2i_DSA_PUBKEY(a, pp, length);

  if(*a != NULL)
    ret = *a;
  else
  {
    fresh_ptr(sizeof(ret));
    store_buf(ret);
    // really?
    *a = ret;
  }

  load_buf(*pp, length, "DER");

  SymN("d2i_DSA_PUBKEY", 1);
  Hint("dsa_pubkey");
  Nondet();

  store_ctx(ret, "pkey");

  *pp = p + length;

  return ret;
}


//int DSA_sign_proxy(int type , unsigned char const   *dgst , int dlen , unsigned char *sig ,
//                    unsigned int *siglen , DSA *dsa )
//{
//
//}
//
//int DSA_verify_proxy(int type , unsigned char const   *dgst , int dgst_len , unsigned char const   *sigbuf ,
//                      int siglen , DSA *dsa )
//{
//
//}


unsigned long lh_strhash_proxy(char const   *c )
{
  unsigned long ret = lh_strhash(c);

  load_all(c, "str");

  SymN("lh_strhash", 1);
  Hint("strhash");
  size_t len = sizeof(ret);
  assume_len(&len, false, sizeof(len));

  store_buf((void *) &ret);

  return ret;
}


////////////////////////////////////////////
// DES
////////////////////////////////////////////

extern void DES_ecb3_encrypt_proxy(const_DES_cblock *input , DES_cblock *output ,
                                   DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                   DES_key_schedule *ks3 , int enc )
{
  // FIXME: fill in
  DES_ecb3_encrypt(input, output, ks1, ks2, ks3, enc);
}

extern void DES_ncbc_encrypt_proxy(unsigned char const   *input , unsigned char *output ,
                                   long length , DES_key_schedule *schedule , DES_cblock *ivec ,
                                   int enc )
{
  // FIXME: fill in
  DES_ncbc_encrypt(input, output, length, schedule, ivec, enc);
}

extern void DES_ecb_encrypt_proxy(const_DES_cblock *input , DES_cblock *output , DES_key_schedule *ks ,
                                  int enc )
{
  // FIXME: fill in
  DES_ecb_encrypt(input, output, ks, enc);
}

extern void DES_ede3_cbc_encrypt_proxy(unsigned char const   *input , unsigned char *output ,
                                       long length , DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                       DES_key_schedule *ks3 , DES_cblock *ivec ,
                                       int enc )
{
  // FIXME: fill in
  DES_ede3_cbc_encrypt(input, output, length, ks1, ks2, ks3, ivec, enc);
}

extern void DES_set_key_unchecked_proxy(const_DES_cblock *key , DES_key_schedule *schedule )
{
  // FIXME: fill in
  DES_set_key_unchecked(key, schedule);
}


////////////////////////////////////////////
// AES
////////////////////////////////////////////

extern int AES_set_encrypt_key_proxy(unsigned char const   *userKey , int bits , AES_KEY *key )
{
  // FIXME: fill in
  return AES_set_encrypt_key(userKey, bits, key);
}

extern int AES_set_decrypt_key_proxy(unsigned char const   *userKey , int bits , AES_KEY *key )
{
  // FIXME: fill in
  return AES_set_decrypt_key(userKey, bits, key);
}

extern void AES_ecb_encrypt_proxy(unsigned char const   *in , unsigned char *out ,
                                  AES_KEY const   *key , int enc )
{
  // FIXME: fill in
  AES_ecb_encrypt(in, out, key, enc);
}

extern void AES_cbc_encrypt_proxy(unsigned char const   *in , unsigned char *out ,
                                  size_t length , AES_KEY const   *key , unsigned char *ivec ,
                                  int enc )
{
  // FIXME: fill in
  AES_cbc_encrypt(in, out, length, key, ivec, enc);
}



////////////////////////////////////////////
// RSA
////////////////////////////////////////////


RSA *RSA_generate_key_proxy(int bits , unsigned long e , void (*callback)(int  ,
                                                                                 int  ,
                                                                                 void * ) ,
                                   void *cb_arg )
{
  // FIXME: fill in
  return RSA_generate_key(bits, e, callback, cb_arg);
}


extern RSA *RSAPrivateKey_dup_proxy(RSA *rsa )
{
  RSA * ret = RSAPrivateKey_dup(rsa);

  copy_ctx(ret, rsa);

  return ret;
}

/*
 * RSA_verify() verifies that the signature sigbuf of size siglen matches a given message digest m
 * of size m_len. type denotes the message digest algorithm that was used to generate the signature.
 * rsa is the signer's public key.
 *
 * RSA_verify() returns 1 on successful verification, 0 otherwise.
 */
#if OPENSSL_MAJOR == 0
  extern int RSA_verify_proxy(int type , unsigned char const   *m , unsigned int m_length ,
                              unsigned char *sigbuf , unsigned int siglen , RSA *rsa )
#else
  extern int RSA_verify_proxy(int type , unsigned char const   *m , unsigned int m_length ,
                              unsigned char const   *sigbuf , unsigned int siglen , RSA *rsa )
#endif
{
  int ret = RSA_verify(type, m, m_length, sigbuf, siglen, rsa);

  // FIXME: Change this for symbolic tracing
  if(ret == 1)
  {
    load_buf(m, m_length, "msg");
    load_ctx(rsa, "id", "pkey");

    SymN("RSA_verify", 2);
    Hint("sig");
    assume_len(&siglen, false, sizeof(siglen));

    store_buf(sigbuf);
  }

  return ret;
}



/*
 * RSA_public_encrypt() encrypts the flen bytes at from (usually a session key)
 * using the public key rsa and stores the ciphertext in to. to must point to RSA_size(rsa) bytes of memory.
 *
 * RSA_public_encrypt() returns the size of the encrypted data (i.e., RSA_size(rsa)).
 */
extern int RSA_public_encrypt_proxy(int flen , unsigned char const   *from , unsigned char *to ,
                                    RSA *rsa , int padding )
{
  int ret = RSA_public_encrypt(flen, from, to, rsa, padding);

  load_buf(from, flen, "plain");
  load_ctx(rsa, "id", "pkey");

  SymN("RSA_public_encrypt", 2);
  Hint("enc");
  assume_len(&ret, true, sizeof(ret));
  Nondet();

  store_buf(to);

  return ret;
}

/*
 * RSA_private_decrypt() decrypts the flen bytes at from using the private key rsa
 * and stores the plaintext in to.
 * to must point to a memory section large enough to hold the decrypted data
 * (which is smaller than RSA_size(rsa)). padding is the padding mode that was used to encrypt the data.
 *
 * RSA_private_decrypt() returns the size of the recovered plaintext.
 */
extern int RSA_private_decrypt_proxy(int flen , unsigned char const   *from , unsigned char *to ,
                                     RSA *rsa , int padding )
{
  // NB: it is possible that from and to is the same pointer
  load_buf(from, flen, "enc");
  load_ctx(rsa, "id", "pkey");

  int ret = RSA_private_decrypt(flen, from, to, rsa, padding);

  // FIXME: relying on concrete value?
  SymN("RSA_private_decrypt", 2);
  Hint("dec");
  assume_len(&ret, true, sizeof(ret));

  store_buf(to);

  return ret;
}

/*
 * RSA_sign() signs the message digest m of size m_len using the private key rsa
 * as specified in PKCS #1 v2.0. It stores the signature in sigret and the signature size in siglen.
 * sigret must point to RSA_size(rsa) bytes of memory.
 *
 * type denotes the message digest algorithm that was used to generate m.
 * It usually is one of NID_sha1, NID_ripemd160 and NID_md5; see objects for details.
 * If type is NID_md5_sha1, an SSL signature (MD5 and SHA1 message digests with PKCS #1 padding
 * and no algorithm identifier) is created.
 */
extern int RSA_sign_proxy(int type , unsigned char const   *m , unsigned int m_length ,
                          unsigned char *sigret , unsigned int *siglen , RSA *rsa )
{
  int ret = RSA_sign(type, m, m_length, sigret, siglen, rsa);

  load_buf(m, m_length, "msg");
  load_ctx(rsa, "id", "pkey");

  SymN("RSA_sign", 2);
  Hint("sig");
  assume_len(siglen, false, sizeof(*siglen));
  Nondet();

  store_buf(sigret);

  return ret;
}

extern void RSA_blinding_off_proxy(RSA *rsa )
{
  // FIXME: fill in
  RSA_blinding_off(rsa);
}

void ERR_load_crypto_strings_proxy(void)
{
  mute();
  ERR_load_crypto_strings();
  unmute();
}

void ERR_print_errors_fp_proxy(FILE *fp )
{
  mute();
  ERR_print_errors_fp(fp);
  unmute();
}
