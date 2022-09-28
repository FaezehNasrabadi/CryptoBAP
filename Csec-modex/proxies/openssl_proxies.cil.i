# 1 "./openssl_proxies.cil.c"
# 1 "/home/faezeh/csec-modex/proxies//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "./openssl_proxies.cil.c"



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

typedef long __off_t;

typedef long __off64_t;

typedef long __time_t;

typedef long __suseconds_t;

typedef __time_t time_t;

struct timeval {
   __time_t tv_sec ;
   __suseconds_t tv_usec ;
};

struct _IO_FILE;

struct _IO_FILE;

typedef struct _IO_FILE FILE;

struct _IO_FILE;

typedef void _IO_lock_t;

struct _IO_marker {
   struct _IO_marker *_next ;
   struct _IO_FILE *_sbuf ;
   int _pos ;
};

struct _IO_FILE {
   int _flags ;
   char *_IO_read_ptr ;
   char *_IO_read_end ;
   char *_IO_read_base ;
   char *_IO_write_base ;
   char *_IO_write_ptr ;
   char *_IO_write_end ;
   char *_IO_buf_base ;
   char *_IO_buf_end ;
   char *_IO_save_base ;
   char *_IO_backup_base ;
   char *_IO_save_end ;
   struct _IO_marker *_markers ;
   struct _IO_FILE *_chain ;
   int _fileno ;
   int _flags2 ;
   __off_t _old_offset ;
   unsigned short _cur_column ;
   signed char _vtable_offset ;
   char _shortbuf[1] ;
   _IO_lock_t *_lock ;
   __off64_t _offset ;
   void *__pad1 ;
   void *__pad2 ;
   void *__pad3 ;
   void *__pad4 ;
   size_t __pad5 ;
   int _mode ;
   char _unused2[(15UL * sizeof(int ) - 4UL * sizeof(void *)) - sizeof(size_t )] ;
};

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

struct stack_st {
   int num ;
   char **data ;
   int sorted ;
   int num_alloc ;
   int (*comp)(void const * , void const * ) ;
};

typedef struct stack_st _STACK;

struct bio_st;

struct stack_st_void;

struct crypto_ex_data_st {
   struct stack_st_void *sk ;
   int dummy ;
};

