################################################################################
#
# hello-world Buildroot package
#
################################################################################

HELLO_WORLD_VERSION = 2f0fc602989907375e364a93da6274c806338395
HELLO_WORLD_SITE = https://github.com/irvanherz/hello-world-autotools-template.git
HELLO_WORLD_SITE_METHOD = git
HELLO_WORLD_LICENSE = GPL-3.0
HELLO_WORLD_LICENSE_FILES = COPYING

# The package uses autotools for configuration and build
HELLO_WORLD_AUTORECONF = YES

# Set cross-compilation flags
HELLO_WORLD_CONF_ENV += \
    CFLAGS="$(TARGET_CFLAGS) --target=aarch64 -D_LARGEFILE64_SOURCE -Wno-error=int-conversion" \
    CXXFLAGS="$(TARGET_CXXFLAGS) --target=aarch64 -D_LARGEFILE64_SOURCE -Wno-error=non-pod-varargs" \
    LDFLAGS="$(TARGET_LDFLAGS) --target=aarch64"

define HELLO_WORLD_CONFIGURE_CMDS
    $(AUTORECONF) $(AUTORECONF_OPTS) $(@D)/
    $(TARGET_CONFIGURE_OPTS) \
    $(HELLO_WORLD_CONF_ENV) \
    $(@D)/configure
endef

$(eval $(autotools-package))

