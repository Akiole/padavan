include $(ROOTDIR)/rules.mk

PKG_NAME:=iperf
PKG_VERSION:=3.21

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.es.net/pub/iperf
PKG_HASH:=656e4405ebd620121de7ceca3eaf43a88f79ea1b857d041a6a0b1314801acdd8

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -D_GNU_SOURCE
CONFIGURE_ARGS += \
	--disable-shared \
	--enable-static \
	--without-openssl

$(eval $(call BuildPackage,iperf))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/iperf3 $(ROMFSDIR)/bin/iperf3
