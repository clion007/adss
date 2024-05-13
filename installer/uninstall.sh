#!/bin/sh
if [ ! -s /tmp/copyright.sh ]; then
	wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/copyright.sh -qO \
		/tmp/copyright.sh && chmod 775 /tmp/copyright.sh && sh /tmp/copyright.sh
	else
		sh /tmp/copyright.sh
fi
rm -f /tmp/copyright.sh
echo
if [ -f /var/lock/opkg.lock ]; then
	rm -f /var/lock/opkg.lock
fi
echo -e "\e[1;31m 开始卸载已安装dnsmasq脚本配置 \e[0m"
echo
echo -e "\e[1;31m 删除残留文件夹以及配置 \e[0m"
rm -rf /etc/dnsmasq
rm -rf /etc/dnsmasq.d
if [ -f /etc/dnsmasq.conf.bak ]; then
	mv -f /etc/dnsmasq.conf.bak /etc/dnsmasq.conf
fi
echo
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
echo -e "\e[1;31m 重启dnsmasq服务\e[0m"
killall dnsmasq > /dev/null 2>&1
/etc/init.d/dnsmasq restart > /dev/null 2>&1