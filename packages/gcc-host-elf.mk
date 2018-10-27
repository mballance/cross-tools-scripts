
ifneq (true,$(RULES))

# Definitions for packages
GCC_HOST_ELF_VERSION := 7.3.0

#HOST_BINUTILS_URL:=https://github.com/riscv/riscv-binutils-gdb/archive/riscv-binutils-2.29.zip
HOST_BINUTILS_URL:=$(GNU_MIRROR_URL)/binutils/binutils-2.30.tar.bz2
HOST_BINUTILS_DIR:=binutils-2.30
HOST_BINUTILS_SRC:=$(PKG_SRC_DIR)/$(HOST_BINUTILS_DIR).tar.bz2

# HOST_GCC_URL:=https://github.com/riscv/riscv-gcc/archive/riscv-gcc-7.zip
HOST_GCC_URL:=$(GNU_MIRROR_URL)/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz
# HOST_GCC_DIR:=riscv-gcc-riscv-gcc-7
HOST_GCC_DIR:=gcc-7.3.0
HOST_GCC_ZIP:=$(PKG_SRC_DIR)/$(HOST_GCC_DIR).tar.gz

HOST_NEWLIB_URL:=https://github.com/riscv/riscv-newlib/archive/newlib-3.0.0.tar.gz
HOST_NEWLIB_DIR:=riscv-newlib-newlib-3.0.0
HOST_NEWLIB_ZIP:=$(PKG_SRC_DIR)/$(HOST_NEWLIB_DIR).tar.gz

ISL_URL:=ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2
ISL_DIR:=isl-0.18
ISL_ZIP:=$(PKG_SRC_DIR)/$(ISL_DIR).tar.bz2

PATH:=$(TEXINFO_INSTDIR)/bin:$(PATH)
export PATH

else

# Rules for packages
#
# EXTRA_CFLAGS:="export CFLAGS=-Wno-error=discarded-qualifiers";

$(HOST_BINUTILS_SRC) :
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(HOST_BINUTILS_SRC)"
	$(Q)$(WGET) -O $@ $(HOST_BINUTILS_URL)

