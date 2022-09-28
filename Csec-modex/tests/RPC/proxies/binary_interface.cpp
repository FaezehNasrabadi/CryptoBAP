
// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.

extern "C"
{
  #include "interface.h"
}

#include "common_internal.h"

#include <map>
#include <iostream>
#include <cstdarg>
#include <sstream>

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// #define DEBUG_ATTR

map<const void *, map<string, string> > string_attributes;
map<const void *, map<string, int> >    int_attributes;

bool muted = false;

///////////////////////////////////////////
// Helpers
///////////////////////////////////////////

void print_delim()
{
  printf("=====================================================\n");
}

string get_attr(const void * ctx, string attr)
{
  if(ctx == NULL)
    cerr << "get_attr: ctx is NULL" << endl;
  return string_attributes[ctx][attr];
}

/**
 * Set the attribute to a long unique value.
 */
void unique_attr(const void * ctx, string attr)
{
  ostringstream str;

  // FIXME: how to properly test for existence?
  if(string_attributes[ctx].find(attr) != string_attributes[ctx].end())
  {
    cerr << "give_id: id already given" << endl;
    return;
  }
  string_attributes[ctx][attr] = "";

  for(int i = 0; i < 10; i++) str << rand();
  string_attributes[ctx][attr] = str.str();
}

void print_rhs(string s, const char * hint)
{
  if(muted) return;

  cout << "\t" << hint << ":" << s << endl;
}

///////////////////////////////////////////
// Interface Functions
///////////////////////////////////////////

extern "C"
{

void mute()
{
  muted = true;
}

void unmute()
{
  muted = false;
}


void sym(const char * s)
{
  if(muted) return;

  cout << s << endl;
}

void load_buf(const unsigned char * buf, size_t len, const char * hint)
{
  if(muted) return;

  printf("\t%s:", hint);
  print_buffer(buf, len);
  printf("\n");
}

void load_ctx(const void * ctx, const char * attr, const char * hint)
{
  #ifdef DEBUG_ATTR
    load_buf(pointer2string(ctx), "ctx");
    load_buf(attr, "attr");
  #endif

  print_rhs(string_attributes[ctx][string(attr)], hint);
}

extern void load_int(int n, const char * hint)
{
  if(muted) return;

  cout << "\t" << hint << ":" << n << endl;
}

void print_lhs(string s, string hint)
{
  if(muted) return;

  cout << "\t" << hint << ":" << s << endl;
  print_delim();
}

void lhs_buf(const unsigned char * buf, size_t len, const char * hint)
{
  if(muted) return;

  if(buf != NULL)
  {
    printf("\t%s:", hint);
    print_buffer(buf, len);
    printf("\n");
  }

  print_delim();
}

void store_ctx(const void * ctx, const char * attr, const char * hint)
{
  string sattr = string(attr);
  unique_attr(ctx, sattr);
  print_lhs(string_attributes[ctx][sattr], hint);

  #ifdef DEBUG_ATTR
    load_buf(pointer2string(ctx), "ctx");
    load_buf(attr, "attr");
    sym("get_attr");
  #endif
}

void add_to_attr(const void * ctx, const char * attr, const unsigned char * buf, size_t len)
{
  #ifdef DEBUG_ATTR
    load_buf(pointer2string(ctx), "ctx");
    load_buf(s, "attr");
    load_buf(buf, len, "value");
    sym("append_attr");
  #endif
  string_attributes[ctx][string(attr)] += buffer2string(buf, len);
}

void set_attr_buf(const void * ctx, const char * attr, const unsigned char * buf, size_t len)
{
  if(len == 0)
    cerr << "set_attr(buf, len): new value is empty" << endl;

  #ifdef DEBUG_ATTR
    load_buf(pointer2string(ctx), "ctx");
    load_buf(s, "attr");
    load_buf(buf, len, "value");
    sym("set_attr");
  #endif
  string_attributes[ctx][string(attr)] = buffer2string(buf, len);
}

void set_attr_str(const void * ctx, const char * attr, const char * str)
{
  if(strlen(str) == 0)
    cerr << "set_attr(char*): new value is empty" << endl;

  #ifdef DEBUG_ATTR
    load_buf(pointer2string(ctx), "ctx");
    load_buf(s, "attr");
    load_buf(string(str), "value");
    sym("set_attr");
  #endif
  string_attributes[ctx][string(attr)] = string(str);
}

extern void set_attr_int(const void * ctx, const char * attr, int n)
{
  int_attributes[ctx][string(attr)] = n;
}

int get_attr_int(const void * ctx, const char * attr)
{
  return int_attributes[ctx][string(attr)];
}

void copy_ctx(const void * to, const void * from)
{
  #ifdef DEBUG_ATTR
    load_buf(pointer2string(from), "from");
    load_buf(pointer2string(to), "to");
    sym("copy_attr");
  #endif

  string_attributes[to] = string_attributes[from];
}

void copy_attr_ex(const void * to, const char * attr_to, const void * from, const char * attr_from)
{
  string value = get_attr(from, string(attr_from));

  if(value == "")
    cerr << "copy_attr(): new value is empty" << endl;

  #ifdef DEBUG_ATTR
    load_buf(pointer2string(ctx), "ctx");
    load_buf(s, "attr");
    load_buf(value, "value");
    sym("copy_attr");
  #endif

  string_attributes[to][string(attr_to)] = value;
}

void copy_attr(const void * to, const void * from, const char * attr)
{
  copy_attr_ex(to, attr, from, attr);
}

void clear_attr(const void * ctx, const char * attr)
{
  #ifdef DEBUG_ATTR
    load_buf(pointer2string(ctx), "ctx");
    load_buf(attr, "attr");
    sym("clear_attr");
  #endif

  string sattr = string(attr);

  string_attributes[ctx][sattr] = "";
  int_attributes[ctx][sattr] = 0;
}

}
