#!/bin/sh
###仅限LEDE固件使用###

###请将DNS设置为lan网关###

###该脚本只需要运行一次###

###----------------------------------------script by Clion----------------------------------------###
# https://github.com/clion007/dnsmasq

#安装wget
opkg update && opkg install wget 2>&1 &

# 移动到用户命令文件夹
cd /usr/bin/

# 创建广告规则与更新脚本存放的文件夿
mkdir -p /etc/dnsmasq
mkdir -p /etc/dnsmasq.d

# dnsmasq.conf 添加广告规则路径
cat >> /etc/dnsmasq.conf <<EOF

# 并发查询所有上游DNS
all-servers

# 添加监听地址（将192.168.1.1修改为你的lan网关ip＿
listen-address=192.168.1.1,127.0.0.1

# 添加上游DNS服务噿
resolv-file=/etc/dnsmasq/resolv.conf

# 添加额外hosts规则路径
addn-hosts=/etc/dnsmasq/noad.conf

# IP反查域名
bogus-priv

# 添加DNS解析文件
conf-file=/etc/dnsmasq.d/fqad.conf
EOF

# 创建上游DNS配置文件
cat > /etc/dnsmasq/resolv.conf <<EOF
# DNS上游解析服务器
nameserver 127.0.0.1
nameserver 114.114.114.119
nameserver 223.5.5.5
nameserver 119.29.29.29
EOF

# 开始下载扶墙和广告规

# 下载dnsmasq规则
# 下载sy618扶墙规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/sy618.conf https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq

# 下载racaljk规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/racaljk.conf https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf

# 下载vokins广告规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/ad.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf

# 下载easylistchina广告规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/easylistchina.conf https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt

# 删除racaljk规则中google相关规则
sed -i '/google/d' /etc/dnsmasq.d/racaljk.conf
sed -i '/youtube/d' /etc/dnsmasq.d/racaljk.conf

# 合并dnsmasq缓存
cat /tmp/racaljk.conf /tmp/sy618.conf /tmp/ad.conf /tmp/easylistchina.conf > /tmp/fqad

# 删除dnsmasq缓存
rm -rf /tmp/ad.conf
rm -rf /tmp/sy618.conf
rm -rf /tmp/racaljk.conf
rm -rf /tmp/easylistchina.conf

# 删除dnsmasq重复规则
sort /tmp/fqad | uniq > /etc/dnsmasq.d/fqad.conf

# 删除dnsmasq合并缓存
rm -rf /tmp/fqad

# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq.d/fqad.conf

# 下载hosts规则
# 下载yhosts缓存
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/yhosts.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt

# 下载malwaredomainlist规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/malwaredomainlist.conf http://www.malwaredomainlist.com/hostslist/hosts.txt

# 下载adaway规则缓存
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/adaway.conf http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt

# 合并hosts缓存
cat /tmp/yhosts.conf /tmp/adaway.conf /tmp/malwaredomainlist.conf > /tmp/noad

# 删除hosts缓存
rm -rf /tmp/yhosts.conf
rm -rf /tmp/adaway.conf
rm -rf /tmp/malwaredomainlist.conf

# 删除hosts重复规则
sort /tmp/noad | uniq > /etc/dnsmasq/noad.conf

# 删除hosts合并缓存
rm -rf /tmp/noad

# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq/noad.conf
# 扶墙和广告屏蔽规则下载结束

# 重启dnsmasq服务
killall dnsmasq
/etc/init.d/dnsmasq restart
#/usr/sbin/dnsmasq

# 创建规则更新脚本
cat > /etc/dnsmasq/fqad_update.sh <<EOF
#!/bin/sh
# 移动到用户命令文件夹
cd /usr/bin/

# 开始更新dnsmasq规则
# 下载sy618扶墙规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/sy618.conf https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq

# 下载racaljk规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/racaljk.conf https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf

# 下载vokins广告规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/ad.conf https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf

# 下载easylistchina广告规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/easylistchina.conf https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt

# 删除racaljk规则中google相关规则
sed -i '/google/d' /etc/dnsmasq.d/racaljk.conf
sed -i '/youtube/d' /etc/dnsmasq.d/racaljk.conf

# 合并dnsmasq缓存
cat /tmp/racaljk.conf /tmp/sy618.conf /tmp/ad.conf /tmp/easylistchina.conf > /tmp/fqad

# 删除dnsmasq缓存
rm -rf /tmp/ad.conf
rm -rf /tmp/sy618.conf
rm -rf /tmp/racaljk.conf
rm -rf /tmp/easylistchina.conf

# 删除dnsmasq重复规则
sort /tmp/fqad | uniq > /etc/dnsmasq.d/fqad.conf

# 删除dnsmasq合并缓存
rm -rf /tmp/fqad

# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq.d/fqad.conf
# dnsmasq规则更新结束

# 开始更新hosts规则
# 下载yhosts缓存
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/yhosts.conf https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt

# 下载malwaredomainlist规则
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/malwaredomainlist.conf http://www.malwaredomainlist.com/hostslist/hosts.txt

# 下载adaway规则缓存
/usr/bin/wget-ssl --no-check-certificate -q -O /tmp/adaway.conf http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt

# 合并hosts缓存
cat /tmp/yhosts.conf /tmp/adaway.conf /tmp/malwaredomainlist.conf > /tmp/noad

# 删除hosts缓存
rm -rf /tmp/yhosts.conf
rm -rf /tmp/adaway.conf
rm -rf /tmp/malwaredomainlist.conf

# 删除hosts重复规则
sort /tmp/noad | uniq > /etc/dnsmasq/noad.conf

# 删除hosts合并缓存
rm -rf /tmp/noad

# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq/noad.conf
# hosts规则更新结束

# 重启dnsmasq服务
killall dnsmasq
/etc/init.d/dnsmasq restart
#/usr/sbin/dnsmasq
EOF

# 注入每天更新一次的任务
chmod 755 /etc/dnsmasq/fqad_update.sh
#http_username=`nvram get http_username`
sed -i '/fqad_update/d' /etc/crontabs/root

cat >> /etc/crontabs/root <<EOF
# 每天5炿0分更新dnsmasq和hosts规则
30 5 * * * /bin/sh /etc/fqad_update.sh
EOF
