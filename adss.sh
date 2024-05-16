 #!/bin/sh
#
# ADSS(Auto DNS Smart Script) V4.0
# Project URL https://github.com/clion007/adss
# Main Module file
# Copyright © by Clion Nieh Email: clion007@126.com
# Licenses in GPL-3
#

curl https://gitee.com/clion007/adss/raw/master/installer/copyright.sh -sSo /tmp/adss/copyright.sh
if [ -s "/tmp/adss/copyright.sh" ]; then
  sh /tmp/adss/copyright.sh
else
  echo 
  echo -e "\e[1;36m  `date +'%Y-%m-%d %H:%M:%S'`: 网络异常，退出安装。\e[0m"
  echo 
  exit 1
fi
echo 