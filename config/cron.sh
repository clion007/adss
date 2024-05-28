#!/bin/sh
CRON_FILE=/etc/crontabs/$USER
grep "adss" $CRON_FILE > /dev/null
if [ $? -ne 0 ]; then
  echo -e "\e[1;31m 添加规则自动更新任务\e[0m"
  echo "# 每天 04:25 更新ADSS规则
25 4 * * * /usr/share/adss/update.sh > /dev/null 2>&1" >> $CRON_FILE
  echo 
  echo -e "\e[1;36m 设置网络不通重启任务\e[0m"
  echo 
  echo "# 每半小时检测一次网络，网络异常，重启网络服务，如果网络仍热异常,则重启路由器
30 * * * * /usr/share/adss/netcheck.sh > /dev/null 2>&1" >> $CRON_FILE
  /etc/init.d/cron reload > /dev/null
fi
