#!/bin/sh
echo
wgetroute="/usr/bin/wget-ssl"
CRON_FILE=/etc/crontabs/$USER
clear
echo "# Copyright (c) 2014-2017,by clion007"
echo "# 本脚本仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）"
echo "# 未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规，文明上网。"
echo "# openwrt类固件使用，包括但不限于pandorabox、LEDE、ddwrt等，Padavan系列固件慎用。"
echo -e "# 安装前请\e[1;31m备份原配置\e[0m；安装过程中需要输入路由器相关配置信息，由此产生的一切后果自行承担！"
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                          +"
echo "+     Install Fq+Noad for OpnWrt or LEDE or PandoraBox     +"
echo "+                                                          +"
echo "+                      Time:`date +'%Y-%m-%d'`                     +"
echo "+                                                          +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo "------------------------------------------------------------------"
echo -e "\e[1;31m 请先查询你的\e[1;36mlan网关ip\e[1;31m再选择,其中必须输入\e[1;36mlan网关ip\e[1;31m,默认：\e[1;36m'192.168.1.1'\e[0m"
echo "------------------------------------------------------------------"
echo
echo -e "\e[1;36m >         1. 安装 \e[0m"
echo
echo -e "\e[1;31m >         2. 卸载 \e[0m"
echo
echo -e "\e[1;36m >         3. 退出 \e[0m"
echo
echo -e -n "\e[1;34m 请输入数字继续执行: \e[0m" 
read menu
if [ "$menu" == "1" ]; then
echo
echo -e "\e[1;36m 三秒后开始安装......\e[0m"
echo
sleep 3
echo -e "\e[1;36m 正在更新软件包，根据网络状态决定时长\e[0m"
rm -f /var/lock/opkg.lock
opkg update
sleep 2
echo
echo -e "\e[1;36m 开始检查并安装wget-支持https\e[0m"
echo
if [ -f $wgetroute ]; then
	echo -e "\e[1;31m 系统已经安装wget-ssl软件\e[0m"
	#opkg remove wget > /dev/null 2>&1
	#opkg install wget	
	else
	echo -e "\e[1;31m 没有发现wget-ssl开始安装\e[0m"
	opkg install wget
	echo
	if [ -f $wgetroute ]; then
		echo -e "\e[1;36m wget安装成功         \e[0m[\e[1;31mmwget has been installde successfully\e[0m]"
		else
		echo -e "\e[1;31m wget安装失败,请到路由器系统软件包手动安装后再试!\e[0m"
		exit
	fi	
fi
echo
sleep 3
echo -e "\e[1;36m 创建dnsmasq规则与更新脚本存放的文件夹\e[0m"
echo
echo -e "\e[1;36m 检测和备份当前dnsmasq配置信息\e[0m"
if [ -d /etc/dnsmasq ]; then
	mv /etc/dnsmasq /etc/dnsmasq.bak
fi
if [ -d /etc/dnsmasq.d ]; then
	mv /etc/dnsmasq.d /etc/dnsmasq.d.bak
fi
mkdir -p /etc/dnsmasq
mkdir -p /etc/dnsmasq.d
echo
sleep 3
echo -e "\e[1;36m dnsmasq.conf 添加广告规则路径\e[0m"
if [ -f /etc/dnsmasq.conf ]; then
	mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
fi
echo -e -n "\e[1;36m 请输入lan网关ip(默认：192.168.1.1 ): \e[0m" 
read lanip
echo "# 添加监听地址（其中$lanip为你的lan网关ip）
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
conf-file=/etc/dnsmasq.d/fqad.conf

