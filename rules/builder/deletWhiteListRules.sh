 #!/bin/sh
message l "删除白名单及误杀规则"
download "rules/adss/adwhitelist" "${TMP_DIR}/adwhitelist"
cat ${TMP_DIR}/adwhitelist | uniq > ${TMP_DIR}/whitelist
rm -rf ${TMP_DIR}/adwhitelist
# strip comments and empty lines (an empty pattern line would match every line)
sed -i '/#/d' ${TMP_DIR}/whitelist
sed -i '/^[[:space:]]*$/d' ${TMP_DIR}/whitelist
# filter as fixed strings in a single pass: no regex injection, much faster than per-line sed -i
if [ -s "${TMP_DIR}/whitelist" ]; then
	grep -vF -f ${TMP_DIR}/whitelist ${TMP_DIR}/dnsAd > ${TMP_DIR}/dnsAd.tmp && mv -f ${TMP_DIR}/dnsAd.tmp ${TMP_DIR}/dnsAd
	grep -vF -f ${TMP_DIR}/whitelist ${TMP_DIR}/hostsAd > ${TMP_DIR}/hostsAd.tmp && mv -f ${TMP_DIR}/hostsAd.tmp ${TMP_DIR}/hostsAd
fi
rm -rf ${TMP_DIR}/whitelist
message g "删除白名单及误杀规则完成！"
