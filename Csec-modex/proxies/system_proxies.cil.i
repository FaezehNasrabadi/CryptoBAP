# 1 "./system_proxies.cil.c"
# 1 "/home/faezeh/csec-modex/proxies//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "./system_proxies.cil.c"



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

typedef long __ssize_t;

typedef unsigned int __socklen_t;

typedef __ssize_t ssize_t;

typedef __socklen_t socklen_t;

typedef unsigned short uint16_t;

typedef unsigned int uint32_t;

typedef unsigned short sa_family_t;

struct sockaddr {
   sa_family_t sa_family ;
   char sa_data[14] ;
};

typedef uint32_t in_addr_t;

extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1), __leaf__)) atoi)(char const *__nptr ) __attribute__((__pure__)) ;
static __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1), __leaf__)) __crest_atoi_opaque)(char const *__nptr ) __attribute__((__pure__)) ;
static int ( __attribute__((__nonnull__(1), __leaf__)) __crest_atoi_opaque)(char const *__nptr )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("atoi", (void (*)())(& atoi), 1);
  __CrestApply("(atoi() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = atoi(__nptr);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) void *( __attribute__((__leaf__)) malloc)(size_t __size ) __attribute__((__malloc__)) ;
static __attribute__((__nothrow__)) void *( __attribute__((__leaf__)) __crest_malloc_opaque)(size_t __size ) __attribute__((__malloc__)) ;
static void *( __attribute__((__leaf__)) __crest_malloc_opaque)(size_t __size )
{
  void *__crest_ret ;

  {
  __CrestCallOpaque("malloc", (void (*)())(& malloc), 1);
  __CrestClear(1);
  __CrestLoadStackPtr("malloc()");
  __CrestNondet();
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = malloc(__size);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) void *( __attribute__((__warn_unused_result__,
__leaf__)) realloc)(void *__ptr , size_t __size ) ;
static __attribute__((__nothrow__)) void *( __attribute__((__warn_unused_result__,
__leaf__)) __crest_realloc_opaque)(void *__ptr , size_t __size ) ;
static void *( __attribute__((__warn_unused_result__, __leaf__)) __crest_realloc_opaque)(void *__ptr ,
                                                                                         size_t __size )
{
  void *__crest_ret ;

  {
  __CrestCallOpaque("realloc", (void (*)())(& realloc), 2);
  __CrestClear(2);
  __CrestLoadStackPtr("realloc()");
  __CrestNondet();
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = realloc(__ptr, __size);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__, __noreturn__)) void ( __attribute__((__leaf__)) exit)(int __status ) ;
static __attribute__((__nothrow__, __noreturn__)) void ( __attribute__((__leaf__)) __crest_exit_opaque)(int __status ) ;
static void ( __attribute__((__leaf__)) __crest_exit_opaque)(int __status )
{


  {
  __CrestCallOpaque("exit", (void (*)())(& exit), 1);
  __CrestClear(1);
  __CrestMute();
  exit(__status);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern void SymN(char const *sym , int n ) ;

extern void Done() ;

extern void Append() ;

extern void StoreBuf(unsigned char const *buf ) ;

extern void Malloc(size_t buflen ) ;

extern __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1,2), __leaf__)) memcpy)(void * __restrict __dest ,
                                                                                                 void const * __restrict __src ,
                                                                                                 size_t __n ) ;
static __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1,2), __leaf__)) __crest_memcpy_opaque)(void * __restrict __dest ,
                                                                                                                void const * __restrict __src ,
                                                                                                                size_t __n ) ;
static void *( __attribute__((__nonnull__(1,2), __leaf__)) __crest_memcpy_opaque)(void * __restrict __dest ,
                                                                                  void const * __restrict __src ,
                                                                                  size_t __n )
{
  void *__crest_ret ;

  {
  __CrestCallOpaque("memcpy", (void (*)())(& memcpy), 3);
  __CrestClear(3);
  __CrestLoadStackPtr("memcpy()");
  __CrestNondet();
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = memcpy(__dest, __src, __n);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1,2), __leaf__)) memmove)(void *__dest ,
                                                                                                  void const *__src ,
                                                                                                  size_t __n ) ;
static __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1,2), __leaf__)) __crest_memmove_opaque)(void *__dest ,
                                                                                                                 void const *__src ,
                                                                                                                 size_t __n ) ;
static void *( __attribute__((__nonnull__(1,2), __leaf__)) __crest_memmove_opaque)(void *__dest ,
                                                                                   void const *__src ,
                                                                                   size_t __n )
{
  void *__crest_ret ;

  {
  __CrestCallOpaque("memmove", (void (*)())(& memmove), 3);
  __CrestClear(3);
  __CrestLoadStackPtr("memmove()");
  __CrestNondet();
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = memmove(__dest, __src, __n);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1), __leaf__)) memset)(void *__s ,
                                                                                               int __c ,
                                                                                               size_t __n ) ;
static __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1), __leaf__)) __crest_memset_opaque)(void *__s ,
                                                                                                              int __c ,
                                                                                                              size_t __n ) ;
