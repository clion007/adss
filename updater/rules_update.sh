#!/bin/sh
sleep 3
wget --no-check-certificate -c -q -O /tmp/adss/initRulesFile.sh https://gitcode.net/clion007/adss/raw/master/rules/builder/initRulesFile.sh
chmod 775 /tmp/adss/initRulesFile.sh
sh /tmp/adss/initRulesFile.sh
rm -f /tmp/adss/initRulesFile.sh
echo
wget --no-check-certificate -c -q -O /tmp/adss/getDnsmasqAdRules.sh https://gitcode.net/clion007/adss/raw/master/rules/builder/getDnsmasqAdRules.sh
chmod 775 /tmp/adss/getDnsmasqAdRules.sh
sh /tmp/adss/getDnsmasqAdRules.sh
rm -f /tmp/adss/getDnsmasqAdRules.sh
echo
wget --no-check-certificate -c -q -O /tmp/adss/getHostsAdRules.sh https://gitcode.net/clion007/adss/raw/master/rules/builder/getHostsAdRules.sh
chmod 775 /tmp/adss/getHostsAdRules.sh
sh /tmp/adss/getHostsAdRules.sh
rm -f /tmp/adss/getHostsAdRules.sh
echo
wget --no-check-certificate -c -q -O /tmp/adss/deletWhiteListRules.sh https://gitcode.net/clion007/adss/raw/master/rules/builder/deletWhiteListRules.sh
chmod 775 /tmp/adss/deletWhiteListRules.sh
sh /tmp/adss/deletWhiteListRules.sh
rm -f /tmp/adss/deletWhiteListRules.sh
echo
echo -e "\e[1;36m 删除dnsmasq及hosts重复规则及临时文件\e[0m"
echo
awk '!a[$0]++' /tmp/adss/dnsAd >> /tmp/adss/dnsrules.conf
awk '!a[$0]++' /tmp/adss/hostsAd >> /tmp/adss/hostsrules.conf
echo "
# Modified DNS end" >> /tmp/adss/dnsrules.conf
echo "
# 修饰hosts结束" >> /tmp/adss/hostsrules.conf
rm -rf /tmp/adss/dnsAd /tmp/adss/hostsAd
sleep 3
if [ -s "/tmp/adss/dnsrules.conf" ]; then
    if ( ! cmp -s /tmp/adss/dnsrules.conf /usr/share/adss/rules/dnsrules.conf ); then
        echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到dnsmasq规则有更新......生成新dnsmasq规则！"
        echo
        mv -f /tmp/adss/dnsrules.conf /usr/share/adss/rules/dnsrules.conf
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
        echo " `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq规则更新完成，应用新规则。"
        echo
    else
        echo " `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq本地规则和在线规则相同，无需更新！"
        rm -f /tmp/adss/dnsrules.conf
        echo
    fi  
fi
if [ -s "/tmp/adss/hostsrules.conf" ]; then
    if ( ! cmp -s /tmp/adss/hostsrules.conf /usr/share/adss/rules/hostsrules.conf ); then
        echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到hosts规则有更新......生成新hosts规则！"
        echo
        mv -f /tmp/adss/hostsrules.conf /usr/share/adss/rules/hostsrules.conf
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
        echo " `date +'%Y-%m-%d %H:%M:%S'`: hosts规则转换完成，应用新规则。"
        echo
    else
        echo " `date +'%Y-%m-%d %H:%M:%S'`: hosts本地规则和在线规则相同，无需更新！"
        rm -f /tmp/adss/hostsrules.conf
        echo
    fi  
fi
echo -e "\e[1;36m 规则更新已完成...\e[0m"
echo
