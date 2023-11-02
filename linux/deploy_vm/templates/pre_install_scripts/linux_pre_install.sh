#!/bin/sh
echo "{{ autoinstall_start_msg }}"
echo "Installer environment variables: "
env | sort

ip_addr=$(ip -o -f inet addr show | grep -v 127.0.0.1 | awk '{print $4}')
echo "DHCP IPv4 address at pre-install: $ip_addr"

echo "Get boot command:"
cat /proc/cmdline

echo "Get devices list:"
lsblk

echo "Get dmesg output at pre-install:"
dmesg -c --color=never
