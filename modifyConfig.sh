#!/bin/sh
sleep 3
grep "hostsrules" /etc/dnsmasq.conf >/dev/null
if [ ! $? -eq 0 ]; then
	echo -e "\e[1;36m 配置dnsmasq\e[0m"
	echo
	lanip=`ifconfig|grep Bcast|awk '{print $2}'|tr -d "addr:"|sed 's/,/\n/g'|awk '{{printf"%s,",$0}}'`
	lanipv6=`ifconfig -a|grep ::1/64|awk '{print $3}'|tr -d "/64"`
	echo "
# 设定域名解析缓存池大小
cache-size=1000000

# 添加监听地址" >> /etc/dnsmasq.conf
	if [ -n $lanipv6 ]; then
		echo "listen-address=$lanip 127.0.0.1,::1,$lanipv6" >> /etc/dnsmasq.conf
	else
		echo "listen-address=$lanip 127.0.0.1" >> /etc/dnsmasq.conf
	fi
	echo "
# 指定上游DNS服务器配置文件路径
resolv-file=/etc/dnsmasq/resolv.conf

# 上游DNS服务器并发查询
all-servers 

# 添加解析文件目录
conf-file=/etc/dnsmasq.d/dnsrules.conf

# 添加额外hosts规则
addn-hosts=/etc/dnsmasq/hostsrules.conf" >> /etc/dnsmasq.conf
fi
if [ ! -s /etc/dnsmasq/resolv.conf ]; then
	echo -e "\e[1;36m 创建上游DNS配置文件\e[0m"
	echo
	echo -e "\e[1;36m 开始创建上游DNS配置\e[0m"
	echo "# 上游DNS解析服务器
# 如需根据自己的网络环境优化DNS服务器，可用ping或DNSBench测速
# 选择最快的服务器依次按速度快慢顺序手动改写

# 当地ISP DNS服务器" > /etc/dnsmasq/resolv
	find /tmp/ -name "resolv.conf.auto" -type f -exec cp {} /tmp/resolv \;
	cat /etc/dnsmasq/resolv /tmp/resolv > /etc/dnsmasq/resolv.conf
	rm -f /etc/dnsmasq/resolv /tmp/resolv
	echo "
# 主流公共DNS查询服务器
nameserver 114.114.114.114
nameserver 218.30.118.6
nameserver 114.114.114.119
nameserver 119.29.29.29
nameserver 8.8.4.4
nameserver 4.2.2.2
nameserver 1.2.4.8
nameserver 223.5.5.5" >> /etc/dnsmasq/resolv.conf
	echo
fi
sleep 3
if [ ! -f /etc/dnsmasq.d/userlist ]; then
	echo -e "\e[1;36m 创建自定义dnsmasq规则\e[0m"
	echo
	echo "# 格式示例如下，删除address前 # 有效，添加自定义规则
# 后面的ip表示希望域名解析的正确IP
#address=/telegram.org/149.154.167.99" > /etc/dnsmasq.d/userlist
fi
hasad=/tmp/*ad*.sh
if [ "$hasad" ]; then
	if [ ! -f /etc/dnsmasq/userblacklist ]; then
		echo -e "\e[1;36m 创建自定义广告黑名单\e[0m"
		echo
		if [ -f /etc/dnsmasq/blacklist ]; then
			mv /etc/dnsmasq/blacklist /etc/dnsmasq/userblacklist
			else
			echo "# 请在下面添加广告黑名单
	# 每行输入要屏蔽广告网址域名不含http://符号，如：www.baidu.com
	# 支持不完整域名地址，支持通配符" > /etc/dnsmasq/userblacklist
		fi	
	fi	
	if [ ! -f /etc/dnsmasq/userwhitelist ]; then
		echo -e "\e[1;36m 创建自定义广告白名单\e[0m"
		echo
		if [ -f /etc/dnsmasq/whitelist ]; then
			mv /etc/dnsmasq/whitelist /etc/dnsmasq/userwhitelist
			else
			echo "# 请将误杀的网址域名添加到在下面
	# 每个一行，不带http://，尽量输入准确地址以免删除有效广告规则" > /etc/dnsmasq/userwhitelist
		fi	
	fi	
fi
