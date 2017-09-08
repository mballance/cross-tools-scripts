
COMMON_DIR := $(shell cd $(dir $(lastword $(MAKEFILE_LIST))); pwd)

ifneq (true,$(RULES))

ifeq (,$(BUILD_ARCH))
BUILD_ARCH=linux_x86_64
endif

ifeq (linux,$(BUILD_ARCH))
CONFIG_HOST:=i686-unknown-linux-gnu
#CONFIGURE_CFLAGS+=
else
CONFIG_HOST:=x86_64-unknown-linux-gnu
#CONFIGURE_CFLAGS+=-m64
endif

ifeq (,$(COMMON_MIRROR_URL))
COMMON_MIRROR_URL := ftp://mirrors.kernel.org
endif

ifeq (,$(GNU_MIRROR_URL))
GNU_MIRROR_URL := $(COMMON_MIRROR_URL)/gnu
endif

ifeq (,$(SOURCEWARE_MIRROR_URL))
SOURCEWARE_MIRROR_URL := $(COMMON_MIRROR_URL)/sourceware
endif


ifeq (,$(VERBOSE))
VERBOSE:=false
endif

ifneq (true,$(VERBOSE))
VERBOSE:=false
endif

ifneq (true,$(VERBOSE))
Q:=@
endif


ifeq (true,$(VERBOSE))
UNZIP=unzip -o
WGET=wget  --no-check-certificate
UNTARGZ=tar xvzf
UNTARBZ2=tar xvjf
TARBZ=tar cjvf
else
UNZIP=unzip -oq
WGET=wget -nv  --no-check-certificate
UNTARGZ=tar xzf
UNTARBZ2=tar xjf
TARBZ=tar cjf
endif

ROOT_DIR=$(shell pwd)
BUILD_DIR=$(ROOT_DIR)/build
PKGS_DIR=$(ROOT_DIR)/packages
PKG_SRC_DIR=$(ROOT_DIR)/package_src
PKG_DIR=$(ROOT_DIR)/packages
PKG_RESULT_DIR=$(ROOT_DIR)/package_result

# MKDIRS := $(BUILD_DIR) $(PKG_SRC_DIR) $(PKG_RESULT_DIR)
MK_BUILDDIR := if test ! -d $(BUILD_DIR); then mkdir -p $(BUILD_DIR); fi
MK_PKG_SRC_DIR := if test ! -d $(PKG_SRC_DIR); then mkdir -p $(PKG_SRC_DIR); fi
MK_PKG_RESULT_DIR := if test ! -d $(PKG_RESULT_DIR); then mkdir -p $(PKG_RESULT_DIR); fi

MKDIRS := $(MK_BUILDDIR); $(MK_PKG_SRC_DIR); $(MK_PKG_RESULT_DIR);

else # Rules

$(BUILD_DIR) :
	$(Q)mkdir -p $(@)
	
$(PKG_SRC_DIR) : 
	$(Q)mkdir -p $(@)
	
$(PKG_RESULT_DIR) :
	$(Q)mkdir -p $(@)


endif
