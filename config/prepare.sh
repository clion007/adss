#!/bin/sh
# 修正可能未定义的USER变量
CURRENT_USER=$(whoami 2>/dev/null || echo "root")
CRON_FILE=/etc/crontabs/${CURRENT_USER}

message l "创建 ADSS 规则文件文件夹"
message l "检测和备份当前 dnsmasq 配置信息"
mkdir -p /usr/share/adss
mkdir -p /etc/dnsmasq.d/adss/rules
touch $CRON_FILE
if [ ! -f $CRON_FILE-adss.bak ]; then
  cp -p $CRON_FILE $CRON_FILE-adss.bak
fi
