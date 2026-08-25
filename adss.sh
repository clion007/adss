#!/bin/sh
#
# ADSS(Auto DNS Smart Script) V4.3
# Project URL https://github.com/clion007/adss
# Main Module file
# Copyright © by Clion Nieh Email: clion007@126.com
# Licenses in GPL-3.0
#

clear
mkdir -p /tmp/adss
echo -e "\e[1;36m 获取最佳 Github 加速镜像\e[0m"
echo 
GH_PROXY_PREFIX="https://github.akams.cn/"
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/ghnodes/ghnodes.ini -sSo /tmp/adss/ghnodes.ini
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/ghnodes/check.sh -sSo /tmp/adss/ghcheck.sh
. /tmp/adss/ghcheck.sh
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/installer/copyright.sh -sSo /tmp/adss/copyright.sh
if [ -s "/tmp/adss/copyright.sh" ]; then
  . /tmp/adss/copyright.sh
else
  echo -e "\e[1;36m  `date +'%Y-%m-%d %H:%M:%S'`: 网络异常，退出安装。\e[0m"
  exit 1
fi
echo 
echo -e "\e[1;36m >         1. 安装 ADSS \e[0m"
echo 
echo -e "\e[1;36m >         2. 卸载 ADSS \e[0m"
echo 
echo -e "\e[1;36m >         3. 退出 \e[0m"
echo 
echo -e -n "\e[1;34m 请输入数字回车执行: \e[0m" 
read Run_Num
echo 
if [ "$Run_Num" == "1" ]; then
	echo -e "\e[1;36m 即将开始安装配置去广告全自动脚本\e[0m"
	echo 
	curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/installer/install.sh -sSo /tmp/adss/install.sh
    . /tmp/adss/install.sh
elif [ "$Run_Num" == "2" ]; then
	echo -e "\e[1;36m 开始卸载已安装脚本\e[0m"
	echo 
	curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/installer/uninstall.sh -sSo /tmp/adss/uninstall.sh
	. /tmp/adss/uninstall.sh
else
    rm -rf /tmp/adss
fi
exit 0
