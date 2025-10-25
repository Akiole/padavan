include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=Release47

# 下载链接（已正确拼接，无需修改）
PKG_SOURCE_URL:=https://github.com/pymumu/smartdns/archive/refs/tags/
PKG_SOURCE:=Release47.tar.gz
# 填写实际计算的SHA256哈希（必须！）
PKG_MIRROR_HASH:=90414fc46de16bdec69a8511d78616287db17c5cc20034c210978896dfa7530a

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,smartdns))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
