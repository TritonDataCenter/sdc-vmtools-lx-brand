# SmartOS lx-brand VM Guest Tools

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
