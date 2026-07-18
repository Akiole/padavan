include $(ROOTDIR)/rules.mk

PKG_NAME:=c-ares
PKG_VERSION:=1.34.6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/c-ares/c-ares/releases/download/v$(PKG_VERSION)
PKG_HASH:=912dd7cc3b3e8a79c52fd7fb9c0f4ecf0aaa73e45efda880266a2d6e26b84ef5

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

$(eval $(call BuildPackage,c-ares))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libcares.so* $(ROMFSDIR)/lib/