struct stack_st_void {
   _STACK stack ;
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

union __anonunion_cb_26 {
   void (*cb_1)(int , int , void * ) ;
   int (*cb_2)(int , int , BN_GENCB * ) ;
};

struct bn_gencb_st {
   unsigned int ver ;
   void *arg ;
   union __anonunion_cb_26 cb ;
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

struct SHA256state_st {
   unsigned int h[8] ;
   unsigned int Nl ;
   unsigned int Nh ;
   unsigned int data[16] ;
   unsigned int num ;
   unsigned int md_len ;
};

typedef struct SHA256state_st SHA256_CTX;

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

typedef unsigned char DES_cblock[8];

typedef unsigned char const_DES_cblock[8];

union __anonunion_ks_46 {
   DES_cblock cblock ;
   unsigned int deslong[2] ;
};

struct DES_ks {
   union __anonunion_ks_46 ks[16] ;
};

typedef struct DES_ks DES_key_schedule;

struct aes_key_st {
   unsigned int rd_key[60] ;
   int rounds ;
};

typedef struct aes_key_st AES_KEY;

extern BN_CTX *BN_CTX_new(void) ;
static BN_CTX *__crest_BN_CTX_new_opaque(void)
{
  BN_CTX *__crest_ret ;

  {
  __CrestCallOpaque("BN_CTX_new", (void (*)())(& BN_CTX_new), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("BN_CTX_new()");
  __CrestNondet();
  __CrestLoadTypeSize("TSComp(struct bignum_ctx, )");
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BN_CTX_new();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void BN_CTX_init(BN_CTX *c ) ;
static void __crest_BN_CTX_init_opaque(BN_CTX *c )
{


  {
  __CrestCallOpaque("BN_CTX_init", (void (*)())(& BN_CTX_init), 1);
  __CrestClear(1);
  __CrestMute();
  BN_CTX_init(c);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void BN_CTX_free(BN_CTX *c ) ;
static void __crest_BN_CTX_free_opaque(BN_CTX *c )
{


  {
  __CrestCallOpaque("BN_CTX_free", (void (*)())(& BN_CTX_free), 1);
  __CrestClear(1);
  __CrestMute();
  BN_CTX_free(c);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void BN_CTX_start(BN_CTX *ctx ) ;
static void __crest_BN_CTX_start_opaque(BN_CTX *ctx )
{


  {
  __CrestCallOpaque("BN_CTX_start", (void (*)())(& BN_CTX_start), 1);
  __CrestClear(1);
  __CrestMute();
  BN_CTX_start(ctx);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern BIGNUM *BN_CTX_get(BN_CTX *ctx ) ;
static BIGNUM *__crest_BN_CTX_get_opaque(BN_CTX *ctx )
{
  BIGNUM *__crest_ret ;

  {
  __CrestCallOpaque("BN_CTX_get", (void (*)())(& BN_CTX_get), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("BN_CTX_get()");
  __CrestNondet();
  __CrestLoadInt((long long )24);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BN_CTX_get(ctx);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void BN_CTX_end(BN_CTX *ctx ) ;
static void __crest_BN_CTX_end_opaque(BN_CTX *ctx )
{


  {
  __CrestCallOpaque("BN_CTX_end", (void (*)())(& BN_CTX_end), 1);
  __CrestClear(1);
  __CrestMute();
  BN_CTX_end(ctx);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern int BN_rand_range(BIGNUM *rnd , BIGNUM const *range ) ;
static int __crest_BN_rand_range_opaque(BIGNUM *rnd , BIGNUM const *range )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_rand_range", (void (*)())(& BN_rand_range), 2);
  __CrestApply("(BN_rand_range() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_rand_range(rnd, range);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BN_num_bits(BIGNUM const *a ) ;
static int __crest_BN_num_bits_opaque(BIGNUM const *a )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_num_bits", (void (*)())(& BN_num_bits), 1);
  __CrestApply("(BN_num_bits() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_num_bits(a);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern BIGNUM *BN_new(void) ;
static BIGNUM *__crest_BN_new_opaque(void)
{
  BIGNUM *__crest_ret ;

  {
  __CrestCallOpaque("BN_new", (void (*)())(& BN_new), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("BN_new()");
  __CrestNondet();
  __CrestLoadInt((long long )24);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BN_new();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void BN_init(BIGNUM * ) ;
static void __crest_BN_init_opaque(BIGNUM *__crest_tmp1 )
{


  {
  __CrestCallOpaque("BN_init", (void (*)())(& BN_init), 1);
  __CrestClear(1);
  __CrestMute();
  BN_init(__crest_tmp1);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void BN_clear_free(BIGNUM *a ) ;
static void __crest_BN_clear_free_opaque(BIGNUM *a )
{


  {
  __CrestCallOpaque("BN_clear_free", (void (*)())(& BN_clear_free), 1);
  __CrestClear(1);
  __CrestMute();
  BN_clear_free(a);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern BIGNUM *BN_copy(BIGNUM *a , BIGNUM const *b ) ;
static BIGNUM *__crest_BN_copy_opaque(BIGNUM *a , BIGNUM const *b )
{
  BIGNUM *__crest_ret ;

  {
  __CrestCallOpaque("BN_copy", (void (*)())(& BN_copy), 2);
  __CrestClear(2);
  __CrestLoadStackPtr("BN_copy()");
  __CrestNondet();
  __CrestLoadInt((long long )24);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BN_copy(a, b);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern BIGNUM *BN_bin2bn(unsigned char const *s , int len , BIGNUM *ret ) ;
static BIGNUM *__crest_BN_bin2bn_opaque(unsigned char const *s , int len , BIGNUM *ret )
{
  BIGNUM *__crest_ret ;

  {
  __CrestCallOpaque("BN_bin2bn", (void (*)())(& BN_bin2bn), 3);
  __CrestClear(3);
  __CrestLoadStackPtr("BN_bin2bn()");
  __CrestNondet();
  __CrestLoadInt((long long )24);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BN_bin2bn(s, len, ret);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BN_bn2bin(BIGNUM const *a , unsigned char *to ) ;
static int __crest_BN_bn2bin_opaque(BIGNUM const *a , unsigned char *to )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_bn2bin", (void (*)())(& BN_bn2bin), 2);
  __CrestApply("(BN_bn2bin() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_bn2bin(a, to);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BN_add(BIGNUM *r , BIGNUM const *a , BIGNUM const *b ) ;
static int __crest_BN_add_opaque(BIGNUM *r , BIGNUM const *a , BIGNUM const *b )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_add", (void (*)())(& BN_add), 3);
  __CrestApply("(BN_add() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_add(r, a, b);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BN_div(BIGNUM *dv , BIGNUM *rem , BIGNUM const *m , BIGNUM const *d ,
                  BN_CTX *ctx ) ;
static int __crest_BN_div_opaque(BIGNUM *dv , BIGNUM *rem , BIGNUM const *m , BIGNUM const *d ,
                                 BN_CTX *ctx )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_div", (void (*)())(& BN_div), 5);
  __CrestApply("(BN_div() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_div(dv, rem, m, d, ctx);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BN_set_word(BIGNUM *a , unsigned long w ) ;
static int __crest_BN_set_word_opaque(BIGNUM *a , unsigned long w )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_set_word", (void (*)())(& BN_set_word), 2);
  __CrestApply("(BN_set_word() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_set_word(a, w);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void BN_free(BIGNUM *a ) ;
static void __crest_BN_free_opaque(BIGNUM *a )
{


  {
  __CrestCallOpaque("BN_free", (void (*)())(& BN_free), 1);
  __CrestClear(1);
  __CrestMute();
  BN_free(a);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern int BN_mod_exp(BIGNUM *r , BIGNUM const *a , BIGNUM const *p , BIGNUM const *m ,
                      BN_CTX *ctx ) ;
static int __crest_BN_mod_exp_opaque(BIGNUM *r , BIGNUM const *a , BIGNUM const *p ,
                                     BIGNUM const *m , BN_CTX *ctx )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_mod_exp", (void (*)())(& BN_mod_exp), 5);
  __CrestApply("(BN_mod_exp() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_mod_exp(r, a, p, m, ctx);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BN_mod_exp_mont(BIGNUM *r , BIGNUM const *a , BIGNUM const *p , BIGNUM const *m ,
                           BN_CTX *ctx , BN_MONT_CTX *m_ctx ) ;
static int __crest_BN_mod_exp_mont_opaque(BIGNUM *r , BIGNUM const *a , BIGNUM const *p ,
                                          BIGNUM const *m , BN_CTX *ctx , BN_MONT_CTX *m_ctx )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_mod_exp_mont", (void (*)())(& BN_mod_exp_mont), 6);
  __CrestApply("(BN_mod_exp_mont() : bitstring * bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_mod_exp_mont(r, a, p, m, ctx, m_ctx);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BN_mod_exp2_mont(BIGNUM *r , BIGNUM const *a1 , BIGNUM const *p1 ,
                            BIGNUM const *a2 , BIGNUM const *p2 , BIGNUM const *m ,
                            BN_CTX *ctx , BN_MONT_CTX *m_ctx ) ;
static int __crest_BN_mod_exp2_mont_opaque(BIGNUM *r , BIGNUM const *a1 , BIGNUM const *p1 ,
                                           BIGNUM const *a2 , BIGNUM const *p2 ,
                                           BIGNUM const *m , BN_CTX *ctx , BN_MONT_CTX *m_ctx )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_mod_exp2_mont", (void (*)())(& BN_mod_exp2_mont), 8);
  __CrestApply("(BN_mod_exp2_mont() : bitstring * bitstring * bitstring * bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_mod_exp2_mont(r, a1, p1, a2, p2, m, ctx, m_ctx);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BN_print_fp(FILE *fp , BIGNUM const *a ) ;
static int __crest_BN_print_fp_opaque(FILE *fp , BIGNUM const *a )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_print_fp", (void (*)())(& BN_print_fp), 2);
  __CrestApply("(BN_print_fp() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_print_fp(fp, a);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern char *BN_bn2hex(BIGNUM const *a ) ;
static char *__crest_BN_bn2hex_opaque(BIGNUM const *a )
{
  char *__crest_ret ;

  {
  __CrestCallOpaque("BN_bn2hex", (void (*)())(& BN_bn2hex), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("BN_bn2hex()");
  __CrestNondet();
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BN_bn2hex(a);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BN_hex2bn(BIGNUM **a , char const *str ) ;
static int __crest_BN_hex2bn_opaque(BIGNUM **a , char const *str )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BN_hex2bn", (void (*)())(& BN_hex2bn), 2);
  __CrestApply("(BN_hex2bn() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BN_hex2bn(a, str);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern BIGNUM *BN_mod_inverse(BIGNUM *ret , BIGNUM const *a , BIGNUM const *n ,
                              BN_CTX *ctx ) ;
static BIGNUM *__crest_BN_mod_inverse_opaque(BIGNUM *ret , BIGNUM const *a , BIGNUM const *n ,
                                             BN_CTX *ctx )
{
  BIGNUM *__crest_ret ;

  {
  __CrestCallOpaque("BN_mod_inverse", (void (*)())(& BN_mod_inverse), 4);
  __CrestClear(4);
  __CrestLoadStackPtr("BN_mod_inverse()");
  __CrestNondet();
  __CrestLoadInt((long long )24);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BN_mod_inverse(ret, a, n, ctx);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void BN_MONT_CTX_free(BN_MONT_CTX *mont ) ;
static void __crest_BN_MONT_CTX_free_opaque(BN_MONT_CTX *mont )
{


  {
  __CrestCallOpaque("BN_MONT_CTX_free", (void (*)())(& BN_MONT_CTX_free), 1);
  __CrestClear(1);
  __CrestMute();
  BN_MONT_CTX_free(mont);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern BN_MONT_CTX *BN_MONT_CTX_set_locked(BN_MONT_CTX **pmont , int lock , BIGNUM const *mod ,
                                           BN_CTX *ctx ) ;
static BN_MONT_CTX *__crest_BN_MONT_CTX_set_locked_opaque(BN_MONT_CTX **pmont , int lock ,
                                                          BIGNUM const *mod , BN_CTX *ctx )
{
  BN_MONT_CTX *__crest_ret ;

  {
  __CrestCallOpaque("BN_MONT_CTX_set_locked", (void (*)())(& BN_MONT_CTX_set_locked),
                    4);
  __CrestClear(4);
  __CrestLoadStackPtr("BN_MONT_CTX_set_locked()");
  __CrestNondet();
  __CrestLoadInt((long long )104);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BN_MONT_CTX_set_locked(pmont, lock, mod, ctx);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void proxy_fail(char const *fmt , ...) ;

extern int BIO_free(BIO *a ) ;
static int __crest_BIO_free_opaque(BIO *a )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BIO_free", (void (*)())(& BIO_free), 1);
  __CrestApply("(BIO_free() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BIO_free(a);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BIO_read(BIO *b , void *data , int len ) ;
static int __crest_BIO_read_opaque(BIO *b , void *data , int len )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BIO_read", (void (*)())(& BIO_read), 3);
  __CrestApply("(BIO_read() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BIO_read(b, data, len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int BIO_write(BIO *b , void const *data , int len ) ;
static int __crest_BIO_write_opaque(BIO *b , void const *data , int len )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("BIO_write", (void (*)())(& BIO_write), 3);
  __CrestApply("(BIO_write() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BIO_write(b, data, len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern long BIO_ctrl(BIO *bp , int cmd , long larg , void *parg ) ;
static long __crest_BIO_ctrl_opaque(BIO *bp , int cmd , long larg , void *parg )
{
  long __crest_ret ;

  {
  __CrestCallOpaque("BIO_ctrl", (void (*)())(& BIO_ctrl), 4);
  __CrestApply("(BIO_ctrl() : bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = BIO_ctrl(bp, cmd, larg, parg);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern BIO *BIO_pop(BIO *b ) ;
static BIO *__crest_BIO_pop_opaque(BIO *b )
{
  BIO *__crest_ret ;

  {
  __CrestCallOpaque("BIO_pop", (void (*)())(& BIO_pop), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("BIO_pop()");
  __CrestNondet();
  __CrestLoadInt((long long )112);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BIO_pop(b);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern BIO *BIO_find_type(BIO *b , int bio_type ) ;

extern BIO *BIO_new_connect(char const *host_port ) ;
static BIO *__crest_BIO_new_connect_opaque(char const *host_port )
{
  BIO *__crest_ret ;

  {
  __CrestCallOpaque("BIO_new_connect", (void (*)())(& BIO_new_connect), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("BIO_new_connect()");
  __CrestNondet();
  __CrestLoadInt((long long )112);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BIO_new_connect(host_port);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern BIO *BIO_new_accept(char const *host_port ) ;
static BIO *__crest_BIO_new_accept_opaque(char const *host_port )
{
  BIO *__crest_ret ;

  {
  __CrestCallOpaque("BIO_new_accept", (void (*)())(& BIO_new_accept), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("BIO_new_accept()");
  __CrestNondet();
  __CrestLoadInt((long long )112);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = BIO_new_accept(host_port);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_MD const *EVP_MD_CTX_md(EVP_MD_CTX const *ctx ) ;
static EVP_MD const *__crest_EVP_MD_CTX_md_opaque(EVP_MD_CTX const *ctx )
{
  EVP_MD const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_MD_CTX_md", (void (*)())(& EVP_MD_CTX_md), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("EVP_MD_CTX_md()");
  __CrestNondet();
  __CrestLoadInt((long long )120);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_MD_CTX_md(ctx);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_CIPHER_CTX_key_length(EVP_CIPHER_CTX const *ctx ) ;

extern int EVP_CIPHER_CTX_iv_length(EVP_CIPHER_CTX const *ctx ) ;

extern int EVP_Cipher(EVP_CIPHER_CTX *c , unsigned char *out , unsigned char const *in ,
                      unsigned int inl ) ;
static int __crest_EVP_Cipher_opaque(EVP_CIPHER_CTX *c , unsigned char *out , unsigned char const *in ,
                                     unsigned int inl )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_Cipher", (void (*)())(& EVP_Cipher), 4);
  __CrestApply("(EVP_Cipher() : bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_Cipher(c, out, in, inl);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_MD_CTX_copy_ex(EVP_MD_CTX *out , EVP_MD_CTX const *in ) ;
static int __crest_EVP_MD_CTX_copy_ex_opaque(EVP_MD_CTX *out , EVP_MD_CTX const *in )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_MD_CTX_copy_ex", (void (*)())(& EVP_MD_CTX_copy_ex), 2);
  __CrestApply("(EVP_MD_CTX_copy_ex() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_MD_CTX_copy_ex(out, in);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_DigestInit_ex(EVP_MD_CTX *ctx , EVP_MD const *type , ENGINE *impl ) ;
static int __crest_EVP_DigestInit_ex_opaque(EVP_MD_CTX *ctx , EVP_MD const *type ,
                                            ENGINE *impl )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_DigestInit_ex", (void (*)())(& EVP_DigestInit_ex), 3);
  __CrestApply("(EVP_DigestInit_ex() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_DigestInit_ex(ctx, type, impl);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_DigestUpdate(EVP_MD_CTX *ctx , void const *d , size_t cnt ) ;
static int __crest_EVP_DigestUpdate_opaque(EVP_MD_CTX *ctx , void const *d , size_t cnt )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_DigestUpdate", (void (*)())(& EVP_DigestUpdate), 3);
  __CrestApply("(EVP_DigestUpdate() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_DigestUpdate(ctx, d, cnt);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_DigestFinal_ex(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ) ;
static int __crest_EVP_DigestFinal_ex_opaque(EVP_MD_CTX *ctx , unsigned char *md ,
                                             unsigned int *s )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_DigestFinal_ex", (void (*)())(& EVP_DigestFinal_ex), 3);
  __CrestApply("(EVP_DigestFinal_ex() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_DigestFinal_ex(ctx, md, s);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_MD_CTX_copy(EVP_MD_CTX *out , EVP_MD_CTX const *in ) ;
static int __crest_EVP_MD_CTX_copy_opaque(EVP_MD_CTX *out , EVP_MD_CTX const *in )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_MD_CTX_copy", (void (*)())(& EVP_MD_CTX_copy), 2);
  __CrestApply("(EVP_MD_CTX_copy() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_MD_CTX_copy(out, in);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_DigestInit(EVP_MD_CTX *ctx , EVP_MD const *type ) ;
static int __crest_EVP_DigestInit_opaque(EVP_MD_CTX *ctx , EVP_MD const *type )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_DigestInit", (void (*)())(& EVP_DigestInit), 2);
  __CrestApply("(EVP_DigestInit() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_DigestInit(ctx, type);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_EncryptInit_ex(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher , ENGINE *impl ,
                              unsigned char const *key , unsigned char const *iv ) ;
static int __crest_EVP_EncryptInit_ex_opaque(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                             ENGINE *impl , unsigned char const *key ,
                                             unsigned char const *iv )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_EncryptInit_ex", (void (*)())(& EVP_EncryptInit_ex), 5);
  __CrestApply("(EVP_EncryptInit_ex() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_EncryptInit_ex(ctx, cipher, impl, key, iv);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_EncryptUpdate(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                             unsigned char const *in , int inl ) ;
static int __crest_EVP_EncryptUpdate_opaque(EVP_CIPHER_CTX *ctx , unsigned char *out ,
                                            int *outl , unsigned char const *in ,
                                            int inl )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_EncryptUpdate", (void (*)())(& EVP_EncryptUpdate), 5);
  __CrestApply("(EVP_EncryptUpdate() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_EncryptUpdate(ctx, out, outl, in, inl);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_EncryptFinal(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ) ;
static int __crest_EVP_EncryptFinal_opaque(EVP_CIPHER_CTX *ctx , unsigned char *out ,
                                           int *outl )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_EncryptFinal", (void (*)())(& EVP_EncryptFinal), 3);
  __CrestApply("(EVP_EncryptFinal() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_EncryptFinal(ctx, out, outl);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_DecryptInit_ex(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher , ENGINE *impl ,
                              unsigned char const *key , unsigned char const *iv ) ;
static int __crest_EVP_DecryptInit_ex_opaque(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                             ENGINE *impl , unsigned char const *key ,
                                             unsigned char const *iv )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_DecryptInit_ex", (void (*)())(& EVP_DecryptInit_ex), 5);
  __CrestApply("(EVP_DecryptInit_ex() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_DecryptInit_ex(ctx, cipher, impl, key, iv);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_DecryptUpdate(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                             unsigned char const *in , int inl ) ;
static int __crest_EVP_DecryptUpdate_opaque(EVP_CIPHER_CTX *ctx , unsigned char *out ,
                                            int *outl , unsigned char const *in ,
                                            int inl )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_DecryptUpdate", (void (*)())(& EVP_DecryptUpdate), 5);
  __CrestApply("(EVP_DecryptUpdate() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_DecryptUpdate(ctx, out, outl, in, inl);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_DecryptFinal(EVP_CIPHER_CTX *ctx , unsigned char *outm , int *outl ) ;
static int __crest_EVP_DecryptFinal_opaque(EVP_CIPHER_CTX *ctx , unsigned char *outm ,
                                           int *outl )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_DecryptFinal", (void (*)())(& EVP_DecryptFinal), 3);
  __CrestApply("(EVP_DecryptFinal() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_DecryptFinal(ctx, outm, outl);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_CipherInit_ex(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher , ENGINE *impl ,
                             unsigned char const *key , unsigned char const *iv ,
                             int enc ) ;
static int __crest_EVP_CipherInit_ex_opaque(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                            ENGINE *impl , unsigned char const *key ,
                                            unsigned char const *iv , int enc )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_CipherInit_ex", (void (*)())(& EVP_CipherInit_ex), 6);
  __CrestApply("(EVP_CipherInit_ex() : bitstring * bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_CipherInit_ex(ctx, cipher, impl, key, iv, enc);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_SignFinal(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s , EVP_PKEY *pkey ) ;
static int __crest_EVP_SignFinal_opaque(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ,
                                        EVP_PKEY *pkey )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_SignFinal", (void (*)())(& EVP_SignFinal), 4);
  __CrestApply("(EVP_SignFinal() : bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_SignFinal(ctx, md, s, pkey);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_VerifyFinal(EVP_MD_CTX *ctx , unsigned char const *sigbuf , unsigned int siglen ,
                           EVP_PKEY *pkey ) ;
static int __crest_EVP_VerifyFinal_opaque(EVP_MD_CTX *ctx , unsigned char const *sigbuf ,
                                          unsigned int siglen , EVP_PKEY *pkey )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_VerifyFinal", (void (*)())(& EVP_VerifyFinal), 4);
  __CrestApply("(EVP_VerifyFinal() : bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_VerifyFinal(ctx, sigbuf, siglen, pkey);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_DigestSignInit(EVP_MD_CTX *ctx , EVP_PKEY_CTX **pctx , EVP_MD const *type ,
                              ENGINE *e , EVP_PKEY *pkey ) ;
static int __crest_EVP_DigestSignInit_opaque(EVP_MD_CTX *ctx , EVP_PKEY_CTX **pctx ,
                                             EVP_MD const *type , ENGINE *e , EVP_PKEY *pkey )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_DigestSignInit", (void (*)())(& EVP_DigestSignInit), 5);
  __CrestApply("(EVP_DigestSignInit() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_DigestSignInit(ctx, pctx, type, e, pkey);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_DigestSignFinal(EVP_MD_CTX *ctx , unsigned char *sigret , size_t *siglen ) ;
static int __crest_EVP_DigestSignFinal_opaque(EVP_MD_CTX *ctx , unsigned char *sigret ,
                                              size_t *siglen )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_DigestSignFinal", (void (*)())(& EVP_DigestSignFinal), 3);
  __CrestApply("(EVP_DigestSignFinal() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_DigestSignFinal(ctx, sigret, siglen);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_MD const *EVP_md5(void) ;
static EVP_MD const *__crest_EVP_md5_opaque(void)
{
  EVP_MD const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_md5", (void (*)())(& EVP_md5), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_md5()");
  __CrestNondet();
  __CrestLoadInt((long long )120);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_md5();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_MD const *EVP_sha1(void) ;
static EVP_MD const *__crest_EVP_sha1_opaque(void)
{
  EVP_MD const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_sha1", (void (*)())(& EVP_sha1), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_sha1()");
  __CrestNondet();
  __CrestLoadInt((long long )120);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_sha1();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_MD const *EVP_dss1(void) ;
static EVP_MD const *__crest_EVP_dss1_opaque(void)
{
  EVP_MD const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_dss1", (void (*)())(& EVP_dss1), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_dss1()");
  __CrestNondet();
  __CrestLoadInt((long long )120);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_dss1();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_MD const *EVP_ecdsa(void) ;
static EVP_MD const *__crest_EVP_ecdsa_opaque(void)
{
  EVP_MD const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_ecdsa", (void (*)())(& EVP_ecdsa), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_ecdsa()");
  __CrestNondet();
  __CrestLoadInt((long long )120);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_ecdsa();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_MD const *EVP_sha256(void) ;
static EVP_MD const *__crest_EVP_sha256_opaque(void)
{
  EVP_MD const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_sha256", (void (*)())(& EVP_sha256), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_sha256()");
  __CrestNondet();
  __CrestLoadInt((long long )120);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_sha256();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_enc_null(void) ;
static EVP_CIPHER const *__crest_EVP_enc_null_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_enc_null", (void (*)())(& EVP_enc_null), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_enc_null()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_enc_null();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_des_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_des_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_des_cbc", (void (*)())(& EVP_des_cbc), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_des_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_des_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_des_ede3_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_des_ede3_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_des_ede3_cbc", (void (*)())(& EVP_des_ede3_cbc), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_des_ede3_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_des_ede3_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_rc4(void) ;
static EVP_CIPHER const *__crest_EVP_rc4_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_rc4", (void (*)())(& EVP_rc4), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_rc4()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_rc4();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_rc2_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_rc2_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_rc2_cbc", (void (*)())(& EVP_rc2_cbc), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_rc2_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_rc2_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_rc2_40_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_rc2_40_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_rc2_40_cbc", (void (*)())(& EVP_rc2_40_cbc), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_rc2_40_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_rc2_40_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_aes_128_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_aes_128_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_aes_128_cbc", (void (*)())(& EVP_aes_128_cbc), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_aes_128_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_aes_128_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_aes_192_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_aes_192_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_aes_192_cbc", (void (*)())(& EVP_aes_192_cbc), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_aes_192_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_aes_192_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_aes_256_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_aes_256_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_aes_256_cbc", (void (*)())(& EVP_aes_256_cbc), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_aes_256_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_aes_256_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_camellia_128_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_camellia_128_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_camellia_128_cbc", (void (*)())(& EVP_camellia_128_cbc),
                    0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_camellia_128_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_camellia_128_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_camellia_256_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_camellia_256_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_camellia_256_cbc", (void (*)())(& EVP_camellia_256_cbc),
                    0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_camellia_256_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_camellia_256_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_seed_cbc(void) ;
static EVP_CIPHER const *__crest_EVP_seed_cbc_opaque(void)
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_seed_cbc", (void (*)())(& EVP_seed_cbc), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("EVP_seed_cbc()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_seed_cbc();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_CIPHER const *EVP_get_cipherbyname(char const *name ) ;
static EVP_CIPHER const *__crest_EVP_get_cipherbyname_opaque(char const *name )
{
  EVP_CIPHER const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_get_cipherbyname", (void (*)())(& EVP_get_cipherbyname),
                    1);
  __CrestClear(1);
  __CrestLoadStackPtr("EVP_get_cipherbyname()");
  __CrestNondet();
  __CrestLoadInt((long long )88);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_get_cipherbyname(name);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_MD const *EVP_get_digestbyname(char const *name ) ;
static EVP_MD const *__crest_EVP_get_digestbyname_opaque(char const *name )
{
  EVP_MD const *__crest_ret ;

  {
  __CrestCallOpaque("EVP_get_digestbyname", (void (*)())(& EVP_get_digestbyname),
                    1);
  __CrestClear(1);
  __CrestLoadStackPtr("EVP_get_digestbyname()");
  __CrestNondet();
  __CrestLoadInt((long long )120);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_get_digestbyname(name);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_PKEY_assign(EVP_PKEY *pkey , int type , void *key ) ;
static int __crest_EVP_PKEY_assign_opaque(EVP_PKEY *pkey , int type , void *key )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_assign", (void (*)())(& EVP_PKEY_assign), 3);
  __CrestApply("(EVP_PKEY_assign() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_PKEY_assign(pkey, type, key);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_PKEY *d2i_PrivateKey(int type , EVP_PKEY **a , unsigned char const **pp ,
                                long length ) ;
static EVP_PKEY *__crest_d2i_PrivateKey_opaque(int type , EVP_PKEY **a , unsigned char const **pp ,
                                               long length )
{
  EVP_PKEY *__crest_ret ;

  {
  __CrestCallOpaque("d2i_PrivateKey", (void (*)())(& d2i_PrivateKey), 4);
  __CrestClear(4);
  __CrestLoadStackPtr("d2i_PrivateKey()");
  __CrestNondet();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = d2i_PrivateKey(type, a, pp, length);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_PKEY_copy_parameters(EVP_PKEY *to , EVP_PKEY const *from ) ;
static int __crest_EVP_PKEY_copy_parameters_opaque(EVP_PKEY *to , EVP_PKEY const *from )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_copy_parameters", (void (*)())(& EVP_PKEY_copy_parameters),
                    2);
  __CrestApply("(EVP_PKEY_copy_parameters() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_PKEY_copy_parameters(to, from);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_PKEY_CTX *EVP_PKEY_CTX_new(EVP_PKEY *pkey , ENGINE *e ) ;
static EVP_PKEY_CTX *__crest_EVP_PKEY_CTX_new_opaque(EVP_PKEY *pkey , ENGINE *e )
{
  EVP_PKEY_CTX *__crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_CTX_new", (void (*)())(& EVP_PKEY_CTX_new), 2);
  __CrestClear(2);
  __CrestLoadStackPtr("EVP_PKEY_CTX_new()");
  __CrestNondet();
  __CrestLoadTypeSize("TSComp(struct evp_pkey_ctx_st, )");
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_PKEY_CTX_new(pkey, e);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_PKEY_CTX_ctrl(EVP_PKEY_CTX *ctx , int keytype , int optype , int cmd ,
                             int p1 , void *p2 ) ;
static int __crest_EVP_PKEY_CTX_ctrl_opaque(EVP_PKEY_CTX *ctx , int keytype , int optype ,
                                            int cmd , int p1 , void *p2 )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_CTX_ctrl", (void (*)())(& EVP_PKEY_CTX_ctrl), 6);
  __CrestApply("(EVP_PKEY_CTX_ctrl() : bitstring * bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_PKEY_CTX_ctrl(ctx, keytype, optype, cmd, p1, p2);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_PKEY *EVP_PKEY_new_mac_key(int type , ENGINE *e , unsigned char const *key ,
                                      int keylen ) ;
static EVP_PKEY *__crest_EVP_PKEY_new_mac_key_opaque(int type , ENGINE *e , unsigned char const *key ,
                                                     int keylen )
{
  EVP_PKEY *__crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_new_mac_key", (void (*)())(& EVP_PKEY_new_mac_key),
                    4);
  __CrestClear(4);
  __CrestLoadStackPtr("EVP_PKEY_new_mac_key()");
  __CrestNondet();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = EVP_PKEY_new_mac_key(type, e, key, keylen);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_PKEY_sign(EVP_PKEY_CTX *ctx , unsigned char *sig , size_t *siglen ,
                         unsigned char const *tbs , size_t tbslen ) ;
static int __crest_EVP_PKEY_sign_opaque(EVP_PKEY_CTX *ctx , unsigned char *sig , size_t *siglen ,
                                        unsigned char const *tbs , size_t tbslen )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_sign", (void (*)())(& EVP_PKEY_sign), 5);
  __CrestApply("(EVP_PKEY_sign() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_PKEY_sign(ctx, sig, siglen, tbs, tbslen);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_PKEY_verify(EVP_PKEY_CTX *ctx , unsigned char const *sig , size_t siglen ,
                           unsigned char const *tbs , size_t tbslen ) ;
static int __crest_EVP_PKEY_verify_opaque(EVP_PKEY_CTX *ctx , unsigned char const *sig ,
                                          size_t siglen , unsigned char const *tbs ,
                                          size_t tbslen )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_verify", (void (*)())(& EVP_PKEY_verify), 5);
  __CrestApply("(EVP_PKEY_verify() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_PKEY_verify(ctx, sig, siglen, tbs, tbslen);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_PKEY_encrypt(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                            unsigned char const *in , size_t inlen ) ;
static int __crest_EVP_PKEY_encrypt_opaque(EVP_PKEY_CTX *ctx , unsigned char *out ,
                                           size_t *outlen , unsigned char const *in ,
                                           size_t inlen )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_encrypt", (void (*)())(& EVP_PKEY_encrypt), 5);
  __CrestApply("(EVP_PKEY_encrypt() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_PKEY_encrypt(ctx, out, outlen, in, inlen);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_PKEY_decrypt(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                            unsigned char const *in , size_t inlen ) ;
static int __crest_EVP_PKEY_decrypt_opaque(EVP_PKEY_CTX *ctx , unsigned char *out ,
                                           size_t *outlen , unsigned char const *in ,
                                           size_t inlen )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_decrypt", (void (*)())(& EVP_PKEY_decrypt), 5);
  __CrestApply("(EVP_PKEY_decrypt() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_PKEY_decrypt(ctx, out, outlen, in, inlen);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int EVP_PKEY_derive_set_peer(EVP_PKEY_CTX *ctx , EVP_PKEY *peer ) ;
static int __crest_EVP_PKEY_derive_set_peer_opaque(EVP_PKEY_CTX *ctx , EVP_PKEY *peer )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("EVP_PKEY_derive_set_peer", (void (*)())(& EVP_PKEY_derive_set_peer),
                    2);
  __CrestApply("(EVP_PKEY_derive_set_peer() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = EVP_PKEY_derive_set_peer(ctx, peer);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern RSA *RSA_generate_key(int bits , unsigned long e , void (*callback)(int ,
                                                                           int ,
                                                                           void * ) ,
                             void *cb_arg ) ;
static RSA *__crest_RSA_generate_key_opaque(int bits , unsigned long e , void (*callback)(int ,
                                                                                          int ,
                                                                                          void * ) ,
                                            void *cb_arg )
{
  RSA *__crest_ret ;

  {
  __CrestCallOpaque("RSA_generate_key", (void (*)())(& RSA_generate_key), 4);
  __CrestClear(4);
  __CrestLoadStackPtr("RSA_generate_key()");
  __CrestNondet();
  __CrestLoadInt((long long )168);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = RSA_generate_key(bits, e, callback, cb_arg);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int RSA_public_encrypt(int flen , unsigned char const *from , unsigned char *to ,
                              RSA *rsa , int padding ) ;
static int __crest_RSA_public_encrypt_opaque(int flen , unsigned char const *from ,
                                             unsigned char *to , RSA *rsa , int padding )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("RSA_public_encrypt", (void (*)())(& RSA_public_encrypt), 5);
  __CrestApply("(RSA_public_encrypt() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = RSA_public_encrypt(flen, from, to, rsa, padding);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int RSA_private_decrypt(int flen , unsigned char const *from , unsigned char *to ,
                               RSA *rsa , int padding ) ;
static int __crest_RSA_private_decrypt_opaque(int flen , unsigned char const *from ,
                                              unsigned char *to , RSA *rsa , int padding )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("RSA_private_decrypt", (void (*)())(& RSA_private_decrypt), 5);
  __CrestApply("(RSA_private_decrypt() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = RSA_private_decrypt(flen, from, to, rsa, padding);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern RSA *d2i_RSAPrivateKey(RSA **a , unsigned char const **in , long len ) ;
static RSA *__crest_d2i_RSAPrivateKey_opaque(RSA **a , unsigned char const **in ,
                                             long len )
{
  RSA *__crest_ret ;

  {
  __CrestCallOpaque("d2i_RSAPrivateKey", (void (*)())(& d2i_RSAPrivateKey), 3);
  __CrestClear(3);
  __CrestLoadStackPtr("d2i_RSAPrivateKey()");
  __CrestNondet();
  __CrestLoadInt((long long )168);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = d2i_RSAPrivateKey(a, in, len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int RSA_sign(int type , unsigned char const *m , unsigned int m_length ,
                    unsigned char *sigret , unsigned int *siglen , RSA *rsa ) ;
static int __crest_RSA_sign_opaque(int type , unsigned char const *m , unsigned int m_length ,
                                   unsigned char *sigret , unsigned int *siglen ,
                                   RSA *rsa )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("RSA_sign", (void (*)())(& RSA_sign), 6);
  __CrestApply("(RSA_sign() : bitstring * bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = RSA_sign(type, m, m_length, sigret, siglen, rsa);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int RSA_verify(int type , unsigned char const *m , unsigned int m_length ,
                      unsigned char const *sigbuf , unsigned int siglen , RSA *rsa ) ;
static int __crest_RSA_verify_opaque(int type , unsigned char const *m , unsigned int m_length ,
                                     unsigned char const *sigbuf , unsigned int siglen ,
                                     RSA *rsa )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("RSA_verify", (void (*)())(& RSA_verify), 6);
  __CrestApply("(RSA_verify() : bitstring * bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = RSA_verify(type, m, m_length, sigbuf, siglen, rsa);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void RSA_blinding_off(RSA *rsa ) ;
static void __crest_RSA_blinding_off_opaque(RSA *rsa )
{


  {
  __CrestCallOpaque("RSA_blinding_off", (void (*)())(& RSA_blinding_off), 1);
  __CrestClear(1);
  __CrestMute();
  RSA_blinding_off(rsa);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern RSA *RSAPrivateKey_dup(RSA *rsa ) ;
static RSA *__crest_RSAPrivateKey_dup_opaque(RSA *rsa )
{
  RSA *__crest_ret ;

  {
  __CrestCallOpaque("RSAPrivateKey_dup", (void (*)())(& RSAPrivateKey_dup), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("RSAPrivateKey_dup()");
  __CrestNondet();
  __CrestLoadInt((long long )168);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = RSAPrivateKey_dup(rsa);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern DSA_SIG *DSA_SIG_new(void) ;
static DSA_SIG *__crest_DSA_SIG_new_opaque(void)
{
  DSA_SIG *__crest_ret ;

  {
  __CrestCallOpaque("DSA_SIG_new", (void (*)())(& DSA_SIG_new), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("DSA_SIG_new()");
  __CrestNondet();
  __CrestLoadInt((long long )16);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = DSA_SIG_new();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void DSA_SIG_free(DSA_SIG *a ) ;
static void __crest_DSA_SIG_free_opaque(DSA_SIG *a )
{


  {
  __CrestCallOpaque("DSA_SIG_free", (void (*)())(& DSA_SIG_free), 1);
  __CrestClear(1);
  __CrestMute();
  DSA_SIG_free(a);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern DSA_METHOD const *DSA_get_default_method(void) ;

extern DSA *DSA_new(void) ;
static DSA *__crest_DSA_new_opaque(void)
{
  DSA *__crest_ret ;

  {
  __CrestCallOpaque("DSA_new", (void (*)())(& DSA_new), 0);
  __CrestClear(0);
  __CrestLoadStackPtr("DSA_new()");
  __CrestNondet();
  __CrestLoadInt((long long )136);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = DSA_new();
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern DSA *DSA_new_method(ENGINE *engine ) ;
static DSA *__crest_DSA_new_method_opaque(ENGINE *engine )
{
  DSA *__crest_ret ;

  {
  __CrestCallOpaque("DSA_new_method", (void (*)())(& DSA_new_method), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("DSA_new_method()");
  __CrestNondet();
  __CrestLoadInt((long long )136);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = DSA_new_method(engine);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void DSA_free(DSA *r ) ;
static void __crest_DSA_free_opaque(DSA *r )
{


  {
  __CrestCallOpaque("DSA_free", (void (*)())(& DSA_free), 1);
  __CrestClear(1);
  __CrestMute();
  DSA_free(r);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern int DSA_generate_key(DSA *a ) ;
static int __crest_DSA_generate_key_opaque(DSA *a )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("DSA_generate_key", (void (*)())(& DSA_generate_key), 1);
  __CrestApply("(DSA_generate_key() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = DSA_generate_key(a);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int SHA256_Init(SHA256_CTX *c ) ;
static int __crest_SHA256_Init_opaque(SHA256_CTX *c )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("SHA256_Init", (void (*)())(& SHA256_Init), 1);
  __CrestApply("(SHA256_Init() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = SHA256_Init(c);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int SHA256_Update(SHA256_CTX *c , void const *data , size_t len ) ;
static int __crest_SHA256_Update_opaque(SHA256_CTX *c , void const *data , size_t len )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("SHA256_Update", (void (*)())(& SHA256_Update), 3);
  __CrestApply("(SHA256_Update() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = SHA256_Update(c, data, len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int SHA256_Final(unsigned char *md , SHA256_CTX *c ) ;
static int __crest_SHA256_Final_opaque(unsigned char *md , SHA256_CTX *c )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("SHA256_Final", (void (*)())(& SHA256_Final), 2);
  __CrestApply("(SHA256_Final() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = SHA256_Final(md, c);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern unsigned long lh_strhash(char const *c ) ;

extern int X509_STORE_CTX_init(X509_STORE_CTX *ctx , X509_STORE *store , X509 *x509 ,
                               struct stack_st_X509 *chain ) ;
static int __crest_X509_STORE_CTX_init_opaque(X509_STORE_CTX *ctx , X509_STORE *store ,
                                              X509 *x509 , struct stack_st_X509 *chain )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("X509_STORE_CTX_init", (void (*)())(& X509_STORE_CTX_init), 4);
  __CrestApply("(X509_STORE_CTX_init() : bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = X509_STORE_CTX_init(ctx, store, x509, chain);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern X509 *d2i_X509_bio(BIO *bp , X509 **x509 ) ;
static X509 *__crest_d2i_X509_bio_opaque(BIO *bp , X509 **x509 )
{
  X509 *__crest_ret ;

  {
  __CrestCallOpaque("d2i_X509_bio", (void (*)())(& d2i_X509_bio), 2);
  __CrestClear(2);
  __CrestLoadStackPtr("d2i_X509_bio()");
  __CrestNondet();
  __CrestLoadInt((long long )184);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = d2i_X509_bio(bp, x509);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern RSA *d2i_RSAPrivateKey_bio(BIO *bp , RSA **rsa ) ;
static RSA *__crest_d2i_RSAPrivateKey_bio_opaque(BIO *bp , RSA **rsa )
{
  RSA *__crest_ret ;

  {
  __CrestCallOpaque("d2i_RSAPrivateKey_bio", (void (*)())(& d2i_RSAPrivateKey_bio),
                    2);
  __CrestClear(2);
  __CrestLoadStackPtr("d2i_RSAPrivateKey_bio()");
  __CrestNondet();
  __CrestLoadInt((long long )168);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = d2i_RSAPrivateKey_bio(bp, rsa);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_PKEY *d2i_PrivateKey_bio(BIO *bp , EVP_PKEY **a ) ;
static EVP_PKEY *__crest_d2i_PrivateKey_bio_opaque(BIO *bp , EVP_PKEY **a )
{
  EVP_PKEY *__crest_ret ;

  {
  __CrestCallOpaque("d2i_PrivateKey_bio", (void (*)())(& d2i_PrivateKey_bio), 2);
  __CrestClear(2);
  __CrestLoadStackPtr("d2i_PrivateKey_bio()");
  __CrestNondet();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = d2i_PrivateKey_bio(bp, a);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int i2d_DSA_PUBKEY(DSA *a , unsigned char **pp ) ;
static int __crest_i2d_DSA_PUBKEY_opaque(DSA *a , unsigned char **pp )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("i2d_DSA_PUBKEY", (void (*)())(& i2d_DSA_PUBKEY), 2);
  __CrestApply("(i2d_DSA_PUBKEY() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = i2d_DSA_PUBKEY(a, pp);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern DSA *d2i_DSA_PUBKEY(DSA **a , unsigned char const **pp , long length ) ;
static DSA *__crest_d2i_DSA_PUBKEY_opaque(DSA **a , unsigned char const **pp , long length )
{
  DSA *__crest_ret ;

  {
  __CrestCallOpaque("d2i_DSA_PUBKEY", (void (*)())(& d2i_DSA_PUBKEY), 3);
  __CrestClear(3);
  __CrestLoadStackPtr("d2i_DSA_PUBKEY()");
  __CrestNondet();
  __CrestLoadInt((long long )136);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = d2i_DSA_PUBKEY(a, pp, length);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern X509 *d2i_X509(X509 **a , unsigned char const **in , long len ) ;
static X509 *__crest_d2i_X509_opaque(X509 **a , unsigned char const **in , long len )
{
  X509 *__crest_ret ;

  {
  __CrestCallOpaque("d2i_X509", (void (*)())(& d2i_X509), 3);
  __CrestClear(3);
  __CrestLoadStackPtr("d2i_X509()");
  __CrestNondet();
  __CrestLoadInt((long long )184);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = d2i_X509(a, in, len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int i2d_X509(X509 *a , unsigned char **out ) ;
static int __crest_i2d_X509_opaque(X509 *a , unsigned char **out )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("i2d_X509", (void (*)())(& i2d_X509), 2);
  __CrestApply("(i2d_X509() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = i2d_X509(a, out);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_PKEY *X509_get_pubkey(X509 *x ) ;
static EVP_PKEY *__crest_X509_get_pubkey_opaque(X509 *x )
{
  EVP_PKEY *__crest_ret ;

  {
  __CrestCallOpaque("X509_get_pubkey", (void (*)())(& X509_get_pubkey), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("X509_get_pubkey()");
  __CrestNondet();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = X509_get_pubkey(x);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int X509_certificate_type(X509 *x , EVP_PKEY *pubkey ) ;
static int __crest_X509_certificate_type_opaque(X509 *x , EVP_PKEY *pubkey )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("X509_certificate_type", (void (*)())(& X509_certificate_type),
                    2);
  __CrestApply("(X509_certificate_type() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = X509_certificate_type(x, pubkey);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern X509 *PEM_read_bio_X509(BIO *bp , X509 **x , pem_password_cb *cb , void *u ) ;
static X509 *__crest_PEM_read_bio_X509_opaque(BIO *bp , X509 **x , pem_password_cb *cb ,
                                              void *u )
{
  X509 *__crest_ret ;

  {
  __CrestCallOpaque("PEM_read_bio_X509", (void (*)())(& PEM_read_bio_X509), 4);
  __CrestClear(4);
  __CrestLoadStackPtr("PEM_read_bio_X509()");
  __CrestNondet();
  __CrestLoadInt((long long )184);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = PEM_read_bio_X509(bp, x, cb, u);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern RSA *PEM_read_bio_RSAPrivateKey(BIO *bp , RSA **x , pem_password_cb *cb , void *u ) ;
static RSA *__crest_PEM_read_bio_RSAPrivateKey_opaque(BIO *bp , RSA **x , pem_password_cb *cb ,
                                                      void *u )
{
  RSA *__crest_ret ;

  {
  __CrestCallOpaque("PEM_read_bio_RSAPrivateKey", (void (*)())(& PEM_read_bio_RSAPrivateKey),
                    4);
  __CrestClear(4);
  __CrestLoadStackPtr("PEM_read_bio_RSAPrivateKey()");
  __CrestNondet();
  __CrestLoadInt((long long )168);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = PEM_read_bio_RSAPrivateKey(bp, x, cb, u);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern EVP_PKEY *PEM_read_bio_PrivateKey(BIO *bp , EVP_PKEY **x , pem_password_cb *cb ,
                                         void *u ) ;
static EVP_PKEY *__crest_PEM_read_bio_PrivateKey_opaque(BIO *bp , EVP_PKEY **x , pem_password_cb *cb ,
                                                        void *u )
{
  EVP_PKEY *__crest_ret ;

  {
  __CrestCallOpaque("PEM_read_bio_PrivateKey", (void (*)())(& PEM_read_bio_PrivateKey),
                    4);
  __CrestClear(4);
  __CrestLoadStackPtr("PEM_read_bio_PrivateKey()");
  __CrestNondet();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = PEM_read_bio_PrivateKey(bp, x, cb, u);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int HMAC_Init_ex(HMAC_CTX *ctx , void const *key , int len , EVP_MD const *md ,
                        ENGINE *impl ) ;
static int __crest_HMAC_Init_ex_opaque(HMAC_CTX *ctx , void const *key , int len ,
                                       EVP_MD const *md , ENGINE *impl )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("HMAC_Init_ex", (void (*)())(& HMAC_Init_ex), 5);
  __CrestApply("(HMAC_Init_ex() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = HMAC_Init_ex(ctx, key, len, md, impl);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int HMAC_Update(HMAC_CTX *ctx , unsigned char const *data , size_t len ) ;
static int __crest_HMAC_Update_opaque(HMAC_CTX *ctx , unsigned char const *data ,
                                      size_t len )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("HMAC_Update", (void (*)())(& HMAC_Update), 3);
  __CrestApply("(HMAC_Update() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = HMAC_Update(ctx, data, len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int HMAC_Final(HMAC_CTX *ctx , unsigned char *md , unsigned int *len ) ;
static int __crest_HMAC_Final_opaque(HMAC_CTX *ctx , unsigned char *md , unsigned int *len )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("HMAC_Final", (void (*)())(& HMAC_Final), 3);
  __CrestApply("(HMAC_Final() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = HMAC_Final(ctx, md, len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern unsigned char *HMAC(EVP_MD const *evp_md , void const *key , int key_len ,
                           unsigned char const *d , size_t n , unsigned char *md ,
                           unsigned int *md_len ) ;
static unsigned char *__crest_HMAC_opaque(EVP_MD const *evp_md , void const *key ,
                                          int key_len , unsigned char const *d ,
                                          size_t n , unsigned char *md , unsigned int *md_len )
{
  unsigned char *__crest_ret ;

  {
  __CrestCallOpaque("HMAC", (void (*)())(& HMAC), 7);
  __CrestClear(7);
  __CrestLoadStackPtr("HMAC()");
  __CrestNondet();
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = HMAC(evp_md, key, key_len, d, n, md, md_len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int RAND_bytes(unsigned char *buf , int num ) ;
static int __crest_RAND_bytes_opaque(unsigned char *buf , int num )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("RAND_bytes", (void (*)())(& RAND_bytes), 2);
  __CrestApply("(RAND_bytes() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = RAND_bytes(buf, num);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int RAND_pseudo_bytes(unsigned char *buf , int num ) ;
static int __crest_RAND_pseudo_bytes_opaque(unsigned char *buf , int num )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("RAND_pseudo_bytes", (void (*)())(& RAND_pseudo_bytes), 2);
  __CrestApply("(RAND_pseudo_bytes() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = RAND_pseudo_bytes(buf, num);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void ERR_put_error(int lib , int func , int reason , char const *file , int line ) ;
static void __crest_ERR_put_error_opaque(int lib , int func , int reason , char const *file ,
                                         int line )
{


  {
  __CrestCallOpaque("ERR_put_error", (void (*)())(& ERR_put_error), 5);
  __CrestClear(5);
  __CrestMute();
  ERR_put_error(lib, func, reason, file, line);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void ERR_print_errors_fp(FILE *fp ) ;
static void __crest_ERR_print_errors_fp_opaque(FILE *fp )
{


  {
  __CrestCallOpaque("ERR_print_errors_fp", (void (*)())(& ERR_print_errors_fp), 1);
  __CrestClear(1);
  __CrestMute();
  ERR_print_errors_fp(fp);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void ERR_load_crypto_strings(void) ;
static void __crest_ERR_load_crypto_strings_opaque(void)
{


  {
  __CrestCallOpaque("ERR_load_crypto_strings", & ERR_load_crypto_strings, 0);
  __CrestClear(0);
  __CrestMute();
  ERR_load_crypto_strings();
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern int ENGINE_load_ssl_client_cert(ENGINE *e , SSL *s , struct stack_st_X509_NAME *ca_dn ,
                                       X509 **pcert , EVP_PKEY **ppkey , struct stack_st_X509 **pother ,
                                       UI_METHOD *ui_method , void *callback_data ) ;
static int __crest_ENGINE_load_ssl_client_cert_opaque(ENGINE *e , SSL *s , struct stack_st_X509_NAME *ca_dn ,
                                                      X509 **pcert , EVP_PKEY **ppkey ,
                                                      struct stack_st_X509 **pother ,
                                                      UI_METHOD *ui_method , void *callback_data )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("ENGINE_load_ssl_client_cert", (void (*)())(& ENGINE_load_ssl_client_cert),
                    8);
  __CrestApply("(ENGINE_load_ssl_client_cert() : bitstring * bitstring * bitstring * bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = ENGINE_load_ssl_client_cert(e, s, ca_dn, pcert, ppkey, pother, ui_method,
                                            callback_data);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void DES_ecb3_encrypt(const_DES_cblock *input , DES_cblock *output , DES_key_schedule *ks1 ,
                             DES_key_schedule *ks2 , DES_key_schedule *ks3 , int enc ) ;
static void __crest_DES_ecb3_encrypt_opaque(const_DES_cblock *input , DES_cblock *output ,
                                            DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                            DES_key_schedule *ks3 , int enc )
{


  {
  __CrestCallOpaque("DES_ecb3_encrypt", (void (*)())(& DES_ecb3_encrypt), 6);
  __CrestClear(6);
  __CrestMute();
  DES_ecb3_encrypt(input, output, ks1, ks2, ks3, enc);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void DES_ncbc_encrypt(unsigned char const *input , unsigned char *output ,
                             long length , DES_key_schedule *schedule , DES_cblock *ivec ,
                             int enc ) ;
static void __crest_DES_ncbc_encrypt_opaque(unsigned char const *input , unsigned char *output ,
                                            long length , DES_key_schedule *schedule ,
                                            DES_cblock *ivec , int enc )
{


  {
  __CrestCallOpaque("DES_ncbc_encrypt", (void (*)())(& DES_ncbc_encrypt), 6);
  __CrestClear(6);
  __CrestMute();
  DES_ncbc_encrypt(input, output, length, schedule, ivec, enc);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void DES_ecb_encrypt(const_DES_cblock *input , DES_cblock *output , DES_key_schedule *ks ,
                            int enc ) ;
static void __crest_DES_ecb_encrypt_opaque(const_DES_cblock *input , DES_cblock *output ,
                                           DES_key_schedule *ks , int enc )
{


  {
  __CrestCallOpaque("DES_ecb_encrypt", (void (*)())(& DES_ecb_encrypt), 4);
  __CrestClear(4);
  __CrestMute();
  DES_ecb_encrypt(input, output, ks, enc);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void DES_ede3_cbc_encrypt(unsigned char const *input , unsigned char *output ,
                                 long length , DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                 DES_key_schedule *ks3 , DES_cblock *ivec , int enc ) ;
static void __crest_DES_ede3_cbc_encrypt_opaque(unsigned char const *input , unsigned char *output ,
                                                long length , DES_key_schedule *ks1 ,
                                                DES_key_schedule *ks2 , DES_key_schedule *ks3 ,
                                                DES_cblock *ivec , int enc )
{


  {
  __CrestCallOpaque("DES_ede3_cbc_encrypt", (void (*)())(& DES_ede3_cbc_encrypt),
                    8);
  __CrestClear(8);
  __CrestMute();
  DES_ede3_cbc_encrypt(input, output, length, ks1, ks2, ks3, ivec, enc);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void DES_set_key_unchecked(const_DES_cblock *key , DES_key_schedule *schedule ) ;
static void __crest_DES_set_key_unchecked_opaque(const_DES_cblock *key , DES_key_schedule *schedule )
{


  {
  __CrestCallOpaque("DES_set_key_unchecked", (void (*)())(& DES_set_key_unchecked),
                    2);
  __CrestClear(2);
  __CrestMute();
  DES_set_key_unchecked(key, schedule);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern int AES_set_encrypt_key(unsigned char const *userKey , int const bits ,
                               AES_KEY *key ) ;
static int __crest_AES_set_encrypt_key_opaque(unsigned char const *userKey , int const bits ,
                                              AES_KEY *key )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("AES_set_encrypt_key", (void (*)())(& AES_set_encrypt_key), 3);
  __CrestApply("(AES_set_encrypt_key() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = AES_set_encrypt_key(userKey, bits, key);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int AES_set_decrypt_key(unsigned char const *userKey , int const bits ,
                               AES_KEY *key ) ;
static int __crest_AES_set_decrypt_key_opaque(unsigned char const *userKey , int const bits ,
                                              AES_KEY *key )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("AES_set_decrypt_key", (void (*)())(& AES_set_decrypt_key), 3);
  __CrestApply("(AES_set_decrypt_key() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = AES_set_decrypt_key(userKey, bits, key);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void AES_ecb_encrypt(unsigned char const *in , unsigned char *out , AES_KEY const *key ,
                            int const enc ) ;
static void __crest_AES_ecb_encrypt_opaque(unsigned char const *in , unsigned char *out ,
                                           AES_KEY const *key , int const enc )
{


  {
  __CrestCallOpaque("AES_ecb_encrypt", (void (*)())(& AES_ecb_encrypt), 4);
  __CrestClear(4);
  __CrestMute();
  AES_ecb_encrypt(in, out, key, enc);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void AES_cbc_encrypt(unsigned char const *in , unsigned char *out , size_t length ,
                            AES_KEY const *key , unsigned char *ivec , int const enc ) ;
static void __crest_AES_cbc_encrypt_opaque(unsigned char const *in , unsigned char *out ,
                                           size_t length , AES_KEY const *key ,
                                           unsigned char *ivec , int const enc )
{


  {
  __CrestCallOpaque("AES_cbc_encrypt", (void (*)())(& AES_cbc_encrypt), 6);
  __CrestClear(6);
  __CrestMute();
  AES_cbc_encrypt(in, out, length, key, ivec, enc);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern int i2d_X509_proxy(X509 *a , unsigned char **out ) ;

#pragma cilnoremove("i2d_X509_proxy")

extern X509 *d2i_X509_proxy(X509 **a , unsigned char const **in , long len___0 ) ;

#pragma cilnoremove("d2i_X509_proxy")

int EVP_DigestInit_ex_proxy(EVP_MD_CTX *ctx , EVP_MD const *type , ENGINE *impl ) ;

#pragma cilnoremove("EVP_DigestInit_ex_proxy")

int EVP_DigestUpdate_proxy(EVP_MD_CTX *ctx , void const *d , size_t cnt ) ;

#pragma cilnoremove("EVP_DigestUpdate_proxy")

extern EVP_PKEY *X509_get_pubkey_proxy(X509 *x ) ;

#pragma cilnoremove("X509_get_pubkey_proxy")

int EVP_VerifyFinal_proxy(EVP_MD_CTX *ctx , unsigned char const *sigbuf , unsigned int siglen ,
                          EVP_PKEY *pkey ) ;

#pragma cilnoremove("EVP_VerifyFinal_proxy")

int EVP_SignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s , EVP_PKEY *pkey ) ;

#pragma cilnoremove("EVP_SignFinal_proxy")

extern EVP_MD const *EVP_md5_proxy(void) ;

#pragma cilnoremove("EVP_md5_proxy")

extern EVP_MD const *EVP_sha1_proxy(void) ;

#pragma cilnoremove("EVP_sha1_proxy")

int EVP_DigestFinal_ex_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s ) ;

#pragma cilnoremove("EVP_DigestFinal_ex_proxy")

extern int EVP_EncryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                    ENGINE *impl , unsigned char const *key , unsigned char const *iv ) ;

#pragma cilnoremove("EVP_EncryptInit_ex_proxy")

extern int EVP_DecryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                    ENGINE *impl , unsigned char const *key , unsigned char const *iv ) ;

#pragma cilnoremove("EVP_DecryptInit_ex_proxy")

int EVP_Cipher_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , unsigned char const *in ,
                     unsigned int inl ) ;

#pragma cilnoremove("EVP_Cipher_proxy")

int EVP_MD_CTX_copy_proxy(EVP_MD_CTX *out , EVP_MD_CTX const *in ) ;

#pragma cilnoremove("EVP_MD_CTX_copy_proxy")

EVP_MD const *EVP_MD_CTX_md_proxy(EVP_MD_CTX const *ctx ) ;

#pragma cilnoremove("EVP_MD_CTX_md_proxy")

int BIO_read_proxy(BIO *b , void *out , int outl ) ;

#pragma cilnoremove("BIO_read_proxy")

int BIO_write_proxy(BIO *b , void const *in , int inl ) ;

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

extern int HMAC_Init_ex_proxy(HMAC_CTX *ctx , void const *key , int len___0 , EVP_MD const *md ,
                              ENGINE *impl ) ;

#pragma cilnoremove("HMAC_Init_ex_proxy")

extern int HMAC_Update_proxy(HMAC_CTX *ctx , unsigned char const *data , size_t len___0 ) ;

#pragma cilnoremove("HMAC_Update_proxy")

extern int HMAC_Final_proxy(HMAC_CTX *ctx , unsigned char *md , unsigned int *len___0 ) ;

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

int EVP_DigestInit_proxy(EVP_MD_CTX *ctx , EVP_MD const *type ) ;

#pragma cilnoremove("EVP_DigestInit_proxy")

extern int EVP_CipherInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                   ENGINE *impl , unsigned char const *key , unsigned char const *iv ,
                                   int enc ) ;

#pragma cilnoremove("EVP_CipherInit_ex_proxy")

int EVP_MD_CTX_copy_ex_proxy(EVP_MD_CTX *out , EVP_MD_CTX const *in ) ;

#pragma cilnoremove("EVP_MD_CTX_copy_ex_proxy")

extern int EVP_DecryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const *in , int inl ) ;

#pragma cilnoremove("EVP_DecryptUpdate_proxy")

extern int EVP_DecryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *outm , int *outl ) ;

#pragma cilnoremove("EVP_DecryptFinal_proxy")

extern EVP_PKEY *EVP_PKEY_new_mac_key_proxy(int type , ENGINE *e , unsigned char *key ,
                                            int keylen ) ;

#pragma cilnoremove("EVP_PKEY_new_mac_key_proxy")

int EVP_DigestSignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *sigret , size_t *siglen ) ;

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

extern RSA *d2i_RSAPrivateKey_proxy(RSA **a , unsigned char const **in , long len___0 ) ;

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

int EVP_DigestSignInit_proxy(EVP_MD_CTX *ctx , EVP_PKEY_CTX **pctx , EVP_MD const *type ,
                             ENGINE *e , EVP_PKEY *pkey ) ;

#pragma cilnoremove("EVP_DigestSignInit_proxy")

extern EVP_PKEY_CTX *EVP_PKEY_CTX_new_proxy(EVP_PKEY *pkey , ENGINE *e ) ;

#pragma cilnoremove("EVP_PKEY_CTX_new_proxy")

int SHA256_Init_proxy(SHA256_CTX *c ) ;

int SHA256_Update_proxy(SHA256_CTX *c , void const *data , size_t len___0 ) ;

int SHA256_Final_proxy(unsigned char *md , SHA256_CTX *c ) ;

int DSA_generate_key_proxy(DSA *a ) ;

int BN_set_word_proxy(BIGNUM *a , unsigned long w ) ;

int BN_mod_exp2_mont_proxy(BIGNUM *rr , BIGNUM const *a1 , BIGNUM const *p1 ,
                           BIGNUM const *a2 , BIGNUM const *p2 , BIGNUM const *m ,
                           BN_CTX *ctx , BN_MONT_CTX *in_mont ) ;

int BN_mod_exp_mont_proxy(BIGNUM *rr , BIGNUM const *a , BIGNUM const *p , BIGNUM const *m ,
                          BN_CTX *ctx , BN_MONT_CTX *in_mont ) ;

extern void DES_ecb3_encrypt_proxy(const_DES_cblock *input___0 , DES_cblock *output___0 ,
                                   DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                   DES_key_schedule *ks3 , int enc ) ;

extern void DES_ncbc_encrypt_proxy(unsigned char const *input___0 , unsigned char *output___0 ,
                                   long length , DES_key_schedule *schedule , DES_cblock *ivec ,
                                   int enc ) ;

extern void DES_ecb_encrypt_proxy(const_DES_cblock *input___0 , DES_cblock *output___0 ,
                                  DES_key_schedule *ks , int enc ) ;

extern void DES_ede3_cbc_encrypt_proxy(unsigned char const *input___0 , unsigned char *output___0 ,
                                       long length , DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                       DES_key_schedule *ks3 , DES_cblock *ivec ,
                                       int enc ) ;

extern void DES_set_key_unchecked_proxy(const_DES_cblock *key , DES_key_schedule *schedule ) ;

extern int AES_set_encrypt_key_proxy(unsigned char const *userKey , int bits , AES_KEY *key ) ;

extern int AES_set_decrypt_key_proxy(unsigned char const *userKey , int bits , AES_KEY *key ) ;

extern void AES_ecb_encrypt_proxy(unsigned char const *in , unsigned char *out ,
                                  AES_KEY const *key , int enc ) ;

extern void AES_cbc_encrypt_proxy(unsigned char const *in , unsigned char *out ,
                                  size_t length , AES_KEY const *key , unsigned char *ivec ,
                                  int enc ) ;

#pragma cilnoremove("RSA_generate_key_proxy")

RSA *RSA_generate_key_proxy(int bits , unsigned long e , void (*callback)(int , int ,
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

extern void RSA_blinding_off_proxy(RSA *rsa ) ;

extern int X509_STORE_CTX_init_proxy(X509_STORE_CTX *ctx , X509_STORE *store , X509 *x509 ,
                                     struct stack_st_X509 *chain ) ;

#pragma cilnoremove("X509_STORE_CTX_init_proxy")

int BN_num_bytes_proxy(BIGNUM const *a ) ;

extern void SymN(char const *sym , int n ) ;

extern void Nondet() ;

extern void Hint(char const *hint ) ;

extern void mute() ;

extern void unmute() ;

extern void load_buf(unsigned char const *buf , size_t len , char const *hint ) ;

extern void load_all(unsigned char const *buf , char const *hint ) ;

extern void load_ctx(void const *ctx , char const *attr , char const *hint ) ;

extern void load_int(long n , _Bool is_signed , size_t width , char const *hint ) ;

extern void len(_Bool is_signed , size_t lenlen ) ;

extern void test_intype(char const *type ) ;

extern void assume_intype(char const *type ) ;

extern void assume_len(unsigned char const *len , _Bool is_signed , size_t width ) ;

extern void assume_len_at_most(unsigned char const *len , _Bool is_signed , size_t width ) ;

extern void input(char const *hint , size_t len ) ;

extern void newTL(size_t len , char const *type , char const *hint ) ;

extern void newT(char const *type , char const *hint ) ;

extern void varsym(char const *name ) ;

extern void store_len(unsigned char const *buf , size_t width , _Bool is_signed ) ;

extern void output() ;

extern void store_buf(unsigned char const *buf ) ;

extern void store_all(unsigned char const *buf ) ;

extern void store_ctx(void const *ctx , char const *attr ) ;

extern void add_to_attr(void const *ctx , char const *attr , unsigned char const *buf ,
                        size_t len ) ;

extern void set_attr_str(void const *ctx , char const *attr , char const *str ) ;

extern void set_attr_buf(void const *ctx , char const *attr , unsigned char const *buf ,
                         size_t len ) ;

extern void set_attr_int(void const *ctx , char const *attr , int n ) ;

extern int get_attr_int(void const *ctx , char const *attr ) ;

extern void copy_ctx(void const *to , void const *from ) ;

extern void copy_attr_ex(void const *to , char const *attr_to , void const *from ,
                         char const *attr_from ) ;

extern void copy_attr(void const *to , void const *from , char const *attr ) ;

extern void clear_attr(void const *ctx , char const *attr ) ;

extern long concrete_val(long n ) ;

extern void fresh_ptr(size_t size ) ;

int EVP_Cipher_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , unsigned char const *in ,
                     unsigned int inl )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_Cipher_proxy", (void (*)())(& EVP_Cipher_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies.c:inl[22366]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[22365]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[22364]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22363]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:64");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22363]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("type");

  load_ctx((void const *)ctx, "type", "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:65");
  __CrestLoadStackPtr("openssl_proxies.c:in[22365]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:inl[22366]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,4] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("plain");

  load_buf(in, (size_t )inl, "plain");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:66");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22363]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadCString("key");

  load_ctx((void const *)ctx, "key", "key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:68");
  __CrestLoadCString("EVP_Cipher");
  __CrestLoadInt((long long )3);
  __CrestBS(1, 4);

  SymN("EVP_Cipher", 3);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:69");
  __CrestLoadCString("enc");

  Hint("enc");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:70");
  __CrestLoadStackPtr("openssl_proxies.c:inl[22366]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)(& inl), (_Bool)0, sizeof(inl));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:71");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:73");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22363]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[22364]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[22365]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:inl[22366]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_Cipher_opaque(ctx, out, in, inl);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22368]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:73");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22368]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22367]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:77");
  __CrestLoadStackPtr("openssl_proxies.c:out[22364]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)out);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:79");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22367]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern BIO *BIO_pop_proxy(BIO *a )
{
  BIO *ret ;
  BIO *tmp ;

  {
  __CrestCall("BIO_pop_proxy", (void (*)())(& BIO_pop_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[22371]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:84");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:85");
  __CrestLoadStackPtr("openssl_proxies.c:a[22371]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BIO_pop_opaque(a);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22373]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:85");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22373]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22372]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:86");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:89");
  __CrestLoadInt((long long )112);
  __CrestBS(0, 8);

  fresh_ptr(sizeof(*ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:90");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22372]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:91");
  __CrestLoadCString("BIO_pop_result");
  __CrestLoadInt((long long )112);
  __CrestBS(0, 8);

  input("BIO_pop_result", sizeof(*ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:92");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22372]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:94");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22372]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int BIO_free_proxy(BIO *a )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("BIO_free_proxy", (void (*)())(& BIO_free_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[22376]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:99");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:100");
  __CrestLoadStackPtr("openssl_proxies.c:a[22376]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BIO_free_opaque(a);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22378]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:100");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22378]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22377]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:101");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:104");
  __CrestLoadCString("BIO_free_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("BIO_free_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:105");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22377]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:107");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22377]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int BIO_write_proxy(BIO *b , void const *in , int inl )
{
  int ret ;
  int tmp ;
  int cond ;
  BIO *tmp___0 ;
  int __retres8 ;

  {
  __CrestCall("BIO_write_proxy", (void (*)())(& BIO_write_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:inl[22385]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[22384]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:b[22383]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:112");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:113");
  __CrestLoadStackPtr("openssl_proxies.c:b[22383]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[22384]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:inl[22385]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BIO_write_opaque(b, in, inl);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22387]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:113");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22387]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22386]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:114");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:116");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);
  __CrestLoadStackPtr("openssl_proxies.c:cond[22388]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  cond = 0;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:118");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:119");
  __CrestLoadStackPtr("openssl_proxies.c:b[22383]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )1025);
  __CrestBS(1, 4);

  tmp___0 = BIO_find_type(b, 1025);
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22390]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:119");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22390]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:cond[22388]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  cond = (unsigned long )tmp___0 != (unsigned long )((void *)0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:120");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:124");
  __CrestLoadStackPtr("openssl_proxies.c:inl[22385]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22386]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = inl;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:128");
  __CrestLoadStackPtr("openssl_proxies.c:cond[22388]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestTruth();

  if (cond) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:132");
    __CrestLoadStackPtr("openssl_proxies.c:ret[22386]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:__retres8[23493]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();

    __retres8 = ret;

    goto return_label;
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:136");
    __CrestLoadStackPtr("openssl_proxies.c:in[22384]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadStackPtr("openssl_proxies.c:inl[22385]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,4] -> [u,8])");
    __CrestDone();
    __CrestLoadCString("msg");

    load_buf((unsigned char const *)((unsigned char *)in), (size_t )inl, "msg");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:137");

    output();
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:139");
    __CrestLoadStackPtr("openssl_proxies.c:ret[22386]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:__retres8[23493]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();

    __retres8 = ret;

    goto return_label;
  }
  }
  return_label:
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:110");
  __CrestLoadStackPtr("openssl_proxies.c:__retres8[23493]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (__retres8);
  }
}
}

int BIO_read_proxy(BIO *b , void *out , int outl )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("BIO_read_proxy", (void (*)())(& BIO_read_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:outl[22397]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[22396]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:b[22395]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:145");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:146");
  __CrestLoadStackPtr("openssl_proxies.c:b[22395]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[22396]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outl[22397]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BIO_read_opaque(b, out, outl);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22399]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:146");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22399]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22398]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:147");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:152");
  __CrestLoadStackPtr("openssl_proxies.c:outl[22397]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22398]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = outl;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:163");
  __CrestLoadCString("msg");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22398]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();

  input("msg", (size_t )ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:164");
  __CrestLoadStackPtr("openssl_proxies.c:out[22396]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)((unsigned char *)out));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:166");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22398]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern BIO *BIO_new_connect_proxy(char *host_port )
{
  BIO *ret ;
  BIO *tmp ;

  {
  __CrestCall("BIO_new_connect_proxy", (void (*)())(& BIO_new_connect_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:host_port[22402]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:171");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:172");
  __CrestLoadStackPtr("openssl_proxies.c:host_port[22402]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  tmp = __crest_BIO_new_connect_opaque((char const *)host_port);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22404]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:172");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22404]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22403]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:173");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:176");
  __CrestLoadInt((long long )112);
  __CrestBS(0, 8);

  fresh_ptr(sizeof(*ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:177");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22403]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:178");
  __CrestLoadCString("BIO_new_connect_result");
  __CrestLoadInt((long long )112);
  __CrestBS(0, 8);

  input("BIO_new_connect_result", sizeof(*ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:179");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22403]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:181");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22403]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern BIO *BIO_new_accept_proxy(char *host_port )
{
  BIO *ret ;
  BIO *tmp ;

  {
  __CrestCall("BIO_new_accept_proxy", (void (*)())(& BIO_new_accept_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:host_port[22407]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:186");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:187");
  __CrestLoadStackPtr("openssl_proxies.c:host_port[22407]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  tmp = __crest_BIO_new_accept_opaque((char const *)host_port);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22409]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:187");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22409]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22408]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:188");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:191");
  __CrestLoadInt((long long )112);
  __CrestBS(0, 8);

  fresh_ptr(sizeof(*ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:192");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22408]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:193");
  __CrestLoadCString("BIO_new_accept_result");
  __CrestLoadInt((long long )112);
  __CrestBS(0, 8);

  input("BIO_new_accept_result", sizeof(*ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:194");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22408]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:196");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22408]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern long BIO_ctrl_proxy(BIO *bp , int cmd , long larg , void *parg )
{
  long ret ;
  long tmp ;

  {
  __CrestCall("BIO_ctrl_proxy", (void (*)())(& BIO_ctrl_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies.c:parg[22418]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:larg[22417]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:cmd[22416]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bp[22415]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:201");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:202");
  __CrestLoadStackPtr("openssl_proxies.c:bp[22415]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cmd[22416]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:larg[22417]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:parg[22418]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BIO_ctrl_opaque(bp, cmd, larg, parg);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22420]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:202");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22420]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22419]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:203");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:206");
  __CrestLoadCString("BIO_ctrl_result");
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);

  input("BIO_ctrl_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:207");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22419]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:212");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22419]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int EVP_DigestInit_proxy(EVP_MD_CTX *ctx , EVP_MD const *type )
{
  int tmp ;

  {
  __CrestCall("EVP_DigestInit_proxy", (void (*)())(& EVP_DigestInit_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:type[22425]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22424]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:231");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22424]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:type[22425]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");

  copy_attr((void const *)ctx, (void const *)type, "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:232");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22424]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadCString("");

  set_attr_str((void const *)ctx, "msg", "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:234");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22424]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:type[22425]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_DigestInit_opaque(ctx, type);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22426]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:234");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22426]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

int EVP_DigestInit_ex_proxy(EVP_MD_CTX *ctx , EVP_MD const *type , ENGINE *impl )
{
  int tmp ;

  {
  __CrestCall("EVP_DigestInit_ex_proxy", (void (*)())(& EVP_DigestInit_ex_proxy),
              3);
  __CrestLoadStackPtr("openssl_proxies.c:impl[22433]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:type[22432]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22431]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:240");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22431]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:type[22432]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");

  copy_attr((void const *)ctx, (void const *)type, "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:241");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22431]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadCString("");

  set_attr_str((void const *)ctx, "msg", "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:243");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22431]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:type[22432]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:impl[22433]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_DigestInit_ex_opaque(ctx, type, impl);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22434]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:243");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22434]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

int EVP_DigestUpdate_proxy(EVP_MD_CTX *ctx , void const *d , size_t cnt )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_DigestUpdate_proxy", (void (*)())(& EVP_DigestUpdate_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:cnt[22441]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:d[22440]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22439]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:248");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22439]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadStackPtr("openssl_proxies.c:d[22440]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:cnt[22441]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  add_to_attr((void const *)ctx, "msg", (unsigned char const *)((unsigned char *)d),
              cnt);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:250");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22439]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:d[22440]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cnt[22441]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_DigestUpdate_opaque(ctx, d, cnt);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22443]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:250");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22443]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22442]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:252");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22442]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int EVP_VerifyFinal_proxy(EVP_MD_CTX *ctx , unsigned char const *sigbuf , unsigned int siglen ,
                          EVP_PKEY *pkey )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_VerifyFinal_proxy", (void (*)())(& EVP_VerifyFinal_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22452]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[22451]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:sigbuf[22450]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22449]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:262");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22449]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadCString("msg");

  load_ctx((void const *)ctx, "msg", "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:263");
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22452]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");
  __CrestLoadCString("pkey");

  load_ctx((void const *)pkey, "id", "pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:265");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22449]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:sigbuf[22450]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[22451]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22452]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_VerifyFinal_opaque(ctx, sigbuf, siglen, pkey);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22454]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:265");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22454]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22453]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:267");
  __CrestLoadCString("EVP_VerifyFinal");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("EVP_VerifyFinal", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:268");
  __CrestLoadCString("sig");

  Hint("sig");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:269");
  __CrestLoadStackPtr("openssl_proxies.c:siglen[22451]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)(& siglen), (_Bool)0, sizeof(siglen));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:271");
  __CrestLoadStackPtr("openssl_proxies.c:sigbuf[22450]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  store_buf(sigbuf);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:273");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22453]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int EVP_SignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s , EVP_PKEY *pkey )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_SignFinal_proxy", (void (*)())(& EVP_SignFinal_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22463]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:s[22462]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:md[22461]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22460]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:284");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22460]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadCString("msg");

  load_ctx((void const *)ctx, "msg", "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:285");
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22463]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");
  __CrestLoadCString("pkey");

  load_ctx((void const *)pkey, "id", "pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:287");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22460]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:md[22461]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:s[22462]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22463]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_SignFinal_opaque(ctx, md, s, pkey);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22465]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:287");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22465]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22464]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:290");
  __CrestLoadCString("EVP_SignFinal");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("EVP_SignFinal", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:291");
  __CrestLoadCString("sig");

  Hint("sig");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:292");
  __CrestLoadStackPtr("openssl_proxies.c:s[22462]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)s, (_Bool)0, sizeof(*s));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:293");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:295");
  __CrestLoadStackPtr("openssl_proxies.c:md[22461]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)md);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:297");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22464]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int EVP_DigestFinal_ex_proxy(EVP_MD_CTX *ctx , unsigned char *md , unsigned int *s )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_DigestFinal_ex_proxy", (void (*)())(& EVP_DigestFinal_ex_proxy),
              3);
  __CrestLoadStackPtr("openssl_proxies.c:s[22472]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:md[22471]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22470]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:303");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22470]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("type");

  load_ctx((void const *)ctx, "type", "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:304");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22470]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadCString("msg");

  load_ctx((void const *)ctx, "msg", "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:306");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22470]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:md[22471]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:s[22472]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_DigestFinal_ex_opaque(ctx, md, s);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22474]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:306");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22474]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22473]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:309");
  __CrestLoadCString("EVP_DigestFinal_ex");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("EVP_DigestFinal_ex", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:310");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);
  __CrestApply("(CastToPtr: [s,4] -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  Hint((char const *)2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:311");
  __CrestLoadStackPtr("openssl_proxies.c:s[22472]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)s, (_Bool)0, sizeof(*s));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:312");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:314");
  __CrestLoadStackPtr("openssl_proxies.c:md[22471]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)md);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:316");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22473]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int EVP_MD_CTX_copy_proxy(EVP_MD_CTX *out , EVP_MD_CTX const *in )
{
  int tmp ;

  {
  __CrestCall("EVP_MD_CTX_copy_proxy", (void (*)())(& EVP_MD_CTX_copy_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:in[22479]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[22478]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:324");
  __CrestLoadStackPtr("openssl_proxies.c:out[22478]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:in[22479]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  copy_ctx((void const *)out, (void const *)in);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:326");
  __CrestLoadStackPtr("openssl_proxies.c:out[22478]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[22479]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_MD_CTX_copy_opaque(out, in);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22480]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:326");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22480]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

int EVP_MD_CTX_copy_ex_proxy(EVP_MD_CTX *out , EVP_MD_CTX const *in )
{
  int tmp ;

  {
  __CrestCall("EVP_MD_CTX_copy_ex_proxy", (void (*)())(& EVP_MD_CTX_copy_ex_proxy),
              2);
  __CrestLoadStackPtr("openssl_proxies.c:in[22485]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[22484]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:331");
  __CrestLoadStackPtr("openssl_proxies.c:out[22484]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:in[22485]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  copy_ctx((void const *)out, (void const *)in);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:333");
  __CrestLoadStackPtr("openssl_proxies.c:out[22484]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[22485]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_MD_CTX_copy_ex_opaque(out, in);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22486]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:333");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22486]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

EVP_MD const *EVP_MD_CTX_md_proxy(EVP_MD_CTX const *ctx )
{
  EVP_MD const *ret ;
  EVP_MD const *tmp ;

  {
  __CrestCall("EVP_MD_CTX_md_proxy", (void (*)())(& EVP_MD_CTX_md_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22489]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:339");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22489]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_MD_CTX_md_opaque(ctx);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22491]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:339");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22491]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22490]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:341");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22490]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22489]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");

  copy_attr((void const *)ret, (void const *)ctx, "type");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:343");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22490]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int EVP_DigestSignFinal_proxy(EVP_MD_CTX *ctx , unsigned char *sigret , size_t *siglen )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_DigestSignFinal_proxy", (void (*)())(& EVP_DigestSignFinal_proxy),
              3);
  __CrestLoadStackPtr("openssl_proxies.c:siglen[22498]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:sigret[22497]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22496]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:358");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22496]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:sigret[22497]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[22498]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_DigestSignFinal_opaque(ctx, sigret, siglen);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22500]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:358");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22500]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22499]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:360");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22496]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("type");

  load_ctx((void const *)ctx, "type", "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:361");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22496]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadCString("msg");

  load_ctx((void const *)ctx, "msg", "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:362");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22496]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadCString("key");

  load_ctx((void const *)ctx, "key", "key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:363");
  __CrestLoadCString("EVP_DigestSign");
  __CrestLoadInt((long long )3);
  __CrestBS(1, 4);

  SymN("EVP_DigestSign", 3);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:364");
  __CrestLoadCString("sig");

  Hint("sig");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:365");
  __CrestLoadStackPtr("openssl_proxies.c:siglen[22498]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)siglen, (_Bool)0, sizeof(*siglen));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:366");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:367");
  __CrestLoadStackPtr("openssl_proxies.c:sigret[22497]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)sigret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:369");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22499]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int i2d_X509_proxy(X509 *a , unsigned char **out )
{
  int notnull ;
  int tmp ;
  int ret ;
  int tmp___0 ;

  {
  __CrestCall("i2d_X509_proxy", (void (*)())(& i2d_X509_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:out[22505]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[22504]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:386");
  __CrestLoadStackPtr("openssl_proxies.c:out[22505]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )out != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    {
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:386");
    __CrestLoadStackPtr("openssl_proxies.c:out[22505]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: ptr -> [u,8])");
    __CrestDone();
    __CrestLoadStackPtr("nullPtr");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestApply("(CastToInt: ptr -> [u,8])");
    __CrestDone();
    __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
    __CrestDone();
    __CrestTruth();

    if ((unsigned long )*out != (unsigned long )((void *)0)) {
      __CrestBranch(1);
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:386");
      __CrestLoadInt((long long )1);
      __CrestBS(1, 4);
      __CrestLoadStackPtr("openssl_proxies.c:tmp[22507]");
      __CrestLoadInt((long long )4);
      __CrestSetPtrStep();
      __CrestStore();

      tmp = 1;
    } else {
      __CrestBranch(0);
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:386");
      __CrestLoadInt((long long )0);
      __CrestBS(1, 4);
      __CrestLoadStackPtr("openssl_proxies.c:tmp[22507]");
      __CrestLoadInt((long long )4);
      __CrestSetPtrStep();
      __CrestStore();

      tmp = 0;
    }
    }
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:386");
    __CrestLoadInt((long long )0);
    __CrestBS(1, 4);
    __CrestLoadStackPtr("openssl_proxies.c:tmp[22507]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();

    tmp = 0;
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:386");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22507]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:notnull[22506]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  notnull = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:388");
  __CrestLoadStackPtr("openssl_proxies.c:a[22504]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[22505]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp___0 = __crest_i2d_X509_opaque(a, out);
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22510]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:388");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22510]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22508]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp___0;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:390");
  __CrestLoadStackPtr("openssl_proxies.c:out[22505]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )out != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:392");
    __CrestLoadStackPtr("openssl_proxies.c:a[22504]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("id");
    __CrestLoadCString("cert");

    load_ctx((void const *)a, "id", "cert");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:394");
    __CrestLoadCString("i2d_X509");
    __CrestLoadInt((long long )1);
    __CrestBS(1, 4);

    SymN("i2d_X509", 1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:395");
    __CrestLoadCString("DER");

    Hint("DER");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:396");
    __CrestLoadStackPtr("openssl_proxies.c:ret[22508]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadInt((long long )(_Bool)1);
    __CrestBS(0, 1);
    __CrestLoadInt((long long )4);
    __CrestBS(0, 8);

    assume_len((unsigned char const *)(& ret), (_Bool)1, sizeof(ret));
    {
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:398");
    __CrestLoadStackPtr("openssl_proxies.c:notnull[22506]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestTruth();

    if (notnull) {
      __CrestBranch(1);
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:399");
      __CrestLoadStackPtr("openssl_proxies.c:out[22505]");
      __CrestApply("ptrLen/0");
      __CrestSetPtrStep();
      __CrestLoadMem();
      __CrestApply("ptrLen/0");
      __CrestSetPtrStep();
      __CrestLoadMem();
      __CrestLoadStackPtr("openssl_proxies.c:ret[22508]");
      __CrestLoadInt((long long )4);
      __CrestSetPtrStep();
      __CrestLoadMem();
      __CrestApply("(MinusPI: ptr * [s,4] -> ptr)");
      __CrestDone();
      __CrestApply("(CastToPtr: ptr -> ptr)");
      __CrestLoadInt((long long )1);
      __CrestSetPtrStep();
      __CrestDone();

      store_buf((unsigned char const *)(*out - ret));
    } else {
      __CrestBranch(0);
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:401");
      __CrestLoadStackPtr("openssl_proxies.c:out[22505]");
      __CrestApply("ptrLen/0");
      __CrestSetPtrStep();
      __CrestLoadMem();
      __CrestApply("ptrLen/0");
      __CrestSetPtrStep();
      __CrestLoadMem();
      __CrestApply("(CastToPtr: ptr -> ptr)");
      __CrestLoadInt((long long )1);
      __CrestSetPtrStep();
      __CrestDone();

      store_buf((unsigned char const *)*out);
    }
    }
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:405");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22508]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern X509 *d2i_X509_proxy(X509 **a , unsigned char const **in , long len___0 )
{
  unsigned char const *oldin ;
  X509 *ret ;
  X509 *tmp ;

  {
  __CrestCall("d2i_X509_proxy", (void (*)())(& d2i_X509_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22518]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[22516]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[22515]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:419");
  __CrestLoadStackPtr("openssl_proxies.c:in[22516]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:oldin[22519]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  oldin = *in;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:421");
  __CrestLoadStackPtr("openssl_proxies.c:a[22515]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[22516]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22518]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_d2i_X509_opaque(a, in, len___0);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22521]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:421");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22521]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22520]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:423");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22520]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )ret != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:425");
    __CrestLoadStackPtr("openssl_proxies.c:oldin[22519]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:len___0[22518]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,8] -> [u,8])");
    __CrestDone();
    __CrestLoadCString("DER");

    load_buf(oldin, (size_t )len___0, "DER");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:427");
    __CrestLoadCString("d2i_X509");
    __CrestLoadInt((long long )1);
    __CrestBS(1, 4);

    SymN("d2i_X509", 1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:428");
    __CrestLoadCString("cert");

    Hint("cert");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:430");
    __CrestLoadStackPtr("openssl_proxies.c:ret[22520]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("id");

    store_ctx((void const *)ret, "id");
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:433");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22520]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_PKEY *X509_get_pubkey_proxy(X509 *x )
{
  EVP_PKEY *ret ;
  EVP_PKEY *tmp ;

  {
  __CrestCall("X509_get_pubkey_proxy", (void (*)())(& X509_get_pubkey_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:x[22524]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:439");
  __CrestLoadStackPtr("openssl_proxies.c:x[22524]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_X509_get_pubkey_opaque(x);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22526]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:439");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22526]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22525]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:441");
  __CrestLoadStackPtr("openssl_proxies.c:x[22524]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");
  __CrestLoadCString("X509");

  load_ctx((void const *)x, "id", "X509");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:443");
  __CrestLoadCString("X509_get_pubkey");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("X509_get_pubkey", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:444");
  __CrestLoadCString("pkey");

  Hint("pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:446");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22525]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  store_ctx((void const *)ret, "id");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:449");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22525]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestFieldOffset("pkey");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestFieldOffset("ptr");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22525]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  copy_ctx((void const *)ret->pkey.ptr, (void const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:451");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22525]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

EVP_MD const *EVP_get_digestbyname_proxy(char const *name )
{
  EVP_MD const *ret ;
  EVP_MD const *tmp ;

  {
  __CrestCall("EVP_get_digestbyname_proxy", (void (*)())(& EVP_get_digestbyname_proxy),
              1);
  __CrestLoadStackPtr("openssl_proxies.c:name[22529]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:469");
  __CrestLoadStackPtr("openssl_proxies.c:name[22529]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_get_digestbyname_opaque(name);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22531]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:469");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22531]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22530]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:471");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22530]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadStackPtr("openssl_proxies.c:name[22529]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  set_attr_str((void const *)ret, "type", name);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:473");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22530]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_MD const *EVP_md5_proxy(void)
{
  EVP_MD const *ret ;
  EVP_MD const *tmp ;

  {
  __CrestCall("EVP_md5_proxy", (void (*)())(& EVP_md5_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:484");

  tmp = __crest_EVP_md5_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22535]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:484");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22535]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22534]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:486");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22534]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("md5");

  set_attr_str((void const *)ret, "type", "md5");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:488");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22534]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_MD const *EVP_sha1_proxy(void)
{
  EVP_MD const *ret ;

  {
  __CrestCall("EVP_sha1_proxy", (void (*)())(& EVP_sha1_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:506");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:507");

  ret = __crest_EVP_sha1_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22538]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:508");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:510");
  __CrestLoadInt((long long )120);
  __CrestBS(0, 8);

  fresh_ptr(sizeof(*ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:511");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22538]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:513");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22538]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("sha1");

  set_attr_str((void const *)ret, "type", "sha1");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:515");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22538]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_MD const *EVP_dss1_proxy(void)
{
  EVP_MD const *ret ;
  EVP_MD const *tmp ;

  {
  __CrestCall("EVP_dss1_proxy", (void (*)())(& EVP_dss1_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:524");

  tmp = __crest_EVP_dss1_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22542]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:524");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22542]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22541]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:526");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22541]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("dss1");

  set_attr_str((void const *)ret, "type", "dss1");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:528");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22541]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_MD const *EVP_ecdsa_proxy(void)
{
  EVP_MD const *ret ;
  EVP_MD const *tmp ;

  {
  __CrestCall("EVP_ecdsa_proxy", (void (*)())(& EVP_ecdsa_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:534");

  tmp = __crest_EVP_ecdsa_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22546]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:534");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22546]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22545]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:536");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22545]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("ecdsa");

  set_attr_str((void const *)ret, "type", "ecdsa");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:538");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22545]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_EncryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                    ENGINE *impl , unsigned char const *key , unsigned char const *iv )
{
  int tmp ;
  int tmp___0 ;
  int tmp___1 ;

  {
  __CrestCall("EVP_EncryptInit_ex_proxy", (void (*)())(& EVP_EncryptInit_ex_proxy),
              5);
  __CrestLoadStackPtr("openssl_proxies.c:iv[22557]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key[22556]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:impl[22555]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:cipher[22554]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22553]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:555");
  __CrestLoadStackPtr("openssl_proxies.c:cipher[22554]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )cipher != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:556");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22553]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadStackPtr("openssl_proxies.c:cipher[22554]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("type");

    copy_attr((void const *)ctx, (void const *)cipher, "type");
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:557");
  __CrestLoadStackPtr("openssl_proxies.c:key[22556]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )key != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:558");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22553]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )168);
    __CrestSetPtrStep();
    __CrestDone();

    tmp = EVP_CIPHER_CTX_key_length((EVP_CIPHER_CTX const *)ctx);
    __CrestLoadStackPtr("openssl_proxies.c:tmp[22558]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:558");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22553]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("key");
    __CrestLoadStackPtr("openssl_proxies.c:key[22556]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:tmp[22558]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,4] -> [u,8])");
    __CrestDone();

    set_attr_buf((void const *)ctx, "key", key, (size_t )tmp);
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:560");
  __CrestLoadStackPtr("openssl_proxies.c:iv[22557]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )iv != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:561");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22553]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )168);
    __CrestSetPtrStep();
    __CrestDone();

    tmp___0 = EVP_CIPHER_CTX_iv_length((EVP_CIPHER_CTX const *)ctx);
    __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22560]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:561");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22553]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("seed");
    __CrestLoadStackPtr("openssl_proxies.c:iv[22557]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22560]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,4] -> [u,8])");
    __CrestDone();

    set_attr_buf((void const *)ctx, "seed", iv, (size_t )tmp___0);
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:565");
    __CrestLoadCString("Ciphers without IV not modeled yet.");
    __CrestMute();

    proxy_fail("Ciphers without IV not modeled yet.");
    __CrestUnmute();
    __CrestClear(1);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:570");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22553]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  set_attr_int((void const *)ctx, "pos", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:571");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22553]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("use");
  __CrestLoadCString("encrypt");

  set_attr_str((void const *)ctx, "use", "encrypt");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:572");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22553]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cipher[22554]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:impl[22555]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key[22556]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:iv[22557]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp___1 = __crest_EVP_EncryptInit_ex_opaque(ctx, cipher, impl, key, iv);
  __CrestLoadStackPtr("openssl_proxies.c:tmp___1[22562]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:572");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___1[22562]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp___1);
  }
}
}

extern int EVP_DecryptInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                    ENGINE *impl , unsigned char const *key , unsigned char const *iv )
{
  int tmp ;
  int tmp___0 ;
  int tmp___1 ;

  {
  __CrestCall("EVP_DecryptInit_ex_proxy", (void (*)())(& EVP_DecryptInit_ex_proxy),
              5);
  __CrestLoadStackPtr("openssl_proxies.c:iv[22573]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key[22572]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:impl[22571]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:cipher[22570]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22569]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:582");
  __CrestLoadStackPtr("openssl_proxies.c:cipher[22570]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )cipher != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:583");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22569]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadStackPtr("openssl_proxies.c:cipher[22570]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("type");

    copy_attr((void const *)ctx, (void const *)cipher, "type");
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:584");
  __CrestLoadStackPtr("openssl_proxies.c:key[22572]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )key != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:585");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22569]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )168);
    __CrestSetPtrStep();
    __CrestDone();

    tmp = EVP_CIPHER_CTX_key_length((EVP_CIPHER_CTX const *)ctx);
    __CrestLoadStackPtr("openssl_proxies.c:tmp[22574]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:585");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22569]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("key");
    __CrestLoadStackPtr("openssl_proxies.c:key[22572]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:tmp[22574]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,4] -> [u,8])");
    __CrestDone();

    set_attr_buf((void const *)ctx, "key", key, (size_t )tmp);
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:587");
  __CrestLoadStackPtr("openssl_proxies.c:iv[22573]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )iv != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:588");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22569]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )168);
    __CrestSetPtrStep();
    __CrestDone();

    tmp___0 = EVP_CIPHER_CTX_iv_length((EVP_CIPHER_CTX const *)ctx);
    __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22576]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:588");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22569]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("seed");
    __CrestLoadStackPtr("openssl_proxies.c:iv[22573]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22576]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,4] -> [u,8])");
    __CrestDone();

    set_attr_buf((void const *)ctx, "seed", iv, (size_t )tmp___0);
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:591");
    __CrestLoadCString("Ciphers without IV not modeled yet.");
    __CrestMute();

    proxy_fail("Ciphers without IV not modeled yet.");
    __CrestUnmute();
    __CrestClear(1);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:594");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22569]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  set_attr_int((void const *)ctx, "pos", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:596");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22569]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("use");
  __CrestLoadCString("decrypt");

  set_attr_str((void const *)ctx, "use", "decrypt");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:598");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22569]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cipher[22570]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:impl[22571]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key[22572]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:iv[22573]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp___1 = __crest_EVP_DecryptInit_ex_opaque(ctx, cipher, impl, key, iv);
  __CrestLoadStackPtr("openssl_proxies.c:tmp___1[22578]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:598");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___1[22578]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp___1);
  }
}
}

extern int EVP_CipherInit_ex_proxy(EVP_CIPHER_CTX *ctx , EVP_CIPHER const *cipher ,
                                   ENGINE *impl , unsigned char const *key , unsigned char const *iv ,
                                   int enc )
{
  int ret ;
  int tmp ;
  int tmp___0 ;

  {
  __CrestCall("EVP_CipherInit_ex_proxy", (void (*)())(& EVP_CipherInit_ex_proxy),
              6);
  __CrestLoadStackPtr("openssl_proxies.c:enc[22591]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:iv[22590]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key[22589]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:impl[22588]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:cipher[22587]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22586]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:611");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22586]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cipher[22587]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:impl[22588]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key[22589]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:iv[22590]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:enc[22591]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_CipherInit_ex_opaque(ctx, cipher, impl, key, iv, enc);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22593]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:611");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22593]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22592]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:613");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22586]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:cipher[22587]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");

  copy_attr((void const *)ctx, (void const *)cipher, "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:615");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22586]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )168);
  __CrestSetPtrStep();
  __CrestDone();

  tmp___0 = EVP_CIPHER_CTX_key_length((EVP_CIPHER_CTX const *)ctx);
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22595]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:615");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22586]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadStackPtr("openssl_proxies.c:key[22589]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22595]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();

  set_attr_buf((void const *)ctx, "key", key, (size_t )tmp___0);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:617");
  __CrestLoadStackPtr("openssl_proxies.c:enc[22591]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);
  __CrestApply("(==: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if (enc == 1) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:618");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22586]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("use");
    __CrestLoadCString("enc");

    set_attr_str((void const *)ctx, "use", "enc");
  } else {
    __CrestBranch(0);
    {
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:619");
    __CrestLoadStackPtr("openssl_proxies.c:enc[22591]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadInt((long long )0);
    __CrestBS(1, 4);
    __CrestApply("(==: [s,4] * [s,4] -> [s,4])");
    __CrestDone();
    __CrestTruth();

    if (enc == 0) {
      __CrestBranch(1);
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:620");
      __CrestLoadStackPtr("openssl_proxies.c:ctx[22586]");
      __CrestApply("ptrLen/0");
      __CrestSetPtrStep();
      __CrestLoadMem();
      __CrestApply("(CastToPtr: ptr -> ptr)");
      __CrestLoadInt((long long )1);
      __CrestSetPtrStep();
      __CrestDone();
      __CrestLoadCString("use");
      __CrestLoadCString("dec");

      set_attr_str((void const *)ctx, "use", "dec");
    } else {
      __CrestBranch(0);
    }
    }
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:622");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22592]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int X509_certificate_type_proxy(X509 *x , EVP_PKEY *pubkey )
{
  int tmp ;

  {
  __CrestCall("X509_certificate_type_proxy", (void (*)())(& X509_certificate_type_proxy),
              2);
  __CrestLoadStackPtr("openssl_proxies.c:pubkey[22600]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:x[22599]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:630");
  __CrestLoadStackPtr("openssl_proxies.c:x[22599]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pubkey[22600]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_X509_certificate_type_opaque(x, pubkey);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22601]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:630");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22601]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern EVP_CIPHER const *EVP_aes_128_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_aes_128_cbc_proxy", (void (*)())(& EVP_aes_128_cbc_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:637");

  tmp = __crest_EVP_aes_128_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22605]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:637");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22605]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22604]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:639");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22604]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("aes_128_cbc");

  set_attr_str((void const *)ret, "type", "aes_128_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:641");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22604]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_MD const *EVP_sha256_proxy(void)
{
  EVP_MD const *ret ;
  EVP_MD const *tmp ;

  {
  __CrestCall("EVP_sha256_proxy", (void (*)())(& EVP_sha256_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:647");

  tmp = __crest_EVP_sha256_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22609]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:647");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22609]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22608]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:649");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22608]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("sha256");

  set_attr_str((void const *)ret, "type", "sha256");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:651");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22608]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int HMAC_Init_ex_proxy(HMAC_CTX *ctx , void const *key , int len___0 , EVP_MD const *md ,
                              ENGINE *impl )
{
  int tmp ;

  {
  __CrestCall("HMAC_Init_ex_proxy", (void (*)())(& HMAC_Init_ex_proxy), 5);
  __CrestLoadStackPtr("openssl_proxies.c:impl[22621]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:md[22620]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22619]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key[22617]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22616]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:674");
  __CrestLoadStackPtr("openssl_proxies.c:md[22620]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )md != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:675");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22616]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadStackPtr("openssl_proxies.c:md[22620]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("type");

    copy_attr((void const *)ctx, (void const *)md, "type");
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:678");
  __CrestLoadStackPtr("openssl_proxies.c:key[22617]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )key != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:679");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22616]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("key");
    __CrestLoadStackPtr("openssl_proxies.c:key[22617]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadStackPtr("openssl_proxies.c:len___0[22619]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,4] -> [u,8])");
    __CrestDone();

    set_attr_buf((void const *)ctx, "key", (unsigned char const *)key, (size_t )len___0);
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:681");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22616]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");

  clear_attr((void const *)ctx, "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:686");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22616]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key[22617]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22619]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:md[22620]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:impl[22621]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_HMAC_Init_ex_opaque(ctx, key, len___0, md, impl);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22622]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:686");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22622]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern int HMAC_Update_proxy(HMAC_CTX *ctx , unsigned char const *data , size_t len___0 )
{
  int tmp ;

  {
  __CrestCall("HMAC_Update_proxy", (void (*)())(& HMAC_Update_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22630]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:data[22628]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22627]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:692");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22627]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadStackPtr("openssl_proxies.c:data[22628]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22630]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  add_to_attr((void const *)ctx, "msg", data, len___0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:697");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22627]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:data[22628]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22630]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_HMAC_Update_opaque(ctx, data, len___0);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22631]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:697");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22631]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern int HMAC_Final_proxy(HMAC_CTX *ctx , unsigned char *md , unsigned int *len___0 )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("HMAC_Final_proxy", (void (*)())(& HMAC_Final_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22639]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:md[22637]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22636]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:708");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22636]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:md[22637]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22639]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_HMAC_Final_opaque(ctx, md, len___0);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22641]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:708");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22641]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22640]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:711");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22636]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("");

  load_ctx((void const *)ctx, "type", "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:712");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22636]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadCString("msg");

  load_ctx((void const *)ctx, "msg", "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:713");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22636]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadCString("key");

  load_ctx((void const *)ctx, "key", "key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:715");
  __CrestLoadCString("HMAC");
  __CrestLoadInt((long long )3);
  __CrestBS(1, 4);

  SymN("HMAC", 3);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:716");
  __CrestLoadCString("hash");

  Hint("hash");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:717");
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22639]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)len___0, (_Bool)0, sizeof(*len___0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:719");
  __CrestLoadStackPtr("openssl_proxies.c:md[22637]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)md);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:722");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22640]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern unsigned char *HMAC_proxy(EVP_MD const *evp_md , void const *key , int key_len ,
                                 unsigned char const *d , size_t n , unsigned char *md ,
                                 unsigned int *md_len )
{
  unsigned char *ret ;
  unsigned char *tmp ;
  long tmp___0 ;

  {
  __CrestCall("HMAC_proxy", (void (*)())(& HMAC_proxy), 7);
  __CrestLoadStackPtr("openssl_proxies.c:md_len[22656]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:md[22655]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:n[22654]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:d[22653]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key_len[22652]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key[22651]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:evp_md[22650]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:743");
  __CrestLoadStackPtr("openssl_proxies.c:md_len[22656]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )md_len != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:743");
    __CrestLoadInt((long long )0U);
    __CrestBS(0, 4);
    __CrestLoadStackPtr("openssl_proxies.c:md_len[22656]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();

    *md_len = 0U;
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:745");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:746");
  __CrestLoadStackPtr("openssl_proxies.c:evp_md[22650]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key[22651]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key_len[22652]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:d[22653]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:n[22654]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:md[22655]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:md_len[22656]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_HMAC_opaque(evp_md, key, key_len, d, n, md, md_len);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22658]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:746");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22658]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22657]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:747");

  unmute();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:749");
  __CrestLoadStackPtr("openssl_proxies.c:md_len[22656]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )md_len != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:750");
    __CrestLoadStackPtr("openssl_proxies.c:md_len[22656]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [u,4] -> [s,8])");
    __CrestDone();

    tmp___0 = concrete_val((long )*md_len);
    __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22660]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestStore();
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:750");
    __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22660]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,8] -> [u,4])");
    __CrestDone();
    __CrestLoadStackPtr("openssl_proxies.c:md_len[22656]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();

    *md_len = (unsigned int )tmp___0;
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:752");
  __CrestLoadStackPtr("openssl_proxies.c:md[22655]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )md != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:753");
    __CrestLoadStackPtr("openssl_proxies.c:md[22655]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:ret[22657]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestStore();

    ret = md;
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:755");
    __CrestLoadStackPtr("openssl_proxies.c:md_len[22656]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [u,4] -> [u,8])");
    __CrestDone();

    fresh_ptr((size_t )*md_len);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:756");
    __CrestLoadStackPtr("openssl_proxies.c:ret[22657]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();

    store_buf((unsigned char const *)(& ret));
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:759");
  __CrestLoadStackPtr("openssl_proxies.c:evp_md[22650]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("");

  load_ctx((void const *)evp_md, "type", "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:760");
  __CrestLoadStackPtr("openssl_proxies.c:d[22653]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:n[22654]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("msg");

  load_buf(d, n, "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:761");
  __CrestLoadStackPtr("openssl_proxies.c:key[22651]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:key_len[22652]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("key");

  load_buf((unsigned char const *)((unsigned char *)key), (size_t )key_len, "key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:763");
  __CrestLoadCString("HMAC");
  __CrestLoadInt((long long )3);
  __CrestBS(1, 4);

  SymN("HMAC", 3);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:764");
  __CrestLoadCString("hash");

  Hint("hash");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:765");
  __CrestLoadStackPtr("openssl_proxies.c:md_len[22656]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)md_len, (_Bool)0, sizeof(*md_len));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:767");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22657]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:769");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22657]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int SHA256_Init_proxy(SHA256_CTX *c )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("SHA256_Init_proxy", (void (*)())(& SHA256_Init_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:c[22663]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:781");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:782");
  __CrestLoadStackPtr("openssl_proxies.c:c[22663]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_SHA256_Init_opaque(c);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22665]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:782");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22665]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22664]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:783");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:785");
  __CrestLoadCString("SHA256_Init");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("SHA256_Init", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:786");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:787");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22667]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:788");
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22667]");
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

  assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:789");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22664]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:791");
  __CrestLoadStackPtr("openssl_proxies.c:c[22663]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");

  clear_attr((void const *)c, "msg");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:793");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22664]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int SHA256_Update_proxy(SHA256_CTX *c , void const *data , size_t len___0 )
{
  int ret ;
  int tmp ;
  size_t ret_len ;

  {
  __CrestCall("SHA256_Update_proxy", (void (*)())(& SHA256_Update_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22675]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:data[22673]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:c[22672]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:798");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:799");
  __CrestLoadStackPtr("openssl_proxies.c:c[22672]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:data[22673]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22675]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_SHA256_Update_opaque(c, data, len___0);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22677]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:799");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22677]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22676]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:800");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:802");
  __CrestLoadCString("SHA256_Update");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("SHA256_Update", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:803");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:804");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:ret_len[22678]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret_len = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:805");
  __CrestLoadStackPtr("openssl_proxies.c:ret_len[22678]");
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
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:806");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22676]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:808");
  __CrestLoadStackPtr("openssl_proxies.c:c[22672]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadStackPtr("openssl_proxies.c:data[22673]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22675]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  add_to_attr((void const *)c, "msg", (unsigned char const *)data, len___0);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:810");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22676]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int SHA256_Final_proxy(unsigned char *md , SHA256_CTX *c )
{
  int ret ;
  int tmp ;
  size_t len___0 ;
  size_t len___1 ;

  {
  __CrestCall("SHA256_Final_proxy", (void (*)())(& SHA256_Final_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:c[22683]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:md[22682]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:815");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:816");
  __CrestLoadStackPtr("openssl_proxies.c:md[22682]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:c[22683]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_SHA256_Final_opaque(md, c);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22685]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:816");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22685]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22684]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:817");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:819");
  __CrestLoadCString("SHA256_Final");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("SHA256_Final", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:820");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:821");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22687]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:822");
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22687]");
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

  assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:823");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22684]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:825");
  __CrestLoadCString("SHA256_key");

  varsym("SHA256_key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:826");
  __CrestLoadStackPtr("openssl_proxies.c:c[22683]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadCString("msg");

  load_ctx((void const *)c, "msg", "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:828");
  __CrestLoadCString("SHA_hash");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("SHA_hash", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:829");
  __CrestLoadCString("hash");

  Hint("hash");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:830");
  __CrestLoadInt((long long )32);
  __CrestBS(1, 4);
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:len___1[22689]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___1 = (size_t )32;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:831");
  __CrestLoadStackPtr("openssl_proxies.c:len___1[22689]");
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

  assume_len((unsigned char const *)(& len___1), (_Bool)0, sizeof(len___1));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:833");
  __CrestLoadStackPtr("openssl_proxies.c:md[22682]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)md);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:835");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22684]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_EncryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const *in , int inl )
{
  int ret ;
  int tmp ;
  int pos ;
  int tmp___0 ;

  {
  __CrestCall("EVP_EncryptUpdate_proxy", (void (*)())(& EVP_EncryptUpdate_proxy),
              5);
  __CrestLoadStackPtr("openssl_proxies.c:inl[22700]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[22699]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:outl[22698]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[22697]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22696]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:848");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22696]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[22697]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outl[22698]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[22699]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:inl[22700]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_EncryptUpdate_opaque(ctx, out, outl, in, inl);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22702]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:848");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22702]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22701]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:850");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22696]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("enc_in");
  __CrestLoadStackPtr("openssl_proxies.c:in[22699]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:inl[22700]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();

  add_to_attr((void const *)ctx, "enc_in", in, (size_t )inl);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:852");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22696]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");

  tmp___0 = get_attr_int((void const *)ctx, "pos");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22705]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:852");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22705]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pos[22703]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  pos = tmp___0;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:854");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22696]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("enc_in");
  __CrestLoadCString("partial_plain");

  load_ctx((void const *)ctx, "enc_in", "partial_plain");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:855");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22696]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadCString("key");

  load_ctx((void const *)ctx, "key", "key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:856");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22696]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("iv");
  __CrestLoadCString("iv");

  load_ctx((void const *)ctx, "iv", "iv");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:857");
  __CrestLoadStackPtr("openssl_proxies.c:pos[22703]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [s,8])");
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadCString("pos");

  load_int((long )pos, (_Bool)1, sizeof(pos), "pos");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:858");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22696]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("type");

  load_ctx((void const *)ctx, "type", "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:860");
  __CrestLoadCString("encPart");
  __CrestLoadInt((long long )5);
  __CrestBS(1, 4);

  SymN("encPart", 5);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:861");
  __CrestLoadCString("partial_enc");

  Hint("partial_enc");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:862");
  __CrestLoadStackPtr("openssl_proxies.c:outl[22698]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)outl, (_Bool)1, sizeof(*outl));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:863");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:865");
  __CrestLoadStackPtr("openssl_proxies.c:out[22697]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)out);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:867");
  __CrestLoadStackPtr("openssl_proxies.c:pos[22703]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outl[22698]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(+: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:pos[22703]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  pos += *outl;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:868");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22696]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");
  __CrestLoadStackPtr("openssl_proxies.c:pos[22703]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  set_attr_int((void const *)ctx, "pos", pos);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:871");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22701]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_EncryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl )
{
  int ret ;
  int tmp ;
  int pos ;
  int tmp___0 ;

  {
  __CrestCall("EVP_EncryptFinal_proxy", (void (*)())(& EVP_EncryptFinal_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:outl[22712]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[22711]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:884");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[22711]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outl[22712]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_EncryptFinal_opaque(ctx, out, outl);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22714]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:884");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22714]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22713]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:890");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");

  tmp___0 = get_attr_int((void const *)ctx, "pos");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22717]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:890");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22717]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pos[22715]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  pos = tmp___0;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:892");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("enc_in");
  __CrestLoadCString("partial_plain");

  load_ctx((void const *)ctx, "enc_in", "partial_plain");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:893");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadCString("key");

  load_ctx((void const *)ctx, "key", "key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:894");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("iv");
  __CrestLoadCString("iv");

  load_ctx((void const *)ctx, "iv", "iv");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:895");
  __CrestLoadStackPtr("openssl_proxies.c:pos[22715]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [s,8])");
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadCString("pos");

  load_int((long )pos, (_Bool)1, sizeof(pos), "pos");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:896");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("type");

  load_ctx((void const *)ctx, "type", "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:898");
  __CrestLoadCString("encFin");
  __CrestLoadInt((long long )5);
  __CrestBS(1, 4);

  SymN("encFin", 5);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:899");
  __CrestLoadCString("partial_enc");

  Hint("partial_enc");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:900");
  __CrestLoadStackPtr("openssl_proxies.c:outl[22712]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)outl, (_Bool)1, sizeof(*outl));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:901");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:903");
  __CrestLoadStackPtr("openssl_proxies.c:out[22711]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)out);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:907");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("enc_in");

  clear_attr((void const *)ctx, "enc_in");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:908");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");

  clear_attr((void const *)ctx, "pos");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:909");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22710]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("iv");

  clear_attr((void const *)ctx, "iv");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:911");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22713]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_DecryptUpdate_proxy(EVP_CIPHER_CTX *ctx , unsigned char *out , int *outl ,
                                   unsigned char const *in , int inl )
{
  int ret ;
  int tmp ;
  int pos ;
  int tmp___0 ;

  {
  __CrestCall("EVP_DecryptUpdate_proxy", (void (*)())(& EVP_DecryptUpdate_proxy),
              5);
  __CrestLoadStackPtr("openssl_proxies.c:inl[22728]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[22727]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:outl[22726]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[22725]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22724]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:921");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22724]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[22725]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outl[22726]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[22727]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:inl[22728]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_DecryptUpdate_opaque(ctx, out, outl, in, inl);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22730]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:921");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22730]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22729]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:923");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22724]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("dec_in");
  __CrestLoadStackPtr("openssl_proxies.c:in[22727]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:inl[22728]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();

  add_to_attr((void const *)ctx, "dec_in", in, (size_t )inl);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:925");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22724]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");

  tmp___0 = get_attr_int((void const *)ctx, "pos");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22733]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:925");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22733]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pos[22731]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  pos = tmp___0;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:927");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22724]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("dec_in");
  __CrestLoadCString("partial_enc");

  load_ctx((void const *)ctx, "dec_in", "partial_enc");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:928");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22724]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadCString("key");

  load_ctx((void const *)ctx, "key", "key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:929");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22724]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("iv");
  __CrestLoadCString("iv");

  load_ctx((void const *)ctx, "iv", "iv");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:930");
  __CrestLoadStackPtr("openssl_proxies.c:pos[22731]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [s,8])");
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadCString("pos");

  load_int((long )pos, (_Bool)1, sizeof(pos), "pos");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:931");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22724]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("type");

  load_ctx((void const *)ctx, "type", "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:933");
  __CrestLoadCString("decPart");
  __CrestLoadInt((long long )5);
  __CrestBS(1, 4);

  SymN("decPart", 5);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:934");
  __CrestLoadCString("partial_dec");

  Hint("partial_dec");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:935");
  __CrestLoadStackPtr("openssl_proxies.c:outl[22726]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)outl, (_Bool)1, sizeof(*outl));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:936");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:938");
  __CrestLoadStackPtr("openssl_proxies.c:out[22725]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)out);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:940");
  __CrestLoadStackPtr("openssl_proxies.c:pos[22731]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outl[22726]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(+: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:pos[22731]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  pos += *outl;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:941");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22724]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");
  __CrestLoadStackPtr("openssl_proxies.c:pos[22731]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  set_attr_int((void const *)ctx, "pos", pos);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:943");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22729]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_DecryptFinal_proxy(EVP_CIPHER_CTX *ctx , unsigned char *outm , int *outl )
{
  int ret ;
  int tmp ;
  int pos ;
  int tmp___0 ;

  {
  __CrestCall("EVP_DecryptFinal_proxy", (void (*)())(& EVP_DecryptFinal_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:outl[22740]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:outm[22739]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:948");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outm[22739]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outl[22740]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_DecryptFinal_opaque(ctx, outm, outl);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22742]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:948");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22742]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22741]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:950");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");

  tmp___0 = get_attr_int((void const *)ctx, "pos");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22745]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:950");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[22745]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pos[22743]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  pos = tmp___0;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:952");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("dec_in");
  __CrestLoadCString("partial_enc");

  load_ctx((void const *)ctx, "dec_in", "partial_enc");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:953");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadCString("key");

  load_ctx((void const *)ctx, "key", "key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:954");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("iv");
  __CrestLoadCString("iv");

  load_ctx((void const *)ctx, "iv", "iv");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:955");
  __CrestLoadStackPtr("openssl_proxies.c:pos[22743]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [s,8])");
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadCString("pos");

  load_int((long )pos, (_Bool)1, sizeof(pos), "pos");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:956");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("type");

  load_ctx((void const *)ctx, "type", "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:958");
  __CrestLoadCString("decFin");
  __CrestLoadInt((long long )5);
  __CrestBS(1, 4);

  SymN("decFin", 5);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:959");
  __CrestLoadCString("partial_dec");

  Hint("partial_dec");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:960");
  __CrestLoadStackPtr("openssl_proxies.c:outl[22740]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)outl, (_Bool)1, sizeof(*outl));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:961");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:963");
  __CrestLoadStackPtr("openssl_proxies.c:outm[22739]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)outm);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:965");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("dec_in");

  clear_attr((void const *)ctx, "dec_in");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:966");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pos");

  clear_attr((void const *)ctx, "pos");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:967");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22738]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("iv");

  clear_attr((void const *)ctx, "iv");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:969");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22741]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int X509_STORE_CTX_init_proxy(X509_STORE_CTX *ctx , X509_STORE *store , X509 *x509 ,
                                     struct stack_st_X509 *chain )
{
  int tmp ;

  {
  __CrestCall("X509_STORE_CTX_init_proxy", (void (*)())(& X509_STORE_CTX_init_proxy),
              4);
  __CrestLoadStackPtr("openssl_proxies.c:chain[22754]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:x509[22753]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:store[22752]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22751]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:997");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22751]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:store[22752]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:x509[22753]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:chain[22754]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_X509_STORE_CTX_init_opaque(ctx, store, x509, chain);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22755]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:997");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22755]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern int ENGINE_load_ssl_client_cert_proxy(ENGINE *e , SSL *s , struct stack_st_X509_NAME *ca_dn ,
                                             X509 **pcert , EVP_PKEY **ppkey , struct stack_st_X509 **pother ,
                                             UI_METHOD *ui_method , void *callback_data )
{
  int tmp ;

  {
  __CrestCall("ENGINE_load_ssl_client_cert_proxy", (void (*)())(& ENGINE_load_ssl_client_cert_proxy),
              8);
  __CrestLoadStackPtr("openssl_proxies.c:callback_data[22772]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ui_method[22771]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:pother[22770]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ppkey[22769]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:pcert[22768]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ca_dn[22767]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:s[22766]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:e[22765]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1005");
  __CrestLoadStackPtr("openssl_proxies.c:e[22765]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:s[22766]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ca_dn[22767]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pcert[22768]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ppkey[22769]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pother[22770]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ui_method[22771]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:callback_data[22772]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_ENGINE_load_ssl_client_cert_opaque(e, s, ca_dn, pcert, ppkey, pother,
                                                   ui_method, callback_data);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22773]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1005");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22773]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern EVP_PKEY *EVP_PKEY_new_mac_key_proxy(int type , ENGINE *e , unsigned char *key ,
                                            int keylen )
{
  EVP_PKEY *ret ;
  EVP_PKEY *tmp ;

  {
  __CrestCall("EVP_PKEY_new_mac_key_proxy", (void (*)())(& EVP_PKEY_new_mac_key_proxy),
              4);
  __CrestLoadStackPtr("openssl_proxies.c:keylen[22782]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key[22781]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:e[22780]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:type[22779]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1015");
  __CrestLoadStackPtr("openssl_proxies.c:type[22779]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:e[22780]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key[22781]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:keylen[22782]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_new_mac_key_opaque(type, e, (unsigned char const *)key,
                                            keylen);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22784]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1015");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22784]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22783]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1017");
  __CrestLoadStackPtr("openssl_proxies.c:key[22781]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:keylen[22782]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("keybits");

  load_buf((unsigned char const *)key, (size_t )keylen, "keybits");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1019");
  __CrestLoadCString("EVP_PKEY_new_mac_key");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("EVP_PKEY_new_mac_key", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1020");
  __CrestLoadCString("key");

  Hint("key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1021");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1023");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22783]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  store_ctx((void const *)ret, "id");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1026");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22783]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestFieldOffset("pkey");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestFieldOffset("ptr");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22783]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  copy_ctx((void const *)ret->pkey.ptr, (void const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1028");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22783]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern X509 *PEM_read_bio_X509_proxy(BIO *bp , X509 **x , pem_password_cb *cb , void *u )
{
  X509 *ret ;
  X509 *tmp ;

  {
  __CrestCall("PEM_read_bio_X509_proxy", (void (*)())(& PEM_read_bio_X509_proxy),
              4);
  __CrestLoadStackPtr("openssl_proxies.c:u[22793]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:cb[22792]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:x[22791]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bp[22790]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1035");
  __CrestLoadStackPtr("openssl_proxies.c:bp[22790]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:x[22791]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cb[22792]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:u[22793]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_PEM_read_bio_X509_opaque(bp, x, cb, u);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22795]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1035");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22795]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22794]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1037");
  __CrestLoadCString("PEM_read_bio_X509");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("PEM_read_bio_X509", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1038");
  __CrestLoadCString("cert");

  Hint("cert");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1039");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1041");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22794]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  store_ctx((void const *)ret, "id");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1043");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22794]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_get_cipherbyname_proxy(char const *name )
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_get_cipherbyname_proxy", (void (*)())(& EVP_get_cipherbyname_proxy),
              1);
  __CrestLoadStackPtr("openssl_proxies.c:name[22798]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1049");
  __CrestLoadStackPtr("openssl_proxies.c:name[22798]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_get_cipherbyname_opaque(name);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22800]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1049");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22800]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22799]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1051");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22799]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadStackPtr("openssl_proxies.c:name[22798]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  set_attr_str((void const *)ret, "type", name);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1053");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22799]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_enc_null_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_enc_null_proxy", (void (*)())(& EVP_enc_null_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1059");

  tmp = __crest_EVP_enc_null_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22804]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1059");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22804]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22803]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1061");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22803]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("null");

  set_attr_str((void const *)ret, "type", "null");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1063");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22803]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern X509 *d2i_X509_bio_proxy(BIO *bp , X509 **x509 )
{
  X509 *ret ;
  X509 *tmp ;

  {
  __CrestCall("d2i_X509_bio_proxy", (void (*)())(& d2i_X509_bio_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:x509[22809]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bp[22808]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1069");
  __CrestLoadStackPtr("openssl_proxies.c:bp[22808]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:x509[22809]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_d2i_X509_bio_opaque(bp, x509);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22811]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1069");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22811]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22810]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1071");
  __CrestLoadCString("d2i_X509_bio");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("d2i_X509_bio", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1072");
  __CrestLoadCString("cert");

  Hint("cert");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1073");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1075");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22810]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  store_ctx((void const *)ret, "id");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1077");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22810]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_PKEY_assign_proxy(EVP_PKEY *pkey , int type , void *key )
{
  int tmp ;

  {
  __CrestCall("EVP_PKEY_assign_proxy", (void (*)())(& EVP_PKEY_assign_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:key[22818]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:type[22817]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22816]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1089");
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22816]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:type[22817]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key[22818]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_assign_opaque(pkey, type, key);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22819]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1089");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22819]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern int EVP_PKEY_copy_parameters_proxy(EVP_PKEY *to , EVP_PKEY const *from )
{
  int tmp ;

  {
  __CrestCall("EVP_PKEY_copy_parameters_proxy", (void (*)())(& EVP_PKEY_copy_parameters_proxy),
              2);
  __CrestLoadStackPtr("openssl_proxies.c:from[22824]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:to[22823]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1098");
  __CrestLoadStackPtr("openssl_proxies.c:to[22823]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:from[22824]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_copy_parameters_opaque(to, from);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22825]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1098");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22825]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern EVP_PKEY *PEM_read_bio_PrivateKey_proxy(BIO *bp , EVP_PKEY **x , pem_password_cb *cb ,
                                               void *u )
{
  EVP_PKEY *ret ;
  EVP_PKEY *tmp ;

  {
  __CrestCall("PEM_read_bio_PrivateKey_proxy", (void (*)())(& PEM_read_bio_PrivateKey_proxy),
              4);
  __CrestLoadStackPtr("openssl_proxies.c:u[22834]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:cb[22833]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:x[22832]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bp[22831]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1105");
  __CrestLoadStackPtr("openssl_proxies.c:bp[22831]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:x[22832]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cb[22833]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:u[22834]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_PEM_read_bio_PrivateKey_opaque(bp, x, cb, u);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22836]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1105");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22836]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22835]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1107");
  __CrestLoadCString("PEM_read_bio_PrivateKey");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("PEM_read_bio_PrivateKey", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1108");
  __CrestLoadCString("pkey");

  Hint("pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1109");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1111");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22835]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");

  store_ctx((void const *)ret, "key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1113");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22835]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestFieldOffset("pkey");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestFieldOffset("ptr");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22835]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  copy_ctx((void const *)ret->pkey.ptr, (void const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1115");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22835]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_PKEY *d2i_PrivateKey_bio_proxy(BIO *bp , EVP_PKEY **a )
{
  EVP_PKEY *ret ;
  EVP_PKEY *tmp ;

  {
  __CrestCall("d2i_PrivateKey_bio_proxy", (void (*)())(& d2i_PrivateKey_bio_proxy),
              2);
  __CrestLoadStackPtr("openssl_proxies.c:a[22841]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bp[22840]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1121");
  __CrestLoadStackPtr("openssl_proxies.c:bp[22840]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:a[22841]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_d2i_PrivateKey_bio_opaque(bp, a);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22843]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1121");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22843]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22842]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1123");
  __CrestLoadCString("d2i_PrivateKey_bio");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("d2i_PrivateKey_bio", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1124");
  __CrestLoadCString("pkey");

  Hint("pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1125");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1127");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22842]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  store_ctx((void const *)ret, "id");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1129");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22842]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestFieldOffset("pkey");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestFieldOffset("ptr");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22842]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  copy_ctx((void const *)ret->pkey.ptr, (void const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1131");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22842]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_PKEY *d2i_PrivateKey_proxy(int type , EVP_PKEY **a , unsigned char const **pp ,
                                      long length )
{
  EVP_PKEY *ret ;
  EVP_PKEY *tmp ;

  {
  __CrestCall("d2i_PrivateKey_proxy", (void (*)())(& d2i_PrivateKey_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies.c:length[22852]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:pp[22851]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[22850]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:type[22849]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1138");
  __CrestLoadStackPtr("openssl_proxies.c:type[22849]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:a[22850]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pp[22851]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:length[22852]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_d2i_PrivateKey_opaque(type, a, pp, length);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22854]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1138");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22854]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22853]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1141");
  __CrestLoadStackPtr("openssl_proxies.c:pp[22851]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:length[22852]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,8] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("keystring");

  load_buf(*pp, (size_t )length, "keystring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1143");
  __CrestLoadCString("d2i_PrivateKey");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("d2i_PrivateKey", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1144");
  __CrestLoadCString("pkey");

  Hint("pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1145");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1147");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22853]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  store_ctx((void const *)ret, "id");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1149");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22853]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )56);
  __CrestSetPtrStep();
  __CrestFieldOffset("pkey");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestFieldOffset("ptr");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22853]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  copy_ctx((void const *)ret->pkey.ptr, (void const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1151");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22853]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_des_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_des_cbc_proxy", (void (*)())(& EVP_des_cbc_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1157");

  tmp = __crest_EVP_des_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22858]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1157");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22858]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22857]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1159");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22857]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("des_cbc");

  set_attr_str((void const *)ret, "type", "des_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1161");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22857]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_des_ede3_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_des_ede3_cbc_proxy", (void (*)())(& EVP_des_ede3_cbc_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1166");

  tmp = __crest_EVP_des_ede3_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22862]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1166");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22862]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22861]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1168");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22861]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("des_ede3_cbc");

  set_attr_str((void const *)ret, "type", "des_ede3_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1170");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22861]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_rc4_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_rc4_proxy", (void (*)())(& EVP_rc4_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1187");

  tmp = __crest_EVP_rc4_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22866]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1187");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22866]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22865]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1189");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22865]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("rc4");

  set_attr_str((void const *)ret, "type", "rc4");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1191");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22865]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_rc2_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_rc2_cbc_proxy", (void (*)())(& EVP_rc2_cbc_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1196");

  tmp = __crest_EVP_rc2_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22870]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1196");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22870]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22869]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1198");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22869]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("rc2_cbc");

  set_attr_str((void const *)ret, "type", "rc2_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1200");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22869]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_rc2_40_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_rc2_40_cbc_proxy", (void (*)())(& EVP_rc2_40_cbc_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1205");

  tmp = __crest_EVP_rc2_40_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22874]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1205");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22874]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22873]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1207");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22873]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("rc2_40_cbc");

  set_attr_str((void const *)ret, "type", "rc2_40_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1209");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22873]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_aes_192_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_aes_192_cbc_proxy", (void (*)())(& EVP_aes_192_cbc_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1215");

  tmp = __crest_EVP_aes_192_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22878]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1215");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22878]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22877]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1217");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22877]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("aes_192_cbc");

  set_attr_str((void const *)ret, "type", "aes_192_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1219");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22877]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_aes_256_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_aes_256_cbc_proxy", (void (*)())(& EVP_aes_256_cbc_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1224");

  tmp = __crest_EVP_aes_256_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22882]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1224");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22882]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22881]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1226");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22881]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("aes_256_cbc");

