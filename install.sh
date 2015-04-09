#!/usr/bin/env bash
#
# Copyright (c) 2015, Joyent, Inc. All rights reserved.
#

set -euo pipefail
IFS=$'\n\t'

usage() {
cat <<EOF

  Usage: $0 -i {absolute path to installation}
  e.g. $0 -i /data/chroot

  Install the lx-brand guest tools for a given installation path.
  
  OPTIONS:
  -i The path to the given Linux installation
  -h Show this message

EOF
}

INSTALL_DIR=

while getopts "hi:" OPTION; do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    i)
      INSTALL_DIR=${OPTARG%/}
      ;;
    ?)
      usage
      exit
      ;;
    esac
done

info() {
  printf "%s\n" "--> $@"
}

fatal() {
  printf "%s\n" "--> $@"
  exit 1
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

if [[ ! -e "$INSTALL_DIR" ]] ; then
  fatal "Directory $INSTALL_DIR not found"
  exit 1
fi

install_tools() {
  info "Creating symlinks for binaries found in /native"

  SYMLINKS=$(cat ./src/symlinks.txt)
  
  # Note Values for ${binary} must be the full path
  for binary in $SYMLINKS; do
    if [[ ! -e $INSTALL_DIR${binary} ]]; then
      chroot $INSTALL_DIR ln -s /native${binary} ${binary}
    else
      info "Binary ${binary} exits in installation. Skipping symlink creation."
    fi
  done
  
  info "Creating wrapper scripts for binaries in /native"
  
  WRAPPERS=$(cat ./src/wrappers.txt)
  
  # Note Values for ${wrapper} must be the full path 
  for wrapper in $WRAPPERS; do
    binary=$(echo ${wrapper} | cut -f1 -d' ')
    binary_type=$(echo ${wrapper} | cut -f2 -d' ')
    if [[ ! -e $INSTALL_DIR${binary} ]]; then
      if [[ "${binary_type}" == "bash" ]]; then
        ARG=/usr/bin/bash
      elif [[ "${binary_type}" == "sh" ]]; then
        ARG=/usr/bin/sh
      else
        ARG=
      fi
      
cat << WRAPPER > $INSTALL_DIR${binary}
#!/bin/sh

exec /native/usr/sbin/chroot /native ${ARG} ${binary} "\$@"

WRAPPER
chmod 755 $INSTALL_DIR${binary}
    else
      info "Binary ${binary} exits in installation. Skipping wrapper creation."
    fi
  done
  
  info "Copying ./src/lib/smartdc to $INSTALL_DIR/lib/"
  cp -r ./src/lib/smartdc $INSTALL_DIR/lib/
  
}

install_debian() {
  install_tools
  
  info "Adding /native/usr/share/man to manpath"
  
cat << MAN >> $INSTALL_DIR/etc/manpath.config

# Include man pages for wrapper scripts and sylinks
# that reference binaries in /native
MANDATORY_MANPATH /native/usr/share/man

MAN
  
  info "Installing custom rc.local file to $INSTALL_DIR/etc/rc.local..."
  cp ./src/lib/smartdc/joyent_rc.local $INSTALL_DIR/etc/rc.local
}

install_redhat() {
  install_tools
  
  info "Adding /native/usr/share/man to manpath"
  
cat << MAN >> $INSTALL_DIR/etc/man.config

# Include man pages for wrapper scripts and sylinks
# that reference binaries in /native
MANPATH /native/usr/share/man

MAN
  
  info "Installing custom rc.local file to $INSTALL_DIR/etc/rc.d/rc.local..."
  cp ./src/lib/smartdc/joyent_rc.local $INSTALL_DIR/etc/rc.d/rc.local
  
  # On CentOS 7 systemd is the default.
  # make /etc/rc.d/rc.local executable to enable rc.local Compatibility unit
  chmod 755 $INSTALL_DIR/etc/rc.d/rc.local
}

## MAIN ##

OS=$(uname -s)

case $OS in
  Linux)
    if [[ -f $INSTALL_DIR/etc/redhat-release ]] ; then
      install_redhat
    elif [[ -f $INSTALL_DIR/etc/debian_version ]] ; then
      install_debian
    else
      fatal "Sorry. Your OS ($OS) is not supported."
    fi
    ;;
  *)
    fatal "Sorry. Your OS ($OS) is not supported."
    ;;
esac

info "Guest tools installed!"
