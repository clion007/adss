#!/bin/sh
echo
CRON_FILE=/etc/crontabs/$USER
clear
echo
echo "# Copyright (c) 2014-2017,by clion007"
echo
echo "# 本脚本仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）"
echo "# 未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规，文明上网。"
echo "# openwrt类固件使用，包括但不限于pandorabox、LEDE、ddwrt、明月、石像鬼等，华硕、老毛子、梅林等Padavan系列固件慎用。"
echo -e "# 安装前请\e[1;31m备份原配置\e[0m；安装过程中需要输入路由器相关配置信息，由此产生的一切后果自行承担！"
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                          +"
echo "+     Install fq+Noad for OpnWrt or LEDE or PandoraBox     +"
echo "+                                                          +"
echo "+                      Time:`date +'%Y-%m-%d'`                     +"
echo "+                                                          +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo -e "\e[1;36m 三秒后开始安装......\e[0m"
echo
sleep 3
echo -e "\e[1;36m 创建dnsmasq规则与更新脚本存放的文件夹\e[0m"
echo
echo -e "\e[1;36m 检测和备份当前dnsmasq配置信息\e[0m"
if [ -d /etc/dnsmasq ]; then
	if [ -d /etc/dnsmasq.bak ]; then
		filedir1=/etc/dnsmasq
		for file1 in ${filedir1}/*
		do
			filename1=`basename $file1`
			if ( ! cmp -s $filedir1/$filename1 /etc/dnsmasq.bak/$filename1 ); then
				cp -f $filedir1/$filename1 /etc/dnsmasq.bak/$filename1
			fi
		done
		else
		cp -r /etc/dnsmasq /etc/dnsmasq.bak
	fi	
	else
	mkdir -p /etc/dnsmasq
fi
if [ -d /etc/dnsmasq.d ]; then
	if [ -d /etc/dnsmasq.d.bak ]; then
		filedir2=/etc/dnsmasq.d
		for file2 in ${filedir2}/*
		do
			filename2=`basename $file2`
			if ( ! cmp -s $filedir2/$filename2 /etc/dnsmasq.d.bak/$filename2 ); then
				cp -f $filedir2/$filename2 /etc/dnsmasq.d.bak/$filename2
			fi
		done
		else
		cp -r /etc/dnsmasq.d /etc/dnsmasq.d.bak
	fi	
	else
	mkdir -p /etc/dnsmasq.d
fi
if [ -f /etc/dnsmasq.conf ]; then
	if [ ! -f /etc/dnsmasq.conf.bak ]; then
		cp -p /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
	fi	
	else
	echo "" > /etc/dnsmasq.conf
fi
if [ -f $CRON_FILE ]; then
	if [ ! -f $CRON_FILE.bak ]; then
		cp -p $CRON_FILE $CRON_FILE.bak
	fi	
	else
	echo "" > $CRON_FILE
fi
echo
sleep 3
grep "ad.conf" /etc/dnsmasq.conf >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e "\e[1;36m 配置dnsmasq\e[0m"
	echo
	echo -e -n "\e[1;36m 请输入lan网关ip(默认：192.168.1.1 ): \e[0m" 
	read lanip
	echo "$lanip" > /etc/dnsmasq/lanip
	echo "
# 添加监听地址（其中$lanip为你的lan网关ip）
listen-address=$lanip,127.0.0.1

# 并发查询所有上游DNS服务器
all-servers 

# 指定上游DNS服务器配置文件路径
resolv-file=/etc/dnsmasq/resolv.conf

# 添加额外hosts规则路径
addn-hosts=/etc/dnsmasq/noad.conf

# IP反查域名
bogus-priv

# 添加DNS解析文件
conf-file=/etc/dnsmasq.d/ad.conf

# 设定域名解析缓存池大小
cache-size=10000" >> /etc/dnsmasq.conf
	echo
fi
sleep 3
if [ ! -f /etc/dnsmasq/resolv.conf ]; then
	echo -e "\e[1;36m 创建上游DNS配置文件\e[0m"
	echo
	echo -e "\e[1;36m 开始创建上游DNS配置\e[0m"
	echo "# 上游DNS解析服务器
# 如需根据自己的网络环境优化DNS服务器，可用ping或DNSBench测速
# 选择最快的服务器依次按速度快慢顺序手动改写

# 本地规则查询服务器
nameserver 127.0.0.1

# 电信服务商当地DNS查询服务器" > /etc/dnsmasq/resolv
	cp /tmp/resolv.conf.auto /tmp/resolv
	sed -i '/#/d' /tmp/resolv
	cat /etc/dnsmasq/resolv /tmp/resolv >> /etc/dnsmasq/resolv.conf
	rm -rf /etc/dnsmasq/resolv /tmp/resolv
	echo "
# 主流公共DNS查询服务器
nameserver 114.114.114.114
nameserver 218.30.118.6
nameserver 114.114.114.119
nameserver 119.29.29.29
nameserver 8.8.4.4
nameserver 4.2.2.2
nameserver 1.2.4.8
nameserver 223.5.5.5" >> /etc/dnsmasq/resolv.conf
	echo
fi
sleep 3
if [ ! -f /etc/dnsmasq.d/userlist ]; then
	echo -e "\e[1;36m 创建自定义dnsmasq规则\e[0m"
	echo
	echo -e "\e[1;36m 开始创建创建自定义dnsmasq规则\e[0m"
	echo "# 格式示例如下，删除address前 # 有效，添加自定义规则
# 正确ip地址表示DNS解析扶墙，127地址表示去广告
#address=/.001union.com/127.0.0.1
#address=/telegram.org/149.154.167.99" > /etc/dnsmasq.d/userlist
	echo
fi
if [ ! -f /etc/dnsmasq/userblacklist ]; then
	echo -e "\e[1;36m 创建自定义广告黑名单\e[0m"
	echo
	if [ -f /etc/dnsmasq/blacklist ]; then
		mv /etc/dnsmasq/blacklist /etc/dnsmasq/userblacklist
		else
		echo -e "\e[1;36m 开始创建创建自定义广告黑名单\e[0m"
		echo "# 请在下面添加广告黑名单
# 每行输入要屏蔽广告网址不含http://符号
# 支持不完整域名地址，支持通配符" > /etc/dnsmasq/userblacklist
		echo
	fi	
fi
if [ ! -f /etc/dnsmasq/userwhitelist ]; then
	echo -e "\e[1;36m 创建自定义广告白名单\e[0m"
	echo
	if [ -f /etc/dnsmasq/whitelist ]; then
		mv /etc/dnsmasq/whitelist /etc/dnsmasq/userwhitelist
		else
		echo -e "\e[1;36m 开始创建创建自定义广告白名单\e[0m"
		echo "# 请将误杀的网址域名添加到在下面
# 每行输入相应的网址或关键词即可，建议尽量输入准确的网址" > /etc/dnsmasq/userwhitelist
		echo
	fi	
fi
echo -e "\e[1;36m 下载广告规则\e[0m"
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
wget --no-check-certificate -q -O /tmp/mallist http://www.malwaredomainlist.com/hostslist/hosts.txt
sed -i "s/.$//g" /tmp/mallist
echo
echo -e "\e[1;36m 下载adaway规则缓存\e[0m"
wget --no-check-certificate -q -O /tmp/adaway https://adaway.org/hosts.txt
wget --no-check-certificate -q -O /tmp/adaway2 http://winhelp2002.mvps.org/hosts.txt
sed -i "s/.$//g" /tmp/adaway2
wget --no-check-certificate -q -O /tmp/adaway3 http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt
wget --no-check-certificate -q -O /tmp/adaway4 https://hosts-file.net/ad_servers.txt
sed -i "s/.$//g" /tmp/adaway4
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
rm -rf /tmp/adblacklist
sed -i "/#/d" /tmp/blacklist
#sed -i 's/^/127.0.0.1 &/g' /tmp/blacklist #hosts方式，不支持通配符
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /tmp/blacklist #改为dnsmasq方式，支持通配符
echo
echo -e "\e[1;36m 合并dnsmasq、hosts缓存\e[0m"
cat /tmp/userlist /tmp/ad.conf /tmp/easylistchina.conf /tmp/blacklist > /tmp/ad
cat /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist > /tmp/noad
echo
echo -e "\e[1;36m 删除dnsmasq、hosts临时文件\e[0m"
rm -rf /tmp/userlist /tmp/ad.conf /tmp/easylistchina.conf /tmp/blacklist /tmp/yhosts.conf /tmp/adaway.conf /tmp/mallist
echo
echo -e "\e[1;36m 删除被误杀的广告规则\e[0m"
wget --no-check-certificate -q -O /tmp/adwhitelist https://raw.githubusercontent.com/clion007/dnsmasq/master/adwhitelist
sort /etc/dnsmasq/userwhitelist /tmp/adwhitelist | uniq > /tmp/whitelist
sed -i "/#/d" /tmp/whitelist
rm -rf /tmp/adwhitelist
while read -r line
do
	sed -i "/$line/d" /tmp/noad
	sed -i "/$line/d" /tmp/ad
done < /tmp/whitelist
rm -rf /tmp/whitelist
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/::1/d' /tmp/ad
sed -i '/localhost/d' /tmp/ad
sed -i '/#/d' /tmp/ad
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

# Modified DNS start" > /etc/dnsmasq.d/ad.conf
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

# 修饰hosts开始" > /etc/dnsmasq/noad.conf
echo
echo -e "\e[1;36m 删除dnsmasq'hosts重复规则及临时文件\e[0m"
sort /tmp/ad | uniq >> /etc/dnsmasq.d/ad.conf
sort /tmp/noad | uniq >> /etc/dnsmasq/noad.conf
rm -rf /tmp/ad /tmp/noad
echo "
# Modified DNS end" >> /etc/dnsmasq.d/ad.conf
echo "
# 修饰hosts结束" >> /etc/dnsmasq/noad.conf
echo
sleep 3
echo -e "\e[1;36m 重启dnsmasq服务\e[0m"
killall dnsmasq
	/etc/init.d/dnsmasq restart > /dev/null 2>&1
echo
sleep 2
echo -e "\e[1;36m 获取脚本更新脚本\e[0m"
wget --no-check-certificate -q -O /etc/dnsmasq/ad_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/ad_update.sh && chmod 755 /etc/dnsmasq/ad_update.sh
echo
echo -e "\e[1;36m 获取规则更新脚本\e[0m"
wget --no-check-certificate -q -O /etc/dnsmasq/adrules_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/adrules_update.sh && chmod 755 /etc/dnsmasq/adrules_update.sh
echo
sleep 1
grep "dnsmasq" $CRON_FILE >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e "\e[1;31m 添加自动更新计划任务\e[0m"
	echo
	echo -e -n "\e[1;36m 请输入更新时间(整点小时): \e[0m" 
	read timedata
	echo "$timedata" > /etc/crontabs/Update_time.conf
	echo "# 每天$timedata点25分更新广告规则
25 $timedata * * * sh /etc/dnsmasq/ad_update.sh > /dev/null 2>&1" >> $CRON_FILE
	/etc/init.d/cron reload
	echo
	echo -e "\e[1;36m 自动更新任务添加完成\e[0m"
	echo
fi
sleep 1
grep "reboot" $CRON_FILE >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e -n "\e[1;31m 是否设置路由器定时重启（y/n）:\e[0m"
	read rebootop
	if [ $rebootop=y ]; then
		echo
		echo -e -n "\e[1;36m 请输入每天定时重启时间(整点小时): \e[0m" 
		read reboottime
		echo "$reboottime" > /etc/crontabs/reboottime.conf
		echo "# 每天$reboottime点05分重启路由器
04 $reboottime * * * sleep 1m && touch /etc/banner && reboot" >> $CRON_FILE
		/etc/init.d/cron reload
		echo
		echo -e "\e[1;36m 定时重启任务设定完成\e[0m"
		echo
	fi	
fi
echo -e "\e[1;36m 创建脚本更新检测副本\e[0m"
wget --no-check-certificate -q -O /etc/dnsmasq/ad_auto.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/ad_auto.sh
chmod 755 /etc/dnsmasq/ad_auto.sh
echo
clear
sleep 1
echo
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                          +"
echo "+                 installation is complete                 +"
echo "+                                                          +"
echo "+                     Time:`date +'%Y-%m-%d'`                      +"
echo "+                                                          +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo
rm -f /tmp/ad.sh
echo -e -n "\e[1;31m 是否需要重启路由器？[y/n]：\e[0m" 
read boot
if [ "$boot" = "y" ];then
	reboot
	else
	exit 0
fi
echo
