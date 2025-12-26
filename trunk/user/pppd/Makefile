include $(ROOTDIR)/rules.mk

PKG_NAME:=ppp
PKG_VERSION:=2.5.2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://download.samba.org/pub/ppp/
PKG_HASH:=47da358de54a10cb10bf6ff2cf9b1c03c0d3555518f6182e8f701b8e55733cb2

PKG_INSTALL:=1
# 启用 autoreconf 确保配置文件兼容当前编译环境
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

# 关键修正：去掉版本号，和旧版2.4.7的插件目录完全一致
PPP_PLUGIN_DIR:=$(ROMFSDIR)/usr/lib/pppd

# 修复 Prepare 阶段逻辑（保留原有修复，简化写法）
define Build/Prepare
	$(call Build/Prepare/Default)
	# 确保插件目录存在，避免编译时报错
	mkdir -p $(PKG_BUILD_DIR)/pppd/plugins/pppoe
	mkdir -p $(PKG_BUILD_DIR)/pppd/plugins/pppol2tp
endef

# 关键：修正configure步骤
define Build/Configure
	$(call Build/Configure/Default, \
		--enable-pppoe \          # 显式启用 pppoe 插件
		--enable-pppol2tp \       # 显式启用 pppol2tp 插件
		--enable-plugins \        # 启用插件编译功能
		--with-pcap=linux \       # 适配 linux pcap 环境
		$(if $(CONFIG_IPV6),--enable-ipv6,) \  # 可选：启用 IPv6 支持
	)
endef

# 编译主程序 + 有效插件
define Build/Compile
	# 编译 pppd 主程序
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) all
	# 单独编译 pppoe 插件（确保生成 so 文件）
	$(MAKE) -C $(PKG_BUILD_DIR)/pppd/plugins/pppoe $(MAKE_FLAGS)
	# 单独编译 pppol2tp 插件
	$(MAKE) -C $(PKG_BUILD_DIR)/pppd/plugins/pppol2tp $(MAKE_FLAGS)
endef

$(eval $(call BuildPackage,ppp))

# 修复 romfs 阶段
romfs:
	# 安装 pppd 主程序
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pppd/pppd $(ROMFSDIR)/usr/sbin/pppd
	
	# 创建插件目录
	$(INSTALL_DIR) $(PPP_PLUGIN_DIR)
	
	# 直接复制 pppoe.so
	$(CP) $(PKG_BUILD_DIR)/pppd/plugins/pppoe/pppoe.so $(PPP_PLUGIN_DIR)/
	
	# 直接复制 pppol2tp.so
	$(CP) $(PKG_BUILD_DIR)/pppd/plugins/pppol2tp/pppol2tp.so $(PPP_PLUGIN_DIR)/
