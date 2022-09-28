# 1 "./common.cil.c"
# 1 "/home/faezeh/csec-modex/proxies//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "./common.cil.c"



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

extern void proxy_fail(char const *fmt , ...) ;

void get_envE(unsigned char **buf , unsigned char const *len___0 , size_t lenlen ,
              char const *name ) ;

void get_env(unsigned char **buf , size_t *len___0 , char const *name ) ;

void readenv(unsigned char const *buf , size_t const *len___0 , char const *name ) ;

void readenvE(unsigned char const *buf , unsigned char const *len___0 , size_t lenlen ,
              char const *name ) ;

void readenvL(unsigned char const *buf , size_t len___0 , char const *name ) ;

void make_sym(unsigned char const *buf , size_t len___0 , char const *s ) ;

void event0(char const *s ) ;

void event1(char const *s , unsigned char const *buf , size_t len___0 ) ;

void event2(char const *s , unsigned char const *buf1 , size_t len1 , unsigned char const *buf2 ,
            size_t len2 ) ;

void event3(char const *s , unsigned char const *buf1 , size_t len1 , unsigned char const *buf2 ,
            size_t len2 , unsigned char const *buf3 , size_t len3 ) ;

void event4(char const *s , unsigned char const *buf1 , size_t len1 , unsigned char const *buf2 ,
            size_t len2 , unsigned char const *buf3 , size_t len3 , unsigned char const *buf4 ,
            size_t len4 ) ;

void typehint(unsigned char const *buf , size_t len___0 , char const *type ) ;

void hint(unsigned char const *buf , size_t len___0 , char const *name ) ;

void append_zero(unsigned char const *buf ) ;

void assume_string(unsigned char const *name ) ;

extern void BS(_Bool is_signed , int width ) ;

extern void SymN(char const *sym , int n ) ;

extern void Env(char const *name ) ;

extern void Len() ;

extern void Dup() ;

extern void Clear(int n ) ;

extern void Nondet() ;

extern void Done() ;

extern void Assume() ;

extern void Append() ;

extern void Hint(char const *hint ) ;

extern void StoreBuf(unsigned char const *buf ) ;

extern void TypeHint(char const *type ) ;

extern void load_buf(unsigned char const *buf , size_t len , char const *hint ) ;

extern void load_all(unsigned char const *buf , char const *hint ) ;

extern void load_int(long n , _Bool is_signed , size_t width , char const *hint ) ;

extern void assume_intype(char const *type ) ;

extern void assume_len(unsigned char const *len , _Bool is_signed , size_t width ) ;

extern void store_buf(unsigned char const *buf ) ;

extern void store_all(unsigned char const *buf ) ;

extern void event(char const *sym , int nargs ) ;

extern void fresh_ptrE(unsigned char *len , size_t lenlen ) ;

void get_envE(unsigned char **buf , unsigned char const *len___0 , size_t lenlen ,
              char const *name )
{


  {
  __CrestCall("get_envE", (void (*)())(& get_envE), 4);
  __CrestLoadStackPtr("common.c:name[3753]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:lenlen[3752]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len___0[3751]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf[3749]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:21");
  __CrestLoadStackPtr("common.c:name[3753]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  Env(name);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:22");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:24");

  Dup();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:25");

  Len();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:26");
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadStackPtr("common.c:lenlen[3752]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  BS((_Bool)0, (int )lenlen);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:27");

  Done();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:29");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:30");
  __CrestLoadStackPtr("common.c:len___0[3751]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreBuf(len___0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:32");
  __CrestLoadStackPtr("common.c:len___0[3751]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("common.c:lenlen[3752]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();

  fresh_ptrE((unsigned char *)len___0, lenlen);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:33");
  __CrestLoadStackPtr("common.c:buf[3749]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  StoreBuf((unsigned char const *)buf);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:35");
  __CrestLoadStackPtr("common.c:buf[3749]");
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

  StoreBuf((unsigned char const *)*buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:16");
  __CrestReturn(1);

  return;
  }
}
}

