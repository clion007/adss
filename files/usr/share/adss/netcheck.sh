#!/bin/sh
rm -rf /tmp/baidu.html > /dev/null 2>&1
curl --connect-timeout 9 -o /tmp/baidu.html -s -w %{time_namelookup}: https://www.baidu.com > /dev/null 2>&1
if [[ -f /tmp/baidu.html ]] && [[ `grep -c "百度一下" /tmp/baidu.html` -ge '1' ]]; then
  rm -rf /tmp/baidu.html
else
  wangluo1='1'
  rm -rf /tmp/baidu.html
fi

rm -rf /tmp/sogou.html > /dev/null 2>&1
curl --connect-timeout 9 -o /tmp/sogou.html -s -w %{time_namelookup}: https://www.sogou.com > /dev/null 2>&1
if [[ -f /tmp/sogou.html ]] && [[ `grep -c "搜狗搜索" /tmp/sogou.html` -ge '1' ]]; then
  rm -rf /tmp/sogou.html
else
  wangluo2='2'
  rm -rf /tmp/sogou.html
fi
if [[ "${wangluo1}" == "1" && "${wangluo2}" == "2" ]]; then
  ifdown wan
  sleep 1
  ifup wan
fi
exit 0
