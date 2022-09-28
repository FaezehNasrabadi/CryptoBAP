
#include "openssl_proxies.h"

#include "common.h"
#include "interface.h"

extern int dsa_init(DSA *dsa);

// Hide the modification of the flags field.
int dsa_init_proxy(DSA *dsa)
{
  mute();
  int ret = dsa_init(dsa);
  unmute();

  ret = 1;
  return ret;
}


/*
 * We do splitting into r and s because it was used in the metering protocol.
 * For well-behaved protocols it should be enough to just use the sig attribute.
 */
DSA_SIG *dsa_do_sign_proxy(unsigned char const   *dgst , int dlen , DSA *dsa )
{
  mute();
  DSA_SIG * ret = dsa_do_sign(dgst, dlen, dsa);
  unmute();

//  symL("dsa_sign_new_bn");
//  store_buf((unsigned char *) &(ret->r), sizeof(ret->r), "r");
//  symL("dsa_sign_new_bn");
//  store_buf((unsigned char *) &(ret->s), sizeof(ret->s), "s");

  // CR: eventually we want to say that the length of the signature is at most
  // dlen * 2 + overhead, but right now this is awkward to express.
  if(dlen != 32)
    proxy_fail("wrong digest length");

  size_t max_sig_len = 100;
  size_t max_half_sig_len = 50;

  fresh_ptr(sizeof(DSA_SIG));
  store_buf(&ret);

  fresh_ptr(sizeof(BIGNUM));
  store_buf((unsigned char *) &(ret->r));
  fresh_ptr(sizeof(BIGNUM));
  store_buf((unsigned char *) &(ret->s));

  load_buf(dgst, dlen, "dgst");
  load_ctx(dsa, "skey", "skey");
  newT("DSA_seed", "seed");
  SymN("DSA_sign", 3);
  // CR: what are conditions for successful signing?
  // Try test_intype instead, also below.
  assume_intype("bitstring");
  assume_len_at_most(&max_sig_len , false, sizeof(max_sig_len));
  Hint("dsa_sig");
  store_ctx(ret, "sig");


  load_ctx(ret, "sig", NULL);
  SymN("DSA_r", 1);
  assume_intype("bitstring");
  assume_len_at_most(&max_half_sig_len , false, sizeof(max_half_sig_len));
  Hint("dsa_sig_r");
  store_ctx(ret->r, "val");

  load_ctx(ret, "sig", NULL);
  SymN("DSA_s", 1);
  assume_intype("bitstring");
  assume_len_at_most(&max_half_sig_len , false, sizeof(max_half_sig_len));
  Hint("dsa_sig_s");
  store_ctx(ret->s, "val");

  return ret;
}


int dsa_do_verify_proxy(unsigned char const   *dgst , int dgst_len ,
                        DSA_SIG *sig , DSA *dsa )
{
  mute();
  int ret = dsa_do_verify(dgst, dgst_len, sig, dsa);
  unmute();

  // FIXME: only do it if no sig is present already
  load_ctx(sig->r, "val", "dsa_sig_r");
  load_ctx(sig->s, "val", "dsa_sig_s");

  SymN("DSA_combine", 2);
  assume_intype("bitstring");
  Hint("dsa_sig");

  store_ctx(sig, "sig");

  load_buf(dgst, dgst_len, "dgst");
  load_ctx(dsa, "pkey", "pkey");
  load_ctx(sig, "sig", "sig");
  SymN("DSA_verify", 3);
  assume_intype("bitstring");
  Hint("sig_verification");
  size_t ret_len = sizeof(ret);
  assume_len(&ret_len, false, sizeof(ret_len));
  store_buf((unsigned char *) &ret);

  return ret;
}

