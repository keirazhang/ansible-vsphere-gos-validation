# Install required packages
required_pkgs="open-vm-tools"
{% if unattend_installer == 'Ubuntu-Ubiquity' %}
# Ubuntu Desktop required packages
required_pkgs="$required_pkgs open-vm-tools-desktop build-essential openssh-server vim locales cloud-init rdma-core rdmacm-utils ibverbs-utils"
{% elif unattend_installer == 'Debian' %}
# Debian required packages
required_pkgs="$required_pkgs open-vm-tools-desktop cloud-init debconf-utils rdma-core rdmacm-utils ibverbs-utils"
{% elif unattend_installer == 'Pardus' %}
# Pardus required packages
required_pkgs="$required_pkgs openssh-server build-essential open-vm-tools sg3-utils vim python3-apt dbus"
if [ "X$OS_DM" != "X" ]; then
  required_pkgs="$required_pkgs open-vm-tools-desktop"
fi
{% endif %}

#Try to install packages from CDROM firstly
cdrom_missing_pkgs=""
for pkg in $required_pkgs; do
    echo "Searching package $pkg in CDROM"
    apt list $pkg 2>/dev/null | cut -d '/' -f 1 | grep $pkg
    pkg_in_cdrom=$?
    if [ $pkg_in_cdrom -eq 0 ]; then
        echo "Installing pacakge $pkg from CDROM"
        apt install -y $pkg 2>&1
        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to install package $pkg from CDROM"
        fi
    else
        echo "Package $pkg doesn't exist in CDROM"
        cdrom_missing_pkgs="$cdrom_missing_pkgs $pkg"
    fi
done

# Try to install CDROM missing package from online repo
if [ "X$cdrom_missing_pkgs" != "X" ]; then
    echo "Adding $OS_NAME $VERSION_ID ($VERSION_CODENAME) offical online repo"
{% if unattend_installer == 'Debian' %}
    echo "deb http://deb.debian.org/debian/ $VERSION_CODENAME main contrib" >> /etc/apt/sources.list
{% elif unattend_installer == 'Pardus' %}
    {% include 'add_pardus_repo.sh' %}
{% endif %}

    echo "APT source list with online repos:"
    cat /etc/apt/sources.list

    echo "Updating list of available packages"
    apt update -y 2>&1

    for pkg in $cdrom_missing_pkgs; do
        echo "Searching package $pkg in online repo"
        apt list $pkg 2>/dev/null | cut -d '/' -f 1 | grep $pkg
        pkg_in_online_repo=$?
        if [ $pkg_in_online_repo -eq 0 ]; then
            echo "Installing package $pkg from online repo"
            apt install -y $pkg 2>&1
            if [ $? -ne 0 ]; then
                echo "ERROR: Failed to install package $pkg from online repo"
            fi
        else
            echo "ERROR: Failed to find package $pkg from CDROM and online repo"
        fi
    done
fi
