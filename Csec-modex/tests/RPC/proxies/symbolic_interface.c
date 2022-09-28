// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "interface.h"

#include "crest.h"

#include <stdbool.h>

// Things implemented in crestify.cpp:
// mute, unmute

void test_intype(const char * type)
{
  Dup();
  InType(type);
  Done();
  Test();
}

void assume_intype(const char * type)
{
  Dup();
  InType(type);
  Assume();
}

void assume(int fact)
{
  mute();
  if(!fact)
    {
      printf("assumption violated\n");
      exit(1);
    }
  unmute();

  LoadBuf(&fact, sizeof(fact));
  Truth();
  Assume();
}

void assume_len(const unsigned char * len, bool is_signed, size_t width)
{
  Dup();
  Len();
  LoadBuf(len, width);
  Val(is_signed, width);
  SymN("EqInt", 2);
  Assume();
}

void assume_len_at_most(const unsigned char * len, bool is_signed, size_t width)
{
  Dup();
  Len();
  LoadBuf(len, width);
  Val(is_signed, width);
  SymN("LeInt", 2);
  Assume();
}


void load_buf(const unsigned char * buf, size_t len, const char * hint)
{
  LoadBuf(buf, len);
  if(hint != NULL) Hint(hint);
}

void load_all(const unsigned char * buf, const char * hint)
{
  LoadAll(buf);
  if(hint != NULL) Hint(hint);
}

void load_ctx(const void * ctx, const char * attr, const char * hint)
{
  LoadAttr(ctx, attr);
  if(hint != NULL) Hint(hint);
}

void load_int(long n, bool is_signed, size_t len, const char * hint)
{
  LoadInt(n);
  BS(is_signed, len);
  if(hint != NULL) Hint(hint);
}

void load_str(const char * str)
{
  LoadStr(str);
}

void len(bool is_signed, size_t lenlen)
{
  Len();
  BS(is_signed, lenlen);
  Done();
}


void input(const char * hint, size_t len)
{
  In();
  // It's fine to assume here since not receiving enough input will not result
  // in termination.
  assume_len(&len, false, sizeof(len));
  if (hint != NULL) Hint(hint);
}


void newTL(size_t len, const char * type, const char * hint)
{
  LoadInt(len);
  if(type == NULL) LoadStr("");
  else LoadStr(type);
  New();
  Done();
  if(hint != NULL) Hint(hint);
}

void newT(const char * type, const char * hint)
{
  LoadInt(-1);
  if(type == NULL) LoadStr("");
  else LoadStr(type);
  New();
  Done();
  if(hint != NULL) Hint(hint);
}


/*
void newTN(const char * type, const char * hint, size_t * len)
{
  LoadStr(type);
  New();
  Done();
  if(hint != NULL) Hint(hint);

  if(len != NULL)
  {
    Dup();
    Len();
    SetLen(sizeof(*len));
    Done();
    // Hint("len");
    StoreBuf((unsigned char *) len);
  }
}

void newL(const char * hint, size_t len)
{
  LoadInt(len);
  New();
  SetLen(len);
  Done();
  if(hint != NULL) Hint(hint);
}
*/

void store_len(const unsigned char * buf, size_t width, bool is_signed)
{
  Dup();
  Len();
  BS(is_signed, width);
  assume_intype("bitstring");
  StoreBuf(buf);
}

void varsym(const char * name)
{
  Env(name);
}

void fresh_var(const char * name_stem)
{
  FreshVar(name_stem);
}

/*
void var(const char * name, const unsigned char * buf, const unsigned char * len, size_t lenlen)
{
  varsym(name);

  if(len != NULL){
    Dup();
    Len();
    BS(false, lenlen);
    Done();
    // Hint("len");

    StoreBuf(len);
  }

  // len will most probably be incomparable with the length of the buffer contents,
  // so we use StoreAll.
  StoreAll(buf);
}
*/

void varWithBufInit(const char * name, const unsigned char ** buf, const unsigned char * len, size_t lenlen)
{
  varsym(name);
  // stack -> name

  Dup();
  // stack -> name, name
  Len();
  BS(false, lenlen);
  Done();
  // Hint("len");

  // stack -> len(name), name

  StoreBuf(len);
  fresh_ptr(*len);
  StoreBuf(buf);
  StoreBuf(*buf);
}

/*
void varL(const char * name, const unsigned char * buf, size_t len)
{
  varsym(name);
  assume_len(len);
  Done();
  // Hint(name);

  // See var for why we use StoreAll
  StoreAll(buf);
}
*/

void duplicate()
{
  Dup();
}

void clear(int n)
{
  Clear(n);
}

void store_buf(const unsigned char * buf)
{
  StoreBuf(buf);
}

void store_all(const unsigned char * buf)
{
  StoreAll(buf);
}

void store_ctx(const void * ctx, const char * attr)
{
  StoreAttr(ctx, attr);
}

/*long int lhs_int(long int n, const char * hint)
{
  Hint(hint);
  CustomReturn();
  return n;
}*/

void event(const char * sym, int nargs)
{
  Event(sym, nargs);
}

void output()
{
  Out();
}

void add_to_attr(const void * ctx, const char * attr, const unsigned char * buf, size_t len)
{
  LoadAttr(ctx, attr);
  LoadBuf(buf, len);
  Append();
  StoreAttr(ctx, attr);
}

/*
 * FIXME: potential unsoundness because of bypassing buffer2string()
 */
void set_attr_str(const void * ctx, const char * attr, const char * str)
{
  LoadStr(str);
  StoreAttr(ctx, attr);
}

void set_attr_buf(const void * ctx, const char * attr, const unsigned char * buf, size_t len)
{
  LoadBuf(buf, len);
  StoreAttr(ctx, attr);
}

void set_attr_int(const void * ctx, const char * attr, int n)
{
  LoadInt(n);
  StoreAttr(ctx, attr);

  StoreRuntimeInt(ctx, attr, n);
}

int get_attr_int(const void * ctx, const char * attr)
{
  LoadAttr(ctx, attr);
  int ret = LoadRuntimeInt(ctx, attr);
  return ret;
}

void clear_attr(const void * ctx, const char * attr)
{
  set_attr_str(ctx, attr, "");
}

void copy_ctx(const void * to, const void * from)
{
  CopyCtx(to, from);
}

void copy_attr_ex(const void * to, const char * attr_to, const void * from, const char * attr_from)
{
  LoadAttr(from, attr_from);
  StoreAttr(to, attr_to);
}

void copy_attr(const void * to, const void * from, const char * attr)
{
  copy_attr_ex(to, attr, from, attr);
}

long int concrete_val(long int n)
{
  long int ret = n;
  __CrestLoadInt(n);
  BS(true, sizeof(ret));
  store_buf(&ret);
  return ret;
}

//void * fresh_ptr(void * p, int size)
//{
//  NewHeapPtr(size);
//  CustomReturn();
//  return p;
//}

void fresh_ptr(size_t size)
{
  Malloc(size);
}

void fresh_ptrE(unsigned char * len, size_t lenlen)
{
  load_buf(len, lenlen, NULL);
  Val(false, lenlen);
  MallocE();
}



void stack_ptr(const char * name)
{
  LoadStackPtr(name);
  LoadInt(1);
  SetPtrStep();
}

