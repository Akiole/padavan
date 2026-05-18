include $(ROOTDIR)/rules.mk

PKG_NAME := squashfs
PKG_VERSION := 4.7.5
PKG_SOURCE := squashfs-tools-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL := https://github.com/plougher/squashfs-tools/archive/refs/tags/$(PKG_VERSION)
PKG_HASH := 547b7b7f4d2e44bf91b6fc554664850c69563701deab9fd9cd7e21f694c88ea6
PKG_BUILD_DIR := $(BUILD_DIR)/squashfs-tools-$(PKG_VERSION)

# ==================== XZ 5.8.2 自动集成（你的代码完全不动） ====================
XZ_NAME      := xz-5.8.2
XZ_TAR       := $(XZ_NAME).tar.gz
XZ_URL       := https://github.com/tukaani-project/xz/archive/refs/tags/v5.8.2.tar.gz
XZ_DIR       := $(BUILD_DIR)/$(XZ_NAME)

# 自动下载 XZ
$(DL_DIR)/$(XZ_TAR):
	$(call download,$(XZ_URL),$(XZ_TAR))

# 自动解压 XZ
$(XZ_DIR)/.unpacked: $(DL_DIR)/$(XZ_TAR)
	mkdir -p $(XZ_DIR)
	tar zxf $(DL_DIR)/$(XZ_TAR) --strip-components=1 -C $(XZ_DIR)
	touch $@

# 自动配置 XZ
$(XZ_DIR)/.configured: $(XZ_DIR)/.unpacked
	cd $(XZ_DIR) && ./autogen.sh
	cd $(XZ_DIR) && ./configure \
		--disable-shared \
		--disable-werror \
		--disable-xz \
		--disable-xzdec \
		--disable-lzmadec \
		--disable-lzmainfo \
		CFLAGS="-std=c99"
	touch $@

# 自动编译 XZ
$(XZ_DIR)/.built: $(XZ_DIR)/.configured
	$(MAKE) -j$(HOST_NCPU) -C $(XZ_DIR)
	touch $@
# ================================================================================

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--with-zlib \
	--with-lzo \
	--with-lz4 \
	--with-xz \
	--with-zstd \
	--enable-xattr

define Build/Compile
	@echo "==> Building xz 5.8.2 first..."
	$(MAKE) $(XZ_DIR)/.built

	@echo "==> Patching default compression method to xz..."
	@$(SED) 's|COMP_DEFAULT = gzip|COMP_DEFAULT = xz|g; s|COMP_DEFAULT ?= gzip|COMP_DEFAULT ?= xz|g' \
		$(PKG_BUILD_DIR)/squashfs-tools/Makefile

	@echo "==> Compiling $(PKG_NAME) with XZ 5.8.2..."
	# 关键：使用刚编译的新版XZ
	+$(MAKE) -C $(PKG_BUILD_DIR)/squashfs-tools \
		XZ_SUPPORT=1 \
		XZ_STATIC=1 \
		XZUTILSDIR=$(XZ_DIR)

	@echo "==> Installing $(PKG_NAME) to tools/mksquashfs_xz..."
	$(INSTALL_DIR) $(ROOTDIR)/tools/mksquashfs_xz
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squashfs-tools/mksquashfs $(ROOTDIR)/tools/mksquashfs_xz/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squashfs-tools/unsquashfs $(ROOTDIR)/tools/mksquashfs_xz/
endef

$(eval $(call BuildPackage,squashfs))
