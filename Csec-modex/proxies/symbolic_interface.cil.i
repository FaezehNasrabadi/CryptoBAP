# 1 "./symbolic_interface.cil.c"
# 1 "/home/faezeh/csec-modex/proxies//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "./symbolic_interface.cil.c"



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

extern __attribute__((__nothrow__, __noreturn__)) void ( __attribute__((__leaf__)) exit)(int __status ) ;

extern int printf(char const * __restrict __format , ...) ;

extern void __CrestLoadInt(long long val ) __attribute__((__crest_skip__)) ;

extern void LoadBuf(unsigned char const *buf , size_t len ) ;

extern void LoadAll(unsigned char const *buf ) ;

extern void LoadAttr(void const *ctx , char const *attr ) ;

extern void LoadInt(int n ) ;

extern void BS(_Bool is_signed , int width ) ;

extern void Val(_Bool is_signed , int width ) ;

extern void LoadStr(char const *str ) ;

extern void SymN(char const *sym , int n ) ;

extern void In() ;

extern void New() ;

extern void Env(char const *name ) ;

extern void FreshVar(char const *name_stem ) ;

extern void Len() ;

extern void InType(char const *type ) ;

extern void Dup() ;

extern void Clear(int n ) ;

extern void Done() ;

extern void Test() ;

extern void Assume() ;

extern void Truth() ;

extern void Event(char const *sym , int n ) ;

extern void Append() ;

extern void Hint(char const *hint ) ;

extern void StoreBuf(unsigned char const *buf ) ;

extern void StoreAll(unsigned char const *buf ) ;

extern void StoreAttr(void const *ctx , char const *attr ) ;

extern void Out() ;

extern void CopyCtx(void const *to , void const *from ) ;

extern void StoreRuntimeInt(void const *ctx , char const *attr , int n ) ;

extern int LoadRuntimeInt(void const *ctx , char const *attr ) ;

extern void Malloc(size_t buflen ) ;

extern void MallocE() ;

extern void LoadStackPtr(char const *name ) ;

extern void SetPtrStep() ;

extern void mute() ;

extern void unmute() ;

void load_buf(unsigned char const *buf , size_t len___0 , char const *hint___0 ) ;

void load_all(unsigned char const *buf , char const *hint___0 ) ;

void load_ctx(void const *ctx , char const *attr , char const *hint___0 ) ;

void load_int(long n , _Bool is_signed , size_t len___0 , char const *hint___0 ) ;

void load_str(char const *str ) ;

void len(_Bool is_signed , size_t lenlen ) ;

void test_intype(char const *type ) ;

void assume_intype(char const *type ) ;

void assume(int fact ) ;

void assume_len(unsigned char const *len___0 , _Bool is_signed , size_t width ) ;

void assume_len_at_most(unsigned char const *len___0 , _Bool is_signed , size_t width ) ;

void duplicate(void) ;

void clear(int n ) ;

void input(char const *hint___0 , size_t len___0 ) ;

void newTL(size_t len___0 , char const *type , char const *hint___0 ) ;

void newT(char const *type , char const *hint___0 ) ;

void varsym(char const *name ) ;

void fresh_var(char const *name_stem ) ;

void varWithBufInit(char const *name , unsigned char const **buf , unsigned char const *len___0 ,
                    size_t lenlen ) ;

void store_len(unsigned char const *buf , size_t width , _Bool is_signed ) ;

void output(void) ;

void store_buf(unsigned char const *buf ) ;

void store_all(unsigned char const *buf ) ;

void store_ctx(void const *ctx , char const *attr ) ;

void event(char const *sym , int nargs ) ;

void add_to_attr(void const *ctx , char const *attr , unsigned char const *buf ,
                 size_t len___0 ) ;

void set_attr_str(void const *ctx , char const *attr , char const *str ) ;

void set_attr_buf(void const *ctx , char const *attr , unsigned char const *buf ,
                  size_t len___0 ) ;

void set_attr_int(void const *ctx , char const *attr , int n ) ;

int get_attr_int(void const *ctx , char const *attr ) ;

void copy_ctx(void const *to , void const *from ) ;

void copy_attr_ex(void const *to , char const *attr_to , void const *from ,
                  char const *attr_from ) ;

void copy_attr(void const *to , void const *from , char const *attr ) ;

void clear_attr(void const *ctx , char const *attr ) ;

