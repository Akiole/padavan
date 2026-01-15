include $(ROOTDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files/
PKG_HASH:=fbdd5501039730f04a8420ea2f8f54b7df63f9f04cde2dc67fa7371e80477bbe

include $(INCLUDE_DIR)/package.mk

CONFIGURE_CMD := :

# SRC_DIR=./miniupnpd-2.x

# disable support IPv6 yet, because no profit w/o IGDv2
# e.g. Windows not supported IGDv2 and UPnP not worked
ENABLE_IPV6:=0

MAKE_FLAGS += \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	-f Makefile.linux \
	ENABLE_IPV6=$(ENABLE_IPV6)

$(eval $(call BuildPackage,miniupnpd))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(ROMFSDIR)/usr/bin/miniupnpd
