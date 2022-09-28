# 1 "./openssl_proxies_internal.cil.c"
# 1 "/home/faezeh/csec-modex/proxies//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "./openssl_proxies_internal.cil.c"



void __CrestInit(void) ;
extern void __CrestAssumeDefined(void) __attribute__((__crest_skip__)) ;
extern void __CrestTruth(void) __attribute__((__crest_skip__)) ;
extern void __CrestDone(void) __attribute__((__crest_skip__)) ;
extern void __CrestLocation(char const *strVal ) __attribute__((__crest_skip__)) ;
extern void __CrestIndexOffset(char const *strVal ) __attribute__((__crest_skip__)) ;
extern void __CrestFieldOffset(char const *strVal ) __attribute__((__crest_skip__)) ;
extern void __CrestLoadStackPtr(char const *name ) __attribute__((__crest_skip__)) ;
extern void __CrestSetPtrStep(void) __attribute__((__crest_skip__)) ;
extern void __CrestLoadTypeSize(char const *strVal ) __attribute__((__crest_skip__)) ;
extern void __CrestLoadChar(char chrVal ) __attribute__((__crest_skip__)) ;
extern void __CrestLoadCString(char const *strVal ) __attribute__((__crest_skip__)) ;
extern void __CrestLoadMem(void) __attribute__((__crest_skip__)) ;
extern void __CrestBS(unsigned char b , long long val ) __attribute__((__crest_skip__)) ;
extern void __CrestLoadInt(long long val ) __attribute__((__crest_skip__)) ;
extern void __CrestStore(void) __attribute__((__crest_skip__)) ;
extern void __CrestReturn(unsigned char b ) __attribute__((__crest_skip__)) ;
extern void __CrestCallOpaque(char const *name , void (*funPtr)() , long long val ) __attribute__((__crest_skip__)) ;
extern void __CrestCall(char const *name , void (*funPtr)() , long long val ) __attribute__((__crest_skip__)) ;
extern void __CrestBranch(unsigned char b ) __attribute__((__crest_skip__)) ;
extern void __CrestNondet(void) __attribute__((__crest_skip__)) ;
extern void __CrestUnmute(void) __attribute__((__crest_skip__)) ;
extern void __CrestMute(void) __attribute__((__crest_skip__)) ;
extern void __CrestApply(char const *op ) __attribute__((__crest_skip__)) ;
extern void __CrestClear(long long val ) __attribute__((__crest_skip__)) ;
extern void __CrestInvoke(void (*funPtr)() ) __attribute__((__crest_skip__)) ;

typedef unsigned long size_t;

typedef long __time_t;

typedef long __suseconds_t;

typedef __time_t time_t;

struct timeval {
   __time_t tv_sec ;
   __suseconds_t tv_usec ;
};

struct stack_st {
   int num ;
   char **data ;
   int sorted ;
   int num_alloc ;
   int (*comp)(void const * , void const * ) ;
};

typedef struct stack_st _STACK;

struct asn1_string_st;

typedef struct asn1_string_st ASN1_INTEGER;

typedef struct asn1_string_st ASN1_ENUMERATED;

typedef struct asn1_string_st ASN1_BIT_STRING;

typedef struct asn1_string_st ASN1_OCTET_STRING;

typedef struct asn1_string_st ASN1_PRINTABLESTRING;

typedef struct asn1_string_st ASN1_T61STRING;

typedef struct asn1_string_st ASN1_IA5STRING;

typedef struct asn1_string_st ASN1_GENERALSTRING;

typedef struct asn1_string_st ASN1_UNIVERSALSTRING;

typedef struct asn1_string_st ASN1_BMPSTRING;

typedef struct asn1_string_st ASN1_UTCTIME;

typedef struct asn1_string_st ASN1_TIME;

typedef struct asn1_string_st ASN1_GENERALIZEDTIME;

typedef struct asn1_string_st ASN1_VISIBLESTRING;

typedef struct asn1_string_st ASN1_UTF8STRING;

typedef struct asn1_string_st ASN1_STRING;

typedef int ASN1_BOOLEAN;

struct asn1_object_st;

typedef struct asn1_object_st ASN1_OBJECT;

struct bignum_st;

typedef struct bignum_st BIGNUM;

struct bignum_ctx;

typedef struct bignum_ctx BN_CTX;

struct bn_blinding_st;

typedef struct bn_blinding_st BN_BLINDING;

struct bn_mont_ctx_st;

typedef struct bn_mont_ctx_st BN_MONT_CTX;

struct bn_gencb_st;

typedef struct bn_gencb_st BN_GENCB;

struct buf_mem_st;

typedef struct buf_mem_st BUF_MEM;

struct evp_cipher_st;

typedef struct evp_cipher_st EVP_CIPHER;

struct evp_cipher_ctx_st;

typedef struct evp_cipher_ctx_st EVP_CIPHER_CTX;

struct env_md_st;

typedef struct env_md_st EVP_MD;

struct env_md_ctx_st;

typedef struct env_md_ctx_st EVP_MD_CTX;

struct evp_pkey_st;

typedef struct evp_pkey_st EVP_PKEY;

struct evp_pkey_asn1_method_st;

typedef struct evp_pkey_asn1_method_st EVP_PKEY_ASN1_METHOD;

struct evp_pkey_ctx_st;

typedef struct evp_pkey_ctx_st EVP_PKEY_CTX;

struct dh_st;

typedef struct dh_st DH;

struct dh_method;

typedef struct dh_method DH_METHOD;

struct dsa_st;

typedef struct dsa_st DSA;

struct dsa_method;

typedef struct dsa_method DSA_METHOD;

struct rsa_st;

typedef struct rsa_st RSA;

struct rsa_meth_st;

typedef struct rsa_meth_st RSA_METHOD;

struct x509_st;

typedef struct x509_st X509;

struct X509_algor_st;

typedef struct X509_algor_st X509_ALGOR;

struct X509_crl_st;

typedef struct X509_crl_st X509_CRL;

struct x509_crl_method_st;

typedef struct x509_crl_method_st X509_CRL_METHOD;

struct X509_name_st;

typedef struct X509_name_st X509_NAME;

struct X509_pubkey_st;

typedef struct X509_pubkey_st X509_PUBKEY;

struct x509_store_st;

typedef struct x509_store_st X509_STORE;

struct x509_store_ctx_st;

typedef struct x509_store_ctx_st X509_STORE_CTX;

struct ui_method_st;

typedef struct ui_method_st UI_METHOD;

struct engine_st;

typedef struct engine_st ENGINE;

struct ssl_st;

typedef struct ssl_st SSL;

struct ssl_ctx_st;

typedef struct ssl_ctx_st SSL_CTX;

struct X509_POLICY_TREE_st;

typedef struct X509_POLICY_TREE_st X509_POLICY_TREE;

struct X509_POLICY_CACHE_st;

typedef struct X509_POLICY_CACHE_st X509_POLICY_CACHE;

struct AUTHORITY_KEYID_st;

typedef struct AUTHORITY_KEYID_st AUTHORITY_KEYID;

struct ISSUING_DIST_POINT_st;

typedef struct ISSUING_DIST_POINT_st ISSUING_DIST_POINT;

struct NAME_CONSTRAINTS_st;

typedef struct NAME_CONSTRAINTS_st NAME_CONSTRAINTS;

struct crypto_ex_data_st;

typedef struct crypto_ex_data_st CRYPTO_EX_DATA;

struct bio_st;

struct stack_st_void;

struct crypto_ex_data_st {
   struct stack_st_void *sk ;
   int dummy ;
};

struct stack_st_void {
   _STACK stack ;
};

struct comp_ctx_st;

typedef struct comp_ctx_st COMP_CTX;

struct comp_method_st {
   int type ;
   char const *name ;
   int (*init)(COMP_CTX *ctx ) ;
   void (*finish)(COMP_CTX *ctx ) ;
   int (*compress)(COMP_CTX *ctx , unsigned char *out , unsigned int olen , unsigned char *in ,
                   unsigned int ilen ) ;
   int (*expand)(COMP_CTX *ctx , unsigned char *out , unsigned int olen , unsigned char *in ,
                 unsigned int ilen ) ;
   long (*ctrl)(void) ;
   long (*callback_ctrl)(void) ;
};

typedef struct comp_method_st COMP_METHOD;

struct comp_ctx_st {
   COMP_METHOD *meth ;
   unsigned long compress_in ;
   unsigned long compress_out ;
   unsigned long expand_in ;
   unsigned long expand_out ;
   CRYPTO_EX_DATA ex_data ;
};

typedef struct bio_st BIO;

typedef void bio_info_cb(struct bio_st * , int , char const * , int , long ,
                         long );

struct bio_method_st {
   int type ;
   char const *name ;
   int (*bwrite)(BIO * , char const * , int ) ;
   int (*bread)(BIO * , char * , int ) ;
   int (*bputs)(BIO * , char const * ) ;
   int (*bgets)(BIO * , char * , int ) ;
   long (*ctrl)(BIO * , int , long , void * ) ;
   int (*create)(BIO * ) ;
   int (*destroy)(BIO * ) ;
   long (*callback_ctrl)(BIO * , int , bio_info_cb * ) ;
};

typedef struct bio_method_st BIO_METHOD;

struct bio_st {
   BIO_METHOD *method ;
   long (*callback)(struct bio_st * , int , char const * , int , long , long ) ;
   char *cb_arg ;
   int init ;
   int shutdown ;
   int flags ;
   int retry_reason ;
   int num ;
   void *ptr ;
   struct bio_st *next_bio ;
   struct bio_st *prev_bio ;
   int references ;
   unsigned long num_read ;
   unsigned long num_write ;
   CRYPTO_EX_DATA ex_data ;
};

struct buf_mem_st {
   size_t length ;
   char *data ;
   size_t max ;
};

struct bignum_st {
   unsigned long *d ;
   int top ;
   int dmax ;
   int neg ;
   int flags ;
};

