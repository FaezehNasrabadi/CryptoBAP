
CSEC_ROOT = ../..

include $(CSEC_ROOT)/mk/common.mk

COMMON = common.mli common.ml

all: CIL leaves.exe calltrace.exe badpairs.exe unreachable.exe calledOpaque.exe bad_opaque_calls.exe

# nums seems to be necessary since 3.12
BUILD_CMD = ocamlc -g -o $@ unix.cma str.cma nums.cma -I $(CIL_OBJDIR) -I $(CIL_ROOT)/_build/ocamlutil cil.cma $^

leaves.exe: $(COMMON) leaves.ml 
	$(BUILD_CMD)

calltrace.exe: $(COMMON) calltrace.ml 
	$(BUILD_CMD)

badpairs.exe: $(COMMON) badpairs.ml 
	$(BUILD_CMD)

unreachable.exe: $(COMMON) mark.ml unreachable.ml 
	$(BUILD_CMD)

calledOpaque.exe: $(COMMON) mark.ml calledOpaque.ml 
	$(BUILD_CMD)

dumpBoring.exe: $(COMMON) dumpBoring.ml 
	$(BUILD_CMD)

bad_opaque_calls.exe: $(COMMON) bad_opaque_calls.ml
	$(BUILD_CMD)

CIL:
	cd $(CIL_ROOT) && make

clean:
	$(RM) *.cmi *.cmo *.exe
