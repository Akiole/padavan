include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=Release47  # 与标签名一致，确保路径正确

# 拆分URL，自动拼接为完整链接
PKG_SOURCE_URL:=https://github.com/pymumu/smartdns/archive/refs/tags/
PKG_SOURCE:=Release47.tar.gz

# 明确源码解压目录（与拼接后的下载包解压结果一致）
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,smartdns))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