long concrete_val(long n ) ;

void fresh_ptr(size_t size ) ;

void fresh_ptrE(unsigned char *len___0 , size_t lenlen ) ;

void stack_ptr(char const *name ) ;

void test_intype(char const *type )
{


  {
  __CrestCall("test_intype", (void (*)())(& test_intype), 1);
  __CrestLoadStackPtr("symbolic_interface.c:type[3746]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:16");

  Dup();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:17");
  __CrestLoadStackPtr("symbolic_interface.c:type[3746]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  InType(type);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:18");

  Done();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:19");

  Test();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:14");
  __CrestReturn(1);

  return;
  }
}
}

void assume_intype(char const *type )
{


  {
  __CrestCall("assume_intype", (void (*)())(& assume_intype), 1);
  __CrestLoadStackPtr("symbolic_interface.c:type[3749]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:24");

  Dup();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:25");
  __CrestLoadStackPtr("symbolic_interface.c:type[3749]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  InType(type);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:26");

  Assume();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:22");
  __CrestReturn(1);

  return;
  }
}
}

void assume(int fact )
{


  {
  __CrestCall("assume", (void (*)())(& assume), 1);
  __CrestLoadStackPtr("symbolic_interface.c:fact[3752]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:31");

  mute();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:32");
  __CrestLoadStackPtr("symbolic_interface.c:fact[3752]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(!: [s,4] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if (! fact) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:34");
    __CrestLoadCString("assumption violated\n");
    __CrestApply("(CastToPtr: ptr -> ptr)");
    __CrestLoadInt((long long )1);
    __CrestSetPtrStep();
    __CrestDone();
    __CrestMute();

    printf((char const * __restrict )"assumption violated\n");
    __CrestUnmute();
    __CrestApply("(vararg_result() : bitstring -> bitstring)");
    __CrestNondet();
    __CrestClear(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:35");
    __CrestLoadInt((long long )1);
    __CrestBS(1, 4);

    exit(1);
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:37");

  unmute();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:39");
  __CrestLoadStackPtr("symbolic_interface.c:fact[3752]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )4);
  __CrestBS(0, 8);

  LoadBuf((unsigned char const *)(& fact), sizeof(fact));
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:40");

  Truth();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:41");

  Assume();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:29");
  __CrestReturn(1);

  return;
  }
}
}

void assume_len(unsigned char const *len___0 , _Bool is_signed , size_t width )
{


  {
  __CrestCall("assume_len", (void (*)())(& assume_len), 3);
  __CrestLoadStackPtr("symbolic_interface.c:width[3760]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3759]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3758]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:46");

  Dup();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:47");

  Len();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:48");
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3758]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:width[3760]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadBuf(len___0, width);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:49");
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3759]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:width[3760]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  Val(is_signed, (int )width);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:50");
  __CrestLoadCString("EqInt");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("EqInt", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:51");

  Assume();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:44");
  __CrestReturn(1);

  return;
  }
}
}

void assume_len_at_most(unsigned char const *len___0 , _Bool is_signed , size_t width )
{


  {
  __CrestCall("assume_len_at_most", (void (*)())(& assume_len_at_most), 3);
  __CrestLoadStackPtr("symbolic_interface.c:width[3768]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3767]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3766]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:56");

  Dup();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:57");

  Len();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:58");
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3766]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:width[3768]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadBuf(len___0, width);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:59");
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3767]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:width[3768]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  Val(is_signed, (int )width);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:60");
  __CrestLoadCString("LeInt");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("LeInt", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:61");

  Assume();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:54");
  __CrestReturn(1);

  return;
  }
}
}

void load_buf(unsigned char const *buf , size_t len___0 , char const *hint___0 )
{


  {
  __CrestCall("load_buf", (void (*)())(& load_buf), 3);
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3777]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3775]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:buf[3773]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:67");
  __CrestLoadStackPtr("symbolic_interface.c:buf[3773]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3775]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadBuf(buf, len___0);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:68");
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3777]");
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

  if ((unsigned long )hint___0 != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:68");
    __CrestLoadStackPtr("symbolic_interface.c:hint___0[3777]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    Hint(hint___0);
  } else {
    __CrestBranch(0);
  }
  }

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:65");
  __CrestReturn(1);

  return;
  }
}
}

