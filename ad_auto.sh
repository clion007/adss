#!/bin/sh
if [ -s "/etc/dnsmasq/resolv.conf" ]; then
	rm -f /var/lock/opkg.lock
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
fi
clear
echo
if [ ! -s /tmp/copyright.sh ]; then
	wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/copyright.sh -c -q -O \
		/tmp/copyright.sh && chmod 775 /tmp/copyright.sh && sh /tmp/copyright.sh
	else
		sh /tmp/copyright.sh
fi
rm -f /tmp/copyright.sh
echo
echo -e "\e[1;36m 三秒后开始备份安装前路由器相关配置......\e[0m"
echo
sleep 3
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/backup.sh -c -q -O \
	/tmp/backup.sh && chmod 775 /tmp/backup.sh && sh /tmp/backup.sh
rm -f /tmp/backup.sh
echo
sleep 3
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/modifyConfig.sh -c -q -O \
	/tmp/modifyConfig.sh  && chmod 775 /tmp/modifyConfig.sh  && sh /tmp/modifyConfig.sh
rm -f /tmp/modifyConfig.sh
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/initRulesFile.sh -c -q -O \
	/tmp/initRulesFile.sh  && chmod 775 /tmp/initRulesFile.sh  && sh /tmp/initRulesFile.sh
rm -f /tmp/initRulesFile.sh
echo
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/getDnsmasqAdRules.sh -c -q -O \
	/tmp/getDnsmasqAdRules.sh  && chmod 775 /tmp/getDnsmasqAdRules.sh  && sh /tmp/getDnsmasqAdRules.sh
rm -f /tmp/getDnsmasqAdRules.sh
echo
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/getHostsAdRules.sh -c -q -O \
	/tmp/getHostsAdRules.sh  && chmod 775 /tmp/getHostsAdRules.sh  && sh /tmp/getHostsAdRules.sh
rm -f /tmp/getHostsAdRules.sh
echo
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/deletWhiteListRules.sh -c -q -O \
	/tmp/deletWhiteListRules.sh  && chmod 775 /tmp/deletWhiteListRules.sh  && sh /tmp/deletWhiteListRules.sh
rm -f /tmp/deletWhiteListRules.sh
echo
echo -e "\e[1;36m 删除dnsmasq,hosts重复规则及临时文件\e[0m"
mv /tmp/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf
mv /tmp/hostsrules.conf /etc/dnsmasq/hostsrules.conf
sort /tmp/dnsAd | uniq >> /etc/dnsmasq.d/dnsrules.conf
sort /tmp/hostsAd | uniq >> /etc/dnsmasq/hostsrules.conf
rm -rf /tmp/dnsAd /tmp/hostsAd
echo "
# Modified DNS end" >> /etc/dnsmasq.d/dnsrules.conf
echo "
# 修饰hosts结束" >> /etc/dnsmasq/hostsrules.conf
echo
sleep 3
echo -e "\e[1;36m 重启dnsmasq服务\e[0m"
killall dnsmasq
	/etc/init.d/dnsmasq restart > /dev/null 2>&1
echo
sleep 2
echo -e "\e[1;36m 获取脚本更新脚本\e[0m"
wget --no-check-certificate -c -q -O /etc/dnsmasq/ad_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/ad_update.sh && chmod 755 /etc/dnsmasq/ad_update.sh
echo
echo -e "\e[1;36m 获取规则更新脚本\e[0m"
wget --no-check-certificate -c -q -O /etc/dnsmasq/adrules_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/adrules_update.sh && chmod 755 /etc/dnsmasq/adrules_update.sh
echo
sleep 3
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/cron.sh -c -q -O \
	/tmp/cron.sh && chmod 775 /tmp/cron.sh && sh /tmp/cron.sh
rm -f /tmp/cron.sh
echo -e "\e[1;36m 创建脚本更新检测副本\e[0m"
if [ -s /tmp/ad_auto.sh ]; then
	mv -f /tmp/ad_auto.sh /etc/dnsmasq/ad_auto.sh
fi
echo
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                          +"
echo "+      Dnsmasq shell script installation is complete       +"
echo "+                                                          +"
echo "+                     Time:`date +'%Y-%m-%d'`                      +"
echo "+                                                          +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo
