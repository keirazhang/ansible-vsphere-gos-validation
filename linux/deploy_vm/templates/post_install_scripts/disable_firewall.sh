if [ "X$OS_ID" == "Xphoton" ]; then
    # Disable iptables for Photon OS
    systemctl stop iptables
    systemctl disable iptables
fi
