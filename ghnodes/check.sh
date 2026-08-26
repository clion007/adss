#!/bin/sh
# 测试 ghnodes.ini 中的节点与 GitHub 直连，输出最优的下载前缀
# 输出：GH_PROXY_PREFIX  （直连=""，镜像="https://<node>/"）

GIT_RAW="raw.githubusercontent.com"
NODES_FILE="${TMP_DIR}/ghnodes.ini"
TEST_URL="${GH_RAW_BASE}/${REPO_PATH}/rules/file/hostsrules.conf"
TIMEOUT=3

if [ ! -f "$NODES_FILE" ]; then
    message r "❌ 节点列表文件 $NODES_FILE 不存在，请检查！"
    exit 1
fi

# 读取节点数量（不含直连）用于显示
node_count=$(grep -v '^[[:space:]]*$' "$NODES_FILE" | wc -l | tr -d ' ')
total_candidates=$((node_count + 1))
message w "⏱️  正在测试 $total_candidates 个候选（含 GitHub 直连）..."

tmp_file=$(mktemp)

# 测速单个候选；GitHub 直连作为第一个测试
test_node() {
    local node="$1"
    if [ "${node}" = "${GIT_RAW}" ]; then
        local full_url="${TEST_URL}"
    else
        # 加速镜像为 GitHub 反代，代理前缀拼在完整 raw URL 前面
        local full_url="https://${node}/${TEST_URL}"
    fi
    local start=$(date +%s%N)
    local status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$TIMEOUT" --max-time "$TIMEOUT" "$full_url" 2>/dev/null)
    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))
    if [ "$status" -ge 200 ] && [ "$status" -lt 400 ]; then
        echo "$duration $node"
    else
        echo "999999 $node"
    fi
}

# 直连作为第一个候选
test_node "${GIT_RAW}" >> "$tmp_file" &

# 逐行读取节点，并行测速
while IFS= read -r node || [ -n "$node" ]; do
    # 跳过空行
    [ -z "$node" ] && continue
    test_node "$node" >> "$tmp_file" &
done < "$NODES_FILE"

# 等待所有后台任务完成
wait

# 排序取最快
best=$(sort -n "$tmp_file" | head -1 | awk '{print $2}')
rm -f "$tmp_file"

# 输出 GH_PROXY_PREFIX
if [ "$best" = "${GIT_RAW}" ]; then
    GH_PROXY_PREFIX=""
    message l "✅ 当前最佳下载源: GitHub 直连"
else
    GH_PROXY_PREFIX="https://${best}/"
    message l "✅ 当前最佳下载源: ${GH_PROXY_PREFIX}"
fi
