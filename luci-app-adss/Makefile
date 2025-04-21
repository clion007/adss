LUCI_TITLE:=LuCI support for ADSS
LUCI_DEPENDS:=+adss
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

PKG_NAME:=luci-app-adss
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-adss
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI Support for ADSS
  DEPENDS:=+luci-base +adss
  PKGARCH:=all
endef

define Package/luci-app-adss/description
  LuCI Support for ADSS (Auto DNS Smart Script)
endef

define Package/luci-app-adss/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/adss
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/adss
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	
	$(INSTALL_DATA) ./luasrc/controller/adss.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DATA) ./luasrc/model/cbi/adss/* $(1)/usr/lib/lua/luci/model/cbi/adss/
	$(INSTALL_DATA) ./luasrc/view/adss/* $(1)/usr/lib/lua/luci/view/adss/
	$(INSTALL_BIN) ./root/etc/uci-defaults/* $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,luci-app-adss))