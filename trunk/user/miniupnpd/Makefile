include $(ROOTDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files/
PKG_HASH:=fbdd5501039730f04a8420ea2f8f54b7df63f9f04cde2dc67fa7371e80477bbe

include $(INCLUDE_DIR)/package.mk

SRC_DIR=./miniupnpd-2.3.7
ENABLE_IPV6:=0

# 保留你修正后的iptables实际路径
IPTABLESPATH=$(ROOTDIR)/build/iptables-1.8.7

define Build/Configure
	cd $(PKG_BUILD_DIR) && ./configure
endef

# 仅改动：删除冲突的-Dupnp_time=time，保留所有iptables相关配置
MAKE_FLAGS += \
	-f Makefile.linux \
	ENABLE_IPV6=$(ENABLE_IPV6) \
	IPTABLESPATH=$(IPTABLESPATH) \
	LIBS="-L$(IPTABLESPATH)/libiptc/.libs -lip4tc"

# 新增：编译前临时修复upnp_time定义（仅修改源码一行，无其他改动）
define Build/Prepare
	$(Build/Prepare/Default)
	# 修复upnp_time函数声明，避免隐式声明警告，不冲突系统time()
	sed -i 's/^time_t upnp_time(void);/static inline time_t upnp_time(void) { return time(NULL); }/' $(PKG_BUILD_DIR)/upnputils.h
endef

$(eval $(call BuildPackage,miniupnpd))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(ROMFSDIR)/usr/bin/miniupnpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpdctl $(ROMFSDIR)/usr/bin/miniupnpdctl
