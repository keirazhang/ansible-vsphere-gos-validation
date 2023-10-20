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
    echo "/lib/debian-installer.d/$i"
    cat /lib/debian-installer.d/$i
done
