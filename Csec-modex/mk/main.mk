
# vpath %.a $(PROXIES)
# vpath %.a $(OPENSSL)

include $(CSEC_ROOT)/mk/common.mk

############################
## IML
############################

#ifndef IML_OUTPUTS 
 # IML_OUTPUTS = iml.out
#endif

#copy: iml.debug.copy.out

#iml.debug.copy.out: iml.debug.out
#	cp $^ $@

#mark:
#	grep "(mark)" iml.debug.out > mark.out

#iml: iml.out

#ifdef DEBUG_IML
#iml.out: $(CVM) $(IMLTRACE)
#	{ $(IMLTRACE) $(CVM) iml.raw.out | tee iml.out; } 2>&1 | tee iml.debug.out
#else
#iml.out: IML.txt $(IMLTRACE)
#	{ $(IMLTRACE) IML.txt iml.raw.out | tee iml.out; } > iml.debug.out 2>&1
#endif

#iml.raw.out: iml.out


ifndef IML_OUTPUTS 
 	IML_OUTPUTS = iml_client.out iml_server.out
endif

iml_client.out: IML_client.txt /home/faezeh/csec-modex/src/symtrace/sym_iml
	{ /home/faezeh/csec-modex/src/symtrace/sym_iml IML_client.txt iml_client.raw.out | tee iml_client.out; } > iml_client.debug.out 2>&1

iml_server.out: IML_server.txt /home/faezeh/csec-modex/src/symtrace/sym_iml
	{ /home/faezeh/csec-modex/src/symtrace/sym_iml IML_server.txt iml_server.raw.out | tee iml_server.out; } > iml_server.debug.out 2>&1

iml_client.raw.out: iml_client.out

iml_server.raw.out: iml_server.out

############################
## CryptoVerif  
############################

ifndef CV_OUTPUTS 
  CV_INPUTS = $(wildcard *.cv.in)
  CV_OUTPUTS = $(CV_INPUTS:.in=.out)
endif

CV_OUTPUTS_NOAUX = $(CV_OUTPUTS:.out=.noaux.out)

cv_model: $(CV_OUTPUTS)
cv_model_noaux: $(CV_OUTPUTS_NOAUX)

cv: $(CV_OUTPUTS)
	for f in $(CV_OUTPUTS); do\
		$(CRYPTOVERIF) -lib $(CV_DEFAULT) $$f | grep "RESULT\|queries";\
	done

cv_full: $(CV_OUTPUTS)
	for f in $(CV_OUTPUTS); do\
		$(CRYPTOVERIF) -lib $(CV_DEFAULT) $$f;\
	done

cv_noaux: $(CV_OUTPUTS_NOAUX)
	for f in $(CV_OUTPUTS_NOAUX); do\
		$(CRYPTOVERIF) -lib $(CV_DEFAULT) $$f;\
	done

%.cv.out: IML_client.txt IML_server.txt $(CV_DEFAULT).cvl %.cv.in $(CVTRACE)
	{ $(CVTRACE) IML_client.txt IML_server.txt $(CV_DEFAULT) $*.cv.in | tee $@; } > $*.cv.debug.out 2>&1

%.cv.noaux.out: %.cv.out
	sed -e '/if auxiliary/s/if \(auxiliary.*\)/(*ifx \1*)/' $< > $@
	
cvmodel.out: IML_client.txt IML_server.txt $(CV_DEFAULT).cvl cvtemplate.in $(CVTRACE)
	{ $(CVTRACE) IML_client.txt IML_server.txt $(CV_DEFAULT) cvtemplate.in | tee $@; } > cvmodel.debug.out 2>&1

############################
## ProVerif
############################

ifndef PV_OUTPUTS 
  PV_INPUTS = $(wildcard *.pv.in)
  PV_OUTPUTS = $(PV_INPUTS:.in=.out)
endif

pv: $(PV_OUTPUTS)
	for f in $(PV_OUTPUTS); do\
		$(PROVERIF) -in pi $$f | grep "RESULT\|queries";\
	done


pv_full: $(PV_OUTPUTS)
	for f in $(PV_OUTPUTS); do\
		$(PROVERIF) -in pi $$f;\
	done


