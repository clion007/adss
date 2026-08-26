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

TMP_DIR="/tmp/adss"
GITEE_RAW_BASE="https://raw.giteeusercontent.com/clion007/adss/raw/master"
mkdir -p "${TMP_DIR}"

# 加载通用工具函数
if [ -f "utils/utils.sh" ]; then
    . ./utils/utils.sh
else
    curl -sSo "${TMP_DIR}/utils.sh" "${GITEE_RAW_BASE}/utils/utils.sh"
    . "${TMP_DIR}/utils.sh"
fi

# 安装 ADSS
install() {
    show_copyright
    run_remote "installer/install.sh"
}

# 卸载 ADSS
uninstall() {
    show_copyright
    run_remote "installer/uninstall.sh"
}

# 升级 ADSS
upgrade() {
    show_copyright
    . /usr/share/adss/update.sh
}

# 显示 ADSS 当前版本
version() {
	message w "ADSS 当前版本: $(get_version)"
}

# 显示 ADSS 帮助
help() {
    cat <<EOF
ADSS (Auto DNS Smart Script) "$(get_version)"
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