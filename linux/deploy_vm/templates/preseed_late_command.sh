echo "OS release information:"
source /etc/os-release
OS_NAME=$NAME
OS_ID=$ID
echo "OS name is $OS_NAME, release version is $VERSION_ID, codename is $VERSION_CODENAME"

# Display manager config file
OS_DM_CONF=/etc/gdm3/daemon.conf

echo "System environment variables:"
env | sort

ip_addr=$(ip -br -4 addr show | grep -v lo | awk '{print $3}')
if [ "$ip_addr" != "" ]; then
    echo "DHCP IPv4 address is $ip_addr"
else
    echo "ERROR: Failed to obtain DHCP IPv4 address"
fi

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

if [ -e /etc/default/locale ]; then
    echo "Set default locale to en_US.UTF-8"
    echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale
fi

echo "Disable GNOME initial setup at first login for root"
mkdir -p -m 755 /root/.config
echo "yes" > /root/.config/gnome-initial-setup-done

echo "Add SSH authorized keys for root"
mkdir -p -m 700 /root/.ssh
echo "{{ ssh_public_key }}" > /root/.ssh/authorized_keys
chown --recursive root:root /root/.ssh
chmod 0644 /root/.ssh/authorized_keys

echo "Config SSHd server to permit root login and password authentication"
sed -ri 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -ri 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

{% if new_user is defined and new_user != 'root' %}
echo "Add new user {{ new_user }} to sudoers"
echo '{{ new_user }} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/{{ new_user }}

echo "Add SSH authorized keys for new user {{ new_user }}"
mkdir -p -m 700 /home/{{ new_user }}/.ssh
echo "{{ ssh_public_key }}" > /home/{{ new_user }}/.ssh/authorized_keys
chown --recursive {{ new_user }}:{{ new_user }} /home/{{ new_user }}/.ssh
chmod 0644 /home/{{ new_user }}/.ssh/authorized_keys

echo "Disable GNOME initial setup at first login for user {{ new_user }}"
mkdir -p -m 755 /home/{{ new_user }}/.config
echo "yes" > /home/{{ new_user }}/.config/gnome-initial-setup-done
chown --recursive {{ new_user }}:{{ new_user }} /home/{{ new_user }}/.config

echo "Enable auto login for new user {{ new_user }}"
sed -ri 's/#? *AutomaticLogin *=.*$/AutomaticLogin={{ new_user }}/' $OS_DM_CONF
{% else %}
echo "Enable auto login for root"
sed -ri 's/#? *AutomaticLogin *=.*$/AutomaticLogin=root/' $OS_DM_CONF
{% endif %}
sed -ri 's/#? *AutomaticLoginEnable *=.*$/AutomaticLoginEnable=true/' $OS_DM_CONF

#echo "Disable blank screen and automatic suspend"
#gsettings set org.gnome.desktop.session idle-delay 0
#gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
# Debian installer log messages are written to syslog, not serial port
# So at the end dump the syslog to serial port

