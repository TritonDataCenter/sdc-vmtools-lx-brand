#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

fatal() {
  printf "%s\n" "$@"
  exit 1
}

install_tools() {
  echo "Creating symlinks for binaries found in /native (e.g., mdata-*, dtrace, prstat etc.)"
  
  # /native/usr/bin 
  NATIVE_USR_BIN=$(cat ./native_usr_bin.txt)
  
  for binary in $NATIVE_USR_BIN; do
    ln -s /native/usr/bin/${binary} /usr/bin/${binary}
  done
  
  # /native/usr/sbin
  NATIVE_USR_SBIN=$(cat ./native_usr_sbin.txt)
  
  for binary in $NATIVE_USR_SBIN; do
    ln -s /native/usr/sbin/${binary} /usr/sbin/${binary}
  done
  
  echo "Copying mdata-* man pages"
  cp -r ./usr/share/man/man1/mdata-* /usr/share/man/man1/
  
  echo "Adding wrapper scripts"
  cp ./usr/bin/* /usr/bin/
  cp ./usr/sbin/* /usr/sbin/
  
  echo "Adding /native/usr/share/man to manpath"
  # This should make most of the man pages in /native available
  # for the symlinks we added
  echo "MANPATH /native/usr/share/man" >> /etc/man.config
}

install_debian() {
  install_tools
  echo "Installing custom rc.local file to /etc/rc.local..."
  cp ./lib/smartdc/joyent_rc.local /etc/rc.local
}

install_redhat() {
  install_tools
  echo "Installing custom rc.local file to /etc/rc.d/rc.local..."
  cp ./lib/smartdc/joyent_rc.local /etc/rc.d/rc.local
  
  # On CentOS 7 systemd is the default.
  # make /etc/rc.d/rc.local executable to enable rc.local Compatibility unit
  chmod 755 /etc/rc.d/rc.local
}

if [[ $EUID -ne 0 ]] ; then
  fatal "You must be root to run this command"
fi

## MAIN ##

OS=$(uname -s)

case $OS in
  Linux)
    if [[ -f /etc/redhat-release ]] ; then
      install_redhat
    elif [[ -f /etc/debian_version ]] ; then
      install_debian
    else
      fatal "Sorry. Your OS ($OS) is not supported by this installer"
    fi
    ;;
  *)
    fatal "Sorry. Your OS ($OS) is not supported by this installer"
    ;;
esac

echo 
echo "All done!"
echo 
