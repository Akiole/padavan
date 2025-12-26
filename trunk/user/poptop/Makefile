include $(ROOTDIR)/rules.mk

PKG_NAME:=pptpd
PKG_VERSION:=1.5.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://sourceforge.net/projects/poptop/files/pptpd/pptpd-1.5.0/
PKG_HASH:=6a724284b1ce00ea23f7d7608d081843a10c8a8d87d951cb2ea86e70aa1b4e77

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-bcrelay
CONFIGURE_VARS += \
	ac_cv_header_libintl_h=no \
	ac_cv_func_logwtmp=no \
	CFLAGS="$(TARGET_CFLAGS) -Wno-error=implicit-function-declaration -Wno-incomplete-type"

MAKE_FLAGS += \
	COPTS="$(TARGET_CFLAGS)" \
	INSTALL="install"

# 修复宏定义和头文件缺失
define Build/Prepare
	$(call Build/Prepare/Default)
	# 修复 MSG_TRYHARD 宏
	sed -i 's/MSG_DONTWAIT|MSG_TRYHARD/MSG_DONTWAIT/g' $(PKG_BUILD_DIR)/bcrelay.c
	# 修复 plugins/pptpd-logwtmp.c 头文件缺失
	if [ -f $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c ]; then \
		sed -i '1i #include <sys/socket.h>' $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
		sed -i '1i #include <utmp.h>' $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
	fi
endef

# 彻底禁用 plugins 编译
define Build/Configure
	$(call Build/Configure/Default)
	# 删除 plugins 编译语句
	sed -i '/^for d in plugins; do/d' $(PKG_BUILD_DIR)/Makefile
	sed -i '/plugins/d' $(PKG_BUILD_DIR)/Makefile
endef

$(eval $(call BuildPackage,pptpd))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pptpd $(ROMFSDIR)/usr/sbin/pptpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pptpctrl $(ROMFSDIR)/usr/sbin/pptpctrl
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bcrelay $(ROMFSDIR)/usr/sbin/bcrelay
