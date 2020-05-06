#!/bin/sh
echo -e "\e[1;36m 开始下载Hosts广告规则\e[0m"
echo
echo -e "\e[1;36m 下载yhosts缓存\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/yhosts.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt
echo
echo -e "\e[1;36m 下载malwaredomainlist规则\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/mallist http://www.malwaredomainlist.com/hostslist/hosts.txt
sed -i "s/.$//g" /tmp/mallist
echo
echo -e "\e[1;36m 下载adaway规则缓存\e[0m"
wget --no-check-certificate -c -q -T 60 -O /tmp/adaway https://adaway.org/hosts.txt
wget --no-check-certificate -c -q -T 60 -O /tmp/adaway2 http://winhelp2002.mvps.org/hosts.txt
sed -i "s/.$//g" /tmp/adaway2
echo
echo -e "\e[1;36m adaway规则下载完成，开始合并规则\e[0m"
cat /tmp/adaway /tmp/adaway2 > /tmp/adaway.conf
echo
echo -e "\e[1;36m adaway规则合并完成，清除生成的规则缓存文件\e[0m"
rm -rf /tmp/adaway /tmp/adaway2
echo
echo -e "\e[1;36m 合并hosts缓存\e[0m"
cat /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist > /tmp/hostsAd
echo
echo -e "\e[1;36m 删除hosts临时文件\e[0m"
rm -rf /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/#/d' /tmp/hostsAd
sed -i '/@/d' /tmp/hostsAd
sed -i '/::1/d' /tmp/hostsAd
sed -i '/localhost/d' /tmp/hostsAd
echo
echo -e "\e[1;36m 统一广告规则格式\e[0m"
sed -i "s/  / /g" /tmp/hostsAd
sed -i "s/	/ /g" /tmp/hostsAd
sed -i "s/0.0.0.0/127.0.0.1/g" /tmp/hostsAd
