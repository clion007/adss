#!/bin/sh
sleep 3
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/initRulesFile.sh -c -O \
	/tmp/initRulesFile.sh  && chmod 775 /tmp/initRulesFile.sh  && sh /tmp/initRulesFile.sh
rm -f /tmp/initRulesFile.sh
echo
echo -e "\e[1;36m 下载扶墙和广告规则\e[0m"
echo
echo -e "\e[1;36m 下载googlehosts规则\e[0m"
wget --no-check-certificate -q -O /tmp/googlehosts https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/dnsmasq.conf
sed -i '/::/d' /tmp/googlehosts
sed -i '/localhost/d' /tmp/googlehosts
sed -i '/#/d' /tmp/googlehosts
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
echo -e "\e[1;36m 合并扶墙、广告规则缓存\e[0m"
cat /tmp/googlehosts /tmp/dnsAd > /tmp/dnsrules
echo -e "\e[1;36m 删除dnsmasq,hosts重复规则及临时文件\e[0m"
sort /tmp/dnsrules | uniq >> /tmp/dnsrules.conf
sort /tmp/hostsAd | uniq >> /tmp/hostsrules.conf
rm -rf /tmp/googlehosts /tmp/dnsAd /tmp/dnsrules /tmp/hostsAd
echo "
# Modified DNS end" >> /tmp/dnsrules.conf
echo "
# 修饰hosts结束" >> /tmp/hostsrules.conf
echo
if [ -s "/tmp/dnsrules.conf" ]; then
	if ( ! cmp -s /tmp/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf ); then
		mv -f /tmp/dnsrules.conf /etc/dnsmasq.d/dnsrules.conf
		echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到fqad规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo
		echo " `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq规则转换完成，应用新规则。"
		echo
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq本地规则和在线规则相同，无需更新！" && rm -f /tmp/dnsrules.conf
		echo
	fi	
fi
if [ -s "/tmp/hostsrules.conf" ]; then
	if ( ! cmp -s /tmp/hostsrules.conf /etc/dnsmasq/hostsrules.conf ); then
		mv -f /tmp/hostsrules.conf /etc/dnsmasq/hostsrules.conf
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到noad规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo
		echo " `date +'%Y-%m-%d %H:%M:%S'`: hosts规则转换完成，应用新规则。"
		echo
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: hosts本地规则和在线规则相同，无需更新！" && rm -f /tmp/hostsrules.conf
		echo
	fi	
fi
echo -e "\e[1;36m hosts,dnsmasq规则更新成功\e[0m"
