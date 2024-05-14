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
	if [ -f /etc/dnsmasq.d/ad_update.sh ]; then
		echo "# 每天$timedata点25分更新广告规则
25 $timedata * * * sh /etc/dnsmasq.d/adss/update.sh > /dev/null 2>&1" >> $CRON_FILE
	fi	
	/etc/init.d/cron reload >/dev/null
	echo
	echo -e "\e[1;36m 自动更新任务添加完成\e[0m"
	echo
fi
grep "reboot" $CRON_FILE >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e "\e[1;36m 设置路由器检测网络不通时重启\e[0m"
	echo "# 检测网络是否畅通，如果不通则重启路由器
*/2 * * * * /etc/dnsmasq.d/adss/netcheck.sh" >> $CRON_FILE
	/etc/init.d/cron reload >/dev/null
	echo
	echo -e "\e[1;36m 定时重启任务设定完成\e[0m"
	echo
fi