struct bn_mont_ctx_st {
   int ri ;
   BIGNUM RR ;
   BIGNUM N ;
   BIGNUM Ni ;
   unsigned long n0[2] ;
   int flags ;
};

union __anonunion_cb_27 {
   void (*cb_1)(int , int , void * ) ;
   int (*cb_2)(int , int , BN_GENCB * ) ;
};

struct bn_gencb_st {
   unsigned int ver ;
   void *arg ;
   union __anonunion_cb_27 cb ;
};

struct X509_algor_st;

struct stack_st_X509_ALGOR {
   _STACK stack ;
};

struct asn1_object_st {
   char const *sn ;
   char const *ln ;
   int nid ;
   int length ;
   unsigned char const *data ;
   int flags ;
};

struct asn1_string_st {
   int length ;
   int type ;
   unsigned char *data ;
   long flags ;
};

struct ASN1_ENCODING_st {
   unsigned char *enc ;
   long len ;
   int modified ;
};

typedef struct ASN1_ENCODING_st ASN1_ENCODING;

struct ASN1_VALUE_st;

typedef struct ASN1_VALUE_st ASN1_VALUE;

union __anonunion_value_28 {
   char *ptr ;
   ASN1_BOOLEAN boolean ;
   ASN1_STRING *asn1_string ;
   ASN1_OBJECT *object ;
   ASN1_INTEGER *integer ;
   ASN1_ENUMERATED *enumerated ;
   ASN1_BIT_STRING *bit_string ;
   ASN1_OCTET_STRING *octet_string ;
   ASN1_PRINTABLESTRING *printablestring ;
   ASN1_T61STRING *t61string ;
   ASN1_IA5STRING *ia5string ;
   ASN1_GENERALSTRING *generalstring ;
   ASN1_BMPSTRING *bmpstring ;
   ASN1_UNIVERSALSTRING *universalstring ;
   ASN1_UTCTIME *utctime ;
   ASN1_GENERALIZEDTIME *generalizedtime ;
   ASN1_VISIBLESTRING *visiblestring ;
   ASN1_UTF8STRING *utf8string ;
   ASN1_STRING *set ;
   ASN1_STRING *sequence ;
   ASN1_VALUE *asn1_value ;
};

struct asn1_type_st {
   int type ;
   union __anonunion_value_28 value ;
};

typedef struct asn1_type_st ASN1_TYPE;

struct stack_st_ASN1_OBJECT {
   _STACK stack ;
};

struct ec_key_st;

union __anonunion_pkey_29 {
   char *ptr ;
   struct rsa_st *rsa ;
   struct dsa_st *dsa ;
   struct dh_st *dh ;
   struct ec_key_st *ec ;
};

struct stack_st_X509_ATTRIBUTE;

struct evp_pkey_st {
   int type ;
   int save_type ;
   int references ;
   EVP_PKEY_ASN1_METHOD const *ameth ;
   ENGINE *engine ;
   union __anonunion_pkey_29 pkey ;
   int save_parameters ;
   struct stack_st_X509_ATTRIBUTE *attributes ;
};

struct env_md_st {
   int type ;
   int pkey_type ;
   int md_size ;
   unsigned long flags ;
   int (*init)(EVP_MD_CTX *ctx ) ;
   int (*update)(EVP_MD_CTX *ctx , void const *data , size_t count ) ;
   int (*final)(EVP_MD_CTX *ctx , unsigned char *md ) ;
   int (*copy)(EVP_MD_CTX *to , EVP_MD_CTX const *from ) ;
   int (*cleanup)(EVP_MD_CTX *ctx ) ;
   int (*sign)(int type , unsigned char const *m , unsigned int m_length , unsigned char *sigret ,
               unsigned int *siglen , void *key ) ;
   int (*verify)(int type , unsigned char const *m , unsigned int m_length , unsigned char const *sigbuf ,
                 unsigned int siglen , void *key ) ;
   int required_pkey_type[5] ;
   int block_size ;
   int ctx_size ;
   int (*md_ctrl)(EVP_MD_CTX *ctx , int cmd , int p1 , void *p2 ) ;
};

struct env_md_ctx_st {
   EVP_MD const *digest ;
   ENGINE *engine ;
   unsigned long flags ;
   void *md_data ;
   EVP_PKEY_CTX *pctx ;
   int (*update)(EVP_MD_CTX *ctx , void const *data , size_t count ) ;
};

struct evp_cipher_st {
   int nid ;
   int block_size ;
   int key_len ;
   int iv_len ;
   unsigned long flags ;
   int (*init)(EVP_CIPHER_CTX *ctx , unsigned char const *key , unsigned char const *iv ,
               int enc ) ;
   int (*do_cipher)(EVP_CIPHER_CTX *ctx , unsigned char *out , unsigned char const *in ,
                    size_t inl ) ;
   int (*cleanup)(EVP_CIPHER_CTX * ) ;
   int ctx_size ;
   int (*set_asn1_parameters)(EVP_CIPHER_CTX * , ASN1_TYPE * ) ;
   int (*get_asn1_parameters)(EVP_CIPHER_CTX * , ASN1_TYPE * ) ;
   int (*ctrl)(EVP_CIPHER_CTX * , int type , int arg , void *ptr ) ;
   void *app_data ;
};

struct evp_cipher_ctx_st {
   EVP_CIPHER const *cipher ;
   ENGINE *engine ;
   int encrypt ;
   int buf_len ;
   unsigned char oiv[16] ;
   unsigned char iv[16] ;
   unsigned char buf[32] ;
   int num ;
   void *app_data ;
   int key_len ;
   unsigned long flags ;
   void *cipher_data ;
   int final_used ;
   int block_mask ;
   unsigned char final[32] ;
};

struct rsa_st;

struct dsa_st;

struct dh_st;

struct ec_key_st;

typedef struct ec_key_st EC_KEY;

struct rsa_meth_st {
   char const *name ;
   int (*rsa_pub_enc)(int flen , unsigned char const *from , unsigned char *to ,
                      RSA *rsa , int padding ) ;
   int (*rsa_pub_dec)(int flen , unsigned char const *from , unsigned char *to ,
                      RSA *rsa , int padding ) ;
   int (*rsa_priv_enc)(int flen , unsigned char const *from , unsigned char *to ,
                       RSA *rsa , int padding ) ;
   int (*rsa_priv_dec)(int flen , unsigned char const *from , unsigned char *to ,
                       RSA *rsa , int padding ) ;
   int (*rsa_mod_exp)(BIGNUM *r0 , BIGNUM const *I , RSA *rsa , BN_CTX *ctx ) ;
   int (*bn_mod_exp)(BIGNUM *r , BIGNUM const *a , BIGNUM const *p , BIGNUM const *m ,
                     BN_CTX *ctx , BN_MONT_CTX *m_ctx ) ;
   int (*init)(RSA *rsa ) ;
   int (*finish)(RSA *rsa ) ;
   int flags ;
   char *app_data ;
   int (*rsa_sign)(int type , unsigned char const *m , unsigned int m_length , unsigned char *sigret ,
                   unsigned int *siglen , RSA const *rsa ) ;
   int (*rsa_verify)(int dtype , unsigned char const *m , unsigned int m_length ,
                     unsigned char const *sigbuf , unsigned int siglen , RSA const *rsa ) ;
   int (*rsa_keygen)(RSA *rsa , int bits , BIGNUM *e , BN_GENCB *cb ) ;
};

struct rsa_st {
   int pad ;
   long version ;
   RSA_METHOD const *meth ;
   ENGINE *engine ;
   BIGNUM *n ;
   BIGNUM *e ;
   BIGNUM *d ;
   BIGNUM *p ;
   BIGNUM *q ;
   BIGNUM *dmp1 ;
   BIGNUM *dmq1 ;
   BIGNUM *iqmp ;
   CRYPTO_EX_DATA ex_data ;
   int references ;
   int flags ;
   BN_MONT_CTX *_method_mod_n ;
   BN_MONT_CTX *_method_mod_p ;
   BN_MONT_CTX *_method_mod_q ;
   char *bignum_data ;
   BN_BLINDING *blinding ;
   BN_BLINDING *mt_blinding ;
};

struct dh_method {
   char const *name ;
   int (*generate_key)(DH *dh ) ;
   int (*compute_key)(unsigned char *key , BIGNUM const *pub_key , DH *dh ) ;
   int (*bn_mod_exp)(DH const *dh , BIGNUM *r , BIGNUM const *a , BIGNUM const *p ,
                     BIGNUM const *m , BN_CTX *ctx , BN_MONT_CTX *m_ctx ) ;
   int (*init)(DH *dh ) ;
   int (*finish)(DH *dh ) ;
   int flags ;
   char *app_data ;
   int (*generate_params)(DH *dh , int prime_len , int generator , BN_GENCB *cb ) ;
};

struct dh_st {
   int pad ;
   int version ;
   BIGNUM *p ;
   BIGNUM *g ;
   long length ;
   BIGNUM *pub_key ;
   BIGNUM *priv_key ;
   int flags ;
   BN_MONT_CTX *method_mont_p ;
   BIGNUM *q ;
   BIGNUM *j ;
   unsigned char *seed ;
   int seedlen ;
   BIGNUM *counter ;
   int references ;
   CRYPTO_EX_DATA ex_data ;
   DH_METHOD const *meth ;
   ENGINE *engine ;
};

struct DSA_SIG_st {
   BIGNUM *r ;
   BIGNUM *s ;
};

typedef struct DSA_SIG_st DSA_SIG;

