#!/bin/sh
###仅限潘多拉与openwrt类固件使用###
###仅限潘多拉与openwrt类固件使用###

###请将DNS设置为lan网关###
###请将DNS设置为lan网关###

###该脚本只需要运行一次###
###该脚本只需要运行一次###

# 移动到用户命令文件夹
cd /usr/bin/

# 创建广告规则与更新脚本存放的文件夹 
mkdir -p /etc/dnsmasq
mkdir -p /etc/dnsmasq.d

# dnsmasq.conf 添加广告规则路径
cat >> /etc/dnsmasq.conf <<EOF
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
EOF

# 创建上游DNS配置文件
cat > /etc/dnsmasq/resolv.conf <<EOF
# 上游DNS解析服务器
nameserver 127.0.0.1
nameserver 114.114.114.119
nameserver 223.5.5.5
nameserver 119.29.29.29
EOF

# 下载扶墙和广告规则
# 下载dnsmasq规则
# 下载sy618扶墙规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq -O /etc/dnsmasq.d/fq.conf
# 下载vokins广告规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf -O /etc/dnsmasq.d/ad.conf
# 下载easylistchina广告规则
wget --no-check-certificate -qO - https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt -O /etc/dnsmasq.d/easylistchina.conf
# 合并dnsmasq缓存
cd /etc/dnsmasq.d;cat fq.conf ad.conf easylistchina.conf > fqad
# 删除dnsmasq缓存
rm -rf /etc/dnsmasq.d/ad.conf
rm -rf /etc/dnsmasq.d/fq.conf
rm -rf /etc/dnsmasq.d/easylistchina.conf
# 删除dnsmasq重复规则
sort /etc/dnsmasq.d/fqad | uniq > /etc/dnsmasq.d/fqad.conf
# 删除dnsmasq合并缓存
rm -rf /etc/dnsmasq.d/fqad

# 下载hosts规则
# 下载yhosts缓存
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt -O /etc/dnsmasq/yhosts.conf
# 下载malwaredomainlist?嬖?
wget --no-check-certificate -qO - http://www.malwaredomainlist.com/hostslist/hosts.txt -O /etc/dnsmasq/malwaredomainlist.conf
# 下载adaway规则缓存
wget --no-check-certificate -qO - http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt -O /etc/dnsmasq/adaway.conf
# 合并hosts缓存
cd /etc/dnsmasq;cat yhosts.conf adaway.conf malwaredomainlist.conf > noad
# 删除hosts缓存
rm -rf /etc/dnsmasq/yhosts.conf
rm -rf /etc/dnsmasq/adaway.conf
rm -rf /etc/dnsmasq/malwaredomainlist.conf
# 删除hosts重复规则
sort /etc/dnsmasq/noad | uniq > /etc/dnsmasq/noad.conf
# 删除hosts合并缓存
rm -rf /etc/dnsmasq/noad

# 重启dnsmasq服务
killall dnsmasq
/usr/sbin/dnsmasq

# 创建规则更新脚本
cat > /etc/dnsmasq/fqad_update.sh <<EOF
#!/bin/sh
# 移动到用户命令文件夹
cd /usr/bin/

# 下载dnsmasq规则
# 下载sy618扶墙规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq -O /etc/dnsmasq.d/fq.conf
# 下载vokins广告规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf -O /etc/dnsmasq.d/ad.conf
# 下载easylistchina广告规则
wget --no-check-certificate -qO - https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt -O /etc/dnsmasq.d/easylistchina.conf
# 合并dnsmasq缓存
cd /etc/dnsmasq.d;cat fq.conf ad.conf easylistchina.conf > fqad
# 删除dnsmasq缓存
rm -rf /etc/dnsmasq.d/ad.conf
rm -rf /etc/dnsmasq.d/fq.conf
rm -rf /etc/dnsmasq.d/easylistchina.conf
# 删除dnsmasq重复规则
sort /etc/dnsmasq.d/fqad | uniq > /etc/dnsmasq.d/fqad.conf
# 删除dnsmasq合并缓存
rm -rf /etc/dnsmasq.d/fqad

# 下载hosts规则
# 下载yhosts缓存
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt -O /etc/dnsmasq/yhosts.conf
# 下载malwaredomainlist规则
wget --no-check-certificate -qO - http://www.malwaredomainlist.com/hostslist/hosts.txt -O /etc/dnsmasq/malwaredomainlist.conf
# 下载adaway规则缓存
wget --no-check-certificate -qO - http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt -O /etc/dnsmasq/adaway.conf
# 合并hosts缓存
cd /etc/dnsmasq;cat yhosts.conf adaway.conf malwaredomainlist.conf > noad
# 删除hosts缓存
rm -rf /etc/dnsmasq/yhosts.conf
rm -rf /etc/dnsmasq/adaway.conf
rm -rf /etc/dnsmasq/malwaredomainlist.conf
# 删除hosts重复规则
sort /etc/dnsmasq/noad | uniq > /etc/dnsmasq/noad.conf
# 删除hosts合并缓存
rm -rf /etc/dnsmasq/noad

# 重启dnsmasq服务
killall dnsmasq
/usr/sbin/dnsmasq
EOF

# 注入每天更新一次的任务
chmod 755 /etc/dnsmasq/fqad_update.sh
#http_username=`nvram get http_username`
sed -i '/fqad_update/d' /etc/crontabs/root

cat >> /etc/crontabs/root <<EOF
# 每天5点30分更新dnsmasq和hosts规则
30 5 * * * /bin/sh /etc/dnsmasq/fqad_update.sh
EOF
