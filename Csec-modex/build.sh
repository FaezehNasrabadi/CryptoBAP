#!/bin/bash

set -o errexit -o nounset -o pipefail

set -x

( 
  cd deps/cil-1.7.3/ 
  if [ ! -f Makefile.features ]; then
    ( 
      cd src
      for file in ../../../src/CIL/*.ml; do
	ln -sf $file
      done
    )
    ./configure EXTRAFEATURES="fundefs funreplace crestInstrument"
  fi
)
cmake . && make
( cd src/CIL && make )
( cd src/symtrace && make )
( 
  cd deps/cryptoverif1.12 
  if [ ! -f cryptoverif ]; then
    ./build 
  fi
)
# forgetting to cmake . in proxies results in vile errors: cilly gets passed an incorrect --root 
# which breaks things in very confusing ways.
# ( cd proxies && cmake . && make )
markdown README.markdown > README.html
