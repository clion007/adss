#!/bin/sh
echo
wgetroute="/usr/bin/wget-ssl"
CRON_FILE=/etc/crontabs/root
clear
echo "# Copyright (c) 2014-2017,by clion007"
echo "# 本脚本仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）"
echo "# 未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规，文明上网。"
echo "# openwrt类固件使用，包括但不限于pandorabox、LEDE、ddwrt等，Padavan系列固件慎用。"
echo -e "# 安装前请\e[1;31m备份原配置\e[0m；由此产生的一切后果自行承担！"
echo -e "# 安装前请\e[1;31m检查确认路由器配置，lan IP必须是192.168.1.1\e[0m；全自动无人值守安装！"
echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                          +"
echo "+     Install Fq only for OpnWrt or LEDE or PandoraBox     +"
echo "+                                                          +"
echo "+                      Time:`date +'%Y-%m-%d'`                     +"
echo "+                                                          +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo "------------------------------------------------------------------"
echo -e "\e[1;31m请先查询你的\e[1;36mlan网关ip\e[1;31m再选择,\e[1;36mlan网关ip\e[1;31m必须为：\e[1;36m'192.168.1.1'\e[0m"
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
	echo
	if [ -f $wgetroute ]; then
		echo -e "\e[1;36mwget安装成功         \e[0m[\e[1;31mmwget has been installde successfully\e[0m]"
		else
		echo -e "\e[1;31mwget安装失败,请到路由器系统软件包手动安装后再试!\e[0m"
		exit
	fi	
fi
echo
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
echo "# 添加监听地址（其中192.168.1.1为你的lan网关ip）
listen-address=192.168.1.1,127.0.0.1

# 并发查询所有上游DNS服务器
all-servers 

# 指定上游DNS服务器配置文件路径
resolv-file=/etc/dnsmasq/resolv.conf

# IP反查域名
bogus-priv

# 添加DNS解析文件
conf-file=/etc/dnsmasq.d/fq.conf

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
# 选择最快的服务器，打开文件依次按速度快慢顺序手动改写
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
echo -e "\e[1;36m下载扶墙规则\e[0m"
echo
echo -e "\e[1;36m下载sy618扶墙规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/sy618.conf https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq
echo
echo -e "\e[1;36m下载racaljk规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/racaljk.conf https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf
echo
sleep 3
#echo -e "\e[1;36m删除racaljk规则中google'youtube相关规则\e[0m"
#sed -i '/google/d' /tmp/racaljk.conf
#sed -i '/youtube/d' /tmp/racaljk.conf
echo
echo -e -n "\e[1;36m合并dnsmasq缓存\e[0m" 
cat /etc/dnsmasq.d/userlist /tmp/racaljk.conf /tmp/sy618.conf > /tmp/fq
#cat /etc/dnsmasq.d/userlist /tmp/sy618.conf > /tmp/fq
echo
echo -e -n "\e[1;36m删除dnsmasq临时文件\e[0m"
rm -rf /tmp/sy618.conf
rm -rf /tmp/racaljk.conf
echo
echo -e "\e[1;36m删除注释\e[0m"
sed -i '/#/d' /tmp/fq
sed -i '/::1/d' /tmp/fq
sed -i '/localhost/d' /tmp/fq
echo
echo -e "\e[1;36m创建dnsmasq规则文件\e[0m"
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
" > /etc/dnsmasq.d/fq.conf # 换成echo的方式注入
echo
echo -e "\e[1;36m删除dnsmasq重复规则及相关临时文件\e[0m"
sort /tmp/fq | uniq >> /etc/dnsmasq.d/fq.conf
rm -rf /tmp/fq
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
echo
# Copyright (c) 2014-2017,by clion007
# 本脚本仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）
# 未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规，文明上网。

#LOGFILE=/tmp/fq_update.log
#LOGSIZE=$(wc -c < $LOGFILE)
#if [ $LOGSIZE -ge 5000 ]; then
#	sed -i -e 1,10d $LOGFILE
#fi

# 更新dnsmasq规则
# 下载sy618扶墙规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/sy618.conf https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq
# 下载racaljk规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/racaljk.conf https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf
# 删除racaljk规则中google相关规则
#sed -i '/google/d' /tmp/racaljk.conf
#sed -i '/youtube/d' /tmp/racaljk.conf
# 合并dnsmasq缓存
cat /etc/dnsmasq.d/userlist /tmp/racaljk.conf /tmp/sy618.conf > /tmp/fq
#cat /etc/dnsmasq.d/userlist /tmp/sy618.conf > /tmp/fq
# 删除dnsmasq缓存
rm -rf /tmp/sy618.conf
rm -rf /tmp/racaljk.conf
# 删除注释
sed -i '/#/d' /tmp/fq
sed -i '/localhost/d' /tmp/fq
sed -i '/::1/d' /tmp/fq
# 创建dnsmasq规则文件
cat > /tmp/fq.conf <<EOF

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
EOF
# 删除dnsmasq重复规则
sort /tmp/fq | uniq >> /tmp/fq.conf
# 删除dnsmasq合并缓存
rm -rf /tmp/fq

if [ -s "/tmp/fq.conf" ]; then
	if ( ! cmp -s /tmp/fq.conf /etc/dnsmasq.d/fq.conf ); then
		mv /tmp/fq.conf /etc/dnsmasq.d/fq.conf
		echo "`date +'%Y-%m-%d %H:%M:%S'`:检测到fq规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart >/dev/null 2>&1
		echo "`date +'%Y-%m-%d %H:%M:%S'`: fq规则转换完成，应用新规则。"
		else
		echo "`date +'%Y-%m-%d %H:%M:%S'`: fq本地规则和在线规则相同，无需更新！" && rm -f /tmp/fq.conf
	fi	
fi
echo
echo -e "\e[1;36m规则更新完成\e[0m"
echo
exit 0" > /etc/dnsmasq/fq_update.sh
# 换成上面echo的方式注入
echo
sleep 1
echo
echo -e "\e[1;31m添加计划任务\e[0m"
chmod 755 /etc/dnsmasq/fq_update.sh
echo
sed -i '/dnsmasq/d' $CRON_FILE
echo
echo "[$USER@$HOSTNAME:/$USER]#cat /etc/crontabs/$USER
# 每天6点28分更新dnsmasq扶墙规则
28 6 * * * /bin/sh /etc/dnsmasq/fq_update.sh > /dev/null 2>&1" >> $CRON_FILE
/etc/init.d/cron reload
echo
echo -e "\e[1;36m定时计划任务添加完成！\e[0m"
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
rm -f /tmp/fq_auto.sh
fi
echo
if [ "$menu" == "2" ]; then
echo
echo -e "\e[1;31m开始卸载dnsmasq扶墙及广告规则\e[0m"
	rm -f /var/lock/opkg.lock
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
/etc/init.d/cron reload
sleep 1
echo
echo -e "\e[1;31m重启dnsmasq\e[0m"
	/etc/init.d/dnsmasq restart  >/dev/null 2>&1
	rm -f /tmp/fq_auto.sh
echo
fi
echo
if [ "$menu" == "3" ]; then
echo
rm -f /tmp/fq_auto.sh
echo
exit 0
fi
echo
