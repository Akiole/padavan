include $(ROOTDIR)/rules.mk

PKG_NAME:=wsdd2
PKG_VERSION:=1.8.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Netgear/wsdd2/archive/refs/tags/
PKG_HASH:=b0b6b31522f4a5e39d075b31d59d57af9a567f543e0b39b2fbdfec324d30310a

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -I$(STAGING_DIR)/include/shared
TARGET_LDFLAGS += -L$(STAGING_DIR)/lib

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wsdd2 $(ROMFSDIR)/sbin/wsdd2

$(eval $(call BuildPackage,wsdd2))
