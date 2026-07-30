include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2026.48

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=e973968eceb718362c3a8d0370d517f8850a41f5
PKG_MIRROR_HASH:=a894a28d7d0b9a0c488d68a14e78b214bb67ed6f571521bdf21bf496b9f66a45

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,smartdns))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
