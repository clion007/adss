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
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/backup.sh -qO \
	/tmp/adss/backup.sh && chmod 775 /tmp/adss/backup.sh && sh /tmp/adss/backup.sh
rm -f /tmp/adss/backup.sh
echo
sleep 3
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/modifyConfig.sh -qO \
	/tmp/adss/modifyConfig.sh  && chmod 775 /tmp/adss/modifyConfig.sh  && sh /tmp/adss/modifyConfig.sh
rm -f /tmp/modifyConfig.sh
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/initRulesFile.sh -qO \
	/tmp/adss/initRulesFile.sh  && chmod 775 /tmp/adss/initRulesFile.sh  && sh /tmp/adss/initRulesFile.sh
rm -f /tmp/adss/initRulesFile.sh
echo
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/getDnsmasqAdRules.sh -qO \
	/tmp/adss/getDnsmasqAdRules.sh  && chmod 775 /tmp/adss/getDnsmasqAdRules.sh  && sh /tmp/adss/getDnsmasqAdRules.sh
rm -f /tmp/adss/getDnsmasqAdRules.sh
echo
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/getHostsAdRules.sh -qO \
	/tmp/adss/getHostsAdRules.sh  && chmod 775 /tmp/adss/getHostsAdRules.sh  && sh /tmp/adss/getHostsAdRules.sh
rm -f /tmp/adss/getHostsAdRules.sh
echo
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/deletWhiteListRules.sh -qO \
	/tmp/adss/deletWhiteListRules.sh  && chmod 775 /tmp/adss/deletWhiteListRules.sh  && sh /tmp/adss/deletWhiteListRules.sh
rm -f /tmp/adss/deletWhiteListRules.sh
echo
echo -e "\e[1;36m 删除dnsmasq,hosts重复规则及临时文件\e[0m"
echo
awk '!a[$0]++' /tmp/adss/dnsAd >> /tmp/adss/dnsrules.conf
awk '!a[$0]++' /tmp/adss/hostsAd >> /tmp/adss/hostsrules.conf
echo "
# Modified DNS end" >> /tmp/adss/dnsrules.conf
echo "
# 修饰hosts结束" >> /tmp/adss/hostsrules.conf
mv /tmp/adss/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf
mv /tmp/adss/hostsrules.conf /etc/dnsmasq.d/hostsrules.conf
rm -rf /tmp/adss/dnsAd /tmp/adss/hostsAd
sleep 3
echo -e "\e[1;36m 重启dnsmasq服务\e[0m"
echo
killall dnsmasq > /dev/null 2>&1
/etc/init.d/dnsmasq restart > /dev/null 2>&1
sleep 2
echo -e "\e[1;36m 获取脚本更新脚本\e[0m"
echo
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/ad_update.sh -qO \
	/etc/dnsmasq.d/ad_update.sh && chmod 755 /etc/dnsmasq.d/ad_update.sh
echo -e "\e[1;36m 获取规则更新脚本\e[0m"
echo
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/adrules_update.sh -qO \
	/etc/dnsmasq.d/adrules_update.sh && chmod 755 /etc/dnsmasq.d/adrules_update.sh
sleep 3
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/cron.sh -qO \
	/tmp/adss/cron.sh && chmod 775 /tmp/adss/cron.sh && sh /tmp/adss/cron.sh
rm -f /tmp/adss/cron.sh
echo -e "\e[1;36m 创建脚本更新检测副本\e[0m"
if [ -s /tmp/adss/ad_auto.sh ]; then
	mv -f /tmp/adss/ad_auto.sh /etc/dnsmasq.d/ad_auto.sh
fi
if [ -f "/tmp/adss/copyright.sh" ]; then
	rm -f /tmp/adss/copyright.sh
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