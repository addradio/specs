SOURCES_DOCBOOK	= $(shell ls -1 src/*.xml)
SOURCES_DIA	= $(shell ls -1 src/*.dia)
TARGETS_RAW	= $(foreach f,$(SOURCES_DOCBOOK),$(foreach c,$(shell xsltproc count.xsl $f),out/$(f:src/%.xml=%)/$c) out/$(f:src/%.xml=%)/index)
TARGETS_MD	= $(foreach c,$(TARGETS_RAW),$c.md)
TARGETS_HTML	= $(foreach c,$(TARGETS_RAW),$c.html)
TARGETS_PNG	= $(foreach c,$(SOURCES_DIA),out/$(shell basename $c .dia).png)
TARGETS_DIR	= $(foreach c,$(SOURCES_DOCBOOK),out/$(c:src/%.xml=%))
TARGETS		= $(TARGETS_MD) $(TARGETS_PNG)
TARGETS_ALL	= $(TARGETS) $(TARGETS_HTML)

all: out $(TARGETS_DIR) $(TARGETS)
clean:
	rm -f $(TARGETS_ALL)
	rmdir $(TARGETS_DIR)
new: clean all

html: all $(TARGETS_HTML)

out:
	mkdir -vp out

$(TARGETS_DIR):
	mkdir -vp $@

out/%.md: BASENAME = $(shell basename $@ .md)
out/%.md: TYPE=$(firstword $(subst _, ,$(BASENAME)))
out/%.md: INDEX=$(lastword $(subst _, ,$(BASENAME)))
out/%.md: $(SOURCES_DOCBOOK)
	xsltproc --stringparam type $(TYPE) --param index $(INDEX) extract.xsl src/$(shell basename $(shell dirname $@)).xml | pandoc -f docbook -t markdown_github --reference-links | sed 's#\(/out/.*\.png\)#/..\1#g' > $@

out/%/index.md: src/%.xml
	xsltproc index.xsl $+ > $@

out/%.png: src/%.dia
	dia -e $@ $+

%.html: %.md
	pandoc -f markdown_github -t html $+ | sed 's/\.md"/\.html"/g' > $@

.PHONY: all clean new
