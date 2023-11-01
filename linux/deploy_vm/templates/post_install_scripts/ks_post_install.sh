#!/bin/bash
# Get OS information
{% include 'get_os_info.sh' %}

{% include 'config_ssh.sh' %}

{% include 'enable_auto_login.sh' %}

{% include 'disable_greeter.sh' %}

{% include 'disable_screen_saver.sh' %}
