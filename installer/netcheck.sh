#!/bin/sh

# 检测网络连接
ping -c 2 -w 5 baidu.com > /dev/null 2>&1
if [ $? -ne 0 ];then
    # 检测到网络异常，重启网络服务
    /etc/init.d/network restart
    ping -c 2 -w 5 baidu.com > /dev/null 2>&1
    if [ $? -ne 0 ];then
        # 重启网络服务后，检测到网络仍然异常，重启路由器
        reboot
    fi
fi