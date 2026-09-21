#!/bin/sh
# 修正可能未定义的USER变量
CURRENT_USER=$(id -un 2>/dev/null || echo "root")
CRON_FILE=/etc/crontabs/${CURRENT_USER}

# 仅当缺少新版 adss upgrade 任务行时才写入，已配置则不动（幂等，
# 且保留用户自定义的执行时间）
[ -f "$CRON_FILE" ] || touch "$CRON_FILE"
if ! grep -q "adss upgrade" $CRON_FILE; then
	# 清除老版本格式行（直接调用 update.sh 已不可用）与旧注释
	sed -i "\|/usr/share/adss/update.sh|d" $CRON_FILE
	sed -i "/更新ADSS规则/d" $CRON_FILE
	message l "添加规则自动更新任务"
	echo "# 每天 04:25 更新ADSS升级脚本
25 4 * * * adss upgrade > /dev/null 2>&1" >> $CRON_FILE
	message l "设置网络不通重启任务"
	echo "# 每5分钟检测一次网络，网络异常，重启网络服务
# */5 * * * * /usr/share/adss/netcheck.sh > /dev/null 2>&1" >> $CRON_FILE
	/etc/init.d/cron reload > /dev/null 2>&1
fi
