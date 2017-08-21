#!/bin/sh
echo
sleep 3
echo " 开始更新dnsmasq规则"
echo
echo -e "\e[1;36m 下载vokins广告规则\e[0m"
wget --no-check-certificate -q -O /tmp/ad.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf
echo
echo -e "\e[1;36m 下载easylistchina广告规则\e[0m"
wget --no-check-certificate -q -O /tmp/easylistchina.conf https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt
echo
echo -e "\e[1;36m 下载yhosts缓存\e[0m"
wget --no-check-certificate -q -O /tmp/yhosts.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt
echo
echo -e "\e[1;36m 下载malwaredomainlist规则\e[0m"
wget --no-check-certificate -q -O /tmp/mallist http://www.malwaredomainlist.com/hostslist/hosts.txt && sed -i "s/.$//g" /tmp/mallist
echo
echo -e "\e[1;36m 下载adaway规则缓存\e[0m"
wget --no-check-certificate -q -O /tmp/adaway https://adaway.org/hosts.txt
wget --no-check-certificate -q -O /tmp/adaway2 http://winhelp2002.mvps.org/hosts.txt && sed -i "s/.$//g" /tmp/adaway2
wget --no-check-certificate -q -O /tmp/adaway3 http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt
wget --no-check-certificate -q -O /tmp/adaway4 https://hosts-file.net/ad_servers.txt && sed -i "s/.$//g" /tmp/adaway4
#wget --no-check-certificate -q -O /tmp/adaway5 https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts
cat /tmp/adaway /tmp/adaway2 /tmp/adaway3 /tmp/adaway4 > /tmp/adaway.conf
rm -rf /tmp/adaway /tmp/adaway2 /tmp/adaway3 /tmp/adaway4 #/tmp/adaway5
echo
sleep 3
echo -e "\e[1;36m 创建用户自定规则缓存\e[0m"
cp /etc/dnsmasq.d/userlist /tmp/userlist
echo
echo -e "\e[1;36m 创建广告黑名单缓存\e[0m"
wget --no-check-certificate -q -O /tmp/adblacklist https://raw.githubusercontent.com/clion007/dnsmasq/master/adblacklist
sort /etc/dnsmasq/userblacklist /tmp/adblacklist | uniq > /tmp/blacklist
sed -i "/#/d" /tmp/blacklist
sed -i 's/^/127.0.0.1 &/g' /tmp/blacklist
echo
echo -e "\e[1;36m 合并dnsmasq'hosts缓存\e[0m"
cat /tmp/userlist /tmp/ad.conf /tmp/easylistchina.conf > /tmp/ad
cat /tmp/blacklist /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist > /tmp/noad
echo
echo -e "\e[1;36m 删除dnsmasq'hosts临时文件\e[0m"
rm -rf /tmp/userlist /tmp/ad.conf /tmp/easylistchina.conf /tmp/blacklist /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist
echo
echo -e "\e[1;36m 删除被误杀的广告规则\e[0m"
wget --no-check-certificate -q -O /tmp/adwhitelist https://raw.githubusercontent.com/clion007/dnsmasq/master/adwhitelist
sort userwhitelist adwhitelist | uniq > /tmp/whitelist
rm -rf /tmp/adwhitelist
while read -r line
do
	sed -i "/$line/d" /tmp/noad
	sed -i "/$line/d" /tmp/ad
done < /etc/tmp/whitelist
rm -rf /etc/tmp/whitelist
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/::1/d' /tmp/ad
sed -i '/localhost/d' /tmp/ad
sed -i '/# /d' /tmp/ad
sed -i '/#★/d' /tmp/ad
sed -i '/#address/d' /tmp/ad
sed -i '/#/d' /tmp/noad
sed -i '/@/d' /tmp/noad
sed -i '/::1/d' /tmp/noad
sed -i '/localhost/d' /tmp/noad
echo
echo -e "\e[1;36m 统一广告规则格式\e[0m"
sed -i "s/0.0.0.0/127.0.0.1/g" /tmp/ad
sed -i "s/  / /g" /tmp/ad
sed -i "s/  / /g" /tmp/noad
sed -i "s/	/ /g" /tmp/noad
sed -i "s/0.0.0.0/127.0.0.1/g" /tmp/noad
echo
echo -e "\e[1;36m 创建dnsmasq规则文件\e[0m"
echo "
############################################################
## 【Copyright (c) 2014-2017, clion007】                          ##
##                                                                ##
## 感谢https://github.com/vokins/hosts                            ##
##                                                                ##
####################################################################

# Localhost (DO NOT REMOVE) Start
address=/localhost/127.0.0.1
address=/localhost/::1
address=/ip6-localhost/::1
address=/ip6-loopback/::1
# Localhost (DO NOT REMOVE) End

# Modified DNS start
" > /etc/dnsmasq.d/ad.conf
echo
echo -e "\e[1;36m 创建hosts规则文件\e[0m"
echo "
############################################################
## 【Copyright (c) 2014-2017, clion007】                          ##
##                                                                ##
## 感谢https://github.com/vokins/hosts                            ##
##                                                                ##
####################################################################

# 默认hosts开始（想恢复最初状态的hosts，只保留下面两行即可）
127.0.0.1 localhost
::1	localhost
::1	ip6-localhost
::1	ip6-loopback
# 默认hosts结束

# 修饰hosts开始
" > /etc/dnsmasq/noad.conf
echo
echo -e "\e[1;36m 删除dnsmasq'hosts重复规则及临时文件\e[0m"
sort /tmp/ad | uniq >> /tmp/ad.conf
sort /tmp/noad | uniq >> /tmp/noad.conf
rm -rf /tmp/ad /tmp/noad
echo "# Modified DNS end" >> /tmp/ad.conf
echo "# 修饰hosts结束" >> /tmp/noad.conf
echo
sleep 3
if [ -s "/tmp/ad.conf" ]; then
	if ( ! cmp -s /tmp/ad.conf /etc/dnsmasq.d/ad.conf ); then
		mv -f /tmp/ad.conf /etc/dnsmasq.d/ad.conf
		echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到ad规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: ad规则转换完成，应用新规则。"
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: ad本地规则和在线规则相同，无需更新！" && rm -f /tmp/ad.conf
	fi	
fi
echo
if [ -s "/tmp/noad.conf" ]; then
	if ( ! cmp -s /tmp/noad.conf /etc/dnsmasq/noad.conf ); then
		mv -f /tmp/noad.conf /etc/dnsmasq/noad.conf
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到noad规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: noad规则转换完成，应用新规则。"
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: noad本地规则和在线规则相同，无需更新！" && rm -f /tmp/noad.conf
	fi	
fi
echo
echo -e "\e[1;36m 规则更新成功\e[0m"
exit 0
