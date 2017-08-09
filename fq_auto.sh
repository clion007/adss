#!/bin/sh
echo
wgetroute="/usr/bin/wget-ssl"
CRON_FILE=/etc/crontabs/$USER
clear
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
	mv /etc/dnsmasq /etc/dnsmasq.bak
fi
if [ -d /etc/dnsmasq.d ]; then
	mv /etc/dnsmasq.d /etc/dnsmasq.d.bak
fi
mkdir -p /etc/dnsmasq
mkdir -p /etc/dnsmasq.d
echo
sleep 3
echo -e "\e[1;36m 配置dnsmasq\e[0m"
if [ -f /etc/dnsmasq.conf ]; then
	mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
fi
echo
lanip=$(ifconfig | awk -F'addr:|Bcast' '/Bcast/{print $2}')
echo -e "\e[1;36m 路由器网关:$lanip\e[0m"
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
cache-size=10000" > /etc/dnsmasq.conf # 换成echo的方式注入
echo
sleep 3
echo -e "\e[1;36m 创建上游DNS配置文件\e[0m"
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
nameserver 1.2.4.8
nameserver 223.5.5.5
nameserver 114.114.114.119" >> /etc/dnsmasq/resolv.conf # 换成echo的方式注入
echo
sleep 3
echo -e "\e[1;36m 创建自定义扶墙规则\e[0m"
echo "# 格式示例如下，删除address前 # 有效，添加自定义规则
# 正确ip地址表示DNS解析扶墙，127地址表示去广告
#address=/.001union.com/127.0.0.1
#address=/telegram.org/149.154.167.99" > /etc/dnsmasq.d/userlist
echo
echo -e "\e[1;36m 下载扶墙规则\e[0m"
echo
echo -e "\e[1;36m 下载sy618扶墙规则\e[0m"
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/sy618 https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq
echo
#echo -e "\e[1;36m 下载racaljk规则\e[0m"
#/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/racaljk https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf
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
rm -rf /tmp/userlist
rm -rf /tmp/sy618
#rm -rf /tmp/racaljk
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
#killall dnsmasq
	/etc/init.d/dnsmasq restart > /dev/null 2>&1
echo
sleep 2
echo -e "\e[1;36m 获取脚本更新脚本\e[0m"
wget --no-check-certificate -q -O /etc/dnsmasq/fq_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/fq_update.sh
echo
echo -e "\e[1;36m 获取规则更新脚本\e[0m"
wget --no-check-certificate -q -O /etc/dnsmasq/fqrules_update.sh https://raw.githubusercontent.com/clion007/dnsmasq/master/fqrules_update.sh
echo
sleep 1
echo -e "\e[1;31m 添加计划任务\e[0m"
chmod 755 /etc/dnsmasq/fq_update.sh
sed -i '/dnsmasq/d' $CRON_FILE
sed -i '/@/d' $CRON_FILE
Update_time=$(cat /etc/crontabs/Update_time.conf)
if [ -f /etc/crontabs/Update_time.conf ]; then
	timedata=$Update_time
	else
	timedata='5'
fi
echo "[$USER@$HOSTNAME:/$USER]#cat /etc/crontabs/$USER
# 每天$timedata点25分更新翻墙规则
28 $timedata * * * /bin/sh /etc/dnsmasq/fq_update.sh > /dev/null 2>&1" >> $CRON_FILE
/etc/init.d/cron reload
echo
echo -e "\e[1;36m 定时计划任务添加完成！\e[0m"
echo
echo -e "\e[1;36m 创建脚本更新检测副本\e[0m"
cp /tmp/fq_auto.sh /etc/dnsmasq/fq_auto.sh
echo
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
exit 0
