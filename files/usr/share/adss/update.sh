#!/bin/sh

message l "开始检测更新脚本及规则"
if [ -s "/etc/rc.d/S90adss" ] && [ ! -s "/etc/rc.d/S18adss" ]; then
	rm -f /etc/rc.d/S90adss
	ln -s /etc/init.d/adss /etc/rc.d/S18adss
fi
if [ ! -s "/lib/upgrade/keep.d/adss" ]; then
	download "files/lib/upgrade/keep.d/adss" "/lib/upgrade/keep.d/adss"
fi

batch_download \
	"adss.sh" "${TMP_DIR}/adss.sh" \
    "files/usr/share/adss/update.sh" "${TMP_DIR}/update.sh" \
    "files/usr/share/adss/rules_update.sh" "${TMP_DIR}/rules_update.sh"

if ! cmp -s "/usr/share/adss/adss.sh" "${TMP_DIR}/adss.sh" ; then
	message l "检测到新版 ADSS 脚本......开始更新。"
	mv ${TMP_DIR}/adss.sh /usr/share/adss/adss.sh
fi

if [ -s "${TMP_DIR}/update.sh" ] && [ -s "${TMP_DIR}/rules_update.sh" ]; then
	if ! cmp -s "${TMP_DIR}/update.sh" "/usr/share/adss/update.sh" ; then
		message l "`date +'%Y-%m-%d %H:%M:%S'`: 检测到新版升级脚本......开始更新。"
		message l "开始更新升级脚本"
		mv -f ${TMP_DIR}/update.sh /usr/share/adss/update.sh
		chmod 755 /usr/share/adss/update.sh
		message l "`date +'%Y-%m-%d %H:%M:%S'`: 升级脚本完成。"
		message l "`date +'%Y-%m-%d %H:%M:%S'`: 检测规则升级脚本是否需要更新。"
		if ! cmp -s "${TMP_DIR}/rules_update.sh" "/usr/share/adss/rules_update.sh" ; then
			message l "`date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......开始更新。"
			mv -f ${TMP_DIR}/rules_update.sh /usr/share/adss/rules_update.sh
			chmod 755 /usr/share/adss/rules_update.sh
			message l "`date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。"
			message l "`date +'%Y-%m-%d %H:%M:%S'`: 开始检测规则更新。"
			. /usr/share/adss/rules_update.sh
			message l "`date +'%Y-%m-%d %H:%M:%S'`: 规则更新已完成。"
		else
			message l "`date +'%Y-%m-%d %H:%M:%S'`: ADSS 无需更新，开始检测规则更新。"
			. /usr/share/adss/rules_update.sh
			message l "`date +'%Y-%m-%d %H:%M:%S'`: 规则更新已完成。"
		fi
	elif ! cmp -s "${TMP_DIR}/rules_update.sh" "/usr/share/adss/rules_update.sh" ; then
		message l "`date +'%Y-%m-%d %H:%M:%S'`: 检测到新版规则升级脚本......开始更新。"
		mv -f ${TMP_DIR}/rules_update.sh /usr/share/adss/rules_update.sh
		chmod 755 /usr/share/adss/rules_update.sh
		message l "`date +'%Y-%m-%d %H:%M:%S'`: 规则升级脚本更新完成。"
		message l "`date +'%Y-%m-%d %H:%M:%S'`: 开始检测规则更新。"
		. /usr/share/adss/rules_update.sh
		message l "`date +'%Y-%m-%d %H:%M:%S'`: 规则更新已完成。"
	else
		message l "`date +'%Y-%m-%d %H:%M:%S'`: ADSS 已为最新，开始检测规则更新。"
		. /usr/share/adss/rules_update.sh
		message l "`date +'%Y-%m-%d %H:%M:%S'`: 规则更新已完成。"
	fi
else
	message l "`date +'%Y-%m-%d %H:%M:%S'`: 文件下载异常，放弃更新。"
	rm -rf ${TMP_DIR}
	exit 1;
fi

rm -rf ${TMP_DIR}
exit 0
