include $(ROOTDIR)/rules.mk

PKG_NAME:=https-dns-proxy
PKG_VERSION:=0ba0525
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aarond10/https_dns_proxy.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=skip 

DEPENDS:=+libcurl +libopenssl +libc-ares +libev +zlib

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,https-dns-proxy))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/https_dns_proxy $(ROMFSDIR)/usr/sbin/
	
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./doh_proxy.sh $(ROMFSDIR)/usr/bin/
	
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./doh.json $(ROMFSDIR)/etc_ro/

