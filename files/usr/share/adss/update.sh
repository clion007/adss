#!/bin/sh

set -e
mkdir -p /tmp/adss
print w "开始检测更新脚本及规则"
if [ -s "/etc/rc.d/S90adss" ] && [ ! -s "/etc/rc.d/S18adss" ]; then
	rm -f /etc/rc.d/S90adss && ln -s /etc/init.d/adss /etc/rc.d/S18adss
fi
if [ ! -s "/lib/upgrade/keep.d/adss" ]; then
	download "files/lib/upgrade/keep.d/adss" "/lib/upgrade/keep.d/adss"
fi
download "files/usr/share/adss/update.sh" "/tmp/adss/update.sh"
download "files/usr/share/adss/rules_update.sh" "/tmp/adss/rules_update.sh"
if [ -s "/tmp/adss/update.sh" ] && [ -s "/tmp/adss/rules_update.sh" ]; then
	if ( ! cmp -s /tmp/adss/update.sh /usr/share/adss/update.sh ); then
		print w "`date +'%Y-%m-%d %H:%M:%S'`: 检测到新版升级脚本......开始更新。"
		print w "开始更新升级脚本"
		mv -f /tmp/adss/update.sh /usr/share/adss/update.sh
		chmod 755 /usr/share/adss/update.sh
		print w "`date +'%Y-%m-%d %H:%M:%S'`: 升级脚本完成。"
		print w "`date +'%Y-%m-%d %H:%M:%S'`: 检测规则升级脚本是否需要更新。"
		if ( ! cmp -s /tmp/adss/rules_update.sh /usr/share/adss/rules_update.sh ); then
			print w "`date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......开始更新。"
			mv -f /tmp/adss/rules_update.sh /usr/share/adss/rules_update.sh
			chmod 755 /usr/share/adss/rules_update.sh
			print w "`date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。"
			print w "`date +'%Y-%m-%d %H:%M:%S'`: 开始检测规则更新。"
			/usr/share/adss/rules_update.sh
			print w "`date +'%Y-%m-%d %H:%M:%S'`: 规则更新已完成。"
		else
			print w "`date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本无需更新，开始检测规则更新。"
			/usr/share/adss/rules_update.sh
			print w "`date +'%Y-%m-%d %H:%M:%S'`: 规则更新已完成。"
		fi
	elif ( ! cmp -s /tmp/adss/rules_update.sh /usr/share/adss/rules_update.sh ); then
		print w "`date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......开始更新。"
		mv -f /tmp/adss/rules_update.sh /usr/share/adss/rules_update.sh
		chmod 755 /usr/share/adss/rules_update.sh
		print w "`date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。"
		print w "`date +'%Y-%m-%d %H:%M:%S'`: 开始检测规则更新。"
		/usr/share/adss/rules_update.sh
		print w "`date +'%Y-%m-%d %H:%M:%S'`: 规则更新已完成。"
	else
		print w "`date +'%Y-%m-%d %H:%M:%S'`: 脚本已为最新，开始检测规则更新。"
		/usr/share/adss/rules_update.sh
		print w "`date +'%Y-%m-%d %H:%M:%S'`: 规则更新已完成。"
	fi
else
	print w "`date +'%Y-%m-%d %H:%M:%S'`: 文件下载异常，放弃更新。"
	rm -rf /tmp/adss
	exit 1;
fi
rm -rf /tmp/adss
exit 0
