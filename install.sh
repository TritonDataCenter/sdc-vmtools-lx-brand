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
    if [[ ! -e $INSTALL_DIR${binary} && ! -L $INSTALL_DIR${binary} ]]; then
      chroot $INSTALL_DIR ln -s /native${binary} ${binary}
    else
      info "Binary ${binary} exits in installation. Skipping symlink creation."
    fi
  done

  info "Copying native_manpath.sh to $INSTALL_DIR/etc/profile.d/"
  cp ./src/etc/profile.d/native_manpath.sh $INSTALL_DIR/etc/profile.d/

  info "Copying ./src/lib/smartdc to $INSTALL_DIR/lib/"
  cp -r ./src/lib/smartdc $INSTALL_DIR/lib/
}

install_debian() {
  install_tools

  info "Installing custom rc.local file to $INSTALL_DIR/etc/rc.local..."
  cp ./src/lib/smartdc/joyent_rc.local $INSTALL_DIR/etc/rc.local
}

install_redhat() {
  install_tools

  info "Installing custom rc.local file to $INSTALL_DIR/etc/rc.d/rc.local..."
  cp ./src/lib/smartdc/joyent_rc.local $INSTALL_DIR/etc/rc.d/rc.local

  # On CentOS 7 systemd is the default.
  # make /etc/rc.d/rc.local executable to enable rc.local Compatibility unit
  chmod 755 $INSTALL_DIR/etc/rc.d/rc.local
}

install_alpine() {
  install_tools

  info "Installing custom rc.local file to $INSTALL_DIR/etc/rc.local..."
  cp ./src/lib/smartdc/joyent_rc.local $INSTALL_DIR/etc/local.d/joyent.start
  chmod +x $INSTALL_DIR/etc/local.d/joyent.start

  info "Installing shutdown wrapper script"
  cp ./src/sbin/shutdown $INSTALL_DIR/sbin/

}

install_arch() {
  install_tools

  info "Installing custom rc.local file to $INSTALL_DIR/etc/rc.d/rc.local..."
  if [[ ! -d $INSTALL_DIR/etc/systemd/system ]] ; then
    mkdir -p $INSTALL_DIR/etc/systemd/system
  fi

  cp ./src/etc/systemd/system/joyent.service \
    $INSTALL_DIR/etc/systemd/system/joyent.service

  # activate joyent systemd unit
  # XXX do that via systemctl in the chroot?
  ln -sf /etc/systemd/system/joyent.service \
    $INSTALL_DIR/etc/systemd/system/multi-user.target.wants/joyent.service
}

## MAIN ##

OS=$(uname -s)

case $OS in
  Linux)
    if [[ -f $INSTALL_DIR/etc/redhat-release ]] ; then
      install_redhat
    elif [[ -f $INSTALL_DIR/etc/debian_version ]] ; then
      install_debian
    elif [[ -f $INSTALL_DIR/etc/alpine-release ]] ; then
      install_alpine
    elif [[ -f $INSTALL_DIR/etc/arch-release ]] ; then
      install_arch
    else
      fatal "Sorry. Your OS ($OS) is not supported."
    fi
    ;;
  *)
    fatal "Sorry. Your OS ($OS) is not supported."
    ;;
esac

info "Guest tools installed!"
