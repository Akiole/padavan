include $(ROOTDIR)/rules.mk

PKG_NAME:=iptables
PKG_VERSION:=1.8.10
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://netfilter.org/projects/iptables/files/
PKG_HASH:=5cc255c189356e317d070755ce9371eb63a1b783c34498fb8c30264f3cc59c9c

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-static \
	--disable-shared \
	--disable-nftables \
	--disable-connlabel \
	--with-xtlibdir=/usr/lib/xtables \
	--with-kernel=$(ROOTDIR)/$(LINUXDIR) \
	--with-xt-lock-name="/var/lock/xtables.lock"

$(eval $(call BuildPackage,iptables))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/lib/xtables
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iptables/xtables-legacy-multi $(ROMFSDIR)/bin/xtables-multi
	$(LN) xtables-multi $(ROMFSDIR)/bin/iptables
	$(LN) xtables-multi $(ROMFSDIR)/bin/iptables-restore
	$(LN) xtables-multi $(ROMFSDIR)/bin/iptables-save
ifdef CONFIG_IPV6
	$(LN) xtables-multi $(ROMFSDIR)/bin/ip6tables
	$(LN) xtables-multi $(ROMFSDIR)/bin/ip6tables-restore
	$(LN) xtables-multi $(ROMFSDIR)/bin/ip6tables-save
endif
