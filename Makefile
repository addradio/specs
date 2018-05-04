SOURCES		= $(shell ls -1 src/*.xml)
TARGETS_RAW	= $(foreach c,$(shell xsltproc count.xsl src/specification.xml),out/$c) out/index
TARGETS_MD	= $(foreach c,$(TARGETS_RAW),$c.md)
TARGETS_HTML	= $(foreach c,$(TARGETS_RAW),$c.html)
TARGETS		= $(TARGETS_MD)
TARGETS_ALL	= $(TARGETS) $(TARGETS_HTML)

all: out $(TARGETS)
clean:
	rm -f $(TARGETS_ALL)
new: clean all

html: all $(TARGETS_HTML)

out:
	mkdir -vp out

out/appendix_%.md: $(SOURCES)
	xsltproc --stringparam type appendix --param index $* extract.xsl $+ | pandoc -f docbook -t markdown_github --reference-links -o $@
out/chapter_%.md: $(SOURCES)
	xsltproc --stringparam type chapter --param index $* extract.xsl $+ | pandoc -f docbook -t markdown_github --reference-links -o $@

out/index.md: $(SOURCES)
	xsltproc index.xsl $+ > $@

%.html: %.md
	pandoc -f markdown_github -t html $+ | sed 's/\.md"/\.html"/g' > $@

.PHONY: all clean new
