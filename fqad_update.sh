#!/bin/sh
echo
echo " Copyright (c) 2014-2017,by clion007"
echo
echo " 本脚本仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）"
echo " 未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规，文明上网。"
echo
#LOGFILE=/tmp/fqad_update.log
#LOGSIZE=$(wc -c < $LOGFILE)
#if [ $LOGSIZE -ge 5000 ]; then
#	sed -i -e 1,10d $LOGFILE
#fi
echo -e "\e[1;36m 1秒钟后开始检测更新脚本及规则\e[0m"
echo
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/fqad_auto.sh -O \
      /tmp/fqad_auto.sh && chmod 775 /tmp/fqad_auto.sh
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/fqad_update.sh -O \
      /tmp/fqad_update.sh && chmod 775 /tmp/fqad_update.sh
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/fqadrules_update.sh -O \
      /tmp/fqadrules_update.sh && chmod 775 /tmp/fqadrules_update.sh
if [ -s "/tmp/fqad_auto.sh" ]; then
	if ( ! cmp -s /tmp/fqad_auto.sh /etc/dnsmasq/fqad_auto.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版翻墙去广告脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新翻墙去广告脚本\e[0m"
		echo
		clear
		sh /tmp/fqad_auto.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 翻墙去广告脚本及规则更新完成。"
	elif ( ! cmp -s /tmp/fqad_update.sh /etc/dnsmasq/fqad_update.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版升级脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新升级脚本\e[0m"
		echo
		clear
		sh /tmp/fqad_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 升级脚本更新完成。"
		rm -rf /tmp/fqad_update.sh
	elif ( ! cmp -s /tmp/fqadrules_update.sh /etc/dnsmasq/fqadrules_update.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新规则升级脚本\e[0m"
		echo
		clear
		sh /tmp/fqadrules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。"
		rm -rf /tmp/fqadrules_update.sh
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 脚本已为最新，3秒后即将开始检测翻墙去广告规则更新"
		rm -rf /tmp/fqad_auto.sh
		rm -rf /tmp/fqad_update.sh
		rm -rf /tmp/fqadrules_update.sh
		sh /etc/dnsmasq/fqadrules_update.sh
	fi	
fi
echo
exit 0