void get_env(unsigned char **buf , size_t *len___0 , char const *name )
{
  size_t lenlen ;

  {
  __CrestCall("get_env", (void (*)())(& get_env), 3);
  __CrestLoadStackPtr("common.c:name[3761]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len___0[3760]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf[3758]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:40");
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("common.c:lenlen[3762]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();

  lenlen = sizeof(*len___0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:41");
  __CrestLoadStackPtr("common.c:buf[3758]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len___0[3760]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadStackPtr("common.c:lenlen[3762]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:name[3761]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  get_envE(buf, (unsigned char const *)len___0, lenlen, name);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:38");
  __CrestReturn(1);

  return;
  }
}
}

void readenvE(unsigned char const *buf , unsigned char const *len___0 , size_t lenlen ,
              char const *name )
{


  {
  __CrestCall("readenvE", (void (*)())(& readenvE), 4);
  __CrestLoadStackPtr("common.c:name[3772]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:lenlen[3771]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len___0[3770]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf[3768]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:46");
  __CrestLoadStackPtr("common.c:lenlen[3771]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )0UL);
  __CrestBS(0, 8);
  __CrestApply("(==: [u,8] * [u,8] -> [s,4])");
  __CrestDone();
  __CrestTruth();

  if (lenlen == 0UL) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:48");
    __CrestLoadCString("readenvE: you certainly don\'t want lenlen = 0\n");
    __CrestMute();

    proxy_fail("readenvE: you certainly don\'t want lenlen = 0\n");
    __CrestUnmute();
    __CrestClear(1);
  } else {
    __CrestBranch(0);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:51");
  __CrestLoadStackPtr("common.c:name[3772]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  Env(name);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:52");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:54");

  Dup();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:55");

  Len();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:56");
  __CrestLoadInt((long long )(_Bool)0);
  __CrestBS(0, 1);
  __CrestLoadStackPtr("common.c:lenlen[3771]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToInt: [u,8] -> [s,4])");
  __CrestDone();

  BS((_Bool)0, (int )lenlen);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:57");

  Done();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:59");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:61");
  __CrestLoadStackPtr("common.c:len___0[3770]");
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

  if ((unsigned long )len___0 != (unsigned long )((void *)0)) {
    __CrestBranch(1);
    __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:62");
    __CrestLoadStackPtr("common.c:len___0[3770]");
    __CrestApply("ptrLen/0");
    __CrestSetPtrStep();
    __CrestLoadMem();

    StoreBuf(len___0);
  } else {
    __CrestBranch(0);
    __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:64");
    __CrestLoadInt((long long )1);
    __CrestBS(1, 4);

    Clear(1);
  }
  }
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:66");
  __CrestLoadStackPtr("common.c:buf[3768]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreBuf(buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:44");
  __CrestReturn(1);

  return;
  }
}
}

void readenv(unsigned char const *buf , size_t const *len___0 , char const *name )
{


  {
  __CrestCall("readenv", (void (*)())(& readenv), 3);
  __CrestLoadStackPtr("common.c:name[3780]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len___0[3779]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf[3777]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:71");
  __CrestLoadStackPtr("common.c:buf[3777]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len___0[3779]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();
  __CrestLoadInt((long long )8);
  __CrestBS(0, 8);
  __CrestLoadStackPtr("common.c:name[3780]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  readenvE(buf, (unsigned char const *)len___0, sizeof(*len___0), name);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:69");
  __CrestReturn(1);

  return;
  }
}
}

void readenvL(unsigned char const *buf , size_t len___0 , char const *name )
{


  {
  __CrestCall("readenvL", (void (*)())(& readenvL), 3);
  __CrestLoadStackPtr("common.c:name[3788]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len___0[3787]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf[3785]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:77");
  __CrestLoadStackPtr("common.c:name[3788]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  Env(name);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:78");
  __CrestLoadCString("bitstring");

  assume_intype("bitstring");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:79");
  __CrestLoadStackPtr("common.c:len___0[3787]");
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
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:81");
  __CrestLoadStackPtr("common.c:buf[3785]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  StoreBuf(buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:75");
  __CrestReturn(1);

  return;
  }
}
}

