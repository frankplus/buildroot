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

# Install toolchain wrappers and symlinks

define TOOLCHAIN_CLANG_EXTERNAL_INSTALL_WRAPPER
	$(Q)$(call MESSAGE,"Copying Clang toolchain binaries to host bin directory...")
	$(Q)cp -a $(TOOLCHAIN_CLANG_EXTERNAL_BIN)/* $(HOST_DIR)/bin/
endef

# Generic package for Clang external toolchain

TOOLCHAIN_CLANG_OHOS_INSTALL_STAGING = YES
TOOLCHAIN_CLANG_OHOS_ADD_TOOLCHAIN_DEPENDENCY = NO

define TOOLCHAIN_CLANG_OHOS_INSTALL_STAGING_CMDS
	$(TOOLCHAIN_CLANG_EXTERNAL_INSTALL_SYSROOT)
	$(TOOLCHAIN_CLANG_EXTERNAL_INSTALL_WRAPPER)
endef

define TOOLCHAIN_CLANG_OHOS_INSTALL_TARGET_CMDS
	$(TOOLCHAIN_CLANG_EXTERNAL_INSTALL_TARGET_LIBS)
endef


# Not really a virtual package, but we use the virtual package infra here so
# both the build log and build directory look nicer (toolchain-virtual instead
# of toolchain-undefined)
$(eval $(virtual-package))
