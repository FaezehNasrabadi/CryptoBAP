
The example protocols from csec-challenge. See below for the description of message structures.

Disclaimer
==========

This source code forms a collection of benchmark examples to further research on verification tools; it is not intended for production use.

Download
========

    git clone git://github.com/tari3x/csec-protocols.git

How to use
==========

Running make in the top directory should compile and run all the protocols. Most protocols
rely on OpenSSL for cryptography, so the system must have the OpenSSL development package
installed.

Cygwin
------

The protocols are known to run on Cygwin. To compile, install Cygwin from http://www.cygwin.com.
From the devel packages, include make, gcc-core, gcc-g++, and openssl-devel. 
Make sure that "C:\\cygwin\\bin" (or wherever you install the binaries) is on your Windows path.
Finally, execute "make" from command line in the top distribution directory.

Protocol Descriptions
=====================

CSur
----

The protocol analysed in 
"Cryptographic protocol analysis on real C code"
by J. Goubault-Larrecq and F. Parrennes.

This is an implementation of the Needham-Schroeder protocol:

    A --> B : { A , Na }_{pub(B)}
    B --> A : { Na, Nb }_{pub(A)}
    A --> B : { Nb }_{pub(b)}

This is the flawed version, without B's identity. 

The encryption is explicitly implemented using modular exponentiation with OpenSSL bignums:

    {X}_{pub(A)} = X^(pub_exp(A)) mod pub_mod(A)

NSL
---

An implementation of the Needham-Schroeder-Lowe protocol:

    A --> B : { A , Na }_{pub(B)}
    B --> A : { Na, Nb, B }_{pub(A)}
    A --> B : { Nb }_{pub(b)}

The encryption and decryption functions are stubs for now.

Compiling with -DLOWE_ATTACK will disable the check for B's identity.

The implementation gives detailed feedback when a message is not formatted correctly.
This feedback is printed to stdandard output and we assume that the attacker cannot observe it.
If the attacker could observe the reason for parsing failure, he would gain information
about the encrypted value.

RPC
---

An implementation of a request-response protocol where the integrity of the message is
protected by a message authentication code with a shared key.

    A --> B: pair(request, hmacsha1(pair("request", request), keyAB))
    B --> A: pair(response, hmacsha1(pair("response", pair(request, response)), keyAB))

where the pairing function is implemented as

    pair(x, y) = len(x) | '|' | x | y

with the symbol | denoting bitstring concatenation.

Reference: 
J. Bengtson, K. Bhargavan, C. Fournet, A. D. Gordon, and S. Maffeis. 
"Refinement types for secure implementations." 

RPC-enc
-------

An implementation of a request-response protocol where the integrity and secrecy of the message
is protected by authenticated encryption with shared key

    A --> B: {request, kS}_kAB
    B --> A: {response}_kS

Reference: 
Mihhail Aizatulin, Francois Dupressoir, Andrew D. Gordon, and Jan Juerjens
"Verifying Cryptographic Code in C: Some Experience and the Csec Challenge"

simple_hash
-----------

A short implementation of the first half of the RPC protocol, in which the client
sends the request and the server verifies its integrity. The physical layout of the message is:

    A --> B: len(payload) | 0x01 | payload | hmacsha1(len(payload) | 0x02 | payload)

Contact
=======

Please send bug reports, contributions and suggestions to Mihhail Aizatulin (<avatar@hot.ee>)


