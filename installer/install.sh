#!/bin/sh
clear
echo
if [ ! -s /tmp/adss/copyright.sh ]; then
	wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/copyright.sh -qO \
		/tmp/adss/copyright.sh && chmod 775 /tmp/adss/copyright.sh
fi
if [ -s "/tmp/adss/copyright.sh" ]; then
	sh /tmp/adss/copyright.sh
else
	echo
	echo -e "\e[1;36m  `date +'%Y-%m-%d %H:%M:%S'`: 文件下载异常，放弃安装。\e[0m"
	echo
	rm -f /tmp/adss/copyright.sh
	exit 1
fi
echo
echo -e "\e[1;36m 三秒后开始备份安装前路由器相关配置......\e[0m"
echo
sleep 3
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/config/backup.sh -qO \
	/tmp/adss/backup.sh && chmod 775 /tmp/adss/backup.sh && sh /tmp/adss/backup.sh
rm -f /tmp/adss/backup.sh
echo
sleep 3
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/config/modifyConfig.sh -qO \
	/tmp/adss/modifyConfig.sh  && chmod 775 /tmp/adss/modifyConfig.sh  && sh /tmp/adss/modifyConfig.sh
rm -f /tmp/modifyConfig.sh
sleep 3
echo -e "\e[1;36m 获取规则文件......\e[0m"
echo
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/rules/file/dnsrules.conf -qO \
	/usr/share/adss/rules/dnsrules.conf
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/rules/file/hostsrules.conf -qO \
	/usr/share/adss/rules/hostsrules.conf
sleep 3
echo -e "\e[1;36m 重启dnsmasq服务\e[0m"
echo
killall dnsmasq > /dev/null 2>&1
/etc/init.d/dnsmasq restart > /dev/null 2>&1
sleep 2
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/adss.sh -qO \
	/usr/share/adss/update.sh && chmod 755 /usr/share/adss/adss.sh
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/updater/update.sh -qO \
	/usr/share/adss/update.sh && chmod 755 /usr/share/adss/update.sh
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/updater/rules_update.sh -qO \
	/usr/share/adss/rules_update.sh && chmod 755 /usr/share/adss/rules_update.sh
sleep 3
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/config/cron.sh -qO \
	/tmp/adss/cron.sh && chmod 775 /tmp/adss/cron.sh && sh /tmp/adss/cron.sh
echo -e "\e[1;36m 删除安装临时文件\e[0m"
rm -rf /tmp/adss
echo
echo
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                           +"
echo "+       Dnsmasq shell script installation is complete       +"
echo "+                                                           +"
echo "+                      Time:`date +'%Y-%m-%d'`                      +"
echo "+                                                           +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo
