 #!/bin/bash
echo -e "\e[1;36m 删除dnsmasq及hosts重复规则\e[0m"
echo 
awk '!a[$0]++' /tmp/adss/dnsAd >> /tmp/adss/dnsrules.conf 
awk '!a[$0]++' /tmp/adss/hostsAd >> /tmp/adss/hostsrules.conf 
echo "
# Modified DNS end" >> /tmp/adss/dnsrules.conf 
echo "
# 修饰hosts结束" >> /tmp/adss/hostsrules.conf 
mv -f /tmp/adss/dnsrules.conf ./rules/file/dnsrules.conf
mv -f /tmp/adss/hostsrules.conf ./rules/file/hostsrules.conf