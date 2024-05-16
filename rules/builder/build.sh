 #!/bin/bash
curl https://gitee.com/clion007/adss/raw/master/rules/builder/initRulesFile.sh -sSo /tmp/adss/initRulesFile.sh
chmod 775 /tmp/adss/initRulesFile.sh
. /tmp/adss/initRulesFile.sh
rm -f /tmp/adss/initRulesFile.sh
echo 
curl https://gitee.com/clion007/adss/raw/master/rules/builder/getDnsmasqAdRules.sh -sSo /tmp/adss/getDnsmasqAdRules.sh
chmod 775 /tmp/adss/getDnsmasqAdRules.sh
. /tmp/adss/getDnsmasqAdRules.sh
rm -f /tmp/adss/getDnsmasqAdRules.sh
echo 
curl https://gitee.com/clion007/adss/raw/master/rules/builder/getHostsAdRules.sh -sSo /tmp/adss/getHostsAdRules.sh
chmod 775 /tmp/adss/getHostsAdRules.sh
. /tmp/adss/getHostsAdRules.sh
rm -f /tmp/adss/getHostsAdRules.sh
echo 
curl https://gitee.com/clion007/adss/raw/master/rules/builder/deletWhiteListRules.sh -sSo /tmp/adss/deletWhiteListRules.sh
chmod 775 /tmp/adss/deletWhiteListRules.sh
. /tmp/adss/deletWhiteListRules.sh
rm -f /tmp/adss/deletWhiteListRules.sh
echo 
echo -e "\e[1;36m 删除dnsmasq及hosts重复规则\e[0m"
echo 
awk '!a[$0]++' /tmp/adss/dnsAd >> /tmp/dnsrules.conf 
awk '!a[$0]++' /tmp/adss/hostsAd >> /tmp/hostsrules.conf 
echo "
# Modified DNS end" >> /tmp/adss/dnsrules.conf
echo "
# 修饰hosts结束" >> /tmp/adss/hostsrules.conf
rm -f /tmp/adss/*Ad
