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
LOG_FILE="/var/log/adss_upgrade.log"

# 记录日志
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOG_FILE
    logger -t "adss" "$1"
}

# 创建临时目录
mkdir -p ${TEMP_DIR}

# 检查网络连接
check_network() {
    curl -s --connect-timeout 5 https://www.baidu.com > /dev/null
    if [ $? -ne 0 ]; then
        log "网络连接失败"
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
    
    # 如果GitHub API失败，尝试备用方法
    if [ -z "$latest_version" ]; then
        log "从GitHub获取版本信息失败，尝试备用源"
        # 尝试从GitHub Pages获取版本信息
        local version_info=$(curl -s --connect-timeout 10 --retry 3 "https://${REPO_OWNER}.github.io/${REPO_NAME}/version.json")
        latest_version=$(echo "$version_info" | jsonfilter -e '@.version' 2>/dev/null)
    fi
    
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

# 下载IPK包
download_ipk() {
    local version=$1
    local ipk_name=$(get_ipk_filename $version)
    local output_file="${TEMP_DIR}/${ipk_name}"
    
    log "下载IPK包: ${ipk_name}"
    echo "下载IPK包: ${ipk_name}"
    
    # 尝试从GitHub Release下载
    curl -L --connect-timeout 10 --retry 3 "${GITHUB_RELEASE_URL}/v${version}/${ipk_name}" -o ${output_file}
    
    # 如果下载失败，尝试从CDN下载
    if [ ! -s "${output_file}" ]; then
        log "从GitHub下载失败，尝试CDN"
        local cdn_url="${GITHUB_CDN_URL}/${ipk_name}"
        curl -L --connect-timeout 10 --retry 3 ${cdn_url} -o ${output_file}
    fi
    
    # 检查下载是否成功
    if [ ! -s "${output_file}" ]; then
        log "IPK软件包下载失败"
        echo "IPK软件包下载失败，尝试使用源码方式更新..."
        return 1
    fi
    
    # 下载luci包
    local luci_ipk_name="luci-app-adss_${version}_all.ipk"
    local luci_output_file="${TEMP_DIR}/${luci_ipk_name}"
    
    log "下载LuCI包: ${luci_ipk_name}"
    echo "下载LuCI包: ${luci_ipk_name}"
    
    curl -L --connect-timeout 10 --retry 3 "${GITHUB_RELEASE_URL}/v${version}/${luci_ipk_name}" -o ${luci_output_file}
    
    # 如果下载失败，尝试从CDN下载
    if [ ! -s "${luci_output_file}" ]; then
        log "从GitHub下载LuCI包失败，尝试CDN"
        local luci_cdn_url="${GITHUB_CDN_URL}/${luci_ipk_name}"
        curl -L --connect-timeout 10 --retry 3 ${luci_cdn_url} -o ${luci_output_file}
    fi
    
    log "IPK软件包下载成功"
    echo "IPK软件包下载成功"
    return 0
}

# 使用IPK安装
install_ipk() {
    local version=$1
    local ipk_name=$(get_ipk_filename $version)
    local ipk_file="${TEMP_DIR}/${ipk_name}"
    local luci_ipk_name="luci-app-adss_${version}_all.ipk"
    local luci_ipk_file="${TEMP_DIR}/${luci_ipk_name}"
    
    log "安装IPK包: ${ipk_name}"
    echo "正在安装 ADSS v${version} 软件包..."
    
    # 使用opkg安装IPK
    opkg install ${ipk_file}
    local result=$?
    
    # 如果luci包存在，也安装它
    if [ -f "$luci_ipk_file" ]; then
        log "安装LuCI包: ${luci_ipk_name}"
        opkg install ${luci_ipk_file}
    fi
    
    # 检查安装结果
    if [ $result -ne 0 ]; then
        log "IPK安装失败"
        echo "IPK安装失败，尝试使用源码方式更新..."
        return 1
    fi
    
    log "ADSS 已成功升级到 v${version}"
    echo "ADSS 已成功升级到 v${version}"
    return 0
}

# 主函数
main() {
    # 检查网络连接
    check_network
    if [ $? -ne 0 ]; then
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
        log "当前已是最新版本: v${CURRENT_VERSION}"
        echo "当前已是最新版本: v${CURRENT_VERSION}"
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
    
    # 清理临时文件
    rm -rf ${TEMP_DIR}
    
    log "升级失败"
    echo "升级失败，请稍后再试或手动安装"
    return 1
}

# 执行主函数
main > /tmp/adss_upgrade.log 2>&1