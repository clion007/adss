 #!/bin/sh
echo -e "\e[1;36m 创建 dnsmasq 规则文件\e[0m"
echo "
####################################################################
##                                                                ##
##      【Copyright (c) 2014-`date +'%Y'`, clion007】                     ##
##                                                                ##
##              Update Time:`date +'%Y-%m-%d'`                            ##
##                                                                ##
####################################################################

# Local DNS (DO NOT REMOVE) Start
address=/localhost/127.0.0.1
address=/localhost/::1
address=/ip6-localhost/::1
address=/ip6-loopback/::1
# Local DNS (DO NOT REMOVE) End

# Modified DNS start" > /tmp/adss/dnsrules.conf 
echo 
echo -e "\e[1;36m 创建 hosts 规则文件\e[0m"
echo "
####################################################################
##                                                                ##
##      【Copyright (c) 2014-`date +'%Y'`, clion007】                     ##
##                                                                ##
##              Update Time:`date +'%Y-%m-%d'`                            ##
##                                                                ##
####################################################################

# 默认 hosts 开始
127.0.0.1 localhost
::1	localhost
::1	ip6-localhost
::1	ip6-loopback
# 默认 hosts 结束

# 修饰 hosts 开始" > /tmp/adss/hostsrules.conf 
rm -f /tmp/adss/initRulesFile.sh