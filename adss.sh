#!/bin/bash
#
# Auto DNS Smart Script V4.0
# Project URL https://github.com/clion007/adss
# Main Module file
# Copyright © by Clion Nieh Email: clion007@126.com
# Licenses in GPL V3.0
#

function install() {
    echo "检测与处理倚赖关系"
    if [ ! type opkg >/dev/null 2>&1 ]; then
      echo "本脚本仅支持 Openwrt 系列固件使用，您的当前固件不支持安装"
      exit 1
    fi
    opkg list_installed | grep "dnsmasq" > /dev/null
    if [ ! $? -eq 0 ]; then
      opkg install dnsmasq-full
    fi
}

function uninstall() {

}

function implant_to_openwrt() {

}