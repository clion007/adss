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
# 仅测速一次并由 MIRROR_READY 缓存；直连时 GH_PROXY_PREFIX 为空字符串
get_mirror() {
    MIRROR_READY="${MIRROR_READY:-}"
    [ -n "$MIRROR_READY" ] && return 0
    MIRROR_READY=1
    message w "获取最佳下载源（GitHub 直连 + 加速镜像）"
    curl "${GITEE_RAW_BASE}/ghnodes/ghnodes.ini" -sSo ${TMP_DIR}/ghnodes.ini
    curl "${GITEE_RAW_BASE}/ghnodes/check.sh" -sSo ${TMP_DIR}/ghcheck.sh
    . ${TMP_DIR}/ghcheck.sh
}

# 获取最佳文件下载 URL（参数: 源路径）
# 直连时 GH_PROXY_PREFIX 为空字符串
get_file_url() {
    local path="$1"
    get_mirror
    echo "${GH_PROXY_PREFIX}${GH_RAW_BASE}/${REPO_PATH}/${path}"
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
    curl -sSo "${dest}" "$(get_file_url "${path}")"
    if [ ! -s "${dest}" ]; then
        message r "`date +'%Y-%m-%d %H:%M:%S'`: 下载 ${path} 失败，网络异常。"
        return 1
    fi
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
        message r "`date +'%Y-%m-%d %H:%M:%S'`: 网络异常，退出。"
        exit 1
    fi
}

# 显示版权声明（安装/卸载/升级前展示）
show_copyright() {
    clear
    run_remote "installer/copyright.sh"
}
