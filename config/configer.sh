#!/bin/sh
echo -e "\e[1;36m 开始配置 ADSS\e[0m"
echo 
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/etc/dnsmasq.d/dnsmasq-adss.conf -sSo /etc/dnsmasq.d/dnsmasq-adss.conf
echo -e "\e[1;36m 获取上游 DNS 解析配置\e[0m"
echo 
curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/etc/dnsmasq.d/adss/resolv-adss.conf -sSo /etc/dnsmasq.d/adss/resolv-adss.conf

if [ ! -f /etc/dnsmasq.d/adss/rules/userlist ]; then
  echo -e "\e[1;36m 创建自定义规则文件\e[0m"
  echo 
  curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/etc/dnsmasq.d/adss/rules/userlist -sSo /etc/dnsmasq.d/adss/rules/userlist
fi

if [ ! -f /etc/dnsmasq.d/adss/rules/userblacklist ]; then
  echo -e "\e[1;36m 创建自定义黑名单文件\e[0m"
  echo 
  curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/etc/dnsmasq.d/adss/rules/userblacklist -sSo /etc/dnsmasq.d/adss/rules/userblacklist
fi	

if [ ! -f /etc/dnsmasq.d/adss/rules/userwhitelist ]; then
  echo -e "\e[1;36m 创建自定义白名单文件\e[0m"
  echo 
  curl ${GH_PROXY_PREFIX}https://raw.githubusercontent.com/clion007/adss/master/files/etc/dnsmasq.d/adss/rules/userwhitelist -sSo /etc/dnsmasq.d/adss/rules/userwhitelist
fi

echo -e "\e[1;31m 添加配置目录权限 \e[0m"
echo 
if [ `grep -c "\/etc\/dnsmasq.d\/" /etc/init.d/dnsmasq` -ne '1' ];then
  sed -i 's/$resolvdir $user_dhcpscript/$resolvdir $user_dhcpscript \/etc\/dnsmasq.d\//g' /etc/init.d/dnsmasq
fi
echo -e "\e[1;31m ADSS 配置完成！ \e[0m"
echo
