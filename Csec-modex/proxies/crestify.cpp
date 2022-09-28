
// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "common_internal.h"

#include "crest.h"
#include "interface.h"

#include <iostream>
#include <fstream>
#include <map>

// for exit()
#include <stdlib.h>

// for strlen()
#include <string.h>
#include <stdbool.h>

////////////////////////////////////////////////////////
// Shared State
////////////////////////////////////////////////////////

int muted = 0;

int lastFreshVar = 0;

/**
 * output channel.
 */
ostream * out;


////////////////////////////////////////////////////////
// Helpers, to be called only from uninstrumented code
////////////////////////////////////////////////////////

void __CrestLoadHeapPtr(int id)
{
  if(muted) return;

  *out << "LoadHeapPtr " << id << endl;
  *out << "LoadInt 1" << endl;
  *out << "SetPtrStep" << endl;
}


/////////////////////////////////////////////////////////////////////////
// Instrumentation Functions, to be called only from uninstrumented code
/////////////////////////////////////////////////////////////////////////


/**
 * The pointer to the function that is being called right now.
 * Used by Call() to detect when the function is invoked from non-instrumented code.
 */
// This doesn't work when we link with a dynamic library
// but neither are we using it
// EXTERN int main(int, char**);
// funPtr calledFun = (funPtr)&main;

void __CrestInit()
{
  if(getenv("CVM_OUTPUT") == NULL)
    out = &cout;
  else
    out = new ofstream(getenv("CVM_OUTPUT"));
}

void __CrestClear(__CREST_VALUE n)
{
  if(muted) return;

  for(int i = 0; i < n; i++)
    *out << "Clear" << endl;
}

void __CrestInvoke(__CREST_FUN_PTR f)
{
  if(muted) return;

  f();
}

//void __CrestApply1(__CREST_OP op, __CREST_VALUE val)
//{
//  if(muted) return;
//
//  *out << "ApplyOp " << op << " " << 1 << endl;
//  *out << "ConcreteResult  " << val << endl;
//}
//
//void __CrestApply2(__CREST_OP op, __CREST_VALUE val)
//{
//  if(muted) return;
//
//  *out << "ApplyOp " << op << " " << 2 << endl;
//  *out << "ConcreteResult  " << val << endl;
//}

void __CrestApply(__CREST_OP op)
{
  if(muted) return;

  *out << "Apply " << endl << op << endl;
}

// For internal use only
void __CrestApplyN(__CREST_OP op, __CREST_VALUE n)
{
  if(muted) return;

  *out << "Apply " << endl << op << "/" << n << endl;
}


void __CrestNondet()
{
  if(muted) return;

  *out << "Nondet" << endl;
}

void __CrestMute()
{
  mute();
}

void __CrestUnmute()
{
  unmute();
}

void __CrestBranch(__CREST_BOOL cond)
{
  if(muted) return;

  *out << "Branch " << (bool) cond << endl;
}

void __CrestCall(__CREST_STR name, __CREST_FUN_PTR f, __CREST_VALUE nargs)
{
  if(muted) return;

  *out << "Call " << name << " " << nargs << endl;
}

void __CrestCallOpaque(__CREST_STR name, __CREST_FUN_PTR f, __CREST_VALUE nargs)
{
  if(!muted) {
    *out << "ERROR: Opaque function calls must be muted: " << name << endl;
  }
}

void __CrestReturn(__CREST_BOOL is_void)
{
  if(muted) return;

  *out << "Return" << endl;
}

void __CrestStore()
{
  if(muted) return;

  *out << "StoreMem " << endl;
}

void __CrestStoreBuf()
{
  if(muted) return;

  *out << "StoreBuf " << endl;
}


void __CrestLoadInt(__CREST_VALUE val)
{
  if(muted) return;

  *out << "LoadInt " << val << endl;
}

void __CrestBS(int is_signed, int width)
{
  if(muted) return;

  if(is_signed)
    *out << "BS_signed " << width << endl;
  else
    *out << "BS_unsigned " << width << endl;
}

