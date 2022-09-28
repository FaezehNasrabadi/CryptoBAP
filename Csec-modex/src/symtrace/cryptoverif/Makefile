 
CSEC_ROOT = ../../..

include $(CSEC_ROOT)/mk/common.mk
 
CV_SRC = parsing_helper.mli parsing_helper.ml ptree.mli parser.mli parser.ml \
           types.ml terms.mli binderset.mli settings.mli binderset.ml settings.ml terms.ml \
           lexer.ml oparser.mli oparser.ml syntax.mli olexer.ml stringmap.mli stringmap.ml \
           syntax.ml

# CV_SRC = parsing_helper.ml parser.ml \
#            types.ml binderset.ml settings.ml terms.ml \
#            lexer.ml oparser.ml olexer.ml stringmap.ml \
#            syntax.ml

CV_OBJ = parsing_helper.cmx parser.cmx \
           types.cmx binderset.cmx settings.cmx terms.cmx \
           lexer.cmx oparser.cmx olexer.cmx stringmap.cmx \
           syntax.cmx

CV_LIB = cryptoverif.cmx

# CV_OBJ = $(subst .ml,.cmo,$(subst .mli,.cmi,$(CV_SRC)))

$(CV_LIB): $(CV_OBJ)
	ocamlopt -pack -o $@ $^

$(CV_OBJ): $(CV_SRC)
	ocamlopt -c -for-pack Cryptoverif $^

%.ml: $(CV_ROOT)/src/%.ml
	cp $< $@

%.mli: $(CV_ROOT)/src/%.mli
	cp $< $@

clean:
	$(RM) *.cmi *.cmo *.cmx *.o
