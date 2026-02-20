include $(ROOTDIR)/rules.mk

PKG_NAME:=igmpproxy
PKG_VERSION:=0.4

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pali/igmpproxy.git
PKG_SOURCE_VERSION:=eb0aec2a508e21e7d87429ed24b2511a35a6a891
PKG_MIRROR_HASH:=0149d5f913ac0548887dc462edae59bc8d56e77fc710dc13ec32d4e784b3d25b

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,igmpproxy))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/igmpproxy $(ROMFSDIR)/bin/igmpproxy
