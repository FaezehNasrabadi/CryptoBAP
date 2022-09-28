#ifndef _GCM_H
#define _GCM_H

#ifdef PYTHON_BINDINGS
#include "Python.h"
#include "modsupport.h"
#define MODIFIERS static
#else
#define MODIFIERS
#endif 

#define GHASH_BLK_SZ (16)

/*  GCM is a general-purpose encryption mode that uses a block cipher
 *  to provide both data confidentiality and data integrity in a
 *  single, easy to use construct.  It provides these services in a
 *  way that is provably secure to very high levels of assurance under
 *  a standard assumption that the underlying block cipher exhibits
 *  pseudo-random behavior (this assumption is widely believed to be
 *  true, but will probably never be proven).
 *
 *  GCM is a building block upon which one can easily build secure
 *  channels.  One need only add authentication, key agreement and
 *  prevention against capture-replay attacks.
 *
 *  GCM accepts several inputs: 
 *     - A key used to initialize the block cipher;
 *     - Data to be encrypted or decrypted;
 *     - A nonce, which is a value that should not be confidential
 *       at all.  The nonce is used in message security, much like an
 *       initialization vector when using other encryption modes.  The
 *       only requirement for the nonce is that, given a particular
 *       key, the nonce never be the same between two messages.  
 *       Generally, an always-incrementing message counter is 
 *       sufficient and can be used to protect against capture-replay 
 *       attacks as well.  The integrity of the nonce is checked 
 *       implicitly when decrypting (but capture-replay is still 
 *       possible... one must still make sure the message counter 
 *       is both valid and larger than the last valid value);
 *     - Additional data that one wishes to authenticate, but not 
 *       encrypt (such as header information that can be public). Note 
 *       that the length of a message is also authenticated implicitly
 *       by this algorithm, so you do not need to include that with
 *       the additional data.
 *
 *  GCM in the abstract can work with any block cipher, but in
 *  practice we expect it to be used primarily with AES.  This
 *  implementation is bound to block ciphers that have 128-bit block
 *  sizes, such as AES.  This implementation is an optimized version that 
 *  comes with its own AES implementation (a modification of the fast
 *  reference code with some tweaks for speed).
 *
 *  Under the hood, GCM uses the block cipher in CTR mode to produce a
 *  stream of bytes used to encrypt both the plaintext and the message
 *  authentication value.  CTR mode is initialized using a function of
 *  the nonce.  That function is described in the GCM paper.
 *
 *  To compute the message authentication value, we derive a "hash
 *  key" and use a "universal hash function" to map the ciphertext to
 *  a single 128-bit value.  The universal hash function has
 *  particular properties that manage to provide high assurance
 *  levels.
 *
 *  The universal hash function we use effectively consists of treating
 *  both the key and the input block as a polynomial in the finite
 *  field GF(2^128) and multiplying those polynomials.  More
 *  precicely, we'll treat our key k as a polynomial, and message
 *  blocks m_1 through m_n as polynomials, and compute:
 *
 *  m_1*k^n + m_2*k^(n-1) + ... + m_n*k
 *
 *  Since these operations all happen in a finite field, the result
 *  has a maximum size.  We've chosen the field so that the range of
 *  possible values has a one-to-one mapping to all of the ways you
 *  can set 128 bits of memory.
 *
 *  
 *  As a reminder, a polynomial takes the form of:
 *  a*x^n + b*x^(n-1) + ... + z*x^0.
 *  
 *  In the case of our hash function, the value of x is always
 *  irrelevent and ignored.  The coefficients can take the values 0 or 1.
 *
 *  Because we're using a finite field, any math operations on our
 *  polynomials are done modulo an "irreducible" polynomial, meaning
 *  the polynomial has no other divisors (akin to a prime number).  
 *  The specific polynomial we use is:
 *
 *  x^128 + x^7 + x^2 + x + 1
 *
 *  As a result, coefficients for x^128 and higher will always be 0. 
 *
 *  Our polynomials are then represented as a vector of 128 bits,
 *  where each bit maps to a single coefficient.
 * 
 *  Because of the way finite fields work, and because coefficients
 *  are either 0 or 1, adding two polynomials together can be
 *  implemented efficiently by XOR-ing the two representations together.
 *  
 *  Multiplication is a bit trickier to understand and implement.  The
 *  strategies that we leverage all rely on a fundamental building
 *  block, the multiplication of a polynomial by x.
 *
 *  In general, if we have a polynomial and we multiply the whole
 *  thing by x, we expect all of the coefficients to move to the left
 *  one bit.  For example:
 *
 *  x^10 + x^7 + x^5 + x^2 + 1 * x = x^11 + x^8 + x^6 + x^3 + x
 *
 *  Then, we need to do the modular reduction.  As it turns out, this
 *  can be done by ADDING the irreducible polynomial to the shifted
 *  result.  As noted above, this is simply an XOR operation.
 * 
 *  In our code, we call this operation mul_alpha (we name the
 *  unimportant free variable alpha instead of x).  This operation can
 *  be used as the foundation by which we multiply together two
 *  polynomials.
 *
 *  Without going into the details of the derivation, it turns out we
 *  can multiply two polynomials p and q using the following algorithm:
 *
 *  - Start out with a resulting polynomial r, where r = 0
 *  - FOR N from 0 to 127:
 *  -     If the x^N term of p is 1, then add q*x^N to r.
 *
 *  We can easily compute q*x^N by repeatedly using mul_alpha to
 *  multiply q by x.  One can work out a few examples longhand to see
 *  that this does indeed give the same results as longhand
 *  multiplication.
 *
 *  One thing to note about this strategy that, if one of the
 *  polynomials is fixed (which is the case in GCM, since one of the
 *  polynomials in a multiplication operation will always be the
 *  key... the other polynomial will be a block of input), then there
 *  are some efficiencies at our disposal.  
 *
 *  First, we can precompute * all 128 values of q*x^N.  This saves us
 *  from performing 127 calls to mul_alpha every time we want to
 *  process a single block.
 *
 *  Second, we note that any time that, for a fixed power l, every
 *  time the coefficient of x^l is 1 in the message block we're
 *  processing, we always XOR in q*x^l.  We can use this knowledge to
 *  precompute the effects of several bits at once.
 *
 *  For example, if the x^0 and x^1 terms of the message block are
 *  both 1, then we'll always XOR in q*x and q.  We can precompute
 *  that value, and then look up the result of q*x XOR q based on the
 *  value of those two bits.
 * 
 *  In practice, we will do this kind of precomputation and do it
 *  either four bits at a time or eight bits at a time.  If we do it
 *  eight bits at a time, we will look at each byte of the message
 *  block and precompute the 256 different possible effects the eight
 *  corresponding coefficients can have on the final result.
 *
 *  Processing 8 bits at a time makes things go quite quickly, since
 *  we can look up a byte at a time.  However, it requires 64K of
 *  memory.  Since this memory is key dependent, this may sometimes be
 *  too much precomputation.  Use gcm4k or gcm256 if this is an issue
 *  (the later uses only about 300 bytes of state per key total).
 *  
 */

