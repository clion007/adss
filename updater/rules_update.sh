#!/bin/sh
mkdir -p /tmp/adss
echo -e "\e[1;36m 初始化规则文件 \e[0m"
echo 
curl https://gitee.com/clion007/adss/raw/master/rules/builder/initRulesFile.sh -sLSo /tmp/adss/initRulesFile.sh
sh /tmp/adss/initRulesFile.sh
echo 
echo -e "\e[1;36m 获取规则文件\e[0m"
curl https://gitdl.cn/https://raw.githubusercontent.com/clion007/adss/master/rules/file/dnsrules.conf -sLSo /tmp/adss/dnsrules
curl https://gitdl.cn/https://raw.githubusercontent.com/clion007/adss/master/rules/file/hostsrules.conf -sLSo /tmp/adss/hostsrules.conf
echo 
echo -e "\e[1;36m 添加用户定义规则\e[0m"
cat /etc/dnsmasq.d/adss/rules/userlist > /tmp/adss/userlist 
sed -i "/#/d" /tmp/adss/userlist
sed -i '/^$/d' /tmp/adss/userlist # 删除空行
echo 
echo -e "\e[1;36m 添加用户定义黑名单\e[0m"
cat /etc/dnsmasq.d/adss/rules/userblacklist > /tmp/adss/blacklist 
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' /tmp/adss/blacklist #支持通配符
echo 
echo -e "\e[1;36m 合并广告规则\e[0m"
cat  /tmp/adss/dnsrules /tmp/adss/blacklist > /tmp/adss/dnsAd 
sed -i '/localhost/d' /tmp/adss/dnsAd # 删除本地规则
sed -i 's/#.*//g' /tmp/adss/dnsAd # 删除注释内容
sed -i '/^$/d' /tmp/adss/dnsAd # 删除空行
awk '!a[$0]++' /tmp/adss/dnsAd > /tmp/adss/dnsAd.conf #去除重复
echo 
echo -e "\e[1;36m 添加用户定义白名单\e[0m"
cat /etc/dnsmasq.d/adss/rules/userwhitelist | uniq > /tmp/adss/whitelist 
sed -i "/#/d" /tmp/adss/whitelist
while read -r line
do
	if [ -s "/tmp/adss/dnsAd.conf" ]; then 
		sed -i "/$line/d" /tmp/adss/dnsAd.conf
	fi
	if [ -s "/tmp/adss/hostsrules.conf" ]; then 
		sed -i "/$line/d" /tmp/adss/hostsrules.conf
	fi
done < /tmp/adss/whitelist
echo 
echo -e "\e[1;36m 生成最终DNS规则\e[0m"
cat /tmp/adss/userlist /tmp/adss/dnsAd.conf >> /tmp/adss/dnsrules.conf
echo "# Modified DNS end" >> /tmp/adss/dnsrules.conf 
echo 
if [ -s "/tmp/adss/dnsrules.conf" ]; then
    if ( ! cmp -s /tmp/adss/dnsrules.conf /etc/dnsmasq.d/adss/rules/dnsrules.conf ); then
        echo "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`:检测到dnsmasq规则有更新......生成新dnsmasq规则！\e[0m"
        echo 
        mv -f /tmp/adss/dnsrules.conf /etc/dnsmasq.d/adss/rules/dnsrules.conf
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
        echo "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq规则更新完成，应用新规则。\e[0m"
        echo 
    else
        echo "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: dnsmasq本地规则和在线规则相同，无需更新！\e[0m"
        rm -f /tmp/adss/dnsrules.conf
        echo 
    fi  
fi
if [ -s "/tmp/adss/hostsrules.conf" ]; then
    if ( ! cmp -s /tmp/adss/hostsrules.conf /etc/dnsmasq.d/adss/rules/hostsrules.conf ); then
        echo "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: 检测到hosts规则有更新......生成新hosts规则！\e[0m"
        echo 
        mv -f /tmp/adss/hostsrules.conf /etc/dnsmasq.d/adss/rules/hostsrules.conf
        /etc/init.d/dnsmasq restart > /dev/null 2>&1
        echo "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: hosts规则转换完成，应用新规则。\e[0m"
        echo 
    else
        echo "\e[1;36m `date +'%Y-%m-%d %H:%M:%S'`: hosts本地规则和在线规则相同，无需更新！\e[0m"
        rm -f /tmp/adss/hostsrules.conf
        echo 
    fi  
fi
rm -rf /tmp/adss
