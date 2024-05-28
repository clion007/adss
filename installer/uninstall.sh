 #!/bin/sh
echo -e "\e[1;36m 开始卸载ADSS \e[0m"
echo 
echo -e "\e[1;36m 停用ADSS \e[0m"
echo 
/etc/init.d/adss stop > /dev/null 2>&1
echo -e "\e[1;31m 删除残留文件夹以及配置 \e[0m"
echo 
rm -rf /usr/share/adss /etc/dnsmasq.d/*adss* /etc/rc.d/S90adss /etc/init.d/adss 
echo -e "\e[1;31m 删除相关计划任务 \e[0m"
echo 
if [ -f /etc/crontabs/$USER-adss.bak ]; then
  mv -f /etc/crontabs/$USER-adss.bak /etc/crontabs/$USER
fi
echo -e "\e[1;31m 删除配置目录权限 \e[0m"
sed -i 's/$resolvdir $user_dhcpscript \/etc\/dnsmasq.d\//$resolvdir $user_dhcpscript/g' /etc/init.d/dnsmasq
echo 
/etc/init.d/cron reload > /dev/null 2>&1
echo -e "\e[1;31m 重启dnsmasq服务 \e[0m"
killall dnsmasq > /dev/null 2>&1
/etc/init.d/dnsmasq restart > /dev/null 2>&1
rm -rf /tmp/adss
