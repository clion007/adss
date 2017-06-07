# 复制下面命令行，到Openwrt、pandorabox、ddwrt路由器webshell或者putty登录后，粘贴回车，即可一键安装dnsmasq及hosts扶墙广告屏蔽脚本
wget --no-check-certificate -qO - https://raw.githubusercontent.com/clion007/dnsmasq/master/dnsmasq_fqad.sh > /etc/dnsmasq_fqad.sh;/bin/sh /etc/dnsmasq_fqad.sh;rm -rf /etc/dnsmasq_fqad.sh

# 复制下面命令行，到LEDE路由器webshell或者putty登录后，粘贴回车，即可一键安装dnsmasq及hosts扶墙广告屏蔽脚本
wget --no-check-certificate -qO - https://raw.githubusercontent.com/clion007/dnsmasq/master/lede_dnsmasq_fqad.sh > /etc/dnsmasq_fqad.sh;/bin/sh /etc/dnsmasq_fqad.sh;rm -rf /etc/dnsmasq_fqad.sh
