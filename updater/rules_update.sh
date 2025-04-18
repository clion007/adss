#!/bin/sh
mkdir -p /tmp/adss
echo -e "\e[1;36m 初始化规则文件 \e[0m"
echo 
curl https://gitee.com/clion007/adss/raw/master/rules/builder/initRulesFile.sh -sLSo /tmp/adss/initRulesFile.sh
. /tmp/adss/initRulesFile.sh
echo 
echo -e "\e[1;36m 获取线上规则文件\e[0m"
curl --http1.1 https://raw.gitmirror.com/clion007/adss/master/rules/file/dnsrules.conf -sLSo /tmp/adss/dnsrules
curl --http1.1 https://raw.gitmirror.com/clion007/adss/master/rules/file/hostsrules.conf -sLSo /tmp/adss/hostsrules.conf
echo 
echo -e "\e[1;36m 添加用户定义规则\e[0m"
cat /etc/dnsmasq.d/adss/rules/userlist > /tmp/adss/userlist 
sed -i "/#/d" /tmp/adss/userlist
sed -i '/^\s*$/d' /tmp/adss/userlist # 删除空行
echo 
echo -e "\e[1;36m 生成用户黑名单规则\e[0m"
cat /etc/dnsmasq.d/adss/rules/userblacklist > /tmp/adss/blacklist
sed -i "/#/d" /tmp/adss/blacklist # 删除注释
sed -i '/^\s*$/d' /tmp/adss/blacklist # 删除空行
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /tmp/adss/blacklist # 生成黑名单规则，支持通配符
echo 
echo -e "\e[1;36m 合并处理规则\e[0m"
cat /tmp/adss/blacklist >> /tmp/adss/dnsrules
sed -i '/localhost/d' /tmp/adss/dnsrules # 删除本地规则
sed -i 's/#.*//g' /tmp/adss/dnsrules # 删除注释内容
sed -i '/^\s*$/d' /tmp/adss/dnsrules # 删除空行
sed -i '/\/$/d' /tmp/adss/dnsrules # 删除dns空规则
echo 
echo -e "\e[1;36m 删除用户白名单中包含规则\e[0m"
cat /etc/dnsmasq.d/adss/rules/userwhitelist | uniq > /tmp/adss/whitelist 
sed -i "/#/d" /tmp/adss/whitelist
while read -r line
do
	if [ -s "/tmp/adss/dnsrules" ]; then 
		sed -i "/$line/d" /tmp/adss/dnsrules
	fi
	if [ -s "/tmp/adss/hostsrules.conf" ]; then 
		sed -i "/$line/d" /tmp/adss/hostsrules.conf
	fi
done < /tmp/adss/whitelist
echo 
echo -e "\e[1;36m 生成最终 DNS 规则\e[0m"
cat /tmp/adss/userlist >> /tmp/adss/dnsrules.conf
rm -f /tmp/adss/userlist
sort -u /tmp/adss/dnsrules >> /tmp/adss/dnsrules.conf # 排序并去除重复规则
rm -f /tmp/adss/dnsrules
echo "# Modified DNS end" >> /tmp/adss/dnsrules.conf 
echo 
if [ -s "/tmp/adss/dnsrules.conf" ]; then
    if ( ! cmp -s /tmp/adss/dnsrules.conf /etc/dnsmasq.d/adss/rules/dnsrules.conf ); then
        echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`：检测到新 DNS 规则......生成新 DNS 规则！\e[0m"
        echo 
        mv -f /tmp/adss/dnsrules.conf /etc/dnsmasq.d/adss/rules/dnsrules.conf
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
        echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`：DNS 规则更新完成，应用新规则。\e[0m"
        echo 
    else
        echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`：DNS 规则无需更新。\e[0m"
        rm -f /tmp/adss/dnsrules.conf
        echo 
    fi  
fi
if [ -s "/tmp/adss/hostsrules.conf" ]; then
    if ( ! cmp -s /tmp/adss/hostsrules.conf /etc/dnsmasq.d/adss/rules/hostsrules.conf ); then
        echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`：检测到新 hosts 规则......生成新 hosts 规则！\e[0m"
        echo 
        mv -f /tmp/adss/hostsrules.conf /etc/dnsmasq.d/adss/rules/hostsrules.conf
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
        echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`：hosts 规则更新完成，应用新规则。\e[0m"
        echo 
    else
        echo -e "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`：hosts 规则无需更新。\e[0m"
        rm -f /tmp/adss/hostsrules.conf
        echo 
    fi  
fi
rm -rf /tmp/adss
