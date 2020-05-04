#!/bin/sh
sleep 
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/initRulesFile.sh -c -O \
	/tmp/initRulesFile.sh  && chmod 775 /tmp/initRulesFile.sh  && sh /tmp/initRulesFile.sh
	rm -f /tmp/initRulesFile.sh
echo
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/getDnsmasqAdRules.sh -c -O \
	/tmp/getDnsmasqAdRules.sh  && chmod 775 /tmp/getDnsmasqAdRules.sh  && sh /tmp/getDnsmasqAdRules.sh
	rm -f /tmp/getDnsmasqAdRules.sh
echo
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/getHostsAdRules.sh -c -O \
	/tmp/getHostsAdRules.sh  && chmod 775 /tmp/getHostsAdRules.sh  && sh /tmp/getHostsAdRules.sh
	rm -f /tmp/getHostsAdRules.sh
echo
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/deletWhiteListRules.sh -c -O \
	/tmp/deletWhiteListRules.sh  && chmod 775 /tmp/deletWhiteListRules.sh  && sh /tmp/deletWhiteListRules.sh
	rm -f /tmp/deletWhiteListRules.sh
echo
echo -e "\e[1;36m 删除dnsmasq'hosts重复规则及临时文件\e[0m"
sort /tmp/dnsAd | uniq >> /tmp/dnsrules.conf
sort /tmp/noad | uniq >> /tmp/hostsrules.conf
rm -rf  /tmp/dnsAd /tmp/hostsAd
echo "
# Modified DNS end" >> /tmp/dnsrules.conf
echo "
# 修饰hosts结束" >> /tmp/hostsrules.conf
echo
sleep 3
if [ -s "/tmp/dnsrules.conf" ]; then
	if ( ! cmp -s /tmp/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf ); then
		mv -f /tmp/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf
		echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到ad规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: ad规则转换完成，应用新规则。"
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: ad本地规则和在线规则相同，无需更新！" && rm -f /tmp/dnsrules.conf
	fi	
fi
echo
if [ -s "/tmp/hostsrules.conf" ]; then
	if ( ! cmp -s /tmp/hostsrules.conf /etc/dnsmasq/hostsrules.conf ); then
		mv -f /tmp/hostsrules.conf /etc/dnsmasq/hostsrules.conf
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到noad规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: noad规则转换完成，应用新规则。"
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: noad本地规则和在线规则相同，无需更新！" && rm -f /tmp/hostsrules.conf
	fi	
fi
echo
echo -e "\e[1;36m 规则更新成功\e[0m"
echo
