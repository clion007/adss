#!/bin/sh
echo
wgetroute="/usr/bin/wget-ssl"
CRON_FILE=/etc/crontabs/root
clear
echo "# Copyright (c) 2014-2017,by clion007&zshwq5"
echo "# 本脚本仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）"
echo "# 未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规，文明上网。"
echo "# openwrt类固件使用，包括但不限于pandorabox、LEDE、ddwrt等，Padavan系列固件慎用。"
echo -e "# 安装前请\e[1;31m备份原配置\e[0m；安装过程中需要输入路由器相关配置信息，由此产生的一切后果自行承担！"
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                        +"
echo "+   Install Fq+Noad for OpnWrt or LEDE or PandoraBox     +"
echo "+                                                        +"
echo "+                    Time 2017.06.10                     +"
echo "+                                                        +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo "------------------------------------------------------------------"
echo -e "\e[1;31m请先查询你的\e[1;36mlan网关ip\e[1;31m再选择,其中必须输入\e[1;36mlan网关ip\e[1;31m,默认：\e[1;36m'192.168.1.1'\e[0m"
echo "------------------------------------------------------------------"
echo
echo -e "\e[1;36m >         1. 安装 \e[0m"
echo
echo -e "\e[1;31m >         2. 卸载 \e[0m"
echo
echo -e "\e[1;36m >         3. 退出 \e[0m"
echo
echo -e -n "\e[1;34m请输入数字继续执行: \e[0m" 
read menu
if [ "$menu" == "1" ]; then
echo
echo -e "\e[1;36m三秒后开始安装......\e[0m"
echo
sleep 3
echo -e "\e[1;36m正在更新软件包，根据网络状态决定时长\e[0m"
rm -f /var/lock/opkg.lock
opkg update
sleep 2
echo
echo -e "\e[1;36m开始检查并安装wget-支持https\e[0m"
if [ -f $wgetroute ]; then
	echo -e "\e[1;31m系统已经安装wget-ssl软件\e[0m"
	#opkg remove wget > /dev/null 2>&1
	#opkg install wget	
	else
	echo -e "\e[1;31m没有发现wget-ssl开始安装\e[0m"
	opkg install wget
fi
echo
if [ -f $wgetroute ]; then
	echo -e "\e[1;36mwget安装成功         \e[0m[\e[1;31mwget has been installde successfully\e[0m]"
	else
	echo -e "\e[1;31mwget安装失败,请手动安装后再试!\e[0m"
	exit
fi
sleep 3
echo
echo -e "\e[1;36m创建广告规则与更新脚本存放的文件夹\e[0m"
if [ -f /etc/dnsmasq ]; then
	mv /etc/dnsmasq /etc/dnsmasq.bak
fi
echo
if [ -f /etc/dnsmasq.d ]; then
	mv /etc/dnsmasq.d /etc/dnsmasq.d.bak
fi
echo
mkdir -p /etc/dnsmasq
mkdir -p /etc/dnsmasq.d
sleep 3
echo
echo -e "\e[1;36mdnsmasq.conf 添加广告规则路径\e[0m"
if [ -f /etc/dnsmasq.conf ]; then
	mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
