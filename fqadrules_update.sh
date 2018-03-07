#!/bin/sh
echo
sleep 3
echo " 开始更新dnsmasq规则"
# 下载sy618扶墙规则
wget --no-check-certificate -q -O /tmp/sy618 https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq
# 下载googlehosts规则
#wget --no-check-certificate -q -O /tmp/googlehosts https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/dnsmasq.conf
# 下载vokins广告规则
wget --no-check-certificate -q -O /tmp/ad.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf
# 下载easylistchina广告规则
wget --no-check-certificate -q -O /tmp/easylistchina.conf https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt

# 删除racaljk规则中的冲突规则
#sed -i '/google/d' /tmp/googlehosts
#sed -i '/youtube/d' /tmp/googlehosts

# 创建用户自定规则缓存
cp /etc/dnsmasq.d/userlist /tmp/userlist

# 创建广告黑名单缓存
wget --no-check-certificate -q -O /tmp/adblacklist https://raw.githubusercontent.com/clion007/dnsmasq/master/adblacklist
sort /etc/dnsmasq/userblacklist /tmp/adblacklist | uniq > /tmp/blacklist
rm -rf /tmp/adblacklist
sed -i "/#/d" /tmp/blacklist
#sed -i 's/^/127.0.0.1 &/g' /tmp/blacklist #hosts方式，不支持通配符
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /tmp/blacklist #改为dnsmasq方式，支持通配符
echo
# 合并dnsmasq缓存
#cat /tmp/userlist /tmp/googlehosts /tmp/sy618 /tmp/ad.conf /tmp/easylistchina.conf /tmp/blacklist > /tmp/fqad
cat /tmp/userlist /tmp/sy618 /tmp/ad.conf /tmp/easylistchina.conf /tmp/blacklist > /tmp/fqad

# 删除dnsmasq缓存
rm -rf /tmp/userlist /tmp/sy618 /tmp/ad.conf /tmp/easylistchina.conf /tmp/blacklist
#rm -rf /tmp/googlehosts

# 创建广告白名单缓存
wget --no-check-certificate -q -O /tmp/adwhitelist https://raw.githubusercontent.com/clion007/dnsmasq/master/adwhitelist
sort /etc/dnsmasq/userwhitelist /tmp/adwhitelist | uniq > /tmp/whitelist
sed -i "/#/d" /tmp/whitelist
rm -rf /tmp/adwhitelist

# 删除误杀广告规则
while read -r line
do
	sed -i "/$line/d" /tmp/fqad
done < /tmp/whitelist

# 删除注释和本地规则
sed -i '/::1/d' /tmp/fqad
sed -i '/localhost/d' /tmp/fqad
sed -i '/# /d' /tmp/fqad
sed -i '/#★/d' /tmp/fqad
sed -i '/#@/d' /tmp/fqad
sed -i '/##/d' /tmp/fqad
sed -i '/#address/d' /tmp/fqad
sed -i '/#server/d' /tmp/fqad
sed -i '/#youtube/d' /tmp/fqad
echo
echo -e " 统一DNS广告规则格式"
sed -i "s/0.0.0.0/127.0.0.1/g" /tmp/fqad
sed -i "s/  / /g" /tmp/fqad
# 创建dnsmasq规则文件
echo "
############################################################
##【Copyright (c) 2014-2017, clion007】                           ##
##                                                                ##
## 感谢https://github.com/sy618/hosts                             ##
## 感谢https://github.com/googlehosts/hosts                       ##
####################################################################

# Localhost (DO NOT REMOVE) Start
address=/localhost/127.0.0.1
address=/localhost/::1
address=/ip6-localhost/::1
address=/ip6-loopback/::1
# Localhost (DO NOT REMOVE) End

# Modified DNS start" > /tmp/fqad.conf

# 删除dnsmasq重复规则
sort /tmp/fqad | uniq >> /tmp/fqad.conf
echo "
# Modified DNS end" >> /tmp/fqad.conf

# 删除dnsmasq合并缓存
rm -rf /tmp/fqad
echo
echo " 开始更新hosts规则"
# 下载yhosts缓存
wget --no-check-certificate -q -O /tmp/yhosts.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts
# 下载malwaredomainlist规则
wget --no-check-certificate -q -O /tmp/mallist http://www.malwaredomainlist.com/hostslist/hosts.txt && sed -i "s/.$//g" /tmp/mallist
# 下载whocare缓存
wget --no-check-certificate -q -O /tmp/whocare http://someonewhocares.org/hosts/hosts
# 下载adaway规则缓存
wget --no-check-certificate -q -O /tmp/adaway https://adaway.org/hosts.txt
wget --no-check-certificate -q -O /tmp/adaway2 http://winhelp2002.mvps.org/hosts.txt && sed -i "s/.$//g" /tmp/adaway2
wget --no-check-certificate -q -O /tmp/adaway3 http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt
wget --no-check-certificate -q -O /tmp/adaway4 https://hosts-file.net/ad_servers.txt && sed -i "s/.$//g" /tmp/adaway4
#wget --no-check-certificate -q -O /tmp/adaway5 https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts
cat /tmp/adaway /tmp/adaway2 /tmp/adaway3 /tmp/adaway4 > /tmp/adaway.conf
rm -rf /tmp/adaway /tmp/adaway2 /tmp/adaway3 /tmp/adaway4 #/tmp/adaway5
echo
# 合并hosts缓存
cat /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist /tmp/whocare > /tmp/noad

# 删除hosts缓存
rm -rf /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist /tmp/whocare

# 删除误杀广告规则
while read -r line
do
	sed -i "/$line/d" /tmp/noad
done < /tmp/whitelist
rm -rf /tmp/whitelist

# 删除注释及本地规则
sed -i '/#/d' /tmp/noad
sed -i '/@/d' /tmp/noad
sed -i '/::1/d' /tmp/noad
sed -i '/localhost/d' /tmp/noad

echo -e " 统一hosts广告规则格式"
sed -i "s/  / /g" /tmp/noad
sed -i "s/	/ /g" /tmp/noad
sed -i "s/0.0.0.0/127.0.0.1/g" /tmp/noad
# 创建hosts规则文件
echo "
############################################################
##【Copyright (c) 2014-2017, clion007】                           ##
##                                                                ##
## 感谢https://github.com/sy618/hosts                             ##
## 感谢https://github.com/vokins/hosts                            ##
## 感谢https://github.com/googlehosts/hosts                       ##
####################################################################

# 默认hosts开始（想恢复最初状态的hosts，只保留下面两行即可）
127.0.0.1 localhost
::1	localhost
::1	ip6-localhost
::1	ip6-loopback
# 默认hosts结束

# 修饰hosts开始" > /tmp/noad.conf

# 删除hosts重复规则
sort /tmp/noad | uniq >> /tmp/noad.conf
echo "
# 修饰hosts结束" >> /tmp/noad.conf

# 删除hosts合并缓存
rm -rf /tmp/noad
echo
if [ -s "/tmp/fqad.conf" ]; then
	if ( ! cmp -s /tmp/fqad.conf /etc/dnsmasq.d/fqad.conf ); then
		mv -f /tmp/fqad.conf /etc/dnsmasq.d/fqad.conf
		echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到fqad规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: fqad规则转换完成，应用新规则。"
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: fqad本地规则和在线规则相同，无需更新！" && rm -f /tmp/fqad.conf
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
echo
exit 0
