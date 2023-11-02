#!/bin/bash
# Get OS information
{% include 'get_os_info.sh' %}

{% if unattend_installer in ['Ubuntu-Ubiquity', "Debian", "Pardus"] %}
{% include 'apt_install_pkgs.sh' %}
{% elif unattend_installer in ['BCLinux', 'BCLinux-for-Euler'] %}
{% include 'bclinux_manage_pkgs.sh' %}
{% endif %}

{% include 'set_locale.sh' %}

{% include 'config_ssh.sh' %}

{% include 'enable_auto_login.sh' %}

{% include 'disable_greeter.sh' %}

{% include 'disable_screen_saver.sh' %}
