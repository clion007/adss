#!/bin/sh

CURRENT_VERSION="4.2"
VERSION_URL="https://api.github.com/repos/clion007/adss/releases/latest"

check_version() {
    local latest_version=$(curl -s $VERSION_URL | jsonfilter -e '@.tag_name' | sed 's/v//')
    if [ -n "$latest_version" ] && [ "$latest_version" != "$CURRENT_VERSION" ]; then
        echo "发现新版本: v$latest_version"
        echo "当前版本: v$CURRENT_VERSION"
        echo "请通过包管理器更新"
        logger -t "adss" "发现新版本: v$latest_version"
        return 0
    fi
    return 1
}

check_version