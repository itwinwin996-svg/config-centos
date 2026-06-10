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
