#!/bin/sh
# ADSS 通用工具函数包

# 定义 ADSS 基本常量
GH_RAW_BASE="https://raw.githubusercontent.com"
REPO_PATH="clion007/adss/master"

# 打印消息（参数: 颜色 格式化字符串）
message() {
  case $1 in
    r) Color="\e[31m";;
    g) Color="\e[32m";;
    b) Color="\e[34m";;
    y) Color="\e[33m";;
    z) Color="\e[35m";;
    l) Color="\e[36m";;
    w) Color="\e[37m";;
  esac
  echo -e "${Color}${2}\e[0m"
  echo
}

# 检测 URL 是否可访问（HTTP 状态码 2xx/3xx）
# 用法：check_url URL [超时秒数]
check_url() {
    url="$1"
    timeout="${2:-5}"   # 默认 5 秒

    # 发送 HEAD 请求，跟随重定向，只获取状态码
    code=$(curl -sL -o /dev/null -w "%{http_code}" \
        --connect-timeout "$timeout" --max-time "$timeout" "$url")

    # 状态码 200~399 表示可用
    if [ "$code" -ge 200 ] && [ "$code" -lt 400 ]; then
        return 1
    else
        return 0
    fi
}

# 获取最佳 Github 加速镜像，并存入 GH_PROXY_PREFIX
get_mirror() {
    message w "获取最佳 Github 加速镜像"
    curl "${GITEE_RAW_BASE}/ghnodes/ghnodes.ini" -sSo ${TMP_DIR}/ghnodes.ini
    curl "${GITEE_RAW_BASE}/ghnodes/check.sh" -sSo ${TMP_DIR}/ghcheck.sh
    . ${TMP_DIR}/ghcheck.sh
}

# 获取镜像源文件 URL（参数: 源路径）
get_mirror_url() {
    local path="$1"
    if [ -z "$GH_PROXY_PREFIX" ]; then
        get_mirror
    fi
    echo "${GH_PROXY_PREFIX}/${GH_RAW_BASE}/${REPO_PATH}/${path}"
}

# 获取版本
get_version() {
    echo "v4.4"
}

# 下载文件（参数: 源路径 目标路径）
download() {
    local path="$1"
    if check_url "${GH_RAW_BASE}"; then
        source="${GH_RAW_BASE}/${REPO_PATH}/${path}"
    else
        source=$(get_mirror_url "${path}")
    fi
    curl -sSo $2 ${source}
}

# 批量下载多个文件（参数为成对的 源路径/URL 目标路径）
batch_download() {
    while [ $# -ge 2 ]; do
        download "$1" "$2"
        shift 2
    done
}

# 下载并执行仓库内指定脚本（路径相对于仓库根目录）
run_remote() {
    local path="$1"
    local tmp_file="${TMP_DIR}/$(basename "$path")"
    download "${path}" "${tmp_file}"
    if [ -s "${tmp_file}" ]; then
        . "${tmp_file}"
    else
        message w "`date +'%Y-%m-%d %H:%M:%S'`: 网络异常，退出。"
        exit 1
    fi
}

# 显示版权声明（安装/卸载/升级前展示）
show_copyright() {
    run_remote "installer/copyright.sh"
}
