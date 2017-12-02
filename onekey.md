# 复制下面命令行，到Openwrt、pandorabox、ddwrt、LEDE路由器webshell或者putty登录后，粘贴回车，即可一键安装dnsmasq及hosts扶墙广告屏蔽脚本
wget --no-check-certificate -qO - https://raw.githubusercontent.com/clion007/dnsmasq/master/fqad_auto.sh > /tmp/fqad_auto.sh && sh /tmp/fqad_auto.sh

# 复制下面命令行，到Openwrt、pandorabox、ddwrt、LEDE等路由器webshell或者putty登录后，粘贴回车，即可一键安装dnsmasq及hosts广告屏蔽脚本
wget --no-check-certificate -qO - https://raw.githubusercontent.com/clion007/dnsmasq/master/ad_auto.sh > /tmp/ad_auto.sh && sh /tmp/ad_auto.sh

注意：一键安装的前，请确认路由固件已经安装了wget及dnsmasq或dnsmasq-full软件包，如果路由固件同时预装了dnsmasq和dnsmasq-full软件包，请安装前登录路由器web管理页面，进入系统-软件包菜单页面手动卸载dnsmasq，保留dnsmasq-full。

# 复制下面命令行，到Openwrt、pandorabox、ddwrt、LEDE路由器webshell或者putty登录后，粘贴回车，即可一键卸载脚本，并自动清除之前配置脚本对路由器固件系统文件的所有配置信息，恢复到脚本安装配置前的状态
wget --no-check-certificate -qO - https://raw.githubusercontent.com/clion007/dnsmasq/master/Uninstall.sh > /tmp/Uninstall.sh && sh f/tmp/Uninstall.sh
