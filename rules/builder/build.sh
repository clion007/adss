#!/bin/sh
# ADSS 规则构建脚本
# 用于根据配置文件生成 dnsmasq 和 hosts 规则文件

set -e

TMP_DIR="/tmp/adss"
mkdir -p "${TMP_DIR}"

# 加载通用工具函数包
. ./utils/utils.sh
. ./rules/builder/initRulesFile.sh
. ./rules/builder/getDnsmasqAdRules.sh
. ./rules/builder/getHostsAdRules.sh
. ./rules/builder/deletWhiteListRules.sh
message l "删除重复规则"
sort -u ${TMP_DIR}/dnsAd >> ${TMP_DIR}/dnsrules.conf
echo "# Modified DNS end" >> ${TMP_DIR}/dnsrules.conf
sort -u ${TMP_DIR}/hostsAd >> ${TMP_DIR}/hostsrules.conf
echo "# 修饰 hosts 结束" >> ${TMP_DIR}/hostsrules.conf
mv -f ${TMP_DIR}/dnsrules.conf ./rules/file/dnsrules.conf
mv -f ${TMP_DIR}/hostsrules.conf ./rules/file/hostsrules.conf
message g "规则创建完成！"
rm -rf ${TMP_DIR}