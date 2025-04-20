#!/bin/sh

# 检查配置文件完整性
check_files() {
    local missing=0
    for file in \
        "/etc/config/adss" \
        "/etc/dnsmasq.d/adss/resolv-adss.conf" \
        "/etc/dnsmasq.d/adss/rules/userwhitelist" \
        "/etc/dnsmasq.d/adss/rules/userblacklist" \
        "/etc/dnsmasq.d/adss/rules/userlist"
    do
        if [ ! -f "$file" ]; then
            echo "缺失文件: $file"
            missing=1
        fi
    done
    return $missing
}

# 检查 DNS 解析
check_dns() {
    if ! nslookup www.baidu.com >/dev/null 2>&1; then
        echo "DNS 解析异常"
        return 1
    fi
    return 0
}

# 检查规则文件
check_rules() {
    if [ ! -s "/etc/dnsmasq.d/adss/rules/dnsrules.conf" ]; then
        echo "DNS 规则文件为空或不存在"
        return 1
    fi
    if [ ! -s "/etc/dnsmasq.d/adss/rules/hostsrules.conf" ]; then
        echo "Hosts 规则文件为空或不存在"
        return 1
    fi
    return 0
}

# 主函数
main() {
    local error=0
    
    echo "开始检查配置..."
    check_files || error=1
    check_dns || error=1
    check_rules || error=1
    
    if [ $error -eq 0 ]; then
        echo "所有检查通过"
    else
        echo "检查发现问题，请查看上述输出"
    fi
    
    return $error
}

main