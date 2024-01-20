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

mkdir /var/ossec/integrations/kubernetes-webhook/
cp csr.conf /var/ossec/integrations/kubernetes-webhook/
sed -i "s/\<wazuh_server_ip\>/${WAZUH_ADDRESS}/" /var/ossec/integrations/kubernetes-webhook/csr.conf
openssl req -x509 -new -nodes -newkey rsa:2048 -keyout /var/ossec/integrations/kubernetes-webhook/rootCA.key -out /var/ossec/integrations/kubernetes-webhook/rootCA.pem -batch -subj "/C=US/ST=California/L=San Jose/O=Wazuh"
openssl req -new -nodes -newkey rsa:2048 -keyout /var/ossec/integrations/kubernetes-webhook/server.key -out /var/ossec/integrations/kubernetes-webhook/server.csr -config /var/ossec/integrations/kubernetes-webhook/csr.conf
openssl x509 -req -in /var/ossec/integrations/kubernetes-webhook/server.csr -CA /var/ossec/integrations/kubernetes-webhook/rootCA.pem -CAkey /var/ossec/integrations/kubernetes-webhook/rootCA.key -CAcreateserial -out /var/ossec/integrations/kubernetes-webhook/server.crt -extfile /var/ossec/integrations/kubernetes-webhook/csr.conf -extensions v3_req
/var/ossec/framework/python/bin/pip3 install flask
cp custom_webhook.py /var/ossec/integrations/
sed -i "s/\<wazuh_server_ip\>/${WAZUH_ADDRESS}/" /var/ossec/integrations/custom_webhook.py
cp wazuh-webhook.service /lib/systemd/system
systemctl daemon-reload
systemctl enable wazuh-webhook.service
systemctl start wazuh-webhook.service


if [ "$os_type" = "RHEL" ]; then
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --reload
fi

if [ "$os_type" = "Debian" ]; then
    ufw allow 8080/tcp
fi

