# Disable license input for BCLinux
rpm -e bclinux-license-manager --nodeps

# Workaround for guest_os_family setting
if [ ! -f /etc/redhat-release ]; then
    ln -s bclinux-release /etc/redhat-release
fi
