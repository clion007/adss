#!/bin/sh

set -e
mkdir -p /tmp/adss
print w "初始化规则文件"
run_remote "rules/builder/initRulesFile.sh"

print w "获取线上规则文件"
batch_download \
    "rules/file/dnsrules.conf" "/tmp/adss/dnsrules" \
    "rules/file/hostsrules.conf" "/tmp/adss/hostsrules.conf"

# 校验下载的文件是否非空
if [ ! -s /tmp/adss/dnsrules ] || [ ! -s /tmp/adss/hostsrules.conf ]; then
  print w "下载的规则文件为空或损坏!"
  rm -rf /tmp/adss
  exit 1
fi

if ! grep -q "# Modified DNS end" /tmp/adss/dnsrules; then
  print w "下载的 dnsrules 文件不正确!"
  rm -rf /tmp/adss
  exit 1
fi

echo

print w "添加用户定义规则"
cat /etc/dnsmasq.d/adss/rules/userlist > /tmp/adss/userlist
sed -i "/#/d" /tmp/adss/userlist
sed -i '/^\s*$/d' /tmp/adss/userlist

print w "生成用户黑名单规则"
cat /etc/dnsmasq.d/adss/rules/userblacklist > /tmp/adss/blacklist
sed -i "/#/d" /tmp/adss/blacklist
sed -i '/^\s*$/d' /tmp/adss/blacklist
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /tmp/adss/blacklist

print w "合并处理规则"
cat /tmp/adss/blacklist >> /tmp/adss/dnsrules
sed -i '/localhost/d' /tmp/adss/dnsrules
sed -i 's/#.*//g' /tmp/adss/dnsrules
sed -i '/^\s*$/d' /tmp/adss/dnsrules
sed -i '/\/$/d' /tmp/adss/dnsrules

print w "删除用户白名单中包含规则"
cat /etc/dnsmasq.d/adss/rules/userwhitelist | uniq > /tmp/adss/whitelist
sed -i "/#/d" /tmp/adss/whitelist
while read -r line; do
  if [ -n "$line" ]; then
    if [ -s "/tmp/adss/dnsrules" ]; then
      sed -i "\$line/d" /tmp/adss/dnsrules
    fi
    if [ -s "/tmp/adss/hostsrules.conf" ]; then
      sed -i "\$line/d" /tmp/adss/hostsrules.conf
    fi
  fi
done < /tmp/adss/whitelist

print w "生成最终规则文件"
cat /tmp/adss/userlist >> /tmp/adss/dnsrules.conf
rm -f /tmp/adss/userlist
sort -u /tmp/adss/dnsrules >> /tmp/adss/dnsrules.conf
rm -f /tmp/adss/dnsrules
echo "# Modified DNS end" >> /tmp/adss/dnsrules.conf

# --- 核心改进: 配置文件测试 ---
print w "验证新生成的配置文件..."

# 创建一个临时的 dnsmasq 配置文件，用于指向 /tmp/adss 中的规则文件进行测试
TEMP_TEST_CONF="/tmp/adss/dnsmasq_test.conf"
# 清空或创建临时配置文件
> "$TEMP_TEST_CONF"

# 将临时目录下的规则文件路径写入临时测试配置
# 注意：确保这些指令与你的 dnsmasq 版本兼容
# echo "conf-dir=/tmp/adss,*.conf" >> "$TEMP_TEST_CONF" # 让 dnsmasq 读取临时目录下以 .conf 结尾的文件
echo "conf-file=/tmp/adss/dnsrules.conf" >> "$TEMP_TEST_CONF"
echo "addn-hosts=/tmp/adss/hostsrules.conf" >> "$TEMP_TEST_CONF"

# 运行 dnsmasq 测试命令，使用临时配置文件
if dnsmasq --conf-file="$TEMP_TEST_CONF" --test 2>/tmp/adss/test_output.log; then
    print w "配置文件测试通过!"
    TEST_PASSED=1
else
    print w "配置文件测试失败!"
    cat /tmp/adss/test_output.log
    rm -rf /tmp/adss
    exit 1
fi
# 清理测试用的临时配置文件和日志，保留规则文件用于后续替换
rm -f "$TEMP_TEST_CONF"
rm -f /tmp/adss/test_output.log

# --- 配置文件测试通过后，进行原子性替换 ---
DNS_RULES_FILE="/etc/dnsmasq.d/adss/rules/dnsrules.conf"
HOSTS_RULES_FILE="/etc/dnsmasq.d/adss/rules/hostsrules.conf"

if [ -s "/tmp/adss/dnsrules.conf" ] && [ "$TEST_PASSED" = "1" ]; then
  if ! cmp -s /tmp/adss/dnsrules.conf "$DNS_RULES_FILE"; then
    print w "检测到新 DNS 规则......生成新 DNS 规则！"
    # --- 原子性替换: 将经过测试的文件移动到最终位置 ---
    mv -f /tmp/adss/dnsrules.conf "$DNS_RULES_FILE"
    DNS_CHANGED=1
  else
    print w "DNS 规则无需更新。"
    rm -f /tmp/adss/dnsrules.conf # 内容无变化，丢弃临时文件
  fi
fi

if [ -s "/tmp/adss/hostsrules.conf" ] && [ "$TEST_PASSED" = "1" ]; then
  if ! cmp -s /tmp/adss/hostsrules.conf "$HOSTS_RULES_FILE"; then
    print w "检测到新 hosts 规则......生成新 hosts 规则！"
    # --- 原子性替换: 将经过测试的文件移动到最终位置 ---
    mv -f /tmp/adss/hostsrules.conf "$HOSTS_RULES_FILE"
    HOSTS_CHANGED=1
  else
    print w "hosts 规则无需更新。"
    rm -f /tmp/adss/hostsrules.conf # 内容无变化，丢弃临时文件
  fi
fi

# 只有在配置文件真正发生变化时才重启服务
if [ "$DNS_CHANGED" = "1" ] || [ "$HOSTS_CHANGED" = "1" ]; then
  print w "正在重启 dnsmasq 服务..."
  if /etc/init.d/dnsmasq restart > /dev/null 2>&1; then
    print w "DNS/hosts 应用新规则。"
  else
    print w "错误: dnsmasq 重启失败! 请手动检查。"
    rm -rf /tmp/adss
    exit 1
  fi
fi

rm -rf /tmp/adss
