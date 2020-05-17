#!/bin/sh
CRON_FILE=/etc/crontabs/$USER
grep "dnsmasq" $CRON_FILE >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e "\e[1;31m 添加规则自动更新计划任务\e[0m"
	if [ -f /etc/crontabs/Update_time.conf ]; then
		timedata=$(cat /etc/crontabs/Update_time.conf)
		else
		timedata='4'
	fi	
	if [ -f /etc/dnsmasq/ad_update.sh ]; then
		echo "# 每天$timedata点25分更新广告规则
25 $timedata * * * sh /etc/dnsmasq/ad_update.sh > /dev/null 2>&1" >> $CRON_FILE
	elif [ -f /etc/dnsmasq/fqad_update.sh ]; then
		echo "# 每天$timedata点25分更新翻墙和广告规则
25 $timedata * * * sh /etc/dnsmasq/fqad_update.sh > /dev/null 2>&1" >> $CRON_FILE
	elif [ -f /etc/dnsmasq/fqad_update.sh ]; then
		echo "# 每天$timedata点25分更新翻墙规则
25 $timedata * * * sh /etc/dnsmasq/fq_update.sh > /dev/null 2>&1" >> $CRON_FILE
	fi	
	/etc/init.d/cron reload
	echo
	echo -e "\e[1;36m 自动更新任务添加完成\e[0m"
	echo
fi
sleep 3
grep "reboot" $CRON_FILE >/dev/null
if [ ! $? -eq 0 ]; then
	if [ -f /etc/crontabs/reboottime.conf ]; then
		reboottime=$(cat /etc/crontabs/reboottime.conf)
		else
		reboottime='5'
	fi	
	echo -e "\e[1;36m 设置路由器定时重启\e[0m"
	echo "# 每两天检测一次网络是否畅通，如果不通重启路由器；每2周$reboottime点05分强制重启路由器
04 $reboottime */2 * * [ $(date +%w) -eq 0 ] sleep 1m && touch /etc/banner && reboot || ping -c2 -w5 114.114.114.114 || sleep 1m && touch /etc/banner && reboot" >> $CRON_FILE
	/etc/init.d/cron reload
	echo
	echo -e "\e[1;36m 定时重启任务设定完成\e[0m"
	echo
fi
