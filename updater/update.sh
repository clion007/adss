#!/bin/sh
mkdir -p /tmp/adss
curl https://gitee.com/clion007/adss/raw/master/installer/copyright.sh -sLSo /tmp/adss/copyright.sh
if [ -s "/tmp/adss/copyright.sh" ]; then
  . /tmp/adss/copyright.sh
else
  echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 网络异常，退出更新。\e[0m"
  echo 
  exit 1
fi
echo -e "\e[1;36m 开始检测更新脚本及规则\e[0m"
echo 
curl https://gitee.com/clion007/adss/raw/master/updater/update.sh -sLSo /tmp/adss/update.sh
curl https://gitee.com/clion007/adss/raw/master/updater/rules_update.sh -sLSo /tmp/adss/rules_update.sh
if [ -s "/tmp/adss/update.sh" -a -s "/tmp/adss/rules_update.sh" ]; then
	if ( ! cmp -s /tmp/adss/update.sh /usr/share/adss/update.sh ); then
		echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版升级脚本......开始更新。\e[0m"
		echo 
		echo -e "\e[1;36m 开始更新升级脚本\e[0m"
		mv -f /tmp/adss/update.sh /usr/share/adss/update.sh
		chmod 755 /usr/share/adss/update.sh
		echo 
		echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 升级脚本完成。\e[0m"
		echo 
		if ( ! cmp -s /tmp/adss/rules_update.sh /usr/share/adss/rules_update.sh ); then
			echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......开始更新。\e[0m"
			echo 
			echo -e "\e[1;36m 开始更新规则升级脚本\e[0m"
			mv -f /tmp/adss/rules_update.sh /usr/share/adss/rules_update.sh
			chmod 755 /usr/share/adss/rules_update.sh
			echo 
			echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。\e[0m"
			echo 
			/usr/share/adss/rules_update.sh
		fi
	elif ( ! cmp -s /tmp/adss/rules_update.sh /usr/share/adss/rules_update.sh ); then
		echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......开始更新。\e[0m"
		echo 
		echo -e "\e[1;36m 开始更新规则升级脚本\e[0m"
		mv -f /tmp/adss/rules_update.sh /usr/share/adss/rules_update.sh
		chmod 755 /usr/share/adss/rules_update.sh
		echo 
		/usr/share/adss/rules_update.sh
		echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。\e[0m"
		echo 
	else
		echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 脚本已为最新，开始检测规则更新。\e[0m"
		echo 
		/usr/share/adss/rules_update.sh
		echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 规则已经更新完成。\e[0m"
		echo 
	fi
else
	echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 脚本文件下载异常，放弃本次更新。\e[0m"
	echo 
	rm -rf /tmp/adss
	exit 1;
fi
rm -rf /tmp/adss
exit 0
