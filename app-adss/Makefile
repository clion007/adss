include $(TOPDIR)/rules.mk

PKG_NAME:=adss
PKG_VERSION:=4.2
PKG_RELEASE:=1

PKG_MAINTAINER:=clion007
PKG_LICENSE:=GPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/adss
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ADSS - Auto DNS Smart Script
  DEPENDS:=+curl +dnsmasq-full
  PKGARCH:=all
endef

define Package/adss/description
  ADSS is an automatic DNS filtering system based on dnsmasq.
endef

define Build/Compile
endef

define Package/adss/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/adss.config $(1)/etc/config/adss
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/adss.init $(1)/etc/init.d/adss
	
	$(INSTALL_DIR) $(1)/usr/share/adss
	$(INSTALL_BIN) ./files/adss.sh $(1)/usr/share/adss/
	$(INSTALL_BIN) ./files/log_clean.sh $(1)/usr/share/adss/
	$(INSTALL_BIN) ./files/check_update.sh $(1)/usr/share/adss/
	$(INSTALL_BIN) ./files/online_upgrade.sh $(1)/usr/share/adss/
	$(INSTALL_DATA) ./files/passwall-compat.conf $(1)/usr/share/adss/
	
	$(INSTALL_DIR) $(1)/etc/dnsmasq.d/adss/rules
	touch $(1)/etc/dnsmasq.d/adss/rules/userblacklist
	touch $(1)/etc/dnsmasq.d/adss/rules/userwhitelist
	touch $(1)/etc/dnsmasq.d/adss/rules/userlist
endef

define Package/adss/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/adss enable
	/etc/init.d/adss start
fi
exit 0
endef

define Package/adss/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/adss stop
	/etc/init.d/adss disable
fi
exit 0
endef

$(eval $(call BuildPackage,adss))