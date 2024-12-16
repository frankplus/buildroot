################################################################################
# External Clang toolchain package for OpenHarmony
#
# This package infrastructure implements support for external Clang toolchains.
# It supports toolchains with no binary prefix, using BR2_TOOLCHAIN_EXTERNAL_CLANG
# and specifying the sysroot directory via BR2_TOOLCHAIN_EXTERNAL_SYSROOT_DIR.
################################################################################

TOOLCHAIN_CLANG_EXTERNAL_SYSROOT = $(call qstrip,$(BR2_TOOLCHAIN_EXTERNAL_SYSROOT_DIR))
TOOLCHAIN_CLANG_EXTERNAL_BIN = $(TOOLCHAIN_CLANG_EXTERNAL_SYSROOT)/bin

TOOLCHAIN_CLANG_EXTERNAL_CC = $(TOOLCHAIN_CLANG_EXTERNAL_BIN)/clang
TOOLCHAIN_CLANG_EXTERNAL_CXX = $(TOOLCHAIN_CLANG_EXTERNAL_BIN)/clang++
TOOLCHAIN_CLANG_EXTERNAL_AR = $(TOOLCHAIN_CLANG_EXTERNAL_BIN)/llvm-ar
TOOLCHAIN_CLANG_EXTERNAL_NM = $(TOOLCHAIN_CLANG_EXTERNAL_BIN)/llvm-nm
TOOLCHAIN_CLANG_EXTERNAL_RANLIB = $(TOOLCHAIN_CLANG_EXTERNAL_BIN)/llvm-ranlib
TOOLCHAIN_CLANG_EXTERNAL_LD = $(TOOLCHAIN_CLANG_EXTERNAL_BIN)/ld.lld

TOOLCHAIN_CLANG_EXTERNAL_LIBS += libclang-cpp.so.* libLLVM.so.* libomp.so.*
TOOLCHAIN_CLANG_EXTERNAL_LIBS += libxml2.so.* libedit.so.* libform.so.*

ifeq ($(BR2_INSTALL_LIBSTDCPP),y)
TOOLCHAIN_CLANG_EXTERNAL_LIBS += libc++.so.* libc++abi.so.*
endif

ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
TOOLCHAIN_CLANG_EXTERNAL_LIBS += libpthread.so.*
endif

ifeq ($(BR2_SSP_NONE),y)
TOOLCHAIN_CLANG_EXTERNAL_LIBS += libssp.so.*
endif

# Copy runtime libraries to target
ifeq ($(BR2_STATIC_LIBS),)
define TOOLCHAIN_CLANG_EXTERNAL_INSTALL_TARGET_LIBS
	$(Q)$(call MESSAGE,"Copying Clang toolchain libraries to target...")
	$(Q)for libpattern in $(TOOLCHAIN_CLANG_EXTERNAL_LIBS); do \
		$(call copy_toolchain_lib_root,$$libpattern); \
	done
endef
endif

# Copy sysroot to staging

define TOOLCHAIN_CLANG_EXTERNAL_INSTALL_SYSROOT
	$(Q)$(call MESSAGE,"Copying Clang toolchain sysroot to staging...")
	$(Q)cp -a $(TOOLCHAIN_CLANG_EXTERNAL_SYSROOT)/* $(STAGING_DIR)
endef

define TOOLCHAIN_CLANG_EXTERNAL_INSTALL_MUSL_SYSROOT
	$(Q)$(call MESSAGE,"Copying MUSL sysroot to staging...")
	@if [ -z "$(BR2_TOOLCHAIN_EXTERNAL_MUSL_SYSROOT_DIR)" ]; then \
		echo "Error: BR2_TOOLCHAIN_EXTERNAL_MUSL_SYSROOT_DIR is not set"; \
		exit 1; \
	fi
	$(Q)cp -a $(BR2_TOOLCHAIN_EXTERNAL_MUSL_SYSROOT_DIR)/usr/* $(STAGING_DIR)/usr/
endef

TOOLCHAIN_CLANG_OHOS_TOOLCHAIN_WRAPPER_ARGS += \
	-DBR_CROSS_PATH_SUFFIX='' \
	-DBR_CROSS_PATH_ABS='"$(TOOLCHAIN_CLANG_EXTERNAL_BIN)"'

# Install toolchain wrappers and symlinks

define TOOLCHAIN_CLANG_EXTERNAL_INSTALL_WRAPPER
	$(Q)$(call MESSAGE,"Creating symbolic links for Clang toolchain in host bin directory...")
	$(Q)cd $(HOST_DIR)/bin; \
	for i in $(TOOLCHAIN_CLANG_EXTERNAL_BIN)/*; do \
		base=$${i##*/}; \
		case "$$base" in \
		*-ar|*-ranlib|*-nm) \
			ln -sf $$(echo $$i | sed 's%^$(HOST_DIR)%..%') .; \
			;; \
		*clang|*clang-*|*++|*++-*|*cpp) \
			ln -sf toolchain-wrapper $$base; \
			;; \
		*) \
			ln -sf $$(echo $$i | sed 's%^$(HOST_DIR)%..%') .; \
			;; \
		esac; \
	done
endef

# Generic package for Clang external toolchain

TOOLCHAIN_CLANG_OHOS_INSTALL_STAGING = YES
TOOLCHAIN_CLANG_OHOS_ADD_TOOLCHAIN_DEPENDENCY = NO

define TOOLCHAIN_CLANG_OHOS_BUILD_CMDS
	$(TOOLCHAIN_WRAPPER_BUILD)
endef

define TOOLCHAIN_CLANG_OHOS_INSTALL_STAGING_CMDS
	$(TOOLCHAIN_WRAPPER_INSTALL)
	$(TOOLCHAIN_CLANG_EXTERNAL_INSTALL_SYSROOT)
	$(TOOLCHAIN_CLANG_EXTERNAL_INSTALL_MUSL_SYSROOT)
	$(TOOLCHAIN_CLANG_EXTERNAL_INSTALL_WRAPPER)
endef

define TOOLCHAIN_CLANG_OHOS_INSTALL_TARGET_CMDS
	$(TOOLCHAIN_CLANG_EXTERNAL_INSTALL_TARGET_LIBS)
endef


# Not really a virtual package, but we use the virtual package infra here so
# both the build log and build directory look nicer (toolchain-virtual instead
# of toolchain-undefined)
$(eval $(virtual-package))