# 设定域名解析缓存池大小
cache-size=10000" > /etc/dnsmasq.conf # 换成echo的方式注入
echo
sleep 3
echo -e "\e[1;36m 创建上游DNS配置文件\e[0m"
cp /tmp/resolv.conf.auto /etc/dnsmasq/resolv.conf
echo "# 上游DNS解析服务器
nameserver 127.0.0.1
# 如需根据自己的网络环境优化DNS服务器，可用ping或DNSBench测速
# 选择最快的服务器，打开resolv文件依次按速度快慢顺序手动改写
nameserver 218.30.118.6
nameserver 8.8.4.4
nameserver 119.29.29.29
nameserver 4.2.2.2
nameserver 114.114.114.114
#nameserver 1.2.4.8
#nameserver 223.5.5.5
#nameserver 114.114.114.119" >> /etc/dnsmasq/resolv.conf # 换成echo的方式注入
echo
sleep 3
echo -e -n "\e[1;36m 创建自定义扶墙规则\e[0m"
echo
echo "# 规则格式,删除address前 # 生效，如有需要自己添加的规则，请在下面添加
# 后面的地址有两种情况,优选具体ip地址
#address=/.001union.com/127.0.0.1
#address=/telegram.org/149.154.167.99" > /etc/dnsmasq.d/userlist
echo
echo -e "\e[1;36m 下载扶墙和广告规则\e[0m"
echo
echo -e "\e[1;36m 下载sy618扶墙规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/sy618 https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq
echo
echo -e "\e[1;36m 下载racaljk规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/racaljk https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf
echo
echo -e "\e[1;36m 下载vokins广告规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/ad.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf
echo
echo -e "\e[1;36m 下载easylistchina广告规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/easylistchina.conf https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt
echo
echo -e "\e[1;36m 下载yhosts缓存\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/yhosts.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt
echo
echo -e "\e[1;36m 下载malwaredomainlist规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/malwaredomainlist.conf http://www.malwaredomainlist.com/hostslist/hosts.txt
echo
echo -e "\e[1;36m 下载adaway规则缓存\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/adaway.conf http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt
echo
sleep 3
#echo -e "\e[1;36m 删除racaljk规则中google'youtube相关规则\e[0m"
#sed -i '/google/d' /tmp/racaljk
#sed -i '/youtube/d' /tmp/racaljk
#echo
echo -e "\e[1;36m 创建用户自定规则缓存\e[0m"
cp /etc/dnsmasq.d/userlist /tmp/userlist
echo
echo -e -n "\e[1;36m 删除dnsmasq缓存注释\e[0m"
sed -i '/#/d' /tmp/sy618
sed -i '/#/d' /tmp/racaljk
sed -i '/#/d' /tmp/ad.conf
sed -i '/#/d' /tmp/easylistchina.conf
sed -i '/#/d' /tmp/userlist
echo
echo -e -n "\e[1;36m 扶墙网站指定到#443端口访问\e[0m"
awk '{print $0"#443"}' /tmp/sy618 > /tmp/sy618.conf
awk '{print $0"#443"}' /tmp/racaljk > /tmp/racaljk.conf
awk '{print $0"#443"}' /tmp/userlist > /tmp/userlist.conf
echo
echo -e -n "\e[1;36m 合并dnsmasq'hosts缓存\e[0m"
cat /tmp/userlist.conf /tmp/racaljk.conf /tmp/sy618.conf /tmp/ad.conf /tmp/easylistchina.conf > /tmp/fqad
#cat /tmp/userlist.conf /tmp/sy618.conf /tmp/ad.conf /tmp/easylistchina.conf > /tmp/fqad
cat /tmp/yhosts.conf /tmp/adaway.conf /tmp/malwaredomainlist.conf > /tmp/noad
echo
echo -e -n "\e[1;36m 删除dnsmasq'hosts临时文件\e[0m"
rm -rf /tmp/userlist
rm -rf /tmp/userlist.conf
rm -rf /tmp/ad.conf
rm -rf /tmp/sy618.conf
rm -rf /tmp/sy618
rm -rf /tmp/easylistchina.conf
rm -rf /tmp/racaljk.conf
rm -rf /tmp/racaljk
rm -rf /tmp/yhosts.conf
rm -rf /tmp/adaway.conf
rm -rf /tmp/malwaredomainlist.conf
echo
echo -e "\e[1;36m 删除所有360和头条的规则\e[0m"
sed -i '/360/d' /tmp/fqad
sed -i '/toutiao/d' /tmp/fqad
sed -i '/360/d' /tmp/noad
sed -i '/toutiao/d' /tmp/noad
echo
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/::1/d' /tmp/fqad
sed -i '/localhost/d' /tmp/fqad
sed -i '/#/d' /tmp/noad
sed -i '/@/d' /tmp/noad
sed -i '/::1/d' /tmp/noad
sed -i '/localhost/d' /tmp/noad
echo
echo -e "\e[1;36m 创建dnsmasq规则文件\e[0m"
echo "
############################################################
##【Copyright (c) 2014-2017, clion007】                           ##
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

