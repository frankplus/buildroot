################################################################################
# android-headers
################################################################################

ANDROID_HEADERS_VERSION = 2c6ac3dcc4f8db593dd69906b0ec22822abfed91
ANDROID_HEADERS_SITE = https://github.com/Halium/android-headers
ANDROID_HEADERS_SITE_METHOD = git
ANDROID_HEADERS_LICENSE = Apache-2.0
ANDROID_HEADERS_LICENSE_FILES = LICENSE

ANDROID_HEADERS_INSTALL_STAGING = YES
ANDROID_HEADERS_INSTALL_TARGET = NO

define ANDROID_HEADERS_INSTALL_STAGING_CMDS
    mkdir -p $(STAGING_DIR)/usr/include/android-headers
    cp -r $(@D)/* $(STAGING_DIR)/usr/include/android-headers
endef

# Use the generic-package infrastructure
$(eval $(generic-package))
