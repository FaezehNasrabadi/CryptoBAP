CSEC_ROOT = ../..

include $(CSEC_ROOT)/mk/common.mk

OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAML_INC = -I $(OCAMLYICES_ROOT) -I /usr/local/lib -I cryptoverif -I $(CIL_OBJDIR)
CAMLP4_FLAGS = -pp "camlp4o pa_extend.cmo q_MLast.cmo pa_log.cmo -loc _loc" -I +camlp4
PA_LOG_FLAGS = -pp "camlp4o pa_extend.cmo q_MLast.cmo -loc _loc" -I +camlp4
OCAMLC_FLAGS = -g $(OCAML_INC) -w +a-4-40-41-42-44-45-48 $(CAMLP4_FLAGS)
# include -p for gprof or perf here if necessary
# valgrind doesn't need special compilation (just -g)
OCAMLOPT_FLAGS = $(OCAMLC_FLAGS)
OCAML_LIBS = nums.cma ocamlyices.cma str.cma unix.cma cil.cma
OCAMLOPT_LIBS = $(OCAML_LIBS:.cma=.cmxa)
## OCAML_FLAGS = -g -I $(OCAMLYICES_ROOT) -package num ocamlyices.cmxa -package str -linkpkg 

CV_LIB = cryptoverif/cryptoverif.cmx

SRC = ${wildcard *.ml *.mli}

COMMON_CMO = common.cmo stats_local.cmo type.cmo fun_type.cmo sym.cmo var.cmo exp.cmo iml.cmo solver.cmo simplify.cmo symex.cmo
COMMON_CMX = $(COMMON_CMO:.cmo=.cmx)

CVTRACE_CMO = typing.cmo cv_fact.cmo syms.cmo transform.cmo template.cmo cv_transform.cmo cv_model.cmo
CVTRACE_CMX = $(CVTRACE_CMO:.cmo=.cmx)

PVTRACE_CMO = $(CVTRACE_CMO) pv_model.cmo
PVTRACE_CMX = $(PVTRACE_CMO:.cmo=.cmx)

# doesn't work:
#$(addprefix -I $(CIL_ROOT), /src /src/frontc $(CIL_OBJDIR))

all: imltrace cvtrace pvtrace run_tests derivation sym_iml
htdoc: doc

imltrace: $(COMMON_CMX) imltrace.cmx
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) $(OCAMLOPT_LIBS) -o $@ $^ 

sym_iml: $(COMMON_CMX) sym_iml.cmx
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) $(OCAMLOPT_LIBS) -o $@ $^ 

pvtrace: $(CV_LIB) $(COMMON_CMX) $(CVTRACE_CMX) $(PVTRACE_CMX) pvtrace.cmx
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) $(OCAMLOPT_LIBS) -o $@ $^

cvtrace: $(CV_LIB) $(COMMON_CMX) $(CVTRACE_CMX) cvtrace.cmx
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) $(OCAMLOPT_LIBS) -o $@ $^

run_tests: $(CV_LIB) $(COMMON_CMX) $(CVTRACE_CMX) run_tests.cmx 
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) $(OCAMLOPT_LIBS) -o $@ $^

derivation: common.cmx stats_local.cmx type.cmx fun_type.cmx sym.cmx var.cmx exp.cmx iml.cmx solver.cmx derivation.cmx
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) $(OCAMLOPT_LIBS) -o $@ $^

top: $(COMMON_CMO)
	ocamlmktop -o $@ $(OCAML_INC) $(OCAML_LIBS) $^

$(CV_LIB):
	cd cryptoverif && $(MAKE)

doc: $(COMMON_SRC) imltrace.ml pvtrace.ml cvtrace.ml sym_iml.ml
	mkdir -p $@
	touch $@  
	ocamldoc -I $(OCAMLYICES_ROOT) -I $(OCAML_LIB) -I cryptoverif -html -d $@ $^

clean:
	$(RM) cvtrace imltrace top *.cma *.cmi *.cmo *.cmx *.o

# Common rules
.SUFFIXES: .ml .mli .cmo .cmi .cmx

# .ml.cmo:
# 	$(OCAMLC) $(OCAMLC_FLAGS) -c $<

# .mli.cmi:
# 	$(OCAMLC) $(OCAMLC_FLAGS) -c $<

# .ml.cmx:
# 	$(OCAMLOPT) $(OCAMLOPT_FLAGS) -c $<


%.cmo: %.ml | pa_log.cmo
	$(OCAMLC) $(OCAMLC_FLAGS) -c $<

%.cmi: %.mli | pa_log.cmo
	$(OCAMLC) $(OCAMLC_FLAGS) -c $<

%.cmx: %.ml | pa_log.cmo
	$(OCAMLOPT) $(OCAMLOPT_FLAGS) -c $<

pa_log.cmo: pa_log.ml
	$(OCAMLC) -o $@ $(PA_LOG_FLAGS) -c pa_log.ml

# Dependencies
.depend: | $(SRC) pa_log.cmo
	ocamldep $(OCAML_INC) $(CAMLP4_FLAGS) *.mli *.ml > .depend

include .depend	
