include $(ROOTDIR)/rules.mk

PKG_NAME:=AdGuardHome
PKG_VERSION:=0.107.71

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/AdguardTeam/AdGuardHome/archive/refs/tags/
PKG_SOURCE_URL_FILE:=v$(PKG_VERSION).tar.gz
PKG_HASH:=f3dde5da6ba48270ac25bd2f501c4ce1af54ddeef93fcd84ef3a8270cec9539f

include $(INCLUDE_DIR)/package.mk

LD_FLAGS:= \
	-X github.com/AdguardTeam/AdGuardHome/internal/version.channel=release \
	-X github.com/AdguardTeam/AdGuardHome/internal/version.version=$(PKG_VERSION)

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		NODE_OPTIONS=--openssl-legacy-provider make js-deps js-build; \
		zip -r embed.zip build; \
	)
endef

define Build/Compile
	# 第一步：执行原始编译逻辑
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux GOARCH=mipsle CGO_ENABLED=0 \
		go build -v -o AdGuardHome \
		-trimpath -ldflags "$(LD_FLAGS) -s -w -buildid=" \
		.; \
	)
	# 第二步：显式调用UPX压缩（直接在Compile目标内执行，无需独立目标追加，规避语法错误）
	$(call Build/Compress)
endef

# 独立UPX压缩目标（保持原有逻辑，供Compile目标显式调用）
define Build/Compress
	# 单独执行压缩命令，确保路径正确
	if [ -f $(PKG_BUILD_DIR)/AdGuardHome ]; then \
		upx --best --lzma $(PKG_BUILD_DIR)/AdGuardHome; \
		echo "✅ AdGuardHome 二进制通过UPX压缩完成"; \
	else \
		echo "❌ AdGuardHome 二进制文件不存在，压缩失败"; \
		exit 1; \
	fi
endef

$(eval $(call BuildPackage,adguardhome))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./adguardhome.sh $(ROMFSDIR)/usr/bin/adguardhome.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/AdGuardHome $(ROMFSDIR)/usr/bin/AdGuardHome
