SCRIPTS = dh_octave_substvar	\
          dh_octave_check	\
          dh_octave_clean	\
          dh_octave_make	\
          dh_octave_version	\
          dh_octave_changelogs	\
          dh_octave_examples

MANPAGES = $(patsubst %,%.1,$(SCRIPTS))

VERSION := $(shell dpkg-parsechangelog -S Version)

.PHONY: all
all: manpages chmod

.PHONY: manpages
manpages: $(MANPAGES)

%.1: %
	pod2man --center="dh-octave" --release="$(VERSION)" --utf8 $< > $@

dh_octave_make: dh_octave_make.in
	perl substitute.pl

.PHONY: chmod
chmod: $(SCRIPTS)
	chmod +x $(SCRIPTS)

.PHONY: check
check:
	PREFIX=$(shell pwd)/ ./test_dh_octave.sh

.PHONY: clean
clean:
	rm -f $(MANPAGES) dh_octave_make