struct dsa_method {
   char const *name ;
   DSA_SIG *(*dsa_do_sign)(unsigned char const *dgst , int dlen , DSA *dsa ) ;
   int (*dsa_sign_setup)(DSA *dsa , BN_CTX *ctx_in , BIGNUM **kinvp , BIGNUM **rp ) ;
   int (*dsa_do_verify)(unsigned char const *dgst , int dgst_len , DSA_SIG *sig ,
                        DSA *dsa ) ;
   int (*dsa_mod_exp)(DSA *dsa , BIGNUM *rr , BIGNUM *a1 , BIGNUM *p1 , BIGNUM *a2 ,
                      BIGNUM *p2 , BIGNUM *m , BN_CTX *ctx , BN_MONT_CTX *in_mont ) ;
   int (*bn_mod_exp)(DSA *dsa , BIGNUM *r , BIGNUM *a , BIGNUM const *p , BIGNUM const *m ,
                     BN_CTX *ctx , BN_MONT_CTX *m_ctx ) ;
   int (*init)(DSA *dsa ) ;
   int (*finish)(DSA *dsa ) ;
   int flags ;
   char *app_data ;
   int (*dsa_paramgen)(DSA *dsa , int bits , unsigned char const *seed , int seed_len ,
                       int *counter_ret , unsigned long *h_ret , BN_GENCB *cb ) ;
   int (*dsa_keygen)(DSA *dsa ) ;
};

struct dsa_st {
   int pad ;
   long version ;
   int write_params ;
   BIGNUM *p ;
   BIGNUM *q ;
   BIGNUM *g ;
   BIGNUM *pub_key ;
   BIGNUM *priv_key ;
   BIGNUM *kinv ;
   BIGNUM *r ;
   int flags ;
   BN_MONT_CTX *method_mont_p ;
   int references ;
   CRYPTO_EX_DATA ex_data ;
   DSA_METHOD const *meth ;
   ENGINE *engine ;
};

struct X509_algor_st {
   ASN1_OBJECT *algorithm ;
   ASN1_TYPE *parameter ;
};

struct X509_val_st {
   ASN1_TIME *notBefore ;
   ASN1_TIME *notAfter ;
};

typedef struct X509_val_st X509_VAL;

struct X509_pubkey_st {
   X509_ALGOR *algor ;
   ASN1_BIT_STRING *public_key ;
   EVP_PKEY *pkey ;
};

struct stack_st_X509_NAME_ENTRY {
   _STACK stack ;
};

struct X509_name_st {
   struct stack_st_X509_NAME_ENTRY *entries ;
   int modified ;
   BUF_MEM *bytes ;
   unsigned char *canon_enc ;
   int canon_enclen ;
};

struct stack_st_X509_NAME {
   _STACK stack ;
};

struct stack_st_X509_EXTENSION;

typedef struct stack_st_X509_EXTENSION X509_EXTENSIONS;

struct stack_st_X509_EXTENSION {
   _STACK stack ;
};

struct stack_st_X509_ATTRIBUTE {
   _STACK stack ;
};

struct x509_cinf_st {
   ASN1_INTEGER *version ;
   ASN1_INTEGER *serialNumber ;
   X509_ALGOR *signature ;
   X509_NAME *issuer ;
   X509_VAL *validity ;
   X509_NAME *subject ;
   X509_PUBKEY *key ;
   ASN1_BIT_STRING *issuerUID ;
   ASN1_BIT_STRING *subjectUID ;
   struct stack_st_X509_EXTENSION *extensions ;
   ASN1_ENCODING enc ;
};

typedef struct x509_cinf_st X509_CINF;

struct x509_cert_aux_st {
   struct stack_st_ASN1_OBJECT *trust ;
   struct stack_st_ASN1_OBJECT *reject ;
   ASN1_UTF8STRING *alias ;
   ASN1_OCTET_STRING *keyid ;
   struct stack_st_X509_ALGOR *other ;
};

typedef struct x509_cert_aux_st X509_CERT_AUX;

struct stack_st_DIST_POINT;

struct stack_st_GENERAL_NAME;

struct x509_st {
   X509_CINF *cert_info ;
   X509_ALGOR *sig_alg ;
   ASN1_BIT_STRING *signature ;
   int valid ;
   int references ;
   char *name ;
   CRYPTO_EX_DATA ex_data ;
   long ex_pathlen ;
   long ex_pcpathlen ;
   unsigned long ex_flags ;
   unsigned long ex_kusage ;
   unsigned long ex_xkusage ;
   unsigned long ex_nscert ;
   ASN1_OCTET_STRING *skid ;
   AUTHORITY_KEYID *akid ;
   X509_POLICY_CACHE *policy_cache ;
   struct stack_st_DIST_POINT *crldp ;
   struct stack_st_GENERAL_NAME *altname ;
   NAME_CONSTRAINTS *nc ;
   unsigned char sha1_hash[20] ;
   X509_CERT_AUX *aux ;
};

struct stack_st_X509 {
   _STACK stack ;
};

struct stack_st_X509_REVOKED {
   _STACK stack ;
};

struct X509_crl_info_st {
   ASN1_INTEGER *version ;
   X509_ALGOR *sig_alg ;
   X509_NAME *issuer ;
   ASN1_TIME *lastUpdate ;
   ASN1_TIME *nextUpdate ;
   struct stack_st_X509_REVOKED *revoked ;
   struct stack_st_X509_EXTENSION *extensions ;
   ASN1_ENCODING enc ;
};

typedef struct X509_crl_info_st X509_CRL_INFO;

struct stack_st_GENERAL_NAMES;

struct X509_crl_st {
   X509_CRL_INFO *crl ;
   X509_ALGOR *sig_alg ;
   ASN1_BIT_STRING *signature ;
   int references ;
   int flags ;
   AUTHORITY_KEYID *akid ;
   ISSUING_DIST_POINT *idp ;
   int idp_flags ;
   int idp_reasons ;
   ASN1_INTEGER *crl_number ;
   ASN1_INTEGER *base_crl_number ;
   unsigned char sha1_hash[20] ;
   struct stack_st_GENERAL_NAMES *issuers ;
   X509_CRL_METHOD const *meth ;
   void *meth_data ;
};

struct stack_st_X509_CRL {
   _STACK stack ;
};

struct stack_st_X509_LOOKUP {
   _STACK stack ;
};

struct stack_st_X509_OBJECT {
   _STACK stack ;
};

struct X509_VERIFY_PARAM_ID_st;

typedef struct X509_VERIFY_PARAM_ID_st X509_VERIFY_PARAM_ID;

struct X509_VERIFY_PARAM_st {
   char *name ;
   time_t check_time ;
   unsigned long inh_flags ;
   unsigned long flags ;
   int purpose ;
   int trust ;
   int depth ;
   struct stack_st_ASN1_OBJECT *policies ;
   X509_VERIFY_PARAM_ID *id ;
};

typedef struct X509_VERIFY_PARAM_st X509_VERIFY_PARAM;

struct x509_store_st {
   int cache ;
   struct stack_st_X509_OBJECT *objs ;
   struct stack_st_X509_LOOKUP *get_cert_methods ;
   X509_VERIFY_PARAM *param ;
   int (*verify)(X509_STORE_CTX *ctx ) ;
   int (*verify_cb)(int ok , X509_STORE_CTX *ctx ) ;
   int (*get_issuer)(X509 **issuer , X509_STORE_CTX *ctx , X509 *x ) ;
   int (*check_issued)(X509_STORE_CTX *ctx , X509 *x , X509 *issuer ) ;
   int (*check_revocation)(X509_STORE_CTX *ctx ) ;
   int (*get_crl)(X509_STORE_CTX *ctx , X509_CRL **crl , X509 *x ) ;
   int (*check_crl)(X509_STORE_CTX *ctx , X509_CRL *crl ) ;
   int (*cert_crl)(X509_STORE_CTX *ctx , X509_CRL *crl , X509 *x ) ;
   struct stack_st_X509 *(*lookup_certs)(X509_STORE_CTX *ctx , X509_NAME *nm ) ;
   struct stack_st_X509_CRL *(*lookup_crls)(X509_STORE_CTX *ctx , X509_NAME *nm ) ;
   int (*cleanup)(X509_STORE_CTX *ctx ) ;
   CRYPTO_EX_DATA ex_data ;
   int references ;
};

struct x509_store_ctx_st {
   X509_STORE *ctx ;
   int current_method ;
   X509 *cert ;
   struct stack_st_X509 *untrusted ;
   struct stack_st_X509_CRL *crls ;
   X509_VERIFY_PARAM *param ;
   void *other_ctx ;
   int (*verify)(X509_STORE_CTX *ctx ) ;
   int (*verify_cb)(int ok , X509_STORE_CTX *ctx ) ;
   int (*get_issuer)(X509 **issuer , X509_STORE_CTX *ctx , X509 *x ) ;
   int (*check_issued)(X509_STORE_CTX *ctx , X509 *x , X509 *issuer ) ;
   int (*check_revocation)(X509_STORE_CTX *ctx ) ;
   int (*get_crl)(X509_STORE_CTX *ctx , X509_CRL **crl , X509 *x ) ;
   int (*check_crl)(X509_STORE_CTX *ctx , X509_CRL *crl ) ;
   int (*cert_crl)(X509_STORE_CTX *ctx , X509_CRL *crl , X509 *x ) ;
   int (*check_policy)(X509_STORE_CTX *ctx ) ;
   struct stack_st_X509 *(*lookup_certs)(X509_STORE_CTX *ctx , X509_NAME *nm ) ;
   struct stack_st_X509_CRL *(*lookup_crls)(X509_STORE_CTX *ctx , X509_NAME *nm ) ;
   int (*cleanup)(X509_STORE_CTX *ctx ) ;
   int valid ;
   int last_untrusted ;
   struct stack_st_X509 *chain ;
   X509_POLICY_TREE *tree ;
   int explicit_policy ;
   int error_depth ;
   int error ;
   X509 *current_cert ;
   X509 *current_issuer ;
   X509_CRL *current_crl ;
   int current_crl_score ;
   unsigned int current_reasons ;
   X509_STORE_CTX *parent ;
   CRYPTO_EX_DATA ex_data ;
};

typedef int pem_password_cb(char *buf , int size , int rwflag , void *userdata );

struct hmac_ctx_st {
   EVP_MD const *md ;
   EVP_MD_CTX md_ctx ;
   EVP_MD_CTX i_ctx ;
   EVP_MD_CTX o_ctx ;
   unsigned int key_length ;
   unsigned char key[128] ;
};

