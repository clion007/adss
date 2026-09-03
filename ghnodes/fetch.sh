#!/bin/sh
# 从上游的 nodes.ts 提取节点域名列表
# 保存到 ghnodes/ghnodes.ini

set -e

# 上游节点原始文件地址
NODES_URL="https://raw.githubusercontent.com/hubporg/ghproxy-next/refs/heads/main/components/nodes.ts"

OUTPUT_FILE="ghnodes/ghnodes.ini"

echo "🔄 正在获取 nodes.ts ..."

content=$(curl -sL --connect-timeout 10 "$NODES_URL" 2>/dev/null)

if [ -z "$content" ]; then
    message r "❌ 无法获取 nodes.ts，请检查网络或上游地址"
    exit 1
fi

# 提取所有 value: "域名" 并去重
echo "$content" | grep -oE 'value:\s*"[^"]+"' | sed 's/value:\s*"\([^"]*\)"/\1/' | sort -u > "$OUTPUT_FILE"

count=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
message g "✅ 成功提取 $count 个节点，已保存到 $OUTPUT_FILE"
