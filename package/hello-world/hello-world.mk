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

$(eval $(autotools-package))

