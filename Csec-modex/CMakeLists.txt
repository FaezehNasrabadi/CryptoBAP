set(CMAKE_LEGACY_CYGWIN_WIN32 0)
cmake_minimum_required(VERSION 2.8)

set(CSEC_ROOT ${CMAKE_BINARY_DIR} CACHE PATH "The root folder of the compilation")

######## deps/CIL and src/CIL  ##############################

# To upgrade to new CIL:
# - link all your sources under CIL/src directory
# - add all your modules to src/cil.mllib
# ./configure EXTRAFEATURES="fundefs funreplace crestInstrument"

set(CIL_ROOT ${CSEC_ROOT}/deps/cil-1.7.3)

# find ARCHOS as configured by CIL
execute_process(COMMAND sed -n "s/.*ARCHOS=\\(.*\\)/\\1/p" ${CIL_ROOT}/config.mk
                OUTPUT_VARIABLE ARCHOS
                OUTPUT_STRIP_TRAILING_WHITESPACE)

set(CIL_OBJDIR ${CIL_ROOT}/_build/src/ CACHE PATH "CIL object folder")
set(CIL_LIB ${CIL_OBJDIR}/cil.a CACHE FILEPATH "Location of the CIL library")
set(CILLY ${CIL_ROOT}/bin/cilly CACHE FILEPATH "Location of the CIL front-end")

set(CIL_DIR ${CSEC_ROOT}/src/CIL)

file(GLOB CIL_SRC "${CIL_DIR}/*.ml")

set(CMAKE_C_COMPILER ${CILLY})

######## test CIL as compiler ###########################

# disable compiler check
project (csec-modex NONE)

# set(CMAKE_VERBOSE_MAKEFILE true)

# 32 or 64 bit?

if(CMAKE_SYSTEM_PROCESSOR MATCHES ".*64.*")
  # set(64_BIT true)
  set(OPENSSL_CONFIG csec-64)
else()
  # set(64_BIT false)
  set(OPENSSL_CONFIG csec)
endif(CMAKE_SYSTEM_PROCESSOR MATCHES ".*64.*")

execute_process(COMMAND ocamlc -where
                OUTPUT_VARIABLE OCAML_LIB
                OUTPUT_STRIP_TRAILING_WHITESPACE)

######## deps/ocamlyices ###########################

set(OCAMLYICES_ROOT ${CSEC_ROOT}/deps/ocamlyices)
set(OCAMLYICES ${OCAMLYICES_ROOT}/ocamlyices.cmxa ${OCAMLYICES_ROOT}/yices.cmi)

######## deps/openssl-crestified ###########################

set(OPENSSL_CRESTIFIED ${CSEC_ROOT}/tests/openssl-1.0.0d)

######## deps/cryptoverif ###########################

set(CV_ROOT ${CSEC_ROOT}/deps/cryptoverif1.12)

set(CRYPTOVERIF ${CV_ROOT}/cryptoverif)

set(CV_DEFAULT ${CV_ROOT}/default)

######## deps/proverif ###########################

set(PV_ROOT ${CSEC_ROOT}/deps/proverif1.84)

set(PROVERIF ${PV_ROOT}/proverif)

######## include ################################

set(PROXIES ${CSEC_ROOT}/proxies CACHE PATH "The proxy libraries location")

######## src/symtrace ##############################

set(SYMTRACE_DIR ${CSEC_ROOT}/src/symtrace)

set(IMLTRACE ${SYMTRACE_DIR}/imltrace${CMAKE_EXECUTABLE_SUFFIX})
set(IMLINPUT ${SYMTRACE_DIR}/sym_iml${CMAKE_EXECUTABLE_SUFFIX})
set(PVTRACE  ${SYMTRACE_DIR}/pvtrace${CMAKE_EXECUTABLE_SUFFIX})
set(CVTRACE  ${SYMTRACE_DIR}/cvtrace${CMAKE_EXECUTABLE_SUFFIX})

file(GLOB SYMTRACE_SRC "${SYMTRACE_DIR}/*.ml" "${SYMTRACE_DIR}/cryptoverif/*.ml")

######## proxies ##############################

# add_subdirectory(proxies)

set(LIBSSL_PROXY_SYM ${PROXIES}/libopenssl-proxies.a ${PROXIES}/libsystem-proxies.a ${PROXIES}/libcrestify.a)

######## CONFIG ##############################

configure_file (mk/common.mk.in mk/common.mk)
# configure_file (mk/common.cmake.in mk/common.cmake)
