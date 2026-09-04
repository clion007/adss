 #!/bin/sh
message l "开始下载 DNS 广告规则,可能时间较长请耐心等待"
batch_download \
    "${GH_RAW_BASE}/privacy-protection-tools/anti-AD/master/adblock-for-dnsmasq.conf" "${TMP_DIR}/antiAD.conf" \
    "${GH_RAW_BASE}/Cats-Team/AdRules/main/smart-dns.conf" "${TMP_DIR}/cats.conf" \
    "${GH_RAW_BASE}/notracking/hosts-blocklists/master/domains.txt" "${TMP_DIR}/notrackAdDomain.conf" \
    "https://neodev.team/dnsmasq.conf" "${TMP_DIR}/neodevhost.conf"

sed -i 's/$/&127.0.0.1/g' ${TMP_DIR}/antiAD.conf
sed -i "s/\/#/\/127.0.0.1/g" ${TMP_DIR}/cats.conf
sed -i "s/address \//address=\//g" ${TMP_DIR}/cats.conf

sleep 3
message l "创建黑名单缓存"
download "rules/adss/adblacklist" "${TMP_DIR}/adblacklist"
awk '!a[$0]++{message}' ${TMP_DIR}/adblacklist > ${TMP_DIR}/blacklist 
rm -rf ${TMP_DIR}/adblacklist
sed -i "/#/d" ${TMP_DIR}/blacklist # 删除注释
sed -i '/^\s*$/d' ${TMP_DIR}/blacklist # 删除空行
sed -i '/./{s|^|address=/|;s|$|/127.0.0.1|}' ${TMP_DIR}/blacklist # 生成黑名单规则，支持通配符

message l "合并规则缓存"
cat ${TMP_DIR}/antiAD.conf ${TMP_DIR}/notrackAdDomain.conf ${TMP_DIR}/cats.conf ${TMP_DIR}/neodevhost.conf ${TMP_DIR}/blacklist >> ${TMP_DIR}/dnsAd 

message l "删除临时规则文件"
rm -rf ${TMP_DIR}/antiAD.conf ${TMP_DIR}/notrackAdDomain.conf ${TMP_DIR}/cats.conf ${TMP_DIR}/neodevhost.conf ${TMP_DIR}/blacklist

message l "删除注释和本地规则"
sed -i '/localhost/d' ${TMP_DIR}/dnsAd # 删除本地规则
sed -i '/^#/d' ${TMP_DIR}/dnsAd # 删除注释行
sed -i 's/#.*//g' ${TMP_DIR}/dnsAd # 删除行尾注释
sed -i '/^\s*$/d' ${TMP_DIR}/dnsAd # 删除空行
sed -i '/\/$/d' ${TMP_DIR}/dnsAd # 删除dns空规则

message l "统一广告规则格式"
sed -i "s/\/0.0.0.0/\/127.0.0.1/g" ${TMP_DIR}/dnsAd
sed -i "s/[ ][ ]*/ /g" ${TMP_DIR}/dnsAd # 删除多余空格，只保留一个空格
