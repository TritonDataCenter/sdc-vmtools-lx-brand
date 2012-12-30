#!/bin/sh

# This script initiates a shutdown when the power putton has been
# pressed. Loosely based on the sample that ships with the acpid package.
#
# Copyright (c) 2012 Joyent Inc., All rights reserved.
#
# This works with the Joyent Debian and Ubuntu datasets

if [ ! -f /proc/acpi/event ] ; then 
	logger -t acpid "Acpi-support not handling power button, acpid handler does not exists at /proc/acpi/event"
	exit 0
fi

# Normal handling wiht Joyent API logging
logger -t acpid "Joyent API shutdown called - simulating power button pressed"
/sbin/shutdown -h -P now "Joyent API shutdown called - simulating power button pressed"
