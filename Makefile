# Copyright © 2018  Rafael Laboissière <rafael@debian.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.

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