typedef struct hmac_ctx_st HMAC_CTX;

struct tls_session_ticket_ext_st;

typedef struct tls_session_ticket_ext_st TLS_SESSION_TICKET_EXT;

struct ssl_method_st;

typedef struct ssl_method_st SSL_METHOD;

struct ssl_cipher_st;

typedef struct ssl_cipher_st SSL_CIPHER;

struct ssl_session_st;

typedef struct ssl_session_st SSL_SESSION;

struct stack_st_SSL_CIPHER {
   _STACK stack ;
};

struct srtp_protection_profile_st {
   char const *name ;
   unsigned long id ;
};

typedef struct srtp_protection_profile_st SRTP_PROTECTION_PROFILE;

struct stack_st_SRTP_PROTECTION_PROFILE {
   _STACK stack ;
};

struct ssl_cipher_st {
   int valid ;
   char const *name ;
   unsigned long id ;
   unsigned long algorithm_mkey ;
   unsigned long algorithm_auth ;
   unsigned long algorithm_enc ;
   unsigned long algorithm_mac ;
   unsigned long algorithm_ssl ;
   unsigned long algo_strength ;
   unsigned long algorithm2 ;
   int strength_bits ;
   int alg_bits ;
};

struct ssl3_enc_method;

struct ssl_method_st {
   int version ;
   int (*ssl_new)(SSL *s ) ;
   void (*ssl_clear)(SSL *s ) ;
   void (*ssl_free)(SSL *s ) ;
   int (*ssl_accept)(SSL *s ) ;
   int (*ssl_connect)(SSL *s ) ;
   int (*ssl_read)(SSL *s , void *buf , int len ) ;
   int (*ssl_peek)(SSL *s , void *buf , int len ) ;
   int (*ssl_write)(SSL *s , void const *buf , int len ) ;
   int (*ssl_shutdown)(SSL *s ) ;
   int (*ssl_renegotiate)(SSL *s ) ;
   int (*ssl_renegotiate_check)(SSL *s ) ;
   long (*ssl_get_message)(SSL *s , int st1 , int stn , int mt , long max , int *ok ) ;
   int (*ssl_read_bytes)(SSL *s , int type , unsigned char *buf , int len , int peek ) ;
   int (*ssl_write_bytes)(SSL *s , int type , void const *buf_ , int len ) ;
   int (*ssl_dispatch_alert)(SSL *s ) ;
   long (*ssl_ctrl)(SSL *s , int cmd , long larg , void *parg ) ;
   long (*ssl_ctx_ctrl)(SSL_CTX *ctx , int cmd , long larg , void *parg ) ;
   SSL_CIPHER const *(*get_cipher_by_char)(unsigned char const *ptr ) ;
   int (*put_cipher_by_char)(SSL_CIPHER const *cipher , unsigned char *ptr ) ;
   int (*ssl_pending)(SSL const *s ) ;
   int (*num_ciphers)(void) ;
   SSL_CIPHER const *(*get_cipher)(unsigned int ncipher ) ;
   struct ssl_method_st const *(*get_ssl_method)(int version ) ;
   long (*get_timeout)(void) ;
   struct ssl3_enc_method *ssl3_enc ;
   int (*ssl_version)(void) ;
   long (*ssl_callback_ctrl)(SSL *s , int cb_id , void (*fp)(void) ) ;
   long (*ssl_ctx_callback_ctrl)(SSL_CTX *s , int cb_id , void (*fp)(void) ) ;
};

struct sess_cert_st;

struct ssl_session_st {
   int ssl_version ;
   unsigned int key_arg_length ;
   unsigned char key_arg[8] ;
   int master_key_length ;
   unsigned char master_key[48] ;
   unsigned int session_id_length ;
   unsigned char session_id[32] ;
   unsigned int sid_ctx_length ;
   unsigned char sid_ctx[32] ;
   char *psk_identity_hint ;
   char *psk_identity ;
   int not_resumable ;
   struct sess_cert_st *sess_cert ;
   X509 *peer ;
   long verify_result ;
   int references ;
   long timeout ;
   long time ;
   unsigned int compress_meth ;
   SSL_CIPHER const *cipher ;
   unsigned long cipher_id ;
   struct stack_st_SSL_CIPHER *ciphers ;
   CRYPTO_EX_DATA ex_data ;
   struct ssl_session_st *prev ;
   struct ssl_session_st *next ;
   char *tlsext_hostname ;
   size_t tlsext_ecpointformatlist_length ;
   unsigned char *tlsext_ecpointformatlist ;
   size_t tlsext_ellipticcurvelist_length ;
   unsigned char *tlsext_ellipticcurvelist ;
   unsigned char *tlsext_tick ;
   size_t tlsext_ticklen ;
   long tlsext_tick_lifetime_hint ;
   char *srp_username ;
};

struct srp_ctx_st {
   void *SRP_cb_arg ;
   int (*TLS_ext_srp_username_callback)(SSL * , int * , void * ) ;
   int (*SRP_verify_param_callback)(SSL * , void * ) ;
   char *(*SRP_give_srp_client_pwd_callback)(SSL * , void * ) ;
   char *login ;
   BIGNUM *N ;
   BIGNUM *g ;
   BIGNUM *s ;
   BIGNUM *B ;
   BIGNUM *A ;
   BIGNUM *a ;
   BIGNUM *b ;
   BIGNUM *v ;
   char *info ;
   int strength ;
   unsigned long srp_Mask ;
};

typedef struct srp_ctx_st SRP_CTX;

struct ssl_comp_st;

typedef struct ssl_comp_st SSL_COMP;

struct ssl_comp_st {
   int id ;
   char const *name ;
   COMP_METHOD *method ;
};

struct stack_st_SSL_COMP {
   _STACK stack ;
};

struct lhash_st_SSL_SESSION {
   int dummy ;
};

struct __anonstruct_stats_39 {
   int sess_connect ;
   int sess_connect_renegotiate ;
   int sess_connect_good ;
   int sess_accept ;
   int sess_accept_renegotiate ;
   int sess_accept_good ;
   int sess_miss ;
   int sess_timeout ;
   int sess_cache_full ;
   int sess_hit ;
   int sess_cb_hit ;
};

struct cert_st;

struct ssl3_buf_freelist_st;

struct ssl_ctx_st {
   SSL_METHOD const *method ;
   struct stack_st_SSL_CIPHER *cipher_list ;
   struct stack_st_SSL_CIPHER *cipher_list_by_id ;
   struct x509_store_st *cert_store ;
   struct lhash_st_SSL_SESSION *sessions ;
   unsigned long session_cache_size ;
   struct ssl_session_st *session_cache_head ;
   struct ssl_session_st *session_cache_tail ;
   int session_cache_mode ;
   long session_timeout ;
   int (*new_session_cb)(struct ssl_st *ssl , SSL_SESSION *sess ) ;
   void (*remove_session_cb)(struct ssl_ctx_st *ctx , SSL_SESSION *sess ) ;
   SSL_SESSION *(*get_session_cb)(struct ssl_st *ssl , unsigned char *data , int len ,
                                  int *copy ) ;
   struct __anonstruct_stats_39 stats ;
   int references ;
   int (*app_verify_callback)(X509_STORE_CTX * , void * ) ;
   void *app_verify_arg ;
   pem_password_cb *default_passwd_callback ;
   void *default_passwd_callback_userdata ;
   int (*client_cert_cb)(SSL *ssl , X509 **x509 , EVP_PKEY **pkey ) ;
   int (*app_gen_cookie_cb)(SSL *ssl , unsigned char *cookie , unsigned int *cookie_len ) ;
   int (*app_verify_cookie_cb)(SSL *ssl , unsigned char *cookie , unsigned int cookie_len ) ;
   CRYPTO_EX_DATA ex_data ;
   EVP_MD const *rsa_md5 ;
   EVP_MD const *md5 ;
   EVP_MD const *sha1 ;
   struct stack_st_X509 *extra_certs ;
   struct stack_st_SSL_COMP *comp_methods ;
   void (*info_callback)(SSL const *ssl , int type , int val ) ;
   struct stack_st_X509_NAME *client_CA ;
   unsigned long options ;
   unsigned long mode ;
   long max_cert_list ;
   struct cert_st *cert ;
   int read_ahead ;
   void (*msg_callback)(int write_p , int version , int content_type , void const *buf ,
                        size_t len , SSL *ssl , void *arg ) ;
   void *msg_callback_arg ;
   int verify_mode ;
   unsigned int sid_ctx_length ;
   unsigned char sid_ctx[32] ;
   int (*default_verify_callback)(int ok , X509_STORE_CTX *ctx ) ;
   int (*generate_session_id)(SSL const *ssl , unsigned char *id , unsigned int *id_len ) ;
   X509_VERIFY_PARAM *param ;
   int quiet_shutdown ;
   unsigned int max_send_fragment ;
   ENGINE *client_cert_engine ;
   int (*tlsext_servername_callback)(SSL * , int * , void * ) ;
   void *tlsext_servername_arg ;
   unsigned char tlsext_tick_key_name[16] ;
   unsigned char tlsext_tick_hmac_key[16] ;
   unsigned char tlsext_tick_aes_key[16] ;
   int (*tlsext_ticket_key_cb)(SSL *ssl , unsigned char *name , unsigned char *iv ,
                               EVP_CIPHER_CTX *ectx , HMAC_CTX *hctx , int enc ) ;
   int (*tlsext_status_cb)(SSL *ssl , void *arg ) ;
   void *tlsext_status_arg ;
   int (*tlsext_opaque_prf_input_callback)(SSL * , void *peerinput , size_t len ,
                                           void *arg ) ;
   void *tlsext_opaque_prf_input_callback_arg ;
   char *psk_identity_hint ;
   unsigned int (*psk_client_callback)(SSL *ssl , char const *hint , char *identity ,
                                       unsigned int max_identity_len , unsigned char *psk ,
                                       unsigned int max_psk_len ) ;
   unsigned int (*psk_server_callback)(SSL *ssl , char const *identity , unsigned char *psk ,
                                       unsigned int max_psk_len ) ;
   unsigned int freelist_max_len ;
   struct ssl3_buf_freelist_st *wbuf_freelist ;
   struct ssl3_buf_freelist_st *rbuf_freelist ;
   SRP_CTX srp_ctx ;
   int (*next_protos_advertised_cb)(SSL *s , unsigned char const **buf , unsigned int *len ,
                                    void *arg ) ;
   void *next_protos_advertised_cb_arg ;
   int (*next_proto_select_cb)(SSL *s , unsigned char **out , unsigned char *outlen ,
                               unsigned char const *in , unsigned int inlen , void *arg ) ;
   void *next_proto_select_cb_arg ;
   struct stack_st_SRTP_PROTECTION_PROFILE *srtp_profiles ;
   int (*alpn_select_cb)(SSL *s , unsigned char const **out , unsigned char *outlen ,
                         unsigned char const *in , unsigned int inlen , void *arg ) ;
   void *alpn_select_cb_arg ;
   unsigned char *alpn_client_proto_list ;
   unsigned int alpn_client_proto_list_len ;
   size_t tlsext_ecpointformatlist_length ;
   unsigned char *tlsext_ecpointformatlist ;
   size_t tlsext_ellipticcurvelist_length ;
   unsigned char *tlsext_ellipticcurvelist ;
};

