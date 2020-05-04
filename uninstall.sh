#!/bin/sh
if [ ! -s /tmp/copyright.sh ]; then
	wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/copyright.sh -O \
		/tmp/copyright.sh && chmod 775 /tmp/copyright.sh && sh /tmp/copyright.sh
	else
		sh /tmp/copyright.sh
fi
rm -f /tmp/copyright.sh
echo
echo -e "\e[1;31m 开始卸载已安装dnsmasq脚本配置 \e[0m"
rm -f /var/lock/opkg.lock
sleep 1
echo
echo -e "\e[1;31m 删除残留文件夹以及配置 \e[0m"
rm -rf /etc/dnsmasq
rm -rf /etc/dnsmasq.d
if [ -d /etc/dnsmasq.bak ]; then
	if [ -s /etc/dnsmasq/originalState ]; then
		mv -f /etc/dnsmasq.bak /etc/dnsmasq
	else
		rm -rf /etc/dnsmasq.bak
	fi
fi
if [ -d /etc/dnsmasq.d.bak ]; then
	if [ -s /etc/dnsmasq.d/originalState ]; then
		mv -f /etc/dnsmasq.d.bak /etc/dnsmasq.d
	else
		rm -rf /etc/dnsmasq.d.bak
	fi
fi
if [ -f /etc/dnsmasq.conf.bak ]; then
	mv -f /etc/dnsmasq.conf.bak /etc/dnsmasq.conf
fi
echo
sleep 1
echo -e "\e[1;31m 删除相关计划任务\e[0m"
if [ -f /etc/crontabs/$USER.bak ]; then
	mv -f /etc/crontabs/$USER.bak /etc/crontabs/$USER
fi
if [ -f /etc/crontabs/Update_time.conf ]; then
	rm -rf /etc/crontabs/Update_time.conf
fi
if [ -f /etc/crontabs/reboottime.conf ]; then
	rm -rf /etc/crontabs/reboottime.conf
fi
/etc/init.d/cron reload > /dev/null 2>&1
echo
sleep 1
echo -e "\e[1;31m 重启dnsmasq服务\e[0m"
killall dnsmasq
/etc/init.d/dnsmasq restart > /dev/null 2>&1
