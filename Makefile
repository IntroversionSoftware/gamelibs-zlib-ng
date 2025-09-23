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
    insert_string.c \
    trees.c \
    uncompr.c \
    zutil.c

SOURCES += \
    arch/generic/adler32_c.c \
    arch/generic/chunkset_c.c \
    arch/generic/compare256_c.c \
    arch/generic/crc32_braid_c.c \
    arch/generic/crc32_chorba_c.c \
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

# ARM files that need -fno-lto
ARM_ARCH_FILES = \
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

# Group x86 files by their required compiler flags
X86_FEATURES_FILES = arch/x86/x86_features.c

SSE2_FILES = \
    arch/x86/chorba_sse2.c \
    arch/x86/chunkset_sse2.c \
    arch/x86/compare256_sse2.c \
    arch/x86/slide_hash_sse2.c

SSSE3_FILES = \
    arch/x86/adler32_ssse3.c \
    arch/x86/chunkset_ssse3.c

SSE41_FILES = arch/x86/chorba_sse41.c

SSE42_FILES = arch/x86/adler32_sse42.c

AVX2_FILES = \
    arch/x86/adler32_avx2.c \
    arch/x86/chunkset_avx2.c \
    arch/x86/compare256_avx2.c \
    arch/x86/slide_hash_avx2.c

AVX512_FILES = \
    arch/x86/adler32_avx512.c \
    arch/x86/compare256_avx512.c

AVX512_VNNI_FILES = arch/x86/adler32_avx512_vnni.c

AVX512_BMI2_FILES = arch/x86/chunkset_avx512.c

PCLMUL_FILES = arch/x86/crc32_pclmulqdq.c

VPCLMUL_FILES = arch/x86/crc32_vpclmulqdq.c
endif

HEADERS_INST := $(patsubst %,$(includedir)/%,$(HEADERS))
OBJECTS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(SOURCES))

CFLAGS ?= -O2

CFLAGS += \
    -I. \
    -DZLIB_COMPAT \
    -D_GNU_SOURCE \
    -DWITH_ALL_FALLBACKS \
    -DWITH_OPTIM \
    -DHAVE_ATTRIBUTE_ALIGNED \
    -DHAVE_BUILTIN_ASSUME_ALIGNED \
    -DHAVE_BUILTIN_CTZ \
    -DHAVE_BUILTIN_CTZLL

ifeq ($(uname_M),arm64)
CFLAGS += \
    -DARCH_ARM \
    -DARCH_64BIT \
    -DARM_FEATURES \
    -DARM_CRC32 \
    -DARM_NEON \
    -DARM_NEON_HASLD4
endif

ifeq ($(uname_M),x86_64)
CFLAGS += \
    -DARCH_X86 \
    -DARCH_64BIT \
    -DHAVE_CPUID_GNU \
    -DX86_AVX2 \
    -DX86_AVX512 \
    -DX86_AVX512VNNI \
    -DX86_FEATURES \
    -DX86_HAVE_XSAVE_INTRIN \
    -DX86_PCLMULQDQ_CRC \
    -DX86_SSE2 \
    -DX86_SSE41 \
    -DX86_SSE42 \
    -DX86_SSSE3 \
    -DX86_VPCLMULQDQ_CRC
endif

# Need to remove -fwhole-program-vtables because it depends on -flto
CFLAGS := $(filter-out -flto -fwhole-program-vtables,$(CFLAGS))

# Target-specific variable assignments for architecture-specific files
ifeq ($(uname_M),arm64)
$(patsubst %.c,$(OBJ_DIR)/%.o,$(ARM_ARCH_FILES)): EXTRA_CFLAGS = -fno-lto
endif

ifeq ($(uname_M),x86_64)
$(patsubst %.c,$(OBJ_DIR)/%.o,$(X86_FEATURES_FILES)): EXTRA_CFLAGS = -fno-lto -mxsave
$(patsubst %.c,$(OBJ_DIR)/%.o,$(SSE2_FILES)): EXTRA_CFLAGS = -fno-lto -msse2
$(patsubst %.c,$(OBJ_DIR)/%.o,$(SSSE3_FILES)): EXTRA_CFLAGS = -fno-lto -mssse3
$(patsubst %.c,$(OBJ_DIR)/%.o,$(SSE41_FILES)): EXTRA_CFLAGS = -fno-lto -msse4.1
$(patsubst %.c,$(OBJ_DIR)/%.o,$(SSE42_FILES)): EXTRA_CFLAGS = -fno-lto -msse4.2
$(patsubst %.c,$(OBJ_DIR)/%.o,$(AVX2_FILES)): EXTRA_CFLAGS = -fno-lto -mavx2
$(patsubst %.c,$(OBJ_DIR)/%.o,$(AVX512_FILES)): EXTRA_CFLAGS = -fno-lto -mavx512f -mavx512bw -mavx512vl
$(patsubst %.c,$(OBJ_DIR)/%.o,$(AVX512_VNNI_FILES)): EXTRA_CFLAGS = -fno-lto -mavx512f -mavx512bw -mavx512vl -mavx512vnni
$(patsubst %.c,$(OBJ_DIR)/%.o,$(AVX512_BMI2_FILES)): EXTRA_CFLAGS = -fno-lto -mavx512f -mavx512bw -mavx512vl -mbmi2
$(patsubst %.c,$(OBJ_DIR)/%.o,$(PCLMUL_FILES)): EXTRA_CFLAGS = -fno-lto -mpclmul -mssse3
$(patsubst %.c,$(OBJ_DIR)/%.o,$(VPCLMUL_FILES)): EXTRA_CFLAGS = -fno-lto -mpclmul -mavx512f -mvpclmulqdq -mavx512dq
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
	$(QUIET_CC)$(CC) $(CFLAGS) $(EXTRA_CFLAGS) -o $@ -c $<

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
