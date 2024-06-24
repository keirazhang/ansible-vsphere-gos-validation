#!/bin/sh
ip_addr=$(ip -o -f inet addr show | grep -v 127.0.0.1 | awk '{print $4}')
{% if unattend_installer in ["Ubuntu-Ubiquity", "Debian", "Pardus"] %}
echo "{{ autoinstall_start_msg }}"
{% else %}
echo "{{ autoinstall_start_msg }} with IPv4 address: $ip_addr"
{% endif %}

echo "Installer environment variables: "
env | sort

echo "Boot command"
cat /proc/cmdline

echo "Devices list:"
lsblk
