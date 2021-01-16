#!/bin/sh
CRON_FILE=/etc/crontabs/$USER
echo -e "\e[1;36m 创建dnsmasq规则与更新脚本存放的文件夹\e[0m"
echo
echo -e "\e[1;36m 检测和备份当前dnsmasq配置信息\e[0m"
if [ ! -d /etc/dnsmasq ]; then
	mkdir -p /etc/dnsmasq
fi
if [ ! -d /etc/dnsmasq.d ]; then
	mkdir -p /etc/dnsmasq.d
fi
if [ -f /etc/dnsmasq.conf ]; then
	if [ ! -f /etc/dnsmasq.conf.bak ]; then
		cp -p /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
	fi	
else
	echo "" > /etc/dnsmasq.conf
fi
if [ -f $CRON_FILE ]; then
	if [ ! -f $CRON_FILE.bak ]; then
		cp -p $CRON_FILE $CRON_FILE.bak
	fi	
else
	echo "" > $CRON_FILE
fi