struct ssl2_state_st;

struct ssl3_state_st;

struct dtls1_state_st;

struct stack_st_OCSP_RESPID;

struct ssl_st {
   int version ;
   int type ;
   SSL_METHOD const *method ;
   BIO *rbio ;
   BIO *wbio ;
   BIO *bbio ;
   int rwstate ;
   int in_handshake ;
   int (*handshake_func)(SSL * ) ;
   int server ;
   int new_session ;
   int quiet_shutdown ;
   int shutdown ;
   int state ;
   int rstate ;
   BUF_MEM *init_buf ;
   void *init_msg ;
   int init_num ;
   int init_off ;
   unsigned char *packet ;
   unsigned int packet_length ;
   struct ssl2_state_st *s2 ;
   struct ssl3_state_st *s3 ;
   struct dtls1_state_st *d1 ;
   int read_ahead ;
   void (*msg_callback)(int write_p , int version , int content_type , void const *buf ,
                        size_t len , SSL *ssl , void *arg ) ;
   void *msg_callback_arg ;
   int hit ;
   X509_VERIFY_PARAM *param ;
   struct stack_st_SSL_CIPHER *cipher_list ;
   struct stack_st_SSL_CIPHER *cipher_list_by_id ;
   int mac_flags ;
   EVP_CIPHER_CTX *enc_read_ctx ;
   EVP_MD_CTX *read_hash ;
   COMP_CTX *expand ;
   EVP_CIPHER_CTX *enc_write_ctx ;
   EVP_MD_CTX *write_hash ;
   COMP_CTX *compress ;
   struct cert_st *cert ;
   unsigned int sid_ctx_length ;
   unsigned char sid_ctx[32] ;
   SSL_SESSION *session ;
   int (*generate_session_id)(SSL const *ssl , unsigned char *id , unsigned int *id_len ) ;
   int verify_mode ;
   int (*verify_callback)(int ok , X509_STORE_CTX *ctx ) ;
   void (*info_callback)(SSL const *ssl , int type , int val ) ;
   int error ;
   int error_code ;
   unsigned int (*psk_client_callback)(SSL *ssl , char const *hint , char *identity ,
                                       unsigned int max_identity_len , unsigned char *psk ,
                                       unsigned int max_psk_len ) ;
   unsigned int (*psk_server_callback)(SSL *ssl , char const *identity , unsigned char *psk ,
                                       unsigned int max_psk_len ) ;
   SSL_CTX *ctx ;
   int debug ;
   long verify_result ;
   CRYPTO_EX_DATA ex_data ;
   struct stack_st_X509_NAME *client_CA ;
   int references ;
   unsigned long options ;
   unsigned long mode ;
   long max_cert_list ;
   int first_packet ;
   int client_version ;
   unsigned int max_send_fragment ;
   void (*tlsext_debug_cb)(SSL *s , int client_server , int type , unsigned char *data ,
                           int len , void *arg ) ;
   void *tlsext_debug_arg ;
   char *tlsext_hostname ;
   int servername_done ;
   int tlsext_status_type ;
   int tlsext_status_expected ;
   struct stack_st_OCSP_RESPID *tlsext_ocsp_ids ;
   X509_EXTENSIONS *tlsext_ocsp_exts ;
   unsigned char *tlsext_ocsp_resp ;
   int tlsext_ocsp_resplen ;
   int tlsext_ticket_expected ;
   size_t tlsext_ecpointformatlist_length ;
   unsigned char *tlsext_ecpointformatlist ;
   size_t tlsext_ellipticcurvelist_length ;
   unsigned char *tlsext_ellipticcurvelist ;
   void *tlsext_opaque_prf_input ;
   size_t tlsext_opaque_prf_input_len ;
   TLS_SESSION_TICKET_EXT *tlsext_session_ticket ;
   int (*tls_session_ticket_ext_cb)(SSL *s , unsigned char const *data , int len ,
                                    void *arg ) ;
   void *tls_session_ticket_ext_cb_arg ;
   int (*tls_session_secret_cb)(SSL *s , void *secret , int *secret_len , struct stack_st_SSL_CIPHER *peer_ciphers ,
                                SSL_CIPHER **cipher , void *arg ) ;
   void *tls_session_secret_cb_arg ;
   SSL_CTX *initial_ctx ;
   unsigned char *next_proto_negotiated ;
   unsigned char next_proto_negotiated_len ;
   struct stack_st_SRTP_PROTECTION_PROFILE *srtp_profiles ;
   SRTP_PROTECTION_PROFILE *srtp_profile ;
   unsigned int tlsext_heartbeat ;
   unsigned int tlsext_hb_pending ;
   unsigned int tlsext_hb_seq ;
   int renegotiate ;
   SRP_CTX srp_ctx ;
   unsigned char *alpn_client_proto_list ;
   unsigned int alpn_client_proto_list_len ;
};

struct __anonstruct_tmp_40 {
   unsigned int conn_id_length ;
   unsigned int cert_type ;
   unsigned int cert_length ;
   unsigned int csl ;
   unsigned int clear ;
   unsigned int enc ;
   unsigned char ccl[32] ;
   unsigned int cipher_spec_length ;
   unsigned int session_id_length ;
   unsigned int clen ;
   unsigned int rlen ;
};

struct ssl2_state_st {
   int three_byte_header ;
   int clear_text ;
   int escape ;
   int ssl2_rollback ;
   unsigned int wnum ;
   int wpend_tot ;
   unsigned char const *wpend_buf ;
   int wpend_off ;
   int wpend_len ;
   int wpend_ret ;
   int rbuf_left ;
   int rbuf_offs ;
   unsigned char *rbuf ;
   unsigned char *wbuf ;
   unsigned char *write_ptr ;
   unsigned int padding ;
   unsigned int rlength ;
   int ract_data_length ;
   unsigned int wlength ;
   int wact_data_length ;
   unsigned char *ract_data ;
   unsigned char *wact_data ;
   unsigned char *mac_data ;
   unsigned char *read_key ;
   unsigned char *write_key ;
   unsigned int challenge_length ;
   unsigned char challenge[32] ;
   unsigned int conn_id_length ;
   unsigned char conn_id[16] ;
   unsigned int key_material_length ;
   unsigned char key_material[48] ;
   unsigned long read_sequence ;
   unsigned long write_sequence ;
   struct __anonstruct_tmp_40 tmp ;
};

struct ssl3_record_st {
   int type ;
   unsigned int length ;
   unsigned int off ;
   unsigned char *data ;
   unsigned char *input ;
   unsigned char *comp ;
   unsigned long epoch ;
   unsigned char seq_num[8] ;
};

typedef struct ssl3_record_st SSL3_RECORD;

struct ssl3_buffer_st {
   unsigned char *buf ;
   size_t len ;
   int offset ;
   int left ;
};

typedef struct ssl3_buffer_st SSL3_BUFFER;

struct __anonstruct_tmp_41 {
   unsigned char cert_verify_md[128] ;
   unsigned char finish_md[128] ;
   int finish_md_len ;
   unsigned char peer_finish_md[128] ;
   int peer_finish_md_len ;
   unsigned long message_size ;
   int message_type ;
   SSL_CIPHER const *new_cipher ;
   DH *dh ;
   EC_KEY *ecdh ;
   int next_state ;
   int reuse_message ;
   int cert_req ;
   int ctype_num ;
   char ctype[9] ;
   struct stack_st_X509_NAME *ca_names ;
   int use_rsa_tmp ;
   int key_block_length ;
   unsigned char *key_block ;
   EVP_CIPHER const *new_sym_enc ;
   EVP_MD const *new_hash ;
   int new_mac_pkey_type ;
   int new_mac_secret_size ;
   SSL_COMP const *new_compression ;
   int cert_request ;
};

