#!/bin/sh

# 导入版本信息
. /usr/share/adss/version.sh
CURRENT_VERSION=$(get_version)

REPO_OWNER="clion007"
REPO_NAME="adss"
TEMP_DIR="/tmp/adss_upgrade"
GITHUB_API="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
GITEE_API="https://gitee.com/api/v5/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"

# 创建临时目录
mkdir -p ${TEMP_DIR}

# 检查网络连接
check_network() {
    curl -s --connect-timeout 5 https://www.baidu.com > /dev/null
    if [ $? -ne 0 ]; then
        echo "网络连接失败，请检查网络设置"
        return 1
    fi
    return 0
}

# 获取最新版本信息
get_latest_version() {
    # 优先尝试GitHub API
    local github_info=$(curl -s ${GITHUB_API})
    local latest_version=$(echo "$github_info" | jsonfilter -e '@.tag_name' | sed 's/v//')
    
    # 如果GitHub API失败，尝试Gitee API
    if [ -z "$latest_version" ]; then
        local gitee_info=$(curl -s ${GITEE_API})
        latest_version=$(echo "$gitee_info" | jsonfilter -e '@.tag_name' | sed 's/v//')
    fi
    
    echo "$latest_version"
}

# 下载最新版本
download_latest() {
    local version=$1
    local download_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/v${version}.tar.gz"
    local backup_url="https://gitee.com/${REPO_OWNER}/${REPO_NAME}/repository/archive/v${version}.tar.gz"
    
    echo "正在下载 ADSS v${version}..."
    
    # 尝试从GitHub下载
    curl -L ${download_url} -o ${TEMP_DIR}/adss.tar.gz
    
    # 如果GitHub下载失败，尝试从Gitee下载
    if [ ! -s "${TEMP_DIR}/adss.tar.gz" ]; then
        echo "从GitHub下载失败，尝试从Gitee下载..."
        curl -L ${backup_url} -o ${TEMP_DIR}/adss.tar.gz
    fi
    
    # 检查下载是否成功
    if [ ! -s "${TEMP_DIR}/adss.tar.gz" ]; then
        echo "下载失败，请稍后重试"
        return 1
    fi
    
    return 0
}

