#!/bin/sh
echo -e "Trying to reboot..."
if pgrep "qemu-system-x86">/dev/null 2>&1 ;
then
	echo -e "VM is running!"
else
	echo -e "Rebooting..."
	/usr/bin/reboot
fi
