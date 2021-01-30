#!/bin/sh
echo -e "Trying to shutdown..."
if pgrep "qemu-system-x86">/dev/null 2>&1 ;
then
	echo -e "VM is running!"
else
	echo -e "Shutting down..."
	sudo /usr/sbin/shutdown now
fi
