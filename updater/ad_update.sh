#!/bin/sh
if [ ! -s /tmp/copyright.sh ]; then
	wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/copyright.sh -qO \
		/tmp/copyright.sh && chmod 775 /tmp/copyright.sh
fi
if [ -s "/tmp/copyright.sh" ]; then
	sh /tmp/copyright.sh
else
	echo
	echo -e "\e[1;36m  `date +'%Y-%m-%d %H:%M:%S'`: 文件下载异常，放弃本次更新。\e[0m"
	echo
	rm -f /tmp/copyright.sh
	exit 1
fi
echo
echo -e "\e[1;36m 开始检测更新脚本及规则\e[0m"
echo
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/ad_auto.sh -qO \
      /tmp/ad_auto.sh && chmod 775 /tmp/ad_auto.sh
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/ad_update.sh -qO \
      /tmp/ad_update.sh && chmod 775 /tmp/ad_update.sh
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/adrules_update.sh -qO \
      /tmp/adrules_update.sh && chmod 775 /tmp/adrules_update.sh
if [ -s "/tmp/ad_auto.sh" -a -s "/tmp/ad_update.sh" -a -s "/tmp/adrules_update.sh" ]; then
	if ( ! cmp -s /tmp/ad_auto.sh /etc/dnsmasq/ad_auto.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新脚本\e[0m"
		echo
		sh /tmp/ad_auto.sh
		rm -rf /tmp/ad_update.sh /tmp/adrules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 脚本及规则更新完成。"
		echo
	elif ( ! cmp -s /tmp/ad_update.sh /etc/dnsmasq/ad_update.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版升级脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新升级脚本\e[0m"
		mv -f /tmp/ad_update.sh /etc/dnsmasq/ad_update.sh
		echo
		sh /etc/dnsmasq/ad_update.sh
		rm -rf /tmp/ad_auto.sh /tmp/adrules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 升级脚本更新完成。"
		echo
	elif ( ! cmp -s /tmp/adrules_update.sh /etc/dnsmasq/adrules_update.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新规则升级脚本\e[0m"
		mv -f /tmp/adrules_update.sh /etc/dnsmasq/adrules_update.sh
		echo
		rm -rf /tmp/ad_auto.sh /tmp/ad_update.sh
		sh /etc/dnsmasq/adrules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。"
		echo
	else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 脚本已为最新，开始检测规则更新"
		echo
		rm -rf /tmp/ad_auto.sh /tmp/ad_update.sh /tmp/adrules_update.sh
		sh /etc/dnsmasq/adrules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 规则已经更新完成。"
		echo
	fi
else
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 脚本文件下载异常，放弃本次更新。"
	echo
	rm -f /tmp/copyright.sh /tmp/ad_auto.sh /tmp/ad_update.sh /tmp/adrules_update.sh
	exit 1;
fi
rm -f /tmp/copyright.sh
exit 0

