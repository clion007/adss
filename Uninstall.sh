#!/bin/sh
echo
echo "# Copyright (c) 2014-2017,by clion007"
echo "# 本脚本仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）"
echo "# 未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规，文明上网。"
echo "# openwrt类固件使用，包括但不限于pandorabox、LEDE、ddwrt等，Padavan系列固件不可用。"
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                        +"
echo "+    Uninstall Fq&Noad 6 in 1 script for OpnWrt or LEDE or PandoraBox    +"
echo "+                                                                        +"
echo "+                             Time:`date +'%Y-%m-%d'`                            +"
echo "+                                                                        +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo -e "\e[1;31m 开始卸载已安装扶墙去广告配置 \e[0m"
rm -f /var/lock/opkg.lock
sleep 1
echo
echo -e "\e[1;31m 删除残留文件夹以及配置 \e[0m"
rm -rf /etc/dnsmasq
rm -rf /etc/dnsmasq.d
if [ -d /etc/dnsmasq.bak ]; then
	mv -f /etc/dnsmasq.bak /etc/dnsmasq
fi
if [ -d /etc/dnsmasq.d.bak ]; then
	mv -f /etc/dnsmasq.d.bak /etc/dnsmasq.d
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
echo
