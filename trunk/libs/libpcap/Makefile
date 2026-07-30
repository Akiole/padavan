include $(ROOTDIR)/rules.mk

PKG_NAME:=libpcap
PKG_VERSION:=1.10.6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.tcpdump.org/release/
PKG_HASH:=872dd11337fe1ab02ad9d4fee047c9da244d695c6ddf34e2ebb733efd4ed8aa9

include $(INCLUDE_DIR)/package.mk

# libpcap includes its public headers as <pcap/...>.  Keep the source tree
# ahead of a previously installed libpcap version during incremental builds.
TARGET_CFLAGS := -I$(PKG_BUILD_DIR) $(TARGET_CFLAGS)

# libpcap's configure script is not Automake-generated.
CONFIGURE_ARGS := $(filter-out --disable-dependency-tracking,$(CONFIGURE_ARGS))

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-yydebug \
	--disable-dbus \
	--disable-usb \
	--disable-bluetooth \
	--with-pcap=linux \
	--without-dag \
	--without-septel \
	--without-libnl

CONFIGURE_VARS += \
	ac_cv_netfilter_can_compile=no

$(eval $(call BuildPackage,libpcap))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(RM) $(ROMFSDIR)/lib/libpcap.so*
	$(CP) \
		$(PKG_INSTALL_DIR)/lib/libpcap.so \
		$(PKG_INSTALL_DIR)/lib/libpcap.so.$(PKG_SOVERSION) \
		$(PKG_INSTALL_DIR)/lib/libpcap.so.$(PKG_VERSION) \
		$(ROMFSDIR)/lib/
