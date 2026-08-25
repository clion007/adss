#!/bin/sh
# 从上游的 nodes.ts 提取节点域名列表
# 保存到 files/etc/adss/ghnodes.ini

set -e

# 上游原始文件地址（优先直接访问 GitHub raw，若失败则使用镜像）
NODES_URL="https://raw.githubusercontent.com/hubporg/ghproxy-next/refs/heads/main/components/nodes.ts"

OUTPUT_FILE="files/etc/adss/ghnodes.ini"

echo "🔄 正在获取 nodes.ts ..."

# 尝试直接下载，若失败则使用镜像
content=$(curl -sL --connect-timeout 10 "$NODES_URL" 2>/dev/null)

if [[ -z "$content" ]]; then
    echo "❌ 无法获取 nodes.ts，请检查网络或上游地址"
    exit 1
fi

# 提取所有 value: "域名" 并去重
echo "$content" | grep -oE 'value:\s*"[^"]+"' | sed 's/value:\s*"\([^"]*\)"/\1/' | sort -u > "$OUTPUT_FILE"

count=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
echo "✅ 成功提取 $count 个节点，已保存到 $OUTPUT_FILE"