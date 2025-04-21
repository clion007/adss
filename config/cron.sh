#!/bin/sh
# 修正可能未定义的USER变量
CURRENT_USER=$(whoami 2>/dev/null || echo "root")
CRON_FILE=/etc/crontabs/${CURRENT_USER}

grep "adss" $CRON_FILE > /dev/null
if [ $? -ne 0 ]; then
  echo -e "\e[1;31m 添加规则自动更新任务\e[0m"
  echo "# 每天 04:25 更新ADSS规则
25 4 * * * /usr/share/adss/update.sh > /dev/null 2>&1" >> $CRON_FILE
  echo 
  echo -e "\e[1;36m 设置网络不通重启任务\e[0m"
  echo 
  echo "# 每5分钟检测一次网络，网络异常，重启网络服务
*/5 * * * * /usr/share/adss/netcheck.sh > /dev/null 2>&1" >> $CRON_FILE
  /etc/init.d/cron reload > /dev/null
fi
