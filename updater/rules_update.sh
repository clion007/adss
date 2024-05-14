#!/bin/sh
mkdir -p /tmp/adss
sleep 3
echo -e "\e[1;36m 获取规则文件\e[0m"
echo
wget --no-check-certificate https://gitee.com/clion007/adss/raw/master/rules/file/dnsrules.conf -qO \
	/tmp/adss/rules/dnsrules.conf
wget --no-check-certificate https://gitee.com/clion007/adss/raw/master/rules/file/hostsrules.conf -qO \
	/tmp/adss/rules/hostsrules.conf
sleep 3
if [ -s "/tmp/adss/dnsrules.conf" ]; then
    if ( ! cmp -s /tmp/adss/dnsrules.conf /usr/share/adss/rules/dnsrules.conf ); then
        echo " `date +'%Y-%m-%d %H:%M:%S'`:检测到dnsmasq规则有更新......生成新dnsmasq规则！"
        echo
        mv -f /tmp/adss/dnsrules.conf /usr/share/adss/rules/dnsrules.conf
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
        echo " `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq规则更新完成，应用新规则。"
        echo
    else
        echo " `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq本地规则和在线规则相同，无需更新！"
        rm -f /tmp/adss/dnsrules.conf
        echo
    fi  
fi
if [ -s "/tmp/adss/hostsrules.conf" ]; then
    if ( ! cmp -s /tmp/adss/hostsrules.conf /usr/share/adss/rules/hostsrules.conf ); then
        echo " `date +'%Y-%m-%d %H:%M:%S'`: 检测到hosts规则有更新......生成新hosts规则！"
        echo
        mv -f /tmp/adss/hostsrules.conf /usr/share/adss/rules/hostsrules.conf
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
        echo " `date +'%Y-%m-%d %H:%M:%S'`: hosts规则转换完成，应用新规则。"
        echo
    else
        echo " `date +'%Y-%m-%d %H:%M:%S'`: hosts本地规则和在线规则相同，无需更新！"
        rm -f /tmp/adss/hostsrules.conf
        echo
    fi  
fi
echo -e "\e[1;36m 规则更新已完成...\e[0m"
echo
rm -rf /tmp/adss