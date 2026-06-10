#!/bin/sh
set -e

# ตรวจสอบว่าผู้ใช้ได้กรอก IP ของ Zabbix Server มาพร้อมคำสั่งหรือไม่
if [ -z "$1" ]; then
    echo "Error: Please provide Zabbix Server IP." >&2
    echo "Usage: curl -s ... | bash -s -- <ZABBIX_SERVER_IP>" >&2
    exit 1
fi

# ดึงค่าจาก Argument ตัวแรก ($1) มาตั้งเป็น IP Server
ZABBIX_SERVER_IP="$1"

# 1. เปลี่ยนตำแหน่ง YUM Repo ไปที่ Vault
cat << 'EOF' > /etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-7.9.2009 Base
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
enabled=1
gpgcheck=0

[updates]
name=CentOS-7.9.2009 Updates
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
enabled=1
gpgcheck=0

[extras]
name=CentOS-7.9.2009 Extras
baseurl=http://vault.centos.org/7.9.2009/extras/$basearch/
enabled=1
gpgcheck=0

[epel]
name=EPEL-7 Archive
baseurl=https://archives.fedoraproject.org/pub/archive/epel/7/$basearch/
enabled=1
gpgcheck=0
EOF

# 2. สั่งติดตั้ง Zabbix Agent
rpm -Uvh https://repo.zabbix.com/zabbix/7.0/rhel/6/x86_64/zabbix-release-latest-7.0.el6.noarch.rpm
yum clean all
yum -y install zabbix-agent2 zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql

# 3. แก้ไข Configuration ไฟล์โดยใช้ IP จาก Argument
CONFIG_FILE="/etc/zabbix/zabbix_agentd.conf"

sed -i "s/^Server=127.0.0.1/Server=$ZABBIX_SERVER_IP/g" "$CONFIG_FILE"
sed -i "s/^ServerActive=127.0.0.1/ServerActive=$ZABBIX_SERVER_IP/g" "$CONFIG_FILE"
sed -i "s/^Hostname=Zabbix server/# Hostname=Zabbix server/g" "$CONFIG_FILE"
sed -i "s/# HostnameItem=system.hostname/HostnameItem=system.hostname/g" "$CONFIG_FILE"

# 4. เปิดใช้งานและ Restart Service
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2

echo "Zabbix Agent installed and configured successfully with Server IP: $ZABBIX_SERVER_IP"
