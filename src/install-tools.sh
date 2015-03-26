#!/usr/bin/env bash

set -o errexit
set -o pipefail

fatal() {
  printf "%s\n" "$@"
  exit 1
}

install_tools() {
  echo "Creating symlinks for binaries found in /native (e.g., mdata-*, dtrace, prstat etc.)"
  # /native/usr/bin
  ln -s /native/usr/bin/mdb /usr/bin/mdb
  ln -s /native/usr/bin/pcred /usr/bin/pcred
  ln -s /native/usr/bin/pfiles /usr/bin/pfiles
  ln -s /native/usr/bin/pflags /usr/bin/pflags
  ln -s /native/usr/bin/pldd /usr/bin/pldd
  ln -s /native/usr/bin/prstat /usr/bin/prstat
  ln -s /native/usr/bin/prun /usr/bin/prun
  ln -s /native/usr/bin/psig /usr/bin/psig
  ln -s /native/usr/bin/pstack /usr/bin/pstack
  ln -s /native/usr/bin/pstop /usr/bin/pstop
  ln -s /native/usr/bin/ptime /usr/bin/ptime
  ln -s /native/usr/bin/pwait /usr/bin/pwait
  ln -s /native/usr/bin/pwdx /usr/bin/pwdx
  ln -s /native/usr/bin/truss /usr/bin/truss
  ln -s /native/usr/bin/kstat /usr/bin/kstat
  
  # /native/sbin
  ln -s /native/usr/sbin/cpustat /usr/sbin/cpustat
  ln -s /native/usr/sbin/dtrace /usr/sbin/dtrace
  ln -s /native/usr/sbin/mdata-get /usr/sbin/mdata-get
  ln -s /native/usr/sbin/mdata-put /usr/sbin/mdata-put
  ln -s /native/usr/sbin/mdata-delete /usr/sbin/mdata-delete
  ln -s /native/usr/sbin/mdata-list /usr/sbin/mdata-list
  ln -s /native/usr/sbin/plockstat /usr/sbin/plockstat
  
  
  echo "Copying mdata-* man pages"
  cp -r ./usr/share/man/man1/mdata-* /usr/share/man/man1/
  
  echo "Adding wrapper scripts"
  cp ./usr/bin/* /usr/bin/
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
