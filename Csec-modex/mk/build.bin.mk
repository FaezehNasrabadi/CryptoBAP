
BIN = ${foreach P,$(ORIG),$(P).bin}

BINTRACES = bintrace.P1.out
ifdef P2 
	BINTRACES += bintrace.P2.out
endif
ifdef P3 
	BINTRACES += bintrace.P3.out
endif

bin_traces: $(BINTRACES)

bin: $(BIN)

#annot:
#	rename bin.res.txt bin.annot.txt *.bin.res.txt

#%.bin.res.txt: %.bin.out.txt $(BINTRACE)
#	bintrace $< > $@

%.bin: CFLAGS += -DCSEC_VERIFY
%.bin: CC = $(BIN_CILLY)
%.bin: BASE_LIB = $(BIN_SSL_LIB) $(BIN_CRYPTO_LIB)
%.bin: PROXY_LIB = $(BIN_PROXY_LIB)
%.bin: $(PROXY_CONF_BIN) $(BIN_PROXY_LIB) $(BIN_SSL_LIB) $(BIN_CRYPTO_LIB) 
	$(BUILD_CMD)



