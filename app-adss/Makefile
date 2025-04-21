include $(TOPDIR)/rules.mk

PKG_NAME:=adss
PKG_VERSION:=4.2
PKG_RELEASE:=1

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

define Package/adss/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/adss.config $(1)/etc/config/adss
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/adss.init $(1)/etc/init.d/adss
	
	$(INSTALL_DIR) $(1)/usr/share/adss
	$(INSTALL_BIN) ./src/rules_update.sh $(1)/usr/share/adss/rules_update.sh
	$(INSTALL_BIN) ./src/netcheck.sh $(1)/usr/share/adss/netcheck.sh
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