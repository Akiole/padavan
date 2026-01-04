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
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux GOARCH=mipsle CGO_ENABLED=0 \
		go build -v -o AdGuardHome \
		-trimpath -ldflags "$(LD_FLAGS) -s -w -buildid=" \
		.; \
	)
endef

# 新增独立目标：单独用于UPX压缩，完全脱离其他阶段
define Build/Compress
	# 单独执行压缩命令，无嵌套括号冲突
	upx --best --lzma $(PKG_BUILD_DIR)/AdGuardHome
	echo "✅ AdGuardHome 二进制通过独立目标压缩完成"
endef

# 让压缩目标在编译后自动执行（关键：依赖Build/Compile）
Build/Compile += Build/Compress

$(eval $(call BuildPackage,adguardhome))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./adguardhome.sh $(ROMFSDIR)/usr/bin/adguardhome.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/AdGuardHome $(ROMFSDIR)/usr/bin/AdGuardHome
