#!/usr/bin/env bash

fatal() {
  printf "%s\n" "$@"
  exit 1
}

install() {
  cp -r ./lib/smartdc /lib/
}


print_prompt() {
  echo "--------------------------------------------------------------------"
  echo " SDC VM Guest Tools - Install (Linux)"
  echo "--------------------------------------------------------------------"
  echo  
  echo "This script will install startup tools for SDC virtual machine"
  echo "guests. This includes an rc.local script which will be used to set"
  echo "root administrator ssh keys, as well as tools to automatically" 
  echo "format secondary disks, and other generic tools."
  echo "Tools will be located in /lib/smartdc, but will not be included in"
  echo "your \$PATH environment variables automatically"
  echo
  echo
}

install_tools() {
  echo "Installing SDC VM Guest Tools..."
}

install_debian() {
  install_tools
  echo "Installing debian-flavour specific files..."
  cp -r ./etc/init/networking-interfaces-config.conf /etc/init/
}

install_redhat() {
  install_tools
  echo "Installing redhat-flavour specific files..."
}

if [[ $EUID -ne 0 ]] ; then
  fatal "You must be root to run this command"
fi

## MAIN ##
clear
print_prompt
while true ; do
  yn=N
  read -p "Do you want to continue (y/N) " yn
  case $yn in
    [Yy]* )
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

case `uname -s` in
  Linux)
    if [[ -f /etc/redhat-release ]] ; then
      install_redhat
    elif [[ -f /etc/debian_version ]] ; then
      install_debian
    else
      fatal "Sorry. Your OS is not supported by this installer"
    fi
    ;;
  *)
    fatal "Sorry. Your OS is not supported by this installer"
    ;;
esac
