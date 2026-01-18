include $(ROOTDIR)/rules.mk

PKG_NAME:=dnsmasq
PKG_VERSION:=2.92
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://thekelleys.org.uk/dnsmasq/
PKG_HASH:=4bf50c2c1018f9fbc26037df51b90ecea0cb73d46162846763b92df0d6c3a458

include $(INCLUDE_DIR)/package.mk

COPTS := -DHAVE_BROKEN_RTC -DNO_INOTIFY -DNO_AUTH -DNO_LOOP
COPTS += -DNO_DUMPFILE -DNO_ID
ifndef CONFIG_IPV6
COPTS += -DNO_DHCP6
endif
ifndef CONFIG_USB_SUPPORT
COPTS += -DNO_TFTP
endif
ifneq ($(CONFIG_FIRMWARE_INCLUDE_IPSET),y)
COPTS += -DNO_IPSET
endif
COPTS += -ffunction-sections -fdata-sections -fvisibility=hidden

MAKE_FLAGS := \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(COPTS)" \
	LDFLAGS="$(TARGET_LDFLAGS) -Wl,--gc-sections" \
	PREFIX=""

$(eval $(call BuildPackage,dnsmasq))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dnsmasq $(ROMFSDIR)/usr/sbin/dnsmasq