fi
echo
echo -e -n "\e[1;36m请输入lan网关ip(默认：192.168.1.1 ): \e[0m" 
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
cache-size=5000" > /etc/dnsmasq.conf # 换成echo的方式注入
echo
sleep 3
echo
echo -e "\e[1;36m创建上游DNS配置文件\e[0m"
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
echo
echo -e -n "\e[1;36m创建自定义扶墙规则\e[0m"
echo "# 规则格式,删除address前 # 生效，如有需要自己添加的规则，请打开userlist添加
# 后面的地址有两种情况,优选具体ip地址
#address=/.001union.com/127.0.0.1
#address=/telegram.org/149.154.167.99" > /etc/dnsmasq.d/userlist
echo
echo -e "\e[1;36m下载扶墙和广告规则\e[0m"
echo
echo -e "\e[1;36m下载sy618扶墙规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/sy618.conf https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq
echo
echo -e "\e[1;36m下载racaljk规则\e[0m"
wget --no-check-certificate -q -O /tmp/racaljk.conf https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf
echo
echo -e "\e[1;36m下载vokins广告规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/ad.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf
echo
echo -e "\e[1;36m下载easylistchina广告规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/easylistchina.conf https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt
echo
echo -e "\e[1;36m下载yhosts缓存\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/yhosts.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt
echo
echo -e "\e[1;36m下载malwaredomainlist规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/malwaredomainlist.conf http://www.malwaredomainlist.com/hostslist/hosts.txt
echo
echo -e "\e[1;36m下载adaway规则缓存\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/adaway.conf http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt
sleep 3
#echo -e "\e[1;36m删除racaljk规则中google'youtube相关规则\e[0m"
#sed -i '/google/d' /tmp/racaljk.conf
#sed -i '/youtube/d' /tmp/racaljk.conf
echo
echo -e -n "\e[1;36m合并dnsmasq'hosts缓存\e[0m" 
cat /etc/dnsmasq.d/userlist /tmp/racaljk.conf /tmp/sy168.conf /tmp/ad.conf /tmp/easylistchina.conf > /tmp/fqad
#cat /etc/dnsmasq.d/userlist /tmp/sy618.conf /tmp/ad.conf /tmp/easylistchina.conf > /tmp/fqad
cat /tmp/yhosts.conf /tmp/adaway.conf /tmp/malwaredomainlist.conf > /tmp/noad
echo
echo -e -n "\e[1;36m删除dnsmasq'hosts临时文件\e[0m"
rm -rf /tmp/ad.conf
rm -rf /tmp/sy618.conf
rm -rf /tmp/easylistchina.conf
rm -rf /tmp/racaljk.conf
rm -rf /tmp/yhosts.conf
rm -rf /tmp/adaway.conf
rm -rf /tmp/malwaredomainlist.conf
echo
echo -e "\e[1;36m删除所有360和头条的规则\e[0m"
sed -i '/360/d' /tmp/fqad
sed -i '/toutiao/d' /tmp/fqad
sed -i '/360/d' /tmp/noad
sed -i '/toutiao/d' /tmp/noad
echo
echo -e "\e[1;36m删除注释\e[0m"
sed -i '/#/d' /tmp/fqad
sed -i '/::1/d' /tmp/fqad
sed -i '/localhost/d' /tmp/fqad
sed -i '/#/d' /tmp/noad
sed -i '/@/d' /tmp/noad
sed -i '/::1/d' /tmp/noad
sed -i '/localhost/d' /tmp/noad
echo
echo -e "\e[1;36m创建dnsmasq规则文件\e[0m"
echo "####################################################################
##【Copyright (c) 2014-2017, clion007】                           ##
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
echo -e "\e[1;36m创建hosts规则文件\e[0m"
echo "####################################################################
##【Copyright (c) 2014-2017, clion007】                           ##
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
echo -e "\e[1;36m删除dnsmasq'hosts重复规则及相关临时文件\e[0m"
sort /tmp/fqad | uniq >> /etc/dnsmasq.d/fqad.conf
sort /tmp/noad | uniq >> /etc/dnsmasq/noad.conf
rm -rf /tmp/fqad
rm -rf /tmp/noad
echo
sleep 3
echo
echo -e "\e[1;36m重启dnsmasq服务\e[0m"
#killall dnsmasq
	/etc/init.d/dnsmasq restart >/dev/null 2>&1
sleep 2
echo
echo -e "\e[1;36m创建规则更新脚本\e[0m"
echo "#!/bin/sh

#LOGFILE=/tmp/fqad_update.log
#LOGSIZE=$(wc -c < $LOGFILE)
#if [ $LOGSIZE -ge 5000 ]; then
#	sed -i -e 1,10d $LOGFILE
#fi
# 更新dnsmasq规则
# 下载sy618扶墙规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/sy618.conf https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq
# 下载racaljk规则
wget --no-check-certificate -q -O /tmp/racaljk.conf https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf
# 下载vokins广告规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/ad.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf
# 下载easylistchina广告规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/easylistchina.conf https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt
# 删除racaljk规则中google相关规则
#sed -i '/google/d' /tmp/racaljk.conf
#sed -i '/youtube/d' /tmp/racaljk.conf
# 合并dnsmasq缓存
cat /etc/dnsmasq.d/userlist /tmp/racaljk.conf /tmp/sy168.conf /tmp/ad.conf /tmp/easylistchina.conf > /tmp/fqad
#cat /etc/dnsmasq.d/userlist /tmp/sy618.conf /tmp/ad.conf /tmp/easylistchina.conf > /tmp/fqad
# 删除dnsmasq缓存
rm -rf /tmp/ad.conf
rm -rf /tmp/sy618.conf
rm -rf /tmp/easylistchina.conf
rm -rf /tmp/racaljk.conf
# 删除所有360和头条的规则
sed -i '/360/d' /tmp/fqad
sed -i '/toutiao/d' /tmp/fqad
# 删除注释
sed -i '/#/d' /tmp/fqad
sed -i '/localhost/d' /tmp/fqad
sed -i '/::1/d' /tmp/fqad
# 创建dnsmasq规则文件
cat > /etc/tmp/fqad.conf <<EOF
####################################################################
##【Copyright (c) 2014-2017, clion007】                           ##
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
EOF
# 删除dnsmasq重复规则
sort /tmp/fqad | uniq >> /tmp/fqad.conf
# 删除dnsmasq合并缓存
rm -rf /tmp/fqad

