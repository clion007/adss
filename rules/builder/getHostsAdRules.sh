 #!/bin/sh
echo -e "\e[1;36m 开始下载 Hosts 规则\e[0m"
echo 
echo -e "\e[1;36m 下载 someonewhocares 缓存\e[0m"
curl https://someonewhocares.org/hosts/zero/hosts -sLSo /tmp/adss/someonewhocares.conf
echo 
echo -e "\e[1;36m 下载大圣净化缓存\e[0m"
curl https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts -sLSo /tmp/adss/adwars.conf
echo
echo -e "\e[1;36m 下载 adaway 规则缓存\e[0m"
curl https://adaway.org/hosts.txt -sLSo /tmp/adss/adaway.conf
echo 
echo -e "\e[1;36m 合并 hosts 缓存\e[0m"
cat /tmp/adss/someonewhocares.conf /tmp/adss/adwars.conf /tmp/adss/adaway.conf > /tmp/adss/hostsAd 
echo 
echo -e "\e[1;36m 删除 hosts 临时文件\e[0m"
rm -rf /tmp/adss/someonewhocares.conf /tmp/adss/adaway.conf
echo 
echo -e "\e[1;36m 删除注释和本地规则\e[0m"
sed -i '/#<localhost/,/#<\/localhost>/d' /tmp/adss/hostsAd
sed -i '/local/d' /tmp/adss/hostsAd
sed -i 's/#.*//g' /tmp/adss/hostsAd
sed -i 's/@.*//g' /tmp/adss/hostsAd
sed -i '/^$/d' /tmp/adss/hostsAd
echo 
echo -e "\e[1;36m 统一广告规则格式\e[0m"
sed -i "s/[ ][ ]*/ /g" /tmp/adss/hostsAd
sed -i "s/0.0.0.0/127.0.0.1/g" /tmp/adss/hostsAd
