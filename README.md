# Debhelper-based infrastructure for building Octave add-on packages

## Introduction

This package (dh-octave) contains the infrastructure for building
add-on packages for Octave which uses the mechanism provided by
Octave's `pkg.m`.  This is particularly the case of the
[Octave-Forge][1] packages.

dh-octave is completely based on [Debhelper][2].  It contains scripts
for automating of the building, installing, checking, and cleaning the
add-on package.  It also generates the appropriate substitution
variables for use in `debian/control`.

[1]: https://octave.sourceforge.io/
[2]: https://github.com/Debian/debhelper

## Usage

For a basic usage of dh-octave, first build-depend on the virtual
package dh-sequence-octave. If some specific feature is needed, a
versioned dependency on dh-octave. Second, use this is the minimal
`debian/rules` file:

```make
#!/usr/bin/make -f
# -*- makefile -*-

%:
	dh $@ --buildsystem=octave --with=octave
```

For executing actions beyond the ones of `pkg install`, the
following Debhelper targets can be used:

- override_dh_auto_build
- override_dh_auto_install
- override_dh_auto_clean

For fine tuning the execution of the unit tests, the environment variables
listed below are available.  They can also be set in the file
`debian/checkvars`, which is sourced by the script `dh_octave_check`
and should be in the shell format.

- `DH_OCTAVE_TEST_ENV`

    The value of this variable is prepended to the `octave` command
    used for running the unit tests.  For instance, one can set its
    value to `LD_PRELOAD=` in order to prevent the tests from being
    run in a fakeroot environment.  It can also be another command,
    like 'xfvb-run`.

- `DH_OCTAVE_TEST_OPT`

    This variable alter the behavior of the tests.  Possible values
    are `quiet`, `normal`, and `verbose` (the later is the default).

- `DH_OCTAVE_EXCLUDE_TEST`

    This variable can be used to prevent the execution of certain unit
    tests.  It should contain a space-separated list of file names
    (`*.m` or `*.cc`) for which the unit tests should not be run.

## Building a Debian package from scratch

`dh_octave_make` is a helper script for generating a first version of
a Debian package for an Octave-Forge package.  The command should be
launched from the top directory of the unpacked sources of an
Octave-Forge packages.  A file called `DESCRIPTION` must be present,
from which information about the package is gathered.
`dh_octave_make` generates the `debian/*` files with sensible
contents, although they need further editing.

## Internals of dh-octave

The dh-octave package adds a new buildsystem to the Debhelper system
through the file `buildsystem.pm`.  In this file, the `install` and
`clean` targets of Debhelper are redefined.  Notice that there is no
`build` target in that file, since the building *and* the installation
are done in the `install` target, by running the code in the Octave
script `/usr/share/dh-octave/install-pkg.m`.

The dh-octave package also alters the sequence of Debhelper commands
through the file `sequence.pm`.  It inserts calls to the `dh_octave_*`
commands at the appropriate places, namely:

| dh-octave command      | where  | Debhelper target       |
| ---------------------- | ------ | ---------------------- |
| `dh_octave_version`    | before | `dh_auto_configure`    |
| `dh_octave_check`      | after  | `dh_auto_install`      |
| `dh_octave_changelogs` | after  | `dh_installchangelogs` |
| `dh_octave_substvar`   | before | `dh_installdeb`        |

Notice that the commands above are not meant to be called directly by
the user, but are activated through the build-dependency on
dh-sequence-octave or by using the option `--with=octave` of `dh` in
`debian/rules`.
