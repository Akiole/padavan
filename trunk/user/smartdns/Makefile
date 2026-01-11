include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2026.47

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=34d4d37acfd10ed8fd9b2191159ec37e28caaa11
PKG_MIRROR_HASH:=3a2d7199975d9c4f7bd0e72d7d2256662186be705ea43b8426baec5952d6c083

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,smartdns))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