# 安装新版本
install_new_version() {
    local version=$1
    
    echo "正在安装 ADSS v${version}..."
    
    # 解压文件
    tar -xzf ${TEMP_DIR}/adss.tar.gz -C ${TEMP_DIR}
    
    # 找到解压后的目录
    local extract_dir=$(find ${TEMP_DIR} -maxdepth 1 -type d -name "*${REPO_NAME}*" | head -n 1)
    
    if [ -z "$extract_dir" ]; then
        echo "解压失败，无法找到有效的安装文件"
        return 1
    fi
    
    # 备份配置文件
    cp -f /etc/config/adss /tmp/adss_config_backup
    
    # 安装文件
    cp -rf ${extract_dir}/app-adss/files/* /usr/share/adss/
    
    # 检查updater目录是否存在
    if [ -d "${extract_dir}/updater" ]; then
        cp -rf ${extract_dir}/updater/* /usr/share/adss/
    else
        echo "警告: updater目录不存在，跳过复制"
    fi
    
    # 更新LuCI界面
    if [ -d "/usr/lib/lua/luci/model/cbi/adss" ]; then
        if [ -d "${extract_dir}/luci-app-adss/luasrc/model/cbi/adss" ]; then
            cp -rf ${extract_dir}/luci-app-adss/luasrc/model/cbi/adss/* /usr/lib/lua/luci/model/cbi/adss/
        fi
        
        if [ -d "${extract_dir}/luci-app-adss/luasrc/controller" ]; then
            cp -rf ${extract_dir}/luci-app-adss/luasrc/controller/* /usr/lib/lua/luci/controller/
        fi
        
        if [ -d "${extract_dir}/luci-app-adss/htdocs" ]; then
            cp -rf ${extract_dir}/luci-app-adss/htdocs/* /www/
        fi
    fi
    
    # 恢复配置文件
    cp -f /tmp/adss_config_backup /etc/config/adss
    
    # 设置权限
    chmod -R 755 /usr/share/adss
    
    # 更新版本信息
    update_version_info ${version}
    
    # 重启服务
    /etc/init.d/adss restart
    
    echo "ADSS 已成功升级到 v${version}"
    return 0
}

# 更新版本信息
update_version_info() {
    local version=$1
    
    # 检查version.sh是否存在
    if [ -f "/usr/share/adss/version.sh" ]; then
        # 更新version.sh中的版本号
        sed -i "s/ADSS_VERSION=\".*\"/ADSS_VERSION=\"${version}\"/" /usr/share/adss/version.sh
        sed -i "s/ADSS_RELEASE_DATE=\".*\"/ADSS_RELEASE_DATE=\"$(date +%Y-%m-%d)\"/" /usr/share/adss/version.sh
    else
        # 创建version.sh文件
        cat > /usr/share/adss/version.sh << EOF
#!/bin/sh

# 集中管理版本信息
ADSS_VERSION="${version}"
ADSS_RELEASE_DATE="$(date +%Y-%m-%d)"
ADSS_AUTHOR="clion007"
ADSS_REPO="https://github.com/clion007/adss"

# 导出版本信息函数
get_version() {
    echo "\$ADSS_VERSION"
}

get_release_date() {
    echo "\$ADSS_RELEASE_DATE"
}
EOF
        chmod 755 /usr/share/adss/version.sh
    fi
    
    # 兼容旧版本的check_update.sh
    if [ -f "/usr/share/adss/check_update.sh" ]; then
        sed -i "s/CURRENT_VERSION=\".*\"/CURRENT_VERSION=\"${version}\"/" /usr/share/adss/check_update.sh
    fi
    
    # 更新logo文件中的版本号
    if [ -f "/usr/share/adss/logo" ]; then
        sed -i "s/V [0-9.]\+/V ${version}/" /usr/share/adss/logo
    fi
    
    echo "版本信息已更新为 v${version}"
    return 0
}

# ADSS 在线升级脚本
# 用于在线升级ADSS到最新版本

LOG_FILE="/var/log/adss_upgrade.log"

# 记录日志
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOG_FILE
    logger -t "adss" "$1"
}

# 主函数
main() {
    log "开始在线升级ADSS"
    
    # 检查opkg是否可用
    if ! command -v opkg >/dev/null 2>&1; then
        log "错误: opkg命令不可用，无法进行在线升级"
        echo "错误: opkg命令不可用，无法进行在线升级"
        return 1
    fi
    
    # 更新软件源
    log "更新软件源"
    echo "更新软件源..."
    opkg update
    
    # 检查是否有更新
    log "检查ADSS更新"
    echo "检查ADSS更新..."
    local upgrade_info=$(opkg list-upgradable | grep "adss -")
    
    if [ -n "$upgrade_info" ]; then
        # 有更新可用
        log "发现ADSS更新: $upgrade_info"
        echo "发现ADSS更新: $upgrade_info"
        
        # 升级ADSS
        log "开始升级ADSS"
        echo "开始升级ADSS..."
        opkg upgrade adss
        
        # 检查升级结果
        if [ $? -eq 0 ]; then
            log "ADSS升级成功"
            echo "ADSS升级成功！"
            
            # 重启服务
            log "重启ADSS服务"
            echo "重启ADSS服务..."
            /etc/init.d/adss restart
            
            return 0
        else
            log "ADSS升级失败"
            echo "ADSS升级失败，请查看日志或手动升级。"
            return 1
        fi
    else
        # 没有更新可用
        log "ADSS已是最新版本"
        echo "ADSS已是最新版本，无需升级。"
        return 0
    fi
}

# 执行主函数
main > /tmp/adss_upgrade.log
    
    # 检查网络
    check_network
    if [ $? -ne 0 ]; then
        rm -rf ${TEMP_DIR}
        return 1
    fi
    
    # 获取最新版本
    local latest_version=$(get_latest_version)
    
    if [ -z "$latest_version" ]; then
        echo "无法获取最新版本信息"
        rm -rf ${TEMP_DIR}
        return 1
    fi
    
    # 比较版本
    if [ "$latest_version" = "$CURRENT_VERSION" ]; then
        echo "当前已是最新版本 v${CURRENT_VERSION}"
        rm -rf ${TEMP_DIR}
        return 0
    fi
    
    echo "发现新版本: v${latest_version}"
    echo "当前版本: v${CURRENT_VERSION}"
    
    # 下载最新版本
    download_latest ${latest_version}
    if [ $? -ne 0 ]; then
        rm -rf ${TEMP_DIR}
        return 1
    fi
    
    # 安装新版本
    install_new_version ${latest_version}
    local result=$?
    
    # 清理临时文件
    rm -rf ${TEMP_DIR}
    
    return ${result}
}

# 执行主函数
main