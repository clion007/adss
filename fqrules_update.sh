#!/bin/sh
echo
sleep 3
echo " 开始更新dnsmasq规则"
# 下载sy618扶墙规则
wget --no-check-certificate -q -O /tmp/sy618 https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq

# 下载googlehosts规则
#wget --no-check-certificate -q -O /tmp/googlehosts https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/dnsmasq.conf

# 删除googlehosts规则中的冲突规则
#sed -i '/google/d' /tmp/googlehosts
#sed -i '/youtube/d' /tmp/googlehosts

# 创建用户自定规则缓存
cp /etc/dnsmasq.d/userlist /tmp/userlist

# 合并dnsmasq缓存
#cat /tmp/userlist /tmp/googlehosts /tmp/sy618 > /tmp/fq
cat /tmp/userlist /tmp/sy618 > /tmp/fq

# 删除dnsmasq临时文件
rm -rf /tmp/userlist
rm -rf /tmp/sy618
#rm -rf /tmp/googlehosts

# 删除注释与本地规则
sed -i '/::1/d' /tmp/fq
sed -i '/localhost/d' /tmp/fq
sed -i '/# /d' /tmp/fq
sed -i '/#★/d' /tmp/fq
sed -i '/#@/d' /tmp/fq
sed -i '/##/d' /tmp/fq
sed -i '/#address/d' /tmp/fq
sed -i '/#server/d' /tmp/fq
sed -i '/#youtube/d' /tmp/fq

# 创建dnsmasq规则文件
echo "
############################################################
## 【Copyright (c) 2014-2017, clion007】                          ##
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

# Modified hosts start" > /tmp/fq.conf

# 删除dnsmasq重复规则
sort /tmp/fq | uniq >> /tmp/fq.conf
echo "
# Modified DNS end" >> /tmp/fq.conf

# 删除dnsmasq合并缓存
rm -rf /tmp/fq
echo
if [ -s "/tmp/fq.conf" ]; then
	if ( ! cmp -s /tmp/fq.conf /etc/dnsmasq.d/fq.conf ); then
		mv -f /tmp/fq.conf /etc/dnsmasq.d/fq.conf
		echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到fq规则有更新......开始转换规则！"
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
		echo " `date +'%Y-%m-%d %H:%M:%S'`: fq规则转换完成，应用新规则。"
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: fq本地规则和在线规则相同，无需更新！" && rm -f /tmp/fq.conf
	fi	
fi
echo
echo -e "\e[1;36m 规则更新完成\e[0m"
exit 0
