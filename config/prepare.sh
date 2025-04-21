#!/bin/sh
# 修正可能未定义的USER变量
CURRENT_USER=$(whoami 2>/dev/null || echo "root")
CRON_FILE=/etc/crontabs/${CURRENT_USER}

echo -e "\e[1;36m 创建dnsmasq规则与更新脚本存放的文件夹\e[0m"
echo 
echo -e "\e[1;36m 检测和备份当前dnsmasq配置信息\e[0m"
mkdir -p /etc/dnsmasq.d/adss/rules
mkdir -p /usr/share/adss
touch $CRON_FILE
if [ ! -f $CRON_FILE-adss.bak ]; then
  cp -p $CRON_FILE $CRON_FILE-adss.bak
fi
