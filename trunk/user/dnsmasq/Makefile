include $(ROOTDIR)/rules.mk

PKG_NAME:=dnsmasq
PKG_VERSION:=2.91

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://thekelleys.org.uk/dnsmasq/
PKG_HASH:=f622682848b33677adb2b6ad08264618a2ae0a01da486a93fd8cd91186b3d153

include $(INCLUDE_DIR)/package.mk

COPTS := -DHAVE_BROKEN_RTC -DNO_INOTIFY -DNO_AUTH -DNO_LOOP
ifndef CONFIG_IPV6
COPTS += -DNO_IPV6
endif
ifndef CONFIG_USB_SUPPORT
COPTS += -DNO_TFTP
endif
ifneq ($(CONFIG_FIRMWARE_INCLUDE_IPSET),y)
COPTS += -DNO_IPSET
endif

MAKE_FLAGS := \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	COPTS="$(COPTS)" \
	PREFIX=""

$(eval $(call BuildPackage,dnsmasq))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dnsmasq $(ROMFSDIR)/usr/sbin/dnsmasq
