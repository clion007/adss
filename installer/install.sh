 #!/bin/bash
echo 
echo -e "\e[1;36m 开始备份路由器相关配置\e[0m"
echo 
curl https://gitee.com/clion007/adss/raw/master/config/backup.sh -sSo /tmp/adss/backup.sh
. /tmp/adss/backup.sh
echo 
curl https://gitee.com/clion007/adss/raw/master/config/modifyConfig.sh -sSo /tmp/adss/modifyConfig.sh
. /tmp/adss/modifyConfig.sh
echo -e "\e[1;36m 获取规则文件\e[0m"
echo 
curl https://gitee.com/clion007/adss/raw/master/rules/file/dnsrules.conf -sSo /usr/share/adss/rules/dnsrules.conf
curl https://gitee.com/clion007/adss/raw/master/rules/file/hostsrules.conf -sSo /usr/share/adss/rules/hostsrules.conf
echo -e "\e[1;36m 重启dnsmasq服务\e[0m"
echo 
killall dnsmasq > /dev/null 2>&1
/etc/init.d/dnsmasq restart > /dev/null 2>&1
sleep 2
curl https://gitee.com/clion007/adss/raw/master/adss.sh -sSo /usr/share/adss/adss.sh
curl https://gitee.com/clion007/adss/raw/master/updater/update.sh -sSo /usr/share/adss/update.sh
curl https://gitee.com/clion007/adss/raw/master/updater/rules_update.sh -sSo /usr/share/adss/rules_update.sh
sleep 3
curl https://gitee.com/clion007/adss/raw/master/config/cron.sh -sSo /tmp/adss/cron.sh
. /tmp/adss/cron.sh
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
