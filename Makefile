SOURCES_DOCBOOK	= $(shell ls -1 src/*.xml)
SOURCES_DIA	= $(shell ls -1 src/*.dia)
TARGETS_RAW	= $(foreach c,$(shell xsltproc count.xsl src/specification.xml),out/$c) out/index
TARGETS_MD	= $(foreach c,$(TARGETS_RAW),$c.md)
TARGETS_HTML	= $(foreach c,$(TARGETS_RAW),$c.html)
TARGETS_PNG	= $(foreach c,$(SOURCES_DIA),out/$(shell basename $c .dia).png)
TARGETS		= $(TARGETS_MD) $(TARGETS_PNG)
TARGETS_ALL	= $(TARGETS) $(TARGETS_HTML)

all: out $(TARGETS)
clean:
	rm -f $(TARGETS_ALL)
new: clean all

html: all $(TARGETS_HTML)

out:
	mkdir -vp out

out/appendix_%.md: $(SOURCES_DOCBOOK)
	xsltproc --stringparam type appendix --param index $* extract.xsl $+ | pandoc -f docbook -t markdown_github --reference-links -o $@
out/chapter_%.md: $(SOURCES_DOCBOOK)
	xsltproc --stringparam type chapter --param index $* extract.xsl $+ | pandoc -f docbook -t markdown_github --reference-links -o $@

out/index.md: $(SOURCES_DOCBOOK)
	xsltproc index.xsl $+ > $@

out/%.png: src/%.dia
	dia -e $@ $+

%.html: %.md
	pandoc -f markdown_github -t html $+ | sed 's/\.md"/\.html"/g' > $@

.PHONY: all clean new