  set_attr_str((void const *)ret, "type", "aes_256_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1228");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22881]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_camellia_128_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_camellia_128_cbc_proxy", (void (*)())(& EVP_camellia_128_cbc_proxy),
              0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1235");

  tmp = __crest_EVP_camellia_128_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22886]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1235");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22886]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22885]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1237");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22885]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("camellia_128_cbc");

  set_attr_str((void const *)ret, "type", "camellia_128_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1239");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22885]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_camellia_256_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_camellia_256_cbc_proxy", (void (*)())(& EVP_camellia_256_cbc_proxy),
              0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1244");

  tmp = __crest_EVP_camellia_256_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22890]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1244");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22890]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22889]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1246");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22889]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("camellia_256_cbc");

  set_attr_str((void const *)ret, "type", "camellia_256_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1248");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22889]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_CIPHER const *EVP_seed_cbc_proxy(void)
{
  EVP_CIPHER const *ret ;
  EVP_CIPHER const *tmp ;

  {
  __CrestCall("EVP_seed_cbc_proxy", (void (*)())(& EVP_seed_cbc_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1253");

  tmp = __crest_EVP_seed_cbc_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22894]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1253");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22894]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22893]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1255");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22893]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");
  __CrestLoadCString("seed_cbc");

  set_attr_str((void const *)ret, "type", "seed_cbc");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1257");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22893]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int RAND_bytes_proxy(unsigned char *buf , int num )
{
  int ret ;
  int tmp ;
  int __retres5 ;

  {
  __CrestCall("RAND_bytes_proxy", (void (*)())(& RAND_bytes_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:num[22899]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:buf[22898]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1273");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1274");
  __CrestLoadStackPtr("openssl_proxies.c:buf[22898]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:num[22899]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_RAND_bytes_opaque(buf, num);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22901]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1274");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22901]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22900]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1275");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22900]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);
  __CrestApply("(!=: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if (ret != 1) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1276");
    __CrestLoadCString("RAND_bytes failed");
    __CrestMute();

    proxy_fail("RAND_bytes failed");
    __CrestUnmute();
    __CrestClear(1);
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1277");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1279");
  __CrestLoadStackPtr("openssl_proxies.c:num[22899]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestLoadCString("nonce");

  newTL((size_t )num, (char const *)((void *)0), "nonce");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1280");
  __CrestLoadStackPtr("openssl_proxies.c:buf[22898]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)buf);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1282");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);
  __CrestLoadStackPtr("openssl_proxies.c:__retres5[23494]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  __retres5 = 1;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1271");
  __CrestLoadStackPtr("openssl_proxies.c:__retres5[23494]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (__retres5);
  }
}
}

