 #!/bin/bash
echo -e "\e[1;36m 开始下载Dnsmasq广告规则\e[0m"
echo 
echo -e "\e[1;36m 下载anti-AD广告规则\e[0m"
curl "https://raw.gitmirror.com/privacy-protection-tools/anti-AD/master/adblock-for-dnsmasq.conf" -sSo /tmp/adss/antiAD.conf
sed -i "/#/d" /tmp/adss/antiAD.conf
sed -i 's/$/&127.0.0.1/g' /tmp/adss/antiAD.conf
echo 
echo -e "\e[1;36m 下载yoyoAd广告规则\e[0m"
curl "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=dnsmasq" -sSo /tmp/adss/yoyoAd.conf
sed -i "/</d" /tmp/adss/yoyoAd.conf
sed -i "/]/d" /tmp/adss/yoyoAd.conf
sed -i '/^$/d' /tmp/adss/yoyoAd.conf
echo 
echo -e "\e[1;36m 下载notrackAd广告规则,文件较大请耐心等待\e[0m"
curl "https://raw.gitmirror.com/notracking/hosts-blocklists/master/domains.txt" -sSo /tmp/adss/notrackAdDomain.conf
echo 
echo -e "\e[1;36m 下载neodevhost广告规则\e[0m"
curl https://neodev.team/dnsmasq.conf -sSo /tmp/adss/neodevhost.conf
echo 
sleep 3
echo -e "\e[1;36m 创建广告黑名单缓存\e[0m"
curl https://gitee.com/clion007/adss/raw/master/rules/adss/adblacklist -sSo /tmp/adss/adblacklist
if [ -f /usr/share/adss/userblacklist ]; then
  awk '!a[$0]++' /usr/share/adss/rules/userblacklist /tmp/adss/adblacklist > /tmp/adss/blacklist
else
  awk '!a[$0]++' /tmp/adss/adblacklist > /tmp/adss/blacklist
fi
rm -rf /tmp/adss/adblacklist
sed -i "/#/d" /tmp/adss/blacklist
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /tmp/adss/blacklist #支持通配符
echo 
if [ -f /usr/share/adss/userlist ]; then
  echo -e "\e[1;36m 添加用户定义的解析规则\e[0m"
  cat /usr/share/adss/userlist > /tmp/adss/dnsAd
  echo 
fi
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
