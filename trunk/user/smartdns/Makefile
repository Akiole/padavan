include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2025.47

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://www.github.com/Akiole/smartdns.git
PKG_SOURCE_VERSION:=8fa6a0a5e3ac2fde30f4f156d9ffe77add2742fa
PKG_MIRROR_HASH:=cad59559106642a533de57ba460c8e81eef4bd570ce42c66c9f98d5eb84c0209

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,smartdns))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
