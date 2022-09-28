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

AC_INIT(ocamlyices,0.8.0)

CFLAGS="-O3 -fPIC"
LIBS="-lstdc++ -lm"

AC_PROG_CC
AC_PROG_CXX
AC_PROG_RANLIB

################################################################################
# Ocaml ########################################################################

AC_CHECK_PROG([OCAMLC], [ocamlc], [ocamlc])
AS_IF([test "x$OCAMLC" = x], [
  AC_MSG_ERROR(Cannot find ocamlc.)
])

AC_MSG_CHECKING([for OCaml version])
OCAMLVERSION=`$OCAMLC -version`
AC_MSG_RESULT([$OCAMLVERSION])

AC_MSG_CHECKING([for OCaml stdlib path])
OCAMLLIB=`$OCAMLC -where`
AC_MSG_RESULT([$OCAMLLIB])

LDFLAGS="$LDFLAGS -L$OCAMLLIB"
CPPFLAGS="$CPPFLAGS -I$OCAMLLIB"

AC_CHECK_PROG([OCAMLFIND], [ocamlfind], [ocamlfind])
AS_IF([ test "x$OCAMLFIND" = x ], [
  AC_MSG_ERROR([Cannot find ocamlfind.])
])

AC_CHECK_PROG([OCAMLOPT], [ocamlopt], [ocamlopt])
AS_IF([ test "x$OCAMLOPT" = x ], [
  AC_MSG_ERROR([Cannot find ocamlopt.])
])

AC_MSG_CHECKING([for OCaml version consistency])
TMPVERSION=`$OCAMLOPT -version`
AS_IF([ test "$TMPVERSION" != "$OCAMLVERSION" ], [
  AC_MSG_RESULT([no])
  AC_MSG_ERROR([Version differs $TMPVERSION != $OCAMLVERSION])
], [
  AC_MSG_RESULT([yes])
])

AC_CHECK_PROG([OCAMLDOC], [ocamldoc], [ocamldoc])
AS_IF([ test "x$OCAMLDOC" = x ], [
  AC_MSG_ERROR([Cannot find ocamldoc.])
])

################################################################################
# Camlidl ######################################################################

AC_CHECK_PROG([CAMLIDL], [camlidl], [camlidl])
AS_IF([ test "x$CAMLIDL" = x ], [
  AC_MSG_ERROR(Cannot find camlidl.)
])

AC_MSG_CHECKING([for camlidl's package])
CAMLIDLPATH=`ocamlfind query camlidl || true`
AS_IF([ test "x$CAMLIDLPATH" = x ], [
  AC_MSG_RESULT([unknown])
], [
  AC_MSG_RESULT([$CAMLIDLPATH])
  AC_MSG_NOTICE([add camlidl to library search path])
  CPPFLAGS="$CPPFLAGS -I$CAMLIDLPATH"
  LDFLAGS="$LDFLAGS -L$CAMLIDLPATH"
])

AC_CHECK_HEADER([caml/camlidlruntime.h], [], [
  AC_MSG_ERROR([Cannot find "caml/camlidlruntime.h".])
])

################################################################################
# Yices library ################################################################

# Add Yices as a library dependency
LIBS="-lyices $LIBS"

# Checks if GMP is built in Yices (if it is there)
AC_CHECK_FUNC([__gmpz_init], [
  STATIC_YICES=yes
], [
  # __gmpz_init is not available yet, but, for all we know, neither is Yices
  STATIC_YICES=
  # add GMP, reported to be needed on some systems (tari3x), still stands?
  LIBS="$LIBS -lgmp"
])

# Checks if Yices is really there now (with GMP if needed)
AC_CHECK_FUNC([yices_version], [], [
  AC_MSG_ERROR([Cannot find yices.

Please download and install Yices 1.0.40 or more recent (but not 2).
(1) Download the latest tarball of Yices from SRI website:
  http://yices.csl.sri.com/download.shtml
(2) Install it on your system (libraries and headers).
You may use either the following command:

wget -q -O- http://git.io/sWxMmg | sh -s yices-XYZ.tar.gz

In both case, yices-XYZ.tar.gz should be replaced with the path to the
downloaded tarball. Also, additional parameters can be added to specify
installation directories (root and library path), e.g.:

wget -q -O- http://git.io/sWxMmg | sh -s <yices-XYZ.tar.gz> --prefix /opt --libdir /opt/lib64
])
])

# Prints linking information
AS_IF([ test -n "$STATIC_YICES" ], [
  AC_MSG_NOTICE([Yices with GMP statically linked])
  AC_MSG_NOTICE([OCamlyices will be linked with libyices.a])
], [
  AC_MSG_NOTICE([Yices with GMP dynamically linked])
  AC_MSG_NOTICE([OCamlyices will be linked with libyices.so])
])

DEFAULT_CUSTOM=no

AC_MSG_CHECKING([whether Yices can be linked into a shared library])
YDLC_TEST=`$CC $CPPFLAGS $CFLAGS $LDFLAGS -shared -xc - $LIBS -o - <<EOF > /dev/null 2> /dev/null && echo yes
extern const char* yices_version();
const char* myf() {
  return yices_version();
}
EOF`
AS_IF([ test "x$YDLC_TEST" == xyes ], [
  AC_MSG_RESULT([yes])
 ], [
  AC_MSG_RESULT([no])
  AC_MSG_WARN([Ocaml custom compilation necessary.])
  AC_MSG_NOTICE([Custom compilation by default (--enable-custom to override).])
  DEFAULT_CUSTOM=yes
])

################################################################################
# Options ######################################################################

AC_ARG_ENABLE(custom,
  [ AS_HELP_STRING([--enable-custom], [Custom compilation (ocamlc option)]) ],
  [ CUSTOM=${enableval} ], [ CUSTOM=$DEFAULT_CUSTOM ])

AC_ARG_ENABLE(partial-linking,
  [ AS_HELP_STRING([--disable-partial-linking],
    [Disable incremental compilation]) ],
  [ PARTIAL_LINKING=${enableval} ], [ PARTIAL_LINKING=yes ])

AS_IF([ test "x$PARTIAL_LINKING" = xno ], [ PARTIAL_LINKING= ])
AS_IF([ test "x$CUSTOM" = xno ], [ CUSTOM= ])

################################################################################
################################################################################

AC_SUBST(PARTIAL_LINKING)
AC_SUBST(CUSTOM)

AC_SUBST(OCAMLC)
AC_SUBST(CAMLIDL)
AC_SUBST(OCAMLOPT)
AC_SUBST(OCAMLDOC)
AC_SUBST(OCAMLDEP)
AC_SUBST(OCAMLFIND)

AC_SUBST(DESTDIR)

AC_SUBST(STATIC_YICES)

AC_CONFIG_FILES([ Makefile ], [ chmod a-w Makefile ])
AC_OUTPUT