static void *( __attribute__((__nonnull__(1), __leaf__)) __crest_memset_opaque)(void *__s ,
                                                                                int __c ,
                                                                                size_t __n )
{
  void *__crest_ret ;

  {
  __CrestCallOpaque("memset", (void (*)())(& memset), 3);
  __CrestClear(3);
  __CrestLoadStackPtr("memset()");
  __CrestNondet();
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = memset(__s, __c, __n);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) memcmp)(void const *__s1 ,
                                                                                               void const *__s2 ,
                                                                                               size_t __n ) __attribute__((__pure__)) ;
static __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) __crest_memcmp_opaque)(void const *__s1 ,
                                                                                                              void const *__s2 ,
                                                                                                              size_t __n ) __attribute__((__pure__)) ;
static int ( __attribute__((__nonnull__(1,2), __leaf__)) __crest_memcmp_opaque)(void const *__s1 ,
                                                                                void const *__s2 ,
                                                                                size_t __n )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("memcmp", (void (*)())(& memcmp), 3);
  __CrestApply("(memcmp() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = memcmp(__s1, __s2, __n);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) char *( __attribute__((__nonnull__(1,2), __leaf__)) strcpy)(char * __restrict __dest ,
                                                                                                 char const * __restrict __src ) ;
static __attribute__((__nothrow__)) char *( __attribute__((__nonnull__(1,2), __leaf__)) __crest_strcpy_opaque)(char * __restrict __dest ,
                                                                                                                char const * __restrict __src ) ;
static char *( __attribute__((__nonnull__(1,2), __leaf__)) __crest_strcpy_opaque)(char * __restrict __dest ,
                                                                                  char const * __restrict __src )
{
  char *__crest_ret ;

  {
  __CrestCallOpaque("strcpy", (void (*)())(& strcpy), 2);
  __CrestClear(2);
  __CrestLoadStackPtr("strcpy()");
  __CrestNondet();
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestMute();
  __crest_ret = strcpy(__dest, __src);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) strcmp)(char const *__s1 ,
                                                                                               char const *__s2 ) __attribute__((__pure__)) ;
static __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) __crest_strcmp_opaque)(char const *__s1 ,
                                                                                                              char const *__s2 ) __attribute__((__pure__)) ;
static int ( __attribute__((__nonnull__(1,2), __leaf__)) __crest_strcmp_opaque)(char const *__s1 ,
                                                                                char const *__s2 )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("strcmp", (void (*)())(& strcmp), 2);
  __CrestApply("(strcmp() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = strcmp(__s1, __s2);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) strncmp)(char const *__s1 ,
                                                                                                char const *__s2 ,
                                                                                                size_t __n ) __attribute__((__pure__)) ;
static __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) __crest_strncmp_opaque)(char const *__s1 ,
                                                                                                               char const *__s2 ,
                                                                                                               size_t __n ) __attribute__((__pure__)) ;
