 #!/bin/sh
message l "开始下载 Hosts 规则"
curl https://someonewhocares.org/hosts/zero/hosts -sSo ${TMP_DIR}/someonewhocares.conf
download "${GH_RAW_BASE}/jdlingyu/ad-wars/master/hosts" "${TMP_DIR}/adwars.conf"
curl https://adaway.org/hosts.txt -sSo ${TMP_DIR}/adaway.conf

message l "合并 hosts 规则缓存"
cat ${TMP_DIR}/someonewhocares.conf ${TMP_DIR}/adwars.conf ${TMP_DIR}/adaway.conf > ${TMP_DIR}/hostsAd 

message l "删除 hosts 临时文件"
rm -rf ${TMP_DIR}/someonewhocares.conf ${TMP_DIR}/adaway.conf

message l "删除注释和本地规则"
sed -i '/#<localhost/,/#<\/localhost>/d' ${TMP_DIR}/hostsAd
sed -i '/local/d' ${TMP_DIR}/hostsAd
sed -i 's/#.*//g' ${TMP_DIR}/hostsAd
sed -i 's/@.*//g' ${TMP_DIR}/hostsAd
sed -i '/^\s*$/d' ${TMP_DIR}/hostsAd

message l "统一广告规则格式"
sed -i "s/[ ][ ]*/ /g" ${TMP_DIR}/hostsAd
sed -i "s/0.0.0.0/127.0.0.1/g" ${TMP_DIR}/hostsAd
