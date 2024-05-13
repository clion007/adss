#!/bin/sh
echo -e "\e[1;36m 开始下载Dnsmasq广告规则\e[0m"
echo
echo -e "\e[1;36m 下载anti-AD广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/adss/antiAD.conf 'https://raw.gitmirror.com/privacy-protection-tools/anti-AD/master/adblock-for-dnsmasq.conf'
sed -i "/#/d" /tmp/adss/antiAD.conf
sed -i 's/$/&127.0.0.1/g' /tmp/adss/antiAD.conf
echo
echo -e "\e[1;36m 下载yoyoAd广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/adss/yoyoAd.conf 'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq'
sed -i "/</d" /tmp/adss/yoyoAd.conf
sed -i "/]/d" /tmp/adss/yoyoAd.conf
sed -i '/^$/d' /tmp/adss/yoyoAd.conf
echo
echo -e "\e[1;36m 下载notrackAd广告规则,文件较大请耐心等待\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/adss/notrackAdDomain.conf 'https://raw.gitmirror.com/notracking/hosts-blocklists/master/domains.txt'
echo
echo -e "\e[1;36m 下载neodevhost广告规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/adss/neodevhost.conf https://neodev.team/dnsmasq.conf
echo
sleep 3
echo -e "\e[1;36m 创建广告黑名单缓存\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/adss/adblacklist https://gitcode.net/clion007/adss/raw/master/rules/adss/adblacklist
awk '!a[$0]++' /etc/dnsmasq.d/adss/userblacklist /tmp/adss/adblacklist > /tmp/adss/blacklist
rm -rf /tmp/adss/adblacklist
sed -i "/#/d" /tmp/adss/blacklist
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /tmp/adss/blacklist #支持通配符
echo
echo -e "\e[1;36m 添加用户定义的解析规则\e[0m"
cat /etc/dnsmasq.d/adss/userlist > /tmp/adss/dnsAd
echo
echo -e "\e[1;36m 合并dnsmasq缓存\e[0m"
cat /tmp/adss/antiAD.conf /tmp/adss/notrackAdDomain.conf /tmp/adss/yoyoAd.conf /tmp/adss/neodevhost.conf /tmp/adss/blacklist >> /tmp/adss/dnsAd
echo
echo -e "\e[1;36m 删除dnsmasq临时文件\e[0m"
rm -rf /tmp/adss/antiAD.conf /tmp/adss/notrackAdDomain.conf /tmp/adss/yoyoAd.conf /tmp/adss/neodevhost.conf /tmp/adss/blacklist
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/localhost/d' /tmp/adss/dnsAd # 删除本地规则
sed -i 's/#.*//g' /tmp/adss/dnsAd # 删除注释内容
sed -i '/^$/d' /tmp/adss/dnsAd # 删除空行
echo
echo -e "\e[1;36m 统一广告规则格式\e[0m"
sed -i "s/\/0.0.0.0/\/127.0.0.1/g" /tmp/adss/dnsAd
sed -i "s/[ ][ ]*/ /g" /tmp/adss/dnsAd # 删除多余空格，只保留一个空格
