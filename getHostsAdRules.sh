#!/bin/sh
echo -e "\e[1;36m 开始下载Hosts广告规则\e[0m"
echo
echo -e "\e[1;36m 下载someonewhocares缓存\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/someonewhocares.conf https://someonewhocares.org/hosts/zero/hosts
echo
echo -e "\e[1;36m 下载adaway规则缓存\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/adaway.conf https://adaway.org/hosts.txt
echo
echo -e "\e[1;36m 合并hosts缓存\e[0m"
cat /tmp/someonewhocares.conf /tmp/adaway.conf > /tmp/hostsAd
echo
echo -e "\e[1;36m 删除hosts临时文件\e[0m"
rm -rf /tmp/someonewhocares.conf /tmp/adaway.conf
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/#.*//g' /tmp/hostsAd
sed -i '/@.*//g' /tmp/hostsAd
sed -i '/::1/d' /tmp/hostsAd
sed -i '/localhost/d' /tmp/hostsAd
echo
echo -e "\e[1;36m 统一广告规则格式\e[0m"
sed -i "s/[ ][ ]*/ /g" /tmp/hostsAd
sed -i "s/0.0.0.0/127.0.0.1/g" /tmp/hostsAd
