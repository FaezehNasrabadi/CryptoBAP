/* Copyright (c) 2008, Jacob Burnim (jburnim@cs.berkeley.edu)
 * Copyright (c) 2010, Mihhail Aizatulin (avatar@hot.ee)
 *
 * See LICENSE file for copyright notice.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See LICENSE
 * for details.
 */

/*
 * Changes by Misha:
 *
 * - all changes that correspond to those recorded in crestInstrument.ml
 *
 * - it is now possible to call __CrestCustomReturn() to provide custom return value
 */

#ifndef LIBCREST_CREST_H__
#define LIBCREST_CREST_H__

/*
 * FIXME: now with pointer instrumentation this explanation is obsolete.
 *
 * During instrumentation, the folowing function calls are inserted in the
 * C code under test.
 *
 * These calls (loosely) correspond to an execution of the program
 * under test by a stack machine.  It is intended that these calls be
 * used to symbolically execute the program under test, by maintaining
 * a a symbolic stack (along with a symbolic memory map).  Specifically:
 *
 *  - A C expression (with no side effects) generates a series of Load
 *    and Apply calls corresponding to the "postfix" evaluation of the
 *    expression, using a stack (i.e. a Load indicates that a value is
 *    pushed onto the stack, and unary and binary operations are applied
 *    to one/two values popped off the stack).  For example, the expression
 *    "a*b > 3+c" would generate the instrumentation:
 *        Load(&a, a)
 *        Load(&b, b)
 *        ApplyBinOp(MULTIPLY, a*b)
 *        Load(0, 3)
 *        Load(&c, c)
 *        ApplyBinOp(ADD, 3+c)
 *        ApplyBinOp(GREATER_THAN, a*b > 3+c)
 *    Note that each Load and Apply call includes the concrete value either
 *    loaded or computed.  Also note that constants are treated as having
 *    address "0".
 *
 * - Entering the then- or else-block of an if statement generates a Branch
 *   call indicating which branch was taken.  The branch is on the value
 *   popped from the stack.  For example, "if (a*b > 3+c) ..." generates
 *   the series of Load and Apply calls above, plus one of:
 *       Branch(true_id,  1)
 *       Branch(false_id, 0)
 *
 * - An assignment statement generates a single Store call, indicating
 *   that a value is popped off the stack and stored in the given address.
 *   For example, "a = 3 + b" generates:
 *        Load(0, 3)
 *        Load(&b, b)
 *        ApplyBinOp(ADD, 3+b)
 *        Store(&a)
 *
 * - The instrumentation for function calls is somewhat complicated,
 *   because we have to handle the case where an instrumented code
 *   calls an un-instrumented function.  (We currently forbid
 *   un-instrumented code from calling back into instrumented code.)
 *
 *   * For all calls, the actual function arguments are pushed onto
 *     the stack.  In the body of the called function (if
 *     instrumented), these values are Stored in the formal
 *     parameters.  (See example below.)
 *
 *   * In the body of the called function, "return e" generates the
 *     instrumentation for expression "e", followed by a call to
 *     Return(1).  An void "return" statement generates a call to Return(0).
 *
 *   * If the returned value is assigned to some variable -- e.g.
 *     "z = max(a, 7)" -- then two calls are generated:
 *         HandleReturn([concrete returned value], [number of function arguments])
 *         Store(&z)
 *     If, instead, the return value is ignored -- e.g. "max(a, 7);"
 *     -- a single call to ClearFrame([number of function arguments]) is generated.
 *
 *     [The difficultly here is that, if the called function was not
 *      instrumented, the stack will still contain the function arguments on top,
 *      so HandleReturn must clean them up and then
 *      load the concrete returned value onto the stack to then be
 *      stored.  If the called function is instrumented, then HandleReturn
 *      need not modify the stack -- it already has the returned value on top.]
 *
 *    * Full example:  Consider the function "add(x, y) { return x+y; }".
 *      A call "z = add(a, 7)" generates instrumentation calls:
 *          Load(&a, a)
 *          Load(0, 7)
 *          Call(add)
 *          Store(&y)
 *          Store(&x)
 *          Load(&x, x)
 *          Load(&y, y)
 *          ApplyBinOp(ADD, x+y)
 *          Return(1)
 *          HandleReturn(z, 2)
 *          Store(&z)
 *
 * - A symbolic input generates a call to create a new symbol (passing
 *   the conrete initial value for that symbol).
 *
 *   [We pass the conrete value and have signed/unsigned versions only
 *   to make it easier to exactly capture/print the concrete inputs to
 *   the program under test.]
 */

/*
   As an extra feature, the functions in the code are allowed to call CustomReturn()
   explicitly if they wish to provide custom symbolic return value. This doesn't affect
   the instrumentation, so a normal Return() call is still inserted.
   The Return() call needs to take appropriate actions to remove the symbolic return value
   constructed by the instrumentation, so that the custom value will remain on top of the stack
   instead.

   You must not call any other function between CustomReturn() and Return(), for instance,
   instead of

     CustomReturn()
     return f()

   you must write

     tmp = f();
     CustomReturn();
     return tmp;
 */

#ifdef __cplusplus
#define EXTERN extern "C"
#else
#define EXTERN extern
#endif

#include <stdbool.h>
#include <stdlib.h>

typedef void (*funPtr)(void);

/*
 * Type definitions.
 *
 * We use these obscure MACRO's rather than the definitions in basic_types.h
 * in an attempt to avoid clashing with names in instrumented programs
 * (and also because C does not support namespaces).
 */
#define __CREST_ID int
#define __CREST_BRANCH_ID int
#define __CREST_FUNCTION_ID unsigned int
#define __CREST_VALUE long long
#define __CREST_SIZE unsigned int
#define __CREST_ADDR unsigned long int
#define __CREST_OP char const *
#define __CREST_BOOL unsigned char
#define __CREST_STR char const *
#define __CREST_CHAR char
#define __CREST_FUN_PTR funPtr

/*
 * Short-cut to indicate that a function should be skipped during
 * instrumentation.
 */
#define __SKIP __attribute__((__crest_skip__))

///////////////////////////////////////////
// Instrumentation functions
///////////////////////////////////////////

EXTERN void __CrestInit() __SKIP;
EXTERN void __CrestClear(__CREST_VALUE) __SKIP;
EXTERN void __CrestInvoke(__CREST_FUN_PTR) __SKIP;
//EXTERN void __CrestApply1(__CREST_ID, __CREST_OP, __CREST_VALUE) __SKIP;
//EXTERN void __CrestApply2(__CREST_ID, __CREST_OP, __CREST_VALUE) __SKIP;
EXTERN void __CrestApply(__CREST_OP) __SKIP;
EXTERN void __CrestSimplify(__CREST_VALUE) __SKIP;
EXTERN void __CrestNondet() __SKIP;
EXTERN void __CrestMute() __SKIP;
EXTERN void __CrestUnmute() __SKIP;
EXTERN void __CrestBranch(__CREST_BOOL) __SKIP;
EXTERN void __CrestCall(__CREST_STR name, __CREST_FUN_PTR f, __CREST_VALUE nargs) __SKIP;
EXTERN void __CrestCallOpaque(__CREST_STR name, __CREST_FUN_PTR f, __CREST_VALUE nargs) __SKIP;
EXTERN void __CrestReturn(__CREST_BOOL is_void) __SKIP;
// EXTERN void __CrestCustomReturn(__CREST_ID) __SKIP;
EXTERN void __CrestStore() __SKIP;
EXTERN void __CrestStoreBuf() __SKIP;
EXTERN void __CrestLoadInt(__CREST_VALUE val) __SKIP;
EXTERN void __CrestBS(int is_signed, int width);
// LoadMem always reads the size of the pointer
EXTERN void __CrestLoadMem() __SKIP;
// Converts to hex and puts the string into heap
EXTERN void __CrestLoadCString(__CREST_STR val) __SKIP;
EXTERN void __CrestLoadString(__CREST_STR val) __SKIP;
EXTERN void __CrestLoadChar(__CREST_CHAR val) __SKIP;
EXTERN void __CrestLoadTypeSize(__CREST_STR ctype) __SKIP;
// EXTERN void __CrestSetLen() __SKIP;
EXTERN void __CrestSetPtrStep() __SKIP;
EXTERN void __CrestLoadStackPtr(__CREST_STR var) __SKIP;
EXTERN void __CrestFieldOffset(__CREST_STR field) __SKIP;
EXTERN void __CrestIndexOffset(__CREST_STR type) __SKIP;
EXTERN void __CrestLocation(__CREST_STR) __SKIP;
EXTERN void __CrestDone() __SKIP;
EXTERN void __CrestTruth() __SKIP;
EXTERN void __CrestAssumeDefined() __SKIP;

///////////////////////////////////////////////////////
// Helpers, to be called only from instrumented code
///////////////////////////////////////////////////////

EXTERN void LoadBuf(const unsigned char * buf, size_t len);
EXTERN void LoadAll(const unsigned char * buf);
EXTERN void LoadAttr(const void * ctx, const char * attr);
EXTERN void LoadInt(int n);
EXTERN void BS(bool is_signed, int width);
EXTERN void Val(bool is_signed, int width);
EXTERN void LoadStr(const char * str);
EXTERN void SymT(const char * sym);
EXTERN void SymN(const char * sym, int n);
EXTERN void In();
EXTERN void New();
EXTERN void Env(const char * name);
EXTERN void FreshVar(const char * name_stem);
EXTERN void Len();
EXTERN void InType(const char * type);
EXTERN void Dup();
EXTERN void Clear(int n);
EXTERN void Nondet();
EXTERN void Done();
EXTERN void Test();
EXTERN void Assume();
EXTERN void Truth();
EXTERN void Event(const char * sym, int n);
EXTERN void Append();
EXTERN void Hint(const char * hint);
EXTERN void StoreBuf(const unsigned char * buf);
EXTERN void StoreAll(const unsigned char * buf);
EXTERN void StoreAttr(const void * ctx, const char * attr);
EXTERN void Out();
EXTERN void CopyCtx(const void * to, const void * from);
EXTERN void StoreRuntimeInt(const void * ctx, const char * attr, int n);
EXTERN int LoadRuntimeInt(const void * ctx, const char * attr);
EXTERN void Malloc(size_t buflen);
EXTERN void MallocE();
EXTERN void LoadStackPtr(const char * name);
EXTERN void SetPtrStep();
EXTERN void TypeHint(const char * type);

#endif  /* LIBCREST_CREST_H__ */
