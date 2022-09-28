cmake_minimum_required(VERSION 2.8)

load_cache(..)

if(NOT CILLY)
  message(FATAL_ERROR "Please run cmake in the top directory first.")
endif()

project (proxies)

# Looks like in some version of cmake this needs to come before project and in some after.
set(CMAKE_C_COMPILER ${CILLY})

# NB: Use the configuration file to decide which files actually get crestified
set(CFLAGS "-fPIC -g2 -Wall -Wno-attributes -Wno-unknown-pragmas -Wno-unused-label")
# Not including --csec-config, as it will be different for each library
set(CILLY_FLAGS "--doCrestInstrument --save-temps --commPrintLn --root=${CMAKE_SOURCE_DIR}")

######## crestify lib ###########################

set(CRESTIFY_SRC symbolic_interface.c common.c common_cpp.cpp crestify.cpp)

add_library(crestify STATIC ${CRESTIFY_SRC})

set_target_properties(crestify
  PROPERTIES COMPILE_FLAGS ${CFLAGS})

# If you re-enable the 32 bit library you need to be aware that 
# the .cil.c file will be written twice, so what is compiled is not 
# necessarily what is in cil.c at the end of compilation. 
# add_library(crestify-32bit STATIC ${CRESTIFY_SRC})
#set_target_properties(crestify-32bit
#  PROPERTIES COMPILE_FLAGS "${CFLAGS} -m32")

set(CIL_CRESTIFY_SRC symbolic_interface.c common.c)
string(REGEX REPLACE "\\.c" ".i.globs.out" CRESTIFY_GLOBS_OUT "${CIL_CRESTIFY_SRC}")
string(REGEX REPLACE "\\.c" ".i.callgraph.out" CRESTIFY_CALLGRAPH_OUT "${CIL_CRESTIFY_SRC}")

set_property(SOURCE ${CIL_CRESTIFY_SRC}
             APPEND
             PROPERTY COMPILE_FLAGS "${CILLY_FLAGS} --csec-config=libcrestify.conf")
             
# can't merge with the previous, seems to be confused by APPEND
# CR: broken ;libcrestify-32bit.conf
set_source_files_properties(${CIL_CRESTIFY_SRC}
                            PROPERTY OBJECT_DEPENDS "${CIL_LIB}")

set(CRESTIFY_GLOBS libcrestify.globs.out)
set(CRESTIFY_CALLGRAPH libcrestify.callgraph.out)
set(CRESTIFY_GLOBS_32 libcrestify-32bit.globs.out)
set(CRESTIFY_CALLGRAPH_32 libcrestify-32bit.callgraph.out)

# The crestify library provides support for proxy functions themselves, these functions should not be proxied
add_custom_command(OUTPUT ${CRESTIFY_GLOBS} ${CRESTIFY_GLOBS_32} ${CRESTIFY_CALLGRAPH} ${CRESTIFY_CALLGRAPH_32}
                    COMMAND echo > ${CRESTIFY_GLOBS}
                    COMMAND echo > ${CRESTIFY_GLOBS_32}
                    COMMAND echo > ${CRESTIFY_CALLGRAPH}
                    COMMAND echo > ${CRESTIFY_CALLGRAPH_32})

# add_custom_command(OUTPUT ${CRESTIFY_GLOBS} ${CRESTIFY_GLOBS_32}
#                     DEPENDS crestify
#                     COMMAND cat ${CRESTIFY_GLOBS_OUT} > ${CRESTIFY_GLOBS}
#                     COMMAND cat ${CRESTIFY_GLOBS_OUT} > ${CRESTIFY_GLOBS_32})
#                     
# add_custom_command(OUTPUT ${CRESTIFY_CALLGRAPH} ${CRESTIFY_CALLGRAPH_32}
#                     DEPENDS crestify
#                     COMMAND cat ${CRESTIFY_CALLGRAPH_OUT} > ${CRESTIFY_CALLGRAPH}
#                     COMMAND cat ${CRESTIFY_CALLGRAPH_OUT} > ${CRESTIFY_CALLGRAPH_32})

add_custom_command(OUTPUT libcrestify-32bit.conf
                    DEPENDS libcrestify.conf
                    COMMAND cp libcrestify.conf libcrestify-32bit.conf)

######## system proxies lib ###########################

set(SYSTEM_SRC system_proxies.c system_proxies_boring.c)
string(REGEX REPLACE "\\.c" ".i.globs.out" SYSTEM_GLOBS_OUT "${SYSTEM_SRC}")
string(REGEX REPLACE "\\.c" ".i.callgraph.out" SYSTEM_CALLGRAPH_OUT "${SYSTEM_SRC}")


