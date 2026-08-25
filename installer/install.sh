#!/bin/sh
print l "检测与处理倚赖关系"
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
    print r "dnsmasq-full安装失败,请web登录路由器到系统软件包中手动安装后再试!"
    exit 1
  fi
fi
print l "倚赖关系处理完成"
print l "ADSS 每天04:25自动更新规则，自动检测网络不通重启路由器，如需修改更新时间，可自行在计划任务中修改"
print l "开始安装配置 ADSS"
print l "开始备份路由器相关配置"

download "config/prepare.sh" "/tmp/adss/prepare.sh"
. /tmp/adss/prepare.sh

download "config/configer.sh" "/tmp/adss/configer.sh"
. /tmp/adss/configer.sh

print l "部署相关文件"
batch_download \
    "rules/file/dnsrules.conf" "/etc/dnsmasq.d/adss/rules/dnsrules.conf" \
    "rules/file/hostsrules.conf" "/etc/dnsmasq.d/adss/rules/hostsrules.conf" \
    "adss.sh" "/usr/share/adss/adss.sh" \
    "files/usr/share/adss/netcheck.sh" "/usr/share/adss/netcheck.sh" \
    "files/usr/share/adss/update.sh" "/usr/share/adss/update.sh" \
    "files/usr/share/adss/rules_update.sh" "/usr/share/adss/rules_update.sh" \
    "files/etc/init.d/adss" "/etc/init.d/adss" \
    "files/lib/upgrade/keep.d/adss" "/lib/upgrade/keep.d/adss"
chmod -R 755 /usr/share/adss /etc/init.d/adss

# 将 ADSS 命令链接到 /usr/bin，可在终端直接使用 adss install/uninstall/upgrade
if [ ! -L /usr/bin/adss ]; then
  ln -s /usr/share/adss/adss.sh /usr/bin/adss
fi

# ADSS 开机启动设置
if [ ! -L /etc/rc.d/S18adss ]; then
  ln -s /etc/init.d/adss /etc/rc.d/S18adss
fi

# 添加 ADSS 计划任务
run_remote "config/cron.sh"


print l "删除安装临时文件"
rm -rf /tmp/adss
print l "启用 ADSS 脚本"
/etc/init.d/adss start > /dev/null 2>&1

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
