if [ -f /etc/ssh/sshd_config ]; then
    echo "Config SSHd server to permit root login and password authentication"
    sed -ri 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -ri 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
    echo "ERROR: openssh-server is not installed in system"
fi

{% if new_user is defined and new_user != 'root' %}
echo "Add new user {{ new_user }} to sudoers"
echo '{{ new_user }} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/{{ new_user }}
{% endif %}

# Add ssh keys
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
{% endif %}

# Modify cloud-init configs about ssh
if [ -f /etc/cloud/cloud.cfg ]; then
    sed -i 's/^disable_root:.*/disable_root: false/' /etc/cloud/cloud.cfg
    sed -i 's/^ssh_pwauth:.*/ssh_pwauth: yes/' /etc/cloud/cloud.cfg
fi
