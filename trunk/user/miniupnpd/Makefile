include $(ROOTDIR)/rules.mk

# 基础定义（仅保留miniupnpd核心，无iptables）
PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files/
PKG_HASH:=fbdd5501039730f04a8420ea2f8f54b7df63f9f04cde2dc67fa7371e80477bbe

include $(INCLUDE_DIR)/package.mk

# 仅保留你原有需求：禁用IPv6
ENABLE_IPV6:=0

# 核心：自动识别包含configure的真实源码目录（解决路径找不到问题）
define FindRealSrcDir
	@for dir in $(PKG_BUILD_DIR) $(PKG_BUILD_DIR)/*; do \
		if [ -f $$dir/configure ]; then \
			echo $$dir; \
			exit 0; \
		fi; \
	done; \
	echo "ERROR: configure file not found in $(PKG_BUILD_DIR)"; \
	exit 1;
endef
REAL_SRC_DIR:=$(shell $(FindRealSrcDir))

# 编译参数（仅保留必要项，无任何iptables内容）
MAKE_FLAGS := \
	$(TARGET_CONFIGURE_OPTS) \
	-f Makefile.linux \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	ENABLE_IPV6=$(ENABLE_IPV6)

# 配置步骤：仅解决configure执行问题，无iptables
define Build/Configure
	# 进入自动识别的真实源码目录
	cd $(REAL_SRC_DIR); \
	# 确保configure有可执行权限
	chmod +x ./configure; \
	# 执行configure，仅传递支持的参数（跳过--target等不兼容项）
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure;
endef

# 编译步骤：进入真实源码目录编译，多核加速
define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(REAL_SRC_DIR) $(MAKE_FLAGS);
endef

$(eval $(call BuildPackage,miniupnpd))

# 安装步骤：仅复制miniupnpd到固件目录，无iptables
romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(REAL_SRC_DIR)/miniupnpd $(ROMFSDIR)/usr/bin/miniupnpd
