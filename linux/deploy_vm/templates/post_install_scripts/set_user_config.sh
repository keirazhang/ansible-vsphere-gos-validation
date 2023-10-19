# Add sudoers
{% if new_user is defined and new_user != 'root' %}
echo "Add new user {{ new_user }} to sudoers"
echo '{{ new_user }} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/{{ new_user }}
{% endif %}

# User ssh keys
if [ "$OS_ID" == "debian" ]; then
    echo "Add SSH authorized keys for root"
    mkdir -p -m 700 /root/.ssh
    echo "{{ ssh_public_key }}" > /root/.ssh/authorized_keys
    chown --recursive root:root /root/.ssh
    chmod 0644 /root/.ssh/authorized_keys
    
{% if new_user is defined and new_user != 'root' %}
    echo "Add SSH authorized keys for new user {{ new_user }}"
    mkdir -p -m 700 /home/{{ new_user }}/.ssh
    echo "{{ ssh_public_key }}" > /home/{{ new_user }}/.ssh/authorized_keys
    chown --recursive {{ new_user }}:{{ new_user }} /home/{{ new_user }}/.ssh
    chmod 0644 /home/{{ new_user }}/.ssh/authorized_keys
    
    echo "Disable GNOME initial setup at first login for user {{ new_user }}"
    mkdir -p -m 755 /home/{{ new_user }}/.config
    echo "yes" > /home/{{ new_user }}/.config/gnome-initial-setup-done
    chown --recursive {{ new_user }}:{{ new_user }} /home/{{ new_user }}/.config
{% endif %}
fi

# Improve user experience
OS_DM=$(awk -F '/' '{print $NF}' < /etc/X11/default-display-manager)
if [[ "$OS_DM" =~ gdm ]]; then
    echo "Default display manager is GNOME"
    # Display manager config file
    if [ "$OS_ID" == "debian" ]; then
        OS_DM_CONF=/etc/gdm3/daemon.conf
    elif [ "$OS_ID" == "ubuntu" ]; then
        OS_DM_CONF=/etc/gdm3/custom.conf
    else
        OS_DM_CONF=/etc/gdm/custom.conf
    fi

    # Auto login
{% if new_user is defined and new_user != 'root' %}
    echo "Enable auto login for new user {{ new_user }}"
    sed -ri 's/#? *AutomaticLogin *=.*$/AutomaticLogin={{ new_user }}/' $OS_DM_CONF
{% else %}
    echo "Enable auto login for root"
    sed -ri 's/#? *AutomaticLogin *=.*$/AutomaticLogin=root/' $OS_DM_CONF
{% endif %}
    sed -ri 's/#? *AutomaticLoginEnable *=.*$/AutomaticLoginEnable=true/' $OS_DM_CONF

    # Disable screen lock
    echo "Disable blank screen, screen saver and automatic suspend"
    cat >/etc/dconf/profile/user <<EOF
user-db:user
system-db:local
EOF

    mkdir -p /etc/dconf/db/local.d
    chmod a+rx /etc/dconf/db/local.d
    cat >/etc/dconf/db/local.d/00-gdm <<EOF
[org/gnome/desktop/screensaver]
lock-enabled=false

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-timeout=0
sleep-inactive-ac-type='nothing'
EOF
    chmod a+rx /etc/dconf/db/local.d/00-gdm

    echo "Update the system dconf databases"
    dconf update
fi
