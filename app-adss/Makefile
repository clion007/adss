include $(TOPDIR)/rules.mk

PKG_NAME:=adss
PKG_VERSION:=4.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/adss
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Auto DNS Smart Script
  DEPENDS:=+dnsmasq-full
  PKGARCH:=all
endef

define Package/adss/description
  ADSS is an automatic DNS filtering system based on dnsmasq
endef

define Package/adss/conffiles
/etc/config/adss
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
	# 检查 src 目录是否存在，如果存在则复制
	if [ -d "./src" ]; then \
		$(CP) ./src/* $(PKG_BUILD_DIR)/; \
	fi
endef

define Build/Configure
endef

define Build/Compile
	# 这里不需要编译，因为是脚本文件
endef

define Package/adss/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/adss.config $(1)/etc/config/adss
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/adss.init $(1)/etc/init.d/adss
	
	$(INSTALL_DIR) $(1)/usr/share/adss
	# 检查文件是否存在，如果存在则安装
	if [ -f "./src/rules_update.sh" ]; then \
		$(INSTALL_BIN) ./src/rules_update.sh $(1)/usr/share/adss/rules_update.sh; \
	fi
	if [ -f "./src/netcheck.sh" ]; then \
		$(INSTALL_BIN) ./src/netcheck.sh $(1)/usr/share/adss/netcheck.sh; \
	fi
	$(INSTALL_BIN) ./files/check_config.sh $(1)/usr/share/adss/check_config.sh
	$(INSTALL_BIN) ./files/test_rules.sh $(1)/usr/share/adss/test_rules.sh
	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/adss-config $(1)/usr/bin/adss-config
	
	$(INSTALL_DIR) $(1)/var/log
	touch $(1)/var/log/adss.log
	touch $(1)/var/log/adss_update.log
endef

define Package/adss/prerm
	$(INSTALL_BIN) ./files/prerm $(1)/CONTROL/prerm
endef

$(eval $(call BuildPackage,adss))