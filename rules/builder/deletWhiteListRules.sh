 #!/bin/bash
echo -e "\e[1;36m 删除白名单及误杀规则，时间较长，请耐心等待。。。\e[0m"
curl https://gitee.com/clion007/adss/raw/master/rules/adss/adwhitelist -sSo /tmp/adss/adwhitelist
if [ -f /usr/share/adss/userwhitelist ]; then
  sort /usr/share/adss/rules/userwhitelist /tmp/adss/adwhitelist | uniq > /tmp/adss/whitelist 
else
  sort /tmp/adss/adwhitelist | uniq > /tmp/adss/whitelist
fi
sed -i "/#/d" /tmp/adss/whitelist
rm -rf /tmp/adss/adwhitelist
while read -r line
do
	if [ -s "/tmp/adss/dnsAd" ]; then 
		sed -i "/$line/d" /tmp/adss/dnsAd
	fi
	if [ -s "/tmp/adss/hostsAd" ]; then 
		sed -i "/$line/d" /tmp/adss/hostsAd
	fi
done < /tmp/adss/whitelist
rm -rf /tmp/adss/whitelist
