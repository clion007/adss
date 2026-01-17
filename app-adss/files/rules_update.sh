#!/bin/sh

# ADSS 规则更新脚本
# 支持自定义规则源和白名单/黑名单

. /lib/functions.sh

TEMP_DIR="/tmp/adss"
RULES_DIR="/etc/dnsmasq.d/adss/rules"
LOG_FILE="/var/log/adss_update.log"

# 记录日志
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOG_FILE
    logger -t "adss" "$1"
}

# 初始化
init() {
    mkdir -p $TEMP_DIR
    mkdir -p $RULES_DIR
    
    log "开始更新ADSS规则"
    
    # 初始化规则文件
    log "初始化规则文件"
    curl -s --connect-timeout 10 --retry 3 https://raw.gitcode.com/clion/adss/raw/master/rules/builder/initRulesFile.sh -o $TEMP_DIR/initRulesFile.sh
    if [ $? -ne 0 ]; then
        log "初始化规则文件下载失败，尝试备用源"
        curl -s --connect-timeout 10 --retry 3 https://raw.githubusercontent.com/clion007/adss/master/rules/builder/initRulesFile.sh -o $TEMP_DIR/initRulesFile.sh
    fi
    
    if [ -f "$TEMP_DIR/initRulesFile.sh" ]; then
        chmod +x $TEMP_DIR/initRulesFile.sh
        . $TEMP_DIR/initRulesFile.sh
        log "规则文件初始化完成"
    else
        log "规则文件初始化失败"
        return 1
    fi
    
    return 0
}

# 下载基础规则
download_base_rules() {
    log "下载基础规则文件"
    
    # 下载DNS规则
    curl -s --connect-timeout 10 --retry 3 https://gh.llkk.cc/https://raw.githubusercontent.com/clion007/adss/master/rules/file/dnsrules.conf -o $TEMP_DIR/base_dnsrules.conf
    if [ $? -ne 0 ]; then
        log "基础DNS规则下载失败，尝试备用源"
        curl -s --connect-timeout 10 --retry 3 https://raw.gitcode.com/clion/adss/raw/master/rules/file/dnsrules.conf -o $TEMP_DIR/base_dnsrules.conf
    fi
    
    # 下载Hosts规则
    curl -s --connect-timeout 10 --retry 3 https://gh.llkk.cc/https://raw.githubusercontent.com/clion007/adss/master/rules/file/hostsrules.conf -o $TEMP_DIR/base_hostsrules.conf
    if [ $? -ne 0 ]; then
        log "基础Hosts规则下载失败，尝试备用源"
        curl -s --connect-timeout 10 --retry 3 https://raw.gitcode.com/clion/adss/raw/master/rules/file/hostsrules.conf -o $TEMP_DIR/base_hostsrules.conf
    fi
    
    if [ -f "$TEMP_DIR/base_dnsrules.conf" ] && [ -f "$TEMP_DIR/base_hostsrules.conf" ]; then
        log "基础规则下载完成"
        return 0
    else
        log "基础规则下载失败"
        return 1
    fi
}

# 处理自定义规则源
process_custom_rules() {
    log "处理自定义规则源"
    
    # 调用自定义规则处理脚本
    /usr/share/adss/custom_rules.sh
    
    # 合并自定义规则
    if [ -f "$TEMP_DIR/custom_hosts_result" ]; then
        local custom_hosts_file=$(cat "$TEMP_DIR/custom_hosts_result")
        if [ -f "$custom_hosts_file" ]; then
            cat "$custom_hosts_file" >> "$TEMP_DIR/base_hostsrules.conf"
            log "合并自定义Hosts规则完成"
        fi
    fi
    
    if [ -f "$TEMP_DIR/custom_dnsmasq_result" ]; then
        local custom_dnsmasq_file=$(cat "$TEMP_DIR/custom_dnsmasq_result")
        if [ -f "$custom_dnsmasq_file" ]; then
            cat "$custom_dnsmasq_file" >> "$TEMP_DIR/base_dnsrules.conf"
            log "合并自定义DNS规则完成"
        fi
    fi
    
    return 0
}

