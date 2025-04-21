#!/bin/sh
VERSION_URL="https://api.github.com/repos/clion007/adss/releases/latest"
BACKUP_URL="https://gitee.com/api/v5/repos/clion007/adss/releases/latest"

LOG_FILE="/var/log/adss_check_update.log"

# 记录日志
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOG_FILE
    logger -t "adss" "$1"
}

# 获取版本信息
get_version() {
    # 尝试从version.sh获取版本
    if [ -f "/usr/share/adss/version.sh" ]; then
        local version_info=$(sh /usr/share/adss/version.sh)
        local version=$(echo "$version_info" | grep -o "版本: [0-9.]*" | grep -o "[0-9.]*")
        if [ -n "$version" ]; then
            echo "$version"
            return
        fi
    fi
    
    # 使用默认版本
    echo "$CURRENT_VERSION"
}

# 检查更新
check_update() {
    log "开始检查ADSS更新"
    
    # 获取当前版本
    local current_version=$(get_version)
    log "当前版本: $current_version"
    
    # 尝试从GitHub获取最新版本
    local latest_version=""
    local release_info=""
    
    # 尝试GitHub API
    release_info=$(curl -s --connect-timeout 10 --retry 3 $VERSION_URL)
    latest_version=$(echo "$release_info" | grep -o '"tag_name": "v[0-9.]*"' | grep -o '[0-9.]*')
    
    # 如果GitHub失败，尝试Gitee
    if [ -z "$latest_version" ]; then
        log "从GitHub获取版本信息失败，尝试Gitee"
        release_info=$(curl -s --connect-timeout 10 --retry 3 $BACKUP_URL)
        latest_version=$(echo "$release_info" | grep -o '"tag_name": "v[0-9.]*"' | grep -o '[0-9.]*')
    fi
    
    # 检查是否获取到版本信息
    if [ -z "$latest_version" ]; then
        log "获取最新版本信息失败"
        echo "获取最新版本信息失败，请检查网络连接或稍后再试。"
        return 1
    fi
    
    log "最新版本: $latest_version"
    
    # 比较版本
    if [ "$latest_version" != "$current_version" ]; then
        log "发现新版本: $latest_version"
        echo "发现新版本: v$latest_version"
        echo "当前版本: v$current_version"
        echo "可以通过以下方式更新:"
        echo "1. 使用包管理器更新: opkg update && opkg upgrade adss"
        echo "2. 运行命令: /usr/share/adss/online_upgrade.sh"
        
        # 提取更新日志
        local changelog=$(echo "$release_info" | grep -o '"body": ".*"' | sed 's/"body": "\(.*\)"/\1/' | sed 's/\\r\\n/\n/g' | sed 's/\\n/\n/g')
        if [ -n "$changelog" ]; then
            echo -e "\n更新日志:\n$changelog"
        fi
        
        return 0
    else
        log "当前已是最新版本: $current_version"
        echo "当前已是最新版本: v$current_version"
        return 0
    fi
}

# 执行检查
check_update > /tmp/adss_check_update.log