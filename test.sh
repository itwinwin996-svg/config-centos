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
name=CentOS-6 - Base
baseurl=https://vault.centos.org/6.10/os/$basearch/
gpgcheck=1
gpgkey=https://vault.centos.org/6.10/os/$basearch/RPM-GPG-KEY-CentOS-6
EOF

# 2. สั่งติดตั้ง Zabbix Agent
yum clean all
yum install -y zabbix-agent

# 3. แก้ไข Configuration ไฟล์โดยใช้ IP จาก Argument
CONFIG_FILE="/etc/zabbix/zabbix_agentd.conf"

sed -i "s/^Server=127.0.0.1/Server=$ZABBIX_SERVER_IP/g" "$CONFIG_FILE"
sed -i "s/^ServerActive=127.0.0.1/ServerActive=$ZABBIX_SERVER_IP/g" "$CONFIG_FILE"
sed -i "s/^Hostname=Zabbix server/# Hostname=Zabbix server/g" "$CONFIG_FILE"
sed -i "s/# HostnameItem=system.hostname/HostnameItem=system.hostname/g" "$CONFIG_FILE"

# 4. เปิดใช้งานและ Restart Service
chkconfig zabbix-agent on
service zabbix-agent restart

echo "Zabbix Agent installed and configured successfully with Server IP: $ZABBIX_SERVER_IP"
