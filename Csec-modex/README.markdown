Csec-modex Toolchain
====================
This is an implementation of the verification method described in 
"Extracting and Verifying Cryptographic Models from C Protocol Code by Symbolic Execution" 
and 
"Computational Verification of C Protocol Implementations by Symbolic Execution" 
by Mihhail Aizatulin, Andy Gordon, and Jan Jürjens.

The distribution includes the source code of the protocols analysed in the papers: CSur,
simple mac, simple xor, RPC, RPC-enc, and NSL. Unfortunately, we are not able to distribute the source code 
of the metering protocol, due to licensing restrictions.

The ProVerif verification tool is being rewritten and is not currently functional.

Download
========

    git clone git://github.com/tari3x/csec-modex.git

Do not use the zip file provided by github, as it breaks symbolic links.
	
Dependencies
============

The distribution bundles and automatically builds most of the dependencies, 
except for the following:

- gcc, ocaml, cmake, openssl, polarssl, markdown

- Yices SMT solver, which we are not allowed to redistribute due to licensing restrictions. 

    The tools are known to work with version 1.0.28/1.0.29 with dynamically linked GMP which you can obtain from
      http://yices.csl.sri.com/
	  
    First make sure that the appropriate version of GMP (static or dynamic, as used by yices) is installed.
    You can then use the script
      deps/ocamlyices/install-yices.sh
    to install yices.

- camlidl. You can get it with opam by running "opam install camlidl".

- the curses library (libncurses-devel in Cygwin), which is required by CIL

How to use
==========

The distribution relies on a unix environment and cmake for building. 
To build all the bundled dependencies and tools install cmake and run

    ./build.sh

Now you can go into each subdirectory of the tests/ directory and run verification via

    make -f Makefile.csec

Contact
=======

Please send bug reports and suggestions to Mihhail Aizatulin (<avatar@hot.ee>)

When submitting bug reports please include the full output of running make together
with all the *.debug.out files from the test folder in which an error happened.
