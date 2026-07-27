include $(ROOTDIR)/rules.mk

PKG_NAME:=json-c
PKG_VERSION:=0.19
PKG_SOVERSION:=5
PKG_LIB_VERSION:=5.5.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-nodoc.tar.gz
PKG_SOURCE_URL:=https://s3.amazonaws.com/json-c_releases/releases/
PKG_HASH:=704927172443309a8efeb162060bb215548e1286e5568514007dd2cc35a0a164

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DBUILD_APPS=OFF \
	-DDISABLE_EXTRA_LIBS=TRUE

$(eval $(call BuildPackage,json-c))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(RM) $(ROMFSDIR)/lib/libjson-c.so*
	$(CP) \
		$(PKG_INSTALL_DIR)/lib/libjson-c.so \
		$(PKG_INSTALL_DIR)/lib/libjson-c.so.$(PKG_SOVERSION) \
		$(PKG_INSTALL_DIR)/lib/libjson-c.so.$(PKG_LIB_VERSION) \
		$(ROMFSDIR)/lib/
