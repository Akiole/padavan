include $(ROOTDIR)/rules.mk

# 1. 版本升级到2.92，配置核心源码信息
PKG_NAME:=dnsmasq
PKG_VERSION:=2.92rel2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://thekelleys.org.uk/dnsmasq/
PKG_HASH:=43d72b8c129bdf33d17bafedc98823f63e46b5005128066bf0d2a472a32ce06a

include $(INCLUDE_DIR)/package.mk

# 2. 定义COPTS：功能禁用宏 + 整合第二段的编译优化参数
COPTS := -DHAVE_BROKEN_RTC -DNO_INOTIFY -DNO_AUTH -DNO_LOOP
# 可选：保留-DNO_DUMPFILE -DNO_ID（精简体积），如需完整功能可删除此行
# COPTS += -DNO_DUMPFILE -DNO_ID
# 从第二段整合的编译优化参数
COPTS += -ffunction-sections -fdata-sections -fvisibility=hidden

# 3. 保留原有条件编译逻辑（IPv6/TFTP/IPSET）
ifndef CONFIG_IPV6
COPTS += -DNO_IPV6
endif
ifndef CONFIG_USB_SUPPORT
COPTS += -DNO_TFTP
endif
ifneq ($(CONFIG_FIRMWARE_INCLUDE_IPSET),y)
COPTS += -DNO_IPSET
endif

# 4. MAKE_FLAGS：将COPTS融入CFLAGS，删除单独传递，补全续行符和链接优化
MAKE_FLAGS := \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(COPTS)" \
	LDFLAGS="$(TARGET_LDFLAGS) -Wl,--gc-sections" \
	PREFIX=""

# 5. 生成OpenWRT软件包构建目标
$(eval $(call BuildPackage,dnsmasq))

# 6. romfs安装逻辑（符合OpenWRT规范，无修改）
romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dnsmasq $(ROMFSDIR)/usr/sbin/dnsmasq
