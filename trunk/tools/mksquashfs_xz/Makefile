include $(ROOTDIR)/rules.mk

PKG_NAME := squashfs
PKG_VERSION := 4.7.4
PKG_SOURCE := squashfs-tools-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL := https://github.com/plougher/squashfs-tools/archive/refs/tags/$(PKG_VERSION)
PKG_HASH := 91c49f9a1ed972ad00688a38222119e2baf49ba74cf5fda05729a79d7d59d335
PKG_BUILD_DIR := $(BUILD_DIR)/squashfs-tools-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--with-zlib \
	--with-lzo \
	--with-lz4 \
	--with-xz \
	--with-zstd \
	--enable-xattr

define Build/Compile
	@echo "==> Patching default compression method to xz..."
	@$(SED) 's|COMP_DEFAULT = gzip|COMP_DEFAULT = xz|g; s|COMP_DEFAULT ?= gzip|COMP_DEFAULT ?= xz|g' \
		$(PKG_BUILD_DIR)/squashfs-tools/Makefile

	@echo "==> Compiling $(PKG_NAME)..."
	+$(MAKE) -C $(PKG_BUILD_DIR)/squashfs-tools

	@echo "==> Installing $(PKG_NAME) to tools/mksquashfs_xz..."
	$(INSTALL_DIR) $(ROOTDIR)/tools/mksquashfs_xz
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squashfs-tools/mksquashfs $(ROOTDIR)/tools/mksquashfs_xz/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/squashfs-tools/unsquashfs $(ROOTDIR)/tools/mksquashfs_xz/
endef

$(eval $(call BuildPackage,squashfs))
