CC = aarch64-linux-gnu-gcc -march=armv8-a -mtune=cortex-a53
CFLAGS=-O3 -Wall
TESTDEFS64K=-Dgcm_init=gcm_init_64k -Dgcm_ctx=gcm_ctx_64k -Dgcm_encrypt=gcm_encrypt_64k -Dgcm_decrypt=gcm_decrypt_64k
TESTDEFS4K=-Dgcm_init=gcm_init_4k -Dgcm_ctx=gcm_ctx_4k -Dgcm_encrypt=gcm_encrypt_4k -Dgcm_decrypt=gcm_decrypt_4k
TESTDEFS256B=-Dgcm_init=gcm_init_256b -Dgcm_ctx=gcm_ctx_256b -Dgcm_encrypt=gcm_encrypt_256b -Dgcm_decrypt=gcm_decrypt_256b

gcmlib: gcm.o prp.o
	ar -r libgcm.a gcm.o prp.o
.c.o:
	${CC} ${CFLAGS} -c $<
prp.c: prp.h
tests: test-gcm-256b test-gcm-4k test-gcm-64k
test-gcm-256b: prp.o gcm.o 
	${CC} -c ${TESTDEFS256B} ${CFLAGS} test.c
	${CC} prp.o test.o gcm.o -o testb
test-gcm-4k:
	${CC} -c ${TESTDEFS4K} ${CFLAGS} test.c
	${CC} prp.o test.o gcm.o -o test4
test-gcm-64k:
	${CC} -c ${TESTDEFS64K} ${CFLAGS} test.c
	${CC} prp.o test.o gcm.o -o test64
clean:
	- rm *~ a.out* *.so *.o testb test4 test64 *core* *.pyc libgcm.a 2>/dev/null sc.*
tidy:
	- rm *~ a.out *.o test* *core* *.pyc 2>/dev/null
