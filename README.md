# dnsmasq超强大的dnsmasq及hosts扶墙去广告全自动脚本
1、什么是Dnsmasq啊？（转自百度百科，不知道就百度）
DNSmasq是一个小巧且方便地用于配置DNS和DHCP的工具，适用于小型网络，它提供了DNS功能和可选择的DHCP功能。它服务那些只在本地适用的域名，这些域名是不会在全球的DNS服务器中出现的。DHCP服务器和DNS服务器结合，并且允许DHCP分配的地址能在DNS中正常解析，而这些DHCP分配的地址和相关命令可以配置到每台主机中，也可以配置到一台核心设备中（比如路由器），DNSmasq支持静态和动态两种DHCP配置方式。

2、Dnsmasq有什么用？能为我解决什么
默认的情况下，我们平时上网用的本地DNS服务器都是使用电信或者联通的，但是这样也导致了不少的问题，首当其冲的就是上网时经常莫名地弹出广告，或者莫名的流量被消耗掉导致网速变慢。其次是部分网站域名不能正常被解析，莫名其妙地打不开，或者时好时坏。
如果碰上不稳定的本地DNS，还可能经常出现无法解析的情况。除了要避免“坏”的DNS的影响，我们还可以利用DNS做些“好”事，例如管理局域网的DNS、给手机App Store加速、纠正错误的DNS解析记录、保证上网更加安全、去掉网页讨厌的广告等等。

3、方案dnsmasq提供了什么？
目前主要提供几个功能：
分域名DNS解析，提升加快不同网站的访问速度
国外域名加密解析自动扶墙，享受无墙的快感
屏蔽恶心的运营商ip劫持、全面屏蔽广告
屏蔽掉大部分广告的hosts

支持谷狗，优兔，非死不可等等熟悉的国外网站的访问规则来自gfwlist，优兔可以看1080p高清视频无压力，当然前提是你的带宽够用。

写本脚本的缘由：

之前使用adbyby之类的插件严重影响网速，因此才想进一步优化通过dnsmasq和hosts优化屏蔽广告，通过各种努力的查找，终于找到一些更加完善的广告过滤dnsmasq和hosts规则，并进一步优化dnsmasq配置和计划任务的命令行和参数，加入著名的adbyby和ABP插件用的easylistchina规则，加入国外网站广告过滤malwaredomainlist规则，加入手机端著名广告过滤软件adaway用的规则。除了个别视频广告外（PC可以通过浏览器插件屏蔽），基本通过浏览器插件及adbyby等插件能屏蔽的广告应该都能屏蔽了。为了方便小白都能容易上手，已将所有代码编辑为全自动的sh脚本，运行一次，所有事情都搞定了。本人亲测，并已经通过测试。

重要提示：兲朝上网请通过https加密连接访问！该脚本和方法只适用于Openwrt系列内核的固件，包括pandorabox，老毛子等固件不适用。如果不是相应的系统，小白就不用往下看了，以免浪费你宝贵的时间。如果是tomato、padavan等其它固件，可以参考http://www.right.com.cn/forum/forum.php?mod=viewthread&tid=184121帖子自行修改。
PS：如果以前运行过类似脚本或命令，最好恢复出厂设置。
PS：因为有的固件携带的wget命令不支持https下载，需要重装wget。使用该脚本需要将dns设置为潘多拉lan网关（如192.168.1.1）

dnsmas_fqad.sh脚本运行方法：首次更改或路由器恢复出厂设置后，将下载得到的本脚本解压并通过winSCP上传到路由器/etc目录中，进入路由器的webshell或者电脑putty登录后运行命令：/bin/sh /etc/dnsmasq_fqad.sh。小白推荐用此方法，一键轻松搞定。

手动还原设置的方法：
打开/etc/dnsmasq.conf文件，删除如下内容：
# 并发查询所有上游DNS
all-servers
# 添加监听地址（将192.168.1.1修改为你的lan网关ip）
listen-address=192.168.1.1,127.0.0.1
# 添加上游DNS服务器
resolv-file=/etc/dnsmasq/resolv.conf
# 添加额外hosts规则路径
addn-hosts=/etc/dnsmasq/noad.conf
# IP反查域名
bogus-priv
# 添加DNS解析文件
conf-file=/etc/dnsmasq.d/fqad.conf
删除/etc目录中dnsmasq以及dnsmasq.d文件夹
删除路由器设置中系统-计划任务中的代码。

至此，基本能完美的解决扶墙、DNS劫持以及各种广告的问题了。这种方法的弊端就是需要有人持续维护更新，如果发现有不能屏蔽的广告，欢迎大家到https://github.com/vokins/yhosts反馈，作者更新后就可以屏蔽了。

据反馈，LEDE系列系统和Openwrt系列系统略有不同，请用LEDE专用脚本！

特别感谢sy618、vokins提供的线上项目资源以及维护项目所做出的贡献！感谢lukme提供的脚本编译写法！感谢zshwq5提供的注入每日定时任务的代码！
