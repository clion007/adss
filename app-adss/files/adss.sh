#!/bin/sh

# ADSS 主服务脚本
# 用于初始化和配置 ADSS 服务

. /lib/functions.sh

ADSS_DIR="/etc/dnsmasq.d/adss"
RULES_DIR="$ADSS_DIR/rules"
LOG_FILE="/var/log/adss.log"

# 记录日志
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOG_FILE
    logger -t "adss" "$1"
}

# 获取配置
uci_get_by_type() {
    local ret=$(uci get adss.@$1[0].$2 2>/dev/null)
    echo ${ret:=$3}
}

# 初始化目录
init_dirs() {
    mkdir -p $ADSS_DIR
    mkdir -p $RULES_DIR
    mkdir -p /usr/share/adss
    mkdir -p /var/log
    
    # 确保日志文件存在
    touch $LOG_FILE
}

# 配置dnsmasq
config_dnsmasq() {
    # 创建dnsmasq配置文件
    cat > $ADSS_DIR/dnsmasq-adss.conf <<EOF
# ADSS dnsmasq 配置文件
# 由 ADSS 自动生成，请勿手动修改

# 指定上游DNS服务器配置文件
resolv-file=$ADSS_DIR/resolv-adss.conf

# 添加解析规则
conf-file=$RULES_DIR/dnsrules.conf

# 添加hosts规则
addn-hosts=$RULES_DIR/hostsrules.conf

# 缓存大小
cache-size=10000

# 不读取/etc/hosts
no-hosts

# 不解析/etc/resolv.conf
no-resolv

# 域名查询缓存时间
min-cache-ttl=1800
EOF

    # 创建上游DNS配置文件
    if [ ! -f "$ADSS_DIR/resolv-adss.conf" ]; then
        cat > $ADSS_DIR/resolv-adss.conf <<EOF
# 上游DNS解析服务器
# 如需根据自己的网络环境优化DNS服务器，可用ping或DNSBench测速
# 选择最快的服务器依次按速度快慢顺序手动改写

# 纯净免费公共DNS查询服务器
nameserver 119.29.29.29       #DNSPod IPv4
nameserver 2402:4e00::        #DNSPod IPv6
nameserver 223.5.5.5          #阿里 IPv4
nameserver 2400:3200::1       #阿里 IPv6
nameserver 180.76.76.76       #百度 IPv4
nameserver 2400:da00::6666    #百度 IPv6
EOF
    fi
    
    # 创建用户自定义规则文件
    if [ ! -f "$RULES_DIR/userlist" ]; then
        cat > $RULES_DIR/userlist <<EOF
# 用户自定义dnsmasq规则
# 每行一条规则，格式：address=/domain/ip
# 例如：address=/example.com/127.0.0.1
EOF
    fi
    
    # 创建用户黑名单文件
    if [ ! -f "$RULES_DIR/userblacklist" ]; then
        cat > $RULES_DIR/userblacklist <<EOF
# 用户自定义黑名单
# 每行一个域名，将被解析到127.0.0.1
# 例如：ad.example.com
EOF
    fi
    
    # 创建用户白名单文件
    if [ ! -f "$RULES_DIR/userwhitelist" ]; then
        cat > $RULES_DIR/userwhitelist <<EOF
# 用户自定义白名单
# 每行一个域名，将不会被过滤
# 例如：example.com
EOF
    fi
}

# 主函数
main() {
    log "ADSS 服务启动"
    
    # 初始化目录
    init_dirs
    
    # 配置dnsmasq
    config_dnsmasq
    
    # 检查规则文件
    if [ ! -f "$RULES_DIR/dnsrules.conf" ] || [ ! -f "$RULES_DIR/hostsrules.conf" ]; then
        log "规则文件不存在，将在后台更新规则"
        /usr/share/adss/rules_update.sh > /var/log/adss_update.log 2>&1 &
    fi
    
    # 应用dnsmasq配置
    if [ -f "/etc/init.d/dnsmasq" ]; then
        log "重启dnsmasq服务应用配置"
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
    fi
    
    # 保持脚本运行
    while true; do
        sleep 3600
    done
}

# 执行主函数
main