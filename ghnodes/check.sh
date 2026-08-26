#!/bin/sh
# 测试 ghnodes.ini 中的节点，输出最优节点

set -e

NODES_FILE="${TMP_DIR}/ghnodes.ini"
TEST_URL="${GH_RAW_BASE}/rules/file/hostsrules.conf"
TIMEOUT=3

if [ ! -f "$NODES_FILE" ]; then
    message r "❌ 节点列表文件 $NODES_FILE 不存在，请检查！"
    exit 1
fi

# 读取节点数量用于显示
node_count=$(grep -v '^[[:space:]]*$' "$NODES_FILE" | wc -l | tr -d ' ')
if [ "$node_count" -eq 0 ]; then
    message r "❌ 节点列表为空"
    exit 1
fi

message w "⏱️  正在测试 $node_count 个节点..."

tmp_file=$(mktemp)

test_node() {
    local node="$1"
    local full_url="https://${node}${TEST_URL}"
    local start=$(date +%s%N)
    local status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$TIMEOUT" --max-time "$TIMEOUT" "$full_url" 2>/dev/null)
    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))
    if [[ "$status" -ge 200 && "$status" -lt 400 ]]; then
        echo "$duration $node"
    else
        echo "999999 $node"
    fi
}

# 逐行读取节点，并行测速（不使用数组）
while IFS= read -r node || [ -n "$node" ]; do
    # 跳过空行
    [ -z "$node" ] && continue
    test_node "$node" >> "$tmp_file" &
done < "$NODES_FILE"

# 等待所有后台任务完成
wait

# 排序取最快
best=$(sort -n "$tmp_file" | head -1 | awk '{message $2}')
rm -f "$tmp_file"

# ---------- 输出 ---------
if [ -n "$best" ]; then
    message w "最优节点: $best"
    message w "完整前缀: https://${best}"
    GH_PROXY_PREFIX="https://${best}/"
else
    message r "❌ 所有节点均不可用"
    exit 1
fi