struct ssl3_state_st {
   long flags ;
   int delay_buf_pop_ret ;
   unsigned char read_sequence[8] ;
   int read_mac_secret_size ;
   unsigned char read_mac_secret[64] ;
   unsigned char write_sequence[8] ;
   int write_mac_secret_size ;
   unsigned char write_mac_secret[64] ;
   unsigned char server_random[32] ;
   unsigned char client_random[32] ;
   int need_empty_fragments ;
   int empty_fragment_done ;
   int init_extra ;
   SSL3_BUFFER rbuf ;
   SSL3_BUFFER wbuf ;
   SSL3_RECORD rrec ;
   SSL3_RECORD wrec ;
   unsigned char alert_fragment[2] ;
   unsigned int alert_fragment_len ;
   unsigned char handshake_fragment[4] ;
   unsigned int handshake_fragment_len ;
   unsigned int wnum ;
   int wpend_tot ;
   int wpend_type ;
   int wpend_ret ;
   unsigned char const *wpend_buf ;
   BIO *handshake_buffer ;
   EVP_MD_CTX **handshake_dgst ;
   int change_cipher_spec ;
   int warn_alert ;
   int fatal_alert ;
   int alert_dispatch ;
   unsigned char send_alert[2] ;
   int renegotiate ;
   int total_renegotiations ;
   int num_renegotiations ;
   int in_read_app_data ;
   void *client_opaque_prf_input ;
   size_t client_opaque_prf_input_len ;
   void *server_opaque_prf_input ;
   size_t server_opaque_prf_input_len ;
   struct __anonstruct_tmp_41 tmp ;
   unsigned char previous_client_finished[64] ;
   unsigned char previous_client_finished_len ;
   unsigned char previous_server_finished[64] ;
   unsigned char previous_server_finished_len ;
   int send_connection_binding ;
   int next_proto_neg_seen ;
   char is_probably_safari ;
   unsigned char *alpn_selected ;
   unsigned int alpn_selected_len ;
};

struct tls_session_ticket_ext_st {
   unsigned short length ;
   void *data ;
};

struct _pqueue;

typedef struct _pqueue *pqueue;

struct dtls1_bitmap_st {
   unsigned long map ;
   unsigned char max_seq_num[8] ;
};

typedef struct dtls1_bitmap_st DTLS1_BITMAP;

struct dtls1_retransmit_state {
   EVP_CIPHER_CTX *enc_write_ctx ;
   EVP_MD_CTX *write_hash ;
   COMP_CTX *compress ;
   SSL_SESSION *session ;
   unsigned short epoch ;
};

struct hm_header_st {
   unsigned char type ;
   unsigned long msg_len ;
   unsigned short seq ;
   unsigned long frag_off ;
   unsigned long frag_len ;
   unsigned int is_ccs ;
   struct dtls1_retransmit_state saved_retransmit_state ;
};

struct dtls1_timeout_st {
   unsigned int read_timeouts ;
   unsigned int write_timeouts ;
   unsigned int num_alerts ;
};

struct record_pqueue_st {
   unsigned short epoch ;
   pqueue q ;
};

typedef struct record_pqueue_st record_pqueue;

struct dtls1_state_st {
   unsigned int send_cookie ;
   unsigned char cookie[256] ;
   unsigned char rcvd_cookie[256] ;
   unsigned int cookie_len ;
   unsigned short r_epoch ;
   unsigned short w_epoch ;
   DTLS1_BITMAP bitmap ;
   DTLS1_BITMAP next_bitmap ;
   unsigned short handshake_write_seq ;
   unsigned short next_handshake_write_seq ;
   unsigned short handshake_read_seq ;
   unsigned char last_write_sequence[8] ;
   record_pqueue unprocessed_rcds ;
   record_pqueue processed_rcds ;
   pqueue buffered_messages ;
   pqueue sent_messages ;
   record_pqueue buffered_app_data ;
   unsigned int listen ;
   unsigned int link_mtu ;
   unsigned int mtu ;
   struct hm_header_st w_msg_hdr ;
   struct hm_header_st r_msg_hdr ;
   struct dtls1_timeout_st timeout ;
   struct timeval next_timeout ;
   unsigned short timeout_duration ;
   unsigned char alert_fragment[2] ;
   unsigned int alert_fragment_len ;
   unsigned char handshake_fragment[12] ;
   unsigned int handshake_fragment_len ;
   unsigned int retransmitting ;
   unsigned int change_cipher_spec_ok ;
};

typedef struct stack_st_GENERAL_NAME GENERAL_NAMES;

struct stack_st_GENERAL_NAME {
   _STACK stack ;
};

union __anonunion_name_44 {
   GENERAL_NAMES *fullname ;
   struct stack_st_X509_NAME_ENTRY *relativename ;
};

struct DIST_POINT_NAME_st {
   int type ;
   union __anonunion_name_44 name ;
   X509_NAME *dpname ;
};

typedef struct DIST_POINT_NAME_st DIST_POINT_NAME;

struct stack_st_DIST_POINT {
   _STACK stack ;
};

struct AUTHORITY_KEYID_st {
   ASN1_OCTET_STRING *keyid ;
   GENERAL_NAMES *issuer ;
   ASN1_INTEGER *serial ;
};

struct stack_st_GENERAL_SUBTREE {
   _STACK stack ;
};

struct NAME_CONSTRAINTS_st {
   struct stack_st_GENERAL_SUBTREE *permittedSubtrees ;
   struct stack_st_GENERAL_SUBTREE *excludedSubtrees ;
};

struct ISSUING_DIST_POINT_st {
   DIST_POINT_NAME *distpoint ;
   int onlyuser ;
   int onlyCA ;
   ASN1_BIT_STRING *onlysomereasons ;
   int indirectCRL ;
   int onlyattr ;
};

extern int i2d_X509_proxy(X509 *a , unsigned char **out ) ;

#pragma cilnoremove("i2d_X509_proxy")

extern X509 *d2i_X509_proxy(X509 **a , unsigned char const **in , long len ) ;

#pragma cilnoremove("d2i_X509_proxy")

extern int EVP_DigestInit_ex_proxy(EVP_MD_CTX *ctx , EVP_MD const *type , ENGINE *impl ) ;

#pragma cilnoremove("EVP_DigestInit_ex_proxy")

extern int EVP_DigestUpdate_proxy(EVP_MD_CTX *ctx , void const *d , size_t cnt ) ;

#pragma cilnoremove("EVP_DigestUpdate_proxy")

extern EVP_PKEY *X509_get_pubkey_proxy(X509 *x ) ;

#pragma cilnoremove("X509_get_pubkey_proxy")

extern int EVP_VerifyFinal_proxy(EVP_MD_CTX *ctx , unsigned char const *sigbuf ,
                                 unsigned int siglen , EVP_PKEY *pkey ) ;

#pragma cilnoremove("EVP_VerifyFinal_proxy")

extern int EVP_SignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ,
                               EVP_PKEY *pkey ) ;

#pragma cilnoremove("EVP_SignFinal_proxy")

extern EVP_MD const *EVP_md5_proxy(void) ;

#pragma cilnoremove("EVP_md5_proxy")

extern EVP_MD const *EVP_sha1_proxy(void) ;

#pragma cilnoremove("EVP_sha1_proxy")

extern int EVP_DigestFinal_ex_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ) ;

#pragma cilnoremove("EVP_DigestFinal_ex_proxy")

extern int EVP_EncryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                    ENGINE *impl , unsigned char const *key , unsigned char const *iv ) ;

#pragma cilnoremove("EVP_EncryptInit_ex_proxy")

extern int EVP_DecryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                    ENGINE *impl , unsigned char const *key , unsigned char const *iv ) ;

#pragma cilnoremove("EVP_DecryptInit_ex_proxy")

extern int EVP_Cipher_proxy(EVP_CIPHER_CTX *c , unsigned char *out , unsigned char const *in ,
                            unsigned int inl ) ;

#pragma cilnoremove("EVP_Cipher_proxy")

extern int EVP_MD_CTX_copy_proxy(EVP_MD_CTX *out , EVP_MD_CTX const *in ) ;

#pragma cilnoremove("EVP_MD_CTX_copy_proxy")

extern EVP_MD const *EVP_MD_CTX_md_proxy(EVP_MD_CTX const *ctx ) ;

#pragma cilnoremove("EVP_MD_CTX_md_proxy")

extern int BIO_read_proxy(BIO *b , void *data , int len ) ;

#pragma cilnoremove("BIO_read_proxy")

extern int BIO_write_proxy(BIO *b , void const *data , int len ) ;

#pragma cilnoremove("BIO_write_proxy")

extern long BIO_ctrl_proxy(BIO *bp , int cmd , long larg , void *parg ) ;

#pragma cilnoremove("BIO_ctrl_proxy")

extern EVP_MD const *EVP_dss1_proxy(void) ;

#pragma cilnoremove("EVP_dss1_proxy")

extern EVP_MD const *EVP_ecdsa_proxy(void) ;

#pragma cilnoremove("EVP_ecdsa_proxy")

extern int X509_certificate_type_proxy(X509 *x , EVP_PKEY *pubkey ) ;

#pragma cilnoremove("X509_certificate_type_proxy")

extern EVP_CIPHER const *EVP_aes_128_cbc_proxy(void) ;

#pragma cilnoremove("EVP_aes_128_cbc_proxy")

extern EVP_MD const *EVP_sha256_proxy(void) ;

#pragma cilnoremove("EVP_sha256_proxy")

extern int HMAC_Init_ex_proxy(HMAC_CTX *ctx , void const *key , int len , EVP_MD const *md ,
                              ENGINE *impl ) ;

#pragma cilnoremove("HMAC_Init_ex_proxy")

extern int HMAC_Update_proxy(HMAC_CTX *ctx , unsigned char const *data , size_t len ) ;

#pragma cilnoremove("HMAC_Update_proxy")

extern int HMAC_Final_proxy(HMAC_CTX *ctx , unsigned char *md , unsigned int *len ) ;

#pragma cilnoremove("HMAC_Final_proxy")

extern unsigned char *HMAC_proxy(EVP_MD const *evp_md , void const *key , int key_len ,
                                 unsigned char const *d , size_t n , unsigned char *md ,
                                 unsigned int *md_len ) ;

#pragma cilnoremove("HMAC_proxy")

extern int EVP_EncryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const *in , int inl ) ;

#pragma cilnoremove("EVP_EncryptUpdate_proxy")

extern int EVP_EncryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ) ;

#pragma cilnoremove("EVP_EncryptFinal_proxy")

extern int EVP_DigestInit_proxy(EVP_MD_CTX *ctx , EVP_MD const *type ) ;

#pragma cilnoremove("EVP_DigestInit_proxy")

