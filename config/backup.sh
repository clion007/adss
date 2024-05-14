#!/bin/sh
CRON_FILE=/etc/crontabs/$USER
echo -e "\e[1;36m 创建dnsmasq规则与更新脚本存放的文件夹\e[0m"
echo
echo -e "\e[1;36m 检测和备份当前dnsmasq配置信息\e[0m"
if [ ! -d /etc/dnsmasq.d.adss.bak ]; then
  cp -rf /etc/dnsmasq.d /etc/dnsmasq.d.adss.bak
fi
if [ ! -d /etc/dnsmasq.d/adss ]; then
  mkdir -p /etc/dnsmasq.d/adss
fi
if [ ! -f /etc/dnsmasq.conf.adss.bak ]; then
  cp -p /etc/dnsmasq.conf /etc/dnsmasq.conf.adss.bak
fi
touch $CRON_FILE
if [ ! -f $CRON_FILE.bak ]; then
  cp -p $CRON_FILE $CRON_FILE.adss.bak
fi
