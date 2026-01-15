include $(ROOTDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files/
PKG_HASH:=fbdd5501039730f04a8420ea2f8f54b7df63f9f04cde2dc67fa7371e80477bbe

include $(INCLUDE_DIR)/package.mk

# 禁用IPv6（和你原有逻辑一致）
ENABLE_IPV6:=0

# 参考dnsmasq的写法，使用Padavan标准编译变量
MAKE_FLAGS := \
	$(TARGET_CONFIGURE_OPTS) \
	-f Makefile.linux \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	ENABLE_IPV6=$(ENABLE_IPV6)

# 覆盖默认Configure步骤（核心：跳过不兼容的--target/--host参数）
# 参考dnsmasq无多余configure参数的风格，仅传递必要环境变量
define Build/Configure
	cd $(PKG_BUILD_DIR); \
	# 仅传递编译器/链接器环境变量，不传递任何命令行参数给miniupnpd的configure
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure;
endef

$(eval $(call BuildPackage,miniupnpd))

# 参考dnsmasq的romfs写法，保持格式统一
romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(ROMFSDIR)/usr/bin/miniupnpd
