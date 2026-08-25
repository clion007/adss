#!/bin/bash
# 测试本地 ghnodes.ini 中的节点，输出最优节点
# 用法：. check.sh

set -e

NODES_FILE="ghnodes.ini"
TEST_URL="https://raw.githubusercontent.com/clion007/adss/master/rules/file/hostsrules.conf"
TIMEOUT=3

if [[ ! -f "$NODES_FILE" ]]; then
    echo "❌ 节点列表文件 $NODES_FILE 不存在，请先运行 fetch_nodes.sh"
    exit 1
fi

# 读取节点数量用于显示
node_count=$(grep -v '^[[:space:]]*$' "$NODES_FILE" | wc -l | tr -d ' ')
if [[ "$node_count" -eq 0 ]]; then
    echo "❌ 节点列表为空"
    exit 1
fi

echo "⏱️  正在测试 $node_count 个节点..."

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
while IFS= read -r node || [[ -n "$node" ]]; do
    # 跳过空行
    [[ -z "$node" ]] && continue
    test_node "$node" >> "$tmp_file" &
done < "$NODES_FILE"

# 等待所有后台任务完成
wait

# 排序取最快
best=$(sort -n "$tmp_file" | head -1 | awk '{print $2}')
rm -f "$tmp_file"

# ---------- 输出 ---------
if [[ -n "$best" ]]; then
    export GH_PROXY_PREFIX="https://${best}/"    # 导出为环境变量，方便其他脚本使用
    echo "最优节点: $best"
    echo "完整前缀: https://${best}/"
else
    echo "❌ 所有节点均不可用"
    exit 1
fi-