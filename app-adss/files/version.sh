#!/bin/sh

# 集中管理版本信息
ADSS_VERSION="4.2"
ADSS_RELEASE_DATE="2023-12-15"
ADSS_AUTHOR="clion007"
ADSS_REPO="https://github.com/clion007/adss"

# 导出版本信息函数
get_version() {
    echo "$ADSS_VERSION"
}

get_release_date() {
    echo "$ADSS_RELEASE_DATE"
}

# 如果直接执行此脚本，则显示版本信息
if [ "$(basename "$0")" = "version.sh" ]; then
    echo "ADSS 广告过滤系统"
    echo "版本: $ADSS_VERSION"
    echo "发布日期: $ADSS_RELEASE_DATE"
    echo "作者: $ADSS_AUTHOR"
    echo "项目地址: $ADSS_REPO"
fi