#!/bin/sh
echo -e "\e[1;36m 检测与处理倚赖关系\e[0m"
echo 
if ! type opkg > /dev/null 2>&1; then
  echo "ADSS 仅支持 Openwrt 系列固件使用，暂时不支持当前固件"
  exit 1
fi
if [ -f /var/lock/opkg.lock ]; then
 rm -f /var/lock/opkg.lock
fi
opkg update > /dev/null
opkg list_installed | grep "dnsmasq" > /dev/null
if [ ! $? -eq 0 ]; then
  opkg install dnsmasq-full > /dev/null
  opkg list_installed | grep "dnsmasq" > /dev/null
  if [ ! $? -eq 0 ]; then
    echo -e "\e[1;31m dnsmasq-full安装失败,请web登录路由器到系统软件包中手动安装后再试!\e[0m"
    exit 1
  fi
fi
echo -e "\e[1;36m 倚赖关系处理完成\e[0m"
echo 
echo -e "\e[1;36m ADSS 每天04:25自动更新规则，自动检测网络不通重启路由器，如需修改更新时间，可自行在计划任务中修改\e[0m"
echo 
echo -e "\e[1;36m 开始安装配置 ADSS\e[0m"
echo 
echo -e "\e[1;36m 开始备份路由器相关配置\e[0m"
echo 
curl --create-dirs ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/config/prepare.sh -sSo /tmp/adss/prepare.sh
. /tmp/adss/prepare.sh
echo 
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/config/configer.sh -sSo /tmp/adss/configer.sh
. /tmp/adss/configer.sh
echo -e "\e[1;36m 部署相关文件\e[0m"
echo 
curl --http1.1 ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/rules/file/dnsrules.conf -sSo /etc/dnsmasq.d/adss/rules/dnsrules.conf --retry 3 --retry-delay 2
curl --http1.1 ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/rules/file/hostsrules.conf -sSo /etc/dnsmasq.d/adss/rules/hostsrules.conf --retry 3 --retry-delay 2
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/adss.sh -sSo /usr/share/adss/adss.sh
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/usr/share/adss/netcheck.sh -sSo /usr/share/adss/netcheck.sh
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/usr/share/adss/update.sh -sSo /usr/share/adss/update.sh
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/usr/share/adss/rules_update.sh -sSo /usr/share/adss/rules_update.sh
chmod -R 755 /usr/share/adss
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/config/cron.sh -sSo /tmp/adss/cron.sh
. /tmp/adss/cron.sh
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/etc/init.d/adss -sSo /etc/init.d/adss
chmod 755 /etc/init.d/adss
if [ -f /etc/rc.d/S18adss ]; then
  ln -s /etc/init.d/adss /etc/rc.d/S18adss
fi
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/lib/upgrade/keep.d/adss -sSo /lib/upgrade/keep.d/adss
echo -e "\e[1;36m 删除安装临时文件\e[0m"
rm -rf /tmp/adss
echo 
echo -e "\e[1;36m 启用 ADSS 脚本\e[0m"
/etc/init.d/adss start > /dev/null 2>&1
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
