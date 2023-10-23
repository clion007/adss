#!/bin/sh
clear
echo "开始检测配置脚本相关软件"
echo
wget=/usr/bin/wget-ssl
dnsmasq=/usr/sbin/dnsmasq
ujail=/sbin/ujail
if [ -f /var/lock/opkg.lock ]; then
	rm -f /var/lock/opkg.lock
fi
if [ ! -f $wget ]; then
	echo -e "\e[1;31m 发现当前路由尚未安装脚本配置需要的wget软件，尝试安装\e[0m"
	opkg update >/dev/null
	opkg install wget
	echo
	if [ -f $wget ]; then
		echo -e "\e[1;36m wget安装成功\e[0m"
	else
		echo -e "\e[1;31m wget安装失败,请网页登录路由器系统软件包手动安装后再试!\e[0m"
		exit 1
	fi	
	echo
fi
echo -e -n "\e[1;31m 是否需要卸载自带dnsmasq，安装dnsmasq-full？[y/n]：\e[0m"
echo
read dnsmasqchange
if [ "$dnsmasqchange" = "y" ];then
	sleep 2
	echo -e "\e[1;36m 开始卸载dnsmasq并安装dnsmasq-full\e[0m"
	echo
	if [ -f $dnsmasq ]; then
		echo -e "\e[1;31m 系统已经安装dnsmasq软件，即将开始卸载\e[0m"
		opkg remove dnsmasq
		echo
		if [ -f $dnsmasq ]; then
			echo -e "\e[1;36m dnsmasq卸载失败，请web登录路由器到系统软件包中手动卸载安装后跳过\e[0m"
			exit 0
		else
			echo -e "\e[1;31m dnsmasq卸载成功，即将安装dnsmasq-full\e[0m"
			echo
		fi	
		opkg update >/dev/null
		opkg install dnsmasq-full
		if [ -f $dnsmasq ]; then
			echo -e "\e[1;36m dnsmasq-full安装成功\e[0m"
			if [ -f /etc/config/dhcp.opkg ]; then
				cp -f -p /etc/config/dhcp.opkg /etc/config/dhcp
			fi	
		else
			echo -e "\e[1;31m dnsmasq-full安装失败,请web登录路由器到系统软件包中手动安装后再试!\e[0m"
			exit 0
		fi	
		else
		echo -e "\e[1;31m 没有发现dnsmasq开始安装\e[0m"
		opkg update
		opkg install dnsmasq-full
		echo
		if [ -f $dnsmasq ]; then
			echo -e "\e[1;36m dnsmasq-full安装成功\e[0m]"
		else
			echo -e "\e[1;31m dnsmasq-full安装失败,请web登录路由器到系统软件包中手动安装后再试!\e[0m"
			exit 0
		fi	
	fi	
fi
if [ -f $ujail ]; then
	opkg remove ujail
fi
echo
clear
wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/copyright.sh -c -q -O \
	/tmp/copyright.sh && chmod 775 /tmp/copyright.sh
sh /tmp/copyright.sh
echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\e[1;36m 安装配置说明：1、2脚本可在安装过程中自定义每天更新规则时间；3、4脚本为全自动安装，规则更新时间为每天早上5:28\e[0m"
echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------"
echo
echo -e "\e[1;36m >         1. 安装配置去广告全自动脚本 \e[0m"
echo
echo -e "\e[1;36m >         2. 安装配置翻墙去广告全自动脚本 \e[0m"
echo
echo -e "\e[1;36m >         3. 卸载已安装脚本 \e[0m"
echo
echo -e "\e[1;36m >         4. 退出安装 \e[0m"
echo
echo -e -n "\e[1;34m 请输入数字回车执行: \e[0m" 
read Run_Num
echo
if [ "$Run_Num" == "1" ]; then
	echo -e "\e[1;36m 三秒后开始安装配置去广告全自动脚本......\e[0m"
	echo
	sleep 3
	wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/ad_auto.sh -c -q -O \
		/tmp/ad_auto.sh && chmod 775 /tmp/ad_auto.sh && sh /tmp/ad_auto.sh
elif [ "$Run_Num" == "2" ]; then
	echo -e "\e[1;36m 三秒后开始安装配置翻墙去广告全自动脚本......\e[0m"
	echo
	sleep 3
	wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/fqad_auto.sh -c -q -O \
		/tmp/fqad_auto.sh && chmod 775 /tmp/fqad_auto.sh && sh /tmp/fqad_auto.sh
elif [ "$Run_Num" == "3" ]; then
	echo -e "\e[1;36m 三秒后开始卸载已安装脚本......\e[0m"
	echo
	sleep 3
	wget --no-check-certificate https://gitcode.net/clion007/dnsmasq/raw/master/uninstall.sh -c -q -O \
		/tmp/uninstall.sh && chmod 775 /tmp/uninstall.sh && sh /tmp/uninstall.sh
	rm -f /tmp/uninstall.sh
elif [ "$Run_Num" == "4" ]; then
	echo "\e[1;36m 您已取消脚本安装，三秒后即将退出！\e[0m"
	sleep 3
	echo
else
	echo "\e[1;36m 您的输入不正确，即将退出脚本安装！\e[0m"
	echo
fi
if [ -f "/tmp/copyright.sh" ]; then
	rm -f /tmp/copyright.sh
fi
exit 0