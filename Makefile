# -*- Makefile -*- for zlib

.SECONDEXPANSION:
.SUFFIXES:

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
        QUIET          = @
        QUIET_CC       = @echo '   ' CC $<;
        QUIET_AR       = @echo '   ' AR $@;
        QUIET_RANLIB   = @echo '   ' RANLIB $@;
        QUIET_INSTALL  = @echo '   ' INSTALL $<;
        export V
endif
endif

LIB    = libz.a
AR    ?= ar
ARFLAGS ?= rc
CC    ?= gcc
RANLIB?= ranlib
RM    ?= rm -f

BUILD_DIR := build
BUILD_ID  ?= default-build-id
OBJ_DIR   := $(BUILD_DIR)/$(BUILD_ID)

ifeq (,$(BUILD_ID))
$(error BUILD_ID cannot be an empty string)
endif

uname_M := $(shell uname -m || echo not)
ifeq ($(uname_M),aarch64)
uname_M := arm64
endif
ifneq ($(ARCH),)
uname_M := $(ARCH)
endif

prefix ?= /usr/local
libdir := $(prefix)/lib
includedir := $(prefix)/include

HEADERS = zlib.h zconf.h zlib_name_mangling.h
SOURCES = \
    adler32.c \
    compress.c \
    cpu_features.c \
    crc32_braid_comb.c \
    crc32.c \
    deflate_fast.c \
    deflate_huff.c \
    deflate_medium.c \
    deflate_quick.c \
    deflate_rle.c \
    deflate_slow.c \
    deflate_stored.c \
    deflate.c \
    functable.c \
    gzlib.c \
    gzwrite.c \
    infback.c \
    inflate.c \
    inftrees.c \
    insert_string_roll.c \
    insert_string.c \
    trees.c \
    uncompr.c \
    zutil.c

SOURCES += \
    arch/generic/adler32_c.c \
    arch/generic/adler32_fold_c.c \
    arch/generic/chunkset_c.c \
    arch/generic/compare256_c.c \
    arch/generic/crc32_braid_c.c \
    arch/generic/crc32_c.c \
    arch/generic/crc32_chorba_c.c \
    arch/generic/crc32_fold_c.c \
    arch/generic/slide_hash_c.c

ifeq ($(uname_M),arm64)
SOURCES += \
    arch/arm/adler32_neon.c \
    arch/arm/arm_features.c \
    arch/arm/chunkset_neon.c \
    arch/arm/compare256_neon.c \
    arch/arm/crc32_armv8.c \
    arch/arm/slide_hash_armv6.c \
    arch/arm/slide_hash_neon.c
endif

ifeq ($(uname_M),x86_64)
SOURCES += \
    arch/x86/adler32_avx2.c \
    arch/x86/adler32_avx512_vnni.c \
    arch/x86/adler32_avx512.c \
    arch/x86/adler32_sse42.c \
    arch/x86/adler32_ssse3.c \
    arch/x86/chorba_sse2.c \
    arch/x86/chorba_sse41.c \
    arch/x86/chunkset_avx2.c \
    arch/x86/chunkset_avx512.c \
    arch/x86/chunkset_sse2.c \
    arch/x86/chunkset_ssse3.c \
    arch/x86/compare256_avx2.c \
    arch/x86/compare256_avx512.c \
    arch/x86/compare256_sse2.c \
    arch/x86/crc32_pclmulqdq.c \
    arch/x86/crc32_vpclmulqdq.c \
    arch/x86/slide_hash_avx2.c \
    arch/x86/slide_hash_sse2.c \
    arch/x86/x86_features.c
endif

HEADERS_INST := $(patsubst %,$(includedir)/%,$(HEADERS))
OBJECTS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(SOURCES))

CFLAGS ?= -O2

CFLAGS += \
    -I. \
    -DZLIB_COMPAT \
    -D_GNU_SOURCE \
    -DHAVE_ATTRIBUTE_ALIGNED \
    -DHAVE_BUILTIN_ASSUME_ALIGNED \
    -DHAVE_BUILTIN_CTZ \
    -DHAVE_BUILTIN_CTZLL

ifeq ($(uname_M),arm64)
CFLAGS += \
    -DARM_FEATURES \
    -DARM_CRC32 \
    -DARM_NEON \
    -DARM_NEON_HASLD4
endif

ifeq ($(uname_M),x86_64)
CFLAGS += \
    -DHAVE_CPUID_GNU \
    -DX86_FEATURES \
    -DX86_SSE2 \
    -DX86_SSE41 \
    -DX86_SSE42 \
    -DX86_SSSE3
endif

.PHONY: install

all: $(OBJ_DIR)/$(LIB)

$(includedir)/%.h: %.h
	-@if [ ! -d $(includedir)  ]; then mkdir -p $(includedir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

$(libdir)/%.a: $(OBJ_DIR)/%.a
	-@if [ ! -d $(libdir)  ]; then mkdir -p $(libdir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

install: $(HEADERS_INST) $(libdir)/$(LIB)

clean:
	$(RM) -r $(OBJ_DIR)

distclean:
	$(RM) -r $(BUILD_DIR)

$(OBJ_DIR)/$(LIB): $(OBJECTS) | $$(@D)/.
	$(QUIET_AR)$(AR) $(ARFLAGS) $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

$(OBJ_DIR)/%.o: %.c $(OBJ_DIR)/.cflags | $$(@D)/.
	$(QUIET_CC)$(CC) $(CFLAGS) -o $@ -c $<

.PRECIOUS: $(OBJ_DIR)/. $(OBJ_DIR)%/.

$(OBJ_DIR)/.:
	$(QUIET)mkdir -p $@

$(OBJ_DIR)%/.:
	$(QUIET)mkdir -p $@

TRACK_CFLAGS = $(subst ','\'',$(CC) $(CFLAGS))

$(OBJ_DIR)/.cflags: .force-cflags | $$(@D)/.
	@FLAGS='$(TRACK_CFLAGS)'; \
	if test x"$$FLAGS" != x"`cat $(OBJ_DIR)/.cflags 2>/dev/null`" ; then \
		echo "    * rebuilding zlib: new build flags or prefix"; \
		echo "$$FLAGS" > $(OBJ_DIR)/.cflags; \
	fi

.PHONY: .force-cflags
