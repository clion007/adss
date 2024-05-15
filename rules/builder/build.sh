 #!/bin/bash
curl -sSo /tmp/adss/initRulesFile.sh "https://gitee.com/clion007/adss/raw/master/rules/builder/initRulesFile.sh"
chmod 775 /tmp/adss/initRulesFile.sh
. /tmp/adss/initRulesFile.sh
rm -f /tmp/adss/initRulesFile.sh
echo 
curl -sSo /tmp/adss/getDnsmasqAdRules.sh "https://gitee.com/clion007/adss/raw/master/rules/builder/getDnsmasqAdRules.sh"
chmod 775 /tmp/adss/getDnsmasqAdRules.sh
. /tmp/adss/getDnsmasqAdRules.sh
rm -f /tmp/adss/getDnsmasqAdRules.sh
echo 
curl -sSo /tmp/adss/getHostsAdRules.sh https://gitee.com/clion007/adss/raw/master/rules/builder/getHostsAdRules.sh
chmod 775 /tmp/adss/getHostsAdRules.sh
. /tmp/adss/getHostsAdRules.sh
rm -f /tmp/adss/getHostsAdRules.sh
echo 
curl -sSo /tmp/adss/deletWhiteListRules.sh https://gitee.com/clion007/adss/raw/master/rules/builder/deletWhiteListRules.sh
chmod 775 /tmp/adss/deletWhiteListRules.sh
. /tmp/adss/deletWhiteListRules.sh
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
