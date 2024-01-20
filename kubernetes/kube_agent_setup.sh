#!/bin/bash

if  [ "$EUID" -ne 0 ]; then 
    echo "User is not root. Skill issue."
    exit 
fi

# check if /etc/redhat-release file exists, indicating a RHEL-based system
if [ -e /etc/redhat-release ]; then
    os_type="RHEL"
fi
# check if /etc/debian_version file exists, indicating a debian-based system
if [ -e /etc/debian_version ]; then
    os_type="Debian"
fi

read -p "Enter IPv4 address of Wazuh manager: " WAZUH_ADDRESS < /dev/tty

cp audit-policy.yaml /etc/kubernetes
cp audit-webhook.yaml /etc/kubernetes

sed -i "s/\<wazuh_server_ip\>/${WAZUH_ADDRESS}/" /etc/kubernetes/audit-webhook.yaml