#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

function usage() {
cat <<EOF

	Usage: $0 -i {absolute path to installation}
	e.g. $0 -i /data/chroot

	Install the lx-brand guest tools for a given installation path.
	The directory path must be absolute with not trailing slashes.
	
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
			INSTALL_DIR="$OPTARG"
			;;
		?)
			usage
			exit
			;;
		esac
done

function info() {
	printf "%s\n" "--> $@"
}

function fatal() {
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

function install_tools() {
	info "Creating symlinks for binaries found in /native (e.g., mdata-*, dtrace, prstat etc.)"
	
	# /native/usr/bin 
	NATIVE_USR_BIN=$(cat ./src/native_usr_bin.txt)
	
	for binary in $NATIVE_USR_BIN; do
		if [[ ! -e $INSTALL_DIR/usr/bin/${binary} ]]; then
			chroot $INSTALL_DIR ln -s /native/usr/bin/${binary} /usr/bin/${binary}
		else
			info "Binary /usr/bin/${binary} exits. Skipping."
		fi
	done
	
	# /native/usr/sbin
	NATIVE_USR_SBIN=$(cat ./src/native_usr_sbin.txt)
	
	for binary in $NATIVE_USR_SBIN; do
		if [[ ! -e $INSTALL_DIR/usr/sbin/${binary} ]]; then
			chroot $INSTALL_DIR ln -s /native/usr/sbin/${binary} /usr/sbin/${binary}
		else
			info "Binary /usr/sbin/${binary} exits. Skipping."
		fi
	done
	
	info "Creating wrapper scripts"
	
	# /native/usr/bin 
	WRAPPER_USR_BIN=$(cat ./src/wrapper_usr_bin.txt)
	
	for wrapper in $WRAPPER_USR_BIN; do
		if [[ ! -e $INSTALL_DIR/usr/bin/${wrapper} ]]; then
			cat <<- WRAPPER > $INSTALL_DIR/usr/bin/${wrapper}
			#!/bin/sh
	
			exec /native/usr/sbin/chroot /native /lib/ld.so.1 -e LD_NOENVIRON=1 -e LD_NOCONFIG=1 /usr/bin/${wrapper} "$@"
	
			WRAPPER
			chmod 755 $INSTALL_DIR/usr/bin/${wrapper}
		else
			info "Binary /usr/sbin/${binary} exits. Skipping."
		fi
  done
	
	# /native/usr/sbin 
	WRAPPER_USR_SBIN=$(cat ./src/wrapper_usr_sbin.txt)
	
	for wrapper in $WRAPPER_USR_SBIN; do
		if [[ ! -e $INSTALL_DIR/usr/sbin/${wrapper} ]]; then
			cat <<- WRAPPER > $INSTALL_DIR/usr/sbin/${wrapper}
			#!/bin/sh

			exec /native/usr/sbin/chroot /native /lib/ld.so.1 -e LD_NOENVIRON=1 -e LD_NOCONFIG=1 /usr/sbin/${wrapper} "$@"
		
			WRAPPER
			chmod 755 $INSTALL_DIR/usr/sbin/${wrapper}
		else
			info "Binary /usr/sbin/${binary} exits. Skipping."
		fi
	done
	
	info "Adding /native/usr/share/man to manpath"
	# This should make most of the man pages in /native available
	# for the symlinks we added
	echo "/n" >> $INSTALL_DIR/etc/man.config
	echo "MANPATH /native/usr/share/man" >> $INSTALL_DIR/etc/man.config
}

function install_debian() {
	install_tools
	info "Installing custom rc.local file to $INSTALL_DIR/etc/rc.local..."
	cp ./src/lib/smartdc/joyent_rc.local $INSTALL_DIR/etc/rc.local
}

function install_redhat() {
	install_tools
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
