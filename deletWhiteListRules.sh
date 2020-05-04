#!/bin/sh
echo -e "\e[1;36m 删除白名单及误杀规则\e[0m"
wget --no-check-certificate -c -O /tmp/adwhitelist https://raw.githubusercontent.com/clion007/dnsmasq/master/adwhitelist
sort /etc/dnsmasq/userwhitelist /tmp/adwhitelist | uniq > /tmp/whitelist
sed -i "/#/d" /tmp/whitelist
rm -rf /tmp/adwhitelist
while read -r line
do
	if[ -s "/tmp/ad" ]; then 
		sed -i "/$line/d" /tmp/ad
	fi
	if[ -s "/tmp/noad" ]; then 
		sed -i "/$line/d" /tmp/noad
	fi
done < /tmp/whitelist
rm -rf /tmp/whitelist
