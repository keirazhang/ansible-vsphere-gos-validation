echo "Config SSHd server to permit root login and password authentication"
sed -ri 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -ri 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
