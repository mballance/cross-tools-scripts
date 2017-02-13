
ifneq (true,$(RULES))

GMP_VERSION=6.1.0
# MPFR_VERSION=2.4.2
MPFR_VERSION=3.1.4
MPC_VERSION=1.0.3
TEXINFO_VERSION=6.3

GMP_SRC_URL:=$(GNU_MIRROR_URL)/gmp/gmp-$(GMP_VERSION).tar.bz2
MPFR_SRC_URL:=$(GNU_MIRROR_URL)/mpfr/mpfr-$(MPFR_VERSION).tar.bz2
MPC_SRC_URL:=$(GNU_MIRROR_URL)/mpc/mpc-$(MPC_VERSION).tar.gz
TEXINFO_SRC_URL:=$(GNU_MIRROR_URL)/texinfo/texinfo-$(TEXINFO_VERSION).tar.gz

GMP_PKG:=$(PKG_SRC_DIR)/gmp-$(GMP_VERSION).tar.bz2
MPFR_PKG:=$(PKG_SRC_DIR)/mpfr-$(MPFR_VERSION).tar.bz2
MPC_PKG:=$(PKG_SRC_DIR)/mpc-$(MPC_VERSION).tar.gz
TEXINFO_PKG:=$(PKG_SRC_DIR)/texinfo-$(TEXINFO_VERSION).tar.gz

GMP_INSTDIR:=$(BUILD_DIR)/gmp/gmp_inst
MPC_INSTDIR:=$(BUILD_DIR)/mpc/mpc_inst
MPFR_INSTDIR:=$(BUILD_DIR)/mpfr/mpfr_inst
TEXINFO_INSTDIR:=$(BUILD_DIR)/texinfo/texinfo_inst

GCC_DEPS:= \
	$(BUILD_DIR)/gmp/gmp.build	 \
	$(BUILD_DIR)/mpfr/mpfr.build \
	$(BUILD_DIR)/mpc/mpc.build	 \
	$(BUILD_DIR)/texinfo/texinfo.build

ifeq (linux_x86_64,$(BUILD_ARCH))
ABI:=64
else
ABI:=32
endif	

else

$(GMP_PKG) : 
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(GMP_SRC_URL)"
	$(Q)$(WGET) -O $@ $(GMP_SRC_URL)
	
$(MPFR_PKG) : 
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(MPFR_SRC_URL)"
	$(Q)$(WGET) -O $@ $(MPFR_SRC_URL)
	
$(MPC_PKG) : 
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(MPC_SRC_URL)"
	$(Q)$(WGET) -O $@ $(MPC_SRC_URL)

$(TEXINFO_PKG) :
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(TEXINFO_SRC_URL)"
	$(Q)$(WGET) -O $@ $(TEXINFO_SRC_URL)

$(BUILD_DIR)/gmp/gmp.build : $(GMP_PKG)
	$(Q)$(MKDIRS)
	$(Q)rm -rf $(BUILD_DIR)/gmp
	$(Q)mkdir -p $(BUILD_DIR)/gmp
	$(Q)cd $(BUILD_DIR)/gmp ; $(UNTARBZ2) $(GMP_PKG)
	$(Q)cd $(BUILD_DIR)/gmp/gmp-$(GMP_VERSION); \
	  export ABI=$(ABI); \
	  ./configure --prefix=$(GMP_INSTDIR) --disable-shared 
	$(Q)cd $(BUILD_DIR)/gmp/gmp-$(GMP_VERSION); $(MAKE)
	$(Q)cd $(BUILD_DIR)/gmp/gmp-$(GMP_VERSION); $(MAKE) install
	$(Q)touch $@

$(BUILD_DIR)/mpc/mpc.build : \
	$(MPC_PKG) \
	$(BUILD_DIR)/gmp/gmp.build \
	$(BUILD_DIR)/mpfr/mpfr.build 
	$(Q)$(MKDIRS)
	$(Q)rm -rf $(BUILD_DIR)/mpc
	$(Q)mkdir -p $(BUILD_DIR)/mpc
	$(Q)cd $(BUILD_DIR)/mpc ; $(UNTARGZ) $(MPC_PKG)
	$(Q)cd $(BUILD_DIR)/mpc/mpc-$(MPC_VERSION); \
	  ./configure --prefix=$(MPC_INSTDIR) --disable-shared \
	    --with-gmp=$(GMP_INSTDIR) \
	    --with-mpfr=$(MPFR_INSTDIR) 
	$(Q)cd $(BUILD_DIR)/mpc/mpc-$(MPC_VERSION); $(MAKE)
	$(Q)cd $(BUILD_DIR)/mpc/mpc-$(MPC_VERSION); $(MAKE) install
	$(Q)touch $@

$(BUILD_DIR)/mpfr/mpfr.build : $(MPFR_PKG)
	$(Q)$(MKDIRS)
	$(Q)rm -rf $(BUILD_DIR)/mpfr
	$(Q)mkdir -p $(BUILD_DIR)/mpfr
	$(Q)cd $(BUILD_DIR)/mpfr ; $(UNTARBZ2) $(MPFR_PKG)
	$(Q)cd $(BUILD_DIR)/mpfr/mpfr-$(MPFR_VERSION); \
	  ./configure --prefix=$(MPFR_INSTDIR) --disable-shared \
	    --with-gmp=$(GMP_INSTDIR)
	$(Q)cd $(BUILD_DIR)/mpfr/mpfr-$(MPFR_VERSION); $(MAKE)
	$(Q)cd $(BUILD_DIR)/mpfr/mpfr-$(MPFR_VERSION); $(MAKE) install
	$(Q)touch $@

$(BUILD_DIR)/texinfo/texinfo.build : $(TEXINFO_PKG)
	$(Q)$(MKDIRS)
	$(Q)rm -rf $(BUILD_DIR)/texinfo
	$(Q)mkdir -p $(BUILD_DIR)/texinfo
	$(Q)cd $(BUILD_DIR)/texinfo ; $(UNTARGZ) $(TEXINFO_PKG)
	$(Q)cd $(BUILD_DIR)/texinfo/texinfo-$(TEXINFO_VERSION); \
	  ./configure --prefix=$(TEXINFO_INSTDIR)
	$(Q)cd $(BUILD_DIR)/texinfo/texinfo-$(TEXINFO_VERSION); $(MAKE)
	$(Q)cd $(BUILD_DIR)/texinfo/texinfo-$(TEXINFO_VERSION); $(MAKE) install
	$(Q)touch $@

endif
