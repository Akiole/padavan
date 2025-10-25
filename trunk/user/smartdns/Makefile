include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2025.09.18-2244

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://www.github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=0f1912ab020ea9a60efac4732442f0bb7093f40b
PKG_MIRROR_HASH:=40a4f975ed79ccc5043cfbc9875e862d2db62540188cbe382219f7adeacfc5fc

include $(INCLUDE_DIR)/package.mk

# 编译规则：只编译UI插件，主程序沿用你原来的旧规则（不重复编译）
define Build/Compile
	# 仅编译UI插件（不碰主程序，避免影响原有功能）
	cd $(PKG_BUILD_DIR) && \
	./package/build-pkg.sh \
		--platform linux \
		--arch mipsle \
		--with-ui \
		--static
endef

define Package/smartdns
	SECTION:=net
	CATEGORY:=Network
	TITLE:=SmartDNS with UI Plugin
endef

$(eval $(call BuildPackage,smartdns))

# romfs规则：保留原有主程序安装，仅新增UI插件
romfs:
	# 沿用你原来的主程序安装路径（完全不变）
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	
	# 新增UI插件安装（仅这一行是新增的）
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/smartdns_ui.so $(ROMFSDIR)/usr/bin/smartdns_ui.so
	
	# 保留你原来的启动脚本和配置文件（完全不变）
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