void __CrestVal(int is_signed, int width)
{
  if(muted) return;

  if(is_signed)
    *out << "Val_signed " << width << endl;
  else
    *out << "Val_unsigned " << width << endl;
}

void __CrestLoadMem()
{
  if(muted) return;

  // Always uses the size of the pointer
  *out << "LoadMem" << endl;
}

void __CrestLoadCString(__CREST_STR val)
{
  if(muted) return;

  int len = strlen(val);
  *out << "LoadCStr " << endl << buffer2string((const unsigned char *) val, len) << endl;
}

void __CrestLoadString(__CREST_STR val)
{
  if(muted) return;

  // int len = strlen(val);
  *out << "LoadStr " << endl << val << endl;
}

void __CrestLoadTypeSize(__CREST_STR val)
{
  if(muted) return;

  *out << "LoadStr " << endl << val << endl;
  __CrestApplyN("DummyOfType", 1);
  *out << "Len" << endl;
}

void __CrestLoadChar(__CREST_CHAR c)
{
  if(muted) return;

  *out << "LoadChar " << c << endl;
}

void __CrestSetLen()
{
  if(muted) return;

  *out << "SetLen" << endl;
}

void __CrestSetPtrStep()
{
  if(muted) return;

  *out << "SetPtrStep" << endl;
}

void __CrestLoadStackPtr(__CREST_STR var)
{
  if(muted) return;

  *out << "LoadStackPtr " << var << endl;
}

void __CrestFieldOffset(__CREST_STR field)
{
  if(muted) return;

  *out << "FieldOffset " << field << endl;
}

void __CrestIndexOffset(__CREST_STR type)
{
  if(muted) return;

  *out << "IndexOffset" << endl << type << endl;
}

void __CrestLocation(__CREST_STR loc)
{
  if(muted) return;

  *out << "// " << loc;
  // if(muted) *out << " (muted)";
  *out << endl;
}

void __CrestDone()
{
  if(muted) return;

  *out << "Done" << endl;
}

void __CrestTruth()
{
  if(muted) return;

  *out << "Truth" << endl;
}

void __CrestAssumeDefined()
{
  if(muted) return;

  *out << "Dup" << endl;
  *out << "InType bitstring" << endl;
  *out << "Assume" << endl;
}


//////////////////////////////////////////////////////////////////
// Interface functions, to be called only from instrumented code
//////////////////////////////////////////////////////////////////

map<const void *, map<string, int> > int_attributes;


/**
 * It is important that mute() and unmute() have no parameters and return values.
 * Otherwise they would need to take special care of them when turning off the instrumentation.
 */
void mute()
{
  muted++;
}

void unmute()
{
  // don't go into negative
  // FIXME: in fact, it would be an error if unmute() is called on 0?
  if(muted) muted--;
}


void LoadBuf(const unsigned char * buf, size_t len)
{
  if(muted) return;
  *out << "LoadBuf" << endl;
}

void LoadAll(const unsigned char * buf)
{
  if(muted) return;
  *out << "LoadAll" << endl;
}

void LoadAttr(const void * ctx, const char * attr)
{
  if(muted) return;

  // remove attr from stack, it's not symbolic
  __CrestClear(1);
  *out << "CtxOffset " << attr << endl;
  *out << "LoadAll " << endl;
}

void LoadInt(int n)
{
  if(muted) return;

  __CrestClear(1);
  *out << "LoadInt " << n << endl;
}

void BS(bool is_signed, int width)
{
  if(muted) return;

  __CrestClear(2);
  if(is_signed)
    *out << "BS_signed " << width << endl;
  else
    *out << "BS_unsigned " << width << endl;
}

void Val(bool is_signed, int width)
{
  if(muted) return;

  __CrestClear(2);
  __CrestVal(is_signed, width);
}


void LoadStr(const char * str)
{
  if(muted) return;

  __CrestClear(1);
  *out << "LoadStr " << endl << str << endl;
}

