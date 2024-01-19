# rewrite old installation
./wazuh-install.sh -a -i -o 

# change passwords
curl -so wazuh-passwords-tool.sh https://packages.wazuh.com/4.7/wazuh-passwords-tool.sh
bash wazuh-passwords-tool.sh -a > /usr/src/wingstop.txt # temporary file name - change later

# file permissions
chown root:wazuh /var/ossec/etc/ossec.conf
chown wazuh:wazuh /var/ossec/etc/shared/default/agent.conf
chown -R wazuh:wazuh /var/ossec/etc/rules
chown root:wazuh /var/ossec/etc/internal_options.conf
chown root:wazuh /var/ossec/logs/ossec.log
chmod /var/ossec/etc/ossec.conf 660
chmod /var/ossec/etc/shared/default/agent.conf 660
chmod -R /var/ossec/etc/rules/ 660
chmod /var/ossec/etc/internal_options.conf 640
chmod /var/ossec/logs/ossec.log 660

#TODO: ossec.conf, policies, decoders, osquery

# create agent groups
/var/ossec/bin/agent_groups -a -g linux
/var/ossec/bin/agent_groups -a -g windows

# set up policies and configs
cp osquery.conf /etc/osquery/osquery.conf
cp centralized_agent.conf /var/ossec/etc/linux/agent.conf
cp internal_options.conf /var/ossec/etc/internal_options.conf
cp decoders/decoder-linux-sysmon.xml /var/ossec/ruleset/decoders
cp decoders/docker-decoders.xml /var/ossec/ruleset/decoders
cp policies/dirtypipe_check.yml /var/ossec/etc/shared/linux/dirtypipe_check.yml
cp policies/detect_linux_keylogger.yml /var/ossec/etc/shared/linux/sca_detect_linux_keylogger.yml
cp policies/sca_systemfiles.yml /var/ossec/etc/shared/linux/sca_systemfiles.yml
chown wazuh:wazuh /var/ossec/etc/shared/linux/dirtypipe_check.yml
chown wazuh:wazuh /var/ossec/etc/shared/linux/sca_detect_linux_keylogger.yml
chown wazuh:wazuh /var/ossec/etc/shared/linux/sca_systemfiles.yml
