#!/bin/sh

# 记录日志
log() {
    logger -t "adss" "$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> /var/log/adss_network.log
}

# 检查网络连接
check_network() {
    local retry=3
    local success=0
    
    # 尝试多个网站 - 修正数组语法
    local sites="www.baidu.com www.qq.com www.163.com"
    
    for site in $sites; do
        for i in $(seq 1 $retry); do
            if ping -c 1 -W 3 $site >/dev/null 2>&1; then
                success=1
                break
            fi
            sleep 1
        done
        
        if [ $success -eq 1 ]; then
            break
        fi
    done
    
    return $success
}

# 重启网络
restart_network() {
    log "网络连接失败，尝试重启网络..."
    
    # 尝试重启网络接口
    ifdown wan
    sleep 2
    ifup wan
    
    log "网络接口已重启"
    
    # 等待网络恢复
    sleep 10
    
    # 再次检查网络
    if check_network; then
        log "网络已恢复"
    else
        log "网络仍然不可用，可能需要手动干预"
    fi
}

# 主函数
main() {
    # 检查网络
    if ! check_network; then
        restart_network
    fi
}

# 执行主函数
main