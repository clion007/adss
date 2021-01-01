#!/bin/sh
CRON_FILE=/etc/crontabs/$USER
clear
echo
if [ ! -s /tmp/copyright.sh ]; then
	wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/copyright.sh -c -q -O \
		/tmp/copyright.sh && chmod 775 /tmp/copyright.sh && sh /tmp/copyright.sh
else
	sh /tmp/copyright.sh
fi
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
grep "dnsmasq" $CRON_FILE >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e "\e[1;31m 添加自动更新计划任务\e[0m"
	echo
	echo -e -n "\e[1;36m 请输入更新时间(整点小时): \e[0m" 
	read timedata
	echo "$timedata" > /etc/crontabs/Update_time.conf
	echo "# 每天$timedata点25分更新广告规则
25 $timedata * * * sh /etc/dnsmasq/ad_update.sh > /dev/null 2>&1" >> $CRON_FILE
	/etc/init.d/cron reload
	echo
	echo -e "\e[1;36m 自动更新任务添加完成\e[0m"
	echo
fi
grep "reboot" $CRON_FILE >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e -n "\e[1;31m 是否设置路由器定时重启（y/n）:\e[0m"
	read isReboot
	if [ $isReboot=y ]; then
		echo
		echo -e -n "\e[1;36m 请输入每天定时重启时间(整点小时): \e[0m" 
		read reboottime
		echo "$reboottime" > /etc/crontabs/reboottime.conf
		echo "# 每天$reboottime点05分重启路由器
04 $reboottime * * * sleep 1m && touch /etc/banner && reboot" >> $CRON_FILE
		/etc/init.d/cron reload
		echo
		echo -e "\e[1;36m 定时重启任务设定完成\e[0m"
		echo
	fi	
fi
echo -e "\e[1;36m 创建脚本更新检测副本\e[0m"
wget --no-check-certificate -c -q -O /etc/dnsmasq/ad_auto.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/ad_auto.sh
chmod 755 /etc/dnsmasq/ad_auto.sh
echo
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                          +"
echo "+                 installation is complete                 +"
echo "+                                                          +"
echo "+                     Time:`date +'%Y-%m-%d'`                      +"
echo "+                                                          +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo
rm -f /tmp/ad.sh
echo -e -n "\e[1;31m 是否需要重启路由器？[y/n]：\e[0m" 
read bootNow
if [ "$bootNow" = "y" ];then
	reboot
fi
