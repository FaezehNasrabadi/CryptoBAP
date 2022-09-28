// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

#include "common.h"

#include <stddef.h>

EXTERN int ( __attribute__((__cdecl__)) memcmp_proxy)(void const   * ,
                                                      void const   * , size_t  ) ;

EXTERN void *( __attribute__((__cdecl__)) memcpy_proxy)(void * ,
                                                        void const   * ,
                                                        size_t  ) ;

EXTERN void *( __attribute__((__cdecl__)) memmove_proxy)(void * ,
                                                         void const   * ,
                                                         size_t  ) ;

extern int strncmp_proxy(char const   *__s1 , char const   *__s2 , size_t __n );

extern  __attribute__((__nothrow__)) int strcmp_proxy(char const   *__s1 , char const   *__s2 )  __attribute__((__pure__,
__nonnull__(1,2))) ;

extern void *malloc_proxy(size_t __size );

extern void *__builtin_alloca_proxy(unsigned long  ) ;

extern  void *realloc_proxy(void *__ptr , size_t __size );

extern  __attribute__((__nothrow__)) void *memset_proxy(void *__s , int __c , size_t __n )  __attribute__((__nonnull__(1))) ;

extern ssize_t read_proxy(int __fd , void *__buf , size_t __nbytes ) ;

extern ssize_t write_proxy(int __fd , void const   *__buf , size_t __n ) ;

extern  __attribute__((__nothrow__)) char *strcpy_proxy(char * __restrict  __dest ,
                                                        char const   * __restrict  __src )  __attribute__((__nonnull__(1,2))) ;

extern size_t strlen_proxy(const char *s);