void make_sym(unsigned char const *buf , size_t len___0 , char const *s )
{


  {
  __CrestCall("make_sym", (void (*)())(& make_sym), 3);
  __CrestLoadStackPtr("common.c:s[3796]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len___0[3795]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf[3793]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:86");
  __CrestLoadStackPtr("common.c:s[3796]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  SymN(s, 0);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:87");
  __CrestLoadStackPtr("common.c:len___0[3795]");
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
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:88");
  __CrestLoadStackPtr("common.c:s[3796]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  Hint(s);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:89");

  Nondet();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:90");
  __CrestLoadStackPtr("common.c:buf[3793]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  store_buf(buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:84");
  __CrestReturn(1);

  return;
  }
}
}

void event0(char const *s )
{


  {
  __CrestCall("event0", (void (*)())(& event0), 1);
  __CrestLoadStackPtr("common.c:s[3799]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:95");
  __CrestLoadStackPtr("common.c:s[3799]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )0);
  __CrestBS(1, 4);

  event(s, 0);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:93");
  __CrestReturn(1);

  return;
  }
}
}

void event1(char const *s , unsigned char const *buf , size_t len___0 )
{


  {
  __CrestCall("event1", (void (*)())(& event1), 3);
  __CrestLoadStackPtr("common.c:len___0[3807]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf[3805]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:s[3804]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:100");
  __CrestLoadStackPtr("common.c:buf[3805]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len___0[3807]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf, len___0, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:101");
  __CrestLoadStackPtr("common.c:s[3804]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  event(s, 1);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:98");
  __CrestReturn(1);

  return;
  }
}
}

void event2(char const *s , unsigned char const *buf1 , size_t len1 , unsigned char const *buf2 ,
            size_t len2 )
{


  {
  __CrestCall("event2", (void (*)())(& event2), 5);
  __CrestLoadStackPtr("common.c:len2[3818]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf2[3817]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len1[3816]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf1[3815]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:s[3814]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:106");
  __CrestLoadStackPtr("common.c:buf1[3815]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len1[3816]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf1, len1, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:107");
  __CrestLoadStackPtr("common.c:buf2[3817]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len2[3818]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf2, len2, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:108");
  __CrestLoadStackPtr("common.c:s[3814]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  event(s, 2);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:104");
  __CrestReturn(1);

  return;
  }
}
}

void event3(char const *s , unsigned char const *buf1 , size_t len1 , unsigned char const *buf2 ,
            size_t len2 , unsigned char const *buf3 , size_t len3 )
{


  {
  __CrestCall("event3", (void (*)())(& event3), 7);
  __CrestLoadStackPtr("common.c:len3[3833]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf3[3832]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len2[3831]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf2[3830]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len1[3829]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf1[3828]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:s[3827]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:115");
  __CrestLoadStackPtr("common.c:buf1[3828]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len1[3829]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf1, len1, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:116");
  __CrestLoadStackPtr("common.c:buf2[3830]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len2[3831]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf2, len2, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:117");
  __CrestLoadStackPtr("common.c:buf3[3832]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len3[3833]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf3, len3, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:118");
  __CrestLoadStackPtr("common.c:s[3827]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )3);
  __CrestBS(1, 4);

  event(s, 3);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:111");
  __CrestReturn(1);

  return;
  }
}
}

