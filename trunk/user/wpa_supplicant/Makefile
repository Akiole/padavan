include $(ROOTDIR)/rules.mk

PKG_NAME:=wpa_supplicant
PKG_VERSION:=2.11
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://w1.fi/releases/
PKG_HASH:=912ea06f74e30a8e36fbb68064d6cdff218d8d591db0fc5d75dee6c81ac7fc0a

include $(INCLUDE_DIR)/package.mk

CONFIGS :=
ifeq ($(CONFIG_FIRMWARE_INCLUDE_EAP_PEAP),y)
CONFIGS += \
	CONFIG_EAP_TTLS=y \
	CONFIG_EAP_PEAP=y \
	CONFIG_EAP_MSCHAPV2=y
else ifeq (,$(wildcard $(STAGING_DIR)/lib/pkgconfig/openssl.pc))
CONFIGS += \
	CONFIG_TLS=internal \
	CONFIG_CRYPTO=internal \
	CONFIG_INTERNAL_LIBTOMMATH=y \
	CONFIG_INTERNAL_RC4=y
endif

define Build/Configure
	(cd $(PKG_BUILD_DIR)/wpa_supplicant; \
	cp -f .config.def .config; \
	$(foreach c,$(CONFIGS),echo $(c) >> .config;) \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/wpa_supplicant $(MAKE_FLAGS) all
endef

$(eval $(call BuildPackage,wpa_supplicant))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wpa_supplicant/wpa_cli $(ROMFSDIR)/usr/sbin/wpa_cli
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wpa_supplicant/wpa_supplicant $(ROMFSDIR)/usr/sbin/wpa_supplicant
