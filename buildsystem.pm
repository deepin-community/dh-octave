# Copyright © 2018, 2022, 2024  Rafael Laboissière <rafael@debian.org>
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

package Debian::Debhelper::Buildsystem::octave;

use strict;
use warnings;
use parent qw(Debian::Debhelper::Buildsystem);
use Debian::Debhelper::Dh_Lib;

sub DESCRIPTION {
    "Octave"
}

sub install {
    my $this = shift;
    my $destdir = shift;
    my $arch = dpkg_architecture_value("DEB_HOST_MULTIARCH");
    my $mpath = "$destdir/usr/share/octave/packages";
    my $bpath = "$destdir/usr/lib/$arch/octave/packages";

    $this->doit_in_sourcedir ("octave",
                              "--no-gui",
                              "--no-history",
                              "--silent",
                              "--no-init-file",
                              "--no-window-system",
                              "/usr/share/dh-octave/install-pkg.m",
                              $mpath, $bpath);

    if (-d $mpath) {

        # Remove unnecessary documentation files
        doit ("find", $mpath, "-name", "doc", "-exec", "/usr/share/dh-octave/clean-docdir", "{}", ";");
        doit ("find", $mpath, "-name", "COPYING", "-exec", "rm", "-f", "{}", ";");

	# Remove left over files *-tst
        doit ("find", $mpath, "-name", "*-tst", "-exec", "rm", "-f", "{}", ";");

	# Remove empty left-over directories
	doit ("rmdir", "--ignore-fail-on-non-empty", "-p", $mpath);

    }

    if (-d $bpath) {

	# Fix permission of installed *.oct and *.mex files, as per FHS 3.0
	# sections 4.6 and 4.7 (see Bug#954149)
	doit ("find", $bpath, "-name", "*.oct", "-exec", "chmod", "-x", "{}", ";");
	doit ("find", $bpath, "-name", "*.mex", "-exec", "chmod", "-x", "{}", ";");

	# Remove empty left-over directories
	doit ("rmdir", "--ignore-fail-on-non-empty", "-p", $bpath);
    }

}

sub clean {
    my $this = shift;
    $this->doit_in_sourcedir_noerror ("dh_octave_clean");
}

1;
