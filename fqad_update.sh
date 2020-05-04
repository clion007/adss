#!/bin/sh
clear
echo
if [ ! -s /tmp/copyright.sh ]; then
	wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/copyright.sh -O \
		/tmp/copyright.sh && chmod 775 /tmp/copyright.sh && sh /tmp/copyright.sh
	else
		sh /tmp/copyright.sh
fi
rm -f /tmp/copyright.sh
echo -e "\e[1;36m 1秒钟后开始检测更新脚本及规则\e[0m"
echo
sleep 1
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
		wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/uninstall.sh -O \
			/tmp/ad_auto.sh && chmod 775 /tmp/ad_auto.sh && sh /tmp/uninstall.sh > /dev/null 2>&1
		rm -f /tmp/uninstall.sh
		sh /tmp/fqad_auto.sh
		rm -rf /tmp/fqad_update.sh /tmp/fqadrules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 翻墙去广告脚本及规则更新完成。"
		exit 0
	elif ( ! cmp -s /tmp/fqad_update.sh /etc/dnsmasq/fqad_update.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版升级脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新升级脚本\e[0m"
		echo
		sh /tmp/fqad_update.sh
		mv -f /tmp/fqad_update.sh /etc/dnsmasq/fqad_update.sh
		rm -rf /tmp/fqad_auto.sh /tmp/fqadrules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 升级脚本更新完成。"
		exit 0
	elif ( ! cmp -s /tmp/fqadrules_update.sh /etc/dnsmasq/fqadrules_update.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新规则升级脚本\e[0m"
		echo
		sh /tmp/fqadrules_update.sh
		mv -f /tmp/fqadrules_update.sh /etc/dnsmasq/fqadrules_update.sh
		rm -rf /tmp/fqad_auto.sh /tmp/fqad_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。"
		exit 0
		else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 脚本已为最新，3秒后即将开始检测翻墙去广告规则更新"
		sh /etc/dnsmasq/fqadrules_update.sh
		rm -rf /tmp/fqad_auto.sh /tmp/fqad_update.sh /tmp/fqadrules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 规则已经更新完成。"
		exit 0
	fi	
	else
	if ( -f /tmp/fqad_auto.sh); then
		rm -f  /tmp/fqad_auto.sh
	fi	
	if ( -f /tmp/fqad_update.sh); then
		rm -f  /tmp/fqad_update.sh
	fi	
	if ( -f /tmp/fqadrules_update.sh); then
		rm -f  /tmp/fqadrules_update.sh
	fi	
	echo -e "\e[1;36m  `date +'%Y-%m-%d %H:%M:%S'`: 网络连接异常，稍后尝试规则更新。\e[0m"
	sh /etc/dnsmasq/fqadrules_update.sh
fi
exit 0
