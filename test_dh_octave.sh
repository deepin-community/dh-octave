#!/bin/bash

# Copyright © 2018 Rafael Laboissière <rafael@debian.org>
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

### The following functions (`has', `has_dir', and `run') are taken from
### the Debian package autodep8.

has() {
    file="$1"
    shift
    mkdir -p $(dirname "$file")
    if [ $# -gt 0 ]; then
        printf "$@" > "$file"
        echo >> "$file"
    else
        touch "$file"
    fi
}

has_dir() {
    mkdir -p "$@"
}

### Set the environment variable PREFIX to the directory where the
### dh_octave_* commands are located.  This is useful for coping with a
### situation where the dh-octave package is not installed in the system,
### like during build time.  PREFIX defaults to null.  N.B.: There *_must_*
### be a leading slash in its value.
: ${PREFIX:=}

run() {
  exitstatus=0
  "$PREFIX$@" > stdout 2> stderr || exitstatus=$?
}

### These are shunits2 functions that must be defined for our tests.

pkg=foo

setUp() {
    tmpdir=$(mktemp -d)
    cd "$tmpdir"
    has debian/control "Source: $pkg\n\nPackage: $pkg\nArchitecture: all"
}

origdir=$(pwd)
tearDown() {
    cd "$origdir"
    rm -rf "$tmpdir"
}

### Check dh_octave_changelog

helper_changelog() {
    srcfile="$1"
    link="$2"
    has debian/$pkg/usr/share/octave/$1
    has_dir debian/$pkg/usr/share/doc/$pkg
    run dh_octave_changelogs --package=$pkg
    assertTrue "test -L debian/$pkg/usr/share/doc/$pkg/$2"
}

test_dh_octave_changelog_has_NEWS() {
    helper_changelog NEWS NEWS
}

test_dh_octave_changelog_has_ChangeLog() {
    helper_changelog ChangeLog changelog.gz
}

### Check dh_octave_clean

test_dh_octave_clean_no_src_dir() {
    run dh_octave_clean
    assertEquals 0 "$exitstatus"
    assertEquals "No such file or directory.  Stop."			\
                 "$(cat stdout stderr | grep src: | sed 's/.*src: //')"
}

test_dh_octave_clean_remove_tst() {
    tst_file=src/test.cc-tst
    has $tst_file ""
    run dh_octave_clean
    assertFalse "test -f $tst_file"
}

test_dh_octave_clean_with_src_Makefile() {
    has src/Makefile "distclean:\n	@echo done"
    run dh_octave_clean
    assertEquals 0 "$exitstatus"
    assertEquals "done" "$(cat stdout stderr| grep done)"
}

### Check dh_octave_version

test_dh_octave_version() {
    has DESCRIPTION "Depends: octave (>= $(octave-config -p VERSION))"
    assertTrue 'Wrong Octave dependency relationship' ${PREFIX}dh_octave_version
}

### Run the unit tests

# Enfore the C locale, since error messages are used in some test cases
export LANG=C

. shunit2
