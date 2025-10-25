include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=Release47  # 与标签一致，确保解压目录正确

# 下载链接（自动拼接）
PKG_SOURCE_URL:=https://github.com/pymumu/smartdns/archive/refs/tags/
PKG_SOURCE:=Release47.tar.gz
# 补充实际计算的SHA256哈希（必须填写，替换成你的文件哈希）
PKG_MIRROR_HASH:=90414fc46de16bdec69a8511d78616287db17c5cc20034c210978896dfa7530a

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,smartdns))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	# 此时PKG_BUILD_DIR自动为$(BUILD_DIR)/smartdns-Release47，与解压目录一致
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
