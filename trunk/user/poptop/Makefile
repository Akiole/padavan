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
	ac_cv_func_logwtmp=yes \
	CFLAGS="$(TARGET_CFLAGS) -Wno-error=implicit-function-declaration -Wno-incomplete-type -Wno-unused-variable"

MAKE_FLAGS += \
	COPTS="$(TARGET_CFLAGS)" \
	INSTALL="install"

# 修复Shell语法（每行末尾加\，fi单独成行）
define Build/Prepare
	$(call Build/Prepare/Default)
	# 1. 修复MSG_TRYHARD宏
	sed -i 's/MSG_DONTWAIT|MSG_TRYHARD/MSG_DONTWAIT/g' $(PKG_BUILD_DIR)/bcrelay.c \
	# 2. 给logwtmp.c补头文件（加\换行，Shell语法正确）
	if [ -f $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c ]; then \
		sed -i '1i #include <sys/types.h>' $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
		sed -i '1i #include <sys/socket.h>' $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
		sed -i '1i #include <utmp.h>' $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
		sed -i '1i #define logwtmp(a,b,c) do {} while(0)' $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
	fi
endef

# 修复sed命令（去掉\$$d的转义）
define Build/Configure
	$(call Build/Configure/Default)
	# 正确匹配plugins编译循环（无转义）
	sed -i '/^for d in plugins; do make -w -C $d all; done/d' $(PKG_BUILD_DIR)/Makefile
	sed -i 's/SUBDIRS = . plugins/SUBDIRS = ./g' $(PKG_BUILD_DIR)/Makefile
endef

$(eval $(call BuildPackage,pptpd))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pptpd $(ROMFSDIR)/usr/sbin/pptpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pptpctrl $(ROMFSDIR)/usr/sbin/pptpctrl
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bcrelay $(ROMFSDIR)/usr/sbin/bcrelay
