use warnings;
use strict;
use Debian::Debhelper::Dh_Lib;

insert_before ("dh_auto_configure", "dh_octave_version");

my %opts;
if (exists $ENV{DEB_BUILD_MAINT_OPTIONS}) {
    %opts = map {$_ => 1} split (/\s+/, $ENV{DEB_BUILD_MAINT_OPTIONS});
}
if (not get_buildoption ("nocheck") and not exists $opts{nocheck}) {
    insert_after ("dh_auto_install", "dh_octave_check");
}

insert_after ("dh_installchangelogs", "dh_octave_changelogs");
insert_after ("dh_installexamples", "dh_octave_examples");
insert_before ("dh_installdeb", "dh_octave_substvar");

1;