#include <stdlib.h>

/*  When we do the modular reduction in mul_alpha, we add in the
 *  polynomial x^128 + x^7 + x^2 + x + 1.  The modular reduction only
 *  needs to occur when the x^128 coefficient is 1, which means the
 *  result for that coefficient will be 0 after the add (x^128 + x^128
 *  = 0, since addition is essentially XOR).
 *  However, we still need to XOR in x^7 + x^2 + x + 1, and this 
 *  constant polynomial is represented by GHASH_ALPHA.
 */

#define GHASH_ALPHA 0xe1000000

#include "prp.h"

#define GCM_J_LIMIT      (0x100)
#define GCM_LEFTMOST_BIT (0x80)
#define GCM_NUM_BITS     (0x08)
#define GCM_I_LIMIT      (16)


typedef struct {
  uint32    table[GCM_I_LIMIT][GCM_J_LIMIT][4];
  KEY_SCHED ck;
  uint32    keylen;
} gcm_ctx_64k;

typedef struct {
  uint32    table[256][4];
  KEY_SCHED ck;
  int       keylen;
} gcm_ctx_4k;

typedef struct {
  uint32    table[16][4];
  KEY_SCHED ck;
  int       keylen;
} gcm_ctx_256b;

MODIFIERS void gcm_init_64k(gcm_ctx_64k *c, uchar key[], size_t keylen);
MODIFIERS void gcm_encrypt_64k(gcm_ctx_64k *c, uchar *nonce, size_t nlen, uchar *pt, 
			       size_t ptlen, uchar *adata, size_t alen, uchar *ct, 
			       uchar *tag);
MODIFIERS int gcm_decrypt_64k(gcm_ctx_64k *c, uchar *nonce, size_t nlen, uchar *ct, 
			      size_t ctlen, uchar *tag, size_t taglen, uchar *adata, 
			      size_t alen, uchar *pt);
MODIFIERS void gcm_destroy_64k(gcm_ctx_64k *c);

MODIFIERS void gcm_init_4k(gcm_ctx_4k *c, uchar key[], size_t keylen);
MODIFIERS void gcm_encrypt_4k(gcm_ctx_4k *c, uchar *nonce, size_t nlen, uchar *pt, 
			      size_t ptlen, uchar *adata, size_t alen, uchar *ct, 
			      uchar *tag);
MODIFIERS int gcm_decrypt_4k(gcm_ctx_4k *c, uchar *nonce, size_t nlen, uchar *ct, 
			     size_t ctlen, uchar *tag, size_t taglen, uchar *adata, 
			     size_t alen, uchar *pt);
MODIFIERS void gcm_destroy_4k(gcm_ctx_4k *c);

MODIFIERS void gcm_init_256b(gcm_ctx_256b *c, uchar key[], size_t keylen);
MODIFIERS void gcm_encrypt_256b(gcm_ctx_256b *c, uchar *nonce, size_t nlen, 
				uchar *pt, size_t ptlen, uchar *adata, size_t alen, 
				uchar *ct, uchar *tag);
MODIFIERS int gcm_decrypt_256b(gcm_ctx_256b *c, uchar *nonce, size_t nlen, uchar *ct, 
			       size_t ctlen, uchar *tag, size_t taglen, uchar *adata, 
			       size_t alen, uchar *pt);
MODIFIERS void gcm_destroy_256b(gcm_ctx_256b *c);

#endif /* _GCM_H */
