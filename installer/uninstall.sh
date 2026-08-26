 #!/bin/sh
message l "开始卸载 ADSS"
message l "停用 ADSS"
/etc/init.d/adss stop > /dev/null 2>&1
message r "删除文件以及配置"
rm -rf /usr/share/adss /etc/dnsmasq.d/*adss* /etc/rc.d/S18adss /etc/init.d/adss /lib/upgrade/keep.d/adss /usr/bin/adss
message r "删除相关计划任务"
if [ -f /etc/crontabs/$USER-adss.bak ]; then
  mv -f /etc/crontabs/$USER-adss.bak /etc/crontabs/$USER
fi
message r "删除配置目录权限"
sed -i 's/$resolvdir $user_dhcpscript \/etc\/dnsmasq.d\//$resolvdir $user_dhcpscript/g' /etc/init.d/dnsmasq
/etc/init.d/cron reload > /dev/null 2>&1
message r "重启 dnsmasq 服务"
killall dnsmasq > /dev/null 2>&1
/etc/init.d/dnsmasq restart > /dev/null 2>&1
rm -rf ${TMP_DIR}
