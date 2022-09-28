// Copyright (c) Mihhail Aizatulin (avatar@hot.ee).
// This file is distributed as part of csec-tools under a BSD license.
// See LICENSE file for copyright notice.
 
#include <stdlib.h>
#include <stdbool.h>

/**
 * Return the key of an external host. Should check that the key is properly bound to the host.
 * The implementation that is reflected in the environment model right now checks the signature of
 * a trustworthy key server.
 */
unsigned char * lookup_xkey(size_t * len, const unsigned char * host, size_t host_len, char side);
