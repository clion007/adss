# 复制下面命令行，到Openwrt、pandorabox、ddwrt路由器webshell或者putty登录后，粘贴回车，即可一键安装dnsmasq及hosts扶墙广告屏蔽脚本
wget --no-check-certificate -qO - https://raw.githubusercontent.com/clion007/dnsmasq/master/fqad_auto.sh > /tmp/fqad.sh && /bin/sh /tmp/fqad.sh

# 复制下面命令行，到LEDE路由器webshell或者putty登录后，粘贴回车，即可一键安装dnsmasq及hosts扶墙广告屏蔽脚本
wget --no-check-certificate -qO - https://raw.githubusercontent.com/clion007/dnsmasq/master/lede_dnsmasq_fqad.sh > /tmp/fqad.sh && /bin/sh /tmp/fqad.sh && rm -rf /tmp/fqad.sh

注意：一键安装的前提是系统带有wget软件包，且lan IP地址必须为192.168.1.1