void load_all(unsigned char const *buf , char const *hint___0 )
{


  {
  __CrestCall("load_all", (void (*)())(& load_all), 2);
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3783]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:buf[3781]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:73");
  __CrestLoadStackPtr("symbolic_interface.c:buf[3781]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadAll(buf);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:74");
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3783]");
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

  if ((unsigned long )hint___0 != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:74");
    __CrestLoadStackPtr("symbolic_interface.c:hint___0[3783]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    Hint(hint___0);
  } else {
    __CrestBranch(0);
  }
  }

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:71");
  __CrestReturn(1);

  return;
  }
}
}

void load_ctx(void const *ctx , char const *attr , char const *hint___0 )
{


  {
  __CrestCall("load_ctx", (void (*)())(& load_ctx), 3);
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3791]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3789]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3788]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:79");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3788]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3789]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadAttr(ctx, attr);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:80");
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3791]");
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

  if ((unsigned long )hint___0 != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:80");
    __CrestLoadStackPtr("symbolic_interface.c:hint___0[3791]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    Hint(hint___0);
  } else {
    __CrestBranch(0);
  }
  }

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:77");
  __CrestReturn(1);

  return;
  }
}
}

void load_int(long n , _Bool is_signed , size_t len___0 , char const *hint___0 )
{


  {
  __CrestCall("load_int", (void (*)())(& load_int), 4);
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3802]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3800]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3798]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:n[3797]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:85");
  __CrestLoadStackPtr("symbolic_interface.c:n[3797]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [s,8] -> [s,4])");
  __CrestDone();

  LoadInt((int )n);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:86");
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3798]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3800]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  BS(is_signed, (int )len___0);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:87");
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3802]");
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

  if ((unsigned long )hint___0 != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:87");
    __CrestLoadStackPtr("symbolic_interface.c:hint___0[3802]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    Hint(hint___0);
  } else {
    __CrestBranch(0);
  }
  }

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:83");
  __CrestReturn(1);

  return;
  }
}
}

void load_str(char const *str )
{


  {
  __CrestCall("load_str", (void (*)())(& load_str), 1);
  __CrestLoadStackPtr("symbolic_interface.c:str[3805]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:92");
  __CrestLoadStackPtr("symbolic_interface.c:str[3805]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadStr(str);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:90");
  __CrestReturn(1);

  return;
  }
}
}

void len(_Bool is_signed , size_t lenlen )
{


  {
  __CrestCall("len", (void (*)())(& len), 2);
  __CrestLoadStackPtr("symbolic_interface.c:lenlen[3810]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3809]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:97");

  Len();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:98");
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3809]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:lenlen[3810]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  BS(is_signed, (int )lenlen);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:99");

  Done();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:95");
  __CrestReturn(1);

  return;
  }
}
}

void input(char const *hint___0 , size_t len___0 )
{


  {
  __CrestCall("input", (void (*)())(& input), 2);
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3817]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3815]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:105");

  In();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:108");
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3817]");
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
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:109");
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3815]");
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

  if ((unsigned long )hint___0 != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:109");
    __CrestLoadStackPtr("symbolic_interface.c:hint___0[3815]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    Hint(hint___0);
  } else {
    __CrestBranch(0);
  }
  }

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:103");
  __CrestReturn(1);

  return;
  }
}
}

void newTL(size_t len___0 , char const *type , char const *hint___0 )
{


  {
  __CrestCall("newTL", (void (*)())(& newTL), 3);
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3826]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:type[3824]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3823]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:115");
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3823]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  LoadInt((int )len___0);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:116");
  __CrestLoadStackPtr("symbolic_interface.c:type[3824]");
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

  if ((unsigned long )type == (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:116");
    __CrestLoadCString("");

    LoadStr("");
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:117");
    __CrestLoadStackPtr("symbolic_interface.c:type[3824]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    LoadStr(type);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:118");

  New();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:119");

  Done();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:120");
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3826]");
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

  if ((unsigned long )hint___0 != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:120");
    __CrestLoadStackPtr("symbolic_interface.c:hint___0[3826]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    Hint(hint___0);
  } else {
    __CrestBranch(0);
  }
  }

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:113");
  __CrestReturn(1);

  return;
  }
}
}

