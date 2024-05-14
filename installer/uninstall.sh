#!/bin/sh
if [ -f /var/lock/opkg.lock ]; then
	rm -f /var/lock/opkg.lock
fi
echo -e "\e[1;31m 开始卸载已安装dnsmasq脚本配置 \e[0m"
echo
echo -e "\e[1;31m 删除残留文件夹以及配置 \e[0m"
rm -rf /etc/dnsmasq.d/adss*
if [ -f /etc/dnsmasq.conf.adss.bak ]; then
	mv -f /etc/dnsmasq.conf.adss.bak /etc/dnsmasq.conf
fi
if [ ! -d /etc/dnsmasq.d.adss.bak ]; then
  mv -f /etc/dnsmasq.d.adss.bak /etc/dnsmasq.d
fi
echo
echo -e "\e[1;31m 删除相关计划任务\e[0m"
if [ -f /etc/crontabs/$USER.bak ]; then
	mv -f /etc/crontabs/$USER.bak /etc/crontabs/$USER
fi
/etc/init.d/cron reload > /dev/null 2>&1
echo
echo -e "\e[1;31m 重启dnsmasq服务\e[0m"
killall dnsmasq > /dev/null 2>&1
/etc/init.d/dnsmasq restart > /dev/null 2>&1
