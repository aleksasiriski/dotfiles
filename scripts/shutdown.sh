#!/bin/sh
echo "Trying to shutdown..."
if pgrep "qemu-system-x86">/dev/null 2>&1 ;
then
	echo "VM is running!"
else
	echo "Shutting down..."
	sudo /usr/sbin/shutdown now
fi
