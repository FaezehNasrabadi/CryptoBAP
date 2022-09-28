
CSEC_ROOT_ABS = /home/faezeh/csec-modex

CIL_ROOT = /home/faezeh/csec-modex/deps/cil-1.7.3

OCAMLYICES_ROOT = /home/faezeh/csec-modex/deps/ocamlyices

CIL_OBJDIR = /home/faezeh/csec-modex/deps/cil-1.7.3/_build/src
CIL_LIB = /home/faezeh/csec-modex/deps/cil-1.7.3/_build/src/cil.a

# OPENSSL = 
# OPENSSL_CRESTIFIED = /home/faezeh/csec-modex/tests/openssl-1.0.0d

PROXIES = /home/faezeh/csec-modex/proxies

IMLTRACE = /home/faezeh/csec-modex/src/symtrace/imltrace
PVTRACE  = /home/faezeh/csec-modex/src/symtrace/pvtrace
CVTRACE  = /home/faezeh/csec-modex/src/symtrace/cvtrace

PROVERIF = /home/faezeh/csec-modex/deps/proverif1.84/proverif

CV_ROOT = /home/faezeh/csec-modex/deps/cryptoverif1.12
CRYPTOVERIF = /home/faezeh/csec-modex/deps/cryptoverif1.12/cryptoverif
CV_DEFAULT = /home/faezeh/csec-modex/deps/cryptoverif1.12/default

CILLY = /home/faezeh/csec-modex/deps/cil-1.7.3/bin/cilly

PROXY_SYM_CILLY = $(CILLY) --doCrestInstrument --csec-config=$(PROXY_CONF_SYM) --save-temps --commPrintLn

OCAML_LIB = /usr/lib/ocaml

OPENSSL_CRESTIFIED=/home/faezeh/csec-modex/tests/openssl-1.0.0d
OPENSSL_CRESTIFIED_CRYPTO=$(OPENSSL_CRESTIFIED)/libcrypto.a

# some system dependency, I guess autoconf would be real nice here
# ifdef WINDIR
#   EXTRA_DEPS = -lwsock32 -ladvapi32 -lgdi32 -luser32
#   CIL_OBJDIR = /obj/x86_WIN32
#   # stupid make can't account for exe extension on cygwin
#   # no, it actually seems to be fine
#   # EXE = .exe 
# else
#   EXTRA_DEPS = -ldl
#   CIL_OBJDIR = /obj/x86_LINUX
# endif
