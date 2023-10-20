#!/bin/sh
echo -e "\e[1;36m 开始下载Dnsmasq广告规则\e[0m"
echo
echo -e "\e[1;36m 下载vokins广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/vokins.conf https://raw.gitmirror.com/vokins/yhosts/master/dnsmasq/union.conf
echo
echo -e "\e[1;36m 下载yoyoAd广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/yoyoAd.conf https://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq\&showintro=0\&mimetype=plaintext
echo
echo -e "\e[1;36m 下载notrackAd广告规则,文件较大请耐心等待\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/notrackAdDomain.conf https://raw.gitmirror.com/notracking/hosts-blocklists/master/domains.txt
echo
sleep 3
echo -e "\e[1;36m 创建广告黑名单缓存\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/adblacklist https://gitcode.net/clion007/dnsmasq/raw/master/adblacklist
sort /etc/dnsmasq/userblacklist /tmp/adblacklist | uniq > /tmp/blacklist
rm -rf /tmp/adblacklist
sed -i "/#/d" /tmp/blacklist
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /tmp/blacklist #支持通配符
echo
echo -e "\e[1;36m 添加用户定义的解析规则\e[0m"
cat /etc/dnsmasq.d/userlist > /tmp/dnsAd
echo
echo -e "\e[1;36m 合并dnsmasq缓存\e[0m"
cat /tmp/vokins.conf /tmp/notrackAdDomain.conf /tmp/yoyoAd.conf /tmp/blacklist >> /tmp/dnsAd
echo
echo -e "\e[1;36m 删除dnsmasq临时文件\e[0m"
rm -rf /tmp/vokins.conf /tmp/notrackAdDomain.conf /tmp/yoyoAd.conf /tmp/blacklist
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/::/d' /tmp/dnsAd
sed -i '/localhost/d' /tmp/dnsAd
sed -i '/#/d' /tmp/dnsAd
echo
echo -e "\e[1;36m 统一广告规则格式\e[0m"
sed -i "s/\/0.0.0.0/\/127.0.0.1/g" /tmp/dnsAd
sed -i "s/  / /g" /tmp/dnsAd