# 处理白名单
process_whitelist() {
    log "处理白名单"
    
    # 创建临时白名单文件
    > $TEMP_DIR/whitelist.conf
    
    # 从配置文件获取白名单
    config_load adss
    
    config_list_foreach "custom" "whitelist" append_whitelist
    
    # 应用白名单
    if [ -s "$TEMP_DIR/whitelist.conf" ]; then
        log "应用白名单规则"
        while read -r domain; do
            if [ -n "$domain" ]; then
                # 从DNS规则中删除
                sed -i "/$domain/d" $TEMP_DIR/base_dnsrules.conf
                # 从Hosts规则中删除
                sed -i "/$domain/d" $TEMP_DIR/base_hostsrules.conf
            fi
        done < $TEMP_DIR/whitelist.conf
    fi
    
    return 0
}

# 添加白名单项
append_whitelist() {
    echo "$1" >> $TEMP_DIR/whitelist.conf
}

# 处理黑名单
process_blacklist() {
    log "处理黑名单"
    
    # 创建临时黑名单文件
    > $TEMP_DIR/blacklist.conf
    
    # 从配置文件获取黑名单
    config_load adss
    
    config_list_foreach "custom" "blacklist" append_blacklist
    
    # 应用黑名单
    if [ -s "$TEMP_DIR/blacklist.conf" ]; then
        log "应用黑名单规则"
        while read -r domain; do
            if [ -n "$domain" ]; then
                # 添加到DNS规则
                echo "address=/$domain/127.0.0.1" >> $TEMP_DIR/base_dnsrules.conf
            fi
        done < $TEMP_DIR/blacklist.conf
    fi
    
    return 0
}

# 添加黑名单项
append_blacklist() {
    echo "$1" >> $TEMP_DIR/blacklist.conf
}

# 应用规则
apply_rules() {
    log "应用最终规则"
    
    # 处理DNS规则
    if [ -f "$TEMP_DIR/base_dnsrules.conf" ]; then
        # 排序并去重
        sort -u $TEMP_DIR/base_dnsrules.conf > $TEMP_DIR/final_dnsrules.conf
        echo "# Modified DNS end" >> $TEMP_DIR/final_dnsrules.conf
        
        # 检查是否有变化
        if [ -f "$RULES_DIR/dnsrules.conf" ]; then
            if ! cmp -s $TEMP_DIR/final_dnsrules.conf $RULES_DIR/dnsrules.conf; then
                log "DNS规则有更新，应用新规则"
                cp -f $TEMP_DIR/final_dnsrules.conf $RULES_DIR/dnsrules.conf
                need_restart=1
            else
                log "DNS规则无变化"
            fi
        else
            log "DNS规则文件不存在，创建新文件"
            cp -f $TEMP_DIR/final_dnsrules.conf $RULES_DIR/dnsrules.conf
            need_restart=1
        fi
    fi
    
    # 处理Hosts规则
    if [ -f "$TEMP_DIR/base_hostsrules.conf" ]; then
        # 排序并去重
        sort -u $TEMP_DIR/base_hostsrules.conf > $TEMP_DIR/final_hostsrules.conf
        echo "# 修饰 hosts 结束" >> $TEMP_DIR/final_hostsrules.conf
        
        # 检查是否有变化
        if [ -f "$RULES_DIR/hostsrules.conf" ]; then
            if ! cmp -s $TEMP_DIR/final_hostsrules.conf $RULES_DIR/hostsrules.conf; then
                log "Hosts规则有更新，应用新规则"
                cp -f $TEMP_DIR/final_hostsrules.conf $RULES_DIR/hostsrules.conf
                need_restart=1
            else
                log "Hosts规则无变化"
            fi
        else
            log "Hosts规则文件不存在，创建新文件"
            cp -f $TEMP_DIR/final_hostsrules.conf $RULES_DIR/hostsrules.conf
            need_restart=1
        fi
    fi
    
    # 如果有更新，重启dnsmasq
    if [ "$need_restart" = "1" ]; then
        log "重启dnsmasq服务应用新规则"
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
    fi
    
    return 0
}

# 清理临时文件
cleanup() {
    log "清理临时文件"
    rm -rf $TEMP_DIR
    log "规则更新完成"
}

# 主函数
main() {
    local need_restart=0
    
    # 初始化
    init || return 1
    
    # 下载基础规则
    download_base_rules || return 1
    
    # 处理自定义规则源
    process_custom_rules
    
    # 处理白名单
    process_whitelist
    
    # 处理黑名单
    process_blacklist
    
    # 应用规则
    apply_rules
    
    # 清理
    cleanup
    
    return 0
}

# 执行主函数
main
