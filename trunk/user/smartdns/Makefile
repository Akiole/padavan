include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2026.47

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Akiole/smartdns.git
PKG_SOURCE_VERSION:=2bc8b7e9edd154d27505367f2ba8e1a310190987
PKG_MIRROR_HASH:=2130065daf0873a7e118e35e22ec918b2e18285f515ab2782a24c928ba7dba01

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,smartdns))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
