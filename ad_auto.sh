#!/bin/sh
clear
echo
if [ ! -s /tmp/copyright.sh ]; then
	wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/copyright.sh -qO \
		/tmp/copyright.sh && chmod 775 /tmp/copyright.sh
fi
if [ -s "/tmp/copyright.sh" ]; then
	sh /tmp/copyright.sh
else
	echo
	echo -e "\e[1;36m  `date +'%Y-%m-%d %H:%M:%S'`: 文件下载异常，放弃本次更新。\e[0m"
	echo
	rm -f /tmp/copyright.sh
	exit 1
fi
echo
echo -e "\e[1;36m 三秒后开始备份安装前路由器相关配置......\e[0m"
echo
sleep 3
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/backup.sh -qO \
	/tmp/backup.sh && chmod 775 /tmp/backup.sh && sh /tmp/backup.sh
rm -f /tmp/backup.sh
echo
sleep 3
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/modifyConfig.sh -qO \
	/tmp/modifyConfig.sh  && chmod 775 /tmp/modifyConfig.sh  && sh /tmp/modifyConfig.sh
rm -f /tmp/modifyConfig.sh
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/initRulesFile.sh -qO \
	/tmp/initRulesFile.sh  && chmod 775 /tmp/initRulesFile.sh  && sh /tmp/initRulesFile.sh
rm -f /tmp/initRulesFile.sh
echo
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/getDnsmasqAdRules.sh -qO \
	/tmp/getDnsmasqAdRules.sh  && chmod 775 /tmp/getDnsmasqAdRules.sh  && sh /tmp/getDnsmasqAdRules.sh
rm -f /tmp/getDnsmasqAdRules.sh
echo
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/getHostsAdRules.sh -qO \
	/tmp/getHostsAdRules.sh  && chmod 775 /tmp/getHostsAdRules.sh  && sh /tmp/getHostsAdRules.sh
rm -f /tmp/getHostsAdRules.sh
echo
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/deletWhiteListRules.sh -qO \
	/tmp/deletWhiteListRules.sh  && chmod 775 /tmp/deletWhiteListRules.sh  && sh /tmp/deletWhiteListRules.sh
rm -f /tmp/deletWhiteListRules.sh
echo
echo -e "\e[1;36m 删除dnsmasq,hosts重复规则及临时文件\e[0m"
echo
sort /tmp/dnsAd | uniq >> /tmp/dnsrules.conf
sort /tmp/hostsAd | uniq >> /tmp/hostsrules.conf
echo "
# Modified DNS end" >> /tmp/dnsrules.conf
echo "
# 修饰hosts结束" >> /tmp/hostsrules.conf
mv /tmp/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf
mv /tmp/hostsrules.conf /etc/dnsmasq/hostsrules.conf
rm -rf /tmp/dnsAd /tmp/hostsAd
sleep 3
echo -e "\e[1;36m 重启dnsmasq服务\e[0m"
echo
killall dnsmasq
	/etc/init.d/dnsmasq restart > /dev/null 2>&1
sleep 2
echo -e "\e[1;36m 获取脚本更新脚本\e[0m"
echo
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/ad_update.sh -qO \
	/etc/dnsmasq/ad_update.sh && chmod 755 /etc/dnsmasq/ad_update.sh
echo -e "\e[1;36m 获取规则更新脚本\e[0m"
echo
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/adrules_update.sh -qO \
	/etc/dnsmasq/adrules_update.sh && chmod 755 /etc/dnsmasq/adrules_update.sh
sleep 3
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/cron.sh -qO \
	/tmp/cron.sh && chmod 775 /tmp/cron.sh && sh /tmp/cron.sh
rm -f /tmp/cron.sh
echo -e "\e[1;36m 创建脚本更新检测副本\e[0m"
if [ -s /tmp/ad_auto.sh ]; then
	mv -f /tmp/ad_auto.sh /etc/dnsmasq/ad_auto.sh
fi
if [ -f "/tmp/copyright.sh" ]; then
	rm -f /tmp/copyright.sh
fi
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
