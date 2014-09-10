#!/usr/bin/env bash

set -o errexit
set -o pipefail

fatal() {
  printf "%s\n" "$@"
  exit 1
}


# TODO: Note that mdata get tools are installed in /usr/sbin/
print_prompt() {
  clear
  echo "--------------------------------------------------------------------"
  echo " SmartOS VM Guest Tools - Install (Linux)"
  echo "--------------------------------------------------------------------"
  echo  
  echo "This script will install startup tools for SmartOS virtual machine"
  echo "guests. This includes an rc.local script which will be used to set"
  echo "root administrator ssh keys, as well as tools to automatically" 
  echo "format secondary disks, and other generic tools."
  echo "Tools will be located in /lib/smartdc, but will not be included in"
  echo "your \$PATH environment variable automatically."
  echo
  echo "To bypass this prompt, run the script with the '-y' flag:"
  echo
  echo "e.g. $0 -y"
  echo
  echo
  
  yn=
  while [[ $yn == "" ]]; do
    read -p "Do you want to continue? (Y/N): " yn
    case $yn in
      [Yy]* )
      echo "Begining installation."
        break
        ;;
      [Nn]* )
        exit
        ;;
      *)
        echo "Plese answer either 'y' or 'n'"
        ;;
      esac
  done

}

install_tools() {
  echo "Installing SmartOS VM Guest Tools..."
  cp -r ./lib/smartdc /lib/
  cp -r ./usr/sbin/mdata-* /usr/sbin/
  cp -r ./usr/share/man/man1/mdata-* /usr/share/man/man1/
  ln -s /usr/sbin/mdata-get /lib/smartdc/mdata-get
  mv /etc/rc.local /etc/rc.local-backup
  ln -s /lib/smartdc/joyent_rc.local /etc/rc.local
}

install_debian() {
  install_tools
  echo "Installing debian-flavour specific files..."
  # Install packages required for guest tools
  apt-get install -y -q parted
}

install_redhat() {
  install_tools
  echo "Installing redhat-flavour specific files..."
  # Install packages required for guest tools
  yum install -y -q parted
  
  # On CentOS 7 systemd is the default.
  # make /etc/rc.d/rc.local executable to enable rc.local Compatibility unit
  ln -s /lib/smartdc/joyent_rc.local /etc/rc.d/rc.local
  chmod 755 /etc/rc.d/rc.local
}

if [[ $EUID -ne 0 ]] ; then
  fatal "You must be root to run this command"
fi

## MAIN ##
if [[ $# -eq 0 ]]; then
  print_prompt
fi

# The -y flag circumvents the prompt
if [[ $1 != "-y" ]]; then
  print_prompt
fi

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
