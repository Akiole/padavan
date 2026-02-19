include $(ROOTDIR)/rules.mk

PKG_NAME:=wsdd2
PKG_VERSION:=1.8.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Netgear/wsdd2/archive/refs/tags/
PKG_HASH:=b0b6b31522f4a5e39d075b31d59d57af9a567f543e0b39b2fbdfec324d30310a

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		-j$(HOST_NCPU)
endef

define Package/wsdd2/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wsdd2 $(1)/sbin/wsdd2
endef

$(eval $(call BuildPackage,wsdd2))
