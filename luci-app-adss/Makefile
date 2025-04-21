include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-adss
PKG_VERSION:=4.2
PKG_RELEASE:=1

LUCI_TITLE:=LuCI support for ADSS
LUCI_DEPENDS:=+adss
LUCI_PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

# 如果是 LuCI 应用，应该包含 luci.mk
include $(TOPDIR)/feeds/luci/luci.mk

# 如果都不存在，则需要手动定义 LuCI 应用的构建规则
ifndef LUCI_MAKEFILE
define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  DEPENDS:=$(LUCI_DEPENDS)
  PKGARCH:=$(LUCI_PKGARCH)
endef

define Package/$(PKG_NAME)/description
  LuCI Web Interface for ADSS (Advanced DNS Security System)
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./luasrc $(PKG_BUILD_DIR)/
	$(CP) ./root $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) $(PKG_BUILD_DIR)/luasrc/* $(1)/usr/lib/lua/luci/
	
	$(INSTALL_DIR) $(1)/
	$(CP) $(PKG_BUILD_DIR)/root/* $(1)/
endef
endif

$(eval $(call BuildPackage,$(PKG_NAME)))