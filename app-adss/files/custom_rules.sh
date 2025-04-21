#!/bin/sh

# 自定义规则源处理脚本
# 用于下载和处理自定义规则源

. /lib/functions.sh

TEMP_DIR="/tmp/adss"
RULES_DIR="/etc/dnsmasq.d/adss/rules"
LOG_FILE="/var/log/adss_update.log"

# 记录日志
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOG_FILE
    logger -t "adss" "$1"
}

# 下载规则文件
download_rule() {
    local name="$1"
    local url="$2"
    local type="$3"
    local output_file="$TEMP_DIR/custom_${name}.conf"
    
    log "开始下载自定义规则源: $name ($url)"
    
    if curl -s --connect-timeout 10 --retry 3 "$url" -o "$output_file"; then
        log "规则源 $name 下载成功"
        echo "$output_file|$type"
        return 0
    else
        log "规则源 $name 下载失败"
        return 1
    fi
}

# 处理hosts格式规则
process_hosts_rule() {
    local file="$1"
    local output="$TEMP_DIR/processed_hosts.conf"
    
    log "处理hosts格式规则: $file"
    
    # 删除注释和空行
    sed -i '/^#/d' "$file"
    sed -i 's/#.*//g' "$file"
    sed -i '/^\s*$/d' "$file"
    
    # 统一格式
    sed -i "s/0.0.0.0/127.0.0.1/g" "$file"
    sed -i "s/[ ][ ]*/ /g" "$file"
    
    # 追加到临时hosts文件
    cat "$file" >> "$output"
    log "hosts规则处理完成"
}

# 处理dnsmasq格式规则
process_dnsmasq_rule() {
    local file="$1"
    local output="$TEMP_DIR/processed_dnsmasq.conf"
    
    log "处理dnsmasq格式规则: $file"
    
    # 删除注释和空行
    sed -i '/^#/d' "$file"
    sed -i 's/#.*//g' "$file"
    sed -i '/^\s*$/d' "$file"
    sed -i '/\/$/d' "$file" # 删除dns空规则
    
    # 统一格式
    sed -i "s/\/0.0.0.0/\/127.0.0.1/g" "$file"
    sed -i "s/[ ][ ]*/ /g" "$file"
    
    # 追加到临时dnsmasq文件
    cat "$file" >> "$output"
    log "dnsmasq规则处理完成"
}

# 主函数
main() {
    mkdir -p "$TEMP_DIR"
    
    # 创建临时文件
    > "$TEMP_DIR/processed_hosts.conf"
    > "$TEMP_DIR/processed_dnsmasq.conf"
    
    # 遍历所有自定义规则源
    config_load adss
    
    process_rule_source() {
        local name url type enabled
        
        config_get name "$1" name
        config_get url "$1" url
        config_get type "$1" type
        config_get_bool enabled "$1" enabled 1
        
        if [ "$enabled" = "1" ] && [ -n "$url" ]; then
            local result=$(download_rule "$name" "$url" "$type")
            local ret=$?
            
            if [ $ret -eq 0 ]; then
                local file=$(echo "$result" | cut -d'|' -f1)
                local type=$(echo "$result" | cut -d'|' -f2)
                
                if [ "$type" = "hosts" ]; then
                    process_hosts_rule "$file"
                elif [ "$type" = "dnsmasq" ]; then
                    process_dnsmasq_rule "$file"
                fi
            fi
        fi
    }
    
    config_foreach process_rule_source rule_source
    
    # 返回处理结果
    if [ -s "$TEMP_DIR/processed_hosts.conf" ]; then
        log "自定义hosts规则处理完成"
        echo "$TEMP_DIR/processed_hosts.conf" > "$TEMP_DIR/custom_hosts_result"
    fi
    
    if [ -s "$TEMP_DIR/processed_dnsmasq.conf" ]; then
        log "自定义dnsmasq规则处理完成"
        echo "$TEMP_DIR/processed_dnsmasq.conf" > "$TEMP_DIR/custom_dnsmasq_result"
    fi
}

main