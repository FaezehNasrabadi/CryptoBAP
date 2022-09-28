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

#include <yicesl_c.h>

#define yicesl_error int
#define yicesl_log_file_error int
#define yicesl_output_file_error int

#define check_yicesl_error(res) if (res == 0) caml_failwith(yicesl_get_last_error_message())
#define check_yicesl_context(res) if (res == (void*)0) caml_failwith("null return value (Yicesl context)")
#define check_yicesl_log_file_error(e) do {\
  if ((e) == 0) caml_failwith("enable_log_file: log file already open");\
  else if ((e) == -1) caml_failwith("enable_log_file: cannot open log file");\
} while (0)
#define check_yicesl_output_file_error(e) if ((e) == 0) caml_failwith("set_output_file: cannot open output file");