extern int RAND_pseudo_bytes_proxy(unsigned char *buf , int num )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("RAND_pseudo_bytes_proxy", (void (*)())(& RAND_pseudo_bytes_proxy),
              2);
  __CrestLoadStackPtr("openssl_proxies.c:num[22906]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:buf[22905]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1296");
  __CrestLoadStackPtr("openssl_proxies.c:buf[22905]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:num[22906]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_RAND_pseudo_bytes_opaque(buf, num);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22908]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1296");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22908]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22907]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1298");
  __CrestLoadCString("RAND_pseudo_bytes");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("RAND_pseudo_bytes", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1299");
  __CrestLoadCString("nonce");

  Hint("nonce");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1300");
  __CrestLoadStackPtr("openssl_proxies.c:num[22906]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)(& num), (_Bool)1, sizeof(num));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1301");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1303");
  __CrestLoadStackPtr("openssl_proxies.c:buf[22905]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)buf);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1305");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22907]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern RSA *d2i_RSAPrivateKey_bio_proxy(BIO *bp , RSA **rsa )
{
  RSA *ret ;
  RSA *tmp ;

  {
  __CrestCall("d2i_RSAPrivateKey_bio_proxy", (void (*)())(& d2i_RSAPrivateKey_bio_proxy),
              2);
  __CrestLoadStackPtr("openssl_proxies.c:rsa[22913]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bp[22912]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1311");
  __CrestLoadStackPtr("openssl_proxies.c:bp[22912]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:rsa[22913]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_d2i_RSAPrivateKey_bio_opaque(bp, rsa);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22915]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1311");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22915]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22914]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1313");
  __CrestLoadCString("d2i_RSAPrivateKey_bio");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("d2i_RSAPrivateKey_bio", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1314");
  __CrestLoadCString("rsa_key");

  Hint("rsa_key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1315");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1317");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22914]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  store_ctx((void const *)ret, "id");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1319");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22914]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern RSA *PEM_read_bio_RSAPrivateKey_proxy(BIO *bp , RSA **x , pem_password_cb *cb ,
                                             void *u )
{
  RSA *ret ;
  RSA *tmp ;

  {
  __CrestCall("PEM_read_bio_RSAPrivateKey_proxy", (void (*)())(& PEM_read_bio_RSAPrivateKey_proxy),
              4);
  __CrestLoadStackPtr("openssl_proxies.c:u[22924]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:cb[22923]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:x[22922]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bp[22921]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1326");
  __CrestLoadStackPtr("openssl_proxies.c:bp[22921]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:x[22922]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cb[22923]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:u[22924]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_PEM_read_bio_RSAPrivateKey_opaque(bp, x, cb, u);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22926]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1326");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22926]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22925]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1328");
  __CrestLoadCString("PEM_read_bio_RSAPrivateKey");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("PEM_read_bio_RSAPrivateKey", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1329");
  __CrestLoadCString("rsa_key");

  Hint("rsa_key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1330");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1332");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22925]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  store_ctx((void const *)ret, "id");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1334");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22925]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern RSA *d2i_RSAPrivateKey_proxy(RSA **a , unsigned char const **in , long len___0 )
{
  RSA *ret ;
  RSA *tmp ;

  {
  __CrestCall("d2i_RSAPrivateKey_proxy", (void (*)())(& d2i_RSAPrivateKey_proxy),
              3);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22934]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[22932]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[22931]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1340");
  __CrestLoadStackPtr("openssl_proxies.c:a[22931]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[22932]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[22934]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_d2i_RSAPrivateKey_opaque(a, in, len___0);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22936]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1340");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22936]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22935]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1342");
  __CrestLoadCString("d2i_RSAPrivateKey");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("d2i_RSAPrivateKey", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1343");
  __CrestLoadCString("rsa_key");

  Hint("rsa_key");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1344");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1346");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22935]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  store_ctx((void const *)ret, "id");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1348");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22935]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern EVP_PKEY_CTX *EVP_PKEY_CTX_new_proxy(EVP_PKEY *pkey , ENGINE *e )
{
  EVP_PKEY_CTX *ret ;
  EVP_PKEY_CTX *tmp ;

  {
  __CrestCall("EVP_PKEY_CTX_new_proxy", (void (*)())(& EVP_PKEY_CTX_new_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:e[22941]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22940]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1438");
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22940]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:e[22941]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_CTX_new_opaque(pkey, e);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22943]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1438");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22943]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22942]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1440");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22942]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22940]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  copy_attr_ex((void const *)ret, "key", (void const *)pkey, "id");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1442");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22942]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_PKEY_derive_set_peer_proxy(EVP_PKEY_CTX *ctx , EVP_PKEY *peer )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_PKEY_derive_set_peer_proxy", (void (*)())(& EVP_PKEY_derive_set_peer_proxy),
              2);
  __CrestLoadStackPtr("openssl_proxies.c:peer[22948]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22947]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1449");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22947]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:peer[22948]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_derive_set_peer_opaque(ctx, peer);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22950]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1449");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22950]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22949]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1451");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22947]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("peerkey");
  __CrestLoadStackPtr("openssl_proxies.c:peer[22948]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  copy_attr_ex((void const *)ctx, "peerkey", (void const *)peer, "id");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1453");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22949]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_PKEY_decrypt_proxy(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                                  unsigned char const *in , size_t inlen )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_PKEY_decrypt_proxy", (void (*)())(& EVP_PKEY_decrypt_proxy), 5);
  __CrestLoadStackPtr("openssl_proxies.c:inlen[22961]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[22960]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:outlen[22959]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[22958]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22957]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1466");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22957]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[22958]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outlen[22959]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[22960]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:inlen[22961]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_decrypt_opaque(ctx, out, outlen, in, inlen);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22963]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1466");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22963]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22962]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1468");
  __CrestLoadStackPtr("openssl_proxies.c:out[22958]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )out != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1470");
    __CrestLoadStackPtr("openssl_proxies.c:in[22960]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:inlen[22961]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadCString("enc");

    load_buf(in, inlen, "enc");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1471");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22957]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("key");
    __CrestLoadCString("pkey");

    load_ctx((void const *)ctx, "key", "pkey");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1473");
    __CrestLoadCString("EVP_PKEY_decrypt");
    __CrestLoadInt((long long )2);
    __CrestBS(1, 4);

    SymN("EVP_PKEY_decrypt", 2);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1474");
    __CrestLoadCString("dec");

    Hint("dec");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1475");
    __CrestLoadStackPtr("openssl_proxies.c:outlen[22959]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadInt((long long )(_Bool)0);
    __CrestBS(0, 1);
    __CrestLoadInt((long long )8);
    __CrestBS(0, 8);

    assume_len((unsigned char const *)outlen, (_Bool)0, sizeof(*outlen));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1477");
    __CrestLoadStackPtr("openssl_proxies.c:out[22958]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();

    store_buf((unsigned char const *)out);
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1480");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22962]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_PKEY_CTX_ctrl_proxy(EVP_PKEY_CTX *ctx , int keytype , int optype ,
                                   int cmd , int p1 , void *p2 )
{
  int tmp ;

  {
  __CrestCall("EVP_PKEY_CTX_ctrl_proxy", (void (*)())(& EVP_PKEY_CTX_ctrl_proxy),
              6);
  __CrestLoadStackPtr("openssl_proxies.c:p2[22976]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:p1[22975]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:cmd[22974]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:optype[22973]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:keytype[22972]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22971]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1487");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22971]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:keytype[22972]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:optype[22973]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cmd[22974]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:p1[22975]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:p2[22976]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_CTX_ctrl_opaque(ctx, keytype, optype, cmd, p1, p2);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22977]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1487");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22977]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

int EVP_DigestSignInit_proxy(EVP_MD_CTX *ctx , EVP_PKEY_CTX **pctx , EVP_MD const *type ,
                             ENGINE *e , EVP_PKEY *pkey )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_DigestSignInit_proxy", (void (*)())(& EVP_DigestSignInit_proxy),
              5);
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22988]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:e[22987]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:type[22986]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:pctx[22985]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22984]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1500");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22984]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pctx[22985]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:type[22986]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:e[22987]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22988]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_DigestSignInit_opaque(ctx, pctx, type, e, pkey);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22990]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1500");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[22990]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[22989]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1502");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22984]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("key");
  __CrestLoadStackPtr("openssl_proxies.c:pkey[22988]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");

  copy_attr_ex((void const *)ctx, "key", (void const *)pkey, "id");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1503");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22984]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:type[22986]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("type");

  copy_attr((void const *)ctx, (void const *)type, "type");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1504");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22984]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("use");
  __CrestLoadCString("DigestSign");

  set_attr_str((void const *)ctx, "use", "DigestSign");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1505");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22984]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("msg");
  __CrestLoadCString("");

  set_attr_str((void const *)ctx, "msg", "");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1507");
  __CrestLoadStackPtr("openssl_proxies.c:pctx[22985]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )pctx != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1508");
    __CrestLoadStackPtr("openssl_proxies.c:pctx[22985]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("key");
    __CrestLoadStackPtr("openssl_proxies.c:pkey[22988]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("id");

    copy_attr_ex((void const *)*pctx, "key", (void const *)pkey, "id");
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1510");
  __CrestLoadStackPtr("openssl_proxies.c:ret[22989]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_PKEY_verify_proxy(EVP_PKEY_CTX *ctx , unsigned char const *sig ,
                                 size_t siglen , unsigned char const *tbs , size_t tbslen )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("EVP_PKEY_verify_proxy", (void (*)())(& EVP_PKEY_verify_proxy), 5);
  __CrestLoadStackPtr("openssl_proxies.c:tbslen[23001]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:tbs[23000]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[22999]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:sig[22998]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22997]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1525");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[22997]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:sig[22998]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[22999]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:tbs[23000]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:tbslen[23001]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_verify_opaque(ctx, sig, siglen, tbs, tbslen);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23003]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1525");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23003]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23002]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1530");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23002]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);
  __CrestApply("(==: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if (ret == 1) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1532");
    __CrestLoadStackPtr("openssl_proxies.c:tbs[23000]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:tbslen[23001]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadCString("msg");

    load_buf(tbs, tbslen, "msg");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1533");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[22997]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("key");
    __CrestLoadCString("pkey");

    load_ctx((void const *)ctx, "key", "pkey");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1535");
    __CrestLoadCString("EVP_PKEY_verify");
    __CrestLoadInt((long long )2);
    __CrestBS(1, 4);

    SymN("EVP_PKEY_verify", 2);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1536");
    __CrestLoadCString("sig");

    Hint("sig");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1537");
    __CrestLoadStackPtr("openssl_proxies.c:siglen[22999]");
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

    assume_len((unsigned char const *)(& siglen), (_Bool)0, sizeof(siglen));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1539");
    __CrestLoadStackPtr("openssl_proxies.c:sig[22998]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    store_buf(sig);
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1547");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23002]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_PKEY_encrypt_proxy(EVP_PKEY_CTX *ctx , unsigned char *out , size_t *outlen ,
                                  unsigned char const *in , size_t inlen )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("EVP_PKEY_encrypt_proxy", (void (*)())(& EVP_PKEY_encrypt_proxy), 5);
  __CrestLoadStackPtr("openssl_proxies.c:inlen[23014]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[23013]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:outlen[23012]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[23011]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23010]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1560");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23010]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[23011]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:outlen[23012]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in[23013]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:inlen[23014]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_encrypt_opaque(ctx, out, outlen, in, inlen);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23016]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1560");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23016]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23015]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1562");
  __CrestLoadStackPtr("openssl_proxies.c:out[23011]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )out != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1564");
    __CrestLoadCString("lenvar");
    __CrestLoadInt((long long )0);
    __CrestBS(1, 4);

    SymN("lenvar", 0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1565");
    __CrestLoadCString("enc_len");

    Hint("enc_len");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1566");
    __CrestLoadInt((long long )8);
    __CrestBS(0, 8);
    __CrestLoadStackPtr("openssl_proxies.c:len___0[23018]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestStore();

    len___0 = sizeof(*outlen);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1567");
    __CrestLoadStackPtr("openssl_proxies.c:len___0[23018]");
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

    assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1569");
    __CrestLoadStackPtr("openssl_proxies.c:outlen[23012]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();

    store_buf((unsigned char const *)((unsigned char *)outlen));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1571");
    __CrestLoadStackPtr("openssl_proxies.c:in[23013]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:inlen[23014]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadCString("plain");

    load_buf(in, inlen, "plain");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1572");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[23010]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("key");
    __CrestLoadCString("pkey");

    load_ctx((void const *)ctx, "key", "pkey");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1574");
    __CrestLoadCString("EVP_PKEY_encrypt");
    __CrestLoadInt((long long )2);
    __CrestBS(1, 4);

    SymN("EVP_PKEY_encrypt", 2);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1575");
    __CrestLoadCString("penc");

    Hint("penc");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1576");

    Nondet();
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1577");
    __CrestLoadStackPtr("openssl_proxies.c:outlen[23012]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadInt((long long )(_Bool)0);
    __CrestBS(0, 1);
    __CrestLoadInt((long long )8);
    __CrestBS(0, 8);

    assume_len((unsigned char const *)outlen, (_Bool)0, sizeof(*outlen));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1579");
    __CrestLoadStackPtr("openssl_proxies.c:out[23011]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();

    store_buf((unsigned char const *)out);
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1582");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23015]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int EVP_PKEY_sign_proxy(EVP_PKEY_CTX *ctx , unsigned char *sig , size_t *siglen ,
                               unsigned char const *tbs , size_t tbslen )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("EVP_PKEY_sign_proxy", (void (*)())(& EVP_PKEY_sign_proxy), 5);
  __CrestLoadStackPtr("openssl_proxies.c:tbslen[23029]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:tbs[23028]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[23027]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:sig[23026]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23025]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1596");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23025]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:sig[23026]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[23027]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:tbs[23028]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:tbslen[23029]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_EVP_PKEY_sign_opaque(ctx, sig, siglen, tbs, tbslen);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23031]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1596");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23031]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23030]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1598");
  __CrestLoadStackPtr("openssl_proxies.c:sig[23026]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )sig != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1600");
    __CrestLoadCString("lenvar");
    __CrestLoadInt((long long )0);
    __CrestBS(1, 4);

    SymN("lenvar", 0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1601");
    __CrestLoadCString("sig_len");

    Hint("sig_len");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1602");
    __CrestLoadInt((long long )8);
    __CrestBS(0, 8);
    __CrestLoadStackPtr("openssl_proxies.c:len___0[23033]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestStore();

    len___0 = sizeof(*siglen);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1603");
    __CrestLoadStackPtr("openssl_proxies.c:len___0[23033]");
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

    assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1604");

    Nondet();
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1606");
    __CrestLoadStackPtr("openssl_proxies.c:siglen[23027]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();

    store_buf((unsigned char const *)((unsigned char *)siglen));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1608");
    __CrestLoadStackPtr("openssl_proxies.c:tbs[23028]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:tbslen[23029]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadCString("msg");

    load_buf(tbs, tbslen, "msg");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1609");
    __CrestLoadStackPtr("openssl_proxies.c:ctx[23025]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("key");
    __CrestLoadCString("pkey");

    load_ctx((void const *)ctx, "key", "pkey");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1611");
    __CrestLoadCString("EVP_PKEY_sign");
    __CrestLoadInt((long long )2);
    __CrestBS(1, 4);

    SymN("EVP_PKEY_sign", 2);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1612");
    __CrestLoadStackPtr("openssl_proxies.c:siglen[23027]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadInt((long long )(_Bool)0);
    __CrestBS(0, 1);
    __CrestLoadInt((long long )8);
    __CrestBS(0, 8);

    assume_len((unsigned char const *)siglen, (_Bool)0, sizeof(*siglen));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1613");

    Nondet();
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1615");
    __CrestLoadStackPtr("openssl_proxies.c:sig[23026]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();

    store_buf((unsigned char const *)sig);
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1618");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23030]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void BN_free_proxy(BIGNUM *a )
{


  {
  __CrestCall("BN_free_proxy", (void (*)())(& BN_free_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[23036]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1626");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1627");
  __CrestLoadStackPtr("openssl_proxies.c:a[23036]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_BN_free_opaque(a);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1628");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1624");
  __CrestReturn(1);

  return;
  }
}
}

BIGNUM *BN_new_proxy(void)
{
  BIGNUM *ret ;
  BIGNUM *tmp ;

  {
  __CrestCall("BN_new_proxy", (void (*)())(& BN_new_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1633");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1634");

  tmp = __crest_BN_new_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23040]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1634");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23040]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23039]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1635");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1637");
  __CrestApply("ptrLen/0");
  __CrestBS(0, 8);

  fresh_ptr(sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1638");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23039]");
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

  store_buf((unsigned char const *)((unsigned char *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1640");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23039]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void BN_init_proxy(BIGNUM *a )
{


  {
  __CrestCall("BN_init_proxy", (void (*)())(& BN_init_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[23043]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1645");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1646");
  __CrestLoadStackPtr("openssl_proxies.c:a[23043]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_BN_init_opaque(a);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1647");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1643");
  __CrestReturn(1);

  return;
  }
}
}

int BN_rand_range_proxy(BIGNUM *rnd , BIGNUM const *range )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("BN_rand_range_proxy", (void (*)())(& BN_rand_range_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:range[23048]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:rnd[23047]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1652");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1653");
  __CrestLoadStackPtr("openssl_proxies.c:rnd[23047]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:range[23048]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_rand_range_opaque(rnd, range);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23050]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1653");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23050]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23049]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1654");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1656");
  __CrestLoadCString("BN_rand_range_result");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("BN_rand_range_result", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1657");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1658");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23052]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1659");
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23052]");
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

  assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1660");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23049]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1662");
  __CrestLoadStackPtr("openssl_proxies.c:range[23048]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("range");

  load_ctx((void const *)range, "val", "range");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1663");
  __CrestLoadCString("BN_rand_range");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("BN_rand_range", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1664");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1665");
  __CrestLoadStackPtr("openssl_proxies.c:rnd[23047]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)rnd, "val");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1667");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23049]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

BN_MONT_CTX *BN_MONT_CTX_set_locked_proxy(BN_MONT_CTX **pmont , int lock , BIGNUM const *mod ,
                                          BN_CTX *ctx )
{
  BN_MONT_CTX *ret ;
  BN_MONT_CTX *tmp ;

  {
  __CrestCall("BN_MONT_CTX_set_locked_proxy", (void (*)())(& BN_MONT_CTX_set_locked_proxy),
              4);
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23061]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:mod[23060]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:lock[23059]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:pmont[23058]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1676");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1677");
  __CrestLoadStackPtr("openssl_proxies.c:pmont[23058]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:lock[23059]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:mod[23060]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23061]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_MONT_CTX_set_locked_opaque(pmont, lock, mod, ctx);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23063]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1677");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23063]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23062]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1678");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1680");
  __CrestApply("ptrLen/0");
  __CrestBS(0, 8);

  fresh_ptr(sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1681");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23062]");
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

  store_buf((unsigned char const *)((unsigned char *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1683");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23062]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

BIGNUM *BN_copy_proxy(BIGNUM *a , BIGNUM const *b )
{
  BIGNUM *ret ;
  BIGNUM *tmp ;

  {
  __CrestCall("BN_copy_proxy", (void (*)())(& BN_copy_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:b[23068]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23067]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1689");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1690");
  __CrestLoadStackPtr("openssl_proxies.c:a[23067]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:b[23068]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_copy_opaque(a, b);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23070]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1690");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23070]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23069]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1691");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1693");
  __CrestLoadStackPtr("openssl_proxies.c:a[23067]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23069]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = a;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1695");
  __CrestLoadStackPtr("openssl_proxies.c:a[23067]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("bignum");

  load_ctx((void const *)a, "val", "bignum");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1696");
  __CrestLoadStackPtr("openssl_proxies.c:b[23068]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)b, "val");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1698");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23069]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int BN_add_proxy(BIGNUM *r , BIGNUM const *a , BIGNUM const *b )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("BN_add_proxy", (void (*)())(& BN_add_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:b[23077]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23076]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:r[23075]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1707");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1708");
  __CrestLoadStackPtr("openssl_proxies.c:r[23075]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:a[23076]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:b[23077]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_add_opaque(r, a, b);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23079]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1708");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23079]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23078]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1709");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1711");
  __CrestLoadCString("BN_add_result");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("BN_add_result", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1712");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1713");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23081]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1714");
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23081]");
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

  assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1715");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23078]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1717");
  __CrestLoadStackPtr("openssl_proxies.c:a[23076]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("a");

  load_ctx((void const *)a, "val", "a");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1718");
  __CrestLoadStackPtr("openssl_proxies.c:b[23077]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("b");

  load_ctx((void const *)b, "val", "b");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1719");
  __CrestLoadCString("BN_add");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("BN_add", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1720");
  __CrestLoadStackPtr("openssl_proxies.c:r[23075]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)r, "val");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1722");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23078]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int BN_div_proxy(BIGNUM *dv , BIGNUM *rem , BIGNUM const *m , BIGNUM const *d ,
                 BN_CTX *ctx )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("BN_div_proxy", (void (*)())(& BN_div_proxy), 5);
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23092]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:d[23091]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:m[23090]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:rem[23089]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:dv[23088]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1735");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1736");
  __CrestLoadStackPtr("openssl_proxies.c:dv[23088]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:rem[23089]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m[23090]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:d[23091]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23092]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_div_opaque(dv, rem, m, d, ctx);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23094]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1736");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23094]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23093]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1737");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1739");
  __CrestLoadCString("BN_div_result");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("BN_div_result", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1740");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1741");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23096]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1742");
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23096]");
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

  assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1743");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23093]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1745");
  __CrestLoadStackPtr("openssl_proxies.c:dv[23088]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )dv != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1746");
    __CrestLoadStackPtr("openssl_proxies.c:m[23090]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("val");
    __CrestLoadCString("m");

    load_ctx((void const *)m, "val", "m");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1747");
    __CrestLoadStackPtr("openssl_proxies.c:d[23091]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("val");
    __CrestLoadCString("d");

    load_ctx((void const *)d, "val", "d");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1748");
    __CrestLoadCString("BN_div");
    __CrestLoadInt((long long )2);
    __CrestBS(1, 4);

    SymN("BN_div", 2);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1749");
    __CrestLoadStackPtr("openssl_proxies.c:dv[23088]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("val");

    store_ctx((void const *)dv, "val");
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1752");
  __CrestLoadStackPtr("openssl_proxies.c:rem[23089]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )rem != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1753");
    __CrestLoadStackPtr("openssl_proxies.c:m[23090]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("val");
    __CrestLoadCString("m");

    load_ctx((void const *)m, "val", "m");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1754");
    __CrestLoadStackPtr("openssl_proxies.c:d[23091]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("val");
    __CrestLoadCString("d");

    load_ctx((void const *)d, "val", "d");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1755");
    __CrestLoadCString("BN_rem");
    __CrestLoadInt((long long )2);
    __CrestBS(1, 4);

    SymN("BN_rem", 2);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1756");
    __CrestLoadStackPtr("openssl_proxies.c:rem[23089]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("val");

    store_ctx((void const *)rem, "val");
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1759");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23093]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

BIGNUM *BN_mod_inverse_proxy(BIGNUM *ret , BIGNUM const *a , BIGNUM const *n ,
                             BN_CTX *ctx )
{


  {
  __CrestCall("BN_mod_inverse_proxy", (void (*)())(& BN_mod_inverse_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23105]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:n[23104]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23103]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23102]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1765");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1766");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23102]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:a[23103]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:n[23104]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23105]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  ret = __crest_BN_mod_inverse_opaque(ret, a, n, ctx);
  __CrestLoadStackPtr("openssl_proxies.c:ret[23102]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1767");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1769");
  __CrestLoadStackPtr("openssl_proxies.c:a[23103]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("a");

  load_ctx((void const *)a, "val", "a");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1770");
  __CrestLoadStackPtr("openssl_proxies.c:n[23104]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("n");

  load_ctx((void const *)n, "val", "n");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1771");
  __CrestLoadCString("BN_mod_inverse");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("BN_mod_inverse", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1772");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23102]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)ret, "val");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1774");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23102]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void BN_clear_free_proxy(BIGNUM *a )
{


  {
  __CrestCall("BN_clear_free_proxy", (void (*)())(& BN_clear_free_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[23108]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1779");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1780");
  __CrestLoadStackPtr("openssl_proxies.c:a[23108]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_BN_clear_free_opaque(a);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1781");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1777");
  __CrestReturn(1);

  return;
  }
}
}

void BN_MONT_CTX_free_proxy(BN_MONT_CTX *mont )
{


  {
  __CrestCall("BN_MONT_CTX_free_proxy", (void (*)())(& BN_MONT_CTX_free_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:mont[23111]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1786");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1787");
  __CrestLoadStackPtr("openssl_proxies.c:mont[23111]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_BN_MONT_CTX_free_opaque(mont);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1788");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1784");
  __CrestReturn(1);

  return;
  }
}
}

void ERR_put_error_proxy(int lib , int func , int reason , char const *file , int line )
{


  {
  __CrestCall("ERR_put_error_proxy", (void (*)())(& ERR_put_error_proxy), 5);
  __CrestLoadStackPtr("openssl_proxies.c:line[23122]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:file[23121]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:reason[23120]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:func[23119]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:lib[23118]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1794");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1795");
  __CrestLoadStackPtr("openssl_proxies.c:lib[23118]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:func[23119]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:reason[23120]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:file[23121]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:line[23122]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_ERR_put_error_opaque(lib, func, reason, file, line);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1796");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1791");
  __CrestReturn(1);

  return;
  }
}
}

BN_CTX *BN_CTX_new_proxy(void)
{
  BN_CTX *ret ;
  BN_CTX *tmp ;

  {
  __CrestCall("BN_CTX_new_proxy", (void (*)())(& BN_CTX_new_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1802");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1803");

  tmp = __crest_BN_CTX_new_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23126]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1803");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23126]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23125]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1804");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1806");
  __CrestApply("ptrLen/0");
  __CrestBS(0, 8);

  fresh_ptr(sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1807");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23125]");
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

  store_buf((unsigned char const *)((unsigned char *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1809");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23125]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void BN_CTX_free_proxy(BN_CTX *c )
{


  {
  __CrestCall("BN_CTX_free_proxy", (void (*)())(& BN_CTX_free_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:c[23129]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1814");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1815");
  __CrestLoadStackPtr("openssl_proxies.c:c[23129]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_BN_CTX_free_opaque(c);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1816");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1812");
  __CrestReturn(1);

  return;
  }
}
}

void BN_CTX_start_proxy(BN_CTX *ctx )
{


  {
  __CrestCall("BN_CTX_start_proxy", (void (*)())(& BN_CTX_start_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23132]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1821");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1822");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23132]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_BN_CTX_start_opaque(ctx);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1823");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1819");
  __CrestReturn(1);

  return;
  }
}
}

BIGNUM *BN_CTX_get_proxy(BN_CTX *ctx )
{
  BIGNUM *ret ;
  BIGNUM *tmp ;

  {
  __CrestCall("BN_CTX_get_proxy", (void (*)())(& BN_CTX_get_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23135]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1828");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1829");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23135]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_CTX_get_opaque(ctx);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23137]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1829");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23137]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23136]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1830");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1832");
  __CrestApply("ptrLen/0");
  __CrestBS(0, 8);

  fresh_ptr(sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1833");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23136]");
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

  store_buf((unsigned char const *)((unsigned char *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1835");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23136]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void BN_CTX_end_proxy(BN_CTX *ctx )
{


  {
  __CrestCall("BN_CTX_end_proxy", (void (*)())(& BN_CTX_end_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23140]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1840");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1841");
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23140]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_BN_CTX_end_opaque(ctx);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1842");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1838");
  __CrestReturn(1);

  return;
  }
}
}

int BN_num_bits_proxy(BIGNUM const *a )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("BN_num_bits_proxy", (void (*)())(& BN_num_bits_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[23143]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1847");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1848");
  __CrestLoadStackPtr("openssl_proxies.c:a[23143]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_num_bits_opaque(a);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23145]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1848");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23145]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23144]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1849");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1851");
  __CrestLoadStackPtr("openssl_proxies.c:a[23143]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();

  load_ctx((void const *)a, "val", (char const *)((void *)0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1853");
  __CrestLoadCString("BN_num_bits");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("BN_num_bits", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1854");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23147]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1855");
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23147]");
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

  assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1857");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23144]");
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

  store_buf((unsigned char const *)((void *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1859");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23144]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int BN_num_bytes_proxy(BIGNUM const *a )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("BN_num_bytes_proxy", (void (*)())(& BN_num_bytes_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[23150]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1876");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1877");
  __CrestLoadStackPtr("openssl_proxies.c:a[23150]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = BN_num_bits_proxy(a);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23152]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1877");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23152]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )7);
  __CrestBS(1, 4);
  __CrestApply("(+: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestLoadInt((long long )8);
  __CrestBS(1, 4);
  __CrestApply("(/: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23151]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = (tmp + 7) / 8;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1878");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1880");
  __CrestLoadStackPtr("openssl_proxies.c:a[23150]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();

  load_ctx((void const *)a, "val", (char const *)((void *)0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1882");
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  len((_Bool)1, sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1883");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1885");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23151]");
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

  store_buf((unsigned char const *)((void *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1887");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23151]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern BIGNUM *BN_bin2bn_proxy(unsigned char const *s , int len___0 , BIGNUM *ret )
{
  BIGNUM *ret2 ;
  BIGNUM *tmp ;
  BIGNUM *result ;

  {
  __CrestCall("BN_bin2bn_proxy", (void (*)())(& BN_bin2bn_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:ret[23160]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23159]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:s[23157]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1900");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1901");
  __CrestLoadStackPtr("openssl_proxies.c:s[23157]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23159]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23160]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_bin2bn_opaque(s, len___0, ret);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23162]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1901");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23162]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret2[23161]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret2 = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1902");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1904");
  __CrestLoadInt((long long )24);
  __CrestBS(0, 8);

  fresh_ptr(sizeof(*ret2));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1905");
  __CrestLoadStackPtr("openssl_proxies.c:ret2[23161]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret2));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1909");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23160]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(==: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )ret == (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1909");
    __CrestLoadStackPtr("openssl_proxies.c:ret2[23161]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:result[23163]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestStore();

    result = ret2;
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1909");
    __CrestLoadStackPtr("openssl_proxies.c:ret[23160]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:result[23163]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestStore();

    result = ret;
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1911");
  __CrestLoadStackPtr("openssl_proxies.c:s[23157]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23159]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();

  load_buf(s, (size_t )len___0, (char const *)((void *)0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1912");
  __CrestLoadStackPtr("openssl_proxies.c:result[23163]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)result, "val");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1914");
  __CrestLoadStackPtr("openssl_proxies.c:result[23163]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (result);
  }
}
}

extern int BN_bn2bin_proxy(BIGNUM const *a , unsigned char *to )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("BN_bn2bin_proxy", (void (*)())(& BN_bn2bin_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:to[23168]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23167]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1925");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1926");
  __CrestLoadStackPtr("openssl_proxies.c:a[23167]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:to[23168]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_bn2bin_opaque(a, to);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23170]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1926");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23170]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23169]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1927");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1929");
  __CrestLoadStackPtr("openssl_proxies.c:a[23167]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();

  load_ctx((void const *)a, "val", (char const *)((void *)0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1930");
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  len((_Bool)1, sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1931");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1932");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23169]");
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

  store_buf((unsigned char const *)((void *)(& ret)));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1934");
  __CrestLoadStackPtr("openssl_proxies.c:a[23167]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();

  load_ctx((void const *)a, "val", (char const *)((void *)0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1935");
  __CrestLoadStackPtr("openssl_proxies.c:to[23168]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)to);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1937");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23169]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int BN_mod_exp_proxy(BIGNUM *r , BIGNUM const *a , BIGNUM const *p , BIGNUM const *m ,
                            BN_CTX *ctx )
{
  int ret ;
  int tmp ;
  int __retres8 ;

  {
  __CrestCall("BN_mod_exp_proxy", (void (*)())(& BN_mod_exp_proxy), 5);
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23181]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:m[23180]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:p[23179]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23178]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:r[23177]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1947");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1948");
  __CrestLoadStackPtr("openssl_proxies.c:r[23177]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:a[23178]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:p[23179]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m[23180]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23181]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_mod_exp_opaque(r, a, p, m, ctx);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23183]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1948");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23183]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23182]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1949");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23182]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);
  __CrestApply("(!=: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if (ret != 1) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1950");
    __CrestLoadCString("BN_mod_exp failed");
    __CrestMute();

    proxy_fail("BN_mod_exp failed");
    __CrestUnmute();
    __CrestClear(1);
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1951");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1953");
  __CrestLoadStackPtr("openssl_proxies.c:a[23178]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("bignum");

  load_ctx((void const *)a, "val", "bignum");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1954");
  __CrestLoadStackPtr("openssl_proxies.c:p[23179]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("bignum");

  load_ctx((void const *)p, "val", "bignum");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1955");
  __CrestLoadStackPtr("openssl_proxies.c:m[23180]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("bignum");

  load_ctx((void const *)m, "val", "bignum");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1957");
  __CrestLoadCString("mod_exp");
  __CrestLoadInt((long long )3);
  __CrestBS(1, 4);

  SymN("mod_exp", 3);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1958");
  __CrestLoadCString("bignum");

  Hint("bignum");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1959");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1961");
  __CrestLoadStackPtr("openssl_proxies.c:r[23177]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)r, "val");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1963");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);
  __CrestLoadStackPtr("openssl_proxies.c:__retres8[23495]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  __retres8 = 1;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1945");
  __CrestLoadStackPtr("openssl_proxies.c:__retres8[23495]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (__retres8);
  }
}
}

extern int BN_hex2bn_proxy(BIGNUM **a , char const *str )
{
  BIGNUM dummy ;
  int create_new ;
  int tmp ;
  int ret ;
  int tmp___0 ;
  BIGNUM *mem_8 ;

  {
  __CrestCall("BN_hex2bn_proxy", (void (*)())(& BN_hex2bn_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:str[23188]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23187]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1977");
  __CrestLoadStackPtr("openssl_proxies.c:a[23187]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )a != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    {
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1977");
    __CrestLoadStackPtr("openssl_proxies.c:a[23187]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: ptr -> [u,8])");
    __CrestDone();
    __CrestLoadStackPtr("nullPtr");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestApply("(CastToInt: ptr -> [u,8])");
    __CrestDone();
    __CrestApply("(==: [u,8] * [u,8] -> [s,4])");
    __CrestDone();
    __CrestTruth();

    if ((unsigned long )*a == (unsigned long )((void *)0)) {
      __CrestBranch(1);
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1977");
      __CrestLoadInt((long long )1);
      __CrestBS(1, 4);
      __CrestLoadStackPtr("openssl_proxies.c:tmp[23191]");
      __CrestLoadInt((long long )4);
      __CrestSetPtrStep();
      __CrestStore();

      tmp = 1;
    } else {
      __CrestBranch(0);
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1977");
      __CrestLoadInt((long long )0);
      __CrestBS(1, 4);
      __CrestLoadStackPtr("openssl_proxies.c:tmp[23191]");
      __CrestLoadInt((long long )4);
      __CrestSetPtrStep();
      __CrestStore();

      tmp = 0;
    }
    }
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1977");
    __CrestLoadInt((long long )0);
    __CrestBS(1, 4);
    __CrestLoadStackPtr("openssl_proxies.c:tmp[23191]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestStore();

    tmp = 0;
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1977");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23191]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:create_new[23190]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  create_new = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1979");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1980");
  __CrestLoadStackPtr("openssl_proxies.c:a[23187]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:str[23188]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp___0 = __crest_BN_hex2bn_opaque(a, str);
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[23194]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1980");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[23194]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23192]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp___0;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1981");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1983");
  __CrestLoadStackPtr("openssl_proxies.c:str[23188]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("hex");

  load_all((unsigned char const *)str, "hex");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1985");
  __CrestLoadCString("ztp");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("ztp", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1986");
  __CrestLoadCString("ztp");

  Hint("ztp");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1988");
  __CrestLoadCString("BN_hex2bn");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("BN_hex2bn", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1989");
  __CrestLoadCString("bignum");

  Hint("bignum");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1990");
  __CrestLoadCString("bitstring");

  test_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1992");
  __CrestLoadStackPtr("openssl_proxies.c:dummy[23189]");
  __CrestLoadInt((long long )24);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)(& dummy), "val");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1994");
  __CrestLoadStackPtr("openssl_proxies.c:dummy[23189]");
  __CrestLoadInt((long long )24);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("");

  load_ctx((void const *)(& dummy), "val", "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1996");
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  len((_Bool)1, sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1997");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:1998");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23192]");
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

  store_buf((unsigned char const *)((void *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2000");
  __CrestLoadStackPtr("openssl_proxies.c:a[23187]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )a != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    {
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2002");
    __CrestLoadStackPtr("openssl_proxies.c:create_new[23190]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestTruth();

    if (create_new) {
      __CrestBranch(1);
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2004");
      __CrestLoadStackPtr("openssl_proxies.c:a[23187]");
      __CrestApply("ptrLen/0");
      __CrestSetPtrStep();
      __CrestLoadMem();
      __CrestApply("ptrLen/0");
      __CrestSetPtrStep();
      __CrestLoadMem();
      __CrestLoadStackPtr("openssl_proxies.c:mem_8[23492]");
      __CrestApply("ptrLen/0");
      __CrestSetPtrStep();
      __CrestStore();

      mem_8 = *a;
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2004");
      __CrestLoadInt((long long )24);
      __CrestBS(0, 8);

      fresh_ptr(sizeof(*mem_8));
      __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2005");
      __CrestLoadStackPtr("openssl_proxies.c:a[23187]");
      __CrestApply("ptrLen/0");
      __CrestSetPtrStep();
      __CrestLoadMem();
      __CrestApply("(CastToPtr: ptr -> ptr)");
      __CrestLoadInt((long long )1);
      __CrestSetPtrStep();
      __CrestDone();
      __CrestApply("(CastToPtr: ptr -> ptr)");
      __CrestLoadInt((long long )1);
      __CrestSetPtrStep();
      __CrestDone();

      store_buf((unsigned char const *)((unsigned char *)a));
    } else {
      __CrestBranch(0);
    }
    }
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2009");
    __CrestLoadStackPtr("openssl_proxies.c:dummy[23189]");
    __CrestLoadInt((long long )24);
    __CrestSetPtrStep();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("val");
    __CrestLoadCString("bignum");

    load_ctx((void const *)(& dummy), "val", "bignum");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2010");
    __CrestLoadStackPtr("openssl_proxies.c:a[23187]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("val");

    store_ctx((void const *)*a, "val");
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2013");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23192]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern char *BN_bn2hex_proxy(BIGNUM const *a )
{
  char *ret ;
  char *tmp ;

  {
  __CrestCall("BN_bn2hex_proxy", (void (*)())(& BN_bn2hex_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[23197]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2026");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2027");
  __CrestLoadStackPtr("openssl_proxies.c:a[23197]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_bn2hex_opaque(a);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23199]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2027");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23199]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23198]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2028");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23198]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(==: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )ret == (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2029");
    __CrestLoadCString("BN_bn2hex failed");
    __CrestMute();

    proxy_fail("BN_bn2hex failed");
    __CrestUnmute();
    __CrestClear(1);
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2030");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2032");
  __CrestLoadStackPtr("openssl_proxies.c:a[23197]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("");

  load_ctx((void const *)a, "val", "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2034");
  __CrestLoadCString("BN_bn2hex");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("BN_bn2hex", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2035");
  __CrestLoadCString("hex");

  Hint("hex");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2036");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2039");
  __CrestApply("ptrLen/0");
  __CrestBS(0, 8);

  fresh_ptr(sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2040");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23198]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2041");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23198]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_all((unsigned char const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2043");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23198]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int BN_set_word_proxy(BIGNUM *a , unsigned long w )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("BN_set_word_proxy", (void (*)())(& BN_set_word_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:w[23204]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23203]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2052");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2053");
  __CrestLoadStackPtr("openssl_proxies.c:a[23203]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:w[23204]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_set_word_opaque(a, w);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23206]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2053");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23206]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23205]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2054");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2056");
  __CrestLoadCString("BN_set_word_result");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("BN_set_word_result", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2057");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2058");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23208]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2059");
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23208]");
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

  assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2060");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23205]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2062");
  __CrestLoadStackPtr("openssl_proxies.c:w[23204]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);
  __CrestLoadCString("wordval");

  load_buf((unsigned char const *)((unsigned char *)(& w)), sizeof(w), "wordval");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2063");
  __CrestLoadStackPtr("openssl_proxies.c:a[23203]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)a, "val");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2065");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23205]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int BN_mod_exp2_mont_proxy(BIGNUM *rr , BIGNUM const *a1 , BIGNUM const *p1 ,
                           BIGNUM const *a2 , BIGNUM const *p2 , BIGNUM const *m ,
                           BN_CTX *ctx , BN_MONT_CTX *in_mont )
{
  int ret ;
  int tmp ;
  size_t ret_len ;
  int m_len ;
  int tmp___0 ;

  {
  __CrestCall("BN_mod_exp2_mont_proxy", (void (*)())(& BN_mod_exp2_mont_proxy), 8);
  __CrestLoadStackPtr("openssl_proxies.c:in_mont[23225]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23224]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:m[23223]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:p2[23222]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a2[23221]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:p1[23220]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a1[23219]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:rr[23218]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2077");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2078");
  __CrestLoadStackPtr("openssl_proxies.c:rr[23218]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:a1[23219]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:p1[23220]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:a2[23221]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:p2[23222]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m[23223]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23224]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in_mont[23225]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_mod_exp2_mont_opaque(rr, a1, p1, a2, p2, m, ctx, in_mont);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23227]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2078");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23227]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23226]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2079");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2081");
  __CrestLoadCString("BN_mod_exp2_mont_result");
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN("BN_mod_exp2_mont_result", 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2082");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2083");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:ret_len[23228]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret_len = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2084");
  __CrestLoadStackPtr("openssl_proxies.c:ret_len[23228]");
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
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2085");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23226]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2087");
  __CrestLoadStackPtr("openssl_proxies.c:m[23223]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp___0 = BN_num_bytes_proxy(m);
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[23231]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2087");
  __CrestLoadStackPtr("openssl_proxies.c:tmp___0[23231]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m_len[23229]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  m_len = tmp___0;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2089");
  __CrestLoadStackPtr("openssl_proxies.c:a1[23219]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("a1");

  load_ctx((void const *)a1, "val", "a1");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2090");
  __CrestLoadStackPtr("openssl_proxies.c:p1[23220]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("p1");

  load_ctx((void const *)p1, "val", "p1");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2091");
  __CrestLoadStackPtr("openssl_proxies.c:a2[23221]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("a1");

  load_ctx((void const *)a2, "val", "a1");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2092");
  __CrestLoadStackPtr("openssl_proxies.c:p2[23222]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("p1");

  load_ctx((void const *)p2, "val", "p1");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2093");
  __CrestLoadStackPtr("openssl_proxies.c:m[23223]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("bignum");

  load_ctx((void const *)m, "val", "bignum");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2095");
  __CrestLoadCString("mod_exp2");
  __CrestLoadInt((long long )5);
  __CrestBS(1, 4);

  SymN("mod_exp2", 5);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2098");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2100");
  __CrestLoadStackPtr("openssl_proxies.c:m_len[23229]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len_at_most((unsigned char const *)(& m_len), (_Bool)1, sizeof(m_len));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2101");
  __CrestLoadCString("rr");

  Hint("rr");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2103");
  __CrestLoadStackPtr("openssl_proxies.c:rr[23218]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)rr, "val");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2105");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23226]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int BN_mod_exp_mont_proxy(BIGNUM *rr , BIGNUM const *a , BIGNUM const *p , BIGNUM const *m ,
                          BN_CTX *ctx , BN_MONT_CTX *in_mont )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("BN_mod_exp_mont_proxy", (void (*)())(& BN_mod_exp_mont_proxy), 6);
  __CrestLoadStackPtr("openssl_proxies.c:in_mont[23244]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23243]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:m[23242]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:p[23241]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23240]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:rr[23239]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2115");
  __CrestLoadStackPtr("openssl_proxies.c:rr[23239]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:a[23240]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:p[23241]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m[23242]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ctx[23243]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:in_mont[23244]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_mod_exp_mont_opaque(rr, a, p, m, ctx, in_mont);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23246]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2115");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23246]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23245]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2117");
  __CrestLoadStackPtr("openssl_proxies.c:a[23240]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("a");

  load_ctx((void const *)a, "val", "a");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2118");
  __CrestLoadStackPtr("openssl_proxies.c:p[23241]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("p");

  load_ctx((void const *)p, "val", "p");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2119");
  __CrestLoadStackPtr("openssl_proxies.c:m[23242]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");
  __CrestLoadCString("bignum");

  load_ctx((void const *)m, "val", "bignum");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2121");
  __CrestLoadCString("mod_exp");
  __CrestLoadInt((long long )3);
  __CrestBS(1, 4);

  SymN("mod_exp", 3);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2124");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2125");
  __CrestLoadCString("rr");

  Hint("rr");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2127");
  __CrestLoadStackPtr("openssl_proxies.c:rr[23239]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("val");

  store_ctx((void const *)rr, "val");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2129");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23245]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void BN_CTX_init_proxy(BN_CTX *c )
{


  {
  __CrestCall("BN_CTX_init_proxy", (void (*)())(& BN_CTX_init_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:c[23249]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2134");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2135");
  __CrestLoadStackPtr("openssl_proxies.c:c[23249]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_BN_CTX_init_opaque(c);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2136");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2132");
  __CrestReturn(1);

  return;
  }
}
}

int BN_print_fp_proxy(FILE *fp , BIGNUM const *a )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("BN_print_fp_proxy", (void (*)())(& BN_print_fp_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:a[23254]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:fp[23253]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2141");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2142");
  __CrestLoadStackPtr("openssl_proxies.c:fp[23253]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:a[23254]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_BN_print_fp_opaque(fp, a);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23256]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2142");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23256]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23255]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2143");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2145");
  __CrestLoadCString("BN_print_fp_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("BN_print_fp_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2146");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23255]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2148");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23255]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void DSA_free_proxy(DSA *r )
{


  {
  __CrestCall("DSA_free_proxy", (void (*)())(& DSA_free_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:r[23259]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2153");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2154");
  __CrestLoadStackPtr("openssl_proxies.c:r[23259]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_DSA_free_opaque(r);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2155");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2151");
  __CrestReturn(1);

  return;
  }
}
}

DSA_SIG *DSA_SIG_new_proxy(void)
{
  DSA_SIG *ret ;
  DSA_SIG *tmp ;

  {
  __CrestCall("DSA_SIG_new_proxy", (void (*)())(& DSA_SIG_new_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2161");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2162");

  tmp = __crest_DSA_SIG_new_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23263]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2162");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23263]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23262]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2163");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2165");
  __CrestApply("ptrLen/0");
  __CrestBS(0, 8);

  fresh_ptr(sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2166");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23262]");
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

  store_buf((unsigned char const *)((unsigned char *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2168");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23262]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void DSA_SIG_free_proxy(DSA_SIG *a )
{


  {
  __CrestCall("DSA_SIG_free_proxy", (void (*)())(& DSA_SIG_free_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[23266]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2173");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2174");
  __CrestLoadStackPtr("openssl_proxies.c:a[23266]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_DSA_SIG_free_opaque(a);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2175");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2171");
  __CrestReturn(1);

  return;
  }
}
}

int DSA_generate_key_proxy(DSA *a )
{
  int tmp ;

  {
  __CrestCall("DSA_generate_key_proxy", (void (*)())(& DSA_generate_key_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:a[23269]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2191");
  __CrestLoadCString("DSA_keyseed");
  __CrestLoadCString("keyseed");

  newT("DSA_keyseed", "keyseed");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2192");
  __CrestLoadStackPtr("openssl_proxies.c:a[23269]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("keyseed");

  store_ctx((void const *)a, "keyseed");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2194");
  __CrestLoadStackPtr("openssl_proxies.c:a[23269]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("keyseed");
  __CrestLoadCString("keyseed");

  load_ctx((void const *)a, "keyseed", "keyseed");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2195");
  __CrestLoadCString("DSA_sk");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("DSA_sk", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2196");
  __CrestLoadCString("skey");

  Hint("skey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2197");
  __CrestLoadStackPtr("openssl_proxies.c:a[23269]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("skey");

  store_ctx((void const *)a, "skey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2199");
  __CrestLoadStackPtr("openssl_proxies.c:a[23269]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("keyseed");
  __CrestLoadCString("keyseed");

  load_ctx((void const *)a, "keyseed", "keyseed");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2200");
  __CrestLoadCString("DSA_pk");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("DSA_pk", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2201");
  __CrestLoadCString("pkey");

  Hint("pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2202");
  __CrestLoadStackPtr("openssl_proxies.c:a[23269]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pkey");

  store_ctx((void const *)a, "pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2204");
  __CrestLoadStackPtr("openssl_proxies.c:a[23269]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_DSA_generate_key_opaque(a);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23270]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2204");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23270]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

DSA *DSA_new_proxy(void)
{
  DSA *ret ;
  DSA *tmp ;

  {
  __CrestCall("DSA_new_proxy", (void (*)())(& DSA_new_proxy), 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2209");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2210");

  tmp = __crest_DSA_new_opaque();
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23274]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2210");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23274]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23273]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2211");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2213");
  __CrestApply("ptrLen/0");
  __CrestBS(0, 8);

  fresh_ptr(sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2214");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23273]");
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

  store_buf((unsigned char const *)((unsigned char *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2216");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23273]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

DSA *DSA_new_method_proxy(ENGINE *engine )
{
  DSA *ret ;
  DSA *tmp ;

  {
  __CrestCall("DSA_new_method_proxy", (void (*)())(& DSA_new_method_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:engine[23277]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2231");

  DSA_get_default_method();
  __CrestClear(1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2233");
  __CrestLoadStackPtr("openssl_proxies.c:engine[23277]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_DSA_new_method_opaque(engine);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23279]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2233");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23279]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23278]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2234");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23278]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int i2d_DSA_PUBKEY_proxy(DSA *a , unsigned char **pp )
{
  unsigned char *old_pp ;
  int ret ;
  int tmp ;
  unsigned char *new_pp ;
  void *p ;

  {
  __CrestCall("i2d_DSA_PUBKEY_proxy", (void (*)())(& i2d_DSA_PUBKEY_proxy), 2);
  __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23283]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2252");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2253");
  __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:old_pp[23285]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  old_pp = *pp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2254");
  __CrestLoadStackPtr("openssl_proxies.c:a[23283]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_i2d_DSA_PUBKEY_opaque(a, pp);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23287]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2254");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23287]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23286]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2255");
  __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:new_pp[23288]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  new_pp = *pp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2256");
  __CrestLoadStackPtr("openssl_proxies.c:old_pp[23285]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  *pp = old_pp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2257");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2259");
  __CrestLoadStackPtr("openssl_proxies.c:a[23283]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pkey");
  __CrestLoadCString("dsa_pkey");

  load_ctx((void const *)a, "pkey", "dsa_pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2260");
  __CrestLoadCString("i2d_DSA_PUBKEY");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("i2d_DSA_PUBKEY", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2261");
  __CrestLoadCString("DER");

  Hint("DER");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2262");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23286]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);

  store_len((unsigned char const *)(& ret), sizeof(ret), (_Bool)1);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2266");
  __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(==: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )*pp == (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2268");
    __CrestLoadStackPtr("openssl_proxies.c:ret[23286]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,4] -> [u,8])");
    __CrestDone();

    fresh_ptr((size_t )ret);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2269");
    __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();

    store_buf((unsigned char const *)pp);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2270");
    __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadStackPtr("openssl_proxies.c:p[23289]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestStore();

    p = (void *)*pp;
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2273");
    __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadStackPtr("openssl_proxies.c:p[23289]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestStore();

    p = (void *)*pp;
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2274");
    __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:ret[23286]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [s,4] -> [u,8])");
    __CrestDone();
    __CrestApply("(PlusPI: ptr * [u,8] -> ptr)");
    __CrestDone();
    __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestStore();

    *pp += ret;
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2278");
  __CrestLoadStackPtr("openssl_proxies.c:p[23289]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)p);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2280");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2281");
  __CrestLoadStackPtr("openssl_proxies.c:new_pp[23288]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pp[23284]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  *pp = new_pp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2282");

  unmute();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2284");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23286]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

DSA *d2i_DSA_PUBKEY_proxy(DSA **a , unsigned char const **pp , long length )
{
  unsigned char *p ;
  DSA *ret ;
  DSA *tmp ;

  {
  __CrestCall("d2i_DSA_PUBKEY_proxy", (void (*)())(& d2i_DSA_PUBKEY_proxy), 3);
  __CrestLoadStackPtr("openssl_proxies.c:length[23296]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:pp[23295]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:a[23294]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2297");
  __CrestLoadStackPtr("openssl_proxies.c:pp[23295]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:p[23297]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  p = (unsigned char *)*pp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2299");
  __CrestLoadStackPtr("openssl_proxies.c:a[23294]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:pp[23295]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:length[23296]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_d2i_DSA_PUBKEY_opaque(a, pp, length);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23299]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2299");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23299]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23298]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2301");
  __CrestLoadStackPtr("openssl_proxies.c:a[23294]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestApply("(CastToInt: ptr -> [u,8])");
  __CrestDone();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((unsigned long )*a != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2302");
    __CrestLoadStackPtr("openssl_proxies.c:a[23294]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:ret[23298]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestStore();

    ret = *a;
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2305");
    __CrestApply("ptrLen/0");
    __CrestBS(0, 8);

    fresh_ptr(sizeof(ret));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2306");
    __CrestLoadStackPtr("openssl_proxies.c:ret[23298]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();

    store_buf((unsigned char const *)ret);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2308");
    __CrestLoadStackPtr("openssl_proxies.c:ret[23298]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:a[23294]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestStore();

    *a = ret;
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2311");
  __CrestLoadStackPtr("openssl_proxies.c:pp[23295]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:length[23296]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,8] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("DER");

  load_buf(*pp, (size_t )length, "DER");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2313");
  __CrestLoadCString("d2i_DSA_PUBKEY");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("d2i_DSA_PUBKEY", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2314");
  __CrestLoadCString("dsa_pubkey");

  Hint("dsa_pubkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2315");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2317");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23298]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("pkey");

  store_ctx((void const *)ret, "pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2319");
  __CrestLoadStackPtr("openssl_proxies.c:p[23297]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:length[23296]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,8] -> [u,8])");
  __CrestDone();
  __CrestApply("(PlusPI: ptr * [u,8] -> ptr)");
  __CrestDone();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:pp[23295]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  *pp = (unsigned char const *)(p + length);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2321");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23298]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

unsigned long lh_strhash_proxy(char const *c )
{
  unsigned long ret ;
  unsigned long tmp ;
  size_t len___0 ;

  {
  __CrestCall("lh_strhash_proxy", (void (*)())(& lh_strhash_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:c[23302]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2340");
  __CrestLoadStackPtr("openssl_proxies.c:c[23302]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = lh_strhash(c);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23304]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2340");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23304]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23303]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2342");
  __CrestLoadStackPtr("openssl_proxies.c:c[23302]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("str");

  load_all((unsigned char const *)c, "str");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2344");
  __CrestLoadCString("lh_strhash");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("lh_strhash", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2345");
  __CrestLoadCString("strhash");

  Hint("strhash");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2346");
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23306]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2347");
  __CrestLoadStackPtr("openssl_proxies.c:len___0[23306]");
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

  assume_len((unsigned char const *)(& len___0), (_Bool)0, sizeof(len___0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2349");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23303]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)((void *)(& ret)));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2351");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23303]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern void DES_ecb3_encrypt_proxy(const_DES_cblock *input___0 , DES_cblock *output___0 ,
                                   DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                   DES_key_schedule *ks3 , int enc )
{


  {
  __CrestCall("DES_ecb3_encrypt_proxy", (void (*)())(& DES_ecb3_encrypt_proxy), 6);
  __CrestLoadStackPtr("openssl_proxies.c:enc[23321]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ks3[23320]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ks2[23319]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ks1[23318]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:output___0[23317]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:input___0[23315]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2364");
  __CrestLoadStackPtr("openssl_proxies.c:input___0[23315]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:output___0[23317]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ks1[23318]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ks2[23319]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ks3[23320]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:enc[23321]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_DES_ecb3_encrypt_opaque(input___0, output___0, ks1, ks2, ks3, enc);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2359");
  __CrestReturn(1);

  return;
  }
}
}

extern void DES_ncbc_encrypt_proxy(unsigned char const *input___0 , unsigned char *output___0 ,
                                   long length , DES_key_schedule *schedule , DES_cblock *ivec ,
                                   int enc )
{


  {
  __CrestCall("DES_ncbc_encrypt_proxy", (void (*)())(& DES_ncbc_encrypt_proxy), 6);
  __CrestLoadStackPtr("openssl_proxies.c:enc[23336]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ivec[23335]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:schedule[23334]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:length[23333]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:output___0[23332]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:input___0[23330]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2372");
  __CrestLoadStackPtr("openssl_proxies.c:input___0[23330]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:output___0[23332]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:length[23333]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:schedule[23334]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ivec[23335]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:enc[23336]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_DES_ncbc_encrypt_opaque(input___0, output___0, length, schedule, ivec, enc);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2367");
  __CrestReturn(1);

  return;
  }
}
}

extern void DES_ecb_encrypt_proxy(const_DES_cblock *input___0 , DES_cblock *output___0 ,
                                  DES_key_schedule *ks , int enc )
{


  {
  __CrestCall("DES_ecb_encrypt_proxy", (void (*)())(& DES_ecb_encrypt_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies.c:enc[23347]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ks[23346]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:output___0[23345]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:input___0[23343]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2379");
  __CrestLoadStackPtr("openssl_proxies.c:input___0[23343]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:output___0[23345]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ks[23346]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:enc[23347]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_DES_ecb_encrypt_opaque(input___0, output___0, ks, enc);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2375");
  __CrestReturn(1);

  return;
  }
}
}

extern void DES_ede3_cbc_encrypt_proxy(unsigned char const *input___0 , unsigned char *output___0 ,
                                       long length , DES_key_schedule *ks1 , DES_key_schedule *ks2 ,
                                       DES_key_schedule *ks3 , DES_cblock *ivec ,
                                       int enc )
{


  {
  __CrestCall("DES_ede3_cbc_encrypt_proxy", (void (*)())(& DES_ede3_cbc_encrypt_proxy),
              8);
  __CrestLoadStackPtr("openssl_proxies.c:enc[23366]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ivec[23365]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ks3[23364]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ks2[23363]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ks1[23362]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:length[23361]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:output___0[23360]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:input___0[23358]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2388");
  __CrestLoadStackPtr("openssl_proxies.c:input___0[23358]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:output___0[23360]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:length[23361]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ks1[23362]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ks2[23363]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ks3[23364]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ivec[23365]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:enc[23366]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_DES_ede3_cbc_encrypt_opaque(input___0, output___0, length, ks1, ks2, ks3,
                                      ivec, enc);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2382");
  __CrestReturn(1);

  return;
  }
}
}

extern void DES_set_key_unchecked_proxy(const_DES_cblock *key , DES_key_schedule *schedule )
{


  {
  __CrestCall("DES_set_key_unchecked_proxy", (void (*)())(& DES_set_key_unchecked_proxy),
              2);
  __CrestLoadStackPtr("openssl_proxies.c:schedule[23371]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key[23370]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2394");
  __CrestLoadStackPtr("openssl_proxies.c:key[23370]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:schedule[23371]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_DES_set_key_unchecked_opaque(key, schedule);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2391");
  __CrestReturn(1);

  return;
  }
}
}

extern int AES_set_encrypt_key_proxy(unsigned char const *userKey , int bits , AES_KEY *key )
{
  int tmp ;

  {
  __CrestCall("AES_set_encrypt_key_proxy", (void (*)())(& AES_set_encrypt_key_proxy),
              3);
  __CrestLoadStackPtr("openssl_proxies.c:key[23378]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bits[23377]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:userKey[23376]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2405");
  __CrestLoadStackPtr("openssl_proxies.c:userKey[23376]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:bits[23377]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [s,4])");
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:key[23378]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_AES_set_encrypt_key_opaque(userKey, (int const )bits, key);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23379]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2405");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23379]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern int AES_set_decrypt_key_proxy(unsigned char const *userKey , int bits , AES_KEY *key )
{
  int tmp ;

  {
  __CrestCall("AES_set_decrypt_key_proxy", (void (*)())(& AES_set_decrypt_key_proxy),
              3);
  __CrestLoadStackPtr("openssl_proxies.c:key[23386]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bits[23385]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:userKey[23384]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2411");
  __CrestLoadStackPtr("openssl_proxies.c:userKey[23384]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:bits[23385]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [s,4])");
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:key[23386]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_AES_set_decrypt_key_opaque(userKey, (int const )bits, key);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23387]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2411");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23387]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern void AES_ecb_encrypt_proxy(unsigned char const *in , unsigned char *out ,
                                  AES_KEY const *key , int enc )
{


  {
  __CrestCall("AES_ecb_encrypt_proxy", (void (*)())(& AES_ecb_encrypt_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies.c:enc[23396]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key[23395]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[23394]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[23393]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2418");
  __CrestLoadStackPtr("openssl_proxies.c:in[23393]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[23394]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key[23395]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:enc[23396]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [s,4])");
  __CrestDone();

  __crest_AES_ecb_encrypt_opaque(in, out, key, (int const )enc);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2414");
  __CrestReturn(1);

  return;
  }
}
}

extern void AES_cbc_encrypt_proxy(unsigned char const *in , unsigned char *out ,
                                  size_t length , AES_KEY const *key , unsigned char *ivec ,
                                  int enc )
{


  {
  __CrestCall("AES_cbc_encrypt_proxy", (void (*)())(& AES_cbc_encrypt_proxy), 6);
  __CrestLoadStackPtr("openssl_proxies.c:enc[23409]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:ivec[23408]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:key[23407]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:length[23406]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:out[23405]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:in[23404]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2426");
  __CrestLoadStackPtr("openssl_proxies.c:in[23404]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:out[23405]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:length[23406]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:key[23407]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ivec[23408]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:enc[23409]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [s,4])");
  __CrestDone();

  __crest_AES_cbc_encrypt_opaque(in, out, length, key, ivec, (int const )enc);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2421");
  __CrestReturn(1);

  return;
  }
}
}

RSA *RSA_generate_key_proxy(int bits , unsigned long e , void (*callback)(int , int ,
                                                                          void * ) ,
                            void *cb_arg )
{
  RSA *tmp ;

  {
  __CrestCall("RSA_generate_key_proxy", (void (*)())(& RSA_generate_key_proxy), 4);
  __CrestLoadStackPtr("openssl_proxies.c:cb_arg[23421]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:callback[23420]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:e[23419]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:bits[23418]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2442");
  __CrestLoadStackPtr("openssl_proxies.c:bits[23418]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:e[23419]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:callback[23420]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:cb_arg[23421]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_RSA_generate_key_opaque(bits, e, callback, cb_arg);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23422]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2442");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23422]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern RSA *RSAPrivateKey_dup_proxy(RSA *rsa )
{
  RSA *ret ;
  RSA *tmp ;

  {
  __CrestCall("RSAPrivateKey_dup_proxy", (void (*)())(& RSAPrivateKey_dup_proxy),
              1);
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23425]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2448");
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23425]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_RSAPrivateKey_dup_opaque(rsa);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23427]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2448");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23427]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23426]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2450");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23426]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23425]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  copy_ctx((void const *)ret, (void const *)rsa);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2452");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23426]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int RSA_verify_proxy(int type , unsigned char const *m , unsigned int m_length ,
                            unsigned char const *sigbuf , unsigned int siglen ,
                            RSA *rsa )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("RSA_verify_proxy", (void (*)())(& RSA_verify_proxy), 6);
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23440]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[23439]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:sigbuf[23438]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:m_length[23437]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:m[23436]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:type[23435]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2470");
  __CrestLoadStackPtr("openssl_proxies.c:type[23435]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m[23436]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m_length[23437]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:sigbuf[23438]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[23439]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23440]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_RSA_verify_opaque(type, m, m_length, sigbuf, siglen, rsa);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23442]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2470");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23442]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23441]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2473");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23441]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);
  __CrestApply("(==: [s,4] * [s,4] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if (ret == 1) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2475");
    __CrestLoadStackPtr("openssl_proxies.c:m[23436]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("openssl_proxies.c:m_length[23437]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToInt: [u,4] -> [u,8])");
    __CrestDone();
    __CrestLoadCString("msg");

    load_buf(m, (size_t )m_length, "msg");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2476");
    __CrestLoadStackPtr("openssl_proxies.c:rsa[23440]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadCString("id");
    __CrestLoadCString("pkey");

    load_ctx((void const *)rsa, "id", "pkey");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2478");
    __CrestLoadCString("RSA_verify");
    __CrestLoadInt((long long )2);
    __CrestBS(1, 4);

    SymN("RSA_verify", 2);
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2479");
    __CrestLoadCString("sig");

    Hint("sig");
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2480");
    __CrestLoadStackPtr("openssl_proxies.c:siglen[23439]");
    __CrestLoadInt((long long )4);
    __CrestSetPtrStep();
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestLoadInt((long long )(_Bool)0);
    __CrestBS(0, 1);
    __CrestLoadInt((long long )4);
    __CrestBS(0, 8);

    assume_len((unsigned char const *)(& siglen), (_Bool)0, sizeof(siglen));
    __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2482");
    __CrestLoadStackPtr("openssl_proxies.c:sigbuf[23438]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    store_buf(sigbuf);
  } else {
    __CrestBranch(0);
  }
  }
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2485");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23441]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int RSA_public_encrypt_proxy(int flen , unsigned char const *from , unsigned char *to ,
                                    RSA *rsa , int padding )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("RSA_public_encrypt_proxy", (void (*)())(& RSA_public_encrypt_proxy),
              5);
  __CrestLoadStackPtr("openssl_proxies.c:padding[23453]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23452]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:to[23451]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:from[23450]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:flen[23449]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2499");
  __CrestLoadStackPtr("openssl_proxies.c:flen[23449]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:from[23450]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:to[23451]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23452]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:padding[23453]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_RSA_public_encrypt_opaque(flen, from, to, rsa, padding);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23455]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2499");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23455]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23454]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2501");
  __CrestLoadStackPtr("openssl_proxies.c:from[23450]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:flen[23449]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("plain");

  load_buf(from, (size_t )flen, "plain");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2502");
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23452]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");
  __CrestLoadCString("pkey");

  load_ctx((void const *)rsa, "id", "pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2504");
  __CrestLoadCString("RSA_public_encrypt");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("RSA_public_encrypt", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2505");
  __CrestLoadCString("enc");

  Hint("enc");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2506");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23454]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)(& ret), (_Bool)1, sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2507");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2509");
  __CrestLoadStackPtr("openssl_proxies.c:to[23451]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)to);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2511");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23454]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int RSA_private_decrypt_proxy(int flen , unsigned char const *from , unsigned char *to ,
                                     RSA *rsa , int padding )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("RSA_private_decrypt_proxy", (void (*)())(& RSA_private_decrypt_proxy),
              5);
  __CrestLoadStackPtr("openssl_proxies.c:padding[23466]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23465]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:to[23464]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:from[23463]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:flen[23462]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2526");
  __CrestLoadStackPtr("openssl_proxies.c:from[23463]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:flen[23462]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,4] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("enc");

  load_buf(from, (size_t )flen, "enc");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2527");
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23465]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");
  __CrestLoadCString("pkey");

  load_ctx((void const *)rsa, "id", "pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2529");
  __CrestLoadStackPtr("openssl_proxies.c:flen[23462]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:from[23463]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:to[23464]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23465]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:padding[23466]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_RSA_private_decrypt_opaque(flen, from, to, rsa, padding);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23468]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2529");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23468]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23467]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2532");
  __CrestLoadCString("RSA_private_decrypt");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("RSA_private_decrypt", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2533");
  __CrestLoadCString("dec");

  Hint("dec");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2534");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23467]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)(& ret), (_Bool)1, sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2536");
  __CrestLoadStackPtr("openssl_proxies.c:to[23464]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)to);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2538");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23467]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern int RSA_sign_proxy(int type , unsigned char const *m , unsigned int m_length ,
                          unsigned char *sigret , unsigned int *siglen , RSA *rsa )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("RSA_sign_proxy", (void (*)())(& RSA_sign_proxy), 6);
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23481]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[23480]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:sigret[23479]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:m_length[23478]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:m[23477]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("openssl_proxies.c:type[23476]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2554");
  __CrestLoadStackPtr("openssl_proxies.c:type[23476]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m[23477]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m_length[23478]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:sigret[23479]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:siglen[23480]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23481]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_RSA_sign_opaque(type, m, m_length, sigret, siglen, rsa);
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23483]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2554");
  __CrestLoadStackPtr("openssl_proxies.c:tmp[23483]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:ret[23482]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2556");
  __CrestLoadStackPtr("openssl_proxies.c:m[23477]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("openssl_proxies.c:m_length[23478]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,4] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("msg");

  load_buf(m, (size_t )m_length, "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2557");
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23481]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("id");
  __CrestLoadCString("pkey");

  load_ctx((void const *)rsa, "id", "pkey");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2559");
  __CrestLoadCString("RSA_sign");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("RSA_sign", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2560");
  __CrestLoadCString("sig");

  Hint("sig");
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2561");
  __CrestLoadStackPtr("openssl_proxies.c:siglen[23480]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  assume_len((unsigned char const *)siglen, (_Bool)0, sizeof(*siglen));
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2562");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2564");
  __CrestLoadStackPtr("openssl_proxies.c:sigret[23479]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)sigret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2566");
  __CrestLoadStackPtr("openssl_proxies.c:ret[23482]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern void RSA_blinding_off_proxy(RSA *rsa )
{


  {
  __CrestCall("RSA_blinding_off_proxy", (void (*)())(& RSA_blinding_off_proxy), 1);
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23486]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2572");
  __CrestLoadStackPtr("openssl_proxies.c:rsa[23486]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_RSA_blinding_off_opaque(rsa);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2569");
  __CrestReturn(1);

  return;
  }
}
}

void ERR_load_crypto_strings_proxy(void)
{


  {
  __CrestCall("ERR_load_crypto_strings_proxy", & ERR_load_crypto_strings_proxy, 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2577");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2578");

  __crest_ERR_load_crypto_strings_opaque();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2579");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2575");
  __CrestReturn(1);

  return;
  }
}
}

void ERR_print_errors_fp_proxy(FILE *fp )
{


  {
  __CrestCall("ERR_print_errors_fp_proxy", (void (*)())(& ERR_print_errors_fp_proxy),
              1);
  __CrestLoadStackPtr("openssl_proxies.c:fp[23491]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2584");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2585");
  __CrestLoadStackPtr("openssl_proxies.c:fp[23491]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_ERR_print_errors_fp_opaque(fp);
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2586");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/openssl_proxies.c:2582");
  __CrestReturn(1);

  return;
  }
}
}
