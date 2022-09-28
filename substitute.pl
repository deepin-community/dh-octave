#!/usr/bin/perl -w

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