$(PKG_RESULT_DIR)/gcc-riscv%-elf.tar.bz2 : $(BUILD_DIR)/gcc-riscv%-elf.build
	$(Q)echo "Copying GCC riscv$(*) Result Files"
	$(Q)rm -rf $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf
	$(Q)mkdir -p $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf
	$(Q)mkdir -p $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf/gcc-riscv$(*)-elf-$(GCC_HOST_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)cp -r $(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/* \
		$(PKG_RESULT_DIR)/gcc-riscv$(*)-elf/gcc-riscv$(*)-elf-$(GCC_HOST_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)echo "Packing $@"
	$(Q)cd $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf ; \
		$(TARBZ) $@ gcc-riscv$(*)-elf-$(GCC_HOST_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)rm -rf $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf


$(BUILD_DIR)/gcc-riscv%-elf/binutils.build : \
		$(BUILD_DIR)/texinfo/texinfo.build \
		$(BUILD_DIR)/gcc-riscv-elf/binutils.unpack
	$(Q)if test ! -d `dirname $@`; then mkdir -p `dirname $@`; fi
	$(Q)$(MKDIRS)
	$(Q)echo "Configuring binutils"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils 
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils 
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils; \
		$(EXTRA_CFLAGS) \
	  ../../gcc-riscv-elf/$(HOST_BINUTILS_DIR)/configure \
		--prefix=$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir \
	    --target=riscv$(*)-unknown-elf --disable-tcl --disable-tk \
	    --disable-itcl --disable-gdbtk --disable-winsup --disable-libgui \
		--disable-python \
	    --disable-rda --disable-sid --disable-sim --with-sysroot
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils ; $(MAKE) 
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils ; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils
	$(Q)touch $@

$(BUILD_DIR)/gcc-riscv-elf/binutils.unpack : $(HOST_BINUTILS_SRC)
	$(Q)if test ! -d `dirname $@`; then mkdir -p `dirname $@`; fi
	$(Q)$(MKDIRS)
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv-elf
	$(Q)echo "Unpacking $(HOST_BINUTILS_SRC)"
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; $(UNTARBZ2) $(HOST_BINUTILS_SRC)
	$(Q)touch $@

$(HOST_GCC_ZIP) :
	$(Q)$(MKDIRS)
	$(Q)$(WGET) -O $@ $(HOST_GCC_URL)

$(ISL_ZIP) :
	$(Q)$(MKDIRS)
	$(Q)$(WGET) -O $@ $(ISL_URL)

$(BUILD_DIR)/gcc-riscv-elf/riscv-gcc.unpack : \
	$(HOST_GCC_ZIP) \
	$(GMP_PKG)  \
	$(MPFR_PKG) \
	$(MPC_PKG)  \
	$(ISL_ZIP)
	$(Q)if test ! -d `dirname $@`; then mkdir -p `dirname $@`; fi
	$(Q)$(MKDIRS)
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv-elf
	$(Q)echo "Unpacking $(HOST_GCC_ZIP)"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv-elf/$(HOST_GCC_DIR)
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; $(UNTARGZ) $(HOST_GCC_ZIP)
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; \
		$(UNTARBZ2) $(GMP_PKG) ; mv gmp-$(GMP_VERSION) $(HOST_GCC_DIR)/gmp
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; \
		$(UNTARGZ) $(MPC_PKG) ; mv mpc-$(MPC_VERSION) $(HOST_GCC_DIR)/mpc
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; \
		$(UNTARBZ2) $(MPFR_PKG) ; mv mpfr-$(MPFR_VERSION) $(HOST_GCC_DIR)/mpfr
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; \
		$(UNTARBZ2) $(ISL_ZIP) ; mv $(ISL_DIR) $(HOST_GCC_DIR)/isl
	$(Q)touch $@

	
$(BUILD_DIR)/gcc-riscv%-elf/gcc_phase1.build : \
		$(BUILD_DIR)/gcc-riscv%-elf/binutils.build \
		$(BUILD_DIR)/gcc-riscv-elf/riscv-gcc.unpack
	$(Q)$(MKDIRS)
	$(Q)echo "Configuring GCC"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc
	$(Q)mkdir $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; \
		$(EXTRA_CFLAGS) \
	    ../../gcc-riscv-elf/$(HOST_GCC_DIR)/configure \
		--target=riscv$(*)-unknown-elf \
	    --prefix=$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir \
	    --enable-languages=c --disable-shared --disable-libssp
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; $(MAKE)
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc
	$(Q)touch $@

$(HOST_NEWLIB_ZIP) :
	$(Q)$(MKDIRS)
	$(Q)$(WGET) -O $@ $(HOST_NEWLIB_URL)

$(BUILD_DIR)/gcc-riscv-elf/riscv-newlib.unpack : $(HOST_NEWLIB_ZIP)
	$(Q)if test ! -d `dirname $@`; then mkdir -p `dirname $@`; fi
	$(Q)$(MKDIRS)
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv-elf/$(HOST_NEWLIB_DIR)
	$(Q)echo "Unpacking $(HOST_NEWLIB_ZIP)"
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; $(UNTARGZ) $^
	$(Q)touch $@


$(BUILD_DIR)/gcc-riscv%-elf/newlib.build : \
	$(BUILD_DIR)/gcc-riscv%-elf/gcc_phase1.build \
	$(BUILD_DIR)/gcc-riscv-elf/riscv-newlib.unpack
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/newlib
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv$(*)-elf/newlib
	$(Q)echo "Configuring newlib"
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/newlib ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; \
		$(EXTRA_CFLAGS) \
	    ../../gcc-riscv-elf/$(HOST_NEWLIB_DIR)/configure \
			--prefix=$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir \
			--target=riscv$(*)-unknown-elf
	$(Q)echo "Building newlib"
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/newlib ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; \
		$(MAKE) 
	$(Q)echo "Installing newlib"
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/newlib ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; \
			$(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/newlib
	$(Q)touch $@

	
$(BUILD_DIR)/gcc-riscv%-elf/gcc_phase2.build : \
	$(BUILD_DIR)/gcc-riscv%-elf/newlib.build 
	$(Q)if test ! -d `dirname $@`; then mkdir -p `dirname $@`; fi
	$(Q)echo "Building gcc-riscv$(*) gcc_phase2"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc-phase2
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc-phase2
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc-phase2; \
          $(EXTRA_CFLAGS) \
	  ../../gcc-riscv-elf/$(HOST_GCC_DIR)/configure \
		--target=riscv$(*)-unknown-elf \
	    --prefix=$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir \
	    --enable-languages=c,c++ --disable-shared --disable-libssp \
		--with-newlib 
	$(Q)echo "Building gcc phase2"
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc-phase2; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; $(MAKE) 
	$(Q)echo "Installing gcc phase2"
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc-phase2; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc-phase2
	$(Q)touch $@
	
#$(BUILD_DIR)/gcc-riscv%-elf.build : \
#		$(BUILD_DIR)/gcc-riscv%-elf/gcc_phase1.build \
#		$(BUILD_DIR)/gcc-riscv%-elf/newlib.build     \
#		$(BUILD_DIR)/gcc-riscv%-elf/gcc_phase2.build 
#	$(Q)touch $@
#
$(BUILD_DIR)/gcc-riscv%-elf.build : \
		$(BUILD_DIR)/gcc-riscv%-elf/gcc_phase1.build \
		$(BUILD_DIR)/gcc-riscv%-elf/newlib.build     \
		$(BUILD_DIR)/gcc-riscv%-elf/gcc_phase2.build 
	$(Q)touch $@
	
endif