extern int EVP_CipherInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                   ENGINE *impl , unsigned char const *key , unsigned char const *iv ,
                                   int enc ) ;

#pragma cilnoremove("EVP_CipherInit_ex_proxy")

extern int EVP_MD_CTX_copy_ex_proxy(EVP_MD_CTX *out , EVP_MD_CTX const *in ) ;

#pragma cilnoremove("EVP_MD_CTX_copy_ex_proxy")

extern int EVP_DecryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const *in , int inl ) ;

#pragma cilnoremove("EVP_DecryptUpdate_proxy")

extern int EVP_DecryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *outm , int *outl ) ;

#pragma cilnoremove("EVP_DecryptFinal_proxy")

extern EVP_PKEY *EVP_PKEY_new_mac_key_proxy(int type , ENGINE *e , unsigned char *key ,
                                            int keylen ) ;

#pragma cilnoremove("EVP_PKEY_new_mac_key_proxy")

extern int EVP_DigestSignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *sigret , size_t *siglen ) ;

#pragma cilnoremove("EVP_DigestSignFinal_proxy")

extern X509 *PEM_read_bio_X509_proxy(BIO *bp , X509 **x , pem_password_cb *cb , void *u ) ;

#pragma cilnoremove("PEM_read_bio_X509_proxy")

extern EVP_CIPHER const *EVP_get_cipherbyname_proxy(char const *name ) ;

#pragma cilnoremove("EVP_get_cipherbyname_proxy")

extern EVP_CIPHER const *EVP_enc_null_proxy(void) ;

#pragma cilnoremove("EVP_enc_null_proxy")

extern X509 *d2i_X509_bio_proxy(BIO *bp , X509 **x509 ) ;

#pragma cilnoremove("d2i_X509_bio_proxy")

extern int EVP_PKEY_assign_proxy(EVP_PKEY *pkey , int type , void *key ) ;

#pragma cilnoremove("EVP_PKEY_assign_proxy")

extern int EVP_PKEY_copy_parameters_proxy(EVP_PKEY *to , EVP_PKEY const *from ) ;

#pragma cilnoremove("EVP_PKEY_copy_parameters_proxy")

extern EVP_PKEY *PEM_read_bio_PrivateKey_proxy(BIO *bp , EVP_PKEY **x , pem_password_cb *cb ,
                                               void *u ) ;

#pragma cilnoremove("PEM_read_bio_PrivateKey_proxy")

extern EVP_PKEY *d2i_PrivateKey_bio_proxy(BIO *bp , EVP_PKEY **a ) ;

#pragma cilnoremove("d2i_PrivateKey_bio_proxy")

extern EVP_PKEY *d2i_PrivateKey_proxy(int type , EVP_PKEY **a , unsigned char const **pp ,
                                      long length ) ;

#pragma cilnoremove("d2i_PrivateKey_proxy")

extern EVP_CIPHER const *EVP_des_cbc_proxy(void) ;

#pragma cilnoremove("EVP_des_cbc_proxy")

extern EVP_CIPHER const *EVP_des_ede3_cbc_proxy(void) ;

#pragma cilnoremove("EVP_des_ede3_cbc_proxy")

extern EVP_CIPHER const *EVP_rc4_proxy(void) ;

#pragma cilnoremove("EVP_rc4_proxy")

extern EVP_CIPHER const *EVP_rc2_cbc_proxy(void) ;

#pragma cilnoremove("EVP_rc2_cbc_proxy")

extern EVP_CIPHER const *EVP_aes_192_cbc_proxy(void) ;

#pragma cilnoremove("EVP_aes_192_cbc_proxy")

extern EVP_CIPHER const *EVP_aes_256_cbc_proxy(void) ;

#pragma cilnoremove("EVP_aes_256_cbc_proxy")

extern EVP_CIPHER const *EVP_camellia_128_cbc_proxy(void) ;

#pragma cilnoremove("EVP_camellia_128_cbc_proxy")

extern EVP_CIPHER const *EVP_camellia_256_cbc_proxy(void) ;

#pragma cilnoremove("EVP_camellia_256_cbc_proxy")

extern EVP_CIPHER const *EVP_seed_cbc_proxy(void) ;

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

extern RSA *d2i_RSAPrivateKey_proxy(RSA **a , unsigned char const **in , long len ) ;

#pragma cilnoremove("d2i_RSAPrivateKey_proxy")

extern void tls1_PRF_proxy(long digest_mask , void const *seed1 , int seed1_len ,
                           void const *seed2 , int seed2_len , void const *seed3 ,
                           int seed3_len , void const *seed4 , int seed4_len , void const *seed5 ,
                           int seed5_len , unsigned char const *sec , int slen ,
                           unsigned char *out1 , unsigned char *out2 , int olen ) ;

#pragma cilnoremove("tls1_PRF_proxy")

extern void tls1_P_hash_proxy(EVP_MD const *md , unsigned char const *sec , int sec_len ,
                              void const *seed1 , int seed1_len , void const *seed2 ,
                              int seed2_len , void const *seed3 , int seed3_len ,
                              void const *seed4 , int seed4_len , void const *seed5 ,
                              int seed5_len , unsigned char *out , int olen ) ;

#pragma cilnoremove("tls1_P_hash_proxy")

extern int tls1_generate_master_secret_proxy(SSL *s , unsigned char *out , unsigned char *p ,
                                             int len ) ;

#pragma cilnoremove("tls1_generate_master_secret_proxy")

extern int ENGINE_load_ssl_client_cert_proxy(ENGINE *e , SSL *s , struct stack_st_X509_NAME *ca_dn ,
                                             X509 **pcert , EVP_PKEY **ppkey , struct stack_st_X509 **pother ,
                                             UI_METHOD *ui_method , void *callback_data ) ;

#pragma cilnoremove("ENGINE_load_ssl_client_cert_proxy")

extern int EVP_PKEY_derive_set_peer_proxy(EVP_PKEY_CTX *ctx , EVP_PKEY *peer ) ;

#pragma cilnoremove("EVP_PKEY_derive_set_peer_proxy")

extern int EVP_PKEY_decrypt_proxy(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                                  unsigned char const *in , size_t inlen ) ;

#pragma cilnoremove("EVP_PKEY_decrypt_proxy")

extern int EVP_PKEY_CTX_ctrl_proxy(EVP_PKEY_CTX *ctx , int keytype , int optype ,
                                   int cmd , int p1 , void *p2 ) ;

#pragma cilnoremove("EVP_PKEY_CTX_ctrl_proxy")

extern int EVP_PKEY_verify_proxy(EVP_PKEY_CTX *ctx , unsigned char const *sig ,
                                 size_t siglen , unsigned char const *tbs , size_t tbslen ) ;

#pragma cilnoremove("EVP_PKEY_verify_proxy")

extern int EVP_PKEY_encrypt_proxy(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                                  unsigned char const *in , size_t inlen ) ;

#pragma cilnoremove("EVP_PKEY_encrypt_proxy")

extern int EVP_PKEY_sign_proxy(EVP_PKEY_CTX *ctx , unsigned char *sig , size_t *siglen ,
                               unsigned char const *tbs , size_t tbslen ) ;

#pragma cilnoremove("EVP_PKEY_sign_proxy")

extern int EVP_DigestSignInit_proxy(EVP_MD_CTX *ctx , EVP_PKEY_CTX **pctx , EVP_MD const *type ,
                                    ENGINE *e , EVP_PKEY *pkey ) ;

#pragma cilnoremove("EVP_DigestSignInit_proxy")

extern EVP_PKEY_CTX *EVP_PKEY_CTX_new_proxy(EVP_PKEY *pkey , ENGINE *e ) ;

#pragma cilnoremove("EVP_PKEY_CTX_new_proxy")