void event4(char const *s , unsigned char const *buf1 , size_t len1 , unsigned char const *buf2 ,
            size_t len2 , unsigned char const *buf3 , size_t len3 , unsigned char const *buf4 ,
            size_t len4 )
{


  {
  __CrestCall("event4", (void (*)())(& event4), 9);
  __CrestLoadStackPtr("common.c:len4[3852]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf4[3851]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len3[3850]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf3[3849]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len2[3848]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf2[3847]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len1[3846]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf1[3845]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:s[3844]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:126");
  __CrestLoadStackPtr("common.c:buf1[3845]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len1[3846]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf1, len1, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:127");
  __CrestLoadStackPtr("common.c:buf2[3847]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len2[3848]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf2, len2, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:128");
  __CrestLoadStackPtr("common.c:buf3[3849]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len3[3850]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf3, len3, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:129");
  __CrestLoadStackPtr("common.c:buf4[3851]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len4[3852]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf4, len4, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:130");
  __CrestLoadStackPtr("common.c:s[3844]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadInt((long long )4);
  __CrestBS(1, 4);

  event(s, 4);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:121");
  __CrestReturn(1);

  return;
  }
}
}

void typehint(unsigned char const *buf , size_t len___0 , char const *type )
{


  {
  __CrestCall("typehint", (void (*)())(& typehint), 3);
  __CrestLoadStackPtr("common.c:type[3860]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len___0[3859]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf[3857]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:135");
  __CrestLoadStackPtr("common.c:buf[3857]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len___0[3859]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf, len___0, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:136");
  __CrestLoadStackPtr("common.c:type[3860]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  TypeHint(type);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:137");
  __CrestLoadStackPtr("common.c:buf[3857]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  store_buf(buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:133");
  __CrestReturn(1);

  return;
  }
}
}

void hint(unsigned char const *buf , size_t len___0 , char const *name )
{


  {
  __CrestCall("hint", (void (*)())(& hint), 3);
  __CrestLoadStackPtr("common.c:name[3868]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:len___0[3867]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLoadStackPtr("common.c:buf[3865]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:142");
  __CrestLoadStackPtr("common.c:buf[3865]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadStackPtr("common.c:len___0[3867]");
  __CrestLoadInt((long long )8);
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_buf(buf, len___0, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:143");
  __CrestLoadStackPtr("common.c:name[3868]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  Hint(name);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:144");
  __CrestLoadStackPtr("common.c:buf[3865]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  store_buf(buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:140");
  __CrestReturn(1);

  return;
  }
}
}

void append_zero(unsigned char const *buf )
{


  {
  __CrestCall("append_zero", (void (*)())(& append_zero), 1);
  __CrestLoadStackPtr("common.c:buf[3871]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:149");
  __CrestLoadStackPtr("common.c:buf[3871]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestLoadCString("");

  load_all(buf, "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:150");
  __CrestLoadInt((long long )0L);
  __CrestBS(1, 8);
  __CrestLoadInt((long long )(_Bool)1);
  __CrestBS(0, 1);
  __CrestLoadInt((long long )1);
  __CrestBS(0, 8);
  __CrestLoadCString("");

  load_int(0L, (_Bool)1, sizeof(char ), "");
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:152");

  Append();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:153");
  __CrestLoadStackPtr("common.c:buf[3871]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();

  store_all(buf);

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:147");
  __CrestReturn(1);

  return;
  }
}
}

void assume_string(unsigned char const *name )
{


  {
  __CrestCall("assume_string", (void (*)())(& assume_string), 1);
  __CrestLoadStackPtr("common.c:name[3874]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestStore();
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:158");
  __CrestLoadStackPtr("common.c:name[3874]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  Env((char const *)name);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:159");
  __CrestLoadCString("ztpSafe");
  __CrestLoadInt((long long )1);
  __CrestBS(1, 4);

  SymN("ztpSafe", 1);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:160");
  __CrestLoadStackPtr("common.c:name[3874]");
  __CrestApply("ptrLen/0");
  __CrestSetPtrStep();
  __CrestLoadMem();
  __CrestApply("(CastToPtr: ptr -> ptr)");
  __CrestLoadInt((long long )1);
  __CrestSetPtrStep();
  __CrestDone();

  Env((char const *)name);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:161");
  __CrestLoadCString("=");
  __CrestLoadInt((long long )2);
  __CrestBS(1, 4);

  SymN("=", 2);
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:162");

  Assume();

  {
  __CrestLocation("/home/faezeh/csec-modex/proxies/common.c:156");
  __CrestReturn(1);

  return;
  }
}
}
