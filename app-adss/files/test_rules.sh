#!/bin/sh

# 测试规则有效性
test_rules() {
    local test_domains="
        www.baidu.com
        www.google.com
        www.youtube.com
        www.facebook.com
    "
    
    echo "开始测试规则解析..."
    echo
    
    for domain in $test_domains; do
        echo "测试域名: $domain"
        nslookup $domain 127.0.0.1
        echo
    done
}

# 测试广告过滤
test_adblock() {
    local ad_domains="
        ad.doubleclick.net
        pagead2.googlesyndication.com
        ads.youtube.com
    "
    
    echo "测试广告过滤..."
    echo
    
    for domain in $ad_domains; do
        echo "测试广告域名: $domain"
        if nslookup $domain 127.0.0.1 | grep -q "127.0.0.1"; then
            echo "√ 成功拦截"
        else
            echo "× 拦截失败"
        fi
        echo
    done
}

# 主函数
main() {
    test_rules
    test_adblock
}

main