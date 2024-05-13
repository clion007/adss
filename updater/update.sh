#!/bin/sh
if [ ! -s /tmp/adss/copyright.sh ]; then
	wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/copyright.sh -qO \
		/tmp/adss/copyright.sh && chmod 775 /tmp/adss/copyright.sh
fi
if [ -s "/tmp/adss/copyright.sh" ]; then
	sh /tmp/adss/copyright.sh
else
	echo
	echo -e "\e[1;36m  `date +'%Y-%m-%d %H:%M:%S'`: 网络异常，放弃本次更新。\e[0m"
	echo
	exit 1
fi
echo
echo -e "\e[1;36m 开始检测更新脚本及规则\e[0m"
echo
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/updater/update.sh -qO \
      /tmp/adss/update.sh && chmod 775 /tmp/adss/update.sh
wget --no-check-certificate https://gitcode.net/clion007/adss/raw/master/updater/rules_update.sh -qO \
      /tmp/adss/rules_update.sh && chmod 775 /tmp/adss/rules_update.sh
if [ -s "/tmp/adss/update.sh" -a -s "/tmp/adss/rules_update.sh" ]; then
	if ( ! cmp -s /tmp/adss/update.sh /etc/dnsmasq.d/adss/update.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版升级脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新升级脚本\e[0m"
		mv -f /tmp/adss/update.sh /etc/dnsmasq.d/adss/update.sh
		echo
		sh /etc/dnsmasq.d/adss/update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 升级脚本更新完成。"
		echo
	elif ( ! cmp -s /tmp/adss/rules_update.sh /etc/dnsmasq.d/adss/rules_update.sh ); then
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......3秒后即将开始更新！"
		echo
		sleep 3
		echo -e "\e[1;36m 开始更新规则升级脚本\e[0m"
		mv -f /tmp/adss/rules_update.sh /etc/dnsmasq.d/adss/rules_update.sh
		echo
		sh /etc/dnsmasq.d/adss/rules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。"
		echo
	else
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 脚本已为最新，开始检测规则更新"
		echo
		sh /etc/dnsmasq.d/adss/rules_update.sh
		echo " `date +'%Y-%m-%d %H:%M:%S'`: 规则已经更新完成。"
		echo
	fi
else
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 脚本文件下载异常，放弃本次更新。"
	echo
	rm -rf /tmp/adss
	exit 1;
fi
rm -rf /tmp/adss
exit 0

