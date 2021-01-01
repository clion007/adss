#!/bin/sh
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
	wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/backup.sh -qO \
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
echo -e "\e[1;36m 下载扶墙和广告规则\e[0m"
echo
echo -e "\e[1;36m 下载googlehosts规则\e[0m"
wget --no-check-certificate -q -O /tmp/googlehosts https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/dnsmasq.conf
sed -i '/::1/d' /tmp/googlehosts
sed -i '/localhost/d' /tmp/googlehosts
sed -i '/#/d' /tmp/googlehosts
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
echo -e "\e[1;36m 合并扶墙、广告规则缓存\e[0m"
cat /tmp/googlehosts /tmp/dnsAd > /tmp/dnsrules
mv /tmp/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf
mv /tmp/hostsrules.conf /etc/dnsmasq/hostsrules.conf
echo
echo -e "\e[1;36m 删除dnsmasq,hosts重复规则及临时文件\e[0m"
sort /tmp/dnsrules | uniq >> /etc/dnsmasq.d/dnsrules.conf
sort /tmp/hostsAd | uniq >> /etc/dnsmasq/hostsrules.conf
rm -rf /tmp/googlehosts /tmp/dnsAd /tmp/dnsrules /tmp/hostsAd
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
wget --no-check-certificate -q -O /etc/dnsmasq/fqad_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/fqad_update.sh && chmod 755 /etc/dnsmasq/fqad_update.sh
echo
echo -e "\e[1;36m 获取规则更新脚本\e[0m"
wget --no-check-certificate -q -O /etc/dnsmasq/fqadrules_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/fqadrules_update.sh && chmod 755 /etc/dnsmasq/fqadrules_update.sh
echo
sleep 3
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/cron.sh -qO \
	/tmp/cron.sh && chmod 775 /tmp/cron.sh && sh /tmp/cron.sh
rm -f /tmp/cron.sh
echo -e "\e[1;36m 创建脚本更新检测副本\e[0m"
if [ -f /tmp/fqad_auto.sh ]; then
	mv -f /tmp/fqad_auto.sh /etc/dnsmasq/fqad_auto.sh
fi
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
