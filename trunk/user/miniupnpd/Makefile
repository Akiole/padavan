include $(ROOTDIR)/rules.mk

# 1. 基础包信息
PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.10
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://miniupnp.free.fr/files/
PKG_HASH:=f9c34ed3632fb60cd248dd5897bd98479a103a75688b056ca2f069e68ab32987

include $(INCLUDE_DIR)/package.mk

# 保留原有iptables路径配置
IPTABLESPATH=$(ROOTDIR)/build/iptables-1.8.7
# 彻底关闭IPv6编译宏
ENABLE_IPV6:=0

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
		# 注释IPv6参数，禁用IPv6配置
		# --ipv6 \
		# 注释IGD2参数，仅启用IGD v1.0
		# --igd2
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
