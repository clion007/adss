#!/bin/sh
echo -e "\e[1;36m 开始下载Dnsmasq广告规则\e[0m"
echo
echo -e "\e[1;36m 下载anti-AD广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /etc/dnsmasq/antiAD.conf 'https://raw.gitmirror.com/privacy-protection-tools/anti-AD/master/adblock-for-dnsmasq.conf'
sed -i "/#/d" /etc/dnsmasq/antiAD.conf
sed -i 's/$/&127.0.0.1/g' /etc/dnsmasq/antiAD.conf
echo
echo -e "\e[1;36m 下载yoyoAd广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /etc/dnsmasq/yoyoAd.conf 'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq'
sed -i "/</d" /etc/dnsmasq/yoyoAd.conf
sed -i "/]/d" /etc/dnsmasq/yoyoAd.conf
sed -i '/^$/d' /etc/dnsmasq/yoyoAd.conf
echo
echo -e "\e[1;36m 下载notrackAd广告规则,文件较大请耐心等待\e[0m"
wget --no-check-certificate -c -q -T 60 -O /etc/dnsmasq/notrackAdDomain.conf 'https://raw.gitmirror.com/notracking/hosts-blocklists/master/domains.txt'
echo
echo -e "\e[1;36m 下载neodevhost广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /etc/dnsmasq/neodevhost.conf https://neodev.team/dnsmasq.conf
echo
sleep 3
echo -e "\e[1;36m 创建广告黑名单缓存\e[0m"
wget --no-check-certificate -c -q -T 60 -O /etc/dnsmasq/adblacklist https://gitcode.net/clion007/dnsmasq/raw/master/adblacklist
awk '!a[$0]++' /etc/dnsmasq/userblacklist /etc/dnsmasq/adblacklist > /etc/dnsmasq/blacklist
rm -rf /etc/dnsmasq/adblacklist
sed -i "/#/d" /etc/dnsmasq/blacklist
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /etc/dnsmasq/blacklist #支持通配符
echo
echo -e "\e[1;36m 添加用户定义的解析规则\e[0m"
cat /etc/dnsmasq.d/userlist > /etc/dnsmasq/dnsAd
echo
echo -e "\e[1;36m 合并dnsmasq缓存\e[0m"
cat /etc/dnsmasq/antiAD.conf /etc/dnsmasq/notrackAdDomain.conf /etc/dnsmasq/yoyoAd.conf /etc/dnsmasq/neodevhost.conf /etc/dnsmasq/blacklist >> /etc/dnsmasq/dnsAd
echo
echo -e "\e[1;36m 删除dnsmasq临时文件\e[0m"
rm -rf /etc/dnsmasq/antiAD.conf /etc/dnsmasq/notrackAdDomain.conf /etc/dnsmasq/yoyoAd.conf /etc/dnsmasq/neodevhost.conf /etc/dnsmasq/blacklist
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/localhost/d' /etc/dnsmasq/dnsAd # 删除本地规则
sed -i 's/#.*//g' /etc/dnsmasq/dnsAd # 删除注释内容
sed -i '/^$/d' /etc/dnsmasq/dnsAd # 删除空行
echo
echo -e "\e[1;36m 统一广告规则格式\e[0m"
sed -i "s/\/0.0.0.0/\/127.0.0.1/g" /etc/dnsmasq/dnsAd
sed -i "s/[ ][ ]*/ /g" /etc/dnsmasq/dnsAd # 删除多余空格，只保留一个空格
