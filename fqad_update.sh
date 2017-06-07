#!/bin/sh
###仅限潘多拉与openwrt类固件使用###

###请将DNS设置为lan网关###

###-------------------------------------------script by Clion----------------------------------------###
# https://github.com/clion007/dnsmasq

# 移动到用户命令文件夹
cd /usr/bin/

# 开始更新dnsmasq规则
# # 下载sy618规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq > /etc/dnsmasq.d/sy168.conf
# 下载racaljk规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf > /etc/dnsmasq.d/racaljk.conf
# 下载vokins广告规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf > /etc/dnsmasq.d/ad.conf
# 下载easylistchina广告规则
wget --no-check-certificate -qO - https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt > /etc/dnsmasq.d/easylistchina.conf
# 合并dnsmasq缓存
cd /etc/dnsmasq.d;cat racaljk.conf sy168.conf ad.conf easylistchina.conf > fqad
# 删除dnsmasq缓存
rm -rf /etc/dnsmasq.d/ad.conf
rm -rf /etc/dnsmasq.d/sy168.conf
rm -rf /etc/dnsmasq.d/racaljk.conf
rm -rf /etc/dnsmasq.d/easylistchina.conf
# 删除dnsmasq重复规则
sort /etc/dnsmasq.d/fqad | uniq > /etc/dnsmasq.d/fqad.conf
# 删除dnsmasq合并缓存
rm -rf /etc/dnsmasq.d/fqad
# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq.d/fqad.conf
# dnsmasq规则更新结束

# 开始更新hosts规则
# 下载yhosts缓存
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt > /etc/dnsmasq/yhosts.conf
# 下载malwaredomainlist?嬖?
wget --no-check-certificate -qO - http://www.malwaredomainlist.com/hostslist/hosts.txt > /etc/dnsmasq/malwaredomainlist.conf
# 下载adaway规则缓存
wget --no-check-certificate -qO - http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt > /etc/dnsmasq/adaway.conf
# 合并hosts缓存
cd /etc/dnsmasq;cat yhosts.conf adaway.conf malwaredomainlist.conf > noad
# 删除hosts缓存
rm -rf /etc/dnsmasq/yhosts.conf
rm -rf /etc/dnsmasq/adaway.conf
rm -rf /etc/dnsmasq/malwaredomainlist.conf
# 删除hosts重复规则
sort /etc/dnsmasq/noad | uniq > /etc/dnsmasq/noad.conf
# 删除hosts合并缓存
rm -rf /etc/dnsmasq/noad
# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq/noad.conf
# hosts规则更新结束

# 重启dnsmasq服务
killall dnsmasq
/usr/sbin/dnsmasq