void newT(char const *type , char const *hint___0 )
{


  {
  __CrestCall("newT", (void (*)())(& newT), 2);
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3832]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:type[3830]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:125");
  __CrestLoadInt((long long )-1);
  __CrestBS(1, 4);

  LoadInt(-1);
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:126");
  __CrestLoadStackPtr("symbolic_interface.c:type[3830]");
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

  if ((unsigned long )type == (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:126");
    __CrestLoadCString("");

    LoadStr("");
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:127");
    __CrestLoadStackPtr("symbolic_interface.c:type[3830]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    LoadStr(type);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:128");

  New();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:129");

  Done();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:130");
  __CrestLoadStackPtr("symbolic_interface.c:hint___0[3832]");
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

  if ((unsigned long )hint___0 != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:130");
    __CrestLoadStackPtr("symbolic_interface.c:hint___0[3832]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    Hint(hint___0);
  } else {
    __CrestBranch(0);
  }
  }

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:123");
  __CrestReturn(1);

  return;
  }
}
}

void store_len(unsigned char const *buf , size_t width , _Bool is_signed )
{


  {
  __CrestCall("store_len", (void (*)())(& store_len), 3);
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3839]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:width[3838]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:buf[3837]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:165");

  Dup();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:166");

  Len();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:167");
  __CrestLoadStackPtr("symbolic_interface.c:is_signed[3839]");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:width[3838]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  BS(is_signed, (int )width);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:168");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:169");
  __CrestLoadStackPtr("symbolic_interface.c:buf[3837]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreBuf(buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:163");
  __CrestReturn(1);

  return;
  }
}
}

void varsym(char const *name )
{


  {
  __CrestCall("varsym", (void (*)())(& varsym), 1);
  __CrestLoadStackPtr("symbolic_interface.c:name[3842]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:174");
  __CrestLoadStackPtr("symbolic_interface.c:name[3842]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  Env(name);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:172");
  __CrestReturn(1);

  return;
  }
}
}

void fresh_var(char const *name_stem )
{


  {
  __CrestCall("fresh_var", (void (*)())(& fresh_var), 1);
  __CrestLoadStackPtr("symbolic_interface.c:name_stem[3845]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:179");
  __CrestLoadStackPtr("symbolic_interface.c:name_stem[3845]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  FreshVar(name_stem);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:177");
  __CrestReturn(1);

  return;
  }
}
}

void varWithBufInit(char const *name , unsigned char const **buf , unsigned char const *len___0 ,
                    size_t lenlen )
{


  {
  __CrestCall("varWithBufInit", (void (*)())(& varWithBufInit), 4);
  __CrestLoadStackPtr("symbolic_interface.c:lenlen[3855]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3854]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:buf[3852]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:name[3851]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:205");
  __CrestLoadStackPtr("symbolic_interface.c:name[3851]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  varsym(name);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:208");

  Dup();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:210");

  Len();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:211");
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadStackPtr("symbolic_interface.c:lenlen[3855]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  BS((_Bool)0, (int )lenlen);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:212");

  Done();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:217");
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3854]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreBuf(len___0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:218");
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3854]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,1] -> [u,8])");
  __CrestDone();

  fresh_ptr((size_t )*len___0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:219");
  __CrestLoadStackPtr("symbolic_interface.c:buf[3852]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  StoreBuf((unsigned char const *)buf);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:220");
  __CrestLoadStackPtr("symbolic_interface.c:buf[3852]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreBuf(*buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:203");
  __CrestReturn(1);

  return;
  }
}
}

void duplicate(void)
{


  {
  __CrestCall("duplicate", & duplicate, 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:238");

  Dup();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:236");
  __CrestReturn(1);

  return;
  }
}
}

void clear(int n )
{


  {
  __CrestCall("clear", (void (*)())(& clear), 1);
  __CrestLoadStackPtr("symbolic_interface.c:n[3859]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:243");
  __CrestLoadStackPtr("symbolic_interface.c:n[3859]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  Clear(n);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:241");
  __CrestReturn(1);

  return;
  }
}
}

void store_buf(unsigned char const *buf )
{


  {
  __CrestCall("store_buf", (void (*)())(& store_buf), 1);
  __CrestLoadStackPtr("symbolic_interface.c:buf[3862]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:248");
  __CrestLoadStackPtr("symbolic_interface.c:buf[3862]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreBuf(buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:246");
  __CrestReturn(1);

  return;
  }
}
}

