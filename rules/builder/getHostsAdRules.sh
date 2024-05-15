 #!/bin/bash
echo -e "\e[1;36m 开始下载Hosts规则\e[0m"
echo 
echo -e "\e[1;36m 下载someonewhocares缓存\e[0m"
curl -sSO https://someonewhocares.org/hosts/zero/hosts -o /tmp/adss/someonewhocares.conf
echo 
echo -e "\e[1;36m 下载adaway规则缓存\e[0m"
curl -sSO https://adaway.org/hosts.txt  /tmp/adss/adaway.conf
echo 
echo -e "\e[1;36m 合并hosts缓存\e[0m"
cat /tmp/adss/someonewhocares.conf /tmp/adss/adaway.conf > /tmp/adss/hostsAd
echo 
echo -e "\e[1;36m 删除hosts临时文件\e[0m"
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
