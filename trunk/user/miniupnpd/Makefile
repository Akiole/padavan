include $(ROOTDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files/
PKG_HASH:=fbdd5501039730f04a8420ea2f8f54b7df63f9f04cde2dc67fa7371e80477bbe

include $(INCLUDE_DIR)/package.mk

SRC_DIR=./miniupnpd-2.3.7
ENABLE_IPV6:=0

# 保留你指定的iptables路径
IPTABLESPATH=$(ROOTDIR)/build/iptables-1.8.7

define Build/Configure
	cd $(PKG_BUILD_DIR) && ./configure
endef

# 保留所有iptables配置，无改动
MAKE_FLAGS += \
	-f Makefile.linux \
	ENABLE_IPV6=$(ENABLE_IPV6) \
	IPTABLESPATH=$(IPTABLESPATH) \
	LIBS="-L$(IPTABLESPATH)/libiptc/.libs -lip4tc"

# 修正：只补头文件，不修改upnp_time声明（保留原有声明，避免和c文件里的实现冲突）
define Build/Prepare
	$(Build/Prepare/Default)
	# 第一步：在upnputils.h开头添加time.h头文件，解决time()函数声明问题
	sed -i '1i #include <time.h>' $(PKG_BUILD_DIR)/upnputils.h
	# 第二步：恢复upnp_time的原始声明（只声明，不实现），避免和c文件里的实现冲突
	sed -i 's/^static inline time_t upnp_time(void) { return time(NULL); }/time_t upnp_time(void);/' $(PKG_BUILD_DIR)/upnputils.h
endef

$(eval $(call BuildPackage,miniupnpd))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(ROMFSDIR)/usr/bin/miniupnpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpdctl $(ROMFSDIR)/usr/bin/miniupnpdctl