void store_all(unsigned char const *buf )
{


  {
  __CrestCall("store_all", (void (*)())(& store_all), 1);
  __CrestLoadStackPtr("symbolic_interface.c:buf[3865]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:253");
  __CrestLoadStackPtr("symbolic_interface.c:buf[3865]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreAll(buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:251");
  __CrestReturn(1);

  return;
  }
}
}

void store_ctx(void const *ctx , char const *attr )
{


  {
  __CrestCall("store_ctx", (void (*)())(& store_ctx), 2);
  __CrestLoadStackPtr("symbolic_interface.c:attr[3870]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3869]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:258");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3869]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3870]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreAttr(ctx, attr);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:256");
  __CrestReturn(1);

  return;
  }
}
}

void event(char const *sym , int nargs )
{


  {
  __CrestCall("event", (void (*)())(& event), 2);
  __CrestLoadStackPtr("symbolic_interface.c:nargs[3875]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:sym[3874]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:270");
  __CrestLoadStackPtr("symbolic_interface.c:sym[3874]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:nargs[3875]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  Event(sym, nargs);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:268");
  __CrestReturn(1);

  return;
  }
}
}

void output(void)
{


  {
  __CrestCall("output", & output, 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:275");

  Out();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:273");
  __CrestReturn(1);

  return;
  }
}
}

void add_to_attr(void const *ctx , char const *attr , unsigned char const *buf ,
                 size_t len___0 )
{


  {
  __CrestCall("add_to_attr", (void (*)())(& add_to_attr), 4);
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3886]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:buf[3884]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3883]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3882]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:280");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3882]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3883]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadAttr(ctx, attr);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:281");
  __CrestLoadStackPtr("symbolic_interface.c:buf[3884]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3886]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadBuf(buf, len___0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:282");

  Append();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:283");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3882]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3883]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreAttr(ctx, attr);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:278");
  __CrestReturn(1);

  return;
  }
}
}

void set_attr_str(void const *ctx , char const *attr , char const *str )
{


  {
  __CrestCall("set_attr_str", (void (*)())(& set_attr_str), 3);
  __CrestLoadStackPtr("symbolic_interface.c:str[3893]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3892]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3891]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:291");
  __CrestLoadStackPtr("symbolic_interface.c:str[3893]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadStr(str);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:292");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3891]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3892]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreAttr(ctx, attr);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:289");
  __CrestReturn(1);

  return;
  }
}
}

void set_attr_buf(void const *ctx , char const *attr , unsigned char const *buf ,
                  size_t len___0 )
{


  {
  __CrestCall("set_attr_buf", (void (*)())(& set_attr_buf), 4);
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3903]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:buf[3901]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3900]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3899]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:297");
  __CrestLoadStackPtr("symbolic_interface.c:buf[3901]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3903]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadBuf(buf, len___0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:298");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3899]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3900]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreAttr(ctx, attr);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:295");
  __CrestReturn(1);

  return;
  }
}
}

void set_attr_int(void const *ctx , char const *attr , int n )
{


  {
  __CrestCall("set_attr_int", (void (*)())(& set_attr_int), 3);
  __CrestLoadStackPtr("symbolic_interface.c:n[3910]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3909]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3908]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:303");
  __CrestLoadStackPtr("symbolic_interface.c:n[3910]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadInt(n);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:304");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3908]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3909]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreAttr(ctx, attr);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:306");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3908]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3909]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:n[3910]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreRuntimeInt(ctx, attr, n);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:301");
  __CrestReturn(1);

  return;
  }
}
}

int get_attr_int(void const *ctx , char const *attr )
{
  int ret ;
  int tmp ;

  {
  __CrestCall("get_attr_int", (void (*)())(& get_attr_int), 2);
  __CrestLoadStackPtr("symbolic_interface.c:attr[3915]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3914]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:311");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3914]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3915]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadAttr(ctx, attr);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:312");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3914]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3915]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  tmp = LoadRuntimeInt(ctx, attr);
  __CrestLoadStackPtr("symbolic_interface.c:tmp[3917]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:312");
  __CrestLoadStackPtr("symbolic_interface.c:tmp[3917]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:ret[3916]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestStore();

  ret = tmp;
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:313");
  __CrestLoadStackPtr("symbolic_interface.c:ret[3916]");
  __CrestLoadInt((long long )4);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void clear_attr(void const *ctx , char const *attr )
{


  {
  __CrestCall("clear_attr", (void (*)())(& clear_attr), 2);
  __CrestLoadStackPtr("symbolic_interface.c:attr[3922]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3921]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:318");
  __CrestLoadStackPtr("symbolic_interface.c:ctx[3921]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3922]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  set_attr_str(ctx, attr, "");

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:316");
  __CrestReturn(1);

  return;
  }
}
}

void copy_ctx(void const *to , void const *from )
{


  {
  __CrestCall("copy_ctx", (void (*)())(& copy_ctx), 2);
  __CrestLoadStackPtr("symbolic_interface.c:from[3927]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:to[3926]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:323");
  __CrestLoadStackPtr("symbolic_interface.c:to[3926]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:from[3927]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  CopyCtx(to, from);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:321");
  __CrestReturn(1);

  return;
  }
}
}