# 更新hosts规则
# 下载yhosts缓存
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/yhosts.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt
# 下载malwaredomainlist规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/malwaredomainlist.conf http://www.malwaredomainlist.com/hostslist/hosts.txt
# 下载adaway规则缓存
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/adaway.conf http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt
# 合并hosts缓存
cat /tmp/yhosts.conf /tmp/adaway.conf /tmp/malwaredomainlist.conf > /tmp/noad
# 删除hosts缓存
rm -rf /tmp/yhosts.conf
rm -rf /tmp/adaway.conf
rm -rf /tmp/malwaredomainlist.conf
# 删除所有360和头条的规则
sed -i '/360/d' /tmp/noad
sed -i '/toutiao/d' /tmp/noad
# 删除注释
sed -i '/#/d' /tmp/noad
sed -i '/@/d' /tmp/noad
sed -i '/::1/d' /tmp/noad
sed -i '/localhost/d' /tmp/noad
cat > /etc/tmp/noad.conf <<EOF
####################################################################
##【Copyright (c) 2014-2017, clion007】                           ##
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
EOF
# 删除hosts重复规则
sort /tmp/noad | uniq >> /tmp/noad.conf
# 删除hosts合并缓存
rm -rf /tmp/noad

if [ -s "/tmp/fqad.conf" ];then
	if ( ! cmp -s /tmp/fqad.conf /etc/dnsmasq.d/fqad.conf );then
		mv /tmp/fqad.conf /etc/dnsmasq.d/fqad.conf
		echo "$(date "+%F %T"):检测到fqad规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart >/dev/null 2>&1
		echo "$(date "+%F %T"): fqad规则转换完成，应用新规则。"
		else
		echo "$(date "+%F %T"): fqad本地规则和在线规则相同，无需更新!" && rm -f /tmp/fqad.conf
	fi	
fi
if [ -s "/tmp/noad.conf" ];then
	if ( ! cmp -s /tmp/noad.conf /etc/dnsmasq/noad.conf );then
		mv /tmp/noad.conf /etc/dnsmasq/noad.conf
		echo "$(date "+%F %T"): 检测到noad规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart >/dev/null 2>&1
		echo "$(date "+%F %T"): noad规则转换完成，应用新规则。"
		else
		echo "$(date "+%F %T"): noad本地规则和在线规则相同，无需更新!" && rm -f /tmp/noad.conf
	fi	
fi
# 规则更新结束
exit 0" > /etc/dnsmasq/fqad_update.sh
# 换成上面echo的方式注入
echo
sleep 1
echo
echo -e "\e[1;31m添加计划任务\e[0m"
chmod 755 /etc/dnsmasq/fqad_update.sh
echo
sed -i '/dnsmasq/d' $CRON_FILE
sed -i '/@/d' $CRON_FILE
echo
echo -e -n "\e[1;36m请输入更新时间(整点小时): \e[0m" 
read timedata
echo
echo -e -n "\e[1;36m请输入路由器主机名称: \e[0m" 
read hostname
echo "[root@$hostname:/root]#cat /etc/crontabs/root
# 每天$timedata点28分更新dnsmasq和hosts规则
28 $timedata * * * /bin/sh /etc/dnsmasq/fqad_update.sh > /dev/null 2>&1
#/tmp/fqad_update.log 2>&1" >> $CRON_FILE
# echo '' > $CRON_FILE
/etc/init.d/cron reload
echo
echo -e "\e[1;36m定时计划任务添加完成！\e[0m"
sleep 1
echo
echo
clear 
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                        +"
echo "+                 installation is complete               +"
echo "+                                                        +"
echo "+                     Time 2017.06.08                    +"
echo "+                                                        +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo 
rm -f /tmp/dnsmasq_fqad.sh
echo
echo -e -n "\e[1;31m是否需要重启路由器？[y/n]：\e[0m" 
read boot
	if [ "$boot" = "y" ];then
		echo
		reboot
	fi
fi
echo
if [ "$menu" == "2" ]; then
echo
echo -e "\e[1;31m开始卸载dnsmasq扶墙及广告规则\e[0m"
	rm -f /var/lock/opkg.lock
	#opkg remove wget > /dev/null 2>&1
sleep 1
echo
echo -e "\e[1;31m删除残留文件夹以及配置\e[0m"
	rm -rf /etc/dnsmasq
	rm -rf /etc/dnsmasq.d
if [ -f /etc/dnsmasq.bak ]; then
	mv /etc/dnsmasq.bak /etc/dnsmasq
fi
echo
if [ -f /etc/dnsmasq.d.bak ]; then
	mv /etc/dnsmasq.d.bak /etc/dnsmasq.d
fi
echo
if [ -f /etc/dnsmasq.conf.bak ]; then
	rm -rf /etc/dnsmasq.conf
	mv /etc/dnsmasq.conf.bak /etc/dnsmasq.conf
fi
echo
sleep 1
echo
echo -e "\e[1;31m删除相关计划任务\e[0m"
sed -i '/dnsmasq/d' $CRON_FILE
# echo '' > $CRON_FILE
/etc/init.d/cron reload
sleep 1
echo
echo -e "\e[1;31m重启dnsmasq\e[0m"
	/etc/init.d/dnsmasq restart  >/dev/null 2>&1
	rm -f /tmp/dnsmasq_fqad.sh
echo
echo -e -n "\e[1;31m是否需要重启路由器？[y/n]：\e[0m" 
read boot
	if [ "$boot" = "y" ];then
		echo
		reboot
	fi
fi
echo
if [ "$menu" == "3" ]; then
echo
rm -f /tmp/dnsmasq_fqad.sh
echo
exit 0
fi
echo