add_library(system-proxies STATIC ${SYSTEM_SRC})

set_target_properties(system-proxies
  PROPERTIES COMPILE_FLAGS "${CFLAGS} ${CILLY_FLAGS} --csec-config=libsystem-proxies.conf")
  
# add_library(system-proxies-32bit STATIC ${SYSTEM_SRC})
#set_target_properties(system-proxies-32bit
#  PROPERTIES COMPILE_FLAGS "${CFLAGS} ${CILLY_FLAGS} --csec-config=libsystem-proxies.conf -m32")

# CR: broken: ;libsystem-proxies-32bit.conf
set_source_files_properties(${SYSTEM_SRC}
                            PROPERTY OBJECT_DEPENDS "${CIL_LIB}")

set(SYSTEM_GLOBS libsystem-proxies.globs.out)
set(SYSTEM_CALLGRAPH libsystem-proxies.callgraph.out)
set(SYSTEM_GLOBS_32 libsystem-proxies-32bit.globs.out)
set(SYSTEM_CALLGRAPH_32 libsystem-proxies-32bit.callgraph.out)

add_custom_command(OUTPUT ${SYSTEM_GLOBS} ${SYSTEM_GLOBS_32}
                    DEPENDS system-proxies
                    COMMAND cat ${SYSTEM_GLOBS_OUT} > ${SYSTEM_GLOBS}
                    COMMAND cat ${SYSTEM_GLOBS_OUT} > ${SYSTEM_GLOBS_32})
                    
add_custom_command(OUTPUT ${SYSTEM_CALLGRAPH} ${SYSTEM_CALLGRAPH_32}
                    DEPENDS system-proxies
                    COMMAND cat ${SYSTEM_CALLGRAPH_OUT} > ${SYSTEM_CALLGRAPH}
                    COMMAND cat ${SYSTEM_CALLGRAPH_OUT} > ${SYSTEM_CALLGRAPH_32})

add_custom_command(OUTPUT libsystem-proxies-32bit.conf
                    DEPENDS libsystem-proxies.conf
                    COMMAND cp libsystem-proxies.conf libsystem-proxies-32bit.conf)


######## OpenSSL proxies lib ###########################

set(OPENSSL_SRC openssl_proxies.c openssl_proxies_internal.c)

add_library(openssl-proxies STATIC ${OPENSSL_SRC})

set_target_properties(openssl-proxies
  PROPERTIES COMPILE_FLAGS "${CFLAGS} ${CILLY_FLAGS} --csec-config=libopenssl-proxies.conf")

# CR: broken: ;libopenssl-proxies.conf
set_source_files_properties(${OPENSSL_SRC}
                            PROPERTY OBJECT_DEPENDS "${CIL_LIB}")

set(OPENSSL_GLOBS libopenssl-proxies.globs.out)
set(OPENSSL_CALLGRAPH libopenssl-proxies.callgraph.out)

string(REGEX REPLACE "\\.c" ".i.globs.out" OPENSSL_GLOBS_OUT "${OPENSSL_SRC}")
string(REGEX REPLACE "\\.c" ".i.callgraph.out" OPENSSL_CALLGRAPH_OUT "${OPENSSL_SRC}")

add_custom_command(OUTPUT ${OPENSSL_GLOBS} 
                    DEPENDS openssl-proxies
                    COMMAND cat ${OPENSSL_GLOBS_OUT} > ${OPENSSL_GLOBS})
                    
add_custom_command(OUTPUT ${OPENSSL_CALLGRAPH} 
                    DEPENDS openssl-proxies
                    COMMAND cat ${OPENSSL_CALLGRAPH_OUT} > ${OPENSSL_CALLGRAPH})

######## Globs and calltraces ###########################

add_custom_target(csec-info ALL
                  DEPENDS ${SYSTEM_GLOBS} ${SYSTEM_CALLGRAPH} # ${SYSTEM_GLOBS_32} ${SYSTEM_CALLGRAPH_32}
                          ${CRESTIFY_GLOBS} ${CRESTIFY_CALLGRAPH} # ${CRESTIFY_GLOBS_32} ${CRESTIFY_CALLGRAPH_32}
                          ${OPENSSL_GLOBS} ${OPENSSL_CALLGRAPH})


######## Cleanup ###########################

file(GLOB OUT_FILES "*.out")

set_property(DIRECTORY PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${OUT_FILES})
