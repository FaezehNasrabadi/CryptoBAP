/*
Copyright (c) 2009-2013, Mickaël Delahaye, http://micdel.fr

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
*/

#include <stdio.h>
#include <yices_c.h>

/* Yices_c additional functions */

// Given on yices-help by Bruno Dutertre (2009-12-16)
extern void yices_interrupt(yices_context ctx);

typedef void* yicesl_context;

// Given on yices-help by Bruno Dutertre (2010-06-01)
extern yicesl_context yices_get_lite_context(yices_context ctx);

#define yicesl_log_file_error int
#define yicesl_output_file_error int

/* Virtual types and names*/

#define yices_error int
#define yices_error_with_message int
#define yices_log_file_error int
#define yices_type_ptr yices_type*
#define srec_p srec_t*
#define yices_scalar_name const char*
#define yices_scalar_int int

#define True l_true
#define False l_false
#define Undef l_undef


/* srec handler */

#define srec2string(s) copy_string((*(s))->str)


/* Unsat core array */

struct unsat_core {
  int length;
  assertion_id* array;
};


/* Check macros */

#define check_yices_error(e) if ((e) == 0) caml_failwith("cannot get a value")
#define check_yices_error_with_message(e) if ((e) == 0) \
  caml_failwith(yices_get_last_error_message())
#define check_yices_log_file_error(e) do {\
  if ((e) == 0) caml_failwith("enable_log_file: log file already open");\
  else if ((e) == -1) caml_failwith("enable_log_file: cannot open log file");\
} while (0)

#define CHECKNOTNULL(p,m) if ((p) == (void*)0) caml_failwith("null return value (" m ")")
#define check_expr(e) CHECKNOTNULL(e,"expression")
#define check_type(e) CHECKNOTNULL(e,"type")
#define check_var_decl(e) CHECKNOTNULL(e,"variable declaration")
#define check_context(e) CHECKNOTNULL(e,"context")
#define check_model(e) CHECKNOTNULL(e,"model")
#define check_var_decl_iterator(e) CHECKNOTNULL(e,"iterator")
#define check_scalar_int(e) if ((e) < 0) caml_failwith("cannot get scalar value as int")
#define check_scalar_name(e) CHECKNOTNULL(e,"string")

/* Yicesl macros */
#define yicesl_error int
#define check_yicesl_error(res) if (!(res)) caml_failwith(yicesl_get_last_error_message())
#define check_yicesl_context(res) CHECKNOTNULL(res,"Yicesl context")

