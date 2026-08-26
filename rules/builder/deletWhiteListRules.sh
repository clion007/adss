 #!/bin/sh
message l "删除白名单及误杀规则，时间较长，请耐心等待。。。"
download "rules/adss/adwhitelist" "${TMP_DIR}/adwhitelist"
cat ${TMP_DIR}/adwhitelist | uniq > ${TMP_DIR}/whitelist 
sed -i "/#/d" ${TMP_DIR}/whitelist
rm -rf ${TMP_DIR}/adwhitelist
while read -r line
do
	if [ -s "${TMP_DIR}/dnsAd" ]; then 
		sed -i "/$line/d" ${TMP_DIR}/dnsAd
	fi
	if [ -s "${TMP_DIR}/hostsAd" ]; then 
		sed -i "/$line/d" ${TMP_DIR}/hostsAd
	fi
done < ${TMP_DIR}/whitelist
rm -rf ${TMP_DIR}/whitelist
message g "删除白名单及误杀规则完成！"
