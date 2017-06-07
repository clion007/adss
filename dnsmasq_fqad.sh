#!/bin/sh
###仅限潘多拉与openwrt类固件使用###

###请将DNS设置为lan网关###

###该脚本只需要运行一次###

###----------------------------------------script by Clion----------------------------------------###
# https://github.com/clion007/dnsmasq

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

# 开始下载扶墙和广告规则

# 下载dnsmasq规则
# # 下载sy618规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq > /etc/dnsmasq.d/sy168.conf
# 下载racaljk规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf > /etc/dnsmasq.d/racaljk.conf
# 下载vokins广告规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf > /etc/dnsmasq.d/ad.conf
# 下载easylistchina广告规则
wget --no-check-certificate -qO - https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt > /etc/dnsmasq.d/easylistchina.conf
# 删除racaljk规则中google相关规则
sed -i '/google/d' /etc/dnsmasq.d/racaljk.conf
sed -i '/youtube/d' /etc/dnsmasq.d/racaljk.conf
# 合并dnsmasq缓存
cd /etc/dnsmasq.d;cat racaljk.conf sy168.conf ad.conf easylistchina.conf > fqad
# 删除dnsmasq缓存
rm -rf /etc/dnsmasq.d/ad.conf
rm -rf /etc/dnsmasq.d/sy168.conf
rm -rf /etc/dnsmasq.d/racaljk.conf
rm -rf /etc/dnsmasq.d/easylistchina.conf
# 删除dnsmasq重复规则
sort /etc/dnsmasq.d/fqad | uniq > /etc/dnsmasq.d/fqad.conf
# 删除dnsmasq合并缓存
rm -rf /etc/dnsmasq.d/fqad
# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq.d/fqad.conf

# 下载hosts规则
# 下载yhosts缓存
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt > /etc/dnsmasq/yhosts.conf
# 下载malwaredomainlist?嬖?
wget --no-check-certificate -qO - http://www.malwaredomainlist.com/hostslist/hosts.txt > /etc/dnsmasq/malwaredomainlist.conf
# 下载adaway规则缓存
wget --no-check-certificate -qO - http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt > /etc/dnsmasq/adaway.conf
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
# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq/noad.conf
# 扶墙和广告屏蔽规则下载结束

# 重启dnsmasq服务
killall dnsmasq
/usr/sbin/dnsmasq

# 创建规则更新脚本
cat > /etc/dnsmasq/fqad_update.sh <<EOF
#!/bin/sh
# 移动到用户命令文件夹
cd /usr/bin/

# 开始更新dnsmasq规则
# # 下载sy618规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq > /etc/dnsmasq.d/sy168.conf
# 下载racaljk规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf > /etc/dnsmasq.d/racaljk.conf
# 下载vokins广告规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf > /etc/dnsmasq.d/ad.conf
# 下载easylistchina广告规则
wget --no-check-certificate -qO - https://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt > /etc/dnsmasq.d/easylistchina.conf
# 删除racaljk规则中google相关规则
sed -i '/google/d' /etc/dnsmasq.d/racaljk.conf
sed -i '/youtube/d' /etc/dnsmasq.d/racaljk.conf
# 合并dnsmasq缓存
cd /etc/dnsmasq.d;cat racaljk.conf sy168.conf ad.conf easylistchina.conf > fqad
# 删除dnsmasq缓存
rm -rf /etc/dnsmasq.d/ad.conf
rm -rf /etc/dnsmasq.d/sy168.conf
rm -rf /etc/dnsmasq.d/racaljk.conf
rm -rf /etc/dnsmasq.d/easylistchina.conf
# 删除dnsmasq重复规则
sort /etc/dnsmasq.d/fqad | uniq > /etc/dnsmasq.d/fqad.conf
# 删除dnsmasq合并缓存
rm -rf /etc/dnsmasq.d/fqad
# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq.d/fqad.conf
# dnsmasq规则更新结束

# 开始更新hosts规则
# 下载yhosts缓存
wget --no-check-certificate -qO - https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt > /etc/dnsmasq/yhosts.conf
# 下载malwaredomainlist?嬖?
wget --no-check-certificate -qO - http://www.malwaredomainlist.com/hostslist/hosts.txt > /etc/dnsmasq/malwaredomainlist.conf
# 下载adaway规则缓存
wget --no-check-certificate -qO - http://77l5b4.com1.z0.glb.clouddn.com/hosts.txt > /etc/dnsmasq/adaway.conf
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
# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq/noad.conf
# hosts规则更新结束

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
