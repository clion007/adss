#!/bin/sh

message w "初始化规则文件"
run_remote "rules/builder/initRulesFile.sh"

message w "获取线上规则文件"
batch_download \
    "rules/file/dnsrules.conf" "${TMP_DIR}/dnsrules" \
    "rules/file/hostsrules.conf" "${TMP_DIR}/hostsrules.conf"

# 校验下载的文件是否非空
if [ ! -s "${TMP_DIR}/dnsrules" ] || [ ! -s "${TMP_DIR}/hostsrules.conf" ]; then
  message w "下载的规则文件为空或损坏!"
  rm -rf ${TMP_DIR}
  exit 1
fi

if ! grep -q "# Modified DNS end" ${TMP_DIR}/dnsrules; then
  message w "下载的 dnsrules 文件不正确!"
  rm -rf ${TMP_DIR}
  exit 1
fi

message w "添加用户定义规则"
cat /etc/dnsmasq.d/adss/rules/userlist > ${TMP_DIR}/userlist
sed -i "/#/d" ${TMP_DIR}/userlist
sed -i '/^\s*$/d' ${TMP_DIR}/userlist

message w "生成用户黑名单规则"
cat /etc/dnsmasq.d/adss/rules/userblacklist > ${TMP_DIR}/blacklist
sed -i "/#/d" ${TMP_DIR}/blacklist
sed -i '/^\s*$/d' ${TMP_DIR}/blacklist
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' ${TMP_DIR}/blacklist

message w "合并处理规则"
cat ${TMP_DIR}/blacklist >> ${TMP_DIR}/dnsrules
sed -i '/localhost/d' ${TMP_DIR}/dnsrules
sed -i 's/#.*//g' ${TMP_DIR}/dnsrules
sed -i '/^\s*$/d' ${TMP_DIR}/dnsrules
sed -i '/\/$/d' ${TMP_DIR}/dnsrules

message w "删除用户白名单中包含规则"
cat /etc/dnsmasq.d/adss/rules/userwhitelist | uniq > ${TMP_DIR}/whitelist
sed -i "/#/d" ${TMP_DIR}/whitelist
while read -r line; do
  if [ -n "${line}" ]; then
    if [ -s "${TMP_DIR}/dnsrules" ]; then
      sed -i "${line}/d" ${TMP_DIR}/dnsrules
    fi
    if [ -s "${TMP_DIR}/hostsrules.conf" ]; then
      sed -i "${line}/d" ${TMP_DIR}/hostsrules.conf
    fi
  fi
done < ${TMP_DIR}/whitelist

message w "生成最终规则文件"
cat ${TMP_DIR}/userlist >> ${TMP_DIR}/dnsrules.conf
rm -f ${TMP_DIR}/userlist
sort -u ${TMP_DIR}/dnsrules >> ${TMP_DIR}/dnsrules.conf
rm -f ${TMP_DIR}/dnsrules
echo "# Modified DNS end" >> ${TMP_DIR}/dnsrules.conf

# --- 核心改进: 配置文件测试 ---
message w "验证新生成的配置文件..."

# 创建一个临时的 dnsmasq 配置文件，用于指向 ${TMP_DIR} 中的规则文件进行测试
TEMP_TEST_CONF="${TMP_DIR}/dnsmasq_test.conf"
# 清空或创建临时配置文件
> "${TEMP_TEST_CONF}"

# 将临时目录下的规则文件路径写入临时测试配置
# 注意：确保这些指令与你的 dnsmasq 版本兼容
# echo "conf-dir=${TMP_DIR},*.conf" >> "${TEMP_TEST_CONF}" # 让 dnsmasq 读取临时目录下以 .conf 结尾的文件
echo "conf-file=${TMP_DIR}/dnsrules.conf" >> "${TEMP_TEST_CONF}"
echo "addn-hosts=${TMP_DIR}/hostsrules.conf" >> "${TEMP_TEST_CONF}"

# 运行 dnsmasq 测试命令，使用临时配置文件
if dnsmasq --conf-file="${TEMP_TEST_CONF}" --test 2>${TMP_DIR}/test_output.log; then
    message w "配置文件测试通过!"
    TEST_PASSED=1
else
    message w "配置文件测试失败!"
    cat ${TMP_DIR}/test_output.log
    rm -rf ${TMP_DIR}
    exit 1
fi
# 清理测试用的临时配置文件和日志，保留规则文件用于后续替换
rm -f "${TEMP_TEST_CONF}"
rm -f ${TMP_DIR}/test_output.log

# --- 配置文件测试通过后，进行原子性替换 ---
DNS_RULES_FILE="/etc/dnsmasq.d/adss/rules/dnsrules.conf"
HOSTS_RULES_FILE="/etc/dnsmasq.d/adss/rules/hostsrules.conf"

if [ -s "${TMP_DIR}/dnsrules.conf" ] && [ "${TEST_PASSED}" = "1" ]; then
  if ! cmp -s "${TMP_DIR}/dnsrules.conf" "${DNS_RULES_FILE}"; then
    message w "检测到新 DNS 规则......生成新 DNS 规则！"
    # --- 原子性替换: 将经过测试的文件移动到最终位置 ---
    mv -f "${TMP_DIR}/dnsrules.conf" "${DNS_RULES_FILE}"
    DNS_CHANGED=1
  else
    message w "DNS 规则无需更新。"
    rm -f ${TMP_DIR}/dnsrules.conf # 内容无变化，丢弃临时文件
  fi
fi

if [ -s "${TMP_DIR}/hostsrules.conf" ] && [ "$TEST_PASSED" = "1" ]; then
  if ! cmp -s "${TMP_DIR}/hostsrules.conf" "${HOSTS_RULES_FILE}"; then
    message w "检测到新 hosts 规则......生成新 hosts 规则！"
    # --- 原子性替换: 将经过测试的文件移动到最终位置 ---
    mv -f "${TMP_DIR}/hostsrules.conf" "${HOSTS_RULES_FILE}"
    HOSTS_CHANGED=1
  else
    message w "hosts 规则无需更新。"
    rm -f ${TMP_DIR}/hostsrules.conf # 内容无变化，丢弃临时文件
  fi
fi

# 只有在配置文件真正发生变化时才重启服务
if [ "${DNS_CHANGED}" = "1" ] || [ "${HOSTS_CHANGED}" = "1" ]; then
  message w "正在重启 dnsmasq 服务..."
  if /etc/init.d/dnsmasq restart > /dev/null 2>&1; then
    message w "DNS/hosts 应用新规则。"
  else
    message w "错误: dnsmasq 重启失败! 请手动检查。"
    rm -rf ${TMP_DIR}
    exit 1
  fi
fi

rm -rf ${TMP_DIR}