#Modified hosts start
" > /etc/dnsmasq.d/fqad.conf # 换成echo的方式注入
echo
echo -e "\e[1;36m 创建hosts规则文件\e[0m"
echo "
############################################################
##【Copyright (c) 2014-2017, clion007】                           ##
##                                                                ##
## 感谢https://github.com/sy618/hosts                             ##
## 感谢https://github.com/vokins/hosts                            ##
## 感谢https://github.com/racaljk/hosts                           ##
####################################################################

#默认hosts开始（想恢复最初状态的hosts，只保留下面两行即可）
127.0.0.1 localhost
::1	localhost
::1	ip6-localhost
::1	ip6-loopback
#默认hosts结束

#修饰hosts开始
" > /etc/dnsmasq/noad.conf # 换成echo的方式注入
echo
echo -e "\e[1;36m 删除dnsmasq'hosts重复规则及相关临时文件\e[0m"
sort /tmp/fqad | uniq >> /etc/dnsmasq.d/fqad.conf
sort /tmp/noad | uniq >> /etc/dnsmasq/noad.conf
rm -rf /tmp/fqad
rm -rf /tmp/noad
echo
sleep 3
echo -e "\e[1;36m 重启dnsmasq服务\e[0m"
#killall dnsmasq
	/etc/init.d/dnsmasq restart >/dev/null 2>&1
echo
sleep 2
echo -e "\e[1;36m 获取规则更新脚本\e[0m"
wget --no-check-certificate -q -O /etc/dnsmasq/fqad_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/fqad_update.sh
echo
sleep 1
echo -e "\e[1;31m 添加计划任务\e[0m"
chmod 755 /etc/dnsmasq/fqad_update.sh
sed -i '/dnsmasq/d' $CRON_FILE
sed -i '/@/d' $CRON_FILE
echo
echo -e -n "\e[1;36m 请输入更新时间(整点小时): \e[0m" 
read timedata
echo
echo "[$USER@$HOSTNAME:/$USER]#cat /etc/crontabs/$USER
# 每天$timedata点28分更新dnsmasq和hosts规则
28 $timedata * * * /bin/sh /etc/dnsmasq/fqad_update.sh > /dev/null 2>&1
#/tmp/fqad_update.log 2>&1" >> $CRON_FILE
/etc/init.d/cron reload
echo -e "\e[1;36m 定时计划任务添加完成！\e[0m"
sleep 1
echo
echo
clear 
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                          +"
echo "+                 installation is complete                 +"
echo "+                                                          +"
echo "+                     Time:`date +'%Y-%m-%d'`                      +"
echo "+                                                          +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo 
rm -f /tmp/fqad.sh
echo
echo -e -n "\e[1;31m 是否需要重启路由器？[y/n]：\e[0m" 
read boot
	if [ "$boot" = "y" ];then
		echo
		reboot
	fi
fi
echo
if [ "$menu" == "2" ]; then
echo
echo -e "\e[1;31m 开始卸载dnsmasq扶墙及广告规则\e[0m"
	rm -f /var/lock/opkg.lock
	#opkg remove wget > /dev/null 2>&1
sleep 1
echo
echo -e "\e[1;31m 删除残留文件夹以及配置\e[0m"
	rm -rf /etc/dnsmasq
	rm -rf /etc/dnsmasq.d
if [ -d /etc/dnsmasq.bak ]; then
	mv /etc/dnsmasq.bak /etc/dnsmasq
fi
echo
if [ -d /etc/dnsmasq.d.bak ]; then
	mv /etc/dnsmasq.d.bak /etc/dnsmasq.d
fi
echo
if [ -f /etc/dnsmasq.conf.bak ]; then
	rm -rf /etc/dnsmasq.conf
	mv /etc/dnsmasq.conf.bak /etc/dnsmasq.conf
fi
echo
sleep 1
echo -e "\e[1;31m 删除相关计划任务\e[0m"
sed -i '/dnsmasq/d' $CRON_FILE
# echo '' > $CRON_FILE
/etc/init.d/cron reload
sleep 1
echo
echo -e "\e[1;31m 重启dnsmasq\e[0m"
	/etc/init.d/dnsmasq restart  >/dev/null 2>&1
	rm -f /tmp/fqad.sh
echo
echo -e -n "\e[1;31m 是否需要重启路由器？[y/n]：\e[0m" 
read boot
	if [ "$boot" = "y" ];then
		echo
		reboot
	fi
fi
echo
if [ "$menu" == "3" ]; then
echo
rm -f /tmp/fqad.sh
echo
exit 0
fi
echo
