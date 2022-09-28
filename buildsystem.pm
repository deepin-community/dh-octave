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
	doit ("find", $mpath, "-name", "doc", "-exec", "rm", "-fr", "{}", "+");
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
