#!/bin/sh
echo
echo "检测网络环境是否正常"
echo
res_code=`curl -I -s --connect-timeout 1 raw.githubusercontent.com -w %{http_code} | tail -n1`
if [ $res_code != 200 -a $res_code != 301 ]; then
	echo "检测到网络异常，放弃本次更新"
	echo
	exit 1
fi
clear
if [ ! -s /tmp/copyright.sh ]; then
	wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/copyright.sh -qO \
		/tmp/copyright.sh && chmod 775 /tmp/copyright.sh
fi
if [ -s "/tmp/copyright.sh" ]; then
	sh /tmp/copyright.sh
else
	echo -e "\e[1;36m  `date +'%Y-%m-%d %H:%M:%S'`: 文件下载异常，放弃本次更新。\e[0m"
	echo
	exit 1
fi
echo
echo -e "\e[1;36m 开始检测更新脚本及规则\e[0m"
echo
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/ad_auto.sh -qO \
      /tmp/ad_auto.sh && chmod 775 /tmp/ad_auto.sh
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/ad_update.sh -qO \
      /tmp/ad_update.sh && chmod 775 /tmp/ad_update.sh
wget --no-check-certificate https://raw.githubusercontent.com/clion007/dnsmasq/master/adrules_update.sh -qO \
      /tmp/adrules_update.sh && chmod 775 /tmp/adrules_update.sh
if  ( ! cmp -s /tmp/ad_auto.sh /etc/dnsmasq/ad_auto.sh ); then
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版脚本......3秒后即将开始更新！"
	echo
	sleep 3
	echo -e "\e[1;36m 开始更新脚本\e[0m"
	echo
	sh /tmp/ad_auto.sh
	rm -rf /tmp/ad_update.sh /tmp/adrules_update.sh
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 脚本及规则更新完成。"
	echo
	exit 0
elif( ! cmp -s /tmp/ad_update.sh /etc/dnsmasq/ad_update.sh ); then
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版升级脚本......3秒后即将开始更新！"
	echo
	sleep 3
	echo -e "\e[1;36m 开始更新升级脚本\e[0m"
	echo
	mv -f /tmp/ad_update.sh /etc/dnsmasq/ad_update.sh
	sh /etc/dnsmasq/ad_update.sh
	rm -rf /tmp/ad_auto.sh /tmp/adrules_update.sh
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 升级脚本更新完成。"
	echo
elif ( ! cmp -s /tmp/adrules_update.sh /etc/dnsmasq/adrules_update.sh ); then
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......3秒后即将开始更新！"
	echo
	sleep 3
	echo -e "\e[1;36m 开始更新规则升级脚本\e[0m"
	echo
	mv -f /tmp/adrules_update.sh /etc/dnsmasq/adrules_update.sh
	rm -rf /tmp/ad_auto.sh /tmp/ad_update.sh
	sh /etc/dnsmasq/adrules_update.sh
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。"
	echo
else
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 脚本已为最新，3秒后即将开始检测规则更新"
	echo
	rm -rf /tmp/ad_auto.sh /tmp/ad_update.sh /tmp/adrules_update.sh
	sh /etc/dnsmasq/adrules_update.sh
	echo " `date +'%Y-%m-%d %H:%M:%S'`: 规则已经更新完成。"
	echo
fi
rm -f /tmp/copyright.sh
exit 0
