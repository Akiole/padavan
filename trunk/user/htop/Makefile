include $(ROOTDIR)/rules.mk

PKG_NAME:=htop
PKG_VERSION:=3.5.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/htop-dev/htop/tar.gz/$(PKG_VERSION)?
PKG_HASH:=dfc4a09845e9bc86f466a722e62b8f87d59028ff39689077ff2257a6a605061d

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-unicode \
	--with-curses=ncursesw

$(eval $(call BuildPackage,htop))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/htop $(ROMFSDIR)/usr/bin/htop
