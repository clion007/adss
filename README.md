# 全自动 DNS 智能脚本（ADSS）

<div align="center">
  <img src="https://raw.gitcode.com/clion/adss/raw/master/images/logo.svg" alt="ADSS Logo" width="200">
  <p><strong>Auto DNS Smart Script - 小巧、方便、全自动的 DNS 智能管理工具</strong></p>
  <p>
    <a href="https://github.com/clion007/adss/actions"><img src="https://img.shields.io/github/workflow/status/clion007/adss/构建并发布%20ADSS" alt="构建状态"></a>
    <a href="https://github.com/clion007/adss/releases/latest"><img src="https://img.shields.io/github/v/release/clion007/adss" alt="最新版本"></a>
    <a href="https://github.com/clion007/adss/blob/master/LICENSE"><img src="https://img.shields.io/github/license/clion007/adss" alt="许可证"></a>
    <a href="https://github.com/clion007/adss/stargazers"><img src="https://img.shields.io/github/stars/clion007/adss" alt="Stars"></a>
    <a href="https://github.com/clion007/adss/network/members"><img src="https://img.shields.io/github/forks/clion007/adss" alt="Forks"></a>
    <a href="https://github.com/clion007/adss/issues"><img src="https://img.shields.io/github/issues/clion007/adss" alt="Issues"></a>
  </p>
</div>

## 📖 项目介绍

**ADSS**（Auto DNS Smart Script）由原来的 clion007/dnsmasq 脚本发展而来，是一个小巧、方便且全自动配置 dnsmasq 的工具，适用于家庭网络智能路由器。支持openwrt的IPK软件包是新写的，并没有经过充分测试，，可能问题较多，如有需要建议先用纯shell版本，IPK版本我充分测试后再使用。

### ADSS的主要作用与优势：

- 🚀 **配置简单**：快速部署，免维护
- 🛡️ **广告过滤**：基于 dnsmasq 的广告拦截功能
- 🔒 **防污染**：域名解析防污染、防追踪
- ✏️ **自定义**：支持用户自定义黑白名单和 DNS 解析重定向

### 🔍 什么是 Dnsmasq？

Dnsmasq 是一个小巧且方便的 DNS 和 DHCP 配置工具，适用于小型网络。它提供了 DNS 功能和可选择的 DHCP 功能，服务于那些只在本地适用的域名。

### Dnsmasq 能解决什么问题？

- 🚫 **拦截广告**：屏蔽恶心的运营商 IP 劫持和各类广告
- 🔍 **优化解析**：分域名 DNS 解析，提升不同网站的访问速度
- 🔄 **纠正错误**：纠正错误的 DNS 解析记录
- 🛡️ **安全保障**：保证上网更加安全

## 💻 安装方法

### 方法一：通过自定义软件源安装（推荐）

1. 添加 ADSS 自定义软件源：
```bash
curl -fsSL https://raw.githubusercontent.com/clion007/adss/master/installer/add_custom_repo.sh | sh
```

2. 更新软件源并安装 ADSS：
```bash
opkg update && opkg install adss luci-app-adss
```

### 方法二：通过安装脚本安装

使用 putty 软件登录路由器或者 web 端登录路由器，进入 tty 终端，输入以下命令行回车：
```bash
mkdir -p /tmp/adss && curl https://raw.gitcode.com/clion/adss/raw/master/adss.sh -sSLo /tmp/adss/adss.sh && sh /tmp/adss/adss.sh
```

> **注意**：putty 运行脚本显示乱码的问题请设置 putty 软件的编码为 UTF-8。

### 方法三：手动下载 IPK 包安装

