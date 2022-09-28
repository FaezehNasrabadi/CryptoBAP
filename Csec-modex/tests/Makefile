
SUBDIRS = CSur NSL RPC RPC-enc simple_hash

all:
	for dir in $(SUBDIRS); do\
		(cd $$dir && $(MAKE) -f Makefile.run;)\
	done

clean:
	for dir in $(SUBDIRS); do\
		(cd $$dir && $(MAKE) -f Makefile.run clean;)\
	done

html: README.html

README.html: README.markdown
	markdown $< > $@
