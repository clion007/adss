#!/bin/sh
echo -e "\e[1;36m 创建dnsmasq规则文件\e[0m"
echo "
############################################################
## 【Copyright (c) 2014-`date +'%Y'`, clion007】                          ##
##                                                                ##
## 感谢https://github.com/vokins/hosts                            ##
##                                                                ##
####################################################################

# Local DNS (DO NOT REMOVE) Start
address=/localhost/127.0.0.1
address=/localhost/::1
address=/ip6-localhost/::1
address=/ip6-loopback/::1
# Local DNS (DO NOT REMOVE) End

# Modified DNS start" > /tmp/dnsrules.conf
echo
echo -e "\e[1;36m 创建hosts规则文件\e[0m"
echo "
############################################################
## 【Copyright (c) 2014-`date +'%Y'`, clion007】                          ##
##                                                                ##
## 感谢https://github.com/vokins/hosts                            ##
##                                                                ##
####################################################################

# 默认hosts开始（想恢复最初状态的hosts，只保留下面两行即可）
127.0.0.1 localhost
::1	localhost
::1	ip6-localhost
::1	ip6-loopback
# 默认hosts结束

# 修饰hosts开始" > /tmp/hostsrules.conf
