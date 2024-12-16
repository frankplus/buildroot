################################################################################
# libhybris
################################################################################

LIBHYBRIS_VERSION = 9f61f26c44d9a3bf62efb67d4c32a7a0c89c21ca
LIBHYBRIS_SITE = https://github.com/libhybris/libhybris.git
LIBHYBRIS_SITE_METHOD = git
LIBHYBRIS_LICENSE = Apache-2.0
LIBHYBRIS_LICENSE_FILES = COPYING
LIBHYBRIS_DEPENDENCIES = android-headers host-pkgconf
LIBHYBRIS_SUBDIR = hybris
LIBHYBRIS_ANDROID_HEADERS_DIR = $(STAGING_DIR)/usr/include/android
LIBHYBRIS_HYBRIS_DIR = $(@D)/$(LIBHYBRIS_SUBDIR)
LIBHYBRIS_TARGET = aarch64-linux-musl

# Specify Android headers directory
LIBHYBRIS_CONF_OPTS += \
    --with-android-headers=$(LIBHYBRIS_ANDROID_HEADERS_DIR) \
    --enable-experimental \
    --enable-property-cache \
    --enable-debug \
    --enable-trace \
    --enable-stub-linker \
    --enable-arch=arm64 \
    --host=$(LIBHYBRIS_TARGET)

# Set cross-compilation flags
LIBHYBRIS_CONF_ENV += \
    CFLAGS="$(TARGET_CFLAGS) --target=aarch64-linux-ohosmusl -D_LARGEFILE64_SOURCE -Wno-error=int-conversion" \
    CXXFLAGS="$(TARGET_CXXFLAGS) --target=aarch64-linux-ohosmusl -D_LARGEFILE64_SOURCE -Wno-error=non-pod-varargs" \
    LDFLAGS="$(TARGET_LDFLAGS) --target=aarch64-linux-ohosmusl"

LIBHYBRIS_AUTORECONF = YES

define LIBHYBRIS_CONFIGURE_CMDS
    $(AUTORECONF) $(AUTORECONF_OPTS) ${LIBHYBRIS_HYBRIS_DIR}
    $(TARGET_CONFIGURE_OPTS) \
    $(LIBHYBRIS_CONF_ENV) \
    ${LIBHYBRIS_HYBRIS_DIR}/configure $(LIBHYBRIS_CONF_OPTS)
endef

# Configure command
# define LIBHYBRIS_CONFIGURE_CMDS
#     cd $(@D)/${LIBHYBRIS_SUBDIR} && autoreconf -fi
#     cd $(@D)/${LIBHYBRIS_SUBDIR} && ./configure \
#         --enable-experimental \
#         --enable-property-cache \
#         --enable-debug \
#         --enable-trace \
#         --enable-stub-linker \
#         --with-android-headers=$(LIBHYBRIS_ANDROID_HEADERS_DIR) \
#         --prefix=$(STAGING_DIR)/usr \
#         --enable-arch=arm64 \
#         --build=x86_64-linux-gnu \
#         --host=$(LIBHYBRIS_TARGET)
# endef

define LIBHYBRIS_BUILD_CMDS
    $(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define LIBHYBRIS_INSTALL_TARGET_CMDS
    $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install DESTDIR=$(TARGET_DIR)
endef

define LIBHYBRIS_INSTALL_STAGING_CMDS
    $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install DESTDIR=$(STAGING_DIR)
endef

$(eval $(autotools-package))
