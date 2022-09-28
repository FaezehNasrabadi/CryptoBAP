# 1 "./system_proxies_boring.cil.c"
# 1 "/home/faezeh/csec-modex/proxies//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "./system_proxies_boring.cil.c"



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

extern __attribute__((__nothrow__)) void ( __attribute__((__leaf__)) free)(void *__ptr ) ;
static __attribute__((__nothrow__)) void ( __attribute__((__leaf__)) __crest_free_opaque)(void *__ptr ) ;
static void ( __attribute__((__leaf__)) __crest_free_opaque)(void *__ptr )
{


  {
  __CrestCallOpaque("free", (void (*)())(& free), 1);
  __CrestClear(1);
  __CrestMute();
  free(__ptr);
  __CrestUnmute();
  __CrestReturn(1);
}
}

extern int fflush(FILE *__stream ) ;
static int __crest_fflush_opaque(FILE *__stream )
{
  int __crest_ret ;

  {
  __CrestCallOpaque("fflush", (void (*)())(& fflush), 1);
  __CrestApply("(fflush() : bitstring -> bitstring)");
  __CrestNondet();
  __CrestMute();
  __crest_ret = fflush(__stream);
  __CrestUnmute();
  __CrestReturn(1);
  return (__crest_ret);
}
}

extern void mute() ;

extern void unmute() ;

extern void assume_intype(char const *type ) ;

extern void assume_len(unsigned char const *len , _Bool is_signed , size_t width ) ;

extern void fresh_var(char const *name_stem ) ;

extern void store_buf(unsigned char const *buf ) ;

int fflush_proxy(FILE *stream )
{
  int ret ;
  int tmp ;
  size_t len___0 ;

  {
  __CrestCall("fflush_proxy", (void (*)())(& fflush_proxy), 1);
  __CrestLoadStackPtr("system_proxies_boring.c:stream[3746]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:12");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:13");
  __CrestLoadStackPtr("system_proxies_boring.c:stream[3746]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = __crest_fflush_opaque(stream);
  __CrestLoadStackPtr("system_proxies_boring.c:tmp[3748]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:13");
  __CrestLoadStackPtr("system_proxies_boring.c:tmp[3748]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("system_proxies_boring.c:ret[3747]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:14");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:16");
  __CrestLoadCString("fflush_ret");

  fresh_var("fflush_ret");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:17");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:18");
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("system_proxies_boring.c:len___0[3750]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  len___0 = sizeof(ret);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:19");
  __CrestLoadStackPtr("system_proxies_boring.c:len___0[3750]");
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
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:20");
  __CrestLoadStackPtr("system_proxies_boring.c:ret[3747]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:22");
  __CrestLoadStackPtr("system_proxies_boring.c:ret[3747]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void free_proxy(void *ptr )
{


  {
  __CrestCall("free_proxy", (void (*)())(& free_proxy), 1);
  __CrestLoadStackPtr("system_proxies_boring.c:ptr[3753]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:27");

  mute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:28");
  __CrestLoadStackPtr("system_proxies_boring.c:ptr[3753]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  __crest_free_opaque(ptr);
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:29");

  unmute();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/system_proxies_boring.c:25");
  __CrestReturn(1);

  return;
  }
}
}
