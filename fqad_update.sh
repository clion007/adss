#!/bin/sh
# Copyright (c) 2014-2017,by clion007
# 本脚本仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）
# 未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规，文明上网。

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
exit 0