static int ( __attribute__((__nonnull__(1,2), __leaf__)) __crest_strncmp_opaque)(char const *__s1 ,
                                                                                 char const *__s2 ,
                                                                                 size_t __n )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("strncmp", (void (*)())(& strncmp), 3);
  __CrestApply("(strncmp() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = strncmp(__s1, __s2, __n);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) size_t ( __attribute__((__nonnull__(1), __leaf__)) strlen)(char const *__s ) __attribute__((__pure__)) ;
static __attribute__((__nothrow__)) size_t ( __attribute__((__nonnull__(1), __leaf__)) __crest_strlen_opaque)(char const *__s ) __attribute__((__pure__)) ;
static size_t ( __attribute__((__nonnull__(1), __leaf__)) __crest_strlen_opaque)(char const *__s )
{
  size_t __crest_ret ;

  {
  __CrestCallOpaque("strlen", (void (*)())(& strlen), 1);
  __CrestApply("(strlen() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = strlen(__s);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int close(int __fd ) ;
static int __crest_close_opaque(int __fd )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("close", (void (*)())(& close), 1);
  __CrestApply("(close() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = close(__fd);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern ssize_t read(int __fd , void *__buf , size_t __nbytes ) ;
static ssize_t __crest_read_opaque(int __fd , void *__buf , size_t __nbytes )
{
  ssize_t __crest_ret ;

  {
  __CrestCallOpaque("read", (void (*)())(& read), 3);
  __CrestApply("(read() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = read(__fd, __buf, __nbytes);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern ssize_t write(int __fd , void const *__buf , size_t __n ) ;
static ssize_t __crest_write_opaque(int __fd , void const *__buf , size_t __n )
{
  ssize_t __crest_ret ;

  {
  __CrestCallOpaque("write", (void (*)())(& write), 3);
  __CrestApply("(write() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = write(__fd, __buf, __n);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__, __noreturn__)) void ( __attribute__((__leaf__)) __assert_fail)(char const *__assertion ,
                                                                                                   char const *__file ,
                                                                                                   unsigned int __line ,
                                                                                                   char const *__function ) ;

extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) socket)(int __domain ,
                                                                             int __type ,
                                                                             int __protocol ) ;
static __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) __crest_socket_opaque)(int __domain ,
                                                                                            int __type ,
                                                                                            int __protocol ) ;
static int ( __attribute__((__leaf__)) __crest_socket_opaque)(int __domain , int __type ,
                                                              int __protocol )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("socket", (void (*)())(& socket), 3);
  __CrestApply("(socket() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = socket(__domain, __type, __protocol);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) bind)(int __fd ,
                                                                           struct sockaddr const *__addr ,
                                                                           socklen_t __len ) ;
static __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) __crest_bind_opaque)(int __fd ,
                                                                                          struct sockaddr const *__addr ,
                                                                                          socklen_t __len ) ;
static int ( __attribute__((__leaf__)) __crest_bind_opaque)(int __fd , struct sockaddr const *__addr ,
                                                            socklen_t __len )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("bind", (void (*)())(& bind), 3);
  __CrestApply("(bind() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = bind(__fd, __addr, __len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int connect(int __fd , struct sockaddr const *__addr , socklen_t __len ) ;
static int __crest_connect_opaque(int __fd , struct sockaddr const *__addr , socklen_t __len )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("connect", (void (*)())(& connect), 3);
  __CrestApply("(connect() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = connect(__fd, __addr, __len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) setsockopt)(int __fd ,
                                                                                 int __level ,
                                                                                 int __optname ,
                                                                                 void const *__optval ,
                                                                                 socklen_t __optlen ) ;
static __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) __crest_setsockopt_opaque)(int __fd ,
                                                                                                int __level ,
                                                                                                int __optname ,
                                                                                                void const *__optval ,
                                                                                                socklen_t __optlen ) ;
static int ( __attribute__((__leaf__)) __crest_setsockopt_opaque)(int __fd , int __level ,
                                                                  int __optname ,
                                                                  void const *__optval ,
                                                                  socklen_t __optlen )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("setsockopt", (void (*)())(& setsockopt), 5);
  __CrestApply("(setsockopt() : bitstring * bitstring * bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = setsockopt(__fd, __level, __optname, __optval, __optlen);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) listen)(int __fd ,
                                                                             int __n ) ;
static __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) __crest_listen_opaque)(int __fd ,
                                                                                            int __n ) ;
static int ( __attribute__((__leaf__)) __crest_listen_opaque)(int __fd , int __n )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("listen", (void (*)())(& listen), 2);
  __CrestApply("(listen() : bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = listen(__fd, __n);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern int accept(int __fd , struct sockaddr * __restrict __addr , socklen_t * __restrict __addr_len ) ;
static int __crest_accept_opaque(int __fd , struct sockaddr * __restrict __addr ,
                                 socklen_t * __restrict __addr_len )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("accept", (void (*)())(& accept), 3);
  __CrestApply("(accept() : bitstring * bitstring * bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = accept(__fd, __addr, __addr_len);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) uint32_t ( __attribute__((__leaf__)) htonl)(uint32_t __hostlong ) __attribute__((__const__)) ;
static __attribute__((__nothrow__)) uint32_t ( __attribute__((__leaf__)) __crest_htonl_opaque)(uint32_t __hostlong ) __attribute__((__const__)) ;
static uint32_t ( __attribute__((__leaf__)) __crest_htonl_opaque)(uint32_t __hostlong )
{
  uint32_t __crest_ret ;

  {
  __CrestCallOpaque("htonl", (void (*)())(& htonl), 1);
  __CrestApply("(htonl() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = htonl(__hostlong);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) uint16_t ( __attribute__((__leaf__)) htons)(uint16_t __hostshort ) __attribute__((__const__)) ;
static __attribute__((__nothrow__)) uint16_t ( __attribute__((__leaf__)) __crest_htons_opaque)(uint16_t __hostshort ) __attribute__((__const__)) ;
static uint16_t ( __attribute__((__leaf__)) __crest_htons_opaque)(uint16_t __hostshort )
{
  uint16_t __crest_ret ;

  {
  __CrestCallOpaque("htons", (void (*)())(& htons), 1);
  __CrestApply("(htons() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = htons(__hostshort);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern __attribute__((__nothrow__)) in_addr_t ( __attribute__((__leaf__)) inet_addr)(char const *__cp ) ;
static __attribute__((__nothrow__)) in_addr_t ( __attribute__((__leaf__)) __crest_inet_addr_opaque)(char const *__cp ) ;
static in_addr_t ( __attribute__((__leaf__)) __crest_inet_addr_opaque)(char const *__cp )
{
  in_addr_t __crest_ret ;

  {
  __CrestCallOpaque("inet_addr", (void (*)())(& inet_addr), 1);
  __CrestApply("(inet_addr() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = inet_addr(__cp);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void proxy_fail(char const *fmt , ...) ;

extern void mute() ;

extern void unmute() ;

extern void load_buf(unsigned char const *buf , size_t len , char const *hint ) ;

extern void load_all(unsigned char const *buf , char const *hint ) ;

extern void load_int(long n , _Bool is_signed , size_t width , char const *hint ) ;

extern void len(_Bool is_signed , size_t lenlen ) ;

extern void test_intype(char const *type ) ;

extern void assume_intype(char const *type ) ;

extern void assume_len(unsigned char const *len , _Bool is_signed , size_t width ) ;

extern void input(char const *hint , size_t len ) ;

extern void output() ;

extern void store_buf(unsigned char const *buf ) ;

extern void store_all(unsigned char const *buf ) ;

extern int ( __attribute__((__cdecl__)) memcmp_proxy)(void const *a , void const *b ,
                                                      size_t len___0 )
{
  int ret ;
  int tmp ;
  size_t len___1 ;

  {
  __CrestCall("memcmp_proxy", (void (*)())(& memcmp_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:len___0[5273]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:b[5271]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:a[5270]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:25");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:26");
  __CrestLoadStackPtr("system_proxies.c:a[5270]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:b[5271]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:len___0[5273]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_memcmp_opaque(a, b, len___0);
  __CrestLoadStackPtr("system_proxies.c:tmp[5275]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:26");
  __CrestLoadStackPtr("system_proxies.c:tmp[5275]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5274]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:27");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:29");
  __CrestLoadStackPtr("system_proxies.c:a[5270]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:len___0[5273]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf((unsigned char const *)a, len___0, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:30");
  __CrestLoadStackPtr("system_proxies.c:b[5271]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:len___0[5273]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf((unsigned char const *)b, len___0, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:32");
  __CrestLoadCString("cmp");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("cmp", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:33");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:34");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("system_proxies.c:len___1[5277]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___1 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:35");
  __CrestLoadStackPtr("system_proxies.c:len___1[5277]");
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
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:36");
  __CrestLoadStackPtr("system_proxies.c:ret[5274]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  StoreBuf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:38");
  __CrestLoadStackPtr("system_proxies.c:ret[5274]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern void *( __attribute__((__cdecl__)) memcpy_proxy)(void *dest , void const *src ,
                                                        size_t len___0 )
{
  void *ret ;

  {
  __CrestCall("memcpy_proxy", (void (*)())(& memcpy_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:len___0[5285]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:src[5283]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:dest[5282]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:43");
  __CrestLoadStackPtr("system_proxies.c:dest[5282]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5286]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = dest;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:45");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:46");
  __CrestLoadStackPtr("system_proxies.c:dest[5282]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:src[5283]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:len___0[5285]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  ret = __crest_memcpy_opaque((void * __restrict )dest, (void const * __restrict )src,
                              len___0);
  __CrestLoadStackPtr("system_proxies.c:ret[5286]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:47");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:49");
  __CrestLoadStackPtr("system_proxies.c:src[5283]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:len___0[5285]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf((unsigned char const *)src, len___0, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:50");
  __CrestLoadStackPtr("system_proxies.c:dest[5282]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)dest);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:52");
  __CrestLoadStackPtr("system_proxies.c:ret[5286]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern void *( __attribute__((__cdecl__)) memmove_proxy)(void *dest , void const *src ,
                                                         size_t len___0 )
{
  void *ret ;

  {
  __CrestCall("memmove_proxy", (void (*)())(& memmove_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:len___0[5294]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:src[5292]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:dest[5291]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:57");
  __CrestLoadStackPtr("system_proxies.c:dest[5291]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5295]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = dest;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:59");
  __CrestLoadStackPtr("system_proxies.c:src[5292]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:len___0[5294]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf((unsigned char const *)src, len___0, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:61");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:62");
  __CrestLoadStackPtr("system_proxies.c:dest[5291]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:src[5292]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:len___0[5294]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  ret = __crest_memmove_opaque(dest, src, len___0);
  __CrestLoadStackPtr("system_proxies.c:ret[5295]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:63");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:65");
  __CrestLoadStackPtr("system_proxies.c:dest[5291]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)dest);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:67");
  __CrestLoadStackPtr("system_proxies.c:ret[5295]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern void *malloc_proxy(size_t size )
{
  void *ret ;
  void *tmp ;

  {
  __CrestCall("malloc_proxy", (void (*)())(& malloc_proxy), 1);
  __CrestLoadStackPtr("system_proxies.c:size[5298]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:73");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:74");
  __CrestLoadStackPtr("system_proxies.c:size[5298]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_malloc_opaque(size);
  __CrestLoadStackPtr("system_proxies.c:tmp[5300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:74");
  __CrestLoadStackPtr("system_proxies.c:tmp[5300]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5299]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:75");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:77");
  __CrestLoadStackPtr("system_proxies.c:size[5298]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  Malloc(size);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:78");
  __CrestLoadStackPtr("system_proxies.c:ret[5299]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:80");
  __CrestLoadStackPtr("system_proxies.c:ret[5299]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern void *__builtin_alloca_proxy(unsigned long size )
{
  void *tmp ;

  {
  __CrestCall("__builtin_alloca_proxy", (void (*)())(& __builtin_alloca_proxy), 1);
  __CrestLoadStackPtr("system_proxies.c:size[5303]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:86");
  __CrestLoadStackPtr("system_proxies.c:size[5303]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = malloc_proxy(size);
  __CrestLoadStackPtr("system_proxies.c:tmp[5304]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:86");
  __CrestLoadStackPtr("system_proxies.c:tmp[5304]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (tmp);
  }
}
}

extern void *realloc_proxy(void *ptr , size_t size )
{
  void *ret ;

  {
  __CrestCall("realloc_proxy", (void (*)())(& realloc_proxy), 2);
  __CrestLoadStackPtr("system_proxies.c:size[5309]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:ptr[5308]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:99");
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestLoadStackPtr("system_proxies.c:ret[5310]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = (void *)0;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:101");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:102");
  __CrestLoadStackPtr("system_proxies.c:ptr[5308]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:size[5309]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  ret = __crest_realloc_opaque(ptr, size);
  __CrestLoadStackPtr("system_proxies.c:ret[5310]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:103");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:105");
  __CrestLoadStackPtr("system_proxies.c:size[5309]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  Malloc(size);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:107");
  __CrestLoadStackPtr("system_proxies.c:ret[5310]");
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
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:108");
  __CrestLoadStackPtr("system_proxies.c:ptr[5308]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("");

  load_all((unsigned char const *)ptr, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:109");
  __CrestLoadStackPtr("system_proxies.c:ret[5310]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)ret);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:111");
  __CrestLoadStackPtr("system_proxies.c:ret[5310]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern void *memset_proxy(void *s , int c , size_t n )
{
  void *ret ;
  void *tmp ;

  {
  __CrestCall("memset_proxy", (void (*)())(& memset_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:n[5317]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:c[5316]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:s[5315]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:120");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:121");
  __CrestLoadStackPtr("system_proxies.c:s[5315]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:c[5316]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:n[5317]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_memset_opaque(s, c, n);
  __CrestLoadStackPtr("system_proxies.c:tmp[5319]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:121");
  __CrestLoadStackPtr("system_proxies.c:tmp[5319]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5318]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:122");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:124");
  __CrestLoadStackPtr("system_proxies.c:s[5315]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5318]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = s;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:126");
  __CrestLoadStackPtr("system_proxies.c:c[5316]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadCString("");

  load_buf((unsigned char const *)(& c), sizeof(c), "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:127");
  __CrestLoadStackPtr("system_proxies.c:n[5317]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);
  __CrestLoadCString("");

  load_buf((unsigned char const *)(& n), sizeof(n), "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:128");
  __CrestLoadCString("replicate");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("replicate", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:129");
  __CrestLoadStackPtr("system_proxies.c:n[5317]");
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

  assume_len((unsigned char const *)(& n), (_Bool)0, sizeof(n));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:131");
  __CrestLoadStackPtr("system_proxies.c:s[5315]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)s);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:133");
  __CrestLoadStackPtr("system_proxies.c:ret[5318]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern ssize_t read_proxy(int fd , void *buf , size_t nbytes )
{
  ssize_t ret ;
  ssize_t tmp ;

  {
  __CrestCall("read_proxy", (void (*)())(& read_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:nbytes[5326]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:buf[5325]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:fd[5324]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:151");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:152");
  __CrestLoadStackPtr("system_proxies.c:fd[5324]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:buf[5325]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:nbytes[5326]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_read_opaque(fd, buf, nbytes);
  __CrestLoadStackPtr("system_proxies.c:tmp[5328]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:152");
  __CrestLoadStackPtr("system_proxies.c:tmp[5328]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5327]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:154");
  __CrestLoadStackPtr("system_proxies.c:ret[5327]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,8] -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:nbytes[5326]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((size_t )ret != nbytes) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:156");
    __CrestLoadCString("read_proxy: ret != nbytes not handled yet, ret = %d, nbytes = %d\n");
    __CrestLoadStackPtr("system_proxies.c:ret[5327]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestLoadStackPtr("system_proxies.c:nbytes[5326]");
    __CrestLoadInt((long long )8);
    __CrestSetPtrStep();
    __CrestLoadMem();
    __CrestMute();

    proxy_fail("read_proxy: ret != nbytes not handled yet, ret = %d, nbytes = %d\n",
               ret, nbytes);
    __CrestUnmute();
    __CrestClear(3);
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:159");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:161");
  __CrestLoadStackPtr("system_proxies.c:nbytes[5326]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,8])");
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:ret[5327]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret = (ssize_t )nbytes;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:163");
  __CrestLoadCString("msg");
  __CrestLoadStackPtr("system_proxies.c:ret[5327]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,8] -> [u,8])");
  __CrestDone();

  input("msg", (size_t )ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:164");
  __CrestLoadStackPtr("system_proxies.c:buf[5325]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)buf);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:166");
  __CrestLoadStackPtr("system_proxies.c:ret[5327]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

extern ssize_t write_proxy(int fd , void const *buf , size_t n )
{
  ssize_t ret ;
  ssize_t tmp ;

  {
  __CrestCall("write_proxy", (void (*)())(& write_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:n[5335]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:buf[5334]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:fd[5333]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:171");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:172");
  __CrestLoadStackPtr("system_proxies.c:fd[5333]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:buf[5334]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:n[5335]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_write_opaque(fd, buf, n);
  __CrestLoadStackPtr("system_proxies.c:tmp[5337]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:172");
  __CrestLoadStackPtr("system_proxies.c:tmp[5337]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5336]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:173");
  __CrestLoadStackPtr("system_proxies.c:ret[5336]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,8] -> [u,8])");
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:n[5335]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(!=: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if ((size_t )ret != n) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:175");
    __CrestLoadCString("write_proxy: ret != n not handled yet");
    __CrestMute();

    proxy_fail("write_proxy: ret != n not handled yet");
    __CrestUnmute();
    __CrestClear(1);
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:177");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:179");
  __CrestLoadStackPtr("system_proxies.c:n[5335]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,8])");
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:ret[5336]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret = (ssize_t )n;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:181");
  __CrestLoadStackPtr("system_proxies.c:buf[5334]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:ret[5336]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,8] -> [u,8])");
  __CrestDone();
  __CrestLoadCString("msg");

  load_buf((unsigned char const *)buf, (size_t )ret, "msg");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:182");

  output();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:184");
  __CrestLoadStackPtr("system_proxies.c:ret[5336]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int strcmp_proxy(char const *a , char const *b )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("strcmp_proxy", (void (*)())(& strcmp_proxy), 2);
  __CrestLoadStackPtr("system_proxies.c:b[5342]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:a[5341]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:189");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:190");
  __CrestLoadStackPtr("system_proxies.c:a[5341]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:b[5342]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_strcmp_opaque(a, b);
  __CrestLoadStackPtr("system_proxies.c:tmp[5344]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:190");
  __CrestLoadStackPtr("system_proxies.c:tmp[5344]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5343]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:191");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:193");
  __CrestLoadStackPtr("system_proxies.c:a[5341]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("");

  load_all((unsigned char const *)a, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:194");
  __CrestLoadCString("ztp");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("ztp", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:195");
  __CrestLoadStackPtr("system_proxies.c:b[5342]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("");

  load_all((unsigned char const *)b, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:196");
  __CrestLoadCString("ztp");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("ztp", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:198");
  __CrestLoadCString("cmp");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("cmp", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:199");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("system_proxies.c:len___0[5346]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:200");
  __CrestLoadStackPtr("system_proxies.c:len___0[5346]");
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
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:201");
  __CrestLoadStackPtr("system_proxies.c:ret[5343]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:203");
  __CrestLoadStackPtr("system_proxies.c:ret[5343]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int strncmp_proxy(char const *a , char const *b , size_t n )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("strncmp_proxy", (void (*)())(& strncmp_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:n[5353]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:b[5352]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:a[5351]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:208");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:209");
  __CrestLoadStackPtr("system_proxies.c:a[5351]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:b[5352]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:n[5353]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_strncmp_opaque(a, b, n);
  __CrestLoadStackPtr("system_proxies.c:tmp[5355]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:209");
  __CrestLoadStackPtr("system_proxies.c:tmp[5355]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5354]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:210");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:212");
  __CrestLoadStackPtr("system_proxies.c:a[5351]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:n[5353]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf((unsigned char const *)a, n, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:213");
  __CrestLoadCString("ztp");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("ztp", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:214");
  __CrestLoadStackPtr("system_proxies.c:b[5352]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:n[5353]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf((unsigned char const *)b, n, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:215");
  __CrestLoadCString("ztp");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("ztp", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:216");
  __CrestLoadCString("cmp");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("cmp", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:217");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("system_proxies.c:len___0[5357]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:218");
  __CrestLoadStackPtr("system_proxies.c:len___0[5357]");
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
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:219");
  __CrestLoadStackPtr("system_proxies.c:ret[5354]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:221");
  __CrestLoadStackPtr("system_proxies.c:ret[5354]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

char *strcpy_proxy(char *dest , char const *src )
{
  void *ret ;
  char *tmp ;
  char *__retres5 ;

  {
  __CrestCall("strcpy_proxy", (void (*)())(& strcpy_proxy), 2);
  __CrestLoadStackPtr("system_proxies.c:src[5362]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:dest[5361]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:230");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:231");
  __CrestLoadStackPtr("system_proxies.c:dest[5361]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:src[5362]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  tmp = __crest_strcpy_opaque((char * __restrict )dest, (char const * __restrict )src);
  __CrestLoadStackPtr("system_proxies.c:tmp[5364]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:231");
  __CrestLoadStackPtr("system_proxies.c:tmp[5364]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:ret[5363]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = (void *)tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:232");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:234");
  __CrestLoadStackPtr("system_proxies.c:dest[5361]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:ret[5363]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  ret = (void *)dest;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:236");
  __CrestLoadStackPtr("system_proxies.c:src[5362]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("");

  load_all((unsigned char const *)src, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:237");
  __CrestLoadCString("ztp");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("ztp", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:238");

  Done();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:239");
  __CrestLoadCString("bitstring");

  test_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:240");
  __CrestLoadInt((long long )0L);
  __CrestBS(1, 8);
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )1);
  __CrestBS(0, 8);
  __CrestLoadCString("");

  load_int(0L, (_Bool)0, sizeof(char ), "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:241");

  Append();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:242");
  __CrestLoadStackPtr("system_proxies.c:dest[5361]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_all((unsigned char const *)dest);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:244");
  __CrestLoadStackPtr("system_proxies.c:ret[5363]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("system_proxies.c:__retres5[5465]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();

  __retres5 = (char *)ret;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:228");
  __CrestLoadStackPtr("system_proxies.c:__retres5[5465]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (__retres5);
  }
}
}

size_t strlen_proxy(char const *s )
{
  size_t ret ;
  size_t tmp ;

  {
  __CrestCall("strlen_proxy", (void (*)())(& strlen_proxy), 1);
  __CrestLoadStackPtr("system_proxies.c:s[5367]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:249");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:250");
  __CrestLoadStackPtr("system_proxies.c:s[5367]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_strlen_opaque(s);
  __CrestLoadStackPtr("system_proxies.c:tmp[5369]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:250");
  __CrestLoadStackPtr("system_proxies.c:tmp[5369]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5368]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:251");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:253");
  __CrestLoadStackPtr("system_proxies.c:s[5367]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadCString("");

  load_all((unsigned char const *)s, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:254");
  __CrestLoadCString("ztp");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("ztp", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:256");

  Done();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:257");
  __CrestLoadCString("bitstring");

  test_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:258");
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);

  len((_Bool)0, sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:259");
  __CrestLoadStackPtr("system_proxies.c:ret[5368]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:261");
  __CrestLoadStackPtr("system_proxies.c:ret[5368]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void __assert_fail_proxy(char const *__assertion , char const *__file , unsigned int __line ,
                         char const *__function )
{


  {
  __CrestCall("__assert_fail_proxy", (void (*)())(& __assert_fail_proxy), 4);
  __CrestLoadStackPtr("system_proxies.c:__function[5378]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:__line[5377]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:__file[5376]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:__assertion[5375]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:307");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:308");
  __CrestLoadStackPtr("system_proxies.c:__assertion[5375]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:__file[5376]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:__line[5377]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:__function[5378]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __assert_fail(__assertion, __file, __line, __function);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:309");

  unmute();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:302");
  __CrestReturn(1);

  return;
  }
}
}

int socket_proxy(int domain , int type , int protocol )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("socket_proxy", (void (*)())(& socket_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:protocol[5385]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:type[5384]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:domain[5383]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:316");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:317");
  __CrestLoadStackPtr("system_proxies.c:domain[5383]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:type[5384]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:protocol[5385]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_socket_opaque(domain, type, protocol);
  __CrestLoadStackPtr("system_proxies.c:tmp[5387]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:317");
  __CrestLoadStackPtr("system_proxies.c:tmp[5387]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5386]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:318");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:320");
  __CrestLoadCString("socket_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("socket_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:321");
  __CrestLoadStackPtr("system_proxies.c:ret[5386]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:322");
  __CrestLoadStackPtr("system_proxies.c:ret[5386]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

uint16_t htons_proxy(uint16_t hostshort )
{
  uint16_t ret ;
  uint16_t tmp ;

  {
  __CrestCall("htons_proxy", (void (*)())(& htons_proxy), 1);
  __CrestLoadStackPtr("system_proxies.c:hostshort[5390]");
  __CrestLoadInt((long long )2);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:327");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:328");
  __CrestLoadStackPtr("system_proxies.c:hostshort[5390]");
  __CrestLoadInt((long long )2);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_htons_opaque(hostshort);
  __CrestLoadStackPtr("system_proxies.c:tmp[5392]");
  __CrestLoadInt((long long )2);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:328");
  __CrestLoadStackPtr("system_proxies.c:tmp[5392]");
  __CrestLoadInt((long long )2);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5391]");
  __CrestLoadInt((long long )2);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:329");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:331");
  __CrestLoadCString("htons_result");
  __CrestLoadInt((long long )2);
  __CrestBS(0, 8);

  input("htons_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:332");
  __CrestLoadStackPtr("system_proxies.c:ret[5391]");
  __CrestLoadInt((long long )2);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:333");
  __CrestLoadStackPtr("system_proxies.c:ret[5391]");
  __CrestLoadInt((long long )2);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

uint32_t htonl_proxy(uint32_t hostlong )
{
  uint32_t ret ;
  uint32_t tmp ;

  {
  __CrestCall("htonl_proxy", (void (*)())(& htonl_proxy), 1);
  __CrestLoadStackPtr("system_proxies.c:hostlong[5395]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:338");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:339");
  __CrestLoadStackPtr("system_proxies.c:hostlong[5395]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_htonl_opaque(hostlong);
  __CrestLoadStackPtr("system_proxies.c:tmp[5397]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:339");
  __CrestLoadStackPtr("system_proxies.c:tmp[5397]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5396]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:340");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:342");
  __CrestLoadCString("htonl_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("htonl_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:343");
  __CrestLoadStackPtr("system_proxies.c:ret[5396]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:344");
  __CrestLoadStackPtr("system_proxies.c:ret[5396]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int setsockopt_proxy(int fd , int level , int optname , void const *optval , socklen_t optlen )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("setsockopt_proxy", (void (*)())(& setsockopt_proxy), 5);
  __CrestLoadStackPtr("system_proxies.c:optlen[5408]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:optval[5407]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:optname[5406]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:level[5405]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:fd[5404]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:353");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:354");
  __CrestLoadStackPtr("system_proxies.c:fd[5404]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:level[5405]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:optname[5406]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:optval[5407]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:optlen[5408]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_setsockopt_opaque(fd, level, optname, optval, optlen);
  __CrestLoadStackPtr("system_proxies.c:tmp[5410]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:354");
  __CrestLoadStackPtr("system_proxies.c:tmp[5410]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5409]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:355");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:357");
  __CrestLoadCString("setsockopt_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("setsockopt_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:358");
  __CrestLoadStackPtr("system_proxies.c:ret[5409]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:359");
  __CrestLoadStackPtr("system_proxies.c:ret[5409]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int listen_proxy(int fd , int n )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("listen_proxy", (void (*)())(& listen_proxy), 2);
  __CrestLoadStackPtr("system_proxies.c:n[5415]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:fd[5414]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:365");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:366");
  __CrestLoadStackPtr("system_proxies.c:fd[5414]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:n[5415]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_listen_opaque(fd, n);
  __CrestLoadStackPtr("system_proxies.c:tmp[5417]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:366");
  __CrestLoadStackPtr("system_proxies.c:tmp[5417]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5416]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:367");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:369");
  __CrestLoadCString("listen_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("listen_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:370");
  __CrestLoadStackPtr("system_proxies.c:ret[5416]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:371");
  __CrestLoadStackPtr("system_proxies.c:ret[5416]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

in_addr_t inet_addr_proxy(char const *cp )
{
  in_addr_t ret ;
  in_addr_t tmp ;

  {
  __CrestCall("inet_addr_proxy", (void (*)())(& inet_addr_proxy), 1);
  __CrestLoadStackPtr("system_proxies.c:cp[5420]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:376");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:377");
  __CrestLoadStackPtr("system_proxies.c:cp[5420]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_inet_addr_opaque(cp);
  __CrestLoadStackPtr("system_proxies.c:tmp[5422]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:377");
  __CrestLoadStackPtr("system_proxies.c:tmp[5422]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5421]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:378");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:380");
  __CrestLoadCString("inet_addr_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("inet_addr_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:381");
  __CrestLoadStackPtr("system_proxies.c:ret[5421]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:382");
  __CrestLoadStackPtr("system_proxies.c:ret[5421]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int bind_proxy(int fd , struct sockaddr const *addr , socklen_t len___0 )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("bind_proxy", (void (*)())(& bind_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:len___0[5430]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:addr[5428]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:fd[5427]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:389");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:390");
  __CrestLoadStackPtr("system_proxies.c:fd[5427]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:addr[5428]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:len___0[5430]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_bind_opaque(fd, addr, len___0);
  __CrestLoadStackPtr("system_proxies.c:tmp[5432]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:390");
  __CrestLoadStackPtr("system_proxies.c:tmp[5432]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5431]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:391");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:393");
  __CrestLoadCString("bind_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("bind_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:394");
  __CrestLoadStackPtr("system_proxies.c:ret[5431]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:395");
  __CrestLoadStackPtr("system_proxies.c:ret[5431]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int connect_proxy(int fd , struct sockaddr const *addr , socklen_t len___0 )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("connect_proxy", (void (*)())(& connect_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:len___0[5440]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:addr[5438]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:fd[5437]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:402");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:403");
  __CrestLoadStackPtr("system_proxies.c:fd[5437]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:addr[5438]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:len___0[5440]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_connect_opaque(fd, addr, len___0);
  __CrestLoadStackPtr("system_proxies.c:tmp[5442]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:403");
  __CrestLoadStackPtr("system_proxies.c:tmp[5442]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5441]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:404");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:406");
  __CrestLoadCString("connect_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("connect_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:407");
  __CrestLoadStackPtr("system_proxies.c:ret[5441]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:408");
  __CrestLoadStackPtr("system_proxies.c:ret[5441]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int accept_proxy(int fd , struct sockaddr * __restrict addr , socklen_t * __restrict addr_len )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("accept_proxy", (void (*)())(& accept_proxy), 3);
  __CrestLoadStackPtr("system_proxies.c:addr_len[5449]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:addr[5448]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("system_proxies.c:fd[5447]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:414");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:415");
  __CrestLoadStackPtr("system_proxies.c:fd[5447]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:addr[5448]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:addr_len[5449]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_accept_opaque(fd, addr, addr_len);
  __CrestLoadStackPtr("system_proxies.c:tmp[5451]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:415");
  __CrestLoadStackPtr("system_proxies.c:tmp[5451]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5450]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:416");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:418");
  __CrestLoadCString("accept_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("accept_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:419");
  __CrestLoadStackPtr("system_proxies.c:ret[5450]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:420");
  __CrestLoadStackPtr("system_proxies.c:ret[5450]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

int close_proxy(int fd )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("close_proxy", (void (*)())(& close_proxy), 1);
  __CrestLoadStackPtr("system_proxies.c:fd[5454]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:425");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:426");
  __CrestLoadStackPtr("system_proxies.c:fd[5454]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_close_opaque(fd);
  __CrestLoadStackPtr("system_proxies.c:tmp[5456]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:426");
  __CrestLoadStackPtr("system_proxies.c:tmp[5456]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5455]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:427");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:429");
  __CrestLoadCString("close_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("close_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:430");
  __CrestLoadStackPtr("system_proxies.c:ret[5455]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:431");
  __CrestLoadStackPtr("system_proxies.c:ret[5455]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void exit_proxy(int status )
{


  {
  __CrestCall("exit_proxy", (void (*)())(& exit_proxy), 1);
  __CrestLoadStackPtr("system_proxies.c:status[5459]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:436");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:437");
  __CrestLoadStackPtr("system_proxies.c:status[5459]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_exit_opaque(status);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:438");

  unmute();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:434");
  __CrestReturn(1);

  return;
  }
}
}

int atoi_proxy(char const *nptr )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("atoi_proxy", (void (*)())(& atoi_proxy), 1);
  __CrestLoadStackPtr("system_proxies.c:nptr[5462]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:444");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:445");
  __CrestLoadStackPtr("system_proxies.c:nptr[5462]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_atoi_opaque(nptr);
  __CrestLoadStackPtr("system_proxies.c:tmp[5464]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:445");
  __CrestLoadStackPtr("system_proxies.c:tmp[5464]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies.c:ret[5463]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:446");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:448");
  __CrestLoadCString("atoi_result");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  input("atoi_result", sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:449");
  __CrestLoadStackPtr("system_proxies.c:ret[5463]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies.c:450");
  __CrestLoadStackPtr("system_proxies.c:ret[5463]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}
