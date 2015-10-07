# SmartOS lx-brand Guest Tools

[![Build Status](https://travis-ci.org/joyent/sdc-vmtools-lx-brand.svg?branch=master)](https://travis-ci.org/joyent/sdc-vmtools-lx-brand)

This repo is used to install the guest tools for lx-brand images. The guest tools are required for enabling ssh key creation and meta data (user-sript, operator-script etc.) functionality. This repo, via the `install.sh` script, also creates symlinks and wrapper scripts for binaries found in `/native` in an lx-brand zone. See below for details.

## Status

This software is still under active development and should be used with care.

## Installing

To install the guest tools, run the ./install.sh script with the -i flag specifying the install path:

    ./install.sh -i /data/chroot

## What Gets Installed

The `install.sh` script installs the following:

- rc.local boot scripts from `src/lib/smartdc`
- Symlinks to binaries found in `/native`. See `symlinks.txt` for the list of relevant binaries
- Wrapper scripts for binaries in `/native`. See `wrappers.txt` for the list of relevant binaries
- A custom `rc.local` file (`/etc/rc.d/rc.local` or `/etc/rc.local` depending on the distrubution)

## Development

### Bash Style

To enusre the scripts are consistent with the Joyent style guidelines, use ./tools/bashstyle:

    ./tools/bashstyle install.sh

### Testing

Tests are executed using [Bats](https://github.com/sstephenson/bats) and can found in `test`.

To install Bats:

    $ git clone https://github.com/sstephenson/bats.git
    $ cd bats
    $ [sudo] ./install.sh /usr/local

Run the tests with:

    bats test
