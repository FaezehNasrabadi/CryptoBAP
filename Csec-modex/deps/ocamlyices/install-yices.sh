#!/bin/sh

# Copyright (c) 2009-2013, Mickaël Delahaye, http://micdel.fr
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

default_prefix=/usr/local
default_bindir_suffix=/bin
default_libdir_suffix=/lib
default_includedir_suffix=/include

warning() {
  echo "[YI] Warning! $*"
}

failwith() {
  echo "[YI] Error! $*"
  exit 1
}

print_info() {
  echo "[YI] $*"
}

print_verbose() {
  if [ -n "$verbose" ]; then
    print_info "$@"
  fi
}

prev=
num=0
for arg; do
  if [ -n "$prev" ]; then
    eval $prev=\$arg
    prev=
    continue
  fi
  
  case $arg in
  *=?*) value=`expr "X$arg" : '[^=]*=\(.*\)'` ;;
  *)   value= ;;
  esac
  
  case "$arg" in
  -verbose|-verb|-v|--verbose|--verb|--v)
    verbose=yes;;
  -help|-hel|-he|-h|--help|--hel|--he|--h)
    show_help=yes;;
  -prefix|--prefix)
    prev=prefix;;
  -libdir|-libdi|-libd|-lib|--libdir|--libdi|--libd|--lib)
    prev=libdir;;
  -includedir|-includedi|-included|-include|--includedir|--includedi|--included|--include)
    prev=includedir;;
  -bindir|-bindi|-bind|-bin|--bindir|--bindi|--bind|--bin)
    prev=bindir;;
  -prefix=*|--prefix=*)
    prefix=$value;;
  -libdir=*|-libdi=*|-libd=*|-lib=*|--libdir=*|--libdi=*|--libd=*|--lib=*)
    libdir=$value;;
  -includedir=*|-includedi=*|-included=*|-include=*|--includedir=*|--includedi=*|--included=*|--include=*)
    includedir=$value;;
  -bindir=*|-bindi=*|-bind=*|-bin=*|--bindir=*|--bindi=*|--bind=*|--bin=*)
    bindir=$value;;
  *)
    case $num in
    0)
      tarball=$arg;;
    1)
      warning "Legacy prefix argument, please use '--prefix $arg'"
      prefix=$arg;;
    2)
      warning "Legacy library argument, please use '--libdir $arg'"
      libdir=$arg;;
    *)
      warning "Extra argument ignored \"$arg\"";;
    esac
    num=`expr $num + 1`;;
  esac
done

if [ -n "$prev" ]; then
   failwith "Missing argument to option --$prev"
fi

if [ -n "$show_help" ]; then
  echo "Yices installer (as part of Ocamlyices)"
  echo
  echo "Usage: $0  [OPTION...] TARBALL"
  echo
  echo "Install Yices (binary, libraries and headers) given a tarball downloaded from"
  echo "  http://yices.csl.sri.com/download.shtml"
  echo
  echo "Options:"
  echo "  -h, --help        Show help otions"
  echo "  --prefix=PREFIX   Set prefix path (by default $default_prefix)"
  echo "  --bindir=DIR      Set path to user executables (by default PREFIX$default_bindir_suffix)"
  echo "  --libdir=DIR      Set path to object code libraries (by default PREFIX$default_libdir_suffix)"
  echo "  --includedir=DIR  Set path to C header files (by default PREFIX$default_includedir_suffix)"
  exit 0
fi

prefix="${prefix:-$default_prefix}"
bindir="${bindir:-$prefix$default_bindir_suffix}"
libdir="${libdir:-$prefix$default_libdir_suffix}"
includedir="${includedir:-$prefix$default_includedir_suffix}"
tarball="`readlink -f "$tarball"`"

print_verbose "prefix: $prefix"
print_verbose "bindir: $bindir"
print_verbose "libdir: $libdir"
print_verbose "includedir: $includedir"
print_verbose "tarball: $tarball"

if touch $includedir/yices_c.h > /dev/null 2> /dev/null; then
  rm $includedir/yices_c.h
elif which sudo > /dev/null 2> /dev/null; then
  warning "Cannot write in $includedir"
  if [ "x$0" = xsh ]; then
    print_verbose "Cannot get the script filename: the script will be downloaded from Github"
    print_info "Let me sudo that for you\n    wget -q -O- http://git.io/sWxMmg | sudo $0 -s $@"
    wget -q -O- http://git.io/sWxMmg | sudo $0 -s "$@"
    exit 0
  else
    print_info "Let me sudo that for you\n    sudo $0 $@"
    exec sudo $0 "$@"
  fi
else
  failwith "Cannot install Yices (check write permission)"
fi

tempdir="`mktemp -dt yices-install.XXX`"

mkdir -p "$tempdir"
cd "$tempdir"
tar -xzf "$tarball" || failwith "Cannot decompress $tarball"

cd yices*

if [ ! -f lib/libyices.so ]; then
	print_info "No shared libary present -> libgmp not needed"
fi

LIBS=`find lib/ \( -name '*.a' -o -name '*.so' \) -not -name 'cyg*.dll'`
LIBS_CYG=`find lib/ -name 'cyg*.dll'`

print_info 'Install libraries'
install -t "$libdir" $LIBS || failwith "Cannot install libraries"
if [ -n "$LIBS_CYG" ]; then
  install -t "$bindir" $LIBS_CYG || failwith "Cannot install libraries"
fi
if which ldconfig > /dev/null 2> /dev/null; then
  ldconfig || warning 'ldconfig failed'
else
  warning 'ldconfig not found'
fi

print_info 'Install headers'
mkdir -p "$includedir"
install -t "$includedir" -m 'a=r,u+w' include/*.h || failwith 'Cannot install headers'

if [ -f bin/yices ]; then
  print_info 'Install executable'
  mkdir -p "$bindir"
  install -t "$bindir" bin/yices || failwith 'Cannot install executable'
else
  print_info 'Library only version: no executable installed'
fi

cd
print_info 'Cleaning up'
rm -rf "$tempdir"

print_info 'Done'

