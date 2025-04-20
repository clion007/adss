#!/bin/sh

. /lib/functions.sh

config_load adss
keep_days=$(uci_get_by_type basic keep_log_days 7)

clean_logs() {
    find /var/log/adss*.log -mtime +${keep_days} -exec rm {} \;
    logger -t "adss" "已清理${keep_days}天前的日志"
}

clean_logs