void copy_attr_ex(void const *to , char const *attr_to , void const *from ,
                  char const *attr_from )
{


  {
  __CrestCall("copy_attr_ex", (void (*)())(& copy_attr_ex), 4);
  __CrestLoadStackPtr("symbolic_interface.c:attr_from[3936]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:from[3935]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:attr_to[3934]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:to[3933]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:328");
  __CrestLoadStackPtr("symbolic_interface.c:from[3935]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr_from[3936]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadAttr(from, attr_from);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:329");
  __CrestLoadStackPtr("symbolic_interface.c:to[3933]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr_to[3934]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreAttr(to, attr_to);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:326");
  __CrestReturn(1);

  return;
  }
}
}

void copy_attr(void const *to , void const *from , char const *attr )
{


  {
  __CrestCall("copy_attr", (void (*)())(& copy_attr), 3);
  __CrestLoadStackPtr("symbolic_interface.c:attr[3943]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:from[3942]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:to[3941]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:334");
  __CrestLoadStackPtr("symbolic_interface.c:to[3941]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3943]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:from[3942]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:attr[3943]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  copy_attr_ex(to, attr, from, attr);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:332");
  __CrestReturn(1);

  return;
  }
}
}

long concrete_val(long n )
{
  long ret ;

  {
  __CrestCall("concrete_val", (void (*)())(& concrete_val), 1);
  __CrestLoadStackPtr("symbolic_interface.c:n[3946]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:339");
  __CrestLoadStackPtr("symbolic_interface.c:n[3946]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("symbolic_interface.c:ret[3947]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  ret = n;

  __CrestLoadInt((long long )n);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:341");
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  BS((_Bool)1, (int )sizeof(ret));
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:342");
  __CrestLoadStackPtr("symbolic_interface.c:ret[3947]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  store_buf((unsigned char const *)(& ret));
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:343");
  __CrestLoadStackPtr("symbolic_interface.c:ret[3947]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestReturn(0);

  return (ret);
  }
}
}

void fresh_ptr(size_t size )
{


  {
  __CrestCall("fresh_ptr", (void (*)())(& fresh_ptr), 1);
  __CrestLoadStackPtr("symbolic_interface.c:size[3950]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:355");
  __CrestLoadStackPtr("symbolic_interface.c:size[3950]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  Malloc(size);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:353");
  __CrestReturn(1);

  return;
  }
}
}

void fresh_ptrE(unsigned char *len___0 , size_t lenlen )
{


  {
  __CrestCall("fresh_ptrE", (void (*)())(& fresh_ptrE), 2);
  __CrestLoadStackPtr("symbolic_interface.c:lenlen[3956]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3955]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:360");
  __CrestLoadStackPtr("symbolic_interface.c:len___0[3955]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("symbolic_interface.c:lenlen[3956]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("nullPtr");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();

  load_buf((unsigned char const *)len___0, lenlen, (char const *)((void *)0));
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:361");
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadStackPtr("symbolic_interface.c:lenlen[3956]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  Val((_Bool)0, (int )lenlen);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:362");

  MallocE();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:358");
  __CrestReturn(1);

  return;
  }
}
}

void stack_ptr(char const *name )
{


  {
  __CrestCall("stack_ptr", (void (*)())(& stack_ptr), 1);
  __CrestLoadStackPtr("symbolic_interface.c:name[3959]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:369");
  __CrestLoadStackPtr("symbolic_interface.c:name[3959]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  LoadStackPtr(name);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:370");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  LoadInt(1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:371");

  SetPtrStep();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/symbolic_interface.c:367");
  __CrestReturn(1);

  return;
  }
}
}
