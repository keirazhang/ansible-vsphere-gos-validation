#!/bin/sh
echo "{{ autoinstall_start_msg }}"
echo "Installer environment variables: "
env | sort

echo "Print installer startup scripts"
for i in `ls /lib/debian-installer-startup.d` ; do
    echo "/lib/debian-installer-startup.d/$i"
    cat /lib/debian-installer-startup.d/$i
done

echo "Print installer scripts"
for i in `ls /lib/debian-installer.d` ; do
    echo "/lib/installer.d/$i"
    cat /lib/installer.d/$i
done

exit 1
