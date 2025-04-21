#!/bin/sh

# 添加 ADSS 自定义软件源
# 此脚本用于在 OpenWrt 系统中添加 ADSS 的自定义软件源

echo "开始添加 ADSS 自定义软件源..."

# 检测系统架构
ARCH=$(uname -m)
case "$ARCH" in
    "x86_64")
        REPO_ARCH="x86_64"
        ;;
    "i686"|"i386")
        REPO_ARCH="x86"
        ;;
    "aarch64"|"arm64")
        REPO_ARCH="aarch64_generic"
        ;;
    "armv7l"|"armv7"*)
        REPO_ARCH="arm_cortex-a7"
        ;;
    "mips")
        REPO_ARCH="mips_24kc"
        ;;
    *)
        echo "不支持的架构: $ARCH"
        echo "请手动下载适合您系统的 IPK 包进行安装"
        exit 1
        ;;
esac

# 添加软件源
mkdir -p /etc/opkg/customfeeds.d/
cat > /etc/opkg/customfeeds.d/adss.conf << EOF
# ADSS 自定义软件源
src/gz adss_packages https://clion007.github.io/adss/releases/latest/$REPO_ARCH
EOF

echo "ADSS 自定义软件源已添加"
echo "请运行以下命令更新软件源并安装 ADSS:"
echo "opkg update"
echo "opkg install adss luci-app-adss"

exit 0