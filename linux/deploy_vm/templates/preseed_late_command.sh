echo "OS release information:"  >/dev/ttyS0
source /etc/os-release 2>/dev/ttyS0
OS_NAME=$NAME
OS_ID=$ID
echo "OS name is $OS_NAME, release version is $VERSION_ID, codename is $VERSION_CODENAME" >/dev/ttyS0

# Display manager config file
OS_DM_CONF=/etc/gdm3/daemon.conf

echo "System environment variables:" >/dev/ttyS0
env | sort >/dev/ttyS0

ip_addr=$(ip -br -4 addr show | grep -v lo | awk '{print $3}')
if [ "$ip_addr" != "" ]; then
    echo "DHCP IPv4 address is $ip_addr" >/dev/ttyS0
else
    echo "ERROR: Failed to obtain DHCP IPv4 address" >/dev/ttyS0
fi

#Install open-vm-toools from CDROM if it exists
echo "Searching open-vm-tools packages in CDROM" >/dev/ttyS0
apt search open-vm-tools 2>/dev/null | grep open-vm-tools >/dev/ttyS0
ovt_in_cdrom=$?
if [ $ovt_in_cdrom -eq 0 ]; then
    echo "Installing open-vm-tools from CDROM" >/dev/ttyS0
    apt install -y open-vm-tools 2>&1 >/dev/ttyS0
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install open-vm-tools" >/dev/ttyS0
    fi
fi

# Add online repos to install open-vm-tools and other packages required by testing
echo "Adding offical online repo ..." >/dev/ttyS0
if [ "$OS_ID" == "debian" ]; then
    echo "deb http://deb.debian.org/debian/ $VERSION_CODENAME main contrib" >> /etc/apt/sources.list
    echo "Updated APT source list is:" >/dev/ttyS0
    cat /etc/apt/sources.list >/dev/ttyS0
    echo "Updating list of available packages" >/dev/ttyS0
    apt update 2>&1 >/dev/ttyS0
    if [ $ovt_in_cdrom -ne 0 ]; then
        echo "Installing open-vm-tools from online repo" >/dev/ttyS0
        apt install -y open-vm-tools 2>&1 >/dev/ttyS0
        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to install open-vm-tools" >/dev/ttyS0
        fi
    fi;
    echo "Installing testing required packages from online repo" >/dev/ttyS0
    apt install -y open-vm-tools-desktop cloud-init debconf-utils locales-all \
                   rdma-core rdmacm-utils ibverbs-utils 2>&1 >/dev/ttyS0
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install testing required packages" >/dev/ttyS0
    fi
fi

if [ -e /etc/default/locale ]; then
    echo "Set default locale to en_US.UTF-8" >/dev/ttyS0
    echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale
fi

echo "Disable GNOME initial setup at first login for root" >/dev/ttyS0
mkdir -p -m 755 /root/.config 2>/dev/ttyS0
echo "yes" > /root/.config/gnome-initial-setup-done 2>/dev/ttyS0

echo "Add SSH authorized keys for root" >/dev/ttyS0
mkdir -p -m 700 /root/.ssh 2>/dev/ttyS0
echo "{{ ssh_public_key }}" > /root/.ssh/authorized_keys
chown --recursive root:root /root/.ssh 2>/dev/ttyS0
chmod 0644 /root/.ssh/authorized_keys 2>/dev/ttyS0

echo "Config SSHd server to permit root login and password authentication" >/dev/ttyS0
sed -ri 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config 2>/dev/ttyS0
sed -ri 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/ttyS0

{% if new_user is defined and new_user != 'root' %}
echo "Add new user {{ new_user }} to sudoers"  >/dev/ttyS0
echo '{{ new_user }} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/{{ new_user }}

echo "Add SSH authorized keys for new user {{ new_user }}" >/dev/ttyS0
mkdir -p -m 700 /home/{{ new_user }}/.ssh 2>/dev/ttyS0
echo "{{ ssh_public_key }}" > /home/{{ new_user }}/.ssh/authorized_keys
chown --recursive {{ new_user }}:{{ new_user }} /home/{{ new_user }}/.ssh 2>/dev/ttyS0
chmod 0644 /home/{{ new_user }}/.ssh/authorized_keys 2>/dev/ttyS0

echo "Disable GNOME initial setup at first login for user {{ new_user }}" >/dev/ttyS0
mkdir -p -m 755 /home/{{ new_user }}/.config 2>/dev/ttyS0
echo "yes" > /home/{{ new_user }}/.config/gnome-initial-setup-done 2>/dev/ttyS0
chown --recursive {{ new_user }}:{{ new_user }} /home/{{ new_user }}/.config 2>/dev/ttyS0

echo "Enable auto login for new user {{ new_user }}" >/dev/ttyS0
sed -ri 's/#? *AutomaticLogin *=.*$/AutomaticLogin={{ new_user }}/' $OS_DM_CONF 2>/dev/ttyS0
{% else %}
echo "Enable auto login for root" >/dev/ttyS0
sed -ri 's/#? *AutomaticLogin *=.*$/AutomaticLogin=root/' $OS_DM_CONF 2>/dev/ttyS0
{% endif %}
sed -ri 's/#? *AutomaticLoginEnable *=.*$/AutomaticLoginEnable=true/' $OS_DM_CONF 2>/dev/ttyS0

#echo "Disable blank screen and automatic suspend"
#gsettings set org.gnome.desktop.session idle-delay 0
#gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
# Debian installer log messages are written to syslog, not serial port
# So at the end dump the syslog to serial port

