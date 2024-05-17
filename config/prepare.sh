 #!/bin/sh
CRON_FILE=/etc/crontabs/$USER
echo -e "\e[1;36m 创建dnsmasq规则与更新脚本存放的文件夹\e[0m"
echo 
echo -e "\e[1;36m 检测和备份当前dnsmasq配置信息\e[0m"
if [ ! -d /etc/dnsmasq.d/adss/rules ]; then
  mkdir -p /etc/dnsmasq.d/adss/rules
fi
if [ ! -d /usr/share/adss ]; then
  mkdir -p /usr/share/adss
fi
touch $CRON_FILE
if [ ! -f $CRON_FILE-adss.bak ]; then
  cp -p $CRON_FILE $CRON_FILE-adss.bak
fi
