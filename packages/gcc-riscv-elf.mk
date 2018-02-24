
ifneq (true,$(RULES))

# Definitions for packages
GCC_RISCV_ELF_VERSION := 7.1.1

RISCV_BINUTILS_URL:=https://github.com/riscv/riscv-binutils-gdb/archive/riscv-binutils-2.29.zip
RISCV_BINUTILS_DIR:=riscv-binutils-gdb-riscv-binutils-2.29
RISCV_BINUTILS_SRC:=$(PKG_SRC_DIR)/$(RISCV_BINUTILS_DIR).zip

RISCV_GCC_URL:=https://github.com/riscv/riscv-gcc/archive/riscv-gcc-7.zip
RISCV_GCC_DIR:=riscv-gcc-riscv-gcc-7
RISCV_GCC_ZIP:=$(PKG_SRC_DIR)/$(RISCV_GCC_DIR).zip

RISCV_NEWLIB_URL:=https://github.com/riscv/riscv-newlib/archive/riscv-newlib-2.5.0.zip
RISCV_NEWLIB_DIR:=riscv-newlib-riscv-newlib-2.5.0
RISCV_NEWLIB_ZIP:=$(PKG_SRC_DIR)/$(RISCV_NEWLIB_DIR).zip

PATH:=$(TEXINFO_INSTDIR)/bin:$(PATH)
export PATH

else

# Rules for packages

$(RISCV_BINUTILS_SRC) :
	$(Q)$(MK_PKG_SRC_DIR)
	$(Q)echo "Download $(RISCV_BINUTILS_SRC)"
	$(Q)$(WGET) -O $@ $(RISCV_BINUTILS_URL)

$(PKG_RESULT_DIR)/gcc-riscv%-elf.tar.bz2 : $(BUILD_DIR)/gcc-riscv%-elf.build
	$(Q)echo "Copying GCC riscv$(*) Result Files"
	$(Q)rm -rf $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf
	$(Q)mkdir -p $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf
	$(Q)mkdir -p $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf/gcc-riscv$(*)-elf-$(GCC_RISCV_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)cp -r $(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/* \
		$(PKG_RESULT_DIR)/gcc-riscv$(*)-elf/gcc-riscv$(*)-elf-$(GCC_RISCV_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)echo "Packing $@"
	$(Q)cd $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf ; \
		$(TARBZ) $@ gcc-riscv$(*)-elf-$(GCC_RISCV_ELF_VERSION)-$(BUILD_ARCH)
	$(Q)rm -rf $(PKG_RESULT_DIR)/gcc-riscv$(*)-elf


$(BUILD_DIR)/gcc-riscv%-elf/binutils.build : \
		$(GCC_DEPS) \
		$(BUILD_DIR)/gcc-riscv-elf/binutils.unpack
	$(Q)$(MKDIRS)
	$(Q)echo "Configuring binutils"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils 
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils 
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	  ../../gcc-riscv-elf/$(RISCV_BINUTILS_DIR)/configure \
		--prefix=$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir \
	    --target=riscv$(*)-unknown-elf --disable-tcl --disable-tk \
	    --disable-itcl --disable-gdbtk --disable-winsup --disable-libgui \
	    --disable-rda --disable-sid --disable-sim --with-sysroot
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils ; $(MAKE) 
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils ; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/binutils
	$(Q)touch $@

$(BUILD_DIR)/gcc-riscv-elf/binutils.unpack : $(RISCV_BINUTILS_SRC)
	$(Q)$(MKDIRS)
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv-elf
	$(Q)echo "Unpacking $(RISCV_BINUTILS_SRC)"
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; $(UNZIP) $(RISCV_BINUTILS_SRC)
	$(Q)touch $@

$(RISCV_GCC_ZIP) :
	$(Q)$(MKDIRS)
	$(Q)$(WGET) -O $@ $(RISCV_GCC_URL)

$(BUILD_DIR)/gcc-riscv-elf/riscv-gcc.unpack : $(RISCV_GCC_ZIP)
	$(Q)$(MKDIRS)
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv-elf
	$(Q)echo "Unpacking $(RISCV_GCC_ZIP)"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv-elf/$(RISCV_GCC_DIR)
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; $(UNZIP) $^
	$(Q)touch $@

	
$(BUILD_DIR)/gcc-riscv%-elf/gcc_phase1.build : \
		$(GCC_DEPS) \
		$(BUILD_DIR)/gcc-riscv%-elf/binutils.build \
		$(BUILD_DIR)/gcc-riscv-elf/riscv-gcc.unpack
	$(Q)$(MKDIRS)
	$(Q)echo "Configuring GCC"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc
	$(Q)mkdir $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	    ../../gcc-riscv-elf/$(RISCV_GCC_DIR)/configure \
		--target=riscv$(*)-unknown-elf \
	    --prefix=$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir \
	    --enable-languages=c --disable-shared --disable-libssp \
	    --with-gmp=$(GMP_INSTDIR) \
	    --with-mpc=$(MPC_INSTDIR) \
	    --with-mpfr=$(MPFR_INSTDIR) 
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; $(MAKE)
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; $(MAKE) install
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc
	$(Q)touch $@

$(RISCV_NEWLIB_ZIP) :
	$(Q)$(MKDIRS)
	$(Q)$(WGET) -O $@ $(RISCV_NEWLIB_URL)

$(BUILD_DIR)/gcc-riscv-elf/riscv-newlib.unpack : $(RISCV_NEWLIB_ZIP)
	$(Q)$(MKDIRS)
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv-elf/$(RISCV_NEWLIB_DIR)
	$(Q)echo "Unpacking $(RISCV_NEWLIB_ZIP)"
	$(Q)cd $(BUILD_DIR)/gcc-riscv-elf ; $(UNZIP) $^
	$(Q)touch $@


$(BUILD_DIR)/gcc-riscv%-elf/newlib.build : \
	$(BUILD_DIR)/gcc-riscv%-elf/gcc_phase1.build \
	$(BUILD_DIR)/gcc-riscv-elf/riscv-newlib.unpack
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/newlib
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv$(*)-elf/newlib
	$(Q)echo "Configuring newlib"
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/newlib ; \
	    export PATH="$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir/bin:$(PATH)"; \
		export CFLAGS=-Wno-error=discarded-qualifiers; \
	    ../../gcc-riscv-elf/$(RISCV_NEWLIB_DIR)/configure \
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
	$(Q)echo "Building gcc-riscv$(*) gcc_phase2"
	$(Q)rm -rf $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc-phase2
	$(Q)mkdir -p $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc-phase2
	$(Q)cd $(BUILD_DIR)/gcc-riscv$(*)-elf/gcc-phase2; \
      export CFLAGS=-Wno-error=discarded-qualifiers;  \
	  ../../gcc-riscv-elf/$(RISCV_GCC_DIR)/configure \
		--target=riscv$(*)-unknown-elf \
	    --prefix=$(BUILD_DIR)/gcc-riscv$(*)-elf/installdir \
	    --enable-languages=c,c++ --disable-shared --disable-libssp \
		--with-newlib \
	    --with-gmp=$(GMP_INSTDIR) \
	    --with-mpc=$(MPC_INSTDIR) \
	    --with-mpfr=$(MPFR_INSTDIR) 
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
