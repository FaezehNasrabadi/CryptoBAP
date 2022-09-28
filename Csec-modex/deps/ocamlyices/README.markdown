OCamlyices
==========

*An OCaml binding for Yices 1*

[![Build Status](https://travis-ci.org/polazarus/ocamlyices.png?branch=master)](https://travis-ci.org/polazarus/ocamlyices)

[Yices][yices] is an efficient SMT solver developed at SRI International.
OCamlyices lets you use this SMT solver inside your own [OCaml][ocaml] program.

Based on [CamlIDL][camlidl], this library allows accessing both Yices APIs (full
and light), with most (if not all) features: unsatisfiable cores, bit vectors,
and more experimental features (interrupting, switching between APIs).

**Warning!** Only tested under Linux (32 and 64 bit platforms), but reported to
work under MacOS X…


First requirement: Yices
------------------------

[Yices][yices] 1.0.40 or more recent (but not 2)  needs to be *installed* on
your system. It can be done in two steps:

1.  Download the latest tarball of [Yices 1 from SRI website][yices-dl].
    Prefer the version with GMP statically linked, except on Linux x86_64 (see
    note below).

2.  Install Yices on your system as follow:

        wget -q -O- http://git.io/sWxMmg | sh -s <yices-XYZ.tar.gz>

    where `<yices-XYZ.tar.gz>` should be replaced with the path to the
    downloaded tarball. The script (available in the repository) installs Yices
    in `/usr/local` and register the shared library.

    Optionally you can set installation directories :

        wget -q -O- http://git.io/sWxMmg | sh -s <yices-XYZ.tar.gz> --prefix /opt --libdir /opt/lib64

**N.B.:** On Linux x86_64 (and possibly other 64-bit platform), “Yices with
GMP dynamically linked” is strongly preferred at the moment. Indeed,
`libyices.a` (provided in “Yices with GMP statically linked”) is not compiled
with the `-fPIC` flag and cannot be compiled in a shared library (used for
bytecode compilation). A possible but *inadvisable* workaround is to use the
custom compilation mode (see configure options below).


Easy install (with Opam)
------------------------

Once Yices is installed, use [Opam][opam] (the official OCaml package manager):

    opam update
    opam install ocamlyices

Done.


Usage
-----

With ocamlfind:

    ocamlfind ocamlc/ocamlopt -package ocamlyices ...

Or without:

    ocamlc -I +ocamlyices nums.cma ocamlyices.cma ...
    ocamlopt -I +ocamlyices nums.cmxa ocamlyices.cmxa ...

`nums` is required in order to handle GMP big integers as `big_int`, but recent
versions of OCaml should infer it automatically.


Documentation
-------------

The documentation of [OCamlyices' API][api] is available online and can be build
locally `doc/` by the following command:

    make doc

For the rest, see the [Yices' official website][yices].

Also, three examples are also available in `examples/`.


Manual install
--------------

### Additional requirements

* GCC
* [OCaml][ocaml]
* Findlib (i.e. ocamlfind)
* [CamlIDL][camlidl]
* GMP shared library (only for Yices without GMP statically linked)
* and optionally autoconf if you wish to tinker with the configuration file.

### Step by step

1.  Download and extract the last release from
    [Github](https://github.com/polazarus/ocamlyices/releases)
    or clone the last version from the repository (at your own risk).

2.  Please make sure to uninstall any previous version beforehand.

2.  Configure and build the OCamlyices library (bytecode and native version):

        autoconf # Only if there is no configure
        ./configure
        make

    Part of the linking is done by an incremental, aka partial, linking, the
    rest is done by ocamlc or ocamlopt when you use the OCamlyices library.

3.  Install the library using ocamlfind's (Findlib) default destination
    directory:

        make install

    Depending on your OCaml installation you may need admin rights or to `sudo`
    this last command.

### (Expert) Configure options: `./configure [OPTIONS]`

    --enable-custom
    --disable-custom [DEFAULT]

Build the OCamlyices for custom bytecode compilation (see ocamlc manual for
more information), rather than using a shared library. As a result, every
program using such a version of OCamlyices will have to be compiled with the
option `-custom`. Also, in this mode, OCamlyices cannot be used from within
the standard interactive toplevel `ocaml`.

    --enable-partial-linking [DEFAULT]
    --disbable-partial-linking

Partial linking is used so as the `ocamlyices.cma/.cmxa` does not depend on
the CamlIDL library.

### (Expert) About GMP

Yices uses a library for arbitrary precision arithmetic, called GMP. Like any
other dependency, this dependency may lead to version incompatibilities.
Yices' website proposes a special version cooked with “GMP statically linked”.
This version contains only a static library `libyices.a`, which includes GMP.
However, using a static library leads to larger binaries and in case of
multiprocess programs to larger memory footprint.

That is why personally I prefer to stick with Yices without GMP. At the moment
(1.0.34), `libyices.so` is dependent on `libgmp.so.10` (that is, a GMP version
5.x). Most recent systems come with packages for the version 5.x of GMP, called
for instance `libgmp10` and `libgmp10-dev` (with headers) on Debian and Ubuntu.

Since version 0.6, OCamlyices does not need to know which one is in use, but
you need to have it on your system. You can know if `libyices.so` has any
problem with `ldd`. Indeed `ldd /pathto/libyices.so` should notably print the
full path of the GMP dynamic library used by Yices.


Uninstall
---------

If you have install it with [Opam][opam]:

    opam remove ocamlyices

Otherwise, use ocamlfind:

    ocamlfind remove ocamlyices


License
-------

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

[yices]: http://yices.csl.sri.com/
[yices-dl]: http://yices.csl.sri.com/download.shtml
[ocaml]: http://ocaml.org/
[opam]: http://opam.ocaml.org/
[camlidl]: http://caml.inria.fr/pub/old_caml_site/camlidl/
[api]: http://micdel.fr/ocamlyices-api
