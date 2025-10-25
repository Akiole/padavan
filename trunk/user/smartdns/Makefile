include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2025.09.18-2244

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://www.github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=0f1912ab020ea9a60efac4732442f0bb7093f40b
PKG_MIRROR_HASH:=40a4f975ed79ccc5043cfbc9875e862d2db62540188cbe382219f7adeacfc5fc

include $(INCLUDE_DIR)/package.mk

# 编译规则（注意：所有命令行必须用 Tab 缩进）
define Build/Compile
	# 原有编译逻辑
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		CC=$(TARGET_CC) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
	
	# 新增UI编译
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
	TITLE:=SmartDNS with UI Dashboard
endef

$(eval $(call BuildPackage,smartdns))

# romfs规则（同样用 Tab 缩进命令）
romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	# 安装原有主程序
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	# 安装UI插件
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/smartdns_ui.so $(ROMFSDIR)/usr/bin/smartdns_ui.so
	# 安装启动脚本
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	
	# 安装配置文件
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
