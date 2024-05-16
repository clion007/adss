 #!/bin/bash
./rules/builder/initRulesFile.sh
echo 
./rules/builder/getDnsmasqAdRules.sh
echo 
./rules/builder/getHostsAdRules.sh
echo 
./rules/builder/deletWhiteListRules.sh
echo 
echo -e "\e[1;36m 删除dnsmasq及hosts重复规则\e[0m"
echo 
awk '!a[$0]++' /tmp/adss/dnsAd >> /tmp/adss/dnsrules.conf 
awk '!a[$0]++' /tmp/adss/hostsAd >> /tmp/adss/hostsrules.conf 
echo "
# Modified DNS end" >> /tmp/adss/dnsrules.conf 
echo "
# 修饰hosts结束" >> /tmp/adss/hostsrules.conf 
rm -f /tmp/adss/*Ad