1. 访问 [ADSS 发布页面](https://github.com/clion007/adss/releases/latest)
2. 下载适合您路由器架构的 IPK 包
3. 上传到路由器并使用以下命令安装：
```bash
opkg install /path/to/adss_x.x.x_arch.ipk
opkg install /path/to/luci-app-adss_x.x.x_all.ipk
```

## 🔧 编译 OpenWrt 固件时安装 ADSS

如果您正在自行编译 OpenWrt 固件，可以按照以下步骤将 ADSS 内置到固件中：

### 方法一：使用 feeds 方式添加

1. 在 OpenWrt 源码目录下创建自定义 feeds 配置文件：
```bash
cat >> feeds.conf.default << EOF
src-git adss https://github.com/clion007/adss.git
EOF
```

2. 更新并安装 feeds：
```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

3. 在 menuconfig 中选择 ADSS 软件包：
```bash
make menuconfig
```

在 menuconfig 界面中，导航到：
- `LuCI` -> `Applications` -> `luci-app-adss`
- `Network` -> `adss`

选中这两个软件包后保存配置并退出。

4. 编译固件：
```bash
make -j$(nproc)
```

### 方法二：直接添加软件包源码

1. 克隆 ADSS 仓库到 OpenWrt 的 package 目录：
```bash
git clone https://github.com/clion007/adss.git package/adss
```

2. 在 menuconfig 中选择 ADSS 软件包：
```bash
make menuconfig
```

在 menuconfig 界面中，导航到：
- `LuCI` -> `Applications` -> `luci-app-adss`
- `Network` -> `adss`

选中这两个软件包后保存配置并退出。

3. 编译固件：
```bash
make -j$(nproc)
```

### 方法三：使用 OpenWrt SDK 单独编译 IPK

如果您只想编译 ADSS 的 IPK 包而不是整个固件：

1. 下载适合您目标设备的 OpenWrt SDK

2. 解压 SDK 并进入目录：
```bash
tar -xJf openwrt-sdk-*.tar.xz
cd openwrt-sdk-*
```

3. 添加 ADSS 源码：
```bash
git clone https://github.com/clion007/adss.git package/adss
```

4. 编译 ADSS 软件包：
```bash
make package/adss/compile V=s
```

编译完成后，IPK 文件将位于 `bin/packages/架构/base/` 目录下。

## 卸载方法

如果您需要卸载 ADSS 软件包，可以按照以下步骤操作：

### 方法一：通过包管理器卸载

如果您是通过 IPK 包安装的 ADSS，可以使用以下命令卸载：

```bash
opkg remove luci-app-adss adss
```
注意 ：建议先卸载 luci-app-adss ，再卸载 adss ，这样可以避免可能的依赖问题。

卸载后，系统会自动清理 ADSS 的相关文件和配置。如果发现有残留文件，可以手动执行以下命令清理：

```bash
rm -rf /etc/dnsmasq.d/adss /usr/share/adss /var/log/adss*.log /tmp/adss_*.log /etc/opkg/customfeeds.d/adss.conf
rm -f /usr/bin/adss-config
```

### 方法二：通过卸载脚本卸载

如果您是通过纯shell脚本安装脚本安装的 ADSS，可以使用以下命令卸载：

```bash
curl https://raw.gitcode.com/clion/adss/raw/master/installer/uninstall.sh -sSLo /tmp/uninstall.sh && sh /tmp/uninstall.sh
```


## ⚠️ 注意事项

- 如果发现配置后 DNS 解析出现问题，可以 IP 登录路由器，用 `dnsmasq --test` 命令行检测配置的问题
- 如果以前运行过类似脚本或命令，最好恢复出厂设置
- 有的固件携带的 wget 命令不支持 https 下载，需要重装 wget
- 本脚本为路由使用，非交换机使用，如果你将路由器的 lan 口链接了上级路由器的 lan 口，此路由即变为交换机，无法使用本脚本
- 如果使用脚本中的软件更新以及安装功能，请确保使用官方的固件

## 🔄 更新与维护

ADSS 提供了自动更新机制，默认每天凌晨 4:25 自动更新规则。您也可以手动运行更新脚本：

```bash
/usr/share/adss/update.sh
```

## 🌐 仓库镜像

1. [GitHub ADSS 项目](https://github.com/clion007/adss)
2. [Gitee ADSS 项目](https://gitee.com/clion007/adss)
3. [Gitcode ADSS 项目](https://gitcode.net/clion007/adss)

## 🙏 致谢

- 感谢规则维护者提供的线上项目资源以及维护项目所做出的贡献！
- 感谢 lukme 提供的脚本编译写法！
- 感谢 zshwq5 为后续优化给的建议！

## ⚖️ 免责声明

本项目所有重定向数据仅用于个人学术研究与学习使用。从未用于产生盈利行为（包括"捐赠"等方式）。
未经许可，请勿内置于软件内发布与传播。请勿用于产生任何盈利活动。
仅供个人免费使用。请遵守当地法律法规，文明上网。