void SymT(const char * sym)
{
  if(muted) return;

  // Discard the parameters from symbolic stack
  __CrestClear(1);
  __CrestApply(sym);
}

void SymN(const char * sym, int n)
{
  if(muted) return;

  // Discard the parameters from symbolic stack
  __CrestClear(2);
  __CrestApplyN(sym, n);
}

void In()
{
  if(muted) return;

  *out << "In " << endl;
}


void New()
{
  if(muted) return;

  *out << "New " << endl;
}

void Env(const char * name)
{
  if(muted) return;

  // Discard the parameters from symbolic stack
  __CrestClear(1);
  *out << "Env " << name << endl;
}

void FreshVar(const char * name_stem)
{
  if(muted) return;

  // Discard the parameters from symbolic stack
  __CrestClear(1);
  *out << "Env " << name_stem << lastFreshVar++ << endl;
}

void InType(const char * type)
{
  if(muted) return;

  __CrestClear(1);
  *out << "InType " << type << endl;
}

void Len()
{
  if(muted) return;

  *out << "Len " << endl;
}


void Dup()
{
  if(muted) return;

  *out << "Dup " << endl;
}

void Clear(int n)
{
  if(muted) return;

  __CrestClear(1);
  for(int i = 0; i < n; i++)
    *out << "Clear" << endl;
}

void Nondet()
{
  if(muted) return;

  __CrestNondet();
}

void Done()
{
  if(muted) return;

  __CrestDone();
}

EXTERN void Test()
{
  if(muted) return;

  *out << "Branch " << true << endl;
}

EXTERN void Assume()
{
  if(muted) return;

  *out << "Assume " << endl;
}

void Truth()
{
  if(muted) return;

  *out << "Truth" << endl;
}


void Event(const char * sym, int n)
{
  if(muted) return;

  __CrestClear(2);
  *out << "Event " << sym << " " << n << endl;
}

void Append()
{
  if(muted) return;

  *out << "Append" << endl;
}

void Hint(const char * hint)
{
  if(muted) return;

  __CrestClear(1);

  if(string(hint) != "")
    *out << "Hint " << hint << endl;
}

void SetLen(size_t len)
{
  if(muted) return;

  *out << "SetLen" << endl;
}

void StoreBuf(const unsigned char * buf)
{
  if(muted) return;

  __CrestStoreBuf();
}

void StoreAll(const unsigned char * buf)
{
  if(muted) return;

  *out << "StoreAll" << endl;
}

void StoreAttr(const void * ctx, const char * attr)
{
  if(muted) return;

  // remove attr from stack
  __CrestClear(1);
  *out << "CtxOffset " << attr << endl;
  *out << "StoreAll " << endl;
}

void Out()
{
  if(muted) return;

  *out << "Out " << endl;
}


void CopyCtx(const void * to, const void * from)
{
  if(muted) return;

  *out << "CopyCtx" << endl;
}

void StoreRuntimeInt(const void * ctx, const char * attr, int n)
{
  // if(muted) return; (this is runtime, so no muting)

  __CrestClear(3);
  int_attributes[ctx][string(attr)] = n;
}

int LoadRuntimeInt(const void * ctx, const char * attr)
{
  // if(muted) return; (this is runtime, so no muting)

  __CrestClear(2);
  int n = int_attributes[ctx][string(attr)];
  __CrestLoadInt(n);
  return n;
}

void Malloc(size_t buflen)
{
  if(muted) return;

  // Keep buflen on stack
  __CrestVal(false, sizeof(buflen));
  *out << "Malloc" << endl;
}

void MallocE()
{
  if(muted) return;

  *out << "Malloc" << endl;
}


void LoadStackPtr(const char * name)
{
  if(muted) return;

  __CrestClear(1);
  __CrestLoadStackPtr(name);
}

void SetPtrStep()
{
  if(muted) return;

  __CrestSetPtrStep();
}


void TypeHint(const char * type)
{
  if(muted) return;

  __CrestClear(1);
  *out << "TypeHint " << type << endl;
}
