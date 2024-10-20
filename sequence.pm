# Copyright © 2018, 2019  Rafael Laboissière <rafael@debian.org>
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
