SOURCES = $(shell ls -1 src/*.xml)
TARGETS = $(foreach c,$(SOURCES),out/$(shell basename "$c" .xml).md)

all: out $(TARGETS)
clean:
	rm -f $(TARGETS)
new: clean all

out:
	mkdir -vp out

out/%.md: src/%.xml
	pandoc -f docbook -t markdown -o $@ $+

.PHONY: all clean new
