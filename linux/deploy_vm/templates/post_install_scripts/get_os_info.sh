echo "OS release information:"
source /etc/os-release
OS_NAME=$NAME
OS_ID=$ID
echo "OS name is $OS_NAME, release version is $VERSION_ID, codename is $VERSION_CODENAME"

echo "System environment variables:"
env | sort

ip_addr=$(ip -br -4 addr show | grep -v lo | awk '{print $3}')
if [ "$ip_addr" != "" ]; then
    echo "DHCP IPv4 address is $ip_addr"
else
    echo "ERROR: Failed to obtain DHCP IPv4 address"
fi