/*

// Bring back when you are crestifying OpenSSL as well.

#if OPENSSL_MAJOR == 0

  extern void tls1_PRF(EVP_MD const   *md5 , EVP_MD const   *sha1 , unsigned char *label ,
                           int label_len , unsigned char const   *sec , int slen ,
                           unsigned char *out1 , unsigned char *out2 , int olen );

  extern void tls1_PRF_proxy(EVP_MD const   *md5 , EVP_MD const   *sha1 , unsigned char *label ,
                             int label_len , unsigned char const   *sec , int slen ,
                             unsigned char *out1 , unsigned char *out2 , int olen )
  {
    tls1_PRF(md5, sha1, label, label_len, sec, slen, out1, out2, olen);

    load_buf(label, label_len, "label");
    load_buf(sec, slen, "secret");
    symL("tls1_PRF");
    store_buf(out1, olen, "prf_result");
  }

  extern void tls1_P_hash(EVP_MD const   *md , unsigned char const   *sec , int sec_len ,
                                unsigned char *seed , int seed_len , unsigned char *out ,
                                int olen );

  extern void tls1_P_hash_proxy(EVP_MD const   *md , unsigned char const   *sec , int sec_len ,
                                unsigned char *seed , int seed_len , unsigned char *out ,
                                int olen )
  {
    tls1_P_hash(md, sec, sec_len, seed, seed_len, out, olen);

    load_buf(seed, seed_len, "seed");
    if(sec != NULL) load_buf(sec, sec_len, "secret");
    symL("tls1_P_hash");
    store_buf(out, olen, "P_hash_result");
  }



#else
  extern void tls1_PRF_proxy(long digest_mask,
                       const void *seed1, int seed1_len,
                       const void *seed2, int seed2_len,
                       const void *seed3, int seed3_len,
                       const void *seed4, int seed4_len,
                       const void *seed5, int seed5_len,
                       const unsigned char *sec, int slen,
                       unsigned char *out1,
                       unsigned char *out2, int olen)
  {
    tls1_PRF(digest_mask,
             seed1, seed1_len, seed2, seed2_len,
             seed3, seed3_len, seed4, seed4_len,
             seed5, seed5_len, sec, slen, out1, out2, olen);

    if(seed1 != NULL)
      load_buf((unsigned char*) seed1, seed1_len, "seed");
    if(seed2 != NULL)
      load_buf((unsigned char*) seed2, seed2_len, "seed");
    if(seed3 != NULL)
      load_buf((unsigned char*) seed3, seed3_len, "seed");
    if(seed4 != NULL)
      load_buf((unsigned char*) seed4, seed4_len, "seed");
    if(seed5 != NULL)
      load_buf((unsigned char*) seed5, seed5_len, "seed");
    if(sec != NULL)
      load_buf((unsigned char*) sec, slen, "secret");
    symL("tls1_PRF", "prf_result", olen, false);
    store_buf(out1);
  }

  void tls1_P_hash_proxy(const EVP_MD *md, const unsigned char *sec,
                          int sec_len,
                          const void *seed1, int seed1_len,
                          const void *seed2, int seed2_len,
                          const void *seed3, int seed3_len,
                          const void *seed4, int seed4_len,
                          const void *seed5, int seed5_len,
                          unsigned char *out, int olen)
  {
    tls1_P_hash(md, sec, sec_len,
                seed1, seed1_len, seed2, seed2_len,
                seed3, seed3_len, seed4, seed4_len,
                seed5, seed5_len, out, olen);

    load_buf((unsigned char*) seed1, seed1_len, "seed1");
    load_buf((unsigned char*) seed2, seed2_len, "seed2");
    load_buf((unsigned char*) seed3, seed3_len, "seed3");
    load_buf((unsigned char*) seed4, seed4_len, "seed4");
    load_buf((unsigned char*) seed5, seed5_len, "seed5");
    if(sec != NULL) load_buf((unsigned char*) sec, sec_len, "secret");
    symL("tls1_P_hash", "P_hash_result", olen, false);
    store_buf(out);
  }
#endif

*/
