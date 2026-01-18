include $(ROOTDIR)/rules.mk

# 1. 基础包信息升级（版本、源码、URL、哈希）
PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.9
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# 2.3.9的官方下载URL（兼容原URL，tuxfamily和free.fr都是官方源）
PKG_SOURCE_URL:=https://miniupnp.tuxfamily.org/files/
# 2.3.9的正确SHA256哈希值（必须更新，否则编译校验失败）
PKG_HASH:=66cb3c3d697ab2bb3a61d3c48628166d6ba328d7c2dbeb95898fdf2a3202af7b

include $(INCLUDE_DIR)/package.mk

# 保留原有iptables路径配置
IPTABLESPATH=$(ROOTDIR)/build/iptables-1.8.7
# 修改点1：启用IPv6（从0改为1）
ENABLE_IPV6:=1

# 2. 补丁应用（核心修改：添加2.3.9的4个补丁）
define Build/Prepare
	$(Build/Prepare/Default)
endef

# 3. 配置阶段升级（适配2.3.9的configure参数）
define Build/Configure
	cd $(PKG_BUILD_DIR) && ./configure \
		--firewall=iptables \
		--vendorcfg \
		--portinuse \
		--leasefile \
		--disable-pppconn \
		--disable-tests \
		# 修改点2：取消--ipv6参数注释，启用IPv6配置
		--ipv6 \
		# 如需启用IGD2，取消注释下面一行
		--igd2
endef

# 4. 编译参数（保留原有iptables配置，无需额外修改）
MAKE_FLAGS += \
	-f Makefile.linux \
	ENABLE_IPV6=$(ENABLE_IPV6) \
	IPTABLESPATH=$(IPTABLESPATH) \
	LIBS="-L$(IPTABLESPATH)/libiptc/.libs -lip4tc"

$(eval $(call BuildPackage,miniupnpd))

# 5. 安装阶段（保持原有逻辑不变）
romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(ROMFSDIR)/usr/bin/miniupnpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpdctl $(ROMFSDIR)/usr/bin/miniupnpdctl
