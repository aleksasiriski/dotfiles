#!/bin/sh
echo "Trying to reboot..."
if pgrep "qemu-system-x86">/dev/null 2>&1 ;
then
	echo "VM is running!"
else
	echo "Rebooting..."
	sudo /usr/sbin/reboot f
fi