extern DSA_SIG *dsa_do_sign(unsigned char const *dgst , int dlen , DSA *dsa ) ;
static DSA_SIG *__crest_dsa_do_sign_opaque(unsigned char const *dgst , int dlen ,
                                           DSA *dsa )
{
  DSA_SIG *__crest_ret ;

  {
  __CrestCallOpaque("dsa_do_sign", (void (*)())(& dsa_do_sign), 3);
  __CrestClear(3);
  __CrestLoadStackPtr("dsa_do_sign()");
  __CrestNondet();
  __CrestLoadInt((long long )16);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = dsa_do_sign(dgst, dlen, dsa);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

DSA_SIG *dsa_do_sign_proxy(unsigned char const *dgst , int dlen , DSA *dsa ) ;

extern int dsa_do_verify(unsigned char const *dgst , int dgst_len , DSA_SIG *sig ,
                         DSA *dsa ) ;
static int __crest_dsa_do_verify_opaque(unsigned char const *dgst , int dgst_len ,
                                        DSA_SIG *sig , DSA *dsa )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("dsa_do_verify", (void (*)())(& dsa_do_verify), 4);
  __CrestApply("(dsa_do_verify() : bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = dsa_do_verify(dgst, dgst_len, sig, dsa);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

int dsa_do_verify_proxy(unsigned char const *dgst , int dgst_len , DSA_SIG *sig ,
                        DSA *dsa ) ;

#pragma cilnoremove("RSA_generate_key_proxy")

extern RSA *RSA_generate_key_proxy(int bits , unsigned long e , void (*callback)(int ,
                                                                                 int ,
                                                                                 void * ) ,
                                   void *cb_arg ) ;

extern RSA *RSAPrivateKey_dup_proxy(RSA *rsa ) ;

#pragma cilnoremove("RSAPrivateKey_dup_proxy")

extern int RSA_verify_proxy(int type , unsigned char const *m , unsigned int m_length ,
                            unsigned char const *sigbuf , unsigned int siglen ,
                            RSA *rsa ) ;

#pragma cilnoremove("RSA_verify_proxy")

extern int RSA_public_encrypt_proxy(int flen , unsigned char const *from , unsigned char *to ,
                                    RSA *rsa , int padding ) ;

#pragma cilnoremove("RSA_public_encrypt_proxy")

extern int RSA_private_decrypt_proxy(int flen , unsigned char const *from , unsigned char *to ,
                                     RSA *rsa , int padding ) ;

#pragma cilnoremove("RSA_private_decrypt_proxy")

extern int RSA_sign_proxy(int type , unsigned char const *m , unsigned int m_length ,
                          unsigned char *sigret , unsigned int *siglen , RSA *rsa ) ;

#pragma cilnoremove("RSA_sign_proxy")

extern int X509_STORE_CTX_init_proxy(X509_STORE_CTX *ctx , X509_STORE *store , X509 *x509 ,
                                     struct stack_st_X509 *chain ) ;

#pragma cilnoremove("X509_STORE_CTX_init_proxy")

extern void proxy_fail(char const *fmt , ...) ;

extern void SymN(char const *sym , int n ) ;

extern void Hint(char const *hint ) ;

extern void mute() ;

extern void unmute() ;

extern void load_buf(unsigned char const *buf , size_t len , char const *hint ) ;

extern void load_ctx(void const *ctx , char const *attr , char const *hint ) ;

extern void assume_intype(char const *type ) ;

extern void assume_len(unsigned char const *len , _Bool is_signed , size_t width ) ;

extern void assume_len_at_most(unsigned char const *len , _Bool is_signed , size_t width ) ;

extern void newT(char const *type , char const *hint ) ;

extern void store_buf(unsigned char const *buf ) ;

extern void store_ctx(void const *ctx , char const *attr ) ;

extern void fresh_ptr(size_t size ) ;

extern int dsa_init(DSA *dsa ) ;
static int __crest_dsa_init_opaque(DSA *dsa )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("dsa_init", (void (*)())(& dsa_init), 1);
  __CrestApply("(dsa_init() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = dsa_init(dsa);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

int dsa_init_proxy(DSA *dsa )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("dsa_init_proxy", (void (*)())(& dsa_init_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies_internal.c:dsa[22290]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:12");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:13");
  __CrestLoadStackPtr("openssl_proxies_internal.c:dsa[22290]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_dsa_init_opaque(dsa);
  __CrestLoadStackPtr("openssl_proxies_internal.c:tmp[22292]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:13");
  __CrestLoadStackPtr("openssl_proxies_internal.c:tmp[22292]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22291]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:14");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:16");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22291]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = 1;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:17");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22291]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

DSA_SIG *dsa_do_sign_proxy(unsigned char const *dgst , int dlen , DSA *dsa )
{
  DSA_SIG *ret ;
  DSA_SIG *tmp ;
  size_t max_sig_len ;
  size_t max_half_sig_len ;

  {
  __CrestCall("dsa_do_sign_proxy", (void (*)())(& dsa_do_sign_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies_internal.c:dsa[22299]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dlen[22298]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dgst[22297]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:27");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:28");
  __CrestLoadStackPtr("openssl_proxies_internal.c:dgst[22297]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dlen[22298]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dsa[22299]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_dsa_do_sign_opaque(dgst, dlen, dsa);
  __CrestLoadStackPtr("openssl_proxies_internal.c:tmp[22301]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:28");
  __CrestLoadStackPtr("openssl_proxies_internal.c:tmp[22301]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:29");

  unmute();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:38");
  __CrestLoadStackPtr("openssl_proxies_internal.c:dlen[22298]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )32);
  __CrestBS(1, 4);
  __CrestApply("(!=: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if (dlen != 32) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:39");
    __CrestLoadCString("wrong digest length");
    __CrestMute();

    proxy_fail("wrong digest length");
    __CrestUnmute();
    __CrestClear(1);
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:41");
  __CrestLoadInt((long long )100);
  __CrestBS(1, 4);
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies_internal.c:max_sig_len[22302]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  max_sig_len = (size_t )100;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:42");
  __CrestLoadInt((long long )50);
  __CrestBS(1, 4);
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies_internal.c:max_half_sig_len[22303]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  max_half_sig_len = (size_t )50;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:44");
  __CrestLoadInt((long long )16);
  __CrestBS(0, 8);

  fresh_ptr(sizeof(DSA_SIG ));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:45");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:47");
  __CrestLoadInt((long long )24);
  __CrestBS(0, 8);

  fresh_ptr(sizeof(BIGNUM ));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:48");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )16);
  __CrestSetPtrStep();
  __CrestFieldOffset("r");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)((unsigned char *)(& ret->r)));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:49");
  __CrestLoadInt((long long )24);
  __CrestBS(0, 8);

  fresh_ptr(sizeof(BIGNUM ));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:50");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )16);
  __CrestSetPtrStep();
  __CrestFieldOffset("s");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)((unsigned char *)(& ret->s)));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:52");
  __CrestLoadStackPtr("openssl_proxies_internal.c:dgst[22297]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dlen[22298]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("dgst");

  load_buf(dgst, (size_t )dlen, "dgst");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:53");
  __CrestLoadStackPtr("openssl_proxies_internal.c:dsa[22299]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("skey");
  __CrestLoadCString("skey");

  load_ctx((void const *)dsa, "skey", "skey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:54");
  __CrestLoadCString("DSA_seed");
  __CrestLoadCString("seed");

  newT("DSA_seed", "seed");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:55");
  __CrestLoadCString("DSA_sign");
  __CrestLoadInt((long long )3);
  __CrestBS(1, 4);

  SymN("DSA_sign", 3);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:58");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:59");
  __CrestLoadStackPtr("openssl_proxies_internal.c:max_sig_len[22302]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);

  assume_len_at_most((unsigned char const *)(& max_sig_len), (_Bool)0, sizeof(max_sig_len));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:60");
  __CrestLoadCString("dsa_sig");

  Hint("dsa_sig");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:61");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("sig");

  store_ctx((void const *)ret, "sig");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:64");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("sig");
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();

  load_ctx((void const *)ret, "sig", (char const *)((void *)0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:65");
  __CrestLoadCString("DSA_r");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("DSA_r", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:66");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:67");
  __CrestLoadStackPtr("openssl_proxies_internal.c:max_half_sig_len[22303]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);

  assume_len_at_most((unsigned char const *)(& max_half_sig_len), (_Bool)0, sizeof(max_half_sig_len));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:68");
  __CrestLoadCString("dsa_sig_r");

  Hint("dsa_sig_r");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:69");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )16);
  __CrestSetPtrStep();
  __CrestFieldOffset("r");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)ret->r, "val");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:71");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("sig");
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();

  load_ctx((void const *)ret, "sig", (char const *)((void *)0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:72");
  __CrestLoadCString("DSA_s");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("DSA_s", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:73");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:74");
  __CrestLoadStackPtr("openssl_proxies_internal.c:max_half_sig_len[22303]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);

  assume_len_at_most((unsigned char const *)(& max_half_sig_len), (_Bool)0, sizeof(max_half_sig_len));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:75");
  __CrestLoadCString("dsa_sig_s");

  Hint("dsa_sig_s");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:76");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )16);
  __CrestSetPtrStep();
  __CrestFieldOffset("s");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)ret->s, "val");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:78");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int dsa_do_verify_proxy(unsigned char const *dgst , int dgst_len , DSA_SIG *sig ,
                        DSA *dsa )
{
  int ret ;
  int tmp ;
  size_t ret_len ;

  {
  __CrestCall("dsa_do_verify_proxy", (void (*)())(& dsa_do_verify_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies_internal.c:dsa[22312]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies_internal.c:sig[22311]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dgst_len[22310]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dgst[22309]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:85");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:86");
  __CrestLoadStackPtr("openssl_proxies_internal.c:dgst[22309]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dgst_len[22310]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:sig[22311]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dsa[22312]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_dsa_do_verify_opaque(dgst, dgst_len, sig, dsa);
  __CrestLoadStackPtr("openssl_proxies_internal.c:tmp[22314]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:86");
  __CrestLoadStackPtr("openssl_proxies_internal.c:tmp[22314]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22313]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:87");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:90");
  __CrestLoadStackPtr("openssl_proxies_internal.c:sig[22311]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )16);
  __CrestSetPtrStep();
  __CrestFieldOffset("r");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("dsa_sig_r");

  load_ctx((void const *)sig->r, "val", "dsa_sig_r");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:91");
  __CrestLoadStackPtr("openssl_proxies_internal.c:sig[22311]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )16);
  __CrestSetPtrStep();
  __CrestFieldOffset("s");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("dsa_sig_s");

  load_ctx((void const *)sig->s, "val", "dsa_sig_s");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:93");
  __CrestLoadCString("DSA_combine");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("DSA_combine", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:94");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:95");
  __CrestLoadCString("dsa_sig");

  Hint("dsa_sig");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:97");
  __CrestLoadStackPtr("openssl_proxies_internal.c:sig[22311]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("sig");

  store_ctx((void const *)sig, "sig");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:99");
  __CrestLoadStackPtr("openssl_proxies_internal.c:dgst[22309]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies_internal.c:dgst_len[22310]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("dgst");

  load_buf(dgst, (size_t )dgst_len, "dgst");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:100");
  __CrestLoadStackPtr("openssl_proxies_internal.c:dsa[22312]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pkey");
  __CrestLoadCString("pkey");

  load_ctx((void const *)dsa, "pkey", "pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:101");
  __CrestLoadStackPtr("openssl_proxies_internal.c:sig[22311]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("sig");
  __CrestLoadCString("sig");

  load_ctx((void const *)sig, "sig", "sig");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:102");
  __CrestLoadCString("DSA_verify");
  __CrestLoadInt((long long )3);
  __CrestBS(1, 4);

  SymN("DSA_verify", 3);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:103");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:104");
  __CrestLoadCString("sig_verification");

  Hint("sig_verification");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:105");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret_len[22315]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret_len = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:106");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret_len[22315]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)(& ret_len), (_Bool)0, sizeof(ret_len));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:107");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22313]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)((unsigned char *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies_internal.c:109");
  __CrestLoadStackPtr("openssl_proxies_internal.c:ret[22313]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}
