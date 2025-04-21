#!/bin/sh

# ADSS 日志清理脚本
# 用于清理过期的日志文件

. /lib/functions.sh

# 获取配置
uci_get_by_type() {
    local ret=$(uci get adss.@$1[0].$2 2>/dev/null)
    echo ${ret:=$3}
}

# 主函数
main() {
    # 加载配置
    config_load adss
    
    # 获取日志保留天数
    local keep_days=$(uci_get_by_type basic keep_log_days 7)
    
    # 创建日志目录
    mkdir -p /var/log
    
    # 清理日志
    logger -t "adss" "开始清理${keep_days}天前的日志"
    
    # 清理主日志
    find /var/log/adss*.log -mtime +${keep_days} -exec rm {} \; 2>/dev/null
    
    # 清理更新日志
    find /tmp/adss_*.log -mtime +${keep_days} -exec rm {} \; 2>/dev/null
    
    # 清理网络检测日志
    find /var/log/adss_network.log -mtime +${keep_days} -exec rm {} \; 2>/dev/null
    
    logger -t "adss" "日志清理完成"
}

# 执行主函数
main