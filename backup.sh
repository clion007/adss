#!/bin/sh
CRON_FILE=/etc/crontabs/$USER
echo -e "\e[1;36m 创建dnsmasq规则与更新脚本存放的文件夹\e[0m"
echo
echo -e "\e[1;36m 检测和备份当前dnsmasq配置信息\e[0m"
if [ -d /etc/dnsmasq ]; then
	if [ -d /etc/dnsmasq.bak ]; then
		filedir1=/etc/dnsmasq
		for file1 in ${filedir1}/*
		do
			filename1=`basename $file1`
			if ( ! cmp -s $filedir1/$filename1 /etc/dnsmasq.bak/$filename1 ); then
				cp -f $filedir1/$filename1 /etc/dnsmasq.bak/$filename1
			fi
		done
		else
		cp -r /etc/dnsmasq /etc/dnsmasq.bak
	fi	
	cat 1 > /etc/dnsmasq/originalState
	else
	mkdir -p /etc/dnsmasq
fi
if [ -d /etc/dnsmasq.d ]; then
	if [ -d /etc/dnsmasq.d.bak ]; then
		filedir2=/etc/dnsmasq.d
		for file2 in ${filedir2}/*
		do
			filename2=`basename $file2`
			if ( ! cmp -s $filedir2/$filename2 /etc/dnsmasq.d.bak/$filename2 ); then
				cp -f $filedir2/$filename2 /etc/dnsmasq.d.bak/$filename2
			fi
		done
		else
		cp -r /etc/dnsmasq.d /etc/dnsmasq.d.bak
	fi	
	cat 1 > /etc/dnsmasq.d/originalState
	else
	mkdir -p /etc/dnsmasq.d
fi
if [ -f /etc/dnsmasq.conf ]; then
	if [ ! -f /etc/dnsmasq.conf.bak ]; then
		cp -p /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
	fi	
	else
	echo "" > /etc/dnsmasq.conf
fi
if [ -f $CRON_FILE ]; then
	if [ ! -f $CRON_FILE.bak ]; then
		cp -p $CRON_FILE $CRON_FILE.bak
	fi	
	else
	echo "" > $CRON_FILE
fi
