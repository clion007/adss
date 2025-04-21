#!/bin/sh

# 导入版本信息
. /usr/share/adss/version.sh
CURRENT_VERSION=$(get_version)

REPO_OWNER="clion007"
REPO_NAME="adss"
TEMP_DIR="/tmp/adss_upgrade"
GITHUB_API="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
GITHUB_RELEASE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download"
# 使用 GitHub Pages 或 GitHub Actions 构建的 CDN 作为备用源
GITHUB_CDN_URL="https://cdn.jsdelivr.net/gh/${REPO_OWNER}/${REPO_NAME}@latest/releases"

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
    # 尝试GitHub API
    local github_info=$(curl -s --connect-timeout 10 --retry 3 ${GITHUB_API})
    local latest_version=$(echo "$github_info" | jsonfilter -e '@.tag_name' | sed 's/v//')
    
    # 保存发布信息以便后续使用
    if [ -n "$github_info" ]; then
        echo "$github_info" > ${TEMP_DIR}/release_info.json
    fi
    
    echo "$latest_version"
}

# 获取适合当前系统的IPK包名
get_ipk_filename() {
    local version=$1
    local arch=$(uname -m)
    local ipk_name=""
    
    # 根据架构确定合适的包名
    case "$arch" in
        "x86_64")
            ipk_name="adss_${version}_x86_64.ipk"
            ;;
        "i686"|"i386")
            ipk_name="adss_${version}_x86.ipk"
            ;;
        "aarch64"|"arm64")
            ipk_name="adss_${version}_aarch64_generic.ipk"
            ;;
        "armv7l"|"armv7"*)
            ipk_name="adss_${version}_arm_cortex-a7.ipk"
            ;;
        "mips")
            ipk_name="adss_${version}_mips_24kc.ipk"
            ;;
        *)
            # 默认使用通用包
            ipk_name="adss_${version}_all.ipk"
            ;;
    esac
    
    echo "$ipk_name"
}

# 下载IPK软件包
download_ipk() {
    local version=$1
    local ipk_name=$(get_ipk_filename $version)
    local output_file="${TEMP_DIR}/${ipk_name}"
    
    echo "正在下载 ADSS v${version} 软件包..."
    
    # 从GitHub Releases下载
    local download_url="${GITHUB_RELEASE_URL}/v${version}/${ipk_name}"
    curl -L --connect-timeout 10 --retry 3 ${download_url} -o ${output_file}
    
    # 如果GitHub Releases下载失败，尝试从CDN下载
    if [ ! -s "${output_file}" ]; then
        echo "从GitHub Releases下载失败，尝试从CDN下载..."
        local cdn_url="${GITHUB_CDN_URL}/${ipk_name}"
        curl -L --connect-timeout 10 --retry 3 ${cdn_url} -o ${output_file}
    fi
    
    # 检查下载是否成功
    if [ ! -s "${output_file}" ]; then
        echo "IPK软件包下载失败，尝试使用源码方式更新..."
        return 1
    fi
    
    echo "IPK软件包下载成功: ${ipk_name}"
    return 0
}

# 使用IPK安装
install_ipk() {
    local version=$1
    local ipk_name=$(get_ipk_filename $version)
    local ipk_file="${TEMP_DIR}/${ipk_name}"
    
    echo "正在安装 ADSS v${version} 软件包..."
    
    # 使用opkg安装IPK
    opkg install ${ipk_file}
    
    # 检查安装结果
    if [ $? -ne 0 ]; then
        echo "IPK安装失败，尝试使用源码方式更新..."
        return 1
    fi
    
    echo "ADSS 已成功升级到 v${version}"
    return 0
}

# 下载最新版本源码（备用方案）
download_source() {
    local version=$1
    local download_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/v${version}.tar.gz"
    
    echo "正在下载 ADSS v${version} 源码..."
    
    # 尝试从GitHub下载
    curl -L --connect-timeout 10 --retry 3 ${download_url} -o ${TEMP_DIR}/adss.tar.gz
    
    # 检查下载是否成功
    if [ ! -s "${TEMP_DIR}/adss.tar.gz" ]; then
        echo "源码下载失败，请稍后重试"
        return 1
    fi
    
    return 0
}

# 从源码安装（备用方案）
install_from_source() {
    local version=$1
    
    echo "正在从源码安装 ADSS v${version}..."
    
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
    
    echo "ADSS 已成功从源码升级到 v${version}"
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
    
    # 检查网络
    check_network
    if [ $? -ne 0 ]; then
        log "网络连接失败，请检查网络设置"
        rm -rf ${TEMP_DIR}
        return 1
    fi
    
    # 获取最新版本
    local latest_version=$(get_latest_version)
    
    if [ -z "$latest_version" ]; then
        log "无法获取最新版本信息"
        echo "无法获取最新版本信息"
        rm -rf ${TEMP_DIR}
        return 1
    fi
    
    # 比较版本
    if [ "$latest_version" = "$CURRENT_VERSION" ]; then
        log "当前已是最新版本 v${CURRENT_VERSION}"
        echo "当前已是最新版本 v${CURRENT_VERSION}"
        rm -rf ${TEMP_DIR}
        return 0
    fi
    
    log "发现新版本: v${latest_version}"
    echo "发现新版本: v${latest_version}"
    echo "当前版本: v${CURRENT_VERSION}"
    
    # 尝试下载并安装IPK
    download_ipk ${latest_version}
    if [ $? -eq 0 ]; then
        install_ipk ${latest_version}
        if [ $? -eq 0 ]; then
            log "通过IPK安装成功"
            rm -rf ${TEMP_DIR}
            return 0
        fi
    fi
    
    # IPK安装失败，尝试源码安装
    log "IPK安装失败，尝试源码安装"
    echo "IPK安装失败，尝试源码安装..."
    
    download_source ${latest_version}
    if [ $? -ne 0 ]; then
        log "源码下载失败"
        echo "源码下载失败，升级终止"
        rm -rf ${TEMP_DIR}
        return 1
    fi
    
    install_from_source ${latest_version}
    local result=$?
    
    # 清理临时文件
    rm -rf ${TEMP_DIR}
    
    return ${result}
}

# 执行主函数
main