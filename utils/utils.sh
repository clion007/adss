#!/bin/sh
# ADSS 通用工具函数包

# 定义 ADSS 基本常量
GH_RAW_BASE="https://raw.githubusercontent.com"
REPO_PATH="clion007/adss/master"

# 打印消息（参数: 颜色 格式化字符串）——输出到 stderr，避免污染 stdout 返回值
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
  echo -e "${Color}${2}\e[0m" >&2
  echo >&2
}

# 选取最快的下载源（GitHub 直连 + 各加速镜像），结果存入 GH_PROXY_PREFIX
# 结果缓存：MIRROR_PREFIX 文件跨进程/子 shell 共享，只测速一次
get_mirror() {
    MIRROR_READY="${MIRROR_READY:-}"
    [ -n "$MIRROR_READY" ] && return 0
    MIRROR_READY=1
    message w "获取最佳下载源（GitHub 直连 + 加速镜像）"
    curl "${GITEE_RAW_BASE}/ghnodes/ghnodes.ini" -sSo ${TMP_DIR}/ghnodes.ini
    curl "${GITEE_RAW_BASE}/ghnodes/check.sh" -sSo ${TMP_DIR}/ghcheck.sh
    . ${TMP_DIR}/ghcheck.sh
}

# Get best file download URL (args: repo-relative path or full URL)
# Repo-relative path: built against this repo; GitHub raw URL: via mirror prefix; other URLs: direct
get_file_url() {
    local src="$1"
    get_mirror
    case "$src" in
        "${GH_RAW_BASE}"/*) SRC_URL="${GH_PROXY_PREFIX}${src}" ;;
        http://*|https://*) SRC_URL="${src}" ;;
        *) SRC_URL="${GH_PROXY_PREFIX}${GH_RAW_BASE}/${REPO_PATH}/${src}" ;;
    esac
}

# 获取版本
get_version() {
    echo "v4.4"
}

# 下载文件（参数: 源路径 目标路径）
# 统一走最快下载源（直连 或 加速镜像）
download() {
    local path="$1"
    local dest="$2"
    get_file_url "${path}"
    curl -sSf -o "${dest}" "${SRC_URL}" || {
        message r "`date +'%Y-%m-%d %H:%M:%S'`: 下载 ${path} 失败，网络异常。"
        rm -f "${dest}"   # 清除下载失败残留的 0 字节文件
        return 1
    }
}

# 批量下载多个文件（参数为成对的 源路径/URL 目标路径）
batch_download() {
    while [ $# -ge 2 ]; do
        download "$1" "$2" || return 1
        shift 2
    done
}

# 下载并执行仓库内指定脚本（路径相对于仓库根目录）
run_remote() {
    local path="$1"
    local tmp_file="${TMP_DIR}/$(basename "$path")"
    download "${path}" "${tmp_file}" || return 1
    . "${tmp_file}"
}

# 显示版权声明（安装/卸载/升级前展示）
show_copyright() {
    run_remote "installer/copyright.sh"
}
