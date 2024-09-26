#!/usr/bin/perl -w

# Copyright © 2018, 2020  Rafael Laboissière <rafael@debian.org>
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

use Parse::DebControl;
use Dpkg::Changelog;

my $parser = new Parse::DebControl;
my $data = $parser->parse_file ('./debian/control') -> [0];

for my $field ("Git", "Browser") {
    (my $tmp = $data -> {"Vcs-$field"}) =~ s/dh-octave/octave-\$name/;
    $data->{"Vcs-$field"} = $tmp;
}

$data -> {"Build-Depends"} =~ m{debhelper-compat \(= ([0-9]+)\)};
$data->{Compat} = $1;

open (FID, "< debian/changelog");
while (<FID>) {
    if (/\(([\d.]+)\)/) {
        $data->{Version} = $1;
        last;
    }
}

$base = "dh_octave_make";
open (IN, "< $base.in");
open (OUT, "> $base");

while (<IN>) {
    for my $field ("Uploaders", "Standards-Version", "Maintainer",
                   "Vcs-Git", "Vcs-Browser", "Compat", "Version") {
        ## Escape @ signs in email addresses
        (my $value = $data->{$field}) =~ s/@/\\@/g;
        s{#$field#}{$value};
    }
    print OUT;
}

close IN;
close OUT;

