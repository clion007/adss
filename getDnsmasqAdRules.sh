#!/bin/sh
echo -e "\e[1;36m 开始下载Dnsmasq广告规则\e[0m"
echo
echo -e "\e[1;36m 下载anti-AD广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/antiAD.conf 'https://raw.gitmirror.com/privacy-protection-tools/anti-AD/master/adblock-for-dnsmasq.conf'
sed -i "/#/d" /tmp/antiAD.conf
sed -i 's/$/&127.0.0.1/g' /tmp/antiAD.conf
echo
echo -e "\e[1;36m 下载yoyoAd广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/yoyoAd.conf 'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq'
sed -i "/</d" /tmp/yoyoAd.conf
sed -i "/]/d" /tmp/yoyoAd.conf
sed -i '/^$/d' /tmp/yoyoAd.conf
echo
echo -e "\e[1;36m 下载notrackAd广告规则,文件较大请耐心等待\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/notrackAdDomain.conf 'https://raw.gitmirror.com/notracking/hosts-blocklists/master/domains.txt'
echo
echo -e "\e[1;36m 下载neodevhost广告规则,文件较大请耐心等待\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/neodevhost.conf 'https://neodev.team/dnsmasq.conf'
echo
sleep 3
echo -e "\e[1;36m 创建广告黑名单缓存\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/adblacklist https://gitcode.net/clion007/dnsmasq/raw/master/adblacklist
awk '!a[$0]++' /etc/dnsmasq/userblacklist /tmp/adblacklist > /tmp/blacklist
rm -rf /tmp/adblacklist
sed -i "/#/d" /tmp/blacklist
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /tmp/blacklist #支持通配符
echo
echo -e "\e[1;36m 添加用户定义的解析规则\e[0m"
cat /etc/dnsmasq.d/userlist > /tmp/dnsAd
echo
echo -e "\e[1;36m 合并dnsmasq缓存\e[0m"
cat /tmp/antiAD.conf /tmp/notrackAdDomain.conf /tmp/yoyoAd.conf /tmp/neodevhost.conf /tmp/blacklist >> /tmp/dnsAd
echo
echo -e "\e[1;36m 删除dnsmasq临时文件\e[0m"
rm -rf /tmp/antiAD.conf /tmp/notrackAdDomain.conf /tmp/yoyoAd.conf /tmp/neodevhost.conf /tmp/blacklist
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/localhost/d' /tmp/dnsAd # 删除本地规则
sed -i '/#.*//g' /tmp/dnsAd # 删除注释内容
sed -i '/^$/d' /tmp/dnsAd # 删除空行
echo
echo -e "\e[1;36m 统一广告规则格式\e[0m"
sed -i "s/\/0.0.0.0/\/127.0.0.1/g" /tmp/dnsAd
sed -i "s/[ ][ ]*/ /g" /tmp/dnsAd # 删除多余空格，只保留一个空格

