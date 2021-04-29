#!/bin/sh
sleep 3
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
echo -e "\e[1;36m 删除dnsmasq'hosts重复规则及临时文件\e[0m"
echo
sort /tmp/dnsAd | uniq >> /tmp/dnsrules.conf
sort /tmp/hostsAd | uniq >> /tmp/hostsrules.conf
echo "
# Modified DNS end" >> /tmp/dnsrules.conf
echo "
# 修饰hosts结束" >> /tmp/hostsrules.conf
rm -rf /tmp/dnsAd /tmp/hostsAd
sleep 3
if [ -s "/tmp/dnsrules.conf" ]; then
	if ( ! cmp -s /tmp/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到dnsmasq规则有更新......生成新dnsmasq规则！"
		echo
		mv -f /tmp/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq规则更新完成，应用新规则。"
		echo
	else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq本地规则和在线规则相同，无需更新！" && rm -f /tmp/dnsrules.conf
		echo
	fi	
fi
if [ -s "/tmp/hostsrules.conf" ]; then
	if ( ! cmp -s /tmp/hostsrules.conf /etc/dnsmasq/hostsrules.conf ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到hosts规则有更新......生成新hosts规则！"
		echo
		mv -f /tmp/hostsrules.conf /etc/dnsmasq/hostsrules.conf
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: hosts规则转换完成，应用新规则。"
		echo
	else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: hosts本地规则和在线规则相同，无需更新！" && rm -f /tmp/hostsrules.conf
		echo
	fi	
fi
echo -e "\e[1;36m 规则更新完成...\e[0m"
echo
