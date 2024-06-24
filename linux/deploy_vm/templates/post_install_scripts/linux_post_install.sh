#!/bin/bash
# Get OS information
{% include 'get_os_info.sh' %}

{% if unattend_installer in ['Ubuntu-Ubiquity', 'Debian', 'Pardus'] %}
# Install required packages
{% include 'apt_install_pkgs.sh' %}
# Set default locale
{% include 'set_locale.sh' %}
{% endif %}

{% include 'config_ssh.sh' %}

{% include 'enable_auto_login.sh' %}

{% include 'disable_greeter.sh' %}

{% include 'disable_screen_saver.sh' %}
