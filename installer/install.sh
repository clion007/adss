 #!/bin/bash
echo 
echo -e "\e[1;36m 三秒后开始备份路由器相关配置\e[0m"
echo 
sleep 3
curl -sSo /tmp/adss/backup.sh https://gitee.com/clion007/adss/raw/master/config/backup.sh
chmod 775 /tmp/adss/backup.sh && . /tmp/adss/backup.sh
rm -f /tmp/adss/backup.sh
echo 
sleep 3
curl -sSo /tmp/adss/modifyConfig.sh https://gitee.com/clion007/adss/raw/master/config/modifyConfig.sh
chmod 775 /tmp/adss/modifyConfig.sh  && . /tmp/adss/modifyConfig.sh
rm -f /tmp/modifyConfig.sh
sleep 3
echo -e "\e[1;36m 获取规则文件......\e[0m"
echo 
curl -sSo /usr/share/adss/rules/dnsrules.conf https://gitee.com/clion007/adss/raw/master/rules/file/dnsrules.conf
curl -sSo /usr/share/adss/rules/hostsrules.conf https://gitee.com/clion007/adss/raw/master/rules/file/hostsrules.conf
sleep 3
echo -e "\e[1;36m 重启dnsmasq服务\e[0m"
echo 
killall dnsmasq > /dev/null 2>&1
/etc/init.d/dnsmasq restart > /dev/null 2>&1
sleep 2
curl -sSo /usr/share/adss/adss.sh https://gitee.com/clion007/adss/raw/master/adss.sh
chmod 755 /usr/share/adss/adss.sh
curl -sSo /usr/share/adss/update.sh https://gitee.com/clion007/adss/raw/master/updater/update.sh
chmod 755 /usr/share/adss/update.sh
curl -sSo /usr/share/adss/rules_update.sh https://gitee.com/clion007/adss/raw/master/updater/rules_update.sh
chmod 755 /usr/share/adss/rules_update.sh
sleep 3
curl -sSo /tmp/adss/cron.sh https://gitee.com/clion007/adss/raw/master/config/cron.sh
chmod 775 /tmp/adss/cron.sh && . /tmp/adss/cron.sh
echo -e "\e[1;36m 删除安装临时文件\e[0m"
rm -rf /tmp/adss
echo 
echo 
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                           +"
echo "+       Auto DNS Smart Script installation is complete      +"
echo "+                                                           +"
echo "+                      Time:`date +'%Y-%m-%d'`                      +"
echo "+                                                           +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo 
echo 
