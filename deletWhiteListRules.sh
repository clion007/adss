#!/bin/sh
echo -e "\e[1;36m 删除白名单及误杀规则，时间较长，请耐心等待。。。\e[0m"
wget --no-check-certificate -c -q -O /tmp/adwhitelist https://gitcode.net/clion007/dnsmasq/raw/master/adwhitelist
sort /etc/dnsmasq/userwhitelist /tmp/adwhitelist | uniq > /tmp/whitelist
sed -i "/#/d" /tmp/whitelist
rm -rf /tmp/adwhitelist
while read -r line
do
	if [ -s "/etc/dnsmasq/dnsAd" ]; then 
		sed -i "/$line/d" /etc/dnsmasq/dnsAd
	fi
	if [ -s "/tmp/hostsAd" ]; then 
		sed -i "/$line/d" /tmp/hostsAd
	fi
done < /tmp/whitelist
rm -rf /tmp/whitelist
