include $(ROOTDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files/
PKG_HASH:=fbdd5501039730f04a8420ea2f8f54b7df63f9f04cde2dc67fa7371e80477bbe

include $(INCLUDE_DIR)/package.mk

# 禁用IPv6（和你原有逻辑一致，会传递给configure/编译阶段）
ENABLE_IPV6:=0

# 参考dnsmasq写法，使用Padavan标准编译变量
MAKE_FLAGS := \
	$(TARGET_CONFIGURE_OPTS) \
	-f Makefile.linux \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	ENABLE_IPV6=$(ENABLE_IPV6)

# 核心修复：在2.3.7根目录执行configure，解决"not found"问题
define Build/Configure
	# 进入miniupnpd-2.3.7根目录（PKG_BUILD_DIR即该目录）
	cd $(PKG_BUILD_DIR); \
	# 确保configure有可执行权限（解压后可能丢失）
	chmod +x ./configure; \
	# 仅传递miniupnpd configure支持的参数，跳过--target/--host等不兼容参数
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	# 传递IPv6禁用参数（对应configure的--ipv6选项，0则不传递）
	$(if $(filter 1,$(ENABLE_IPV6)),--ipv6,) \
	./configure;
endef

# 编译步骤：直接在2.3.7根目录执行make
define Build/Compile
	cd $(PKG_BUILD_DIR); \
	$(MAKE) $(MAKE_FLAGS);
endef

$(eval $(call BuildPackage,miniupnpd))

# 安装步骤：从2.3.7根目录复制编译好的二进制文件
romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(ROMFSDIR)/usr/bin/miniupnpd
