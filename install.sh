#!/bin/bash

mkdir -p /root/repo-backup
mv /etc/yum.repos.d/*.repo /root/repo-backup/ 2>/dev/null

curl -o /etc/yum.repos.d/CentOS-Vault.repo \
https://github.com/itwinwin996-svg/config-cent6/raw/refs/heads/main/CentOS-Vault.repo

yum clean all
rm -rf /var/cache/yum/*
yum makecache
yum repolist
yum -y install wget nano curl vim net-tools telnet bind-utils unzip zip
rpm -Uvh https://repo.zabbix.com/zabbix/7.0/rhel/6/x86_64/zabbix-release-latest-7.0.el6.noarch.rpm
yum clean all
yum -y install zabbix-agent

CONFIG_FILE="/etc/zabbix/zabbix_agentd.conf"
ZABBIX_SERVER_IP="192.168.8.142"

sed -i "s/^Server=127.0.0.1/Server=$ZABBIX_SERVER_IP/g" "$CONFIG_FILE"
sed -i "s/^ServerActive=127.0.0.1/ServerActive=$ZABBIX_SERVER_IP/g" "$CONFIG_FILE"
chkconfig zabbix-agent on
service zabbix-agent restart
