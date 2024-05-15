#!/bin/sh
#
# ADSS(Auto DNS Smart Script) V4.0
# Project URL https://github.com/clion007/adss
# Main Module file
# Copyright © by Clion Nieh Email: clion007@126.com
# Licenses in GPL V3.0
#

function show_copyright() {
  mkdir -p /tmp/adss
  curl -sL https://gitee.com/clion007/adss/raw/master/config/logo
  echo
  echo "Auto DNS Smart Script V4.0"
  echo "Project URL https://github.com/clion007/adss"
  echo "Copyright © 2014-`date +'%Y'`,by Clion Nieh Email: clion007@126.com"
  echo "Licenses in GPL V3.0"
  echo
  echo "------------------------------------------------------------------------------"
  echo "ADSS 仅用于个人研究与学习使用，从未用于产生任何盈利（包括“捐赠”等方式）"
  echo "未经许可，请勿内置于软件内发布与传播！请勿用于产生盈利活动！请遵守当地法律法规!"
  echo "ADSS 仅供openwrt类固件使用，包括但不限于pandorabox、LEDE、ddwrt、明月、石像鬼等。"
  echo -e "安装前请\e[1;31m备份原配置\e[0m；由此产生的一切后果自行承担！"
  echo "------------------------------------------------------------------------------"
  echo
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "+                                                           +"
  echo "+        Install ADSI for OpnWrt/LEDE/PandoraBox etc        +"
  echo "+                                                           +"
  echo "+                      Time:`date +'%Y-%m-%d'`                      +"
  echo "+                                                           +"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo
}

function install() {
  show_copyright
  echo "检测与处理倚赖关系"
  if [ ! type opkg > /dev/null 2>&1 ]; then
    echo "ADSS 仅支持 Openwrt 系列固件使用，暂时不支持当前固件"
    exit 1
  fi
  if [ -f /var/lock/opkg.lock ]; then
    rm -f /var/lock/opkg.lock
  fi
  opkg list_installed | grep "dnsmasq" > /dev/null
  if [ ! $? -eq 0 ]; then
    opkg install dnsmasq-full
    opkg list_installed | grep "dnsmasq" > /dev/null
    if [ ! $? -eq 0 ]; then
      echo -e "\e[1;31m dnsmasq-full安装失败,请web登录路由器到系统软件包中手动安装后再试!\e[0m"
      exit 1
    fi
  fi
  opkg list_installed | grep "wget" > /dev/null
  if [ ! $? -eq 0 ]; then
    opkg install dnsmasq-full
    opkg list_installed | grep "wget" > /dev/null
    if [ ! $? -eq 0 ]; then
      echo -e "\e[1;31m wget安装失败,请web登录路由器到系统软件包中手动安装后再试!\e[0m"
      exit 1
    fi
  fi
  opkg list_installed | grep "ujail" > /dev/null
  if [ $? -eq 0 ]; then
    opkg remove ujail
  fi
  echo
  echo "倚赖关系处理完成"
  echo
  echo -e "\e[1;36m ***ADSS 每天04:25自动更新规则，自动检测网络不通重启路由器，如需修改更新时间，可自行在计划任务中修改***\e[0m"
  echo
  echo -e "\e[1;36m 三秒后开始安装配置 ADSS\e[0m"
	echo
	sleep 3
	wget --no-check-certificate https://gitee.com/clion007/dnsmasq/raw/master/install.sh -c -q -O \
		/tmp/adss/install.sh && chmod 775 /tmp/adss/install.sh && sh /tmp/adss/install.sh
}

function uninstall() {
  show_copyright
	echo -e "\e[1;36m 三秒后开始卸载已安装脚本......\e[0m"
	echo
	sleep 3
	wget --no-check-certificate https://gitee.com/clion007/dnsmasq/raw/master/installer/uninstall.sh -c -q -O \
		/tmp/adss/uninstall.sh && chmod 775 /tmp/adss/uninstall.sh && sh /tmp/adss/uninstall.sh
	rm -rf /tmp/adss
}