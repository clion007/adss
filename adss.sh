#!/bin/sh
#
# ADSS(Auto DNS Smart Script) V4.3
# Project URL https://github.com/clion007/adss
# Main Module file (CLI entry)
# Copyright © by Clion Nieh Email: clion007@126.com
# Licenses in GPL-3.0
#
# 安装完成后本脚本被链接到 /usr/bin/adss，可在终端直接调用：
#   adss install | uninstall | upgrade | version | help

set -e

mkdir -p /tmp/adss

GH_RAW_BASE="https://raw.githubusercontent.com/clion007/adss/master"

print() {
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

# 获取最佳 Github 加速镜像，并存入 GH_PROXY_PREFIX
get_mirror() {
    print w "获取最佳 Github 加速镜像"
    curl https://raw.giteeusercontent.com/clion007/adss/raw/master/ghnodes/ghnodes.ini -sSo /tmp/adss/ghnodes.ini
    curl https://raw.giteeusercontent.com/clion007/adss/raw/master/ghnodes/check.sh -sSo /tmp/adss/ghcheck.sh
    . /tmp/adss/ghcheck.sh
    clear
}

# 获取版本
get_version() {
    echo "v4.4"
}

# 下载文件
download() {
	local path="$1"
	local destination="$2"	
    curl ${GH_PROXY_PREFIX}/${GH_RAW_BASE}/${path} -sSo "${destination}"
}

# 批量下载多个文件（参数为成对的 源路径 目标路径）
batch_download() {
    while [ $# -ge 2 ]; do
        download "$1" "$2"
        shift 2
    done
}

# 下载并执行仓库内指定脚本（路径相对于仓库根目录）
run_remote() {
    local path="$1"
    local tmp_file="/tmp/adss/$(basename "$path")"
    download "${path}" "${tmp_file}"
    if [ -s "${tmp_file}" ]; then
        . "${tmp_file}"
    else
        print w "`date +'%Y-%m-%d %H:%M:%S'`: 网络异常，退出。"
        exit 1
    fi
}

# 显示版权声明（安装/卸载/升级前展示）
show_copyright() {
    get_mirror
    run_remote "installer/copyright.sh"
}

# 安装
install() {
    print w "即将开始安装配置 ADSS"
    show_copyright
    run_remote "installer/install.sh"
}

# 卸载
uninstall() {
    print w "开始卸载 ADSS"
    show_copyright
    run_remote "installer/uninstall.sh"
}

# 升级（重新拉取并部署最新脚本与配置）
upgrade() {
    print w "开始升级 ADSS"
    show_copyright
    . /usr/share/adss/update.sh
}

# 显示版本
version() {
	print w "ADSS 当前版本: $(get_version)"
}

# 显示帮助
help() {
    cat <<EOF
ADSS (Auto DNS Smart Script) $(get_version)
Project URL https://github.com/clion007/adss

用法:
  adss install         安装 ADSS
  adss uninstall       卸载 ADSS
  adss upgrade         升级 ADSS
  adss version         显示当前版本
  adss help            显示本帮助
EOF
}

main() {
    case "${1:-help}" in
        install)   install ;;
        upgrade)   upgrade ;;
        uninstall) uninstall ;;
        help|-h|--help) help ;;
        version|-v|--version)   version ;;
        *) echo "未知命令: $1"; echo; help; exit 1 ;;
    esac
}

main "$@"
exit 0