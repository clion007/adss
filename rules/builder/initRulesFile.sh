 #!/bin/sh
message l "创建 dnsmasq 规则文件"
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

# Modified DNS start" > ${TMP_DIR}/dnsrules.conf 
message l "创建 hosts 规则文件"
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

# 修饰 hosts 开始" > ${TMP_DIR}/hostsrules.conf 
rm -f ${TMP_DIR}/initRulesFile.sh