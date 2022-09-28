
# DEPRECATED

include $(CSEC_ROOT)/mk/common.mk

ifndef BUILD_CMD
	BUILD_CMD = $(CC) $(CFLAGS) $(CPPFLAGS) $(BUILD_SRC) $(LDFLAGS) $(LDLIBS) -o $@
endif

orig: $(ORIG)

run: SHELL = /bin/bash
run: orig
	if [ -e "$(P1)" ]; then ./$(P1) $(P1_CMD); fi &  \
	if [ -e "$(P2)" ]; then sleep 1; ./$(P2) $(P2_CMD); fi & \
	if [ -e "$(P3)" ]; then sleep 2; ./$(P3) $(P3_CMD); fi & \
	wait

$(ORIG): BASE_LIB = $(SSL_LIB) $(CRYPTO_LIB)
$(ORIG): CFLAGS += -DVERBOSE
$(ORIG): $(SSL_LIB) $(CRYPTO_LIB)
	$(BUILD_CMD)

# Can't say $(CLIENT).%, because $(CLIENT).c would also match.
# Should work with mpp, see multiple targets in sandbox
$(P1) $(P1).bin $(P1).sym.out: BUILD_SRC = $(P1_SRC)
$(P1) $(P1).bin $(P1).sym.out: $(P1_SRC) $(CIL_LIB)

ifneq ($(P1), $(P2))
$(P2) $(P2).bin $(P2).sym.out: BUILD_SRC = $(P2_SRC)
$(P2) $(P2).bin $(P2).sym.out: $(P2_SRC) $(CIL_LIB)
endif

ifneq ($(P2), $(P3))
$(P3) $(P3).bin $(P3).sym.out: BUILD_SRC = $(P3_SRC)
$(P3) $(P3).bin $(P3).sym.out: $(P3_SRC) $(CIL_LIB)
endif

# can't use an implicit rule due to a bug in make (https://savannah.gnu.org/bugs/index.php?29104)
# makepp doesn't understand this, but do use makepp as soon as bug
# https://sourceforge.net/tracker/?func=detail&aid=2961995&group_id=138953&atid=742140
# is fixed and you can just add libraries to SLL_LIB without fear of cilly mangling them
#$(sort $(CLIENT).bin $(SERVER).bin $(CLIENT).sym $(SERVER).sym $(CLIENT) $(SERVER)): 
#	$(BUILD_CMD)