%.pv.out: IML_client.txt IML_server.txt %.pv.in $(PVTRACE)
	{ $(PVTRACE) IML_client.txt IML_server.txt $(CV_DEFAULT) $*.cv.in $*.pv.in | tee $@; } > $*.pv.debug.out 2>&1

############################
## Testing
############################

ifndef OUTPUTS
  OUTPUTS = $(IML_OUTPUTS) $(PV_OUTPUTS) $(CV_OUTPUTS)
endif
GOOD_OUTPUTS = $(OUTPUTS:.out=.good.txt)

check: $(GOOD_OUTPUTS)

%.good.txt: %.out
	@if patdiff $@ $<; then\
		echo "$<: Test OK.";\
	else\
		echo "$<: Test not OK.";\
#		exit 1;\
	fi
#    touch $@;\

bless: $(OUTPUTS)
	rename out good.txt $^


############################
## Callgraph info
############################

ifdef USE_CRESTIFIED_OPENSSL
OPENSSL_CALLGRAPH = $(OPENSSL_CRESTIFIED)/openssl.callgraph.out
OPENSSL_GLOBS = $(OPENSSL_CRESTIFIED)/openssl.globs.out
endif

ifndef LOCAL_CALLGRAPH
LOCAL_CALLGRAPH = $(shell find . -name "*.callgraph.out")
# the problem with this is that cryptokix doesn't rely on sym to build itself
#$(LOCAL_CALLGRAPH): sym
endif

ifndef LOCAL_GLOBS
LOCAL_GLOBS = $(shell find . -name "*.globs.out")
#$(LOCAL_GLOBS): sym
endif

# PROXY_CALLGRAPH = $(shell find $(PROXIES) -name "*.callgraph.out")
# PROXY_GLOBS = $(shell find $(PROXIES) -name "*.globs.out")

LIB_CALLGRAPH = $(PROXY_LIBS:.a=.callgraph.out)
LIB_GLOBS = $(PROXY_LIBS:.a=.globs.out)

filegraph: sym
	cat *.callgraph.out $(PROXIES)/openssl.fullgraph.out | sort -u > fullgraph.out
	mkdir -p defs
	cp *.defs.out defs
	cp -r $(PROXIES)/defs .
	time reachable fullgraph.out | clusterise defs | tee filegraph.out
	cat filegraph.out | sort -u | graph2dot > filegraph.dot
	time dot -Tpdf filegraph.dot > filegraph.pdf

# $(PROXY_CALLGRAPH) $(OPENSSL_CALLGRAPH)
callgraph.out: $(LOCAL_CALLGRAPH) $(LIB_CALLGRAPH)
	cat $^ > callgraph.out

# $(PROXY_GLOBS) $(OPENSSL_GLOBS)
globs.out: $(LOCAL_GLOBS) $(LIB_GLOBS)
	cat $^ > globs.out

# The list of called functions produced by symbolic execution.
called.out: iml

funlist: funlist_compile funlist_run

# This one depends on compilation only.
# We want this to work even if funlist_run fails, so that we can tell the user to instrument main().
# Make sure to call leaves first, as it gives better diagnostics.
funlist_compile: callgraph.out globs.out
	@echo "==== Reachable functions not proxied, opaque or crestified:"
	@$(CSEC_ROOT)/src/CIL/leaves.exe
	@echo "==== Opaque functions called from proxy functions:"
	@$(CSEC_ROOT)/src/CIL/bad_opaque_calls.exe
	@echo "==== Bad pairs:"
	@$(CSEC_ROOT)/src/CIL/badpairs.exe
	@echo "==== Unreachable boring functions:"
	@$(CSEC_ROOT)/src/CIL/unreachable.exe $(CSEC_CONF)
	@#echo "==== Instrumented boring functions:"
	@#comm -12 boring.out crestified.out
	@#echo "==== Unreachable boring functions:"
	@#comm -23 boring.out leaves.out

# This one depends on running the program.
funlist_run: called.out
	@echo "==== Called boring functions:"
	@$(CSEC_ROOT)/src/CIL/calledOpaque.exe $(CSEC_CONF) "called.out"

############################
## Misc
############################


clean::
	$(RM) *.exe *.o *.cil.c *.i *.out

phony:

.PHONY: phony

