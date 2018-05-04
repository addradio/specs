SOURCES		= $(shell ls -1 src/*.xml)
TARGETS_RAW	= $(foreach c,$(shell xsltproc count.xsl src/specification.xml),out/$c) out/index
TARGETS_MD	= $(foreach c,$(TARGETS_RAW),$c.md)
TARGETS		= $(TARGETS_MD)

all: out $(TARGETS)
clean:
	rm -f $(TARGETS)
new: clean all

out:
	mkdir -vp out

out/appendix_%.md: $(SOURCES)
	xsltproc --stringparam type appendix --param index $* extract.xsl $+ | pandoc -f docbook -t markdown_github --reference-links -o $@
out/chapter_%.md: $(SOURCES)
	xsltproc --stringparam type chapter --param index $* extract.xsl $+ | pandoc -f docbook -t markdown_github --reference-links -o $@

out/index.md: $(SOURCES)
	xsltproc index.xsl $+ > $@

.PHONY: all clean new
