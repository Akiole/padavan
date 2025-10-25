include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2025.09.18-2244

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://www.github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=0f1912ab020ea9a60efac4732442f0bb7093f40b
PKG_MIRROR_HASH:=40a4f975ed79ccc5043cfbc9875e862d2db62540188cbe382219f7adeacfc5fc

include $(INCLUDE_DIR)/package.mk

# 保留原主程序编译逻辑，仅追加UI插件编译步骤
define Build/Compile
	# 先执行主程序原有编译（不修改原有逻辑）
	$(call Build/Compile/Default)
	
	# 仅追加UI插件编译，强制使用当前工具链，不下载新库
	cd $(PKG_BUILD_DIR) && \
	export CC=$(TARGET_CC) \
	export CXX=$(TARGET_CXX) \
	export AR=$(TARGET_AR) \
	export LD=$(TARGET_LD) \
	export RUSTFLAGS="-C linker=$(TARGET_CC) -C link-arg=-static -C target-cpu=mips32" && \
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
	# 新增UI插件安装
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/smartdns_ui.so $(ROMFSDIR)/usr/bin/smartdns_ui.so
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
