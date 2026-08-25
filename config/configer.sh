#!/bin/sh
print l "开始配置 ADSS"
if [ ! -f /etc/dnsmasq.d/dnsmasq-adss.conf ]; then
  download "files/etc/dnsmasq.d/dnsmasq-adss.conf" "/etc/dnsmasq.d/dnsmasq-adss.conf"
fi

if [ ! -f /etc/dnsmasq.d/adss/resolv-adss.conf ]; then
  print l "获取上游 DNS 解析配置"
  download "files/etc/dnsmasq.d/adss/resolv-adss.conf" "/etc/dnsmasq.d/adss/resolv-adss.conf"
fi

if [ ! -f /etc/dnsmasq.d/adss/rules/userlist ]; then
  print l "创建自定义规则文件"
  download "files/etc/dnsmasq.d/adss/rules/userlist" "/etc/dnsmasq.d/adss/rules/userlist"
fi

if [ ! -f /etc/dnsmasq.d/adss/rules/userblacklist ]; then
  print l "创建自定义黑名单文件"
  download "files/etc/dnsmasq.d/adss/rules/userblacklist" "/etc/dnsmasq.d/adss/rules/userblacklist"
fi

if [ ! -f /etc/dnsmasq.d/adss/rules/userwhitelist ]; then
  print l "创建自定义白名单文件"
  download "files/etc/dnsmasq.d/adss/rules/userwhitelist" "/etc/dnsmasq.d/adss/rules/userwhitelist"
fi

print r "添加配置目录权限"
if [ `grep -c "\/etc\/dnsmasq.d\/" /etc/init.d/dnsmasq` -ne '1' ]; then
  sed -i 's/$resolvdir $user_dhcpscript/$resolvdir $user_dhcpscript \/etc\/dnsmasq.d\//g' /etc/init.d/dnsmasq
fi
print r "ADSS 配置完成！"
