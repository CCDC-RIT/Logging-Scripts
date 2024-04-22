#!/bin/bash
# Author: jznn

# rewrite old installation
./wazuh-install.sh -a -i -o 

# change passwords
curl -so wazuh-passwords-tool.sh https://packages.wazuh.com/4.7/wazuh-passwords-tool.sh
bash wazuh-passwords-tool.sh -a > /usr/src/wingstop.txt # temporary file name - change later

# file permissions
chown root:wazuh /var/ossec/etc/ossec.conf
chown wazuh:wazuh /var/ossec/etc/shared/default/agent.conf
chown root:wazuh /var/ossec/etc/internal_options.conf
chown root:wazuh /var/ossec/logs/ossec.log
chmod 660 /var/ossec/etc/ossec.conf 
chmod 660 /var/ossec/etc/shared/default/agent.conf 
chmod 640 /var/ossec/etc/internal_options.conf 
chmod 660 /var/ossec/logs/ossec.log 

# create agent groups
/var/ossec/bin/agent_groups -a -g linux -q
/var/ossec/bin/agent_groups -a -g windows -q

# set up policies and configs
printf "insmod:\nrmmod:\nmodprobe:" > /var/ossec/etc/lists/kernel_control_commands
cp osquery.conf /etc/osquery/osquery.conf
cp centralized_agent.conf /var/ossec/etc/shared/linux/agent.conf
cp internal_options.conf /var/ossec/etc/internal_options.conf
cp ossec.conf /var/ossec/etc/ossec.conf
cp decoders/decoder-linux-sysmon.xml /var/ossec/ruleset/decoders
cp decoders/docker-decoders.xml /var/ossec/ruleset/decoders
cat decoders/yara-decoder.xml >> /var/ossec/etc/decoders/local_decoder.xml
cp linux_rules.xml /var/ossec/ruleset/rules
cp windows_rules.xml /var/ossec/ruleset/rules
#leave sigma out till sigma works
#cp sigma.xml /var/ossec/ruleset/rules
cp policies/dirtypipe_check.yml /var/ossec/etc/shared/linux/dirtypipe_check.yml
cp policies/detect_linux_keylogger.yml /var/ossec/etc/shared/linux/sca_detect_linux_keylogger.yml
cp policies/sca_systemfiles.yml /var/ossec/etc/shared/linux/sca_systemfiles.yml
chown wazuh:wazuh /var/ossec/etc/shared/linux/dirtypipe_check.yml
chown wazuh:wazuh /var/ossec/etc/shared/linux/sca_detect_linux_keylogger.yml
chown wazuh:wazuh /var/ossec/etc/shared/linux/sca_systemfiles.yml
chown root:wazuh /var/ossec/ruleset/rules/linux_rules.xml
chown root:wazuh /var/ossec/ruleset/rules/windows_rules.xml

# fix timeout issue and restart services
mkdir /etc/systemd/system/wazuh-indexer.service.d
echo -e "[Service]\nTimeoutStartSec=300" | sudo tee /etc/systemd/system/wazuh-indexer.service.d/startup-timeout.conf 
systemctl daemon-reload
systemctl restart wazuh-indexer
systemctl restart wazuh-manager
systemctl restart wazuh-dashboard
