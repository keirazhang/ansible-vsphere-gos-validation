#!/bin/bash

# Get OS information
{% include 'get_os_info.sh' %}

# Set default locale
{% include 'set_locale.sh' %}

#Install open-vm-toools from CDROM if it exists
echo "Searching open-vm-tools packages in CDROM"
apt search open-vm-tools 2>/dev/null | grep open-vm-tools
ovt_in_cdrom=$?
if [ $ovt_in_cdrom -eq 0 ]; then
    echo "Installing open-vm-tools from CDROM"
    apt install -y open-vm-tools 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install open-vm-tools"
    fi
fi

# Add online repos to install open-vm-tools and other packages required by testing
echo "Adding offical online repo ..."
if [ "$OS_ID" == "debian" ]; then
    echo "deb http://deb.debian.org/debian/ $VERSION_CODENAME main contrib" >> /etc/apt/sources.list
    echo "Updated APT source list is:"
    cat /etc/apt/sources.list
    echo "Updating list of available packages"
    apt update 2>&1
    if [ $ovt_in_cdrom -ne 0 ]; then
        echo "Installing open-vm-tools from online repo"
        apt install -y open-vm-tools 2>&1
        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to install open-vm-tools"
        fi
    fi;
    echo "Installing testing required packages from online repo"
    apt install -y open-vm-tools-desktop cloud-init debconf-utils locales-all \
                   rdma-core rdmacm-utils ibverbs-utils 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install testing required packages"
    fi
fi

{% include 'set_sshd.sh' %}

{% include 'set_user_config.sh' %}
