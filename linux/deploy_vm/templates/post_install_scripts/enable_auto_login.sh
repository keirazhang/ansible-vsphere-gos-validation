# Enable user auto login
if [ "X$OS_DM_CONF" != "X" ]; then
    if [[ "X$OS_DM" =~ Xgdm ]]; then
        sed -ri '/AutomaticLoginEnable *=/d' $OS_DM_CONF
        sed -ri '/AutomaticLogin *=/d' $OS_DM_CONF
{% if new_user is defined and new_user != 'root' %}
        echo "Enable auto login for new user {{ new_user }}"
        sed -ri '/\[daemon\]/a AutomaticLogin={{ new_user }}' $OS_DM_CONF
{% else %}
        echo "Enable auto login for root"
        sed -ri '/\[daemon\]/a AutomaticLogin=root' $OS_DM_CONF
{% endif %}
        sed -ri '/\[daemon\]/a AutomaticLoginEnable=True'  $OS_DM_CONF
    elif [[ "X$OS_DM" =~ Xlightdm ]]; then
{% if new_user is defined and new_user != 'root' %}
        echo "Enable auto login for new user {{ new_user }}"
        sed -ri 's/#autologin-user=/autologin-user={{ new_user }}/' $OS_DM_CONF
{% else %}
        echo "Enable auto login for root"
        sed -ri 's/#autologin-user=/autologin-user=root/' $OS_DM_CONF
{% endif %}
        sed -ri 's/#autologin-user-timeout=.*$/autologin-user-timeout=0/' $OS_DM_CONF
    fi
fi
