include $(ROOTDIR)/rules.mk

# 1. 基础包信息
PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.9
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files/
PKG_HASH:=66cb3c3d697ab2bb3a61d3c48628166d6ba328d7c2dbeb95898fdf2a3202af7b

include $(INCLUDE_DIR)/package.mk

# 保留原有iptables路径配置
IPTABLESPATH=$(ROOTDIR)/build/iptables-1.8.7
# 彻底关闭IPv6编译宏
ENABLE_IPV6:=1

# 2. 补丁应用
define Build/Prepare
	$(Build/Prepare/Default)
endef

# 3. 配置阶段：注释--ipv6和--igd2，禁用IPv6和IGD2
define Build/Configure
	cd $(PKG_BUILD_DIR) && ./configure \
		--firewall=iptables \
		--vendorcfg \
		--portinuse \
		--leasefile \
		--disable-pppconn \
		--disable-tests \
		--ipv6 \
		--igd2
endef

# 4. 编译参数：改回硬编码的libiptc路径，补充-lip6tc
MAKE_FLAGS += \
	-f Makefile.linux \
	ENABLE_IPV6=$(ENABLE_IPV6) \
	IPTABLESPATH=$(IPTABLESPATH) \
	LIBS="-L$(IPTABLESPATH)/libiptc/.libs -lip4tc -lip6tc"

$(eval $(call BuildPackage,miniupnpd))

# 5. 安装阶段
romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(ROMFSDIR)/usr/bin/miniupnpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpdctl $(ROMFSDIR)/usr/bin/miniupnpdctl
