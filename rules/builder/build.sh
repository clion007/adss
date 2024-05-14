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