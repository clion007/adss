#!/bin/sh
###仅限潘多拉与openwrt类固件使用###

###请将DNS设置为lan网关###

###该脚本只需要运行一次###

###----------------------------------------script by Clion----------------------------------------###
# https://github.com/clion007/dnsmasq

# 移动到用户命令文件夹
cd /usr/bin/
# 创建规则与更新脚本存放的文件夹 
mkdir -p /etc/dnsmasq.d

# dnsmasq.conf 添加广告规则路径
cat >> /etc/dnsmasq.conf <<EOF
# 并发查询所有上游DNS
all-servers

# 添加监听地址（将192.168.1.1修改为你的lan网关ip）
listen-address=192.168.1.1,127.0.0.1

# 添加上游DNS服务器
resolv-file=/etc/dnsmasq.d/resolv.conf

# IP反查域名
bogus-priv

# 添加DNS解析文件
conf-file=/etc/dnsmasq.d/fq.conf
EOF
# 创建上游DNS配置文件
cat > /etc/dnsmasq.d/resolv.conf <<EOF
# 上游DNS解析服务器
nameserver 127.0.0.1
nameserver 114.114.114.119
nameserver 223.5.5.5
nameserver 119.29.29.29
EOF

# 开始下载dnsmasq规则
# 下载sy618规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq > /etc/dnsmasq.d/sy168.conf
# 下载racaljk规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf > /etc/dnsmasq.d/racaljk.conf
# 删除racaljk规则中google相关规则
sed -i '/google/d' /etc/dnsmasq.d/racaljk.conf
sed -i '/youtube/d' /etc/dnsmasq.d/racaljk.conf
# 合并dnsmasq缓存
cd /etc/dnsmasq.d;cat racaljk.conf sy168.conf > fq
# 删除dnsmasq缓存
rm -rf /etc/dnsmasq.d/sy168.conf
rm -rf /etc/dnsmasq.d/racaljk.conf
# 删除dnsmasq重复规则
sort /etc/dnsmasq.d/fq | uniq > /etc/dnsmasq.d/fq.conf
# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq.d/fq.conf
# 删除规则合并缓存
rm -rf /etc/dnsmasq.d/fq
# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq.d/fq.conf
# 下载dnsmasq规则结束

# 重启dnsmasq服务
killall dnsmasq
/usr/sbin/dnsmasq

# 创建规则更新脚本
cat > /etc/dnsmasq.d/fq_update.sh <<EOF
#!/bin/sh
# 移动到用户命令文件夹
cd /usr/bin/

# 开始更新dnsmasq规则
# 下载sy618规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/sy618/hosts/master/dnsmasq/dnsfq > /etc/dnsmasq.d/sy168.conf
# 下载racaljk规则
wget --no-check-certificate -qO - https://raw.githubusercontent.com/racaljk/hosts/master/dnsmasq.conf > /etc/dnsmasq.d/racaljk.conf
# 删除racaljk规则中google相关规则
sed -i '/google/d' /etc/dnsmasq.d/racaljk.conf
sed -i '/youtube/d' /etc/dnsmasq.d/racaljk.conf
# 合并dnsmasq缓存
cd /etc/dnsmasq.d;cat racaljk.conf sy168.conf > fq
# 删除dnsmasq缓存
rm -rf /etc/dnsmasq.d/sy168.conf
rm -rf /etc/dnsmasq.d/racaljk.conf
# 删除dnsmasq重复规则
sort /etc/dnsmasq.d/fq | uniq > /etc/dnsmasq.d/fq.conf
# 删除规则合并缓存
rm -rf /etc/dnsmasq.d/fq
# 删除无用的注释
sed -i '/#/d' /etc/dnsmasq.d/fq.conf
# dnsmasq规则更新结束

# 重启dnsmasq服务
killall dnsmasq
/usr/sbin/dnsmasq
EOF

# 注入每天更新一次的任务
chmod 755 /etc/dnsmasq.d/fq_update.sh
#http_username=`nvram get http_username`
sed -i '/fq_update/d' /etc/crontabs/root

cat >> /etc/crontabs/root <<EOF
# 每天5点30分更新dnsmasq规则
30 5 * * * /bin/sh /etc/dnsmasq.d/fq_update.sh
EOF
