include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2025.09.18-2244

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://www.github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=0f1912ab020ea9a60efac4732442f0bb7093f40b
PKG_MIRROR_HASH:=40a4f975ed79ccc5043cfbc9875e862d2db62540188cbe382219f7adeacfc5fc

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	# 先执行主程序原有编译
	$(call Build/Compile/Default)
	
	# 追加UI插件编译，使用默认工具链
	cd $(PKG_BUILD_DIR) && \
	RUSTFLAGS="-C link-arg=-static -C target-cpu=mips32" \
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

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	# 安装UI插件及相关文件
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/smartdns_ui.so $(ROMFSDIR)/usr/bin/smartdns_ui.so
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
