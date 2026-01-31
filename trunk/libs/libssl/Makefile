include $(ROOTDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

# 包基础配置（工整对齐，变量规范）
PKG_NAME:=openssl
PKG_VERSION:=3.5.5
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.openssl.org/source/
PKG_HASH:=b28c91532a8b65a1f983b4c28b7488174e4a01008e29ce8e69bd789f28bc2a89

# ------------------------------------------------------------------------------
# 1. 精简：一次性定义 smartdns 启用状态（避免重复判断，核心优化点）
# 后续 EC、QUIC/KTLS 均复用该变量，消除繁琐的重复条件判断
# ------------------------------------------------------------------------------
SMARTDNS_ENABLED:=$(CONFIG_FIRMWARE_INCLUDE_SMARTDNS)

# ------------------------------------------------------------------------------
# 2. OpenSSL 核心编译选项（规范排版：每行一个选项，缩进统一，便于维护）
# ------------------------------------------------------------------------------
OPENSSL_OPTIONS = \
	no-async \
	no-capieng \
	no-cms \
	no-rfc3779 \
	no-seed \
	no-ec2m \
	no-err \
	no-idea \
	no-rc5 \
	no-rmd160 \
	no-static-engine \
	no-md2 \
	no-sse2 \
	no-dso \
	no-ts \
	no-mdc2 \
	no-cast \
	no-whirlpool \
	no-sctp \
	no-srp \
	no-ssl2 \
	no-ssl3 \
	no-blake2 \
	no-hw-padlock \
	no-aria \
	no-hw \
	no-devcryptoeng \
	no-ssl3-method \
	no-tests \
	no-sm2 \
	no-sm3 \
	no-sm4 \
	no-afalgeng \
	no-comp

# ------------------------------------------------------------------------------
# 3. 条件判断（精简冗余：复用已定义的变量，消除重复判断）
# ------------------------------------------------------------------------------
# 3.1 EC 功能控制（仅一次判断，复用变量，简化逻辑）
ifeq (,$(filter y,$(CONFIG_FIRMWARE_INCLUDE_OPENSSL_EC) $(SMARTDNS_ENABLED)))
OPENSSL_OPTIONS += no-ec
endif

# 3.2 RC2 算法控制（保持原有逻辑，规范排版）
ifneq ($(CONFIG_FIRMWARE_INCLUDE_SSWAN),y)
OPENSSL_OPTIONS += no-rc2
endif

# 3.3 编译基础参数（规范对齐，补充必要路径，无冗余）
CONFIGURE_CMD = ./Configure
CONFIGURE_ARGS = \
	linux-mips32 \
	shared \
	enable-tls1_3 \
	--prefix=$(STAGING_DIR) \
	--libdir=$(STAGING_DIR)/lib \
	--openssldir=/etc/ssl \
	$(OPENSSL_OPTIONS)

# 3.4 SmartDNS 联动 QUIC/KTLS（复用变量，精简判断，无繁琐重复）
ifeq ($(SMARTDNS_ENABLED),y)
CONFIGURE_ARGS += enable-quic enable-ktls
endif

# ------------------------------------------------------------------------------
# 4. 编译/安装/固件打包（规范代码格式：缩进统一、注释简洁、无冗余步骤）
# ------------------------------------------------------------------------------
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(MAKE_FLAGS) \
		LIBS=-latomic
endef

define Build/Install
	# 安装核心库（轻量化，不包含文档/示例）
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(MAKE_FLAGS) \
		DESTDIR= \
		install_sw

	# 安装 SSL 配置目录
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(MAKE_FLAGS) \
		DESTDIR=$(STAGING_DIR) \
		install_ssldirs
endef

define Build/Romfs
	# 复制 OpenSSL 动态库
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libssl.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libcrypto.so* $(ROMFSDIR)/lib/

	# 复制 OpenSSL 配置文件
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./openssl.cnf $(ROMFSDIR)/etc_ro/openssl.cnf

	# 可选：安装 openssl 可执行文件
	ifeq ($(CONFIG_FIRMWARE_INCLUDE_OPENSSL_EXE),y)
		$(INSTALL_DIR) $(ROMFSDIR)/bin
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/openssl $(ROMFSDIR)/bin/
	endif
endef

# ------------------------------------------------------------------------------
# 5. 注册包编译（符合规范，无冗余代码）
# ------------------------------------------------------------------------------
$(eval $(call BuildPackage,openssl))
