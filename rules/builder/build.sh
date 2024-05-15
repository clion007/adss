 #!/bin/bash
bash <(curl -fsSL  https://gitee.com/clion007/adss/raw/master/rules/builder/initRulesFile.sh)
echo
bash <(curl -fsSL  https://gitee.com/clion007/adss/raw/master/rules/builder/getDnsmasqAdRules.sh)
echo
bash <(curl -fsSL  https://gitee.com/clion007/adss/raw/master/rules/builder/getHostsAdRules.sh)
echo
bash <(curl -fsSL  https://gitee.com/clion007/adss/raw/master/rules/builder/deletWhiteListRules.sh)
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
