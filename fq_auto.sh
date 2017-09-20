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
echo -e "# 安装前请\e[1;31m备份原配置\e[0m；由此产生的一切后果自行承担！"
echo -e "# 全自动无人值守安装！"
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                          +"
echo "+     Install Fq only for OpnWrt or LEDE or PandoraBox     +"
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
grep "fq.conf" /etc/dnsmasq.conf >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e "\e[1;36m 配置dnsmasq\e[0m"
	echo
	if [ -f /etc/dnsmasq/lanip ]; then
		lanip=$(cat /etc/dnsmasq/lanip)
		else
		lanip=$(ifconfig |grep Bcast|awk '{print $2}'|tr -d "addr:")
	fi
	echo -e "\e[1;36m 路由器网关:$lanip，开始配置dnsmasq\e[0m"
	echo "# 添加监听地址（其中$lanip为你的lan网关ip）
listen-address=$lanip,127.0.0.1

# 并发查询所有上游DNS服务器
all-servers 

# 指定上游DNS服务器配置文件路径
resolv-file=/etc/dnsmasq/resolv.conf

# IP反查域名
bogus-priv

# 添加DNS解析文件
conf-file=/etc/dnsmasq.d/fq.conf

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
echo -e "\e[1;36m 下载扶墙规则\e[0m"
echo
echo -e "\e[1;36m 下载sy618扶墙规则\e[0m"
wget --no-check-certificate -q -O /tmp/sy618 https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq
echo
#echo -e "\e[1;36m 下载racaljk规则\e[0m"
#wget --no-check-certificate -q -O /tmp/racaljk https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf
#echo
sleep 3
#echo -e "\e[1;36m 删除racaljk规则中的冲突规则\e[0m"
#sed -i '/google/d' /tmp/racaljk
#sed -i '/youtube/d' /tmp/racaljk
#echo
echo -e "\e[1;36m 创建用户自定规则缓存\e[0m"
cp /etc/dnsmasq.d/userlist /tmp/userlist
echo
echo -e "\e[1;36m 合并dnsmasq缓存\e[0m"
#cat /tmp/userlist /tmp/racaljk /tmp/sy618 > /tmp/fq
cat /tmp/userlist /tmp/sy618 > /tmp/fq
echo
echo -e "\e[1;36m 删除dnsmasq临时文件\e[0m"
rm -rf /tmp/userlist /tmp/sy618 #/tmp/racaljk
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/#/d' /tmp/fq
sed -i '/::1/d' /tmp/fq
sed -i '/localhost/d' /tmp/fq
echo
echo -e "\e[1;36m 创建dnsmasq规则文件\e[0m"
echo "
############################################################
## 【Copyright (c) 2014-2017, clion007】                          ##
##                                                                ##
## 感谢https://github.com/sy618/hosts                             ##
## 感谢https://github.com/racaljk/hosts                           ##
####################################################################

# Localhost (DO NOT REMOVE) Start
address=/localhost/127.0.0.1
address=/localhost/::1
address=/ip6-localhost/::1
address=/ip6-loopback/::1
# Localhost (DO NOT REMOVE) End

# Modified DNS start
" > /etc/dnsmasq.d/fq.conf
echo
echo -e "\e[1;36m 删除dnsmasq重复规则及相关临时文件\e[0m"
sort /tmp/fq | uniq >> /etc/dnsmasq.d/fq.conf
echo "# Modified DNS end" >> /etc/dnsmasq.d/fq.conf
rm -rf /tmp/fq
echo
sleep 3
echo -e "\e[1;36m 重启dnsmasq服务\e[0m"
killall dnsmasq
	/etc/init.d/dnsmasq restart > /dev/null 2>&1
echo
sleep 2
echo -e "\e[1;36m 获取脚本更新脚本\e[0m"
wget --no-check-certificate -q -O /etc/dnsmasq/fq_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/fq_update.sh && chmod 755 /etc/dnsmasq/fq_update.sh
echo
echo -e "\e[1;36m 获取规则更新脚本\e[0m"
wget --no-check-certificate -q -O /etc/dnsmasq/fqrules_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/fqrules_update.sh && chmod 755 /etc/dnsmasq/fqrules_update.sh
echo
sleep 1
grep "dnsmasq" $CRON_FILE >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e "\e[1;31m 添加自动更新计划任务\e[0m"
	if [ -f /etc/crontabs/Update_time.conf ]; then
		timedata=$(cat /etc/crontabs/Update_time.conf)
		else
		timedata='5'
	fi	
	echo "# 每天$timedata点25分更新翻墙规则
25 $timedata * * * sh /etc/dnsmasq/fq_update.sh > /dev/null 2>&1" >> $CRON_FILE
	/etc/init.d/cron reload
	echo
	echo -e "\e[1;36m 自动更新任务添加完成\e[0m"
	echo
fi
sleep 1
grep "reboot" $CRON_FILE >/dev/null
if [ ! $? -eq 0 ]; then
	if [ -f /etc/crontabs/reboottime.conf ]; then
		reboottime=$(cat /etc/crontabs/reboottime.conf)
		else
		reboottime='6'
	fi	
	echo -e "\e[1;36m 设置路由器定时重启\e[0m"
	echo "# 每天$reboottime点05分重启路由器
04 $reboottime * * * sleep 1m && touch /etc/banner && reboot" >> $CRON_FILE
	/etc/init.d/cron reload
	echo
	echo -e "\e[1;36m 定时重启任务设定完成\e[0m"
	echo
fi
echo -e "\e[1;36m 创建脚本更新检测副本\e[0m"
if [ -f /tmp/fq_auto.sh ]; then
	mv -f /tmp/fq_auto.sh /etc/dnsmasq/fq_auto.sh
fi
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
exit 0
